import 'dart:io';

class CommandResult {
  const CommandResult({
    required this.stdout,
    required this.stderr,
    required this.exitCode,
  });

  final String stdout;
  final String stderr;
  final int exitCode;
}

abstract interface class SystemCommandRunner {
  Future<CommandResult> run(String command, List<String> arguments);
}

class ProcessSystemCommandRunner implements SystemCommandRunner {
  @override
  Future<CommandResult> run(String command, List<String> arguments) async {
    try {
      final result = await Process.run(command, arguments);
      return CommandResult(
        stdout: result.stdout.toString(),
        stderr: result.stderr.toString(),
        exitCode: result.exitCode,
      );
    } on ProcessException catch (error) {
      return CommandResult(stdout: '', stderr: error.message, exitCode: -1);
    }
  }
}
