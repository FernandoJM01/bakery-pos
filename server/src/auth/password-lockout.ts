/** Back office lockout (brief 5.3): 10 wrong passwords in 15 minutes lock for 15 minutes. */
export const PASSWORD_MAX_FAILURES = 10;
export const PASSWORD_WINDOW_MS = 15 * 60 * 1000;
export const PASSWORD_LOCK_MS = 15 * 60 * 1000;

export interface PasswordFailureState {
  failedPasswordAttempts: number;
  passwordFailureWindowStart: Date | null;
  passwordLockedUntil: Date | null;
}

/**
 * Next state after a wrong password. Failures older than the window no longer
 * count, and reaching the limit locks the account and starts a fresh count, so
 * the first wrong password after the lock expires does not re-lock it.
 * Kept apart from the PIN counters (failed_pin_attempts, locked_until) so a
 * back office lockout never locks the till PIN, or the reverse.
 */
export function recordPasswordFailure(
  state: PasswordFailureState,
  now: Date,
): PasswordFailureState {
  const windowStart = state.passwordFailureWindowStart;
  const windowOpen =
    windowStart !== null &&
    now.getTime() - windowStart.getTime() < PASSWORD_WINDOW_MS;
  const attempts = windowOpen ? state.failedPasswordAttempts + 1 : 1;

  if (attempts >= PASSWORD_MAX_FAILURES) {
    return {
      failedPasswordAttempts: 0,
      passwordFailureWindowStart: null,
      passwordLockedUntil: new Date(now.getTime() + PASSWORD_LOCK_MS),
    };
  }
  return {
    failedPasswordAttempts: attempts,
    passwordFailureWindowStart: windowOpen ? windowStart : now,
    passwordLockedUntil: null,
  };
}
