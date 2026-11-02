import { CashShift, Prisma, Role, Staff, StaffBranch } from '@prisma/client';
import { ClassConstructor, plainToInstance } from 'class-transformer';
import { validateSync } from 'class-validator';
import { PERMISSION_KEYS, PermissionKey } from '../common/permissions';

export type SyncErrorCode =
  'SYNC_UNKNOWN_TYPE' | 'SYNC_INVALID_PAYLOAD' | 'SYNC_REJECTED';

export interface Rejection {
  ok: false;
  code: SyncErrorCode;
  message: string;
}

/**
 * What a record does once its inbox row is in. `apply` runs inside the
 * record's transaction; it may still reject (checks that need locked rows),
 * and must do so before writing anything.
 */
export type Plan =
  | {
      ok: true;
      apply: (tx: Prisma.TransactionClient) => Promise<Rejection | void>;
    }
  | Rejection;

export const rejected = (message: string): Rejection => ({
  ok: false,
  code: 'SYNC_REJECTED',
  message,
});

/** Checks a payload against its DTO; null when it is valid. */
export function parsePayload<T extends object>(
  cls: ClassConstructor<T>,
  payload: unknown,
): { value: T } | Rejection {
  const value = plainToInstance(cls, payload);
  const errors = validateSync(value, {
    whitelist: true,
    forbidNonWhitelisted: true,
  });
  if (errors.length === 0) return { value };
  const messages: string[] = [];
  const walk = (es: typeof errors, path: string) => {
    for (const e of es) {
      const at = path ? `${path}.${e.property}` : e.property;
      for (const m of Object.values(e.constraints ?? {})) {
        messages.push(path ? `${at}: ${m}` : m);
      }
      if (e.children?.length) walk(e.children, at);
    }
  };
  walk(errors, '');
  return {
    ok: false,
    code: 'SYNC_INVALID_PAYLOAD',
    message: messages.join('; '),
  };
}

/** Only these roles can approve (same rule as online approvals, A12). */
export const APPROVER_ROLES: readonly Role[] = [
  Role.OWNER,
  Role.BRANCH_MANAGER,
];

export type StaffWithBranches = Staff & { staffBranches: StaffBranch[] };

type Db = Pick<Prisma.TransactionClient, 'staff' | 'rolePermission'>;

export function inBranch(staff: StaffWithBranches, branchId: string): boolean {
  return (
    staff.role === Role.OWNER ||
    staff.staffBranches.some((sb) => sb.branchId === branchId)
  );
}

export async function findStaff(
  db: Db,
  id: string,
): Promise<StaffWithBranches | null> {
  return db.staff.findUnique({
    where: { id },
    include: { staffBranches: true },
  });
}

/** Role permission as in the database (owners hold every key). */
export async function holds(
  db: Db,
  staff: Staff,
  key: PermissionKey,
): Promise<boolean> {
  if (staff.role === Role.OWNER) return true;
  const granted = await db.rolePermission.findUnique({
    where: { role_permissionKey: { role: staff.role, permissionKey: key } },
  });
  return granted != null;
}

/**
 * Checks a manager approval given on the till: someone other than the
 * requester, assigned to the branch, an owner or manager, holding `key`.
 * Returns the approver, or the reason it does not count.
 */
export async function checkApprover(
  db: Db,
  approverId: string,
  requesterId: string,
  branchId: string,
  key: string,
): Promise<StaffWithBranches | Rejection> {
  if (!(PERMISSION_KEYS as readonly string[]).includes(key)) {
    return rejected(`Unknown approvalAction ${key}`);
  }
  if (approverId === requesterId) {
    return rejected('Requester cannot self-approve');
  }
  const approver = await findStaff(db, approverId);
  if (!approver) return rejected('Unknown approverStaffId');
  if (!inBranch(approver, branchId)) {
    return rejected('Approver is not assigned to this branch');
  }
  if (!APPROVER_ROLES.includes(approver.role)) {
    return rejected('Only owners and branch managers can approve');
  }
  if (!(await holds(db, approver, key as PermissionKey))) {
    return rejected('Approver lacks permission for this action');
  }
  return approver;
}

/**
 * The shift a sale, refund or movement names: this device's, and not closed
 * before the record happened (M4 brief 4.6).
 */
export async function checkShift(
  db: Pick<Prisma.TransactionClient, 'cashShift'>,
  deviceId: string,
  shiftId: string,
  occurredAt: Date,
): Promise<CashShift | Rejection> {
  const shift = await db.cashShift.findUnique({ where: { id: shiftId } });
  if (!shift || shift.deviceId !== deviceId) {
    return rejected('Shift not found on this device');
  }
  if (shift.closedAt && occurredAt > shift.closedAt) {
    return rejected('The shift was already closed');
  }
  return shift;
}

export function isRejection(x: unknown): x is Rejection {
  return (
    typeof x === 'object' && x !== null && (x as { ok?: unknown }).ok === false
  );
}
