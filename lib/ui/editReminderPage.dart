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
  final double _elementSpacing = 24.0;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.reminder['titulo']);
    descriptionController = TextEditingController(text: widget.reminder['descripcion']);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInputSection(
              label: "Título del recordatorio",
              controller: titleController,
              icon: Icons.title_rounded,
            ),
            SizedBox(height: _elementSpacing),
            _buildInputSection(
              label: "Descripción",
              controller: descriptionController,
              icon: Icons.description_rounded,
              maxLines: 4,
            ),
            SizedBox(height: _elementSpacing * 1.5),
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text(
        "Editar Recordatorio",
        style: AppTextStyles.appBarTitle.copyWith(fontWeight: FontWeight.w600),
      ),
      backgroundColor: AppColors.appBar,
      elevation: 2,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(16)),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.delete_rounded, color: Colors.red[300]),
          onPressed: _confirmDeleteReminder,
          tooltip: 'Eliminar',
        ),
      ],
    );
  }

  Widget _buildInputSection({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        style: AppTextStyles.bodyText.copyWith(color: AppColors.textPrimary),
        decoration: InputDecoration(
          filled: true,
          fillColor: Colors.white,
          prefixIcon: Icon(icon, color: AppColors.primary.withOpacity(0.8)),
          floatingLabelBehavior: FloatingLabelBehavior.never,
          labelText: label,
          labelStyle: TextStyle(color: Colors.grey.shade600),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide(color: AppColors.primary, width: 1.5),
          ),
          contentPadding: EdgeInsets.symmetric(
              vertical: maxLines > 1 ? 18 : 0, horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: _confirmUpdateReminder,
            icon: Icon(Icons.save_rounded, size: 22),
            label: Text(
              "GUARDAR CAMBIOS",
              style: TextStyle(letterSpacing: 0.8, fontWeight: FontWeight.w600),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
              shadowColor: AppColors.primary.withOpacity(0.3),
            ),
          ),
        ),
      ],
    );
  }

  Future<bool> _showConfirmationDialog({required String title, required String content}) async {
    return await showDialog<bool>(
          context: context,
          builder: (context) => Dialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.warning_amber_rounded, size: 48, color: Colors.amber),
                  SizedBox(height: 16),
                  Text(title, style: AppTextStyles.bigTitle.copyWith(fontSize: 20)),
                  SizedBox(height: 12),
                  Text(content, style: AppTextStyles.bodyText.copyWith(color: Colors.grey.shade700)),
                  SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.pop(context, false),
                        child: Text("Cancelar", style: TextStyle(color: Colors.grey.shade600)),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(context, true),
                        child: Text("Confirmar"),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ) ??
        false;
  }

  void _showNotification(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 12),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        duration: Duration(seconds: 3),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: EdgeInsets.all(20),
      ),
    );
  }

  void _confirmDeleteReminder() async {
    bool confirmed = await _showConfirmationDialog(
      title: "¿Eliminar recordatorio?",
      content: "Esta acción no se puede deshacer.",
    );
    if (confirmed) {
      // Lógica para eliminar desde MongoDB aquí
      // await MongoDBService.deleteReminder(widget.reminder['_id']);
      Navigator.pop(context); // Volver a la pantalla anterior
      _showNotification("Recordatorio eliminado");
    }
  }

  void _confirmUpdateReminder() async {
    bool confirmed = await _showConfirmationDialog(
      title: "¿Guardar cambios?",
      content: "Se actualizará el recordatorio actual.",
    );
    if (confirmed) {
      // Lógica para actualizar en MongoDB aquí
      // await MongoDBService.updateReminder(widget.reminder['_id'], {
      //   'titulo': titleController.text,
      //   'descripcion': descriptionController.text,
      // });
      Navigator.pop(context); // Volver con los cambios
      _showNotification("Recordatorio actualizado");
    }
  }
}
