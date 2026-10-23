/**
 * Till sessions end at 04:00 branch local time (brief 5.2): today's 04:00 if
 * the login is before 04:00 local, otherwise tomorrow's.
 */
export function getNextFourAm(now: Date, timeZone: string): Date {
  const local = wallClock(now, timeZone);
  let { year, month, day } = local;
  if (local.hour >= 4) {
    const next = new Date(Date.UTC(year, month - 1, day + 1));
    year = next.getUTCFullYear();
    month = next.getUTCMonth() + 1;
    day = next.getUTCDate();
  }
  return zonedTimeToUtc(year, month, day, 4, timeZone);
}

interface WallClock {
  year: number;
  month: number;
  day: number;
  hour: number;
  minute: number;
  second: number;
}

function wallClock(instant: Date, timeZone: string): WallClock {
  // hourCycle h23: some ICU versions print midnight as "24" with hour12:false.
  const parts = new Intl.DateTimeFormat('en-US', {
    timeZone,
    year: 'numeric',
    month: 'numeric',
    day: 'numeric',
    hour: 'numeric',
    minute: 'numeric',
    second: 'numeric',
    hourCycle: 'h23',
  }).formatToParts(instant);
  const get = (type: string) =>
    parseInt(parts.find((p) => p.type === type)!.value, 10);
  return {
    year: get('year'),
    month: get('month'),
    day: get('day'),
    hour: get('hour'),
    minute: get('minute'),
    second: get('second'),
  };
}

/** Offset of [timeZone] from UTC at [instant], in milliseconds. */
function offsetAt(instant: number, timeZone: string): number {
  const w = wallClock(new Date(instant), timeZone);
  const asUtc = Date.UTC(
    w.year,
    w.month - 1,
    w.day,
    w.hour,
    w.minute,
    w.second,
  );
  return asUtc - Math.floor(instant / 1000) * 1000;
}

/**
 * The instant at which the wall clock in [timeZone] shows the given local
 * time. The offset is taken at the result itself (second pass), so a DST
 * change between midnight and 04:00 does not shift the answer by an hour.
 */
function zonedTimeToUtc(
  year: number,
  month: number,
  day: number,
  hour: number,
  timeZone: string,
): Date {
  const naive = Date.UTC(year, month - 1, day, hour, 0, 0);
  const first = naive - offsetAt(naive, timeZone);
  const second = naive - offsetAt(first, timeZone);
  return new Date(second);
}
