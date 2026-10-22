import { ExecutionContext, UnauthorizedException } from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { Reflector } from '@nestjs/core';
import { Device, DeviceStatus } from '@prisma/client';
import { v7 as uuidv7 } from 'uuid';
import { ClockService } from '../../common/clock.service';
import { hashTokenWithPepper } from '../../common/crypto';
import { PrismaService } from '../../prisma/prisma.service';
import { DeviceGuard, RequestWithDevice } from './device.guard';

describe('DeviceGuard', () => {
  let guard: DeviceGuard;
  let reflector: Reflector;
  let prisma: PrismaService;
  let clock: ClockService;
  let updateDeviceMock: jest.Mock<Promise<unknown>, [unknown]>;
  let findUniqueDeviceMock: jest.Mock<Promise<unknown>, [unknown]>;
  const pepper = 'test-device-pepper';

  beforeEach(() => {
    reflector = new Reflector();
    updateDeviceMock = jest
      .fn<Promise<unknown>, [unknown]>()
      .mockResolvedValue({});
    findUniqueDeviceMock = jest.fn<Promise<unknown>, [unknown]>();
    prisma = {
      device: {
        findUnique: findUniqueDeviceMock,
        update: updateDeviceMock,
      },
    } as unknown as PrismaService;
    clock = new ClockService();
    const config = {
      getOrThrow: jest.fn().mockReturnValue(pepper),
    } as unknown as ConfigService;

    guard = new DeviceGuard(reflector, prisma, clock, config);
  });

  function createMockContext(headers: Record<string, string | undefined> = {}) {
    const request: RequestWithDevice = {
      headers,
    } as unknown as RequestWithDevice;

    return {
      getHandler: jest.fn(),
      getClass: jest.fn(),
      switchToHttp: () => ({
        getRequest: () => request,
      }),
    } as unknown as ExecutionContext;
  }

  it('allows access when route does not require device', async () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(false);
    const context = createMockContext();

    expect(await guard.canActivate(context)).toBe(true);
  });

  it('throws 401 DEVICE_UNKNOWN when X-Device-Token is missing', async () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(true);
    const context = createMockContext({});

    await expect(guard.canActivate(context)).rejects.toThrow(
      new UnauthorizedException({
        code: 'DEVICE_UNKNOWN',
        message: 'Device token required',
      }),
    );
  });

  it('throws 401 DEVICE_UNKNOWN when token is unknown', async () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(true);
    findUniqueDeviceMock.mockResolvedValue(null);
    const context = createMockContext({ 'x-device-token': 'unknown-token' });

    await expect(guard.canActivate(context)).rejects.toThrow(
      new UnauthorizedException({
        code: 'DEVICE_UNKNOWN',
        message: 'Unknown device',
      }),
    );
  });

  it('throws 401 DEVICE_REVOKED when device is revoked', async () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(true);
    const rawToken = 'revoked-token';
    const tokenHash = hashTokenWithPepper(rawToken, pepper);
    findUniqueDeviceMock.mockResolvedValue({
      id: uuidv7(),
      tokenHash,
      status: DeviceStatus.REVOKED,
    });
    const context = createMockContext({ 'x-device-token': rawToken });

    await expect(guard.canActivate(context)).rejects.toThrow(
      new UnauthorizedException({
        code: 'DEVICE_REVOKED',
        message: 'Device has been revoked',
      }),
    );
  });

  it('throws 401 DEVICE_UNKNOWN when device is pending', async () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(true);
    const rawToken = 'pending-token';
    const tokenHash = hashTokenWithPepper(rawToken, pepper);
    findUniqueDeviceMock.mockResolvedValue({
      id: uuidv7(),
      tokenHash,
      status: DeviceStatus.PENDING,
    });
    const context = createMockContext({ 'x-device-token': rawToken });

    await expect(guard.canActivate(context)).rejects.toThrow(
      new UnauthorizedException({
        code: 'DEVICE_UNKNOWN',
        message: 'Device is not active',
      }),
    );
  });

  it('attaches device to request and updates lastSeenAt when active', async () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(true);
    const fixedNow = new Date('2026-10-21T10:00:00Z');
    clock.setNow(fixedNow);

    const rawToken = 'valid-active-token';
    const tokenHash = hashTokenWithPepper(rawToken, pepper);
    const deviceId = uuidv7();
    const mockDevice = {
      id: deviceId,
      tokenHash,
      status: DeviceStatus.ACTIVE,
      lastSeenAt: null,
    } as unknown as Device;
    findUniqueDeviceMock.mockResolvedValue(mockDevice);

    const context = createMockContext({ 'x-device-token': rawToken });
    const request = context.switchToHttp().getRequest<RequestWithDevice>();

    expect(await guard.canActivate(context)).toBe(true);
    expect(request.device).toEqual(mockDevice);
    expect(updateDeviceMock).toHaveBeenCalledWith({
      where: { id: deviceId },
      data: { lastSeenAt: fixedNow },
    });
  });

  it('does not update lastSeenAt if updated within the last minute', async () => {
    jest.spyOn(reflector, 'getAllAndOverride').mockReturnValue(true);
    const rawToken = 'valid-token';
    const now = new Date('2026-10-21T12:00:00Z');
    clock.setNow(now);

    const mockDevice = {
      id: uuidv7(),
      tokenHash: hashTokenWithPepper(rawToken, pepper),
      status: DeviceStatus.ACTIVE,
      lastSeenAt: new Date(now.getTime() - 30 * 1000), // 30s ago
    } as unknown as Device;
    findUniqueDeviceMock.mockResolvedValue(mockDevice);

    const context = createMockContext({ 'x-device-token': rawToken });
    expect(await guard.canActivate(context)).toBe(true);
    expect(updateDeviceMock).not.toHaveBeenCalled();
  });
});
