import 'package:coloncare/core/constants/assets_manager.dart';
import 'package:coloncare/core/utils/app_animations.dart';
import 'package:coloncare/features/bmi/presentation/blocs/bmi_bloc.dart';
import 'package:coloncare/features/bmi/presentation/blocs/bmi_event.dart';
import 'package:coloncare/features/bmi/presentation/blocs/bmi_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../../core/di/injector.dart';

class BmiCalculatorPage extends StatelessWidget {
  const BmiCalculatorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<BmiBloc>(
      create: (_) => getIt<BmiBloc>(),
      child: const _BmiCalculatorPageContent(),
    );
  }
}

class _BmiCalculatorPageContent extends StatelessWidget {
  const _BmiCalculatorPageContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
        leading: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Image(
            image: const AssetImage(AssetsManager.appLogo),
            fit: BoxFit.contain,
            height: 50,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/bmi-history');
            },
            tooltip: 'View History',
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
              ),
              child: CircleAvatar(
                backgroundColor: Theme.of(context).primaryColor.withOpacity(0.1),
                child: ClipOval(
                  child: SvgPicture.network(
                    AssetsManager.avatarUrl,
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      body: BlocConsumer<BmiBloc, BmiState>(
        listener: (context, state) {
          if (state is BmiError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          } else if (state is BmiHistoryLoaded) {
            // Show success message when calculation is saved
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('BMI saved successfully'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is BmiLoading) {
            return _buildLoadingState();
          }

          if (state is BmiInputState || state is BmiInitial) {
            final inputState = state is BmiInputState ? state : const BmiInputState();
            return _buildCalculatorForm(context, inputState);
          }

          if (state is BmiHistoryLoaded) {
            // After calculation, show form with latest data
            return _buildCalculatorForm(
              context,
              const BmiInputState(),
            );
          }

          return _buildCalculatorForm(context, const BmiInputState());
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Calculating BMI...'),
        ],
      ),
    );
  }

  Widget _buildCalculatorForm(BuildContext context, BmiInputState state) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // BMI Result Card
          FadeInAnimation(
            child: _buildBmiResultCard(state),
          ),
          const SizedBox(height: 32),

          // Weight Input
          SlideInAnimation(
            delay: const Duration(milliseconds: 100),
            child: _buildWeightInput(context, state),
          ),
          const SizedBox(height: 24),

          // Height Input
          SlideInAnimation(
            delay: const Duration(milliseconds: 200),
            child: _buildHeightInput(context, state),
          ),
          const SizedBox(height: 24),

          // Notes Input
          SlideInAnimation(
            delay: const Duration(milliseconds: 300),
            child: _buildNotesInput(context, state),
          ),
          const SizedBox(height: 32),

          // Calculate Button
          SlideInAnimation(
            delay: const Duration(milliseconds: 400),
            child: _buildCalculateButton(context, state),
          ),
          const SizedBox(height: 24),

          // BMI Info
          FadeInAnimation(
            duration: const Duration(milliseconds: 500),
            child: _buildBmiInfo(),
          ),
        ],
      ),
    );
  }

  Widget _buildBmiResultCard(BmiInputState state) {
    final bmi = state.calculatedBmi;
    final category = state.bmiCategory;
    final color = state.bmiColor;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your BMI',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
          Text(
            bmi.toStringAsFixed(1),
            style: TextStyle(
              fontSize: 64,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: color.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Text(
              category,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeightInput(BuildContext context, BmiInputState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Weight (kg)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            Text(
              '${state.weight.toStringAsFixed(1)} kg',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: state.weight,
          min: 30,
          max: 200,
          divisions: 170,
          label: '${state.weight.toStringAsFixed(1)} kg',
          onChanged: (value) {
            context.read<BmiBloc>().add(
              BmiInputChanged(weight: value),
            );
          },
          activeColor: Colors.blue,
          inactiveColor: Colors.grey[300],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '30 kg',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '200 kg',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildHeightInput(BuildContext context, BmiInputState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Height (cm)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.grey[800],
              ),
            ),
            Text(
              '${state.height.toStringAsFixed(1)} cm',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Slider(
          value: state.height,
          min: 100,
          max: 250,
          divisions: 150,
          label: '${state.height.toStringAsFixed(1)} cm',
          onChanged: (value) {
            context.read<BmiBloc>().add(
              BmiInputChanged(height: value),
            );
          },
          activeColor: Colors.blue,
          inactiveColor: Colors.grey[300],
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '100 cm',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            Text(
              '250 cm',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildNotesInput(BuildContext context, BmiInputState state) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notes (Optional)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.grey[800],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          onChanged: (value) {
            context.read<BmiBloc>().add(
              BmiInputChanged(notes: value),
            );
          },
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Add any notes about this measurement...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ],
    );
  }

  Widget _buildCalculateButton(BuildContext context, BmiInputState state) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: state.canCalculate
            ? () {
          context.read<BmiBloc>().add(
            BmiCalculateRequested(
              weight: state.weight,
              height: state.height,
              notes: state.notes.isNotEmpty ? state.notes : null,
            ),
          );
        }
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          elevation: 4,
        ),
        child: const Text(
          'Save BMI Result',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildBmiInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: Colors.blue,
              ),
              const SizedBox(width: 8),
              Text(
                'BMI Categories',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.blue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          _buildCategoryRow('Underweight', 'Below 18.5', Colors.orange),
          _buildCategoryRow('Normal', '18.5 - 24.9', Colors.green),
          _buildCategoryRow('Overweight', '25 - 29.9', Colors.orange),
          _buildCategoryRow('Obesity Class I', '30 - 34.9', Colors.red),
          _buildCategoryRow('Obesity Class II', '35 - 39.9', Colors.red),
          _buildCategoryRow('Obesity Class III', '40 and above', Colors.red),
        ],
      ),
    );
  }

  Widget _buildCategoryRow(String category, String range, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              category,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
              ),
            ),
          ),
          Text(
            range,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}