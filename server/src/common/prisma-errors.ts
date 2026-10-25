import { ConflictException } from '@nestjs/common';
import { Prisma } from '@prisma/client';

/**
 * Turns a unique-constraint violation (P2002) into the contract's 409
 * CONFLICT. The services check uniqueness first for a clear message, but two
 * concurrent requests can both pass that check; the database is the referee.
 */
export async function withUniqueConflict<T>(
  message: string,
  write: () => Promise<T>,
): Promise<T> {
  try {
    return await write();
  } catch (e) {
    if (
      e instanceof Prisma.PrismaClientKnownRequestError &&
      e.code === 'P2002'
    ) {
      throw new ConflictException({ code: 'CONFLICT', message });
    }
    throw e;
  }
}
