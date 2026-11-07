.PHONY: help setup dev-backend dev-ai docker-up docker-down docker-logs test-backend test-frontend lint-backend lint-frontend migrate clean

SHELL := /bin/bash

help:
	@echo "Sahaayi Developer Automation Suite"
	@echo "setup         : Install dependencies across all modules"
	@echo "dev-backend   : Run FastAPI backend with live reload (:8000)"
	@echo "dev-ai        : Run AI Engine microservice (:8001)"
	@echo "docker-up     : Spin up all services in Docker"
	@echo "docker-down   : Stop Docker containers"
	@echo "test-backend  : Run pytest suite"
	@echo "test-frontend : Run Flutter test suite"
	@echo "lint-backend  : Run ruff and black checks"
	@echo "lint-frontend : Run flutter analyze"

setup:
	@test -f .env || cp .env.example .env
	@cd backend && python -m venv venv && pip install -r requirements.txt
	@cd ai-engine && python -m venv venv && pip install -r requirements.txt
	@cd frontend/mobile && flutter pub get

dev-backend:
	@cd backend && uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload

dev-ai:
	@cd ai-engine && uvicorn main:app --host 0.0.0.0 --port 8001 --reload

docker-up:
	@docker compose up -d

docker-down:
	@docker compose down

test-backend:
	@cd backend && pytest --cov=app tests/ -v

test-frontend:
	@cd frontend/mobile && flutter test

lint-backend:
	@cd backend && ruff check app/ tests/

lint-frontend:
	@cd frontend/mobile && flutter analyze

migrate:
	@cd backend && alembic upgrade head
