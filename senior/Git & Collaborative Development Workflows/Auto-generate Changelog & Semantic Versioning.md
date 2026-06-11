# Auto-generate Changelog & Semantic Versioning từ Conventional Commits

## Ý Tưởng Cốt Lõi

Khi toàn bộ team tuân thủ một commit format chuẩn, **máy có thể đọc hiểu được commit history** — từ đó tự động xác định version number và tạo changelog mà không cần con người làm thủ công.

---

## 1. Semantic Versioning (SemVer) là gì?

Format: **`MAJOR.MINOR.PATCH`** — ví dụ `2.4.1`

Mỗi số có ý nghĩa rõ ràng:

- **PATCH** (`2.4.1` → `2.4.2`): fix bug, không thay đổi API/behavior. User update mà không lo gì.
- **MINOR** (`2.4.2` → `2.5.0`): thêm feature mới, backward compatible. User có thêm tính năng nhưng code cũ vẫn chạy.
- **MAJOR** (`2.5.0` → `3.0.0`): breaking changes. User phải đọc migration guide, có thể phải sửa code.

Vấn đề là: **ai quyết định tăng số nào?** Nếu làm thủ công, developer phải tự nhớ "release này có breaking change không?" — rất dễ sai, đặc biệt khi release chứa 50+ commits từ nhiều người.

---

## 2. Conventional Commits Giải Quyết Vấn Đề Này

Mỗi prefix trong commit message **map trực tiếp** vào SemVer:

```
fix(payment): resolve currency formatting     →  PATCH  (2.4.1 → 2.4.2)
fix(auth): handle token expiry edge case      →  PATCH

feat(profile): add avatar upload              →  MINOR  (2.4.2 → 2.5.0)
feat(chat): implement real-time messaging     →  MINOR

feat(api)!: redesign authentication flow      →  MAJOR  (2.5.0 → 3.0.0)
refactor(db)!: migrate from SQLite to Drift   →  MAJOR
```

Dấu `!` hoặc footer `BREAKING CHANGE:` trong commit body báo hiệu breaking change → trigger MAJOR bump.

Quy tắc ưu tiên: nếu trong một release có cả `fix`, `feat`, và breaking change, **số cao nhất thắng**. Có 10 fix + 1 breaking change → vẫn là MAJOR bump.

---

## 3. Auto-generate Changelog Hoạt Động Thế Nào

Tool sẽ đọc Git history từ tag cuối cùng đến hiện tại, phân loại commits, và tạo file `CHANGELOG.md`:

```markdown
## 2.5.0 (2026-03-13)

### Features
- **profile**: add avatar upload (#142)
- **chat**: implement real-time messaging (#138)

### Bug Fixes
- **payment**: resolve currency formatting on VN locale (#145)
- **auth**: handle token expiry edge case (#141)

### Performance
- **home**: lazy load images in feed (#139)
```

Mọi thứ được **tự động phân nhóm** theo type (`feat`, `fix`, `perf`...), kèm scope và link đến PR/issue. Không ai phải ngồi viết tay, không ai quên liệt kê change nào.

---

## 4. Trong Flutter Project Cụ Thể

### Với Melos (monorepo)

Nếu project dùng **Melos** quản lý nhiều packages, Melos có built-in support cho Conventional Commits:

```bash
melos version
```

Lệnh này tự động phân tích commits, xác định package nào bị ảnh hưởng, bump version từng package độc lập, và generate changelog cho mỗi package. Ví dụ `packages/core` có breaking change thì bump MAJOR, trong khi `packages/ui_kit` chỉ có fix thì bump PATCH — tất cả tự động.

### Với single package

Dùng tool như **cider** hoặc **commit_lint** + script tự viết. Hoặc dùng GitHub Actions:

```yaml
# .github/workflows/release.yml
name: Release
on:
  push:
    branches: [main]

jobs:
  release:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
        with:
          fetch-depth: 0    # cần full history để đọc commits
      
      - name: Determine version & changelog
        # Tool đọc commits từ last tag, tính version mới,
        # generate changelog, tạo git tag, push
```

### Với pubspec.yaml

Sau khi xác định version mới, tool tự update `pubspec.yaml`:

```yaml
# Trước
version: 2.4.2+24

# Sau (auto-updated)
version: 2.5.0+25
```

Build number (`+25`) cũng có thể auto-increment — rất quan trọng vì App Store và Play Store yêu cầu build number tăng dần mỗi lần submit.

---

## 5. Tại Sao Senior Phải Quan Tâm

**Không có Conventional Commits**, quy trình release thường là: ai đó ngồi đọc lại toàn bộ PR merged, tự viết changelog, tự quyết version number, rồi thủ công update `pubspec.yaml` và tạo tag. Mất thời gian, dễ sai, không consistent.

**Có Conventional Commits**, quy trình trở thành: merge PR vào `main` → CI tự phân tích → tự bump version → tự generate changelog → tự tag → tự build và distribute. Con người chỉ cần review và approve PR.

Đó là lý do senior cần enforce convention này — nó biến release process từ một việc manual, error-prone thành **fully automated pipeline**.
