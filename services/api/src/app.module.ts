import { Module } from '@nestjs/common';
import { ConfigModule } from '@nestjs/config';
import { TerminusModule } from '@nestjs/terminus';
import { HealthController } from './health/health.controller';
import { VenuesModule } from './venues/venues.module';

@Module({
  imports: [ConfigModule.forRoot({ isGlobal: true }), TerminusModule, VenuesModule],
  controllers: [HealthController],
})
export class AppModule {}
