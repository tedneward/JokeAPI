import {Injectable, NotFoundException} from '@nestjs/common';
import {InjectRepository} from '@nestjs/typeorm';
import {Repository} from 'typeorm';
import {Joke} from './joke.entity';
import {v4 as uuidv4} from 'uuid';

@Injectable()
export class JokeService {
  constructor(@InjectRepository(Joke) private repo: Repository<Joke>) {}

  async create(data: Partial<Joke>) {
    if (!data.setup || !data.punchline) throw new Error('setup and punchline required');
    if (!data.id) data.id = uuidv4();
    const j = this.repo.create(data as Joke);
    return this.repo.save(j);
  }

  async findById(id: string) {
    const j = await this.repo.findOne({where: {id}});
    if (!j) throw new NotFoundException();
    return j;
  }

  async update(id: string, body: Partial<Joke>) {
    const j = await this.findById(id);
    Object.assign(j, body);
    return this.repo.save(j);
  }

  async delete(id: string) {
    await this.repo.delete({id});
  }

  async bumpLol(id: string) {
    const j = await this.findById(id);
    j.lolCount = (j.lolCount || 0) + 1;
    return this.repo.save(j);
  }

  async bumpGroan(id: string) {
    const j = await this.findById(id);
    j.groanCount = (j.groanCount || 0) + 1;
    return this.repo.save(j);
  }

  async random() {
    const all = await this.repo.find();
    if (!all || all.length === 0) throw new NotFoundException();
    return all[Math.floor(Math.random() * all.length)];
  }

  async randomByCategory(category: string) {
    const list = await this.repo.find({where: {category}});
    if (!list || list.length === 0) throw new NotFoundException();
    return list[Math.floor(Math.random() * list.length)];
  }

  async bySource(source: string) {
    return this.repo.find({where: {source}});
  }
}
