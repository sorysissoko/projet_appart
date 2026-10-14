import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class ReservationHelpers {
  static String getStatusText(String status) {
    switch (status) {
      case 'confirmee': return 'Confirmé';
      case 'en_attente': return 'En attente';
      case 'annulee': return 'Annulé';
      case 'terminee': return 'Terminé';
      case 'refuse': return 'Refusé';
      default: return status;
    }
  }

  static Color getStatusColor(String status) {
    switch (status) {
      case 'confirmee': return const Color(0xFF10B981);
      case 'en_attente': return const Color(0xFFF59E0B);
      case 'annulee': return const Color(0xFFEF4444);
      case 'terminee': return const Color(0xFF8B5CF6);
      case 'refuse': return const Color(0xFFEF4444);
      default: return Colors.grey;
    }
  }

  static String formatPrix(String prix) {
    final number = int.tryParse(prix) ?? 0;
    return NumberFormat.decimalPattern('fr_FR').format(number) + ' XOF';
  }

  static String formatDate(dynamic date) {
    if (date == null) return '';
    try {
      if (date is DateTime) {
        return DateFormat('dd/MM/yyyy').format(date);
      }
      return DateFormat('dd/MM/yyyy').format(DateTime.parse(date.toString()));
    } catch (e) {
      return date.toString();
    }
  }

  static int calculateNights(DateTime start, DateTime end) {
    return end.difference(start).inDays;
  }

  static String getMomentPaiementText(String moment) {
    switch (moment) {
      case 'arrivee': return 'À l\'arrivée';
      case 'depart': return 'Au départ';
      case 'immediat': return 'Immédiat';
      default: return moment;
    }
  }
}