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
  - name: Check project files
    run: |
      ls -la
      find . -name pubspec.yaml
  - name: Install dependencies
    run: flutter pub get
    working-directory: .
