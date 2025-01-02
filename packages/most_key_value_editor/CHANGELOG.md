## 1.0.0
- BREAKING CHANGE: `JsonReaderWriter` renamed to `JsonAccessor`.
- BREAKING CHANGE: `JsonPropertyReaderWriter` renamed to `JsonPropertyAccessor`.
- BREAKING CHANGE: `JsonAccessor` is not holding command history (i.e. undo feature is temporary removed).
- BREAKING CHANGE: `MostKeyValueEditor#customBuilders` replaced with 3 dedicated parameters.
- BREAKING CHANGE: `MostKeyValueEditorController` is not supporting validation using FormKey.
- BREAKING CHANGE: `MostKeyValueEditorController` validates JSON when it is changed.
- BREAKING CHANGE: `StringFormField` renamed to `StringField` and saves value only on user interaction (i.e. tap).
- BREAKING CHANGE: `MostValidator` renamed to `EditorStateValidator`.

## 0.0.2
- Add `MostValidator` concept:
  - Allows to add custom validators to the key-value editor.
  - Validation works as before with 0 changes.
  - For the usage please refer to `example/`

## 0.0.1

- Initial release.
- Added editor:
  - Added `MostKeyValueEditor`
  - Added `MostKeyValueEditorController`
  - Added `PropertyBuilder`
  - Added `JsonReaderWriter`
  - Added `JsonPropertyReaderWriter`
  - Added `ValidationResult`
  - Added `ValidationMessage`
- Added widgets:
  - Added `ValuePropertyView`
  - Added `NestingIndicatorView`
  - Added `ValidationStateView`
  - Added `PropertyNameView`
  - Added `StringFormField`
- Added extensions:
  - Added `LightnessColorExtension`
  - Added `HexColorExtension`