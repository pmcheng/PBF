PowerMic Buttons for Fluency
============================

PowerMic Buttons for Fluency is an AutoHotkey script which persists as a tray icon, intercepts buttons on a PowerMic dictation microphone, and sends simulated function key presses to Fluency for Imaging Reporting.  

The compiled script can be downloaded [here](https://pcheng.org/powermic/PowerMic_Buttons_for_Fluency.exe).  Since this is an unsigned executable, a Windows Defender SmartScreen warning will typically appear on first execution.  Click on the "More info" link, then the "Run anyway" button to execute the script.  This warning is typical of unsigned compiled AutoHotkey scripts; if you are worried, scan the file with a virus checker, or review and compile the source code with [AutoHotkey](https://www.autohotkey.com).

<img src="more_info.png" width=300> <img src="run_anyway.png" width=300>

Fluency should be configured ahead of time to map the F1, F2, and F3 function keys to dictation, previous field, and next field functions in Fluency, as shown here:

<p align="center">
<img src="Fluency_User_Preferences.png">
</p>

In the default configuration, the PowerMic dictation button operates as a deadman switch, i.e. press and hold to dictate, release to stop dictation.  In "Toggle Mode", pressing the Dictation button activates the microphone, and pressing again deactivates it.  To activate Toggle Mode, right click the tray icon for a context menu and click on the Toggle Mode option.  You can also turn the script on or off by clicking the "Active" item in the menu, or by double-clicking the tray icon (this may be useful if you need to intermittently use the PowerMic in a program other than Fluency).  The tray icon turns red when the script is disabled.

<p align="center">
<img src="tray_menu.png">
</p>

If Fluency is running as an independent window recognizable by the host operating system, the script will send the function keys directly to the Fluency window.  Otherwise, if Fluency is running within a remote desktop, the script will send the function keys to the active window within the desktop, which may have unintended side effects.

The script can be used as a template for mapping PowerMic buttons to arbitrary system actions.  It uses the [AHKHID](https://github.com/jleb/AHKHID) library; if running or compiling from source, obtain [AHKHID.ahk](https://github.com/jleb/AHKHID/blob/master/AHKHID.ahk) and put it in the same folder as the main script.
