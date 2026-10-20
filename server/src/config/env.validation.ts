import { plainToInstance } from 'class-transformer';
import {
  IsNotEmpty,
  IsNumber,
  IsOptional,
  IsString,
  validateSync,
} from 'class-validator';

export class EnvironmentVariables {
  @IsNotEmpty({ message: 'DATABASE_URL is required' })
  @IsString()
  DATABASE_URL!: string;

  @IsNotEmpty({ message: 'JWT_SECRET is required' })
  @IsString()
  JWT_SECRET!: string;

  @IsNotEmpty({ message: 'DEVICE_TOKEN_PEPPER is required' })
  @IsString()
  DEVICE_TOKEN_PEPPER!: string;

  @IsOptional()
  @IsString()
  NODE_ENV?: string = 'development';

  @IsOptional()
  @IsNumber()
  PORT?: number = 3000;

  @IsOptional()
  @IsString()
  APP_VERSION?: string = '0.1.0-m1';

  @IsOptional()
  @IsString()
  LOG_LEVEL?: string = 'info';
}

export function validateEnv(config: Record<string, unknown>) {
  const validatedConfig = plainToInstance(EnvironmentVariables, config, {
    enableImplicitConversion: true,
  });
  const errors = validateSync(validatedConfig, {
    skipMissingProperties: false,
  });

  if (errors.length > 0) {
    const missingKeys = errors.map((err) => err.property).join(', ');
    throw new Error(
      `Server refuses to start: required environment variable(s) missing or invalid: ${missingKeys}`,
    );
  }
  return validatedConfig;
}
