import 'dart:io';

void main() async {
  final result = await Process.run('flutter', ['analyze', 'lib']);
  print(result.stdout);
  print(result.stderr);
}
