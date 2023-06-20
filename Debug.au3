
#include-once

Func _DebugPrint($s_Text, $sLine = @ScriptLineNumber)
    _GUICtrlEdit_AppendText ( $MEMO, "-->Line(" & StringFormat("%04d", $sLine) & "):" & @TAB & $s_Text & @CRLF)
EndFunc   ;==>_DebugPrint

