@echo off
:: UTF-8 Modus fuer Konsole aktivieren
chcp 65001 > nul

set "PROJECT_DIR=%~dp0"
set "OUTPUT_FILE=%PROJECT_DIR%_project_export.txt"

echo ===================================================
echo 🚀 Starte kompletten Projekt-Export
echo ===================================================
echo.

echo 📦 Generiere kombinierten Export...

powershell -NoProfile -ExecutionPolicy Bypass -Command "$ProjectPath = '%PROJECT_DIR%'.TrimEnd('\'); $OutputFile = '%OUTPUT_FILE%'; $ExtArray = @('.gd','.tscn','.tres','.gdshader','.cfg','.import'); $ExcludeDirs = @('.godot', '.import', '.git'); $NL = [Environment]::NewLine; $files = Get-ChildItem -Path $ProjectPath -Recurse -File | Where-Object { $path = $_.FullName; $name = $_.Name; $exclude = $false; foreach ($dir in $ExcludeDirs) { if ($path -like '*\' + $dir + '\*') { $exclude = $true } }; if ($name -like '_*') { $exclude = $true }; -not $exclude } | Sort-Object FullName; $codeFiles = $files | Where-Object { $ExtArray -contains $_.Extension.ToLower() }; $sb = [System.Text.StringBuilder]::new(); [void]$sb.AppendLine('=================================================='); [void]$sb.AppendLine('TEIL 1: GIT COMMITS UND HISTORY'); [void]$sb.AppendLine('=================================================='); [void]$sb.AppendLine(''); try { Set-Location $ProjectPath; $gitLog = git -c core.quotepath=false log -n 50; if ($gitLog) { [void]$sb.AppendLine(($gitLog -join $NL)) } else { [void]$sb.AppendLine('[HINWEIS] Kein Git-Repository gefunden.') } } catch { [void]$sb.AppendLine('[HINWEIS] Fehler beim Auslesen von Git.') }; [void]$sb.AppendLine(''); [void]$sb.AppendLine('=================================================='); [void]$sb.AppendLine('TEIL 2: DATEIUEBERSICHT UND STRUKTUR'); [void]$sb.AppendLine('Gesamtanzahl Dateien: ' + $files.Count); [void]$sb.AppendLine('=================================================='); [void]$sb.AppendLine(''); foreach ($f in $files) { $rel = $f.FullName.Substring($ProjectPath.Length + 1); [void]$sb.AppendLine('• ' + $rel) }; [void]$sb.AppendLine(''); [void]$sb.AppendLine('=================================================='); [void]$sb.AppendLine('TEIL 3: VOLLSTAENDIGER PROJEKT-CODE (' + $codeFiles.Count + ' DATEIEN)'); [void]$sb.AppendLine('=================================================='); [void]$sb.AppendLine(''); foreach ($file in $codeFiles) { $relativePath = $file.FullName.Substring($ProjectPath.Length + 1); [void]$sb.AppendLine('===== FILE: ' + $relativePath + ' ====='); [void]$sb.AppendLine(''); $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8; [void]$sb.AppendLine($content); [void]$sb.AppendLine('') }; Set-Content -Path $OutputFile -Value $sb.ToString() -Encoding UTF8 -Force; if (Test-Path $OutputFile) { Get-Content -Path $OutputFile -Raw | Set-Clipboard; Write-Host '   [OK] Exportdatei erfolgreich erstellt.' -ForegroundColor Green; Write-Host ('   📄 ' + $codeFiles.Count + ' Code-/Szene-Dateien + Git Log zusammengefasst.') -ForegroundColor Green; Write-Host '   📋 Der gesamte Inhalt wurde in die Zwischenablage kopiert! (Strg + V)' -ForegroundColor Yellow }"

echo.
echo ===================================================
echo 🎉 Fertig! Die Datei liegt direkt im Hauptordner:
echo    %OUTPUT_FILE%
echo ===================================================
echo.
pause