const DAY_LABELS = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'] as const;

export function dayLabel(dayOfWeek: number): string {
  return DAY_LABELS[dayOfWeek] ?? `Day ${dayOfWeek}`;
}

// "08:00:00" or "08:00" → "8:00 am"
export function formatTime(t: string | null): string {
  if (!t) return '—';
  const [h, m] = t.split(':').map(Number);
  if (h === undefined || m === undefined) return t;
  const suffix = h < 12 ? 'am' : 'pm';
  const hour = h % 12 || 12;
  return `${hour}:${String(m).padStart(2, '0')} ${suffix}`;
}

const ABBR_TO_LABEL: Record<string, string> = {
  mon: 'Mon',
  tue: 'Tue',
  wed: 'Wed',
  thu: 'Thu',
  fri: 'Fri',
  sat: 'Sat',
  sun: 'Sun',
};

export function formatDays(days: string[]): string {
  if (days.length === 0) return 'All days';
  if (days.length === 7) return 'Every day';
  return days.map((d) => ABBR_TO_LABEL[d] ?? d).join(', ');
}
