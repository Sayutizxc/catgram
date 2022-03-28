import 'dart:ui';

import 'package:catgram/models/catgram_story_model.dart';
import 'package:catgram/provider/home_provider.dart';
import 'package:catgram/ui/theme/text_style.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:octo_image/octo_image.dart';

import '../../../theme/box_decoration.dart';
import '../../../widgets/catgram_network_image.dart';

class CatgramStory extends ConsumerWidget {
  const CatgramStory({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _catgramStory = ref.watch(homePageDataProvider);
    return _catgramStory.when(
        error: (err, _) => const SliverToBoxAdapter(child: SizedBox()),
        loading: () => const SliverToBoxAdapter(child: SizedBox()),
        data: (_) => const _CatgamStoryData());
  }
}

class _CatgamStoryData extends ConsumerStatefulWidget {
  const _CatgamStoryData({
    Key? key,
  }) : super(key: key);

  @override
  ConsumerState<_CatgamStoryData> createState() => _CatgamStoryDataState();
}

class _CatgamStoryDataState extends ConsumerState<_CatgamStoryData> {
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.position.pixels >=
          _scrollController.position.maxScrollExtent) {
        ref.read(homePageDataProvider.notifier).loadMoreStory();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _catgramStory =
        ref.watch(homePageDataProvider).asData?.value.stories ?? [];
    return SliverToBoxAdapter(
      child: Container(
        height: 100,
        padding: const EdgeInsets.only(bottom: 8),
        child: ListView.builder(
          controller: _scrollController,
          scrollDirection: Axis.horizontal,
          itemCount: _catgramStory.length + 1,
          itemBuilder: (context, index) {
            if (index < _catgramStory.length) {
              final _imageUrl = _catgramStory[index].profileImage;
              final _username = _catgramStory[index].username;

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => StoryPreview(
                        data: _catgramStory[index],
                      ),
                    ),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  child: AspectRatio(
                    aspectRatio: 3 / 4,
                    child: Column(
                      children: [
                        Expanded(
                          child: _StoryBorder(
                            child: _StoryPhotoProfile(_imageUrl),
                          ),
                        ),
                        _CatStoryUsername(_username)
                      ],
                    ),
                  ),
                ),
              );
            } else {
              return const Padding(
                padding: EdgeInsets.only(left: 16, right: 32),
                child: Center(child: CupertinoActivityIndicator()),
              );
            }
          },
        ),
      ),
    );
  }
}

class _CatStoryUsername extends StatelessWidget {
  const _CatStoryUsername(
    this.name, {
    Key? key,
  }) : super(key: key);
  final String name;

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: kCatNameStyle,
    );
  }
}

class _StoryBorder extends StatelessWidget {
  const _StoryBorder({
    Key? key,
    required this.child,
  }) : super(key: key);
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(4),
      padding: const EdgeInsets.all(2),
      decoration: kStoryGradientBorder,
      child: Container(
        padding: const EdgeInsets.all(2),
        decoration: kStoryBlackBorder,
        child: child,
      ),
    );
  }
}

class _StoryPhotoProfile extends StatelessWidget {
  const _StoryPhotoProfile(
    this.url, {
    Key? key,
  }) : super(key: key);
  final String url;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      clipBehavior: Clip.hardEdge,
      padding: const EdgeInsets.all(2),
      decoration: kCircleBackground,
      child: CatgramNetworkImage(
        url: url,
      ),
    );
  }
}

final _pageProvider = StateProvider.autoDispose<int>((ref) {
  return 0;
});

class StoryPreview extends ConsumerStatefulWidget {
  const StoryPreview({required this.data, Key? key}) : super(key: key);
  final CatgramStoryModel data;

  @override
  ConsumerState<StoryPreview> createState() => _StoryPreviewState();
}

class _StoryPreviewState extends ConsumerState<StoryPreview> {
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final _size = MediaQuery.of(context).size;
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: widget.data.stories.length,
            scrollDirection: Axis.horizontal,
            onPageChanged: (page) {
              ref.read(_pageProvider.notifier).update((_) => page);
            },
            itemBuilder: (BuildContext context, int index) {
              final String _imageUrl = widget.data.stories[index].url ?? "";
              return Container(
                width: _size.width,
                height: _size.height,
                color: Colors.black,
                child: Stack(
                  children: [
                    _BackgroundImage(imageUrl: _imageUrl),
                    _StoryImage(imageUrl: _imageUrl),
                  ],
                ),
              );
            },
          ),
          SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (widget.data.stories.length > 1)
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      mainAxisSize: MainAxisSize.max,
                      children: widget.data.stories.asMap().entries.map(
                        (story) {
                          return Expanded(
                            child: Consumer(
                              builder: (
                                BuildContext context,
                                WidgetRef ref,
                                Widget? child,
                              ) {
                                final page = ref.watch(_pageProvider);
                                return Container(
                                  height: 3,
                                  width: 20,
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 4),
                                  color: story.key <= page
                                      ? Colors.white
                                      : Colors.grey,
                                );
                              },
                            ),
                          );
                        },
                      ).toList(),
                    ),
                  ),
                Row(
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      clipBehavior: Clip.antiAlias,
                      margin: const EdgeInsets.fromLTRB(16, 8, 8, 8),
                      decoration: kCircleBackground,
                      child: CatgramNetworkImage(
                        url: widget.data.profileImage,
                      ),
                    ),
                    DefaultTextStyle(
                      style: const TextStyle(),
                      child: Text(widget.data.username),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Consumer(
                builder: (BuildContext context, WidgetRef ref, Widget? child) {
                  final page = ref.watch(_pageProvider);
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      (page > 0)
                          ? IconButton(
                              onPressed: _backToPreviousPage,
                              icon: const Icon(Icons.arrow_back_ios_new),
                            )
                          : const SizedBox(),
                      (page < (widget.data.stories.length - 1))
                          ? IconButton(
                              onPressed: _goToNextPage,
                              icon: const Icon(Icons.arrow_forward_ios),
                            )
                          : const SizedBox(),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _goToNextPage() => _pageController.nextPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutExpo,
      );

  void _backToPreviousPage() => _pageController.previousPage(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutExpo,
      );
}

class _StoryImage extends StatelessWidget {
  const _StoryImage({
    Key? key,
    required String imageUrl,
  })  : _imageUrl = imageUrl,
        super(key: key);

  final String _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: CatgramNetworkImage(
          url: _imageUrl,
          withProgressIndicator: true,
        ),
      ),
    );
  }
}

class _BackgroundImage extends StatelessWidget {
  const _BackgroundImage({
    Key? key,
    required String imageUrl,
  })  : _imageUrl = imageUrl,
        super(key: key);

  final String _imageUrl;

  @override
  Widget build(BuildContext context) {
    return SizedBox.expand(
      child: ImageFiltered(
        imageFilter:
            ImageFilter.blur(sigmaX: 15, sigmaY: 10, tileMode: TileMode.decal),
        child: OctoImage(
          image: NetworkImage(_imageUrl),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
