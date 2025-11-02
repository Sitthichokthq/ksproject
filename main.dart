import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz;
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:ui';
import 'package:in_app_update/in_app_update.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart';
import 'neptune_theme.dart' as neptune_theme;
import 'neptune_ui.dart' as neptune_ui;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

// Global notification instance
final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
    FlutterLocalNotificationsPlugin();

// เพิ่ม ThemeModeNotifier สำหรับจัดการโหมดแสง
class ThemeModeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ThemeMode get themeMode => _themeMode;

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('themeMode', mode.index);
  }

  Future<void> loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final idx = prefs.getInt('themeMode');
    if (idx != null && idx >= 0 && idx <= 2) {
      _themeMode = ThemeMode.values[idx];
      notifyListeners();
    }
  }
}

// เพิ่ม ChangeNotifierProvider
class ChangeNotifierProvider<T extends ChangeNotifier> extends InheritedNotifier<T> {
  const ChangeNotifierProvider({Key? key, required T create, required Widget child})
      : super(key: key, notifier: create, child: child);

  static T of<T extends ChangeNotifier>(BuildContext context) {
    final provider = context.dependOnInheritedWidgetOfExactType<ChangeNotifierProvider<T>>();
    return provider!.notifier!;
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await _initializeNotifications();
  final themeNotifier = ThemeModeNotifier();
  await themeNotifier.loadThemeMode();
  runApp(
    ChangeNotifierProvider<ThemeModeNotifier>(
      create: themeNotifier,
      child: const MyApp(),
    ),
  );
}

Future<void> _initializeNotifications() async {
  // Initialize timezone
  tz.initializeTimeZones();
  
  // Android settings
  const AndroidInitializationSettings initializationSettingsAndroid =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  // iOS settings
  const DarwinInitializationSettings initializationSettingsIOS =
      DarwinInitializationSettings(
    requestAlertPermission: true,
    requestBadgePermission: true,
    requestSoundPermission: true,
  );

  const InitializationSettings initializationSettings = InitializationSettings(
    android: initializationSettingsAndroid,
    iOS: initializationSettingsIOS,
  );

  await flutterLocalNotificationsPlugin.initialize(
    initializationSettings,
    onDidReceiveNotificationResponse: (NotificationResponse response) {
      // Handle notification tap
      print('Notification tapped: ${response.payload}');
    },
  );
}

Future<void> _requestNotificationPermissions() async {
  // Request notification permissions for Android 13+
  if (await Permission.notification.isDenied) {
    await Permission.notification.request();
  }
}

Future<void> _scheduleNotification({
  required String title,
  required String body,
  required DateTime scheduledDate,
  String? payload,
}) async {
  const AndroidNotificationDetails androidPlatformChannelSpecifics =
      AndroidNotificationDetails(
    'water_quality_scheduled_channel',
    'Scheduled Water Quality Alerts',
    channelDescription: 'Scheduled notifications for water quality monitoring',
    importance: Importance.high,
    priority: Priority.high,
    showWhen: true,
    enableVibration: true,
    playSound: true,
  );

  const DarwinNotificationDetails iOSPlatformChannelSpecifics =
      DarwinNotificationDetails(
    presentAlert: true,
    presentBadge: true,
    presentSound: true,
  );

  const NotificationDetails platformChannelSpecifics = NotificationDetails(
    android: androidPlatformChannelSpecifics,
    iOS: iOSPlatformChannelSpecifics,
  );

  await flutterLocalNotificationsPlugin.zonedSchedule(
    1,
    title,
    body,
    tz.TZDateTime.from(scheduledDate, tz.local),
    platformChannelSpecifics,
    androidAllowWhileIdle: true,
    uiLocalNotificationDateInterpretation:
        UILocalNotificationDateInterpretation.absoluteTime,
    payload: payload,
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeNotifier = ChangeNotifierProvider.of<ThemeModeNotifier>(context);
    return MaterialApp(
      title: 'Water Quality Monitor',
      theme: _buildLightTheme(),
      darkTheme: _buildDarkTheme(),
      themeMode: themeNotifier.themeMode,
      home: const WaterQualityPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

ThemeData _buildLightTheme() {
  return neptune_theme.NeptuneTheme.lightTheme;
}

ThemeData _buildDarkTheme() {
  return ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00BFFF),
      brightness: Brightness.dark,
      primary: const Color(0xFF00BFFF),
      secondary: const Color(0xFF2196F3),
      tertiary: const Color(0xFF03A9F4),
      surface: const Color(0xFF181F25),
      background: const Color(0xFF10151A),
      onBackground: Colors.white,
      onSurface: Colors.white,
    ),
    scaffoldBackgroundColor: const Color(0xFF10151A),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF181F25),
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      titleTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 24,
        letterSpacing: 0.2,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      color: const Color(0xFF181F25), // สีเข้มสำหรับ dark mode
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      shadowColor: const Color(0x2200BFFF),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: const Color(0xFF181F25),
      elevation: 12,
      selectedItemColor: const Color(0xFF00BFFF),
      unselectedItemColor: Colors.white,
      selectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
      unselectedLabelStyle: GoogleFonts.inter(fontWeight: FontWeight.w500, fontSize: 13, color: Colors.white),
      type: BottomNavigationBarType.fixed,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF181F25),
      indicatorColor: const Color(0xFF00BFFF).withOpacity(0.13),
      labelTextStyle: MaterialStateProperty.all(GoogleFonts.inter(color: Colors.white)),
      iconTheme: MaterialStateProperty.all(const IconThemeData(color: Colors.white)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF00BFFF),
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
      elevation: 8,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0x2200BFFF),
      labelStyle: GoogleFonts.inter(fontWeight: FontWeight.w600, fontSize: 14, color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      selectedColor: const Color(0x3300BFFF),
      secondarySelectedColor: const Color(0x4400BFFF),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: const Color(0xFF181F25),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titleTextStyle: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 20, color: const Color(0xFF00BFFF)),
      contentTextStyle: GoogleFonts.inter(fontSize: 16, color: Colors.white),
    ),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme.copyWith(
        headlineLarge: GoogleFonts.inter(color: Colors.white),
        headlineMedium: GoogleFonts.inter(color: Colors.white),
        headlineSmall: GoogleFonts.inter(color: Colors.white),
        titleLarge: GoogleFonts.inter(color: Colors.white),
        titleMedium: GoogleFonts.inter(color: Colors.white),
        titleSmall: GoogleFonts.inter(color: Colors.white),
        bodyLarge: GoogleFonts.inter(color: Colors.white),
        bodyMedium: GoogleFonts.inter(color: Colors.white70),
        bodySmall: GoogleFonts.inter(color: Colors.white60),
        labelLarge: GoogleFonts.inter(color: Colors.white),
        labelMedium: GoogleFonts.inter(color: Colors.white),
        labelSmall: GoogleFonts.inter(color: Colors.white),
      ),
    ),
    useMaterial3: true,
  );
}

class WaterQualityPage extends StatefulWidget {
  const WaterQualityPage({super.key});

  @override
  State<WaterQualityPage> createState() => _WaterQualityPageState();
}

class _WaterQualityPageState extends State<WaterQualityPage> {
  bool isLoading = true;
  double? dht;
  double? ph;
  double? turbidity;
  String? date;
  String? time;
  String? status;
  bool _permissionDialogShown = false;
  
  // เพิ่มตัวแปรสำหรับเก็บค่าก่อนหน้า
  double? _previousDht;
  double? _previousPh;
  double? _previousTurbidity;
  
  // เพิ่มตัวแปรสำหรับเก็บสถานะการแจ้งเตือน
  bool _notificationEnabled = false;
  
  // เพิ่มตัวแปรสำหรับ developer mode
  bool _developerMode = false;
  
  // เพิ่มตัวแปรสำหรับเก็บหน้าปัจจุบัน
  int _currentPageIndex = 0;

  // เพิ่มตัวแปรสำหรับสถานะปั๊มน้ำ
  bool _pumpOn = false;

  // Connectivity (อินเทอร์เน็ต)
  bool _isOffline = false;
  StreamSubscription<ConnectivityResult>? _connectivitySub;

  late DatabaseReference ref;
  late DatabaseReference pumpRef;

  // เพิ่มตัวแปรเก็บประวัติย้อนหลัง
  List<Map<String, dynamic>> tempHistory = [];
  List<Map<String, dynamic>> phHistory = [];
  List<Map<String, dynamic>> turbidityHistory = [];

  // ฟังก์ชันโหลดประวัติย้อนหลัง
  Future<void> _fetchHistory() async {
    tempHistory = await _getHistoryList('Temp_history');
    phHistory = await _getHistoryList('PH_history');
    turbidityHistory = await _getHistoryList('turbidity_history');
    setState(() {});
  }

  Future<List<Map<String, dynamic>>> _getHistoryList(String key) async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref(key).orderByChild('timestamp').limitToLast(20).get();
      if (snapshot.exists && snapshot.value != null) {
        // รองรับทั้งกรณีเป็น Map (push id) และ List
        if (snapshot.value is Map) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          final list = data.entries.map((e) {
            final v = e.value as Map<dynamic, dynamic>;
            return {
              'id': e.key, // เพิ่ม id
              'value': _toDouble(v['value']),
              'timestamp': v['timestamp'] ?? '',
            };
          }).where((e) => e['value'] != null).toList();
          // เรียงจากใหม่ไปเก่า
          list.sort((a, b) {
            final aTime = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(2000);
            final bTime = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(2000);
            return bTime.compareTo(aTime);
          });
          return list;
        } else if (snapshot.value is List) {
          final data = snapshot.value as List<dynamic>;
          final list = data.where((v) => v != null).map((v) {
            final map = v as Map<dynamic, dynamic>;
            return {
              'id': map['id'] ?? '',
              'value': _toDouble(map['value']),
              'timestamp': map['timestamp'] ?? '',
            };
          }).where((e) => e['value'] != null).toList();
          // เรียงจากใหม่ไปเก่า
          list.sort((a, b) {
            final aTime = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(2000);
            final bTime = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(2000);
            return bTime.compareTo(aTime);
          });
          return list;
        }
      }
    } catch (e) {
      print('Error fetching $key: $e');
    }
    return [];
  }

  @override
  void initState() {
    super.initState();
    _checkAndShowPermissionDialog();
    _loadNotificationSettings();
    _loadDeveloperMode();
    ref = FirebaseDatabase.instance.ref('logDHT/latest');
    pumpRef = FirebaseDatabase.instance.ref('pump/state');
    _fetchData();
    _fetchHistory(); // โหลดประวัติย้อนหลัง
    ref.onValue.listen(_onDataChanged);
    pumpRef.onValue.listen((event) {
      final value = event.snapshot.value;
      setState(() {
        _pumpOn = value == 1 || value == true || value == '1';
      });
    });
  }

  @override
  void dispose() {
    _connectivitySub?.cancel();
    super.dispose();
  }
  

  Future<void> _loadNotificationSettings() async {
    final prefs = await SharedPreferences.getInstance();
      setState(() {
      _notificationEnabled = prefs.getBool('notificationEnabled') ?? false;
    });
  }

  Future<void> _loadDeveloperMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _developerMode = prefs.getBool('developerMode') ?? false;
    });
  }

  Future<void> _saveDeveloperMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('developerMode', value);
    setState(() {
      _developerMode = value;
    });
  }

  Future<void> _checkAndShowPermissionDialog() async {
    final prefs = await SharedPreferences.getInstance();
    final shown = prefs.getBool('permissionDialogShown') ?? false;
    if (!shown) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        // ไม่ต้องแสดง dialog แล้ว เพราะย้ายไปไว้ใน SettingsPage
      });
      await prefs.setBool('permissionDialogShown', true);
    }
    
    // Request notification permissions
    await _requestNotificationPermissions();
  }

  // เพิ่มฟังก์ชัน _showNotification ในคลาส
  Future<void> _showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'water_quality_channel',
      'Water Quality Notifications',
      channelDescription: 'Notifications for water quality monitoring',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await flutterLocalNotificationsPlugin.show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }

  // เพิ่มฟังก์ชันบันทึกค่าปัจจุบันลง history
  Future<void> _saveCurrentToHistory() async {
    final now = DateTime.now().toIso8601String();
    if (dht != null) {
      await FirebaseDatabase.instance.ref('Temp_history').push().set({
        'value': dht,
        'timestamp': now,
      });
    }
    if (ph != null) {
      await FirebaseDatabase.instance.ref('PH_history').push().set({
        'value': ph,
        'timestamp': now,
      });
    }
    if (turbidity != null) {
      await FirebaseDatabase.instance.ref('turbidity_history').push().set({
        'value': turbidity,
        'timestamp': now,
      });
    }
  }

  Future<void> _fetchData() async {
    setState(() => isLoading = true);
    final snapshot = await ref.get();
    final data = snapshot.value as Map?;
    setState(() {
      dht = _convertTemperature(_toDouble(data?['Temp']));
      ph = _convertPhValue(_toDouble(data?['PH']));
      turbidity = _toDouble(data?['turbidity']);
      _previousDht = _convertTemperature(_toDouble(data?['Temp_previous']));
      _previousPh = _convertPhValue(_toDouble(data?['PH_previous']));
      _previousTurbidity = _toDouble(data?['turbidity_previous']);
      date = data?['date']?.toString();
      time = data?['time']?.toString();
      status = data?['status']?.toString();
      isLoading = false;
    });
    await _saveCurrentToHistory();
    _checkValueChanges();
  }

  double? _toDouble(dynamic value) {
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      final v = double.tryParse(value);
      if (v != null && v.isFinite) return v;
    }
    return null;
  }

  // เพิ่มฟังก์ชันแปลงค่า pH จาก 0-1024 เป็น pH ทางวิทยาศาสตร์
  double? _convertPhValue(double? rawValue) {
    if (rawValue == null) return null;
    // แปลงจาก 0-1024 เป็น pH 0-14
    // pH = 14 - (rawValue / 1024 * 14)
    return 14 - (rawValue / 1024 * 14);
  }

  // เพิ่มฟังก์ชันแปลงอุณหภูมิจากค่าหลักร้อยเป็นองศา
  double? _convertTemperature(double? rawValue) {
    if (rawValue == null) return null;
    // แปลงจากค่าหลักร้อยเป็นองศา
    // ตัวอย่าง: 250 = 25.0°C, 300 = 30.0°C
    return rawValue / 10;
  }

  double getBarMaxY(double? value) {
    if (value == null) return 10;
    if (value < 5) return 10;
    if (value < 15) return 20;
    if (value < 30) return 40;
    return value + 10;
  }

  Future<void> _showValueChart(BuildContext context, String label, double? value, Color color) async {
    String historyKey = '';
    if (label == 'DHT' || label == 'อุณหภูมิ (DHT)' || label == 'Temp') historyKey = 'Temp_history';
    if (label == 'pH' || label == 'PH') historyKey = 'PH_history';
    if (label == 'Turbidity' || label == 'ความขุ่น') historyKey = 'turbidity_history';

    List<Map<String, dynamic>> history = [];
    if (historyKey.isNotEmpty) {
      try {
        final snapshot = await FirebaseDatabase.instance.ref(historyKey).orderByChild('timestamp').limitToLast(20).get();
        if (snapshot.exists && snapshot.value != null) {
          // รองรับทั้งกรณีเป็น Map (push id) และ List
          if (snapshot.value is Map) {
            final data = snapshot.value as Map<dynamic, dynamic>;
            history = data.entries.map((e) {
              final v = e.value as Map<dynamic, dynamic>;
              return {
                'value': _toDouble(v['value']),
                'timestamp': v['timestamp'] ?? DateTime.now().toIso8601String(),
              };
            }).where((e) => e['value'] != null && e['value'] > 0).toList();
          } else if (snapshot.value is List) {
            final data = snapshot.value as List<dynamic>;
            history = data.where((v) => v != null).map((v) {
              final map = v as Map<dynamic, dynamic>;
              return {
                'value': _toDouble(map['value']),
                'timestamp': map['timestamp'] ?? DateTime.now().toIso8601String(),
              };
            }).where((e) => e['value'] != null && e['value'] > 0).toList();
          }
          // Sort by timestamp if available
          history.sort((a, b) {
            try {
              final aTime = DateTime.tryParse(a['timestamp'] ?? '');
              final bTime = DateTime.tryParse(b['timestamp'] ?? '');
              if (aTime != null && bTime != null) {
                return aTime.compareTo(bTime);
              }
              return 0;
            } catch (e) {
              return 0;
            }
          });
        }
      } catch (e) {
        print('Error fetching history data: $e');
        // Continue with empty history if there's an error
      }
    }
    // เพิ่มจุดปัจจุบันเข้าไปในกราฟ (ถ้ายังไม่มีหรือค่าต่างจากค่าล่าสุด)
    if (value != null && value > 0 && (history.isEmpty || (history.last['value'] as double?) != value)) {
      history.add({'value': value, 'timestamp': DateTime.now().toIso8601String()});
    }
    // Ensure we have at least some data to display
    if (history.isEmpty) {
      history = [{'value': value ?? 0, 'timestamp': DateTime.now().toIso8601String()}];
    }
    if (!context.mounted) return;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(top: 12, bottom: 20),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: color.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.analytics, color: color),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                '$label Analysis',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        SizedBox(
                          height: 240,
                          child: history.isNotEmpty
                              ? BarChart(
                                  BarChartData(
                                    minY: 0,
                                    maxY: _calculateMaxY(history),
                                    barGroups: [
                                      for (int i = 0; i < history.length; i++)
                                        BarChartGroupData(
                                          x: i,
                                          barRods: [
                                            BarChartRodData(
                                              toY: (history[i]['value'] as double?) ?? 0,
                                              color: i == history.length - 1
                                                  ? color // ค่าปัจจุบัน rod สุดท้าย
                                                  : color.withOpacity(0.4), // ค่าเก่า rod สีจาง
                                              width: 18,
                                              borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                            ),
                                          ],
                                        ),
                                    ],
                                    titlesData: FlTitlesData(
                                      leftTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          reservedSize: 40,
                                          getTitlesWidget: (y, meta) => Text(
                                            y.toStringAsFixed(0),
                                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                          ),
                                        ),
                                      ),
                                      bottomTitles: AxisTitles(
                                        sideTitles: SideTitles(
                                          showTitles: true,
                                          interval: 1,
                                          getTitlesWidget: (x, meta) {
                                            final int idx = x.toInt();
                                            if (idx < 0 || idx >= history.length) return const SizedBox.shrink();
                                            final ts = history[idx]['timestamp'] as String? ?? '';
                                            String dateStr = '';
                                            if (ts.isNotEmpty) {
                                              final dt = DateTime.tryParse(ts);
                                              if (dt != null) {
                                                dateStr = '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                                              }
                                            }
                                            if (idx == history.length - 1) {
                                              return Column(
                                                mainAxisSize: MainAxisSize.min,
                                                children: [
                                                  Text('ปัจจุบัน', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                                  Text(dateStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                                ],
                                              );
                                            }
                                            return Column(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('ย้อนหลัง', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                                Text(dateStr, style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                      rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                      topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    ),
                                    borderData: FlBorderData(show: false),
                                    gridData: FlGridData(
                                      show: true,
                                      drawVerticalLine: false,
                                      horizontalInterval: 5,
                                      getDrawingHorizontalLine: (value) => FlLine(
                                        color: Colors.grey[200]!,
                                        strokeWidth: 1,
                                      ),
                                    ),
                                  ),
                                )
                              : const Center(child: Text('ไม่มีข้อมูลย้อนหลัง')),
                        ),
                        const SizedBox(height: 20),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.info_outline, color: color),
                              const SizedBox(width: 8),
                              Text(
                                'Current $label: ${value?.toStringAsFixed(2) ?? '-'}',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: color,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // Helper function to calculate max Y value safely
  double _calculateMaxY(List<Map<String, dynamic>> history) {
    if (history.isEmpty) return 10;
    
    try {
      final maxValue = history.map((e) => (e['value'] as double?) ?? 0).reduce((a, b) => a > b ? a : b);
      return maxValue + 5;
    } catch (e) {
      return 10;
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      extendBody: true,
      body: SafeArea(
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 350),
          child: _currentPageIndex == 1
              ? const SettingsPage(key: ValueKey('settings'))
              : _buildHomeContent(context),
        ),
      ),
      floatingActionButton: _currentPageIndex == 0
          ? FloatingActionButton.extended(
              onPressed: _fetchData,
              icon: const Icon(Icons.refresh),
              label: const Text('อัปเดตข้อมูล'),
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 6,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            )
          : null,
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      bottomNavigationBar: _buildFloatingNavBar(context),
    );
  }

  Widget _buildHomeContent(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 350),
      child: isLoading
          ? const Center(
              key: ValueKey('loading'),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('กำลังโหลดข้อมูล...'),
                ],
              ),
            )
            : SingleChildScrollView(
              key: ValueKey('main'),
              padding: const EdgeInsets.all(16),
                child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                  if (_isOffline)
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.orange.withOpacity(0.3)),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.wifi_off, color: Colors.orange, size: 18),
                          SizedBox(width: 8),
                          Expanded(child: Text('ออฟไลน์: ข้อมูลอาจไม่อัปเดตแบบเรียลไทม์')),
                        ],
                      ),
                    ),
                  _buildHeader(),
                  const SizedBox(height: 24),
                  _buildPumpControlCard(), // เพิ่ม card ควบคุมปั๊มน้ำ
                  const SizedBox(height: 24),
                  _buildMetricsGrid(),
                  const SizedBox(height: 24),
                  _buildStatusCard(),
                  const SizedBox(height: 24),
                  _buildHistorySectionV2(),
                ],
              ),
            ),
    );
  }

  Widget _buildPumpControlCard() {
    final theme = Theme.of(context);
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _pumpOn ? Icons.water : Icons.water_drop_outlined,
                    color: theme.colorScheme.primary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 20),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ควบคุมปั๊มน้ำ',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _pumpOn ? 'สถานะ: เปิด' : 'สถานะ: ปิด',
                        style: GoogleFonts.inter(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _pumpOn ? theme.colorScheme.primary : Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'ระบบอัตโนมัติ: ปั๊มจะเปิดเมื่อความขุ่น > 25 NTU',
                        style: GoogleFonts.inter(
                          fontSize: 12,
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFloatingNavBar(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, bottom: 18),
      child: PhysicalModel(
        color: Colors.transparent,
      elevation: 12,
        borderRadius: BorderRadius.circular(32),
        shadowColor: const Color(0x3300BFFF),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32),
          child: Container(
            decoration: BoxDecoration(
              color: theme.bottomNavigationBarTheme.backgroundColor,
              borderRadius: BorderRadius.circular(32),
              boxShadow: [
                BoxShadow(
                  color: const Color(0x2200BFFF),
                  blurRadius: 16,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: NavigationBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              height: 68,
              indicatorColor: theme.navigationBarTheme.indicatorColor ?? theme.colorScheme.primary.withOpacity(0.13),
      selectedIndex: _currentPageIndex,
              animationDuration: const Duration(milliseconds: 350),
              destinations: [
                NavigationDestination(
                  icon: Icon(Icons.home_outlined, size: 28, color: theme.navigationBarTheme.iconTheme?.resolve({})?.color ?? theme.colorScheme.primary),
                  selectedIcon: Icon(Icons.home, size: 28, color: theme.navigationBarTheme.iconTheme?.resolve({})?.color ?? theme.colorScheme.primary),
                  label: 'หน้าหลัก',
                ),
                NavigationDestination(
                  icon: Icon(Icons.settings_outlined, size: 28, color: theme.navigationBarTheme.iconTheme?.resolve({})?.color ?? theme.colorScheme.primary),
                  selectedIcon: Icon(Icons.settings, size: 28, color: theme.navigationBarTheme.iconTheme?.resolve({})?.color ?? theme.colorScheme.primary),
                  label: 'ตั้งค่า',
                ),
              ],
      onDestinationSelected: (index) {
        setState(() {
          _currentPageIndex = index;
        });
      },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            const Color(0xFF00BFFF),
            const Color(0xFF2196F3),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF00BFFF),
                      const Color(0xFF2196F3),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water_drop,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'คุณภาพน้ำ',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Real-time Monitoring',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (date != null && time != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.access_time,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                          'อัปเดตล่าสุด: $date $time',
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget oneUiSectionHeader(String title, IconData icon, Color color) {
    return Padding(
      padding: const EdgeInsets.only(left: 24, right: 24, top: 16, bottom: 8),
      child: Row(
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(width: 12),
          Text(
            title,
            style: GoogleFonts.inter(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricsGrid() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        oneUiSectionHeader('ค่าที่วัดได้', Icons.analytics, const Color(0xFF2196F3)),
        const SizedBox(height: 8),
        LayoutBuilder(
          builder: (context, constraints) {
            final double spacing = 12;
            final double horizontalPadding = 16;
            final double maxWidth = MediaQuery.of(context).size.width - (horizontalPadding * 2);
            final double tileWidth = (maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                SizedBox(
                  width: tileWidth,
                  child: HomeTile(
                    label: 'อุณหภูมิ (DHT)',
                    icon: Icons.thermostat,
                    value: dht,
                    color: const Color(0xFF4CAF50),
                    unit: '°C',
                    isNormal: dht != null && dht! >= 25 && dht! <= 35,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            title: 'อุณหภูมิ (DHT)',
                            color: const Color(0xFF4CAF50),
                            unit: '°C',
                            currentValue: dht,
                            historyKey: 'Temp_history',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: HomeTile(
                    label: 'ค่า pH',
                    icon: Icons.science,
                    value: ph,
                    color: const Color(0xFF2196F3),
                    unit: '',
                    isNormal: ph != null && ph! >= 6.5 && ph! <= 8.5,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            title: 'ค่า pH',
                            color: const Color(0xFF2196F3),
                            unit: '',
                            currentValue: ph,
                            historyKey: 'PH_history',
                          ),
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(
                  width: tileWidth,
                  child: HomeTile(
                    label: 'ความขุ่น',
                    icon: Icons.opacity,
                    value: turbidity,
                    color: const Color(0xFF9C27B0),
                    unit: 'NTU',
                    isNormal: turbidity != null && turbidity! >= 0 && turbidity! <= 25,
                    onTap: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => DetailPage(
                            title: 'ความขุ่น',
                            color: const Color(0xFF9C27B0),
                            unit: 'NTU',
                            currentValue: turbidity,
                            historyKey: 'turbidity_history',
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _buildStatusCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.health_and_safety,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Text(
                  'สถานะคุณภาพน้ำ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildStatusIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusIndicators() {
    final hasWarning = (dht != null && (dht! < 25 || dht! > 35)) ||
        (ph != null && (ph! < 6.5 || ph! > 8.5)) ||
        (turbidity != null && (turbidity! < 0 || turbidity! > 25));

    if (hasWarning) {
      return Column(
        children: [
          if (dht != null && (dht! < 25 || dht! > 35))
            _StatusIndicator(
              text: '⚠️ อุณหภูมิอยู่นอกช่วงปกติ (${dht!.toStringAsFixed(1)}°C)',
              color: Colors.orange,
              icon: Icons.thermostat,
            ),
          if (ph != null && (ph! < 6.5 || ph! > 8.5))
            _StatusIndicator(
              text: '⚠️ pH อยู่นอกช่วงปกติ (${ph!.toStringAsFixed(1)})',
              color: Colors.red,
              icon: Icons.science,
            ),
          if (turbidity != null && (turbidity! < 0 || turbidity! > 25))
            _StatusIndicator(
              text: '⚠️ ความขุ่นอยู่นอกช่วงปกติ (${turbidity!.toStringAsFixed(1)} NTU)',
              color: Colors.red,
              icon: Icons.opacity,
            ),
        ],
      );
    } else {
      return _StatusIndicator(
        text: '✅ ค่าทุกอย่างอยู่ในช่วงปกติ',
        color: Colors.green,
        icon: Icons.check_circle,
      );
    }
  }

  void _checkValueChanges() async {
    if (!_notificationEnabled) return;
    final now = DateTime.now().toIso8601String();
    // ถ้ามีการเปลี่ยนแปลงค่า ให้บันทึกค่าเก่าลง Firebase เป็นประวัติ (push) พร้อม timestamp
    if (_previousDht != null && dht != null && (dht! - _previousDht!).abs() > 0) {
      await ref.child('Temp_history').push().set({
        'value': _previousDht,
        'timestamp': now,
      });
    }
    if (_previousPh != null && ph != null && (ph! - _previousPh!).abs() > 0) {
      await ref.child('PH_history').push().set({
        'value': _previousPh,
        'timestamp': now,
      });
    }
    if (_previousTurbidity != null && turbidity != null && (turbidity! - _previousTurbidity!).abs() > 0) {
      await ref.child('turbidity_history').push().set({
        'value': _previousTurbidity,
        'timestamp': now,
      });
    }
    // ตรวจสอบการเปลี่ยนแปลงอุณหภูมิ
    if (_previousDht != null && dht != null && 
        (dht! - _previousDht!).abs() > 2.0) {
      _showNotification(
        title: '🌡️ อุณหภูมิเปลี่ยนแปลง',
        body: 'อุณหภูมิเปลี่ยนจาก ${_previousDht!.toStringAsFixed(1)}°C เป็น ${dht!.toStringAsFixed(1)}°C',
        payload: 'temperature_change',
      );
    }
    // ตรวจสอบการเปลี่ยนแปลง pH
    if (_previousPh != null && ph != null && 
        (ph! - _previousPh!).abs() > 0.5) {
      _showNotification(
        title: '🧪 ค่า pH เปลี่ยนแปลง',
        body: 'ค่า pH เปลี่ยนจาก ${_previousPh!.toStringAsFixed(1)} เป็น ${ph!.toStringAsFixed(1)}',
        payload: 'ph_change',
      );
    }
    // ตรวจสอบการเปลี่ยนแปลงความขุ่น
    if (_previousTurbidity != null && turbidity != null && 
        (turbidity! - _previousTurbidity!).abs() > 10.0) {
      _showNotification(
        title: '🌊 ความขุ่นเปลี่ยนแปลง',
        body: 'ความขุ่นเปลี่ยนจาก ${_previousTurbidity!.toStringAsFixed(1)} NTU เป็น ${turbidity!.toStringAsFixed(1)} NTU',
        payload: 'turbidity_change',
      );
    }
    // ตรวจสอบค่าที่อยู่นอกช่วงปกติ
    _checkWaterQualityAlerts();
    
    // ตรวจสอบและควบคุมปั๊มน้ำอัตโนมัติ
    _checkAutoPumpControl();
    
    // อัปเดตค่าก่อนหน้า
    _previousDht = dht;
    _previousPh = ph;
    _previousTurbidity = turbidity;
  }

  // เพิ่มฟังก์ชันตรวจสอบคุณภาพน้ำและแจ้งเตือน
  void _checkWaterQualityAlerts() {
    // ตรวจสอบ pH (6.5 <= pH <= 8.5)
    if (ph != null) {
      if (ph! < 6.5 || ph! > 8.5) {
        _showNotification(
          title: '⚠️ ค่า pH ผิดปกติ',
          body: 'ค่า pH ปัจจุบัน: ${ph!.toStringAsFixed(1)} (ปกติ: 6.5-8.5)',
          payload: 'ph_alert',
        );
      }
    }
    
    // ตรวจสอบความขุ่น (0 <= NTU <= 25)
    if (turbidity != null) {
      if (turbidity! < 0 || turbidity! > 25) {
        _showNotification(
          title: '⚠️ ความขุ่นผิดปกติ',
          body: 'ความขุ่นปัจจุบัน: ${turbidity!.toStringAsFixed(1)} NTU (ปกติ: 0-25 NTU)',
          payload: 'turbidity_alert',
        );
      }
    }
    
    // ตรวจสอบอุณหภูมิ (25 <= temp <= 35)
    if (dht != null) {
      if (dht! < 25 || dht! > 35) {
        _showNotification(
          title: '⚠️ อุณหภูมิผิดปกติ',
          body: 'อุณหภูมิปัจจุบัน: ${dht!.toStringAsFixed(1)}°C (ปกติ: 25-35°C)',
          payload: 'temperature_alert',
        );
      }
    }
  }

  // เพิ่มฟังก์ชันตรวจสอบและควบคุมปั๊มน้ำอัตโนมัติ
  void _checkAutoPumpControl() async {
    if (turbidity == null) return;
    bool shouldTurnOnPump = turbidity! > 25.0;
    if (shouldTurnOnPump && !_pumpOn) {
      setState(() {
        _pumpOn = true;
      });
      await pumpRef.set(1);
      _showNotification(
        title: '🔧 เปิดปั๊มน้ำอัตโนมัติ',
        body: 'เปิดปั๊มน้ำเนื่องจากความขุ่น > 25 NTU',
        payload: 'auto_pump_on',
      );
    } else if (!shouldTurnOnPump && _pumpOn) {
      setState(() {
        _pumpOn = false;
      });
      await pumpRef.set(0);
      _showNotification(
        title: '✅ ปิดปั๊มน้ำอัตโนมัติ',
        body: 'ปิดปั๊มน้ำเนื่องจากความขุ่นกลับมาปกติ',
        payload: 'auto_pump_off',
      );
    }
  }

  void _onDataChanged(DatabaseEvent event) {
    final data = event.snapshot.value as Map?;
    setState(() {
      dht = _convertTemperature(_toDouble(data?['Temp']));
      ph = _convertPhValue(_toDouble(data?['PH']));
      turbidity = _toDouble(data?['turbidity']);
      _previousDht = _convertTemperature(_toDouble(data?['Temp_previous']));
      _previousPh = _convertPhValue(_toDouble(data?['PH_previous']));
      _previousTurbidity = _toDouble(data?['turbidity_previous']);
      date = data?['date']?.toString();
      time = data?['time']?.toString();
      status = data?['status']?.toString();
    });
    _saveCurrentToHistory();
    _checkValueChanges();
  }

  // เพิ่ม Widget แสดงข้อมูลย้อนหลังในหน้าหลัก
  Widget _buildHistorySectionV2() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        oneUiSectionHeader('ข้อมูลย้อนหลัง', Icons.history, const Color(0xFF9C27B0)),
        const SizedBox(height: 8),
        _buildHistoryCategory('อุณหภูมิ (DHT)', 'Temp_history', '°C', const Color(0xFF4CAF50)),
        _buildHistoryCategory('ค่า pH', 'PH_history', '', const Color(0xFF2196F3)),
        _buildHistoryCategory('ความขุ่น', 'turbidity_history', 'NTU', const Color(0xFF9C27B0)),
      ],
    );
  }

  Widget _buildHistoryCategory(String label, String firebaseKey, String unit, Color color) {
    return FutureBuilder(
      future: _getHistoryListV2(firebaseKey),
      builder: (context, snapshot) {
        final history = snapshot.data as List<Map<String, dynamic>>?;
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: GoogleFonts.inter(fontWeight: FontWeight.bold, fontSize: 16, color: color)),
                const SizedBox(height: 8),
                if (snapshot.connectionState == ConnectionState.waiting)
                  const Center(child: CircularProgressIndicator()),
                if (history == null || history.isEmpty)
                  const Text('ไม่มีข้อมูลย้อนหลัง', style: TextStyle(color: Colors.grey)),
                if (history != null && history.isNotEmpty)
                  SizedBox(
                    height: 180,
                    child: ListView.builder(
                      itemCount: history.length,
                      itemBuilder: (context, i) {
                        final item = history[i];
                        final value = item['value'] as double?;
                        final ts = item['timestamp'] ?? '';
                        final id = item['id'] ?? '';
                        String dateStr = '';
                        if (ts.isNotEmpty) {
                          final dt = DateTime.tryParse(ts);
                          if (dt != null) {
                            dateStr = '${dt.day}/${dt.month} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}';
                          }
                        }
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              Icon(Icons.circle, color: color, size: 10),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Row(
                                  children: [
                                    Text(dateStr, style: const TextStyle(fontSize: 13, color: Colors.black87)),
                                    if (id.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Text('[$id]', style: const TextStyle(fontSize: 10, color: Colors.grey)),
                                    ],
                                  ],
                                ),
                              ),
                              Text(value != null ? value.toStringAsFixed(2) : '-', style: TextStyle(fontWeight: FontWeight.bold, color: color)),
                              if (unit.isNotEmpty) ...[
                                const SizedBox(width: 4),
                                Text(unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                              ],
                            ],
                          ),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<List<Map<String, dynamic>>> _getHistoryListV2(String key) async {
    try {
      final snapshot = await FirebaseDatabase.instance.ref(key).orderByChild('timestamp').limitToLast(20).get();
      print('DEBUG: $key snapshot.exists = \${snapshot.exists} snapshot.value = \${snapshot.value}');
      if (snapshot.exists && snapshot.value != null) {
        if (snapshot.value is Map) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          final list = data.entries.map((e) {
            final v = e.value;
            if (v is Map) {
              return {
                'id': e.key,
                'value': v['value'] != null ? _toDouble(v['value']) : null,
                'timestamp': v['timestamp'] ?? '',
              };
            } else {
              return {
                'id': e.key,
                'value': null,
                'timestamp': '',
              };
            }
          }).where((e) => e['value'] != null).toList();
          // เรียงจากใหม่ไปเก่า
          list.sort((a, b) {
            final aTime = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(2000);
            final bTime = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(2000);
            return bTime.compareTo(aTime);
          });
          print('DEBUG: $key history list = \${list.length} items: \${list}');
          return list;
        } else {
          print('DEBUG: $key snapshot.value is not Map');
        }
      } else {
        print('DEBUG: $key snapshot.exists false or value is null');
      }
    } catch (e) {
      print('Error fetching $key: $e');
    }
    return [];
  }
}

class ValueCard extends StatelessWidget {
  final String label;
  final IconData icon;
  final double? value;
  final Color color;
  final String unit;
  final Future<void> Function()? onTap;
  final bool? isNormal;

  const ValueCard({
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
    required this.unit,
    required this.onTap,
    this.isNormal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Material(
        color: Colors.transparent,
      child: InkWell(
          borderRadius: BorderRadius.circular(28),
          onTap: () async { if (onTap != null) await onTap!(); },
          child: Padding(
            padding: const EdgeInsets.all(28),
          child: Row(
            children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(16),
                  ),
                child: Icon(icon, color: color, size: 28),
              ),
                const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        label,
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            value != null ? value!.toStringAsFixed(1) : '-',
                            style: GoogleFonts.inter(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          if (unit.isNotEmpty) ...[
                            const SizedBox(width: 6),
                            Text(
                              unit,
                              style: GoogleFonts.inter(
                                fontSize: 18,
                                color: Colors.grey[600],
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ],
                      ),
                      if (isNormal != null) ...[
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(
                              isNormal! ? Icons.check_circle : Icons.warning,
                              size: 18,
                              color: isNormal! ? Colors.green : Colors.orange,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              isNormal! ? 'ปกติ' : 'ผิดปกติ',
                              style: GoogleFonts.inter(
                                fontSize: 14,
                                color: isNormal! ? Colors.green : Colors.orange,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.13),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    Icons.chevron_right,
                    color: color,
                    size: 24,
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

class _StatusIndicator extends StatelessWidget {
  final String text;
  final Color color;
  final IconData icon;

  const _StatusIndicator({
    required this.text,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CreditsPage extends StatefulWidget {
  const CreditsPage({super.key});

  @override
  State<CreditsPage> createState() => _CreditsPageState();
}

class _CreditsPageState extends State<CreditsPage> {
  final List<_PersonDetail> _team = [
    _PersonDetail(
      name: 'วิชทชภณ พวงแก้ว',
      role: 'ครูที่ปรึกษา',
      desc: 'ครูที่ปรึกษาในการแข่งขันและการพัฒนาระบบทั้งหมด',
      icon: Icons.school,
      color: Color(0xFF2196F3),
      facebook: 'https://www.facebook.com/tawadchai.puangkaew',
      ig: 'https://www.instagram.com/oat.wcp/',
      line: '',
      school: 'โรงเรียนคุรุประชาสรรค์',
      address: '',
    ),
    _PersonDetail(
      name: 'เตชสิทธิ์ ทองคำ',
      role: 'นักพัฒนา',
      desc: 'นักพัฒนาในการพัฒนาระบบหลังบ้านทั้งหมด',
      icon: Icons.code,
      color: Color(0xFF4CAF50),
      facebook: 'https://www.facebook.com/ze.mx.86126',
      ig: 'https://www.instagram.com/zemx_9/',
      line: '',
      school: 'โรงเรียนคุรุประชาสรรค์',
      address: '',
    ),
    _PersonDetail(
      name: 'สิทธิโชค ยอดดำเนิน',
      role: 'นักพัฒนา',
      desc: 'นักพัฒนาในการพัฒนาระบบหลังบ้านและหน้าบ้าน',
      icon: Icons.computer,
      color: Color(0xFF2196F3),
      facebook: 'https://www.facebook.com/sitthichokthq/',
      ig: 'https://www.instagram.com/sitthichokthq_3/',
      line: '',
      school: 'โรงเรียนคุรุประชาสรรค์',
      address: '',
    ),
    _PersonDetail(
      name: 'ณัฐภูมิ พานิชพิบูลย์',
      role: 'ออกแบบและประกอบ',
      desc: 'ออกแบบอุปกรณ์และเครื่องมือการทำงาน',
      icon: Icons.design_services,
      color: Color(0xFF9C27B0),
      facebook: 'https://www.facebook.com/poom.notephone',
      ig: 'https://www.instagram.com/poom_071151/',
      line: '',
      school: 'โรงเรียนคุรุประชาสรรค์',
      address: 'ร้านโน๊ตโฟน',
    ),
    _PersonDetail(
      name: 'ชิษณุพงศ์ บุญมา',
      role: 'ประกอบ',
      desc: 'ผู้ช่วยประกอบเครื่องมือการทำงาน',
      icon: Icons.handyman,
      color: Color(0xFF9C27B0),
      facebook: 'https://www.facebook.com/chis.nu.phngs.652833',
      ig: 'https://www.instagram.com/nxme_.x/',
      line: '',
      school: 'โรงเรียนคุรุประชาสรรค์',
      address: '',
    ),
    _PersonDetail(
      name: 'ปฐมวัฒน์ ปลูกงาม',
      role: 'เขียนเล่ม',
      desc: 'ผู้เขียนเล่มในการส่งแข่ง',
      icon: Icons.menu_book,
      color: Color(0xFF2196F3),
      facebook: 'https://www.facebook.com/pathomwat.plukngam',
      ig: 'https://www.instagram.com/_pathomwat/',
      line: '',
      school: 'โรงเรียนคุรุประชาสรรค์',
      address: '',
    ),
    _PersonDetail(
      name: 'ปภาวรินทร์ ศรีฉ่ำ',
      role: 'ผู้ช่วยเขียนเล่ม',
      desc: 'ผู้ช่วยเขียนเล่มในการส่งแข่ง',
      icon: Icons.edit,
      color: Color(0xFF2196F3),
      facebook: 'https://www.facebook.com/aim.prapawarin.3',
      ig: 'https://www.instagram.com/aim_paphawalin/',
      line: '',
      school: 'โรงเรียนชัยนาทพิทยาคม',
      address: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        leading: const BackButton(),
        title: Text('Credits', style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text('Credits', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            _buildSectionCard('Development Team', _buildTeamCard(theme), theme),
            _buildSectionCard('Technologies Used', _buildTechCard(theme), theme),
            _buildSectionCard('Special Thanks', _buildThanksCard(theme), theme),
            _buildSectionCard('Contact', _buildContactCard(theme), theme),
            const SizedBox(height: 16),
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 16),
                child: Text(
                  '© 2024 Water Quality Monitor. All rights reserved.',
                  style: theme.textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget child, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        // color: theme.brightness == Brightness.dark ? const Color(0xFF232A34) : null, // ลบ override นี้
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 4. SectionHeader/Title ใน dark mode ใช้สีฟ้าอ่อนหรือขาว
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.primary.withOpacity(0.85)
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTeamCard(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _team.map((person) => Column(
        children: [
          _personTile(person, context, oneUi: true),
          if (person != _team.last) _divider(),
        ],
      )).toList(),
    );
  }

  Widget _buildTechCard(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _techChip('Flutter', Icons.flutter_dash, theme.colorScheme.primary),
        _techChip('Firebase', Icons.cloud, theme.colorScheme.secondary),
        _techChip('FL Chart', Icons.bar_chart, theme.colorScheme.tertiary),
        _techChip('Material Design 3', Icons.palette, theme.colorScheme.primary),
      ],
    );
  }

  Widget _buildThanksCard(ThemeData theme) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _thanksChip('Flutter Community', Icons.groups, theme.colorScheme.primary),
        _thanksChip('Firebase Team', Icons.cloud_done, theme.colorScheme.secondary),
        _thanksChip('Material Design Team', Icons.palette, Colors.pink),
      ],
    );
  }

  Widget _buildContactCard(ThemeData theme) {
    return Column(
      children: [
        _contactTile(Icons.email, 'Email', 'ksproject@gmail.com', theme.colorScheme.primary, oneUi: true),
        _divider(),
        _contactTile(Icons.link, 'GitHub', 'github.com/Sitthichokthq/ksproject/', Colors.black87, oneUi: true),
        _divider(),
        _contactTile(Icons.web, 'Website', 'tnddeta.web.app', theme.colorScheme.secondary, oneUi: true),
      ],
    );
  }

  Widget _personTile(_PersonDetail person, BuildContext context, {bool oneUi = false}) {
    final theme = Theme.of(context);
    return ListTile(
      leading: CircleAvatar(
        radius: oneUi ? 28 : 24,
        backgroundColor: person.color.withOpacity(0.12),
        child: Icon(person.icon, color: person.color, size: oneUi ? 32 : 24),
      ),
      title: Text(
        person.name,
        style: theme.textTheme.bodyLarge?.copyWith(
          fontWeight: FontWeight.bold,
          fontSize: oneUi ? 18 : 16,
          color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
        ),
      ),
      subtitle: Text(
        person.role,
        style: theme.textTheme.bodyMedium?.copyWith(
          color: person.color,
          fontWeight: FontWeight.w600,
          fontSize: oneUi ? 15 : 13,
        ),
      ),
      trailing: const Icon(Icons.chevron_right, color: Colors.grey, size: 28),
      contentPadding: EdgeInsets.symmetric(horizontal: oneUi ? 20 : 16, vertical: oneUi ? 10 : 4),
      onTap: () => _showPersonDetail(context, person),
    );
  }

  void _showPersonDetail(BuildContext context, _PersonDetail person) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(36)),
      ),
      builder: (context) {
        final theme = Theme.of(context);
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 32,
            bottom: MediaQuery.of(context).viewInsets.bottom + 32,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircleAvatar(
                radius: 38,
                backgroundColor: person.color.withOpacity(0.13),
                child: Icon(person.icon, color: person.color, size: 40),
              ),
              const SizedBox(height: 18),
              Text(person.name, style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 22)),
              const SizedBox(height: 4),
              Text(person.role, style: TextStyle(color: person.color, fontWeight: FontWeight.w600, fontSize: 16)),
              const SizedBox(height: 14),
              Text(person.desc, style: theme.textTheme.bodyLarge?.copyWith(fontSize: 16), textAlign: TextAlign.center),
              const SizedBox(height: 22),
              if (person.facebook.isNotEmpty || person.ig.isNotEmpty || person.line.isNotEmpty)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (person.facebook.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.facebook, color: Color(0xFF1877F3), size: 32),
                        tooltip: 'Facebook',
                        onPressed: () => _launchUrl(person.facebook),
                      ),
                    if (person.ig.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.camera_alt, color: Color(0xFFE1306C), size: 32),
                        tooltip: 'Instagram',
                        onPressed: () => _launchUrl(person.ig),
                      ),
                    if (person.line.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.chat, color: Color(0xFF00C300), size: 32),
                        tooltip: 'Line',
                        onPressed: () => _launchUrl(person.line),
                      ),
                  ],
                ),
              if (person.facebook.isNotEmpty || person.ig.isNotEmpty || person.line.isNotEmpty)
                const SizedBox(height: 16),
              Card(
                color: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                child: Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.school, color: Color(0xFF2196F3)),
                          const SizedBox(width: 8),
                          Text('โรงเรียน', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(person.school, style: theme.textTheme.bodyMedium?.copyWith(color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87)),
                      if (person.address.isNotEmpty) ...[
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Color(0xFF4CAF50)),
                            const SizedBox(width: 8),
                            Text('ที่อยู่', style: theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text(person.address, style: theme.textTheme.bodyMedium?.copyWith(color: theme.brightness == Brightness.dark ? Colors.white70 : Colors.black87)),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.close),
                  label: const Text('ปิด', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _divider() => const Divider(height: 1, indent: 24, endIndent: 24);

  Widget _techChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, color: color, size: 20),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
      backgroundColor: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _thanksChip(String label, IconData icon, Color color) {
    return Chip(
      avatar: Icon(icon, color: color, size: 20),
      label: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600, fontSize: 15)),
      backgroundColor: color.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    );
  }

  Widget _contactTile(IconData icon, String title, String value, Color color, {bool oneUi = false}) {
    return ListTile(
      leading: Icon(icon, color: color, size: oneUi ? 28 : 22),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.w600, fontSize: oneUi ? 17 : 14)),
      subtitle: Text(value, style: TextStyle(color: color, fontSize: oneUi ? 15 : 13)),
      contentPadding: EdgeInsets.symmetric(horizontal: oneUi ? 20 : 16, vertical: oneUi ? 10 : 4),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('ไม่สามารถเปิดลิงก์นี้ได้')),
      );
    }
  }
}

class _PersonDetail {
  final String name;
  final String role;
  final String desc;
  final IconData icon;
  final Color color;
  final String facebook;
  final String ig;
  final String line;
  final String school;
  final String address;
  _PersonDetail({
    required this.name,
    required this.role,
    required this.desc,
    required this.icon,
    required this.color,
    required this.facebook,
    required this.ig,
    required this.line,
    required this.school,
    required this.address,
  });
}

class UpdatePage extends StatefulWidget {
  const UpdatePage({super.key});

  @override
  State<UpdatePage> createState() => _UpdatePageState();
}

class _UpdatePageState extends State<UpdatePage> {
  bool isChecking = false;
  bool hasUpdate = false;
  String currentVersion = '1.0.0';
  String latestVersion = '1.0.0';
  String updateDescription = '';

  @override
  void initState() {
    super.initState();
    _checkForUpdates();
  }

  Future<void> _checkForUpdates() async {
    setState(() {
      isChecking = true;
    });

    // Simulate checking for updates
    await Future.delayed(const Duration(seconds: 2));

    setState(() {
      isChecking = false;
      hasUpdate = true;
      updateDescription = '''
• ปรับปรุงประสิทธิภาพการทำงาน
• แก้ไขบัคการแสดงผลกราฟ
• เพิ่มฟีเจอร์การแจ้งเตือน
• ปรับปรุง UI ให้สวยงามขึ้น
• เพิ่มการรองรับอุปกรณ์ใหม่
''';
    });
  }

  Future<void> _checkAndUpdateApp() async {
    try {
      final info = await InAppUpdate.checkForUpdate();
      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('แอพเป็นเวอร์ชันล่าสุดแล้ว')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('เกิดข้อผิดพลาด: \$e')),
      );
    }
  }

  void _showUpdateDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
                color: const Color(0xFF4CAF50).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.system_update, color: Color(0xFF4CAF50)),
            ),
            const SizedBox(width: 12),
            const Text('อัปเดตแอพ', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('เวอร์ชันล่าสุด: \$latestVersion'),
            const SizedBox(height: 8),
            Text('เวอร์ชันปัจจุบัน: \$currentVersion'),
            const SizedBox(height: 16),
            const Text(
              'การเปลี่ยนแปลงในเวอร์ชันใหม่:',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            Text(
              updateDescription,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('ยกเลิก'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _checkAndUpdateApp();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4CAF50),
              foregroundColor: Colors.white,
            ),
            child: const Text('อัปเดต'),
          ),
        ],
      ),
    );
  }

  void _downloadUpdate() {
    // Simulate download
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('กำลังดาวน์โหลดอัปเดต...'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('อัปเดตแอพ', style: Theme.of(context).appBarTheme.titleTextStyle),
        backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
        foregroundColor: Theme.of(context).appBarTheme.foregroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
              child: Text('อัปเดตแอพ', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 8),
            _buildSectionCard('เวอร์ชันปัจจุบัน', _buildCurrentVersionCard(), theme),
            _buildSectionCard('ตรวจสอบอัปเดต', _buildCheckUpdateCard(), theme),
            if (hasUpdate) _buildSectionCard('มีอัปเดตใหม่', _buildUpdateAvailableCard(), theme),
            _buildSectionCard('ประวัติการอัปเดต', _buildUpdateHistoryCard(), theme),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget child, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        // color: theme.brightness == Brightness.dark ? Colors.white : null, // ลบ override นี้
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 4. SectionHeader/Title ใน dark mode ใช้สีฟ้าอ่อนหรือขาว
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.primary.withOpacity(0.85)
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentVersionCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2196F3).withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
                  child: const Icon(
                    Icons.info_outline,
                    color: Color(0xFF2196F3),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'เวอร์ชันปัจจุบัน',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'Water Quality Monitor',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.tag,
                    color: Color(0xFF2196F3),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Version $currentVersion',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF2196F3),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCheckUpdateCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4CAF50).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.system_update,
                    color: Color(0xFF4CAF50),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ตรวจสอบอัปเดต',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'ตรวจสอบเวอร์ชันล่าสุดของแอพ',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isChecking ? null : _checkForUpdates,
                icon: isChecking
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.refresh),
                label: Text(isChecking ? 'กำลังตรวจสอบ...' : 'ตรวจสอบอัปเดต'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4CAF50),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateAvailableCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF9800).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.new_releases,
                    color: Color(0xFFFF9800),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'มีอัปเดตใหม่',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                      Text(
                        'เวอร์ชันล่าสุดพร้อมใช้งาน',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFF9800).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.tag,
                    color: Color(0xFFFF9800),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Version $latestVersion',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF9800),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _showUpdateDialog,
                icon: const Icon(Icons.download),
                label: const Text('อัปเดตแอพ'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFF9800),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpdateHistoryCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF9C27B0).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.history,
                    color: Color(0xFF9C27B0),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                const Text(
                  'ประวัติการอัปเดต',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1A1A1A),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _UpdateHistoryItem(
              version: '1.0.1',
              date: '15 มกราคม 2024',
              description: 'ปรับปรุงประสิทธิภาพและแก้ไขบัค',
            ),
            const SizedBox(height: 8),
            _UpdateHistoryItem(
              version: '1.0.0',
              date: '1 มกราคม 2024',
              description: 'เวอร์ชันแรกของแอพ',
            ),
          ],
        ),
      ),
    );
  }
}

class _UpdateHistoryItem extends StatelessWidget {
  final String version;
  final String date;
  final String description;

  const _UpdateHistoryItem({
    required this.version,
    required this.date,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF9C27B0).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
        child: Text(
                  'v$version',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF9C27B0),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                date,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            description,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF1A1A1A),
            ),
          ),
        ],
      ),
    );
  }
}

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _notificationEnabled = false;
  bool _permissionDialogShown = false;
  bool _developerMode = false;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationEnabled = prefs.getBool('notificationEnabled') ?? false;
      _developerMode = prefs.getBool('developerMode') ?? false;
    });
  }

  Future<void> _saveNotificationSetting(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notificationEnabled', value);
    setState(() {
      _notificationEnabled = value;
    });
  }

  Future<void> _saveDeveloperMode(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('developerMode', value);
    setState(() {
      _developerMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.fromLTRB(24, 24, 24, 8),
                child: Text('ตั้งค่า', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              _buildThemeModeSettings(),
              _buildSectionCard('การแจ้งเตือน', _buildNotificationSettings(), theme),
              _buildSectionCard('Developer Mode', _buildDeveloperSettings(), theme),
              _buildSectionCard('การทดสอบ', _buildTestSettings(), theme),
              _buildSectionCard('ข้อมูลแอป', _buildAppInfo(), theme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionCard(String title, Widget child, ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        // color: theme.brightness == Brightness.dark ? Colors.white : null, // ลบ override นี้
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 4. SectionHeader/Title ใน dark mode ใช้สีฟ้าอ่อนหรือขาว
              Text(
                title,
                style: GoogleFonts.inter(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: theme.brightness == Brightness.dark
                      ? theme.colorScheme.primary.withOpacity(0.85)
                      : theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 12),
              child,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildThemeModeSettings() {
    final themeNotifier = ChangeNotifierProvider.of<ThemeModeNotifier>(context);
    return neptune_ui.NeptuneCard(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: neptune_theme.NeptuneColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.brightness_6, color: neptune_theme.NeptuneColors.primary, size: 20),
            ),
            title: const Text('โหมดแสง', style: TextStyle(fontWeight: FontWeight.w500)),
            subtitle: Text(
              themeNotifier.themeMode == ThemeMode.system
                  ? 'ตามระบบ'
                  : themeNotifier.themeMode == ThemeMode.light
                      ? 'โหมดสว่าง'
                      : 'โหมดมืด',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: DropdownButton<ThemeMode>(
              value: themeNotifier.themeMode,
              underline: const SizedBox(),
              items: const [
                DropdownMenuItem(
                  value: ThemeMode.system,
                  child: Text('ตามระบบ'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.light,
                  child: Text('โหมดสว่าง'),
                ),
                DropdownMenuItem(
                  value: ThemeMode.dark,
                  child: Text('โหมดมืด'),
                ),
              ],
              onChanged: (mode) {
                if (mode != null) {
                  themeNotifier.setThemeMode(mode);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
    return neptune_ui.NeptuneCard(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: neptune_theme.NeptuneColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _notificationEnabled ? Icons.notifications_active : Icons.notifications_off,
                color: neptune_theme.NeptuneColors.primary,
                size: 20,
              ),
            ),
            title: const Text(
              'การแจ้งเตือนอัตโนมัติ',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              _notificationEnabled 
                ? 'ระบบจะแจ้งเตือนเมื่อค่ามีการเปลี่ยนแปลง'
                : 'ระบบจะไม่แจ้งเตือนเมื่อค่ามีการเปลี่ยนแปลง',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Switch(
              value: _notificationEnabled,
              onChanged: (value) {
                _saveNotificationSetting(value);
                _showNotification(
                  title: value ? '🔔 เปิดการแจ้งเตือน' : '🔕 ปิดการแจ้งเตือน',
                  body: value 
                    ? 'ระบบจะแจ้งเตือนเมื่อค่ามีการเปลี่ยนแปลง'
                    : 'ระบบจะไม่แจ้งเตือนเมื่อค่ามีการเปลี่ยนแปลง',
                  payload: 'notification_toggle',
                );
              },
              activeColor: neptune_theme.NeptuneColors.primary,
            ),
          ),
          if (!_permissionDialogShown) ...[
            const Divider(height: 1, indent: 16, endIndent: 16),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: neptune_theme.NeptuneColors.warning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.security,
                  color: neptune_theme.NeptuneColors.warning,
                  size: 20,
                ),
              ),
              title: const Text(
                'สิทธิ์การแจ้งเตือน',
                style: TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                'ตั้งค่าสิทธิ์การแจ้งเตือน',
                style: TextStyle(color: Colors.grey[600]),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: _showPermissionDialog,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDeveloperSettings() {
    return neptune_ui.NeptuneCard(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: neptune_theme.NeptuneColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _developerMode ? Icons.developer_mode : Icons.developer_mode_outlined,
                color: neptune_theme.NeptuneColors.accent,
                size: 20,
              ),
            ),
            title: const Text(
              'Developer Mode',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              _developerMode 
                ? 'เปิดใช้งานฟีเจอร์สำหรับนักพัฒนา'
                : 'ปิดใช้งานฟีเจอร์สำหรับนักพัฒนา',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: Switch(
              value: _developerMode,
              onChanged: (value) {
                _saveDeveloperMode(value);
                _showNotification(
                  title: value ? '🔧 เปิด Developer Mode' : '🔧 ปิด Developer Mode',
                  body: value 
                    ? 'ฟีเจอร์สำหรับนักพัฒนาพร้อมใช้งาน'
                    : 'ฟีเจอร์สำหรับนักพัฒนาถูกปิดใช้งาน',
                  payload: 'developer_mode_toggle',
                );
              },
              activeColor: neptune_theme.NeptuneColors.accent,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestSettings() {
    return neptune_ui.NeptuneCard(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: _developerMode 
                  ? neptune_theme.NeptuneColors.success.withOpacity(0.1)
                  : Colors.grey.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.notification_add,
                color: _developerMode 
                  ? neptune_theme.NeptuneColors.success
                  : Colors.grey,
                size: 20,
              ),
            ),
            title: Text(
              'ทดสอบการแจ้งเตือน',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: _developerMode ? neptune_theme.NeptuneColors.textPrimary : Colors.grey,
              ),
            ),
            subtitle: Text(
              _developerMode 
                ? 'ทดสอบระบบการแจ้งเตือน'
                : 'ต้องเปิด Developer Mode ก่อน',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: _developerMode 
              ? const Icon(Icons.arrow_forward_ios, size: 16)
              : const Icon(Icons.lock, size: 16, color: Colors.grey),
            onTap: _developerMode 
              ? () => _showNotification(
                  title: '🧪 ทดสอบการแจ้งเตือน',
                  body: 'ระบบการแจ้งเตือนทำงานปกติ',
                  payload: 'test_notification',
                )
              : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAppInfo() {
    return neptune_ui.NeptuneCard(
      child: Column(
        children: [
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: neptune_theme.NeptuneColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.info_outline,
                color: neptune_theme.NeptuneColors.accent,
                size: 20,
              ),
            ),
            title: const Text(
              'ข้อมูลแอป',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'ข้อมูลทีมพัฒนาและเทคโนโลยี',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const CreditsPage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
          const Divider(height: 1, indent: 16, endIndent: 16),
          ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: neptune_theme.NeptuneColors.primaryDark.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.update,
                color: neptune_theme.NeptuneColors.primaryDark,
                size: 20,
              ),
            ),
            title: const Text(
              'อัปเดตแอป',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            subtitle: Text(
              'ตรวจสอบและอัปเดตแอป',
              style: TextStyle(color: Colors.grey[600]),
            ),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () => Navigator.push(
              context,
              PageRouteBuilder(
                pageBuilder: (context, animation, secondaryAnimation) => const UpdatePage(),
                transitionsBuilder: (context, animation, secondaryAnimation, child) {
                  const begin = Offset(1.0, 0.0);
                  const end = Offset.zero;
                  const curve = Curves.easeInOut;
                  var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));
                  var offsetAnimation = animation.drive(tween);
                  return SlideTransition(position: offsetAnimation, child: child);
                },
                transitionDuration: const Duration(milliseconds: 300),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFF2196F3).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.security, color: Color(0xFF2196F3)),
            ),
            const SizedBox(width: 12),
            const Text('การอนุญาต', style: TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('แอปนี้ต้องการสิทธิ์ในการทำงานเบื้องหลัง\nเพื่อให้สามารถตรวจสอบและอัปเดตข้อมูลคุณภาพน้ำได้อย่างต่อเนื่อง'),
            SizedBox(height: 16),
            Text('แอปนี้ต้องการสิทธิ์ในการแจ้งเตือน\nเพื่อแจ้งเตือนเมื่อค่าคุณภาพน้ำอยู่นอกช่วงปกติ'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            style: TextButton.styleFrom(
              backgroundColor: const Color(0xFF2196F3),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('เข้าใจแล้ว'),
          ),
        ],
      ),
    );
  }

  void _showNotification({
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'water_quality_channel',
      'Water Quality Notifications',
      channelDescription: 'Notifications for water quality monitoring',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: androidPlatformChannelSpecifics);

    await FlutterLocalNotificationsPlugin().show(
      0,
      title,
      body,
      platformChannelSpecifics,
      payload: payload,
    );
  }
}

// เพิ่มวิดเจ็ต HomeTile สไตล์ Google Home
class HomeTile extends StatelessWidget {
  final String label;
  final IconData icon;
  final double? value;
  final Color color;
  final String unit;
  final Future<void> Function()? onTap;
  final bool? isNormal;

  const HomeTile({
    required this.label,
    required this.icon,
    required this.value,
    required this.color,
    required this.unit,
    required this.onTap,
    this.isNormal,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: () async { if (onTap != null) await onTap!(); },
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: theme.colorScheme.surfaceVariant.withOpacity(0.7)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(icon, color: color, size: 22),
                  ),
                  const Spacer(),
                  if (isNormal != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: (isNormal! ? Colors.green : Colors.orange).withOpacity(0.12),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          Icon(isNormal! ? Icons.check_circle : Icons.warning,
                              size: 14, color: isNormal! ? Colors.green : Colors.orange),
                          const SizedBox(width: 6),
                          Text(
                            isNormal! ? 'ปกติ' : 'ผิดปกติ',
                            style: TextStyle(
                              color: isNormal! ? Colors.green : Colors.orange,
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                label,
                style: GoogleFonts.inter(
                  fontSize: 13,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 6),
              Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    value != null ? value!.toStringAsFixed(1) : '-',
                    style: GoogleFonts.inter(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      color: theme.brightness == Brightness.dark ? Colors.white : Colors.black87,
                    ),
                  ),
                  if (unit.isNotEmpty) ...[
                    const SizedBox(width: 6),
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        unit,
                        style: GoogleFonts.inter(
                          fontSize: 14,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// หน้าแสดงรายละเอียดแบบเต็มจอ
class DetailPage extends StatefulWidget {
  final String title;
  final Color color;
  final String unit;
  final double? currentValue;
  final String historyKey;

  const DetailPage({
    super.key,
    required this.title,
    required this.color,
    required this.unit,
    required this.currentValue,
    required this.historyKey,
  });

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  List<Map<String, dynamic>> _history = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final snapshot = await FirebaseDatabase.instance.ref(widget.historyKey).orderByChild('timestamp').limitToLast(50).get();
      List<Map<String, dynamic>> items = [];
      if (snapshot.exists && snapshot.value != null) {
        if (snapshot.value is Map) {
          final data = snapshot.value as Map<dynamic, dynamic>;
          items = data.entries.map((e) {
            final v = e.value;
            if (v is Map) {
              return {
                'id': e.key,
                'value': (v['value'] is num) ? (v['value'] as num).toDouble() : double.tryParse('${v['value']}'),
                'timestamp': v['timestamp'] ?? '',
              };
            }
            return {'id': e.key, 'value': null, 'timestamp': ''};
          }).where((e) => e['value'] != null).toList();
        }
      }
      // sort by time asc for chart
      items.sort((a, b) {
        final aTime = DateTime.tryParse(a['timestamp'] ?? '') ?? DateTime(2000);
        final bTime = DateTime.tryParse(b['timestamp'] ?? '') ?? DateTime(2000);
        return aTime.compareTo(bTime);
      });
      // append current value as last point if different
      if (widget.currentValue != null && (items.isEmpty || items.last['value'] != widget.currentValue)) {
        items.add({'id': 'current', 'value': widget.currentValue, 'timestamp': DateTime.now().toIso8601String()});
      }
      setState(() {
        _history = items;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
    }
  }

  double _calcMaxY() {
    if (_history.isEmpty) return 10;
    final maxValue = _history.map((e) => (e['value'] as double?) ?? 0).reduce((a, b) => a > b ? a : b);
    return maxValue + (maxValue * 0.1) + 1;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _load,
            tooltip: 'รีเฟรช',
          )
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _load,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                children: [
                  // Summary card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            width: 44,
                            height: 44,
                            decoration: BoxDecoration(color: widget.color.withOpacity(0.12), shape: BoxShape.circle),
                            child: Icon(Icons.analytics, color: widget.color),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ค่าปัจจุบัน', style: GoogleFonts.inter(fontWeight: FontWeight.w600, color: Colors.grey[600])),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Text(
                                      widget.currentValue != null ? widget.currentValue!.toStringAsFixed(2) : '-',
                                      style: GoogleFonts.inter(fontSize: 28, fontWeight: FontWeight.bold, color: widget.color),
                                    ),
                                    if (widget.unit.isNotEmpty) ...[
                                      const SizedBox(width: 6),
                                      Text(widget.unit, style: GoogleFonts.inter(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w600)),
                                    ]
                                  ],
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.share),
                            onPressed: () {},
                            tooltip: 'แชร์',
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Chart
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
                      child: SizedBox(
                        height: 260,
                        child: _history.isEmpty
                            ? const Center(child: Text('ไม่มีข้อมูลย้อนหลัง'))
                            : BarChart(
                                BarChartData(
                                  minY: 0,
                                  maxY: _calcMaxY(),
                                  barGroups: [
                                    for (int i = 0; i < _history.length; i++)
                                      BarChartGroupData(
                                        x: i,
                                        barRods: [
                                          BarChartRodData(
                                            toY: (_history[i]['value'] as double?) ?? 0,
                                            color: i == _history.length - 1 ? widget.color : widget.color.withOpacity(0.4),
                                            width: 16,
                                            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                          ),
                                        ],
                                      ),
                                  ],
                                  titlesData: FlTitlesData(
                                    leftTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        reservedSize: 40,
                                        getTitlesWidget: (y, meta) => Text(
                                          y.toStringAsFixed(0),
                                          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                                        ),
                                      ),
                                    ),
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        interval: 1,
                                        getTitlesWidget: (x, meta) {
                                          final int idx = x.toInt();
                                          if (idx < 0 || idx >= _history.length) return const SizedBox.shrink();
                                          final ts = _history[idx]['timestamp'] as String? ?? '';
                                          String dateStr = '';
                                          if (ts.isNotEmpty) {
                                            final dt = DateTime.tryParse(ts);
                                            if (dt != null) {
                                              dateStr = '${dt.day}/${dt.month}';
                                            }
                                          }
                                          return Padding(
                                            padding: const EdgeInsets.only(top: 6),
                                            child: Text(
                                              idx == _history.length - 1 ? 'ปัจจุบัน' : dateStr,
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: idx == _history.length - 1 ? FontWeight.bold : FontWeight.normal,
                                                color: idx == _history.length - 1 ? widget.color : Colors.grey,
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                    rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  borderData: FlBorderData(show: false),
                                  gridData: FlGridData(
                                    show: true,
                                    drawVerticalLine: false,
                                    horizontalInterval: 5,
                                    getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey[200]!, strokeWidth: 1),
                                  ),
                                ),
                              ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // History list
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ListTile(
                            leading: Icon(Icons.history, color: widget.color),
                            title: const Text('ประวัติย้อนหลังล่าสุด'),
                            trailing: IconButton(
                              icon: const Icon(Icons.refresh),
                              onPressed: _load,
                              tooltip: 'รีเฟรช',
                            ),
                          ),
                          const Divider(height: 1),
                          ..._history.reversed.take(30).map((item) {
                            final ts = item['timestamp'] as String? ?? '';
                            DateTime? dt = ts.isNotEmpty ? DateTime.tryParse(ts) : null;
                            final dateStr = dt != null ? '${dt.day}/${dt.month}/${dt.year} ${dt.hour}:${dt.minute.toString().padLeft(2, '0')}' : '-';
                            final val = item['value'] as double?;
                            return ListTile(
                              dense: true,
                              leading: Icon(Icons.circle, size: 10, color: widget.color),
                              title: Text(dateStr),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(val != null ? val.toStringAsFixed(2) : '-', style: TextStyle(color: widget.color, fontWeight: FontWeight.bold)),
                                  if (widget.unit.isNotEmpty) ...[
                                    const SizedBox(width: 4),
                                    Text(widget.unit, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                                  ],
                                ],
                              ),
                            );
                          }).toList(),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
