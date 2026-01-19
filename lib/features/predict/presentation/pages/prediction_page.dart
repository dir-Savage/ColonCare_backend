// features/predict/presentation/pages/prediction_page.dart
import 'dart:io';
import 'package:coloncare/core/constants/assets_manager.dart';
import 'package:coloncare/core/navigation/app_router.dart';
import 'package:coloncare/core/utils/app_animations.dart';
import 'package:coloncare/features/predict/domain/entities/prediction_result.dart';
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
        appBar: AppBar(
          title: const Text('Colon Scan Prediction'),
          centerTitle: true,
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            IconButton(
              icon: const Icon(Icons.history),
              onPressed: () =>
                  Navigator.pushNamed(context, AppRouter.predictionHistory),
              tooltip: 'View History',
            ),
          ],
        ),
        body: BlocListener<PredictionBloc, PredictionState>(
          listener: (context, state) {
            if (state is PredictionSuccess) {
              // Navigate to results page after successful prediction
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
            // Image Preview
            _buildImageSection(state),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Show appropriate content based on state
                    if (state is PredictionInitial) _buildInitialState(),

                    if (state is PredictionInputState)
                      _buildImageSelectedState(context, state),

                    if (state is PredictionLoading) _buildLoadingState(),

                    if (state is PredictionError)
                      _buildErrorState(context, state),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  // Image Preview Section
  Widget _buildImageSection(PredictionState state) {
    File? selectedImage;

    if (state is PredictionInputState) selectedImage = state.selectedImage;
    if (state is PredictionLoading) selectedImage = state.selectedImage;
    if (state is PredictionError) selectedImage = state.selectedImage;

    return Container(
      height: 250,
      width: double.infinity,
      color: Colors.blue[50],
      child: selectedImage != null
          ? Image.file(selectedImage, fit: BoxFit.cover)
          : Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image, size: 60, color: Colors.blue[300]),
            const SizedBox(height: 16),
            Text(
              'No image selected',
              style: TextStyle(color: Colors.blue[600], fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  // Initial State (no image)
  Widget _buildInitialState() {
    return FadeInAnimation(
      duration: const Duration(milliseconds: 800),
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.cloud_upload, size: 80, color: Colors.blue[400]),
            const SizedBox(height: 24),
            Text(
              'Upload a colonoscopy image\nfor AI analysis',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _pickImage,
              icon: const Icon(Icons.add_photo_alternate),
              label: const Text('SELECT IMAGE'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 30, vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Supported formats: JPG, PNG',
              style: TextStyle(color: Colors.blue[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Image Selected State
  Widget _buildImageSelectedState(
      BuildContext context, PredictionInputState state) {
    return FadeInAnimation(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            ScaleAnimation(
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.image_search,
                        size: 50, color: Colors.blue[700]),
                    const SizedBox(height: 16),
                    Text(
                      'Image Ready for Analysis',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap Analyze to process with AI',
                      style: TextStyle(color: Colors.blue[600]),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                OutlinedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.refresh),
                  label: const Text('CHANGE IMAGE'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.blue[400]!),
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    if (state.selectedImage != null) {
                      context
                          .read<PredictionBloc>()
                          .add(PredictFromImage(state.selectedImage!));
                    }
                  },
                  icon: const Icon(Icons.psychology),
                  label: const Text('ANALYZE'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[600],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 40, vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 3,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Loading State
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 100,
            height: 100,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  valueColor:
                  AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
                  strokeWidth: 4,
                ),
                Icon(Icons.medical_information,
                    size: 40, color: Colors.blue[700]),
              ],
            ),
          ),
          const SizedBox(height: 32),
          FadeInAnimation(
            child: Text(
              'AI Analysis in Progress...',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.blue[800],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Processing your image with our medical AI model',
            style: TextStyle(color: Colors.blue[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // Error State
  Widget _buildErrorState(BuildContext context, PredictionError state) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error, size: 80, color: Colors.red),
          const SizedBox(height: 24),
          Text(
            'Analysis Failed',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: Colors.red[800],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            state.message,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.red[600]),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              OutlinedButton.icon(
                onPressed: _pickImage,
                icon: const Icon(Icons.refresh),
                label: const Text('NEW IMAGE'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  side: BorderSide(color: Colors.blue[400]!),
                ),
              ),
              const SizedBox(width: 16),
              ElevatedButton.icon(
                onPressed: state.selectedImage != null
                    ? () {
                  context.read<PredictionBloc>().add(
                    PredictFromImage(state.selectedImage!),
                  );
                }
                    : null,
                icon: const Icon(Icons.refresh),
                label: const Text('RETRY'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 30, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 3,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}