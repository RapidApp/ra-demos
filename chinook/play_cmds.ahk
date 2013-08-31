; -----------------------------------
;   ---- Setup global vars ----
ShellTitle = demohost - SecureCRT
comment = #
pause_str = # --
next_lone_newline = 0
no_newline_prefix = 1
auto_next = 0
indx = 1

;   ---- Install Hotkeys ----
; ctrl + spacebar:
^Space::
  AdvanceNext(0)
return

; ctrl + alt + a
^!a::
  StartStopAutoAdvance()
return
; -----------------------------------


AdvanceNext(auto) {
  global
  if(auto_next && !auto) {
    return StartStopAutoAdvance()
  }
  return AdvanceNextLine()
}

StartStopAutoAdvance() {
  global
  if(auto_next) {
    auto_next = 0
  }
  else {
    return AutoAdvanceNext(300)
  }
}

AutoAdvanceNext(delay) {
  global
  auto_next = 1
  Sleep %delay%
  if(auto_next) {
    AdvanceNext(1)
  }
  if(auto_next) {
    return AutoAdvanceNext(delay)
  }
}



AdvanceNextLine() {
  global
  WinGetActiveTitle, WinTitle
  if(WinTitle = ShellTitle) {
  
    if(next_lone_newline) {
      SendPlay {Enter}
      next_lone_newline = 0
      no_newline_prefix = 1
      return
    }
    
    if(no_newline_prefix) {
      ; Turn off for next call:
      no_newline_prefix = 0
    }
    else {
      SendPlay {Enter}
    }
  
    FileReadLine, line, cmd_script.txt, %indx%
    if(ErrorLevel) {
      exit
    }
    
    comment_pos := InStr(line,comment)
    pause_pos := InStr(line,pause_str)
    
    SendRaw %line%
    indx++
    
    ; If we're a comment line (that is not a pause):
    if(comment_pos = 2 && pause_pos <> 2) {
      ; Look ahead and advance to the next line if its 
      ; a comment, too
      FileReadLine, nextline, cmd_script.txt, %indx%
      next_comment_pos := InStr(nextline,comment)
      if(next_comment_pos = 2 && !ErrorLevel) {
        return AdvanceNextLine()
      }
    }
    
    ; If we're an actual command, make the next call
    ; send a lone newline/Enter (to hold for its output)
    if(comment_pos = 0) {
      next_lone_newline = 1
    }
  }
  else {
    MsgBox Wanted %ShellTitle%, got %WinTitle%
  }
  return
}

