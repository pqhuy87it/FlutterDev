import 'package:flutter/material.dart';

class AspectRatioImage extends StatefulWidget {
  final ImageProvider imageProvider;
  final BoxFit fit;

  const AspectRatioImage({super.key, required this.imageProvider, this.fit = BoxFit.cover});

  @override
  State<AspectRatioImage> createState() => _AspectRatioImageState();
}

class _AspectRatioImageState extends State<AspectRatioImage> {
  double? _aspectRatio;
  late final ImageStream _imageStream;
  late final ImageStreamListener _imageStreamListener;

  @override
  void initState() {
    super.initState();
    // 1. Tạo một listener để lắng nghe khi ảnh được tải xong
    _imageStreamListener = ImageStreamListener(_onImageLoad, onError: _onImageError);
    // 2. Lấy stream từ ImageProvider
    _imageStream = widget.imageProvider.resolve(const ImageConfiguration());
    // 3. Thêm listener vào stream
    _imageStream.addListener(_imageStreamListener);
  }

  // Hàm được gọi khi thông tin ảnh có sẵn
  void _onImageLoad(ImageInfo imageInfo, bool synchronousCall) {
    // 4. Lấy kích thước ảnh và tính toán tỉ lệ
    final image = imageInfo.image;
    if (mounted) {
      setState(() {
        _aspectRatio = image.width / image.height;
      });
    }
  }

  // Hàm xử lý lỗi (tùy chọn)
  void _onImageError(dynamic exception, StackTrace? stackTrace) {
    if (mounted) {
      // Có thể hiển thị một widget báo lỗi ở đây
      print('Lỗi tải ảnh: $exception');
      setState(() {
        _aspectRatio = 1.0; // Tạm dùng tỉ lệ 1:1 nếu lỗi
      });
    }
  }

  @override
  void dispose() {
    // 6. Rất quan trọng: Gỡ bỏ listener để tránh rò rỉ bộ nhớ
    _imageStream.removeListener(_imageStreamListener);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // 5. Dựng giao diện dựa trên trạng thái
    if (_aspectRatio != null) {
      // Nếu đã có tỉ lệ, hiển thị ảnh với AspectRatio
      return AspectRatio(
        aspectRatio: _aspectRatio!,
        child: Image(
          image: widget.imageProvider,
          fit: widget.fit,
        ),
      );
    } else {
      // Nếu chưa có tỉ lệ (đang tải), hiển thị một placeholder
      // Đặt placeholder trong AspectRatio 16:9 (hoặc tỉ lệ bạn muốn)
      // để tránh layout bị "nhảy" khi ảnh thật tải xong.
      return AspectRatio(
        aspectRatio: 16 / 9, // Tỉ lệ tạm thời
        child: Container(
          color: Colors.grey[200],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        ),
      );
    }
  }
}
