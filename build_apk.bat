@echo off
set "JAVA_HOME=C:\Users\Tshepo Makola\.antigravity-ide\extensions\redhat.java-1.55.0-win32-x64\jre\21.0.11-win32-x86_64"
set "PATH=%JAVA_HOME%\bin;%PATH%"
set "ANDROID_HOME=C:\Users\Tshepo Makola\AppData\Local\Android\Sdk"
set "ANDROID_SDK_ROOT=C:\Users\Tshepo Makola\AppData\Local\Android\Sdk"

echo [ThutoTech] Building Android APK using Java 21 LTS and Android SDK...
cd frontend\android
call gradlew.bat assembleDebug
if %ERRORLEVEL% NEQ 0 (
    echo [ThutoTech] Build failed with error code %ERRORLEVEL%
    exit /b %ERRORLEVEL%
)

echo.
echo [ThutoTech] =======================================================
echo [ThutoTech] SUCCESS: Android APK Generated!
echo [ThutoTech] Output File: frontend\android\app\build\outputs\apk\debug\app-debug.apk
echo [ThutoTech] =======================================================
