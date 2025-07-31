# HiPop Environment Management

Quick guides for managing your staging and production environments.

## 🚀 Quick Start

```bash
# Check what's different between environments
./scripts/check-differences.sh

# Deploy staging → production (GitHub)
# Go to: GitHub Actions → "Deploy Staging to Production" → Type "DEPLOY"

# Deploy staging → production (command line)
./scripts/merge-staging-to-production.sh
```

## 📚 Documentation

- **[Environment Sync Guide](ENVIRONMENT_SYNC_GUIDE.md)** - How to analyze differences and sync environments
- **[GitHub Workflow Guide](GITHUB_WORKFLOW_GUIDE.md)** - How to use GitHub Actions for deployment

## 🔧 Available Scripts

| Script | Purpose |
|--------|---------|
| `./scripts/check-differences.sh` | Show differences between staging and production |
| `./scripts/merge-staging-to-production.sh` | Interactive staging → production deployment |
| `./scripts/setup-environment.sh` | Environment setup and management menu |

## 📁 Directory Structure

```
hipop/                    # 🏭 Production Environment
hipop-staging/            # 🧪 Staging Environment
docs/                     # 📖 Documentation
├── ENVIRONMENT_SYNC_GUIDE.md
├── GITHUB_WORKFLOW_GUIDE.md
└── README.md (this file)
scripts/                  # 🛠️ Automation Scripts
├── check-differences.sh
├── merge-staging-to-production.sh
└── setup-environment.sh
.github/workflows/        # ⚙️ GitHub Actions
├── staging-to-production.yml
└── pr-validation.yml
```

## 🎯 Common Tasks

### Check Environment Differences
```bash
./scripts/check-differences.sh
```
Shows:
- Different files in lib/ folder
- Critical configuration file status
- New features in staging
- Summary of changes

### Deploy to Production
**Option 1: GitHub Actions (Recommended)**
1. Go to GitHub → Actions
2. Click "Deploy Staging to Production"
3. Type "DEPLOY" to confirm
4. Monitor progress

**Option 2: Command Line**
```bash
./scripts/merge-staging-to-production.sh
```

### Manual File Sync
```bash
# Copy specific files
cp hipop-staging/lib/models/new_model.dart hipop/lib/models/

# Test changes
cd hipop
flutter pub get && flutter analyze && flutter test

# Commit changes
git add . && git commit -m "Add new model from staging"
```

## ⚠️ Important Notes

- **Firebase configs are different** between environments (staging vs production)
- **Always test** after syncing environments
- **Critical files** (pubspec.yaml, main.dart) need careful review
- **Use GitHub Actions** for safe, validated deployments

## 🆘 Need Help?

1. **Check differences**: `./scripts/check-differences.sh`
2. **Read guides**: See documentation links above
3. **View logs**: GitHub Actions → Workflow runs
4. **Revert changes**: `git reset --hard HEAD~1`

---

**Last Updated**: July 2025  
**Repository**: https://github.com/jwgillispie/hipop