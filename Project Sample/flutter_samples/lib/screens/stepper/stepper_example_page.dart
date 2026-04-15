import 'package:flutter/material.dart';

class StepperExamplePage extends StatefulWidget {
  static String routeName = 'basics/stepper_example';

  const StepperExamplePage({super.key});

  @override
  State<StepperExamplePage> createState() => _StepperExamplePageState();
}

class _StepperExamplePageState extends State<StepperExamplePage> {
  // Biến quản lý bước hiện tại
  int _currentStep = 0;

  // GlobalKeys để validate các Form
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>()
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Flutter Stepper Demo'),
      ),
      body: Stepper(
        // Loại Stepper: vertical hoặc horizontal
        type: StepperType.vertical,
        // Bước hiện tại
        currentStep: _currentStep,
        // Callback khi nhấn vào một bước
        onStepTapped: (step) => setState(() => _currentStep = step),
        // Callback khi nhấn nút Continue
        onStepContinue: () {
          // Validate form của bước hiện tại
          if (_formKeys[_currentStep].currentState!.validate()) {
            // Nếu chưa phải bước cuối cùng
            if (_currentStep < _getSteps().length - 1) {
              setState(() {
                _currentStep += 1;
              });
            } else {
              // Đây là bước cuối cùng, xử lý hoàn tất
              print('Hoàn thành tất cả các bước!');
              // Ví dụ: gửi dữ liệu lên server
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Đăng ký thành công!')),
              );
            }
          }
        },
        // Callback khi nhấn nút Cancel
        onStepCancel: () {
          if (_currentStep > 0) {
            setState(() {
              _currentStep -= 1;
            });
          }
        },
        // Danh sách các bước
        steps: _getSteps(),
        // Tùy chỉnh các nút điều khiển
        controlsBuilder: (BuildContext context, ControlsDetails details) {
          return Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: <Widget>[
                ElevatedButton(
                  onPressed: details.onStepContinue,
                  child: Text(_currentStep == _getSteps().length - 1 ? 'XÁC NHẬN' : 'TIẾP TỤC'),
                ),
                // Chỉ hiển thị nút 'QUAY LẠI' nếu không phải là bước đầu tiên
                if (_currentStep != 0)
                  TextButton(
                    onPressed: details.onStepCancel,
                    child: const Text('QUAY LẠI'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  // Hàm trả về danh sách các Step
  List<Step> _getSteps() {
    return [
      // Bước 1: Thông tin tài khoản
      Step(
        title: const Text('Tài khoản'),
        content: Form(
          key: _formKeys[0],
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập email';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mật khẩu'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập mật khẩu';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        // Bước này đang active nếu _currentStep là 0
        isActive: _currentStep >= 0,
        // Trạng thái của bước
        state: _currentStep > 0 ? StepState.complete : StepState.indexed,
      ),
      // Bước 2: Thông tin cá nhân
      Step(
        title: const Text('Thông tin cá nhân'),
        content: Form(
          key: _formKeys[1],
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Họ và tên'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập họ và tên';
                  }
                  return null;
                },
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Địa chỉ'),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập địa chỉ';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        isActive: _currentStep >= 1,
        state: _currentStep > 1 ? StepState.complete : StepState.indexed,
      ),
      // Bước 3: Xác nhận
      Step(
        title: const Text('Xác nhận'),
        content: Form(
          key: _formKeys[2],
          child: Center(
            child: Text('Vui lòng kiểm tra lại thông tin và xác nhận.'),
          ),
        ),
        isActive: _currentStep >= 2,
        state: _currentStep > 2 ? StepState.complete : StepState.indexed,
      ),
    ];
  }
}
