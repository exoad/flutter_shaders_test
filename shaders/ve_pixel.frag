#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform vec2 uDownsample;
uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    fragColor=texture(uTexture,round((FlutterFragCoord().xy/uSize)*uDownsample)/uDownsample);
}