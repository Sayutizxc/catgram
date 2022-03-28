import 'package:flutter/foundation.dart';

@immutable
class CatModel {
  final String? id;
  final String? url;
  final int? width;
  final int? height;

  const CatModel({
    this.id,
    this.url,
    this.width,
    this.height,
  });

  factory CatModel.fromJson(Map<String, dynamic> json) => CatModel(
        id: json['id'] as String?,
        url: json['url'] as String?,
        width: json['width'] as int?,
        height: json['height'] as int?,
      );

  CatModel copyWith({
    String? id,
    String? url,
    int? width,
    int? height,
  }) {
    return CatModel(
      id: id ?? this.id,
      url: url ?? this.url,
      width: width ?? this.width,
      height: height ?? this.height,
    );
  }
}
