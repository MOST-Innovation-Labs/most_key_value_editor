import 'package:most_schema_parser/most_schema_parser.dart';
import 'package:recase/recase.dart';

extension MostPropertyExtension on MostProperty {
  /// Display title that is visible to user.
  String get displayTitle => title ?? propertyName.titleCase;
}
