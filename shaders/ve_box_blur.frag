#version 460 core

precision highp float;

#include <flutter/runtime_effect.glsl>

#define kernel 10.0
#define weight 1.0

uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
    vec2 uv=FlutterFragCoord().xy/uSize.xy;
    vec3 sum=vec3(0);
    float pixel=1.0/uSize.x;
    vec3 a=vec3(0);
    vec3 w_sum=vec3(0);
    for(float i=float(-kernel);i<=kernel;i++)
    {
        a+=texture(uTexture,uv+vec2(i*pixel,0)).xyz*weight;
        w_sum+=weight;
    }
    sum=a/w_sum;
    fragColor=vec4(sum,1.0);
}