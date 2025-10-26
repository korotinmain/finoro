import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker/core/errors/auth_error_mapper.dart';
import 'package:money_tracker/core/errors/auth_exception.dart';

extension AuthExceptionLocalization on AuthException {
  String localizedMessage(AppLocalizations t) {
    final normalized = message.toLowerCase();

    if (normalized.contains('google sign-in')) {
      return t.googleSignInFailed;
    }
    if (normalized.contains('apple sign-in')) {
      return t.appleSignInFailed;
    }

    if (code == null) {
      return message;
    }

    if (normalized.contains('sign in')) {
      return AuthErrorMapper.mapSignInError(code!, t);
    }
    if (normalized.contains('user reload')) {
      return t.couldNotRefreshStatus;
    }

    return t.errUnexpected;
  }
}
