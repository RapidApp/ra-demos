; Drags the FF browser to the smaller size for the
; second part of the demo

WinActivate("RA::ChinookDemo - Mozilla Firefox")

; Expected starting position - should do nothing
WinMove("RA::ChinookDemo - Mozilla Firefox","",0,0,1023,769,2)

; start the mouse in the upper left
MouseMove(-59,43)

; move the mouse to the window corner
MouseMove(1019,763,10)

; drag the window smaller
MouseClickDrag("left",1019,763,796,594,10)

; move the mouse out of the corner
MouseMove(547,490,10)

