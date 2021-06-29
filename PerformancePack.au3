#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Version=Beta
#AutoIt3Wrapper_Icon=Assets/icon.ico
#AutoIt3Wrapper_Outfile=NotCPUCores_x86.exe
#AutoIt3Wrapper_Outfile_x64=NotCPUCores.exe
#AutoIt3Wrapper_Compression=4
#AutoIt3Wrapper_Compile_Both=y
#AutoIt3Wrapper_UseX64=y
#AutoIt3Wrapper_Res_Comment=Compiled %date% @ %time%
#AutoIt3Wrapper_Res_Description=NotCPUCores
#AutoIt3Wrapper_Res_Fileversion=2.0.0.0
#AutoIt3Wrapper_Res_ProductVersion=2.0.0.0
#AutoIt3Wrapper_Res_LegalCopyright=Robert Maehl, using LGPL 3 License
#AutoIt3Wrapper_Res_Language=1033
#AutoIt3Wrapper_Res_requestedExecutionLevel=highestAvailable
#AutoIt3Wrapper_Run_Au3Stripper=y
#Au3Stripper_Parameters=/pe /so
#AutoIt3Wrapper_Res_File_Add=assets\GUI.png, RT_RCDATA, GUI, 0
#AutoIt3Wrapper_Res_File_Add=assets\Logo.jpg, RT_RCDATA, LOGO, 0
#AutoIt3Wrapper_Res_File_Add=assets\Close.png, RT_RCDATA, CLOSE, 0
#AutoIt3Wrapper_Res_File_Add=assets\Close_Alt.png, RT_RCDATA, CLOSE_ALT, 0
#AutoIt3Wrapper_Res_File_Add=assets\Minimize.png, RT_RCDATA, MINIMIZE, 0
#AutoIt3Wrapper_Res_File_Add=assets\Minimize_Alt.png, RT_RCDATA, MINIMIZE_ALT, 0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****

FileChangeDir(@SystemDir)

#include <GDIPlus.au3>

#include "includes\ResourcesEx.au3"

Main()

Func Main()

	Local $hGUI, $hCLOSE, $hMINIMIZE

	If _GDIPlus_Startup() Then
	;	SendReport("GDI+ started up successfully")
	Else
	;	SendReport("[ERROR] : GDI+ did not start !!! (errorcode : "&@error&")")
	EndIf

	;GUICtrlSetData($splash_status, "   " & Translate("Loading interface"))

	If Not @Compiled Or FileExists("theme") Then
		$sPath = "assets\"
		If FileExists("theme") Then $sPath = "theme\"
		$hGUI = _GDIPlus_ImageLoadFromFile($sPath & "GUI.png")
		$hCLOSE[0] = _GDIPlus_ImageLoadFromFile($sPath & "Close.png")
		$hCLOSE[1] = _GDIPlus_ImageLoadFromFile($sPath & "Close_Alt.png")
		$hMINIMIZE[0] = _GDIPlus_ImageLoadFromFile($sPath & "Minimize.png")
		$hMINIMIZE[1] = _GDIPlus_ImageLoadFromFile($sPath & "Minimize_Alt.png")
	Else
		$hGUI = _Resource_GetAsImage("GUI", $RT_RCDATA)
		$hCLOSE[0] = _Resource_GetAsImage("CLOSE", $RT_RCDATA)
		$hCLOSE[1] = _Resource_GetAsImage("CLOSE_ALT", $RT_RCDATA)
		$hMINIMIZE[0] = _Resource_GetAsImage("MINIMIZE", $RT_RCDATA)
		$hMINIMIZE[1] = _Resource_GetAsImage("MINIMIZE_ALT", $RT_RCDATA)
	EndIf

	$hCTRL_GUI = GUICreate("", 800, 600, 0, 0, $WS_POPUP, BitOR($WS_EX_LAYERED, $WS_EX_MDICHILD), $hGUI)

	_WinAPI_SetLayeredWindowAttributes($hCTRL_GUI, 0x121314)

	$ZEROGraphic = _GDIPlus_GraphicsCreateFromHWND($hCTRL_GUI)

	$hDISPLAY = _GDIPlus_GraphicsDrawImageRectRect($ZEROGraphic, $hGUI, 0, 0, 450, 750, 0, 0, 450, 750)

	GUISetState($GUI_SHOW, $hCTRL_GUI)

EndFunc