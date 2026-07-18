class Currency {
  final int id;
  final String name;
  final String symbol;
  final String code;
  final double rate;
  final bool isDefault;
  final bool showExchangeRate;

  Currency({
    required this.id,
    required this.name,
    required this.symbol,
    required this.code,
    required this.rate,
    this.isDefault = false,
    this.showExchangeRate = true,
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'] ?? 0,
      name: json['name'] ?? json['code'] ?? '',
      symbol: json['symbol'] ?? json['code'] ?? '',
      code: json['code'] ?? json['name'] ?? '',
      rate: _parseDouble(json['rate']) ?? _parseDouble(json['exchangeRate']) ?? 1.0,
      isDefault: json['isDefault'] ?? json['is_default'] ?? false,
      showExchangeRate: json['showExchangeRate'] ?? json['show_exchange_rate'] ?? true,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    return double.tryParse(value.toString());
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'symbol': symbol,
      'code': code,
      'rate': rate,
      'isDefault': isDefault,
      'showExchangeRate': showExchangeRate,
    };
  }

  Currency copyWith({
    int? id,
    String? name,
    String? symbol,
    String? code,
    double? rate,
    bool? isDefault,
    bool? showExchangeRate,
  }) {
    return Currency(
      id: id ?? this.id,
      name: name ?? this.name,
      symbol: symbol ?? this.symbol,
      code: code ?? this.code,
      rate: rate ?? this.rate,
      isDefault: isDefault ?? this.isDefault,
      showExchangeRate: showExchangeRate ?? this.showExchangeRate,
    );
  }
}
