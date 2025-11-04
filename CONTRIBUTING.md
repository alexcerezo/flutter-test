# Contributing to Flutter Event Booking App

Thank you for your interest in contributing to this project! This guide will help you understand our development workflow and CI/CD requirements.

## 📋 Table of Contents

- [Getting Started](#getting-started)
- [Development Workflow](#development-workflow)
- [CI/CD Requirements](#cicd-requirements)
- [Code Standards](#code-standards)
- [Testing Requirements](#testing-requirements)
- [Pull Request Process](#pull-request-process)
- [Agent Responsibilities](#agent-responsibilities)

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (stable channel)
- Dart SDK >=2.19.6 <3.0.0
- Git

### Setup

1. **Clone the repository**:
   ```bash
   git clone https://github.com/alexcerezo/flutter-test.git
   cd flutter-test
   ```

2. **Install dependencies**:
   ```bash
   flutter pub get
   ```

3. **Verify setup**:
   ```bash
   flutter doctor -v
   flutter analyze
   flutter test
   ```

## 🔄 Development Workflow

### 1. Create a Branch

```bash
git checkout -b feature/your-feature-name
# or
git checkout -b fix/your-bug-fix
```

### 2. Make Changes

- Write clean, well-documented code
- Follow existing code style and patterns
- Add tests for new functionality
- Update documentation as needed

### 3. Run Local Checks

**Before committing, run these commands**:

```bash
# Format code
flutter format .

# Analyze code
flutter analyze

# Run tests
flutter test

# Build to verify
flutter build web --release
```

### 4. Commit Changes

```bash
git add .
git commit -m "Brief description of changes"
```

**Commit Message Format**:
- `feat: Add new feature`
- `fix: Fix bug description`
- `docs: Update documentation`
- `test: Add or update tests`
- `refactor: Code refactoring`
- `style: Code formatting`
- `ci: CI/CD changes`

### 5. Push and Create PR

```bash
git push origin feature/your-feature-name
```

Then create a Pull Request on GitHub.

## ✅ CI/CD Requirements

All pull requests must pass CI checks before merging:

### Required Checks

1. **Code Analysis** (`flutter analyze`)
   - Zero errors allowed
   - Zero warnings allowed
   - All lints must pass

2. **Code Formatting** (`flutter format`)
   - All code must be properly formatted
   - Run `flutter format .` before committing

3. **Tests** (`flutter test`)
   - All tests must pass
   - No test failures allowed
   - Coverage reports generated

4. **Build** (`flutter build web`)
   - Build must complete successfully
   - No build errors allowed

### Automated Workflows

Our CI/CD pipeline includes:

- **CI**: Runs on every PR (analyze, format, test, build)
- **CD**: Builds artifacts on merge to main
- **Pages**: Deploys to GitHub Pages on merge to main
- **Security**: Weekly security and dependency scans

See [CI/CD Quick Reference](.github/CI_CD_QUICKREF.md) for details.

## 📏 Code Standards

### Dart/Flutter Style

- Follow [Effective Dart](https://dart.dev/guides/language/effective-dart) guidelines
- Use trailing commas for better formatting
- Prefer `const` constructors where possible
- Use meaningful variable and function names
- Add doc comments for public APIs

### Example

```dart
/// Represents an event with all necessary details.
///
/// Events are immutable and use [copyWith] for modifications.
class Event {
  const Event({
    required this.id,
    required this.title,
    required this.date,
    // ... other parameters
  });

  final String id;
  final String title;
  final DateTime date;

  /// Creates a copy with optional field modifications.
  Event copyWith({String? title, DateTime? date}) {
    return Event(
      id: id,
      title: title ?? this.title,
      date: date ?? this.date,
    );
  }
}
```

### Architecture

Follow Clean Architecture principles:
- **Domain Layer**: Pure business logic (no Flutter dependencies)
- **State Management**: ChangeNotifier for global state
- **Presentation Layer**: Widgets with clear responsibilities

See [ARCHITECTURE.md](ARCHITECTURE.md) for details.

## 🧪 Testing Requirements

### Test Types

1. **Unit Tests**: Test business logic and models
2. **Widget Tests**: Test UI components and interactions
3. **Integration Tests**: Test complete user flows

### Coverage

- Aim for >80% code coverage
- All new features must include tests
- All bug fixes must include regression tests

### Writing Tests

```dart
void main() {
  group('Event Model', () {
    test('should create event with required fields', () {
      final event = Event(
        id: '1',
        title: 'Test Event',
        date: DateTime(2024, 1, 1),
        // ... other required fields
      );

      expect(event.id, '1');
      expect(event.title, 'Test Event');
    });

    test('copyWith should update fields', () {
      final event = Event(/* ... */);
      final updated = event.copyWith(title: 'New Title');

      expect(updated.title, 'New Title');
      expect(updated.id, event.id); // Unchanged
    });
  });
}
```

## 🔀 Pull Request Process

### Before Creating PR

- [ ] All local checks pass
- [ ] Code is formatted
- [ ] Tests are added/updated
- [ ] Documentation is updated
- [ ] Branch is up to date with main

### PR Description Template

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Testing
- [ ] Added unit tests
- [ ] Added widget tests
- [ ] Manual testing completed

## Checklist
- [ ] Code follows style guidelines
- [ ] Self-review completed
- [ ] Documentation updated
- [ ] No new warnings
- [ ] Tests pass locally
```

### Review Process

1. **Automated Checks**: CI workflow runs automatically
2. **Code Review**: At least one approval required
3. **Agent Review**: Relevant agents may review:
   - @Dash: Architecture and code quality
   - @El-Bicho: Test coverage and quality
   - @Semanti-Dash: Accessibility compliance
   - @La-Cabra: CI/CD and deployment

4. **Merge**: Squash and merge after approval

## 👥 Agent Responsibilities

Our project uses specialized agents for different aspects:

### @Dash (Architecture Agent)
- **Responsibility**: Code architecture and quality
- **Reviews**: Structure, patterns, best practices
- **Contact**: For architecture decisions

### @El-Bicho (Testing Agent)
- **Responsibility**: Test coverage and quality
- **Reviews**: Tests, coverage, edge cases
- **Contact**: For testing strategies

### @Semanti-Dash (Accessibility Agent)
- **Responsibility**: Accessibility compliance
- **Reviews**: Semantic labels, focus management, contrast
- **Contact**: For accessibility issues

### @La-Cabra (DevOps Agent)
- **Responsibility**: CI/CD and deployment
- **Reviews**: Workflows, builds, deployment
- **Contact**: For CI/CD issues

## 🐛 Reporting Issues

### Bug Reports

Include:
- Clear description
- Steps to reproduce
- Expected behavior
- Actual behavior
- Screenshots (if applicable)
- Environment details

### Feature Requests

Include:
- Clear description
- Use case
- Proposed solution
- Alternative solutions

## 📚 Additional Resources

- [README.md](README.md) - Project overview
- [ARCHITECTURE.md](ARCHITECTURE.md) - Architecture details
- [ACCESSIBILITY_REPORT.md](ACCESSIBILITY_REPORT.md) - Accessibility guide
- [.github/workflows/README.md](.github/workflows/README.md) - CI/CD documentation
- [.github/CI_CD_QUICKREF.md](.github/CI_CD_QUICKREF.md) - Quick reference

## 📞 Getting Help

- **General Questions**: Open a discussion
- **Bug Reports**: Open an issue
- **CI/CD Issues**: Contact @La-Cabra
- **Code Review**: Tag relevant agent in PR

## 📜 License

By contributing, you agree that your contributions will be licensed under the same license as the project.

---

**Thank you for contributing!** 🎉

Your contributions help make this project better for everyone.
