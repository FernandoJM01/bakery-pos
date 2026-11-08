export { daysBefore, daysBetween } from './fifo';

/** The calendar day of a DATE column, as YYYY-MM-DD. */
export const dayOf = (d: Date) => d.toISOString().slice(0, 10);
