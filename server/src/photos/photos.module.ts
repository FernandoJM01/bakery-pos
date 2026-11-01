import { Module } from '@nestjs/common';
import { PrismaModule } from '../prisma/prisma.module';
import { PhotosController } from './photos.controller';
import { PhotosService } from './photos.service';

@Module({
  imports: [PrismaModule],
  controllers: [PhotosController],
  providers: [PhotosService],
})
export class PhotosModule {}
