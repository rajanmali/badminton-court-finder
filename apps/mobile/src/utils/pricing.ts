export function formatPriceCents(cents: number | null): string {
  if (cents === null) return 'Rates not listed';
  return `$${(cents / 100).toFixed(0)}/hr`;
}
