;Copyright (C) 2004-2012 John T. Haller
;Copyright (C) 2008-2012 Brandon Cheng (gluxon)

;Website: http://PortableApps.com/EclipsePortable

;This software is OSI Certified Open Source Software.
;OSI Certified is a certification mark of the Open Source Initiative.

;This program is free software; you can redistribute it and/or
;modify it under the terms of the GNU General Public License
;as published by the Free Software Foundation; either version 2
;of the License, or (at your option) any later version.

;This program is distributed in the hope that it will be useful,
;but WITHOUT ANY WARRANTY; without even the implied warranty of
;MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;GNU General Public License for more details.

;You should have received a copy of the GNU General Public License
;along with this program; if not, write to the Free Software
;Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.

!define PORTABLEAPPNAME "Eclipse Portable"
!define NAME "EclipsePortable"
!define APPNAME "Eclipse"
!define VER "2.0.1.0"
!define WEBSITE "PortableApps.com/EclipsePortable"
!define DEFAULTEXE "eclipse.exe"
!define DEFAULTAPPDIR "App\Eclipse"
!define DEFAULTSETTINGSDIR "Data\settings"
!define LAUNCHERLANGUAGE "English"

;=== Program Details
Name "${PORTABLEAPPNAME}"
OutFile "..\..\${NAME}.exe"
Caption "${PORTABLEAPPNAME} | PortableApps.com"
VIProductVersion "${VER}"
VIAddVersionKey ProductName "${PORTABLEAPPNAME}"
VIAddVersionKey Comments "Allows ${APPNAME} to be run from a removable drive.  For additional details, visit ${WEBSITE}"
VIAddVersionKey CompanyName "PortableApps.com"
VIAddVersionKey LegalCopyright "PortableApps.com & Contributors"
VIAddVersionKey FileDescription "${PORTABLEAPPNAME}"
VIAddVersionKey FileVersion "${VER}"
VIAddVersionKey ProductVersion "${VER}"
VIAddVersionKey InternalName "${PORTABLEAPPNAME}"
VIAddVersionKey LegalTrademarks "PortableApps.com is a Trademark of Rare Ideas, LLC."
VIAddVersionKey OriginalFilename "${NAME}.exe"
;VIAddVersionKey PrivateBuild ""
;VIAddVersionKey SpecialBuild ""

;=== Runtime Switches
CRCCheck On
WindowIcon Off
SilentInstall Silent
AutoCloseWindow True
RequestExecutionLevel user

;=== Best Compression
SetCompress Auto
SetCompressor /SOLID lzma
SetCompressorDictSize 32
SetDatablockOptimize On

;=== Program Icon
Icon "..\..\App\AppInfo\appicon.ico"

;=== Include
;(Standard NSIS)
!include TextFunc.nsh
!include FileFunc.nsh
!include WordFunc.nsh
!include LogicLib.nsh

;(Plugins)
!include StrRep.nsh
!include TextReplace.nsh

;(Macros)
!insertmacro WordReplace
!insertmacro GetParent
!insertmacro GetParameters
!insertmacro GetRoot

;(Custom)
!include ReplaceInFile.nsh
!include ReadINIStrWithDefault.nsh

!include Explode.nsh

;Macro update for RepairUpdir
!define RepairUpdir "!insertmacro RepairUpdir"
!macro  RepairUpdir NewPath  RelativePath
	Push "${RelativePath}"
	Call RepairUpdir
	Pop "${NewPath}"
!macroend
!include RepairUpdir.nsh

;=== Languages
;!insertmacro MUI_LANGUAGE "${LAUNCHERLANGUAGE}"
!include PortableApps.comLauncherLANG_${LAUNCHERLANGUAGE}.nsh

Var PROGRAMDIRECTORY
Var SETTINGSDIRECTORY
Var PROGRAMEXECUTABLE
Var ADDITIONALPARAMETERS
Var MISSINGFILEORPATH

Var ROOT
Var ROOTDOUBLESLASH
Var LASTROOT
Var LASTROOTDOUBLESLASH
Var APPDIRECTORY
Var DATADIRECTORY
Var PARENTDIRECTORY
Var JAVAPATH
Var NSISPATH
Var MINGWPATH
Var ADDITIONALPATHS
Var PARAMETERS
Var WORKSPACE
Var WORKSPACEDOUBLESLASH
Var LASTEXEDIR

Section Main
	;Finding out the drive's letter and parent dir
	${GetParent} "$EXEDIR" "$PARENTDIRECTORY"
	${GetRoot} "$EXEDIR" "$ROOT"
	${GetParameters} "$PARAMETERS"
	${WordReplace} "$ROOT" ":" "\:" "+" "$ROOTDOUBLESLASH"

	;Reading the INI
	${ReadINIStrWithDefault} "$0" "$EXEDIR\${NAME}.ini" "${NAME}" "${APPNAME}Directory" "${DEFAULTAPPDIR}"
	StrCpy "$PROGRAMDIRECTORY" "$EXEDIR\$0"

	${ReadINIStrWithDefault} "$0" "$EXEDIR\${NAME}.ini" "${NAME}" "SettingsDirectory" "${DEFAULTSETTINGSDIR}"
	StrCpy "$SETTINGSDIRECTORY" "$EXEDIR\$0"

	${ReadINIStrWithDefault} "$PROGRAMEXECUTABLE" "$EXEDIR\${NAME}.ini" "${NAME}" "${APPNAME}Executable" "${DEFAULTEXE}"
	;Empty if value is not found
	${ReadINIStrWithDefault} "$JAVAPATH" "$EXEDIR\${NAME}.ini" "${NAME}" "JavaPath" "" 
	${ReadINIStrWithDefault} "$MINGWPATH" "$EXEDIR\${NAME}.ini" "${NAME}" "MinGWPath" "..\CommonFiles\MinGW\bin"
	;Empty if value is not found
	${ReadINIStrWithDefault} "$ADDITIONALPATHS" "$EXEDIR\${NAME}.ini" "${NAME}" "AdditionalPaths" ""
	${ReadINIStrWithDefault} "$ADDITIONALPARAMETERS" "$EXEDIR\${NAME}.ini" "${NAME}" "AdditionalParameters" ""

	${IfNot} ${FileExists} "$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE"

		;No eclipse.exe in [X]:\PortableApps\EclipsePortable\App\Eclipse\ exists
		StrCpy "$MISSINGFILEORPATH" "$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE"
		MessageBox MB_OK|MB_ICONEXCLAMATION "$(LauncherFileNotFound)"
		Abort

	${EndIf}

	;Make relative absolute!
	${If} "$MINGWPATH" != ""
		${RepairUpdir} "$MINGWPATH" "$EXEDIR\$MINGWPATH"
	${EndIf}

	${If} "$JAVAPATH" != ""
		${RepairUpdir} "$JAVAPATH" "$EXEDIR\$JAVAPATH"
	${EndIf}

	;AdditionalPaths will contain multiple directories. We need to make them all absolute.
	${Explode} $0 ";" "$ADDITIONALPATHS"
	StrCpy "$ADDITIONALPATHS" ""
	${For} $1 1 $0
		Pop $2
		${If} "$2" != ""
			${RepairUpdir} "$2" "$EXEDIR\$2"
			StrCpy "$ADDITIONALPATHS" "$ADDITIONALPATHS$2;"
		${EndIf}
	${Next}

	${If} ${FileExists} "$SETTINGSDIRECTORY\${NAME}Settings.ini"

		;Read previous launcher settings
		ReadINIStr "$LASTROOT" "$SETTINGSDIRECTORY\${NAME}Settings.ini" "${NAME}Settings" "LastDrive"
		ReadINIStr "$R1" "$SETTINGSDIRECTORY\${NAME}Settings.ini" "${NAME}Settings" "FirstRun"
		ReadINIStr "$LASTEXEDIR" "$SETTINGSDIRECTORY\${NAME}Settings.ini" "${NAME}Settings" "LastEXEDIrectory"

	${Else}

		;No Launcher settings, lets use defaults!
		CreateDirectory "$SETTINGSDIRECTORY"
		SetOutPath "$SETTINGSDIRECTORY"
		StrCpy "$LASTROOT" "$ROOT"
		StrCpy "$R1" "true"

	${EndIf}

	;Eclipse uses double slashes in paths
	${WordReplace} "$LASTROOT" ":" "\:" "+" "$LASTROOTDOUBLESLASH"

	;Let's create the settings
	CreateDirectory "$PROGRAMDIRECTORY\configuration\.settings"
	${IfNot} ${FileExists} "$PROGRAMDIRECTORY\configuration\.settings\org.eclipse.ui.ide.prefs"
		WriteINIStr "$PROGRAMDIRECTORY\configuration\.settings\org.eclipse.ui.ide.prefs" "${NAME}" "YouShouldNotSeeThis" "IfYouDoThatsBad"
		FileOpen $0 "$PROGRAMDIRECTORY\configuration\.settings\org.eclipse.ui.ide.prefs" w
		FileWrite $0 ""
		FileClose $0
	${EndIf}

	${If} $R1 == "true"
	;This is the first run of EclipsePortable

		;Set up workspace directory with double paths
		${GetParent} "$SETTINGSDIRECTORY" "$DATADIRECTORY"
		StrCpy "$WORKSPACE" "$DATADIRECTORY\workspace"
		${WordReplace} "$WORKSPACE" "\" "\\" "+" "$WORKSPACEDOUBLESLASH"
		${WordReplace} "$WORKSPACEDOUBLESLASH" "$ROOT" "$ROOTDOUBLESLASH" "+" "$WORKSPACEDOUBLESLASH"

		;Set up settings file with workspace
		CreateDirectory "$PROGRAMDIRECTORY\configuration\.settings"
		${ConfigWrite} "$PROGRAMDIRECTORY\configuration\.settings\org.eclipse.ui.ide.prefs" "RECENT_WORKSPACES_PROTOCOL=" "3" "$0"
		${ConfigWrite} "$PROGRAMDIRECTORY\configuration\.settings\org.eclipse.ui.ide.prefs" "MAX_RECENT_WORKSPACES=" "1" "$0"
		${ConfigWrite} "$PROGRAMDIRECTORY\configuration\.settings\org.eclipse.ui.ide.prefs" "SHOW_WORKSPACE_SELECTION_DIALOG=" "false" "$0"
		${ConfigWrite} "$PROGRAMDIRECTORY\configuration\.settings\org.eclipse.ui.ide.prefs" "RECENT_WORKSPACES=" "$WORKSPACEDOUBLESLASH" "$0"
		${ConfigWrite} "$PROGRAMDIRECTORY\configuration\.settings\org.eclipse.ui.ide.prefs" "eclipse.preferences.version=" "1" "$0"
		${ConfigWrite} "$PROGRAMDIRECTORY\configuration\config.ini" "osgi.instance.area.default=" "$WORKSPACEDOUBLESLASH" "$0"

		;EclipseNSIS
		StrCpy "$NSISPATH" "$PARENTDIRECTORY\NSISPortable\App\NSIS"
		${WordReplace} "$NSISPATH" "\\" "\" "+" "$NSISPATH"

	${Else}
	;Mananging Eclipse's settings

		; Get our full workspace
		${ConfigRead} "$PROGRAMDIRECTORY\configuration\.settings\org.eclipse.ui.ide.prefs" "RECENT_WORKSPACES=" "$WORKSPACEDOUBLESLASH"

		;Get our workspace
		${WordReplace} "$WORKSPACEDOUBLESLASH" "\\" "\" "+" "$WORKSPACE"
		${WordReplace} "$WORKSPACE" "$LASTROOTDOUBLESLASH" "$LASTROOT" "+" "$WORKSPACE"
		${WordReplace} "$WORKSPACE" "$LASTEXEDIR" "$EXEDIR" "+" "$WORKSPACE"

		;Explode the workspace directory, so we can support multiple workspaces
		${Explode} $0 "\n" "$WORKSPACE"
		Pop "$WORKSPACE"

		${WordReplace} "$LASTEXEDIR" "\" "\\" "+" "$R2"
		${WordReplace} "$R2" "$LASTROOT" "$LASTROOTDOUBLESLASH" "+" "$R2"
		${WordReplace} "$EXEDIR" "\" "\\" "+" "$R3"
		${WordReplace} "$R3" "$ROOT" "$ROOTDOUBLESLASH" "+" "$R3"

		${WordReplace} "$WORKSPACEDOUBLESLASH" "$R2" "$R3" "+" "$WORKSPACEDOUBLESLASH" 
		${WordReplace} "$WORKSPACEDOUBLESLASH" "$LASTROOTDOUBLESLASH" "$ROOTDOUBLESLASH" "+" "$WORKSPACEDOUBLESLASH" ;Update workspace drive letter.

		${ConfigWrite} "$PROGRAMDIRECTORY\configuration\.settings\org.eclipse.ui.ide.prefs" "RECENT_WORKSPACES=" "$WORKSPACEDOUBLESLASH" "$0"

		;Update Locations
		${ReplaceInFile} "$WORKSPACE\.metadata\.plugins\org.eclipse.ui.workbench\workbench.xml" "$LASTROOT" "$ROOT"
		Delete "$WORKSPACE\.metadata\.plugins\org.eclipse.ui.workbench\workbench.xml.old"

		;Update Workspace with new drive letter path
		${ConfigWrite} "$PROGRAMDIRECTORY\configuration\config.ini" "osgi.instance.area.default=" "$WORKSPACEDOUBLESLASH" "$0"

		;Get EclipseNSIS Paths
		${ConfigRead} "$WORKSPACE\.metadata\.plugins\org.eclipse.core.runtime\.settings\net.sf.eclipsensis.prefs" "nsisHome=" "$NSISPATH"
		${WordReplace} "$NSISPATH" "$LASTROOTDOUBLESLASH" "$ROOTDOUBLESLASH" "+" "$NSISPATH"

	${EndIf}

	;Update EclispeNSIS paths
	${ConfigWrite} "$WORKSPACE\.metadata\.plugins\org.eclipse.core.runtime\.settings\net.sf.eclipsensis.prefs" "nsisHome=" "$NSISPATH" "$0"

	;Redirect AppData
	;System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("APPDATA", "$WORKSPACEDIRECTORY").r0'
	;System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("LOCALAPPDATA", "$WORKSPACEDIRECTORY").r0'

	;Set up MinGW Toolchain and add Additional Paths
	ReadEnvStr $0 "PATH"
	StrCpy $0 "$MINGWPATH;$ADDITIONALPATHS$0" ;$ADDITIONALPATHS already has semicolon appended
	System::Call 'Kernel32::SetEnvironmentVariable(t, t) i("PATH", "$0").r0'

	;Eclipse Portable Settings
	WriteINIStr "$SETTINGSDIRECTORY\${NAME}Settings.ini" "${NAME}Settings" "FirstRun" "False"
	WriteINIStr "$SETTINGSDIRECTORY\${NAME}Settings.ini" "${NAME}Settings" "LastDrive" "$ROOT"
	WriteINIStr "$SETTINGSDIRECTORY\${NAME}Settings.ini" "${NAME}Settings" "LastEXEDirectory" "$EXEDIR"

	${GetParent} "$PROGRAMDIRECTORY" "$APPDIRECTORY"

	${If} ${FileExists} "$JAVAPATH\javaw.exe"
		Exec '"$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE" $PARAMETERS -vm "$JAVAPATH"$ADDITIONALPARAMETERS'
	${ElseIf} ${FileExists} "$APPDIRECTORY\Java\bin\javaw.exe"
		Exec '"$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE" $PARAMETERS -vm "$APPDIRECTORY\Java\bin"$ADDITIONALPARAMETERS'
	${ElseIf} ${FileExists} "$PARENTDIRECTORY\CommonFiles\Java\bin\javaw.exe"
		Exec '"$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE" $PARAMETERS -vm "$PARENTDIRECTORY\CommonFiles\Java\bin"$ADDITIONALPARAMETERS'
	${Else}
		;No Java, let's hope it's installed locally, if not, Ecipse will handle the rest of the errors
		Exec '"$PROGRAMDIRECTORY\$PROGRAMEXECUTABLE"$PARAMETERS $ADDITIONALPARAMETERS'
	${EndIf}
	;Check for Java


SectionEnd