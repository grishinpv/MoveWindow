;Functions.au3
#include-once
#include "WinAPI_CreateToolhelp32Snapshot.au3"
#include "Debug.au3"


Func EnumProcesses()

	;$aArray[0][0]="PROCESS_ID"
	;$aArray[1][0]="NOT USED"
	;$aArray[2][0]="NOT USED"
	;$aArray[3][0]="THREAD_COUNT"
	;$aArray[4][0]="PARENT_PROCESS_ID"
	;$aArray[5][0]="PRIORITY_CLASS_BASE"
	;$aArray[6][0]="NOT_USED"
	;$aArray[7][0]="EXE_PATH"

	Dim $lResultList[1][2]

	_CreateToolHelp32Snapshot_OnInit()
	$hSnapShot = _CreateToolHelp32Snapshot($TH32CS_SNAPALL,0)

	$pe32 = _Process32First($hSnapShot)
	While True
		; get ProcessName from handle (PID)
		$pid = $pe32[0][1]
		$processName =  _WinAPI_GetProcessName ( $pid )

		$sFill = $pid & "|" & $processName
		;ConsoleWrite($sFill & @CRLF)
		
		if Not $pid = 0 Then 
			_ArrayAdd($lResultList, $sFill)
			$lResultList[0][0] += 1
		EndIf 
			
		$pe32 = _Process32Next($hSnapShot)
		If $pe32 = False Then ExitLoop
	WEnd

	;clean up
	_CreateToolHelp32Snapshot_OnExit()

	Return $lResultList




EndFunc

Func CheckWindowCount($iPID)
	ConsoleWrite("PID = " & $iPID & @CRLF )
	Local $lProcessWindows = _WinAPI_EnumProcessWindows ( $iPID )

	; return empty list in case of error
	if @error or $lProcessWindows[0][0] = 0 Then
		ConsoleWrite("No windows found for process with pid " &  $iPID &  @CRLF)
		return False
	EndIf

	Return True
EndFunc

Func  EnumWindows($iPID)
	Dim $lResultList[1][2]
	$lResultList[0][0] =  0

	Local $lProcessWindows = _WinAPI_EnumProcessWindows ( $iPID )
	

	; return empty list in case of error
	if @error or $lProcessWindows[0][0] = 0 Then
		_DebugPrint("[EnumWindows] No windows found for process with pid " &  $iPID)
		return $lResultList
	EndIf
	
	_DebugPrint("[EnumWindows] Found " & $lProcessWindows[0][0] & " windows for PID " & $iPID)
	
	
	for $i = 1 To $lProcessWindows[0][0]
		
		; get window text by handle
		$windowTitle =  _WinAPI_GetWindowText($lProcessWindows[$i][0])

		; update result array
		$sFill = $lProcessWindows[$i][0] &  "|" &  $windowTitle
		;_DebugPrint($sFill)
		
		_ArrayAdd($lResultList, $sFill)
		$lResultList[0][0] += 1

	Next
	
	Return $lResultList

EndFunc