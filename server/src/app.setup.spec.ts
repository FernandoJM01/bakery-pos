import type { NextFunction, Request, Response } from 'express';
import { parseOrigins, rejectPlainHttp, requireHttps } from './app.setup';

describe('app setup', () => {
  const originalEnv = { ...process.env };
  afterEach(() => {
    process.env = { ...originalEnv };
  });

  function run(req: Partial<Request>) {
    const res = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    const next = jest.fn() as NextFunction;
    rejectPlainHttp(req as Request, res as unknown as Response, next);
    return { res, next };
  }

  it('rejects plain HTTP with 403 PERMISSION_DENIED', () => {
    const { res, next } = run({ secure: false, path: '/v1/branches' });
    expect(next).not.toHaveBeenCalled();
    expect(res.status).toHaveBeenCalledWith(403);
    expect(res.json).toHaveBeenCalledWith({
      code: 'PERMISSION_DENIED',
      message: 'HTTPS is required',
    });
  });

  it('lets HTTPS requests and the plain-HTTP health check through', () => {
    expect(run({ secure: true, path: '/v1/branches' }).next).toHaveBeenCalled();
    expect(run({ secure: false, path: '/health' }).next).toHaveBeenCalled();
  });

  it('requires HTTPS only in production, unless REQUIRE_HTTPS=false', () => {
    process.env.NODE_ENV = 'development';
    expect(requireHttps()).toBe(false);
    process.env.NODE_ENV = 'production';
    expect(requireHttps()).toBe(true);
    process.env.REQUIRE_HTTPS = 'false';
    expect(requireHttps()).toBe(false);
  });

  it('parses a comma-separated BACKOFFICE_ORIGIN list', () => {
    expect(parseOrigins(undefined)).toEqual([]);
    expect(parseOrigins(' https://a.ts.net , https://b.ts.net,')).toEqual([
      'https://a.ts.net',
      'https://b.ts.net',
    ]);
  });
});
