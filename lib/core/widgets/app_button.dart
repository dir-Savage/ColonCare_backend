import 'package:flutter/material.dart';

class AppButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool isLoading;
  final bool isFullWidth;

  const AppButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isFullWidth = true,
  });

  @override
  Widget build(BuildContext context) {
    // ── Glassy style constants (tuned for blue gradient background) ──
    const double borderRadius = 24.0;
    const double blurSigma = 12.0; // subtle blur feel
    final glassColor = Colors.white.withOpacity(0.10); // very light → glassy
    final borderColor = Colors.white.withOpacity(0.22);
    final glowColor = const Color(0xFF64B5F6).withOpacity(0.35); // soft blue[300] glow

    final buttonContent = isLoading
        ? const SizedBox(
      height: 22,
      width: 22,
      child: CircularProgressIndicator(
        strokeWidth: 2.4,
        color: Colors.white,
      ),
    )
        : Text(
      text,
      style: const TextStyle(
        fontSize: 17,
        fontWeight: FontWeight.w700,
        letterSpacing: 0.4,
        color: Colors.white,
      ),
    );

    final button = ElevatedButton(
      onPressed: isLoading ? null : onPressed,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(borderRadius),
        ),
        elevation: 0, // we handle shadow manually
        backgroundColor: Colors.transparent, // important for glass
        foregroundColor: Colors.white,
        shadowColor: Colors.transparent,
      ),
      child: Container(
        width: double.infinity,
        height: 58, // nice tall modern button
        decoration: BoxDecoration(
          // Glassy base
          color: glassColor,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: borderColor,
            width: 1.4,
          ),
          // Soft glow + inner shadow
          boxShadow: [
            // Outer soft blue glow
            BoxShadow(
              color: glowColor,
              blurRadius: 20,
              spreadRadius: 2,
              offset: const Offset(0, 0),
            ),
            // Inner depth shadow
            BoxShadow(
              color: Colors.black.withOpacity(0.18),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
          // Subtle blue gradient overlay for premium feel
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.white.withOpacity(0.08),
              Colors.blue[300]!.withOpacity(0.06),
              Colors.white.withOpacity(0.04),
            ],
          ),
        ),
        child: Center(child: buttonContent),
      ),
    );

    // Optional disabled overlay (duller glass)
    final disabledOverlay = IgnorePointer(
      ignoring: !isLoading,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.12),
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );

    final finalButton = Stack(
      alignment: Alignment.center,
      children: [
        button,
        if (isLoading) disabledOverlay,
      ],
    );

    return isFullWidth
        ? SizedBox(width: double.infinity, child: finalButton)
        : finalButton;
  }
}