import 'package:flutter/cupertino.dart';

class ShowImage extends StatelessWidget {
  final String path;
  const ShowImage({Key? key, required this.path}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Image.asset(
        path,
        fit: BoxFit.cover,
      ),
    );
  }
}
