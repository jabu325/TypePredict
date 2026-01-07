#NoEnv
#SingleInstance Force
SetBatchLines -1
SendMode Input
SetKeyDelay, 0

; =========================================================================
; --- WORD LIST CONFIGURATION ---
; Files must be in the SAME directory as this script
; =========================================================================

WordFile1 := "Wordlist1.txt"
WordFile2 := "Wordlist2.txt"
WordFile3 := "Wordlist3.txt"
WordFile4 := "WordList4.txt"

AllWordFiles := [WordFile1, WordFile2, WordFile3, WordFile4]

global current := ""
global SuggestionList := Object()
global WordArray := Object()

; =====================
; GUI
; =====================
Gui, +AlwaysOnTop -Caption +ToolWindow
Gui, Color, FFFFCC
Gui, Font, s10, Segoe UI
Gui, Add, Text, vT w320 h160, Type letters and press 1–6 to replace
Gui, Show, x20 y20

; =====================
; LOAD WORD LISTS
; =====================
WordArray := LoadWordLists(AllWordFiles)

if (!IsObject(WordArray) || WordArray.MaxIndex() = "")
{
    MsgBox, 16, Error, Failed to load word lists.
    ExitApp
}

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

~Space::ClearBuffer()
~Backspace::RemoveChar()

*1::SelectSuggestion(1)
*2::SelectSuggestion(2)
*3::SelectSuggestion(3)
*4::SelectSuggestion(4)
*5::SelectSuggestion(5)
*6::SelectSuggestion(6)

return

; =========================================================================
; WORD LIST LOADER (ROBUST)
; =========================================================================
LoadWordLists(Files)
{
    Temp := Object()

    for _, FileName in Files
    {
        FullPath := A_ScriptDir "\" FileName
        if !FileExist(FullPath)
            continue

        Loop, Read, %FullPath%
        {
            word := Trim(A_LoopReadLine)
            if (word = "")
                continue

            StringLower, word, word
            Temp.Insert(word)
        }
    }
    return Temp
}

; =====================
; CORE FUNCTIONS
; =====================
AddChar(c)
{
    global current
    current .= c
    ShowSuggestions()
}

ClearBuffer()
{
    global current, SuggestionList

    ; Reset typing state for the next word
    current := ""
    SuggestionList := Object()

    ; Clear GUI so suggestions don't linger
    GuiControl,, T, Type letters and press 1–6 to replace
}

RemoveChar()
{
    global current
    if (StrLen(current) > 0)
        current := SubStr(current, 1, -1)
    ShowSuggestions()
}

ShowSuggestions()
{
    global current, WordArray, SuggestionList

    SuggestionList := Object()
    text := "Typing: " current "`n"

    if (StrLen(current) < 1)
    {
        GuiControl,, T, % text "`n(start typing letters)"
        return
    }

    text .= "`nPress 1–6 to replace:`n"
    count := 0

    for _, w in WordArray
    {
        if InStr(w, current)
        {
            count++
            SuggestionList[count] := w
            text .= count ". " w "`n"
            if (count >= 6)
                break
        }
    }

    if (count = 0)
        text .= "-- No matches --"

    GuiControl,, T, %text%
}

SelectSuggestion(num)
{
    global current, SuggestionList

    word := SuggestionList[num]
    if (word = "")
        return

    ; SAFELY delete typed fragment
    Loop % StrLen(current)
        Send, {Backspace}

    ; Insert suggestion
    Send, %word%

    current := ""
    SuggestionList := Object()
    GuiControl,, T, Inserted: %word%
}
