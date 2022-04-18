import 'package:catgram/provider/home_provider.dart';
import 'package:catgram/ui/pages/home/widgets/post.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'widgets/app_bar.dart';
import 'widgets/story.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  late ScrollController _scrollController;
  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(
      () {
        if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent) {
          ref.read(homePageDataProvider.notifier).loadMorePost();
        }
      },
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(
            parent: AlwaysScrollableScrollPhysics()),
        controller: _scrollController,
        slivers: [
          const CatgramAppbar(),
          CupertinoSliverRefreshControl(
            onRefresh: () async => ref.refresh(homePageDataProvider),
          ),
          const CatgramStory(),
          const CatgramPost(),
        ],
      ),
    );
  }
}
