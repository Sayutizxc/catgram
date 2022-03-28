import 'dart:io';
import 'dart:math';

import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/cat_api_model.dart';
import '../provider/general_provider.dart';

final catRepositoryProvider = Provider<CatRepository>((ref) {
  return CatRepository(client: ref.read(dioClientProvider));
});

class CatRepository {
  const CatRepository({required this.client});
  final Dio client;

  Future<List<List<CatModel>>> getCat({
    required int page,
    required int limit,
  }) async {
    try {
      final _response = await client.get(
        'v1/images/search?limit=$limit&page=$page&order=Rand',
      );
      List _cats = _response.data;
      return compute(_parseCats, _cats);
    } on DioError catch (e) {
      if (e.response != null) {
        _parseDioError(e.response!);
      }
      if (e.error is SocketException) {
        throw Exception("No Internet Connection.");
      }
      throw Exception("Unexpected Error.");
    }
  }
}

void _parseDioError(Response<dynamic>? response) async {
  switch (response?.statusCode) {
    case 304:
      {
        if (response?.data != null) {
          List _cats = response?.data;
          return compute(_parseCats, _cats);
        }
        throw Exception("Not Receiving Data.");
      }
    case 404:
      throw Exception("Not Found.");
    case 400:
      throw Exception("Bad Request.");
    case 500:
      throw Exception("Internal Server Error.");
    default:
      throw Exception(response?.statusMessage ?? "Unknown Error.");
  }
}

List<List<CatModel>> _parseCats(List<dynamic> cats) {
  List<List<dynamic>> result = [];
  while (cats.isNotEmpty) {
    int randomNumber = Random().nextInt(6) + 1;
    List<dynamic> randomCats = cats.take(randomNumber).toList();
    result.add(randomCats);
    if (randomNumber > cats.length) {
      randomNumber = cats.length;
    }
    cats.removeRange(0, randomNumber);
  }
  return result
      .map<List<CatModel>>((cats) =>
          cats.map<CatModel>((json) => CatModel.fromJson(json)).toList())
      .toList();
}
