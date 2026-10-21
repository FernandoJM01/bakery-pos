import { Injectable } from '@nestjs/common';

@Injectable()
export class ClockService {
  private customNow: Date | null = null;

  /**
   * Returns the current date/time, or the mocked date/time if set.
   */
  now(): Date {
    return this.customNow ? new Date(this.customNow.getTime()) : new Date();
  }

  /**
   * Sets a fixed time for testing. Pass null to reset to system time.
   */
  setNow(date: Date | null): void {
    this.customNow = date ? new Date(date.getTime()) : null;
  }

  /**
   * Advances the current clock by a number of milliseconds.
   */
  advance(ms: number): void {
    const current = this.now();
    this.customNow = new Date(current.getTime() + ms);
  }
}
