import 'package:flutter/material.dart';

import '../../../theme/text_style.dart';

class CatgramAppbar extends StatelessWidget {
  const CatgramAppbar({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const SliverAppBar(
      centerTitle: true,
      pinned: true,
      title: Text(
        "Catgram",
        style: kTitleAppBarStyle,
      ),
      bottom: PreferredSize(
        child: Divider(height: 1, thickness: 1),
        preferredSize: Size.fromHeight(1),
      ),
    );
  }
}
