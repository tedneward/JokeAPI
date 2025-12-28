import {NestFactory} from '@nestjs/core';
import {AppModule} from './app.module';

async function bootstrap() {
  const app = await NestFactory.create(AppModule);
  await app.listen(process.env.PORT ? +process.env.PORT : 8000, '0.0.0.0');
  console.log('NestJS server listening on port', process.env.PORT || 8000);
}

if (require.main === module) {
  bootstrap().catch(err => {
    console.error(err);
    process.exit(1);
  });
}

export default bootstrap;
