// A tiny raymarched 3D scene: a Flutter-logo-ish shape built from three
// rounded beams, three glossy orbs, a reflective grid floor, soft shadows.
// The camera orbits with uYaw / uPitch (drag), uExplode pulls the beams
// apart so you can see they really are 3D.
//
// Everything is one fragment shader — no meshes, no 3D engine.

#version 460 core
#include <flutter/runtime_effect.glsl>

precision highp float;

uniform vec2 uSize;
uniform float uTime;
uniform float uYaw;      // radians
uniform float uPitch;    // radians
uniform float uExplode;  // 0..1

out vec4 fragColor;

const vec3 CANVAS = vec3(0.031, 0.031, 0.047);
const vec3 PINK   = vec3(1.000, 0.216, 0.373);
const vec3 PURPLE = vec3(0.749, 0.353, 0.949);
const vec3 BLUE   = vec3(0.039, 0.518, 1.000);
const vec3 CYAN   = vec3(0.392, 0.824, 1.000);
const vec3 ORANGE = vec3(1.000, 0.624, 0.039);
const vec3 DART   = vec3(0.329, 0.773, 0.973);
const vec3 NAVY   = vec3(0.008, 0.337, 0.608);

const float S2 = 0.70710678;

float sdRoundBox(vec3 p, vec3 b, float r) {
  vec3 q = abs(p) - b + r;
  return length(max(q, 0.0)) + min(max(q.x, max(q.y, q.z)), 0.0) - r;
}

// Beam along the (1, 1) diagonal in the xy plane.
float beamUp(vec3 p, vec2 c, float halfLen) {
  vec2 d = p.xy - c;
  vec2 q = vec2((d.x + d.y) * S2, (d.y - d.x) * S2);
  return sdRoundBox(vec3(q, p.z), vec3(halfLen, 0.13, 0.13), 0.05);
}

// Beam along the (1, -1) diagonal.
float beamDown(vec3 p, vec2 c, float halfLen) {
  vec2 d = p.xy - c;
  vec2 q = vec2((d.x - d.y) * S2, (d.x + d.y) * S2);
  return sdRoundBox(vec3(q, p.z), vec3(halfLen, 0.13, 0.13), 0.05);
}

mat2 rot(float a) {
  float c = cos(a), s = sin(a);
  return mat2(c, -s, s, c);
}

// Returns (distance, material id).
// ids: 1 floor, 2 light beam, 3 dark beam, 4/5/6 orbs
vec2 map(vec3 p) {
  vec2 res = vec2(p.y, 1.0);

  // The logo floats and slowly turns.
  vec3 q = p - vec3(0.0, 1.35 + 0.08 * sin(uTime * 1.3), 0.0);
  q.xz = rot(0.35 * sin(uTime * 0.4)) * q.xz;
  float e = uExplode;

  float top = beamUp(q - vec3(0.0, 0.0, -0.55 * e), vec2(-0.03, 0.62), 0.86);
  float mid = beamUp(q - vec3(0.0, 0.0, 0.0), vec2(0.25, -0.22), 0.44);
  float bot = beamDown(q - vec3(0.0, 0.0, 0.55 * e), vec2(0.19, -0.80), 0.36);

  float light = min(top, mid);
  if (light < res.x) res = vec2(light, 2.0);
  if (bot < res.x) res = vec2(bot, 3.0);

  // Three orbs on a tilted orbit.
  for (int i = 0; i < 3; i++) {
    float fi = float(i);
    float a = uTime * 0.6 + fi * 2.094;
    vec3 c = vec3(cos(a) * 1.75, 1.15 + 0.35 * sin(a * 2.0 + fi), sin(a) * 1.75);
    float d = length(p - c) - (0.26 + 0.12 * e);
    if (d < res.x) res = vec2(d, 4.0 + fi);
  }
  return res;
}

vec3 normalAt(vec3 p) {
  const vec2 k = vec2(1.0, -1.0);
  const float h = 0.0015;
  return normalize(k.xyy * map(p + k.xyy * h).x +
                   k.yyx * map(p + k.yyx * h).x +
                   k.yxy * map(p + k.yxy * h).x +
                   k.xxx * map(p + k.xxx * h).x);
}

vec2 march(vec3 ro, vec3 rd) {
  float t = 0.0;
  float id = -1.0;
  for (int i = 0; i < 90; i++) {
    vec2 h = map(ro + rd * t);
    if (h.x < 0.001) { id = h.y; break; }
    t += h.x;
    if (t > 30.0) break;
  }
  return vec2(t, id);
}

vec2 marchShort(vec3 ro, vec3 rd) {
  float t = 0.0;
  float id = -1.0;
  for (int i = 0; i < 40; i++) {
    vec2 h = map(ro + rd * t);
    if (h.x < 0.002) { id = h.y; break; }
    t += h.x;
    if (t > 20.0) break;
  }
  return vec2(t, id);
}

float softShadow(vec3 ro, vec3 rd) {
  float res = 1.0;
  float t = 0.02;
  for (int i = 0; i < 28; i++) {
    float h = map(ro + rd * t).x;
    res = min(res, 10.0 * h / t);
    t += clamp(h, 0.02, 0.4);
    if (res < 0.001 || t > 8.0) break;
  }
  return clamp(res, 0.0, 1.0);
}

vec3 sky(vec3 rd) {
  float g = clamp(rd.y * 0.5 + 0.5, 0.0, 1.0);
  vec3 col = mix(CANVAS * 1.2, CANVAS + PURPLE * 0.10, g);
  col += PINK * 0.10 * pow(max(0.0, dot(rd, normalize(vec3(-0.8, 0.25, -0.5)))), 6.0);
  col += BLUE * 0.12 * pow(max(0.0, dot(rd, normalize(vec3(0.9, 0.3, 0.4)))), 6.0);
  return col;
}

vec3 albedo(float id, vec3 p) {
  if (id < 1.5) {
    // Floor: faint grid.
    vec2 g = abs(fract(p.xz * 1.0) - 0.5);
    float line = 1.0 - smoothstep(0.0, 0.03, min(g.x, g.y));
    float fade = exp(-0.05 * dot(p.xz, p.xz));
    return CANVAS * 1.6 + CYAN * 0.25 * line * fade;
  }
  if (id < 2.5) return DART;
  if (id < 3.5) return NAVY * 1.3;
  if (id < 4.5) return PINK;
  if (id < 5.5) return PURPLE;
  return ORANGE;
}

vec3 shade(vec3 p, vec3 rd, float id, out float refl) {
  vec3 n = normalAt(p);
  vec3 lig = normalize(vec3(0.6, 0.9, -0.5));
  vec3 base = albedo(id, p);

  float dif = max(dot(n, lig), 0.0) * softShadow(p + n * 0.01, lig);
  float amb = 0.35 + 0.25 * n.y;
  vec3 h = normalize(lig - rd);
  float spe = pow(max(dot(n, h), 0.0), id < 1.5 ? 32.0 : 64.0);
  float fre = pow(1.0 - max(dot(n, -rd), 0.0), 3.0);

  vec3 col = base * (amb * 0.45 + dif * 0.9);
  col += vec3(1.0) * spe * dif * (id < 1.5 ? 0.25 : 1.2);
  col += sky(reflect(rd, n)) * fre * 0.6;

  refl = id < 1.5 ? 0.35 : 0.18 + 0.5 * fre;
  return col;
}

void main() {
  vec2 frag = FlutterFragCoord().xy;
  vec2 uv = (frag - 0.5 * uSize) / uSize.y;
  uv.y = -uv.y;

  // Orbit camera.
  float pitch = clamp(uPitch, -0.15, 1.2);
  vec3 target = vec3(0.0, 1.1, 0.0);
  float dist = 5.4;
  vec3 ro = target + dist * vec3(sin(uYaw) * cos(pitch), sin(pitch), -cos(uYaw) * cos(pitch));
  vec3 fw = normalize(target - ro);
  vec3 rt = normalize(cross(vec3(0.0, 1.0, 0.0), fw));
  vec3 up = cross(fw, rt);
  vec3 rd = normalize(fw * 1.6 + rt * uv.x + up * uv.y);

  vec3 col;
  vec2 hit = march(ro, rd);
  if (hit.y < 0.0) {
    col = sky(rd);
  } else {
    vec3 p = ro + rd * hit.x;
    float refl;
    col = shade(p, rd, hit.y, refl);

    // One reflection bounce.
    vec3 n = normalAt(p);
    vec3 rd2 = reflect(rd, n);
    vec2 hit2 = marchShort(p + n * 0.01, rd2);
    vec3 rc;
    if (hit2.y < 0.0) {
      rc = sky(rd2);
    } else {
      float r2;
      rc = shade(p + n * 0.01 + rd2 * hit2.x, rd2, hit2.y, r2);
    }
    col = mix(col, rc, refl);

    // Fog into the canvas.
    col = mix(col, CANVAS, 1.0 - exp(-0.004 * hit.x * hit.x));
  }

  // Vignette + gamma.
  vec2 q = frag / uSize;
  col *= 0.55 + 0.45 * pow(16.0 * q.x * q.y * (1.0 - q.x) * (1.0 - q.y), 0.2);
  col = pow(max(col, 0.0), vec3(0.4545));
  fragColor = vec4(col, 1.0);
}
