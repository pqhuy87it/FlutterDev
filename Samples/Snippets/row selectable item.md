# 1.Dartpad
[DartPad](https://dartpad.dev/345f85d3cf6c6faa296c84fa2c9825a0)

# 2.Layout
<img width="866" height="1208" alt="CleanShot 2025-11-23 at 15 23 32@2x" src="https://github.com/user-attachments/assets/51c56b16-d990-40f1-b593-a714007504f4" />

# 3.Code
```dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Màu nền xám nhạt tổng thể
        fontFamily: 'Arial', // Hoặc font mặc định
        useMaterial3: true,
      ),
      home: const TaskListScreen(),
    );
  }
}

// 1. MODEL DỮ LIỆU
class Task {
  final String dayNumber;
  final String dayName;
  final String title;
  final String subtitle;
  final bool isCompleted;
  final bool showDate; // Biến này để quyết định có hiện ô ngày tháng bên trái hay không
  final bool isToday;  // Biến này để tô màu xanh cho ngày hiện tại

  Task({
    required this.dayNumber,
    required this.dayName,
    required this.title,
    required this.subtitle,
    this.isCompleted = false,
    this.showDate = false,
    this.isToday = false,
  });
}

class TaskListScreen extends StatefulWidget {
  const TaskListScreen({super.key});

  @override
  State<TaskListScreen> createState() => _TaskListScreenState();
}

class _TaskListScreenState extends State<TaskListScreen> {
  // 2. DỮ LIỆU GIẢ LẬP (Giống hệt trong ảnh)
  final List<Task> tasks = [
    Task(
      dayNumber: "1", dayName: "Tue",
      title: "Design Interview <> Roman Kamu...",
      subtitle: "Don't know how to grow",
      isCompleted: true, showDate: true,
    ),
    Task(
      dayNumber: "1", dayName: "Tue",
      title: "Weekly Product Sync <> Floyd",
      subtitle: "4:15 AM — 5:30 AM",
      isCompleted: true, showDate: false, // Cùng ngày nên không hiện lại ngày
    ),
    Task(
      dayNumber: "2", dayName: "Wed",
      title: "Project Discussion <> Remote tea...",
      subtitle: "12:30 AM — 00:30 PM",
      isCompleted: false, showDate: true, isToday: true, // Ngày hiện tại (Màu xanh)
    ),
    Task(
      dayNumber: "2", dayName: "Wed",
      title: "Daily Project Collab <> Big Mike",
      subtitle: "8:00 AM — 8:00 PM",
      isCompleted: false, showDate: false,
    ),
    Task(
      dayNumber: "2", dayName: "Wed",
      title: "Project Discussion <> Local team",
      subtitle: "12:00 AM — 12:30 AM",
      isCompleted: false, showDate: false,
    ),
    Task(
      dayNumber: "3", dayName: "Thu",
      title: "Jessica Pixless Seminar #2",
      subtitle: "10:30 AM — 6:15 PM",
      isCompleted: false, showDate: true,
    ),
    Task(
      dayNumber: "4", dayName: "Fri",
      title: "Product Meetup <> Main office",
      subtitle: "12:30 AM — 00:30 PM",
      isCompleted: false, showDate: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: tasks.length,
          itemBuilder: (context, index) {
            return TaskItem(task: tasks[index]);
          },
        ),
      ),
    );
  }
}

// 3. WIDGET ITEM (CARD)
class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  @override
  Widget build(BuildContext context) {
    // Màu nền Card: Nếu xong là xám đậm, chưa xong là trắng
    final backgroundColor = task.isCompleted ? const Color(0xFFE0E0E0) : Colors.white;
    
    // Kiểu chữ: Nếu xong thì gạch ngang và màu xám, chưa xong thì màu đen đậm
    final titleStyle = TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
      color: task.isCompleted ? Colors.grey[600] : Colors.black,
    );

    final subtitleStyle = TextStyle(
      fontSize: 14,
      color: Colors.grey[600],
      decoration: task.isCompleted ? TextDecoration.lineThrough : TextDecoration.none,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12), // Padding bên trong card
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: task.isCompleted 
            ? [] // Task xong thì không đổ bóng (làm chìm đi)
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                )
              ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // --- PHẦN NGÀY THÁNG (BÊN TRÁI) ---
          if (task.showDate) ...[
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                // Nếu là hôm nay (isToday) thì màu xanh, còn lại màu xám
                color: task.isToday ? const Color(0xFFA5D6A7) : const Color(0xFFBDBDBD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    task.dayNumber,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  Text(
                    task.dayName,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: Colors.black54,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
          ] else ...[
            // Nếu không hiện ngày, vẫn cần khoảng trống (hoặc không, tùy design)
            // Trong ảnh, item thứ 2 không có khoảng trống của ngày, text thụt vào
            // nên ta không cần SizedBox giữ chỗ.
          ],

          // --- PHẦN NỘI DUNG (GIỮA) ---
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: titleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  task.subtitle,
                  style: subtitleStyle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          const SizedBox(width: 12),

          // --- PHẦN CHECKBOX (BÊN PHẢI) ---
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: task.isCompleted ? const Color(0xFF5C6BC0) : Colors.transparent, // Màu xanh tím khi checked
              border: Border.all(
                color: task.isCompleted ? const Color(0xFF5C6BC0) : Colors.grey,
                width: 2,
              ),
            ),
            child: task.isCompleted
                ? const Icon(Icons.check, size: 18, color: Colors.white)
                : null,
          ),
        ],
      ),
    );
  }
}
```
