#!/usr/bin/env bash
echo "Linting Backend..."
cd backend
ruff check app/ tests/ || true
cd ..

echo "Analyzing Flutter App..."
cd frontend/mobile
flutter analyze || true
cd ../..
