import 'package:flutter/material.dart';
import 'package:octo_image/octo_image.dart';

class CatgramNetworkImage extends StatelessWidget {
  const CatgramNetworkImage({
    Key? key,
    required this.url,
    this.withProgressIndicator = false,
  }) : super(key: key);
  final String url;
  final bool withProgressIndicator;

  @override
  Widget build(BuildContext context) {
    return OctoImage(
      fit: BoxFit.cover,
      image: NetworkImage(url),
      progressIndicatorBuilder: withProgressIndicator
          ? (context, progress) {
              double? value;
              if (progress != null && progress.expectedTotalBytes != null) {
                value = progress.cumulativeBytesLoaded /
                    progress.expectedTotalBytes!;
              }
              return Center(
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(
                    value: value,
                    color: Colors.white,
                    strokeWidth: 1,
                  ),
                ),
              );
            }
          : null,
    );
  }
}
