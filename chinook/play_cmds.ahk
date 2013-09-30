;# This AutoHotKey macro script plays a series of commands
;# and shell interactions for the "Chinook" RapidApp demo video
;# (Note that this is built expecting a specfic environment)

#Include funcs.ahk

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

;skip_to = EditMacroCrudOpts
;skip_to = at_commit_5
exit_at = END_SCRIPT

bypass_test_server = 0
fake_db_setup = 1


ResetDefaultKeyDelay()

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

ResetDefaultKeyDelay() {
  SetKeyDelay, 15
}


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
  ResetDefaultKeyDelay()
  
  if(name = "RunTestServer") {
    if(bypass_test_server) {
      return 1
    }
    return RunTestServer(seq)
  }
  
  else if(name = "CreateSQLiteDB") {
    return CreateSQLiteDB(seq)
  }
  
  else if(name = "EditMacroOne") {
    return EditMacroOne(seq)
  }
  else if(name = "EditMacroTwo") {
    return EditMacroTwo(seq)
  }
  else if(name = "EditMacroThree") {
    return EditMacroThree(seq)
  }
  else if(name = "EditMacroFour") {
    return EditMacroFour(seq)
  }
  else if(name = "EditMacroCrudOpts") {
    return EditMacroCrudOpts(seq)
  }
  else if(name = "EditMacroAuthCore") {
    return EditMacroAuthCore(seq)
  }
  else if(name = "EditMacroCoreAdmin") {
    return EditMacroCoreAdmin(seq)
  }
  else if(name = "EditMacroNavCore") {
    return EditMacroNavCore(seq)
  }
  else if(name = "EditMacroEditorType") {
    return EditMacroEditorType(seq)
  }
  else if(name = "EditMacroVirtualColumn") {
    return EditMacroVirtualColumn(seq)
  }
  else if(name = "EditMacroVirtColWritable") {
    return EditMacroVirtColWritable(seq)
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
      ResetDefaultKeyDelay()
      active_macro := MacName
      return
    }
    
    is_speedup = 0

    ; Check for speed-up flag
    if(is_pause && InStr(line,speed_up_str)) {
      is_pause = 0
      is_speedup = 1
    }
    
    ; New/Override: make all comments speedups:
    if(is_comment) {
      is_speedup = 1
    }
    
    if(is_speedup) {
      SetKeyDelay, 1
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
    ResetDefaultKeyDelay()
    
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
    vimNewHashCnf("'Plugin::RapidApp::RapidDbic'",1)
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
    vimJumpStringTop("__PACKAGE__",0)
    Sleep 200
    vimJumpString("dbic_models",0)
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}{Backspace}
    Sleep 500
    Send {,}{Enter}
    vimNewHashCnf("configs","Model Configs")
  }
  else if(seq = 4) {
    vimNewHashCnf("DB","Configs for the model 'DB'")
  }
  else if(seq = 5) {
    vimNewHashCnf("grid_params",1)
  }
  else if(seq = 6) {
    vimNewHashCnf("Album",0)
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
  else if(seq = 9) {
    Send {Down}{Enter}
    vimNewHashCnf("Track",0)
  }
  else if(seq = 10) {
    SendRaw include_colspec => ['*','albumid.artistid.*']
    Send {Space}
  }
  else if(seq = 11) {
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

EditMacroThree(seq) {
  global
  Sleep 500
  if(seq = 1) {
    Send {Space}{#} Set 'display_column' for Sources{Enter}
    Send vim lib/RA/ChinookDemo.pm
  }
  else if(seq = 2) {
    Send {Enter}
  }
  else if(seq = 3) {
    vimJumpStringTop("DB",0)
    Sleep 200
    vimJumpString("(grid_params",0)
    Sleep 500
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}{Enter}
    vimNewHashCnf("TableSpecs",1)
  }
  else if(seq = 4) {
    vimNewHashCnf("Album",0)
    SendRaw display_column => 'title'
  }
  else if(seq = 5) {
    Send {Down}{End}{Enter}
    vimNewHashCnf("Artist",0)
    SendRaw display_column => 'name'
  }
  else if(seq = 6) {
    Send {Down}{End}{Enter}
    vimNewHashCnf("Genre",0)
    SendRaw display_column => 'name'
  }
  else if(seq = 7) {
    Send {Down}{End}{Enter}
    vimNewHashCnf("MediaType",0)
    SendRaw display_column => 'name'
  }
  else if(seq = 8) {
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


EditMacroFour(seq) {
  global
  Sleep 500
  if(seq = 1) {
    Send {Space}{#} Enable grid editing{Enter}
    Send vim lib/RA/ChinookDemo.pm
  }
  else if(seq = 2) {
    Send {Enter}
  }
  else if(seq = 3) {
    vimJumpStringTop("__PACKAGE__",0)
    Sleep 200
    vimJumpString("grid_params",0)
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}{Enter}{Tab}
    vimNewHashCnf("'*defaults'","Defaults for all Sources")
    SendRaw updatable_colspec => ['*'],
    Send {Enter}
    SendRaw creatable_colspec => ['*'],
    Send {Enter}
    SendRaw destroyable_relspec => ['*']
  }
  else if(seq = 4) {
    Send {Escape}
    Sleep 200
    ;vimJumpStringTop("__PACKAGE__",0)
    ;Sleep 200
    vimJumpString("Album",0)
    Sleep 500
    vimJumpString("{}}",0)
    ;Send {Down 2}
    Sleep 500
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}{Enter}
    vimNewHashCnf("InvoiceLine",0)
  }
  else if(seq = 5) {
    SendRaw include_colspec => ['*','*.*'],
  }
  else if(seq = 6) {
    Send {Up}{End}{Enter}{Tab}
    SendRaw # join all columns of all relationships (first-level):
    Send {Down}{End}{Enter}
  }
  else if(seq = 7) {
    vimNewArrCnf("updatable_colspec",0)
  }
  else if(seq = 8) {
    SendRaw 'unitprice','quantity',
    Send {Enter}
  }
  else if(seq = 9) {
    SendRaw 'invoiceid.billing*'
  }
  else if(seq = 10) {
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


EditMacroCrudOpts(seq) {
  global
  Sleep 500
  if(seq = 1) {
    Send {Space}{#} Set custom CRUD options{Enter}
    Send vim lib/RA/ChinookDemo.pm
  }
  else if(seq = 2) {
    Send {Enter}
  }
  else if(seq = 3) {
    vimJumpStringTop("__PACKAGE__",0)
    Sleep 200
    vimJumpString("grid_params",0)
    Sleep 200
    vimJumpString("Track",0)
    Sleep 200
    vimJumpString("include_colspec",0)
    Sleep 200
    Sleep 500
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}{Backspace}{,}{Enter}
    vimNewHashCnf("persist_immediately",0)
  }
  else if (seq = 4) {
    SendRaw create  => 0,
    Send {Enter}
    SendRaw update  => 0,
    Send {Enter}
    SendRaw destroy => 0
    Sleep 500
    Send {Up 4}{End}{Enter}
    SendRaw # Don't persist anything immediately:
  }
  else if (seq = 5) {
    Send {Down}{End}{Enter}{Tab}
    SendRaw # 'create => 0' changes these defaults:
    Sleep 500
    Send {Enter}{Space 2}
    SendRaw use_add_form => '0' (normally 'tab')
    Sleep 500
    Send {Enter}
    SendRaw autoload_added_record => 0 (normally '1')
  }
  else if (seq = 6) {
    Send {Down 4}{End}{Enter}
    SendRaw use_add_form => 'window'
    Sleep 500
    Send {Up}{End}{Enter}
    SendRaw # Use the add form in a window:
  }
  else if (seq = 7) {
    Send {Up 12}{End}{Enter}
    vimNewHashCnf("MediaType",0)
  }
  else if (seq = 8) {
    SendRaw # Use the grid itself to set new row values:
    Sleep 500
    Send {Enter}{Backspace 2}
    SendRaw use_add_form => 0, #<-- also disables autoload_added_record
  }
  else if (seq = 9) {
    Send {Enter}
    vimNewHashCnf("persist_immediately",0)
    SendRaw create  => 0,
    Send {Enter}
    SendRaw update  => 1,
    Send {Enter}
    SendRaw destroy => 1
  }
  else if (seq = 10) {
    Send {Down}{End}{Enter}
    SendRaw confirm_on_destroy => 0
    Sleep 500
    Send {Up}{End}{Enter}
    SendRaw # No delete confirmations:
  }
  else if (seq = 11) {
    Send {Up 17}{End}{Enter}
    vimNewHashCnf("Genre",0)
  }
  else if (seq = 12) {
    SendRaw # Leave persist_immediately on without the add form
    Sleep 500
    Send {Enter}
    SendRaw (inserts blank/default rows immediately):
    Sleep 500
    Send {Enter}{Backspace 2}
    SendRaw use_add_form => 0
  }
  else if (seq = 13) {
    Send {,}{Enter}
    SendRaw # No delete confirmations:
    Send {Enter}{Backspace 2}
    SendRaw confirm_on_destroy => 0
  }
  else if (seq = 14) {
    Send {Down}{End}{Enter}
    vimNewHashCnf("Invoice",0)
  }
  else if (seq = 15) {
    SendRaw # Delete invoice_lines with invoice (cascade):
    Sleep 500
    Send {Enter}{Backspace 2}
    SendRaw destroyable_relspec => ['*','invoice_lines']
  }
  else if(seq = 16) {
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



EditMacroEditorType(seq) {
  global
  Sleep 500
  if(seq = 1) {
    Send {Space}{#} Set certain Sources to be dropdowns {Enter}
    Send vim lib/RA/ChinookDemo.pm
  }
  else if(seq = 2) {
    Send {Enter}
  }
  else if(seq = 3) {
    vimJumpStringTop("TableSpecs",0)
    Sleep 200
    vimJumpString("Genre",0)
    Sleep 100
    Send {Down}
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}{,}{Enter}
    SendRaw auto_editor_type => 'grid'
  }
  else if(seq = 4) {
    Send {Left}{Backspace 4}combo
  }
  else if(seq = 5) {
    Send {Down 4}{End}{Enter}
    vimNewHashCnf("Track",0)
  }
  else if(seq = 6) {
    vimNewHashCnf("columns",0)
  }
  else if(seq = 7) {
    vimNewHashCnf("bytes",0)
  }
  else if(seq = 8) {
    SendRaw renderer => 'Ext.util.Format.fileSize'
    Sleep 500
    Send {,}{Enter}
    SendRaw header => 'Size'
  }
  else if(seq = 9) {
    Send {Down}{End}{Enter}
    vimNewHashCnf("unitprice",0)
    Sleep 500
    SendRaw renderer => 'Ext.util.Format.usMoney'
    Sleep 500
    Send {,}{Enter}
    SendRaw header => 'Unit Price'
  }
  else if(seq = 10) {
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


EditMacroVirtualColumn(seq) {
  global
  Sleep 500
  if(seq = 1) {
    Send {Space}{#} Setup a virtual column{Enter}
    Send vim lib/RA/ChinookDemo.pm
  }
  else if(seq = 2) {
    Send {Enter}
  }
  else if(seq = 3) {
    vimJumpStringTop("DB",0)
    Sleep 200
    vimJumpString("(grid_params",0)
    Sleep 500
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}{Enter}
    vimNewHashCnf("virtual_columns",1)
  }
  else if(seq = 4) {
    vimNewHashCnf("Employee",0)
  }
  else if(seq = 5) {
    vimNewHashCnf("full_name",0)
    SendRaw data_type => "varchar",
    Send {Enter}
    SendRaw is_nullable => 0,
    Send {Enter}
    SendRaw size => 255,
  }
  else if(seq = 6) {
    Send {Enter}
    SendRaw sql => 'SELECT self.firstname || " " || self.lastname'
  }
  else if(seq = 7) {
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

EditMacroVirtColWritable(seq) {
  global
  Sleep 500
  if(seq = 1) {
    Send {Space}{#} Make virtual column writable{Enter}
    Send vim lib/RA/ChinookDemo.pm
  }
  else if(seq = 2) {
    Send {Enter}
  }
  else if(seq = 3) {
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}{,}{Enter}
    vimNewHashSub("set_function",0)
  }
  else if(seq = 4) {
    SendRaw my ($row, $value) = @_;
    Send {Enter}
  }
  else if(seq = 5) {
    SendRaw my ($fn, $ln) = split(/\s+/,$value,2);
    Send {Enter}
  }
  else if(seq = 6) {
    SendRaw $row->update({ firstname=>$fn, lastname=>$ln });
  }
  else if(seq = 7) {
    Send {Escape}
    Sleep 200
    vimJumpString("Genre",0)
    Sleep 200
    Send i ; go into INSERT mode
    Sleep 500
    Send {Enter}{Up}
    vimNewHashCnf("Employee",0)
  }
  else if(seq = 8) {
    SendRaw display_column => 'full_name'
  }
  else if(seq = 9) {
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


EditMacroAuthCore(seq) {
  global
  Sleep 500
  if(seq = 1) {
    Send {Space}{#} Enable AuthCore to password protect site{Enter}
    Send vim lib/RA/ChinookDemo.pm
  }
  else if(seq = 2) {
    Send {Enter}
  }
  else if(seq = 3) {
    vimJumpStringTop("RapidApp::RapidDbic",0)
    Sleep 200
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}{Enter}
    SendRaw RapidApp::AuthCore
  }
  else if(seq = 4) {
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

EditMacroCoreAdmin(seq) {
  global
  Sleep 500
  if(seq = 1) {
    Send {Space}{#} Enable basic access to user management{Enter}
    Send vim lib/RA/ChinookDemo.pm
  }
  else if(seq = 2) {
    Send {Enter}
  }
  else if(seq = 3) {
    vimJumpStringTop("RapidApp::AuthCore",0)
    Sleep 200
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}{Enter}
    SendRaw RapidApp::CoreSchemaAdmin
  }
  else if(seq = 4) {
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

EditMacroNavCore(seq) {
  global
  Sleep 500
  if(seq = 1) {
    Send {Space}{#} Enable NavCore for saved views{Enter}
    Send vim lib/RA/ChinookDemo.pm
  }
  else if(seq = 2) {
    Send {Enter}
  }
  else if(seq = 3) {
    vimJumpStringTop("RapidApp::CoreSchemaAdmin",0)
    Sleep 200
    Send i ; go into INSERT mode
    Sleep 500
    Send {End}{Enter}
    SendRaw RapidApp::NavCore
  }
  else if(seq = 4) {
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


CreateSQLiteDB(seq) {
  global
  if(seq = 1) {
    if(fake_db_setup) {
      SendRaw cp ../chinook.db .
      return 1 ; finished
    }
    else {
      ;SendRaw sqlite3 chinook.db < sql/Chinook_Sqlite.sql
      SendRaw sqlite3 chinook.db < sql/Chinook_Sqlite_AutoIncrementPKs.sql
      
    }
  }
  else if(seq = 2) {
    Send {Home}
  }
  else if(seq = 3) {
    Send time{Space}
  }
  else if(seq = 4) {
    Send {End}
  }
  else if(seq = 5) {
    Send {Enter}
  }
  else {
    auto_next = 0 ;<-- break auto_next
    no_newline_prefix = 1
    return 1 ; finished
  }
  return 0 ; not finished
}


RunTestServer(seq) {
  global
  if(seq = 1) {
    Send {Space}{#} Start the test server:{Enter}
    Sleep 200
    Send script/ra_chinookdemo_server.pl
  }
  else if(seq = 2) {
    Send {Enter}
    Sleep 5000 ; min sleep time
    auto_next = 0 ;<-- break auto_next
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


