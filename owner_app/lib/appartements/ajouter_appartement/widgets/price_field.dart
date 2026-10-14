import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:owner_app/appartements/ajouter_appartement/widgets/price_formatter.dart';
import 'package:owner_app/core/theme/app_theme.dart';

class PriceField extends StatelessWidget {
  final TextEditingController controller;

  const PriceField({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Prix (FCFA)',
            style: GoogleFonts.nunito(
              fontSize: 15,
              fontWeight: FontWeight.w800,
              color: AppColors.inputText,
            ),
          ),
          const SizedBox(height: 6),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
              PriceFormatter(),
            ],
            style: GoogleFonts.nunito(
              fontSize: 14,
              color: AppColors.inputText,
            ),
            decoration: InputDecoration(
              hintText: 'ex : 35000',
              hintStyle: GoogleFonts.nunito(
                color: const Color(0xFF8A94A6),
              ),
              prefixText: 'XOF ',
              prefixStyle: GoogleFonts.nunito(
                color: AppColors.inputText,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
              fillColor: Colors.white,
              filled: true,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 12,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: Color(0xFFE2E8F0),
                  width: 1.5,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: const BorderSide(
                  color: AppColors.cardForeground,
                  width: 1.5,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}