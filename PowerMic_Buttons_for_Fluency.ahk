; PowerMic Buttons for Fluency
; by Phillip Cheng MD MS
; phillip.cheng@med.usc.edu

; This script intercepts Powermic buttons and sends simulated keystrokes to the Fluency window.
; If the Fluency window is in a VMWare session, the script sends simulated keystrokes to the 
; VMWare session; these must be translated into appropriate keystrokes by the companion script,
; "PowerMic Relay for Fluency."

; Fluency should be configured to “Use tab and shift+tab to navigate fields”

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
Menu, Tray, ToggleCheck, Toggle Mode
toggle:=1

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
v. 2023-07-29

by Phillip Cheng MD MS
phillip.cheng@med.usc.edu

Dictation Beep: 
        on = beep when PMic Dictate button pressed

Toggle Mode: 
        on = push to dictate, push again to stop
        off = deadman switch (push and hold to dictate)
        
Active: 
        on = script enabled (green tray icon)
        off = script disabled (red tray icon)
        (double-clicking tray icon also toggles script)
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

                local := 0
                fluency:= WinExist("Fluency for Imaging Reporting")
                if (fluency>0) {
                    local := 1
                }
                else {
                    if !WinActive("ahk_exe vmware-view.exe") {
                        Return
                    }
                }
                switch data
                {
                    case 0x4: ; Dictate button pressed, toggle dictation on
                        if (local = 1) {
                            if ((dictate = 1) and (toggle = 1)) {
                                send {`` up}
                                dictate := 0
                                if (beep = 1) {
                                    SoundBeep, 300
                                }
                            } else {
                                send {`` down}
                                dictate := 1
                                if (beep = 1) {
                                    SoundBeep, 400
                                }
                            }
                        } else {
                            if ((dictate = 1) and (toggle = 1)) {
                                send {F14}
                                dictate := 0
                                if (beep = 1) {
                                    SoundBeep, 300
                                }
                            } else {
                                send {F13}
                                dictate := 1
                                if (beep = 1) {
                                    SoundBeep, 400
                                }
                            }
                        }

                    case 0x0: ; Dictate button released, toggle dictation off
                        if (toggle=0) {
                            if (local = 1) {
                                send {`` up}
                            } else {
                                send {F14}
                            }
                            dictate :=0
                            if (beep = 1) {
                                SoundBeep, 300
                            }
                        }
                    case 0x2: ; Tab backward button pressed, previous field
                        if (local = 1) {
                            controlsend,,+{tab},ahk_id %fluency%
                        } else {
                            send {F15}
                        }
                    case 0x8: ; Tab forward button pressed, next field
                        if (local = 1) {
                            controlsend,,{tab},ahk_id %fluency%
                        } else {
                            send {F16}
                        }
                }
            }
            
        }
    }
}
