; PowerMic Relay for Fluency
; by Phillip Cheng MD MS
; phillip.cheng@med.usc.edu

; This script relays output from PowerMic Buttons for Fluency to the Fluency window

#SingleInstance force
#Persistent
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

Menu, Tray, Add, About, about
Menu, Tray, Add

Menu, Tray, NoStandard
Menu, Tray, Icon, microphone_green_icon.ico

Menu, Tray, Add, Exit, exit


SetTitleMatchMode, 2
return

about:
    Gui +OwnDialogs
    Msgbox,,PowerMic Relay for Fluency,
(
PowerMic Relay for Fluency
v. 2023-07-29

by Phillip Cheng MD MS
phillip.cheng@med.usc.edu

)
    Return


exit:
    ExitApp    

FluencyActive() {
    return (WinExist("Fluency for Imaging Reporting"))
}


    
$F13::
if (FluencyActive()>0) {
    send {`` down}    
}
return

$F14::
if (FluencyActive()>0) {
    send {`` up}
}
return

$F15::
fluency := FluencyActive()
if (fluency>0) {
    controlsend,,+{tab},ahk_id %fluency%
}
return

$F16::
fluency := FluencyActive()
if (fluency>0) {
    controlsend,,{tab},ahk_id %fluency%
}
return
