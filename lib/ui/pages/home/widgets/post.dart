import 'package:catgram/provider/general_provider.dart';
import 'package:catgram/provider/home_provider.dart';
import 'package:catgram/ui/theme/box_decoration.dart';
import 'package:catgram/ui/widgets/catgram_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../models/cat_api_model.dart';

class CatgramPost extends ConsumerWidget {
  const CatgramPost({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _catgramPost = ref.watch(homePageDataProvider);
    final _size = MediaQuery.of(context).size;
    return _catgramPost.when(
      error: (err, _) => SliverToBoxAdapter(
        child: Center(
          child: Text(
            err.toString() + "\nPull to refresh!",
            textAlign: TextAlign.center,
          ),
        ),
      ),
      loading: () => _Loading(size: _size),
      data: (_) => const _CatgramPostData(),
    );
  }
}

class _Loading extends StatelessWidget {
  const _Loading({
    Key? key,
    required Size size,
  })  : _size = size,
        super(key: key);

  final Size _size;

  @override
  Widget build(BuildContext context) {
    return SliverToBoxAdapter(
      child: SizedBox(
        height: _size.height - (2 * kToolbarHeight),
        width: _size.width,
        child: const Center(
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 1,
          ),
        ),
      ),
    );
  }
}

class _CatgramPostData extends ConsumerWidget {
  const _CatgramPostData({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final _catgramPost =
        ref.watch(homePageDataProvider).asData?.value.posts ?? [];
    final _numberFormatter = ref.watch(numberFormatterProvider);
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          if (index < _catgramPost.length) {
            final _cat = _catgramPost[index];
            return LimitedBox(
              child: Column(
                children: [
                  _PostHeader(
                    profileImage: _cat.profileImage,
                    catUsername: _cat.username,
                  ),
                  _PostBody(
                    postImage: _cat.posts,
                    likes: _numberFormatter.format(_cat.likedNumber),
                  ),
                ],
              ),
            );
          } else {
            return const Padding(
              padding: EdgeInsets.symmetric(vertical: 16),
              child: Center(child: CupertinoActivityIndicator()),
            );
          }
        },
        childCount: _catgramPost.length + 1,
      ),
    );
  }
}

class _PostHeader extends ConsumerWidget {
  const _PostHeader({
    Key? key,
    required this.profileImage,
    required this.catUsername,
  }) : super(key: key);

  final String profileImage;
  final String catUsername;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 56,
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 8, 0, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          AspectRatio(
            aspectRatio: 1,
            child: Container(
              clipBehavior: Clip.hardEdge,
              decoration: kCircleBackground,
              child: CatgramNetworkImage(url: profileImage),
            ),
          ),
          const SizedBox(width: 8),
          Text(catUsername),
          const Spacer(),
          PopupMenuButton(
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                child: const Text('Hide post'),
                onTap: () {
                  ref
                      .read(homePageDataProvider.notifier)
                      .removePost(catUsername, profileImage);
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

final lableVisibilityProvider = StateProvider.autoDispose<bool>((ref) {
  return true;
});

class _PostBody extends ConsumerStatefulWidget {
  const _PostBody({
    Key? key,
    required this.postImage,
    required this.likes,
  }) : super(key: key);

  final List<CatModel> postImage;
  final String likes;

  @override
  ConsumerState<_PostBody> createState() => _PostBodyState();
}

class _PostBodyState extends ConsumerState<_PostBody> {
  int page = 0;
  @override
  Widget build(BuildContext context) {
    final widthRatio = (widget.postImage.first.width == 0)
        ? 1
        : (widget.postImage.first.width ?? 1);
    final heigthRatio = (widget.postImage.first.height == 0)
        ? 1
        : (widget.postImage.first.height ?? 1);
    final aspectRatio =
        (widthRatio / heigthRatio) >= 2 ? 4 / 3 : (widthRatio / heigthRatio);
    return Column(
      children: [
        GestureDetector(
          onTap: () => ref
              .read(lableVisibilityProvider.notifier)
              .update((state) => !state),
          child: AspectRatio(
            aspectRatio: widthRatio / heigthRatio,
            child: PageView.builder(
              onPageChanged: ((value) {
                setState(() {
                  page = value;
                });
              }),
              itemCount: widget.postImage.length,
              scrollDirection: Axis.horizontal,
              itemBuilder: (BuildContext context, int index) {
                return AspectRatio(
                  aspectRatio: aspectRatio,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      CatgramNetworkImage(
                        url: widget.postImage[index].url ?? "",
                        withProgressIndicator: true,
                      ),
                      Consumer(
                        builder: (BuildContext context, WidgetRef ref,
                            Widget? child) {
                          final isVisible = ref.watch(lableVisibilityProvider);
                          return (widget.postImage.length > 1 && isVisible)
                              ? Positioned(
                                  top: 8,
                                  right: 8,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 4,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.black45,
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                    child: Text(
                                      "${index + 1}/${widget.postImage.length}",
                                    ),
                                  ),
                                )
                              : const SizedBox();
                        },
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
        _PostFooter(
          likes: widget.likes,
          page: page,
          postImage: widget.postImage,
        ),
      ],
    );
  }
}

class _PostFooter extends StatelessWidget {
  const _PostFooter({
    Key? key,
    required this.likes,
    required this.page,
    required this.postImage,
  }) : super(key: key);

  final String likes;
  final int page;
  final List<CatModel> postImage;

  @override
  Widget build(BuildContext context) {
    return LimitedBox(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Text("$likes likes"),
              ),
              IconButton(
                onPressed: () => _shareImage(context),
                icon: const Icon(Icons.share),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Divider(height: 1, thickness: 1),
        ],
      ),
    );
  }

  Future<void> _shareImage(BuildContext context) async {
    const snackBar = SnackBar(
      content: Text('Please wait...'),
      backgroundColor: Colors.green,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
    final dio = Dio();
    final temp = await getTemporaryDirectory();
    String fileType =
        RegExp(r"(\w+)$").firstMatch(postImage[page].url!)?.group(0) ?? ".jpg";
    final path = '${temp.path}/cat.$fileType';
    await dio.download(postImage[page].url!, path);
    await Share.shareFiles(
      [path],
    );
  }
}
