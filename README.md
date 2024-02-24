# NSIS_Notepad2_Installer
A NSIS Script to make an installer for the Notepad2 binaries. Binaries are from: https://github.com/zufuliu/notepad2

For now only an Installer for Notepad2_en_x64_v4.24.01r5100 has been made, but it can easily be adapted to others.

Replacing the default editor under Win11 removes the windows editor (I don't know any other solution), uninstalling Notepad2 will install the editor again.

can be silently installed by calling the installer with /S /I=full or minimal (default or without parameter it installs minimal)
