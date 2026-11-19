// A dynamic "now playing" background: four colours picked from the album
// art drift around as soft blobs, warped by noise, pulsing with the beat.

#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform float uTime;
uniform vec3 uColors[4];
uniform float uBeat;   // 0..1, spikes on every beat

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

void main() {
  vec2 px = FlutterFragCoord().xy;
  vec2 uv = px / uSize;
  float t = uTime * 0.25;

  // Warp the lookup so the blobs melt into each other.
  vec2 w = uv + 0.18 * vec2(noise(uv * 3.0 + t), noise(uv * 3.0 - t + 7.0)) - 0.09;

  vec3 col = vec3(0.0);
  float total = 0.0;
  for (int i = 0; i < 4; i++) {
    float fi = float(i);
    vec2 c = vec2(0.5) + 0.38 * vec2(cos(t * (0.9 + fi * 0.23) + fi * 1.7),
                                     sin(t * (1.1 + fi * 0.17) + fi * 2.3));
    float d = length((w - c) * vec2(uSize.x / uSize.y, 1.0));
    float wgt = exp(-d * d * (5.0 - uBeat * 1.5));
    col += uColors[i] * wgt;
    total += wgt;
  }
  col /= max(total, 1e-3);

  // Darken toward the bottom so the player controls stay legible.
  col *= mix(1.05, 0.45, smoothstep(0.35, 1.0, uv.y));
  col *= 1.0 + uBeat * 0.12;
  col += (hash(px + fract(uTime)) - 0.5) * 0.03;

  fragColor = vec4(col, 1.0);
}
