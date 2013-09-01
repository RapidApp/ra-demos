;# This AutoHotKey macro script plays a series of commands
;# and shell interactions for the "Chinook" RapidApp demo video
;# (Note that this is built expecting a specfic environment)

; -----------------------------------
;   ---- Setup global vars ----
ShellTitle = demohost - SecureCRT
speed_up_str = -->
next_lone_newline = 0
no_newline_prefix = 1
auto_next = 0
indx = 1
active_macro = 0
active_substep = 0

SetKeyDelay, 10

;   ---- Install Hotkeys ----
; Ctrl + Spacebar:
^Space::
  AdvanceNext(0)
return

; Ctrl + F1
^F1::
  StartStopAutoAdvance()
return

; Ctrl + Escape
^Escape::
  ExitApp
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
  SetKeyDelay, 10
  
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
    
    is_comment := IsCommentLine(line)
    is_pause := IsPauseLine(line)
    
    ; Check for speed-up flag
    if(is_pause && InStr(line,speed_up_str)) {
      is_pause = 0
      SetKeyDelay, 0
    }
    
    SendRaw %line%
    indx++
    
    ; If we're a comment line (that is not a pause):
    if(is_comment = 1 && is_pause = 0) {
    
      macro_num := GetMacroNumber(line)
      if(macro_num) {
        ; restore normal key delay (ends the speedup)
        SetKeyDelay, 10
        active_macro := macro_num
        Send {Enter}
        return
      }
    
      ; Look ahead and advance to the next line if its a comment, too
      FileReadLine, nextline, cmd_script.txt, %indx%
      if(IsCommentLine(nextline) && !ErrorLevel) {
        return AdvanceNextLine()
      }
    }

    ; restore normal key delay (ends the speedup)
    SetKeyDelay, 10

    
    ; If we're an actual command, make the next call
    ; send a lone newline/Enter (to hold for its output)
    if(is_comment = 0) {
      next_lone_newline = 1
    }
    
    ; Special handling for multi-line command (ending in '\'):
    ; We *don't* want to do a lone newline on next
    if(RegExMatch(line,"\\\s*$")){
      next_lone_newline = 0
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


IsCommentLine(line) {
  global
  
  if(RegExMatch(line,"^\s*\#")) {
    return 1
  }
  return 0
}

IsPauseLine(line) {
  global
  
  if(IsCommentLine(line)) {
    if(RegExMatch(line,"^\s*\#\s*--")) {
      return 1
    }

    ; New: also pause on * bullets
    if(RegExMatch(line,"^\s\#\s+\*")) {
      return 1
    }
    
    ; New: also pause on any comment with 4 leading spaces (after the #)
    if(RegExMatch(line,"^\s\#\s{4}")) {
      return 1
    }
  }

  return 0
}


; ---- Interactice Edit Macros ----

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
    Send {Enter}{Up}use RapidApp;
  }
  else if(substep = 4) {
    Send {Down 3}
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
    Send {Enter 2}
    SendRaw }
    Send {Up 2}{End}
    Send {Enter}{Delete}{Space 2}
  }
  else if(substep = 8) {
    Send {#} Only required option:{Enter}{Backspace 2}
    Sleep 200
    SendRaw dbic_models => ['Chinook'] 
    Send {Space}{Escape} ; leave INSERT mode
  }
  else if(substep = 9) {
    Send {Z 2} ; Save and exit
  }
  else if(substep = 10) {
    Send {Space}{#} Start the test server:{Enter}
    Sleep 200
    Send script/ra_chinookdemo_server.pl
  }
  else if(substep = 11) {
    Send {Enter}
    Sleep 10000 ; min sleep time
  }
  else if(substep = 12) {
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


