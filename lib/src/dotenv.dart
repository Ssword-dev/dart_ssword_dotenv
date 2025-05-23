library dotenv;

import 'dart:io';

import 'package:meta/meta.dart';

import 'parser.dart';

/// Loads key-value pairs from a file into a [Map<String, String>].
///
/// The parser will attempt to handle simple variable substitution,
/// respect single- vs. double-quotes, and ignore `#comments` or the `export` keyword.
class DotEnv {
  /// If true, the underlying map will contain the entries of [Platform.environment],
  /// even after calling [clear].
  /// Otherwise, it will be empty until populated by [load].
  final bool includePlatformEnvironment;

  /// If true, suppress "file not found" messages on [stderr] during [load].
  final bool quiet;

  final _map = <String, String>{};

  DotEnv({this.includePlatformEnvironment = false, this.quiet = false}) {
    if (includePlatformEnvironment) _addPlatformEnvironment();
  }

  /// Provides access to the underlying [Map].
  ///
  /// Prefer using [operator[]] to read values.
  @visibleForTesting
  Map<String, String> get map => _map;

  /// Reads the value for [key] from the underlying map.
  ///
  /// Returns `null` if [key] is absent.  See [isDefined].
  String? operator [](String key) => _map[key];

  /// Calls [Map.addAll] on the underlying map.
  void addAll(Map<String, String> other) => _map.addAll(other);

  /// Calls [Map.clear] on the underlying map.
  ///
  /// If [includePlatformEnvironment] is true, the entries of [Platform.environment] will be reinserted.
  void clear() {
    _map.clear();
    if (includePlatformEnvironment) _addPlatformEnvironment();
  }

  /// Equivalent to [operator []] when the underlying map contains [key],
  /// and the value is non-empty.  See [isDefined].
  ///
  /// Otherwise, calls [orElse] and returns the value.
  String getOrElse(String key, String Function() orElse) =>
      isDefined(key) ? _map[key]! : orElse();

  /// True if [key] has a nonempty value in the underlying map.
  ///
  /// Differs from [Map.containsKey] by excluding empty values.
  bool isDefined(String key) => _map[key]?.isNotEmpty ?? false;

  /// True if all supplied [vars] have nonempty value; false otherwise.
  ///
  /// See [isDefined].
  bool isEveryDefined(Iterable<String> vars) => vars.every(isDefined);

  /// Parses environment variables from each path in [filenames], and adds them
  /// to the underlying [Map].
  ///
  /// Logs to [stderr] if any file does not exist; see [quiet].
  void load(
      [Iterable<String> filenames = const ['.env'],
      Parser psr = const Parser()]) {
    for (var filename in filenames) {
      var f = File.fromUri(Uri.file(filename));
      var lines = _verify(f);
      _map.addAll(psr.parse(lines));
    }
  }

  /// Parses environment variables from each path in [filenames], and adds them
  /// to the underlying [Map].
  ///
  /// Logs to [stderr] if any file does not exist; see [quiet].
  ///
  /// An extension of [DotEnv.load]
  Future<void> loadAsync(
      [Iterable<String> filenames = const ['.env'],
      Parser psr = const Parser()]) async {
    for (var filename in filenames) {
      var f = File.fromUri(Uri.file(filename));
      var lines = await _verifyAsync(f);
      _map.addAll(psr.parse(lines));
    }
  }

  void _addPlatformEnvironment() => _map.addAll(Platform.environment);

  List<String> _verify(File f) {
    if (!f.existsSync()) {
      if (!quiet) stderr.writeln('[dotenv] Load failed: file not found: $f');
      return [];
    }
    return f.readAsLinesSync();
  }

  /// A non blocking future based version of _verify from the original dotenv
  /// repo [source code](https://github.com/mockturtl/dotenv/blob/master/lib/src/dotenv.dart)
  Future<List<String>> _verifyAsync(File f) async {
    bool envExists = await f.exists();
    if (!envExists) {
      if (!quiet) stderr.writeln('[dotenv] Load failed: file not found: $f');
      return [];
    }

    List<String> envContents = await f.readAsLines();
    return envContents;
  }
}
