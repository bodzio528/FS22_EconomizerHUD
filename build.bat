rem make ZIP archive
tar.exe -a -c -f FS22_EconomizerHUD.zip modDesc.xml icon_economizer.dds EconomizerHUD.lua

rem copy ZIP to FS22 mods folder
rem xcopy /b/v/y FS22_EconomizerHUD.zip "%userprofile%\Documents\My Games\FarmingSimulator2022\mods"

rem make update mod as well
copy /b/v/y FS22_EconomizerHUD.zip FS22_EconomizerHUD_update.zip
