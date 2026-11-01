import {
  BadRequestException,
  Injectable,
  NotFoundException,
  OnModuleInit,
} from '@nestjs/common';
import { ConfigService } from '@nestjs/config';
import { createHash } from 'crypto';
import { promises as fs } from 'fs';
import * as path from 'path';
import { v7 as uuidv7 } from 'uuid';
import { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { PrismaService } from '../prisma/prisma.service';
import { encodePhoto, sniffImageType } from './photo-image';

@Injectable()
export class PhotosService implements OnModuleInit {
  private readonly dir: string;

  constructor(
    private readonly prisma: PrismaService,
    config: ConfigService,
  ) {
    this.dir = config.getOrThrow<string>('PHOTO_DIR');
  }

  /** Fails at start, not at the first upload, if the folder is unusable. */
  async onModuleInit(): Promise<void> {
    await fs.mkdir(this.dir, { recursive: true });
    await fs.access(this.dir, fs.constants.W_OK);
  }

  fileFor(id: string): string {
    return path.join(this.dir, `${id}.webp`);
  }

  async upload(user: AuthenticatedUser, file?: Express.Multer.File) {
    if (!file?.buffer?.length) {
      throw new BadRequestException({
        code: 'VALIDATION_FAILED',
        message: 'A file field with an image is required',
      });
    }
    if (!sniffImageType(file.buffer)) {
      throw new BadRequestException({
        code: 'VALIDATION_FAILED',
        message: 'Only JPEG, PNG or WebP images are accepted',
      });
    }
    let encoded;
    try {
      encoded = await encodePhoto(file.buffer);
    } catch {
      throw new BadRequestException({
        code: 'VALIDATION_FAILED',
        message: 'The image could not be read',
      });
    }

    const id = uuidv7();
    const target = this.fileFor(id);
    // Write then rename, so a crash never leaves a half-written photo.
    await fs.writeFile(`${target}.part`, encoded.data);
    await fs.rename(`${target}.part`, target);
    const photo = await this.prisma.photo.create({
      data: {
        id,
        contentType: 'image/webp',
        bytes: encoded.data.length,
        width: encoded.width,
        height: encoded.height,
        sha256: createHash('sha256').update(encoded.data).digest('hex'),
        createdBy: user.staffId,
      },
    });
    return {
      id: photo.id,
      width: photo.width,
      height: photo.height,
      bytes: photo.bytes,
    };
  }

  async read(id: string): Promise<Buffer> {
    const photo = await this.prisma.photo.findUnique({ where: { id } });
    if (!photo) throw notFound();
    try {
      return await fs.readFile(this.fileFor(id));
    } catch {
      throw notFound();
    }
  }
}

function notFound(): NotFoundException {
  return new NotFoundException({
    code: 'NOT_FOUND',
    message: 'Photo not found',
  });
}
