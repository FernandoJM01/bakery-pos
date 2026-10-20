import { ConfigService } from '@nestjs/config';
import { Test, TestingModule } from '@nestjs/testing';
import { PrismaService } from '../prisma/prisma.service';
import { HealthService } from './health.service';

describe('HealthService', () => {
  let service: HealthService;
  let prismaService: jest.Mocked<PrismaService>;

  beforeEach(async () => {
    const mockPrisma = {
      isHealthy: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      providers: [
        HealthService,
        {
          provide: PrismaService,
          useValue: mockPrisma,
        },
        {
          provide: ConfigService,
          useValue: {
            get: jest.fn().mockReturnValue('0.1.0-m1'),
          },
        },
      ],
    }).compile();

    service = module.get<HealthService>(HealthService);
    prismaService = module.get(PrismaService);
  });

  it('reports ok when database is reachable', async () => {
    prismaService.isHealthy.mockResolvedValue(true);

    const result = await service.check();
    expect(result).toEqual({
      status: 'ok',
      database: 'ok',
      version: '0.1.0-m1',
    });
  });

  it('reports degraded when database is unreachable', async () => {
    prismaService.isHealthy.mockResolvedValue(false);

    const result = await service.check();
    expect(result).toEqual({
      status: 'degraded',
      database: 'unreachable',
      version: '0.1.0-m1',
    });
  });
});
