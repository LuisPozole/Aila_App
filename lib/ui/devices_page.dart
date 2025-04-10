import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:fl_chart/fl_chart.dart';
import '../utils/constants.dart';

class DevicesPage extends StatefulWidget {
  @override
  _DevicesPageState createState() => _DevicesPageState();
}

class _DevicesPageState extends State<DevicesPage> with TickerProviderStateMixin {
  late MqttServerClient client;
  List<FlSpot> mq135Data = [];
  String dht11Temp = "No Data";
  String dht11Hum = "No Data";
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _connectToMQTT();
  }

  @override
  void dispose() {
    _animationController.dispose();
    client.disconnect();
    super.dispose();
  }

  Future<void> _connectToMQTT() async {
    client = MqttServerClient('test.mosquitto.org', 'flutter_client');
    client.port = 1883;
    client.keepAlivePeriod = 60;
    client.onConnected = _onConnected;
    client.onDisconnected = _onDisconnected;
    client.logging(on: false);

    try {
      await client.connect();
    } catch (e) {
      print('Error al conectar: $e');
      client.disconnect();
    }
  }

  void _onConnected() {
    print('Conectado a MQTT');
    client.subscribe('sensor/mq135', MqttQos.atMostOnce);
    client.subscribe('sensor/dht11tmp', MqttQos.atMostOnce);
    client.subscribe('sensor/dht11hum', MqttQos.atMostOnce);

    client.updates!.listen((List<MqttReceivedMessage<MqttMessage>>? c) {
      final MqttPublishMessage message = c![0].payload as MqttPublishMessage;
      final payload = MqttPublishPayload.bytesToStringAsString(message.payload.message);
      final topic = c[0].topic;

      setState(() {
        if (topic == 'sensor/mq135') {
          double value = double.tryParse(payload) ?? 0;
          double timestamp = DateTime.now().millisecondsSinceEpoch.toDouble();
          mq135Data.add(FlSpot(timestamp, value));
          if (mq135Data.length > 5) mq135Data.removeAt(0);
        } else if (topic == 'sensor/dht11tmp') {
          dht11Temp = payload;
        } else if (topic == 'sensor/dht11hum') {
          dht11Hum = payload;
        }
      });
    });
  }

  void _onDisconnected() {
    print('Desconectado de MQTT');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Icon(Icons.air, size: 28),
            SizedBox(width: 12),
            Text("Monitoreo Ambiental",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.8,
              )),
          ],
        ),
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.secondary],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        padding: EdgeInsets.all(20),
        child: Column(
          children: [
            _buildAirQualityChart(isDarkMode),
            SizedBox(height: 24),
            _buildLegend(),
            SizedBox(height: 24),
            _buildEnvironmentStats(),
          ],
        ),
      ),
    );
  }

  Widget _buildAirQualityChart(bool isDarkMode) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: Offset(0, 4),
          )
        ],
        gradient: LinearGradient(
          colors: isDarkMode
              ? [Colors.grey[850]!, Colors.grey[900]!]
              : [Colors.white, Color(0xFFF8F9FA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      padding: EdgeInsets.all(20),
      child: AspectRatio(
        aspectRatio: 1.6,
        child: LineChart(
          LineChartData(
            minY: 0,
            maxY: 1500,
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.2),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 40,
                  getTitlesWidget: (value, meta) => Text(
                    '${value.toInt()}',
                    style: TextStyle(
                      color: isDarkMode ? Colors.white70 : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
              bottomTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            ),
            borderData: FlBorderData(show: false),
            lineBarsData: [
              LineChartBarData(
                spots: mq135Data.isEmpty ? [FlSpot(0, 0)] : mq135Data,
                isCurved: true,
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                barWidth: 3,
                belowBarData: BarAreaData(
                  show: true,
                  gradient: LinearGradient(colors: [
                    AppColors.primary.withOpacity(0.2),
                    AppColors.secondary.withOpacity(0.2),
                  ]),
                ),
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) =>
                      FlDotCirclePainter(
                    radius: 3,
                    color: AppColors.primary,
                    strokeWidth: 2,
                    strokeColor: Colors.white,
                  ),
                ),
              ),
            ],
            lineTouchData: LineTouchData(
              touchTooltipData: LineTouchTooltipData(
                tooltipBgColor: AppColors.primary,
                getTooltipItems: (touchedSpots) {
                  return touchedSpots.map((spot) {
                    return LineTooltipItem(
                      '${spot.y.toStringAsFixed(1)} ppm\n${_formatTime(spot.x)}',
                      TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
                    );
                  }).toList();
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLegend() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildIndicator("Bueno", "0-400", Colors.green),
          SizedBox(width: 15),
          _buildIndicator("Moderado", "401-800", Colors.orange),
          SizedBox(width: 15),
          _buildIndicator("Peligroso", "801+", Colors.red),
        ],
      ),
    );
  }

  Widget _buildIndicator(String title, String value, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title,
                  style: TextStyle(
                      fontSize: 14, fontWeight: FontWeight.w600, color: color)),
              Text(value,
                  style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildEnvironmentStats() {
    return Row(
      children: [
        Expanded(
          child: _buildStatCard(
            icon: Icons.thermostat,
            title: "Temperatura",
            value: dht11Temp,
            unit: "°C",
            color: AppColors.primary,
          ),
        ),
        SizedBox(width: 16),
        Expanded(
          child: _buildStatCard(
            icon: Icons.water_drop,
            title: "Humedad",
            value: dht11Hum,
            unit: "%",
            color: AppColors.secondary,
          ),
        ),
      ],
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String title,
    required String value,
    required String unit,
    required Color color,
  }) {
    return AnimatedContainer(
      duration: Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 24, color: color),
              ),
              SizedBox(width: 12),
              Text(title,
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: color)),
            ],
          ),
          SizedBox(height: 12),
          RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.grey[800],
                height: 1.2,
              ),
              children: [
                TextSpan(text: value != "No Data" ? value : "--"),
                TextSpan(
                  text: value != "No Data" ? " $unit" : "",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.normal,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(double timestamp) {
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp.toInt());
    return '${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
