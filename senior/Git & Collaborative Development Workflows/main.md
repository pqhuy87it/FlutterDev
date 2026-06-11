# Git & Collaborative Development Workflows cho Senior Flutter Developer

Ở level senior, đây không chỉ là biết `git add/commit/push` — mà là khả năng **thiết kế và vận hành workflow** cho cả team, xử lý các tình huống phức tạp, và đảm bảo codebase luôn stable.

---

## 1. Git Nâng Cao — Không Chỉ Là Cơ Bản

**Branching strategies** là thứ senior phải nắm vững và biết chọn phù hợp cho team:

**Git Flow** phù hợp cho app có release cycle rõ ràng (ví dụ mỗi 2 tuần submit lên App Store/Play Store). Bạn có `develop`, `release/x.x.x`, `hotfix`, `feature/*`. Điểm mạnh là kiểm soát chặt, nhưng overhead cao.

**Trunk-based development** phù hợp cho team nhỏ, CI/CD mạnh — mọi người merge vào `main` liên tục với feature flags. Ít branch sống lâu, giảm merge conflict.

**GitHub Flow** là middle ground — feature branch ngắn, PR vào `main`, deploy sau khi merge.

Senior phải đánh giá team size, release cadence, QA process để chọn strategy phù hợp, không phải cứ áp Git Flow vào mọi project.

## 2. Xử Lý Conflict & Rebase vs Merge

Ở level senior, bạn cần hiểu rõ sự khác biệt và trade-off:

**`git rebase`** giữ history sạch, linear — rất hữu ích khi bạn muốn feature branch luôn cập nhật với `main` mà không tạo merge commit thừa. Nhưng **không bao giờ rebase branch đã shared** — đây là rule mà senior phải enforce cho team.

**`git merge --no-ff`** giữ được context của feature branch trong history, dễ revert cả feature nếu cần.

**Interactive rebase** (`git rebase -i`) để squash, reorder, edit commit trước khi tạo PR — giúp reviewer dễ đọc hơn. Ví dụ bạn có 15 commit WIP, squash lại thành 3-4 commit có ý nghĩa.

Các lệnh quan trọng khác mà senior phải thành thạo: `git cherry-pick` (lấy hotfix từ branch khác), `git bisect` (tìm commit gây bug), `git reflog` (recovery khi lỡ tay), `git stash` với multiple stashes.

## 3. Commit Convention & History Management

Senior thường thiết lập **Conventional Commits** cho team:

```
feat(auth): add biometric login for iOS
fix(payment): resolve currency formatting on VN locale
refactor(home): extract widget tree into smaller components
chore(deps): bump flutter_bloc to 8.1.4
```

Tại sao quan trọng? Vì nó cho phép auto-generate changelog, semantic versioning, và khi `git log` hay `git blame` thì ai cũng hiểu ngay commit làm gì. Senior cũng thường setup **commit hooks** (via `husky` hoặc `lefthook`) để lint commit message, chạy `flutter analyze`, format code trước khi commit.

## 4. Code Review & PR Workflow

Đây là phần **collaborative** thực sự. Senior Flutter developer cần:

**Tạo PR có chất lượng** — description rõ ràng (what, why, how), screenshot/video cho UI changes (đặc biệt quan trọng với Flutter vì UI-heavy), link Jira/Linear ticket, note breaking changes. PR nhỏ, focused vào 1 mục đích — tránh PR 50+ files thay đổi.

**Review code hiệu quả** — không chỉ tìm bug mà còn đánh giá architecture, naming, performance implications đặc thù Flutter (unnecessary rebuilds, improper state management). Biết khi nào comment là "nit" (suggestion nhỏ) vs "blocker" (phải fix).

**Thiết lập rules** — required reviewers, minimum approvals, CI phải pass trước khi merge, branch protection rules.

## 5. CI/CD Integration với Git

Senior phải biết cách Git events trigger CI/CD pipeline:

Push lên `feature/*` chạy `flutter analyze` + `flutter test`. PR vào `develop` chạy full test suite + build APK/IPA. Merge vào `main` trigger deploy lên TestFlight/Firebase App Distribution. Tag `v*` trigger production release.

Tools phổ biến: **GitHub Actions**, **Codemagic** (chuyên Flutter), **Bitrise**, **Fastlane** cho signing và distribution. Senior cần setup và maintain các pipeline này.

## 6. Monorepo & Multi-package Management

Nhiều Flutter project lớn dùng **Melos** để quản lý monorepo với nhiều packages (core, features, shared UI). Git workflow phức tạp hơn vì một PR có thể affect nhiều packages. Senior cần hiểu cách cấu hình CI chỉ build/test packages bị thay đổi (affected packages), và versioning strategy cho internal packages.

## 7. Các Tình Huống Thực Tế Senior Phải Handle

**Hotfix production** — app đang crash trên production, bạn cần cherry-pick fix từ `develop` vào `release` branch, build lại, submit emergency update — tất cả trong vài giờ mà không làm rối history.

**Rollback** — release mới có bug nghiêm trọng, cần `git revert` merge commit của cả feature, rebuild và re-deploy.

**Onboarding** — developer mới join team, senior phải document workflow, setup guide, và pair với họ qua vài PR đầu tiên.

**Conflict resolution** — hai feature branch cùng sửa state management hoặc routing, senior phải coordinate merge order và giải quyết conflict có chiến lược thay vì "accept both" rồi cầu nguyện.

---

## Tóm Lại

Ở senior level, Git không phải tool — nó là **infrastructure của collaboration**. Bạn không chỉ dùng Git, bạn thiết kế cách cả team dùng Git. Từ branching strategy, commit convention, PR process, đến CI/CD integration — tất cả phải hoạt động như một hệ thống nhất quán, giúp team ship code nhanh mà vẫn giữ được chất lượng và traceability.
