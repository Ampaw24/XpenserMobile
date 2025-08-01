import 'package:expenser/core/constants/imageconstants.dart';
import 'package:expenser/view/auth/login/loginscreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class SplashcreenPage extends StatefulWidget {
  const SplashcreenPage({super.key});

  @override
  State<SplashcreenPage> createState() => _SplashcreenPageState();
}

class _SplashcreenPageState extends State<SplashcreenPage> {
  @override
  void initState() {
    Future.delayed(
      Duration(seconds: 5),
      () {
        if (!mounted) return;
        Navigator.push(
          context,
          CupertinoPageRoute(builder: (context) => const Loginscreen()),
        );
      },
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: size.width,
        height: size.height,

        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: size.height * 0.2,
              width: size.width * 0.5,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage(Imageconstants.applogo),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Container(
            //   decoration: BoxDecoration(
            //     image: DecorationImage(image: AssetImage())
            //   ),
            // )
          ],
        ),
      ),
    );
  }
}
