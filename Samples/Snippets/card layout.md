[DartPad](https://dartpad.dev/680569bb2002c2da11a7ea167815a6f0)
<img width="1186" height="1320" alt="CleanShot 2025-11-23 at 15 14 50@2x" src="https://github.com/user-attachments/assets/3d5c0c30-300c-44af-80af-ede973848c33" />
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
        scaffoldBackgroundColor: Colors.white,
        fontFamily: 'Arial',
        useMaterial3: true,
      ),
      home: const DashboardScreen(),
    );
  }
}

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const double gap = 16.0;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          // 1. IntrinsicHeight: Chìa khóa để 2 cột cao bằng nhau dựa theo nội dung
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch, // Ép 2 cột giãn full chiều cao
              children: [
                // --- CỘT BÊN TRÁI ---
                Expanded(
                  child: Column(
                    children: [
                      // 1. Explore rewards (Height tự động theo nội dung)
                      _buildCard(
                        color: const Color(0xFFF7F9FC),
                        // Không set height cứng, dùng constraints để có chiều cao tối thiểu
                        constraints: const BoxConstraints(minHeight: 200),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildIconBox(Icons.attach_money, Colors.green, bgColor: const Color(0xFFE0F2F1)),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF5B8DEF),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: const Text("5 new", style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                )
                              ],
                            ),
                            const SizedBox(height: 40), // Khoảng cách mềm
                            const Text("Explore\nrewards", style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, height: 1.1, color: Color(0xFF1A1A1A))),
                            const SizedBox(height: 8),
                            const Text("+182 points", style: TextStyle(color: Color(0xFF5B8DEF), fontWeight: FontWeight.w700, fontSize: 15)),
                          ],
                        ),
                      ),
                      const SizedBox(height: gap),

                      // 2. Credit cards
                      _buildCard(
                        color: const Color(0xFFF7F9FC),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildIconBox(Icons.credit_card, const Color(0xFF5B8DEF), bgColor: const Color(0xFFE3F2FD)),
                            const SizedBox(height: 40),
                            const Text("3 credit cards", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                const Icon(Icons.warning_amber_rounded, size: 16, color: Colors.orange),
                                const SizedBox(width: 4),
                                Expanded(child: Text("Use commercial kits", style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500))),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: gap),

                      // 3. Sun & Folder
                      Row(
                        children: [
                          Expanded(
                            child: _buildCard(
                              color: const Color(0xFFFFF8E1),
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: const Center(child: Icon(Icons.wb_sunny_outlined, color: Colors.black87, size: 36)),
                            ),
                          ),
                          const SizedBox(width: gap),
                          Expanded(
                            child: _buildCard(
                              color: const Color(0xFFE3F2FD),
                              padding: const EdgeInsets.symmetric(vertical: 30),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  const Icon(Icons.folder_outlined, color: Color(0xFF5B8DEF), size: 36),
                                  const Positioned(
                                    right: 0,
                                    top: 0,
                                    child: CircleAvatar(radius: 4, backgroundColor: Colors.redAccent),
                                  )
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: gap),

                      // 4. Support (ITEM CUỐI CÙNG - DÙNG EXPANDED)
                      // Expanded ở đây sẽ ép card này giãn ra lấp đầy khoảng trống còn lại của cột
                      Expanded(
                        child: _buildCard(
                          color: const Color(0xFFF7F9FC),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Container(
                                 padding: const EdgeInsets.all(10),
                                 decoration: BoxDecoration(
                                   color: Colors.grey[200],
                                   borderRadius: BorderRadius.circular(16),
                                 ),
                                 child: const Icon(Icons.headset_mic_outlined, size: 32, color: Colors.black54)
                              ),
                              const SizedBox(width: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Support", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: Color(0xFF1A1A1A))),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: const [
                                      Icon(Icons.circle, size: 10, color: Colors.green),
                                      SizedBox(width: 6),
                                      Text("Online", style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13)),
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: gap),

                // --- CỘT BÊN PHẢI ---
                Expanded(
                  child: Column(
                    children: [
                      // 5. Purchase UI
                      _buildCard(
                        color: const Color(0xFFE3F2FD),
                        // Min height để đảm bảo bố cục đẹp, nhưng vẫn giãn nếu nội dung dài
                        constraints: const BoxConstraints(minHeight: 200),
                        child: SizedBox(
                          width: double.infinity,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildIconBox(
                                Icons.people_alt_outlined, 
                                const Color(0xFF5B8DEF), 
                                bgColor: Colors.white.withOpacity(0.6)
                              ),
                              const SizedBox(height: 40),
                              const Text(
                                "Purchase UI\nkits for effeci...", 
                                textAlign: TextAlign.left,
                                style: TextStyle(
                                  fontSize: 20, 
                                  fontWeight: FontWeight.w800, 
                                  color: Color(0xFF5B8DEF), 
                                  height: 1.2
                                )
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: gap),

                      // 6. Tokens
                      _buildCard(
                        color: const Color(0xFFF7F9FC),
                        child: Row(
                          children: [
                            _buildCircleIcon(Icons.currency_bitcoin, Colors.orange, const Color(0xFFFFF3E0)),
                            const SizedBox(width: 14),
                            Expanded( // Wrap text để xuống dòng nếu cần
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text("5,128.06", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
                                  Text("Tokens", style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                                ],
                              ),
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: gap),

                      // 7. Gems
                      _buildCard(
                        color: const Color(0xFFF7F9FC),
                        child: Row(
                          children: [
                            _buildCircleIcon(Icons.diamond_outlined, Colors.tealAccent.shade700, const Color(0xFFE0F2F1)),
                            const SizedBox(width: 14),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("9", style: TextStyle(fontSize: 19, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
                                Text("Gems", style: TextStyle(fontSize: 13, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                              ],
                            )
                          ],
                        ),
                      ),
                      const SizedBox(height: gap),

                      // 8. Withdraw (ITEM CUỐI CÙNG - DÙNG EXPANDED)
                      Expanded(
                        child: _buildCard(
                          color: const Color(0xFFF7F9FC),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.card_giftcard_outlined, size: 32, color: Color(0xFF5B8DEF)),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(24),
                                      boxShadow: [
                                        BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4, offset: const Offset(0, 2))
                                      ]
                                    ),
                                    child: const Text("Withdraw", style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.black87)),
                                  )
                                ],
                              ),
                              // Spacer ở đây sẽ đẩy nội dung trên lên đỉnh và nội dung dưới xuống đáy
                              // Vì Card này nằm trong Expanded, Spacer sẽ hoạt động hiệu quả
                              const Spacer(), 
                              const SizedBox(height: 20),
                              const Text("18", style: TextStyle(fontSize: 42, fontWeight: FontWeight.w900, color: Color(0xFF1A1A1A))),
                              Text("Claimed rewards", style: TextStyle(fontSize: 14, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCard({
    required Color color,
    required Widget child,
    EdgeInsetsGeometry padding = const EdgeInsets.all(20),
    BoxConstraints? constraints, // Thêm tham số constraints thay vì height cố định
  }) {
    return Container(
      constraints: constraints, // Sử dụng constraints (minHeight, v.v.)
      padding: padding,
      width: double.infinity,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(28),
      ),
      child: child,
    );
  }

  Widget _buildIconBox(IconData icon, Color iconColor, {required Color bgColor}) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Icon(icon, color: iconColor, size: 26),
    );
  }

  Widget _buildCircleIcon(IconData icon, Color iconColor, Color bgColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: bgColor,
      ),
      child: Icon(icon, color: iconColor, size: 26),
    );
  }
}
```
