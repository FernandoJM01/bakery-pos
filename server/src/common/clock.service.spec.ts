import { ClockService } from './clock.service';

describe('ClockService', () => {
  let clock: ClockService;

  beforeEach(() => {
    clock = new ClockService();
  });

  it('defaults to system time', () => {
    const before = Date.now();
    const now = clock.now().getTime();
    const after = Date.now();
    expect(now).toBeGreaterThanOrEqual(before);
    expect(now).toBeLessThanOrEqual(after);
  });

  it('allows overriding time with setNow', () => {
    const target = new Date('2026-10-21T12:00:00Z');
    clock.setNow(target);
    expect(clock.now().toISOString()).toBe(target.toISOString());

    clock.setNow(null);
    const systemNow = Date.now();
    expect(Math.abs(clock.now().getTime() - systemNow)).toBeLessThan(100);
  });

  it('allows advancing time with advance', () => {
    const target = new Date('2026-10-21T12:00:00Z');
    clock.setNow(target);
    clock.advance(15 * 60 * 1000); // +15m
    expect(clock.now().toISOString()).toBe(
      new Date('2026-10-21T12:15:00Z').toISOString(),
    );
  });
});
