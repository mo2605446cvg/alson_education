import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:alson_education/services/api_service.dart';
import 'package:alson_education/models/user.dart';

class AdminDashboard extends StatefulWidget {
  final User user;
  final ApiService apiService;
  final Function() onLogout;

  AdminDashboard({required this.user, required this.apiService, required this.onLogout});

  @override
  _AdminDashboardState createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int _userCount = 0;
  String _location = 'جاري تحديد الموقع...';
  String _deviceInfo = 'جاري جمع معلومات الجهاز...';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDashboardData();
  }

  Future<void> _loadDashboardData() async {
    try {
      // جلب عدد المستخدمين
      final users = await widget.apiService.getUsers();
      
      // جلب الموقع
      await _getCurrentLocation();
      
      // جلب معلومات الجهاز
      await _getDeviceInfo();

      setState(() {
        _userCount = users.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في تحميل بيانات لوحة التحكم')),
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _location = 'خدمة الموقع غير مفعلة';
        });
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _location = 'تم رفض إذن الموقع';
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _location = 'تم رفض إذن الموقع بشكل دائم';
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );

      setState(() {
        _location = '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
    } catch (e) {
      setState(() {
        _location = 'فشل في الحصول على الموقع';
      });
    }
  }

  Future<void> _getDeviceInfo() async {
    try {
      DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
      
      if (Theme.of(context).platform == TargetPlatform.android) {
        AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
        setState(() {
          _deviceInfo = 'Android ${androidInfo.version.release} - ${androidInfo.model}';
        });
      } else if (Theme.of(context).platform == TargetPlatform.iOS) {
        IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
        setState(() {
          _deviceInfo = 'iOS ${iosInfo.systemVersion} - ${iosInfo.model}';
        });
      } else {
        setState(() {
          _deviceInfo = 'معلومات الجهاز غير متاحة';
        });
      }
    } catch (e) {
      setState(() {
        _deviceInfo = 'فشل في جمع معلومات الجهاز';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('لوحة تحكم المدير'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: widget.onLogout,
            tooltip: 'تسجيل الخروج',
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Padding(
              padding: EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إحصائيات المستخدمين',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _buildStatCard('إجمالي المستخدمين', _userCount.toString(), Icons.people),
                              _buildStatCard('المستخدمين النشطين', (_userCount ~/ 2).toString(), Icons.person),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'معلومات الجهاز',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          SizedBox(height: 20),
                          ListTile(
                            leading: Icon(Icons.location_on),
                            title: Text('الموقع الجغرافي'),
                            subtitle: Text(_location),
                          ),
                          Divider(),
                          ListTile(
                            leading: Icon(Icons.phone_android),
                            title: Text('معلومات الجهاز'),
                            subtitle: Text(_deviceInfo),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    child: Padding(
                      padding: EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'إجراءات سريعة',
                            style: Theme.of(context).textTheme.displayMedium,
                          ),
                          SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              ElevatedButton(
                                onPressed: () {
                                  // الانتقال إلى إدارة المستخدمين
                                },
                                child: Text('إدارة المستخدمين'),
                              ),
                              ElevatedButton(
                                onPressed: () {
                                  // الانتقال إلى إدارة المحتوى
                                },
                                child: Text('إدارة المحتوى'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, size: 40, color: Theme.of(context).colorScheme.primary),
        SizedBox(height: 10),
        Text(value, style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
        Text(title, style: TextStyle(color: Colors.grey)),
      ],
    );
  }
}