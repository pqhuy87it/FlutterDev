import 'package:flutter/material.dart';
import 'dart:io';
import 'package:flutter_logs/flutter_logs.dart';
import 'package:path_provider/path_provider.dart';

void initLogs() {
  //Initialize Logging
  // FlutterLogs.initLogs(
  //   logLevelsEnabled: [
  //     LogLevel.INFO,
  //     LogLevel.WARNING,
  //     LogLevel.ERROR,
  //     LogLevel.SEVERE,
  //   ],
  //   timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
  //   directoryStructure: DirectoryStructure.FOR_DATE,
  //   logTypesEnabled: [
  //     "shared_preferences_logs",
  //     "secure_storage_logs",
  //     "press_login_flow_logs",
  //   ],
  //   logFileExtension: LogFileExtension.LOG,
  //   logsWriteDirectoryName: "AppLogs",
  //   logsExportDirectoryName: "AppLogs/Exported",
  //   debugFileOperations: true,
  //   isDebuggable: true,
  //   enabled: true,
  // );
  FlutterLogs.initLogs(
    timeStampFormat: TimeStampFormat.TIME_FORMAT_READABLE,
    directoryStructure: DirectoryStructure.FOR_DATE,
    logTypesEnabled: [
      "shared_preferences_logs",
      "secure_storage_logs",
      "press_login_flow_logs",
    ],
    logFileExtension: LogFileExtension.LOG
  );
}

void main() {
  initLogs();
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
  void getAppFolderPath() async {
    Directory? externalDirectory;

    if (Platform.isIOS) {
      externalDirectory = await getApplicationDocumentsDirectory();
    } else {
      externalDirectory = await getExternalStorageDirectory();
    }

    File file = File("${externalDirectory!.path}/");

    print("App folder path is: ${file.path.toString()}");
  }

  @override
  void initState() {
    getAppFolderPath();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text('Test write log to folder'),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  writeSharedPreferenceLogs('Class A', 'Method A', 'Test log');
                },
                child: Text('Write Shared Preferences logs'),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  writeSecureStorageLogs('Class A', 'Method A', 'Test log');
                },
                child: Text('Write Secure Storage logs'),
              ),
            ),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.only(left: 10.0, right: 10.0),
              child: ElevatedButton(
                onPressed: () {
                  writeLoginFlowLogs('Class A', 'Method A', 'Test log');
                },
                child: Text('Write Login Flow logs'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void writeSharedPreferenceLogs(
    String className,
    String methodName,
    String message,
  ) {
    var logMessage =
        "Class Name: ${className}, Method Name: ${methodName}, Message: ${message}";
    FlutterLogs.logToFile(
      logFileName: "shared_preferences_logs",
      overwrite: false,
      logMessage: logMessage,
      appendTimeStamp: false,
    );
  }

  void writeSecureStorageLogs(
      String className,
      String methodName,
      String message,
      ) {
    var logMessage =
        "Class Name: ${className}, Method Name: ${methodName}, Message: ${message}";
    FlutterLogs.logToFile(
      logFileName: "secure_storage_logs",
      overwrite: false,
      logMessage: logMessage,
      appendTimeStamp: false,
    );
  }

  void writeLoginFlowLogs(
      String className,
      String methodName,
      String message,
      ) {
    var logMessage =
        "Class Name: ${className}, Method Name: ${methodName}, Message: ${message}";
    FlutterLogs.logToFile(
      logFileName: "press_login_flow_logs",
      overwrite: false,
      logMessage: logMessage,
      appendTimeStamp: false,
    );
  }
}
