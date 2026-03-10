#!/bin/bash

echo "🧹 Starting comprehensive cleanup..."

# Stop any running Flutter processes
pkill -f flutter || true
sleep 2

# 1. Clean Flutter
echo "1️⃣  Cleaning Flutter..."
flutter clean

# 2. Remove pubspec.lock
echo "2️⃣  Removing pubspec.lock..."
rm -f pubspec.lock

# 3. Clean macOS build artifacts
echo "3️⃣  Cleaning macOS build artifacts..."
rm -rf macos/Pods
rm -rf macos/Podfile.lock
rm -rf macos/Flutter/Flutter-Generated.xcconfig
rm -rf macos/Runner.xcodeproj/project.xcworkspace/xcuserdata
rm -rf macos/Flutter/ephemeral

# 4. Clean Xcode derived data
echo "4️⃣  Cleaning Xcode derived data..."
rm -rf ~/Library/Developer/Xcode/DerivedData/*

# 5. Get fresh dependencies
echo "5️⃣  Getting fresh dependencies..."
flutter pub get

# 6. Reinstall pods
echo "6️⃣  Reinstalling CocoaPods..."
cd macos
pod deintegrate
pod install --repo-update
cd ..

echo "✅ Cleanup complete! Now running Flutter build..."
sleep 2

# 7. Run on macOS
flutter run -d macos

