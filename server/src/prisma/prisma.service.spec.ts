import { PrismaService } from './prisma.service';

describe('PrismaService', () => {
  let service: PrismaService;

  beforeEach(() => {
    service = new PrismaService();
  });

  afterEach(() => {
    jest.restoreAllMocks();
  });

  it('connects on module init', async () => {
    const connectSpy = jest
      .spyOn(service, '$connect')
      .mockResolvedValue(undefined);
    await service.onModuleInit();
    expect(connectSpy).toHaveBeenCalled();
  });

  it('handles connection error in test mode gracefully', async () => {
    process.env.NODE_ENV = 'test';
    jest
      .spyOn(service, '$connect')
      .mockRejectedValue(new Error('Connection failed'));
    await expect(service.onModuleInit()).resolves.toBeUndefined();
  });

  it('re-throws connection error in non-test mode', async () => {
    process.env.NODE_ENV = 'production';
    jest
      .spyOn(service, '$connect')
      .mockRejectedValue(new Error('Connection failed'));
    await expect(service.onModuleInit()).rejects.toThrow('Connection failed');
    process.env.NODE_ENV = 'test';
  });

  it('disconnects on module destroy', async () => {
    const disconnectSpy = jest
      .spyOn(service, '$disconnect')
      .mockResolvedValue(undefined);
    await service.onModuleDestroy();
    expect(disconnectSpy).toHaveBeenCalled();
  });

  it('isHealthy returns true when query succeeds', async () => {
    jest.spyOn(service, '$queryRaw').mockResolvedValue([{ '?column?': 1 }]);
    const healthy = await service.isHealthy();
    expect(healthy).toBe(true);
  });

  it('isHealthy returns false when query fails', async () => {
    jest
      .spyOn(service, '$queryRaw')
      .mockRejectedValue(new Error('DB unreachable'));
    const healthy = await service.isHealthy();
    expect(healthy).toBe(false);
  });
});
