import 'package:coloncare/features/medicine/domain/entities/medicine_reminder.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_bloc.dart';
import 'package:coloncare/features/medicine/presentation/blocs/medicine_event.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class AddEditMedicinePage extends StatefulWidget {
  final MedicineReminder? medicine;
  const AddEditMedicinePage({super.key, this.medicine});

  @override
  State<AddEditMedicinePage> createState() => _AddEditMedicinePageState();
}

class _AddEditMedicinePageState extends State<AddEditMedicinePage> {
  late TextEditingController _titleCtrl;
  late TextEditingController _purposeCtrl;
  DateTime _startDate = DateTime.now();
  DateTime? _endDate;
  int _interval = 8;
  final List<String> _selectedDays = [];

  final List<String> _weekDays = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
  final List<int> _intervalOptions = [1, 2, 3, 4, 6, 8, 12, 24];

  @override
  void initState() {
    super.initState();
    _titleCtrl = TextEditingController(text: widget.medicine?.title ?? '');
    _purposeCtrl = TextEditingController(text: widget.medicine?.purpose ?? '');
    if (widget.medicine != null) {
      _startDate = widget.medicine!.startDate;
      _endDate = widget.medicine!.endDate;
      _interval = widget.medicine!.hourInterval;
      _selectedDays.addAll(widget.medicine!.daysOfWeek);
    } else {
      // Default to today for new medicines
      _startDate = DateTime.now();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _purposeCtrl.dispose();
    super.dispose();
  }

  void _save() {
    print("💾 Saving medicine...");
    print("  Title: ${_titleCtrl.text}");
    print("  Purpose: ${_purposeCtrl.text}");
    print("  Start Date: $_startDate");
    print("  End Date: $_endDate");
    print("  Interval: $_interval hours");
    print("  Selected Days: $_selectedDays");

    if (_titleCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a medicine name')),
      );
      return;
    }

    if (_purposeCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter the purpose')),
      );
      return;
    }

    context.read<MedicineBloc>().add(
      SaveMedicineEvent(
        title: _titleCtrl.text.trim(),
        purpose: _purposeCtrl.text.trim(),
        startDate: _startDate,
        endDate: _endDate,
        hourInterval: _interval,
        daysOfWeek: _selectedDays,
        medicineId: widget.medicine?.id,
      ),
    );

    Navigator.pop(context);
  }

  Future<void> _selectStartDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _startDate = picked);
    }
  }

  Future<void> _selectEndDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? DateTime.now().add(const Duration(days: 30)),
      firstDate: _startDate,
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() => _endDate = picked);
    }
  }

  void _toggleDay(String day) {
    setState(() {
      if (_selectedDays.contains(day)) {
        _selectedDays.remove(day);
      } else {
        _selectedDays.add(day);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.medicine == null ? 'Add Medicine' : 'Edit Medicine'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _save,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _titleCtrl,
              decoration: const InputDecoration(
                labelText: 'Medicine Name',
                hintText: 'e.g., Aspirin, Insulin',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.medication),
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _purposeCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Purpose',
                hintText: 'e.g., For headache, Blood pressure',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.description),
              ),
            ),
            const SizedBox(height: 24),

            // Start Date
            _buildDateField(
              label: 'Start Date',
              date: _startDate,
              onTap: _selectStartDate,
              icon: Icons.calendar_today,
            ),
            const SizedBox(height: 16),

            // End Date (Optional)
            _buildDateField(
              label: 'End Date (Optional)',
              date: _endDate,
              onTap: _selectEndDate,
              icon: Icons.calendar_today,
              isOptional: true,
            ),
            const SizedBox(height: 24),

            // Interval Selection
            Text(
              'Dosage Interval',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _intervalOptions.map((hours) {
                final isSelected = _interval == hours;
                return ChoiceChip(
                  label: Text('Every $hours${hours == 1 ? ' hour' : ' hours'}'),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() => _interval = hours);
                  },
                );
              }).toList(),
            ),
            const SizedBox(height: 24),

            // Days of Week Selection
            Text(
              'Days of Week (Select all for daily)',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _weekDays.map((day) {
                final isSelected = _selectedDays.contains(day);
                return GestureDetector(
                  onTap: () => _toggleDay(day),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? Theme.of(context).primaryColor
                          : Colors.grey.shade100,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isSelected
                            ? Theme.of(context).primaryColor
                            : Colors.grey.shade300,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        day[0],
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.grey.shade700,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (_selectedDays.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                'Selected: ${_selectedDays.join(', ')}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                widget.medicine == null ? 'Add Medicine' : 'Save Changes',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildDateField({
    required String label,
    required DateTime? date,
    required VoidCallback onTap,
    required IconData icon,
    bool isOptional = false,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.grey.shade600),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    date != null
                        ? DateFormat('MMM dd, yyyy').format(date)
                        : isOptional ? 'Not set' : 'Select date',
                    style: TextStyle(
                      fontSize: 16,
                      color: date != null ? Colors.black : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            if (date != null && isOptional)
              IconButton(
                icon: const Icon(Icons.clear, size: 18),
                onPressed: () => setState(() => _endDate = null),
              ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}