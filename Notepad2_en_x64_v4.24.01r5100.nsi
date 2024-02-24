!include "MUI2.nsh"
!include FileFunc.nsh
!insertmacro GetParameters
!insertmacro GetOptions
!include WinVer.nsh
!include psexec.nsh
;--------------------------------
;General
!define RELEASEVERSION "en_x64_v4.24.01r5100"
!define APPNAME "Notepad2"
Name ${APPNAME}
Caption "Notepad2_${RELEASEVERSION} Setup"
Icon "Notepad2_Installer.ico" ; Update the icon path if necessary
!define MUI_ICON "Notepad2_Installer.ico"
!define MUI_UNICON "Notepad2_Installer.ico"

UninstallIcon "Notepad2_Installer.ico" ; Update the uninstall icon path if necessary
OutFile "notepad2_${RELEASEVERSION}-install.exe"

SetCompressor /SOLID /FINAL lzma

InstallDir "$PROGRAMFILES\Notepad2"
InstallDirRegKey HKLM "Software\Notepad2" "Install_Dir"

RequestExecutionLevel admin
;--------------------------------
;Variables
Var StartMenuFolder
Var installType
;--------------------------------
;Interface Settings
!define MUI_ABORTWARNING
;--------------------------------
;Pages

!insertmacro MUI_PAGE_LICENSE "Notepad2_${RELEASEVERSION}\License.txt"
!insertmacro MUI_PAGE_COMPONENTS
!insertmacro MUI_PAGE_DIRECTORY

;Start Menu Folder Page Configuration
!define MUI_STARTMENUPAGE_REGISTRY_ROOT "HKLM"
!define MUI_STARTMENUPAGE_REGISTRY_KEY "Software\Notepad2"
!define MUI_STARTMENUPAGE_REGISTRY_VALUENAME "Start Menu Folder"

!insertmacro MUI_PAGE_STARTMENU Application $StartMenuFolder
!insertmacro MUI_PAGE_INSTFILES
!insertmacro MUI_UNPAGE_CONFIRM
!insertmacro MUI_UNPAGE_INSTFILES
;--------------------------------

!ifndef NOINSTTYPES
InstType "Typical"
InstType "Minimal"
InstType "Full"
!endif

;--------------------------------
; Parse command line parameters for silent installation type
Function .onInit
    ; Default to minimal installation type
    StrCpy $installType "minimal"

    ; Parse command line for "/i=" parameter
    ClearErrors
    ${GetParameters} $R1
    ${GetOptions} $R1 /I= $R0
    IfErrors notFound
    StrCpy $installType $R0

    notFound:

    ; Assuming SEC02 is the identifier for "Replace Windows Editor"
    ; Check installation type and dynamically adjust section flags
    ${If} $installType == "full"
        SectionGetFlags 2 $R0
        IntOp $R0 $R0 | ${SF_SELECTED}
        SectionSetFlags 2 $R0
    ${Else}
        SectionGetFlags 2 $R0
        IntOp $R0 $R0 & ~${SF_SELECTED}
        SectionSetFlags 2 $R0
    ${EndIf}

FunctionEnd

;--------------------------------
; Installation Sections

Section "Notepad2" SEC01
SectionIn 1 2 3 RO

  SetOutPath $INSTDIR

  ; Include all the binaries and configuration files
  File "Notepad2_${RELEASEVERSION}\Notepad2.exe"
  File "Notepad2_${RELEASEVERSION}\metapath.exe"
  File "Notepad2_${RELEASEVERSION}\metapath.ini"
  File "Notepad2_${RELEASEVERSION}\Notepad2 DarkTheme.ini"
  File "Notepad2_${RELEASEVERSION}\Notepad2.ini"

  WriteRegStr HKLM SOFTWARE\Notepad2 "Install_Dir" "$INSTDIR"

  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2" "DisplayName" "Notepad2"
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2" "UninstallString" '"$INSTDIR\Uninstall.exe"'
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2" "DisplayIcon" "$INSTDIR\Notepad2.exe"
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2" "DisplayVersion" "${RELEASEVERSION}"
  WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2" "NoModify" 1
  WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2" "NoRepair" 1
  WriteUninstaller "Uninstall.exe"

  !insertmacro MUI_STARTMENU_WRITE_BEGIN Application
  !define MUI_STARTMENUPAGE_DEFAULTFOLDER ${APPNAME}
    CreateDirectory "$SMPROGRAMS\$StartMenuFolder"
    CreateShortcut "$SMPROGRAMS\$StartMenuFolder\Notepad2.lnk" "$INSTDIR\Notepad2.exe"
    CreateShortcut "$SMPROGRAMS\$StartMenuFolder\metapath.lnk" "$INSTDIR\metapath.exe"
  !insertmacro MUI_STARTMENU_WRITE_END

SectionEnd
;--------------------------------


Section "Replace Windows Editor" SEC02

  SectionIn 1 3
  ${If} ${SectionIsSelected} ${SEC02}
    ; Replace Windows Notepad with Notepad2
    
  ${If} ${AtLeastWin11}
  ${PowerShellExec} 'Get-AppxPackage *Microsoft.WindowsNotepad* | Remove-AppxPackage'
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "" '$INSTDIR\Notepad2.exe'
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "Debugger" '"$INSTDIR\Notepad2.exe" /z'
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\0\" "FilterFullPath" '$INSTDIR\Notepad2.exe'
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\1\" "FilterFullPath" '$INSTDIR\Notepad2.exe'
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\2\" "FilterFullPath" '$INSTDIR\Notepad2.exe'
  ${Else}
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "Debugger" '"$INSTDIR\Notepad2.exe" /z'
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "" '$INSTDIR\Notepad2.exe'
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "UseFilter" "0"
  ${EndIf}
${EndIf}

SectionEnd


;--------------------------------


; Uninstaller Section
Section "Uninstall"
  Delete $INSTDIR\metapath.exe
  Delete $INSTDIR\metapath.ini
  Delete "$INSTDIR\Notepad2 DarkTheme.ini"
  Delete $INSTDIR\Notepad2.ini
  Delete $INSTDIR\Notepad2.exe
  Delete "$INSTDIR\Uninstall.exe"
  RMDir "$INSTDIR"
  !insertmacro MUI_STARTMENU_GETFOLDER Application $StartMenuFolder

  Delete "$SMPROGRAMS\$StartMenuFolder\Uninstall.lnk"
  RMDir "$SMPROGRAMS\$StartMenuFolder"
  
  ; check if notepad2 is the default notepad.exe value, if so set it back to windows notepad
  ReadRegStr $0 HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" ""
  StrCmp $0 '$INSTDIR\Notepad2.exe' value_matches done
  value_matches:
    ${If} ${AtLeastWin11}
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "" 'C:\Windows\notepad.exe'
    DeleteRegValue  HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "Debugger"
    DeleteRegValue HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\0\" "FilterFullPath"
    DeleteRegValue HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\1\" "FilterFullPath"
    DeleteRegValue HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe\2\" "FilterFullPath"
    ${PowerShellExec} 'Get-AppxPackage -allusers Microsoft.WindowsNotepad | Foreach {Add-AppxPackage -DisableDevelopmentMode -Register $$($_.InstallLocation)\AppXManifest.xml}'

  ${Else}
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "Debugger" '"$INSTDIR\Notepad2.exe" /z'
    WriteRegStr HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "" '$INSTDIR\Notepad2.exe'
    WriteRegDWORD HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "UseFilter" "0"
  ${EndIf}
  
  
  DeleteRegValue  HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "Debugger"
  WriteRegStr HKLM "SOFTWARE\Microsoft\Windows NT\CurrentVersion\Image File Execution Options\notepad.exe" "" 'C:\Windows\notepad.exe'
  done:
  
    ; Remove uninstall information from Add/Remove Programs
  DeleteRegKey HKLM "SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\Notepad2"
  DeleteRegKey HKLM "SOFTWARE\Notepad2"

SectionEnd
