
ResetDefaultKeyDelay() {
  SetKeyDelay, 15
}

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


vimNewHashCnf(name,comment) {
  SendRaw %name% => {
  if(comment) {
    if(comment <> 1) {
      Send {Space}{#}{Space}%comment%
    }
  }
  Sleep 100
  Send {Enter 2}
  SendRaw },
  Sleep 100
  if(comment) {
    Send {Space}
    SendRaw # (%name%)
  }
  Send {Up 2}{End}{Enter}
  Sleep 200
  Send {Delete}{Tab}
}


vimNewHashSub(name,comment) {
  SendRaw %name% => sub {
  if(comment) {
    if(comment <> 1) {
      Send {Space}{#}{Space}%comment%
    }
  }
  Sleep 100
  Send {Enter 2}
  SendRaw },
  Sleep 100
  if(comment) {
    Send {Space}
    SendRaw # (%name%)
  }
  Send {Up 2}{End}{Enter}
  Sleep 200
  Send {Delete}{Tab}
}

vimNewArrCnf(name,comment) {
  SetKeyDelay, 30
  SendRaw %name% => [
  if(comment) {
    if(comment <> 1) {
      Send {Space}{#}{Space}%comment%
    }
  }
  Sleep 100
  Send {Enter 2}
  SendRaw ],
  Sleep 100
  if(comment) {
    Send {Space}
    SendRaw # (%name%)
  }
  Send {Up 2}{End}{Enter}
  Sleep 200
  Send {Delete}{Tab}
  ResetDefaultKeyDelay()
}
