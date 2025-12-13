/**
 * Returns the arguments of a function F as an array.
 */
// prettier-ignore
export type ArgumentsOf<F extends Function>
  = F extends (...args: infer A) => unknown ? A : never;

export enum BandcampImageSize {
  PNG_2000_8BIT = 0,
  PNG_2000_16BIT,
  JPEG_350,
  JPEG_100,
  JPEG_400,
  JPEG_700,
  JPEG_100_1,
  JPEG_150,
  JPEG_124,
  JPEG_210,
  JPEG_1200,
  JPEG_172,
  JPEG_138,
  JPEG_380,
  JPEG_368,
  JPEG_135,
  JPEG_700_1,
  JPEG_1024 = 21,
  PNG_1024 = 31,
  PNG_LARGE_MIDDLECROPPED = 100,
}
