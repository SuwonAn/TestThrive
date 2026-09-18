#!/bin/bash

# Test Script
# Usage: ./scripts/test.sh

set -euo pipefail

WORKSPACE="TestThrive/TestThrive.xcworkspace"
SCHEME="TestThrive"
BUILD_DIR="build"

echo "🧪 Running Unit Tests..."

mkdir -p "$BUILD_DIR"

xcodebuild test \
    -workspace "$WORKSPACE" \
    -scheme "$SCHEME" \
    -configuration Debug \
    -derivedDataPath "$BUILD_DIR/DerivedData" \
    -destination "platform=iOS Simulator,name=iPhone 17,OS=latest" \
    -only-testing:TestThriveTests \
    -quiet

echo "✅ Tests completed successfully!"
