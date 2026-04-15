import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:project_samples/utils/gaps.dart';

class CustomSearchBar extends StatefulWidget implements PreferredSizeWidget  {
  final String backImg;
  final String hintText;
  final void Function(String)? onPressed;

  const CustomSearchBar({
    super.key,
    this.backImg = 'assets/images/ic_back_black.png',
    this.hintText = '',
    this.onPressed,
  });

  @override
  State<CustomSearchBar> createState() => _CustomSearchBarState();

  @override
  Size get preferredSize => const Size.fromHeight(48.0);
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focus = FocusNode();

  @override
  void dispose() {
    _focus.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    Widget backButton = Semantics(
      label: '返回',
      child: SizedBox(
        width: 48.0,
        height: 48.0,
        child: InkWell(
          onTap: () {
            Navigator.pop(context);
          },
          borderRadius: BorderRadius.circular(24.0),
          child: Padding(
            key: const Key('search_back'),
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              widget.backImg,
              color: Colors.black,
            ),
          ),
        ),
      ),
    );

    Widget textField = Expanded(
      child: Container(
        height: 40.0,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(4.0),
        ),
        child: TextField(
          key: const Key('search_text_field'),
//          autofocus: true,
          controller: _controller,
          focusNode: _focus,
          textInputAction: TextInputAction.search,
          onSubmitted: (String val) {
            _focus.unfocus();
            // 点击软键盘的动作按钮时的回调
            widget.onPressed?.call(val);
          },
          decoration: InputDecoration(
            contentPadding: const EdgeInsets.only(left: -8.0, right: -16.0, bottom: 14.0),
            border: InputBorder.none,
            icon: Padding(
              padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 8.0),
              child: LoadAssetImage('order_search', color: Colors.grey.shade300,),
            ),
            hintText: widget.hintText,
            suffixIcon: GestureDetector(
              child: Semantics(
                label: '清空',
                child: Padding(
                  padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
                  child: LoadAssetImage('order_delete', color: Colors.grey.shade300),
                ),
              ),
              onTap: () {},
            ),
          ),
        ),
      ),
    );

    Widget search = TextButton(onPressed: (){}, child: Text('Search'),);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: light ,
      child: Material(
        color: Colors.white,
        child: SafeArea(
          child: Row(
            children: <Widget>[
              backButton,
              textField,
              Gaps.hGap8,
              search,
              Gaps.hGap16,
            ],
          ),
        ),
      ),
    );
  }
}

const SystemUiOverlayStyle light = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  systemNavigationBarColor: Color(0xFF18191A),
  systemNavigationBarIconBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.light,
  statusBarBrightness: Brightness.dark,
);

const SystemUiOverlayStyle dark = SystemUiOverlayStyle(
  statusBarColor: Colors.transparent,
  systemNavigationBarColor: Colors.white,
  systemNavigationBarIconBrightness: Brightness.dark,
  statusBarIconBrightness: Brightness.dark,
  statusBarBrightness: Brightness.light,
);

class LoadAssetImage extends StatelessWidget {

  const LoadAssetImage(this.image, {
    super.key,
    this.width,
    this.height,
    this.cacheWidth,
    this.cacheHeight,
    this.fit,
    this.format = ImageFormat.png,
    this.color
  });

  final String image;
  final double? width;
  final double? height;
  final int? cacheWidth;
  final int? cacheHeight;
  final BoxFit? fit;
  final ImageFormat format;
  final Color? color;

  @override
  Widget build(BuildContext context) {

    return Image.asset(
      ImageUtils.getImgPath(image, format: format),
      height: height,
      width: width,
      cacheWidth: cacheWidth,
      cacheHeight: cacheHeight,
      fit: fit,
      color: color,
      /// 忽略图片语义
      excludeFromSemantics: true,
    );
  }
}

class ImageUtils {

  static ImageProvider getAssetImage(String name, {ImageFormat format = ImageFormat.png}) {
    return AssetImage(getImgPath(name, format: format));
  }

  static String getImgPath(String name, {ImageFormat format = ImageFormat.png}) {
    return 'assets/images/$name.${format.value}';
  }
}

extension ImageFormatExtension on ImageFormat {
  String get value => ['png', 'jpg', 'gif', 'webp'][index];
}

enum ImageFormat {
  png,
  jpg,
  gif,
  webp
}
