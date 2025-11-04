# CI/CD Pipeline Documentation

## Overview

This repository uses GitHub Actions for automated Continuous Integration (CI) and Continuous Deployment (CD). The pipelines ensure code quality, run tests, and deploy the application automatically.

## Workflows

### 1. CI - Continuous Integration (`ci.yml`)

**Trigger**: Pull requests and pushes to `main` and `develop` branches

**Purpose**: Validate code quality, run tests, and verify builds before merging

**Steps**:
1. **Checkout**: Clone the repository code
2. **Setup Flutter**: Install Flutter SDK with caching for speed
3. **Dependencies**: Run `flutter pub get` to install packages
4. **Analyze**: Run `flutter analyze` - **MANDATORY** - no errors allowed
5. **Format Check**: Verify code formatting with `flutter format`
6. **Tests**: Run all tests with coverage - **MANDATORY** - no failures allowed
7. **Coverage**: Upload coverage report to Codecov
8. **Build Web**: Build web app to verify build process
9. **Upload Artifact**: Store build artifact for inspection

**Exit Criteria**: All steps must pass for PR to be mergeable

**Performance Optimizations**:
- Caches Flutter SDK and pub dependencies
- Concurrent job cancellation on new pushes
- Parallel execution where possible

### 2. CD - Continuous Deployment (`cd.yml`)

**Trigger**: Pushes to `main` branch, manual dispatch

**Purpose**: Build release artifacts for distribution

**Jobs**:

#### Build Web Application
- Builds optimized web release
- Uploads artifact with 30-day retention
- Names artifact with commit SHA for traceability

#### Build Android APK
- Sets up Java 17 (required for Android builds)
- Builds debug APK (use release + signing for production)
- Uploads APK with 30-day retention

#### Create GitHub Release (conditional)
- **Trigger**: Only on version tags (e.g., `v1.0.0`)
- Downloads all build artifacts
- Creates ZIP archive of web build
- Creates GitHub Release with:
  - Web app ZIP
  - Android APK
  - Auto-generated release notes

**Deployment Strategy**: Manual promotion model
- Artifacts are built automatically
- Release creation requires version tag
- Production deployment is controlled

### 3. GitHub Pages Deployment (`pages.yml`)

**Trigger**: Pushes to `main` branch, manual dispatch

**Purpose**: Deploy web app to GitHub Pages for live preview

**Steps**:
1. Build Flutter web app with correct base href
2. Configure GitHub Pages
3. Upload build artifact
4. Deploy to GitHub Pages environment

**Access**: `https://alexcerezo.github.io/flutter-test/`

**Permissions**: Requires `pages: write` and `id-token: write`

**Concurrency**: Only one deployment at a time (no cancellation)

### 4. Security & Dependencies (`security.yml`)

**Trigger**: 
- Weekly schedule (Sundays at midnight UTC)
- Pull requests modifying `pubspec.yaml` or `pubspec.lock`
- Manual dispatch

**Jobs**:

#### Security Vulnerability Scan
- Runs `dart pub audit` to check for known vulnerabilities
- Runs strict static analysis with `--fatal-infos --fatal-warnings`

#### Dependency Check
- Lists outdated dependencies
- Generates dependency tree
- Uploads dependency report as artifact

**Purpose**: Proactive security and maintenance

## Environment Variables & Secrets

### Required Secrets
- `GITHUB_TOKEN`: Auto-provided by GitHub Actions

### Optional Secrets (for future enhancements)
- `FIREBASE_TOKEN`: For Firebase App Distribution
- `ANDROID_KEYSTORE`: For signed Android releases
- `ANDROID_KEY_PASSWORD`: Keystore password
- `IOS_CERTIFICATE`: For iOS signing
- `IOS_PROVISIONING_PROFILE`: For iOS provisioning

### Environment Variables
- Automatically managed by workflows
- Flutter channel: `stable`
- Java version: `17` (for Android builds)

## Caching Strategy

### Flutter SDK Cache
- Caches Flutter SDK installation
- Key: `flutter-:os:-:channel:-:version:-:arch:-:hash:`
- Significantly reduces setup time

### Pub Dependencies Cache
- Caches pub dependencies
- Managed by `subosito/flutter-action@v2`
- Reduces `flutter pub get` time

### Artifact Retention
- Web builds: 7 days (CI), 30 days (CD)
- APK builds: 30 days
- Dependency reports: 30 days

## Monitoring & Status

### GitHub Status Checks
All workflows report status to pull requests:
- ✅ Green check: All validations passed
- ❌ Red X: Failures detected
- 🟡 Yellow dot: In progress

### Badges
Repository README includes status badges for all workflows:
- CI Status
- CD Status
- GitHub Pages Status
- Security Status

## Troubleshooting

### CI Workflow Fails

**Analyze Step Fails**:
- Run `flutter analyze` locally
- Fix all errors and warnings
- Commit and push

**Format Check Fails**:
- Run `flutter format .` locally
- Commit formatted files

**Tests Fail**:
- Run `flutter test` locally
- Fix failing tests
- Ensure all tests pass before pushing

**Build Fails**:
- Run `flutter build web` locally
- Check for missing dependencies
- Verify `pubspec.yaml` is correct

### CD Workflow Issues

**Android Build Fails**:
- Verify Java 17 is specified
- Check Android configuration
- Ensure `android/` directory is properly configured

**Artifacts Not Uploading**:
- Check artifact paths
- Verify build completed successfully
- Check GitHub Actions logs

### GitHub Pages Deployment Issues

**Page Not Loading**:
- Verify GitHub Pages is enabled in repository settings
- Check that `base-href` is set correctly
- Ensure deployment completed successfully

**404 Errors**:
- Confirm repository name in base-href
- Check GitHub Pages URL format

## Best Practices

### For Developers

1. **Run Tests Locally**: Always run `flutter test` before pushing
2. **Check Analysis**: Run `flutter analyze` to catch issues early
3. **Format Code**: Run `flutter format .` before committing
4. **Review CI**: Check CI status before requesting reviews
5. **Small PRs**: Keep pull requests focused and small

### For Maintainers

1. **Protect Main**: Require status checks before merging
2. **Review Coverage**: Monitor test coverage trends
3. **Update Dependencies**: Review weekly security reports
4. **Version Tags**: Use semantic versioning for releases
5. **Monitor Costs**: Check GitHub Actions usage monthly

### For CI/CD Maintenance

1. **Keep Actions Updated**: Update action versions regularly
2. **Test Workflow Changes**: Use feature branches for workflow updates
3. **Document Changes**: Update this file when changing workflows
4. **Monitor Performance**: Check workflow execution times
5. **Optimize Caching**: Review cache hit rates

## Future Enhancements

Planned improvements for the CI/CD pipeline:

### Short Term
- [ ] Integration tests in CI
- [ ] Performance benchmarks
- [ ] Lighthouse CI for web performance
- [ ] Automated changelog generation

### Medium Term
- [ ] Firebase App Distribution for APKs
- [ ] iOS build pipeline
- [ ] Signed Android releases
- [ ] Staging environment deployment

### Long Term
- [ ] Multi-platform builds (iOS, macOS, Windows, Linux)
- [ ] Automated dependency updates (Dependabot)
- [ ] Visual regression testing
- [ ] Automated release notes with AI

## Support

For issues with CI/CD pipelines:
1. Check workflow logs in GitHub Actions tab
2. Review this documentation
3. Contact DevOps team (@La-Cabra)
4. Open an issue with `ci/cd` label

## References

- [GitHub Actions Documentation](https://docs.github.com/en/actions)
- [Flutter CI/CD Best Practices](https://docs.flutter.dev/deployment/cd)
- [subosito/flutter-action](https://github.com/subosito/flutter-action)
- [GitHub Pages Documentation](https://docs.github.com/en/pages)
