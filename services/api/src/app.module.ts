import { Module } from '@nestjs/common';
import { TerminusModule } from '@nestjs/terminus';
import { HealthController } from './health/health.controller';
import { VenuesModule } from './venues/venues.module';

@Module({
  imports: [TerminusModule, VenuesModule],
  controllers: [HealthController],
})
export class AppModule {}
