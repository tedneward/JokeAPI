import {Module} from '@nestjs/common';
import {TypeOrmModule} from '@nestjs/typeorm';
import {Joke} from './joke.entity';
import {JokeService} from './joke.service';
import {JokeController} from './joke.controller';

@Module({
  imports: [
    // allow switching to a pure-JS driver (sql.js) in Docker via DB_DRIVER=sqljs
    TypeOrmModule.forRoot(
      process.env.DB_DRIVER === 'sqljs'
        ? {
            type: 'sqljs',
            location: 'data/jokes.sqlite',
            autoSave: true,
            entities: [Joke],
            synchronize: true
          }
        : {
            type: 'sqlite',
            database: 'data/jokes.db',
            entities: [Joke],
            synchronize: true
          }
    ),
    TypeOrmModule.forFeature([Joke])
  ],
  controllers: [JokeController],
  providers: [JokeService]
})
export class AppModule {}
