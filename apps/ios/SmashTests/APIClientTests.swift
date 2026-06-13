import Foundation
import Testing
@testable import Smash

// MARK: - Canned Outcome

/// A single stubbed response outcome for `StubURLProtocol`.
enum StubOutcome: Sendable {
    case response(statusCode: Int, data: Data)
    case error(URLError)
}

// MARK: - StubURLProtocol

/// A `URLProtocol` subclass that serves pre-registered canned outcomes in
/// FIFO order.
///
/// ## Swift 6.2 / MainActor-default isolation note
/// `SWIFT_DEFAULT_ACTOR_ISOLATION = MainActor` in this project makes every
/// method in every file implicitly `@MainActor` unless opted out. All
/// `URLProtocol` overridable members are declared `nonisolated` in the base
/// class, so we must explicitly annotate each override and all state with
/// `nonisolated` / `nonisolated(unsafe)` to match.
final class StubURLProtocol: URLProtocol {

    // All mutable state is `nonisolated(unsafe)` and protected by `_lock` at
    // runtime. This is the canonical Swift 6 pattern for legacy-lock-guarded
    // global state that cannot be expressed as a Sendable actor.
    nonisolated(unsafe) private static var _lock = NSLock()
    nonisolated(unsafe) private static var pendingOutcomes: [StubOutcome] = []
    nonisolated(unsafe) private static var _attemptCount: Int = 0

    // MARK: Setup helpers

    nonisolated static func register(outcomes: [StubOutcome]) {
        _lock.withLock {
            pendingOutcomes = outcomes
            _attemptCount = 0
        }
    }

    nonisolated static var attemptCount: Int {
        _lock.withLock { _attemptCount }
    }

    // MARK: URLProtocol — designated init
    // Must be nonisolated to match URLProtocol's nonisolated declaration.
    nonisolated override init(
        request: URLRequest,
        cachedResponse: CachedURLResponse?,
        client: (any URLProtocolClient)?
    ) {
        super.init(request: request, cachedResponse: cachedResponse, client: client)
    }

    // MARK: URLProtocol overrides

    nonisolated override class func canInit(with request: URLRequest) -> Bool {
        true
    }

    nonisolated override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }

    nonisolated override func startLoading() {
        let outcome: StubOutcome = Self._lock.withLock {
            Self._attemptCount += 1
            guard !Self.pendingOutcomes.isEmpty else {
                return .error(URLError(.unknown))
            }
            return Self.pendingOutcomes.removeFirst()
        }

        switch outcome {
        case .response(let statusCode, let data):
            let response = HTTPURLResponse(
                url: request.url!,
                statusCode: statusCode,
                httpVersion: nil,
                headerFields: ["Content-Type": "application/json"]
            )!
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)

        case .error(let urlError):
            client?.urlProtocol(self, didFailWithError: urlError)
        }
    }

    nonisolated override func stopLoading() {}
}

// MARK: - JSON Fixtures

private let venueListResponseJSON = """
{
    "venues": [
        {
            "id": "venue-001",
            "name": "Test Badminton Centre",
            "suburb": "Testville",
            "lat": -33.9,
            "lng": 151.2,
            "courtCount": 4,
            "dedicatedBadminton": true,
            "distanceKm": null,
            "priceFrom": 1200,
            "hasLiveAvailability": false
        }
    ]
}
""".data(using: .utf8)!

private let venueDetailResponseJSON = """
{
    "venue": {
        "id": "venue-001",
        "name": "Test Badminton Centre",
        "suburb": "Testville",
        "lat": -33.9,
        "lng": 151.2,
        "courtCount": 4,
        "dedicatedBadminton": true,
        "distanceKm": null,
        "priceFrom": 1200,
        "hasLiveAvailability": false,
        "slug": "test-badminton-centre",
        "address": "1 Test St, Testville NSW 2000",
        "phone": null,
        "email": null,
        "bookingUrl": "https://test.example.com/book",
        "platform": "skedda",
        "rateCards": [],
        "openingHours": []
    }
}
""".data(using: .utf8)!

private let notFoundJSON = """
{"message":"Venue x not found","error":"Not Found","statusCode":404}
""".data(using: .utf8)!

private let serverErrorJSON = """
{"message":"Internal Server Error","error":"Internal Server Error","statusCode":500}
""".data(using: .utf8)!

// MARK: - Helpers

/// Builds a test `APIClient` whose session is backed by `StubURLProtocol`.
/// `retryDelay: .zero` keeps tests fast and deterministic.
private func makeTestClient() -> APIClient {
    let config = URLSessionConfiguration.ephemeral
    config.protocolClasses = [StubURLProtocol.self]
    let session = URLSession(configuration: config)
    return APIClient(
        baseURL: URL(string: "http://test.local/api/v1")!,
        session: session,
        retryCount: 2,
        retryDelay: .zero
    )
}

private func makeTestRepository(client: APIClient) -> LiveVenueRepository {
    LiveVenueRepository(apiClient: client)
}

// MARK: - Tests

@Suite("APIClient")
struct APIClientTests {

    // MARK: Test 1 — Retry then succeed

    @Test("Retries URLError twice then succeeds on third attempt")
    func retryThenSucceed() async throws {
        StubURLProtocol.register(outcomes: [
            .error(URLError(.timedOut)),
            .error(URLError(.timedOut)),
            .response(statusCode: 200, data: venueListResponseJSON)
        ])

        let client = makeTestClient()
        let repo = makeTestRepository(client: client)
        let venues = try await repo.fetchVenues()

        #expect(venues.count == 1)
        #expect(venues[0].id == "venue-001")
        #expect(StubURLProtocol.attemptCount == 3)
    }

    // MARK: Test 2 — Network failure exhausts retries

    @Test("Throws APIError.network after exhausting all retries")
    func networkFailureExhaustsRetries() async throws {
        StubURLProtocol.register(outcomes: [
            .error(URLError(.notConnectedToInternet)),
            .error(URLError(.notConnectedToInternet)),
            .error(URLError(.notConnectedToInternet))
        ])

        let client = makeTestClient()
        let repo = makeTestRepository(client: client)

        do {
            _ = try await repo.fetchVenues()
            Issue.record("Expected APIError.network to be thrown")
        } catch let error as APIError {
            if case .network = error {
                // Expected
            } else {
                Issue.record("Expected .network, got \(error)")
            }
        }

        #expect(StubURLProtocol.attemptCount == 3)
    }

    // MARK: Test 3 — 404 not retried

    @Test("404 response surfaces immediately without retrying")
    func notFoundNotRetried() async throws {
        StubURLProtocol.register(outcomes: [
            .response(statusCode: 404, data: notFoundJSON)
        ])

        let client = makeTestClient()
        let repo = makeTestRepository(client: client)

        do {
            _ = try await repo.fetchVenue(id: "x")
            Issue.record("Expected APIError.http to be thrown")
        } catch let error as APIError {
            if case .http(let statusCode, let body) = error {
                #expect(statusCode == 404)
                #expect(body?.message == "Venue x not found")
            } else {
                Issue.record("Expected .http, got \(error)")
            }
        }

        // Must be exactly 1 — 4xx must not trigger any retry.
        #expect(StubURLProtocol.attemptCount == 1)
    }

    // MARK: Test 4 — 5xx retried

    @Test("500 response is retried and throws APIError.http after all attempts")
    func serverErrorRetried() async throws {
        StubURLProtocol.register(outcomes: [
            .response(statusCode: 500, data: serverErrorJSON),
            .response(statusCode: 500, data: serverErrorJSON),
            .response(statusCode: 500, data: serverErrorJSON)
        ])

        let client = makeTestClient()
        let repo = makeTestRepository(client: client)

        do {
            _ = try await repo.fetchVenues()
            Issue.record("Expected APIError.http to be thrown")
        } catch let error as APIError {
            if case .http(let statusCode, _) = error {
                #expect(statusCode == 500)
            } else {
                Issue.record("Expected .http, got \(error)")
            }
        }

        #expect(StubURLProtocol.attemptCount == 3)
    }

    // MARK: Test 5 — Successful decode

    @Test("200 response decodes VenueDetail correctly")
    func successDecode() async throws {
        StubURLProtocol.register(outcomes: [
            .response(statusCode: 200, data: venueDetailResponseJSON)
        ])

        let client = makeTestClient()
        let repo = makeTestRepository(client: client)

        let venue = try await repo.fetchVenue(id: "venue-001")

        #expect(venue.id == "venue-001")
        #expect(venue.name == "Test Badminton Centre")
        #expect(venue.suburb == "Testville")
        #expect(venue.slug == "test-badminton-centre")
        #expect(venue.platform == .skedda)
        #expect(venue.rateCards.isEmpty)
        #expect(venue.openingHours.isEmpty)
    }
}
