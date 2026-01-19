import 'dart:io';
import 'package:coloncare/core/navigation/app_router.dart';
import 'package:coloncare/features/predict/presentation/blocs/prediction_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import '../../../../core/di/injector.dart';
import 'prediction_results_page.dart';

class PredictionPage extends StatelessWidget {
  const PredictionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<PredictionBloc>(
      create: (_) => getIt<PredictionBloc>(),
      child: Scaffold(
        backgroundColor: const Color(0xFFF8FAFC),
        appBar: AppBar(
          title: const Text(
            'Colon Scan',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              letterSpacing: -0.3,
            ),
          ),
          centerTitle: true,
          elevation: 0,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          foregroundColor: Colors.black87,
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: const Icon(Icons.history_rounded, size: 26),
                tooltip: 'History',
                onPressed: () => Navigator.pushNamed(context, AppRouter.predictionHistory),
              ),
            ),
          ],
        ),
        body: BlocListener<PredictionBloc, PredictionState>(
          listener: (context, state) {
            if (state is PredictionSuccess) {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PredictionResultsPage(
                    result: state.result,
                    imageFile: state.selectedImage,
                  ),
                ),
              );
            }
          },
          child: const _PredictionPageContent(),
        ),
      ),
    );
  }
}

class _PredictionPageContent extends StatefulWidget {
  const _PredictionPageContent();

  @override
  State<_PredictionPageContent> createState() => _PredictionPageContentState();
}

class _PredictionPageContentState extends State<_PredictionPageContent> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null && context.mounted) {
      context.read<PredictionBloc>().add(
        PredictionImageSelected(File(pickedFile.path)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<PredictionBloc, PredictionState>(
      builder: (context, state) {
        return Column(
          children: [
            // ── Image Preview Area ───────────────────────────────
            Container(
              height: 300,
              margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(28),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.07),
                    blurRadius: 24,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(28),
                child: _buildImagePreview(state),
              ),
            ),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  children: [
                    const SizedBox(height: 32),
                    _buildMainContent(context, state),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildImagePreview(PredictionState state) {
    File? image;

    if (state is PredictionInputState) image = state.selectedImage;
    if (state is PredictionLoading) image = state.selectedImage;
    if (state is PredictionError) image = state.selectedImage;

    return image != null
        ? Image.file(image, fit: BoxFit.cover)
        : Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.add_a_photo_rounded,
            size: 72,
            color: Colors.blueGrey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            'No image selected',
            style: TextStyle(
              fontSize: 17,
              color: Colors.grey.shade600,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent(BuildContext context, PredictionState state) {
    if (state is PredictionInitial) {
      return _InitialView(onPick: _pickImage);
    }

    if (state is PredictionInputState) {
      return _ReadyToAnalyzeView(
        onAnalyze: () => context.read<PredictionBloc>().add(
          PredictFromImage(state.selectedImage!),
        ),
        onChange: _pickImage,
      );
    }

    if (state is PredictionLoading) {
      return const _AnalyzingView();
    }

    if (state is PredictionError) {
      return _ErrorView(
        message: state.message,
        hasImage: state.selectedImage != null,
        onRetry: () {
          if (state.selectedImage != null) {
            context.read<PredictionBloc>().add(
              PredictFromImage(state.selectedImage!),
            );
          }
        },
        onNewImage: _pickImage,
      );
    }

    return const SizedBox.shrink();
  }
}

class _InitialView extends StatelessWidget {
  final VoidCallback onPick;

  const _InitialView({required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Icon(
          Icons.medical_services_rounded,
          size: 88,
          color: Color(0xFF3B82F6),
        ),
        const SizedBox(height: 32),
        const Text(
          "Analyze Colonoscopy\nwith AI",
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            height: 1.24,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        Text(
          "Upload image → get instant prediction",
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 48),
        _BigActionButton(
          label: "CHOOSE IMAGE",
          icon: Icons.photo_library_rounded,
          onPressed: onPick,
        ),
        const SizedBox(height: 24),
        Text(
          "JPG • PNG • HEIC",
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey.shade500,
          ),
        ),
      ],
    );
  }
}

class _ReadyToAnalyzeView extends StatelessWidget {
  final VoidCallback onAnalyze;
  final VoidCallback onChange;

  const _ReadyToAnalyzeView({
    required this.onAnalyze,
    required this.onChange,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFFEFF6FF),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFB3D4FC), width: 1.5),
          ),
          child: Column(
            children: [
              Icon(
                Icons.auto_awesome_rounded,
                size: 56,
                color: Colors.blue,
              ),
              const SizedBox(height: 20),
              const Text(
                "Ready for Analysis",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Colors.blue,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                "Press Analyze to start AI processing",
                style: TextStyle(color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
        const SizedBox(height: 40),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SecondaryButton(
              label: "CHANGE IMAGE",
              onPressed: onChange,
            ),
            const SizedBox(width: 12),
            _BigActionButton(
              label: "ANALYZE",
              icon: Icons.play_arrow_rounded,
              onPressed: onAnalyze,
            ),
          ],
        ),
      ],
    );
  }
}

class _AnalyzingView extends StatelessWidget {
  const _AnalyzingView();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 110,
                height: 110,
                child: CircularProgressIndicator(
                  strokeWidth: 5,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                  backgroundColor: Colors.blue.shade100,
                ),
              ),
              Icon(
                Icons.psychology_alt_rounded,
                size: 48,
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 40),
          const Text(
            "Analyzing Image...",
            style: TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1E293B),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "AI is working on your scan right now",
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final bool hasImage;
  final VoidCallback onRetry;
  final VoidCallback onNewImage;

  const _ErrorView({
    required this.message,
    required this.hasImage,
    required this.onRetry,
    required this.onNewImage,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.error_outline_rounded,
          size: 90,
          color: Colors.red.shade400,
        ),
        const SizedBox(height: 24),
        const Text(
          "Analysis Failed",
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: Colors.redAccent,
          ),
        ),
        const SizedBox(height: 16),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 16,
              height: 1.4,
              color: Colors.grey.shade800,
            ),
          ),
        ),
        const SizedBox(height: 48),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _SecondaryButton(
              label: "NEW IMAGE",
              onPressed: onNewImage,
            ),
            if (hasImage) ...[
              const SizedBox(width: 20),
              _BigActionButton(
                label: "RETRY",
                icon: Icons.refresh_rounded,
                onPressed: onRetry,
                backgroundColor: Colors.red.shade600,
              ),
            ],
          ],
        ),
      ],
    );
  }
}

// ── Reusable Buttons ────────────────────────────────────────

class _BigActionButton extends StatelessWidget {
  final String label;
  final IconData? icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;

  const _BigActionButton({
    required this.label,
    this.icon,
    required this.onPressed,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      icon: icon != null ? Icon(icon, size: 22) : const SizedBox.shrink(),
      label: Text(
        label,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w700,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor ?? const Color(0xFF2563EB),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        elevation: 3,
        minimumSize: const Size(150, 50),
      ),
    );
  }
}

class _SecondaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;

  const _SecondaryButton({
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: const Color(0xFF2563EB),
        side: const BorderSide(color: Color(0xFF93C5FD), width: 2),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        minimumSize: const Size(150, 50),
      ),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}