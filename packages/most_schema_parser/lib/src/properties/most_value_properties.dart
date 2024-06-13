import 'most_property.dart';

/// [MostValueProperty] for boolean type.
class BooleanMostProperty extends MostValueProperty {
  /// Creates [BooleanMostProperty].
  BooleanMostProperty({
    required super.title,
    required super.description,
    required super.propertyName,
    required super.required,
    required super.parent,
  });

  @override
  String toString() => '${super.toString()} (bool)';
}

/// [MostValueProperty] for string type.
class StringMostProperty extends MostValueProperty {
  /// Optional Regular Expression.
  final RegExp? pattern;

  /// Creates [StringMostProperty].
  StringMostProperty({
    required super.title,
    required super.description,
    required super.propertyName,
    required super.required,
    required super.parent,
    required this.pattern,
  });

  @override
  String toString() => '${super.toString()} '
      '(text'
      '${pattern != null ? " pattern:'$pattern'" : ''}'
      ')';
}

/// [MostValueProperty] for string enum type.
class EnumMostProperty extends MostValueProperty {
  /// Available enum options.
  final List<String> values;

  /// Creates [EnumMostProperty].
  EnumMostProperty({
    required super.title,
    required super.description,
    required super.propertyName,
    required super.required,
    required super.parent,
    required this.values,
  });

  @override
  String toString() => '${super.toString()} (enum)';
}

/// [MostValueProperty] for number type.
class NumberMostProperty extends MostValueProperty {
  /// Minimum allowed value of the number.
  final num? minimum;

  /// Creates [NumberMostProperty].
  NumberMostProperty({
    required super.title,
    required super.description,
    required super.propertyName,
    required super.required,
    required super.parent,
    required this.minimum,
  });

  @override
  String toString() => '${super.toString()} '
      '(number'
      '${minimum != null ? " min:$minimum" : ''}'
      ')';
}

/// [MostValueProperty] for array type.
class ArrayMostProperty extends MostValueProperty {
  /// [MostValueProperty] for the underlying item type.
  final MostValueProperty itemProperty;

  /// Creates [ArrayMostProperty].
  ArrayMostProperty({
    required super.title,
    required super.description,
    required super.propertyName,
    required super.required,
    required super.parent,
    required this.itemProperty,
  });

  @override
  String toString() => '${super.toString()} (array)';
}
