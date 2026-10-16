import 'package:flutter/material.dart';
import 'package:service/snackbar_service.dart';

class ReservationHelpers {
  static void showAppSnackBar({
    required String message,
    required SnackBarType type,
    IconData? icon,
    Duration duration = const Duration(seconds: 4),
  }) {
    switch (type) {
      case SnackBarType.success:
        SnackBarService().showSuccess(
          message,
          icon: icon,
          duration: duration,
        );
        break;
      case SnackBarType.error:
        SnackBarService().showError(
          message,
          icon: icon,
          duration: duration,
        );
        break;
      case SnackBarType.warning:
        SnackBarService().showWarning(
          message,
          icon: icon,
          duration: duration,
        );
        break;
      case SnackBarType.info:
        SnackBarService().showInfo(
          message,
          icon: icon,
          duration: duration,
        );
        break;
    }
  }

  static DateTime calculateFreeCancellationDate(DateTime startDate) {
    return startDate.subtract(const Duration(days: 2));
  }

  static bool isRangeAvailable(DateTime start, DateTime end, Set<DateTime> reservedDates) {
    for (final reserved in reservedDates) {
      if (!reserved.isBefore(start) && !reserved.isAfter(end)) {
        return false;
      }
    }
    return true;
  }
}