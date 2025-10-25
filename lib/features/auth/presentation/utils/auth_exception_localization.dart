import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:money_tracker/core/errors/auth_error_mapper.dart';
import 'package:money_tracker/core/errors/auth_exception.dart';

extension AuthExceptionLocalization on AuthException {
  String localizedMessage(AppLocalizations t) {
    if (code == null) {
      return message;
    }

    final normalized = message.toLowerCase();
    if (normalized.contains('sign in')) {
      return AuthErrorMapper.mapSignInError(code!, t);
    }
    if (normalized.contains('sign up')) {
      return AuthErrorMapper.mapSignUpError(code!, t);
    }
    if (normalized.contains('password reset')) {
      return AuthErrorMapper.mapPasswordResetError(code!, t);
    }
    if (normalized.contains('profile update')) {
      return t.errUnexpected;
    }
    if (normalized.contains('email verification')) {
      return t.couldNotSendEmail;
    }
    if (normalized.contains('user reload')) {
      return t.couldNotRefreshStatus;
    }

    return t.errUnexpected;
  }
}
