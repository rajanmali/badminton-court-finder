import { Controller, Get, InternalServerErrorException } from '@nestjs/common';
import { VenuesService } from './venues.service';

@Controller('venues')
export class VenuesController {
  constructor(private readonly venues: VenuesService) {}

  @Get()
  async findAll() {
    try {
      const venues = await this.venues.findAll();
      return { venues };
    } catch (err) {
      throw new InternalServerErrorException((err as Error).message);
    }
  }
}
