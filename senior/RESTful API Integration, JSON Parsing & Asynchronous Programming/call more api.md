Có nhiều cách, tùy vào mục đích cụ thể:

## 1. Record destructuring (Dart 3+)

Cách hiện đại nhất, type-safe hơn `Future.wait`:

```dart
// Future.wait trả về List<dynamic> → phải cast
final results = await Future.wait([getUser(), getPosts()]);
final user = results[0] as User;   // Không type-safe
final posts = results[1] as List<Post>;

// Record pattern → mỗi biến đã có đúng type
final (user, posts) = await (getUser(), getPosts()).wait;
// user là User, posts là List<Post> — compiler biết rõ
```

Đây là extension trên `Record` có sẵn từ Dart 3.0, nằm trong `dart:async`. Gọn, an toàn, và không cần nhớ thứ tự index.

## 2. FutureGroup (package async)

Khi số lượng Future **động**, không biết trước:

```dart
import 'package:async/async.dart';

final group = FutureGroup<UserModel>();

for (final id in userIds) {
  group.add(fetchUser(id)); // Thêm bao nhiêu cũng được
}

group.close(); // Báo đã thêm xong
final users = await group.future; // Đợi tất cả
```

## 3. BLoC / Riverpod — update từng phần UI

Khi bạn **không muốn đợi tất cả**, mà muốn phần nào xong hiện phần đó:

```dart
class HomeBloc extends Bloc<HomeEvent, HomeState> {
  Future<void> _onLoad(LoadHome event, Emitter emit) async {
    emit(state.copyWith(
      userStatus: LoadingStatus.loading,
      postsStatus: LoadingStatus.loading,
    ));

    // Chạy song song, nhưng update state độc lập
    unawaited(
      getUser().then(
        (user) => add(UserLoaded(user)),
        onError: (e) => add(UserFailed(e)),
      ),
    );

    unawaited(
      getPosts().then(
        (posts) => add(PostsLoaded(posts)),
        onError: (e) => add(PostsFailed(e)),
      ),
    );
  }
}
```

UI render theo từng phần:

```dart
// User section — hiện ngay khi user data sẵn sàng
if (state.userStatus == LoadingStatus.loading)
  ShimmerAvatar()
else
  UserHeader(state.user!),

// Posts section — hiện ngay khi posts data sẵn sàng  
if (state.postsStatus == LoadingStatus.loading)
  ShimmerList()
else
  PostList(state.posts),
```

## 4. Completer — kiểm soát thủ công

Khi bạn cần resolve Future từ **bên ngoài**:

```dart
class ImageLoader {
  final _completer = Completer<File>();

  Future<File> get result => _completer.future;

  void onUploadDone(File file) {
    if (!_completer.isCompleted) {
      _completer.complete(file);
    }
  }

  void onUploadFailed(Object error) {
    if (!_completer.isCompleted) {
      _completer.completeError(error);
    }
  }
}

// Dùng
final loader1 = ImageLoader();
final loader2 = ImageLoader();

// Một nơi nào đó gọi loader1.onUploadDone(file)...
// Đợi cả 2 xong
final (img1, img2) = await (loader1.result, loader2.result).wait;
```

## 5. Stream.merge — nhiều nguồn real-time

Khi data đến liên tục, không phải one-shot:

```dart
import 'package:rxdart/rxdart.dart';

final combined = Rx.combineLatest3(
  watchUser(userId),        // Stream<User>
  watchPosts(userId),       // Stream<List<Post>>
  watchNotifications(),     // Stream<List<Notification>>
  (user, posts, notifs) => HomeData(user, posts, notifs),
);

// Mỗi khi BẤT KỲ stream nào emit giá trị mới
// → combine lại và emit HomeData mới
```

## Khi nào dùng cái nào?

| Tình huống | Dùng |
|---|---|
| Biết trước số lượng, đợi tất cả | `(a, b).wait` (Dart 3) |
| Biết trước, cần `List<dynamic>` | `Future.wait` |
| Số lượng động | `FutureGroup` |
| Phần nào xong hiện phần đó | BLoC/Riverpod update riêng |
| Resolve Future từ bên ngoài | `Completer` |
| Data real-time liên tục | `combineLatest` / `Stream.merge` |

Với Dart 3 trở lên, `(a, b).wait` nên là lựa chọn mặc định thay `Future.wait` vì type-safe và dễ đọc hơn.
