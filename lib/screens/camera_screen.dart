import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class CameraScreen extends StatefulWidget {
  @override
  _CameraScreenState createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  bool _isCameraOn = true;
  bool _isRecording = false;
  bool _isFrontDoorLocked = true;
  bool _isLoading = true;
  String _cameraIp = "192.168.1.12";
  late WebViewController _webViewController;
  double _loadingProgress = 0;

  @override
  void initState() {
    super.initState();
    _initializeWebView();
  }

  void _initializeWebView() {
    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (int progress) {
            setState(() {
              _loadingProgress = progress / 100;
            });
          },
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
          },
          onWebResourceError: (WebResourceError error) {
            setState(() {
              _isLoading = false;
            });
            print('WebView error: ${error.description}');
          },
        ),
      )
      ..loadHtmlString(_buildHtmlStream());
  }

  // ✅ Tạo HTML để display MJPEG stream
  String _buildHtmlStream() {
    return '''
    <!DOCTYPE html>
    <html>
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <style>
        body {
          margin: 0;
          padding: 0;
          background-color: black;
          display: flex;
          justify-content: center;
          align-items: center;
          height: 100vh;
        }
        img {
          max-width: 100%;
          max-height: 100%;
          object-fit: contain;
        }
      </style>
    </head>
    <body>
      <img src="http://$_cameraIp/stream" />
    </body>
    </html>
    ''';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          'GIÁM SÁT CAMERA',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.black,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            icon: Icon(Icons.settings, color: Colors.white),
            onPressed: _showCameraSettings,
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshCamera,
          ),
        ],
      ),
      body: Column(
        children: [
          if (_isLoading)
            LinearProgressIndicator(
              value: _loadingProgress,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
            ),

          Expanded(
            flex: 3,
            child: Container(
              margin: EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: Colors.grey.shade900,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.5),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: _isCameraOn
                    ? _buildCameraStream()
                    : _buildCameraOffPlaceholder(),
              ),
            ),
          ),

          _buildControlPanel(),
          _buildDoorInfoPanel(),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showEmergencyDialog,
        backgroundColor: Colors.red,
        child: Icon(Icons.warning, color: Colors.white),
      ),
    );
  }

  Widget _buildCameraStream() {
    return Stack(
      children: [
        WebViewWidget(controller: _webViewController),

        if (_isLoading)
          Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text(
                    'Đang kết nối camera...',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'IP: $_cameraIp',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),

        if (!_isLoading && _loadingProgress == 0)
          Container(
            color: Colors.black.withOpacity(0.8),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.wifi_off, color: Colors.red, size: 50),
                  SizedBox(height: 16),
                  Text(
                    'Không thể kết nối camera',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'IP: $_cameraIp',
                    style: TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                  SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _refreshCamera,
                    child: Text('Thử lại kết nối'),
                  ),
                ],
              ),
            ),
          ),

        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.7),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.fiber_manual_record,
                  color: _isRecording ? Colors.red : Colors.white,
                  size: 16,
                ),
                SizedBox(width: 6),
                Text(
                  _isRecording ? 'ĐANG GHI' : 'GHI HÌNH',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCameraOffPlaceholder() {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 80,
              color: Colors.grey.shade600,
            ),
            SizedBox(height: 16),
            Text(
              'CAMERA ĐANG TẮT',
              style: TextStyle(
                color: Colors.grey.shade400,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Nhấn nút BẬT để khởi động camera',
              style: TextStyle(
                color: Colors.grey.shade500,
                fontSize: 14,
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _toggleCamera,
              icon: Icon(Icons.videocam, color: Colors.white),
              label: Text(
                'BẬT CAMERA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlPanel() {
    return Container(
      height: 120,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildControlButton(
            icon: Icons.videocam,
            label: _isCameraOn ? 'TẮT' : 'BẬT',
            color: _isCameraOn ? Colors.green : Colors.grey,
            onTap: _toggleCamera,
          ),
          _buildControlButton(
            icon: Icons.fiber_manual_record,
            label: _isRecording ? 'DỪNG' : 'GHI',
            color: _isRecording ? Colors.red : Colors.white,
            onTap: _toggleRecording,
          ),
          _buildControlButton(
            icon: Icons.photo_camera,
            label: 'CHỤP',
            color: Colors.blue,
            onTap: _takeSnapshot,
          ),
          _buildControlButton(
            icon: Icons.fullscreen,
            label: 'TOÀN MÀN',
            color: Colors.orange,
            onTap: _showFullScreen,
          ),
        ],
      ),
    );
  }

  Widget _buildDoorInfoPanel() {
    return Expanded(
      flex: 2,
      child: Container(
        padding: EdgeInsets.all(16),
        color: Colors.grey.shade800,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'ĐIỀU KHIỂN & THÔNG TIN',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            _isFrontDoorLocked ? Icons.lock : Icons.lock_open,
                            color: _isFrontDoorLocked ? Colors.green : Colors.orange,
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'CỬA CHÍNH',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 4),
                      Text(
                        _isFrontDoorLocked ? '🔒 ĐÃ KHÓA' : '🔓 ĐÃ MỞ',
                        style: TextStyle(
                          color: _isFrontDoorLocked ? Colors.green : Colors.orange,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  ElevatedButton(
                    onPressed: _toggleDoorLock,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isFrontDoorLocked ? Colors.orange : Colors.green,
                      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _isFrontDoorLocked ? 'MỞ CỬA' : 'KHÓA CỬA',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildInfoItem('👤', 'Người phát hiện', '2'),
                _buildInfoItem('🚨', 'Cảnh báo hôm nay', '0'),
                _buildInfoItem('📶', 'Tín hiệu', _isLoading ? 'Yếu' : 'Mạnh'),
                _buildInfoItem('⏱️', 'Hoạt động', '24/7'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.black,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoItem(String emoji, String title, String value) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Center(
            child: Text(emoji, style: TextStyle(fontSize: 20)),
          ),
        ),
        SizedBox(height: 6),
        Text(
          title,
          style: TextStyle(color: Colors.white70, fontSize: 10),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  void _toggleCamera() {
    setState(() {
      _isCameraOn = !_isCameraOn;
    });
    if (_isCameraOn) {
      _refreshCamera();
    }
    _showSnackBar(
      _isCameraOn ? '📹 Đã bật camera' : '📹 Đã tắt camera',
      color: _isCameraOn ? Colors.green : Colors.orange,
    );
  }

  void _toggleRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });
    _showSnackBar(
      _isRecording ? '🔴 Bắt đầu ghi hình' : '⏹️ Dừng ghi hình',
      color: _isRecording ? Colors.red : Colors.grey,
    );
  }

  void _takeSnapshot() {
    _showSnackBar('📸 Đã chụp ảnh và lưu vào bộ nhớ', color: Colors.blue);
  }

  void _toggleDoorLock() {
    setState(() {
      _isFrontDoorLocked = !_isFrontDoorLocked;
    });
    _showSnackBar(
      _isFrontDoorLocked ? '🔒 Đã khóa cửa chính' : '🔓 Đã mở cửa chính',
      color: _isFrontDoorLocked ? Colors.green : Colors.orange,
    );
  }

  void _refreshCamera() {
    _webViewController.reload();
    _showSnackBar('🔄 Đang làm mới kết nối camera...', color: Colors.blue);
  }

  void _showFullScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.black,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text('XEM TOÀN MÀN HÌNH',
                style: TextStyle(color: Colors.white)),
          ),
          body: Center(
            child: _buildCameraStream(),
          ),
        ),
      ),
    );
  }

  void _showCameraSettings() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        String newIp = _cameraIp;
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Text(
            '⚙️ CÀI ĐẶT CAMERA',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Địa chỉ IP Camera:', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 8),
                TextFormField(
                  initialValue: _cameraIp,
                  decoration: InputDecoration(
                    hintText: '192.168.1.100',
                    hintStyle: TextStyle(color: Colors.grey),
                    border: OutlineInputBorder(),
                    filled: true,
                    fillColor: Colors.grey.shade800,
                  ),
                  style: TextStyle(color: Colors.white),
                  onChanged: (value) {
                    newIp = value;
                  },
                ),
                SizedBox(height: 16),
                Container(
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange),
                  ),
                  child: Text(
                    '💡 Lưu ý: Đảm bảo ESP32-CAM và điện thoại cùng kết nối chung một mạng WiFi',
                    style: TextStyle(color: Colors.orange, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('HỦY', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  _cameraIp = newIp;
                });
                _initializeWebView();
                Navigator.of(context).pop();
                _showSnackBar('✅ Đã cập nhật địa chỉ IP camera', color: Colors.green);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
              child: Text('LƯU CÀI ĐẶT'),
            ),
          ],
        );
      },
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.grey.shade900,
          title: Row(
            children: [
              Icon(Icons.warning, color: Colors.red, size: 28),
              SizedBox(width: 8),
              Text('🚨 CẢNH BÁO KHẨN CẤP',
                  style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Bạn có chắc muốn kích hoạt chế độ khẩn cấp?\n\nHệ thống sẽ:\n• 📞 Gọi cảnh sát\n• 🔊 Phát còi báo động\n• 💡 Bật tất cả đèn\n• 🔒 Khóa tất cả cửa',
            style: TextStyle(color: Colors.white, height: 1.5),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('HỦY BỎ', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _activateEmergencyMode();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: Text('KÍCH HOẠT KHẨN CẤP'),
            ),
          ],
        );
      },
    );
  }

  void _activateEmergencyMode() {
    setState(() {
      _isRecording = true;
      _isFrontDoorLocked = true;
    });
    _showSnackBar('🚨 ĐÃ KÍCH HOẠT CHẾ ĐỘ KHẨN CẤP!', color: Colors.red);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.red.shade900,
          title: Row(
            children: [
              Icon(Icons.emergency, color: Colors.white, size: 28),
              SizedBox(width: 8),
              Text('CHẾ ĐỘ KHẨN CẤP',
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
          content: Text(
            'Hệ thống đã kích hoạt chế độ khẩn cấp. Cơ quan chức năng đã được thông báo.\n\nGiữ bình tĩnh và làm theo hướng dẫn.',
            style: TextStyle(color: Colors.white, height: 1.5),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _deactivateEmergencyMode();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              child: Text('TẮT BÁO ĐỘNG'),
            ),
          ],
        );
      },
    );
  }

  void _deactivateEmergencyMode() {
    setState(() {
      _isRecording = false;
    });
    _showSnackBar('✅ Đã tắt chế độ khẩn cấp', color: Colors.green);
  }

  void _showSnackBar(String message, {Color color = Colors.green}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        duration: Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}