// Modification: switch every package:dotenv in the docs
// to reflect the real package url
/// Loads environment variables from a `.env` file.
///
/// ## usage
///
/// Call [DotEnv.load] to parse the file(s).
/// Read variables from the underlying [Map] using the `[]` operator.
///
///     import 'package:ssword_dotenv/ssword_dotenv.dart';
///
///     void main() {
///       var env = DotEnv(includePlatformEnvironment: true)
///         ..load('path/to/my/.env');
///       var foo = env['foo'];
///       var homeDir = env['HOME'];
///       // ...
///     }
///
/// Verify required variables are present:
///
///     const _requiredEnvVars = ['host', 'port'];
///     bool get hasEnv => env.isEveryDefined(_requiredEnvVars);

// Modification: Direct use of exports through path, not package url
export 'src/dotenv.dart';
