name: Build Android APK

on:
push:
branches:
- main
workflow_dispatch:

jobs:
build:
runs-on: ubuntu-latest

steps:
  - name: Checkout repository
    uses: actions/checkout@v4
  - name: Setup Java
    uses: actions/setup-java@v4
    with:
      distribution: temurin
      java-version: '17'
  - name: Setup Flutter
    uses: subosito/flutter-action@v2
    with:
      channel: stable
  - name: Install dependencies
    run: |
      if [ ! -f pubspec.yaml ]; then
        echo "ERROR: pubspec.yaml not found"
        exit 1
      fi
      flutter pub get
  - name: Build APK
    run: flutter build apk --release
  - name: Upload APK
    uses: actions/upload-artifact@v4
    with:
      name: akhwain-furniture-apk
      path: build/app/outputs/flutter-apk/app-release.apk
