Attribute VB_Name = "Module1"
Option Explicit

Global fso As New CFileSystem2

Sub Main()

    Dim path As String
    Dim hash_mode As Boolean
    
    '3.18.20 - noticed if Form1 loaded first, then loads form2 and form1 unloads app terminates? because of submain ?
    
    '2.8.2020 - form1.form_load kept being called over and over again by the runtime
    '           when it was the startup object and we tried to call unload me with another form open
    '           from form_load itself. now moved this to its own submain...
    
    If Len(Command) = 0 Then
        Form1.errorStartup
        Exit Sub
    End If
    
    'bulk can be a raw crlf hash list, or it can be a crlf hash,file list in which case submit is available, as well as file path included in report..
    If InStr(Command, "/bulk") > 0 Then
       If InStr(Command, "/bulktest") > 0 Then
            Clipboard.Clear
            Const limit As Long = 4
            Clipboard.SetText Join(Split("f99e279d071fedc77073c4f979672a3c,e9e63cbcee86fa508856c84fdd5a8438,55c8660374ba2e76aa56012f0e48fbbf,6e7a8fe5ca03d765c1aebf9df7461da9,2f52937aab6f97dbf2b20b3d4a4b1226,c31b2f42c15d3c0080c8c694c569e8,e069c340a2237327e270d9bd5b9ed1dc,ab1de766e7fca8269efe04c9d6f91af0,142b70232a81a067673784e4e99e8165,60bf1bace9662117d5e0f1b2a825e5f3,6e6c35ad1d5271be255b2776f848521,bb41f3db526e35d722409086e3a7d111,00bdaecd9c8493b24488d5be0ff7393a,7b83a45568a8f8d8cdffcef70b95cb05,aa1e8e25bd36c313f4febe200c575fc7,f6e5d212dd791931d7138a106c42376c,e6c129c0694c043d8dda1afa60791cbf,3e4d1b61653fedeba122b33d15e1377d,48821e738e56d8802a89e28e1cab224d", ",", limit), vbCrLf)
       End If
       Form1.Show
       Form1.mnuAddHashs_Click
       Form1.cmdQuery_Click
       
    ElseIf InStr(Command, "/submit") > 0 Then
        
        If InStr(Command, "/submitbulk") > 0 Then
            frmSubmit.SubmitBulk
        Else
           path = Replace(Command, """", Empty)
           path = Replace(path, "/submit", Empty)
           path = Trim(path)
           If Not fso.FileExists(path) Then
                MsgBox "File not found for /submit path=" & path, vbInformation
                End
           End If
           frmSubmit.SubmitFile CStr(path)
        End If
        
    Else
        hash_mode = (Left(LCase(Command), 5) = "/hash")
        path = Replace(Command, """", Empty)
        If hash_mode Then path = Replace(path, "/hash", Empty)
        path = Trim(path)
        
        If Len(path) = 0 Then
            Form1.errorStartup
            Exit Sub
        End If
            
        If hash_mode Then
            Form2.StartFromHash path
        Else
            If Not fso.FileExists(path) Then
                Form1.errorStartup
                Exit Sub
            End If
            Form2.StartFromFile path
        End If

    End If

End Sub

Function GetCompileTime(Optional ByVal exe As String) As String
    
    Dim f As Long, i As Integer
    Dim stamp As Long, e_lfanew As Long
    Dim base As Date, compiled As Date

    On Error GoTo errExit
    
    FileLen exe 'throw error if not exist
    
    f = FreeFile
    Open exe For Binary Access Read As f
    Get f, , i
    
    If i <> &H5A4D Then GoTo errExit 'MZ check
     
    Get f, 60 + 1, e_lfanew
    Get f, e_lfanew + 1, i
    
    If i <> &H4550 Then GoTo errExit 'PE check
    
    Get f, e_lfanew + 9, stamp
    Close f
    
    base = DateSerial(1970, 1, 1)
    compiled = DateAdd("s", stamp, base)
    GetCompileTime = Format(compiled, "ddd, mmm d yyyy, h:nn:ss ")
    
    Exit Function
errExit:
    Close f
        
End Function

Function lvGetAllElements(lv As Object) As String
    Dim ret() As String, i As Integer, tmp As String
    Dim lI 'As ListItem
    
    On Error Resume Next
    
    For i = 1 To lv.ColumnHeaders.count
        tmp = tmp & lv.ColumnHeaders(i).Text & vbTab
    Next
    
    push ret, tmp
    push ret, String(50, "-")
        
    For Each lI In lv.ListItems
        tmp = lI.Text & vbTab
        For i = 1 To lv.ColumnHeaders.count - 1
            tmp = tmp & lI.subItems(i) & vbTab
        Next
        push ret, tmp
    Next
    
    lvGetAllElements = Join(ret, vbCrLf)
    
End Function

Public Sub lvColumnSort(ListViewControl As Object, Column As Object)
    On Error Resume Next
    Const lvwAscending As Long = 0
    Const lvwDescending As Long = 1
     
    With ListViewControl
       If .SortKey <> Column.index - 1 Then
             .SortKey = Column.index - 1
             .SortOrder = lvwAscending
       Else
             If .SortOrder = lvwAscending Then
              .SortOrder = lvwDescending
             Else
              .SortOrder = lvwAscending
             End If
       End If
       .Sorted = -1
    End With
End Sub

Sub push(ary, Value) 'this modifies parent ary object
    On Error GoTo Init
    Dim X
       
    X = UBound(ary)
    ReDim Preserve ary(X + 1)
    
    If IsObject(Value) Then
        Set ary(X + 1) = Value
    Else
        ary(X + 1) = Value
    End If
    
    Exit Sub
Init:
    ReDim ary(0)
    If IsObject(Value) Then
        Set ary(0) = Value
    Else
        ary(0) = Value
    End If
End Sub
