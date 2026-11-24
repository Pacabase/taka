import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:system_ssh/system_ssh.dart';

part 'login_prompt.freezed.dart';

/// What ssh asks while tunnel [tunnelId] logs in; [id] names it in the
/// answer.
@freezed
sealed class const LoginPrompt._() with _$LoginPrompt {
  const factory({
    required int id,
    required String tunnelId,
    required SshPrompt prompt,
  }) = _LoginPrompt;

  static LoginPrompt fromJson(Object? json) => switch (json) {
    {
          'id': final int id,
          'tunnel': final String tunnelId,
          'kind': final String kind,
          'text': final String text,
        } &&
        final Map<Object?, Object?> fields =>
      LoginPrompt(
        id: id,
        tunnelId: tunnelId,
        prompt: switch ((kind, fields['keyPath'])) {
          ('passphrase', final String keyPath) => SshPassphrasePrompt(
            text,
            keyPath: keyPath,
          ),
          ('password', _) => SshPasswordPrompt(text),
          _ => SshCodePrompt(text),
        },
      ),
    _ => throw FormatException('Not a login prompt: $json'),
  };

  Map<String, Object?> toJson() => {
    'id': id,
    'tunnel': tunnelId,
    ...switch (prompt) {
      SshPassphrasePrompt(:final keyPath) => {
        'kind': 'passphrase',
        'keyPath': keyPath,
      },
      SshPasswordPrompt() => {'kind': 'password'},
      SshCodePrompt() => {'kind': 'code'},
    },
    'text': prompt.text,
  };
}
