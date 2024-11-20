# Flutter Enterprise Project Generator
param (
    [Parameter(Mandatory=$false)]
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
        New-Item -ItemType Directory -Path $path | Out-Null
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
Write-ColorOutput Cyan "`n=== Flutter Enterprise Project Generator ===`n"

# Get project details
if (-not $projectPath) {
    $projectName = Read-Host "Enter project name (lowercase, underscore_case)"
    $projectPath = Join-Path (Get-Location) $projectName
}

# Get additional configuration
$useSupabase = Read-Host "Will you use Supabase? (y/n)"
$useAnalytics = Read-Host "Will you include analytics? (y/n)"
$usePushNotifications = Read-Host "Will you include push notifications? (y/n)"
$organizationName = Read-Host "Enter organization name (for package name, e.g., com.example)"

# Create Flutter project
Write-ColorOutput Yellow "`nCreating Flutter project..."
flutter create --org $organizationName --project-name $projectName $projectPath

Set-Location $projectPath

# Create main directory structure
$directories = @(
    "lib/app/theme",
    "lib/app/providers",
    "lib/app/navigation/bottom_navigation/providers",
    "lib/app/navigation/drawer/providers",
    "lib/core/api/interceptors",
    "lib/core/api/models",
    "lib/core/database/abstract",
    "lib/core/database/models",
    "lib/core/constants",
    "lib/core/enums",
    "lib/core/errors",
    "lib/core/extensions",
    "lib/core/hooks",
    "lib/core/models/response",
    "lib/core/models/request",
    "lib/core/services/local_storage",
    "lib/core/services/connectivity",
    "lib/core/utils",
    "lib/features/auth/data/models",
    "lib/features/auth/data/repositories",
    "lib/features/auth/data/datasources",
    "lib/features/auth/providers",
    "lib/features/auth/presentation/screens",
    "lib/features/auth/presentation/widgets",
    "lib/features/home/data/models",
    "lib/features/home/data/repositories",
    "lib/features/home/data/datasources",
    "lib/features/home/providers",
    "lib/features/home/presentation/screens",
    "lib/features/home/presentation/widgets",
    "lib/shared/widgets/navigation",
    "lib/shared/mixins",
    "assets/images/navigation/bottom_nav_icons",
    "assets/images/navigation/drawer_icons",
    "assets/fonts",
    "assets/translations",
    "test/unit/api",
    "test/unit/database",
    "test/widget",
    "test/integration"
)

foreach ($dir in $directories) {
    Create-Directory (Join-Path $projectPath $dir)
}

# Create placeholder files
$placeholderFiles = @{
    "lib/app/app.dart" = "import 'package:flutter/material.dart';"
    "lib/app/router.dart" = "// GoRouter configuration"
    "lib/app/theme/app_theme.dart" = "import 'package:flutter/material.dart';"
    "lib/app/theme/colors.dart" = "import 'package:flutter/material.dart';"
    "lib/core/constants/app_constants.dart" = "// App constants"
    "lib/core/enums/app_enums.dart" = "// App enums"
    "analysis_options.yaml" = "include: package:flutter_lints/flutter.yaml`n`nlinter:`n  rules:`n    prefer_const_constructors: true`n    prefer_const_declarations: true`n    avoid_print: true`n    prefer_single_quotes: true`n    sort_child_properties_last: true"
}

foreach ($file in $placeholderFiles.Keys) {
    Create-File (Join-Path $projectPath $file) $placeholderFiles[$file]
}

# Update pubspec.yaml with common dependencies
$pubspecContent = @"
name: $projectName
description: A new Flutter project.
publish_to: 'none'
version: 1.0.0+1

environment:
  sdk: '>=3.0.0 <4.0.0'

dependencies:
  flutter:
    sdk: flutter
  cupertino_icons: ^1.0.2
  go_router: ^13.0.0
  flutter_riverpod: ^2.4.0
  riverpod_annotation: ^2.3.0
  freezed_annotation: ^2.4.1
  json_annotation: ^4.8.1
  hooks_riverpod: ^2.4.0
  flutter_hooks: ^0.20.0
  dio: ^5.0.0
  shared_preferences: ^2.0.0
  logger: ^2.0.0
"@

# Add conditional dependencies
if ($useSupabase -eq "y") {
    $pubspecContent += "`n  supabase_flutter: ^2.0.0"
}
if ($useAnalytics -eq "y") {
    $pubspecContent += "`n  firebase_analytics: ^10.0.0"
}
if ($usePushNotifications -eq "y") {
    $pubspecContent += "`n  firebase_messaging: ^14.0.0"
}

$pubspecContent += @"

dev_dependencies:
  flutter_test:
    sdk: flutter
  flutter_lints: ^3.0.0
  build_runner: ^2.4.0
  riverpod_generator: ^2.3.0
  freezed: ^2.4.1
  json_serializable: ^6.7.0

flutter:
  uses-material-design: true
  
  assets:
    - assets/images/
    - assets/translations/
    
  fonts:
    - family: Roboto
      fonts:
        - asset: assets/fonts/Roboto-Regular.ttf
        - asset: assets/fonts/Roboto-Bold.ttf
          weight: 700
"@

Set-Content -Path (Join-Path $projectPath "pubspec.yaml") -Value $pubspecContent

# Create .gitignore
$gitignoreContent = @"
# Miscellaneous
*.class
*.log
*.pyc
*.swp
.DS_Store
.atom/
.buildlog/
.history
.svn/

# IntelliJ related
*.iml
*.ipr
*.iws
.idea/

# VSCode related
.vscode/

# Flutter/Dart/Pub related
**/doc/api/
**/ios/Flutter/.last_build_id
.dart_tool/
.flutter-plugins
.flutter-plugins-dependencies
.packages
.pub-cache/
.pub/
/build/

# Web related
lib/generated_plugin_registrant.dart

# Symbolication related
app.*.symbols

# Obfuscation related
app.*.map.json

# Android Studio will place build artifacts here
/android/app/debug
/android/app/profile
/android/app/release

# Environment files
.env
.env.development
.env.production
"@

Set-Content -Path (Join-Path $projectPath ".gitignore") -Value $gitignoreContent

# Create README.md
$readmeContent = @"
# $projectName

## Getting Started

This project is a Flutter enterprise application.

### Prerequisites

- Flutter SDK
- Dart SDK
- IDE (VS Code or Android Studio)

### Installation

1. Clone the repository
2. Run `flutter pub get`
3. Run `flutter pub run build_runner build --delete-conflicting-outputs`

### Project Structure

```
lib/
├── app/          # Application-wide configurations
├── core/         # Core functionality and utilities
├── features/     # Feature modules
└── shared/       # Shared components and utilities
```

### Development

- Run tests: `flutter test`
- Generate code: `flutter pub run build_runner build`
- Format code: `flutter format .`
"@

Set-Content -Path (Join-Path $projectPath "README.md") -Value $readmeContent

# Final steps
Write-ColorOutput Yellow "`nRunning flutter pub get..."
flutter pub get

Write-ColorOutput Cyan "`nProject created successfully!"
Write-ColorOutput Cyan "Next steps:"
Write-ColorOutput White "1. cd $projectName"
Write-ColorOutput White "2. flutter pub run build_runner build --delete-conflicting-outputs"
Write-ColorOutput White "3. Review and customize the generated structure"
Write-ColorOutput White "4. Start building your awesome app!"

if ($useSupabase -eq "y") {
    Write-ColorOutput Yellow "`nDon't forget to configure Supabase credentials in your environment files!"
}
if ($useAnalytics -eq "y" -or $usePushNotifications -eq "y") {
    Write-ColorOutput Yellow "Don't forget to add your Firebase configuration files!"
}
cd..