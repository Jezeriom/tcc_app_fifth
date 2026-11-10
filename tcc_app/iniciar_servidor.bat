@echo off
chcp 65001 > nul
title Sistema de Inventario - Servidor y Lanzador
color 0B

echo =====================================================================
echo           SISTEMA DE GESTION DE INVENTARIOS (TCC)
echo                 Servidor y Lanzador de Aplicacion
echo =====================================================================
echo.

:: Verificar si Flutter esta disponible
where flutter >nul 2>nul
if %ERRORLEVEL% neq 0 (
    echo [ERROR] No se encontro Flutter en el PATH del sistema.
    echo Por favor asegurese de tener Flutter instalado y configurado.
    echo.
    pause
    exit /b 1
)

:: Verificar dependencias
echo [1/3] Verificando dependencias del proyecto...
call flutter pub get
if %ERRORLEVEL% neq 0 (
    echo [ADVERTENCIA] Hubo un inconveniente al actualizar paquetes, continuando...
)

echo.
echo =====================================================================
echo  Seleccione el modo en el que desea ejecutar la aplicacion:
echo =====================================================================
echo.
echo  [1] Iniciar Servidor Web en Navegador (Chrome / Edge) [RECOMENDADO]
echo      - Abre la aplicacion directamente en tu navegador web.
echo.
echo  [2] Iniciar Servidor Web Local (web-server puerto 8080)
echo      - Inicia el servidor accesible en http://localhost:8080
echo.
echo  [3] Iniciar en Emulador Android
echo      - Lanza el emulador Android disponible y ejecuta la app.
echo.
echo  [4] Salir
echo.
echo =====================================================================

set /p OPCION="Ingrese una opcion (1-4) y presione Enter [Por defecto 1]: "

if "%OPCION%"=="" set OPCION=1
if "%OPCION%"=="1" goto MODO_CHROME
if "%OPCION%"=="2" goto MODO_WEBSERVER
if "%OPCION%"=="3" goto MODO_ANDROID
if "%OPCION%"=="4" goto SALIR

echo Opcion no valida, iniciando en modo navegador por defecto...
goto MODO_CHROME

:MODO_CHROME
echo.
echo =====================================================================
echo  Iniciando la aplicacion en el navegador web...
echo =====================================================================
echo.
call flutter run -d chrome --web-port 8080
goto FIN

:MODO_WEBSERVER
echo.
echo =====================================================================
echo  Iniciando Servidor Web en: http://localhost:8080
echo =====================================================================
echo.
start "" cmd /c "timeout /t 4 /nobreak >nul && start http://localhost:8080"
call flutter run -d web-server --web-port 8080 --web-hostname 0.0.0.0
goto FIN

:MODO_ANDROID
echo.
echo =====================================================================
echo  Iniciando en Emulador Android...
echo =====================================================================
echo.
call flutter emulators --launch Pixel_10_Pro_XL >nul 2>nul
call flutter run
goto FIN

:SALIR
echo.
echo Saliendo...
exit /b 0

:FIN
echo.
echo =====================================================================
echo  La sesion de la aplicacion ha finalizado.
echo =====================================================================
pause
