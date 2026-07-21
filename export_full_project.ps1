# Automatisch den Ordner nehmen, in dem das Skript liegt
$ProjectPath = $PSScriptRoot
if (-not $ProjectPath) { $ProjectPath = "C:\Users\thvnh\Documents\whiplash" } # Fallback

$OutputFile = Join-Path $ProjectPath "_project_export.txt"

# Wirklich ALLES einbinden wie gewünscht
$Extensions = @("*.gd", "*.tscn", "*.tres", "*.gdshader", "*.cfg", "*.import")
$ExcludeDirs = @(".godot", ".import", ".git")

if (Test-Path $OutputFile) { Remove-Item $OutputFile }

$files = Get-ChildItem -Path $ProjectPath -Recurse -Include $Extensions -File | Where-Object {
    $path = $_.FullName
    $exclude = $false
    foreach ($dir in $ExcludeDirs) {
        if ($path -like "*\$dir\*") { $exclude = $true }
    }
    -not $exclude
} | Sort-Object FullName

foreach ($file in $files) {
    $relativePath = $file.FullName.Substring($ProjectPath.Length + 1)
    Add-Content -Path $OutputFile -Value "`n===== FILE: $relativePath =====`n"
    Get-Content -Path $file.FullName -Raw | Add-Content -Path $OutputFile
}

# Auch direkt in die Zwischenablage kopieren (optional, aber extrem praktisch)
Get-Content -Path $OutputFile -Raw | Set-Clipboard

Write-Host "✅ Fertig: $OutputFile" -ForegroundColor Green
Write-Host "📦 Groesse: $([math]::Round((Get-Item $OutputFile).Length / 1KB, 1)) KB"
Write-Host "📄 Dateien zusammengefasst: $($files.Count)"
Write-Host "📋 Text wurde auch in die Zwischenablage kopiert! (Strg + V)" -ForegroundColor Yellow