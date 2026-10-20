import {
  ArgumentsHost,
  BadRequestException,
  ForbiddenException,
  HttpException,
  HttpStatus,
  NotFoundException,
} from '@nestjs/common';
import { Response } from 'express';
import { GlobalExceptionFilter } from './http-exception.filter';

describe('GlobalExceptionFilter', () => {
  let filter: GlobalExceptionFilter;
  let mockResponse: { status: jest.Mock; json: jest.Mock };
  let mockHost: ArgumentsHost;

  beforeEach(() => {
    filter = new GlobalExceptionFilter();
    mockResponse = {
      status: jest.fn().mockReturnThis(),
      json: jest.fn().mockReturnThis(),
    };
    mockHost = {
      switchToHttp: jest.fn().mockReturnValue({
        getResponse: jest.fn().mockReturnValue(mockResponse),
      }),
    } as unknown as ArgumentsHost;
  });

  it('formats NotFoundException to standard NOT_FOUND Error schema', () => {
    filter.catch(new NotFoundException('Resource missing'), mockHost);

    expect(mockResponse.status).toHaveBeenCalledWith(HttpStatus.NOT_FOUND);
    expect(mockResponse.json).toHaveBeenCalledWith({
      code: 'NOT_FOUND',
      message: 'Resource missing',
    });
  });

  it('formats validation errors into VALIDATION_FAILED with details', () => {
    const validationError = new BadRequestException({
      message: ['name should not be empty', 'code must match pattern'],
    });

    filter.catch(validationError, mockHost);

    expect(mockResponse.status).toHaveBeenCalledWith(HttpStatus.BAD_REQUEST);
    expect(mockResponse.json).toHaveBeenCalledWith({
      code: 'VALIDATION_FAILED',
      message: 'Validation failed',
      details: {
        errors: ['name should not be empty', 'code must match pattern'],
      },
    });
  });

  it('preserves custom code and details passed in HttpException', () => {
    const customException = new HttpException(
      {
        code: 'AUTH_LOCKED',
        message: 'Too many attempts',
        details: { lockedUntil: '2026-10-20T12:00:00Z' },
      },
      423,
    );

    filter.catch(customException, mockHost);

    expect(mockResponse.status).toHaveBeenCalledWith(423);
    expect(mockResponse.json).toHaveBeenCalledWith({
      code: 'AUTH_LOCKED',
      message: 'Too many attempts',
      details: { lockedUntil: '2026-10-20T12:00:00Z' },
    });
  });

  it('formats string response in HttpException', () => {
    filter.catch(new ForbiddenException('Custom forbidden message'), mockHost);

    expect(mockResponse.status).toHaveBeenCalledWith(HttpStatus.FORBIDDEN);
    expect(mockResponse.json).toHaveBeenCalledWith({
      code: 'PERMISSION_DENIED',
      message: 'Custom forbidden message',
    });
  });

  it('handles unexpected non-HttpException errors with 500 INTERNAL_SERVER_ERROR', () => {
    filter.catch(new Error('Database disk full'), mockHost);

    expect(mockResponse.status).toHaveBeenCalledWith(
      HttpStatus.INTERNAL_SERVER_ERROR,
    );
    expect(mockResponse.json).toHaveBeenCalledWith({
      code: 'INTERNAL_SERVER_ERROR',
      message: 'An unexpected error occurred',
    });
  });
});
