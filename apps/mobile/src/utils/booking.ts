export type BookingAction =
  | { type: 'url'; label: string; href: string }
  | { type: 'phone'; label: string; href: string }
  | { type: 'email'; label: string; href: string }
  | { type: 'none' };

export function getBookingAction(venue: {
  bookingUrl: string;
  phone: string | null;
  email: string | null;
}): BookingAction {
  if (venue.bookingUrl) {
    return { type: 'url', label: 'Book a court', href: venue.bookingUrl };
  }
  if (venue.phone) {
    return { type: 'phone', label: 'Call venue', href: `tel:${venue.phone.replace(/\s+/g, '')}` };
  }
  if (venue.email) {
    return { type: 'email', label: 'Email venue', href: `mailto:${venue.email}` };
  }
  return { type: 'none' };
}
