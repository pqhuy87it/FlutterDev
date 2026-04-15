import 'package:flutter/material.dart';

class SliverMainAxisGroupExample extends StatelessWidget {
  const SliverMainAxisGroupExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Sliver 1: Một SliverAppBar bình thường
          SliverAppBar(title: Text('Sliver Demo'), floating: true),

          // Sliver 2: Đây là nhân vật chính của chúng ta!
          SliverMainAxisGroup(
            slivers: [
              // Sliver con 1: Một tiêu đề cho nhóm
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Đây là một nhóm được bọc bởi SliverMainAxisGroup',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                ),
              ),
              // Sliver con 2: Một lưới nhỏ bên trong nhóm
              SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) => Container(
                    color: Colors.teal[100 * (index % 9)],
                    child: Center(child: Text('Grid ${index + 1}')),
                  ),
                  childCount: 6,
                ),
              ),
            ],
          ),

          // Sliver 3: Một danh sách dài bên ngoài nhóm
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) =>
                  ListTile(title: Text('Item bên ngoài nhóm ${index + 1}')),
              childCount: 50,
            ),
          ),
        ],
      ),
    );
  }
}
