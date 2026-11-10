# PNG

The PNG decoder and encoder in irl, held to fixtures, hostile input and sanitizers.

## Checks

- `png` (`check/png.l`): `png.l`'s `(png-load path)` reads an 8-bit RGBA or RGB PNG, not interlaced, to a `<png>`: width,
  height and width x height ARGB words in C memory (alpha on top, not premultiplied), as a Gezira image holds them. The
  decoder is `png.irl`, typed and lowered through ir2 into `build/png.dylib`: every chunk's CRC-32 is checked, the data
  inflated (stored, fixed and dynamic Huffman blocks) and checked against its Adler-32, and every row filter undone;
  ancillary chunks are skipped and an unknown critical one refused (PNG 5.4), and anything else is an error naming it. Our
  fixtures (`check/png/`) are held to pixels worked out separately through zlib: every block kind and filter, RGB, and
  `chunks.png`'s chunks with no pixels (gAMA, cHRM, sRGB, pHYs, tEXt, zTXt, iTXt, a suggested PLTE, a private one, tIME and
  tEXt after the data) around data split over three IDATs. Hostile input is refused for its own reason, never read past
  (`check/png/bad/`, one file per rule): a file that ends early or a chunk longer than the file, IHDR missing, not first or
  not 13 bytes, a zero or too large width or height (at most 2^24 each and 2^28 pixels), a compression or filter method
  other than 0, no IEND, a zlib preset dictionary or missing trailer, a stored block whose NLEN isn't LEN's complement or
  whose LEN runs past the data, a length or distance code no stream may use, and an over-subscribed Huffman code.
  `png-encode` writes an image back (any filter per row, stored
  or fixed Huffman blocks with runs, IDATs of any size, tEXt around them), and 120 random images round-trip pixel for
  pixel. With `MARU_DBJR` the front page's image (730 x 980, which `fetch-dbjr` fetches with every image a document
  names) at five points and in its byte sum; it decodes in well under a second.
- `png_asan` (`check/png-asan.irl`): `png.irl` built with a harness (an irl program with its own `main`) under
  AddressSanitizer and UndefinedBehaviorSanitizer; every PNG fixture, good and hostile, is read into a buffer of exactly
  its size, so any read past the input fails the case.
