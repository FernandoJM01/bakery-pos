import { INestApplication, ValidationPipe } from '@nestjs/common';

interface ExpressInstance {
  set(setting: string, val: boolean | number | string): void;
}

/**
 * Settings shared by main.ts and the e2e tests, so tests exercise the same
 * routes and validation as production.
 */
export function configureApp(app: INestApplication): void {
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
