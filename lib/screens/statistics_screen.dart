// screens/statistics_screen.dart
import 'package:flutter/material.dart';
import '../services/device_service.dart';
import 'package:PBL4_smart_home/models/device_usage.dart';

class StatisticsScreen extends StatefulWidget {
  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  String _selectedPeriod = 'today';
  List<DeviceUsage> _deviceUsageData = [];
  bool _isLoading = true;
  String _error = '';
  double _totalCost = 0;
  double _totalPower = 0;
  int _totalDevices = 0;

  @override
  void initState() {
    super.initState();
    _loadRealStatistics();
  }

  // THÊM HÀM NÀY
  void _checkDebugStats() async {
    print('🛠️ Checking debug stats...');
    var result = await DeviceService.getDebugStats();
    print('🔍 DEBUG STATS: $result');

    // Hiển thị kết quả trong dialog để dễ đọc
    if (mounted) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: Text('Debug Stats'),
          content: SingleChildScrollView(
            child: Text(result.toString()),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('Đóng'),
            ),
          ],
        ),
      );
    }
  }
  void _cleanupSessions() async {
    print('🧹 Cleaning up sessions...');
    var result = await DeviceService.cleanupSessions();
    print('🧹 Cleanup result: $result');

    // Reload stats sau khi cleanup
    _loadRealStatistics();
  }

  Future<void> _loadRealStatistics() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = '';
    });

    try {
      print('🔄 Loading statistics for period: $_selectedPeriod');

      final result = await DeviceService.getRealStatistics(_selectedPeriod);
      print('🛠️ Checking debug after loading stats...');
      var debugResult = await DeviceService.getDebugStats();
      print('🔍 DEBUG STATS: $debugResult');
      print('📊 API Response: $result');

      if (result['success'] == true && mounted) {
        List<dynamic> statistics = result['statistics'] ?? [];
        print('📈 Found ${statistics.length} devices statistics');

        List<DeviceUsage> deviceUsages = statistics.map((stat) {
          return DeviceUsage.fromJson(stat);
        }).toList();

        // Tính tổng
        double totalCost = deviceUsages.fold(0, (sum, item) => sum + item.cost);
        double totalPower = deviceUsages.fold(0, (sum, item) => sum + item.powerConsumption);
        int totalDevices = deviceUsages.length;

        if (mounted) {
          setState(() {
            _deviceUsageData = deviceUsages;
            _totalCost = totalCost;
            _totalPower = totalPower;
            _totalDevices = totalDevices;
            _isLoading = false;
          });
        }

        print('✅ Statistics loaded successfully');

      } else {
        String errorMessage = result['message'] ?? 'Lỗi tải dữ liệu thống kê';
        print('❌ API Error: $errorMessage');

        if (mounted) {
          setState(() {
            _error = errorMessage;
            _isLoading = false;
          });
          _loadSampleData();
        }
      }
    } catch (e) {
      print('❌ Exception in _loadRealStatistics: $e');
      if (mounted) {
        setState(() {
          _error = 'Lỗi kết nối: $e';
          _isLoading = false;
        });
        _loadSampleData();
      }
    }
  }

  void _loadSampleData() {
    print('📋 Loading sample data');
    setState(() {
      _deviceUsageData = [
        DeviceUsage(
          deviceName: 'Đèn phòng khách',
          deviceType: 'light',
          turnOnCount: 0,
          totalUsageHours: 0,
          powerConsumption: 0,
          cost: 0,
          usageData: [],
        ),
        DeviceUsage(
          deviceName: 'Quạt phòng ngủ',
          deviceType: 'fan',
          turnOnCount: 0,
          totalUsageHours: 0,
          powerConsumption: 0,
          cost: 0,
          usageData: [],
        ),
        DeviceUsage(
          deviceName: 'Cửa ra vào',
          deviceType: 'door',
          turnOnCount: 0,
          totalUsageHours: 0,
          powerConsumption: 0,
          cost: 0,
          usageData: [],
        ),
      ];
      _totalCost = 0;
      _totalPower = 0;
      _totalDevices = _deviceUsageData.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('THỐNG KÊ SỬ DỤNG'),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(Icons.bug_report, color: Colors.white),
            onPressed: _checkDebugStats,
            tooltip: 'Debug Stats',
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _loadRealStatistics,
            tooltip: 'Làm mới dữ liệu',
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Đang tải dữ liệu thống kê...',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    if (_error.isNotEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 64, color: Colors.red),
            SizedBox(height: 16),
            Text(
              _error,
              style: TextStyle(
                color: Colors.red,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8),
            Text(
              'Đang hiển thị dữ liệu mẫu',
              style: TextStyle(
                color: Colors.grey.shade600,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadRealStatistics,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade800,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
              child: Text(
                'Thử lại',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      color: Colors.grey.shade50,
      child: Column(
        children: [
          _buildPeriodSelector(),
          _buildSummaryCards(),
          Expanded(
            child: _deviceUsageData.isEmpty
                ? _buildEmptyState()
                : RefreshIndicator(
              onRefresh: _loadRealStatistics,
              child: ListView.builder(
                padding: EdgeInsets.all(16),
                itemCount: _deviceUsageData.length,
                itemBuilder: (context, index) {
                  return _buildDeviceStatsCard(_deviceUsageData[index]);
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  // THÊM METHOD _buildEmptyState
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.analytics_outlined, size: 64, color: Colors.grey.shade400),
          SizedBox(height: 16),
          Text(
            'Chưa có dữ liệu thống kê',
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Dữ liệu sẽ xuất hiện sau khi sử dụng thiết bị',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildPeriodSelector() {
    return Container(
      padding: EdgeInsets.all(16),
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildPeriodChip('Hôm nay', 'today'),
          _buildPeriodChip('Tuần này', 'week'),
          _buildPeriodChip('Tháng này', 'month'),
        ],
      ),
    );
  }

  Widget _buildPeriodChip(String label, String period) {
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
      selected: _selectedPeriod == period,
      selectedColor: Colors.blue.shade800,
      labelStyle: TextStyle(
        color: _selectedPeriod == period ? Colors.white : Colors.black87,
      ),
      onSelected: (selected) {
        if (selected) {
          setState(() {
            _selectedPeriod = period;
          });
          _loadRealStatistics();
        }
      },
    );
  }

  Widget _buildSummaryCards() {
    return Container(
      padding: EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildSummaryCard(
              '💰',
              'Tổng chi phí',
              _formatCurrency(_totalCost),
              Colors.green,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              '⚡',
              'Điện năng',
              '${_totalPower.toStringAsFixed(1)} kWh',
              Colors.orange,
            ),
          ),
          SizedBox(width: 12),
          Expanded(
            child: _buildSummaryCard(
              '📊',
              'Thiết bị',
              '$_totalDevices',
              Colors.blue,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String emoji, String title, String value, Color color) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: TextStyle(fontSize: 24)),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 6),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceStatsCard(DeviceUsage usage) {
    return Card(
      margin: EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: _getDeviceColor(usage.deviceType).withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      _getDeviceEmoji(usage.deviceType),
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        usage.deviceName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade800,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        _getDeviceTypeText(usage.deviceType),
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatCurrency(usage.cost),
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      '${usage.powerConsumption.toStringAsFixed(1)} kWh',
                      style: TextStyle(
                        color: Colors.orange.shade700,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: 16),

            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: Colors.grey.shade200, width: 1),
                  bottom: BorderSide(color: Colors.grey.shade200, width: 1),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('🔄', 'Số lần bật', '${usage.turnOnCount}'),
                  _buildStatItem('⏱️', 'Thời gian', '${usage.totalUsageHours.toStringAsFixed(1)}h'),
                  _buildStatItem('💡', 'Công suất', '${_getDevicePower(usage.deviceType)}W'),
                ],
              ),
            ),

            SizedBox(height: 16),

            if (usage.totalUsageHours > 0) _buildUsageProgressBar(usage.totalUsageHours),

            SizedBox(height: 16),

            if (usage.usageData.isNotEmpty) ...[
              Text(
                'Lịch sử sử dụng:',
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade700,
                  fontSize: 14,
                ),
              ),
              SizedBox(height: 8),
              ...usage.usageData.map((usageItem) => _buildUsageItem(usageItem)).toList(),
            ] else ...[
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16, color: Colors.grey.shade600),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Chưa có lịch sử sử dụng trong khoảng thời gian này',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String emoji, String label, String value) {
    return Column(
      children: [
        Text(emoji, style: TextStyle(fontSize: 20)),
        SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            color: Colors.grey.shade600,
            fontWeight: FontWeight.w500,
          ),
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade800,
          ),
        ),
      ],
    );
  }

  Widget _buildUsageProgressBar(double hours) {
    double maxHours = 24.0;
    double percentage = (hours / maxHours).clamp(0.0, 1.0);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Thời gian sử dụng:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '${hours.toStringAsFixed(1)}h / 24h',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: Colors.grey.shade700,
              ),
            ),
          ],
        ),
        SizedBox(height: 6),
        Container(
          height: 8,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey.shade300,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Stack(
            children: [
              AnimatedContainer(
                duration: Duration(milliseconds: 500),
                curve: Curves.easeOut,
                width: MediaQuery.of(context).size.width * percentage,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      _getProgressColor(percentage),
                      _getProgressColor(percentage).withOpacity(0.8),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsageItem(Map<String, dynamic> usage) {
    return Container(
      margin: EdgeInsets.only(bottom: 6),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.blue.shade100, width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.access_time, size: 16, color: Colors.blue.shade600),
          SizedBox(width: 8),
          Text(
            '${usage['time']}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade700,
            ),
          ),
          Spacer(),
          Text(
            '${usage['duration']} giờ',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.blue.shade800,
            ),
          ),
        ],
      ),
    );
  }

  // Helper methods
  Color _getDeviceColor(String deviceType) {
    switch (deviceType) {
      case 'light': return Colors.yellow.shade600;
      case 'fan': return Colors.blue.shade600;
      case 'ac': return Colors.red.shade600;
      case 'door': return Colors.green.shade600;
      case 'socket': return Colors.purple.shade600;
      default: return Colors.grey.shade600;
    }
  }

  String _getDeviceEmoji(String deviceType) {
    switch (deviceType) {
      case 'light': return '💡';
      case 'fan': return '🌀';
      case 'ac': return '❄️';
      case 'door': return '🚪';
      case 'socket': return '🔌';
      default: return '⚙️';
    }
  }

  String _getDeviceTypeText(String deviceType) {
    switch (deviceType) {
      case 'light': return 'Đèn';
      case 'fan': return 'Quạt';
      case 'ac': return 'Điều hòa';
      case 'door': return 'Cửa';
      case 'socket': return 'Ổ cắm';
      default: return 'Thiết bị';
    }
  }

  String _getDevicePower(String deviceType) {
    switch (deviceType) {
      case 'light': return '15';
      case 'fan': return '50';
      case 'ac': return '1200';
      case 'door': return '5';
      case 'socket': return '100';
      default: return '10';
    }
  }

  Color _getProgressColor(double percentage) {
    if (percentage < 0.3) return Colors.green;
    if (percentage < 0.7) return Colors.orange;
    return Colors.red;
  }

  String _formatCurrency(double amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M đ';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(1)}K đ';
    }
    return '${amount.toStringAsFixed(0)} đ';
  }
}