import { getNextFourAm } from './session-expiry';

describe('getNextFourAm', () => {
  const tz = 'America/Mexico_City'; // UTC-6 without DST since 2023

  it('computes next 4:00 AM when login is late night (23:00)', () => {
    // 2026-10-23 23:00 CST is 2026-10-24 05:00 UTC
    const loginTime = new Date('2026-10-24T05:00:00.000Z');
    const expiry = getNextFourAm(loginTime, tz);

    // Expected next 4:00 AM CST is 2026-10-24 10:00:00 UTC
    expect(expiry.toISOString()).toBe('2026-10-24T10:00:00.000Z');
  });

  it('computes next 4:00 AM when login is early morning (03:00)', () => {
    // 2026-10-24 03:00 CST is 2026-10-24 09:00 UTC
    const loginTime = new Date('2026-10-24T09:00:00.000Z');
    const expiry = getNextFourAm(loginTime, tz);

    // Expected next 4:00 AM CST is same day 2026-10-24 10:00:00 UTC
    expect(expiry.toISOString()).toBe('2026-10-24T10:00:00.000Z');
  });

  it('computes next 4:00 AM when login is at 04:00 exactly', () => {
    // 2026-10-24 04:00 CST is 2026-10-24 10:00 UTC
    const loginTime = new Date('2026-10-24T10:00:00.000Z');
    const expiry = getNextFourAm(loginTime, tz);

    // Expected next 4:00 AM CST is next day 2026-10-25 10:00:00 UTC
    expect(expiry.toISOString()).toBe('2026-10-25T10:00:00.000Z');
  });

  it('handles a login just after midnight local time', () => {
    // 2026-10-24 00:30 CST is 06:30 UTC; expiry is the same day's 04:00
    const expiry = getNextFourAm(new Date('2026-10-24T06:30:00.000Z'), tz);
    expect(expiry.toISOString()).toBe('2026-10-24T10:00:00.000Z');
  });

  it('ends at 04:00 local on the night DST starts (America/Tijuana)', () => {
    // 2026-03-07 12:00 PST; clocks jump 02:00 -> 03:00 on 2026-03-08,
    // so 04:00 PDT (UTC-7) is 11:00 UTC.
    const expiry = getNextFourAm(
      new Date('2026-03-07T20:00:00.000Z'),
      'America/Tijuana',
    );
    expect(expiry.toISOString()).toBe('2026-03-08T11:00:00.000Z');
  });

  it('ends at 04:00 local on the night DST ends (America/Tijuana)', () => {
    // 2026-10-31 13:00 PDT; clocks fall back 02:00 -> 01:00 on 2026-11-01,
    // so 04:00 PST (UTC-8) is 12:00 UTC.
    const expiry = getNextFourAm(
      new Date('2026-10-31T20:00:00.000Z'),
      'America/Tijuana',
    );
    expect(expiry.toISOString()).toBe('2026-11-01T12:00:00.000Z');
  });
});
