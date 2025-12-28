import {Controller, Post, Body, Get, Param, Put, Delete} from '@nestjs/common';
import {JokeService} from './joke.service';
import {Joke} from './joke.entity';

@Controller('jokes')
export class JokeController {
  constructor(private service: JokeService) {}

  @Post()
  create(@Body() body: Partial<Joke>) {
    return this.service.create(body);
  }

  @Get('random')
  random() {
    return this.service.random();
  }

  @Get('random/category/:category')
  randomByCategory(@Param('category') category: string) {
    return this.service.randomByCategory(category);
  }

  @Get('source/:source')
  bySource(@Param('source') source: string) {
    return this.service.bySource(source);
  }

  @Get(':id')
  findById(@Param('id') id: string) {
    return this.service.findById(id);
  }

  @Put(':id')
  update(@Param('id') id: string, @Body() body: Partial<Joke>) {
    return this.service.update(id, body);
  }

  @Delete(':id')
  delete(@Param('id') id: string) {
    return this.service.delete(id);
  }

  @Post(':id/bump/lol')
  bumpLol(@Param('id') id: string) {
    return this.service.bumpLol(id);
  }

  @Post(':id/bump/groan')
  bumpGroan(@Param('id') id: string) {
    return this.service.bumpGroan(id);
  }
}
