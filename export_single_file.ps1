Add-Type -AssemblyName System.Windows.Forms

$FilePicker = New-Object System.Windows.Forms.OpenFileDialog
$FilePicker.InitialDirectory = $PSScriptRoot
$FilePicker.Filter = "Godot Dateien (*.gd;*.tscn;*.tres;*.gdshader;*.cfg)|*.gd;*.tscn;*.tres;*.gdshader;*.cfg|Alle Dateien (*.*)|*.*"
$FilePicker.Title = "Waehle eine Datei fuer Claude aus"

$result = $FilePicker.ShowDialog()

if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
    $SelectedFile = $FilePicker.FileName
    
    $ProjectPath = $PSScriptRoot
    if ($SelectedFile.StartsWith($ProjectPath)) {
        $RelativePath = $SelectedFile.Substring($ProjectPath.Length + 1)
    } else {
        $RelativePath = Split-Path $SelectedFile -Leaf
    }

    $FileContent = Get-Content -Path $SelectedFile -Raw
    $FormattedOutput = "`n===== FILE: $RelativePath =====`n`n$FileContent"

    $FormattedOutput | Set-Clipboard

    Write-Host "Kopiert: $RelativePath" -ForegroundColor Green
    Write-Host "Bereit zum Einfuegen bei Claude (Strg + V)!" -ForegroundColor Yellow
} else {
    Write-Host "Auswahl abgebrochen." -ForegroundColor Red
}