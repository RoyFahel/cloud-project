import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/consultation_provider.dart';
import 'package:email_validator/email_validator.dart';

class DoctorScreen extends StatefulWidget {
  const DoctorScreen({super.key});

  @override
  State<DoctorScreen> createState() => _DoctorScreenState();
}

class _DoctorScreenState extends State<DoctorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();

  String? _selectedMaladyId;
  String? _selectedMedicamentId;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    // Initialize consultation provider data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final consultationProvider =
          Provider.of<ConsultationProvider>(context, listen: false);
      consultationProvider.initialize();
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();

    super.dispose();
  }

  void _onMaladyChanged(String? maladyId) {
    if (maladyId != null) {
      setState(() {
        _selectedMaladyId = maladyId;
        _selectedMedicamentId = null;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_selectedMaladyId == null) {
      _showErrorDialog('Please select a product category');
      return;
    }

    if (_selectedMedicamentId == null) {
      _showErrorDialog('Please select a product');
      return;
    }

    setState(() {
      _isSubmitting = true;
    });

    try {
      final consultationProvider =
          Provider.of<ConsultationProvider>(context, listen: false);

      final patient = await consultationProvider.createPatient(
        firstName: _firstNameController.text.trim(),
        lastName: _lastNameController.text.trim(),
        email: _emailController.text.trim(),
      );

      if (patient == null) {
        throw Exception('Failed to create patient');
      }

      // Then create the consultation with the patient ID
      final consultationSuccess = await consultationProvider.createConsultation(
        patientId: patient.id!,
        maladyId: _selectedMaladyId!,
        medicamentId: _selectedMedicamentId!,
      );

      if (!consultationSuccess) {
        throw Exception('Failed to create consultation');
      }

      if (mounted) {
        _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Failed to save member information';

        final errorString = e.toString().toLowerCase();
        if (errorString.contains('email already exists') ||
            errorString.contains('duplicate') ||
            errorString.contains('e11000')) {
          errorMessage =
              'This email is already registered in the system. Please use a different email.';
        } else {
          errorMessage = 'Failed to save member information: ${e.toString()}';
        }

        _showErrorDialog(errorMessage);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });
      }
    }
  }

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        icon: const Icon(
          Icons.check_circle,
          color: Colors.amber,
          size: 44,
        ),
        title: const Text(
          'Success',
          style: TextStyle(color: Colors.white),
        ),
        content: const Text(
          'Member information and product assignment saved successfully!',
          style: TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.grey[900],
        icon: const Icon(
          Icons.error,
          color: Colors.red,
          size: 44,
        ),
        title: const Text(
          'Error',
          style: TextStyle(color: Colors.white),
        ),
        content: Text(message, style: const TextStyle(color: Colors.white70)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  InputDecoration _filledDecoration({required String label, IconData? prefix}) {
    return InputDecoration(
      labelText: label,
      prefixIcon: prefix != null ? Icon(prefix, color: Colors.grey) : null,
      filled: true,
      fillColor: Colors.grey[900],
      border: const OutlineInputBorder(),
      labelStyle: const TextStyle(color: Colors.amber),
    );
  }

  @override
  Widget build(BuildContext context) {
    // theme colors aligned with AdminScreen black & yellow
    final accent = Colors.amber;
    final surface = Colors.black;
    final cardSurface = Colors.grey[900];
    final onSurface = Colors.white;

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        title: const Text(
          'Trainer Portal',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Card(
                  color: cardSurface,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        Icon(
                          Icons.fitness_center,
                          size: 48,
                          color: accent,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Add New Member',
                          style: Theme.of(context)
                              .textTheme
                              .headlineSmall
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: onSurface,
                              ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Enter member information below',
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: Colors.grey[400],
                                  ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                Card(
                  color: cardSurface,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Member Information',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: onSurface),
                        ),
                        const SizedBox(height: 20),
                        // First name
                        TextFormField(
                          controller: _firstNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _filledDecoration(
                              label: 'First Name', prefix: Icons.person),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter first name';
                            }
                            if (value.trim().length < 3) {
                              return 'First name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Last name
                        TextFormField(
                          controller: _lastNameController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _filledDecoration(
                              label: 'Last Name', prefix: Icons.person_outline),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter last name';
                            }
                            if (value.trim().length < 3) {
                              return 'Last name must be at least 3 characters';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),

                        // Email
                        TextFormField(
                          controller: _emailController,
                          style: const TextStyle(color: Colors.white),
                          decoration: _filledDecoration(
                              label: 'Email Address', prefix: Icons.email),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter email address';
                            }

                            if (!EmailValidator.validate(value)) {
                              return 'Please enter a valid email address';
                            }
                            return null;
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // Product Information (was Medical Information)
                Card(
                  color: cardSurface,
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Product Information',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge
                              ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: onSurface),
                        ),
                        const SizedBox(height: 20),

                        // Product Category Dropdown (was Type of Illness)
                        Consumer<ConsultationProvider>(
                          builder: (context, consultationProvider, child) {
                            return DropdownButtonFormField<String>(
                              value: _selectedMaladyId,
                              dropdownColor: Colors.grey[850],
                              decoration: InputDecoration(
                                labelText: 'Product Category',
                                prefixIcon: const Icon(Icons.category,
                                    color: Colors.grey),
                                labelStyle:
                                    const TextStyle(color: Colors.amber),
                                filled: true,
                                fillColor: Colors.grey[900],
                                border: const OutlineInputBorder(),
                              ),
                              items:
                                  consultationProvider.maladies.map((malady) {
                                return DropdownMenuItem<String>(
                                  value: malady.id,
                                  child: Text(malady.maladyName,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: _onMaladyChanged,
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a product category';
                                }
                                return null;
                              },
                            );
                          },
                        ),

                        const SizedBox(height: 16),

                        // Product Dropdown (was Prescribed Medication)
                        Consumer<ConsultationProvider>(
                          builder: (context, consultationProvider, child) {
                            return DropdownButtonFormField<String>(
                              value: _selectedMedicamentId,
                              dropdownColor: Colors.grey[850],
                              decoration: InputDecoration(
                                labelText: 'Product',
                                prefixIcon: const Icon(Icons.inventory_2,
                                    color: Colors.grey),
                                labelStyle:
                                    const TextStyle(color: Colors.amber),
                                filled: true,
                                fillColor: Colors.grey[900],
                                border: const OutlineInputBorder(),
                              ),
                              items: consultationProvider
                                  .getMedicamentsForMalady(
                                      _selectedMaladyId ?? '')
                                  .map((medicament) {
                                return DropdownMenuItem<String>(
                                  value: medicament.id,
                                  child: Text(medicament.medicamentName,
                                      style:
                                          const TextStyle(color: Colors.white)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                if (value != null) {
                                  setState(() {
                                    _selectedMedicamentId = value;
                                  });
                                }
                              },
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Please select a product';
                                }
                                return null;
                              },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 32),

                // Submit Button
                ElevatedButton(
                  onPressed: _isSubmitting ? null : _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accent,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isSubmitting
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('Adding Member...'),
                          ],
                        )
                      : const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add),
                            SizedBox(width: 8),
                            Text('Add Member'),
                          ],
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
