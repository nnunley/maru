# SDL3

Typed SDL3 bindings, measured from this machine's headers.

## Checks

- `sdl3_window` (`check/sdl3-window.k`, `sdl3.k`): `sdl3.k`, typed SDL3 over its C functions (measured in `sdl3.osdefs`), opens a
  window on SDL's dummy video driver, draws a known frame, reads its pixels back at four points and round-trips a mouse button,
  a motion and a key event. Offscreen fails on macOS (no GL), so the case sets `SDL_VIDEO_DRIVER=dummy`. `sdl3.osdefs.k` is
  measured from this machine's SDL3 headers when the check builds (it isn't tracked), and the case asserts it's up to date.
  Where `pkg-config` finds no SDL3 (or there's no `pkg-config`) it prints `SKIP` and passes.
