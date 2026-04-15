import 'package:flutter/material.dart';
import 'service_locator.dart';
import 'user_service.dart';

void main() {
  setupLocator();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  // Lấy instance của UserService từ get_it
  final UserService _userService = getIt<UserService>();

  // Hoặc ngắn gọn hơn: final _userService = getIt.get<UserService>();

  String _userName = 'Loading...';

  @override
  void initState() {
    super.initState();
      _fetchUser();
  }

  void _fetchUser() async {
    final name = await _userService.getUserName();
    setState(() {
      _userName = name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('GetIt Demo')),
      body: Center(
        child: Text(
          'Hello, $_userName!',
          style: Theme.of(context).textTheme.headlineMedium,
        ),
      ),
    );
  }
}
