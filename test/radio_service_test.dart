import 'package:flutter_test/flutter_test.dart';
import 'package:musicpod/data.dart';
import 'package:musicpod/radio.dart';

const Audio sixFortyStation = Audio(
  url: 'http://radio.6forty.com:8000/6forty',
);

Future<void> main() async {
  final service = RadioService();
  final host = await service.init();

  test('initRadioService', () async {
    expect(host != null, true);
  });

  test('loadTags', () async {
    final response = await service.loadTags();
    expect(response?.statusCode, 200);
    expect(response?.items.any((e) => e.name == 'metal'), true);
  });

  test('find6forty', () async {
    final result = await service.getStations(name: '6forty');
    expect(result?.isNotEmpty, true);
    expect(result?.any((e) => e.name.contains('6forty')), true);
    expect(result?.any((e) => e.url == sixFortyStation.url), true);
  });

  test('findByName', () async {
    final result = await service.getStations(name: 'WDR');
    expect(result?.isNotEmpty, true);
    expect(result?.any((e) => e.name.toLowerCase().contains('wdr')), true);
  });

  test('findByCountry', () async {
    final result = await service.getStations(country: 'Germany');
    expect(result?.isNotEmpty, true);
  });

  test('findByTag', () async {
    final result = await service.getStations(tag: 'metal');
    expect(result?.isNotEmpty, true);
  });

  test('findByState', () async {
    final result = await service.getStations(
      state: 'nordrhein',
    );
    expect(result?.isNotEmpty, true);
  });
}
