; Assumes and requires a FireFox browser at 0:0, 
; setup for the chinook demo video recording

; CRT position	: -7, -99
; CRT size		: 1055,896

; FF Position	: 0,0
; FF Size		: 1023,769
; ------------------------------------------------------


; EXPERIMENTAL/UNFINISHED.....

Sleep( 1000 )

AutoItSetOption("SendKeyDelay",20)

WinWaitActive("Mozilla FireFox","",5)

Sleep( 600 )

MouseMove(187,67,20) ; position in address bar
Sleep(600)
MouseClick("left")
Sleep(600)
Send("http://demohost:3000",1)
Sleep(600)
Send("{ENTER}",0)

Sleep( 2000 )
MouseMove(20,130,20) ; position on DB expander in tree
Sleep(600)
MouseClick("left")