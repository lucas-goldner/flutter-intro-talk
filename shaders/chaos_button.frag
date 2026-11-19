// "chaos button" — a black pill that erupts into turbulent contour lines
// around the pointer when hovered. Inspired by @realvjy's button.

#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;    // button size
uniform float uTime;
uniform float uHover;  // 0..1 eased
uniform vec2 uMouse;   // local px

out vec4 fragColor;

float hash(vec2 p) {
  return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
}

float noise(vec2 p) {
  vec2 i = floor(p);
  vec2 f = fract(p);
  vec2 u = f * f * (3.0 - 2.0 * f);
  return mix(mix(hash(i), hash(i + vec2(1, 0)), u.x),
             mix(hash(i + vec2(0, 1)), hash(i + vec2(1, 1)), u.x), u.y);
}

float fbm(vec2 p) {
  float v = 0.0;
  float a = 0.5;
  for (int i = 0; i < 4; i++) {
    v += a * noise(p);
    p = p * 2.03 + 11.0;
    a *= 0.5;
  }
  return v;
}

float sdRoundBox(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

void main() {
  vec2 px = FlutterFragCoord().xy;
  vec2 hs = uSize * 0.5;
  float d = sdRoundBox(px - hs, hs - 2.0, hs.y - 2.0);

  float inside = 1.0 - smoothstep(-1.0, 0.5, d);
  float border = 1.0 - smoothstep(0.6, 2.0, abs(d));

  // Turbulent contour lines.
  vec2 p = px / uSize.y * 1.6;
  float n = fbm(p + vec2(uTime * 0.35, -uTime * 0.2) + fbm(p * 1.7 - uTime * 0.3) * 1.8);
  float lines = 1.0 - smoothstep(0.0, 0.08, abs(fract(n * 9.0) - 0.5) - 0.38);

  float near = exp(-pow(length(px - uMouse) / (uSize.y * 1.4), 2.0));
  float chaos = uHover * (0.25 + 0.75 * near);

  vec3 blue = vec3(0.25, 0.45, 1.0);
  vec3 col = vec3(0.0);
  col += mix(blue, vec3(1.0), near * 0.6) * lines * chaos;
  col += vec3(1.0) * border * (0.75 + 0.25 * uHover);
  col += blue * border * near * uHover * 1.5;

  float a = max(inside, border);
  fragColor = vec4(col * a, a);
}
