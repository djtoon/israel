@echo off
rem Launches the live, in-progress build. Builders are editing it, so it may change or break between runs.
rem For the stable gameplay checkpoint, use checkpoints\cp1\PLAY.bat once it exists.
"C:\Users\Dans\AppData\Local\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.1-stable_win64.exe" --path "%~dp0game"
