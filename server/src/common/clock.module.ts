import { Global, Module } from '@nestjs/common';
import { ClockService } from './clock.service';

/**
 * One ClockService for the whole app. Registering it in several modules
 * creates separate instances, and a test that moves one clock would not move
 * the others (for example the global AuthGuard's).
 */
@Global()
@Module({
  providers: [ClockService],
  exports: [ClockService],
})
export class ClockModule {}
