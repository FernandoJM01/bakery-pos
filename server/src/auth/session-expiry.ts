/**
 * Calculates the next 04:00:00 in the given IANA timezone.
 *
 * Per brief 5.2 / contract:
 * Till sessions end at 04:00 branch local time the next day (or today if login is before 04:00).
 * If login is at or after 04:00 local, it expires at tomorrow's 04:00 local.
 * If login is before 04:00 local, it expires at today's 04:00 local.
 */
export function getNextFourAm(now: Date, timeZone: string): Date {
  const formatter = new Intl.DateTimeFormat('en-US', {
    timeZone,
    year: 'numeric',
    month: 'numeric',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
    second: 'numeric',
    hour12: false,
  });

  const parts = formatter.formatToParts(now);
  const partMap: Record<string, string> = {};
  for (const p of parts) {
    partMap[p.type] = p.value;
  }

  const year = parseInt(partMap.year, 10);
  const month = parseInt(partMap.month, 10);
  const day = parseInt(partMap.day, 10);
  const hour = parseInt(partMap.hour, 10);

  let targetYear = year;
  let targetMonth = month;
  let targetDay = day;

  if (hour >= 4) {
    // Add 1 day
    const nextDay = new Date(Date.UTC(year, month - 1, day + 1));
    targetYear = nextDay.getUTCFullYear();
    targetMonth = nextDay.getUTCMonth() + 1;
    targetDay = nextDay.getUTCDate();
  }

  // Construct UTC guess for 04:00
  const guessUtc = new Date(
    Date.UTC(targetYear, targetMonth - 1, targetDay, 4, 0, 0),
  );

  // Compute timezone offset at target date using formatter parts
  const tzParts = formatter.formatToParts(guessUtc);
  const tzMap: Record<string, string> = {};
  for (const p of tzParts) {
    tzMap[p.type] = p.value;
  }
  const tzDate = new Date(
    Date.UTC(
      parseInt(tzMap.year, 10),
      parseInt(tzMap.month, 10) - 1,
      parseInt(tzMap.day, 10),
      parseInt(tzMap.hour, 10),
      parseInt(tzMap.minute, 10),
      parseInt(tzMap.second, 10),
    ),
  );

  const offsetMs = tzDate.getTime() - guessUtc.getTime();
  return new Date(guessUtc.getTime() - offsetMs);
}
