set "currentDir=%~dp0"
for %%I in ("%currentDir%.") do set "folderName=%%~nxI"

7z.exe a "%folderName%.zip" shaders\ LICENSE README.md