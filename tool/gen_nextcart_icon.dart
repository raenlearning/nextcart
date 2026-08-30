import 'dart:io';
import 'package:image/image.dart';

// Renders nextcart-logo.svg to 1024x1024 PNGs using image package primitives.
// SVG: indigo #4F46E5 rounded square, white cart+chevron, one coral wheel #FF6B4A.
void main() {
  const int w = 1024, h = 1024;
  const double s = 2.0; // scale factor (512→1024)

  final bg = ColorRgba8(0x4F, 0x46, 0xE5, 255);
  final white = ColorRgba8(255, 255, 255, 255);
  final coral = ColorRgba8(0xFF, 0x6B, 0x4A, 255);

  Image make({required bool transparent}) {
    final img = Image(width: w, height: h);

    // background rounded rect
    if (!transparent) {
      fillRect(img, x1: 0, y1: 0, x2: w - 1, y2: h - 1, color: bg);
    }

    // Handle / forward arrow (white, thick stroke → draw as filled polygon)
    // SVG path: M 118 168 L 176 216 L 118 264 (chevron)
    // Approximate with a thick filled polygon (stroke-width 30 → ~60 at 2x)
    fillPolygon(
      img,
      vertices: [
        Point((118 * s - 30).round(), (168 * s).round()),
        Point((176 * s).round(), (216 * s).round()),
        Point((118 * s - 30).round(), (264 * s).round()),
        Point((118 * s + 30).round(), (244 * s).round()),
        Point((156 * s).round(), (216 * s).round()),
        Point((118 * s + 30).round(), (188 * s).round()),
      ],
      color: white,
    );

    // Cart basket (stroke → approximate with filled polygon for outline)
    // SVG: M 176 216 L 396 216 L 358 336 L 202 336 Z
    // We'll draw the basket as a filled polygon (white) then overlay inner with bg
    // to create a stroke effect. Simpler: draw filled basket outline with thick edges.
    // Outer basket
    fillPolygon(
      img,
      vertices: [
        Point((176 * s).round(), (216 * s).round()),
        Point((396 * s).round(), (216 * s).round()),
        Point((358 * s).round(), (336 * s).round()),
        Point((202 * s).round(), (336 * s).round()),
      ],
      color: white,
    );
    // Inner cutout (bg color) to make it stroke-only
    final innerColor = transparent ? ColorRgba8(0, 0, 0, 0) : bg;
    fillPolygon(
      img,
      vertices: [
        Point((176 * s + 30).round(), (216 * s + 30).round()),
        Point((396 * s - 30).round(), (216 * s + 30).round()),
        Point((362 * s - 10).round(), (336 * s - 30).round()),
        Point((206 * s + 10).round(), (336 * s - 30).round()),
      ],
      color: innerColor,
    );

    // Wheels
    fillCircle(img, x: (232 * s).round(), y: (384 * s).round(), radius: (24 * s).round(), color: white, antialias: true);
    fillCircle(img, x: (330 * s).round(), y: (384 * s).round(), radius: (24 * s).round(), color: coral, antialias: true);

    return img;
  }

  File('assets/branding/nextcart_logo.png')
      .writeAsBytesSync(encodePng(make(transparent: false)));
  File('assets/branding/nextcart_icon_foreground.png')
      .writeAsBytesSync(encodePng(make(transparent: true)));
  print('NextCart logo rendered from SVG to PNG.');
}
