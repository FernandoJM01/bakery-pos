import { SetMetadata } from '@nestjs/common';
import type { RoutePermission } from '../permissions';

export const PERMISSIONS_KEY = 'permissions';
export const RequirePermission = (...permissions: RoutePermission[]) =>
  SetMetadata(PERMISSIONS_KEY, permissions);
