import { INestApplication, ValidationPipe } from '@nestjs/common';

/**
 * Settings shared by main.ts and the e2e tests, so tests exercise the same
 * routes and validation as production.
 */
export function configureApp(app: INestApplication): void {
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
