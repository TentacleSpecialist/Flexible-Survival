@echo off & setlocal EnableDelayedExpansion

:: BatchGotAdmin
:-------------------------------------
REM  --> Check for permissions
>nul 2>&1 "%SYSTEMROOT%\system32\cacls.exe" "%SYSTEMROOT%\system32\config\system"

REM --> If error flag set, we do not have admin.
if '%errorlevel%' NEQ '0' (
    echo Requesting administrative privileges...
    goto UACPrompt
) else ( goto gotAdmin )

:UACPrompt
    echo Set UAC = CreateObject^("Shell.Application"^) > "%temp%\getadmin.vbs"
    echo UAC.ShellExecute "%~s0", "", "", "runas", 1 >> "%temp%\getadmin.vbs"

    "%temp%\getadmin.vbs"
    exit /B

:gotAdmin
    if exist "%temp%\getadmin.vbs" ( del "%temp%\getadmin.vbs" )
    pushd "%CD%"
    CD /D "%~dp0"
:--------------------------------------

:: Grab the installation path of FS
for /f "usebackq tokens=3*" %%a in (`reg query "HKLM\SOFTWARE\WOW6432Node\Silver Games LLC\flexible" /v "Path"`) do (
	set _FS_ROOT=%%a %%b
)
call :Trim _FS_ROOT_TRIMMED !_FS_ROOT!
set "FS_INSTALLDIR=%_FS_ROOT_TRIMMED%Flexible Survival\Release"

echo [INFO] Starting...

echo [INFO] Making symlink for .ctags in User folder
fsutil reparsepoint query "%USERPROFILE%\.ctags" >nul && (
  echo [INFO]   Removing existing symlink...
  del "%USERPROFILE%\.ctags"
) || (
  echo [INFO]   Backing up .ctags
  move /Y "%USERPROFILE%\.ctags" "%USERPROFILE%\.ctags_old"
)
mklink "%USERPROFILE%\.ctags" "%USERPROFILE%\Documents\Github\Flexible-Survival\.ctags"

echo [INFO] Making symlink for story.ni in Inform folder
fsutil reparsepoint query "%USERPROFILE%\Documents\Inform\Projects\Flexible Survival.inform\Source\story.ni" >nul && (
  echo [INFO]   Removing existing symlink...
  del "%USERPROFILE%\Documents\Inform\Projects\Flexible Survival.inform\Source\story.ni"
) || (
  echo [INFO]   Backing up story.ni
  move /Y "%USERPROFILE%\Documents\Inform\Projects\Flexible Survival.inform\Source\story.ni" "%USERPROFILE%\Documents\Inform\Projects\Flexible Survival.inform\Source\story_old.ni"
)
mklink "%USERPROFILE%\Documents\Inform\Projects\Flexible Survival.inform\Source\story.ni" "%USERPROFILE%\Documents\Github\Flexible-Survival\Inform\story.ni"

echo [INFO] Making symlink for .gblorb in Program Files folder
fsutil reparsepoint query "%FS_INSTALLDIR%\Flexible Survival.gblorb" >nul && (
  echo [INFO]   Removing existing symlink...
  del "%FS_INSTALLDIR%\Flexible Survival.gblorb"
) || (
  echo [INFO]   Backing up .gblorb
  move /Y "%FS_INSTALLDIR%\Flexible Survival.gblorb" "%FS_INSTALLDIR%\Flexible Survival_old.gblorb"
)
mklink "%FS_INSTALLDIR%\Flexible Survival.gblorb" "%USERPROFILE%\Documents\Inform\Projects\Flexible Survival.materials\Release\Flexible Survival.gblorb"

echo [INFO] Making Flexible Survival.materials folder in Inform folder
mkdir "%USERPROFILE%\Documents\Inform\Projects\Flexible Survival.materials"

echo [INFO] Making symlink for Figures folder in Inform folder
rmdir /S /Q "%USERPROFILE%\Documents\Inform\Projects\Flexible Survival.materials\Figures"
mklink /D "%USERPROFILE%\Documents\Inform\Projects\Flexible Survival.materials\Figures" "%USERPROFILE%\Documents\Github\Flexible-Survival\Figures"

echo [INFO] Making symlink for all folders that are not Inform or Figures into the Inform extensions folder
for /d %%D in (*) do (
  IF "%%D"=="Inform" (
    echo [INFO]   * Skipping Inform folder
  ) ELSE (
    IF "%%D"=="Flexible Infection" (
      echo [INFO]   * Skipping Flexible Infection folder
    ) ELSE (
      IF "%%D"=="Figures" (
        echo [INFO]   * Skipping Figures folder
      ) ELSE (
        echo [INFO]   Making symlink for %%D
        rmdir /S /Q "%USERPROFILE%\Documents\Inform\Extensions\%%D"
        mklink /D "%USERPROFILE%\Documents\Inform\Extensions\%%D" "%USERPROFILE%\Documents\Github\Flexible-Survival\%%D"
      )
    )
  )
)

pause
goto :eof

:Trim
set Params=%*
for /f "tokens=1*" %%a in ("!Params!") do set %1=%%b
goto :eof
