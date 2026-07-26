@echo off
:: Schaltet die Konsolen-Codepage auf UTF-8 um
chcp 65001 > nul

set "REPO_PATH=%~dp0"
set "OUTPUT_FILE=%REPO_PATH%commits.txt"

echo Generiere aktuelle commit.txt in UTF-8...

:: Führt Git Log aus und erzwingt UTF-8 Output
git -c core.quotepath=false -C "%REPO_PATH%." log --format="========================================%%nCommit: %%h%%nDatum:  %%ad%%nAutor:  %%an %%n%%nNachricht:%%n%%B" > "%OUTPUT_FILE%"

if %ERRORLEVEL% EQU 0 (
    echo.
    echo [OK] commits.txt wurde erfolgreich ohne Zeichensatz-Fehler erstellt!
) else (
    echo.
    echo [FEHLER] Git-Repository konnte nicht gelesen werden.
)

timeout /t 2 > nul