import { Controller, Get, NotFoundException, Param, InternalServerErrorException } from '@nestjs/common';
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

  @Get(':id')
  async findOne(@Param('id') id: string) {
    try {
      const venue = await this.venues.findOne(id);
      if (!venue) throw new NotFoundException(`Venue ${id} not found`);
      return { venue };
    } catch (err) {
      if (err instanceof NotFoundException) throw err;
      throw new InternalServerErrorException((err as Error).message);
    }
  }
}
