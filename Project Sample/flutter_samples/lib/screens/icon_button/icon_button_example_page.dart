import 'package:flutter/material.dart';

class IconButtonExamplePage extends StatefulWidget {
  static String routeName = 'basics/icon_button_example';

  const IconButtonExamplePage({super.key});

  @override
  State<IconButtonExamplePage> createState() => _IconButtonExamplePageState();
}

class _IconButtonExamplePageState extends State<IconButtonExamplePage> {
  bool standardSelected = false;
  bool filledSelected = false;
  bool tonalSelected = false;
  bool outlinedSelected = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Icon Button Example')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton(
                    isSelected: standardSelected,
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    onPressed: () {
                      setState(() {
                        standardSelected = !standardSelected;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton(
                    isSelected: standardSelected,
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    onPressed: null,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton.filled(
                    isSelected: filledSelected,
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    onPressed: () {
                      setState(() {
                        filledSelected = !filledSelected;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton.filled(
                    isSelected: filledSelected,
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    onPressed: null,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton.filledTonal(
                    isSelected: tonalSelected,
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    onPressed: () {
                      setState(() {
                        tonalSelected = !tonalSelected;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton.filledTonal(
                    isSelected: tonalSelected,
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    onPressed: null,
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  IconButton.outlined(
                    isSelected: outlinedSelected,
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    onPressed: () {
                      setState(() {
                        outlinedSelected = !outlinedSelected;
                      });
                    },
                  ),
                  const SizedBox(width: 10),
                  IconButton.outlined(
                    isSelected: outlinedSelected,
                    icon: const Icon(Icons.settings_outlined),
                    selectedIcon: const Icon(Icons.settings),
                    onPressed: null,
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
