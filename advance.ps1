# Flutter Project Extension Script
param (
    [Parameter(Mandatory=$true)]
    [string]$projectPath
)

function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Create-Directory {
    param (
        [string]$path
    )
    
    if (!(Test-Path $path)) {
        New-Item -ItemType Directory -Path $path -Force | Out-Null
        Write-ColorOutput Green "Created directory: $path"
    }
}

function Create-File {
    param (
        [string]$path,
        [string]$content = ""
    )
    
    if (!(Test-Path $path)) {
        New-Item -ItemType File -Path $path -Force | Out-Null
        if ($content) {
            Set-Content -Path $path -Value $content
        }
        Write-ColorOutput Green "Created file: $path"
    }
}

# Welcome message
Write-ColorOutput Cyan "`n=== Flutter Project Extension Generator ===`n"

# Verify project path
if (!(Test-Path $projectPath)) {
    Write-ColorOutput Red "Project directory not found!"
    exit 1
}

# Configuration prompts
$useFirebase = Read-Host "Will you use Firebase? (y/n)"
$useFastlane = Read-Host "Will you use Fastlane for CI/CD? (y/n)"
$useGithubActions = Read-Host "Will you set up GitHub Actions? (y/n)"
$setupNativeCode = Read-Host "Will you include native code implementations? (y/n)"

# New directory structure
$newDirectories = @(
    # App
    "lib/app/initialization",
    "lib/app/lifecycle",
    "lib/app/navigation/deep_links",
    "lib/app/navigation/guards",
    "lib/app/config",
    
    # Core
    "lib/core/biometrics",
    "lib/core/cache",
    "lib/core/device",
    "lib/core/localization/l10n",
    "lib/core/networking",
    "lib/core/notifications",
    "lib/core/permissions",
    "lib/core/security",
    "lib/core/tracking",
    
    # Features
    "lib/features/onboarding/data/models",
    "lib/features/onboarding/providers",
    "lib/features/onboarding/presentation/screens",
    "lib/features/settings/data/models",
    "lib/features/settings/providers",
    "lib/features/settings/presentation/screens",
    "lib/features/profile/data/models",
    "lib/features/profile/providers",
    "lib/features/profile/presentation/screens",
    "lib/features/notifications/data/models",
    "lib/features/notifications/providers",
    "lib/features/notifications/presentation/screens",
    "lib/features/offline_sync/data/models",
    "lib/features/offline_sync/providers",
    "lib/features/offline_sync/presentation/screens",
    
    # Shared
    "lib/shared/animations",
    "lib/shared/behaviors",
    "lib/shared/styles",
    "lib/shared/widgets/adaptive",
    "lib/shared/widgets/layouts",
    "lib/shared/widgets/states",
    
    # Assets
    "assets/animations",
    "assets/images/1x",
    "assets/images/2x",
    "assets/images/3x",
    "assets/vectors",
    
    # Config
    "config/dev",
    "config/prod",
    "config/staging",
    
    # Tools
    "tools/build_scripts",
    "tools/code_generators",
    "tools/ci_cd/scripts",
    
    # Tests
    "test/fixtures",
    "test/helpers",
    "test/mocks"
)

# Create directories
foreach ($dir in $newDirectories) {
    Create-Directory (Join-Path $projectPath $dir)
}

# Create essential files
$essentialFiles = @{
    # App initialization
    "lib/app/initialization/app_startup.dart" = "import 'package:flutter/material.dart';"
    "lib/app/initialization/dependency_injection.dart" = "// DI configuration"
    "lib/app/initialization/environment_config.dart" = "// Environment specific configuration"
    
    # App lifecycle
    "lib/app/lifecycle/app_lifecycle_observer.dart" = "import 'package:flutter/material.dart';"
    "lib/app/lifecycle/background_handler.dart" = "// Background task handler"
    
    # Config
    "lib/app/config/flavor_config.dart" = @"
enum Flavor { dev, staging, prod }

class FlavorConfig {
  final Flavor flavor;
  final String apiUrl;
  
  FlavorConfig({
    required this.flavor,
    required this.apiUrl,
  });
}"
    
    # Core files
    "lib/core/biometrics/biometric_service.dart" = "// Biometric authentication service"
    "lib/core/security/encryption_service.dart" = "// Encryption service"
    "lib/core/tracking/analytics_events.dart" = "// Analytics event definitions"
    
    # Shared widgets
    "lib/shared/widgets/states/empty_state.dart" = @"
import 'package:flutter/material.dart';

class EmptyStateWidget extends StatelessWidget {
  final String message;
  final VoidCallback? onRetry;

  const EmptyStateWidget({
    Key? key,
    required this.message,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message),
          if (onRetry != null)
            ElevatedButton(
              onPressed: onRetry,
              child: const Text('Retry'),
            ),
        ],
      ),
    );
  }
}"
}

foreach ($file in $essentialFiles.Keys) {
    Create-File (Join-Path $projectPath $file) $essentialFiles[$file]
}

# Conditional file creation based on user choices
if ($useFirebase -eq "y") {
    Create-Directory (Join-Path $projectPath ".firebase")
    $firebaseFiles = @{
        "config/dev/firebase_options.dart" = "// Development Firebase options"
        "config/prod/firebase_options.dart" = "// Production Firebase options"
        ".firebase/firebase_app.dart" = "// Firebase initialization"
    }
    foreach ($file in $firebaseFiles.Keys) {
        Create-File (Join-Path $projectPath $file) $firebaseFiles[$file]
    }
}

if ($useFastlane -eq "y") {
    Create-Directory (Join-Path $projectPath "tools/ci_cd/fastlane")
    $fastlaneFiles = @{
        "tools/ci_cd/fastlane/Fastfile" = "# Fastlane configuration"
        "tools/ci_cd/fastlane/Appfile" = "# App configuration"
    }
    foreach ($file in $fastlaneFiles.Keys) {
        Create-File (Join-Path $projectPath $file) $fastlaneFiles[$file]
    }
}

if ($useGithubActions -eq "y") {
    Create-Directory (Join-Path $projectPath ".github/workflows")
    $githubFiles = @{
        ".github/workflows/ci.yml" = @"
name: CI
on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test
      - run: flutter build apk
"@
        ".github/PULL_REQUEST_TEMPLATE.md" = @"
## Description
Describe your changes here.

## Type of change
- [ ] Bug fix
- [ ] New feature
- [ ] Breaking change
- [ ] Documentation update

## Checklist
- [ ] My code follows the style guidelines
- [ ] I have performed a self-review
- [ ] I have added tests
- [ ] I have updated the documentation
"@
    }
    foreach ($file in $githubFiles.Keys) {
        Create-File (Join-Path $projectPath $file) $githubFiles[$file]
    }
}

if ($setupNativeCode -eq "y") {
    $nativeDirectories = @(
        "native/android/app/src/main/kotlin/native_implementations",
        "native/ios/Runner/native_implementations"
    )
    foreach ($dir in $nativeDirectories) {
        Create-Directory (Join-Path $projectPath $dir)
    }
}

# Update pubspec.yaml with new dependencies
$newDependencies = @"

  # Biometrics
  local_auth: ^2.1.0

  # Storage & Cache
  flutter_secure_storage: ^8.0.0
  cached_network_image: ^3.2.0

  # Device Info
  device_info_plus: ^9.0.0
  package_info_plus: ^4.0.0

  # Localization
  flutter_localizations:
    sdk: flutter
  intl: ^0.18.0

  # Animations
  lottie: ^2.3.0

  # Utils
  permission_handler: ^10.2.0
"@

$pubspecPath = Join-Path $projectPath "pubspec.yaml"
Add-Content -Path $pubspecPath -Value $newDependencies

# Final instructions
Write-ColorOutput Cyan "`nProject structure extended successfully!"
Write-ColorOutput Cyan "Next steps:"
Write-ColorOutput White "1. Review the generated structure"
Write-ColorOutput White "2. Run 'flutter pub get' to install new dependencies"
Write-ColorOutput White "3. Configure environment-specific settings in config/"

if ($useFirebase -eq "y") {
    Write-ColorOutput Yellow "Don't forget to add your Firebase configuration files!"
}
if ($useFastlane -eq "y") {
    Write-ColorOutput Yellow "Configure your Fastlane setup in tools/ci_cd/fastlane/"
}
if ($useGithubActions -eq "y") {
    Write-ColorOutput Yellow "Review and customize the GitHub Actions workflows in .github/workflows/"
}