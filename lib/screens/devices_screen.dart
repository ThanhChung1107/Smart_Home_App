import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DevicesScreen extends StatefulWidget {
  @override
  _DevicesScreenState createState() => _DevicesScreenState();
}

class _DevicesScreenState extends State<DevicesScreen> {
  String _selectedRoom = 'all';
  List<Device> _devices = [];
  bool _isLoading = false;

  // ⚠️ THAY ĐỔI IP CỦA BẠN TẠI ĐÂY
  static const String ESP_IP = "172.20.10.2";
  static const String BASE_URL = "http://$ESP_IP";

  @override
  void initState() {
    super.initState();
    _loadDevices();
  }

  void _loadDevices() {
    setState(() {
      _isLoading = true;
    });

    Future.delayed(Duration(seconds: 1), () {
      setState(() {
        _devices = [
          Device(
            id: 'led1',
            name: 'Đèn Phòng Khách',
            deviceType: 'light',
            typeName: 'Đèn LED',
            room: 'living_room',
            roomName: 'Phòng khách',
            isOn: false,
            icon: '💡',
            status: {'brightness': 100},
          ),
          Device(
            id: 'led2',
            name: 'Đèn Phòng Ngủ',
            deviceType: 'light',
            typeName: 'Đèn LED',
            room: 'bedroom',
            roomName: 'Phòng ngủ',
            isOn: false,
            icon: '💡',
            status: {'brightness': 100},
          ),
          Device(
            id: 'fan',
            name: 'Quạt Trần',
            deviceType: 'fan',
            typeName: 'Quạt',
            room: 'living_room',
            roomName: 'Phòng khách',
            isOn: false,
            icon: '🌀',
            status: {'speed': 3},
          ),
          Device(
            id: 'door',
            name: 'Cửa Chính',
            deviceType: 'door',
            typeName: 'Cửa',
            room: 'outside',
            roomName: 'Bên ngoài',
            isOn: false,
            icon: '🚪',
            status: {},
          ),
          Device(
            id: 'dryer',
            name: 'Cây Phơi',
            deviceType: 'dryer',
            typeName: 'Cây phơi',
            room: 'outside',
            roomName: 'Bên ngoài',
            isOn: false,
            icon: '👕',
            status: {},
          ),
        ];
        _isLoading = false;
      });
    });
  }

  // 🔧 GỌI ĐÚNG ENDPOINT CỦA ESP8266
  Future<Map<String, dynamic>> _controlDevice(String deviceId, String value) async {
    try {
      String endpoint = '';

      // Xác định endpoint và parameters dựa trên device
      switch (deviceId) {
        case 'led1':
          endpoint = '$BASE_URL/led1?state=$value';
          break;
        case 'led2':
          endpoint = '$BASE_URL/led2?state=$value';
          break;
        case 'fan':
          endpoint = '$BASE_URL/fan?speed=$value';
          break;
        case 'door':
          endpoint = '$BASE_URL/door?action=$value';
          break;
        case 'dryer':
          endpoint = '$BASE_URL/dry?action=$value';
          break;
        default:
          return {
            'success': false,
            'message': 'Unknown device: $deviceId',
          };
      }

      print('🚀 Gọi API: $endpoint');

      final response = await http.get(Uri.parse(endpoint))
          .timeout(Duration(seconds: 5));

      print('📨 Status: ${response.statusCode}');
      print('📨 Body: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 303) {
        // ESP8266 trả về redirect 303 - vẫn coi là thành công
        return {
          'success': true,
          'message': 'Lệnh đã gửi thành công',
        };
      } else {
        return {
          'success': false,
          'message': 'Lỗi HTTP: ${response.statusCode}',
        };
      }
    } catch (e) {
      print('❌ Lỗi kết nối: $e');
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }

  // Bật/tắt thiết bị
  Future<void> _toggleDevice(Device device) async {
    String value = '';

    // Xác định giá trị gửi đi
    switch (device.id) {
      case 'led1':
      case 'led2':
        value = device.isOn ? '0' : '1';
        break;
      case 'fan':
        value = device.isOn ? '0' : '3'; // Tắt hoặc tốc độ 3
        break;
      case 'door':
        value = device.isOn ? 'close' : 'open';
        break;
      case 'dryer':
        value = device.isOn ? 'in' : 'out';
        break;
    }

    print('🎯 Gửi lệnh: device=${device.id}, value=$value');

    final result = await _controlDevice(device.id, value);

    if (result['success'] == true) {
      setState(() {
        final index = _devices.indexWhere((d) => d.id == device.id);
        _devices[index] = _devices[index].copyWith(isOn: !device.isOn);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${device.name} đã ${!device.isOn ? 'bật' : 'tắt'}'),
          backgroundColor: Color(0xFF10B981),
          duration: Duration(seconds: 2),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${result['message']}'),
          backgroundColor: Color(0xFFEF4444),
          duration: Duration(seconds: 3),
        ),
      );
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
      ),
      body: Column(
        children: [
          _buildRoomFilter(),
          Expanded(
            child: _isLoading
                ? Center(
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
            )
                : _buildDevicesList(_devices),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomFilter() {
    return Container(
      padding: EdgeInsets.fromLTRB(20, 12, 20, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lọc theo phòng',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF64748B),
              letterSpacing: 0.3,
            ),
          ),
          SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildRoomChip('Tất cả', 'all'),
                _buildRoomChip('Phòng khách', 'living_room'),
                _buildRoomChip('Phòng ngủ', 'bedroom'),
                _buildRoomChip('Nhà bếp', 'kitchen'),
                _buildRoomChip('Phòng tắm', 'bathroom'),
                _buildRoomChip('Bên ngoài', 'outside'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomChip(String label, String room) {
    final isSelected = _selectedRoom == room;
    return Padding(
      padding: EdgeInsets.only(right: 10),
      child: FilterChip(
        label: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Color(0xFF64748B),
            fontWeight: FontWeight.w600,
            fontSize: 13,
          ),
        ),
        selected: isSelected,
        onSelected: (selected) {
          setState(() {
            _selectedRoom = room;
          });
        },
        backgroundColor: Color(0xFFE2E8F0),
        selectedColor: Color(0xFF6366F1),
        side: BorderSide(
          color: isSelected ? Color(0xFF6366F1) : Colors.transparent,
          width: 2,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildDevicesList(List<Device> devices) {
    final filteredDevices = _selectedRoom == 'all'
        ? devices
        : devices.where((device) => device.room == _selectedRoom).toList();

    if (filteredDevices.isEmpty) {
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
              _selectedRoom == 'all'
                  ? 'Không có thiết bị nào'
                  : 'Không có thiết bị trong\n${_getRoomName(_selectedRoom)}',
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

    return ListView.builder(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20),
      itemCount: filteredDevices.length,
      itemBuilder: (context, index) {
        return _buildDeviceCard(filteredDevices[index]);
      },
    );
  }

  String _getRoomName(String roomKey) {
    switch (roomKey) {
      case 'living_room':
        return 'phòng khách';
      case 'bedroom':
        return 'phòng ngủ';
      case 'kitchen':
        return 'nhà bếp';
      case 'bathroom':
        return 'phòng tắm';
      case 'outside':
        return 'bên ngoài';
      default:
        return roomKey;
    }
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
            _devices[index] = updatedDevice;
          });
        },
        controlDevice: _controlDevice,
      ),
    );
  }
}

// Device Model
class Device {
  final String id;
  final String name;
  final String deviceType;
  final String typeName;
  final String room;
  final String roomName;
  final bool isOn;
  final String icon;
  final Map<String, dynamic> status;

  Device({
    required this.id,
    required this.name,
    required this.deviceType,
    required this.typeName,
    required this.room,
    required this.roomName,
    required this.isOn,
    required this.icon,
    required this.status,
  });

  Device copyWith({
    bool? isOn,
    Map<String, dynamic>? status,
  }) {
    return Device(
      id: id,
      name: name,
      deviceType: deviceType,
      typeName: typeName,
      room: room,
      roomName: roomName,
      isOn: isOn ?? this.isOn,
      icon: icon,
      status: status ?? this.status,
    );
  }
}

// Device Detail Bottom Sheet
class DeviceDetailBottomSheet extends StatefulWidget {
  final Device device;
  final Function(Device) onDeviceUpdated;
  final Future<Map<String, dynamic>> Function(String, String) controlDevice;

  const DeviceDetailBottomSheet({
    Key? key,
    required this.device,
    required this.onDeviceUpdated,
    required this.controlDevice,
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
    String value = '';

    switch (device.id) {
      case 'led1':
      case 'led2':
        value = device.isOn ? '0' : '1';
        break;
      case 'fan':
        value = device.isOn ? '0' : '3';
        break;
      case 'door':
        value = device.isOn ? 'close' : 'open';
        break;
      case 'dryer':
        value = device.isOn ? 'in' : 'out';
        break;
    }

    final result = await widget.controlDevice(device.id, value);

    if (result['success'] == true) {
      setState(() {
        device = device.copyWith(isOn: !device.isOn);
      });
      widget.onDeviceUpdated(device);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${device.name} đã ${device.isOn ? 'bật' : 'tắt'}'),
          backgroundColor: Color(0xFF10B981),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(result['message']),
          backgroundColor: Color(0xFFEF4444),
        ),
      );
    }
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