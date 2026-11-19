// FlutterKaigi 2026 — title slide.
//
// A domain-warped aurora (fbm of fbm) in the deck palette, with three liquid
// glass metaballs floating over it. One of them follows the pointer. Because
// the background is a pure function of position, the glass can "refract" it
// by simply evaluating that function at a displaced coordinate — no
// texture, no BackdropFilter, works on every renderer.

#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;      // logical size of the slide
uniform float uTime;     // seconds
uniform vec2 uMouse;     // pointer, logical px
uniform float uGlass;    // 0 = aurora only, 1 = glass blobs fully in
uniform float uPress;    // 0..1 while the pointer is down — blob swells

out vec4 fragColor;

// ── Palette (matches DeckColors) ──────────────────────────────────────────
const vec3 CANVAS = vec3(0.031, 0.031, 0.047);
const vec3 PINK   = vec3(1.000, 0.216, 0.373);
const vec3 PURPLE = vec3(0.749, 0.353, 0.949);
const vec3 BLUE   = vec3(0.039, 0.518, 1.000);
const vec3 CYAN   = vec3(0.392, 0.824, 1.000);

// ── Noise ─────────────────────────────────────────────────────────────────
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
  mat2 rot = mat2(0.8, 0.6, -0.6, 0.8);
  for (int i = 0; i < 5; i++) {
    v += a * noise(p);
    p = rot * p * 2.02 + 17.0;
    a *= 0.5;
  }
  return v;
}

// The aurora. `p` is aspect-corrected, roughly -1..1 on the short axis.
vec3 aurora(vec2 p) {
  float t = uTime * 0.06;
  vec2 q = vec2(fbm(p * 1.1 + vec2(0.0, t)),
                fbm(p * 1.1 + vec2(5.2, 1.3) - t));
  vec2 r = vec2(fbm(p * 1.4 + 3.2 * q + vec2(1.7, 9.2) + t * 1.4),
                fbm(p * 1.4 + 3.2 * q + vec2(8.3, 2.8) - t * 1.2));
  float f = fbm(p * 1.25 + 3.6 * r);

  vec3 col = CANVAS;
  col = mix(col, PURPLE * 0.55, smoothstep(0.35, 0.95, f));
  col = mix(col, PINK * 0.85, smoothstep(0.55, 1.15, length(q)) * 0.75);
  col = mix(col, BLUE * 0.9, smoothstep(0.45, 0.95, r.y) * 0.65);
  col += CYAN * pow(max(f - 0.45, 0.0), 2.0) * 2.2;

  // Colour pools top-right; the bottom-left stays dark for the title text.
  vec2 uv = p / vec2(uSize.x / uSize.y, 1.0) * 0.5 + 0.5;
  float pool = smoothstep(-0.2, 1.1, uv.x * 0.9 + (1.0 - uv.y) * 0.55);
  col *= mix(0.22, 1.25, pool);
  return col;
}

// ── Glass ─────────────────────────────────────────────────────────────────
float smin(float a, float b, float k) {
  float h = max(k - abs(a - b), 0.0) / k;
  return min(a, b) - h * h * k * 0.25;
}

// Signed distance (in px) to the union of the three blobs.
float scene(vec2 px) {
  float t = uTime;
  float s = min(uSize.x, uSize.y);
  vec2 a = uSize * vec2(0.80, 0.56) + vec2(cos(t * 0.37), sin(t * 0.52)) * s * 0.10;
  vec2 b = uSize * vec2(0.90, 0.78) + vec2(sin(t * 0.29), cos(t * 0.41)) * s * 0.08;
  float ra = s * 0.13 * uGlass;
  float rb = s * 0.085 * uGlass;
  float rm = s * (0.075 + 0.025 * uPress) * uGlass;

  float d = length(px - a) - ra;
  d = smin(d, length(px - b) - rb, s * 0.12);
  d = smin(d, length(px - uMouse) - rm, s * 0.14);
  return d;
}

vec2 toP(vec2 px) {
  return (px - 0.5 * uSize) / uSize.y * 2.0;
}

void main() {
  vec2 px = FlutterFragCoord().xy;
  vec2 p = toP(px);

  float d = scene(px);
  vec3 col;

  if (uGlass > 0.001 && d < 1.5) {
    // Normal from the SDF gradient, same trick as liquid_glass_renderer.
    float e = 1.5;
    vec2 g = vec2(scene(px + vec2(e, 0)) - scene(px - vec2(e, 0)),
                  scene(px + vec2(0, e)) - scene(px - vec2(0, e)));
    vec2 n2 = g / max(length(g), 1e-4);

    // A circular "lens" profile: flat in the middle, steep at the rim.
    float thickness = min(uSize.x, uSize.y) * 0.06;
    float x = clamp(1.0 + d / thickness, 0.0, 1.0);   // 0 deep inside → 1 at rim
    float slope = x * x * x;
    vec3 n = normalize(vec3(n2 * slope, 1.0 - slope * 0.85));

    vec3 refr = refract(vec3(0, 0, -1), n, 1.0 / 1.45);
    vec2 disp = refr.xy * thickness * 2.2;

    // Chromatic aberration: sample the aurora three times.
    float ca = 0.10;
    col.r = aurora(toP(px + disp * (1.0 + ca))).r;
    col.g = aurora(toP(px + disp)).g;
    col.b = aurora(toP(px + disp * (1.0 - ca))).b;

    // Glass tint + saturation lift.
    col = mix(col, col * 1.25 + 0.03, 0.6);

    // Rim light from the top-left plus a dimmer counter light.
    vec2 light = normalize(vec2(-0.6, -0.8));
    float rim = smoothstep(0.55, 1.0, x);
    float key = max(dot(n2, light), 0.0);
    float back = max(dot(n2, -light), 0.0) * 0.45;
    col += vec3(1.0) * rim * (key + back) * 0.9;
    col += vec3(1.0) * pow(rim, 6.0) * 0.25;

    // Anti-aliased edge back into the aurora.
    float alpha = 1.0 - smoothstep(-1.0, 1.5, d);
    col = mix(aurora(p), col, alpha);

    // Soft contact shadow just outside the blob.
  } else {
    col = aurora(p);
    float shadow = uGlass * (1.0 - smoothstep(0.0, 60.0, d)) * 0.28;
    col *= 1.0 - shadow;
  }

  // Film grain keeps the gradients from banding on a projector.
  col += (hash(px + fract(uTime)) - 0.5) * 0.025;

  fragColor = vec4(col, 1.0);
}
