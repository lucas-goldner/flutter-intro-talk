// "Warp portal" — a wormhole that opens around the pointer. Polar
// coordinates around the centre turn a scrolling noise field into a
// tunnel; the twist, speed and hue come from sliders on the slide.

#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform float uTime;
uniform vec2 uMouse;    // pointer, logical px
uniform float uSpeed;   // tunnel speed
uniform float uTwist;   // spiral amount
uniform float uHue;     // 0..1 palette shift
uniform float uWarp;    // 0..1 eased "press" — a warp jump

out vec4 fragColor;

const float PI = 3.14159265;

float hash(vec2 p) {
  p = fract(p * vec2(123.34, 456.21));
  p += dot(p, p + 45.32);
  return fract(p.x * p.y);
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
  for (int i = 0; i < 5; i++) {
    v += a * noise(p);
    p = p * 2.03 + 11.7;
    a *= 0.5;
  }
  return v;
}

// Cosine palette (Inigo Quilez) — uHue rotates through it.
vec3 palette(float t) {
  vec3 a = vec3(0.5, 0.45, 0.6);
  vec3 b = vec3(0.5, 0.45, 0.4);
  vec3 c = vec3(1.0, 1.0, 1.0);
  vec3 d = vec3(0.85, 0.35, 0.65) + uHue;
  return a + b * cos(2.0 * PI * (c * t + d));
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 uv = (frag - uMouse) / uSize.y;

  float r = length(uv) + 1e-4;
  float a = atan(uv.y, uv.x);

  float speed = uSpeed * (1.0 + 4.0 * uWarp);
  float depth = 0.35 / r + uTime * speed;
  float ang = a / PI + uTwist * depth * 0.15;

  // Seamless angular coordinate: sample noise on a circle.
  vec2 tc = vec2(cos(ang * PI), sin(ang * PI)) * 1.6 + vec2(depth, 0.0);
  float n = fbm(tc * 1.4);
  float n2 = fbm(tc * 3.1 + n * 2.0 - uTime * 0.2);

  vec3 col = palette(n * 0.9 + depth * 0.05 + n2 * 0.3);
  col *= smoothstep(0.0, 0.9, n2 + 0.25);

  // Bright streaks during a warp jump.
  float streak = pow(noise(vec2(ang * 40.0, depth * 0.5)), 12.0);
  col += vec3(1.0) * streak * (0.3 + 2.0 * uWarp);

  // Depth fade: dark far away (centre), glowing throat ring.
  float throat = exp(-pow((r - 0.06 - 0.04 * uWarp) * 18.0, 2.0));
  col *= smoothstep(0.0, 0.25, r);
  col += palette(uTime * 0.05 + 0.3) * throat * 1.4;
  col += vec3(1.0) * exp(-r * 40.0) * (0.4 + uWarp);

  // Vignette to the canvas.
  vec2 q = frag / uSize;
  col *= 0.4 + 0.6 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.25);
  col = clamp(col, 0.0, 1.0);
  fragColor = vec4(col, 1.0);
}
