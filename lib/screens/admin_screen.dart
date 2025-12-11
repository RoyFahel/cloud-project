import "package:flutter/material.dart";
import 'package:provider/provider.dart';
import '../providers/consultation_provider.dart';

class Consultation {
  final String id;
  final String firstName;
  final String lastName;
  final String email;
  String maladyName;
  List<String> medicaments;
  bool isDeleted;

  Consultation({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.maladyName,
    required this.medicaments,
    this.isDeleted = false,
  });
}

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ConsultationProvider>();
      provider.loadMaladies();
      provider.loadMedicaments();
      provider.loadConsultations();
    });
  }

  Future<void> _showIllnessDialog({Consultation? existing}) async {
    final provider = context.read<ConsultationProvider>();
    final formKey = GlobalKey<FormState>();

    // For adding new category (malady)
    final maladyNameController = TextEditingController();

    // For adding new Product item (medicament)
    final medicamentNameController = TextEditingController();

    String? selectedMaladyId;

    // For editing existing
    final illnessController = TextEditingController(text: existing?.maladyName ?? "");
    final List<TextEditingController> medicamentControllers = [];

    if (existing != null && existing.medicaments.isNotEmpty) {
      for (final med in existing.medicaments) {
        medicamentControllers.add(TextEditingController(text: med));
      }
    } else {
      medicamentControllers.add(TextEditingController());
    }

    final accent = Colors.amber;
    final surface = Colors.grey[900];
    final onSurface = Colors.white;

    await showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: surface,
              title: Text(
                existing == null ? "Add Category & Product" : "Edit Category",
                style: TextStyle(color: onSurface, fontWeight: FontWeight.bold),
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: MediaQuery.of(context).size.width * 0.8,
                  child: Form(
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (existing == null) ...[
                          // Add new Category section
                          Text(
                            "Add New Product Category",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: maladyNameController,
                            style: TextStyle(color: onSurface),
                            decoration: InputDecoration(
                              labelText: "Category Name",
                              labelStyle: TextStyle(color: accent),
                              border: const OutlineInputBorder(),
                              hintText: "e.g., Creatine, Protein, Accessories",
                              hintStyle: TextStyle(color: Colors.grey[400]),
                              filled: true,
                              fillColor: Colors.grey[850],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () async {
                                    if (maladyNameController.text.trim().isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Please fill in category name'),
                                          backgroundColor: Colors.orange,
                                        ),
                                      );
                                      return;
                                    }

                                    final success = await provider.createMalady(
                                      maladyName: maladyNameController.text.trim(),
                                    );

                                    if (success) {
                                      maladyNameController.clear();
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Category added to database!'),
                                          backgroundColor: Colors.green,
                                        ),
                                      );
                                      setStateDialog(() {});
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text('Failed to add category'),
                                          backgroundColor: Colors.red,
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.add, color: Colors.black),
                                  label: const Text('Add Category'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: accent,
                                    foregroundColor: Colors.black,
                                    padding: const EdgeInsets.symmetric(vertical: 14),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          const Divider(),
                          const SizedBox(height: 12),

                          // Add newproduct section
                          Text(
                            "Add New Product",
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: onSurface),
                          ),
                          const SizedBox(height: 8),
                          if (provider.maladies.isEmpty)
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                'Add a category first before adding products.',
                                style: TextStyle(color: Colors.orange[300]),
                              ),
                            )
                          else ...[
                            DropdownButtonFormField<String>(
                              dropdownColor: surface,
                              value: selectedMaladyId ?? provider.maladies.first.id,
                              decoration: InputDecoration(
                                labelText: 'Related Category',
                                labelStyle: TextStyle(color: accent),
                                border: const OutlineInputBorder(),
                                filled: true,
                                fillColor: Colors.grey[850],
                              ),
                              items: provider.maladies.map((malady) {
                                return DropdownMenuItem(
                                  value: malady.id,
                                  child: Text(malady.maladyName, style: TextStyle(color: onSurface)),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setStateDialog(() {
                                  selectedMaladyId = value;
                                });
                              },
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              controller: medicamentNameController,
                              style: TextStyle(color: onSurface),
                              decoration: InputDecoration(
                                labelText: "Product Name",
                                labelStyle: TextStyle(color: accent),
                                border: const OutlineInputBorder(),
                                hintText: "e.g., Nutrex Creatine Monohydrate",
                                hintStyle: TextStyle(color: Colors.grey[400]),
                                filled: true,
                                fillColor: Colors.grey[850],
                              ),
                            ),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () async {
                                if (medicamentNameController.text.trim().isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Please fill in Product name'),
                                      backgroundColor: Colors.orange,
                                    ),
                                  );
                                  return;
                                }

                                final success = await provider.createMedicament(
                                  medicamentName: medicamentNameController.text.trim(),
                                  maladyId: (selectedMaladyId ?? provider.maladies.first.id)!,
                                );

                                if (success) {
                                  medicamentNameController.clear();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Product added to database!'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                  setStateDialog(() {});
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Failed to add product'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                }
                              },
                              icon: const Icon(Icons.add, color: Colors.black),
                              label: const Text('Add Product'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: accent,
                                foregroundColor: Colors.black,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ],
                        ] else ...[
                          // Edit existing consultation (edit category + product fields)
                          TextFormField(
                            controller: illnessController,
                            style: TextStyle(color: onSurface),
                            decoration: InputDecoration(
                              labelText: "Category",
                              labelStyle: TextStyle(color: accent),
                              border: const OutlineInputBorder(),
                              filled: true,
                              fillColor: Colors.grey[850],
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return "Please enter a category name";
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 12),
                          Column(
                            children: List.generate(
                              medicamentControllers.length,
                              (index) => Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: TextFormField(
                                  controller: medicamentControllers[index],
                                  style: TextStyle(color: onSurface),
                                  decoration: InputDecoration(
                                    labelText: "Product ${index + 1}",
                                    labelStyle: TextStyle(color: accent),
                                    border: const OutlineInputBorder(),
                                    filled: true,
                                    fillColor: Colors.grey[850],
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return "Please enter a product name";
                                    }
                                    return null;
                                  },
                                ),
                              ),
                            ),
                          ),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: TextButton.icon(
                              onPressed: () {
                                setStateDialog(() {
                                  medicamentControllers.add(TextEditingController());
                                });
                              },
                              icon: const Icon(Icons.add, color: Colors.amber),
                              label: Text("Add new field", style: TextStyle(color: onSurface)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(),
                  child: const Text("Close"),
                ),
                if (existing != null)
                  ElevatedButton(
                    onPressed: () {
                      if (!formKey.currentState!.validate()) return;

                      final illness = illnessController.text.trim();
                      final meds = medicamentControllers
                          .map((c) => c.text.trim())
                          .where((m) => m.isNotEmpty)
                          .toList();

                      setState(() {
                        existing.maladyName = illness;
                        existing.medicaments = meds;
                      });

                      Navigator.of(ctx).pop();
                    },
                    child: const Text("Update"),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final accent = Colors.amber;
    final surface = Colors.black;
    final cardSurface = Colors.grey[900];
    final onSurface = Colors.white;

    return Scaffold(
      backgroundColor: surface,
      appBar: AppBar(
        title: const Text("Manager Portal"),
        backgroundColor: surface,
        foregroundColor: onSurface,
        elevation: 0,
        actions: [
          TextButton.icon(
            onPressed: () => _showIllnessDialog(),
            icon: Icon(Icons.add, color: accent),
            label: Text(
              "Add to Catalog",
              style: TextStyle(color: accent, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
      body: Consumer<ConsultationProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // On small widths stack columns vertically, otherwise keep grid-like layout.
          final isNarrow = MediaQuery.of(context).size.width < 900;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: isNarrow
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildCategoriesCard(provider, cardSurface!, accent, onSurface),
                      const SizedBox(height: 12),
                      _buildProductsCard(provider, cardSurface, accent, onSurface),
                      const SizedBox(height: 12),
                      _buildSessionsCard(provider, cardSurface, accent, onSurface, flex: 0),
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Left column: categories + products stacked
                      Expanded(
                        child: Column(
                          children: [
                            _buildCategoriesCard(provider, cardSurface!, accent, onSurface),
                            const SizedBox(height: 12),
                            _buildProductsCard(provider, cardSurface, accent, onSurface),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Right: sessions table
                      Expanded(
                        flex: 3,
                        child: _buildSessionsCard(provider, cardSurface, accent, onSurface),
                      ),
                    ],
                  ),
          );
        },
      ),
    );
  }

  Widget _buildCategoriesCard(ConsultationProvider provider, Color cardSurface, Color accent, Color onSurface) {
    return Card(
      color: cardSurface,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with title and count
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.category, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    "Product Categories",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface),
                  ),
                ]),
                Text(
                  "${provider.maladies.length} items",
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: provider.maladies.isEmpty
                  ? Center(
                      child: Text(
                        "No categories added yet.\nClick 'Add to Catalog' to add.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : ListView.separated(
                      itemCount: provider.maladies.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.grey),
                      itemBuilder: (context, index) {
                        final malady = provider.maladies[index];
                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[800],
                            child: Icon(Icons.category, color: accent),
                          ),
                          title: Text(malady.maladyName, style: TextStyle(color: onSurface)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: Colors.grey[900],
                                  title: Text("Delete Category", style: TextStyle(color: onSurface)),
                                  content: Text(
                                    "Delete '${malady.maladyName}'?\n\nThis will also delete all related Product items.",
                                    style: TextStyle(color: Colors.grey[300]),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && malady.id != null) {
                                final success = await provider.deleteMalady(malady.id!);
                                if (success && mounted) {
                                  // Reload medicaments to remove those related to deleted malady
                                  await provider.loadMedicaments();
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Category deleted successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductsCard(ConsultationProvider provider, Color cardSurface, Color accent, Color onSurface) {
    return Card(
      color: cardSurface,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.inventory_2, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    "Product Items",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface),
                  ),
                ]),
                Text(
                  "${provider.medicaments.length} items",
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            SizedBox(
              height: 220,
              child: provider.medicaments.isEmpty
                  ? Center(
                      child: Text(
                        "No products added yet.\nClick 'Add to Catalog' to add.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : ListView.separated(
                      itemCount: provider.medicaments.length,
                      separatorBuilder: (_, __) => const Divider(color: Colors.grey),
                      itemBuilder: (context, index) {
                        final medicament = provider.medicaments[index];

                        // Find the category name, handle case where category might not exist
                        String maladyName = 'Unknown';
                        try {
                          final malady = provider.maladies.firstWhere((m) => m.id == medicament.maladyId);
                          maladyName = malady.maladyName;
                        } catch (e) {
                          // ignore
                        }

                        return ListTile(
                          contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                          leading: CircleAvatar(
                            backgroundColor: Colors.grey[800],
                            child: Icon(Icons.fitness_center, color: accent),
                          ),
                          title: Text(medicament.medicamentName, style: TextStyle(color: onSurface)),
                          subtitle: Text('Category: $maladyName', style: TextStyle(color: Colors.grey[400], fontSize: 12)),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              final confirmed = await showDialog<bool>(
                                context: context,
                                builder: (ctx) => AlertDialog(
                                  backgroundColor: Colors.grey[900],
                                  title: Text("Delete Product", style: TextStyle(color: onSurface)),
                                  content: Text(
                                    "Delete '${medicament.medicamentName}'?",
                                    style: TextStyle(color: Colors.grey[300]),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(ctx).pop(false),
                                      child: const Text("Cancel"),
                                    ),
                                    ElevatedButton(
                                      style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                      onPressed: () => Navigator.of(ctx).pop(true),
                                      child: const Text("Delete"),
                                    ),
                                  ],
                                ),
                              );

                              if (confirmed == true && medicament.id != null) {
                                final success = await provider.deleteMedicament(medicament.id!);
                                if (success && mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Product deleted successfully'),
                                      backgroundColor: Colors.green,
                                    ),
                                  );
                                }
                              }
                            },
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSessionsCard(ConsultationProvider provider, Color cardSurface, Color accent, Color onSurface, {int flex = 3}) {
    return Card(
      color: cardSurface,
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Icon(Icons.calendar_today, color: accent),
                  const SizedBox(width: 8),
                  Text(
                    "Sessions",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: onSurface),
                  ),
                ]),
                Text(
                  "${provider.consultations.length} records",
                  style: TextStyle(color: Colors.grey[400], fontSize: 13),
                ),
              ],
            ),
            const Divider(color: Colors.grey),
            const SizedBox(height: 8),
            Expanded(
              child: provider.consultations.isEmpty
                  ? Center(
                      child: Text(
                        "No sessions recorded yet.",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                    )
                  : SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: SingleChildScrollView(
                        child: DataTable(
                          headingRowColor: MaterialStateProperty.all(Colors.grey[850]),
                          dataRowColor: MaterialStateProperty.resolveWith((states) => Colors.grey[900]),
                          columnSpacing: 24,
                          columns: const [
                            DataColumn(
                              label: Text(
                                'Date',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Member',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Email',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Category',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                            DataColumn(
                              label: Text(
                                'Product',
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
                              ),
                            ),
                          ],
                          rows: provider.consultations.map((consultation) {
                            // Get patient info
                            String patientName = 'Unknown';
                            String patientEmail = '';
                            if (consultation.patient != null) {
                              patientName = '${consultation.patient!['firstName']} ${consultation.patient!['lastName']}';
                              patientEmail = consultation.patient!['email'] ?? '';
                            }

                            // Get category name
                            String maladyName = 'Unknown';
                            if (consultation.malady != null) {
                              maladyName = consultation.malady!['maladyName'];
                            }

                            // Get Product name
                            String medicamentName = 'Unknown';
                            if (consultation.medicament != null) {
                              medicamentName = consultation.medicament!['medicamentName'];
                            }

                            return DataRow(
                              cells: [
                                DataCell(
                                  Text(
                                    '${consultation.date.day}/${consultation.date.month}/${consultation.date.year}',
                                    style: const TextStyle(color: Colors.white70),
                                  ),
                                ),
                                DataCell(
                                  Text(
                                    patientName,
                                    style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.white),
                                  ),
                                ),
                                DataCell(Text(patientEmail, style: const TextStyle(color: Colors.white70))),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.amber.shade800.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      maladyName,
                                      style: TextStyle(
                                        color: Colors.amber.shade200,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                                DataCell(
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.grey[800],
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      medicamentName,
                                      style: TextStyle(
                                        color: Colors.grey[200],
                                        fontSize: 12,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            );
                          }).toList(),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
