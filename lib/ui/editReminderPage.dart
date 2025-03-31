import 'package:flutter/material.dart';
import 'package:aila_/services/mongodb_service.dart';
import 'package:aila_/utils/constants.dart';

class EditReminderPage extends StatefulWidget {
  final Map<String, dynamic> reminder;

  EditReminderPage({required this.reminder});

  @override
  _EditReminderPageState createState() => _EditReminderPageState();
}

class _EditReminderPageState extends State<EditReminderPage> {
  late TextEditingController titleController;
  late TextEditingController descriptionController;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.reminder['titulo']);
    descriptionController = TextEditingController(text: widget.reminder['descripcion']);
  }

  Future<void> _confirmUpdateReminder() async {
    bool confirm = await _showConfirmationDialog(
      title: "Confirmar cambios",
      content: "¿Estás seguro de que quieres guardar los cambios?",
    );
    if (confirm) {
      await _updateReminder();
    }
  }

  Future<void> _updateReminder() async {
    widget.reminder['titulo'] = titleController.text;
    widget.reminder['descripcion'] = descriptionController.text;

    await MongoDBService.updateReminder(widget.reminder);
    _showNotification("Cambios guardados correctamente.");
    Navigator.pop(context, true); // Devuelve true para indicar éxito
  }

  Future<void> _confirmDeleteReminder() async {
    bool confirm = await _showConfirmationDialog(
      title: "Eliminar recordatorio",
      content: "¿Seguro que quieres eliminar este recordatorio? Esta acción no se puede deshacer.",
    );
    if (confirm) {
      await _deleteReminder();
    }
  }

  Future<void> _deleteReminder() async {
    await MongoDBService.deleteReminder(widget.reminder['_id']);
    _showNotification("Recordatorio eliminado correctamente.");
    Navigator.pop(context, true); // Devuelve true para indicar éxito
  }

  Future<bool> _showConfirmationDialog({required String title, required String content}) async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title, style: AppTextStyles.bigTitle),
        content: Text(content, style: AppTextStyles.bodyText),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text("Cancelar", style: TextStyle(color: AppColors.textPrimary)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text("Confirmar", style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    ) ?? false;
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: TextStyle(color: Colors.white, fontSize: 16)),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text("Editar Recordatorio", style: AppTextStyles.appBarTitle),
        backgroundColor: AppColors.appBar,
        actions: [
          IconButton(
            icon: Icon(Icons.delete, color: Colors.red),
            onPressed: _confirmDeleteReminder,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Título", style: AppTextStyles.bigTitle),
            SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              style: AppTextStyles.bodyText,
            ),
            SizedBox(height: 16),
            Text("Descripción", style: AppTextStyles.bigTitle),
            SizedBox(height: 8),
            TextField(
              controller: descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: AppColors.primary, width: 2),
                ),
              ),
              style: AppTextStyles.bodyText,
            ),
            SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                onPressed: _confirmUpdateReminder,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text("Guardar cambios", style: TextStyle(color: Colors.white, fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
