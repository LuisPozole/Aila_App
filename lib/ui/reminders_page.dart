import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:aila_/services/mongodb_service.dart';
import 'package:aila_/ui/add_reminder_page.dart';
import 'package:aila_/ui/editReminderPage.dart';
import 'package:aila_/utils/constants.dart';

class RemindersPage extends StatefulWidget {
  @override
  _RemindersPageState createState() => _RemindersPageState();
}

class _RemindersPageState extends State<RemindersPage> {
  final storage = FlutterSecureStorage();
  String? userId;
  List<Map<String, dynamic>> reminders = [];

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    String? id = await storage.read(key: 'userId');
    if (id != null) {
      setState(() {
        userId = id;
      });
      _fetchReminders();
    }
  }

  Future<void> _fetchReminders() async {
    if (userId == null) return;
    try {
      List<Map<String, dynamic>> data =
          await MongoDBService.getReminders(userId!);
      setState(() {
        reminders = data;
      });
    } catch (e) {
      print("Error al obtener recordatorios: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Hola!",
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                )),
            Text("Tus Recordatorios",
                style: AppTextStyles.appBarTitle.copyWith(
                  fontSize: 24,
                  color: AppColors.primary,
                  fontWeight: FontWeight.w800,
                )),
          ],
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.primary),
        toolbarHeight: 80,
      ),
      body: userId == null
          ? _buildLoadingShimmer()
          : reminders.isEmpty
              ? _noRemindersWidget(context)
              : RefreshIndicator(
                  onRefresh: _fetchReminders,
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.separated(
                          padding: EdgeInsets.only(top: 20, bottom: 100),
                          itemCount: reminders.length,
                          separatorBuilder: (context, index) =>
                              SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            var reminder = reminders[index];
                            return _buildReminderCard(reminder, context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
      floatingActionButton: _buildAddButton(context),
    );
  }

  Widget _buildReminderCard(
      Map<String, dynamic> reminder, BuildContext context) {
    return TweenAnimationBuilder(
      tween: Tween<double>(begin: 0, end: 1),
      duration: Duration(milliseconds: 300),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Container(
        margin: EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.primary.withOpacity(0.1),
              blurRadius: 12,
              offset: Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Container(
                width: 6,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    bottomLeft: Radius.circular(20),
                  ),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          reminder['titulo'] ?? 'Sin título',
                          style: AppTextStyles.bigTitle.copyWith(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                            color: AppColors.primary,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(Icons.edit_outlined, size: 22),
                        color: AppColors.textSecondary,
                        onPressed: () => _navigateToEdit(reminder, context),
                      ),
                    ],
                  ),
                  SizedBox(height: 12),
                  _buildDetailRow(Icons.description,
                      reminder['descripcion'] ?? 'Sin descripción'),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      _buildDetailChip(
                          Icons.calendar_today, reminder['fecha'] ?? ''),
                      SizedBox(width: 12),
                      _buildDetailChip(
                          Icons.access_time, reminder['hora'] ?? ''),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: AppTextStyles.bodyText.copyWith(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDetailChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.primary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: AppColors.primary),
          SizedBox(width: 6),
          Text(
            text,
            style: AppTextStyles.bodyText.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _noRemindersWidget(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(20),
      child: Stack(
        children: [
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Opacity(
                opacity: 0.1,
                child: Image.asset('assets/mascota3.png', height: 250),
              ),
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.1),
                      blurRadius: 12,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: Icon(Icons.notifications_off,
                    size: 40, color: AppColors.primary),
              ),
              SizedBox(height: 30),
              Text(
                "No hay recordatorios",
                style: AppTextStyles.bigTitle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.primary,
                ),
              ),
              SizedBox(height: 15),
              Text(
                "Presiona el botón para agregar tu primer recordatorio",
                textAlign: TextAlign.center,
                style: AppTextStyles.bodyText.copyWith(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 30),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAddButton(BuildContext context) {
    return FloatingActionButton.extended(
      onPressed: () => _navigateToAdd(context),
      icon: Icon(Icons.add, color: Colors.white),
      label: Text("Nuevo recordatorio",
          style:
              TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
      backgroundColor: AppColors.primary,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      heroTag: 'addReminder',
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: EdgeInsets.all(20),
      itemCount: 4,
      itemBuilder: (context, index) {
        return Container(
          margin: EdgeInsets.only(bottom: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black12,
                blurRadius: 8,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: CustomShimmer(
            linearGradient: LinearGradient(
              colors: [
                AppColors.background,
                AppColors.primary.withOpacity(0.05),
                AppColors.background,
              ],
              stops: [0.1, 0.5, 0.9],
            ),
            child: Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        );
      },
    );
  }

  void _navigateToEdit(Map<String, dynamic> reminder, BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditReminderPage(reminder: reminder),
      ),
    ).then((result) {
      if (result == true) _fetchReminders();
    });
  }

  void _navigateToAdd(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddReminderPage()),
    ).then((result) {
      if (result == true) _fetchReminders();
    });
  }
}

// Renombrada para evitar conflictos con la librería shimmer oficial
class CustomShimmer extends StatefulWidget {
  final Widget child;
  final LinearGradient linearGradient;

  const CustomShimmer({
    required this.child,
    required this.linearGradient,
  });

  @override
  _CustomShimmerState createState() => _CustomShimmerState();
}

class _CustomShimmerState extends State<CustomShimmer>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: Duration(seconds: 1),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return widget.linearGradient.createShader(
              Rect.fromLTWH(
                -bounds.width * _controller.value,
                0,
                bounds.width * 2,
                bounds.height,
              ),
            );
          },
          child: widget.child,
        );
      },
    );
  }
}
