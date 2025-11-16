import 'package:flutter/material.dart';
import '../services/schedule_service.dart';
import '../services/device_service.dart';
import '../models/schedule_model.dart';
import '../models/device.dart';

class ScheduleScreen extends StatefulWidget {
  @override
  _ScheduleScreenState createState() => _ScheduleScreenState();
}

class _ScheduleScreenState extends State<ScheduleScreen> {
  List<Schedule> schedules = [];
  List<Device> devices = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      isLoading = true;
    });

    try {
      final schedulesResult = await ScheduleService.getSchedules();
      final devicesResult = await DeviceService.getDevices();

      if (schedulesResult['success'] == true && devicesResult['success'] == true) {
        setState(() {
          schedules = (schedulesResult['schedules'] as List)
              .map((json) => Schedule.fromJson(json))
              .toList();
          devices = devicesResult['devices'] ?? [];
          isLoading = false;
        });
      } else {
        _showError('Lỗi tải dữ liệu: ${schedulesResult['message'] ?? devicesResult['message']}');
      }
    } catch (e) {
      _showError('Lỗi kết nối: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
    setState(() {
      isLoading = false;
    });
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Lịch trình'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: isLoading
          ? _buildLoading()
          : schedules.isEmpty
          ? _buildEmptyState()
          : _buildScheduleList(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddScheduleDialog(),
        child: Icon(Icons.add),
        backgroundColor: Colors.blue,
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Đang tải lịch trình...'),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.schedule,
            size: 80,
            color: Colors.grey[300],
          ),
          SizedBox(height: 16),
          Text(
            'Chưa có lịch trình nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Nhấn nút + để tạo lịch trình mới',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduleList() {
    return RefreshIndicator(
      onRefresh: _loadData,
      child: ListView.builder(
        padding: EdgeInsets.all(16),
        itemCount: schedules.length,
        itemBuilder: (context, index) {
          return _buildScheduleCard(schedules[index]);
        },
      ),
    );
  }

  Widget _buildScheduleCard(Schedule schedule) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: schedule.isActive ? Colors.green : Colors.grey,
          child: Icon(
            schedule.isActive ? Icons.check : Icons.schedule,
            color: Colors.white,
          ),
        ),
        title: Text(
          schedule.deviceName,
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('${schedule.displayAction} - ${schedule.formattedTime}'),
            Text(
              schedule.repeatText,
              style: TextStyle(color: Colors.grey[600]),
            ),
            if (schedule.nextExecution != null)
              Text(
                'Tiếp theo: ${_formatDateTime(schedule.nextExecution!)}',
                style: TextStyle(color: Colors.blue[600], fontSize: 12),
              ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Switch(
              value: schedule.isActive,
              onChanged: (value) => _toggleSchedule(schedule, value),
            ),
            PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _deleteSchedule(schedule);
                }
              },
              itemBuilder: (BuildContext context) {
                return [
                  PopupMenuItem(value: 'delete', child: Text('Xóa')),
                ];
              },
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(String isoString) {
    try {
      final dateTime = DateTime.parse(isoString).toLocal();
      return '${dateTime.hour}:${dateTime.minute.toString().padLeft(2, '0')} ${dateTime.day}/${dateTime.month}';
    } catch (e) {
      return isoString;
    }
  }

  void _showAddScheduleDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AddScheduleDialog(
          devices: devices,
          onScheduleAdded: _loadData,
        );
      },
    );
  }

  void _toggleSchedule(Schedule schedule, bool value) async {
    final result = await ScheduleService.updateSchedule(schedule.id, value);
    if (result['success'] == true) {
      setState(() {
        schedule.isActive = value;
      });
      _showSuccess('Đã ${value ? 'bật' : 'tắt'} lịch trình');
    } else {
      _showError(result['message'] ?? 'Lỗi khi cập nhật lịch trình');
    }
  }

  void _deleteSchedule(Schedule schedule) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Xóa lịch trình'),
          content: Text('Bạn có chắc muốn xóa lịch trình "${schedule.deviceName}"?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Hủy'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop();
                final result = await ScheduleService.deleteSchedule(schedule.id);
                if (result['success'] == true) {
                  setState(() {
                    schedules.remove(schedule);
                  });
                  _showSuccess('Đã xóa lịch trình');
                } else {
                  _showError(result['message'] ?? 'Lỗi khi xóa lịch trình');
                }
              },
              child: Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}

class AddScheduleDialog extends StatefulWidget {
  final List<Device> devices;
  final Function onScheduleAdded;

  const AddScheduleDialog({
    Key? key,
    required this.devices,
    required this.onScheduleAdded,
  }) : super(key: key);

  @override
  _AddScheduleDialogState createState() => _AddScheduleDialogState();
}

class _AddScheduleDialogState extends State<AddScheduleDialog> {
  final _formKey = GlobalKey<FormState>();

  String? selectedDeviceId;
  String? selectedAction;
  TimeOfDay selectedTime = TimeOfDay.now();
  DateTime? selectedDate;
  String selectedRepeatType = 'once';
  List<String> selectedDays = [];

  List<String> repeatTypes = ['once', 'daily', 'weekly'];
  Map<String, String> repeatTypeLabels = {
    'once': 'Một lần',
    'daily': 'Hàng ngày',
    'weekly': 'Hàng tuần',
  };

  List<String> days = ['Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7', 'Chủ nhật'];
  Map<String, String> dayMapping = {
    'Thứ 2': 'mon',
    'Thứ 3': 'tue',
    'Thứ 4': 'wed',
    'Thứ 5': 'thu',
    'Thứ 6': 'fri',
    'Thứ 7': 'sat',
    'Chủ nhật': 'sun',
  };
  List<String> actions = ['on', 'off'];
  Map<String, String> actionLabels = {
    'on': 'BẬT',
    'off': 'TẮT',
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Thêm lịch trình mới'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              DropdownButtonFormField<String>(
                value: selectedDeviceId,
                decoration: InputDecoration(
                  labelText: 'Thiết bị',
                  border: OutlineInputBorder(),
                ),
                items: widget.devices.map((device) {
                  return DropdownMenuItem(
                    value: device.id,
                    child: Text(device.name),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedDeviceId = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Vui lòng chọn thiết bị';
                  return null;
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedAction,
                decoration: InputDecoration(
                  labelText: 'Hành động',
                  border: OutlineInputBorder(),
                ),
                items: actions.map((action) {
                  return DropdownMenuItem(
                    value: action,
                    child: Text(actionLabels[action]!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedAction = value;
                  });
                },
                validator: (value) {
                  if (value == null) return 'Vui lòng chọn hành động';
                  return null;
                },
              ),
              SizedBox(height: 16),
              ListTile(
                leading: Icon(Icons.access_time),
                title: Text('Thời gian'),
                subtitle: Text('${selectedTime.hour}:${selectedTime.minute.toString().padLeft(2, '0')}'),
                onTap: () async {
                  final TimeOfDay? time = await showTimePicker(
                    context: context,
                    initialTime: selectedTime,
                  );
                  if (time != null) {
                    setState(() {
                      selectedTime = time;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedRepeatType,
                decoration: InputDecoration(
                  labelText: 'Lặp lại',
                  border: OutlineInputBorder(),
                ),
                items: repeatTypes.map((type) {
                  return DropdownMenuItem(
                    value: type,
                    child: Text(repeatTypeLabels[type]!),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    selectedRepeatType = value!;
                    if (value != 'once') {
                      selectedDate = null;
                    }
                  });
                },
              ),
              SizedBox(height: 16),
              if (selectedRepeatType == 'once')
                ListTile(
                  leading: Icon(Icons.calendar_today),
                  title: Text('Ngày'),
                  subtitle: Text(
                      selectedDate != null
                          ? '${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}'
                          : 'Chọn ngày'
                  ),
                  onTap: () async {
                    final DateTime? date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime(2100),
                    );
                    if (date != null) {
                      setState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),
              if (selectedRepeatType == 'weekly')
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Ngày trong tuần:', style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: days.map((day) {
                        final isSelected = selectedDays.contains(day);
                        return FilterChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (selected) {
                            setState(() {
                              if (selected) {
                                selectedDays.add(day);
                              } else {
                                selectedDays.remove(day);
                              }
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Hủy'),
        ),
        ElevatedButton(
          onPressed: _saveSchedule,
          child: Text('Lưu'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
        ),
      ],
    );
  }

  void _saveSchedule() async {
    if (_formKey.currentState!.validate()) {
      final backendDays = selectedDays.map((day) => dayMapping[day]!).toList();

      // SỬA: Thêm leading zero cho giờ và phút
      final hour = selectedTime.hour.toString().padLeft(2, '0');
      final minute = selectedTime.minute.toString().padLeft(2, '0');
      final timeString = '$hour:$minute'; // "04:02" thay vì "4:02"

      String? dateString;
      if (selectedDate != null) {
        dateString = '${selectedDate!.year}-${selectedDate!.month.toString().padLeft(2, '0')}-${selectedDate!.day.toString().padLeft(2, '0')}';
      }

      final scheduleData = {
        'device_id': selectedDeviceId,
        'action': selectedAction,
        'scheduled_time': timeString, // Đã sửa định dạng
        'scheduled_date': dateString,
        'repeat_type': selectedRepeatType,
        'repeat_days': backendDays,
      };

      print('🚀 Creating schedule: $scheduleData');

      final result = await ScheduleService.createSchedule(scheduleData);

      if (result['success'] == true) {
        widget.onScheduleAdded();
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm lịch trình mới'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result['message'] ?? 'Lỗi khi tạo lịch trình'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}