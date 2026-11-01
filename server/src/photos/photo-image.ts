import sharp from 'sharp';

export const MAX_UPLOAD_BYTES = 5 * 1024 * 1024;
export const MAX_SIDE_PX = 800;

/**
 * Tells JPEG, PNG and WebP apart by their first bytes. The file name and the
 * declared content type are ignored: a renamed text file or an SVG never
 * reaches the image decoder.
 */
export function sniffImageType(buf: Buffer): 'jpeg' | 'png' | 'webp' | null {
  if (
    buf.length >= 3 &&
    buf[0] === 0xff &&
    buf[1] === 0xd8 &&
    buf[2] === 0xff
  ) {
    return 'jpeg';
  }
  if (
    buf.length >= 8 &&
    buf
      .subarray(0, 8)
      .equals(Buffer.from([0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a]))
  ) {
    return 'png';
  }
  if (
    buf.length >= 12 &&
    buf.toString('latin1', 0, 4) === 'RIFF' &&
    buf.toString('latin1', 8, 12) === 'WEBP'
  ) {
    return 'webp';
  }
  return null;
}

export interface EncodedPhoto {
  data: Buffer;
  width: number;
  height: number;
}

/**
 * Re-encodes to WebP no larger than 800 × 800. Turning the image upright
 * first means the EXIF orientation is not needed, and sharp drops all
 * metadata (EXIF, GPS, ICC) unless asked to keep it.
 */
export async function encodePhoto(input: Buffer): Promise<EncodedPhoto> {
  const { data, info } = await sharp(input, {
    failOn: 'error',
    limitInputPixels: 50_000_000,
  })
    .rotate()
    .resize(MAX_SIDE_PX, MAX_SIDE_PX, {
      fit: 'inside',
      withoutEnlargement: true,
    })
    .webp({ quality: 82 })
    .toBuffer({ resolveWithObject: true });
  return { data, width: info.width, height: info.height };
}
