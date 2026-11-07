#!/usr/bin/env bash
echo "Starting Sahaayi Backend and AI Engine..."
(cd backend && uvicorn app.main:app --port 8000 --reload) &
(cd ai-engine && uvicorn main:app --port 8001 --reload) &
wait
