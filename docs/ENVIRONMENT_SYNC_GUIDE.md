# HiPop Environment Sync Guide

This guide explains how to analyze differences between your staging and production environments and sync them safely.

## Quick Start

### Check Differences
```bash
./scripts/check-differences.sh
```

### Sync Staging → Production (GitHub)
```bash
# Option 1: GitHub Actions (Recommended)
# Go to GitHub → Actions → "Deploy Staging to Production" → Run workflow → Type "DEPLOY"

# Option 2: Command Line
./scripts/merge-staging-to-production.sh
```

## Environment Structure

```
hipop/                    # Production Environment
├── lib/                  # Flutter source code
├── android/              # Android configuration
├── ios/                  # iOS configuration
├── pubspec.yaml          # Dependencies
└── firebase.json         # Firebase config

hipop-staging/            # Staging Environment  
├── lib/                  # Flutter source code (may have new features)
├── android/              # Android configuration
├── ios/                  # iOS configuration
├── pubspec.yaml          # Dependencies (may differ)
└── firebase.json         # Firebase config (different project)
```

## Analyzing Differences

### 1. Run the Difference Checker

```bash
./scripts/check-differences.sh
```

**Sample Output:**
```
🔍 HiPop Environment Differences
=================================
Production: hipop
Staging: hipop-staging

📊 Directory Stats:
  Production: 16556 files (1.4G)
  Staging: 10949 files (341M)

📚 Dart Files in lib/ Folder:
  Production: 120 Dart files
  Staging: 120 Dart files

🔄 Different Dart Files in lib/:
  📄 lib/main.dart
  📄 lib/firebase_options.dart
  📄 lib/screens/vendor_management_screen.dart

⚠️  Critical Files Status:
  ❌ pubspec.yaml - DIFFERENT
  ❌ lib/main.dart - DIFFERENT
  ❌ lib/firebase_options.dart - DIFFERENT
  ✅ ios/Runner/Info.plist - IDENTICAL

➕ New Files in Staging:
  + lib/models/unified_vendor.dart
  + lib/services/subscription_service.dart

📋 Summary:
  Different files: 15
  Focus areas: lib/ folder, critical config files
```

### 2. Understanding the Output

**🔄 Different Files**: Files that exist in both but have changes
**➕ New Files**: Features added in staging, not in production
**➖ Removed Files**: Files removed from staging
**⚠️ Critical Files**: Important configuration files to review carefully

### 3. Priority Review Order

1. **Critical Config Files** (❌ red items)
   - `pubspec.yaml` - Dependencies and app config
   - `lib/firebase_options.dart` - Firebase configuration
   - `android/app/build.gradle.kts` - Android build config

2. **Core App Files**
   - `lib/main.dart` - App entry point
   - Core service files in `lib/services/`

3. **Feature Files**
   - New screens in `lib/screens/`
   - New models in `lib/models/`
   - UI widgets in `lib/widgets/`

## Syncing Environments

### Method 1: GitHub Actions (Recommended)

**Safe, Automated Deployment**

1. **Go to GitHub Actions**
   - Navigate to your repository on GitHub
   - Click "Actions" tab
   - Find "Deploy Staging to Production" workflow

2. **Run Deployment**
   - Click "Run workflow"
   - Type `DEPLOY` in the confirmation field
   - Click "Run workflow" button

3. **Monitor Deployment**
   - Watch the workflow progress
   - Review the deployment summary
   - Check validation results

**Features:**
- ✅ Requires explicit "DEPLOY" confirmation
- ✅ Automatically validates Flutter and website builds
- ✅ Creates deployment summaries
- ✅ Runs security checks

### Method 2: Command Line Script

**Interactive Local Deployment**

```bash
./scripts/merge-staging-to-production.sh
```

**What it does:**
1. Shows recent commits in staging
2. Asks for confirmation
3. Merges staging → production branch
4. Pushes to GitHub
5. Shows deployment summary

### Method 3: Manual File Sync

**For Specific Files Only**

```bash
# Copy specific files from staging to production
cp hipop-staging/lib/models/new_model.dart hipop/lib/models/
cp hipop-staging/lib/services/new_service.dart hipop/lib/services/

# Test the changes
cd hipop
flutter pub get
flutter analyze
flutter test

# Commit the changes
git add .
git commit -m "Add new features from staging"
git push
```

## Environment-Specific Files

### Files That Should Stay Different

**❗ DO NOT sync these files - they're environment-specific:**

- `lib/firebase_options.dart` - Different Firebase projects
- `firebase.json` - Different Firebase project configs
- `.firebaserc` - Different Firebase project IDs
- `android/app/google-services.json` - Different Android configs
- `ios/Runner/GoogleService-Info.plist` - Different iOS configs

### Files Safe to Sync

**✅ These files can usually be synced safely:**

- New Dart files in `lib/models/`, `lib/services/`, `lib/screens/`
- UI widgets in `lib/widgets/`
- New assets in `assets/`
- Test files in `test/`

### Files to Review Carefully

**⚠️ These files may need manual review:**

- `pubspec.yaml` - Check for new dependencies
- `lib/main.dart` - Core app changes
- Build configuration files
- Database migration scripts

## Best Practices

### Before Syncing

1. **Always check differences first**
   ```bash
   ./scripts/check-differences.sh
   ```

2. **Review critical files manually**
   ```bash
   diff hipop/pubspec.yaml hipop-staging/pubspec.yaml
   diff hipop/lib/main.dart hipop-staging/lib/main.dart
   ```

3. **Backup important files** (if doing manual sync)
   ```bash
   cp hipop/lib/main.dart hipop/lib/main.dart.backup
   ```

### After Syncing

1. **Test the application**
   ```bash
   cd hipop
   flutter pub get
   flutter analyze
   flutter test
   flutter run
   ```

2. **Check for compilation errors**
   ```bash
   flutter build apk --debug
   ```

3. **Verify Firebase connectivity**
   - Test authentication
   - Test database operations
   - Check analytics

4. **Commit and document changes**
   ```bash
   git add .
   git commit -m "Sync features from staging: [describe changes]"
   git push
   ```

## Troubleshooting

### Common Issues

**Dependency Conflicts**
```bash
# If pubspec.yaml has conflicts
cd hipop
flutter clean
flutter pub get
```

**Firebase Configuration Issues**
```bash
# Make sure you're using the right Firebase project
firebase use production  # or staging
```

**Build Errors After Sync**
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter build apk --debug
```

### Getting Help

1. **Check the differences again**
   ```bash
   ./scripts/check-differences.sh
   ```

2. **Review recent commits**
   ```bash
   git log --oneline -10
   ```

3. **Revert if needed**
   ```bash
   git reset --hard HEAD~1  # Revert last commit
   ```

## Quick Reference

| Task | Command |
|------|---------|
| Check differences | `./scripts/check-differences.sh` |
| Sync via GitHub | GitHub Actions → "Deploy Staging to Production" |
| Sync via script | `./scripts/merge-staging-to-production.sh` |
| Test app | `flutter pub get && flutter analyze && flutter test` |
| Clean build | `flutter clean && flutter pub get` |

---

**⚠️ Important:** Always test thoroughly after syncing environments. Different Firebase configurations mean your staging and production will connect to different databases and services.