@echo off
echo 🚀 Pushing Flutter Frontend to GitHub Repository
echo Repository: https://github.com/Sora49/sih_qr_host
echo Creating frontend folder structure...

REM Navigate to the main SIH_QR directory
cd /d "c:\Users\gayat\Downloads\SIH_QR\SIH_QR"

REM Initialize git if not already done
git init

REM Set the remote origin to your repository
git remote remove origin 2>nul
git remote add origin https://github.com/Sora49/sih_qr_host.git

REM Create frontend directory structure
mkdir frontend 2>nul

REM Copy Flutter project to frontend folder
echo 📁 Copying Flutter files to frontend folder...
xcopy "sih_qr\*" "frontend\" /E /I /Y

REM Create .gitignore for the root to ignore backend local files
echo Creating .gitignore...
echo # Local backend files > .gitignore
echo backend/.env >> .gitignore
echo backend/venv/ >> .gitignore
echo backend/__pycache__/ >> .gitignore
echo backend/*.pyc >> .gitignore
echo backend/tenders_export_*.xlsx >> .gitignore
echo. >> .gitignore
echo # Flutter build files >> .gitignore
echo frontend/build/ >> .gitignore
echo frontend/.dart_tool/ >> .gitignore
echo frontend/.packages >> .gitignore
echo frontend/pubspec.lock >> .gitignore

REM Add all files except what's in .gitignore
echo 📤 Adding files to git...
git add .

REM Check status
echo 📋 Git status:
git status

REM Commit the changes
echo 💾 Committing changes...
git commit -m "Add Flutter frontend to repository - complete QR scanner app with backend integration"

REM Push to GitHub
echo 🌐 Pushing to GitHub...
git push -u origin main

echo ✅ Done! Frontend pushed to https://github.com/Sora49/sih_qr_host
echo 📁 Frontend files are now in the 'frontend' folder
echo 🗂️  Repository structure:
echo    backend/     - Flask API server
echo    frontend/    - Flutter mobile app
pause