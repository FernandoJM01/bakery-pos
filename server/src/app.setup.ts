import { INestApplication, ValidationPipe } from '@nestjs/common';
import type { NextFunction, Request, Response } from 'express';

interface ExpressInstance {
  set(setting: string, val: boolean | number | string): void;
}

/**
 * Settings shared by main.ts and the e2e tests, so tests exercise the same
 * routes and validation as production.
 */
export function configureApp(app: INestApplication): void {
  const http = app.getHttpAdapter().getInstance() as unknown as {
    disable?(setting: string): void;
  };
  http.disable?.('x-powered-by');

  // Configure trust proxy if specified (e.g., behind nginx or AWS ALB)
  const trustProxy = process.env.TRUST_PROXY;
  if (trustProxy !== undefined && trustProxy !== '') {
    const expressApp = app
      .getHttpAdapter()
      .getInstance() as unknown as ExpressInstance;
    if (expressApp && typeof expressApp.set === 'function') {
      if (trustProxy === 'true') {
        expressApp.set('trust proxy', true);
      } else if (trustProxy === 'false') {
        expressApp.set('trust proxy', false);
      } else if (!isNaN(Number(trustProxy))) {
        expressApp.set('trust proxy', Number(trustProxy));
      } else {
        expressApp.set('trust proxy', trustProxy);
      }
    }
  }

  // Behind Tailscale or nginx the proxy terminates TLS; req.secure trusts its
  // X-Forwarded-Proto only because TRUST_PROXY is set (checked at startup).
  // /health stays reachable over plain HTTP for the container health check.
  if (requireHttps()) {
    app.use(rejectPlainHttp);
  }

  // The back office is normally served from the same origin as the API, so
  // CORS is closed unless BACKOFFICE_ORIGIN names the allowed origin(s).
  const origins = parseOrigins(process.env.BACKOFFICE_ORIGIN);
  if (origins.length > 0) {
    app.enableCors({
      origin: origins,
      methods: ['GET', 'POST', 'PATCH', 'DELETE'],
      allowedHeaders: [
        'Authorization',
        'Content-Type',
        'Idempotency-Key',
        'X-Device-Token',
        'X-Approval-Token',
      ],
    });
  }

  // Every route is under /v1 except the health check (contract: /health).
  app.setGlobalPrefix('v1', { exclude: ['health'] });

  app.useGlobalPipes(
    new ValidationPipe({
      whitelist: true,
      forbidNonWhitelisted: true,
      transform: true,
    }),
  );
}

export function requireHttps(): boolean {
  return (
    process.env.NODE_ENV === 'production' &&
    process.env.REQUIRE_HTTPS !== 'false'
  );
}

export function parseOrigins(value: string | undefined): string[] {
  return (value ?? '')
    .split(',')
    .map((o) => o.trim())
    .filter((o) => o !== '');
}

export function rejectPlainHttp(
  req: Request,
  res: Response,
  next: NextFunction,
): void {
  if (req.secure || req.path === '/health') {
    next();
    return;
  }
  res.status(403).json({
    code: 'PERMISSION_DENIED',
    message: 'HTTPS is required',
  });
}
