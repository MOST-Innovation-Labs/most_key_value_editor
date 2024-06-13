<h1> most_schema_parser </h1>

<p align="center">
  <a href="https://pub.dev/packages/most_schema_parser">
    <img src="https://img.shields.io/pub/v/most_schema_parser.svg?label=pub&color=orange" alt="pub version">
  </a>
</p>

Highly customizable JSON Schema object model mapper.

- [Usage](#usage)
- [Implementation](#implementation)

## Usage
- Create `JsonSchema` object;
- Convert `JsonSchema` into `MostJsonSchema`;
- Use it!


For more information on the usage, please, check `example/`.

## Implementation

`MostJsonSchemaParser` is designed to convert JSON Schema into `MostJsonSchema`. It has a `customMappers` parameter which is allowing to customize property-to-most-object mapping.

`MostJsonSchema` contains the original `JsonSchema` object for the reference and a list of most properties `MostProperty`.

`MostProperty` have the following implementations:
- `MostObjectProperty`
- `MostValueProperty`, which is inherited in:
  - `BooleanMostProperty`
  - `StringMostProperty`
  - `EnumMostProperty`
  - `NumberMostProperty`
  - `ArrayMostProperty`

`MostProperty` is open for extension if special property needs to be implemented.
