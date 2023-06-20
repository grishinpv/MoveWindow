#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=Icon\MoveWindow.ico
#AutoIt3Wrapper_Res_Description=Window Mover Tool
#AutoIt3Wrapper_Res_Fileversion=0.0.1.0
#AutoIt3Wrapper_Res_ProductName=WindowMove
#AutoIt3Wrapper_Res_ProductVersion=0.0.1.0
#AutoIt3Wrapper_Res_CompanyName=p.grishin
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
;*****************************************
;MoveWindow.au3 by p.grishin
;Created with ISN AutoIt Studio v. 1.13
;*****************************************
#include-once

#include "Forms\MoveWindowUI.isf"
#include "Functions.au3"
#include <GuiComboBox.au3>
#include <GUIConstantsEx.au3>
#include "Debug.au3"

$EMPTY_WINDOW_LIST =  "<Процесс не имеет окон>"


Func FillProcessList()
	;MsgBox(0, "", "FillProcessList")
	
	GUICtrlSetState($ctrlBtnMove, $GUI_DISABLE)
	GUICtrlSetState($ctrlBtnRefresh, $GUI_DISABLE)
	
	_DebugPrint("[FillProcessList] Wait process enumeration..." )
		
	$lProcessList =  EnumProcesses()
	;_ArrayDisplay($lProcessList)
	
	_DebugPrint("[FillProcessList] Process list updated successfully" )
	
	_GUICtrlComboBox_ResetContent ( $ctrlProcessList )
	_GUICtrlComboBox_BeginUpdate($ctrlProcessList)
	
	for $i = 1 to $lProcessList[0][0]-1
		;GUICtrlSetData($MEMO, $lProcessList[$i][0] &  " " &  $lProcessList[$i][1])
		_GUICtrlComboBox_AddString ( $ctrlProcessList, $lProcessList[$i][0] &  " " &  $lProcessList[$i][1] )
	Next 
    _GUICtrlComboBox_EndUpdate($ctrlProcessList)
	_GUICtrlComboBox_SetCurSel($ctrlProcessList, 0 )

	GUICtrlSetState($ctrlBtnMove, $GUI_ENABLE)
	GUICtrlSetState($ctrlBtnRefresh, $GUI_ENABLE)
    

EndFunc


Func FillWindowsList($iPID)
	;MsgBox(0, "", "FillWindowsList")
	
	$lWindowList =  EnumWindows($iPID)
	
	_GUICtrlComboBox_ResetContent ( $ctrlWindowList )
	_GUICtrlComboBox_BeginUpdate($ctrlWindowList)
	if not IsArray($lWindowList) or $lWindowList[0][0] =  0 Then 
		_GUICtrlComboBox_AddString ( $ctrlWindowList, $EMPTY_WINDOW_LIST )
		GUICtrlSetState($ctrlBtnMove, $GUI_DISABLE)
	Else 
		for $i = 1 to $lWindowList[0][0]
			_DebugPrint("[FillWindowsList] Add string to window list ctrl: " & $lWindowList[$i][0] &  " " &  $lWindowList[$i][1])
			_GUICtrlComboBox_AddString ( $ctrlWindowList, $lWindowList[$i][0] &  " " &  $lWindowList[$i][1] )
		Next
		GUICtrlSetState($ctrlBtnMove, $GUI_ENABLE)
	EndIf 
	
	_GUICtrlComboBox_EndUpdate($ctrlWindowList)
	_GUICtrlComboBox_SetCurSel($ctrlWindowList, 0 )
	
	
	
EndFunc

Func BtnMove_Click()
	$iSelectedItem =  _GUICtrlComboBox_GetCurSel ( $ctrlWindowList )
	$sItemText =  _GUICtrlComboBox_GetEditText ( $ctrlWindowList )
	
	if $sItemText =  "" then 
		GUICtrlSetState($ctrlBtnMove, $GUI_DISABLE)
		Return 
	EndIf
	
	$hWindow =  StringSplit($sItemText, " ")
	
	_DebugPrint("[BtnMove_Click] Try to move window with hwnd " & $hWindow[1] )
	WinSetState ( HWnd ($hWindow[1]), "", @SW_MAXIMIZE )
	$bStatus =  _WinAPI_MoveWindow ( $hWindow[1], 0, 0, 200, 200 )
	
	_DebugPrint("[BtnMove_Click] OpStatus = " & $bStatus )
EndFunc

#include <GuiEdit.au3>

Func WM_COMMAND($hWnd, $iMsg, $wParam, $lParam)
    #forceref $hWnd, $iMsg
    Local $hWndFrom, $iIDFrom, $iCode, $hWndCombo
    If Not IsHWnd($ctrlProcessList) Then $hWndCombo = GUICtrlGetHandle($ctrlProcessList)
    $hWndFrom = $lParam
    $iIDFrom = BitAND($wParam, 0xFFFF) ; Low Word
    $iCode = BitShift($wParam, 16) ; Hi Word
    Switch $hWndFrom
        Case $ctrlProcessList, $hWndCombo
            Switch $iCode
                Case $CBN_CLOSEUP ; Sent when the list box of a combo box has been closed
;~                     _DebugPrint("$CBN_CLOSEUP" & @CRLF & "--> hWndFrom:" & @TAB & $hWndFrom & @CRLF & _
;~                             "-->IDFrom:" & @TAB & $iIDFrom & @CRLF & _
;~                             "-->Code:" & @TAB & $iCode)
                    ; no return value
                Case $CBN_DBLCLK ; Sent when the user double-clicks a string in the list box of a combo box
;~                     _DebugPrint("$CBN_DBLCLK" & @CRLF & "--> hWndFrom:" & @TAB & $hWndFrom & @CRLF & _
;~                             "-->IDFrom:" & @TAB & $iIDFrom & @CRLF & _
;~                             "-->Code:" & @TAB & $iCode)
                    ; no return value
                Case $CBN_DROPDOWN ; Sent when the list box of a combo box is about to be made visible
;~                     _DebugPrint("$CBN_DROPDOWN" & @CRLF & "--> hWndFrom:" & @TAB & $hWndFrom & @CRLF & _
;~                             "-->IDFrom:" & @TAB & $iIDFrom & @CRLF & _
;~                             "-->Code:" & @TAB & $iCode)
                    ; no return value
                Case $CBN_EDITCHANGE ; Sent after the user has taken an action that may have altered the text in the edit control portion of a combo box
;~                     _DebugPrint("$CBN_EDITCHANGE" & @CRLF & "--> hWndFrom:" & @TAB & $hWndFrom & @CRLF & _
;~                             "-->IDFrom:" & @TAB & $iIDFrom & @CRLF & _
;~                             "-->Code:" & @TAB & $iCode)
                    
					
					$item =  GUICtrlRead( $ctrlProcessList )
					;_DebugPrint("[UICtrl] Selected process item: " &  $item)
					
					if $item =  "" Then 
						GUICtrlSetState($ctrlBtnMove, $GUI_DISABLE)
						return
					EndIf
					
					GUICtrlSetState($ctrlBtnMove, $GUI_ENABLE)
					
					$pid =  StringSplit($item, " ")
					;_DebugPrint("[UICtrl] PID from process item: " &  $pid[1])
					
					if Not StringIsDigit($pid[1]) Then 
						_DebugPrint("[UICtrl] Invalid PID")
						Return 
					EndIf
					
					

					FillWindowsList($pid[1])
					
                    ; no return value
                Case $CBN_EDITUPDATE ; Sent when the edit control portion of a combo box is about to display altered text
;~                     _DebugPrint("$CBN_EDITUPDATE" & @CRLF & "--> hWndFrom:" & @TAB & $hWndFrom & @CRLF & _
;~                             "-->IDFrom:" & @TAB & $iIDFrom & @CRLF & _
;~                             "-->Code:" & @TAB & $iCode)
                    ; no return value
                Case $CBN_ERRSPACE ; Sent when a combo box cannot allocate enough memory to meet a specific request
;~                     _DebugPrint("$CBN_ERRSPACE" & @CRLF & "--> hWndFrom:" & @TAB & $hWndFrom & @CRLF & _
;~                             "-->IDFrom:" & @TAB & $iIDFrom & @CRLF & _
;~                             "-->Code:" & @TAB & $iCode)
                    ; no return value
                Case $CBN_KILLFOCUS ; Sent when a combo box loses the keyboard focus
;~                     _DebugPrint("$CBN_KILLFOCUS" & @CRLF & "--> hWndFrom:" & @TAB & $hWndFrom & @CRLF & _
;~                             "-->IDFrom:" & @TAB & $iIDFrom & @CRLF & _
;~                             "-->Code:" & @TAB & $iCode)
                    ; no return value
                Case $CBN_SELCHANGE ; Sent when the user changes the current selection in the list box of a combo box
;~                     _DebugPrint("$CBN_SELCHANGE" & @CRLF & "--> hWndFrom:" & @TAB & $hWndFrom & @CRLF & _
;~                             "-->IDFrom:" & @TAB & $iIDFrom & @CRLF & _
;~                             "-->Code:" & @TAB & $iCode)
                    ; no return value
                Case $CBN_SELENDCANCEL ; Sent when the user selects an item, but then selects another control or closes the dialog box
;~                     _DebugPrint("$CBN_SELENDCANCEL" & @CRLF & "--> hWndFrom:" & @TAB & $hWndFrom & @CRLF & _
;~                             "-->IDFrom:" & @TAB & $iIDFrom & @CRLF & _
;~                             "-->Code:" & @TAB & $iCode)
                    ; no return value
                Case $CBN_SELENDOK ; Sent when the user selects a list item, or selects an item and then closes the list
;~                     _DebugPrint("$CBN_SELENDOK" & @CRLF & "--> hWndFrom:" & @TAB & $hWndFrom & @CRLF & _
;~                             "-->IDFrom:" & @TAB & $iIDFrom & @CRLF & _
;~                             "-->Code:" & @TAB & $iCode)
							
					$item =  GUICtrlRead( $ctrlProcessList )
					;_DebugPrint("Selected process item: " &  $item)
					
					if $item =  "" Then 
						GUICtrlSetState($ctrlBtnMove, $GUI_DISABLE)
						return
					EndIf
					
					GUICtrlSetState($ctrlBtnMove, $GUI_ENABLE)
					
					$pid =  StringSplit($item, " ")
					;_DebugPrint("[UICtrl] PID from process item: " &  $pid[1])
					
					if Not StringIsDigit($pid[1]) Then 
						_DebugPrint("[UICtrl] Invalid PID")
						Return 
					EndIf

					FillWindowsList($pid[1])
                    ; no return value
                Case $CBN_SETFOCUS ; Sent when a combo box receives the keyboard focus
;~                     _DebugPrint("$CBN_SETFOCUS" & @CRLF & "--> hWndFrom:" & @TAB & $hWndFrom & @CRLF & _
;~                             "-->IDFrom:" & @TAB & $iIDFrom & @CRLF & _
;~                             "-->Code:" & @TAB & $iCode)
                    ; no return value
            EndSwitch
    EndSwitch
    Return $GUI_RUNDEFMSG
EndFunc   ;==>WM_COMMAND



; -- Created with ISN Form Studio 2 for ISN AutoIt Studio -- ;
#include <StaticConstants.au3>
#include <GUIConstantsEx.au3>
#include <WindowsConstants.au3>
#Include <GuiButton.au3>
#include <GuiRichEdit.au3>
#include <ComboConstants.au3>

$MoveWindowUI = GUICreate("MoveWindow",429,457,-1,-1,-1,-1)
$ctrlProcessList = GUICtrlCreateCombo("",120,30,221,21,-1,-1)
GUICtrlSetData(-1,"")
GUICtrlCreateLabel("Process",21,36,52,15,-1,-1)
GUICtrlSetFont(-1,10,400,0,"MS Sans Serif")
GUICtrlSetBkColor(-1,"-2")
GUICtrlCreateLabel("Window",20,80,50,15,-1,-1)
GUICtrlSetFont(-1,10,400,0,"MS Sans Serif")
GUICtrlSetBkColor(-1,"-2")
$ctrlWindowList = GUICtrlCreateCombo("",120,74,280,21,-1,-1)
GUICtrlSetData(-1,"")
;$ctrlMoveStart = GUICtrlCreateRadio("Move Start",120,120,82,20,-1,-1)
;$ctrlMoveCenter = GUICtrlCreateRadio("Move Center",220,120,150,20,-1,-1)
$ctrlBtnMove = GUICtrlCreateButton("Move",300,160,100,30,-1,-1)
GUICtrlSetOnEvent(-1,"BtnMove_Click")
GUICtrlSetState(-1,BitOr($GUI_SHOW,$GUI_DISABLE))
$ctrlBtnRefresh = GUICtrlCreateButton("Refresh",343,30,57,21,-1,-1)
GUICtrlSetOnEvent(-1,"FillProcessList")
$MEMO = _GUICtrlRichEdit_Create($MoveWindowUI,"",20,243,395,200,BitOr($ES_AUTOVSCROLL,$ES_MULTILINE,$WS_VSCROLL,$WS_HSCROLL),-1)
GUICtrlCreateLabel("Output",20,220,50,15,-1,-1)
GUICtrlSetBkColor(-1,"-2")

GUISetState(@SW_SHOW, $MoveWindowUI)
GUIRegisterMsg($WM_COMMAND, "WM_COMMAND")


ConsoleWrite("Start..." &  @CRLF)

While 1
	$nMsg = GUIGetMsg()
	Switch $nMsg
		Case $GUI_EVENT_CLOSE
			Exit
		Case $ctrlBtnRefresh
			FillProcessList()
		Case $ctrlBtnMove
			BtnMove_Click()
			
	EndSwitch
WEnd
