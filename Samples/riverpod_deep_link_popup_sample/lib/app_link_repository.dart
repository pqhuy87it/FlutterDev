import 'package:app_links/app_links.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final appLinkRepositoryProvider = Provider((ref) => AppLinkRepository());

class AppLinkRepository {
  final AppLinks _appLinks = AppLinks();

  Stream<Uri> get uriStream => _appLinks.uriLinkStream;
}
