# scripts/dev.ps1 - Development server startup for Windows PowerShell
Write-Host "==========================================================" -ForegroundColor Cyan
Write-Host "🚀 SAHAAYI: Starting Development Services" -ForegroundColor Cyan
Write-Host "==========================================================" -ForegroundColor Cyan

$env:DATABASE_URL_OVERRIDE = "sqlite+aiosqlite:///backend/sahaayi_dev.db"

Write-Host "Starting Backend API on http://127.0.0.1:8000 ..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd backend; `$env:DATABASE_URL_OVERRIDE='sqlite+aiosqlite:///sahaayi_dev.db'; uvicorn app.main:app --host 127.0.0.1 --port 8000 --reload"

Write-Host "Starting AI Engine on http://127.0.0.1:8001 ..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd ai-engine; uvicorn main:app --host 127.0.0.1 --port 8001 --reload"

Write-Host "Starting Flutter Mobile Client ..." -ForegroundColor Green
Start-Process powershell -ArgumentList "-NoExit", "-Command", "cd frontend/mobile; flutter run"

Write-Host "`nAll development processes launched in separate windows!" -ForegroundColor Yellow
Write-Host "Backend API docs: http://127.0.0.1:8000/docs" -ForegroundColor Yellow
Write-Host "AI Engine docs:  http://127.0.0.1:8001/docs" -ForegroundColor Yellow

