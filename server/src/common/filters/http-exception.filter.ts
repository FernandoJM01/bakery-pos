import {
  ArgumentsHost,
  Catch,
  ExceptionFilter,
  HttpException,
  HttpStatus,
  Logger,
} from '@nestjs/common';
import { Response } from 'express';

const STATUS_CODE_MAP: Record<number, string> = {
  [HttpStatus.BAD_REQUEST]: 'VALIDATION_FAILED',
  [HttpStatus.UNAUTHORIZED]: 'AUTH_REQUIRED',
  [HttpStatus.FORBIDDEN]: 'PERMISSION_DENIED',
  [HttpStatus.NOT_FOUND]: 'NOT_FOUND',
  [HttpStatus.CONFLICT]: 'CONFLICT',
  [HttpStatus.GONE]: 'DEVICE_CODE_INVALID',
  423: 'AUTH_LOCKED',
  [HttpStatus.TOO_MANY_REQUESTS]: 'RATE_LIMITED',
  [HttpStatus.INTERNAL_SERVER_ERROR]: 'INTERNAL_SERVER_ERROR',
  [HttpStatus.SERVICE_UNAVAILABLE]: 'SERVICE_UNAVAILABLE',
};

@Catch()
export class GlobalExceptionFilter implements ExceptionFilter {
  private readonly logger = new Logger(GlobalExceptionFilter.name);

  catch(exception: unknown, host: ArgumentsHost) {
    const ctx = host.switchToHttp();
    const response = ctx.getResponse<Response>();

    let status = HttpStatus.INTERNAL_SERVER_ERROR;
    let code = 'INTERNAL_SERVER_ERROR';
    let message = 'An unexpected error occurred';
    let details: Record<string, unknown> | undefined;

    if (exception instanceof HttpException) {
      status = exception.getStatus();
      const res = exception.getResponse();

      if (typeof res === 'string') {
        message = res;
        code = STATUS_CODE_MAP[status] ?? 'ERROR';
      } else if (typeof res === 'object' && res !== null) {
        const obj = res as Record<string, unknown>;
        code = (obj.code as string) || STATUS_CODE_MAP[status] || 'ERROR';

        if (Array.isArray(obj.message)) {
          // Default class-validator output
          code = 'VALIDATION_FAILED';
          message = 'Validation failed';
          details = { errors: obj.message };
        } else {
          message = (obj.message as string) || exception.message;
        }

        if (obj.details && typeof obj.details === 'object') {
          details = obj.details as Record<string, unknown>;
        }
      }
    } else {
      this.logger.error('Unhandled exception:', exception);
    }

    const payload: {
      code: string;
      message: string;
      details?: Record<string, unknown>;
    } = {
      code,
      message,
    };

    if (details !== undefined) {
      payload.details = details;
    }

    response.status(status).json(payload);
  }
}
