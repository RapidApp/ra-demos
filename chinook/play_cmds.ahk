; -----------------------------------
;   ---- Setup global vars ----
ShellTitle = demohost - SecureCRT
comment = #
pause_str = # --
next_lone_newline = 0
no_newline_prefix = 1
auto_next = 0
indx = 1
active_macro = 0
active_substep = 0

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
  
  if(active_macro) {
    active_substep++
    finished := EditMacro(active_macro,active_substep)
    if(finished = 1) {
      return FinishMacro()
    }
  }
  else {
    return AdvanceNextLine()
  }
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

EditMacro(number,substep) {
  global
  if(number = 1) {
    return EditMacroOne(substep)
  }
  else if(number = 2) {
    return EditMacroTwo(substep)
  }
  else {
    MsgBox Unknown EditMacro '%number%' - exiting!
    ExitApp
  }
}

FinishMacro() {
  global
  
  active_macro = 0
  active_substep = 0
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
      ExitApp
    }
    
    comment_pos := InStr(line,comment)
    pause_pos := InStr(line,pause_str)
    
    SendRaw %line%
    indx++
    
    ; If we're a comment line (that is not a pause):
    if(comment_pos = 2 && pause_pos <> 2) {
    
      macro_num := GetMacroNumber(line)
      if(macro_num) {
        active_macro := macro_num
        Send {Enter}
        return
      }
    
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
    MsgBox Wanted active title '%ShellTitle%', got '%WinTitle%' - exiting!
    ExitApp
  }
  return
}

; Checks the supplied string for a macro number def
; i.e. comment like:  # (123) - bla bla
GetMacroNumber(str) {

  op = (
  cl = )
  OpenPos := InStr(str,op)
  ClosePos := InStr(str,cl)
  
  if(OpenPos) {
    OpenPos++
    Len := ClosePos - OpenPos
    MacroNum := SubStr(str,OpenPos,Len)
    
    ; Consider only numeric macros:
    if(RegExMatch(MacroNum,"^\d+$")) {
      return MacroNum
    }
  }
  
  return 0
}


EditMacroOne(substep) {
  global
  Sleep 500
  if(substep = 1) {
    Send vim lib/RA/ChinookDemo.pm
  }
  else if(substep = 2) {
    Send {Enter}
  }
  else if(substep = 3) {
    Send {g 2} ; move to the first line
    Send {Down 6} ; Go to the start of the comments
    Sleep 500
    Loop, 11 { ; Delete the comments
      Send {d 2}
      Sleep 30
    }
    Sleep 500
    Send i ; go into INSERT mode
    Sleep 500
    Send use RapidApp;{Enter}
  }
  else if(substep = 4) {
    Send {Down 2}
    Send {End}
    Send {Enter}
    Sleep 300
    Send RapidApp::RapidDbic
  }
  else if(substep = 5) {
    Send {Escape} ; leave INSERT mode
    Sleep 300
    Send {Down}
    Loop, 2 { ; Delete the other plugins
      Send {d 2}
      Sleep 300
    }
  }
  else if(substep = 6) {
    Send {Down 6}
    Sleep 500
    Loop, 8 { ; Delete the comments
      Send {d 2}
      Sleep 30
    }
    Sleep 500
  }
  else if(substep = 7) {
    Send {Down 4}
    Sleep 500
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}
    Sleep 300
    Send {Enter 2}
    SendRaw 'Plugin::RapidApp::RapidDbic' => {
    Send {Enter}{Space 2}
    Send {#} Only required option:{Enter}{Backspace 2}
    Sleep 200
    SendRaw dbic_models => ['Chinook']
    Send {Enter}
    Sleep 100
    Send {Backspace 2}
    SendRaw }
    Send {Enter}
    Send {Escape} ; leave INSERT mode
  }
  else if(substep = 8) {
    Send {Z 2} ; Save and exit
  }
  else if(substep = 9) {
    Send {Space}{#} Start the test server:{Enter}
    Sleep 200
    Send script/ra_chinookdemo_server.pl
  }
  else if(substep = 10) {
    Send {Enter}
    Sleep 10000 ; min sleep time
  }
  else if(substep = 11) {
    ; stop the test server
    Send ^c
    Sleep 500
  }
  else {
    return 1 ; finished
  }
  return 0 ; not finished
}


EditMacroTwo(substep) {
  global
  if(substep = 1) {
  
  
  }
  else if(substep = 2) {
  
  
  }
  else {
    return 1 ; finished
  }
  return 0 ; not finished
}


