#!/usr/bin/env bash
set -e
echo "Running Backend Tests..."
cd backend
pytest tests/ -v
cd ..

echo "Running Flutter Tests..."
cd frontend/mobile
flutter test
cd ../..
