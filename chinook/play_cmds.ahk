; Hotkey: ctrl + Space
Hotkey, ^Space, NextLineLabel

ShellTitle = demohost - SecureCRT
comment = #
pause_str = # --
next_lone_newline = 0
no_newline_prefix = 1

indx = 1
NextLineLabel:
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
      if(next_comment_pos = 2) {
        Goto NextLineLabel
      }
    }
    
    ; If we're an actual command, make the next call
    ; send a lone newline/Enter (to hold for its output)
    if(comment_pos = 0) {
      next_lone_newline = 1
    }
  }
  else {
    ;MsgBox Wanted %ShellTitle%, got %WinTitle%
  }
return

