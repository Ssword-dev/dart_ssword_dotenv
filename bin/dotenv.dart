/// This will remain unmodified until big changes comes
/// e.g: security bug fix (if there is, please consider contributing)

import 'dart:io';

import 'package:args/args.dart';
import 'package:ssword_dotenv/ssword_dotenv.dart';

/// Prints the [dotEnv] map.
///
/// ## usage
///
///     dart pub global run dotenv --help
void main(List<String> argv) {
  var opts = _argPsr.parse(argv);

  if (opts.wasParsed(_flagHelp)) return _usage();

  var files = opts[_flagFiles] as List<String>;
  var withProcessVars = opts.wasParsed(_flagMergePlatformVars);

  var quiet = opts[_flagQuiet] as bool;

  _loadAndPrint(
      DotEnv(includePlatformEnvironment: withProcessVars, quiet: quiet), files);
}

const _flagFiles = 'filenames';
const _flagHelp = 'help';
const _flagMergePlatformVars = 'merge-platform-vars';
const _flagQuiet = 'quiet';

final _argPsr = new ArgParser()
  ..addFlag(_flagHelp,
      abbr: 'h', negatable: false, help: 'Print this help text.')
  ..addMultiOption(_flagFiles,
      abbr: 'f',
      defaultsTo: ['.env'],
      help:
          'Files to read.\nProvide environment variable definitions, one per line.')
  ..addFlag(_flagMergePlatformVars,
      abbr: 'p',
      help: 'Merge process variables from Platform.environment.',
      defaultsTo: false)
  ..addFlag(_flagQuiet,
      abbr: 'q',
      help: 'Suppress "file not found" messages on stderr.',
      defaultsTo: false);

void _loadAndPrint(DotEnv dotEnv, List<String> files) {
  dotEnv.load(files);
  //ignore: invalid_use_of_visible_for_testing_member
  _p(dotEnv.map);
}

void _p(msg) => stdout.writeln(msg);

void _usage() {
  _p('Parse variable definitions from a file, print the environment and exit.');
  _p('Usage: pub global run dotenv [-f <file>]\n${_argPsr.usage}');
}
