#NoTrayIcon
#Region ;**** Directives created by AutoIt3Wrapper_GUI ****
#AutoIt3Wrapper_Icon=rapp2.ico
#AutoIt3Wrapper_Outfile_x64=rapp2.exe
#AutoIt3Wrapper_Res_Fileversion=0.0.3.0
#EndRegion ;**** Directives created by AutoIt3Wrapper_GUI ****
#include <TrayConstants.au3>
#include <WinAPI.au3>
#include <Process.au3>

; Options:
; 1 - do not show default AutoIt menu
; 2 - items will not automatically check/uncheck when clicked
Opt("TrayMenuMode", 1 + 2)
Opt("TrayOnEventMode", 1)

Dim $showProcesses[1][2]

main()

Func main()
	Dim $en[10]
	Dim $ru[10]

	$en[0] = "Exit"
	$ru[0] = "Выход"
	$en[1] = "Recent apps"
	$ru[1] = "Недавние приложения"

	Local $loc
	If @OSLang == "0419" Then
		$loc = $ru
	Else
		$loc = $en
	EndIf

    TrayCreateItem($loc[0])
	TrayItemSetOnEvent(-1, "close")
    TrayCreateItem("")

    TraySetState($TRAY_ICONSTATE_SHOW)

	TraySetToolTip($loc[1])

    While 1
		Sleep(2000)

		Local $currentWindows = WinList()
		For $curWin = 1 to $currentWindows[0][0]
			If $currentWindows[$curWin][0] == '' Then ContinueLoop

			Local $winState = WinGetState($currentWindows[$curWin][1])
			If Not BitAND($winState, $WIN_STATE_VISIBLE) Then ContinueLoop

			Local $curProcPID = WinGetProcess($currentWindows[$curWin][1])
			Local $curProcName = _ProcessGetName($curProcPID)

			For $showProc = 1 to UBound($showProcesses) - 1
				If $curProcName == $showProcesses[$showProc][0] Then
					ContinueLoop 2
				EndIf
			Next

			Local $procFilename = _WinAPI_GetProcessFileName($curProcPID)

			ReDim $showProcesses[UBound($showProcesses) + 1][2]
			$showProcesses[UBound($showProcesses) - 1][0] = $curProcName
			$showProcesses[UBound($showProcesses) - 1][1] = $procFilename

			If StringLower(StringRight($curProcName, 4)) == '.exe' Then
				$procName = StringTrimRight($curProcName, 4)
			Else
				$procName = $curProcName
			EndIf
			TrayCreateItem($procName)
			TrayItemSetOnEvent(-1, "go")
		Next
    WEnd
EndFunc

Func go()
	If @TRAY_ID > 8 Then
		Run($showProcesses[@TRAY_ID - 8][1])
	EndIf
EndFunc

Func close()
	Exit
EndFunc
