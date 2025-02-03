import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/flutter_highlight.dart';
import 'package:flutter_highlight/themes/gruvbox-dark.dart';
import 'package:google_fonts/google_fonts.dart';

late Image image;
late ui.Image imageBacker;

double PIXELIZATION_SCALE = 5;
double CHROMATIC_ABBERATION_AMOUNT = 1.5;
double EMBOSS_W = 0.0015;
double EMBOSS_H = 0.0015;
int _selected = 1;
int selected_max = 11;
int selected_min = 1;
final Map<String, TextStyle> codeStyle = gruvboxDarkTheme
    .map((String a, TextStyle b) => MapEntry<String, TextStyle>(a, b))
  ..["root"] = TextStyle(backgroundColor: Colors.black, color: Color(0xffebdbb2));
int selected_shader = 0;

const double MAX_W = 560;

Future<void> selected(int r) async {
  _selected = r;
  await loadImage("assets/image$r.jpg");
}

int getSelected() => _selected;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  loadImage("assets/image${getSelected()}.jpg").then((_) {
    runApp(const MyApp());
  });
}

Future<void> loadImage(String asset) async {
  image = Image.asset(asset, fit: BoxFit.fill);
  await decodeImageFromList((await rootBundle.load(asset)).buffer.asUint8List())
      .then((ui.Image r) {
    imageBacker = r;
  });
}

class Btn extends StatelessWidget {
  final void Function() onPressed;
  final String label;

  const Btn(this.label, this.onPressed);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
        onTap: onPressed,
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: Colors.amber),
              borderRadius: BorderRadius.circular(0)),
          padding: EdgeInsets.all(6),
          child: Text(label,
              style: GoogleFonts.playfairDisplay(
                  textStyle: TextStyle(fontSize: 16, color: Colors.white))),
        ));
  }
}

class ChromaticAbberationFragPainter extends CustomPainter {
  final ui.FragmentShader shader;

  ChromaticAbberationFragPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    shader.setImageSampler(0, imageBacker);
    shader.setFloat(0, CHROMATIC_ABBERATION_AMOUNT);
    shader.setFloat(1, size.width);
    shader.setFloat(2, size.height);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class PixelFragPainter extends CustomPainter {
  final ui.FragmentShader shader;

  PixelFragPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    shader.setImageSampler(0, imageBacker);
    shader.setFloat(0, size.width / PIXELIZATION_SCALE);
    shader.setFloat(1, size.height / PIXELIZATION_SCALE);
    shader.setFloat(2, size.width);
    shader.setFloat(3, size.height);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class InvertFragPainter extends CustomPainter {
  final ui.FragmentShader shader;

  InvertFragPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    shader.setImageSampler(0, imageBacker);
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class BoxBlurFragPainter extends CustomPainter {
  final ui.FragmentShader shader;

  BoxBlurFragPainter(this.shader);

  @override
  void paint(Canvas canvas, Size size) {
    shader.setImageSampler(0, imageBacker);
    shader.setFloat(0, size.width);
    shader.setFloat(1, size.height);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ColoredBoxPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = Colors.amber
          ..style = PaintingStyle.fill
          ..filterQuality = FilterQuality.high);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return true;
  }
}

class ItemWrapper extends StatelessWidget {
  final String code;
  final List<Widget> children;

  const ItemWrapper(this.code, this.children);

  @override
  Widget build(BuildContext context) {
    return Container(
        decoration: BoxDecoration(
            border: Border.all(color: Colors.white),
            borderRadius: BorderRadius.circular(0)),
        padding: EdgeInsets.all(8),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          spacing: 6,
          children: children
            ..add(Btn("View Src", () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return Dialog(
                      child: SingleChildScrollView(
                        child: Padding(
                          padding: EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            spacing: 6,
                            children: <Widget>[
                              HighlightView(
                                code,
                                language: "glsl",
                                padding: EdgeInsets.all(20),
                                theme: codeStyle,
                                textStyle: GoogleFonts.firaCode(),
                              ),
                              Btn("Copy", () {
                                Clipboard.setData(ClipboardData(text: code));
                              })
                            ],
                          ),
                        ),
                      ),
                    );
                  });
            })),
        ));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final Map<String, ui.FragmentShader?> shaders = <String, ui.FragmentShader?>{};

  void load(String name) async {
    shaders[name] = (await ui.FragmentProgram.fromAsset(name)).fragmentShader();
    if (mounted) {
      setState(() {});
    }
  }

  @override
  void initState() {
    super.initState();
    load("shaders/ve_pixel.frag");
    load("shaders/ve_box_blur.frag");
    load("shaders/ve_invert.frag");
    load("shaders/ve_chromatic_abberation.frag");
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
            scaffoldBackgroundColor: Colors.black,
            dialogBackgroundColor: Colors.black,
            dialogTheme: DialogTheme(
                backgroundColor: Colors.black,
                shape: RoundedRectangleBorder(side: BorderSide(color: Colors.amber))),
            colorScheme: const ColorScheme(
              brightness: Brightness.light,
              primary: Color(0xff443400),
              surfaceTint: Color(0xff735b0c),
              onPrimary: Color(0xffffffff),
              primaryContainer: Color(0xff836a1c),
              onPrimaryContainer: Color(0xffffffff),
              secondary: Color(0xff3f351b),
              onSecondary: Color(0xffffffff),
              secondaryContainer: Color(0xff786c4d),
              onSecondaryContainer: Color(0xffffffff),
              tertiary: Color(0xff1f3c24),
              onTertiary: Color(0xffffffff),
              tertiaryContainer: Color(0xff557558),
              onTertiaryContainer: Color(0xffffffff),
              error: Color(0xff740006),
              onError: Color(0xffffffff),
              errorContainer: Color(0xffcf2c27),
              onErrorContainer: Color(0xffffffff),
              surface: Color(0xfffff8f1),
              onSurface: Color(0xff141109),
              onSurfaceVariant: Color(0xff3b3629),
              outline: Color(0xff585244),
              outlineVariant: Color(0xff736c5d),
              shadow: Color(0xff000000),
              scrim: Color(0xff000000),
              inverseSurface: Color(0xff343027),
              inversePrimary: Color(0xffe3c36c),
              primaryFixed: Color(0xff836a1c),
              onPrimaryFixed: Color(0xffffffff),
              primaryFixedDim: Color(0xff695200),
              onPrimaryFixedVariant: Color(0xffffffff),
              secondaryFixed: Color(0xff786c4d),
              onSecondaryFixed: Color(0xffffffff),
              secondaryFixedDim: Color(0xff5f5437),
              onSecondaryFixedVariant: Color(0xffffffff),
              tertiaryFixed: Color(0xff557558),
              onTertiaryFixed: Color(0xffffffff),
              tertiaryFixedDim: Color(0xff3e5c41),
              onTertiaryFixedVariant: Color(0xffffffff),
              surfaceDim: Color(0xffcdc6b9),
              surfaceBright: Color(0xfffff8f1),
              surfaceContainerLowest: Color(0xffffffff),
              surfaceContainerLow: Color(0xfffbf3e5),
              surfaceContainer: Color(0xfff0e7d9),
              surfaceContainerHigh: Color(0xffe4dcce),
              surfaceContainerHighest: Color(0xffd9d1c3),
            )),
        home: Scaffold(
            body: Center(
                child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            SingleChildScrollView(
              physics:
                  const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  spacing: 6,
                  children: <Widget>[
                    ItemWrapper(
                      "no code",
                      <Widget>[
                        Text("RAW",
                            style: GoogleFonts.playfairDisplay(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600))),
                        RepaintBoundary(
                          child: SizedBox(width: MAX_W, child: image),
                        )
                      ],
                    ),
                    ItemWrapper(
                      """
#version 460 core

precision highp float;

#include < flutter / runtime_effect.glsl >

uniform vec2 uDownsample;
uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  fragColor = texture(uTexture, round((FlutterFragCoord().xy / uSize) * uDownsample) / uDownsample);
}
""",
                      <Widget>[
                        Text("PIXELIZATION ($PIXELIZATION_SCALE)",
                            style: GoogleFonts.playfairDisplay(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600))),
                        RepaintBoundary(
                          child: SizedBox(
                            width: MAX_W,
                            height: (MAX_W * imageBacker.height) / imageBacker.width,
                            child: CustomPaint(
                                painter: shaders.containsKey("shaders/ve_pixel.frag")
                                    ? PixelFragPainter(shaders["shaders/ve_pixel.frag"]!)
                                    : ColoredBoxPainter()),
                          ),
                        ),
                        Row(
                          spacing: 6,
                          children: <Widget>[
                            Btn("Sample Up", () => setState(() => PIXELIZATION_SCALE++)),
                            Btn(
                                "Sample Down",
                                () => setState(() => PIXELIZATION_SCALE =
                                    PIXELIZATION_SCALE - 1 <= 1
                                        ? 1
                                        : PIXELIZATION_SCALE - 1)),
                            Btn("Sample Reset",
                                () => setState(() => PIXELIZATION_SCALE = 1)),
                          ],
                        ),
                      ],
                    ),
                    ItemWrapper(
                      """
// adapted from: https://www.shadertoy.com/view/wsdBWM
#version 460 core

precision highp float;

#include < flutter / runtime_effect.glsl >

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
  vec2 uv = FlutterFragCoord().xy / uSize.xy;
  fragColor = vec4(ChromaticAbberation(uv), 1.0);
}

""",
                      <Widget>[
                        Text(
                            "CHROMATIC ABBERATION (${CHROMATIC_ABBERATION_AMOUNT.toStringAsFixed(1)})",
                            style: GoogleFonts.playfairDisplay(
                                textStyle: TextStyle(
                                    color: Colors.white,
                                    fontSize: 26,
                                    fontWeight: FontWeight.w600))),
                        RepaintBoundary(
                          child: SizedBox(
                            width: MAX_W,
                            height: (MAX_W * imageBacker.height) / imageBacker.width,
                            child: CustomPaint(
                                painter: shaders.containsKey(
                                        "shaders/ve_chromatic_abberation.frag")
                                    ? ChromaticAbberationFragPainter(
                                        shaders["shaders/ve_chromatic_abberation.frag"]!)
                                    : ColoredBoxPainter()),
                          ),
                        ),
                        Row(
                          spacing: 6,
                          children: <Widget>[
                            Btn("+0.1",
                                () => setState(() => CHROMATIC_ABBERATION_AMOUNT += 0.1)),
                            Btn(
                                "-0.1",
                                () => setState(() => CHROMATIC_ABBERATION_AMOUNT =
                                    CHROMATIC_ABBERATION_AMOUNT - 0.1 < 0
                                        ? 0
                                        : CHROMATIC_ABBERATION_AMOUNT - 0.1)),
                            Btn("0",
                                () => setState(() => CHROMATIC_ABBERATION_AMOUNT = 0)),
                          ],
                        ),
                      ],
                    ),
                    ItemWrapper("""
#version 460 core

precision highp float;

#include < flutter / runtime_effect.glsl >

#define kernel 10.0
#define weight 1.0

uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize.xy;
  vec3 sum = vec3(0);
  float pixel = 1.0 / uSize.x;
  vec3 a = vec3(0);
  vec3 w_sum = vec3(0);
  for (float i = float(-kernel); i <= kernel; i++)
  {
    a += texture(uTexture, uv + vec2(i * pixel, 0)).xyz * weight;
    w_sum += weight;
  }
  sum = a / w_sum;
  fragColor = vec4(sum, 1.0);
}
""", <Widget>[
                      Text("BOX_BLUR (Kernel=10)",
                          style: GoogleFonts.playfairDisplay(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600))),
                      RepaintBoundary(
                        child: SizedBox(
                          width: MAX_W,
                          height: (MAX_W * imageBacker.height) / imageBacker.width,
                          child: CustomPaint(
                              painter: shaders.containsKey("shaders/ve_box_blur.frag")
                                  ? BoxBlurFragPainter(
                                      shaders["shaders/ve_box_blur.frag"]!)
                                  : ColoredBoxPainter()),
                        ),
                      ),
                    ]),
                    ItemWrapper("""
#version 460 core

precision highp float;

#include < flutter / runtime_effect.glsl >

uniform vec2 uSize;
uniform sampler2D uTexture;

out vec4 fragColor;

void main() {
  vec2 uv = FlutterFragCoord().xy / uSize.xy;
  vec3 rr = texture(uTexture, uv).rgb;
  rr = vec3(1.0) - rr;
  fragColor = vec4(rr, 1.0);
}
""", <Widget>[
                      Text("INVERT",
                          style: GoogleFonts.playfairDisplay(
                              textStyle: TextStyle(
                                  color: Colors.white,
                                  fontSize: 26,
                                  fontWeight: FontWeight.w600))),
                      RepaintBoundary(
                        child: SizedBox(
                          width: MAX_W,
                          height: (MAX_W * imageBacker.height) / imageBacker.width,
                          child: CustomPaint(
                              painter: shaders.containsKey("shaders/ve_invert.frag")
                                  ? InvertFragPainter(shaders["shaders/ve_invert.frag"]!)
                                  : ColoredBoxPainter()),
                        ),
                      ),
                    ]),
                  ],
                ),
              ),
            ),
            Row(
              spacing: 6,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                Btn("<", () {
                  selected(getSelected() - 1 < selected_min
                          ? selected_min
                          : getSelected() - 1)
                      .then((_) {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                }),
                Btn(">", () {
                  selected(getSelected() + 1 > selected_max
                          ? selected_max
                          : getSelected() + 1)
                      .then((_) {
                    if (mounted) {
                      setState(() {});
                    }
                  });
                }),
              ],
            ),
          ],
        ))));
  }
}
