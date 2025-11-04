# CI/CD Quick Reference Guide

## 🎯 Purpose
This guide provides quick commands and troubleshooting for developers working with the CI/CD pipelines.

## 🚀 Local Validation (Before Push)

Run these commands locally to catch issues before CI:

```bash
# 1. Install/Update dependencies
flutter pub get

# 2. Run code analysis (same as CI)
flutter analyze

# 3. Check code formatting
flutter format --set-exit-if-changed .

# 4. Fix formatting automatically
flutter format .

# 5. Run all tests
flutter test

# 6. Run tests with coverage
flutter test --coverage

# 7. Build web (verify no build errors)
flutter build web --release

# 8. Check for outdated dependencies
flutter pub outdated
```

## 📊 CI/CD Status Badges

Check workflow status at a glance:

- **CI**: [![CI](https://github.com/alexcerezo/flutter-test/actions/workflows/ci.yml/badge.svg)](https://github.com/alexcerezo/flutter-test/actions/workflows/ci.yml)
- **CD**: [![CD](https://github.com/alexcerezo/flutter-test/actions/workflows/cd.yml/badge.svg)](https://github.com/alexcerezo/flutter-test/actions/workflows/cd.yml)
- **Pages**: [![Pages](https://github.com/alexcerezo/flutter-test/actions/workflows/pages.yml/badge.svg)](https://github.com/alexcerezo/flutter-test/actions/workflows/pages.yml)
- **Security**: [![Security](https://github.com/alexcerezo/flutter-test/actions/workflows/security.yml/badge.svg)](https://github.com/alexcerezo/flutter-test/actions/workflows/security.yml)

## 🔍 Workflow Triggers

| Workflow | Trigger | Purpose |
|----------|---------|---------|
| `ci.yml` | PR + Push to main/develop | Quality checks before merge |
| `cd.yml` | Push to main + Manual | Build release artifacts |
| `pages.yml` | Push to main + Manual | Deploy to GitHub Pages |
| `security.yml` | Weekly + pubspec changes | Security & dependency audit |

## ⚡ Common Issues & Solutions

### ❌ CI Fails: `flutter analyze`

**Problem**: Code analysis errors

**Solution**:
```bash
flutter analyze
# Fix all errors and warnings
# Commit fixes
```

### ❌ CI Fails: Code formatting

**Problem**: Code not properly formatted

**Solution**:
```bash
flutter format .
git add .
git commit -m "Format code"
git push
```

### ❌ CI Fails: Tests

**Problem**: One or more tests failing

**Solution**:
```bash
flutter test
# Fix failing tests
# Ensure all tests pass locally
git commit -m "Fix failing tests"
git push
```

### ❌ CI Fails: Build

**Problem**: Build process fails

**Solution**:
```bash
flutter clean
flutter pub get
flutter build web --release
# Fix any build errors
# Test build succeeds locally
```

### ❌ GitHub Pages 404

**Problem**: Deployed app shows 404

**Solution**:
1. Check repository Settings → Pages
2. Ensure Pages is enabled
3. Source should be "GitHub Actions"
4. Wait a few minutes for deployment
5. Access: `https://alexcerezo.github.io/flutter-test/`

## 📦 Creating a Release

To create a GitHub release with artifacts:

```bash
# 1. Update version in pubspec.yaml
version: 1.1.0+2

# 2. Commit version bump
git add pubspec.yaml
git commit -m "Bump version to 1.1.0"
git push

# 3. Create and push tag
git tag v1.1.0
git push origin v1.1.0

# 4. CD workflow will automatically create release with:
#    - Web app ZIP
#    - Android APK
#    - Release notes
```

## 🔐 Security Workflow

Runs automatically weekly, but you can trigger manually:

1. Go to Actions tab
2. Select "Security & Dependencies"
3. Click "Run workflow"
4. Review results in artifacts

## 🎨 Manual Deployment

To manually trigger deployments:

### Deploy to GitHub Pages:
1. Go to Actions tab
2. Select "Deploy to GitHub Pages"
3. Click "Run workflow"
4. Select branch: `main`
5. Click "Run workflow" button

### Build Artifacts:
1. Go to Actions tab
2. Select "CD - Continuous Deployment"
3. Click "Run workflow"
4. Select branch: `main`
5. Click "Run workflow" button

## 📱 Accessing Builds

### Web Build (from CI/CD):
1. Go to Actions tab
2. Click on latest successful workflow run
3. Scroll to "Artifacts" section
4. Download `web-build` or `web-release-*`
5. Extract and serve locally

### Android APK:
1. Go to Actions tab
2. Click on latest CD workflow run
3. Download `android-apk-*`
4. Install on Android device

### Live Web App:
- URL: `https://alexcerezo.github.io/flutter-test/`
- Auto-updates on push to `main`

## 🛠️ Workflow Maintenance

### Update Flutter Version:
Edit workflows and change:
```yaml
- name: Setup Flutter SDK
  uses: subosito/flutter-action@v2
  with:
    channel: 'stable'  # or 'beta', 'dev'
```

### Add Secret:
1. Go to Settings → Secrets and variables → Actions
2. Click "New repository secret"
3. Name: `SECRET_NAME`
4. Value: `secret_value`
5. Use in workflow: `${{ secrets.SECRET_NAME }}`

## 📚 Additional Resources

- **Full Documentation**: `.github/workflows/README.md`
- **Architecture**: `ARCHITECTURE.md`
- **Accessibility**: `ACCESSIBILITY_REPORT.md`
- **GitHub Actions**: [Official Docs](https://docs.github.com/en/actions)
- **Flutter CI/CD**: [Flutter Docs](https://docs.flutter.dev/deployment/cd)

## 👥 Team Contacts

- **DevOps Issues**: @La-Cabra (DevOps Agent)
- **Code Quality**: @Dash (Architecture Agent)
- **Testing**: @El-Bicho (Testing Agent)
- **Accessibility**: @Semanti-Dash (Accessibility Agent)

---

**Last Updated**: 2025-11-04
**Maintained by**: La Cabra (DevOps Expert)
