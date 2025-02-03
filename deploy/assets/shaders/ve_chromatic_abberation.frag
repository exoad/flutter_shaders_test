{
  "sksl": {
    "entrypoint": "ve_chromatic_abberation_fragment_main",
    "shader": "// This SkSL shader is autogenerated by spirv-cross.\n\nfloat4 flutter_FragCoord;\n\nuniform float amount;\nuniform vec2 uSize;\nuniform shader uTexture;\nuniform half2 uTexture_size;\n\nvec4 fragColor;\n\nvec2 FLT_flutter_local_FlutterFragCoord()\n{\n    return flutter_FragCoord.xy;\n}\n\nvec2 FLT_flutter_local_PincushionDistortion(vec2 uv, float strength)\n{\n    vec2 st = uv - vec2(0.5);\n    float uvA = atan(st.x, st.y);\n    float uvD = dot(st, st);\n    return vec2(0.5) + ((vec2(sin(uvA), cos(uvA)) * sqrt(uvD)) * (1.0 - (strength * uvD)));\n}\n\nvec3 FLT_flutter_local_ChromaticAbberation(vec2 uv)\n{\n    vec2 param = uv;\n    float param_1 = 0.300000011920928955078125 * amount;\n    float rChannel = uTexture.eval(uTexture_size * ( FLT_flutter_local_PincushionDistortion(param, param_1))).x;\n    vec2 param_2 = uv;\n    float param_3 = 0.1500000059604644775390625 * amount;\n    float gChannel = uTexture.eval(uTexture_size * ( FLT_flutter_local_PincushionDistortion(param_2, param_3))).y;\n    vec2 param_4 = uv;\n    float param_5 = 0.07500000298023223876953125 * amount;\n    float bChannel = uTexture.eval(uTexture_size * ( FLT_flutter_local_PincushionDistortion(param_4, param_5))).z;\n    vec3 retColor = vec3(rChannel, gChannel, bChannel);\n    return retColor;\n}\n\nvoid FLT_main()\n{\n    vec2 uv_1 = FLT_flutter_local_FlutterFragCoord() / uSize;\n    vec2 param_6 = uv_1;\n    fragColor = vec4(FLT_flutter_local_ChromaticAbberation(param_6), 1.0);\n}\n\nhalf4 main(float2 iFragCoord)\n{\n      flutter_FragCoord = float4(iFragCoord, 0, 0);\n      FLT_main();\n      return fragColor;\n}\n",
    "stage": 1,
    "uniforms": [
      {
        "array_elements": 0,
        "bit_width": 32,
        "columns": 1,
        "location": 0,
        "name": "amount",
        "rows": 1,
        "type": 10
      },
      {
        "array_elements": 0,
        "bit_width": 32,
        "columns": 1,
        "location": 1,
        "name": "uSize",
        "rows": 2,
        "type": 10
      },
      {
        "array_elements": 0,
        "bit_width": 0,
        "columns": 1,
        "location": 2,
        "name": "uTexture",
        "rows": 1,
        "type": 12
      }
    ]
  }
}