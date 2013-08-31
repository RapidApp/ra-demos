; Hotkey: ctrl + Space
Hotkey, ^Space, NextLineLabel

ShellTitle = demohost - SecureCRT
comment = #
;newline_next = 1

indx = 1
NextLineLabel:
  WinGetActiveTitle, WinTitle
  if(WinTitle = ShellTitle) {
    FileReadLine, line, cmd_script.txt, %indx%
    comment_pos := InStr(line,comment)
    
    if(indx > 1){
      SendPlay {Enter}
    }
    
    SendRaw %line%
    indx++
    
    ; If we're a comment line:
    if(comment_pos = 2) {
    
      ; Look ahead and advance to the next line if its 
      ; a comment, too
      FileReadLine, nextline, cmd_script.txt, %indx%
      next_comment_pos := InStr(nextline,comment)
      if(next_comment_pos = 2) {
        Goto NextLineLabel
      }
    }
  }
  else {
    ;MsgBox Wanted %ShellTitle%, got %WinTitle%
  }
return

