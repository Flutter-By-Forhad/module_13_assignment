import 'package:flutter/material.dart';

class BMICalculatorScreen extends StatefulWidget {
  const BMICalculatorScreen({super.key});

  @override
  State<BMICalculatorScreen> createState() => _BMICalculatorScreenState();
}

class _BMICalculatorScreenState extends State<BMICalculatorScreen> {
  // Controllers for input fields
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightMetricController = TextEditingController();
  final TextEditingController _feetController = TextEditingController();
  final TextEditingController _inchController = TextEditingController();

  // Unit selections
  String _weightUnit = 'kg'; // Default to kg
  String _heightUnit = 'cm'; // Default to cm (options: m, cm, ft_in)

  // Result variables
  double? _bmi;
  String _category = '';
  Color _categoryColor = Colors.grey;

  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _weightController.dispose();
    _heightMetricController.dispose();
    _feetController.dispose();
    _inchController.dispose();
    super.dispose();
  }

  // Function to calculate BMI
  void _calculateBMI() {
    if (_formKey.currentState?.validate() ?? false) {
      double weightKg = _parseWeight();
      double heightM = _parseHeight();

      if (weightKg > 0 && heightM > 0) {
        double bmi = weightKg / (heightM * heightM);
        setState(() {
          _bmi = bmi;
          _updateCategory(bmi);
        });
      } else {
        _showSnackBar('Please enter valid positive values.');
      }
    }
  }

  // Parse weight based on unit
  double _parseWeight() {
    double weight = double.tryParse(_weightController.text) ?? 0;
    if (_weightUnit == 'lb') {
      weight *= 0.45359237; // Convert lb to kg
    }
    return weight;
  }

  // Parse height based on unit
  double _parseHeight() {
    double heightM = 0;
    if (_heightUnit == 'm') {
      heightM = double.tryParse(_heightMetricController.text) ?? 0;
    } else if (_heightUnit == 'cm') {
      double heightCm = double.tryParse(_heightMetricController.text) ?? 0;
      heightM = heightCm / 100;
    } else if (_heightUnit == 'ft_in') {
      double feet = double.tryParse(_feetController.text) ?? 0;
      double inches = double.tryParse(_inchController.text) ?? 0;

      // Nice UX: Carry over inches to feet if >=12
      if (inches >= 12) {
        feet += (inches / 12).floorToDouble();
        inches %= 12;
        // Update fields
        _feetController.text = feet.toStringAsFixed(0);
        _inchController.text = inches.toStringAsFixed(1);
      }

      heightM = (feet * 12 + inches) * 0.0254;
    }
    return heightM;
  }

  // Update category and color based on BMI
  void _updateCategory(double bmi) {
    if (bmi < 18.5) {
      _category = 'Underweight';
      _categoryColor = Colors.blue;
    } else if (bmi >= 18.5 && bmi < 25.0) {
      _category = 'Normal';
      _categoryColor = Colors.green;
    } else if (bmi >= 25.0 && bmi < 30.0) {
      _category = 'Overweight';
      _categoryColor = Colors.orange;
    } else {
      _category = 'Obese';
      _categoryColor = Colors.red;
    }
  }

  // Show SnackBar for errors
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Validator for positive double
  String? _validatePositiveDouble(String? value) {
    if (value == null || value.isEmpty) {
      return 'This field is required';
    }
    final num = double.tryParse(value);
    if (num == null || num <= 0) {
      return 'Enter a positive number';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BMI Calculator'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Weight Section
              const Text('Weight:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'kg', label: Text('kg')),
                  ButtonSegment(value: 'lb', label: Text('lb')),
                ],
                selected: {_weightUnit},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _weightUnit = newSelection.first;
                  });
                },
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _weightController,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  labelText: 'Enter weight ($_weightUnit)',
                  border: const OutlineInputBorder(),
                ),
                validator: _validatePositiveDouble,
              ),
              const SizedBox(height: 24),

              // Height Section
              const Text('Height:', style: TextStyle(fontSize: 18)),
              const SizedBox(height: 8),
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'm', label: Text('m')),
                  ButtonSegment(value: 'cm', label: Text('cm')),
                  ButtonSegment(value: 'ft_in', label: Text('ft + in')),
                ],
                selected: {_heightUnit},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() {
                    _heightUnit = newSelection.first;
                    // Clear fields when unit changes
                    _heightMetricController.clear();
                    _feetController.clear();
                    _inchController.clear();
                  });
                },
              ),
              const SizedBox(height: 8),
              if (_heightUnit == 'm' || _heightUnit == 'cm')
                TextFormField(
                  controller: _heightMetricController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: 'Enter height ($_heightUnit)',
                    border: const OutlineInputBorder(),
                  ),
                  validator: _validatePositiveDouble,
                )
              else
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _feetController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Feet',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validatePositiveDouble,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _inchController,
                        keyboardType: const TextInputType.numberWithOptions(decimal: true),
                        decoration: const InputDecoration(
                          labelText: 'Inches',
                          border: OutlineInputBorder(),
                        ),
                        validator: _validatePositiveDouble,
                      ),
                    ),
                  ],
                ),
              const SizedBox(height: 32),

              // Calculate Button
              ElevatedButton(
                onPressed: _calculateBMI,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Calculate BMI'),
              ),
              const SizedBox(height: 24),

              // Result Card
              if (_bmi != null)
                Card(
                  color: _categoryColor.withOpacity(0.1),
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'BMI: ${_bmi!.toStringAsFixed(1)}',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Chip(
                          label: Text(_category),
                          backgroundColor: _categoryColor,
                          labelStyle: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}