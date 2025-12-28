import {Test, TestingModule} from '@nestjs/testing';
import {TypeOrmModule} from '@nestjs/typeorm';
import {JokeService} from '../joke.service';
import {Joke} from '../joke.entity';

describe('JokeService (e2e)', () => {
  let service: JokeService;

  beforeAll(async () => {
    const module: TestingModule = await Test.createTestingModule({
      imports: [
        TypeOrmModule.forRoot({
          type: 'sqlite',
          database: ':memory:',
          dropSchema: true,
          entities: [Joke],
          synchronize: true
        }),
        TypeOrmModule.forFeature([Joke])
      ],
      providers: [JokeService]
    }).compile();

    service = module.get<JokeService>(JokeService);
  });

  it('create -> bump -> delete', async () => {
    const created = await service.create({setup: 'S', punchline: 'P'});
    expect(created).toBeDefined();
    const id = created.id;
    const found = await service.findById(id);
    expect(found.setup).toBe('S');
    await service.bumpLol(id);
    const bumped = await service.findById(id);
    expect(bumped.lolCount).toBe(1);
    await service.bumpGroan(id);
    const bg = await service.findById(id);
    expect(bg.groanCount).toBe(1);
    await service.delete(id);
    try {
      await service.findById(id);
      throw new Error('should not reach');
    } catch (e) {}
  });
});
