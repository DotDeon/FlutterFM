import 'package:ai_radio/model/radio.dart';
import 'package:ai_radio/utils/ai_util.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
// import 'package:alan_voice/alan_voice.dart';
import 'package:velocity_x/velocity_x.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late List<MyRadio> radios;
  late MyRadio _selectedRadio;
  late Color _selectedColor = AIColors.primaryColor1;
  bool _isPlaying = false;

  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    fetchRadios();

    _audioPlayer.onPlayerStateChanged.listen((PlayerState s) => {
          if (s == PlayerState.PLAYING)
            {
              _isPlaying = true,
            }
          else
            {
              _isPlaying = false,
            },
          setState(() {})
        });
  }

  fetchRadios() async {
    final radioJson = await rootBundle.loadString("assets/radio.json");
    radios = MyRadioList.fromJson(radioJson).radios;
    print(radios);
    setState(() {});
  }

  _playMusic(String url) {
    _audioPlayer.play(url);
    _selectedRadio = radios.firstWhere((element) => element.url == url);
    print(_selectedRadio.name);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        drawer: Drawer(),
        body: Stack(
          children: [
            VxAnimatedBox()
                .size(context.screenWidth, context.screenHeight)
                .withGradient(LinearGradient(
                    colors: [Color(0xffE4E3E0), Color(0xffE2E2E2)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight))
                .make(),
            AppBar(
              title: "AfrknsFm".text.xl2.bold.white.make().shimmer(
                  primaryColor: Vx.yellow600, secondaryColor: Vx.green800),
              backgroundColor: Colors.transparent,
              elevation: 0.0,
              centerTitle: true,
            ).h(100.0).p16(),
            radios != null
                ? VxSwiper.builder(
                    itemCount: radios.length,
                    aspectRatio: 1.0,
                    enlargeCenterPage: true,
                    onPageChanged: (index) {
                      // final colorHex = int.tryParse(radios[index].color);
                      _selectedColor = AIColors.primaryColor3;
                      setState(() {});
                    },
                    itemBuilder: (context, index) {
                      final rad = radios[index];
                      return VxBox(
                              child: ZStack(
                        [
                          Positioned(
                              top: 0.0,
                              right: 0.0,
                              child: VxBox(
                                child: rad.category.text.uppercase.white
                                    .make()
                                    .p16(),
                              )
                                  .height(45)
                                  .black
                                  .alignCenter
                                  .withRounded(value: 10.0)
                                  .make()),
                          Align(
                              alignment: Alignment.bottomCenter,
                              child: VStack(
                                [
                                  rad.name.text.xl3.white.bold.make(),
                                  5.heightBox,
                                  rad.tagline.text.sm.white.semiBold.make()
                                ],
                                crossAlignment: CrossAxisAlignment.center,
                              )),
                          Align(
                              alignment: Alignment.center,
                              child: [
                                Icon(CupertinoIcons.play_circle,
                                    color: Colors.white),
                                10.heightBox,
                                "Double tap to play".text.gray300.make()
                              ].vStack())
                        ],
                      ))
                          .clip(Clip.antiAlias)
                          .bgImage(
                            DecorationImage(
                                image: NetworkImage(rad.image),
                                fit: BoxFit.cover,
                                colorFilter: ColorFilter.mode(
                                    Colors.black.withOpacity(0.3),
                                    BlendMode.darken)),
                          )
                          .border(color: Colors.black, width: 0.5)
                          .withRounded(value: 60.0)
                          .make()
                          .onInkDoubleTap(() {
                        _playMusic(rad.url);
                      }).p16();
                    }).centered()
                : Center(
                    child: CircularProgressIndicator(
                    backgroundColor: Colors.white,
                  )),
            Align(
                    alignment: Alignment.bottomCenter,
                    child: [
                      if (_isPlaying)
                        "Playing Now - ${_selectedRadio.name}"
                            .text
                            .white
                            .makeCentered(),
                      Icon(
                              _isPlaying
                                  ? CupertinoIcons.stop_circle
                                  : CupertinoIcons.play_circle,
                              color: Colors.white,
                              size: 50.0)
                          .shimmer(
                              primaryColor: Vx.yellow600,
                              secondaryColor: Vx.green800)
                          .onInkTap(() {
                        if (_isPlaying) {
                          _audioPlayer.stop();
                        } else {
                          _playMusic(_selectedRadio.url);
                        }
                      })
                    ].vStack())
                .pOnly(bottom: context.percentHeight * 12)
          ],
          fit: StackFit.expand,
        ));
  }
}
