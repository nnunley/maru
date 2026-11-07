"squeak-ttf.st -- Squeak's TrueType classes (TTCFont, its description, TTGlyph) and Frank's GeziraPath, as KSWorld's KSFont
 and KSShape use them, in test-pepsi.l's form over truetype.l: what Squeak's image read from a .ttf, read by our reader.  A
 family is found as ksworld-text.l's font chain finds one, and a character the font lacks in the next font with a glyph for
 it (TTCFont's fallbackFont).  Lengths are in font units, y up, as a TTGlyph's are."

TTCFont : Object ()
TTGlyph : Object ()
GeziraPath : Object ()

TTCFont class familyName: name pointSize: size emphasis: style { (ks-ttc-font name size style) }
TTCFont isTTCFont                       [ true ]
Object isTTCFont                        [ false ]
TTCFont ttcDescription                  { (ks-slot self 'description) }

TTFontDescription unitsPerEm            { (<ttf>-upem (car (ks-slot self 'fonts))) }
TTFontDescription ascender              { (<ttf>-ascent (car (ks-slot self 'fonts))) }
TTFontDescription descender             { (<ttf>-descent (car (ks-slot self 'fonts))) }
TTFontDescription size                  [ 65536 ]
TTFontDescription at: code              { (ks-ttc-glyph self code) }

TTGlyph advanceWidth                    { (ttf-advance (ks-slot self 'font) (ks-slot self 'glyph)) }
TTGlyph leftSideBearing                 { (ttf-lsb (ks-slot self 'font) (ks-slot self 'glyph)) }
TTGlyph bounds                          { (let ((b (ttf-bounds (ks-slot self 'font) (ks-slot self 'glyph)))) (ks-rect (car b) (cadr b) (caddr b) (cadddr b))) }
TTGlyph asGeziraPath                    { (ks-glyph-float-array (ks-slot self 'font) (ks-slot self 'glyph)) }
TTGlyph transformFor: scale             [ | b | b := self bounds.
                                          "font units to the box: scaled, y down, the ink's top left at the origin"
                                          MatrixTransform2x3 a: scale b: 0 c: 0 d: scale negated e: b left * scale negated f: b bottom * scale ]

GeziraPath class path: floats           { (new <ks-object> 'GeziraPath 0 () (list (cons 'floats floats) (cons 'fill 'nil)) () 0) }
GeziraPath fill: aColor                 { (let () (ks-set-slot self 'fill aColor) self) }
MatrixTransform2x3 : Object ()
MatrixTransform2x3 class a: a b: b c: c d: d e: e f: f { (ks-matrix a b c d e f) }
