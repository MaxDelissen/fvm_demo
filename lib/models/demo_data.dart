import 'dart:math';

class DemoCardData {
  const DemoCardData({
    required this.id,
    required this.label,
    required this.value,
    required this.height,
  });

  final String id;
  final String label;
  final double value;
  final double height;

  Map<String, Object> toArguments() => <String, Object>{
        'id': id,
        'label': label,
        'value': value,
        'valueText': 'Value: ${value.toStringAsFixed(2)}',
        'height': height,
      };
}

class DemoDataRepository {
  const DemoDataRepository();

  List<DemoCardData> fetchCards({int count = 8}) {
    final Random random = Random(count);
    final List<DemoCardData> cards =
        List<DemoCardData>.generate(count, (int index) {
      final double rawValue = random.nextDouble() * 1000;
      return DemoCardData(
        id: 'card_$index',
        label: 'Data Point ${index + 1}',
        value: double.parse(rawValue.toStringAsFixed(2)),
        height: random.nextDouble() * 200.0,
      );
    });
    return cards;
  }
}
