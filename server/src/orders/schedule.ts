export interface Schedule {
  kind: 'STANDING' | 'ONE_OFF';
  /** Bit set, Monday = 1, Tuesday = 2 ... Sunday = 64. */
  weekdays: number;
  /** YYYY-MM-DD */
  startDate: string;
  endDate: string | null;
  status: 'ACTIVE' | 'PAUSED' | 'ENDED';
  pausedFrom: string | null;
  pausedUntil: string | null;
  skips: readonly string[];
}

/** Monday = 1 ... Sunday = 64, the bit a calendar day has. */
export function weekdayBit(day: string): number {
  const d = new Date(`${day}T00:00:00Z`).getUTCDay(); // Sunday = 0
  return 1 << ((d + 6) % 7);
}

/**
 * Whether an order is due on `day` (M6 brief 4.1). The app has the same
 * function; both reproduce `contracts/fixtures/order-schedule-cases.json`.
 */
export function isDue(s: Schedule, day: string): boolean {
  if (s.status === 'ENDED') return false;
  if (day < s.startDate) return false;
  if (s.kind === 'ONE_OFF') {
    if (day !== s.startDate) return false;
  } else {
    if (s.endDate && day > s.endDate) return false;
    if ((s.weekdays & weekdayBit(day)) === 0) return false;
  }
  if (s.skips.includes(day)) return false;
  if (
    s.pausedFrom &&
    day >= s.pausedFrom &&
    (s.pausedUntil == null || day <= s.pausedUntil)
  ) {
    return false;
  }
  return true;
}
