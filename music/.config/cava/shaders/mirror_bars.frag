#version 330

// Mirrored bar spectrum for cava's sdl_glsl output: bars grow up and down
// from a centre line, with pixel-exact bar width/spacing from the config.
// Colour follows the configured gradient left to right (bass to treble),
// matching the terminal profile in cmus.conf.

in vec2 fragCoord;
out vec4 fragColor;

uniform float bars[512];
uniform int bars_count;
uniform int bar_width;
uniform int bar_spacing;

uniform vec3 u_resolution;

uniform vec3 bg_color;
uniform vec3 fg_color;
uniform int gradient_count;
uniform vec3 gradient_colors[8];

vec3 gradient_at(float t) {
  if (gradient_count < 2) {
    return fg_color;
  }
  float pos = clamp(t, 0.0, 1.0) * float(gradient_count - 1);
  int i = min(int(floor(pos)), gradient_count - 2);
  return mix(gradient_colors[i], gradient_colors[i + 1], pos - float(i));
}

void main() {
  float x = u_resolution.x * fragCoord.x;
  float bar_size = u_resolution.x / float(bars_count);
  int bar = clamp(int(x / bar_size), 0, bars_count - 1);

  // Half-height of this bar, at least one pixel so silence draws a thin line.
  float h = max(bars[bar], 1.0 / u_resolution.y);
  float dist = abs(fragCoord.y - 0.5) * 2.0;

  bool in_gap = x > float(bar + 1) * bar_size - float(bar_spacing);

  if (dist < h && !in_gap) {
    fragColor = vec4(gradient_at(fragCoord.x), 1.0);
  } else {
    fragColor = vec4(bg_color, 1.0);
  }
}
