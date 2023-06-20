#include-once
#include <Memory.au3>
#include <WinAPI.au3>
#include <Array.au3>
#include <ProcessConstants.au3>
#include <WinAPIProc.au3>
#include <WinAPISys.au3>
#include <SecurityConstants.au3>
OnAutoItExitRegister("_CreateToolHelp32Snapshot_OnExit")
Global const $TH32CS_SNAPALL=bitor(0x00000001,0x00000008,0x00000002,0x00000004)
Global const $TH32CS_INHERIT=0x80000000
Global const $TH32CS_SNAPHEAPLIST=0x00000001
Global const $TH32CS_SNAPMODULE=0x00000008
Global const $TH32CS_SNAPMODULE32=0x00000010
Global const $TH32CS_SNAPPROCESS=0x00000002
Global const $TH32CS_SNAPTHREAD=0x00000004
Global const $tagHEAPENTRY_32="struct;dword dwSize;handle;ptr;int;int;int;int;int;ptr;endstruct"
Global const $tagHEAPLIST_32="struct;int;Dword;Ptr;Dword;endstruct"
Global const $tagMODULEENTRY_32="struct;dword;int;int;int;byte[4];byte[4];int;handle;char[1024];char[1024];endstruct"
Global const $tagMODULEENTRY_32W="struct;dword dwSize;int;int;int;byte[4];byte[4];int;handle;wchar[1024];wchar[1024];endstruct"
Global const $tagPROCESSENTRY_32="struct;dword dwSize;int;int;ptr;int;int;int;int;int;char[1024];endstruct"
Global const $tagPROCESSENTRY_32W="struct;dword dwSize;int;int;ptr;int;int;int;int;int;wChar[1024];endstruct"
Global const $tagTHREADENTRY_32="struct;dword dwSize;int;int;int;int;int;int;endstruct"
Global $Struct_HeapEntry32,$Struct_HeapList32,$Struct_ModuleEntry32,$Struct_ModuleEntry32W,$Struct_ProcessEntry32,$Struct_ProcessEntry32W,$Struct_ThreadEntry32
Global $pStruct_HeapEntry32,$pStruct_HeapList32,$pStruct_ModuleEntry32,$pStruct_ModuleEntry32W,$pStruct_ProcessEntry32,$pStruct_ProcessEntry32W,$pStruct_ThreadEntry32
;~ =============================================================================================================================================================================================================================
;~ Title	Description                                       Author:$MarkyRocks!!
;~ ==========================================================================================================================================================================================================================================
;~ CreateToolhelp32Snapshot($Flags,$ProcessID )    Takes a snapshot of the specified processes, as well as the heaps, modules, and threads used by these processes.
;~ ========================================================================================================================================================================================================================================
;~ Heap32First($hSnapShot)	         Retrieves information about the first block of a heap that has been allocated by a process.
;~ ================================================================================================================================================================================================================================================
;~ =====================================================================================================================================================================================================================================================
;~ Heap32Next($hSnapShot)		    Retrieves information about the next block of a heap that has been allocated by a process.
;~ ==================================================================================================================================================================================================================================================
;~ Module32First($hSnapShot)		Retrieves information about the first module associated with a process.
;~ ========================================================================================================================================================================================================================================================
;~ Module32FirstW($hSnapShot)		Retrieves information about the first module associated with a process.
;~ ==================================================================================================================================================================================================================================================
;~ Module32Next($hSnapShot)		    Retrieves information about the next module associated with a process or thread.
;~ ==================================================================================================================================================================================================================================================
;~ Module32NextW($hSnapShot)		Retrieves information about the next module associated with a process or thread.
;~ ==================================================================================================================================================================================================================================================
;~ Process32First($hSnapShot)		Retrieves information about the first process encountered in a system snapshot.
;~ ==================================================================================================================================================================================================================================================
;~ Process32FirstW($hSnapShot)		Retrieves information about the first process encountered in a system snapshot.
;~ ==================================================================================================================================================================================================================================================
;~ Process32Next($hSnapShot)		Retrieves information about the next process recorded in a system snapshot.
;~ ==================================================================================================================================================================================================================================================
;~ Process32NextW($hSnapShot)		Retrieves information about the next process recorded in a system snapshot.
;~ ==================================================================================================================================================================================================================================================
;~ Thread32First($hSnapShot)		Retrieves information about the first thread of any process encountered in a system snapshot.
;~ ==================================================================================================================================================================================================================================================
;~ Thread32Next($hSnapShot)	        Retrieves information about the next thread of any process encountered in the system memory snapshot.
;~ ==================================================================================================================================================================================================================================================
;~ Toolhelp32ReadProcessMemory($th32ProcessID,$lpBaseAddress,$lpBuffer,$cbRead,$lpNumberOfBytesRead)	    Copies memory allocated to another process into an application-supplied buffer.
;~ ==================================================================================================================================================================================================================================================
;~ CreateToolHelp32Snapshot_OnInit()    Builds the structs gets things ready !!!!!!!!!!Must Be Ran on Start of your code
;~ +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;~ CreateToolHelp32Snapshot_OnExit()     Release Memory resources   SHOULD Be automatic but it can't hurt to run it anyways
;=====================================================================================================================================================================================================================================================
;~   CreateToolhelp32Snapshot($flags,$iPID)     Takes a snapshot of the specified processes, as well as the heaps, modules, and threads used by these processes.
;~
;~                           Returns a Handle to the Snapshot of the system or Exit on fail                                                        Markyrocks
;~======================================================================================================================================================================================================================================================
func _CreateToolHelp32Snapshot($dwFlags,$th32ProcessID)
$aResult = DllCall("kernel32.dll", "handle", "CreateToolhelp32Snapshot", "dword", $dwFlags, "dword",$th32ProcessID)
if not $aResult[0] Then
MsgBox('','ERROR','Failed to get snapshot')
Exit
EndIf
Return $aResult[0]
EndFunc
;===============================================================================================================================================================================
;~   Heap32First(              Retrieves information about the first block of a heap that has been allocated by a process.
;~   LPHEAPENTRY32 lphe,
;~   DWORD         th32ProcessID,
;~   ULONG_PTR     th32HeapID                   Returns a 2d array or False on Fail   !!!!!!This Needs to be called before anyother Heap Functions                   Markyrocks
;~===============================================================================================================================================================================
Func _Heap32First($hSnapshot) ;should be ok
$bool=_Heap32ListFirst($hSnapshot,$pStruct_HeapList32)
if not $bool Then
MsgBox('','Error _Heap32First()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
$aResult = DllCall("kernel32.dll","bool","Heap32First","long_ptr",DllStructGetPtr($Struct_HeapEntry32), _
"dword",DllStructGetData($Struct_HeapList32,2),"ulong_ptr",DllStructGetData($Struct_HeapList32,3))
if not $aResult[0] Then
Return False
EndIf
Dim $aArray[8][2]
$aArray[0][0]="HANDLE"
$aArray[1][0]="ADDRESS"
$aArray[2][0]="BLOCK_SIZE"
$aArray[3][0]="FLAGS"
$aArray[4][0]="LOCK_COUNT"
$aArray[5][0]="RESERVED"
$aArray[6][0]="PROCESS_ID"
$aArray[7][0]="HEAP_ID"
for $x=0 to UBound($aArray)-1
$aArray[$x][1]=DllStructGetData($Struct_HeapEntry32,$x+1)
Next
Return $aArray
EndFunc
;================================================================================================================================================================================
;~   Heap32ListFirst(                 Retrieves information about the first heap that has been allocated by a specified process.
;~   HANDLE       hSnapshot,
;~   LPHEAPLIST32 lphl               ###INTERNAL###                                                                                                         Markyrocks
;~==============================================================================================================================================================================
Func _Heap32ListFirst($hSnapshot,$lphl)
$aResult = DllCall("kernel32.dll", "bool", "Heap32ListFirst", "handle", $hSnapshot,"ptr",$lphl)
if not $aResult[0] Then
MsgBox('','Error _Heap32ListFirst()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
Return True
EndFunc
;~ ================================================================================================================================================================================
;~   Heap32ListNext(                Retrieves information about the next heap that has been allocated by a process.
;~   HANDLE       hSnapshot,
;~   LPHEAPLIST32 lphl                  ###INTERNAL###                                                                                                 Markyrocks
;~================================================================================================================================================================================
Func _Heap32ListNext($hSnapshot,$lphl)
$aResult = DllCall("kernel32.dll","bool","Heap32ListNext","handle",$hSnapshot,"ptr",$lphl)
if not $aResult[0] Then
MsgBox('','Error _Heap32ListNext()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
Return True
EndFunc
;~ ===================================================================================================================================================================================
;~   Heap32Next(                          Retrieves information about the next block of a heap that has been allocated by a process.
;~   LPHEAPENTRY32 lphe                         Returns a 2d Array or False on Fail                                                                          Markyrocks
;~=====================================================================================================================================================================================
Func _Heap32Next($hSnapshot)
if not _Heap32ListNext($hSnapshot,DllStructGetPtr($Struct_HeapList32)) Then
MsgBox('','Error _Heap32Next()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
$aResult = DllCall("kernel32.dll","bool","Heap32Next","ptr",DllStructGetPtr($Struct_HeapEntry32))
if not $aResult[0] Then
Return False
EndIf
dim $aArray[8][2]
$aArray[0][0]="HANDLE"
$aArray[1][0]="ADDRESS"
$aArray[2][0]="BLOCK_SIZE"
$aArray[3][0]="FLAGS"
$aArray[4][0]="LOCK_COUNT"
$aArray[5][0]="RESERVED"
$aArray[6][0]="PROCESS_ID"
$aArray[7][0]="HEAP_ID"
for $x=0 to UBound($aArray)-1
$aArray[$x][1]=DllStructGetData($Struct_HeapEntry32,$x+1)
Next
Return $aArray
EndFunc
;~ =======================================================================================================================================================================================
;~   Module32First(                   Retrieves information about the first module associated with a process.
;~   HANDLE          hSnapshot,
;~   LPMODULEENTRY32 lpme                                Returns a 2d Array or False on Fail    !!!!!This Needs Called b4 any other Module32 Functions         markyrocks
;~============================================================================================================================================================================================

Func _Module32First($hSnapshot)
$aResult = DllCall("kernel32.dll","bool","Module32First","handle",$hSnapshot,"ptr",DllStructGetPtr($Struct_ModuleEntry32))
if not $aResult[0] Then
MsgBox('','Error _Module32First',_WinAPI_GetLastError())
Return False
EndIf
Dim $aArray[7][2]
$aArray[0][0]="PROCESS_ID"
$aArray[1][0]="GLOBAL_COUNT"
$aArray[2][0]="LOAD_COUNT"
$aArray[3][0]="BASE_ADDRESS"
$aArray[4][0]="BASE_SIZE"
$aArray[5][0]="HANDLE"
$aArray[6][0]="MODULE_NAME"

for $x=0 to UBound($aArray)-1
$aArray[$x][1]=DllStructGetData($Struct_ModuleEntry32,$x+3)
Next
Return $aArray
EndFunc
;~ ============================================================================================================================================================================================
;~   Module32FirstW(                      Retrieves information about the first module associated with a process.
;~   HANDLE           hSnapshot,
;~   LPMODULEENTRY32W lpme                              Returns a 2d Array or False on Fail           !!!!!This Needs Called b4 any other Module32 Functions       markyrocks
;~====================================================================================================================================================================================================
Func _Module32FirstW($hSnapshot)
$aResult = DllCall("kernel32.dll","bool","Module32FirstW","handle",$hSnapshot,"ptr",DllStructGetPtr($Struct_ModuleEntry32W))
if not $aResult[0] Then
	MsgBox('','Error _Module32FirstW()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
Dim $aArray[7][2]
$aArray[0][0]="PROCESS_ID"
$aArray[1][0]="GLOBAL_COUNT"
$aArray[2][0]="LOAD_COUNT"
$aArray[3][0]="BASE_ADDRESS"
$aArray[4][0]="BASE_SIZE"
$aArray[5][0]="HANDLE"
$aArray[6][0]="MODULE_NAME"

for $x=0 to UBound($aArray)-1
$aArray[$x][1]=DllStructGetData($Struct_ModuleEntry32W,$x+3)
Next
_ArrayDisplay($aResult,'aResult')
Return $aArray
EndFunc
;~ ========================================================================================================================================================================================================================
;~   Module32Next(                        Retrieves information about the next module associated with a process or thread.
;~   HANDLE          hSnapshot,
;~   LPMODULEENTRY32 lpme                        Returns a 2d Array or False on Fail                                                                     Markyrocks
;~================================================================================================================================================================================================

Func _Module32Next($hSnapshot)
$aResult = DllCall("kernel32.dll","bool","Module32Next","handle",$hSnapshot,"ptr",DllStructGetPtr($Struct_ModuleEntry32))
if not $aResult[0] Then
MsgBox('','Error _Module32Next()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
Dim $aArray[7][2]
$aArray[0][0]="PROCESS_ID"
$aArray[1][0]="GLOBAL_COUNT"
$aArray[2][0]="LOAD_COUNT"
$aArray[3][0]="BASE_ADDRESS"
$aArray[4][0]="BASE_SIZE"
$aArray[5][0]="HANDLE"
$aArray[6][0]="MODULE_NAME"
for $x=0 to UBound($aArray)-1
$aArray[$x][1]=DllStructGetData($Struct_ModuleEntry32,$x+3)
Next

Return $aArray
EndFunc
;~ ===================================================================================================================================================================================================
;~   Module32NextW(                      Retrieves information about the next module associated with a process or thread.
;~   HANDLE           hSnapshot,
;~   LPMODULEENTRY32W lpme                               Returns a 2d Array or false on Fail                                                                  Markyrocks
;~==========================================================================================================================================================================================================

Func _Module32NextW($hSnapshot)
$aResult = DllCall("kernel32.dll","bool","Module32Nextw","handle",$hSnapshot,"ptr",DllStructGetPtr($Struct_ModuleEntry32W))
if not $aResult[0] Then
MsgBox('','Error _Module32NextW()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
Dim $aArray[7][2]
$aArray[0][0]="PROCESS_ID"
$aArray[1][0]="GLOBAL_COUNT"
$aArray[2][0]="LOAD_COUNT"
$aArray[3][0]="BASE_ADDRESS"
$aArray[4][0]="BASE_SIZE"
$aArray[5][0]="HANDLE"
$aArray[6][0]="MODULE_NAME"

for $x=0 to UBound($aArray)-1
$aArray[$x][1]=DllStructGetData($Struct_ModuleEntry32W,$x+3)
Next
Return $aArray
EndFunc
;~ ============================================================================================================================================================================================================
;~   Process32First(                   Retrieves information about the first process encountered in a system snapshot.
;~   HANDLE           hSnapshot,
;~   LPPROCESSENTRY32 lppe                     Returns a 2d Array or False on Fail !!!!!!Must be called first b4 any other process function                      Markyrock
;~==============================================================================================================================================================================================================
Func _Process32First($hSnapshot)
$aResult = DllCall("kernel32.dll","bool","Process32First","handle",$hSnapshot,"ptr",DllStructGetPtr($Struct_ProcessEntry32))
if not $aResult[1] Then
MsgBox('','_Process32First()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
Dim $aArray[8][2]
$aArray[0][0]="PROCESS_ID"
$aArray[1][0]="NOT USED"
$aArray[2][0]="NOT USED"
$aArray[3][0]="THREAD_COUNT"
$aArray[4][0]="PARENT_PROCESS_ID"
$aArray[5][0]="PRIORITY_CLASS_BASE"
$aArray[6][0]="NOT_USED"
$aArray[7][0]="EXE_PATH"
for $x=0 to UBound($aArray)-1
$aArray[$x][1]=DllStructGetData($Struct_ProcessEntry32,$x+3)
Next
Return $aArray
EndFunc
;~ =============================================================================================================================================================================================================
;~   Process32FirstW(                     Retrieves information about the first process encountered in a system snapshot.
;~   HANDLE            hSnapshot,
;~   LPPROCESSENTRY32W lppe                   Returns a 2d Array or False on Fail !!!!!!Must be called first b4 any other process function                      Markyrock
;~===================================================================================================================================================================================================================

Func _Process32FirstW($hSnapshot)
$aResult = DllCall("kernel32.dll","bool","Process32FirstW","handle",$hSnapshot,"ptr",DllStructGetPtr($Struct_ProcessEntry32W))
if not $aResult[0] Then
MsgBox('','_Process32FirstW()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
Dim $aArray[8][2]
$aArray[0][0]="PROCESS_ID"
$aArray[1][0]="NOT USED"
$aArray[2][0]="NOT USED"
$aArray[3][0]="THREAD_COUNT"
$aArray[4][0]="PARENT_PROCESS_ID"
$aArray[5][0]="PRIORITY_CLASS_BASE"
$aArray[6][0]="NOT_USED"
$aArray[7][0]="EXE_PATH"
for $x=0 to UBound($aArray)-1
$aArray[$x][1]=DllStructGetData($Struct_ProcessEntry32W,$x+3)
Next
Return $aArray
EndFunc
;~ ===================================================================================================================================================================================================================
;~   Process32Next(                   Retrieves information about the next process recorded in a system snapshot.
;~   HANDLE           hSnapshot,
;~   LPPROCESSENTRY32 lppe                              Returns a 2d Array or False                                                                   Markyrocks
;~=============================================================================================================================================================================================================================
Func _Process32Next($hSnapshot)
$aResult = DllCall("kernel32.dll","bool","Process32Next","handle",$hSnapshot,"ptr",DllStructGetPtr($Struct_ProcessEntry32))
if not $aResult[0] Then
;MsgBox('','Error _Process32Next()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
Dim $aArray[8][2]
$aArray[0][0]="PROCESS_ID"
$aArray[1][0]="NOT USED"
$aArray[2][0]="NOT USED"
$aArray[3][0]="THREAD_COUNT"
$aArray[4][0]="PARENT_PROCESS_ID"
$aArray[5][0]="PRIORITY_CLASS_BASE"
$aArray[6][0]="NOT_USED"
$aArray[7][0]="EXE_PATH"
for $x=0 to UBound($aArray)-1
$aArray[$x][1]=DllStructGetData($Struct_ProcessEntry32,$x+3)
Next
Return $aArray
EndFunc
;~ ===================================================================================================================================================================================================================================
;~   Process32NextW(              Retrieves information about the next process recorded in a system snapshot.
;~   HANDLE            hSnapshot,
;~   LPPROCESSENTRY32W lppe                                Returns a 2d Array or False                                                                   Markyrocks
;~====================================================================================================================================================================================================================================
Func _Process32NextW($hSnapshot)
$aResult = DllCall("kernel32.dll","bool","Process32NextW","handle",$hSnapshot,"ptr",DllStructGetPtr($Struct_ProcessEntry32W))
if not $aResult[0] Then
;MsgBox('','Error _Process32NextW()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
Dim $aArray[8][2]
$aArray[0][0]="PROCESS_ID"
$aArray[1][0]="NOT USED"
$aArray[2][0]="NOT USED"
$aArray[3][0]="THREAD_COUNT"
$aArray[4][0]="PARENT_PROCESS_ID"
$aArray[5][0]="PRIORITY_CLASS_BASE"
$aArray[6][0]="NOT_USED"
$aArray[7][0]="EXE_PATH"
for $x=0 to UBound($aArray)-1
$aArray[$x][1]=DllStructGetData($Struct_ProcessEntry32W,$x+3)
Next
Return $aArray
EndFunc
;~ ============================================================================================================================================================================================================================================
;~	 Thread32First(              Retrieves information about the first thread of any process encountered in a system snapshot.
;~   HANDLE          hSnapshot,
;~   LPTHREADENTRY32 lpte                                       Returns a 2d Array or False                                                                   Markyrocks
;~=============================================================================================================================================================================================================================================
Func _Thread32First($hSnapshot)
$aResult = DllCall("kernel32.dll","bool","Thread32First","handle",$hSnapshot,"ptr",DllStructGetPtr($Struct_ThreadEntry32))
if not $aResult[0] Then
MsgBox('','Error _Thread32First()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
Dim $aArray[3][2]
$aArray[0][0]="THREAD_ID"
$aArray[1][0]="OWNER_PROCESS_ID"
$aArray[2][0]="BASE PRIORITY"
for $x=0 to UBound($aArray)-1
$aArray[$x][1]=DllStructGetData($Struct_ThreadEntry32,$x+3)
Next
Return $aArray
EndFunc
;~ ============================================================================================================================================================================================================================================
;~   Thread32Next(                   Retrieves information about the next thread of any process encountered in the system memory snapshot.
;~   HANDLE          hSnapshot,
;~   LPTHREADENTRY32 lpte                                     Returns a 2d Array or False                                                                   Markyrocks
;~=============================================================================================================================================================================================================================================
Func _Thread32Next($hSnapshot)
$aResult = DllCall("kernel32.dll","bool","Thread32Next","handle",$hSnapshot,"ptr",DllStructGetPtr($Struct_ThreadEntry32))
if not $aResult[0] Then
MsgBox('','Error _Thread32Next()',_WinAPI_GetLastErrorMessage())
Return False
EndIf
Dim $aArray[3][2]
$aArray[0][0]="THREAD_ID"
$aArray[1][0]="OWNER_PROCESS_ID"
$aArray[2][0]="BASE PRIORITY"
for $x=0 to UBound($aArray)-1
$aArray[$x][1]=DllStructGetData($Struct_ThreadEntry32,$x+3)
Next
Return $aArray
EndFunc
;~ =====================================================================================================================================================================================================================================================================
;~   Toolhelp32ReadProcessMemory(                 Copies memory allocated to another process into an application-supplied buffer.
;~   LPCVOID lpBaseAddress,
;~   LPVOID  lpBuffer,
;~   SIZE_T  cbRead,
;~   SIZE_T  *lpNumberOfBytesRead                  Returns True or False   The Read Memory Is Written To The Buffer                                           markyrocks
;~=========================================================================================================================================================================================================================================================================
Func _Toolhelp32ReadProcessMemory($th32ProcessID,$lpBaseAddress,$lpBuffer,$cbRead,$lpNumberOfBytesRead)
$aResult = DllCall("kernel32.dll","bool","Toolhelp32ReadProcessMemory","dword",$th32ProcessID,"ptr",$lpBaseAddress,_
"ptr",$lpBuffer,"size_t",$cbRead,"size_t*",$lpNumberOfBytesRead)
if not $aResult[0] Then
Return False
EndIf
Return True
EndFunc
;~ ==============================================================================================================================================================================================================================================================================
;~ CreateToolHelp32Snapshot_OnInit()                 Builds the structs and gets other preliminary tasks done.
;~                                                                                                                                                        markyrocks
;~ =============================================================================================================================================================================================================================================================================
Func _CreateToolHelp32Snapshot_OnInit()
;~ OnAutoItExitRegister("_CreateToolHelp32Snapshot_OnExit")
$Struct_HeapEntry32=DllStructCreate($tagHEAPENTRY_32)
$Struct_HeapList32=DllStructCreate($tagHEAPLIST_32)
$Struct_ModuleEntry32=DllStructCreate($tagMODULEENTRY_32)
$Struct_ModuleEntry32W=DllStructCreate($tagMODULEENTRY_32W)
$Struct_ProcessEntry32=DllStructCreate($tagPROCESSENTRY_32)
$Struct_ProcessEntry32W=DllStructCreate($tagPROCESSENTRY_32W)
$Struct_ThreadEntry32=DllStructCreate($tagTHREADENTRY_32)
$pStruct_HeapEntry32=DllStructGetPtr($Struct_HeapEntry32)
$pStruct_HeapList32=DllStructGetPtr($Struct_HeapList32)
$pStruct_ModuleEntry32=DllStructGetPtr($Struct_ModuleEntry32)
$pStruct_ModuleEntry32W=DllstructGetPtr($Struct_ModuleEntry32W)
$pStruct_ProcessEntry32=DllStructGetPtr($Struct_ProcessEntry32)
$pStruct_ProcessEntry32W=DllstructGetPtr($Struct_ProcessEntry32W)
$pStruct_ThreadEntry32=DllStructGetPtr($Struct_ThreadEntry32)
DllStructSetData($Struct_HeapEntry32,1,DllStructGetSize($Struct_HeapEntry32))
DllStructSetData($Struct_HeapList32,1,DllStructGetSize($Struct_HeapList32))
DllStructSetData($Struct_ModuleEntry32,1,DllStructGetSize($Struct_ModuleEntry32))
DllStructSetData($Struct_ModuleEntry32W,1,DllStructGetSize($Struct_ModuleEntry32W))
DllStructSetData($Struct_ProcessEntry32,1,DllStructGetSize($Struct_ProcessEntry32))
dllstructsetdata($Struct_ProcessEntry32W,1,DllStructGetSize($Struct_ProcessEntry32W))
dllstructsetdata($Struct_ThreadEntry32,1,DllstructGetSize($Struct_ThreadEntry32))
if @error=1 Then
MsgBox('','ERROR','Variable passed to DllStructCreate was not a string.')
Exit
ElseIf @error=2 Then
MsgBox('','ERROR','There is an unknown Data Type in the string passed.')
Exit
elseif @error=3 Then
MsgBox('','ERROR','Failed to allocate the memory needed for the struct, or Pointer = 0.')
Exit
elseif @error=4 Then
MsgBox('','ERROR','Error allocating memory for the passed string.')
Exit
EndIf
EndFunc
;~ ==============================================================================================================================================================================================================================================================================
;~ CreateToolHelp32Snapshot_OnExit()                Cleanup
;~ This Function Starts automatically when the script is Exited                                                                               markyrocks
;~ =============================================================================================================================================================================================================================================================================
Func _CreateToolHelp32Snapshot_OnExit()
$Struct_HeapEntry32=0
$Struct_HeapList32=0
$Struct_ModuleEntry32=0
$Struct_ModuleEntry32W=0
$Struct_ProcessEntry32=0
$Struct_ProcessEntry32W=0
$Struct_ThreadEntry32=0
$hSnapshot=0
EndFunc