
vimScrollUp(lines) {
  Loop, %lines% {
    Sleep 10
    Send ^y
  }
}

vimJumpString(str,scroll) {
  Send {/}%str%{Enter}  ; jump to search string
  if(scroll) {
    Send zz             ; scroll cursor to top
  }
}

vimJumpStringTop(str,scroll) {
  Send {g 2}            ; move to the first line
  vimJumpString(str,scroll)
}
