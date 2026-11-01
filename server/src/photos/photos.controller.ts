import {
  Controller,
  Get,
  HttpCode,
  HttpStatus,
  Param,
  ParseUUIDPipe,
  Post,
  Res,
  StreamableFile,
  UploadedFile,
  UseInterceptors,
} from '@nestjs/common';
import { FileInterceptor } from '@nestjs/platform-express';
import type { Response } from 'express';
import type { AuthenticatedUser } from '../auth/interfaces/auth.interface';
import { CurrentUser } from '../common/decorators/current-user.decorator';
import { Public } from '../common/decorators/public.decorator';
import { RequirePermission } from '../common/decorators/require-permission.decorator';
import { MAX_UPLOAD_BYTES } from './photo-image';
import { PhotosService } from './photos.service';

@Controller('photos')
export class PhotosController {
  constructor(private readonly photos: PhotosService) {}

  @Post()
  @HttpCode(HttpStatus.CREATED)
  @RequirePermission('catalog.manage')
  @UseInterceptors(
    FileInterceptor('file', {
      limits: { fileSize: MAX_UPLOAD_BYTES, files: 1 },
    }),
  )
  upload(
    @CurrentUser() user: AuthenticatedUser,
    @UploadedFile() file?: Express.Multer.File,
  ) {
    return this.photos.upload(user, file);
  }

  // Photo ids are random and photos are not sensitive (contract: x-public).
  // Headers are set only once the photo is found, so a 404 stays JSON.
  @Get(':photoId')
  @Public()
  async get(
    @Param('photoId', ParseUUIDPipe) id: string,
    @Res({ passthrough: true }) res: Response,
  ) {
    const data = await this.photos.read(id);
    res.setHeader('Cache-Control', 'public, max-age=31536000, immutable');
    return new StreamableFile(data, { type: 'image/webp' });
  }
}
