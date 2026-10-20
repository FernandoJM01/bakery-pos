import { HttpStatus } from '@nestjs/common';
import { Test, TestingModule } from '@nestjs/testing';
import type { Response } from 'express';
import { HealthController } from './health.controller';
import { HealthService } from './health.service';

describe('HealthController', () => {
  let controller: HealthController;
  let healthService: jest.Mocked<HealthService>;

  beforeEach(async () => {
    const mockHealthService = {
      check: jest.fn(),
    };

    const module: TestingModule = await Test.createTestingModule({
      controllers: [HealthController],
      providers: [
        {
          provide: HealthService,
          useValue: mockHealthService,
        },
      ],
    }).compile();

    controller = module.get<HealthController>(HealthController);
    healthService = module.get(HealthService);
  });

  it('returns 200 when system is healthy', async () => {
    healthService.check.mockResolvedValue({
      status: 'ok',
      database: 'ok',
      version: '0.1.0-m1',
    });

    const statusMock = jest.fn();
    const mockRes = {
      status: statusMock,
    } as unknown as Response;

    const result = await controller.getHealth(mockRes);
    expect(result).toEqual({
      status: 'ok',
      database: 'ok',
      version: '0.1.0-m1',
    });
    expect(statusMock).not.toHaveBeenCalled();
  });

  it('sets 503 SERVICE_UNAVAILABLE when database is degraded', async () => {
    healthService.check.mockResolvedValue({
      status: 'degraded',
      database: 'unreachable',
      version: '0.1.0-m1',
    });

    const statusMock = jest.fn();
    const mockRes = {
      status: statusMock,
    } as unknown as Response;

    const result = await controller.getHealth(mockRes);
    expect(result).toEqual({
      status: 'degraded',
      database: 'unreachable',
      version: '0.1.0-m1',
    });
    expect(statusMock).toHaveBeenCalledWith(HttpStatus.SERVICE_UNAVAILABLE);
  });
});
