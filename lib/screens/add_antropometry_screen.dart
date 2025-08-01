// lib/screens/add_antropometry_screen.dart
import 'package:flutter/material.dart';
import 'package:smart_stunting_app/models/antropometry_record.dart';
import 'package:smart_stunting_app/models/child.dart';
import 'package:smart_stunting_app/services/antropometry_service.dart';
import 'package:smart_stunting_app/services/child_service.dart';
import 'package:intl/intl.dart';

class AddAntropometryScreen extends StatefulWidget {
  final int childId;

  const AddAntropometryScreen({Key? key, required this.childId})
    : super(key: key);

  @override
  State<AddAntropometryScreen> createState() => _AddAntropometryScreenState();
}

class _AddAntropometryScreenState extends State<AddAntropometryScreen> {
  final _formKey = GlobalKey<FormState>();
  final AntropometryService _antropometryService = AntropometryService();
  final ChildService _childService = ChildService();

  Child? _currentChild;
  bool _isLoadingChild = true;
  bool _isSaving = false;

  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _headCircumferenceController =
      TextEditingController();
  final TextEditingController _upperArmCircumferenceController =
      TextEditingController();

  DateTime _selectedDate = DateTime.now();

  int? _selectedVitaminACount;
  final List<int> _vitaminADoses = [0, 1, 2, 3, 4, 5];

  @override
  void initState() {
    super.initState();
    _fetchChildDetails();
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _headCircumferenceController.dispose();
    _upperArmCircumferenceController.dispose();
    super.dispose();
  }

  Future<void> _fetchChildDetails() async {
    try {
      final child = await _childService.fetchChild(widget.childId);
      setState(() {
        _currentChild = child;
        _isLoadingChild = false;
      });
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          'Gagal memuat detail anak: ${e.toString().replaceFirst('Exception: ', '')}',
          Colors.red,
        );
        setState(() {
          _isLoadingChild = false;
        });
      }
    }
  }

  int _calculateAgeInMonths(DateTime recordDate) {
    if (_currentChild == null) {
      return 0;
    }
    DateTime dob = _currentChild!.birthDate;
    int months =
        (recordDate.year - dob.year) * 12 + recordDate.month - dob.month;
    if (recordDate.day < dob.day) {
      months--;
    }
    return months < 0 ? 0 : months;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: _currentChild?.birthDate ?? DateTime(2000),
      lastDate: DateTime.now(),
      // Penambahan tema untuk date picker agar lebih cantik
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: const ColorScheme.light(
              primary: Colors.blue, // Warna header date picker
              onPrimary: Colors.white, // Warna teks header date picker
              onSurface: Colors.black87, // Warna teks di dalam kalender
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // Warna teks tombol
              ),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveAntropometry() async {
    if (!_formKey.currentState!.validate() || _currentChild == null) {
      if (_currentChild == null) {
        _showSnackBar(
          'Data anak belum dimuat. Tidak bisa menyimpan antropometri.',
          Colors.orange,
        );
      }
      return;
    }

    if (_selectedVitaminACount == null) {
      _showSnackBar('Dosis Vitamin A harus dipilih.', Colors.red);
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final double weight = double.parse(_weightController.text);
      final double height = double.parse(_heightController.text);
      final int ageInMonth = _calculateAgeInMonths(_selectedDate);

      final int? vitaminACount = _selectedVitaminACount;

      final double? headCircumference =
          _headCircumferenceController.text.isEmpty
          ? null
          : double.tryParse(_headCircumferenceController.text);
      final double? upperArmCircumference =
          _upperArmCircumferenceController.text.isEmpty
          ? null
          : double.tryParse(_upperArmCircumferenceController.text);

      final AntropometryRecord newRecord = AntropometryRecord(
        anakId: _currentChild!.id!,
        ageInMonth: ageInMonth,
        weight: weight,
        height: height,
        vitaminACount: vitaminACount,
        headCircumference: headCircumference,
        upperArmCircumference: upperArmCircumference,
      );

      AntropometryRecord createdRecord = await _antropometryService
          .createAntropometryRecord(newRecord);

      if (mounted) {
        setState(() {
          _isSaving = false;
        });

        _showSnackBar(
          'Data antropometri berhasil ditambahkan, Id pengukuran : ${createdRecord.id})',
          Colors.green,
        );

        await Future.delayed(const Duration(milliseconds: 500));
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
        String errorMessage = e.toString().replaceFirst('Exception: ', '');
        _showSnackBar('Error: $errorMessage', Colors.red);
      }
    }
  }

  // Helper function untuk menampilkan SnackBar yang lebih konsisten
  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior
            .floating, // Membuat snackbar di atas bottom navigation bar
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ), // Sudut membulat
        margin: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ), // Jarak dari tepi
      ),
    );
  }

  // Helper widget untuk input field agar kodenya lebih rapi dan konsisten
  Widget _buildFormField({
    required TextEditingController controller,
    required String labelText,
    required String suffixText,
    required String? Function(String?) validator,
    TextInputType keyboardType = const TextInputType.numberWithOptions(
      decimal: true,
    ),
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: labelText,
          suffixText: suffixText,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0), // Sudut membulat
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.blue.shade200,
              width: 1.0,
            ), // Warna border saat tidak fokus
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: const BorderSide(
              color: Colors.blue,
              width: 2.0,
            ), // Warna border saat fokus
          ),
          filled: true,
          fillColor: Colors.blue.shade50, // Latar belakang field
          contentPadding: const EdgeInsets.symmetric(
            vertical: 14.0,
            horizontal: 16.0,
          ),
        ),
        keyboardType: keyboardType,
        validator: validator,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Tambah Antropometri',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        elevation: 0, // Hapus bayangan AppBar
      ),
      body: _isLoadingChild
          ? const Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            )
          : _currentChild == null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: Colors.red,
                      size: 60,
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'Gagal memuat data anak.\nSilakan pastikan ID anak valid dan koneksi internet stabil.',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.black54),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context); // Kembali ke layar sebelumnya
                      },
                      icon: const Icon(Icons.arrow_back),
                      label: const Text('Kembali'),
                      style: ElevatedButton.styleFrom(
                        foregroundColor: Colors.white,
                        backgroundColor: Colors.redAccent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 25,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20.0), // Padding seluruh halaman
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Informasi Anak
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Detail Anak',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Divider(height: 20, thickness: 1),
                            // Menampilkan detail anak dengan ikon
                            _buildDetailRow(
                              Icons.person,
                              'Nama Anak:',
                              _currentChild!.name,
                            ),
                            _buildDetailRow(
                              Icons.cake,
                              'Tanggal Lahir:',
                              DateFormat(
                                'dd-MM-yyyy',
                              ).format(_currentChild!.birthDate),
                            ),
                            // Anda bisa menambahkan jenis kelamin, dll. jika ada di model Child Anda
                          ],
                        ),
                      ),
                    ),

                    // Form Pengukuran Antropometri
                    Card(
                      elevation: 4,
                      margin: const EdgeInsets.only(bottom: 20),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Data Pengukuran',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                            const Divider(height: 20, thickness: 1),

                            // Tanggal Pengukuran (Tampilan seperti TextFormField)
                            InkWell(
                              onTap: () => _selectDate(context),
                              child: InputDecorator(
                                decoration: InputDecoration(
                                  labelText: 'Tanggal Pengukuran',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade200,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                      width: 2.0,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.blue.shade50,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14.0,
                                    horizontal: 16.0,
                                  ),
                                  suffixIcon: const Icon(
                                    Icons.calendar_today,
                                    color: Colors.blue,
                                  ), // Ikon kalender
                                ),
                                baseStyle: const TextStyle(
                                  fontSize: 16,
                                  color: Colors.black87,
                                ),
                                child: Text(
                                  DateFormat(
                                    'dd-MM-yyyy',
                                  ).format(_selectedDate),
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            _buildFormField(
                              controller: _weightController,
                              labelText: 'Berat Badan',
                              suffixText: 'kg',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Berat badan tidak boleh kosong';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Masukkan angka yang valid (contoh: 8.5)';
                                }
                                return null;
                              },
                            ),
                            _buildFormField(
                              controller: _heightController,
                              labelText: 'Tinggi Badan',
                              suffixText: 'cm',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Tinggi badan tidak boleh kosong';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Masukkan angka yang valid (contoh: 70.0)';
                                }
                                return null;
                              },
                            ),
                            _buildFormField(
                              controller: _headCircumferenceController,
                              labelText: 'Lingkar Kepala',
                              suffixText: 'cm',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lingkar kepala tidak boleh kosong';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Masukkan angka yang valid (contoh: 43.0)';
                                }
                                return null;
                              },
                            ),
                            _buildFormField(
                              controller: _upperArmCircumferenceController,
                              labelText: 'Lingkar Lengan Atas',
                              suffixText: 'cm',
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Lingkar lengan atas tidak boleh kosong';
                                }
                                if (double.tryParse(value) == null) {
                                  return 'Masukkan angka yang valid (contoh: 12.5)';
                                }
                                return null;
                              },
                            ),

                            // Dropdown Dosis Vitamin A (dengan styling konsisten)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 16.0),
                              child: DropdownButtonFormField<int>(
                                value: _selectedVitaminACount,
                                decoration: InputDecoration(
                                  labelText: 'Dosis Vitamin A',
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: BorderSide(
                                      color: Colors.blue.shade200,
                                      width: 1.0,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.blue,
                                      width: 2.0,
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: Colors.blue.shade50,
                                  contentPadding: const EdgeInsets.symmetric(
                                    vertical: 14.0,
                                    horizontal: 16.0,
                                  ),
                                ),
                                items: _vitaminADoses.map((int dose) {
                                  return DropdownMenuItem<int>(
                                    value: dose,
                                    child: Text(
                                      '$dose kali',
                                    ), // Tampilkan "X kali"
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    _selectedVitaminACount = newValue;
                                  });
                                },
                                validator: (value) {
                                  if (value == null) {
                                    return 'Dosis Vitamin A harus dipilih.';
                                  }
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),
                    Center(
                      child: _isSaving
                          ? const CircularProgressIndicator()
                          : ElevatedButton(
                              onPressed: _saveAntropometry,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              child: const Text(
                                'Simpan Antropometri',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  // Helper widget untuk baris detail anak
  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: Colors.blue.shade700, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: const TextStyle(fontSize: 16, color: Colors.black87),
                children: [
                  TextSpan(
                    text: label,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  TextSpan(text: ' $value'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
