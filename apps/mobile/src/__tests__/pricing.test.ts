import { formatPriceCents } from '../utils/pricing';

describe('formatPriceCents', () => {
  it('formats whole-dollar amounts without decimal', () => {
    expect(formatPriceCents(2900)).toBe('$29/hr');
  });

  it('formats round hundreds', () => {
    expect(formatPriceCents(3600)).toBe('$36/hr');
  });

  it('returns canonical phrase for null', () => {
    expect(formatPriceCents(null)).toBe('Rates not listed');
  });

  it('formats zero', () => {
    expect(formatPriceCents(0)).toBe('$0/hr');
  });

  it('rounds down sub-cent values', () => {
    expect(formatPriceCents(2150)).toBe('$22/hr');
  });
});
