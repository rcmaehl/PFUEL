#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=Assets/icon.ico
#AutoIt3Wrapper_Outfile=NotCPUCores_x86.exe
#AutoIt3Wrapper_Outfile_x64=NotCPUCores.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=Compiled 2/2/2021 @ ~18:00 EST
#AutoIt3Wrapper_Res_Description=NotCPUCores
#AutoIt3Wrapper_Res_Fileversion=1.7.3.0
#AutoIt3Wrapper_Res_ProductVersion=1.7.3.0
#AutoIt3Wrapper_Res_LegalCopyright=Robert Maehl, using LGPL 3 License
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /sf
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

#include <Misc.au3>
#include <Array.au3>
#include <String.au3>
#include <Process.au3>
#include <Constants.au3>
#include <GUIListView.au3>
#include <GuiComboBox.au3>
#include <WinAPISysWin.au3>
#include <EditConstants.au3>
#include <FileConstants.au3>
#include <ComboConstants.au3>
#include <GUIConstantsEx.au3>
#include <AutoItConstants.au3>
#include <ButtonConstants.au3>
#include <StaticConstants.au3>
#include <WindowsConstants.au3>
#include <ListViewConstants.au3>

#include ".\Includes\_Core.au3"
#include ".\Includes\_WMIC.au3"
#include ".\Includes\_GetSteam.au3"
#include ".\Includes\_Bitwise64.au3"
;#include ".\Includes\_ModeSelect.au3"
#include ".\Includes\_GetLanguage.au3"
#include ".\Includes\_ExtendedFunctions.au3"

Opt("TrayIconHide", 1)
Opt("TrayMenuMode", 1)
Opt("TrayAutoPause", 0)
Opt("GUICloseOnESC", 0)
Opt("GUIResizeMode", $GUI_DOCKALL)

_LoadLanguage()

PreFlightCheck()

; Allow any function to set
Global $bInterrupt = False

; Reduce unneeded variable setting or function calls
If Not IsDeclared("bAdmin") Then Global Static $bAdmin = IsAdmin()

Global Static $iCores = _GetCPUInfo(0)
Global Static $iThreads = _GetCPUInfo(1)
Global Static $sSocket = _GetCPUInfo(3)

Main()

Func Main()

	; One Time Variable Setting

	Local $aExclusions[0]

	Local $aCores
	Local $bHPET = False
	Local $bInit = True
	Local $bReset = False
	Local $iSleep = 100
	Local $aActive[2] = [False, ""]
	Local $aUnload[0]
	Local $hLibrary = ""
	Local $hProfile = "Autoload.ncc"
	Local $sVersion = "1.7.3.0"
	Local $iAllCores
	Local $sPriority = "High"
	Local $sBPriority = "High"
	Local $aProcesses[3] = [$aUnload, "", $aExclusions]
	Local $iProcesses = 0
	Local $iProcessCores = 1
	Local $iBroadcasterCores = 0
	Local $iOtherProcessCores = 1

	If $iThreads > 64 Then $iThreads = 64

	For $iLoop = 0 To $iThreads - 1
		$iAllCores += 2^$iLoop
	Next

	Local $hGUI = GUICreate("NotCPUCores", 640, 480, -1, -1, BitOr($WS_MINIMIZEBOX, $WS_CAPTION, $WS_SYSMENU))
	GUISetOnEvent($GUI_EVENT_CLOSE, "OnInterrupt")
	GUISetFont($_sLang_GUIFontSize, $_sLang_GUIFontWeight, 0, $_sLang_GUIFontName)

	#Region ; Dummy Controls
	Local $hClear = GUICtrlCreateDummy()
	Local $hRefresh = GUICtrlCreateDummy()
	Local $hInterrupt = GUICtrlCreateDummy()
	GUICtrlSetOnEvent(-1, "OnInterrupt")
	#EndRegion

	Local $aHotkeys[4][2] = [["{F5}", $hRefresh], ["{PAUSE}", $hInterrupt], ["{BREAK}", $hInterrupt], ["{DEL}", $hClear]]
	GUISetAccelerators($aHotkeys)

	#Region ; File Menu
	Local $hMenu1 = GUICtrlCreateMenu($_sLang_FileMenu)
	Local $hLoad = GUICtrlCreateMenuItem($_sLang_FileLoad, $hMenu1)
	Local $hSave = GUICtrlCreateMenuItem($_sLang_FileSave, $hMenu1)
	GUICtrlCreateMenuItem("", $hMenu1)
	Local $hQuit = GUICtrlCreateMenuItem($_sLang_FileQuit, $hMenu1)
	GUICtrlSetOnEvent(-1, "OnInterrupt")
	#EndRegion

	#Region ; Options Menu
	Local $hMenu2 = GUICtrlCreateMenu($_sLang_OptionsMenu)
	Local $hLang = GUICtrlCreateMenu($_sLang_TextMenu, $hMenu2)
	Local $hCLang = GUICtrlCreateMenuItem($_sLang_TextCurrent & ": " & $_sLang_Language, $hLang)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlCreateMenuItem("", $hLang)
	Local $hLoadLanguage = GUICtrlCreateMenuItem($_sLang_TextLoad, $hLang)
	Local $hResetLanguage = GUICtrlCreateMenuItem("Reset to Default Language", $hLang)
	Local $hTimer = GUICtrlCreateMenu($_sLang_SleepMenu, $hMenu2)
	Local $hGetTimer = GUICtrlCreateMenuItem($_sLang_SleepCurrent & ": " & $iSleep & "ms", $hTimer)
	GUICtrlSetState(-1, $GUI_DISABLE)
	GUICtrlCreateMenuItem("", $hTimer)
	Local $hSetTimer = GUICtrlCreateMenuItem($_sLang_SleepSet, $hTimer)
	Local $hSteam = GUICtrlCreateMenu("Steam", $hMenu2)
	Local $hSetLibrary = GUICtrlCreateMenuItem($_sLang_SetLibrary, $hSteam)
	Local $hRemLibrary = GUICtrlCreateMenuItem($_sLang_RemLibrary, $hSteam)
	#EndRegion

	#Region ; Help Menu
	Local $hMenu3 = GUICtrlCreateMenu($_sLang_HelpMenu)
	Local $hGithub = GUICtrlCreateMenuItem($_sLang_HelpSite, $hMenu3)
	Local $hDiscord = GUICtrlCreateMenuItem($_sLang_HelpCord, $hMenu3)
	GUICtrlCreateMenuItem("", $hMenu3)
	Local $hHowTo = GUICtrlCreateMenuItem($_sLang_HelpHowTo, $hMenu3)
	Local $hDonate = GUICtrlCreateMenuItem($_sLang_HelpDonate, $hMenu3)
	GUICtrlCreateMenuItem("", $hMenu3)
	Local $hUpdate = GUICtrlCreateMenuItem($_sLang_HelpUpdate, $hMenu3)
	#EndRegion

	GUICtrlCreateTab(0, 0, 280, 275)

	#Region ; Work Tab
	;GUICtrlCreateTabItem($_sLang_WorkTab)

	#EndRegion

	#Region ; Play Tab
	GUICtrlCreateTabItem($_sLang_PlayTab)

	GUICtrlCreateLabel($_sLang_PlayText, 5, 25, 250, 15, $SS_CENTER + $SS_SUNKEN)
		GUICtrlSetBkColor(-1, 0xF0F0F0)

	Local $hDToggle = GUICtrlCreateButton("D", 250, 25, 20, 15)
		GUICtrlSetTip($hDToggle, $_sLang_DebugTip)


	GUICtrlCreateLabel($_sLang_OptimizeProcess & ":", 10, 50, 140, 15)

	Local $hTask = GUICtrlCreateInput("", 150, 45, 100, 20, $ES_UPPERCASE + $ES_RIGHT + $ES_AUTOHSCROLL)
		GUICtrlSetTip(-1, $_sLang_OptimizeTip & @CRLF & _
			$_sLang_Example & ": NOTEPAD.EXE" & @CRLF & _
			$_sLang_Example & ": NOTEPAD.EXE|CHROME.EXE" , $_sLang_Usage, $TIP_NOICON)

	Local $hSearch = GUICtrlCreateButton(ChrW(8678), 250, 45, 20, 20)
		GUICtrlSetFont(-1, 12)
		GUICtrlSetTip(-1, $_sLang_ImportTip, $_sLang_Usage, $TIP_NOICON)

	GUICtrlCreateLabel($_sLang_IncludeChildren, 10, 75, 140, 20)

	Local $hChildren = GUICtrlCreateCheckbox("", 150, 70, 120, 20, $BS_RIGHTBUTTON)
		GUICtrlSetTip(-1, $_sLang_ChildrenTip, $_sLang_Usage, $TIP_NOICON)
		GUICtrlSetState(-1, $GUI_DISABLE)

	GUICtrlCreateLabel($_sLang_AllocationMode & ":", 10, 100, 140, 15)

	Local $hAssignMode = GUICtrlCreateCombo("", 150, 95, 120, 20, $CBS_DROPDOWNLIST)
		If $iCores = $iThreads Then
			GUICtrlSetData(-1, _
			$_sLang_AllocAll & "|" & _
			$_sLang_AllocFirst & "|" & _
			$_sLang_AllocFirstTwo & "|" & _
			$_sLang_AllocFirstFour & "|" & _
			$_sLang_AllocFirstHalf & "|" & _
			$_sLang_AllocEven & "|" & _
			$_sLang_AllocOdd & "|" & _
			$_sLang_AllocPairs & "|" & _
			$_sLang_AllocFirstAMD & "|" & _
			$_sLang_AllocCustom, $_sLang_AllocAll)
		Else
			GUICtrlSetData(-1, _
			$_sLang_AllocAll & "|" & _
			$_sLang_AllocFirst & "|" & _
			$_sLang_AllocFirstTwo & "|" & _
			$_sLang_AllocFirstFour & "|" & _
			$_sLang_AllocFirstHalf & "|" & _
			$_sLang_AllocPhysical & "|" & _
			$_sLang_AllocVirtual & "|" & _
			$_sLang_AllocPairs & "|" & _
			$_sLang_AllocFirstAMD & "|" & _
			$_sLang_AllocCustom, $_sLang_AllocAll)
		EndIf

	GUICtrlCreateLabel($_sLang_Assignments & ":", 10, 125, 140, 15)

	Local $hCores = GUICtrlCreateInput("", 150, 120, 120, 20, $ES_UPPERCASE + $ES_RIGHT + $ES_AUTOHSCROLL)
		GUICtrlSetTip(-1, $_sLang_AssignTip1 & @CRLF & _
			$_sLang_AssignTip2 & @CRLF & _
			$_sLang_AssignTip3 & @CRLF & _
			$_sLang_Example & ": 1,3,4-6" & @TAB & @TAB & $_sLang_AssignTip4 & ": " & $iThreads, $_sLang_Usage, $TIP_NOICON)
		If $iThreads <= 4 Then
			GUICtrlSetData(-1, "1-" & $iThreads)
		ElseIf $iThreads <= 6 Then
			GUICtrlSetData(-1, "1-4")
		Else
			GUICtrlSetData(-1, "1-" & Ceiling($iThreads/2))
		EndIf
		GUICtrlSetState(-1, $GUI_DISABLE)

	GUICtrlCreateLabel($_sLang_OptimizePriority & ":", 10, 150, 140, 15)

	Local $hPPriority = GUICtrlCreateCombo("", 150, 145, 120, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData(-1, _
		$_sLang_PriorityLow & "|" & _
		$_sLang_PriorityBNormal & "|" & _
		$_sLang_PriorityNormal & "|" & _
		$_sLang_PriorityANormal & "|" & _
		$_sLang_PriorityHigh & "|" & _
		$_sLang_PriorityRealtime, $_sLang_PriorityHigh)
	#EndRegion

	#Region ; Stream Tab
	GUICtrlCreateTabItem($_sLang_StreamTab)

	GUICtrlCreateLabel($_sLang_StreamText, 5, 25, 270, 15, $SS_CENTER + $SS_SUNKEN)
		GUICtrlSetBkColor(-1, 0xF0F0F0)

	GUICtrlCreateLabel($_sLang_StreamSoftware & ":", 10, 50, 140, 15)

	Local $hBroadcaster = GUICtrlCreateCombo("", 150, 45, 120, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData(-1, "-|LightStream|OBS|ReLive|StreamLabs|ShadowPlay|vMix|Wirecast|XSplit", "-")

	GUICtrlCreateLabel($_sLang_IncludeChildren, 10, 75, 140, 20)

	Local $hBroChild = GUICtrlCreateCheckbox("", 150, 70, 120, 20, $BS_RIGHTBUTTON)
		GUICtrlSetTip(-1, $_sLang_ChildrenTip, $_sLang_Usage, $TIP_NOICON)
		GUICtrlSetState(-1, $GUI_DISABLE)

	GUICtrlCreateLabel($_sLang_AllocationMode & ":", 10, 100, 140, 15)

	Local $hSplitMode = GUICtrlCreateCombo("", 150, 95, 120, 20, $CBS_DROPDOWNLIST)
		If $iCores = $iThreads Then
			GUICtrlSetData(-1, _
			$_sLang_AllocAll & "|" & _
			$_sLang_AllocLast & "|" & _
			$_sLang_AllocLastTwo & "|" & _
			$_sLang_AllocLastFour & "|" & _
			$_sLang_AllocLastHalf & "|" & _
			$_sLang_AllocEven & "|" & _
			$_sLang_AllocOdd & "|" & _
			$_sLang_AllocPairs & "|" & _
			$_sLang_AllocLastAMD & "|" & _
			$_sLang_AllocCustom, $_sLang_AllocLastHalf)
		Else
			GUICtrlSetData(-1, _
			$_sLang_AllocAll & "|" & _
			$_sLang_AllocLast & "|" & _
			$_sLang_AllocLastTwo & "|" & _
			$_sLang_AllocLastFour & "|" & _
			$_sLang_AllocLastHalf & "|" & _
			$_sLang_AllocPhysical & "|" & _
			$_sLang_AllocVirtual & "|" & _
			$_sLang_AllocPairs & "|" & _
			$_sLang_AllocLastAMD & "|" & _
			$_sLang_AllocCustom, $_sLang_AllocLastHalf)
		EndIf
		GUICtrlSetState(-1, $GUI_DISABLE)

	GUICtrlCreateLabel($_sLang_Assignments & ":", 10, 125, 140, 15)

	Local $hBCores = GUICtrlCreateInput("2", 150, 120, 120, 20, $ES_UPPERCASE + $ES_RIGHT + $ES_AUTOHSCROLL)
		GUICtrlSetTip(-1, $_sLang_AssignTip1 & @CRLF & _
			$_sLang_AssignTip2 & @CRLF & _
			$_sLang_AssignTip3 & @CRLF & _
			$_sLang_Example & ": 1,3,4-6" & @TAB & @TAB & $_sLang_AssignTip4 & ": " & $iThreads, $_sLang_Usage, $TIP_NOICON)
		GUICtrlSetState(-1, $GUI_DISABLE)
		If $iThreads > 2 Then
			If $iThreads = 3 Then
				GUICtrlSetData(-1, "3")
			Else
				GUICtrlSetData(-1, Ceiling($iThreads/2) + 1 & "-" & $iThreads)
			EndIf
		EndIf

	GUICtrlCreateLabel($_sLang_OptimizePriority & ":", 10, 150, 140, 15)

	Local $hBPriority = GUICtrlCreateCombo("", 150, 145, 120, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData(-1, _
		$_sLang_PriorityLow & "|" & _
		$_sLang_PriorityBNormal & "|" & _
		$_sLang_PriorityNormal & "|" & _
		$_sLang_PriorityANormal & "|" & _
		$_sLang_PriorityHigh & "|" & _
		$_sLang_PriorityRealtime, $_sLang_PriorityHigh)

	GUICtrlCreateLabel($_sLang_StreamOtherAssign & ":", 10, 175, 140, 20)

	Local $hOAssign = GUICtrlCreateCombo("", 150, 170, 120, 20, $CBS_DROPDOWNLIST)
		GUICtrlSetData(-1, _
			$_sLang_AllocBroadcaster & "|" & _
			$_sLang_AllocProcess & "|" & _
			$_sLang_AllocRemaining & "|", $_sLang_AllocRemaining)
		GUICtrlSetState(-1, $GUI_DISABLE)

	#EndRegion

	#Region ; Tools Tab
	GUICtrlCreateTabItem($_sLang_ToolTab)

	GUICtrlCreateLabel($_sLang_GameSection, 5, 25, 80, 15, $SS_CENTER + $SS_SUNKEN)
		GUICtrlSetBkColor(-1, 0xF0F0F0)

	Local $hGameM = GUICtrlCreateButton($_sLang_GameMode, 5, 40, 80, 40, $BS_MULTILINE)
		GUICtrlSetImage(-1, "shell32.dll", -208)
		If @OSVersion = "WIN_10" Then
			If @OSBuild < 15007 Then GUICtrlSetState(-1, $GUI_DISABLE)
		Else
			GUICtrlSetState(-1, $GUI_DISABLE)
		EndIf

	Local $hHAGS = GUICtrlCreateButton($_sLang_HAGS, 5, 85, 80, 40, $BS_MULTILINE)
		GUICtrlSetImage(-1, "imageres.dll", -30)
		If @OSVersion = "WIN_10" Then
			If @OSBuild < 19041 Then GUICtrlSetState(-1, $GUI_DISABLE)
			If StringInStr(_GetGPUInfo(0), "nvidia") Then
				Select
					Case FileExists("C:\Program Files\NVIDIA Corporation\NVSMI\nvml.dll") ; Older Drivers
						If StringReplace(FileGetVersion("C:\Program Files\NVIDIA Corporation\NVSMI\nvml.dll", $FV_FILEDESCRIPTION), "NVIDIA Management Library ", "") < 451.48 Then GUICtrlSetState(-1, $GUI_DISABLE)
					Case FileExists("C:\Windows\System32\nvml.dll") ; Newer Drivers
						If StringReplace(FileGetVersion("C:\Windows\System32\nvml.dll", $FV_FILEDESCRIPTION), "NVIDIA Management Library ", "") < 451.48 Then GUICtrlSetState(-1, $GUI_DISABLE)
					Case FileExists("C:\Windows\System32\nvcuda.dll") ; May Fail if Nvidia Ever Stops using CUDA
						If StringReplace(FileGetVersion("C:\Windows\System32\nvcuda.dll", $FV_FILEDESCRIPTION), "NVIDIA CUDA Driver, Version ", "") < 451.48 Then GUICtrlSetState(-1, $GUI_DISABLE)
				EndSelect
			Else
				GUICtrlSetState(-1, $GUI_DISABLE)
			EndIf
		Else
			GUICtrlSetState(-1, $GUI_DISABLE)
		EndIf

	Local $hHPET = GUICtrlCreateButton($_sLang_HPET, 5, 130, 80, 40, $BS_MULTILINE)
		GUICtrlSetImage(-1, "imageres.dll", -30)

	GUICtrlCreateLabel($_sLang_DiskSection, 100, 25, 80, 15, $SS_CENTER + $SS_SUNKEN)
		GUICtrlSetBkColor(-1, 0xF0F0F0)

	Local $hDefrag = GUICtrlCreateButton($_sLang_DiskDefrag, 100, 40, 80, 40, $BS_MULTILINE)
		GUICtrlSetImage(-1, "shell32.dll", -81)

	Local $hCleanup = GUICtrlCreateButton($_sLang_DiskCleanup, 100, 85, 80, 40, $BS_MULTILINE)
		GUICtrlSetImage(-1, "shell32.dll", -32)

	Local $hCheck = GUICtrlCreateButton($_sLang_DiskCheck, 100, 130, 80, 40, $BS_MULTILINE)
		GUICtrlSetImage(-1, "shell32.dll", -271)

	Local $hSSense = GUICtrlCreateButton($_sLang_StorageSense, 100, 175, 80, 40, $BS_MULTILINE)
		If @OSVersion = "WIN_10" Then
			If @OSBuild < 16299 Then GUICtrlSetState(-1, $GUI_DISABLE)
		Else
			GUICtrlSetState(-1, $GUI_DISABLE)
		EndIf
		GUICtrlSetImage(-1, "shell32.dll", -167)

	GUICtrlCreateLabel($_sLang_ReliabilitySection, 195, 25, 80, 15, $SS_CENTER + $SS_SUNKEN)
		GUICtrlSetBkColor(-1, 0xF0F0F0)

	Local $hEvents = GUICtrlCreateButton($_sLang_RecentEvents, 195, 40, 80, 40, $BS_MULTILINE)
		GUICtrlSetImage(-1, "shell32.dll", -208)

	Local $hActions = GUICtrlCreateButton($_sLang_ActionCenter, 195, 85, 80, 40, $BS_MULTILINE)
		If @OSVersion = "Win_Vista" Then
			GUICtrlSetImage(-1, "imageres.dll", -73)
		Else
			GUICtrlSetImage(-1, "ActionCenter.dll", 1)
		EndIf

	Local $hPower = GUICtrlCreateButton($_sLang_PowerOptions, 195, 130, 80, 40, $BS_MULTILINE)
		GUICtrlSetImage(-1, "powercpl.dll", 1)

	#EndRegion

	#Region ; Specs Tab
	GUICtrlCreateTabItem($_sLang_SpecsTab)

	GUICtrlCreateLabel($_sLang_SpecsOSSection, 5, 25, 270, 15, $SS_CENTER + $SS_SUNKEN)
		GUICtrlSetBkColor(-1, 0xF0F0F0)

	GUICtrlCreateLabel($_sLang_SpecsOS & ":", 10, 45, 70, 15)
		GUICtrlCreateLabel(StringReplace(_GetOSInfo(0), "Microsoft ", "") & " " & _GetOSInfo(1), 40, 45, 230, 20, $ES_RIGHT)

	GUICtrlCreateLabel($_sLang_SpecsLanguage & ":", 10, 65, 70, 15)
		GUICtrlCreateLabel(_GetLanguage(), 80, 65, 190, 20, $ES_RIGHT)

	GUICtrlCreateLabel($_sLang_SpecsHardwareSection, 5, 90, 270, 15, $SS_CENTER + $SS_SUNKEN)
		GUICtrlSetBkColor(-1, 0xF0F0F0)

	GUICtrlCreateLabel($_sLang_SpecsMobo & ":", 10, 110, 70, 15)
		GUICtrlCreateLabel(_GetMotherboardInfo(0) & " " & _GetMotherboardInfo(1), 10, 125, 260, 20, $ES_RIGHT)

	GUICtrlCreateLabel($_sLang_SpecsCPU & ":", 10, 145, 50, 15)
		GUICtrlCreateLabel(_GetCPUInfo(2), 10, 160, 260, 20, $ES_RIGHT)

	GUICtrlCreateLabel($_sLang_SpecsRAM & ":", 10, 180, 70, 15)
		GUICtrlCreateLabel(Round(MemGetStats()[1]/1048576) & " GB @ " & _GetRAMInfo(0) & " MHz", 10, 195, 260, 20, $ES_RIGHT)

	GUICtrlCreateLabel($_sLang_SpecsGPU & ":", 10, 215, 70, 15)
		GUICtrlCreateLabel(_GetGPUInfo(0), 10, 230, 260, 30, $ES_RIGHT)

	#EndRegion

	#Region ; About Tab
	GUICtrlCreateTabItem($_sLang_AboutTab)

	GUICtrlCreateLabel(@CRLF & "NotCPUCores" & @TAB & "v" & $sVersion & @CRLF & _
		$_sLang_AboutLicense & " LGPL-3.0" & @CRLF & _
		$_sLang_AboutDeveloper & " Robert Maehl" & @CRLF & _
		$_sLang_AboutIcon & " /u/ImRealNow" & @CRLF & _
		$_sLang_AboutLanguage & " " & $_sLang_Translator, 5, 25, 270, 80, $SS_CENTER)
		GUICtrlSetBkColor(-1, 0xF0F0F0)

	#EndRegion
	GUICtrlCreateTabItem("")

	Local $hReset = GUICtrlCreateButton($_sLang_Restore, 5, 275, 135, 20)
	Local $hOptimize = GUICtrlCreateButton($_sLang_Optimize, 140, 275, 135, 20)

	$hQuickTabs = GUICreate("", 360, 300, 280, 0, $WS_POPUP, $WS_EX_MDICHILD, $hGUI)
	GUISetAccelerators($aHotkeys)
	GUISetFont($_sLang_GUIFontSize, $_sLang_GUIFontWeight, 0, $_sLang_GUIFontName)

	$hTabs = GUICtrlCreateTab(0, 0, 360, 300)

	#Region ; Process List
	GUICtrlCreateTabItem($_sLang_RunningTab)
	Local $bPHidden = False
	Local $hProcesses = GUICtrlCreateListView($_sLang_ProcessList & "|" & $_sLang_ProcessTitle, 0, 20, 360, 280, $LVS_REPORT+$LVS_SINGLESEL, $LVS_EX_GRIDLINES+$LVS_EX_FULLROWSELECT+$LVS_EX_DOUBLEBUFFER+$LVS_EX_FLATSB)
		_GUICtrlListView_RegisterSortCallBack($hProcesses)
		GUICtrlSetTip(-1, $_sLang_RefreshTip, $_sLang_Usage)

	_GetProcessList($hProcesses)
	_GUICtrlListView_SortItems($hProcesses, 0)
	#EndRegion

	#Region ; Games List
	GUICtrlCreateTabItem($_sLang_GamesTab)
	Local $hGames = GUICtrlCreateListView($_sLang_GameID & "|" & $_sLang_GameName, 0, 20, 360, 280, $LVS_REPORT+$LVS_SINGLESEL, $LVS_EX_GRIDLINES+$LVS_EX_FULLROWSELECT+$LVS_EX_DOUBLEBUFFER)
		_GUICtrlListView_RegisterSortCallBack($hGames)
		GUICtrlSetTip(-1, $_sLang_RefreshTip, $_sLang_Usage)

	_GetSteamGames($hGames, $hLibrary)
	_GUICtrlListView_SortItems($hGames, 1)
	#EndRegion
	$bPHidden = True

	#Region ; Exclusion List
	GUICtrlCreateTabItem($_sLang_ExclusionsTab)
	Local $hExclusions = GUICtrlCreateListView($_sLang_ProcessList, 0, 20, 360, 280, $LVS_REPORT+$LVS_SINGLESEL, $LVS_EX_GRIDLINES+$LVS_EX_FULLROWSELECT+$LVS_EX_DOUBLEBUFFER)
		_GUICtrlListView_RegisterSortCallBack($hExclusions)
		GUICtrlSetTip(-1, $_sLang_RefreshTip, $_sLang_Usage)

	$aExclusions = _GetExclusionsList($hExclusions)
	_GUICtrlListView_SortItems($hExclusions, 0)
	#EndRegion

	GUICtrlCreateTabItem("")
	GUISwitch($hGUI)

	#Region ; Debug Console
	Local $bCHidden = False
	$hConsole = GUICtrlCreateEdit($_sLang_DebugStart & @CRLF & "---" & @CRLF, 0, 300, 640, 160, BitOR($ES_MULTILINE, $WS_VSCROLL, $ES_AUTOVSCROLL, $ES_READONLY))
		GUICtrlSetColor(-1, 0xFFFFFF)
		GUICtrlSetBkColor(-1, 0x000000)

	GUICtrlSetState($hConsole, $GUI_HIDE)
	$bCHidden = True
	#EndRegion

	WinMove($hGUI, "", Default, Default, 285, 345, 1)
	GUISetState(@SW_SHOW, $hGUI)

	#Region ; Sleep Timer GUI
	$hTimerGUI = GUICreate($_sLang_SleepSet, 240, 120, -1, -1, $WS_POPUP + $WS_CAPTION, $WS_EX_TOOLWINDOW + $WS_EX_TOPMOST)
	GUISetFont($_sLang_GUIFontSize, $_sLang_GUIFontWeight, 0, $_sLang_GUIFontName)

	GUICtrlCreateLabel($_sLang_SleepText, 10, 5, 220, 45)
	GUICtrlCreateLabel($_sLang_NewSleep & ":", 10, 60, 110, 20)

	$hSleepTime = GUICtrlCreateInput($iSleep, 120, 55, 40, 20, $ES_RIGHT + $ES_NUMBER)
	GUICtrlSetLimit(-1, 3, 1)
	GUICtrlCreateLabel("ms", 165, 60, 20, 15)

	$hSleepOK = GUICtrlCreateButton("OK", 170, 90, 60, 20)
	#EndRegion

	#cs
	#Region ; Settings UI
	$hSettingsGUI = GUICreate("Settings", 360, 120, -1, -1, $WS_VISIBLE + $WS_POPUP + $WS_CAPTION, $WS_EX_TOOLWINDOW + $WS_EX_TOPMOST)


	$hSettingsOK = GUICtrlCreateButton("OK", 290, 90, 60, 20)
	#EndRegion
	#ce


	While 1

		; Optimize first, always
		If Not $iProcesses = 0 Then
			If $bInterrupt = True Then
				$bInterrupt = False
				$iProcesses = 1
				_ConsoleWrite($_sLang_Interrupt, $hConsole)
				ContinueLoop
			ElseIf $iProcesses = 1 Then
				Opt("GUIOnEventMode", 0)
				_ConsoleWrite($_sLang_RestoringState & @CRLF, $hConsole)
				_Restore($aExclusions, $iThreads, $hConsole) ; Do Clean Up
				_ConsoleWrite($_sLang_Done & @CRLF, $hConsole)
				_ConsoleWrite("---" & @CRLF, $hConsole)
				GUICtrlSetData($hReset, $_sLang_Restore)
				GUICtrlSetData($hOptimize, $_sLang_Optimize)
				GUICtrlSetState($hMenu1, $GUI_ENABLE)
				GUICtrlSetState($hMenu2, $GUI_ENABLE)
				GUICtrlSetState($hMenu3, $GUI_ENABLE)
				For $iLoop = $hTask - 1 to $hBPriority + 1 Step 1
					If $iLoop = $hChildren Then ContinueLoop
					If $iLoop = $hBroChild Then ContinueLoop
					GUICtrlSetState($iLoop, $GUI_ENABLE)
				Next
				GUICtrlSetState($hReset   , $GUI_ENABLE)
				GUICtrlSetState($hOptimize, $GUI_ENABLE)
				$iProcesses = 0
				$aActive[0] = False
				$aActive[1] = ""
				$bReset = True
			Else
				Select
;					Case Not $aActive[1] = _ProcessGetName(WinGetProcess("[ACTIVE]"))
;						ContinueCase
					Case UBound(ProcessList()) <> $iProcesses
						If $aActive[0] Then
							$aProcesses[0] = GUICtrlRead($hTask)
							$aProcesses[0] = StringSplit($aProcesses[0], "|", $STR_NOCOUNT)
							$aUnload = $aProcesses[0] ; Unload $aProcesses[0]
							For $iLoop = 0 To UBound($aUnload) - 1 Step 1
								Switch $aUnload[$iLoop]
									Case "ACTIVE"
										$aUnload[$iLoop] = _ProcessGetName(WinGetProcess("[ACTIVE]"))
										$aActive[1] = $aUnload[$iLoop]
								EndSwitch
							Next
							$aProcesses[0] = $aUnload ; Reload $aProcesses[0]
						EndIf
						$iProcesses = _Optimize($iProcesses,$aProcesses[0],$iProcessCores,$iSleep,$sPriority,$hConsole)
						Switch $iProcesses
							Case 1
								Switch @error
									Case 0
										Switch @extended
											Case 1
												_ConsoleWrite(_ArrayToString($aProcesses[0], " & ") & " " & $_sLang_RestoringState & @CRLF, $hConsole)
										EndSwitch
									Case 1
										Switch @extended
											Case 1
												_ConsoleWrite("!> " & _ArrayToString($aProcesses[0], " & ") & " " & $_sLang_NotRunning & @CRLF, $hConsole)
											Case 2
												_ConsoleWrite("!> " & $_sLang_InvalidProcessCores & @CRLF, $hConsole)
											Case 3
												_ConsoleWrite("!> " & $_sLang_TooManyCores & @CRLF, $hConsole)
											Case 4
												_ConsoleWrite("!> " & $sPriority & " - " & $_sLang_InvalidPriority & @CRLF, $hConsole)
										EndSwitch
								EndSwitch
							Case Else
								Switch @extended
									Case 0
										_ConsoleWrite(_ArrayToString($aProcesses[0], " & ") & " " & $_sLang_Optimizing & @CRLF, $hConsole)
									Case 1
										_ConsoleWrite($_sLang_ReOptimizing & @CRLF, $hConsole)
									Case 2
										_ConsoleWrite("!> " & $_sLang_MaxPerformance & @CRLF, $hConsole)
										_ConsoleWrite(_ArrayToString($aProcesses[0], " & ") & " " & $_sLang_Optimizing & @CRLF, $hConsole)
								EndSwitch
						EndSwitch
						Switch _OptimizeOthers($aProcesses, $iOtherProcessCores, $iSleep, $hConsole)
							Case 1
								$iProcesses = 1
								Switch @error
									Case 1
										_ConsoleWrite("!> " & $_sLang_InvalidProcessCores & @CRLF, $hConsole)
									Case 2
										_ConsoleWrite("!> " & $_sLang_TooManyCores & @CRLF, $hConsole)
								EndSwitch
						EndSwitch
						Switch _OptimizeBroadcaster($aProcesses, $iBroadcasterCores, $iSleep, $sBPriority, $hConsole)
							Case 0
								Switch @extended
									Case 1
										_ConsoleWrite("!> " & $_sLang_MaxCores & @CRLF, $hConsole)
								EndSwitch
							Case 1
								$iProcesses = 1
								Switch @error
									Case 1
										_ConsoleWrite("!> " & $_sLang_TooManyTotalCores & @CRLF, $hConsole)
								EndSwitch
						EndSwitch
				EndSelect
			EndIf
		EndIf

		If Opt("GUIOnEventMode") Then
			Sleep($iSleep)
		Else
			$hMsg = GUIGetMsg()
			$hTMsg = TrayGetMsg()

			Select

				Case $hMsg = $GUI_EVENT_CLOSE or $hMsg = $hQuit
					_GUICtrlListView_UnRegisterSortCallBack($hGames)
					_GUICtrlListView_UnRegisterSortCallBack($hProcesses)
					_GUICtrlListView_UnRegisterSortCallBack($hExclusions)
					GUIDelete($hQuickTabs)
					GUIDelete($hTimerGUI)
					GUIDelete($hGUI)
					Exit

				Case $hMsg = $hClear
					GUICtrlSetData($hConsole, "")

				Case $hMsg = $GUI_EVENT_MINIMIZE
					Opt("TrayIconHide", 0)
					TraySetToolTip("NotCPUCores")
					GUISetState(@SW_HIDE, $hGUI)

				Case $hTMsg = $TRAY_EVENT_PRIMARYUP
					Opt("TrayIconHide", 1)
					GUISetState(@SW_SHOW, $hGUI)

				Case $hMsg = $hLoadLanguage ; LAZINESS... but saves a couple hundred lines of code
					$hFile = FileOpenDialog($_sLang_LoadProfile, @WorkingDir, "Language File (*.ini)", $FD_FILEMUSTEXIST, StringRight(@OSLang,2) & ".ini", $hGUI)
					If Not @error Then ContinueCase

				Case $hMsg = $hResetLanguage
					_LoadLanguage($hFile)
					_GUICtrlListView_UnRegisterSortCallBack($hGames)
					_GUICtrlListView_UnRegisterSortCallBack($hProcesses)
					_GUICtrlListView_UnRegisterSortCallBack($hExclusions)
					GUIDelete($hQuickTabs)
					GUIDelete($hTimerGUI)
					GUIDelete($hGUI)
					$hFile = ""
					Main()

				Case $hMsg = $hDToggle
					If $bCHidden Or $bPHidden Then
						$aPos = WinGetPos($hGUI)
						WinMove($hGUI, "", $aPos[0], $aPos[1], 640, 480)
						$aPos = WinGetPos($hQuickTabs)
						WinMove($hQuickTabs, "", $aPos[0], $aPos[1], 355, 300)
						GUICtrlSetState($hConsole, $GUI_SHOW)
						GUISetState(@SW_SHOW, $hQuickTabs)
	;					GUICtrlSetPos($hGames, 0, 20, 355, 280)
						GUICtrlSetPos($hConsole, 0, 300, 635, 135)
	;					GUICtrlSetPos($hProcesses, 0, 20, 355, 280)
						$bCHidden = False
						$bPHidden = False
					Else
						GUICtrlSetState($hConsole, $GUI_HIDE)
						GUISetState(@SW_HIDE, $hQuickTabs)
						$aPos = WinGetPos($hGUI)
						WinMove($hGUI, "", $aPos[0], $aPos[1], 285, 345)
						$bCHidden = True
						$bPHidden = True
					EndIf

				Case $hMsg = $hSetTimer
					GUISetState(@SW_SHOW, $hTimerGUI)

				Case $hMsg = $hSleepOK
					$iSleep = GUICtrlRead($hSleepTime)
					GUICtrlSetData($hGetTimer, $_sLang_SleepCurrent & ": " & $iSleep & "ms")
					GUISetState(@SW_HIDE, $hTimerGUI)

				Case $hMsg = $hSetLibrary
					$hFile = FileOpenDialog($_sLang_LoadProfile, @WorkingDir, "SteamLibrary (*.vdf)", $FD_FILEMUSTEXIST, "libraryfolders.vdf", $hGUI)
					If @error Then
						;;;
					Else
						$hLibrary = $hFile
						_GetSteamGames($hGames, $hLibrary)
						_GUICtrlListView_SortItems($hGames, GUICtrlGetState($hGames))
					EndIf

				Case $hMsg = $hRemLibrary
					$hLibrary = ""
					_GetSteamGames($hGames, $hLibrary)
					_GUICtrlListView_SortItems($hGames, GUICtrlGetState($hGames))

	;			Case $hMsg = $hSettingsOK
	;				GUISetState(@SW_HIDE, $hSettingsGUI)

				Case $hMsg = $hSave
					$hFile = FileSaveDialog($_sLang_SaveProfile, @WorkingDir, "NotCPUCores Profile (*.ncc)", $FD_PROMPTOVERWRITE, "", $hGUI)
					If @error Then
						;;;
					Else
						IniWrite($hFile, "Meta"     , "Version"    ,                                       "1")
						IniWrite($hFile, "General"  , "Process"    ,                GUICtrlRead($hTask       ))
						IniWrite($hFile, "General"  , "SplitAs"    , _GUICtrlComboBox_GetCurSel($hAssignMode ))
						IniWrite($hFile, "General"  , "Threads"    ,                GUICtrlRead($hCores      ))
						IniWrite($hFile, "General"  , "Children"   ,                GUICtrlRead($hChildren   ))
						IniWrite($hFile, "General"  , "Priority"   , _GUICtrlComboBox_GetCurSel($hPPriority  ))
						IniWrite($hFile, "Streaming", "SplitAs"    , _GUICtrlComboBox_GetCurSel($hSplitMode  ))
						IniWrite($hFile, "Streaming", "Threads"    ,                GUICtrlRead($hBCores     ))
						IniWrite($hFile, "Streaming", "Software"   ,                GUICtrlRead($hBroadcaster))
						IniWrite($hFile, "Streaming", "Children"   ,                GUICtrlRead($hBroChild   ))
						IniWrite($hFile, "Streaming", "Priority"   , _GUICtrlComboBox_GetCurSel($hBPriority  ))
						IniWrite($hFile, "Streaming", "Assignment" , _GUICtrlComboBox_GetCurSel($hOAssign    ))
					EndIf

				Case $hMsg = $hProcesses
					_GetProcessList($hProcesses)
					_GUICtrlListView_SortItems($hProcesses, GUICtrlGetState($hProcesses))

				Case $hMsg = $hGames
					_GetSteamGames($hGames, $hLibrary)
					_GUICtrlListView_SortItems($hGames, GUICtrlGetState($hGames))

				Case $hMsg = $hExclusions
					$aExclusions = _GetExclusionsList($hExclusions)
					_GUICtrlListView_SortItems($hExclusions, GUICtrlGetState($hExclusions))

				Case $hMsg = $hRefresh
					Switch GUICtrlRead($hTabs)
						Case 0
							_GetProcessList($hProcesses)
							_GUICtrlListView_SortItems($hProcesses, 0)
						Case 1
							_GetSteamGames($hGames, $hLibrary)
							_GUICtrlListView_SortItems($hGames, 1)
						Case 2
							$aExclusions = _GetExclusionsList($hExclusions)
					EndSwitch

				Case $hMsg = $hSearch
					GUICtrlSetState($hDToggle, $GUI_DISABLE)
					If $bPHidden Then
						GUICtrlSetState($hGames, $GUI_SHOW)
						GUICtrlSetState($hProcesses, $GUI_SHOW)
						$aPos = WinGetPos($hGUI)
						WinMove($hGUI, "", $aPos[0], $aPos[1], 640)
						$aPos = WinGetPos($hQuickTabs)
						WinMove($hQuickTabs, "", $aPos[0], $aPos[1], 355, 300)
						GUISetState(@SW_SHOW, $hQuickTabs)
						GUICtrlSetPos($hGames, 0, 20, 355, 280)
						GUICtrlSetPos($hProcesses, 0, 20, 355, 280)
						$bPHidden = False
					Else
						Switch GUICtrlRead($hTabs)
							Case 0
								$aTask = StringSplit(GUICtrlRead(GUICtrlRead($hProcesses)), "|", $STR_NOCOUNT)
							Case 1
								$aTask = StringSplit(GUICtrlRead(GUICtrlRead($hGames)), "|", $STR_NOCOUNT)
							Case 2
								$aTask = StringSplit(GUICtrlRead(GUICtrlRead($hExclusions)), "|", $STR_NOCOUNT)
						EndSwitch
						If $aTask[0] = "0" Then
							;;;
						Else
							GUICtrlSetData($hTask, $aTask[0])
						EndIf
						$aTask = ""
					EndIf
					GUICtrlSetState($hDToggle, $GUI_ENABLE)

				Case $bInit = True
					ContinueCase

				Case $hMsg = $hLoad
					If $bInit Then
						$bInit = False
						$hFile = "Autoload.ncc"
						If FileExists(@WorkingDir & "\Settings.ini") Then
							$hLibrary = IniRead(@WorkingDir & "\Settings.ini", "Steam"  , "Library Path"   , "Auto")
							$hFile = IniRead(@WorkingDir & "\Settings.ini", "General", "Default Profile", "Autoload.ncc")
							If Not FileExists($hFile) Then $hFile = ""
						EndIf
					Else
						$hFile = FileOpenDialog($_sLang_LoadProfile, @WorkingDir, "NotCPUCores Profile (*.ncc)", $FD_FILEMUSTEXIST, "profile.ncc", $hGUI)
						If @error Then ContinueCase
					EndIf
					If Not FileExists($hFile) Then
						ContinueCase
					Else
						_UpdateProfile($hFile)
						GUICtrlSetData(            $hTask       , String(_IniRead($hFile, "General"  , "Process"   ,                                      "",             "")))
						GUICtrlSetState(           $hChildren   , Number(_IniRead($hFile, "General"  , "Children"  ,                                      "", $GUI_UNCHECKED)))
						_GUICtrlComboBox_SetCurSel($hAssignMode , Number(_IniRead($hFile, "General"  , "SplitAs"   ,                   "0|1|2|3|4|5|6|7|8|9",            "9")))
						GUICtrlSetData(            $hCores      , String(_IniRead($hFile, "General"  , "Threads"   ,                                      "",            "1")))
						_GUICtrlComboBox_SetCurSel($hPPriority  , Number(_IniRead($hFile, "General"  , "Priority"  ,                           "0|1|2|3|4|5",            "4")))
						_GUICtrlComboBox_SetCurSel($hSplitMode  , Number(_IniRead($hFile, "Streaming", "SplitAs"   ,                   "0|1|2|3|4|5|6|7|8|9",            "9")))
						GUICtrlSetData(            $hBCores     , String(_IniRead($hFile, "Streaming", "Threads"   ,                                      "",            "2")))
						GUICtrlSetData(            $hBroadcaster, String(_IniRead($hFile, "Streaming", "Software"  , _GUICtrlComboBox_GetList($hBroadcaster),            "-")))
						GUICtrlSetState(           $hBroChild   , Number(_IniRead($hFile, "Streaming", "Children"  ,                                      "", $GUI_UNCHECKED)))
						_GUICtrlComboBox_SetCurSel($hBPriority  , Number(_IniRead($hFile, "Streaming", "Priority"  ,                           "0|1|2|3|4|5",            "4")))
						_GUICtrlComboBox_SetCurSel($hOAssign    , Number(_IniRead($hFile, "Streaming", "Assignment",                                 "0|1|2",            "2")))
					EndIf
					ContinueCase

				Case $bReset = True
					$bReset = False
					ContinueCase

				Case $hMsg = $hBCores
					$iBroadcasterCores = 0
					If Not StringRegExp(GUICtrlRead($hBCores), "^(?:[1-9]\d*-?(?!\d+-)(?:[1-9]\d*)?(?!,$),?)+$") Then ;\A[0-9]+?(,[0-9]+)*\Z
						GUICtrlSetColor($hBCores, 0xFF0000)
						GUICtrlSetState($hOptimize, $GUI_DISABLE)
					Else
						GUICtrlSetColor($hBCores, 0x000000)
						If StringRegExp(GUICtrlRead($hCores), "^(?:[1-9]\d*-?(?!\d+-)(?:[1-9]\d*)?(?!,$),?)+$") Then GUICtrlSetState($hOptimize, $GUI_ENABLE)
						If StringInStr(GUICtrlRead($hBCores), ",") Or StringInStr(GUICtrlRead($hBCores), "-") Then ; Convert Multiple Cores if Declared to Magic Number
							$aBCores = StringSplit(GUICtrlRead($hBCores), ",", $STR_NOCOUNT)
							For $iLoop1 = 0 To UBound($aBCores) - 1 Step 1
								If StringInStr($aBCores[$iLoop1], "-") Then
									$aRange = StringSplit($aBCores[$iLoop1], "-", $STR_NOCOUNT)
									If Number($aRange[0]) < Number($aRange[1]) Then
										For $iLoop2 = $aRange[0] To $aRange[1] Step 1
											$iBroadcasterCores += 2^($iLoop2-1)
										Next
									Else
										For $iLoop2 = $aRange[1] To $aRange[0] Step 1
											$iBroadcasterCores += 2^($iLoop2-1)
										Next
									EndIf
								Else
									$iBroadcasterCores += 2^($aBCores[$iLoop1]-1)
								EndIf
							Next
						Else
							$iBroadcasterCores = 2^(GUICtrlRead($hBCores)-1)
						EndIf
					EndIf
					ContinueCase

				Case $hMsg = $hBroadcaster
					For $iLoop = $hSplitMode To $hOAssign Step 2
						If $iLoop = $hBroChild Then ContinueLoop
						GUICtrlSetState($iLoop, $GUI_ENABLE)
					Next
					Switch GUICtrlRead($hBroadcaster)
						Case "-"
							ReDim $aProcesses[3]
							$aProcesses[0] = GUICtrlRead($hTask)
							$aProcesses[1] = ""
							$aProcesses[2] = $aExclusions
							For $iLoop = $hSplitMode To $hOAssign Step 2
								GUICtrlSetState($iLoop, $GUI_DISABLE)
							Next
							_GUICtrlComboBox_SetCurSel($hOAssign, 2)
						Case "LightStream"
							ReDim $aProcesses[7]
							$aProcesses[0] = GUICtrlRead($hTask)
							$aProcesses[1] = "iexplore.exe"
							$aProcesses[2] = "msedge.exe"
							$aProcesses[3] = "chrome.exe"
							$aProcesses[4] = "firefox.exe"
							$aProcesses[5] = "opera.exe"
							$aProcesses[6] = $aExclusions
						Case "OBS"
							ReDim $aProcesses[6]
							$aProcesses[0] = GUICtrlRead($hTask)
							$aProcesses[1] = "obs.exe"
							$aProcesses[2] = "obs32.exe"
							$aProcesses[3] = "obs64.exe"
							$aProcesses[4] = "obs-ffmpeg-mux.exe"
							$aProcesses[5] = $aExclusions
						Case "ReLive"
							ReDim $aProcesses[13]
							$aProcesses[0] = GUICtrlRead($hTask)
							$aProcesses[1] = "RadeonSoftware.exe"
							$aProcesses[2] = "FacebookClient.exe"
							$aProcesses[3] = "GfycatWrapper.exe"
							$aProcesses[4] = "QuanminTVWrapper.exe"
							$aProcesses[5] = "RestreamAPIWrapper.exe"
							$aProcesses[6] = "SinaWeiboWrapper.exe"
							$aProcesses[7] = "StreamableAPIWrapper.exe"
							$aProcesses[8] = "TwitchClient.exe"
							$aProcesses[9] = "TwitterWrapperClient.exe"
							$aProcesses[10] = "YoukuWrapper.exe"
							$aProcesses[11] = "YoutubeAPIWrapper.exe"
							$aProcesses[12] = $aExclusions
						Case "StreamLabs"
							ReDim $aProcesses[6]
							$aProcesses[0] = GUICtrlRead($hTask)
							$aProcesses[1] = "Streamlabs OBS.exe"
							$aProcesses[2] = "obs32.exe"
							$aProcesses[3] = "obs64.exe"
							$aProcesses[4] = "obs-ffmpeg-mux.exe"
							$aProcesses[5] = $aExclusions
						Case "ShadowPlay"
							ReDim $aProcesses[7]
							$aProcesses[0] = GUICtrlRead($hTask)
							$aProcesses[1] = "nvcontainer.exe"
							$aProcesses[2] = "nvscaphelper.exe"
							$aProcesses[3] = "nvsphelper.exe"
							$aProcesses[4] = "nvsphelper64.exe"
							$aProcesses[5] = "GFExperience.exe"
							$aProcesses[6] = $aExclusions
						Case "vMix"
							ReDim $aProcesses[8]
							$aProcesses[0] = GUICtrlRead($hTask)
							$aProcesses[1] = "vMixService.exe"
							$aProcesses[2] = "vMix.exe"
							$aProcesses[3] = "vMix64.exe"
							$aProcesses[4] = "vMixDesktopCapture.exe"
							$aProcesses[5] = "vMixNDIHelper.exe"
							$aProcesses[6] = "ffmpeg.exe"
							$aProcesses[7] = $aExclusions
						Case "Wirecast"
							ReDim $aProcesses[5]
							$aProcesses[0] = GUICtrlRead($hTask)
							$aProcesses[1] = "CEFChildProcess.exe"
							$aProcesses[2] = "Wirecast.exe"
							$aProcesses[3] = "wirecastd.exe"
							$aProcesses[4] = $aExclusions
						Case "XSplit"
							ReDim $aProcesses[6]
							$aProcesses[0] = GUICtrlRead($hTask)
							$aProcesses[1] = "XGS32.exe"
							$aProcesses[2] = "XGS64.exe"
							$aProcesses[3] = "XSplit.Core.exe"
							$aProcesses[4] = "XSplit.xbcbp.exe"
							$aProcesses[5] = $aExclusions
						Case Else
							ReDim $aProcesses[3]
							$aProcesses[0] = GUICtrlRead($hTask)
							$aProcesses[1] = ""
							$aProcesses[2] = $aExclusions
							For $iLoop = $hSplitMode To $hOAssign Step 2
								GUICtrlSetState($iLoop, $GUI_DISABLE)
							Next
							_GUICtrlComboBox_SetCurSel($hOAssign, 2)
							_ConsoleWrite("!> " & $_sLang_InvalidBroadcast & @CRLF, $hConsole)

					EndSwitch
					ContinueCase

				Case $hMsg = $hBPriority
					$sBPriority = $PROCESS_HIGH
					$aPriorities = StringSplit(_GUICtrlComboBox_GetList($hBPriority), Opt("GUIDataSeparatorChar"), $STR_NOCOUNT)
					Switch GUICtrlRead($hBPriority)

						Case $aPriorities[0] ; Low
							$sBPriority = $PROCESS_LOW

						Case $aPriorities[1] ; Below Normal
							$sBPriority = $PROCESS_BELOWNORMAL

						Case $aPriorities[2] ; Normal
							$sBPriority = $PROCESS_NORMAL

						Case $aPriorities[3] ; Above Normal
							$sBPriority = $PROCESS_ABOVENORMAL

						Case $aPriorities[4] ; High
							$sBPriority = $PROCESS_HIGH

						Case $aPriorities[5] ; Realtime
							$sBPriority = $PROCESS_REALTIME

						Case Else
							$sBPriority = $PROCESS_HIGH
							_ConsoleWrite("!> " & $_sLang_InvalidPriority & @CRLF, $hConsole)

					EndSwitch
					ContinueCase

				Case $hMsg = $hPPriority
					$sPriority = $PROCESS_HIGH
					$aPriorities = StringSplit(_GUICtrlComboBox_GetList($hPPriority), Opt("GUIDataSeparatorChar"), $STR_NOCOUNT)
					Switch GUICtrlRead($hPPriority)

						Case $aPriorities[0] ; Low
							$sPriority = $PROCESS_LOW

						Case $aPriorities[1] ; Below Normal
							$sPriority = $PROCESS_BELOWNORMAL

						Case $aPriorities[2] ; Normal
							$sPriority = $PROCESS_NORMAL

						Case $aPriorities[3] ; Above Normal
							$sPriority = $PROCESS_ABOVENORMAL

						Case $aPriorities[4] ; High
							$sPriority = $PROCESS_HIGH

						Case $aPriorities[5] ; Realtime
							$sPriority = $PROCESS_REALTIME

						Case Else
							$sPriority = $PROCESS_HIGH
							_ConsoleWrite("!> " & $_sLang_InvalidPriority & @CRLF, $hConsole)

					EndSwitch
					ContinueCase

				Case $hMsg = $hSplitMode
					$iBroadcasterCores = 0
					If GUICtrlRead($hBroadcaster) = "-" Then ContinueCase
					$aSplitMode = StringSplit(_GUICtrlComboBox_GetList($hSplitMode), Opt("GUIDataSeparatorChar"), $STR_NOCOUNT)
					GUICtrlSetState($hBCores, $GUI_DISABLE)
					Switch GUICtrlRead($hSplitMode)

						Case $aSplitMode[0] ; All Cores
							$iBroadcasterCores = 0
							$aProcesses[0] = GUICtrlRead($hTask)

						Case $aSplitMode[1] ; Last Core
							$iBroadcasterCores = 2^($iThreads - 1)

						Case $aSplitMode[2] ; Last 2 Cores
							For $iLoop = ($iThreads - 2) To $iThreads - 1
								$iBroadcasterCores += 2^($iLoop)
							Next

						Case $aSplitMode[3] ; Last 4 Cores
							For $iLoop = ($iThreads-4) To $iThreads - 1
								$iBroadcasterCores += 2^($iLoop)
							Next

						Case $aSplitMode[4] ; Last Half
							For $iLoop = Ceiling(($iThreads - ($iThreads/2))) To $iThreads - 1
								$iBroadcasterCores += 2^($iLoop)
							Next

						Case $aSplitMode[5] ; Physical Cores
							For $iLoop = 0 To $iThreads - 1 Step 2
								$iBroadcasterCores += 2^($iLoop)
							Next

						Case $aSplitMode[6] ; Non-Physical Cores
							For $iLoop = 1 To $iThreads - 1 Step 2
								$iBroadcasterCores += 2^($iLoop)
							Next

						Case $aSplitMode[7] ; Pairs
							For $iLoop = 2 To $iThreads - 1 Step 4
								$iBroadcasterCores += 2^($iLoop)
								$iBroadcasterCores += 2^($iLoop + 1)
							Next

						Case $aSplitMode[8] ; CPU Optimized
							Switch $sSocket
								Case "AM4"
									For $iLoop = ($iThreads - ($iThreads/2)) To $iThreads - 1 Step 1
										$iBroadcasterCores += 2^($iLoop)
									Next
								Case "TR4", "sTRX4"
									For $iLoop = ($iThreads - ($iThreads/4)) To $iThreads - 1 Step 1
										$iBroadcasterCores += 2^($iLoop)
									Next
								Case Else
									GUICtrlSetState($hOAssign, $GUI_DISABLE)
									_ConsoleWrite("!> " & $_sLang_InvalidBroadcastCores & @CRLF, $hConsole)
							EndSwitch

						Case $aSplitMode[9] ; Custom
							GUICtrlSetState($hBCores, $GUI_ENABLE)
							If Not StringRegExp(GUICtrlRead($hBCores), "^(?:[1-9]\d*-?(?!\d+-)(?:[1-9]\d*)?(?!,$),?)+$") Then ;\A[0-9]+?(,[0-9]+)*\Z
								GUICtrlSetColor($hBCores, 0xFF0000)
								GUICtrlSetState($hOptimize, $GUI_DISABLE)
							Else
								GUICtrlSetColor($hBCores, 0x000000)
								If StringRegExp(GUICtrlRead($hCores), "^(?:[1-9]\d*-?(?!\d+-)(?:[1-9]\d*)?(?!,$),?)+$") Then GUICtrlSetState($hOptimize, $GUI_ENABLE)
								If StringInStr(GUICtrlRead($hBCores), ",") Or StringInStr(GUICtrlRead($hBCores), "-") Then ; Convert Multiple Cores if Declared to Magic Number
									$aBCores = StringSplit(GUICtrlRead($hBCores), ",", $STR_NOCOUNT)
									For $iLoop1 = 0 To UBound($aBCores) - 1 Step 1
										If StringInStr($aBCores[$iLoop1], "-") Then
											$aRange = StringSplit($aBCores[$iLoop1], "-", $STR_NOCOUNT)
											If Number($aRange[0]) < Number($aRange[1]) Then
												For $iLoop2 = $aRange[0] To $aRange[1] Step 1
													$iBroadcasterCores += 2^($iLoop2-1)
												Next
											Else
												For $iLoop2 = $aRange[1] To $aRange[0] Step 1
													$iBroadcasterCores += 2^($iLoop2-1)
												Next
											EndIf
										Else
											$iBroadcasterCores += 2^($aBCores[$iLoop1]-1)
										EndIf
									Next
								Else
									$iBroadcasterCores = 2^(GUICtrlRead($hBCores)-1)
								EndIf
							EndIf

						Case Else
							GUICtrlSetState($hOAssign, $GUI_DISABLE)
							_ConsoleWrite("!> " & $_sLang_InvalidBroadcastCores & @CRLF, $hConsole)

					EndSwitch
					ContinueCase

				Case $hMsg = $hCores
					$iProcessCores = 0
					If Not StringRegExp(GUICtrlRead($hCores), "^(?:[1-9]\d*-?(?!\d+-)(?:[1-9]\d*)?(?!,$),?)+$") Then ;\A[0-9]+?(,[0-9]+)*\Z
						GUICtrlSetColor($hCores, 0xFF0000)
						GUICtrlSetState($hOptimize, $GUI_DISABLE)
					Else
						GUICtrlSetColor($hCores, 0x000000)
						If StringRegExp(GUICtrlRead($hBCores), "^(?:[1-9]\d*-?(?!\d+-)(?:[1-9]\d*)?(?!,$),?)+$") Then GUICtrlSetState($hOptimize, $GUI_ENABLE)
						If StringInStr(GUICtrlRead($hCores), ",") Or StringInStr(GUICtrlRead($hCores), "-") Then ; Convert Multiple Cores if Declared to Magic Number
							$aCores = StringSplit(GUICtrlRead($hCores), ",", $STR_NOCOUNT)
							For $iLoop1 = 0 To UBound($aCores) - 1 Step 1
								If StringInStr($aCores[$iLoop1], "-") Then
									$aRange = StringSplit($aCores[$iLoop1], "-", $STR_NOCOUNT)
									If Number($aRange[0]) < Number($aRange[1]) Then
										For $iLoop2 = $aRange[0] To $aRange[1] Step 1
											$iProcessCores += 2^($iLoop2-1)
										Next
									Else
										For $iLoop2 = $aRange[1] To $aRange[0] Step 1
											$iProcessCores += 2^($iLoop2-1)
										Next
									EndIf
								Else
									$iProcessCores += 2^($aCores[$iLoop1]-1)
								EndIf
							Next
						Else
							$iProcessCores = 2^(GUICtrlRead($hCores)-1)
						EndIf
					EndIf
					ContinueCase

				Case $hMsg = $hAssignMode
					$iProcessCores = 0
					$aAssignMode = StringSplit(_GUICtrlComboBox_GetList($hAssignMode), Opt("GUIDataSeparatorChar"), $STR_NOCOUNT)
					GUICtrlSetState($hCores, $GUI_DISABLE)
					Switch GUICtrlRead($hAssignMode)

						Case $aAssignMode[0] ; All Cores
							$iProcessCores = $iAllCores

						Case $aAssignMode[1] ; First Core
							$iProcessCores = 1

						Case $aAssignMode[2] ; First 2 Cores
							$iProcessCores = 3

						Case $aAssignMode[3] ; First 4 Cores
							$iProcessCores = 15

						Case $aAssignMode[4] ; First Half
							For $iLoop = 0 To (Floor(($iThreads - ($iThreads/2))) - 1)
								$iProcessCores += 2^($iLoop)
							Next

						Case $aAssignMode[5] ; Physical Cores
							For $iLoop = 0 To $iThreads - 1 Step 2
								$iProcessCores += 2^($iLoop)
							Next

						Case $aAssignMode[6] ; Non-Physical Cores
							For $iLoop = 1 To $iThreads - 1 Step 2
								$iProcessCores += 2^($iLoop)
							Next

						Case $aAssignMode[7] ; Every Other Pair
							For $iLoop = 0 To $iThreads - 1 Step 4
								$iProcessCores += 2^($iLoop)
								$iProcessCores += 2^($iLoop + 1)
							Next

						Case $aAssignMode[8] ; First AMD CCX
							Switch $sSocket
								Case "AM4"
									For $iLoop = 0 To (($iThreads/2) - 1) Step 1
										$iProcessCores += 2^($iLoop)
									Next
								Case "TR4", "sTRX4"
									For $iLoop = 0 To (($iThreads/4) - 1) Step 1
										$iProcessCores += 2^($iLoop)
									Next
								Case Else
									_ConsoleWrite("!> " & $_sLang_InvalidProcessCores & @CRLF, $hConsole)
									GUICtrlSetState($hOptimize, $GUI_DISABLE)
									GUICtrlSetState($hCores, $GUI_DISABLE)
							EndSwitch

						Case $aAssignMode[9] ; Custom
							GUICtrlSetState($hCores, $GUI_ENABLE)
							If Not StringRegExp(GUICtrlRead($hCores), "^(?:[1-9]\d*-?(?!\d+-)(?:[1-9]\d*)?(?!,$),?)+$") Then ;\A[0-9]+?(,[0-9]+)*\Z
								GUICtrlSetColor($hCores, 0xFF0000)
								GUICtrlSetState($hOptimize, $GUI_DISABLE)
							Else
								GUICtrlSetColor($hCores, 0x000000)
								If StringRegExp(GUICtrlRead($hBCores), "^(?:[1-9]\d*-?(?!\d+-)(?:[1-9]\d*)?(?!,$),?)+$") Then GUICtrlSetState($hOptimize, $GUI_ENABLE)
								If StringInStr(GUICtrlRead($hCores), ",") Or StringInStr(GUICtrlRead($hCores), "-") Then ; Convert Multiple Cores if Declared to Magic Number
									$aCores = StringSplit(GUICtrlRead($hCores), ",", $STR_NOCOUNT)
									For $iLoop1 = 0 To UBound($aCores) - 1 Step 1
										If StringInStr($aCores[$iLoop1], "-") Then
											$aRange = StringSplit($aCores[$iLoop1], "-", $STR_NOCOUNT)
											If Number($aRange[0]) < Number($aRange[1]) Then
												For $iLoop2 = $aRange[0] To $aRange[1] Step 1
													$iProcessCores += 2^($iLoop2-1)
												Next
											Else
												For $iLoop2 = $aRange[1] To $aRange[0] Step 1
													$iProcessCores += 2^($iLoop2-1)
												Next
											EndIf
										Else
											$iProcessCores += 2^($aCores[$iLoop1]-1)
										EndIf
									Next
								Else
									$iProcessCores = 2^(GUICtrlRead($hCores)-1)
								EndIf
							EndIf

						Case Else
						_ConsoleWrite("!> " & $_sLang_InvalidProcessCores & @CRLF, $hConsole)
						GUICtrlSetState($hOptimize, $GUI_DISABLE)
						GUICtrlSetState($hCores, $GUI_DISABLE)

					EndSwitch
					ContinueCase

				Case $hMsg = $hOAssign
					$iOtherProcessCores = 0
					$aOAssign = StringSplit(_GUICtrlComboBox_GetList($hOAssign), Opt("GUIDataSeparatorChar"), $STR_NOCOUNT)
					Switch GUICtrlRead($hOAssign)

						Case $aOAssign[0] ; Broadcaster Cores
							$iOtherProcessCores = $iBroadcasterCores

						Case $aOAssign[1] ; Game Cores
							$iOtherProcessCores = $iProcessCores

						Case $aOAssign[2] ; Remaining Cores
							$iOtherProcessCores = $iAllCores - _BitOR64($iProcessCores, $iBroadcasterCores)

						Case Else
							$iOtherProcessCores = 1
							_ConsoleWrite("!> " & $_sLang_InvalidOtherCores & @CRLF, $hConsole)

					EndSwitch

				Case $hMsg = $hReset
					GUICtrlSetState($hMenu1, $GUI_DISABLE)
					GUICtrlSetState($hMenu2, $GUI_DISABLE)
					GUICtrlSetState($hMenu3, $GUI_DISABLE)
					For $Loop = $hTask - 1 to $hOAssign Step 1
						GUICtrlSetState($Loop, $GUI_DISABLE)
					Next
					GUICtrlSetState($hReset   , $GUI_DISABLE)
					GUICtrlSetState($hOptimize, $GUI_DISABLE)
					GUICtrlSetData($hReset, $_sLang_RestoreAlt)
					; Do not merge with $iProcesses = 0 or Exclusions list can't be reset
					_ConsoleWrite($_sLang_RestoringState & @CRLF, $hConsole)
					_Restore("", $iThreads, $hConsole) ; Do Clean Up
					_ConsoleWrite($_sLang_Done & @CRLF, $hConsole)
					_ConsoleWrite("---" & @CRLF, $hConsole)
					GUICtrlSetData($hReset, $_sLang_Restore)
					GUICtrlSetData($hOptimize, $_sLang_Optimize)
					GUICtrlSetState($hMenu1, $GUI_ENABLE)
					GUICtrlSetState($hMenu2, $GUI_ENABLE)
					GUICtrlSetState($hMenu3, $GUI_ENABLE)
					For $iLoop = $hTask - 1 to $hBPriority + 1 Step 1
						If $iLoop = $hChildren Then ContinueLoop
						If $iLoop = $hBroChild Then ContinueLoop
						GUICtrlSetState($iLoop, $GUI_ENABLE)
					Next
					GUICtrlSetState($hReset   , $GUI_ENABLE)
					GUICtrlSetState($hOptimize, $GUI_ENABLE)
					$iProcesses = 0
					$aActive[0] = False
					$aActive[1] = ""
					$aExclusions = _GetExclusionsList($hExclusions)
					$bReset = True

				Case $hMsg = $hOptimize
					Opt("GUIOnEventMode", 1)
					GUICtrlSetData($hConsole, "")
					GUICtrlSetState($hMenu1, $GUI_DISABLE)
					GUICtrlSetState($hMenu2, $GUI_DISABLE)
					GUICtrlSetState($hMenu3, $GUI_DISABLE)
					For $Loop = $hTask - 1 to $hOAssign Step 1
						GUICtrlSetState($Loop, $GUI_DISABLE)
					Next
					GUICtrlSetState($hReset   , $GUI_DISABLE)
					GUICtrlSetState($hOptimize, $GUI_DISABLE)
					GUICtrlSetData($hOptimize, $_sLang_OptimizeAlt)
					$aProcesses[0] = GUICtrlRead($hTask)
					$aProcesses[0] = StringSplit($aProcesses[0], "|", $STR_NOCOUNT)
					$aUnload = $aProcesses[0] ; Unload $aProcesses[0]
					For $iLoop = 0 To UBound($aUnload) - 1 Step 1
						Switch $aUnload[$iLoop]
							Case "ACTIVE"
								$aActive[0] = True
								$aUnload[$iLoop] = _ProcessGetName(WinGetProcess("[ACTIVE]"))
								$aActive[1] = $aUnload[$iLoop]
							Case 1 To 4294967295
								If Not ProcessExists("steam.exe") And Not ProcessExists("steamservice.exe") Then
									_ConsoleWrite("!> " & $_sLang_SteamNotRunning & @CRLF, $hConsole)
									$iProcesses = 1
									ContinueLoop
								ElseIf ShellExecute("steam://rungameid/" & $aUnload[$iLoop]) > 0 Then
									$aPre = ProcessList()
									Do
										$aPost = ProcessList()
										If $aPost[0][0] < $aPre[0][0] Then $aPre = $aPost
									Until $aPost[0][0] > $aPre[0][0]
									$iGame = $aPost[$aPost[0][0]][1]
									$aUnload[$iLoop] = _ProcessGetName($iGame)
								Else
									$aUnload[$iLoop] = $aProcesses
								EndIf
						EndSwitch
					Next
					$aProcesses[0] = $aUnload ; Reload $aProcesses[0]
					$iProcesses = _Optimize($iProcesses,$aProcesses[0],$iProcessCores,$iSleep,$sPriority,$hConsole)
					Switch $iProcesses
						Case 1
							Switch @error
								Case 0
									Switch @extended
										Case 1
											_ConsoleWrite(_ArrayToString($aProcesses[0], " & ") & " " & $_sLang_RestoringState & @CRLF, $hConsole)
									EndSwitch
								Case 1
									Switch @extended
										Case 1
											_ConsoleWrite("!> " & _ArrayToString($aProcesses[0], " & ") & " " & $_sLang_NotRunning & @CRLF, $hConsole)
										Case 2
											_ConsoleWrite("!> " & $_sLang_InvalidProcessCores & @CRLF, $hConsole)
										Case 3
											_ConsoleWrite("!> " & $_sLang_TooManyCores & @CRLF, $hConsole)
										Case 4
											_ConsoleWrite("!> " & $sPriority & " - " & $_sLang_InvalidPriority & @CRLF, $hConsole)
									EndSwitch
							EndSwitch
						Case Else
							Switch @extended
								Case 0
									_ConsoleWrite(_ArrayToString($aProcesses[0], " & ") & " " & $_sLang_Optimizing & @CRLF, $hConsole)
								Case 1
									_ConsoleWrite($_sLang_ReOptimizing & @CRLF, $hConsole)
								Case 2
									_ConsoleWrite("!> " & $_sLang_MaxPerformance & @CRLF, $hConsole)
									_ConsoleWrite(_ArrayToString($aProcesses[0], " & ") & " " & $_sLang_Optimizing & @CRLF, $hConsole)
							EndSwitch
					EndSwitch
					Switch _OptimizeOthers($aProcesses, $iOtherProcessCores, $iSleep, $hConsole)
						Case 1
							$iProcesses = 1
							Switch @error
								Case 1
									_ConsoleWrite("!> " & $_sLang_InvalidProcessCores & @CRLF, $hConsole)
								Case 2
									_ConsoleWrite("!> " & $_sLang_TooManyCores & @CRLF, $hConsole)
							EndSwitch
					EndSwitch
					Switch _OptimizeBroadcaster($aProcesses, $iBroadcasterCores, $iSleep, $sBPriority, $hConsole)
						Case 0
							Switch @extended
								Case 1
									_ConsoleWrite("!> " & $_sLang_MaxCores & @CRLF, $hConsole)
							EndSwitch
						Case 1
							$iProcesses = 1
							Switch @error
								Case 1
									_ConsoleWrite("!> " & $_sLang_TooManyTotalCores & @CRLF, $hConsole)
							EndSwitch
					EndSwitch


				Case $hMsg = $hHPET
					_ToggleHPET("", $hConsole)
					_ConsoleWrite($_sLang_HPETChange & @CRLF, $hConsole)

				Case $hMsg = $hGameM
					ShellExecute("ms-settings:gaming-gamemode")

				Case $hMsg = $hPower
					Run(@ComSpec & " /c " & 'control powercfg.cpl,,1', "", @SW_HIDE)

				Case $hMsg = $hDefrag
					Run(@ComSpec & " /c " & 'defrag C: /V && pause', "")

				Case $hMsg = $hCheck
					Run(@ComSpec & " /c " & 'chkdsk C: /V && pause', "")

				Case $hMsg = $hCleanup
					Run(@ComSpec & " /c " & 'cleanmgr', "")

				Case $hMsg = $hSSense
					ShellExecute("ms-settings:storagepolicies")

				Case $hMsg = $hEvents
					Run(@ComSpec & " /c " & 'perfmon /rel', "", @SW_HIDE)

				Case $hMsg = $hActions
					Run(@ComSpec & " /c " & 'control wscui.cpl', "", @SW_HIDE)

				Case $hMsg = $hHAGS
					ShellExecute("ms-settings:display-advancedgraphics")

				Case $hMsg = $hGithub
					ShellExecute("https://fcofix.org/NotCPUCores")

				Case $hMsg = $hDiscord
					ShellExecute("https://discord.gg/uBnBcBx")

				Case $hMsg = $hHowTo
					ShellExecute("https://fcofix.org/NotCPUCores/wiki/Manually-Copying-NotCPUCores")

				Case $hMsg = $hDonate
					ShellExecute("https://www.paypal.me/rhsky")

				Case $hMsg = $hUpdate
					Switch _GetLatestRelease($sVersion)
						Case -1
							_ConsoleWrite("!> " & $_sLang_TooNew & @CRLF, $hConsole)
						Case 0
							Switch @error
								Case 0
									_ConsoleWrite("!> " & $_sLang_NoUpdates & @CRLF, $hConsole)
								Case 1
									_ConsoleWrite("!> " & $_sLang_LoadFail & @CRLF, $hConsole)
								Case 2
									_ConsoleWrite("!> " & $_sLang_DataFail & @CRLF, $hConsole)
								Case 3
									Switch @extended
										Case 0
											_ConsoleWrite("!> " & $_sLang_TagsFail & @CRLF, $hConsole)
										Case 1
											_ConsoleWrite("!> " & $_sLang_TypeFail & @CRLF, $hConsole)
									EndSwitch
							EndSwitch
						Case 1
							_ConsoleWrite("!> " & $_sLang_NewVersion & @CRLF, $hConsole)
							ShellExecute("https://fcofix.org/NotCPUCores/releases")
					EndSwitch

				Case Else
					Sleep($iSleep / 10)

			EndSelect
		EndIf
	WEnd
EndFunc

OnInterrupt()

Func OnInterrupt()
	If Not $bInterrupt Then $bInterrupt = True
	Opt("GUIOnEventMode", 0)
EndFunc

Func PreFlightCheck()
	Select

		Case Not _Singleton("NotCPUCores", 1)
			MsgBox($MB_ICONINFORMATION+$MB_OK, $_sLang_AlreadyRunningTitle, $_sLang_AlreadyRunningMessage)
			Exit 1

		Case ProcessExists("CpuCores.exe")
			MsgBox($MB_ICONERROR+$MB_OK, $_sLang_IncompatibleTitle, "CPUCores " & $_sLang_IncompatibleMessage)
			Exit 1

		Case ProcessExists("ProcessLasso.exe")
			MsgBox($MB_YESNO+$MB_DEFBUTTON2, $_sLang_IncompatibleTitle, "ProcessLasso " & $_sLang_IncompatibleMessage)
			Exit 1

	EndSelect
EndFunc

Func _GetChildProcesses($i_pid) ; First level children processes only
    Local Const $TH32CS_SNAPPROCESS = 0x00000002

    Local $a_tool_help = DllCall("Kernel32.dll", "long", "CreateToolhelp32Snapshot", "int", $TH32CS_SNAPPROCESS, "int", 0)
    If IsArray($a_tool_help) = 0 Or $a_tool_help[0] = -1 Then Return SetError(1, 0, $i_pid)

    Local $tagPROCESSENTRY32 = _
        DllStructCreate _
            ( _
                "dword dwsize;" & _
                "dword cntUsage;" & _
                "dword th32ProcessID;" & _
                "uint th32DefaultHeapID;" & _
                "dword th32ModuleID;" & _
                "dword cntThreads;" & _
                "dword th32ParentProcessID;" & _
                "long pcPriClassBase;" & _
                "dword dwFlags;" & _
                "char szExeFile[260]" _
            )
    DllStructSetData($tagPROCESSENTRY32, 1, DllStructGetSize($tagPROCESSENTRY32))

    Local $p_PROCESSENTRY32 = DllStructGetPtr($tagPROCESSENTRY32)

    Local $a_pfirst = DllCall("Kernel32.dll", "int", "Process32First", "long", $a_tool_help[0], "ptr", $p_PROCESSENTRY32)
    If IsArray($a_pfirst) = 0 Then Return SetError(2, 0, $i_pid)

    Local $a_pnext, $a_children[11][2] = [[10]], $i_child_pid, $i_parent_pid, $i_add = 0
    $i_child_pid = DllStructGetData($tagPROCESSENTRY32, "th32ProcessID")
    If $i_child_pid <> $i_pid Then
        $i_parent_pid = DllStructGetData($tagPROCESSENTRY32, "th32ParentProcessID")
        If $i_parent_pid = $i_pid Then
            $i_add += 1
            $a_children[$i_add][0] = $i_child_pid
            $a_children[$i_add][1] = DllStructGetData($tagPROCESSENTRY32, "szExeFile")
        EndIf
    EndIf

    While 1
        $a_pnext = DLLCall("Kernel32.dll", "int", "Process32Next", "long", $a_tool_help[0], "ptr", $p_PROCESSENTRY32)
        If IsArray($a_pnext) And $a_pnext[0] = 0 Then ExitLoop
        $i_child_pid = DllStructGetData($tagPROCESSENTRY32, "th32ProcessID")
        If $i_child_pid <> $i_pid Then
            $i_parent_pid = DllStructGetData($tagPROCESSENTRY32, "th32ParentProcessID")
            If $i_parent_pid = $i_pid Then
                If $i_add = $a_children[0][0] Then
                    ReDim $a_children[$a_children[0][0] + 11][2]
                    $a_children[0][0] = $a_children[0][0] + 10
                EndIf
                $i_add += 1
                $a_children[$i_add][0] = $i_child_pid
                $a_children[$i_add][1] = DllStructGetData($tagPROCESSENTRY32, "szExeFile")
            EndIf
        EndIf
    WEnd

    If $i_add <> 0 Then
        ReDim $a_children[$i_add + 1][2]
        $a_children[0][0] = $i_add
    EndIf

    DllCall("Kernel32.dll", "int", "CloseHandle", "long", $a_tool_help[0])
    If $i_add Then Return $a_children
    Return SetError(3, 0, 0)
EndFunc

Func _GetError($sFunction, $iError, $iExtended)
EndFunc

Func _GetExclusionsList($hControl)

	Local $aAffinity
	Local $aProcesses
	Local $aExclusions[0]

	_GUICtrlListView_DeleteAllItems($hControl)
	Local $aProcesses = ProcessList()
	For $Loop = 5 To $aProcesses[0][0] ; Skip System
		$hCurProcess = _WinAPI_OpenProcess($PROCESS_QUERY_LIMITED_INFORMATION, False, $aProcesses[$Loop][1])
		$aAffinity = _WinAPI_GetProcessAffinityMask($hCurProcess)
		If @error Then ContinueLoop
		Select
			Case $aAffinity[1] = $aAffinity[2]
				;;;
			Case _ProcessGetPriority($aProcesses[$Loop][1]) <> 2
				ContinueCase
			Case Else
				ReDim $aExclusions[UBound($aExclusions) + 1]
				$aExclusions[UBound($aExclusions)-1] = $aProcesses[$Loop][0]
				GUICtrlCreateListViewItem($aProcesses[$Loop][0], $hControl)
		EndSelect
		_WinAPI_CloseHandle($hCurProcess)
	Next
	_ArrayDelete($aProcesses, 0)
	For $i = 0 To _GUICtrlListView_GetColumnCount($hControl) Step 1
		_GUICtrlListView_SetColumnWidth($hControl, $i, $LVSCW_AUTOSIZE_USEHEADER)
	Next

	Return $aExclusions

EndFunc

Func _GetProcessList($hControl)

	_GUICtrlListView_DeleteAllItems($hControl)
	Local $aWindows = WinList()
	Do
		$iDelete = _ArraySearch($aWindows, "Default IME")
		_ArrayDelete($aWindows, $iDelete)
	Until _ArraySearch($aWindows, "Default IME") = -1
	Do
		$iDelete = _ArraySearch($aWindows, "")
		_ArrayDelete($aWindows, $iDelete)
	Until _ArraySearch($aWindows, "") = -1
	$aWindows[0][0] = UBound($aWindows)
	For $Loop = 1 To $aWindows[0][0] - 1
		$aWindows[$Loop][1] = _ProcessGetName(WinGetProcess($aWindows[$Loop][1]))
		GUICtrlCreateListViewItem($aWindows[$Loop][1] & "|" & $aWindows[$Loop][0], $hControl)
	Next
	_ArrayDelete($aWindows, 0)
	For $i = 0 To _GUICtrlListView_GetColumnCount($hControl) Step 1
		_GUICtrlListView_SetColumnWidth($hControl, $i, $LVSCW_AUTOSIZE_USEHEADER)
	Next
;	_GUICtrlListView_SortItems($hControl, GUICtrlGetState($hControl))

EndFunc

Func _GetSteamGames($hControl, $hLibrary)

	_GUICtrlListView_DeleteAllItems($hControl)

	If $hLibrary = "" Then
		Local $aSteamLibraries = _GetSteamLibraries()
	Else
		Local $aSteamLibraries = _GetSteamLibraries($hLibrary)
	EndIf
	Local $aSteamGames
	For $iLoop1 = 1 To $aSteamLibraries[0] Step 1
		$aSteamGames = _SteamGetGamesFromLibrary($aSteamLibraries[$iLoop1])
		If $aSteamGames[0][0] = 0 Then ContinueLoop
		$aSteamGames[0][1] = $aSteamGames[0][0]
		Do
			$iDelete = _ArraySearch($aSteamGames, "")
			If $iDelete = -1 Then
				;;;
			Else
				$aSteamGames[0][0] = $aSteamGames[0][0] - 1
			EndIf
			_ArrayDelete($aSteamGames, $iDelete)
		Until _ArraySearch($aSteamGames, "") = -1
		For $iLoop2 = 1 To $aSteamGames[0][0] Step 1
			GUICtrlCreateListViewItem($aSteamGames[$iLoop2][0] & "|" & $aSteamGames[$iLoop2][1], $hControl)
		Next
	Next
	_ArrayDelete($aSteamGames, 0)
	For $i = 0 To _GUICtrlListView_GetColumnCount($hControl) Step 1
		_GUICtrlListView_SetColumnWidth($hControl, $i, $LVSCW_AUTOSIZE_USEHEADER)
	Next

EndFunc

Func _GetLatestRelease($sCurrent)

	Local $dAPIBin
	Local $sAPIJSON

	$dAPIBin = InetRead("https://api.fcofix.org/repos/rcmaehl/NotCPUCores/releases")
	If @error Then Return SetError(1, 0, 0)
	$sAPIJSON = BinaryToString($dAPIBin)
	If @error Then Return SetError(2, 0, 0)

	Local $aReleases = _StringBetween($sAPIJSON, '"tag_name":"', '",')
	If @error Then Return SetError(3, 0, 0)
	Local $aRelTypes = _StringBetween($sAPIJSON, '"prerelease":', ',')
	If @error Then Return SetError(3, 1, 0)
	Local $aCombined[UBound($aReleases)][2]

	For $iLoop = 0 To UBound($aReleases) - 1 Step 1
		$aCombined[$iLoop][0] = $aReleases[$iLoop]
		$aCombined[$iLoop][1] = $aRelTypes[$iLoop]
	Next

	Return _VersionCompare($aCombined[0][0], $sCurrent)

EndFunc


Func _IsChecked($idControlID)
	Return BitAND(GUICtrlRead($idControlID), $GUI_CHECKED) = $GUI_CHECKED
EndFunc   ;==>_IsChecked

Func _UpdateProfile($hFile)

	Switch IniRead($hFile, "Meta", "Version", "0") = "0"

		Case "0"

			Local Enum $AllCores, $FirstCore, $First2Cores, $First4Cores, $FirstHalf, $EvenCores, $OddCores, $EveryOtherPair, $FirstAMDCCX, $Custom
			Local Enum $PhysicalCores = 5, $NonPhysicalCores
			; Language Typos are hell
			Local Enum $PhyscialCores = 5
			Local Enum $LastCore = 1, $Last2Cores, $Last4Cores, $LastHalf, $LastAMDCCX = 8
			Local Enum $Low, $BelowNormal, $Normal, $AboveNormal, $High, $RealTime
			Local Enum $BroadcasterCores, $GameAppCores, $RemainingCores

			IniWrite($hFile, "Meta", "Version", "1")

			IniWrite($hFile, "General"  , "SplitAs"   , Eval(StringStripWS(StringReplace(IniRead($hFile, "General"  , "SplitAs"   , "Custom"), "-", ""), $STR_STRIPALL)))
			IniWrite($hFile, "General"  , "Priority"  , Eval(StringStripWS(              IniRead($hFile, "General"  , "Priority"  , "Custom")          , $STR_STRIPALL)))
			IniWrite($hFile, "Streaming", "SplitAs"   , Eval(StringStripWS(StringReplace(IniRead($hFile, "Streaming", "SplitAs"   , "Custom"), "-", ""), $STR_STRIPALL)))
			IniWrite($hFile, "Streaming", "Priority"  , Eval(StringStripWS(              IniRead($hFile, "Streaming", "Priority"  , "Custom")          , $STR_STRIPALL)))
			IniWrite($hFile, "Streaming", "Assignment", Eval(StringStripWS(StringReplace(IniRead($hFile, "Streaming", "Assignment", "Custom"), "/", ""), $STR_STRIPALL)))

		Case Else
			;;;

	EndSwitch

EndFunc

#cs
#include <StaticConstants.au3>

$sProcess = "firefox.exe"
$sIcon = _ProcessGetIcon($sProcess)

If Not @error Then
    $iWidth = 400
    $iHeight = 120

    GUICreate("_ProcessGetIcon - Extract Icon From Process Demo", $iWidth, $iHeight)
    GUISetIcon($sIcon)

    GUICtrlCreateLabel("Extracted Icon: " & @CRLF & $sIcon, 0, ($iHeight/2) - (32/2) - 30, $iWidth, 30, $SS_CENTER)
    GUICtrlCreateIcon($sIcon, 0, ($iWidth/2) - (32/2), ($iHeight/2) - (32/2), 32, 32)

    GUISetState()

    While GUIGetMsg() <> -3
    WEnd
Else
    MsgBox(48, "Attention!", "Error - Process (" & $sProcess & ") probably not runing!")
EndIf

Func _ProcessGetIcon($vProcess)
    Local $iPID = ProcessExists($vProcess)
    If Not $iPID Then Return SetError(1, 0, -1)

    Local $aProc = DllCall('kernel32.dll', 'hwnd', 'OpenProcess', 'int', BitOR(0x0400, 0x0010), 'int', 0, 'int', $iPID)
    If Not IsArray($aProc) Or Not $aProc[0] Then Return SetError(2, 0, -1)

    Local $vStruct = DllStructCreate('int[1024]')

    Local $hPsapi_Dll = DllOpen('Psapi.dll')
    If $hPsapi_Dll = -1 Then $hPsapi_Dll = DllOpen(@SystemDir & '\Psapi.dll')
    If $hPsapi_Dll = -1 Then $hPsapi_Dll = DllOpen(@WindowsDir & '\Psapi.dll')
    If $hPsapi_Dll = -1 Then Return SetError(3, 0, '')

    DllCall($hPsapi_Dll, 'int', 'EnumProcessModules', _
        'hwnd', $aProc[0], _
        'ptr', DllStructGetPtr($vStruct), _
        'int', DllStructGetSize($vStruct), _
        'int_ptr', 0)
    Local $aRet = DllCall($hPsapi_Dll, 'int', 'GetModuleFileNameEx', _
        'hwnd', $aProc[0], _
        'int', DllStructGetData($vStruct, 1), _
        'str', '', _
        'int', 2048)

    DllClose($hPsapi_Dll)

    If Not IsArray($aRet) Or StringLen($aRet[3]) = 0 Then Return SetError(4, 0, '')
    Return $aRet[3]
EndFunc
#ce
