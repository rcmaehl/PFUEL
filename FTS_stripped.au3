#RequireAdmin
Global $__g_aArrayDisplay_SortInfo[11]
Global Const $_ARRAYCONSTANT_tagLVITEM = "struct;uint Mask;int Item;int SubItem;uint State;uint StateMask;ptr Text;int TextMax;int Image;lparam Param;" & "int Indent;int GroupID;uint Columns;ptr pColumns;ptr piColFmt;int iGroup;endstruct"
#Au3Stripper_Ignore_Funcs=__ArrayDisplay_SortCallBack
Func __ArrayDisplay_SortCallBack($nItem1, $nItem2, $hWnd)
If $__g_aArrayDisplay_SortInfo[3] = $__g_aArrayDisplay_SortInfo[4] Then
If Not $__g_aArrayDisplay_SortInfo[7] Then
$__g_aArrayDisplay_SortInfo[5] *= -1
$__g_aArrayDisplay_SortInfo[7] = 1
EndIf
Else
$__g_aArrayDisplay_SortInfo[7] = 1
EndIf
$__g_aArrayDisplay_SortInfo[6] = $__g_aArrayDisplay_SortInfo[3]
Local $sVal1 = __ArrayDisplay_GetItemText($hWnd, $nItem1, $__g_aArrayDisplay_SortInfo[3])
Local $sVal2 = __ArrayDisplay_GetItemText($hWnd, $nItem2, $__g_aArrayDisplay_SortInfo[3])
If $__g_aArrayDisplay_SortInfo[8] = 1 Then
If(StringIsFloat($sVal1) Or StringIsInt($sVal1)) Then $sVal1 = Number($sVal1)
If(StringIsFloat($sVal2) Or StringIsInt($sVal2)) Then $sVal2 = Number($sVal2)
EndIf
Local $nResult
If $__g_aArrayDisplay_SortInfo[8] < 2 Then
$nResult = 0
If $sVal1 < $sVal2 Then
$nResult = -1
ElseIf $sVal1 > $sVal2 Then
$nResult = 1
EndIf
Else
$nResult = DllCall('shlwapi.dll', 'int', 'StrCmpLogicalW', 'wstr', $sVal1, 'wstr', $sVal2)[0]
EndIf
$nResult = $nResult * $__g_aArrayDisplay_SortInfo[5]
Return $nResult
EndFunc
Func __ArrayDisplay_GetItemText($hWnd, $iIndex, $iSubItem = 0)
Local $tBuffer = DllStructCreate("wchar Text[4096]")
Local $pBuffer = DllStructGetPtr($tBuffer)
Local $tItem = DllStructCreate($_ARRAYCONSTANT_tagLVITEM)
DllStructSetData($tItem, "SubItem", $iSubItem)
DllStructSetData($tItem, "TextMax", 4096)
DllStructSetData($tItem, "Text", $pBuffer)
If IsHWnd($hWnd) Then
DllCall("user32.dll", "lresult", "SendMessageW", "hwnd", $hWnd, "uint", 0x1073, "wparam", $iIndex, "struct*", $tItem)
Else
Local $pItem = DllStructGetPtr($tItem)
GUICtrlSendMsg($hWnd, 0x1073, $iIndex, $pItem)
EndIf
Return DllStructGetData($tBuffer, "Text")
EndFunc
Global Enum $ARRAYFILL_FORCE_DEFAULT, $ARRAYFILL_FORCE_SINGLEITEM, $ARRAYFILL_FORCE_INT, $ARRAYFILL_FORCE_NUMBER, $ARRAYFILL_FORCE_PTR, $ARRAYFILL_FORCE_HWND, $ARRAYFILL_FORCE_STRING, $ARRAYFILL_FORCE_BOOLEAN
Func _ArrayAdd(ByRef $aArray, $vValue, $iStart = 0, $sDelim_Item = "|", $sDelim_Row = @CRLF, $iForce = $ARRAYFILL_FORCE_DEFAULT)
If $iStart = Default Then $iStart = 0
If $sDelim_Item = Default Then $sDelim_Item = "|"
If $sDelim_Row = Default Then $sDelim_Row = @CRLF
If $iForce = Default Then $iForce = $ARRAYFILL_FORCE_DEFAULT
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, 1)
Local $hDataType = 0
Switch $iForce
Case $ARRAYFILL_FORCE_INT
$hDataType = Int
Case $ARRAYFILL_FORCE_NUMBER
$hDataType = Number
Case $ARRAYFILL_FORCE_PTR
$hDataType = Ptr
Case $ARRAYFILL_FORCE_HWND
$hDataType = Hwnd
Case $ARRAYFILL_FORCE_STRING
$hDataType = String
Case $ARRAYFILL_FORCE_BOOLEAN
$hDataType = "Boolean"
EndSwitch
Switch UBound($aArray, 0)
Case 1
If $iForce = $ARRAYFILL_FORCE_SINGLEITEM Then
ReDim $aArray[$iDim_1 + 1]
$aArray[$iDim_1] = $vValue
Return $iDim_1
EndIf
If IsArray($vValue) Then
If UBound($vValue, 0) <> 1 Then Return SetError(5, 0, -1)
$hDataType = 0
Else
Local $aTmp = StringSplit($vValue, $sDelim_Item, 2 + 1)
If UBound($aTmp, 1) = 1 Then
$aTmp[0] = $vValue
EndIf
$vValue = $aTmp
EndIf
Local $iAdd = UBound($vValue, 1)
ReDim $aArray[$iDim_1 + $iAdd]
For $i = 0 To $iAdd - 1
If String($hDataType) = "Boolean" Then
Switch $vValue[$i]
Case "True", "1"
$aArray[$iDim_1 + $i] = True
Case "False", "0", ""
$aArray[$iDim_1 + $i] = False
EndSwitch
ElseIf IsFunc($hDataType) Then
$aArray[$iDim_1 + $i] = $hDataType($vValue[$i])
Else
$aArray[$iDim_1 + $i] = $vValue[$i]
EndIf
Next
Return $iDim_1 + $iAdd - 1
Case 2
Local $iDim_2 = UBound($aArray, 2)
If $iStart < 0 Or $iStart > $iDim_2 - 1 Then Return SetError(4, 0, -1)
Local $iValDim_1, $iValDim_2 = 0, $iColCount
If IsArray($vValue) Then
If UBound($vValue, 0) <> 2 Then Return SetError(5, 0, -1)
$iValDim_1 = UBound($vValue, 1)
$iValDim_2 = UBound($vValue, 2)
$hDataType = 0
Else
Local $aSplit_1 = StringSplit($vValue, $sDelim_Row, 2 + 1)
$iValDim_1 = UBound($aSplit_1, 1)
Local $aTmp[$iValDim_1][0], $aSplit_2
For $i = 0 To $iValDim_1 - 1
$aSplit_2 = StringSplit($aSplit_1[$i], $sDelim_Item, 2 + 1)
$iColCount = UBound($aSplit_2)
If $iColCount > $iValDim_2 Then
$iValDim_2 = $iColCount
ReDim $aTmp[$iValDim_1][$iValDim_2]
EndIf
For $j = 0 To $iColCount - 1
$aTmp[$i][$j] = $aSplit_2[$j]
Next
Next
$vValue = $aTmp
EndIf
If UBound($vValue, 2) + $iStart > UBound($aArray, 2) Then Return SetError(3, 0, -1)
ReDim $aArray[$iDim_1 + $iValDim_1][$iDim_2]
For $iWriteTo_Index = 0 To $iValDim_1 - 1
For $j = 0 To $iDim_2 - 1
If $j < $iStart Then
$aArray[$iWriteTo_Index + $iDim_1][$j] = ""
ElseIf $j - $iStart > $iValDim_2 - 1 Then
$aArray[$iWriteTo_Index + $iDim_1][$j] = ""
Else
If String($hDataType) = "Boolean" Then
Switch $vValue[$iWriteTo_Index][$j - $iStart]
Case "True", "1"
$aArray[$iWriteTo_Index + $iDim_1][$j] = True
Case "False", "0", ""
$aArray[$iWriteTo_Index + $iDim_1][$j] = False
EndSwitch
ElseIf IsFunc($hDataType) Then
$aArray[$iWriteTo_Index + $iDim_1][$j] = $hDataType($vValue[$iWriteTo_Index][$j - $iStart])
Else
$aArray[$iWriteTo_Index + $iDim_1][$j] = $vValue[$iWriteTo_Index][$j - $iStart]
EndIf
EndIf
Next
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return UBound($aArray, 1) - 1
EndFunc
Func _ArrayConcatenate(ByRef $aArrayTarget, Const ByRef $aArraySource, $iStart = 0)
If $iStart = Default Then $iStart = 0
If Not IsArray($aArrayTarget) Then Return SetError(1, 0, -1)
If Not IsArray($aArraySource) Then Return SetError(2, 0, -1)
Local $iDim_Total_Tgt = UBound($aArrayTarget, 0)
Local $iDim_Total_Src = UBound($aArraySource, 0)
Local $iDim_1_Tgt = UBound($aArrayTarget, 1)
Local $iDim_1_Src = UBound($aArraySource, 1)
If $iStart < 0 Or $iStart > $iDim_1_Src - 1 Then Return SetError(6, 0, -1)
Switch $iDim_Total_Tgt
Case 1
If $iDim_Total_Src <> 1 Then Return SetError(4, 0, -1)
ReDim $aArrayTarget[$iDim_1_Tgt + $iDim_1_Src - $iStart]
For $i = $iStart To $iDim_1_Src - 1
$aArrayTarget[$iDim_1_Tgt + $i - $iStart] = $aArraySource[$i]
Next
Case 2
If $iDim_Total_Src <> 2 Then Return SetError(4, 0, -1)
Local $iDim_2_Tgt = UBound($aArrayTarget, 2)
If UBound($aArraySource, 2) <> $iDim_2_Tgt Then Return SetError(5, 0, -1)
ReDim $aArrayTarget[$iDim_1_Tgt + $iDim_1_Src - $iStart][$iDim_2_Tgt]
For $i = $iStart To $iDim_1_Src - 1
For $j = 0 To $iDim_2_Tgt - 1
$aArrayTarget[$iDim_1_Tgt + $i - $iStart][$j] = $aArraySource[$i][$j]
Next
Next
Case Else
Return SetError(3, 0, -1)
EndSwitch
Return UBound($aArrayTarget, 1)
EndFunc
Func _ArrayDelete(ByRef $aArray, $vRange)
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, 1) - 1
If IsArray($vRange) Then
If UBound($vRange, 0) <> 1 Or UBound($vRange, 1) < 2 Then Return SetError(4, 0, -1)
Else
Local $iNumber, $aSplit_1, $aSplit_2
$vRange = StringStripWS($vRange, 8)
$aSplit_1 = StringSplit($vRange, ";")
$vRange = ""
For $i = 1 To $aSplit_1[0]
If Not StringRegExp($aSplit_1[$i], "^\d+(-\d+)?$") Then Return SetError(3, 0, -1)
$aSplit_2 = StringSplit($aSplit_1[$i], "-")
Switch $aSplit_2[0]
Case 1
$vRange &= $aSplit_2[1] & ";"
Case 2
If Number($aSplit_2[2]) >= Number($aSplit_2[1]) Then
$iNumber = $aSplit_2[1] - 1
Do
$iNumber += 1
$vRange &= $iNumber & ";"
Until $iNumber = $aSplit_2[2]
EndIf
EndSwitch
Next
$vRange = StringSplit(StringTrimRight($vRange, 1), ";")
EndIf
If $vRange[1] < 0 Or $vRange[$vRange[0]] > $iDim_1 Then Return SetError(5, 0, -1)
Local $iCopyTo_Index = 0
Switch UBound($aArray, 0)
Case 1
For $i = 1 To $vRange[0]
$aArray[$vRange[$i]] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $aArray[$iReadFrom_Index] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
$aArray[$iCopyTo_Index] = $aArray[$iReadFrom_Index]
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $aArray[$iDim_1 - $vRange[0] + 1]
Case 2
Local $iDim_2 = UBound($aArray, 2) - 1
For $i = 1 To $vRange[0]
$aArray[$vRange[$i]][0] = ChrW(0xFAB1)
Next
For $iReadFrom_Index = 0 To $iDim_1
If $aArray[$iReadFrom_Index][0] == ChrW(0xFAB1) Then
ContinueLoop
Else
If $iReadFrom_Index <> $iCopyTo_Index Then
For $j = 0 To $iDim_2
$aArray[$iCopyTo_Index][$j] = $aArray[$iReadFrom_Index][$j]
Next
EndIf
$iCopyTo_Index += 1
EndIf
Next
ReDim $aArray[$iDim_1 - $vRange[0] + 1][$iDim_2 + 1]
Case Else
Return SetError(2, 0, False)
EndSwitch
Return UBound($aArray, 1)
EndFunc
Func _ArraySearch(Const ByRef $aArray, $vValue, $iStart = 0, $iEnd = 0, $iCase = 0, $iCompare = 0, $iForward = 1, $iSubItem = -1, $bRow = False)
If $iStart = Default Then $iStart = 0
If $iEnd = Default Then $iEnd = 0
If $iCase = Default Then $iCase = 0
If $iCompare = Default Then $iCompare = 0
If $iForward = Default Then $iForward = 1
If $iSubItem = Default Then $iSubItem = -1
If $bRow = Default Then $bRow = False
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray) - 1
If $iDim_1 = -1 Then Return SetError(3, 0, -1)
Local $iDim_2 = UBound($aArray, 2) - 1
Local $bCompType = False
If $iCompare = 2 Then
$iCompare = 0
$bCompType = True
EndIf
If $bRow Then
If UBound($aArray, 0) = 1 Then Return SetError(5, 0, -1)
If $iEnd < 1 Or $iEnd > $iDim_2 Then $iEnd = $iDim_2
If $iStart < 0 Then $iStart = 0
If $iStart > $iEnd Then Return SetError(4, 0, -1)
Else
If $iEnd < 1 Or $iEnd > $iDim_1 Then $iEnd = $iDim_1
If $iStart < 0 Then $iStart = 0
If $iStart > $iEnd Then Return SetError(4, 0, -1)
EndIf
Local $iStep = 1
If Not $iForward Then
Local $iTmp = $iStart
$iStart = $iEnd
$iEnd = $iTmp
$iStep = -1
EndIf
Switch UBound($aArray, 0)
Case 1
If Not $iCompare Then
If Not $iCase Then
For $i = $iStart To $iEnd Step $iStep
If $bCompType And VarGetType($aArray[$i]) <> VarGetType($vValue) Then ContinueLoop
If $aArray[$i] = $vValue Then Return $i
Next
Else
For $i = $iStart To $iEnd Step $iStep
If $bCompType And VarGetType($aArray[$i]) <> VarGetType($vValue) Then ContinueLoop
If $aArray[$i] == $vValue Then Return $i
Next
EndIf
Else
For $i = $iStart To $iEnd Step $iStep
If $iCompare = 3 Then
If StringRegExp($aArray[$i], $vValue) Then Return $i
Else
If StringInStr($aArray[$i], $vValue, $iCase) > 0 Then Return $i
EndIf
Next
EndIf
Case 2
Local $iDim_Sub
If $bRow Then
$iDim_Sub = $iDim_1
If $iSubItem > $iDim_Sub Then $iSubItem = $iDim_Sub
If $iSubItem < 0 Then
$iSubItem = 0
Else
$iDim_Sub = $iSubItem
EndIf
Else
$iDim_Sub = $iDim_2
If $iSubItem > $iDim_Sub Then $iSubItem = $iDim_Sub
If $iSubItem < 0 Then
$iSubItem = 0
Else
$iDim_Sub = $iSubItem
EndIf
EndIf
For $j = $iSubItem To $iDim_Sub
If Not $iCompare Then
If Not $iCase Then
For $i = $iStart To $iEnd Step $iStep
If $bRow Then
If $bCompType And VarGetType($aArray[$j][$i]) <> VarGetType($vValue) Then ContinueLoop
If $aArray[$j][$i] = $vValue Then Return $i
Else
If $bCompType And VarGetType($aArray[$i][$j]) <> VarGetType($vValue) Then ContinueLoop
If $aArray[$i][$j] = $vValue Then Return $i
EndIf
Next
Else
For $i = $iStart To $iEnd Step $iStep
If $bRow Then
If $bCompType And VarGetType($aArray[$j][$i]) <> VarGetType($vValue) Then ContinueLoop
If $aArray[$j][$i] == $vValue Then Return $i
Else
If $bCompType And VarGetType($aArray[$i][$j]) <> VarGetType($vValue) Then ContinueLoop
If $aArray[$i][$j] == $vValue Then Return $i
EndIf
Next
EndIf
Else
For $i = $iStart To $iEnd Step $iStep
If $iCompare = 3 Then
If $bRow Then
If StringRegExp($aArray[$j][$i], $vValue) Then Return $i
Else
If StringRegExp($aArray[$i][$j], $vValue) Then Return $i
EndIf
Else
If $bRow Then
If StringInStr($aArray[$j][$i], $vValue, $iCase) > 0 Then Return $i
Else
If StringInStr($aArray[$i][$j], $vValue, $iCase) > 0 Then Return $i
EndIf
EndIf
Next
EndIf
Next
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return SetError(6, 0, -1)
EndFunc
Func _ArrayToString(Const ByRef $aArray, $sDelim_Col = "|", $iStart_Row = -1, $iEnd_Row = -1, $sDelim_Row = @CRLF, $iStart_Col = -1, $iEnd_Col = -1)
If $sDelim_Col = Default Then $sDelim_Col = "|"
If $sDelim_Row = Default Then $sDelim_Row = @CRLF
If $iStart_Row = Default Then $iStart_Row = -1
If $iEnd_Row = Default Then $iEnd_Row = -1
If $iStart_Col = Default Then $iStart_Col = -1
If $iEnd_Col = Default Then $iEnd_Col = -1
If Not IsArray($aArray) Then Return SetError(1, 0, -1)
Local $iDim_1 = UBound($aArray, 1) - 1
If $iStart_Row = -1 Then $iStart_Row = 0
If $iEnd_Row = -1 Then $iEnd_Row = $iDim_1
If $iStart_Row < -1 Or $iEnd_Row < -1 Then Return SetError(3, 0, -1)
If $iStart_Row > $iDim_1 Or $iEnd_Row > $iDim_1 Then Return SetError(3, 0, "")
If $iStart_Row > $iEnd_Row Then Return SetError(4, 0, -1)
Local $sRet = ""
Switch UBound($aArray, 0)
Case 1
For $i = $iStart_Row To $iEnd_Row
$sRet &= $aArray[$i] & $sDelim_Col
Next
Return StringTrimRight($sRet, StringLen($sDelim_Col))
Case 2
Local $iDim_2 = UBound($aArray, 2) - 1
If $iStart_Col = -1 Then $iStart_Col = 0
If $iEnd_Col = -1 Then $iEnd_Col = $iDim_2
If $iStart_Col < -1 Or $iEnd_Col < -1 Then Return SetError(5, 0, -1)
If $iStart_Col > $iDim_2 Or $iEnd_Col > $iDim_2 Then Return SetError(5, 0, -1)
If $iStart_Col > $iEnd_Col Then Return SetError(6, 0, -1)
For $i = $iStart_Row To $iEnd_Row
For $j = $iStart_Col To $iEnd_Col
$sRet &= $aArray[$i][$j] & $sDelim_Col
Next
$sRet = StringTrimRight($sRet, StringLen($sDelim_Col)) & $sDelim_Row
Next
Return StringTrimRight($sRet, StringLen($sDelim_Row))
Case Else
Return SetError(2, 0, -1)
EndSwitch
Return 1
EndFunc
Func _FileCountLines($sFilePath)
FileReadToArray($sFilePath)
If @error Then Return SetError(@error, @extended, 0)
Return @extended
EndFunc
Func _FileReadToArray($sFilePath, ByRef $vReturn, $iFlags = 1, $sDelimiter = "")
$vReturn = 0
If $iFlags = Default Then $iFlags = 1
If $sDelimiter = Default Then $sDelimiter = ""
Local $bExpand = True
If BitAND($iFlags, 2) Then
$bExpand = False
$iFlags -= 2
EndIf
Local $iEntire = 0
If BitAND($iFlags, 4) Then
$iEntire = 1
$iFlags -= 4
EndIf
Local $iNoCount = 0
If $iFlags <> 1 Then
$iFlags = 0
$iNoCount = 2
EndIf
If $sDelimiter Then
Local $aLines = FileReadToArray($sFilePath)
If @error Then Return SetError(@error, 0, 0)
Local $iDim_1 = UBound($aLines) + $iFlags
If $bExpand Then
Local $iDim_2 = UBound(StringSplit($aLines[0], $sDelimiter, $iEntire + 2))
Local $aTemp_Array[$iDim_1][$iDim_2]
Local $iFields, $aSplit
For $i = 0 To $iDim_1 - $iFlags - 1
$aSplit = StringSplit($aLines[$i], $sDelimiter, $iEntire + 2)
$iFields = UBound($aSplit)
If $iFields <> $iDim_2 Then
Return SetError(3, 0, 0)
EndIf
For $j = 0 To $iFields - 1
$aTemp_Array[$i + $iFlags][$j] = $aSplit[$j]
Next
Next
If $iDim_2 < 2 Then Return SetError(4, 0, 0)
If $iFlags Then
$aTemp_Array[0][0] = $iDim_1 - $iFlags
$aTemp_Array[0][1] = $iDim_2
EndIf
Else
Local $aTemp_Array[$iDim_1]
For $i = 0 To $iDim_1 - $iFlags - 1
$aTemp_Array[$i + $iFlags] = StringSplit($aLines[$i], $sDelimiter, $iEntire + $iNoCount)
Next
If $iFlags Then
$aTemp_Array[0] = $iDim_1 - $iFlags
EndIf
EndIf
$vReturn = $aTemp_Array
Else
If $iFlags Then
Local $hFileOpen = FileOpen($sFilePath, 0)
If $hFileOpen = -1 Then Return SetError(1, 0, 0)
Local $sFileRead = FileRead($hFileOpen)
FileClose($hFileOpen)
If StringLen($sFileRead) Then
$vReturn = StringRegExp(@LF & $sFileRead, "(?|(\N+)\z|(\N*)(?:\R))", 3)
$vReturn[0] = UBound($vReturn) - 1
Else
Return SetError(2, 0, 0)
EndIf
Else
$vReturn = FileReadToArray($sFilePath)
If @error Then
$vReturn = 0
Return SetError(@error, 0, 0)
EndIf
EndIf
EndIf
Return 1
EndFunc
Func _FileWriteToLine($sFilePath, $iLine, $sText, $bOverWrite = False, $bFill = False)
If $bOverWrite = Default Then $bOverWrite = False
If $bFill = Default Then $bFill = False
If Not FileExists($sFilePath) Then Return SetError(2, 0, 0)
If $iLine <= 0 Then Return SetError(4, 0, 0)
If Not(IsBool($bOverWrite) Or $bOverWrite = 0 Or $bOverWrite = 1) Then Return SetError(5, 0, 0)
If Not IsString($sText) Then
$sText = String($sText)
If $sText = "" Then Return SetError(6, 0, 0)
EndIf
If Not IsBool($bFill) Then Return SetError(7, 0, 0)
Local $aArray = FileReadToArray($sFilePath)
If @error Then Local $aArray[0]
Local $iUBound = UBound($aArray) - 1
If $bFill Then
If $iUBound < $iLine Then
ReDim $aArray[$iLine]
$iUBound = $iLine - 1
EndIf
Else
If($iUBound + 1) < $iLine Then Return SetError(1, 0, 0)
EndIf
$aArray[$iLine - 1] =($bOverWrite ? $sText : $sText & @CRLF & $aArray[$iLine - 1])
Local $sData = ""
For $i = 0 To $iUBound
$sData &= $aArray[$i] & @CRLF
Next
$sData = StringTrimRight($sData, StringLen(@CRLF))
Local $hFileOpen = FileOpen($sFilePath, FileGetEncoding($sFilePath) + 2)
If $hFileOpen = -1 Then Return SetError(3, 0, 0)
FileWrite($hFileOpen, $sData)
FileClose($hFileOpen)
Return 1
EndFunc
Global Const $tagRECT = "struct;long Left;long Top;long Right;long Bottom;endstruct"
Global Const $tagREBARBANDINFO = "uint cbSize;uint fMask;uint fStyle;dword clrFore;dword clrBack;ptr lpText;uint cch;" & "int iImage;hwnd hwndChild;uint cxMinChild;uint cyMinChild;uint cx;handle hbmBack;uint wID;uint cyChild;uint cyMaxChild;" & "uint cyIntegral;uint cxIdeal;lparam lParam;uint cxHeader" &((@OSVersion = "WIN_XP") ? "" : ";" & $tagRECT & ";uint uChevronState")
Func _WinAPI_GetLastError(Const $_iCurrentError = @error, Const $_iCurrentExtended = @extended)
Local $aResult = DllCall("kernel32.dll", "dword", "GetLastError")
Return SetError($_iCurrentError, $_iCurrentExtended, $aResult[0])
EndFunc
Func _VersionCompare($sVersion1, $sVersion2)
If $sVersion1 = $sVersion2 Then Return 0
Local $sSubVersion1 = "", $sSubVersion2 = ""
If StringIsAlpha(StringRight($sVersion1, 1)) Then
$sSubVersion1 = StringRight($sVersion1, 1)
$sVersion1 = StringTrimRight($sVersion1, 1)
EndIf
If StringIsAlpha(StringRight($sVersion2, 1)) Then
$sSubVersion2 = StringRight($sVersion2, 1)
$sVersion2 = StringTrimRight($sVersion2, 1)
EndIf
Local $aVersion1 = StringSplit($sVersion1, ".,"), $aVersion2 = StringSplit($sVersion2, ".,")
Local $iPartDifference =($aVersion1[0] - $aVersion2[0])
If $iPartDifference < 0 Then
ReDim $aVersion1[UBound($aVersion2)]
$aVersion1[0] = UBound($aVersion1) - 1
For $i =(UBound($aVersion1) - Abs($iPartDifference)) To $aVersion1[0]
$aVersion1[$i] = "0"
Next
ElseIf $iPartDifference > 0 Then
ReDim $aVersion2[UBound($aVersion1)]
$aVersion2[0] = UBound($aVersion2) - 1
For $i =(UBound($aVersion2) - Abs($iPartDifference)) To $aVersion2[0]
$aVersion2[$i] = "0"
Next
EndIf
For $i = 1 To $aVersion1[0]
If StringIsDigit($aVersion1[$i]) And StringIsDigit($aVersion2[$i]) Then
If Number($aVersion1[$i]) > Number($aVersion2[$i]) Then
Return SetExtended(2, 1)
ElseIf Number($aVersion1[$i]) < Number($aVersion2[$i]) Then
Return SetExtended(2, -1)
ElseIf $i = $aVersion1[0] Then
If $sSubVersion1 > $sSubVersion2 Then
Return SetExtended(3, 1)
ElseIf $sSubVersion1 < $sSubVersion2 Then
Return SetExtended(3, -1)
EndIf
EndIf
Else
If $aVersion1[$i] > $aVersion2[$i] Then
Return SetExtended(1, 1)
ElseIf $aVersion1[$i] < $aVersion2[$i] Then
Return SetExtended(1, -1)
EndIf
EndIf
Next
Return SetExtended(Abs($iPartDifference), 0)
EndFunc
Func _StringBetween($sString, $sStart, $sEnd, $iMode = 0, $bCase = False)
$sStart = $sStart ? "\Q" & $sStart & "\E" : "\A"
If $iMode <> 1 Then $iMode = 0
If $iMode = 0 Then
$sEnd = $sEnd ? "(?=\Q" & $sEnd & "\E)" : "\z"
Else
$sEnd = $sEnd ? "\Q" & $sEnd & "\E" : "\z"
EndIf
If $bCase = Default Then
$bCase = False
EndIf
Local $aReturn = StringRegExp($sString, "(?s" &(Not $bCase ? "i" : "") & ")" & $sStart & "(.*?)" & $sEnd, 3)
If @error Then Return SetError(1, 0, 0)
Return $aReturn
EndFunc
Global Enum $SECURITYANONYMOUS = 0, $SECURITYIDENTIFICATION, $SECURITYIMPERSONATION, $SECURITYDELEGATION
Func _Security__AdjustTokenPrivileges($hToken, $bDisableAll, $tNewState, $iBufferLen, $tPrevState = 0, $pRequired = 0)
Local $aCall = DllCall("advapi32.dll", "bool", "AdjustTokenPrivileges", "handle", $hToken, "bool", $bDisableAll, "struct*", $tNewState, "dword", $iBufferLen, "struct*", $tPrevState, "struct*", $pRequired)
If @error Then Return SetError(@error, @extended, False)
Return Not($aCall[0] = 0)
EndFunc
Func _Security__ImpersonateSelf($iLevel = $SECURITYIMPERSONATION)
Local $aCall = DllCall("advapi32.dll", "bool", "ImpersonateSelf", "int", $iLevel)
If @error Then Return SetError(@error, @extended, False)
Return Not($aCall[0] = 0)
EndFunc
Func _Security__LookupPrivilegeValue($sSystem, $sName)
Local $aCall = DllCall("advapi32.dll", "bool", "LookupPrivilegeValueW", "wstr", $sSystem, "wstr", $sName, "int64*", 0)
If @error Or Not $aCall[0] Then Return SetError(@error, @extended, 0)
Return $aCall[3]
EndFunc
Func _Security__OpenThreadToken($iAccess, $hThread = 0, $bOpenAsSelf = False)
If $hThread = 0 Then
Local $aResult = DllCall("kernel32.dll", "handle", "GetCurrentThread")
If @error Then Return SetError(@error + 10, @extended, 0)
$hThread = $aResult[0]
EndIf
Local $aCall = DllCall("advapi32.dll", "bool", "OpenThreadToken", "handle", $hThread, "dword", $iAccess, "bool", $bOpenAsSelf, "handle*", 0)
If @error Or Not $aCall[0] Then Return SetError(@error, @extended, 0)
Return $aCall[4]
EndFunc
Func _Security__OpenThreadTokenEx($iAccess, $hThread = 0, $bOpenAsSelf = False)
Local $hToken = _Security__OpenThreadToken($iAccess, $hThread, $bOpenAsSelf)
If $hToken = 0 Then
Local Const $ERROR_NO_TOKEN = 1008
If _WinAPI_GetLastError() <> $ERROR_NO_TOKEN Then Return SetError(20, _WinAPI_GetLastError(), 0)
If Not _Security__ImpersonateSelf() Then Return SetError(@error + 10, _WinAPI_GetLastError(), 0)
$hToken = _Security__OpenThreadToken($iAccess, $hThread, $bOpenAsSelf)
If $hToken = 0 Then Return SetError(@error, _WinAPI_GetLastError(), 0)
EndIf
Return $hToken
EndFunc
Func _Security__SetPrivilege($hToken, $sPrivilege, $bEnable)
Local $iLUID = _Security__LookupPrivilegeValue("", $sPrivilege)
If $iLUID = 0 Then Return SetError(@error + 10, @extended, False)
Local Const $tagTOKEN_PRIVILEGES = "dword Count;align 4;int64 LUID;dword Attributes"
Local $tCurrState = DllStructCreate($tagTOKEN_PRIVILEGES)
Local $iCurrState = DllStructGetSize($tCurrState)
Local $tPrevState = DllStructCreate($tagTOKEN_PRIVILEGES)
Local $iPrevState = DllStructGetSize($tPrevState)
Local $tRequired = DllStructCreate("int Data")
DllStructSetData($tCurrState, "Count", 1)
DllStructSetData($tCurrState, "LUID", $iLUID)
If Not _Security__AdjustTokenPrivileges($hToken, False, $tCurrState, $iCurrState, $tPrevState, $tRequired) Then Return SetError(2, @error, False)
DllStructSetData($tPrevState, "Count", 1)
DllStructSetData($tPrevState, "LUID", $iLUID)
Local $iAttributes = DllStructGetData($tPrevState, "Attributes")
If $bEnable Then
$iAttributes = BitOR($iAttributes, 0x00000002)
Else
$iAttributes = BitAND($iAttributes, BitNOT(0x00000002))
EndIf
DllStructSetData($tPrevState, "Attributes", $iAttributes)
If Not _Security__AdjustTokenPrivileges($hToken, False, $tPrevState, $iPrevState, $tCurrState, $tRequired) Then Return SetError(3, @error, False)
Return True
EndFunc
Global Const $tagOSVERSIONINFO = 'struct;dword OSVersionInfoSize;dword MajorVersion;dword MinorVersion;dword BuildNumber;dword PlatformId;wchar CSDVersion[128];endstruct'
Global Const $__WINVER = __WINVER()
Func _WinAPI_GetDlgCtrlID($hWnd)
Local $aResult = DllCall("user32.dll", "int", "GetDlgCtrlID", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetModuleHandle($sModuleName)
Local $sModuleNameType = "wstr"
If $sModuleName = "" Then
$sModuleName = 0
$sModuleNameType = "ptr"
EndIf
Local $aResult = DllCall("kernel32.dll", "handle", "GetModuleHandleW", $sModuleNameType, $sModuleName)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func __WINVER()
Local $tOSVI = DllStructCreate($tagOSVERSIONINFO)
DllStructSetData($tOSVI, 1, DllStructGetSize($tOSVI))
Local $aRet = DllCall('kernel32.dll', 'bool', 'GetVersionExW', 'struct*', $tOSVI)
If @error Or Not $aRet[0] Then Return SetError(@error, @extended, 0)
Return BitOR(BitShift(DllStructGetData($tOSVI, 2), -8), DllStructGetData($tOSVI, 3))
EndFunc
Func _WinAPI_CloseHandle($hObject)
Local $aResult = DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hObject)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_OpenProcess($iAccess, $bInherit, $iPID, $bDebugPriv = False)
Local $aResult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $bInherit, "dword", $iPID)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return $aResult[0]
If Not $bDebugPriv Then Return SetError(100, 0, 0)
Local $hToken = _Security__OpenThreadTokenEx(BitOR(0x00000020, 0x00000008))
If @error Then Return SetError(@error + 10, @extended, 0)
_Security__SetPrivilege($hToken, "SeDebugPrivilege", True)
Local $iError = @error
Local $iExtended = @extended
Local $iRet = 0
If Not @error Then
$aResult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $bInherit, "dword", $iPID)
$iError = @error
$iExtended = @extended
If $aResult[0] Then $iRet = $aResult[0]
_Security__SetPrivilege($hToken, "SeDebugPrivilege", False)
If @error Then
$iError = @error + 20
$iExtended = @extended
EndIf
Else
$iError = @error + 30
EndIf
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hToken)
Return SetError($iError, $iExtended, $iRet)
EndFunc
Global Const $tagMEMMAP = "handle hProc;ulong_ptr Size;ptr Mem"
Func _MemFree(ByRef $tMemMap)
Local $pMemory = DllStructGetData($tMemMap, "Mem")
Local $hProcess = DllStructGetData($tMemMap, "hProc")
Local $bResult = _MemVirtualFreeEx($hProcess, $pMemory, 0, 0x00008000)
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hProcess)
If @error Then Return SetError(@error, @extended, False)
Return $bResult
EndFunc
Func _MemInit($hWnd, $iSize, ByRef $tMemMap)
Local $aResult = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
If @error Then Return SetError(@error + 10, @extended, 0)
Local $iProcessID = $aResult[2]
If $iProcessID = 0 Then Return SetError(1, 0, 0)
Local $iAccess = BitOR(0x00000008, 0x00000010, 0x00000020)
Local $hProcess = __Mem_OpenProcess($iAccess, False, $iProcessID, True)
Local $iAlloc = BitOR(0x00002000, 0x00001000)
Local $pMemory = _MemVirtualAllocEx($hProcess, 0, $iSize, $iAlloc, 0x00000004)
If $pMemory = 0 Then Return SetError(2, 0, 0)
$tMemMap = DllStructCreate($tagMEMMAP)
DllStructSetData($tMemMap, "hProc", $hProcess)
DllStructSetData($tMemMap, "Size", $iSize)
DllStructSetData($tMemMap, "Mem", $pMemory)
Return $pMemory
EndFunc
Func _MemWrite(ByRef $tMemMap, $pSrce, $pDest = 0, $iSize = 0, $sSrce = "struct*")
If $pDest = 0 Then $pDest = DllStructGetData($tMemMap, "Mem")
If $iSize = 0 Then $iSize = DllStructGetData($tMemMap, "Size")
Local $aResult = DllCall("kernel32.dll", "bool", "WriteProcessMemory", "handle", DllStructGetData($tMemMap, "hProc"), "ptr", $pDest, $sSrce, $pSrce, "ulong_ptr", $iSize, "ulong_ptr*", 0)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _MemVirtualAllocEx($hProcess, $pAddress, $iSize, $iAllocation, $iProtect)
Local $aResult = DllCall("kernel32.dll", "ptr", "VirtualAllocEx", "handle", $hProcess, "ptr", $pAddress, "ulong_ptr", $iSize, "dword", $iAllocation, "dword", $iProtect)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _MemVirtualFreeEx($hProcess, $pAddress, $iSize, $iFreeType)
Local $aResult = DllCall("kernel32.dll", "bool", "VirtualFreeEx", "handle", $hProcess, "ptr", $pAddress, "ulong_ptr", $iSize, "dword", $iFreeType)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func __Mem_OpenProcess($iAccess, $bInherit, $iPID, $bDebugPriv = False)
Local $aResult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $bInherit, "dword", $iPID)
If @error Then Return SetError(@error, @extended, 0)
If $aResult[0] Then Return $aResult[0]
If Not $bDebugPriv Then Return SetError(100, 0, 0)
Local $hToken = _Security__OpenThreadTokenEx(BitOR(0x00000020, 0x00000008))
If @error Then Return SetError(@error + 10, @extended, 0)
_Security__SetPrivilege($hToken, "SeDebugPrivilege", True)
Local $iError = @error
Local $iExtended = @extended
Local $iRet = 0
If Not @error Then
$aResult = DllCall("kernel32.dll", "handle", "OpenProcess", "dword", $iAccess, "bool", $bInherit, "dword", $iPID)
$iError = @error
$iExtended = @extended
If $aResult[0] Then $iRet = $aResult[0]
_Security__SetPrivilege($hToken, "SeDebugPrivilege", False)
If @error Then
$iError = @error + 20
$iExtended = @extended
EndIf
Else
$iError = @error + 30
EndIf
DllCall("kernel32.dll", "bool", "CloseHandle", "handle", $hToken)
Return SetError($iError, $iExtended, $iRet)
EndFunc
Func _SendMessage($hWnd, $iMsg, $wParam = 0, $lParam = 0, $iReturn = 0, $wParamType = "wparam", $lParamType = "lparam", $sReturnType = "lresult")
Local $aResult = DllCall("user32.dll", $sReturnType, "SendMessageW", "hwnd", $hWnd, "uint", $iMsg, $wParamType, $wParam, $lParamType, $lParam)
If @error Then Return SetError(@error, @extended, "")
If $iReturn >= 0 And $iReturn <= 4 Then Return $aResult[$iReturn]
Return $aResult
EndFunc
Global Const $__STATUSBARCONSTANT_WM_USER = 0X400
Global Const $SB_GETUNICODEFORMAT = 0x2000 + 6
Global Const $SB_ISSIMPLE =($__STATUSBARCONSTANT_WM_USER + 14)
Global Const $SB_SETPARTS =($__STATUSBARCONSTANT_WM_USER + 4)
Global Const $SB_SETTEXTA =($__STATUSBARCONSTANT_WM_USER + 1)
Global Const $SB_SETTEXTW =($__STATUSBARCONSTANT_WM_USER + 11)
Global Const $SB_SETTEXT = $SB_SETTEXTA
Global Const $SB_SIMPLEID = 0xff
Global $__g_aUDF_GlobalIDs_Used[16][55535 + 2 + 1]
Func __UDF_GetNextGlobalID($hWnd)
Local $nCtrlID, $iUsedIndex = -1, $bAllUsed = True
If Not WinExists($hWnd) Then Return SetError(-1, -1, 0)
For $iIndex = 0 To 16 - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] <> 0 Then
If Not WinExists($__g_aUDF_GlobalIDs_Used[$iIndex][0]) Then
For $x = 0 To UBound($__g_aUDF_GlobalIDs_Used, 2) - 1
$__g_aUDF_GlobalIDs_Used[$iIndex][$x] = 0
Next
$__g_aUDF_GlobalIDs_Used[$iIndex][1] = 10000
$bAllUsed = False
EndIf
EndIf
Next
For $iIndex = 0 To 16 - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] = $hWnd Then
$iUsedIndex = $iIndex
ExitLoop
EndIf
Next
If $iUsedIndex = -1 Then
For $iIndex = 0 To 16 - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] = 0 Then
$__g_aUDF_GlobalIDs_Used[$iIndex][0] = $hWnd
$__g_aUDF_GlobalIDs_Used[$iIndex][1] = 10000
$bAllUsed = False
$iUsedIndex = $iIndex
ExitLoop
EndIf
Next
EndIf
If $iUsedIndex = -1 And $bAllUsed Then Return SetError(16, 0, 0)
If $__g_aUDF_GlobalIDs_Used[$iUsedIndex][1] = 10000 + 55535 Then
For $iIDIndex = 2 To UBound($__g_aUDF_GlobalIDs_Used, 2) - 1
If $__g_aUDF_GlobalIDs_Used[$iUsedIndex][$iIDIndex] = 0 Then
$nCtrlID =($iIDIndex - 2) + 10000
$__g_aUDF_GlobalIDs_Used[$iUsedIndex][$iIDIndex] = $nCtrlID
Return $nCtrlID
EndIf
Next
Return SetError(-1, 55535, 0)
EndIf
$nCtrlID = $__g_aUDF_GlobalIDs_Used[$iUsedIndex][1]
$__g_aUDF_GlobalIDs_Used[$iUsedIndex][1] += 1
$__g_aUDF_GlobalIDs_Used[$iUsedIndex][($nCtrlID - 10000) + 2] = $nCtrlID
Return $nCtrlID
EndFunc
Func __UDF_FreeGlobalID($hWnd, $iGlobalID)
If $iGlobalID - 10000 < 0 Or $iGlobalID - 10000 > 55535 Then Return SetError(-1, 0, False)
For $iIndex = 0 To 16 - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][0] = $hWnd Then
For $x = 2 To UBound($__g_aUDF_GlobalIDs_Used, 2) - 1
If $__g_aUDF_GlobalIDs_Used[$iIndex][$x] = $iGlobalID Then
$__g_aUDF_GlobalIDs_Used[$iIndex][$x] = 0
Return True
EndIf
Next
Return SetError(-3, 0, False)
EndIf
Next
Return SetError(-2, 0, False)
EndFunc
Global $__g_aInProcess_WinAPI[64][2] = [[0, 0]]
Func _WinAPI_CreateWindowEx($iExStyle, $sClass, $sName, $iStyle, $iX, $iY, $iWidth, $iHeight, $hParent, $hMenu = 0, $hInstance = 0, $pParam = 0)
If $hInstance = 0 Then $hInstance = _WinAPI_GetModuleHandle("")
Local $aResult = DllCall("user32.dll", "hwnd", "CreateWindowExW", "dword", $iExStyle, "wstr", $sClass, "wstr", $sName, "dword", $iStyle, "int", $iX, "int", $iY, "int", $iWidth, "int", $iHeight, "hwnd", $hParent, "handle", $hMenu, "handle", $hInstance, "struct*", $pParam)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_DestroyWindow($hWnd)
Local $aResult = DllCall("user32.dll", "bool", "DestroyWindow", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, False)
Return $aResult[0]
EndFunc
Func _WinAPI_GetClassName($hWnd)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $aResult = DllCall("user32.dll", "int", "GetClassNameW", "hwnd", $hWnd, "wstr", "", "int", 4096)
If @error Or Not $aResult[0] Then Return SetError(@error, @extended, '')
Return SetExtended($aResult[0], $aResult[2])
EndFunc
Func _WinAPI_GetParent($hWnd)
Local $aResult = DllCall("user32.dll", "hwnd", "GetParent", "hwnd", $hWnd)
If @error Then Return SetError(@error, @extended, 0)
Return $aResult[0]
EndFunc
Func _WinAPI_GetWindowThreadProcessId($hWnd, ByRef $iPID)
Local $aResult = DllCall("user32.dll", "dword", "GetWindowThreadProcessId", "hwnd", $hWnd, "dword*", 0)
If @error Then Return SetError(@error, @extended, 0)
$iPID = $aResult[2]
Return $aResult[0]
EndFunc
Func _WinAPI_InProcess($hWnd, ByRef $hLastWnd)
If $hWnd = $hLastWnd Then Return True
For $iI = $__g_aInProcess_WinAPI[0][0] To 1 Step -1
If $hWnd = $__g_aInProcess_WinAPI[$iI][0] Then
If $__g_aInProcess_WinAPI[$iI][1] Then
$hLastWnd = $hWnd
Return True
Else
Return False
EndIf
EndIf
Next
Local $iPID
_WinAPI_GetWindowThreadProcessId($hWnd, $iPID)
Local $iCount = $__g_aInProcess_WinAPI[0][0] + 1
If $iCount >= 64 Then $iCount = 1
$__g_aInProcess_WinAPI[0][0] = $iCount
$__g_aInProcess_WinAPI[$iCount][0] = $hWnd
$__g_aInProcess_WinAPI[$iCount][1] =($iPID = @AutoItPID)
Return $__g_aInProcess_WinAPI[$iCount][1]
EndFunc
Func _WinAPI_IsClassName($hWnd, $sClassName)
Local $sSeparator = Opt("GUIDataSeparatorChar")
Local $aClassName = StringSplit($sClassName, $sSeparator)
If Not IsHWnd($hWnd) Then $hWnd = GUICtrlGetHandle($hWnd)
Local $sClassCheck = _WinAPI_GetClassName($hWnd)
For $x = 1 To UBound($aClassName) - 1
If StringUpper(StringMid($sClassCheck, 1, StringLen($aClassName[$x]))) = StringUpper($aClassName[$x]) Then Return True
Next
Return False
EndFunc
Global $__g_hSBLastWnd
Global Const $__STATUSBARCONSTANT_ClassName = "msctls_statusbar32"
Func _GUICtrlStatusBar_Create($hWnd, $vPartEdge = -1, $vPartText = "", $iStyles = -1, $iExStyles = 0x00000000)
If Not IsHWnd($hWnd) Then Return SetError(1, 0, 0)
Local $iStyle = BitOR(0x40000000, 0x10000000)
If $iStyles = -1 Then $iStyles = 0x00000000
If $iExStyles = -1 Then $iExStyles = 0x00000000
Local $aPartWidth[1], $aPartText[1]
If @NumParams > 1 Then
If IsArray($vPartEdge) Then
$aPartWidth = $vPartEdge
Else
$aPartWidth[0] = $vPartEdge
EndIf
If @NumParams = 2 Then
ReDim $aPartText[UBound($aPartWidth)]
Else
If IsArray($vPartText) Then
$aPartText = $vPartText
Else
$aPartText[0] = $vPartText
EndIf
If UBound($aPartWidth) <> UBound($aPartText) Then
Local $iLast
If UBound($aPartWidth) > UBound($aPartText) Then
$iLast = UBound($aPartText)
ReDim $aPartText[UBound($aPartWidth)]
Else
$iLast = UBound($aPartWidth)
ReDim $aPartWidth[UBound($aPartText)]
For $x = $iLast To UBound($aPartWidth) - 1
$aPartWidth[$x] = $aPartWidth[$x - 1] + 75
Next
$aPartWidth[UBound($aPartText) - 1] = -1
EndIf
EndIf
EndIf
If Not IsHWnd($hWnd) Then $hWnd = HWnd($hWnd)
If @NumParams > 3 Then $iStyle = BitOR($iStyle, $iStyles)
EndIf
Local $nCtrlID = __UDF_GetNextGlobalID($hWnd)
If @error Then Return SetError(@error, @extended, 0)
Local $hWndSBar = _WinAPI_CreateWindowEx($iExStyles, $__STATUSBARCONSTANT_ClassName, "", $iStyle, 0, 0, 0, 0, $hWnd, $nCtrlID)
If @error Then Return SetError(@error, @extended, 0)
If @NumParams > 1 Then
_GUICtrlStatusBar_SetParts($hWndSBar, UBound($aPartWidth), $aPartWidth)
For $x = 0 To UBound($aPartText) - 1
_GUICtrlStatusBar_SetText($hWndSBar, $aPartText[$x], $x)
Next
EndIf
Return $hWndSBar
EndFunc
Func _GUICtrlStatusBar_Destroy(ByRef $hWnd)
If Not _WinAPI_IsClassName($hWnd, $__STATUSBARCONSTANT_ClassName) Then Return SetError(2, 2, False)
Local $iDestroyed = 0
If IsHWnd($hWnd) Then
If _WinAPI_InProcess($hWnd, $__g_hSBLastWnd) Then
Local $nCtrlID = _WinAPI_GetDlgCtrlID($hWnd)
Local $hParent = _WinAPI_GetParent($hWnd)
$iDestroyed = _WinAPI_DestroyWindow($hWnd)
Local $iRet = __UDF_FreeGlobalID($hParent, $nCtrlID)
If Not $iRet Then
EndIf
Else
Return SetError(1, 1, False)
EndIf
EndIf
If $iDestroyed Then $hWnd = 0
Return $iDestroyed <> 0
EndFunc
Func _GUICtrlStatusBar_GetUnicodeFormat($hWnd)
Return _SendMessage($hWnd, $SB_GETUNICODEFORMAT) <> 0
EndFunc
Func _GUICtrlStatusBar_IsSimple($hWnd)
Return _SendMessage($hWnd, $SB_ISSIMPLE) <> 0
EndFunc
Func _GUICtrlStatusBar_Resize($hWnd)
_SendMessage($hWnd, 0x05)
EndFunc
Func _GUICtrlStatusBar_SetParts($hWnd, $vPartEdge = -1, $vPartWidth = 25)
If IsArray($vPartEdge) And IsArray($vPartWidth) Then Return False
Local $tParts, $iParts
If IsArray($vPartEdge) Then
$vPartEdge[UBound($vPartEdge) - 1] = -1
$iParts = UBound($vPartEdge)
$tParts = DllStructCreate("int[" & $iParts & "]")
For $x = 0 To $iParts - 2
DllStructSetData($tParts, 1, $vPartEdge[$x], $x + 1)
Next
DllStructSetData($tParts, 1, -1, $iParts)
Else
If $vPartEdge < -1 Then Return False
If IsArray($vPartWidth) Then
$iParts = UBound($vPartWidth)
$tParts = DllStructCreate("int[" & $iParts & "]")
Local $iPartRightEdge = 0
For $x = 0 To $iParts - 2
$iPartRightEdge += $vPartWidth[$x]
If $vPartWidth[$x] <= 0 Then Return False
DllStructSetData($tParts, 1, $iPartRightEdge, $x + 1)
Next
DllStructSetData($tParts, 1, -1, $iParts)
ElseIf $vPartEdge > 1 Then
$iParts = $vPartEdge
$tParts = DllStructCreate("int[" & $iParts & "]")
For $x = 1 To $iParts - 1
DllStructSetData($tParts, 1, $vPartWidth * $x, $x)
Next
DllStructSetData($tParts, 1, -1, $iParts)
Else
$iParts = 1
$tParts = DllStructCreate("int")
DllStructSetData($tParts, 1, -1)
EndIf
EndIf
If _WinAPI_InProcess($hWnd, $__g_hSBLastWnd) Then
_SendMessage($hWnd, $SB_SETPARTS, $iParts, $tParts, 0, "wparam", "struct*")
Else
Local $iSize = DllStructGetSize($tParts)
Local $tMemMap
Local $pMemory = _MemInit($hWnd, $iSize, $tMemMap)
_MemWrite($tMemMap, $tParts)
_SendMessage($hWnd, $SB_SETPARTS, $iParts, $pMemory, 0, "wparam", "ptr")
_MemFree($tMemMap)
EndIf
_GUICtrlStatusBar_Resize($hWnd)
Return True
EndFunc
Func _GUICtrlStatusBar_SetText($hWnd, $sText = "", $iPart = 0, $iUFlag = 0)
Local $bUnicode = _GUICtrlStatusBar_GetUnicodeFormat($hWnd)
Local $iBuffer = StringLen($sText) + 1
Local $tText
If $bUnicode Then
$tText = DllStructCreate("wchar Text[" & $iBuffer & "]")
$iBuffer *= 2
Else
$tText = DllStructCreate("char Text[" & $iBuffer & "]")
EndIf
DllStructSetData($tText, "Text", $sText)
If _GUICtrlStatusBar_IsSimple($hWnd) Then $iPart = $SB_SIMPLEID
Local $iRet
If _WinAPI_InProcess($hWnd, $__g_hSBLastWnd) Then
$iRet = _SendMessage($hWnd, $SB_SETTEXTW, BitOR($iPart, $iUFlag), $tText, 0, "wparam", "struct*")
Else
Local $tMemMap
Local $pMemory = _MemInit($hWnd, $iBuffer, $tMemMap)
_MemWrite($tMemMap, $tText)
If $bUnicode Then
$iRet = _SendMessage($hWnd, $SB_SETTEXTW, BitOR($iPart, $iUFlag), $pMemory, 0, "wparam", "ptr")
Else
$iRet = _SendMessage($hWnd, $SB_SETTEXT, BitOR($iPart, $iUFlag), $pMemory, 0, "wparam", "ptr")
EndIf
_MemFree($tMemMap)
EndIf
Return $iRet <> 0
EndFunc
Global Const $WS_CAPTION = 0x00C00000
Func CloseServiceHandle($hSCObject)
Local $avCSH = DllCall( "advapi32.dll", "int", "CloseServiceHandle", "hwnd", $hSCObject )
Return $avCSH[0]
EndFunc
Func ControlService($hService, $iControl)
Local $avCS = DllCall("advapi32.dll", "int", "ControlService", "hwnd", $hService, "dword", $iControl, "str", "")
Return $avCS[0]
EndFunc
Func GetLastError()
Local $aiE = DllCall("kernel32.dll", "dword", "GetLastError")
Return $aiE[0]
EndFunc
Func OpenService($hSC, $sServiceName, $iAccess)
Local $avOS = DllCall("advapi32.dll", "hwnd", "OpenService", "hwnd", $hSC, "str", $sServiceName, "dword", $iAccess)
Return $avOS[0]
EndFunc
Func _SCMStartup($sHostname = "")
Local Const $SC_MANAGER_CONNECT = 0x0001
Local $avOSCM = DllCall("advapi32.dll", "hwnd", "OpenSCManager", "str", $sHostname, "str", "ServicesActive", "dword", $SC_MANAGER_CONNECT)
Return $avOSCM[0]
EndFunc
Func _SCMShutdown($hSCHandle)
Local $avCSH = DllCall("advapi32.dll", "int", "CloseServiceHandle", "hwnd", $hSCHandle)
Return $avCSH[0]
EndFunc
Func _ServiceContinue($hSCHandle, $sService)
Local $hService, $iCSR, $iCSRE
If StringInStr($sService, " ") Then $sService = '"' & $sService & '"'
$hService = OpenService($hSCHandle, $sService, 0x0040)
$iCSR = ControlService($hService, 0x00000003)
If $iCSR = 0 Then $iCSRE = GetLastError()
CloseServiceHandle($hService)
Return SetError($iCSRE, 0, $iCSR)
EndFunc
Func _ServicePause($hSCHandle, $sService)
Local $hService, $iCSP, $iCSPE
If StringInStr($sService, " ") Then $sService = '"' & $sService & '"'
$hService = OpenService($hSCHandle, $sService, 0x0040)
$iCSP = ControlService($hService, 0x00000002)
If $iCSP = 0 Then $iCSPE = GetLastError()
CloseServiceHandle($hService)
Return SetError($iCSPE, 0, $iCSP)
EndFunc
Func _ServiceStart($hSCHandle, $sService)
Local $hService, $avSS, $iSS
If StringInStr($sService, " ") Then $sService = '"' & $sService & '"'
$hService = OpenService($hSCHandle, $sService, 0x0010)
$avSS = DllCall("advapi32.dll", "int", "StartService", "hwnd", $hService, "dword", 0, "ptr", 0)
If $avSS[0] = 0 Then $iSS = GetLastError()
CloseServiceHandle($hService)
Return SetError($iSS, 0, $avSS[0])
EndFunc
Func _ServiceStop($hSCHandle, $sService)
Local $hService, $iCSS, $iCSSE
If StringInStr($sService, " ") Then $sService = '"' & $sService & '"'
$hService = OpenService($hSCHandle, $sService, 0x0020)
$iCSS = ControlService($hService, 0x00000001)
If $iCSS = 0 Then $iCSSE = GetLastError()
CloseServiceHandle($hService)
Return SetError($iCSSE, 0, $iCSS)
EndFunc
Opt("WinTitleMatchMode", 4)
Main()
Func Main()
Local $sVersion = "1.3.0"
Local $aStatusSize[2] = [75, -1]
Local $bSuspended = False
Local $hActive, $hLastActive
Local $hFreezeTimer, $bThawing = False, $hThawTimer
Local $aServicesSnapshot
Local $aProcessExclusions[0], $aServicesExclusions[0]
Local $hState = _GetStateFile()
FileSetAttrib(".frozen", "-H")
Switch $hState
Case False
Case True
If IsString($hState) Then ContinueCase
If MsgBox(4+48+0x00040000, "State File could not be read", "A previous unthawed session was detected but its details could not be read. " & "This may cause issues with freezing or thawing. Please delete the '.frozen' file or run the application as an administrator to resolve. " & "Would you like to continue?") = 6 Then
Else
Exit 1
EndIf
Case Else
Switch MsgBox(3+32+0x00040000, "Previous Session Exists", "A previous unthawed session from " & $hState & " was found." & @CRLF & @CRLF & "Would you like to thaw it?" & @CRLF & "The session will be deleted to prevent conflicts." & @CRLF & "To exit immediately and take other action, choose Cancel.")
Case 6
If FileReadLine(".frozen", 2) = "True" Then
$aServicesSnapshot = _ReadStateFile()
If $aServicesSnapshot = False Then
MsgBox(0+16+0x00040000, "State File could not be recovered", "Unable to recover previous system state. A computer reboot is highly recommended.")
Exit 1
Else
_ThawFromStock("", True, $aServicesSnapshot, False, "")
_ThawFromStock("", True, $aServicesSnapshot, True, "")
EndIf
Else
_ThawFromStock("", False, "", False, "")
EndIf
Case 7
_RemoveStateFile()
Case 2
Exit 1
EndSwitch
EndSwitch
Local $hGUI = GUICreate("FreezeToStock", 320, 240, -1, -1, BitOr(0x00020000, $WS_CAPTION, 0x00080000))
Local $hFile = GUICtrlCreateMenu("File")
Local $hExport = GUICtrlCreateMenuItem("Export", $hFile)
GUICtrlCreateMenuItem("", $hFile)
Local $hQuit = GUICtrlCreateMenuItem("Quit", $hFile)
Local $hExclude = GUICtrlCreateMenu("Exclusions")
Local $hAntiCheat = GUICtrlCreateMenu("Anti-Cheats", $hExclude)
Local $hBE = GUICtrlCreateMenuItem("BattlEye", $hAntiCheat)
Local $hEAC = GUICtrlCreateMenuItem("EasyAntiCheat", $hAntiCheat)
Local $hBroadcasters = GUICtrlCreateMenu("Broadcasters", $hExclude)
Local $hAMD = GUICtrlCreateMenuItem("AMD ReLive", $hBroadcasters)
Local $hNvidia = GUICtrlCreateMenuItem("Nvidia ShadowPlay", $hBroadcasters)
Local $hOBS = GUICtrlCreateMenuItem("OBS", $hBroadcasters)
Local $hSLOBS = GUICtrlCreateMenuItem("StreamLabs OBS", $hBroadcasters)
Local $hVMix = GUICtrlCreateMenuItem("VMix", $hBroadcasters)
Local $hWirecast = GUICtrlCreateMenuItem("Wirecast", $hBroadcasters)
Local $hWinDVR = GUICtrlCreateMenuItem("Windows DVR", $hBroadcasters)
Local $hXSplit = GUICtrlCreateMenuItem("XSplit", $hBroadcasters)
Local $hBrowsers = GUICtrlCreateMenu("Browsers", $hExclude)
Local $hChrome = GUICtrlCreateMenuItem("Chrome", $hBrowsers)
Local $hEdge = GUICtrlCreateMenuItem("Edge (New)", $hBrowsers)
Local $hFirefox = GUICtrlCreateMenuItem("Firefox", $hBrowsers)
Local $hMSIE = GUICtrlCreateMenuItem("IE", $hBrowsers)
Local $hOpera = GUICtrlCreateMenuItem("Opera", $hBrowsers)
Local $hPale = GUICtrlCreateMenuItem("Pale Moon", $hBrowsers)
Local $hHardware = GUICtrlCreateMenu("Hardware", $hExclude)
Local $hCorsiar = GUICtrlCreateMenuItem("Corsair iCUE", $hHardware)
Local $hLogi = GUICtrlCreateMenuItem("Logitech", $hHardware)
Local $hMSMK = GUICtrlCreateMenuItem("Microsft Mouse && Keyboard", $hHardware)
Local $hLaunchers = GUICtrlCreateMenu("Launchers", $hExclude)
Local $hEpik = GUICtrlCreateMenuItem("Epic Games", $hLaunchers)
Local $hParsec = GUICtrlCreateMenuItem("Parsec", $hLaunchers)
Local $hSteam = GUICtrlCreateMenuItem("Steam", $hLaunchers)
Local $hHTCVP = GUICtrlCreateMenuItem("VivePort", $hLaunchers)
Local $hXbox = GUICtrlCreateMenuItem("Xbox", $hLaunchers)
Local $hSocial = GUICtrlCreateMenu("Social", $hExclude)
Local $hDiscord = GUICtrlCreateMenuItem("Discord", $hSocial)
Local $hTelegram = GUICtrlCreateMenuItem("Telegram", $hSocial)
Local $hTools = GUICtrlCreateMenu("Tools", $hExclude)
Local $hMSPT = GUICtrlCreateMenuItem("Microsoft Powertoys", $hTools)
Local $hNBFC = GUICtrlCreateMenuItem("NoteBook FanControl", $hTools)
Local $hTStop = GUICtrlCreateMenuItem("ThrottleStop", $hTools)
Local $hVirtualR = GUICtrlCreateMenu("Virtual Reality", $hExclude)
Local $hOculus = GUICtrlCreateMenuItem("Oculus", $hVirtualR)
Local $hSteamVR = GUICtrlCreateMenuItem("SteamVR (+ HTC)", $hVirtualR)
Local $hWinMR = GUICtrlCreateMenuItem("Windows Mixed Reality", $hVirtualR)
GUICtrlCreateMenuItem("", $hExclude)
Local $hCustom = GUICtrlCreateMenu("Custom", $hExclude)
Local $hAddCustom = GUICtrlCreateMenuItem("Add Custom", $hCustom)
Local $hNewCustom = GUICtrlCreateMenuItem("Create Custom", $hCustom)
GUICtrlSetState(-1, 128)
Local $hRemCustom = GUICtrlCreateMenuItem("Remove Custom", $hCustom)
Local $hHelp = GUICtrlCreateMenu("Help")
Local $hGithub = GUICtrlCreateMenuItem("Github", $hHelp)
Local $hDisWeb = GUICtrlCreateMenuItem("Discord", $hHelp)
GUICtrlCreateMenuItem("", $hHelp)
Local $hDonate = GUICtrlCreateMenuItem("Donate", $hHelp)
GUICtrlCreateMenuItem("", $hHelp)
Local $hUpdate = GUICtrlCreateMenuItem("Update", $hHelp)
GUICtrlCreateGroup("Options", 5, 5, 310, 190)
Local $hToggle = GUICtrlCreateButton(" FREEZE SYSTEM", 10, 20, 300, 60)
GUICtrlSetFont(-1, 20)
If @Compiled Then
GUICtrlSetImage(-1, @ScriptFullPath, 201, 1)
Else
GUICtrlSetImage(-1, ".\Includes\freeze_small.ico", -1, 1)
EndIf
Local $hServices = GUICtrlCreateCheckbox("Freeze Services as well as Processes", 12, 85, 296, 15)
GUICtrlSetTip(-1, "This Pauses known unneeded System Services")
GUICtrlCreateLabel(Chrw(9625), 12, 100, 15, 15, 0x1)
GUICtrlSetState(-1, 128)
Local $hAggressive = GUICtrlCreateCheckbox("Stop Services instead of just Pausing", 27, 100, 286, 15)
GUICtrlSetState(-1, 128)
GUICtrlSetTip(-1, "This will give stronger results for lower powered devices," & @CRLF & "Services will automatically be restarted for you.")
Local $hThawTop = GUICtrlCreateCheckbox("Dynamically Thaw Active Window (Coming Soon)", 12, 120, 296, 15)
GUICtrlSetState(-1, 128)
GUICtrlCreateLabel(Chrw(9625), 12, 135, 15, 15, 0x1)
GUICtrlSetState(-1, 128)
Local $hReFreeze = GUICtrlCreateCheckbox("Refreeze Inactive Thawed Windows", 27, 135, 286, 15)
GUICtrlSetState(-1, 128)
Local $hThawCycle = GUICtrlCreateCheckbox("Periodically Thaw Frozen Processes", 12, 155, 296, 15)
GUICtrlSetTip(-1, "This allows frozen processes to process any pending data")
GUICtrlCreateLabel(Chrw(9625), 12, 170, 15, 15, 0x1)
GUICtrlCreateLabel("Every", 27, 171, 30, 15)
Local $hCycle = GUICtrlCreateInput("60", 57, 170, 40, 15, 2048)
GUICtrlCreateUpdown(-1,0x0020+0x0002)
GUICtrlSetLimit(-1, 360, 1)
GUICtrlCreateLabel("Minute(s) for", 101, 171, 60, 15)
Local $hPeriod = GUICtrlCreateInput("5", 165, 170, 40, 15, 2048)
GUICtrlCreateUpdown(-1,0x0020+0x0002)
GUICtrlSetLimit(-1, 60, 5)
GUICtrlCreateLabel("Seconds", 206, 171, 45, 15)
For $iLoop = 1 To 8 Step 1
GUICtrlSetState($hThawCycle + $iLoop, 128)
GUICtrlSetTip($hThawCycle + $iLoop, "How often to thaw processes and for how long, " & @CRLF & "This setting can be modified during Freeze.")
Next
$hStatus = _GUICtrlStatusBar_Create($hGUI, $aStatusSize)
GUISetState(@SW_SHOW, $hGUI)
While 1
$hMsg = GUIGetMsg()
If $bSuspended And _IsChecked($hThawTop) Then
$hActive = WinActive("[ACTIVE]")
If Not $hActive = $hLastActive Then
_ProcessResume(WinGetProcess($hActive))
$hLastActive = $hActive
EndIf
EndIf
If $bSuspended And _IsChecked($hThawCycle) Then
If $bThawing Then
If TimerDiff($hThawTimer) >= GUICtrlRead($hPeriod) * 1000 Then
_FreezeToStock($aProcessExclusions, _IsChecked($hServices), $aServicesExclusions, _IsChecked($hAggressive), $hStatus)
$bThawing = False
$hFreezeTimer = TimerInit()
EndIf
ElseIf TimerDiff($hFreezeTimer) >= GUICtrlRead($hCycle) * 60000 Then
_ThawFromStock($aProcessExclusions, _IsChecked($hServices), $aServicesSnapshot, _IsChecked($hAggressive), $hStatus)
$bThawing = True
$hThawTimer = TimerInit()
EndIf
EndIf
Switch $hMsg
Case -3
_GUICtrlStatusBar_Destroy($hGUI)
GUIDelete($hGUI)
Exit
Case $hExport
FileDelete(".\export.csv")
FileWrite(".\export.csv", "[Processes]" & @CRLF)
FileWrite(".\export.csv", _ArrayToString(ProcessList(), ",") & @CRLF)
FileWrite(".\export.csv", "[SERVICES]" & @CRLF)
FileWrite(".\export.csv", _ArrayToString(_ServicesList(), ",") & @CRLF)
Case $hBE, $hEAC, $hAMD To $hXSplit, $hChrome to $hPale, $hCorsiar to $hMSMK, $hEpik to $hXbox, $hDiscord to $hTelegram, $hMSPT to $hTStop, $hOculus To $hWinMR
If _IsChecked($hMsg) Then
GUICtrlSetState($hMsg, 4)
Switch $hMsg
Case $hBE
_ArrayRemove($aProcessExclusions, "BEService.exe")
_ArrayRemove($aServicesExclusions, "BEService")
Case $hEAC
_ArrayRemove($aProcessExclusions, "EasyAntiCheat.exe")
_ArrayRemove($aServicesExclusions, "EasyAntiCheat")
Case $hAMD
_ArrayRemove($aProcessExclusions, "RadeonSoftware.exe")
_ArrayRemove($aProcessExclusions, "FacebookClient.exe")
_ArrayRemove($aProcessExclusions, "GfycatWrapper.exe")
_ArrayRemove($aProcessExclusions, "QuanminTVWrapper.exe")
_ArrayRemove($aProcessExclusions, "RestreamAPIWrapper.exe")
_ArrayRemove($aProcessExclusions, "SinaWeiboWrapper.exe")
_ArrayRemove($aProcessExclusions, "StreamableAPIWrapper.exe")
_ArrayRemove($aProcessExclusions, "TwitchClient.exe")
_ArrayRemove($aProcessExclusions, "TwitterWrapperClient.exe")
_ArrayRemove($aProcessExclusions, "YoukuWrapper.exe")
_ArrayRemove($aProcessExclusions, "YoutubeAPIWrapper.exe")
Case $hNvidia
_ArrayRemove($aProcessExclusions, "nvcontainer.exe")
_ArrayRemove($aProcessExclusions, "nvscaphelper.exe")
_ArrayRemove($aProcessExclusions, "nvsphelper.exe")
_ArrayRemove($aProcessExclusions, "nvsphelper64.exe")
_ArrayRemove($aProcessExclusions, "GFExperience.exe")
Case $hOBS
_ArrayRemove($aProcessExclusions, "obs.exe")
_ArrayRemove($aProcessExclusions, "obs32.exe")
_ArrayRemove($aProcessExclusions, "obs64.exe")
_ArrayRemove($aProcessExclusions, "obs-ffmpeg-mux.exe")
Case $hSLOBS
_ArrayRemove($aProcessExclusions, "Streamlabs OBS.exe")
_ArrayRemove($aProcessExclusions, "obs32.exe")
_ArrayRemove($aProcessExclusions, "obs64.exe")
_ArrayRemove($aProcessExclusions, "obs-ffmpeg-mux.exe")
Case $hVMix
_ArrayRemove($aProcessExclusions, "vMixService.exe")
_ArrayRemove($aProcessExclusions, "vMix.exe")
_ArrayRemove($aProcessExclusions, "vMix64.exe")
_ArrayRemove($aProcessExclusions, "vMixDesktopCapture.exe")
_ArrayRemove($aProcessExclusions, "vMixNDIHelper.exe")
_ArrayRemove($aProcessExclusions, "ffmpeg.exe")
_ArrayRemove($aServicesExclusions, "vMixService")
Case $hWirecast
_ArrayRemove($aProcessExclusions, "CEFChildProcess.exe")
_ArrayRemove($aProcessExclusions, "Wirecast.exe")
_ArrayRemove($aProcessExclusions, "wirecastd.exe")
Case $hWinDVR
_ArrayRemove($aServicesExclusions, "BcastDVRUserService")
Case $hXSplit
_ArrayRemove($aProcessExclusions, "XGS32.exe")
_ArrayRemove($aProcessExclusions, "XGS64.exe")
_ArrayRemove($aProcessExclusions, "XSplit.Core.exe")
_ArrayRemove($aProcessExclusions, "XSplit.xbcbp.exe")
Case $hChrome
_ArrayRemove($aProcessExclusions, "chrome.exe")
Case $hEdge
_ArrayRemove($aProcessExclusions, "msedge.exe")
Case $hFirefox
_ArrayRemove($aProcessExclusions, "firefox.exe")
Case $hMSIE
_ArrayRemove($aProcessExclusions, "iexplore.exe")
Case $hOpera
_ArrayRemove($aProcessExclusions, "opera.exe")
Case $hPale
_ArrayRemove($aProcessExclusions, "palemoon.exe")
_ArrayRemove($aProcessExclusions, "plugin-container.exe")
_ArrayRemove($aProcessExclusions, "plugin-hang-ui.exe")
Case $hCorsiar
_ArrayRemove($aProcessExclusions, "Corsair.Service.CpuIdRemote64.exe")
_ArrayRemove($aProcessExclusions, "Corsair.Service.DisplayAdapter.exe")
_ArrayRemove($aProcessExclusions, "Corsair.Service.exe")
_ArrayRemove($aProcessExclusions, "CorsairGamingAudioCfgService64.exe")
_ArrayRemove($aServicesExclusions, "CorsairGamingAudioConfig")
_ArrayRemove($aServicesExclusions, "CorsairLLAService")
_ArrayRemove($aServicesExclusions, "CorsairService")
Case $hLogi
_ArrayRemove($aProcessExclusions, "KHALMNPR.exe")
_ArrayRemove($aProcessExclusions, "SetPoint.exe")
Case $hMSMK
_ArrayRemove($aProcessExclusions, "MKCHelper.exe")
_ArrayRemove($aProcessExclusions, "ipoint.exe")
_ArrayRemove($aProcessExclusions, "itype.exe")
Case $hEpik
_ArrayRemove($aProcessExclusions, "EpicGamesLauncher.exe")
Case $hParsec
_ArrayRemove($aProcessExclusions, "pservice.exe")
_ArrayRemove($aProcessExclusions, "parsecd.exe")
_ArrayRemove($aServicesExclusions, "Parsec")
Case $hSteam
_ArrayRemove($aProcessExclusions, "Steam.exe")
_ArrayRemove($aProcessExclusions, "SteamService.exe")
_ArrayRemove($aProcessExclusions, "steamwebhelper.exe")
_ArrayRemove($aServicesExclusions, "Steam Client Service")
Case $hHTCVP
_ArrayRemove($aProcessExclusions, "ViveportDesktopService.exe")
_ArrayRemove($aServicesExclusions, "ViveportDesktopService")
Case $hXbox
_ArrayRemove($aServicesExclusions, "XboxGipSvc")
_ArrayRemove($aServicesExclusions, "XblAuthManager")
_ArrayRemove($aServicesExclusions, "XblGameSave")
_ArrayRemove($aServicesExclusions, "XboxNetApiSvc")
Case $hDiscord
_ArrayRemove($aProcessExclusions, "Discord.exe")
Case $hTelegram
_ArrayRemove($aProcessExclusions, "Telegram.exe")
Case $hMSPT
_ArrayRemove($aProcessExclusions, "PowerToys.exe")
_ArrayRemove($aProcessExclusions, "PowerToysSettings.exe")
_ArrayRemove($aProcessExclusions, "ColorPicker.exe")
_ArrayRemove($aProcessExclusions, "ColorPickerUI.exe")
_ArrayRemove($aProcessExclusions, "FancyZonesEditor.exe")
_ArrayRemove($aProcessExclusions, "ImageResizer.exe")
_ArrayRemove($aProcessExclusions, "PowerLauncher.exe")
Case $hNBFC
_ArrayRemove($aProcessExclusions, "NoteBookFanControl.exe")
_ArrayRemove($aServicesExclusions, "NbfcService")
Case $hTStop
_ArrayRemove($aProcessExclusions, "ThrottleStop.exe")
Case $hOculus
_ArrayRemove($aProcessExclusions, "OVRLibraryService.exe")
_ArrayRemove($aProcessExclusions, "OVRServiceLauncher.exe")
_ArrayRemove($aProcessExclusions, "oculus-platform-runtime.exe")
_ArrayRemove($aProcessExclusions, "OculusClient.exe")
_ArrayRemove($aProcessExclusions, "OculusDash.exe")
_ArrayRemove($aProcessExclusions, "OVRRedir.exe")
_ArrayRemove($aProcessExclusions, "OVRServer_x64.exe")
_ArrayRemove($aServicesExclusions, "OVRLibraryService")
_ArrayRemove($aServicesExclusions, "OVRService")
Case $hSteamVR
_ArrayRemove($aProcessExclusions, "vrcompositor.exe")
_ArrayRemove($aProcessExclusions, "vrdashboard.exe")
_ArrayRemove($aProcessExclusions, "vrmonitor.exe")
_ArrayRemove($aProcessExclusions, "vrserver.exe")
_ArrayRemove($aProcessExclusions, "vrwebhelper.exe")
Case $hWinMR
_ArrayRemove($aProcessExclusions, "Cortanalistenui.exe")
_ArrayRemove($aProcessExclusions, "DesktopView.exe")
_ArrayRemove($aProcessExclusions, "EnvironmentsApp.exe")
EndSwitch
Else
GUICtrlSetState($hMsg, 1)
Switch $hMsg
Case $hBE
_ArrayAdd($aProcessExclusions, "BEService.exe")
_ArrayAdd($aServicesExclusions, "BEService")
Case $hEAC
_ArrayAdd($aProcessExclusions, "EasyAntiCheat.exe")
_ArrayAdd($aServicesExclusions, "EasyAntiCheat")
Case $hAMD
_ArrayAdd($aProcessExclusions, "RadeonSoftware.exe")
_ArrayAdd($aProcessExclusions, "FacebookClient.exe")
_ArrayAdd($aProcessExclusions, "GfycatWrapper.exe")
_ArrayAdd($aProcessExclusions, "QuanminTVWrapper.exe")
_ArrayAdd($aProcessExclusions, "RestreamAPIWrapper.exe")
_ArrayAdd($aProcessExclusions, "SinaWeiboWrapper.exe")
_ArrayAdd($aProcessExclusions, "StreamableAPIWrapper.exe")
_ArrayAdd($aProcessExclusions, "TwitchClient.exe")
_ArrayAdd($aProcessExclusions, "TwitterWrapperClient.exe")
_ArrayAdd($aProcessExclusions, "YoukuWrapper.exe")
_ArrayAdd($aProcessExclusions, "YoutubeAPIWrapper.exe")
Case $hNvidia
_ArrayAdd($aProcessExclusions, "nvcontainer.exe")
_ArrayAdd($aProcessExclusions, "nvscaphelper.exe")
_ArrayAdd($aProcessExclusions, "nvsphelper.exe")
_ArrayAdd($aProcessExclusions, "nvsphelper64.exe")
_ArrayAdd($aProcessExclusions, "GFExperience.exe")
Case $hOBS
_ArrayAdd($aProcessExclusions, "obs.exe")
_ArrayAdd($aProcessExclusions, "obs32.exe")
_ArrayAdd($aProcessExclusions, "obs64.exe")
_ArrayAdd($aProcessExclusions, "obs-ffmpeg-mux.exe")
Case $hSLOBS
_ArrayAdd($aProcessExclusions, "Streamlabs OBS.exe")
_ArrayAdd($aProcessExclusions, "obs32.exe")
_ArrayAdd($aProcessExclusions, "obs64.exe")
_ArrayAdd($aProcessExclusions, "obs-ffmpeg-mux.exe")
Case $hVMix
_ArrayAdd($aProcessExclusions, "vMixService.exe")
_ArrayAdd($aProcessExclusions, "vMix.exe")
_ArrayAdd($aProcessExclusions, "vMix64.exe")
_ArrayAdd($aProcessExclusions, "vMixDesktopCapture.exe")
_ArrayAdd($aProcessExclusions, "vMixNDIHelper.exe")
_ArrayAdd($aProcessExclusions, "ffmpeg.exe")
_ArrayAdd($aServicesExclusions, "vMixService")
Case $hWirecast
_ArrayAdd($aProcessExclusions, "CEFChildProcess.exe")
_ArrayAdd($aProcessExclusions, "Wirecast.exe")
_ArrayAdd($aProcessExclusions, "wirecastd.exe")
Case $hWinDVR
_ArrayAdd($aServicesExclusions, "BcastDVRUserService")
Case $hXSplit
_ArrayAdd($aProcessExclusions, "XGS32.exe")
_ArrayAdd($aProcessExclusions, "XGS64.exe")
_ArrayAdd($aProcessExclusions, "XSplit.Core.exe")
_ArrayAdd($aProcessExclusions, "XSplit.xbcbp.exe")
Case $hChrome
_ArrayAdd($aProcessExclusions, "chrome.exe")
Case $hEdge
_ArrayAdd($aProcessExclusions, "msedge.exe")
Case $hFirefox
_ArrayAdd($aProcessExclusions, "firefox.exe")
Case $hMSIE
_ArrayAdd($aProcessExclusions, "iexplore.exe")
Case $hOpera
_ArrayAdd($aProcessExclusions, "opera.exe")
Case $hPale
_ArrayAdd($aProcessExclusions, "palemoon.exe")
_ArrayAdd($aProcessExclusions, "plugin-container.exe")
_ArrayAdd($aProcessExclusions, "plugin-hang-ui.exe")
Case $hCorsiar
_ArrayAdd($aProcessExclusions, "Corsair.Service.CpuIdRemote64.exe")
_ArrayAdd($aProcessExclusions, "Corsair.Service.DisplayAdapter.exe")
_ArrayAdd($aProcessExclusions, "Corsair.Service.exe")
_ArrayAdd($aProcessExclusions, "CorsairGamingAudioCfgService64.exe")
_ArrayAdd($aServicesExclusions, "CorsairGamingAudioConfig")
_ArrayAdd($aServicesExclusions, "CorsairLLAService")
_ArrayAdd($aServicesExclusions, "CorsairService")
Case $hLogi
_ArrayAdd($aProcessExclusions, "KHALMNPR.exe")
_ArrayAdd($aProcessExclusions, "SetPoint.exe")
Case $hMSMK
_ArrayAdd($aProcessExclusions, "MKCHelper.exe")
_ArrayAdd($aProcessExclusions, "ipoint.exe")
_ArrayAdd($aProcessExclusions, "itype.exe")
Case $hEpik
_ArrayAdd($aProcessExclusions, "EpicGamesLauncher.exe")
Case $hParsec
_ArrayAdd($aProcessExclusions, "pservice.exe")
_ArrayAdd($aProcessExclusions, "parsecd.exe")
_ArrayAdd($aServicesExclusions, "Parsec")
Case $hSteam
_ArrayAdd($aProcessExclusions, "Steam.exe")
_ArrayAdd($aProcessExclusions, "SteamService.exe")
_ArrayAdd($aProcessExclusions, "steamwebhelper.exe")
_ArrayAdd($aServicesExclusions, "Steam Client Service")
Case $hHTCVP
_ArrayAdd($aProcessExclusions, "ViveportDesktopService.exe")
_ArrayAdd($aServicesExclusions, "ViveportDesktopService")
Case $hXbox
_ArrayAdd($aServicesExclusions, "XboxGipSvc")
_ArrayAdd($aServicesExclusions, "XblAuthManager")
_ArrayAdd($aServicesExclusions, "XblGameSave")
_ArrayAdd($aServicesExclusions, "XboxNetApiSvc")
Case $hDiscord
_ArrayAdd($aProcessExclusions, "Discord.exe")
Case $hTelegram
_ArrayAdd($aProcessExclusions, "Telegram.exe")
Case $hMSPT
_ArrayAdd($aProcessExclusions, "PowerToys.exe")
_ArrayAdd($aProcessExclusions, "PowerToysSettings.exe")
_ArrayAdd($aProcessExclusions, "ColorPicker.exe")
_ArrayAdd($aProcessExclusions, "ColorPickerUI.exe")
_ArrayAdd($aProcessExclusions, "FancyZonesEditor.exe")
_ArrayAdd($aProcessExclusions, "ImageResizer.exe")
_ArrayAdd($aProcessExclusions, "PowerLauncher.exe")
Case $hNBFC
_ArrayAdd($aProcessExclusions, "NoteBookFanControl.exe")
_ArrayAdd($aServicesExclusions, "NbfcService")
Case $hTSTOP
_ArrayAdd($aProcessExclusions, "ThrottleStop.exe")
Case $hOculus
_ArrayAdd($aProcessExclusions, "OVRLibraryService.exe")
_ArrayAdd($aProcessExclusions, "OVRServiceLauncher.exe")
_ArrayAdd($aProcessExclusions, "oculus-platform-runtime.exe")
_ArrayAdd($aProcessExclusions, "OculusClient.exe")
_ArrayAdd($aProcessExclusions, "OculusDash.exe")
_ArrayAdd($aProcessExclusions, "OVRRedir.exe")
_ArrayAdd($aProcessExclusions, "OVRServer_x64.exe")
_ArrayAdd($aServicesExclusions, "OVRLibraryService")
_ArrayAdd($aServicesExclusions, "OVRService")
Case $hSteamVR
_ArrayAdd($aProcessExclusions, "vrcompositor.exe")
_ArrayAdd($aProcessExclusions, "vrdashboard.exe")
_ArrayAdd($aProcessExclusions, "vrmonitor.exe")
_ArrayAdd($aProcessExclusions, "vrserver.exe")
_ArrayAdd($aProcessExclusions, "vrwebhelper.exe")
Case $hWinMR
_ArrayAdd($aProcessExclusions, "Cortanalistenui.exe")
_ArrayAdd($aProcessExclusions, "DesktopView.exe")
_ArrayAdd($aProcessExclusions, "EnvironmentsApp.exe")
EndSwitch
EndIf
Case $hAddCustom
$hFile = FileOpenDialog("Select Definition File to Load", @WorkingDir, "Exclusions Definition (*.def)", 1, "exclusion.def", $hGUI)
If @error Then
Else
_LoadCustom($hFile, $aProcessExclusions, $aServicesExclusions)
EndIf
Case $hRemCustom
$hFile = FileOpenDialog("Select Definition File to Unload", @WorkingDir, "Exclusions Definition (*.def)", 1, "exclusion.def", $hGUI)
If @error Then
Else
_RemoveCustom($hFile, $aProcessExclusions, $aServicesExclusions)
EndIf
Case $hToggle
GUICtrlSetState($hToggle, 128)
If Not $bSuspended Then
If Not _IsChecked($hThawCycle) Then GUICtrlSetState($hExclude, 128)
GUICtrlSetState($hServices, 128)
GUICtrlSetState($hAggressive, 128)
GUICtrlSetState($hThawCycle, 128)
$aServicesSnapshot = _ServicesList()
_FreezeToStock($aProcessExclusions, _IsChecked($hServices), $aServicesExclusions, _IsChecked($hAggressive), $hStatus)
$bSuspended = Not $bSuspended
GUICtrlSetData($hToggle, " UNFREEZE SYSTEM")
$hFreezeTimer = TimerInit()
Else
_ThawFromStock($aProcessExclusions, _IsChecked($hServices), $aServicesSnapshot, _IsChecked($hAggressive), $hStatus)
$bSuspended = Not $bSuspended
GUICtrlSetState($hServices, 64)
If _IsChecked($hServices) Then GUICtrlSetState($hAggressive, 64)
GUICtrlSetState($hThawCycle, 64)
If _IsChecked($hThawCycle) Then GUICtrlSetState($hThawCycle + 1, 64)
GUICtrlSetData($hToggle, " FREEZE SYSTEM")
GUICtrlSetState($hExclude, 64)
EndIf
GUICtrlSetState($hToggle, 64)
Case $hServices
If _IsChecked($hServices) Then
GUICtrlSetState($hAggressive - 1, 64)
GUICtrlSetState($hAggressive, 64)
Else
GUICtrlSetState($hAggressive - 1, 128)
GUICtrlSetState($hAggressive, 128)
EndIf
Case $hThawTop
If _IsChecked($hThawTop) Then
GUICtrlSetState($hReFreeze - 1, 64)
GUICtrlSetState($hReFreeze, 64)
Else
GUICtrlSetState($hReFreeze - 1, 128)
GUICtrlSetState($hReFreeze, 128)
EndIf
Case $hThawCycle
If _IsChecked($hThawCycle) Then
For $iLoop = 1 To 8 Step 1
GUICtrlSetState($hThawCycle + $iLoop, 64)
Next
Else
For $iLoop = 1 To 8 Step 1
GUICtrlSetState($hThawCycle + $iLoop, 128)
Next
EndIf
Case $hGithub
ShellExecute("https://fcofix.org/FreezeToStock")
Case $hDisWeb
ShellExecute("https://discord.gg/uBnBcBx")
Case $hDonate
ShellExecute("https://www.paypal.me/rhsky")
Case $hUpdate
If $bSuspended Then
MsgBox(0+48+0x00040000, "Unable to Check for Updates", "Please thaw the system to check for updates", 10)
Else
Switch _GetLatestRelease($sVersion)
Case -1
MsgBox(0+48+0x00040000, "Test Build?", "You're running a newer build than publically available!", 10)
Case 0
Switch @error
Case 0
MsgBox(0+64+0x00040000, "Up to Date", "You're running the latest build!", 10)
Case 1
MsgBox(0+48+0x00040000, "Unable to Check for Updates", "Unable to load release data.", 10)
Case 2
MsgBox(0+48+0x00040000, "Unable to Check for Updates", "Invalid Data Received!", 10)
Case 3
Switch @extended
Case 0
MsgBox(0+48+0x00040000, "Unable to Check for Updates", "Invalid Release Tags Received!", 10)
Case 1
MsgBox(0+48+0x00040000, "Unable to Check for Updates", "Invalid Release Types Received!", 10)
EndSwitch
EndSwitch
Case 1
If MsgBox(4+64+0x00040000, "Update Available", "An Update is Availabe, would you like to download it?", 10) = 6 Then ShellExecute("https://fcofix.org/FreezeToStock/releases")
EndSwitch
EndIf
Case Else
EndSwitch
WEnd
EndFunc
Func _ArrayRemove(ByRef $aArray, $sRemString)
$sTemp = "," & _ArrayToString($aArray, ",") & ","
$sTemp = StringReplace($sTemp, "," & $sRemString & ",", ",")
$sTemp = StringReplace($sTemp, ",,", ",")
If StringLeft($sTemp, 1) = "," Then $sTemp = StringTrimLeft($sTemp, 1)
If StringRight($sTemp, 1) = "," Then $sTemp = StringTrimRight($sTemp, 1)
If $sTemp = "" Or $sTemp = "," Then
$aArray = StringSplit($sTemp, ",", 2)
_ArrayDelete($aArray, 0)
Else
$aArray = StringSplit($sTemp, ",", 2)
EndIf
EndFunc
Func _FreezeToStock($aProcessExclusions, $bIncludeServices, $aServicesExclusions, $bAggressive, $hOutput)
_GUICtrlStatusBar_SetText($hOutput, "Freezing...", 0)
If @Compiled Then
Local $aSelf[1] = ["FTS.exe"]
Else
Local $aSelf[3] = ["AutoIt3.exe", "AutoIt3_x64.exe", "SciTE.exe"]
EndIf
Local $aCantBeSuspended[6] = ["Memory Compression", "Registry", "Secure System", "System", "System Idle Process", "System Interrupts"]
Local $aSystemProcesses[33] = ["ApplicationFrameHost.exe", "backgroundTaskHost.exe", "csrss.exe", "ctfmon.exe", "dllhost.exe", "dwm.exe", "explorer.exe", "fontdrvhost.exe", "lsass.exe", "MsMpEng.exe", "NisSrv.exe", "RuntimeBroker.exe", "SecurityHealthService.exe", "SecurityHealthSystray.exe", "services.exe", "SgrmBroker.exe", "ShellExperienceHost.exe", "sihost.exe", "smartscreen.exe", "smss.exe", "StartMenuExperienceHost.exe", "svchost.exe", "taskhostw.exe", "taskmgr.exe", "TextInputHost.exe", "unsecapp.exe", "VSSVC.exe", "wininit.exe", "winlogon.exe", "wlanext.exe", "WmiPrvSE.exe", "WUDFHost.exe", "WWAHost.exe"]
Local $aSystemServices[71] = ["Appinfo", "AudioEndpointBuilder", "Audiosrv", "BFE", "BrokerInfrastructure", "camsvc", "CertPropSvc", "CoreMessagingRegistrar", "CryptSvc", "DcomLaunch", "Dhcp", "DispBrokerDesktopSvc", "Dnscache", "DPS", "DusmSvc", "EventLog", "EventSystem", "FontCache", "gpsvc", "iphlpsvc", "KeyIso", "LanmanServer", "LanmanWorkstation", "lmhosts", "LSM", "mpssvc", "NcbService", "netprofm", "NlaSvc", "nsi", "PcaSvc", "PlugPlay", "Power", "ProfSvc", "RmSvc", "RpcEptMapper", "RpcSs", "SamSs", "Schedule", "SecurityHealthService", "SENS", "SessionEvc", "SgrmBroker", "ShellHWDetection", "StateRepository", "StorSvc", "swprv", "SysMain", "SystemEventsBroker", "TabletInputService", "TermService", "Themes", "TimeBrokerSvc", "TokenBroker", "TrkWks", "UmRdpService", "UserManager", "UsoSvc", "VaultSvc", "VSS", "WarpJITSvc", "WbioSrvc", "Wcmsvc", "WdiServiceHost", "WdiSystemHost", "WdNisSvc", "WinDefend", "WinHttpAutoProxySvc", "Winmgmt", "WpnService", "wscsvc"]
_ArrayConcatenate($aProcessExclusions, $aSelf)
_ArrayConcatenate($aProcessExclusions, $aCantBeSuspended)
_ArrayConcatenate($aProcessExclusions, $aSystemProcesses)
_ArrayConcatenate($aServicesExclusions, $aSystemServices)
$aProcesses = ProcessList()
For $iLoop = 0 to $aProcesses[0][0] Step 1
If _ArraySearch($aProcessExclusions, $aProcesses[$iLoop][0]) = -1 Then
_GUICtrlStatusBar_SetText($hOutput, "Process: " & $aProcesses[$iLoop][0], 1)
_ProcessSuspend($aProcesses[$iLoop][1])
Else
ConsoleWrite("Skipped " & $aProcesses[$iLoop][0] & @CRLF)
EndIf
Next
FileWrite(".frozen", @HOUR & ":" & @MIN & " - " & @MDAY & "/" & @MON & "/" & @YEAR & @CRLF)
If $bIncludeServices Then
Local $hSCM = _SCMStartup()
$aServices = _ServicesList()
For $iLoop0 = 0 To 2 Step 1
For $iLoop1 = 0 to $aServices[0][0] Step 1
If $aServices[$iLoop1][1] = "RUNNING" Then
If _ArraySearch($aServicesExclusions, $aServices[$iLoop1][0]) = -1 Then
If $bAggressive Then
_GUICtrlStatusBar_SetText($hOutput, $iLoop0 + 1 & "/3 Service: " & $aServices[$iLoop1][0], 1)
_ServiceStop($hSCM, $aServices[$iLoop1][0])
Else
_GUICtrlStatusBar_SetText($hOutput, $iLoop0 + 1 & "/3 Service: " & $aServices[$iLoop1][0], 1)
_ServicePause($hSCM, $aServices[$iLoop1][0])
EndIf
Sleep(10)
Else
ConsoleWrite("Skipped " & $aServices[$iLoop1][0] & @CRLF)
EndIf
EndIf
Next
Next
_SCMShutdown($hSCM)
FileWrite(".frozen", "True" & @CRLF)
FileWrite(".frozen", _ArrayToString($aServices, ","))
EndIf
FileSetAttrib(".frozen", "+H")
_GUICtrlStatusBar_SetText($hOutput, "", 0)
_GUICtrlStatusBar_SetText($hOutput, "", 1)
EndFunc
Func _GetLatestRelease($sCurrent)
Local $dAPIBin
Local $sAPIJSON
$dAPIBin = InetRead("https://api.fcofix.org/repos/rcmaehl/FreezeToStock/releases")
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
Func _GetStateFile()
If FileExists(".frozen") Then
Local $hStateFile = FileOpen(".frozen", 0)
If $hStateFile = -1 Then
Return True
EndIf
Return FileReadLine($hStateFile, 1)
Else
Return False
EndIf
EndFunc
Func _IsChecked($idControlID)
Return BitAND(GUICtrlRead($idControlID), 1) = 1
EndFunc
Func _LoadCustom($sFile, ByRef $aProcessExclusions, ByRef $aServicesExclusions)
Local $hFile
Local $aLine
If FileExists($sFile) Then
$hFile = FileOpen($sFile)
If @error Then SetError(2,0,0)
Else
SetError(2,1,0)
EndIf
Local $iLines = _FileCountLines($sFile)
For $iLine = 1 to $iLines Step 1
$sLine = FileReadLine($hFile, $iLine)
If @error = -1 Then ExitLoop
$aLine = StringSplit($sLine, ",", 2)
If UBound($aLine) <> 2 Then ContinueLoop
Switch $aLine[0]
Case "Process"
_ArrayAdd($aProcessExclusions, $aLine[1])
Case "Service"
_ArrayAdd($aServicesExclusions, $aLine[1])
Case Else
ContinueLoop
EndSwitch
Next
FileClose($hFile)
EndFunc
Func _ProcessSuspend($iPID)
$hProcess = _WinAPI_OpenProcess(0x00000800, False, $iPID)
$iSuccess = DllCall("ntdll.dll", "int", "NtSuspendProcess", "int", $hProcess)
_WinAPI_CloseHandle($hProcess)
If IsArray($iSuccess) Then
Return 1
Else
SetError(1)
Return 0
EndIf
EndFunc
Func _ProcessResume($iPID)
$hProcess = _WinAPI_OpenProcess(0x00000800, False, $iPID)
$iSuccess = DllCall("ntdll.dll", "int", "NtResumeProcess", "int", $hProcess)
_WinAPI_CloseHandle($hProcess)
If IsArray($iSuccess) Then
Return 1
Else
SetError(1)
Return 0
EndIf
EndFunc
Func _ReadStateFile()
Local $aFullArray
_FileWriteToLine(".frozen", 1, ",", True)
_FileWriteToLine(".frozen", 2, ",", True)
_FileReadToArray(".frozen", $aFullArray, 0, ",")
If @error Then Return False
_ArrayDelete($aFullArray, 0)
_ArrayDelete($aFullArray, 0)
Return $aFullArray
EndFunc
Func _RemoveStateFile()
FileDelete(".frozen")
EndFunc
Func _RemoveCustom($sFile, ByRef $aProcessExclusions, ByRef $aServicesExclusions)
Local $hFile
Local $aLine
If FileExists($sFile) Then
$hFile = FileOpen($sFile)
If @error Then SetError(2,0,0)
Else
SetError(2,1,0)
EndIf
Local $iLines = _FileCountLines($sFile)
For $iLine = 1 to $iLines Step 1
$sLine = FileReadLine($hFile, $iLine)
If @error = -1 Then ExitLoop
$aLine = StringSplit($sLine, ",", 2)
If UBound($aLine) <> 2 Then ContinueLoop
Switch $aLine[0]
Case "Process"
_ArrayRemove($aProcessExclusions, $aLine[1])
Case "Service"
_ArrayRemove($aServicesExclusions, $aLine[1])
Case Else
ContinueLoop
EndSwitch
Next
FileClose($hFile)
EndFunc
Func _ServicesList()
Local $iExitCode, $st,$a,$aServicesList[1][2],$x
$iExitCode = Run(@ComSpec & ' /C sc queryex type= service state= all', '', @SW_HIDE, 0x2)
While 1
$st &= StdoutRead($iExitCode)
If @error Then ExitLoop
Sleep(10)
WEnd
$a = StringRegExp($st,'(?m)(?i)(?s)(?:SERVICE_NAME|NOME_SERVIO)\s*?:\s+?(\w+).+?(?:STATE|ESTADO)\s+?:\s+?\d+?\s+?(\w+)',3)
For $x = 0 To UBound($a)-1 Step 2
ReDim $aServicesList[UBound($aServicesList)+1][2]
$aServicesList[UBound($aServicesList)-1][0]=$a[$x]
$aServicesList[UBound($aServicesList)-1][1]=$a[$x+1]
Next
$aServicesList[0][0] = UBound($aServicesList)-1
Return $aServicesList
EndFunc
Func _ThawFromStock($aProcessExclusions, $bIncludeServices, $aServicesSnapshot, $bAggressive, $hOutput)
_GUICtrlStatusBar_SetText($hOutput, "Thawing...", 0)
If $bIncludeServices Then
Local $hSCM = _SCMStartup()
For $iLoop0 = 0 To 2 Step 1
For $iLoop1 = 0 to $aServicesSnapshot[0][0] Step 1
If $aServicesSnapshot[$iLoop1][1] = "RUNNING" Then
If $bAggressive Then
_GUICtrlStatusBar_SetText($hOutput, $iLoop0 + 1 & "/3 Service: " & $aServicesSnapshot[$iLoop1][0], 1)
_ServiceStart($hSCM, $aServicesSnapshot[$iLoop1][0])
Else
_GUICtrlStatusBar_SetText($hOutput, $iLoop0 + 1 & "/3 Service: " & $aServicesSnapshot[$iLoop1][0], 1)
_ServiceContinue($hSCM, $aServicesSnapshot[$iLoop1][0])
EndIf
Sleep(10)
Else
EndIf
Next
Next
_SCMShutdown($hSCM)
EndIf
$aProcesses = ProcessList()
For $iLoop = 0 to $aProcesses[0][0] Step 1
If _ArraySearch($aProcessExclusions, $aProcesses[$iLoop][0]) = -1 Then
_GUICtrlStatusBar_SetText($hOutput, "Process: " & $aProcesses[$iLoop][0], 1)
_ProcessResume($aProcesses[$iLoop][1])
Else
EndIf
Next
_RemoveStateFile()
_GUICtrlStatusBar_SetText($hOutput, "", 0)
_GUICtrlStatusBar_SetText($hOutput, "", 1)
EndFunc
