// "Galaxy button" — hover and a spiral galaxy wakes up inside the button,
// spinning around the pointer.

#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform float uTime;
uniform float uHover;
uniform vec2 uMouse;

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

float sdRoundBox(vec2 p, vec2 b, float r) {
  vec2 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, q.y), 0.0) - r;
}

float stars(vec2 p, float density) {
  vec2 cell = floor(p);
  vec2 f = fract(p) - 0.5;
  float h = hash(cell);
  vec2 o = vec2(hash(cell + 3.1), hash(cell + 7.7)) - 0.5;
  float twinkle = 0.5 + 0.5 * sin(uTime * (2.0 + h * 4.0) + h * 30.0);
  float s = smoothstep(0.08, 0.0, length(f - o * 0.7)) * step(1.0 - density, h);
  return s * twinkle;
}

void main() {
  vec2 px = FlutterFragCoord().xy;
  vec2 hs = uSize * 0.5;
  float r = min(hs.y, 26.0);
  float d = sdRoundBox(px - hs, hs - 1.5, r);
  float inside = 1.0 - smoothstep(-1.0, 0.5, d);
  float border = 1.0 - smoothstep(0.5, 1.8, abs(d));

  // Spiral arms around a centre that leans toward the pointer.
  vec2 c = mix(hs, uMouse, 0.7 * uHover);
  vec2 q = (px - c) / uSize.y;
  float rad = length(q);
  float ang = atan(q.y, q.x);
  float spin = uTime * 0.8;
  float arms = 0.5 + 0.5 * sin(ang * 2.0 - log(rad + 0.05) * 5.0 + spin);
  float dust = noise(q * 6.0 + vec2(spin * 0.3, 0.0));
  float core = exp(-rad * 5.5);
  float galaxy = (pow(arms, 3.0) * dust * exp(-rad * 1.6) + core) * uHover;

  vec3 base = mix(vec3(0.20, 0.06, 0.32), vec3(0.42, 0.10, 0.48), px.x / uSize.x);
  vec3 col = base;
  col += mix(vec3(0.75, 0.35, 0.95), vec3(1.0, 0.45, 0.7), arms) * galaxy * 1.4;
  col += vec3(1.0, 0.9, 1.0) * core * uHover * 0.8;
  col += vec3(1.0) * stars(px / 7.0, 0.12) * (0.35 + 0.65 * uHover);

  col += vec3(0.85, 0.6, 1.0) * border * (0.45 + 0.55 * uHover);

  float a = max(inside, border);
  fragColor = vec4(col * a, a);
}
