#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    vec2 uv=FlutterFragCoord().xy/uSize.xy;
    vec3 rr=texture(uTexture,uv).rgb;
    rr=vec3(1.0)-rr;
    fragColor=vec4(rr,1.0);
}