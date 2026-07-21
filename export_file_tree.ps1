# Nimmt automatisch den Ordner, in dem das Skript liegt
$ProjectPath = $PSScriptRoot
if (-not $ProjectPath) { $ProjectPath = Get-Location }

$OutputFile = Join-Path $ProjectPath "_file_list.txt"
$ExcludeDirs = @(".godot", ".import", ".git")

# Zuordnung von Dateiendungen zu anschaulichen Kategorien
function Get-FileType ($extension) {
    switch ($extension.ToLower()) {
        ".gd"        { return "GDScript (Code)" }
        ".gdshader"  { return "Shader" }
        ".tscn"      { return "Godot-Szene" }
        ".tres"      { return "Godot-Ressource/Material" }
        ".import"    { return "Import-Metadaten" }
        ".png"       { return "Textur/Bild (PNG)" }
        ".jpg"       { return "Textur/Bild (JPG)" }
        ".jpeg"      { return "Textur/Bild (JPG)" }
        ".svg"       { return "Vektorgrafik (SVG)" }
        ".glb"       { return "3D-Modell (GLTF/GLB)" }
        ".gltf"      { return "3D-Modell (GLTF)" }
        ".obj"       { return "3D-Modell (OBJ)" }
        ".wav"       { return "Audio (WAV)" }
        ".ogg"       { return "Audio (OGG)" }
        ".mp3"       { return "Audio (MP3)" }
        ".wasm"      { return "WebAssembly (Binaerdatei)" }
        ".pck"       { return "Godot Package (Binaerdatei)" }
        ".exe"       { return "Windows Ausfuehrbar (EXE)" }
        ".cfg"       { return "Konfiguration" }
        ".md"        { return "Markdown-Dokument" }
        ".txt"       { return "Textdatei" }
        default      { 
            if ([string]::IsNullOrWhiteSpace($extension)) { return "Datei ohne Endung" }
            return "Datei ($extension)" 
        }
    }
}

# Dateien suchen und verbotene Ordner/Dateien filtern
$files = Get-ChildItem -Path $ProjectPath -Recurse -File | Where-Object {
    $path = $_.FullName
    $name = $_.Name
    $exclude = $false
    
    foreach ($dir in $ExcludeDirs) {
        if ($path -like "*\$dir\*") { $exclude = $true }
    }
    
    # Ignoriere alle eigenen Export-Skripte / Listen mit fuehrendem Unterstrich
    if ($name -like "_*") { $exclude = $true }
    
    -not $exclude
} | Sort-Object FullName

# Output aufbauen
$sb = [System.Text.StringBuilder]::new()
[void]$sb.AppendLine("==================================================")
[void]$sb.AppendLine("PROJEKT-DATEIUEBERSICHT: $(Split-Path $ProjectPath -Leaf)")
[void]$sb.AppendLine("Gesamtanzahl Dateien: $($files.Count)")
[void]$sb.AppendLine("==================================================`n")

foreach ($file in $files) {
    $relativePath = $file.FullName.Substring($ProjectPath.Length + 1)
    $fileType = Get-FileType -extension $file.Extension
    
    # Ausgabenzeile formatieren
    [void]$sb.AppendLine("• Name: $relativePath")
    [void]$sb.AppendLine("  Art:  $fileType")
    [void]$sb.AppendLine("")
}

# Speichern & In Zwischenablage kopieren
$resultText = $sb.ToString()
Set-Content -Path $OutputFile -Value $resultText -Encoding UTF8
$resultText | Set-Clipboard

Write-Host "Fertig! Liste gespeichert in: $OutputFile" -ForegroundColor Green
Write-Host "Erfasste Dateien: $($files.Count)"
Write-Host "Die Liste wurde direkt in deine Zwischenablage kopiert! (Strg + V)" -ForegroundColor Yellow