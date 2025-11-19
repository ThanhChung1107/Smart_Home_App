import 'package:flutter/material.dart';
import 'package:PBL4_smart_home/services/device_service.dart';
import 'package:PBL4_smart_home/models/device.dart'; // CHỈ IMPORT, KHÔNG ĐỊNH NGHĨA LẠI
import 'dart:async';

class DevicesScreen extends StatefulWidget {
  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  List<Device> _devices = []; // Sử dụng Device từ models/device.dart
  bool _isLoading = false;
  String _errorMessage = '';
  Timer? _syncTimer;

  @override
  void initState() {
    super.initState();
    _loadDevicesFromAPI();
    _startPeriodicSync();
  }

  @override
  void dispose() {
    _syncTimer?.cancel(); // ✅ Dừng timer khi dispose
    super.dispose();
  }
  void _startPeriodicSync() {
    _syncTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      _syncDevicesQuietly();
    });
  }
  Future<void> _syncDevicesQuietly() async {
    final result = await DeviceService.syncDeviceStatus();

    if (result['success'] == true) {
      // Reload devices sau khi sync
      final devicesResult = await DeviceService.getDevices();

      if (devicesResult['success'] == true && mounted) {
        setState(() {
          _devices = List<Device>.from(devicesResult['devices']);
        });

        print('🔄 Synced ${result['synced_count'] ?? 0} devices');
      }
    }
  }

  /// Đồng bộ thủ công (có loading, có thông báo)
  Future<void> _syncDevicesManually() async {
    setState(() {
      _isLoading = true;
    });

    final result = await DeviceService.syncDeviceStatus();

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      // Reload devices
      await _loadDevicesFromAPI();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Đã đồng bộ ${result['synced_count'] ?? 0} thiết bị'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ ${result['message']}'),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _loadDevicesFromAPI() async {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });

    print('🔄 Loading devices from API...');

    final result = await DeviceService.getDevices();

    setState(() {
      _isLoading = false;
    });

    if (result['success'] == true) {
      setState(() {
        _devices = List<Device>.from(result['devices']); // Cast rõ ràng
      });
      print('✅ Đã tải ${_devices.length} thiết bị từ database');
    } else {
      setState(() {
        _errorMessage = result['message'] ?? 'Lỗi không xác định';
      });
      print('❌ Lỗi tải thiết bị: $_errorMessage');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi tải thiết bị: $_errorMessage'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  Future<void> _toggleDevice(Device device) async {
    print('🎯 Điều khiển thiết bị: ${device.name}, ID: ${device.id}');

    String action = '';
    Map<String, dynamic>? parameters = {};

    switch (device.deviceType.toLowerCase()) {
      case 'light':
      case 'led':
        action = device.isOn ? 'turn_off' : 'turn_on';
        break;
      case 'fan':
        action = device.isOn ? 'turn_off' : 'turn_on';
        parameters = {'speed': 3};
        break;
      case 'ac':
        action = device.isOn ? 'turn_off' : 'turn_on';
        parameters = {'temperature': 25};
        break;
      case 'socket':
        action = device.isOn ? 'turn_off' : 'turn_on';
        break;
      case 'door':
        action = device.isOn ? 'close' : 'open';
        break;
      default:
        action = device.isOn ? 'turn_off' : 'turn_on';
    }

    print('📤 Gửi lệnh: action=$action, parameters=$parameters');

    final result = await DeviceService.controlDevice(
      device.id,
      action,
      parameters: parameters.isNotEmpty ? parameters : null,
    );

    if (result['success'] == true) {
      setState(() {
        final index = _devices.indexWhere((d) => d.id == device.id);
        if (index != -1) {
          _devices[index] = _devices[index].copyWith(
            isOn: !device.isOn,
            status: result['device']?['status'] ?? device.status,
          );
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${device.name} đã ${!device.isOn ? 'bật' : 'tắt'} thành công'),
            backgroundColor: Color(0xFF10B981),
            duration: Duration(seconds: 2),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${result['message']}'),
            backgroundColor: Color(0xFFEF4444),
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Text(
          'THIẾT BỊ THÔNG MINH',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            fontSize: 20,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        actions: [
          IconButton(
            icon: Icon(Icons.sync),
            onPressed: _syncDevicesManually,
            tooltip: 'Đồng bộ trạng thái',
          ),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadDevicesFromAPI,
            tooltip: 'Làm mới danh sách',
          ),
        ],
      ),
      body: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Color(0xFF6366F1),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Đang tải thiết bị...',
              style: TextStyle(
                color: Color(0xFF6366F1),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Lỗi tải thiết bị',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            SizedBox(height: 8),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey[600],
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadDevicesFromAPI,
              child: Text('Thử lại'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF6366F1),
              ),
            ),
          ],
        ),
      );
    }

    return _buildDevicesList(_devices);
  }

  Widget _buildDevicesList(List<Device> devices) {
    if (devices.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Color(0xFFE0E7FF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.devices_other,
                size: 40,
                color: Color(0xFF6366F1),
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Không có thiết bị nào',
              style: TextStyle(
                color: Color(0xFF64748B),
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await _loadDevicesFromAPI();
      },
      child: ListView.builder(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
        itemCount: devices.length,
        itemBuilder: (context, index) {
          return _buildDeviceCard(devices[index]);
        },
      ),
    );
  }

  Widget _buildDeviceCard(Device device) {
    final statusColor = device.isOn ? Color(0xFF10B981) : Color(0xFF94A3B8);
    final statusBgColor = device.isOn ? Color(0xFFD1FAE5) : Color(0xFFE2E8F0);

    return GestureDetector(
      onTap: () => _showDeviceDetail(device),
      child: Container(
        margin: EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: device.isOn
                      ? Color(0xFF10B981).withOpacity(0.1)
                      : Color(0xFF94A3B8).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Text(
                    device.icon,
                    style: TextStyle(fontSize: 28),
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      device.name,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1E293B),
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      '${device.typeName} • ${device.roomName}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Color(0xFF94A3B8),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      child: Text(
                        device.isOn ? '🟢 Đang hoạt động' : '⚫ Tắt',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: statusColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Material(
                color: Colors.transparent,
                child: Switch(
                  value: device.isOn,
                  onChanged: (value) async {
                    await _toggleDevice(device);
                  },
                  activeColor: Color(0xFF10B981),
                  activeTrackColor: Color(0xFFD1FAE5),
                  inactiveThumbColor: Color(0xFF94A3B8),
                  inactiveTrackColor: Color(0xFFE2E8F0),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeviceDetail(Device device) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => DeviceDetailBottomSheet(
        device: device,
        onDeviceUpdated: (updatedDevice) {
          setState(() {
            final index = _devices.indexWhere((d) => d.id == updatedDevice.id);
            if (index != -1) {
              _devices[index] = updatedDevice;
            }
          });
        },
        toggleDevice: _toggleDevice,
      ),
    );
  }
}

// =====================================================
// DeviceDetailBottomSheet - CHỈ SỬ DỤNG Device từ models
// =====================================================
class DeviceDetailBottomSheet extends StatefulWidget {
  final Device device;
  final Function(Device) onDeviceUpdated;
  final Future<void> Function(Device) toggleDevice;

  const DeviceDetailBottomSheet({
    Key? key,
    required this.device,
    required this.onDeviceUpdated,
    required this.toggleDevice,
  }) : super(key: key);

  @override
  _DeviceDetailBottomSheetState createState() => _DeviceDetailBottomSheetState();
}

class _DeviceDetailBottomSheetState extends State<DeviceDetailBottomSheet> {
  late Device device;

  @override
  void initState() {
    super.initState();
    device = widget.device;
  }

  Future<void> _toggleDevice() async {
    await widget.toggleDevice(device);
    setState(() {
      device = device.copyWith(isOn: !device.isOn);
    });
    widget.onDeviceUpdated(device);
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = device.isOn ? Color(0xFF10B981) : Color(0xFFEF4444);

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(28),
          topRight: Radius.circular(28),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
          ),
        ],
      ),
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.fromLTRB(24, 20, 24, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 48,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Color(0xFFE2E8F0),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              SizedBox(height: 24),
              Row(
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: device.isOn
                          ? Color(0xFF10B981).withOpacity(0.1)
                          : Color(0xFFEF4444).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Center(
                      child: Text(
                        device.icon,
                        style: TextStyle(fontSize: 32),
                      ),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          device.name,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF1E293B),
                            letterSpacing: 0.5,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '${device.typeName} • ${device.roomName}',
                          style: TextStyle(
                            fontSize: 13,
                            color: Color(0xFF94A3B8),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        SizedBox(height: 8),
                        Container(
                          decoration: BoxDecoration(
                            color: device.isOn
                                ? Color(0xFFD1FAE5)
                                : Color(0xFFFEE2E2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          padding: EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          child: Text(
                            device.isOn ? '🟢 Đang hoạt động' : '🔴 Tắt',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: statusColor,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              Container(
                decoration: BoxDecoration(
                  color: device.isOn
                      ? Color(0xFFD1FAE5)
                      : Color(0xFFFEE2E2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _toggleDevice,
                    borderRadius: BorderRadius.circular(14),
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            device.isOn ? Icons.power_off : Icons.power,
                            color: statusColor,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            device.isOn ? 'TẮT THIẾT BỊ' : 'BẬT THIẾT BỊ',
                            style: TextStyle(
                              color: statusColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 14,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
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
}