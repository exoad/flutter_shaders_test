// adapted from: https://www.shadertoy.com/view/wsdBWM
#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

uniform float amount;
uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

vec2 PincushionDistortion(in vec2 uv, float strength)
{
	vec2 st = uv - 0.5;
    float uvA = atan(st.x, st.y);
    float uvD = dot(st, st);
    return 0.5 + vec2(sin(uvA), cos(uvA)) * sqrt(uvD) * (1.0 - strength * uvD);
}

vec3 ChromaticAbberation(in vec2 uv)
{
	float rChannel = texture(uTexture, PincushionDistortion(uv, 0.3 * amount)).r;
    float gChannel = texture(uTexture, PincushionDistortion(uv, 0.15 * amount)).g;
    float bChannel = texture(uTexture, PincushionDistortion(uv, 0.075 * amount)).b;
    vec3 retColor = vec3(rChannel, gChannel, bChannel);
    return retColor;
}

void main() {
    vec2 uv=FlutterFragCoord().xy/uSize.xy;
    fragColor=vec4(ChromaticAbberation(uv),1.0);
}