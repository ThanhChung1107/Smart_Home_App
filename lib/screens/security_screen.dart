import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:PBL4_smart_home/providers/device_provider.dart';

class SecurityScreen extends StatefulWidget {
  @override
  _SecurityScreenState createState() => _SecurityScreenState();
}

class _SecurityScreenState extends State<SecurityScreen> {
  bool _isSecuritySystemOn = true;
  bool _isAlarmTriggered = false;
  List<Alert> _alerts = [
    Alert(
      type: AlertType.motion,
      location: 'Cửa trước',
      time: DateTime.now().subtract(Duration(minutes: 5)),
      description: 'Phát hiện chuyển động',
      isNew: true,
    ),
    Alert(
      type: AlertType.face,
      location: 'Camera phòng khách',
      time: DateTime.now().subtract(Duration(hours: 2)),
      description: 'Nhận diện người lạ',
      isNew: false,
    ),
    Alert(
      type: AlertType.door,
      location: 'Cửa sổ phòng ngủ',
      time: DateTime.now().subtract(Duration(hours: 5)),
      description: 'Cửa mở bất thường',
      isNew: false,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade100,
      appBar: AppBar(
        title: Text('HỆ THỐNG CẢNH BÁO'),
        backgroundColor: _isSecuritySystemOn ? Colors.green : Colors.grey,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              // TODO: Xem lịch sử cảnh báo
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Trạng thái hệ thống
          Container(
            padding: EdgeInsets.all(20),
            margin: EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black12,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _isSecuritySystemOn ? Colors.green.withOpacity(0.2) : Colors.grey.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _isSecuritySystemOn ? Icons.security : Icons.security_outlined,
                    color: _isSecuritySystemOn ? Colors.green : Colors.grey,
                    size: 30,
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'HỆ THỐNG AN NINH',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        _isSecuritySystemOn ? '🟢 ĐANG BẢO VỆ' : '⚪ TẠM DỪNG',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: _isSecuritySystemOn ? Colors.green : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                Switch(
                  value: _isSecuritySystemOn,
                  onChanged: (value) {
                    setState(() {
                      _isSecuritySystemOn = value;
                    });
                  },
                  activeColor: Colors.green,
                ),
              ],
            ),
          ),

          // Cảnh báo khẩn cấp
          if (_isAlarmTriggered)
            Container(
              margin: EdgeInsets.symmetric(horizontal: 16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red, width: 2),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning, color: Colors.red, size: 30),
                  SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'CẢNH BÁO KHẨN CẤP!',
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          'Phát hiện xâm nhập tại cửa trước',
                          style: TextStyle(color: Colors.red.shade700),
                        ),
                      ],
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _isAlarmTriggered = false;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text('TẮT BÁO ĐỘNG'),
                  ),
                ],
              ),
            ),

          SizedBox(height: 16),

          // Danh sách cảnh báo
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'CẢNH BÁO GẦN ĐÂY',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade700,
                  ),
                ),
                Text(
                  '${_alerts.length} cảnh báo',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ),

          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: _alerts.length,
              itemBuilder: (context, index) {
                return _buildAlertCard(_alerts[index]);
              },
            ),
          ),

          // Panel điều khiển nhanh
          Container(
            padding: EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildQuickAction(
                  icon: Icons.people,
                  label: 'Người lạ',
                  color: Colors.orange,
                  onTap: () {
                    _showStrangerAlert();
                  },
                ),
                _buildQuickAction(
                  icon: Icons.door_front_door,
                  label: 'Cửa mở',
                  color: Colors.blue,
                  onTap: () {
                    _showDoorAlert();
                  },
                ),
                _buildQuickAction(
                  icon: Icons.motion_photos_on,
                  label: 'Chuyển động',
                  color: Colors.purple,
                  onTap: () {
                    _showMotionAlert();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertCard(Alert alert) {
    return Card(
      margin: EdgeInsets.only(bottom: 12),
      color: alert.isNew ? Colors.blue.withOpacity(0.1) : Colors.white,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: _getAlertColor(alert.type).withOpacity(0.2),
            shape: BoxShape.circle,
          ),
          child: Icon(
            _getAlertIcon(alert.type),
            color: _getAlertColor(alert.type),
          ),
        ),
        title: Text(
          alert.description,
          style: TextStyle(
            fontWeight: alert.isNew ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Vị trí: ${alert.location}'),
            Text('Thời gian: ${_formatTime(alert.time)}'),
          ],
        ),
        trailing: alert.isNew
            ? Container(
          padding: EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: Colors.red,
            shape: BoxShape.circle,
          ),
          child: Text(
            'MỚI',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : null,
        onTap: () {
          _showAlertDetail(alert);
        },
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            shape: BoxShape.circle,
            border: Border.all(color: color, width: 2),
          ),
          child: IconButton(
            icon: Icon(icon, color: color),
            onPressed: onTap,
          ),
        ),
        SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ],
    );
  }

  // Helper methods
  Color _getAlertColor(AlertType type) {
    switch (type) {
      case AlertType.motion:
        return Colors.orange;
      case AlertType.face:
        return Colors.red;
      case AlertType.door:
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  IconData _getAlertIcon(AlertType type) {
    switch (type) {
      case AlertType.motion:
        return Icons.motion_photos_on;
      case AlertType.face:
        return Icons.face;
      case AlertType.door:
        return Icons.door_front_door;
      default:
        return Icons.warning;
    }
  }

  String _formatTime(DateTime time) {
    return '${time.hour}:${time.minute.toString().padLeft(2, '0')} ${time.day}/${time.month}';
  }

  void _showAlertDetail(Alert alert) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('CHI TIẾT CẢNH BÁO'),
          content: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Loại: ${_getAlertTypeText(alert.type)}'),
              Text('Vị trí: ${alert.location}'),
              Text('Thời gian: ${_formatTime(alert.time)}'),
              Text('Mô tả: ${alert.description}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('ĐÓNG'),
            ),
            if (alert.isNew)
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    alert.isNew = false;
                  });
                  Navigator.of(context).pop();
                },
                child: Text('ĐÁNH DẤU ĐÃ XEM'),
              ),
          ],
        );
      },
    );
  }

  String _getAlertTypeText(AlertType type) {
    switch (type) {
      case AlertType.motion:
        return 'Chuyển động';
      case AlertType.face:
        return 'Nhận diện khuôn mặt';
      case AlertType.door:
        return 'Cửa mở';
      default:
        return 'Khác';
    }
  }

  void _showStrangerAlert() {
    setState(() {
      _alerts.insert(0, Alert(
        type: AlertType.face,
        location: 'Camera cổng',
        time: DateTime.now(),
        description: 'Phát hiện người lạ',
        isNew: true,
      ));
    });
  }

  void _showDoorAlert() {
    setState(() {
      _alerts.insert(0, Alert(
        type: AlertType.door,
        location: 'Cửa sau',
        time: DateTime.now(),
        description: 'Cửa mở ngoài giờ',
        isNew: true,
      ));
    });
  }

  void _showMotionAlert() {
    setState(() {
      _alerts.insert(0, Alert(
        type: AlertType.motion,
        location: 'Sân vườn',
        time: DateTime.now(),
        description: 'Chuyển động bất thường',
        isNew: true,
      ));
    });
  }
}

// Model cho cảnh báo
class Alert {
  final AlertType type;
  final String location;
  final DateTime time;
  final String description;
  bool isNew;

  Alert({
    required this.type,
    required this.location,
    required this.time,
    required this.description,
    required this.isNew,
  });
}

enum AlertType {
  motion,
  face,
  door,
}