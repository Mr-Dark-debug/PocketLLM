import 'package:flutter/material.dart';
import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart'; // For requesting permissions
import '../custom_app_bar.dart'; // Import the CustomAppBar

class ModelDownloaderPage extends StatefulWidget {
  const ModelDownloaderPage({Key? key}) : super(key: key);

  @override
  _ModelDownloaderPageState createState() => _ModelDownloaderPageState();
}

class _ModelDownloaderPageState extends State<ModelDownloaderPage> {
  Map<String, dynamic> _deviceInfo = {};
  bool _isTermuxInstalled = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  Future<void> _initializeData() async {
    try {
      await _requestStoragePermission();
      await _fetchDeviceInfo();
      await _checkTermuxInstallation();
    } catch (e) {
      debugPrint('Error during initialization: $e');
    } finally {
      setState(() {
        _isLoading = false; // Ensure loading stops even if errors occur
      });
    }
  }

  Future<void> _requestStoragePermission() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await DeviceInfoPlugin().androidInfo;
        if (androidInfo.version.sdkInt >= 30) {
          // For Android 11+, request MANAGE_EXTERNAL_STORAGE
          final status = await Permission.manageExternalStorage.request();
          if (!status.isGranted) {
            debugPrint('Manage External Storage permission not granted');
            throw Exception('Manage External Storage permission not granted');
          }
        } else {
          // For older versions, request READ/WRITE permissions
          final status = await Permission.storage.request();
          if (!status.isGranted) {
            debugPrint('Storage permission not granted');
            throw Exception('Storage permission not granted');
          }
        }
      }
    } catch (e) {
      debugPrint('Error requesting storage permission: $e');
      rethrow;
    }
  }

  Future<void> _fetchDeviceInfo() async {
    final deviceInfoPlugin = DeviceInfoPlugin();
    Map<String, dynamic> deviceData = {};

    try {
      if (Platform.isAndroid) {
        final androidInfo = await deviceInfoPlugin.androidInfo;
        deviceData = {
          'Device': androidInfo.model,
          'Manufacturer': androidInfo.manufacturer,
          'RAM': 'Not directly available', // AndroidDeviceInfo does not provide totalMemory
          'Storage': await _getStorageInfo(),
          'Processor': androidInfo.hardware,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await deviceInfoPlugin.iosInfo;
        deviceData = {
          'Device': iosInfo.name,
          'Model': iosInfo.model,
          'Storage': await _getStorageInfo(),
          'Processor': 'Apple ${iosInfo.utsname.machine}',
        };
      }
    } catch (e) {
      debugPrint('Error fetching device info: $e');
      deviceData = {'Error': 'Failed to fetch device info'};
    }

    setState(() {
      _deviceInfo = deviceData;
    });
  }

  Future<String> _getStorageInfo() async {
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        return 'Storage info unavailable';
      }

      final totalSpace = await _getTotalStorage(directory.path);
      final freeSpace = await _getFreeStorage(directory.path);

      return '$freeSpace GB available of $totalSpace GB';
    } catch (e) {
      debugPrint('Error fetching storage info: $e');
      return 'Storage info unavailable';
    }
  }

  Future<int> _getTotalStorage(String path) async {
    try {
      final statFs = await Process.run('df', [path]);
      final lines = statFs.stdout.toString().split('\n');
      if (lines.length > 1) {
        final values = lines[1].split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
        return int.parse(values[1]) ~/ 1024; // Total size in MB
      }
      return 0;
    } catch (e) {
      debugPrint('Error fetching total storage: $e');
      return 0;
    }
  }

  Future<int> _getFreeStorage(String path) async {
    try {
      final statFs = await Process.run('df', [path]);
      final lines = statFs.stdout.toString().split('\n');
      if (lines.length > 1) {
        final values = lines[1].split(RegExp(r'\s+')).where((s) => s.isNotEmpty).toList();
        return int.parse(values[3]) ~/ 1024; // Free space in MB
      }
      return 0;
    } catch (e) {
      debugPrint('Error fetching free storage: $e');
      return 0;
    }
  }

  Future<void> _checkTermuxInstallation() async {
    try {
      final result = await Process.run('pm', ['list', 'packages', 'com.termux']);
      final output = result.stdout.toString();
      setState(() {
        _isTermuxInstalled = output.contains('package:com.termux');
      });
    } catch (e) {
      debugPrint('Error checking Termux installation: $e');
      setState(() {
        _isTermuxInstalled = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(kToolbarHeight),
        child: CustomAppBar(
          appName: 'Models',
          onSettingsPressed: () {
            debugPrint('Settings pressed in Models page');
          },
        ),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Device Configuration',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: _deviceInfo.entries.map((entry) {
                          return Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${entry.key}:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                              Expanded(
                                child: Text(entry.value.toString()),
                              ),
                            ],
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Termux Installation',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Is Termux Installed?',
                            style: TextStyle(fontSize: 18),
                          ),
                          Icon(
                            _isTermuxInstalled ? Icons.check_circle : Icons.cancel,
                            color: _isTermuxInstalled ? Colors.green : Colors.red,
                            size: 32,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Download Models',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 16),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      final model = ['Model A', 'Model B', 'Model C'][index];
                      return ListTile(
                        leading: Icon(Icons.cloud_download),
                        title: Text(model),
                        subtitle: Text('Description for $model'),
                        onTap: () {
                          debugPrint('Downloading $model...');
                        },
                      );
                    },
                  ),
                ],
              ),
            ),
    );
  }
}