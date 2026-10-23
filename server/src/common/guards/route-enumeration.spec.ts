import { Controller, Get, INestApplication } from '@nestjs/common';
import { PATH_METADATA } from '@nestjs/common/constants';
import { ModulesContainer, Reflector } from '@nestjs/core';
import { Test } from '@nestjs/testing';
import { AppModule } from '../../app.module';
import { REQUIRE_DEVICE_KEY } from '../../devices/decorators/require-device.decorator';
import { DevicesController } from '../../devices/devices.controller';
import { IS_PUBLIC_KEY } from '../decorators/public.decorator';
import { PERMISSIONS_KEY } from '../decorators/require-permission.decorator';
import { PrismaService } from '../../prisma/prisma.service';

@Controller('unprotected-test')
class UndecoratedTestController {
  @Get('rogue')
  rogueRoute() {
    return 'danger';
  }
}

describe('Route Enumeration (Acceptance Test A4)', () => {
  let app: INestApplication;
  let reflector: Reflector;

  beforeAll(async () => {
    const moduleRef = await Test.createTestingModule({
      imports: [AppModule],
    })
      .overrideProvider(PrismaService)
      .useValue({
        isHealthy: jest.fn().mockResolvedValue(true),
        $connect: jest.fn().mockResolvedValue(undefined),
        $disconnect: jest.fn().mockResolvedValue(undefined),
      })
      .compile();

    app = moduleRef.createNestApplication();
    await app.init();
    reflector = app.get(Reflector);
  });

  afterAll(async () => {
    if (app) {
      await app.close();
    }
  });

  function getUndecoratedRoutes(controllers: object[]): string[] {
    const violations: string[] = [];

    for (const controller of controllers) {
      const prototype = Object.getPrototypeOf(controller) as Record<
        string,
        unknown
      >;
      const methodNames = Object.getOwnPropertyNames(prototype).filter(
        (prop) =>
          prop !== 'constructor' && typeof prototype[prop] === 'function',
      );

      for (const methodName of methodNames) {
        const handler = prototype[methodName] as (
          ...args: unknown[]
        ) => unknown;
        const isRoute = Reflect.hasMetadata(PATH_METADATA, handler);
        if (!isRoute) continue;

        const controllerClass = controller.constructor as new (
          ...args: unknown[]
        ) => unknown;
        const isPublic = reflector.getAllAndOverride<boolean>(IS_PUBLIC_KEY, [
          handler,
          controllerClass,
        ]);
        const permissions = reflector.getAllAndOverride<string[]>(
          PERMISSIONS_KEY,
          [handler, controllerClass],
        );

        if (!isPublic && (!permissions || permissions.length === 0)) {
          violations.push(`${controllerClass.name}.${methodName}`);
        }
      }
    }

    return violations;
  }

  it('A4: every route has a permission or @Public(); a test enumerating routes fails otherwise', () => {
    const modulesContainer = app.get(ModulesContainer);
    const registeredControllers: object[] = [];

    for (const nestModule of modulesContainer.values()) {
      for (const controller of nestModule.controllers.values()) {
        if (controller.instance) {
          registeredControllers.push(controller.instance);
        }
      }
    }

    expect(registeredControllers.length).toBeGreaterThan(0);
    const violations = getUndecoratedRoutes(registeredControllers);
    expect(violations).toEqual([]);
  });

  it('A4: detects and reports any controller route lacking both @Public() and @RequirePermission()', () => {
    const rogueController = new UndecoratedTestController();
    const violations = getUndecoratedRoutes([rogueController]);

    expect(violations).toContain('UndecoratedTestController.rogueRoute');
  });

  it('verifies routes marked x-device: required have @RequireDevice() metadata', () => {
    const devicesController = app.get(DevicesController);
    const prototype = Object.getPrototypeOf(devicesController) as Record<
      string,
      (...args: unknown[]) => unknown
    >;
    const hasRequireDevice = reflector.get<boolean>(
      REQUIRE_DEVICE_KEY,
      prototype.getDeviceStaffBundle,
    );
    expect(hasRequireDevice).toBe(true);
  });
});
