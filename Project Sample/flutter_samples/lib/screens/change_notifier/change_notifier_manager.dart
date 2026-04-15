import 'package:flutter/material.dart';
import 'package:project_samples/utils/color.dart';

class ChangeNotifierManager extends StatefulWidget {
  const ChangeNotifierManager({super.key});

  @override
  State<ChangeNotifierManager> createState() => _ChangeNotifierManagerState();
}

class _ChangeNotifierManagerState extends State<ChangeNotifierManager>
    with ChangeNotifierMixin<ChangeNotifierManager> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  final FocusNode _usernameFocusNode = FocusNode();
  final FocusNode _passwordFocusNode = FocusNode();

  Color? primaryColor = Colors.lightBlueAccent;
  Color? backgroundColor = Colors.white;
  AssetImage backgroundImage = const AssetImage("assets/images/full-bloom.png");
  bool _btnLoginEnable = false;

  @override
  Map<ChangeNotifier, List<VoidCallback>?>? changeNotifier() {
    final List<VoidCallback> callbacks = <VoidCallback>[_verify];
    return <ChangeNotifier, List<VoidCallback>?>{
      _usernameController: callbacks,
      _passwordController: callbacks,
      _usernameFocusNode: null,
      _passwordFocusNode: null,
    };
  }

  void _verify() {
    final String username = _usernameController.text;
    final String password = _passwordController.text;

    bool btnLoginEnable = true;

    if (username.isEmpty || username.length < 10) {
      btnLoginEnable = false;
    }

    if (password.isEmpty || password.length < 8) {
      btnLoginEnable = false;
    }

    if (btnLoginEnable != _btnLoginEnable) {
      setState(() {
        _btnLoginEnable = btnLoginEnable;
      });
    }
  }

  void _login() {}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          decoration: BoxDecoration(color: backgroundColor),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              _buildHeaderImage(),
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Text(
                  "Email",
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                ),
              ),
              _buildEmailInputTextField(),
              Padding(
                padding: const EdgeInsets.only(left: 40.0),
                child: Text(
                  "Password",
                  style: TextStyle(color: Colors.grey, fontSize: 16.0),
                ),
              ),
              _buildPasswordInputTextField(),
              _buildLoginWithFacebookButton(),
              _buildLoginButton(),
              _buildDontHaveAccountButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderImage() {
    return Expanded(
      child: ClipPath(
        clipper: MyClipper(),
        child: Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: backgroundImage,
              fit: BoxFit.cover,
            ),
          ),
          alignment: Alignment.center,
          padding: EdgeInsets.only(top: 100.0, bottom: 100.0),
          child: Column(
            children: <Widget>[
              Text(
                "DEMO",
                style: TextStyle(
                  fontSize: 50.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
              Text(
                "Login Screen",
                style: TextStyle(
                  fontSize: 20.0,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmailInputTextField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withAlphas(0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 20.0,
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 15.0,
            ),
            child: Icon(Icons.person_outline, color: Colors.grey),
          ),
          Container(
            height: 30.0,
            width: 1.0,
            color: Colors.grey.withAlphas(0.5),
            margin: const EdgeInsets.only(left: 00.0, right: 10.0),
          ),
          Expanded(
            child: TextField(
              controller: _usernameController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your email',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPasswordInputTextField() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.grey.withAlphas(0.5),
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(20.0),
      ),
      margin: const EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 20.0,
      ),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 15.0,
            ),
            child: Icon(Icons.lock_open, color: Colors.grey),
          ),
          Container(
            height: 30.0,
            width: 1.0,
            color: Colors.grey.withAlphas(0.5),
            margin: const EdgeInsets.only(left: 00.0, right: 10.0),
          ),
          Expanded(
            child: TextField(
              controller: _passwordController,
              decoration: InputDecoration(
                border: InputBorder.none,
                hintText: 'Enter your password',
                hintStyle: TextStyle(color: Colors.grey),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginWithFacebookButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: TextButton(
              onPressed: () {
                // Xử lý logic khi nhấn nút ở đây
              },
              style: TextButton.styleFrom(
                backgroundColor: const Color(
                  0xff3B5998,
                ), // Tương đương với 'color'
                foregroundColor:
                Colors.white, // Màu cho chữ và icon bên trong
                padding: EdgeInsets
                    .zero, // Bỏ padding mặc định để tự kiểm soát layout
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30.0),
                ),
                // Hiệu ứng splash color (khi nhấn giữ)
                overlayColor: Colors.white.withAlphas(0.1),
              ),
              child: Row(
                children: <Widget>[
                  const Padding(
                    padding: EdgeInsets.only(left: 20.0),
                    child: Text(
                      "LOGIN WITH FACEBOOK",
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                  Expanded(child: Container()),
                  Transform.translate(
                    offset: const Offset(-5.0, 0.0),
                    child: TextButton(
                      onPressed: () => {},
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28.0),
                        ),
                        overlayColor: Colors.white,
                      ),
                      child: const Icon(
                        IconData(0x0066, fontFamily: 'icomoon'),
                        color: Color(0xff3b5998),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginButton() {
    return Container(
      margin: const EdgeInsets.only(top: 10.0),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              children: <Widget>[
                Expanded(
                  child: TextButton(
                    onPressed: _btnLoginEnable ? _login : null,
                    style: TextButton.styleFrom(
                      backgroundColor:
                      _btnLoginEnable? primaryColor : Colors.grey, // Tương đương với 'color'
                      foregroundColor: Colors
                          .white, // Màu cho chữ và icon bên trong
                      padding: EdgeInsets
                          .zero, // Bỏ padding mặc định để tự kiểm soát layout
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30.0),
                      ),
                      // Hiệu ứng splash color (khi nhấn giữ)
                      overlayColor: Colors.white.withAlphas(0.1),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Padding(
                          padding: EdgeInsets.only(left: 20.0),
                          child: Text(
                            "LOGIN",
                            style: TextStyle(color: Colors.white),
                          ),
                        ),
                        Expanded(child: Container()),
                        Transform.translate(
                          offset: const Offset(-5.0, 0.0),
                          child: TextButton(
                            onPressed: () => {},
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                  28.0,
                                ),
                              ),
                              overlayColor: Colors.white,
                            ),
                            child: Icon(
                              Icons.arrow_forward,
                              color: primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDontHaveAccountButton() {
    return Container(
      margin: const EdgeInsets.only(top: 20.0),
      padding: const EdgeInsets.only(left: 20.0, right: 20.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                TextButton(
                  onPressed: () {
                    // Xử lý logic khi nhấn nút ở đây
                  },
                  style: TextButton.styleFrom(
                    backgroundColor:
                    Colors.transparent, // Tương đương với 'color'
                    foregroundColor:
                    Colors.white, // Màu cho chữ và icon bên trong
                    padding: EdgeInsets
                        .zero, // Bỏ padding mặc định để tự kiểm soát layout
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30.0),
                    ),
                    // Hiệu ứng splash color (khi nhấn giữ)
                    overlayColor: Colors.white.withAlphas(0.1),
                  ),
                  child: Row(
                    children: <Widget>[
                      const Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Text(
                          "DON'T HAVE AN ACCOUNT?",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class MyClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path p = Path();
    p.lineTo(size.width, 0.0);
    p.lineTo(size.width, size.height * 0.85);
    p.arcToPoint(
      Offset(0.0, size.height * 0.85),
      radius: const Radius.elliptical(50.0, 10.0),
      rotation: 0.0,
    );
    p.lineTo(0.0, 0.0);
    p.close();
    return p;
  }

  @override
  bool shouldReclip(CustomClipper oldClipper) {
    return true;
  }
}

mixin ChangeNotifierMixin<T extends StatefulWidget> on State<T> {
  Map<ChangeNotifier?, List<VoidCallback>?>? _map;

  Map<ChangeNotifier?, List<VoidCallback>?>? changeNotifier();

  @override
  void initState() {
    _map = changeNotifier();

    /// 遍历数据，如果callbacks不为空则添加监听
    _map?.forEach((changeNotifier, callbacks) {
      if (callbacks != null && callbacks.isNotEmpty) {
        void addListener(VoidCallback callback) {
          changeNotifier?.addListener(callback);
        }

        callbacks.forEach(addListener);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _map?.forEach((changeNotifier, callbacks) {
      if (callbacks != null && callbacks.isNotEmpty) {
        void removeListener(VoidCallback callback) {
          changeNotifier?.removeListener(callback);
        }

        callbacks.forEach(removeListener);
      }
      changeNotifier?.dispose();
    });
    super.dispose();
  }
}
