import 'package:flutter/material.dart';
import 'package:project_samples/screens/text_form_field/text_area_widget.dart';
import 'package:fluentui_system_icons/fluentui_system_icons.dart';

class TextFormFieldExamplePage extends StatelessWidget {
  static String routeName = 'basics/text_form_field_example';

  const TextFormFieldExamplePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Text Form Field Example')),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: <Widget>[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: <Widget>[
                  TextareaWidget(
                    title: 'What happens to your pet if or when you move? ',
                    hintText: '',
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'This field is required';
                      }
                      return null;
                    },
                    onSaved: (value) {},
                  ),
                  SizedBox(height: 20),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: Colors.grey.shade300, width: 0.5),
                    ),
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    height: 40,
                    child: TextFormField(
                      decoration: InputDecoration(
                        suffixIcon: Icon(
                          FluentIcons.filter_32_regular,
                          size: 14,
                          color: Stylings.lightBlack,
                        ),
                        contentPadding: EdgeInsets.only(left: 10),
                        prefixIcon: Icon(
                          FluentIcons.search_32_regular,
                          size: 14,
                          color: Stylings.lightBlack,
                        ),
                        fillColor: Colors.white,
                        hintText: "Search any recipe",
                        hintStyle: Stylings.lilgreyText,
                        border: OutlineInputBorder(borderSide: BorderSide.none),
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
}

class Stylings {
  //Colors
  static Color main = Colors.purple.shade700;
  static Color deepBlack = Colors.black;
  static Color lightBlack = Colors.black45;
  static Color bgColor = const Color(0xffeeedf2);

  //textStyles
  static TextStyle header = TextStyle(
    fontFamily: "WorkSans",
    fontSize: 15,
    fontWeight: FontWeight.w700,
    color: deepBlack,
  );
  static TextStyle subHeader = TextStyle(
    fontFamily: "WorkSans",
    fontSize: 13,
    fontWeight: FontWeight.w700,
    color: deepBlack,
  );
  static TextStyle lilgreyText = TextStyle(
    fontFamily: "WorkSans",
    fontSize: 12,
    color: lightBlack,
    fontWeight: FontWeight.w400,
  );

  //media
  static String imgPath = "assets";
}
