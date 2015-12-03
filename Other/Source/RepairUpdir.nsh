 ; RepairUpdir  - repair ../ path names to good names
 ; input, top of stack = pathname with ../
 ; output, top of stack
 ; modifies no other variables.
 ;
 ; Usage:
 ; Push "A:\B\..\C\D\..\E.txt"
 ; Call RepairUpdir
 ; Pop $R0; $R0 is now "A:\C\E.txt"
 
 Function RepairUpdir
  Exch $R0
  Push $R1
  Push $R2  ; strlen(orgstr)
  Push $R3  ; tempchar
  Push $R4  ; pos of last good '/' before '/..'
 
  restart:
  StrCpy $R1 -1   ; position of where last good / is
  StrCpy $R4 -1
  StrLen $R2 $R0
 
  loop:
    IntOp $R1 $R1 + 1 ; pos++
    IntCmp $R1 $R2 cut 0 cut
    ; 3 chars at cur pos
    StrCpy $R3 $R0 3 $R1
    StrCmp $R3 "\.." get
    StrCmp $R3 "/.." get
    ; single char at cur pos
    StrCpy $R3 $R0 1 $R1
    StrCmp $R3 "/" set
    StrCmp $R3 "\" set
 
    Goto loop
  ; Remember the last "/" position
  set:
    StrCpy $R4 $R1
    Goto loop
  ; Now delete from $R4 to $R1
  get:
    ; Make sure we fond somehting good
    IntCmp $R1 $R4 cut cut 0
    ; left part
    StrCpy  $R3 $R0 $R4  ; C:\
    ; right part
    IntOp  $R1 $R1 + 3   ; $R1-=4
    StrCpy $R4 $R0 $R2 $R1;
    StrCpy $R0 $R3$R4
    ; Now we have to redo this for multiple occurrences of /..
    goto restart
 
cut: ; Nothing happened
    Pop $R4
    Pop $R3
    Pop $R2
    Pop $R1
    Exch $R0
 FunctionEnd