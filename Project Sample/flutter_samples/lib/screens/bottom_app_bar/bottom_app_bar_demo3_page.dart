import 'package:flutter/material.dart';
import 'dart:math' as math;

class BottomAppBarDemo3Page extends StatelessWidget {
  const BottomAppBarDemo3Page({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('ClipRRect + BottomAppBar')),
      // Nội dung chính của trang
      body: Stack(
        children: [
          Center(
            child: Text(
              'Nội dung trang',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ),
        ],
      ),
      bottomNavigationBar: // Đặt thanh điều hướng nổi ở dưới cùng
      Container(
        // Khoảng trống để tạo hiệu ứng nổi
        margin: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        // Đổ bóng cho đẹp
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          // Bo tròn các góc
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: BottomAppBar(
            color: Colors.white,
            // Shape để tạo ra cái "khuyết"
            shape: const CircularNotchedRectangle(),
            // Khoảng cách giữa FAB và thanh bar
            notchMargin: 10.0,
            child: Row(
              // Căn chỉnh các icon
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                IconButton(
                  icon: const Icon(Icons.home_filled, color: Colors.pink),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.bar_chart_rounded, color: Colors.grey),
                  onPressed: () {},
                ),
                // Thêm một SizedBox để tạo khoảng trống cho FAB ở giữa
                const SizedBox(width: 40),
                IconButton(
                  icon: const Icon(Icons.notifications, color: Colors.grey),
                  onPressed: () {},
                ),
                IconButton(
                  icon: const Icon(Icons.person, color: Colors.grey),
                  onPressed: () {},
                ),
              ],
            ),
          ),
        ),
      ),
      // Đặt FAB ở đây để nó có thể nằm trên BottomAppBar
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: Colors.pink,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      // Vị trí này sẽ đặt FAB ở giữa và "cắm" vào BottomAppBar
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

// Lớp shape tùy chỉnh hình thang
class TrapezoidNotchedRectangle extends NotchedShape {
  const TrapezoidNotchedRectangle();

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    // Tọa độ của FAB
    final double fabX = guest.center.dx;
    final double fabY = guest.top;
    final double fabRadius = guest.width / 2.0;

    // Kích thước của vết khuyết hình thang
    final double notchWidth = fabRadius * 2.5; // Rộng hơn FAB một chút
    final double notchDepth = fabRadius * 0.6; // Nông hơn hình tròn

    final Path path = Path();

    // Bắt đầu vẽ từ góc trên bên trái của BottomAppBar
    path.moveTo(host.left, host.top);

    // Vẽ đường thẳng đến điểm bắt đầu của vết khuyết
    path.lineTo(fabX - notchWidth / 2, host.top);

    // Vẽ cạnh chéo xuống của hình thang
    path.lineTo(fabX - fabRadius, fabY + notchDepth);

    // Vẽ cạnh đáy của hình thang (có thể là đường cong hoặc thẳng)
    path.lineTo(fabX + fabRadius, fabY + notchDepth);

    // Vẽ cạnh chéo lên của hình thang
    path.lineTo(fabX + notchWidth / 2, host.top);

    // Vẽ nốt phần còn lại của cạnh trên BottomAppBar
    path.lineTo(host.right, host.top);

    // Vẽ các cạnh còn lại của BottomAppBar
    path.lineTo(host.right, host.bottom);
    path.lineTo(host.left, host.bottom);

    path.close();
    return path;
  }
}

class CustomDiamondNotch extends NotchedShape {
  const CustomDiamondNotch();

  @override
  Path getOuterPath(Rect host, Rect? guest) {
    if (guest == null || !host.overlaps(guest)) {
      return Path()..addRect(host);
    }

    // Calculate the intersection of the host and guest
    final Rect intersection = host.intersect(guest);

    // Define the path for a diamond-shaped notch
    final Path path = Path();
    path.moveTo(host.left, host.top);
    path.lineTo(
      intersection.left + intersection.width / 2,
      host.top,
    ); // Top point of the diamond
    path.lineTo(
      guest.left,
      intersection.center.dy,
    ); // Left point of the diamond
    path.lineTo(
      intersection.left + intersection.width / 2,
      guest.bottom,
    ); // Bottom point of the diamond
    path.lineTo(
      guest.right,
      intersection.center.dy,
    ); // Right point of the diamond
    path.lineTo(
      intersection.left + intersection.width / 2,
      host.top,
    ); // Back to top point
    path.lineTo(host.right, host.top);
    path.lineTo(host.right, host.bottom);
    path.lineTo(host.left, host.bottom);
    path.close();
    return path;
  }
}
