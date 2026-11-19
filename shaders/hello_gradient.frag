#version 460 core
#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;   // Flutter から: 描画サイズ
uniform float uTime;  // Flutter から: 経過秒
uniform vec2 uMouse;  // Flutter から: ポインター位置

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize;
  vec3 color = 0.5 + 0.5 * cos(uTime + uv.xyx * 3.0 + vec3(0, 2, 4));

  float d = distance(FlutterFragCoord().xy, uMouse);
  color += smoothstep(120.0, 0.0, d) * 0.6;

  fragColor = vec4(color, 1.0);
}
