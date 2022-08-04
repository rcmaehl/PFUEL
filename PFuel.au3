#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=Assets/icon.ico
#AutoIt3Wrapper_Outfile=NotCPUCores_x86.exe
#AutoIt3Wrapper_Outfile_x64=NotCPUCores.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=Compiled %date% @ %time%
#AutoIt3Wrapper_Res_Description=PerformancePack
#AutoIt3Wrapper_Res_Fileversion=1.0.0.0
#AutoIt3Wrapper_Res_ProductVersion=1.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Robert Maehl, using LGPL 3 License
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=AsInvoker
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /so
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

FileChangeDir(@SystemDir)

Global $sVersion = "1.0.0.0"

#include <Misc.au3>
#include <String.au3>
#include <FontConstants.au3>
#include <WinAPIShellEx.au3>
#include <GUIConstantsEx.au3>

#include "includes\_WMIC.au3"
#include "includes\_Theming.au3"
#include "includes\_Translations.au3"
#include "includes\ResourcesEx.au3"

Global $aFonts[5]
Global $aColors = _SetTheme()

Main()

Func Main()

	Local Static $iMUI = @MUILang
	Local Static $aFonts[4]
	$aFonts = _GetTranslationFonts($iMUI)

	Local Enum $FontSmall, $FontMedium, $FontLarge, $FontExtraLarge
	Local Const $DPI_RATIO = _GDIPlus_GraphicsGetDPIRatio()[0]

	Local Enum $iBackground = 0, $iText, $iSidebar, $iFooter

	ProgressOn("PFUEL", "Loading WMIC")
	ProgressSet(0, "_GetCPUInfo()")
	ProgressSet(25, "_GetDiskInfo()")
	ProgressSet(50, "_GetGPUInfo()")
	ProgressSet(75, "_GetTPMInfo()")
	ProgressSet(100, "Done")
	Sleep(250)
	ProgressOff()

	Local $hGUI = GUICreate("PFuel", 800, 600, -1, -1, BitOR($WS_POPUP, $WS_BORDER))
	GUISetBkColor($aColors[$iBackground])
	GUISetFont($aFonts[$FontSmall] * $DPI_RATIO, $FW_BOLD, "", "Arial")

	GUICtrlSetDefColor($aColors[$iText])
	GUICtrlSetDefBkColor($aColors[$iBackground])

	Local $sCheck = RegRead("HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Themes\Personalize", "AppsUseLightTheme")
	If @error Then
		;;;
	ElseIf Not $sCheck Then
		GUICtrlSetDefColor(0xFFFFFF)
	EndIf

	; Top Most Interaction for Update Text
	Local $hUpdate = GUICtrlCreateLabel("", 0, 570, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])
	GUICtrlSetCursor(-1, 0)

	; Top Most Interaction for Closing Window
	Local $hExit = GUICtrlCreateLabel("", 760, 10, 30, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontExtraLarge] * $DPI_RATIO, $FW_MEDIUM)
	GUICtrlSetCursor(-1, 0)

	; Top Most Interaction for Socials
	Local $hGithub = GUICtrlCreateLabel("", 34, 110, 32, 32)
	GUICtrlSetTip(-1, "GitHub")
	GUICtrlSetCursor(-1, 0)

	Local $hDonate = GUICtrlCreateLabel("", 34, 160, 32, 32)
	GUICtrlSetTip(-1, _Translate($iMUI, "Donate"))
	GUICtrlSetCursor(-1, 0)

	Local $hDiscord = GUICtrlCreateLabel("", 34, 210, 32, 32)
	GUICtrlSetTip(-1, "Discord")
	GUICtrlSetCursor(-1, 0)

	Local $hLTT = GUICtrlCreateLabel("", 34, 260, 32, 32)
	GUICtrlSetTip(-1, "LTT")
	GUICtrlSetCursor(-1, 0)

	Local $hJob
	If @LogonDomain <> @ComputerName Then
		$hJob = GUICtrlCreateLabel("", 34, 310, 32, 32)
		GUICtrlSetTip(-1, "I'm For Hire")
		GUICtrlSetCursor(-1, 0)
	Else
		$hJob = GUICtrlCreateDummy()
	EndIf

	Local $hToggle = GUICtrlCreateLabel("", 34, 518, 32, 32)
	GUICtrlSetTip(-1, "Settings")
	GUICtrlSetCursor(-1, 0)
	GUICtrlSetState(-1, $GUI_HIDE)

	; Allow Dragging of Window
	GUICtrlCreateLabel("", 0, 0, 800, 30, -1, $GUI_WS_EX_PARENTDRAG)

	GUICtrlCreateLabel("", 0, 0, 100, 570)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])

	GUICtrlCreateLabel(_Translate($iMUI, "Check for Updates"), 0, 570, 100, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontSmall] * $DPI_RATIO, $FW_NORMAL, $GUI_FONTUNDER)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])
	GUICtrlSetTip(-1, "Update")
	GUICtrlSetCursor(-1, 0)

	GUICtrlCreateButton("Allocation", 0, 80, 100, 80, $BS_FLAT)
	GUICtrlCreateButton("Optimization", 0, 160, 100, 80, $BS_FLAT)
	GUICtrlCreateButton("Organization", 0, 240, 100, 80, $BS_FLAT)
	GUICtrlCreateButton("Settings", 0, 320, 100, 80, $BS_FLAT)

	#cs
	_GDIPlus_Startup()
	If @Compiled Then
		GUICtrlCreateIcon("", -1, 34, 110, 32, 32)
		_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 201, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 160, 32, 32)
		_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 202, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 210, 32, 32)
		_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 203, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 260, 32, 32)
		_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 204, 32, 32)
		If @LogonDomain <> @ComputerName Then
			GUICtrlCreateIcon("", -1, 34, 310, 32, 32)
			_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 205, 32, 32)
		EndIf
		GUICtrlCreateIcon("", -1, 34, 518, 32, 32)
		_SetBkSelfIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptFullPath, 206, 32, 32)
	Else
		GUICtrlCreateIcon("", -1, 34, 110, 32, 32)
		_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & "\assets\GitHub.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 160, 32, 32)
		_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & ".\assets\PayPal.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 210, 32, 32)
		_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & ".\assets\Discord.ico", -1, 32, 32)
		GUICtrlCreateIcon("", -1, 34, 260, 32, 32)
		_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & ".\assets\Web.ico", -1, 32, 32)
		If @LogonDomain <> @ComputerName Then
			GUICtrlCreateIcon("", -1, 34, 310, 32, 32)
			_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & ".\assets\HireMe.ico", -1, 32, 32)
		EndIf
		GUICtrlCreateIcon("", -1, 34, 518, 32, 32)
		_SetBkIcon(-1, $aColors[$iText], $aColors[$iSidebar], @ScriptDir & ".\assets\Settings.ico", -1, 32, 32)
	EndIf
	_GDIPlus_Shutdown()
	#ce

	GUICtrlCreateLabel("PFuel", 10, 10, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])
	GUICtrlCreateLabel("v " & $sVersion, 10, 30, 80, 20, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])

	GUICtrlCreateLabel(_Translate($iMUI, "Check for Updates"), 5, 560, 90, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontSmall] * $DPI_RATIO, $FW_NORMAL, $GUI_FONTUNDER)
	GUICtrlSetBkColor(-1, $aColors[$iSidebar])

	GUICtrlCreateLabel("", 100, 560, 700, 40)
	GUICtrlSetBkColor(-1, $aColors[$iFooter])

	GUICtrlCreateLabel(_GetCPUInfo(2), 470, 560, 300, 20, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iFooter])
	GUICtrlCreateLabel(_GetGPUInfo(0), 470, 580, 300, 20, $SS_CENTERIMAGE)
	GUICtrlSetBkColor(-1, $aColors[$iFooter])

	GUICtrlCreateLabel(_Translate($iMUI, "Program Allocation"), 130, 15, 640, 40, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontLarge] * $DPI_RATIO, $FW_SEMIBOLD, "", "", $CLEARTYPE_QUALITY)

	GUICtrlCreateLabel(ChrW(0x274C), 765, 5, 30, 30, $SS_CENTER + $SS_CENTERIMAGE)
	GUICtrlSetFont(-1, $aFonts[$FontLarge] * $DPI_RATIO, $FW_NORMAL)

	#Region Settings GUI
	Local $hSettings = GUICreate(_Translate($iMUI, "Settings"), 670, 558, 102, 2, $WS_POPUP, $WS_EX_MDICHILD, $hGUI)
	Local $bSettings = False
	GUISetBkColor($aColors[$iBackground])
	GUISetFont($aFonts[$FontSmall] * $DPI_RATIO, $FW_BOLD, "", "Arial")

	GUICtrlSetDefColor($aColors[$iText])
	GUICtrlSetDefBkColor($aColors[$iBackground])

	GUICtrlCreateGroup("", 30, 30, 640, 100)

	#EndRegion Settings GUI

	GUISwitch($hGUI)

	GUISetState(@SW_SHOW, $hGUI)

	Local $hMsg
	While 1
		$hMsg = GUIGetMsg()

		Select

			Case $hMsg = $GUI_EVENT_CLOSE Or $hMsg = $hExit
				GUIDelete($hGUI)
				Exit

			Case $hMsg = $hJob
				ShellExecute("https://fcofix.org/rcmaehl/wiki/I'M-FOR-HIRE")

			Case $hMsg = $hGithub
				ShellExecute("https://fcofix.org/PerformancePack")

			Case $hMsg = $hDonate
				ShellExecute("https://paypal.me/rhsky")

			Case $hMsg = $hDiscord
				ShellExecute("https://discord.gg/uBnBcBx")

			Case $hMsg = $hLTT
				;ShellExecute("")

			Case $hMsg = $hToggle
				If $bSettings Then
					GUISetState(@SW_HIDE, $hSettings)
				Else
					GUISetState(@SW_SHOW, $hSettings)
				EndIf
				$bSettings = Not $bSettings

			Case $hMsg = $hUpdate
				Switch _GetLatestRelease($sVersion)
					Case -1
						MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($iMUI, "Test Build?"), _Translate($iMUI, "You're running a newer build than publicly Available!"), 10)
					Case 0
						Switch @error
							Case 0
								MsgBox($MB_OK + $MB_ICONINFORMATION + $MB_TOPMOST, _Translate($iMUI, "Up to Date"), _Translate($iMUI, "You're running the latest build!"), 10)
							Case 1
								MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($iMUI, "Unable to Check for Updates"), _Translate($iMUI, "Unable to load release data."), 10)
							Case 2
								MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($iMUI, "Unable to Check for Updates"), _Translate($iMUI, "Invalid Data Received!"), 10)
							Case 3
								Switch @extended
									Case 0
										MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($iMUI, "Unable to Check for Updates"), _Translate($iMUI, "Invalid Release Tags Received!"), 10)
									Case 1
										MsgBox($MB_OK + $MB_ICONWARNING + $MB_TOPMOST, _Translate($iMUI, "Unable to Check for Updates"), _Translate($iMUI, "Invalid Release Types Received!"), 10)
								EndSwitch
						EndSwitch
					Case 1
						If MsgBox($MB_YESNO + $MB_ICONINFORMATION + $MB_TOPMOST, _Translate($iMUI, "Update Available"), _Translate($iMUI, "An Update is Available, would you like to download it?"), 10) = $IDYES Then ShellExecute("https://fcofix.org/PerformancePack/releases")
				EndSwitch

			Case Else
				;;;

		EndSelect
	WEnd
EndFunc   ;==>Main

Func _GetLatestRelease($sCurrent)

	Local $dAPIBin
	Local $sAPIJSON

	$dAPIBin = InetRead("https://api.fcofix.org/repos/rcmaehl/PFUEL/releases")
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

EndFunc   ;==>_GetLatestRelease