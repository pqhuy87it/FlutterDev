import 'package:flutter/material.dart';

class InkWellDemo2 extends StatelessWidget {
  const InkWellDemo2({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Tappable Card')),
      body: Center(
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          // Dùng Stack để đặt InkWell lên trên cùng
          child: Stack(
            children: [
              // Nội dung của Card
              Container(
                width: 300,
                height: 200,
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Tiêu đề Card', style: Theme.of(context).textTheme.headlineSmall),
                    SizedBox(height: 8),
                    Text('Đây là nội dung của card. Bạn có thể nhấn vào bất cứ đâu trên card này.'),
                  ],
                ),
              ),
              // Lớp InkWell nằm trên cùng để bắt sự kiện
              Positioned.fill(
                child: Material(
                  color: Colors.transparent, // Phải trong suốt để thấy nội dung bên dưới
                  child: InkWell(
                    borderRadius: BorderRadius.circular(15), // Đồng bộ với shape của Card
                    onTap: () {
                      print('Card được nhấn!');
                    },
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
