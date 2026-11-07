#!/usr/bin/env bash
set -e
echo "=================================================="
echo "    Sahaayi Development Environment Setup       "
echo "=================================================="

# Copy environment config
if [ ! -f .env ]; then
    echo "[+] Copying .env.example to .env..."
    cp .env.example .env
fi

# Setup backend
echo "[+] Setting up Backend virtual environment..."
cd backend
python3 -m venv venv || python -m venv venv
source venv/bin/activate || source venv/Scripts/activate
pip install --upgrade pip
pip install -r requirements.txt
cd ..

# Setup AI Engine
echo "[+] Setting up AI Engine virtual environment..."
cd ai-engine
python3 -m venv venv || python -m venv venv
source venv/bin/activate || source venv/Scripts/activate
pip install --upgrade pip
pip install -r requirements.txt
cd ..

# Setup Flutter
echo "[+] Resolving Flutter dependencies..."
cd frontend/mobile
flutter pub get
cd ../..

echo "=================================================="
echo "   Setup Completed! Ready for development.        "
echo "=================================================="
