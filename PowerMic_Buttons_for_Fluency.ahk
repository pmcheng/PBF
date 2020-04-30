; PowerMic Buttons for Fluency
; by Phillip Cheng MD MS
; phillip.cheng@med.usc.edu

; This script intercepts Powermic buttons and sends function key presses to the Fluency window.
; If the Fluency window is not a top level window in the local OS (e.g. vGPU session), 
; the script sends simulated keystrokes to the active window (this may have unintended side
; effects if the Fluency window is not the active window, so be careful).

; The following setup must be performed in Fluency:
; F1 = Start/Stop recording (Dictate button)
; F2 = Previous field (Tab backward button)
; F3 = Next field (Tab forward button)

; AHK Version 1.1
; uses AHKHID from https://github.com/jleb/AHKHID

#Include AHKHID.ahk
#SingleInstance, force
#NoEnv  ; Recommended for performance and compatibility with future AutoHotkey releases.
SendMode Input  ; Recommended for new scripts due to its superior speed and reliability.

FileInstall,microphone_green.png, %A_Temp%\microphone_green.png,1
FileInstall,microphone_red.png, %A_Temp%\microphone_red.png,1

Menu, Tray, NoStandard
Menu, Tray, Icon, %A_Temp%\microphone_green.png
Menu, Tray, Tip, PowerMic Buttons for Fluency (active)

Menu, Tray, Add, About, about
Menu, Tray, Add

Menu, Tray, Add, Dictation Beep, beep_mode
Menu, Tray, ToggleCheck, Dictation Beep
beep:=1

Menu, Tray, Add, Toggle Mode, toggle_mode
toggle:=0

Menu, Tray, Add, Active, active
Menu, Tray, ToggleCheck, Active
Menu, Tray, Default, Active
active:=1

Menu, Tray, Add
Menu, Tray, Add, Exit, exit

Gui +hwndhwnd ; stores window handle in hwnd
AHKHID_Register(1,0,hwnd,RIDEV_PAGEONLY + RIDEV_INPUTSINK) 
    ; Usage Page 1, Usage 0
    ; RIDEV_PAGEONLY only devices with top level collection is usage page 1 (Powermic)
    ; RIDEV_INPUTSINK enables caller to receive input even when not in foreground

OnMessage(0x00FF, "InputMsg")  ; intercept WM_INPUT
Return

toggle_mode:
    Menu, Tray, ToggleCheck, Toggle Mode
    toggle:=!toggle
    Return
    
beep_mode:
    Menu, Tray, ToggleCheck, Dictation Beep
    beep:=!beep
    Return

active:
    Menu, Tray, ToggleCheck, Active
    active:=!active
    if (active=1) {
        Menu, Tray, Icon, %A_Temp%\microphone_green.png
        Menu, Tray, Tip, PowerMic Buttons for Fluency (active)
    } else {
        Menu, Tray, Icon, %A_Temp%\microphone_red.png
        Menu, Tray, Tip, PowerMic Buttons for Fluency (disabled)
    }
    Return

about:
    Gui +OwnDialogs
    Msgbox,,PowerMic Buttons for Fluency,
(
PowerMic Buttons for Fluency (PBF)
v. 1.01

by Phillip Cheng MD MS
phillip.cheng@med.usc.edu

Fluency Setup:
F1 = Start/Stop recording (PMic Dictate button)
F2 = Previous field (PMic Tab backward button)
F3 = Next field (PMic Tab forward button)

Toggle Mode: Push to dictate, push to stop
        (disable deadman switch mode)
Active: Uncheck to disable PMic buttons 
        (can also double click tray icon)
)
    Return

exit:
    ExitApp

InputMsg(wParam, lParam) {
    Local r, h, vid, pid, uspg, us, data, fluency
    Critical    ;Or otherwise you could get ERROR_INVALID_HANDLE
    
    if (active = 1) {
        ;Get device type
        r := AHKHID_GetInputInfo(lParam, II_DEVTYPE) 
        If (r = RIM_TYPEHID) {
            h := AHKHID_GetInputInfo(lParam, II_DEVHANDLE)

            vid := AHKHID_GetDevInfo(h, DI_HID_VENDORID, True)   ; Vendor ID = 0x554 = 1364 for Dictaphone Corp.
            pid := AHKHID_GetDevInfo(h, DI_HID_PRODUCTID, True)  ; Product ID
            uspg := AHKHID_GetDevInfo(h, DI_HID_USAGEPAGE, True) ; Usage Page
            us := AHKHID_GetDevInfo(h, DI_HID_USAGE, True)       ; Usage
            
            if (vid = 1364) and (pid = 4097) and (uspg = 1) and (us = 0) {  ; we have a PowerMic!
                r := AHKHID_GetInputData(lParam, uData)
                data := NumGet(uData,2,"UShort")

                fluency:= WinExist("Fluency for Imaging Reporting")
                switch data
                {
                    case 0x4: ; Dictate button pressed, toggle dictation on
                        if (fluency>0) {
                            controlsend,,{F1},ahk_id %fluency%
                        } else {
                            send {F1}
                        }
                        if (toggle = 0) {
                            dictate := 1
                        }
                        if (beep = 1) {
                            SoundBeep, 400
                        }
                    case 0x0: ; Dictate button released, toggle dictation off
                        if (toggle = 0) {
                            if (dictate = 1) {
                                if (fluency>0) {
                                    controlsend,,{F1},ahk_id %fluency%
                                } else {
                                    send {F1}
                                }
                                dictate :=0
                            }
                        }
                    case 0x2: ; Tab backward button pressed, previous field
                        if (fluency>0) {
                            controlsend,,{F2},ahk_id %fluency%
                        } else {
                            send {F2}
                        }
                    case 0x8: ; Tab forward button pressed, next field
                        if (fluency>0) {
                            controlsend,,{F3},ahk_id %fluency%
                        } else {
                            send {F3}
                        }
                }
            }
            
        }
    }
}
