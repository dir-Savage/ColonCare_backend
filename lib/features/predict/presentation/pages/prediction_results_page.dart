// features/predict/presentation/pages/prediction_results_page.dart
import 'dart:io';
import 'package:coloncare/core/utils/app_animations.dart';
import 'package:coloncare/features/predict/domain/entities/prediction_result.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PredictionResultsPage extends StatefulWidget {
  final PredictionResult result;
  final File? imageFile;

  const PredictionResultsPage({
    super.key,
    required this.result,
    this.imageFile,
  });

  @override
  State<PredictionResultsPage> createState() => _PredictionResultsPageState();
}

class _PredictionResultsPageState extends State<PredictionResultsPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutBack,
      ),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
      ),
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final isNormal = result.prediction.toLowerCase() == 'normal';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction Results'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _fadeAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                child: child,
              ),
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                // Header
                SlideInAnimation(
                  child: Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.blue[200]!),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.verified,
                          size: 50,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'AI Analysis Complete',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[800],
                          ),
                        ),
                        Text(
                          DateFormat('MMM dd, yyyy • HH:mm').format(DateTime.now()),
                          style: TextStyle(
                            color: Colors.blue[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Show image if available
                if (widget.imageFile != null)
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 50),
                    child: _buildImagePreview(),
                  ),

                if (widget.imageFile != null) const SizedBox(height: 24),

                // Main Result
                SlideInAnimation(
                  delay: const Duration(milliseconds: 100),
                  child: _buildMainResultCard(result, isNormal),
                ),
                const SizedBox(height: 24),

                // Confidence Meter
                SlideInAnimation(
                  delay: const Duration(milliseconds: 200),
                  child: _buildConfidenceCard(result),
                ),
                const SizedBox(height: 24),

                // Details
                if (result.details.isNotEmpty)
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 300),
                    child: _buildDetailsCard(result),
                  ),
                SizedBox(height: 20,),

                // OOD Warning
                if (result.isOutOfDistribution)
                  SlideInAnimation(
                    delay: const Duration(milliseconds: 400),
                    child: _buildOODWarning(),
                  ),

                const SizedBox(height: 32),

                // Recommendations
                SlideInAnimation(
                  delay: const Duration(milliseconds: 500),
                  child: _buildRecommendationsCard(result),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: _buildBottomButtons(context),
    );
  }

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.file(
          widget.imageFile!,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              color: Colors.grey[200],
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  size: 60,
                  color: Colors.grey,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMainResultCard(PredictionResult result, bool isNormal) {
    final predictionColor = _getPredictionColor(result.prediction);
    final icon = _getPredictionIcon(result.prediction);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            predictionColor.withOpacity(0.1),
            predictionColor.withOpacity(0.05),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: predictionColor.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: predictionColor.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: predictionColor.withOpacity(0.2),
              shape: BoxShape.circle,
              border: Border.all(color: predictionColor, width: 3),
            ),
            child: Icon(icon, size: 40, color: predictionColor),
          ),
          const SizedBox(height: 20),
          Text(
            result.prediction.toUpperCase(),
            style: TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.bold,
              color: predictionColor,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _getPredictionDescription(result.prediction),
            style: TextStyle(
              fontSize: 18,
              color: Colors.blue[800],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfidenceCard(PredictionResult result) {
    final percentage = result.probability * 100;
    final confidenceColor = _getConfidenceColor(percentage);
    final confidenceLevel = _getConfidenceLevel(percentage);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[100]!),
        boxShadow: [
          BoxShadow(
            color: Colors.blue.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'AI Confidence Level',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
              Chip(
                label: Text(
                  confidenceLevel,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                backgroundColor: confidenceColor,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Stack(
            children: [
              Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.blue[100],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(seconds: 1),
                curve: Curves.easeOut,
                height: 12,
                width: MediaQuery.of(context).size.width * percentage / 100 * 0.85,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      confidenceColor.withOpacity(0.8),
                      confidenceColor,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: confidenceColor,
                ),
              ),
              Text(
                'Distance Score: ${(result.distance * 100).toStringAsFixed(1)}',
                style: TextStyle(
                  color: Colors.blue[600],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard(PredictionResult result) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info,
                color: Colors.blue[700],
              ),
              const SizedBox(width: 10),
              Text(
                'Analysis Details',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            result.details,
            style: TextStyle(
              fontSize: 16,
              color: Colors.blue[700],
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOODWarning() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.orange[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange[200]!),
      ),
      child: Row(
        children: [
          Icon(
            Icons.warning_amber,
            color: Colors.orange[700],
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'This image appears different from typical training data. Results may have reduced confidence.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecommendationsCard(PredictionResult result) {
    final isNormal = result.prediction.toLowerCase() == 'normal';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.recommend,
                color: Colors.green[700],
              ),
              const SizedBox(width: 10),
              Text(
                'Recommendations',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.green[800],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (isNormal)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecommendationItem(
                  'Continue regular screening',
                  Icons.check_circle,
                ),
                _buildRecommendationItem(
                  'Maintain healthy lifestyle',
                  Icons.favorite,
                ),
                _buildRecommendationItem(
                  'Next screening in 3-5 years',
                  Icons.calendar_today,
                ),
              ],
            )
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildRecommendationItem(
                  'Consult with a gastroenterologist',
                  Icons.medical_services,
                ),
                _buildRecommendationItem(
                  'Schedule follow-up examination',
                  Icons.schedule,
                ),
                _buildRecommendationItem(
                  'Consider biopsy if recommended',
                  Icons.biotech,
                ),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildRecommendationItem(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.green[700]),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 15,
                color: Colors.green[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomButtons(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[200]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.arrow_back),
              label: const Text('BACK'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.blue[400]!),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to history page
                Navigator.pushNamed(context, '/prediction-history');
              },
              icon: const Icon(Icons.history),
              label: const Text('SAVE & HISTORY'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue[600],
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getPredictionColor(String prediction) {
    switch (prediction.toLowerCase()) {
      case 'normal':
        return Colors.green;
      case 'polyp':
        return Colors.orange;
      case 'cancer':
        return Colors.red;
      default:
        return Colors.blue;
    }
  }

  IconData _getPredictionIcon(String prediction) {
    switch (prediction.toLowerCase()) {
      case 'normal':
        return Icons.check_circle;
      case 'polyp':
        return Icons.warning;
      case 'cancer':
        return Icons.error;
      default:
        return Icons.help;
    }
  }

  String _getPredictionDescription(String prediction) {
    switch (prediction.toLowerCase()) {
      case 'normal':
        return 'No abnormalities detected';
      case 'polyp':
        return 'Growth detected in colon lining';
      case 'cancer':
        return 'Malignant cells detected';
      default:
        return 'Analysis complete';
    }
  }

  Color _getConfidenceColor(double percentage) {
    if (percentage >= 80) return Colors.green;
    if (percentage >= 60) return Colors.orange;
    return Colors.red;
  }

  String _getConfidenceLevel(double percentage) {
    if (percentage >= 80) return 'HIGH';
    if (percentage >= 60) return 'MEDIUM';
    return 'LOW';
  }
}