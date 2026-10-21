import 'dart:io';

import 'package:yaml/yaml.dart';
import 'package:yaml_edit/yaml_edit.dart';

void main(List<String> args) {
  if (args.length < 2) {
    stderr.writeln(
      'Usage: dart tool/normalize_openapi.dart <input_path> <output_path>',
    );
    exit(1);
  }
  final inputPath = args[0];
  final outputPath = args[1];

  final content = File(inputPath).readAsStringSync();
  final yamlDoc = loadYaml(content);
  if (yamlDoc is! YamlMap) {
    File(outputPath).writeAsStringSync(content);
    return;
  }

  final editor = YamlEditor(content);
  final paths = yamlDoc['paths'];
  if (paths is YamlMap) {
    for (final entry in paths.entries) {
      final pathKey = entry.key;
      final pathItem = entry.value;
      if (pathItem is YamlMap && pathItem.containsKey('parameters')) {
        final pathParams = (pathItem['parameters'] as YamlList)
            .map((e) => e)
            .toList();
        editor.remove(['paths', pathKey, 'parameters']);
        for (final m in ['get', 'post', 'put', 'patch', 'delete']) {
          if (pathItem.containsKey(m)) {
            final op = pathItem[m];
            final existingParams = op is YamlMap && op.containsKey('parameters')
                ? (op['parameters'] as YamlList).map((e) => e).toList()
                : [];
            editor.update(
              ['paths', pathKey, m, 'parameters'],
              [...existingParams, ...pathParams],
            );
          }
        }
      }
    }
  }

  File(outputPath).writeAsStringSync(editor.toString());
}
