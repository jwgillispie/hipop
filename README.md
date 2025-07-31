# HiPop - Local Market Discovery Platform

A Flutter mobile application and Next.js website for connecting shoppers with local markets and vendors.

## 🏗️ Project Structure

```
hipop/                    # 📱 Flutter Mobile App (Production)
├── lib/                  # Dart source code
├── android/              # Android configuration
├── ios/                  # iOS configuration
└── pubspec.yaml          # Dependencies

hipop-staging/            # 🧪 Flutter Mobile App (Staging)
├── lib/                  # Dart source code (with new features)
├── android/              # Android configuration
└── pubspec.yaml          # Dependencies

hipop-website/            # 🌐 Next.js Website
├── src/                  # React/TypeScript source
├── public/               # Static assets
└── package.json          # Dependencies

docs/                     # 📚 Documentation
├── ENVIRONMENT_SYNC_GUIDE.md
├── GITHUB_WORKFLOW_GUIDE.md
└── README.md

scripts/                  # 🛠️ Automation Scripts
├── check-differences.sh
├── merge-staging-to-production.sh
└── setup-environment.sh

.github/workflows/        # ⚙️ GitHub Actions
├── staging-to-production.yml
└── pr-validation.yml
```

## 🚀 Quick Start

### Check Environment Differences
```bash
./scripts/check-differences.sh
```

### Deploy Staging → Production
```bash
# GitHub Actions (Recommended)
# Go to: GitHub → Actions → "Deploy Staging to Production" → Type "DEPLOY"

# Or command line
./scripts/merge-staging-to-production.sh
```

### Setup Development Environment
```bash
./scripts/setup-environment.sh
```

## 📖 Documentation

- **[Environment Sync Guide](docs/ENVIRONMENT_SYNC_GUIDE.md)** - Managing staging and production
- **[GitHub Workflow Guide](docs/GITHUB_WORKFLOW_GUIDE.md)** - Automated deployment workflows
- **[Quick Reference](docs/README.md)** - Common commands and tasks

## 🛠️ Development

### Flutter App
```bash
cd hipop  # or hipop-staging
flutter pub get
flutter run
```

### Website
```bash
cd hipop-website
npm install
npm run dev
```

### Testing
```bash
# Flutter tests
cd hipop
flutter test

# Website tests
cd hipop-website
npm test
```

## 🔒 Security

- Firebase configurations are environment-specific
- Sensitive files are properly gitignored
- Automated security scanning in CI/CD

## 📱 Platforms

- **iOS**: iPhone and iPad support
- **Android**: Phone and tablet support  
- **Web**: Responsive website

## 🤝 Contributing

1. Create feature branch from `main`
2. Merge to `staging` for testing
3. Deploy to `production` via GitHub Actions

## 📧 Contact

For questions about this project, please create an issue on GitHub.

---

**Last Updated**: July 2025  
**Repository**: https://github.com/jwgillispie/hipop
