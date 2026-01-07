#NoEnv
#SingleInstance Force
SetBatchLines -1
SendMode Input

; =========================================================================
; --- DYNAMIC WORD LIST CONFIGURATION ---
; Files must be in the same directory as this script.
; =========================================================================

WordFile1 := "Wordlist1.txt"
WordFile2 := "Wordlist2.txt"
WordFile3 := "Wordlist3.txt"
WordFile4 := "WordList4.txt"
AllWordFiles := [WordFile1, WordFile2, WordFile3, WordFile4]

; =====================
; GUI
; =====================
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, FFFFCC
Gui, Font, s10, Segoe UI
Gui, Add, Text, vT w300 h120, Type letters...
Gui, Show, x20 y20

current := ""

; -------------------------------------------------------------------------
; REPLACEMENT: Dynamically load the WordArray from the text files.
; -------------------------------------------------------------------------
WordArray := LoadWordLists(AllWordFiles)

; Check if loading failed (LoadWordLists returns False on error)
if (!IsObject(WordArray)) {
    MsgBox, 16, Error, Failed to load one or more word lists. Please check file paths and permissions. Script will exit.
    ExitApp
}

; Use MaxIndex() for AHK v1 array size
MsgBox % "Loaded words: " WordArray.MaxIndex()

; =====================
; HOTKEYS
; =====================
~a::AddChar("a")
~b::AddChar("b")
~c::AddChar("c")
~d::AddChar("d")
~e::AddChar("e")
~f::AddChar("f")
~g::AddChar("g")
~h::AddChar("h")
~i::AddChar("i")
~j::AddChar("j")
~k::AddChar("k")
~l::AddChar("l")
~m::AddChar("m")
~n::AddChar("n")
~o::AddChar("o")
~p::AddChar("p")
~q::AddChar("q")
~r::AddChar("r")
~s::AddChar("s")
~t::AddChar("t")
~u::AddChar("u")
~v::AddChar("v")
~w::AddChar("w")
~x::AddChar("x")
~y::AddChar("y")
~z::AddChar("z")

~Backspace::RemoveChar()

return

; =========================================================================
; --- DYNAMIC WORD LIST LOADING FUNCTION (AHK v1) ---
; =========================================================================
LoadWordLists(Files)
{
    Local TempArray := [] ; AHK v1 array (Object)
    
    for index, FileName in Files
    {
        FileRead, FileContent, %A_ScriptDir%\%FileName%
        
        if (ErrorLevel) {
            return False ; Signal failure
        }

        ; Normalize line endings and split by newline
        StringReplace, FileContent, FileContent, `r, , All 
        
        Loop, parse, FileContent, `n
        {
            Word := A_LoopField
            Word := RegExReplace(Word, "^\s*|\s*$", "") ; Trim whitespace
            
            if (Word = "")
                continue
            
            ; Convert to lowercase for case-insensitive prefix searching
            StringLower, WordLower, Word 
            TempArray.Push(WordLower) ; Add the word to the array
        }
    }
    return TempArray
}

; =====================
; FUNCTIONS
; =====================
AddChar(c) {
    global current
    current .= c
    ShowSuggestions()
}


RemoveChar() {
    global current
    ; FIX for AHK v1: SubStr(current, 1, -1) is invalid. 
    ; Must use StrLen to determine length before removing the last character.
    current := SubStr(current, 1, StrLen(current) - 1)
    ShowSuggestions()
}

ShowSuggestions() {
    global current, WordArray

    if (StrLen(current) < 2) {
        GuiControl,, T, Type letters...
        return
    }

    text := "Suggestions:`n"
    count := 0

    ; NOTE: This prefix search logic remains the same as your template.
    for i, w in WordArray {
        if (SubStr(w, 1, StrLen(current)) = current) {
            text .= "- " w "`n"
            if (++count >= 5)
                break
        }
    }

    GuiControl,, T, %text%
}