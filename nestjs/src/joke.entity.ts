import {Entity, PrimaryColumn, Column} from 'typeorm';

@Entity()
export class Joke {
  @PrimaryColumn()
  id: string;

  @Column()
  setup: string;

  @Column()
  punchline: string;

  @Column({default: ''})
  category: string;

  @Column({default: 'ted'})
  source: string;

  @Column({default: 0})
  lolCount: number;

  @Column({default: 0})
  groanCount: number;
}
