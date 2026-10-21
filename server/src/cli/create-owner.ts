import { PrismaClient, Role } from '@prisma/client';
import * as readline from 'node:readline';
import { v7 as uuidv7 } from 'uuid';
import { hashPassword, hashPin } from '../common/crypto';

const prisma = new PrismaClient();

async function promptVisible(
  question: string,
  iter: AsyncIterator<string>,
): Promise<string> {
  process.stdout.write(question);
  const result = await iter.next();
  if (result.done) {
    return '';
  }
  return result.value.trim();
}

async function promptHidden(
  question: string,
  iter: AsyncIterator<string>,
): Promise<string> {
  process.stdout.write(question);
  if (!process.stdin.isTTY) {
    const result = await iter.next();
    if (result.done) {
      return '';
    }
    return result.value.trim();
  }

  return new Promise((resolve) => {
    let input = '';
    const wasRaw = process.stdin.isRaw;
    process.stdin.setRawMode(true);
    process.stdin.resume();

    const onData = (chunk: Buffer) => {
      const char = chunk.toString();
      for (const c of char) {
        if (c === '\r' || c === '\n') {
          process.stdin.setRawMode(wasRaw);
          process.stdin.removeListener('data', onData);
          process.stdout.write('\n');
          resolve(input.trim());
          return;
        } else if (c === '\u0003') {
          process.stdin.setRawMode(wasRaw);
          process.exit(130);
        } else if (c === '\u0008' || c === '\x7f') {
          input = input.slice(0, -1);
        } else if (c >= ' ') {
          input += c;
        }
      }
    };
    process.stdin.on('data', onData);
  });
}

async function main() {
  const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout,
  });
  const iter = rl[Symbol.asyncIterator]();

  try {
    console.log('=== Create Owner (Production / Back Office) ===');

    const fullName = await promptVisible('Full Name: ', iter);
    if (!fullName) {
      throw new Error('Full Name is required.');
    }

    const displayName = await promptVisible('Display Name: ', iter);
    if (!displayName) {
      throw new Error('Display Name is required.');
    }

    const rawEmail = await promptVisible('Email: ', iter);
    const email = rawEmail.toLowerCase();
    if (!email || !/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
      throw new Error('A valid email address is required.');
    }

    const password = await promptHidden('Password (min 10 chars): ', iter);
    if (password.length < 10) {
      throw new Error('Password must be at least 10 characters long.');
    }

    const pin = await promptHidden('PIN (4 to 6 digits): ', iter);
    if (!/^\d{4,6}$/.test(pin)) {
      throw new Error('PIN must be between 4 and 6 digits.');
    }

    // Check if staff with this email already exists
    const existing = await prisma.staff.findUnique({
      where: { email },
    });
    if (existing) {
      throw new Error(`A staff member with email "${email}" already exists.`);
    }

    const passwordHash = await hashPassword(password);
    const { pinHash, offlinePinVerifier } = await hashPin(pin);
    const staffId = uuidv7();

    // Link owner to all active branches
    const branches = await prisma.branch.findMany({
      where: { isActive: true },
      select: { id: true },
    });

    const created = await prisma.staff.create({
      data: {
        id: staffId,
        fullName,
        displayName,
        role: Role.OWNER,
        email,
        passwordHash,
        pinHash,
        offlinePinVerifier,
        pinUpdatedAt: new Date(),
        isActive: true,
        staffBranches: {
          create: branches.map((b) => ({ branchId: b.id })),
        },
      },
    });

    // Prints nothing secret: no password, no PIN, no hash
    console.log(
      `\nOwner created successfully: ${created.email} (ID: ${created.id})`,
    );
  } finally {
    rl.close();
    await prisma.$disconnect();
  }
}

main().catch((err: unknown) => {
  const message = err instanceof Error ? err.message : String(err);
  console.error(`\nError creating owner: ${message}`);
  process.exit(1);
});
