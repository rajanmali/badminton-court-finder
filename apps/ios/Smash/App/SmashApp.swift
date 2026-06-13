import SwiftUI

@main
struct SmashApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    var body: some View {
        VStack(spacing: Spacing.md) {
            Text("Smash")
                .font(.system(size: Typography.Size.xxl, weight: Typography.weight(.bold)))
                .foregroundStyle(Color.smashPrimary)
            Text("Find badminton courts near you.")
                .font(.system(size: Typography.Size.md, weight: Typography.weight(.regular)))
                .foregroundStyle(Color.smashTextSecondary)
        }
        .padding(Spacing.lg)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.smashBackground)
    }
}

#Preview {
    ContentView()
}
