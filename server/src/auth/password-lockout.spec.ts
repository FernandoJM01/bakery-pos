import {
  PASSWORD_LOCK_MS,
  PASSWORD_WINDOW_MS,
  PasswordFailureState,
  recordPasswordFailure,
} from './password-lockout';

describe('recordPasswordFailure', () => {
  const start = new Date('2026-10-21T12:00:00Z');
  const fresh: PasswordFailureState = {
    failedPasswordAttempts: 0,
    passwordFailureWindowStart: null,
    passwordLockedUntil: null,
  };
  const at = (ms: number) => new Date(start.getTime() + ms);

  it('starts a window on the first failure', () => {
    expect(recordPasswordFailure(fresh, start)).toEqual({
      failedPasswordAttempts: 1,
      passwordFailureWindowStart: start,
      passwordLockedUntil: null,
    });
  });

  it('locks for 15 minutes on the 10th failure inside 15 minutes', () => {
    let state = fresh;
    for (let i = 0; i < 9; i++) {
      state = recordPasswordFailure(state, at(i * 60_000));
      expect(state.passwordLockedUntil).toBeNull();
    }
    const locked = recordPasswordFailure(state, at(9 * 60_000));
    expect(locked.passwordLockedUntil).toEqual(
      at(9 * 60_000 + PASSWORD_LOCK_MS),
    );
    expect(locked.failedPasswordAttempts).toBe(0);
  });

  it('does not count failures older than the window', () => {
    const nine: PasswordFailureState = {
      failedPasswordAttempts: 9,
      passwordFailureWindowStart: start,
      passwordLockedUntil: null,
    };
    const later = recordPasswordFailure(nine, at(PASSWORD_WINDOW_MS));
    expect(later.failedPasswordAttempts).toBe(1);
    expect(later.passwordLockedUntil).toBeNull();
  });

  it('does not re-lock on the first failure after a lock expires', () => {
    const afterLock: PasswordFailureState = {
      failedPasswordAttempts: 0,
      passwordFailureWindowStart: null,
      passwordLockedUntil: at(PASSWORD_LOCK_MS),
    };
    const next = recordPasswordFailure(afterLock, at(PASSWORD_LOCK_MS + 1));
    expect(next.passwordLockedUntil).toBeNull();
    expect(next.failedPasswordAttempts).toBe(1);
  });
});
