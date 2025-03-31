import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aila_/services/mongodb_service.dart';
import '../utils/constants.dart'; // Asegúrate de importar tus constantes

class AddReminderPage extends StatefulWidget {
  @override
  _AddReminderPageState createState() => _AddReminderPageState();
}

class _AddReminderPageState extends State<AddReminderPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _timeController = TextEditingController();
  final storage = FlutterSecureStorage();
  String? userId;

  DateTime? selectedDate;
  TimeOfDay? selectedTime;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    String? id = await storage.read(key: 'userId');
    setState(() {
      userId = id;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
        _dateController.text = "${picked.toLocal()}".split(' ')[0];
      });
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime ?? TimeOfDay.now(),
    );

    if (picked != null && picked != selectedTime)
      setState(() {
        selectedTime = picked;
        _timeController.text = "${picked.format(context)}";
      });
  }

  Future<void> _saveReminder() async {
    if (!_formKey.currentState!.validate() || userId == null) return;

    if (selectedDate == null || selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, selecciona una fecha y hora')),
      );
      return;
    }

    Map<String, dynamic> reminder = {
      'titulo': _titleController.text,
      'descripcion': _descriptionController.text,
      'fecha': selectedDate!.toIso8601String(),
      'hora': selectedTime!.format(context),
      'idUsuario': userId,
    };

    await MongoDBService.addReminder(reminder);

    Navigator.pop(context); // Regresar a la pantalla de recordatorios
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Añadir Recordatorio", style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.appBar,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_titleController, "Título", Icons.title),
              _buildTextField(_descriptionController, "Descripción", Icons.description),
              _buildDateField(context),
              _buildTimeField(context),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _saveReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Guardar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        validator: (value) => value!.isEmpty ? "Por favor, ingresa un $label" : null,
      ),
    );
  }

  Widget _buildDateField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _dateController,
        decoration: InputDecoration(
          labelText: "Fecha",
          prefixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
          suffixIcon: Icon(Icons.calendar_today, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        readOnly: true,
        onTap: () => _selectDate(context),
        validator: (value) => value!.isEmpty ? "Seleccione una fecha" : null,
      ),
    );
  }

  Widget _buildTimeField(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: TextFormField(
        controller: _timeController,
        decoration: InputDecoration(
          labelText: "Hora",
          prefixIcon: Icon(Icons.access_time, color: AppColors.primary),
          suffixIcon: Icon(Icons.access_time, color: AppColors.primary),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: AppColors.primary),
          ),
        ),
        readOnly: true,
        onTap: () => _selectTime(context),
        validator: (value) => value!.isEmpty ? "Seleccione una hora" : null,
      ),
    );
  }
}
