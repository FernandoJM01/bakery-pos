import { SetMetadata } from '@nestjs/common';

export const REQUIRE_DEVICE_KEY = 'requireDevice';

/**
 * Marks a route as requiring a valid, active X-Device-Token header (contract: `x-device: required`).
 */
export const RequireDevice = () => SetMetadata(REQUIRE_DEVICE_KEY, true);
