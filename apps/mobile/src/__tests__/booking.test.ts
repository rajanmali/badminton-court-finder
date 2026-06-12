import { getBookingAction } from '../utils/booking';

const base = { bookingUrl: '', phone: null, email: null };

describe('getBookingAction', () => {
  it('returns url action when bookingUrl is set', () => {
    const result = getBookingAction({ ...base, bookingUrl: 'https://example.com/book' });
    expect(result).toEqual({ type: 'url', label: 'Book a court', href: 'https://example.com/book' });
  });

  it('returns phone action when bookingUrl is empty and phone is set', () => {
    const result = getBookingAction({ ...base, phone: '02 9123 4567' });
    expect(result).toEqual({ type: 'phone', label: 'Call venue', href: 'tel:0291234567' });
  });

  it('strips spaces from phone number in href', () => {
    const result = getBookingAction({ ...base, phone: '(02) 9911 6300' });
    expect(result.type).toBe('phone');
    if (result.type === 'phone') expect(result.href).toBe('tel:(02)99116300');
  });

  it('returns email action when bookingUrl and phone are both absent', () => {
    const result = getBookingAction({ ...base, email: 'info@venue.com.au' });
    expect(result).toEqual({ type: 'email', label: 'Email venue', href: 'mailto:info@venue.com.au' });
  });

  it('prefers url over phone', () => {
    const result = getBookingAction({ bookingUrl: 'https://book.me', phone: '0400000000', email: null });
    expect(result.type).toBe('url');
  });

  it('prefers phone over email when no bookingUrl', () => {
    const result = getBookingAction({ ...base, phone: '0400000000', email: 'a@b.com' });
    expect(result.type).toBe('phone');
  });

  it('returns none when all contact options are absent', () => {
    expect(getBookingAction(base)).toEqual({ type: 'none' });
  });
});
