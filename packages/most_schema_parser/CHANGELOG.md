## 1.0.0
- BREAKING CHANGE: `MostJsonSchemaParser` is not applying default mappers by default. 
```dart
// BEFORE
MostJsonSchemaParser(
  customMappers: [
    MyMapper(),
  ],
);

// AFTER
MostJsonSchemaParser(
  customMappers: [
    MyMapper(),
    ...MostJsonSchemaParser.defaultMappers,
  ],
);
// OR
MostJsonSchemaParser(
  customMappers: [
    MyMapper(),
    EnumPropertyMapper(),
    BooleanPropertyMapper(),
    StringPropertyMapper(),
    NumberPropertyMapper(),
    ArrayPropertyMapper(),
    ObjectPropertyMapper(),,
  ],
);
```
- BREAKING CHANGE: `MostProperty` is now sealed. Consider implementing `MostValueProperty` or `MostObjectProperty`.
- BREAKING CHANGE: Validator-related classes are removed from the package.

## 0.0.3
- Fix `MostJsonSchemaValidator` not validating.

## 0.0.2
- Add `MostValidator` concept.

## 0.0.1

- Initial release.
- Added `MostJsonSchema`
- Added `MostProperty`
  - Added `MostObjectProperty`
  - Added `MostValueProperty`
    - Added `BooleanMostProperty`
    - Added `StringMostProperty`
    - Added `EnumMostProperty`
    - Added `NumberMostProperty`
    - Added `ArrayMostProperty`
- Added `MostJsonSchemaParser`
- Added `PropertyMapper`
  - Added `CustomPropertyMapper` 
  - Added `ObjectPropertyMapper`
  - Added `BooleanPropertyMapper`
  - Added `StringPropertyMapper`
  - Added `EnumPropertyMapper`
  - Added `NumberPropertyMapper`
  - Added `ArrayPropertyMapper`
