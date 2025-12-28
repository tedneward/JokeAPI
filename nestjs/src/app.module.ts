import {Module} from '@nestjs/common';
import {TypeOrmModule} from '@nestjs/typeorm';
import {Joke} from './joke.entity';
import {JokeService} from './joke.service';
import {JokeController} from './joke.controller';

@Module({
  imports: [
    TypeOrmModule.forRoot({
      type: 'sqlite',
      database: 'data/jokes.db',
      entities: [Joke],
      synchronize: true
    }),
    TypeOrmModule.forFeature([Joke])
  ],
  controllers: [JokeController],
  providers: [JokeService]
})
export class AppModule {}
