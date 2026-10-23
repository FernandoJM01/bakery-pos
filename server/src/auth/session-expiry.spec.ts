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
});
