# Godot-Projekt in eine einzige Text-Datei zusammenfassen
$ProjectPath = "C:\Users\thvnh\Documents\lemonade"
$OutputFile = Join-Path $ProjectPath "_project_export.txt"

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

Write-Host "Fertig: $OutputFile"
if (Test-Path $OutputFile) {
    Write-Host "Groesse: $([math]::Round((Get-Item $OutputFile).Length / 1KB, 1)) KB"
}
Write-Host "Dateien zusammengefasst: $($files.Count)"