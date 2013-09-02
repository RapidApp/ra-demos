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
active_macro_seq = 0
skip_to = 0
exit_at = 0

;skip_to = EditMacroTwo
exit_at = END_SCRIPT

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
    active_macro_seq++
    finished := CallMacro(active_macro,active_macro_seq)
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

; If AHK had simple eval support, we wouldn't need this
CallMacro(name,seq) {
  global
  SetKeyDelay, 10
  
  if(name = "EditMacroOne") {
    return EditMacroOne(seq)
  }
  else if(name = "EditMacroTwo") {
    return EditMacroTwo(seq)
  }
  else if(name = "RunTestServer") {
    return RunTestServer(seq)
  }
  
  
  MsgBox Unknown Macro Name '%name%' - exiting!
  ExitApp
}

FinishMacro() {
  global
  active_macro = 0
  active_macro_seq = 0
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
  
    FileReadLine, line, cmd_script.txt, %indx%
    if(ErrorLevel) {
      ExitApp
    }
    indx++
    
    if(skip_to = 0 && exit_at <> 0) {
      if(InStr(line,exit_at)) {
        ExitApp
      }
    }
    
    if(skip_to <> 0) {
      if(InStr(line,skip_to)) {
        skip_to = 0 ; turn off for rest of script
      }
      else {
        return AdvanceNextLine()
      }
    }
    
    if(no_newline_prefix) {
      ; Turn off for next call:
      no_newline_prefix = 0
    }
    else {
      SendPlay {Enter}
    }
    
    is_comment := IsCommentLine(line)
    is_pause := IsPauseLine(line)
    
    ; Jump into named Macro:
    MacName := GetMacroName(line)
    if(is_comment && MacName <> 0) {
      ; restore normal key delay (ends any speedup)
      SetKeyDelay, 10
      active_macro := MacName
      return
    }

    ; Check for speed-up flag
    if(is_pause && InStr(line,speed_up_str)) {
      is_pause = 0
      SetKeyDelay, 0
    }
    
    SendRaw %line%
    
    ; If we're a comment line (that is not a pause):
    if(is_comment = 1 && is_pause = 0) {
      ; Look ahead and advance to the next line if its a comment, too
      FileReadLine, nextline, cmd_script.txt, %indx%
      if(IsCommentLine(nextline) && !ErrorLevel) {
        return AdvanceNextLine()
      }
    }

    ; restore normal key delay (ends any speedup)
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

; Gets a macro name from a special comment line:
; # <[SomeLabel]>
GetMacroName(line) {
  global
  
  if(RegExMatch(line,"^\s*\#\s{1}\<\[")) {
  
    op = [
    cl = ]
    OpenPos := InStr(line,op)
    ClosePos := InStr(line,cl)
    
    if(OpenPos) {
      OpenPos++
      Len := ClosePos - OpenPos
      MacName := SubStr(line,OpenPos,Len)
      return MacName
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


; ---- Interactive Edit Macros ----

EditMacroOne(seq) {
  global
  Sleep 500
  if(seq = 1) {
    Send {Space}{#} Configure bare-bones RapidDbic:{Enter}
    Send vim lib/RA/ChinookDemo.pm
  }
  else if(seq = 2) {
    Send {Enter}
  }
  else if(seq = 3) {
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
  else if(seq = 4) {
    Send {Down 3}
    Send {End}
    Send {Enter}
    Sleep 300
    Send RapidApp::RapidDbic
  }
  else if(seq = 5) {
    Send {Escape} ; leave INSERT mode
    Sleep 300
    Send {Down}
    Loop, 2 { ; Delete the other plugins
      Send {d 2}
      Sleep 300
    }
  }
  else if(seq= 6) {
    Send {Down 6}
    Sleep 500
    Loop, 8 { ; Delete the comments
      Send {d 2}
      Sleep 30
    }
    Sleep 500
  }
  else if(seq = 7) {
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
    Send {Enter}{Delete}{Space 3}
  }
  else if(seq = 8) {
    Send {#} Only required option:{Enter}{Backspace 2}
    Sleep 200
    SendRaw dbic_models => ['DB'] 
    Send {Space}{Escape} ; leave INSERT mode
  }
  else if(seq= 9) {
    Send {Z 2} ; Save and exit
    no_newline_prefix = 1
    return 1 ; finished
  }
  else {
    return 1 ; finished
  }
  return 0 ; not finished
}


EditMacroTwo(seq) {
  global
  Sleep 500
  if(seq = 1) {
    Send {Space}{#} Configure joined columns{Enter}
    Send vim lib/RA/ChinookDemo.pm
  }
  else if(seq = 2) {
    Send {Enter}
  }
  else if(seq = 3) {
    Send :40{Enter} ; goto line 40 (to scroll down)
    Sleep 300
    Send :26{Enter} ; goto line 26
    Sleep 500
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}{Backspace}
    Sleep 500
    Send {,}{Enter}
    SendRaw configs => {
    Send {Enter 2}
    SendRaw }
    Send {Up 2}{End}
    Send {Enter}{Delete}{Space 3}
  }
  else if(seq = 4) {
    SendRaw DB => {
    Send {Enter 2}
    SendRaw }
    Send {Up 2}{End}
    Send {Enter}{Delete}{Space 3}
  }
  else if(seq = 5) {
    SendRaw grid_params => {
    Send {Enter 2}
    SendRaw }
    Send {Up 2}{End}
    Send {Enter}{Delete}{Space 3}
  }
  else if(seq = 6) {
    SendRaw Album => {
    Send {Enter 2}
    SendRaw }
    Send {Up 2}{End}
    Send {Enter}{Delete}{Space 3}
  }
  else if(seq = 7) {
    SendRaw include_colspec => ['*']
    Send {Space}
  }
  else if(seq = 8) {
    Send {Left 2}
    Sleep 400
    Send {,}'artistid.name'
    Send {Right 2}
  }
  else if(seq= 9) {
    Send {Escape}
    Sleep 200
    Send {Z 2} ; Save and exit
    no_newline_prefix = 1
    return 1 ; finished
  }
  else {
    return 1 ; finished
  }

  return 0 ; not finished
}


; --------------------

RunTestServer(seq) {
  if(seq = 1) {
    Send {Space}{#} Start the test server:{Enter}
    Sleep 200
    Send script/ra_chinookdemo_server.pl
  }
  else if(seq = 2) {
    Send {Enter}
    Sleep 10000 ; min sleep time
  }
  else if(seq = 3) {
    ; stop the test server
    Send ^c
    Sleep 500
  }
  else {
    no_newline_prefix = 1
    return 1 ; finished
  }
  return 0 ; not finished
}


