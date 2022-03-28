import 'package:dio/dio.dart';
import 'package:faker/faker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

/// Memformat pernulisan nomer
///
/// Menambahkan tanda koma agar lebih mudah dibaca
/// Contoh penulisan angka dari 10000 menjadi 10,000.
final numberFormatterProvider = Provider<NumberFormat>((ref) {
  return NumberFormat('#,##,000');
});

/// Mengembalikan instance dari faker
///
/// Digunakan untuk membantu membuat data dummy.
final fakerProvider = Provider<Faker>((ref) {
  return Faker();
});

/// Mengembalikan instance dari dio
///
/// Digunakan sebagai dio client untuk melakukan http request.
final dioClientProvider = Provider<Dio>((ref) {
  final _option = BaseOptions(
    baseUrl: 'https://api.thecatapi.com/',
    contentType: 'application/json',
    connectTimeout: 5000,
    receiveTimeout: 5000,
  );
  final _dio = Dio(_option);
  return _dio;
});

final scaffoldKeyProvider = Provider<GlobalKey<ScaffoldMessengerState>>((ref) {
  return GlobalKey<ScaffoldMessengerState>();
});
