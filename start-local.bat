@echo off
echo ==============================================
echo    Agile Sprint Simulation - Startup Script
echo ==============================================

echo [1/3] Starting MongoDB...
docker-compose up -d
if %errorlevel% neq 0 (
    echo.
    echo [ERROR] Docker failed to start. 
    echo Please make sure Docker Desktop is RUNNING.
    pause
    exit /b
)

echo.
echo [2/3] Starting Backend Server (Port 3001)...
start "NestJS Backend" cmd /k "cd backend && npm run start:dev"

echo.
echo [3/3] Starting Frontend Client (Port 3000)...
start "Next.js Frontend" cmd /k "cd frontend && npm run dev"

echo.
echo ==============================================
echo    All systems go!
echo    Frontend: http://localhost:3000
echo    Backend:  http://localhost:3001/api
echo ==============================================
pause
