export interface JwtPayload {
  sub: string;
  sid: string;
  did?: string;
  branchIds: string[];
}

export interface AuthenticatedUser {
  staffId: string;
  sessionId: string;
  deviceId: string | null;
  role: string;
  branchIds: string[];
  permissions: string[];
}
