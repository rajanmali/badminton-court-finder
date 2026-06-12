import { dayLabel, formatTime, formatDays } from '../utils/datetime';

describe('dayLabel', () => {
  it('maps 0 to Sun', () => expect(dayLabel(0)).toBe('Sun'));
  it('maps 1 to Mon', () => expect(dayLabel(1)).toBe('Mon'));
  it('maps 6 to Sat', () => expect(dayLabel(6)).toBe('Sat'));
  it('falls back for out-of-range', () => expect(dayLabel(7)).toBe('Day 7'));
});

describe('formatTime', () => {
  it('formats midnight as 12:00 am', () => expect(formatTime('00:00')).toBe('12:00 am'));
  it('formats noon as 12:00 pm', () => expect(formatTime('12:00')).toBe('12:00 pm'));
  it('formats 9am with leading zero hour', () => expect(formatTime('09:00')).toBe('9:00 am'));
  it('formats 10pm', () => expect(formatTime('22:00')).toBe('10:00 pm'));
  it('returns — for null', () => expect(formatTime(null)).toBe('—'));
  it('handles HH:MM:SS from Postgres', () => expect(formatTime('17:30:00')).toBe('5:30 pm'));
});

describe('formatDays', () => {
  it('returns Every day for 7 days', () =>
    expect(formatDays(['mon', 'tue', 'wed', 'thu', 'fri', 'sat', 'sun'])).toBe('Every day'));
  it('returns All days for empty array', () => expect(formatDays([])).toBe('All days'));
  it('formats subset', () => expect(formatDays(['mon', 'wed', 'fri'])).toBe('Mon, Wed, Fri'));
  it('formats weekend', () => expect(formatDays(['sat', 'sun'])).toBe('Sat, Sun'));
});
