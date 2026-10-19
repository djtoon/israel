@echo off
rem Opens the game from source (game\project.godot) with Godot 4.7.1.
rem Uses the winget install of Godot if present, otherwise "godot" on PATH.
set "G=%LOCALAPPDATA%\Microsoft\WinGet\Packages\GodotEngine.GodotEngine_Microsoft.Winget.Source_8wekyb3d8bbwe\Godot_v4.7.1-stable_win64.exe"
if not exist "%G%" set "G=godot"
"%G%" --path "%~dp0game"
