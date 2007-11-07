VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IniWriterTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Sub EmptyWithComment()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Dim iniWriter As iniWriter
    Set iniWriter = NewIniWriter(writer)

    Call Assert.AreEqual(IniWriteState.Start, iniWriter.WriteState)

    iniWriter.WriteEmpty ("First INI file")
    Call Assert.AreEqual("; First INI file", ReadLine(writer, 1))
    Call Assert.AreEqual(IniWriteState.BeforeFirstSection, iniWriter.WriteState)
End Sub


Public Sub EmptyWithoutComment()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Dim iniWriter As iniWriter
    Set iniWriter = NewIniWriter(writer)

    Call Assert.AreEqual(IniWriteState.Start, iniWriter.WriteState)

    Call iniWriter.WriteEmpty
    Call Assert.AreEqual("", ReadLine(writer, 1))
    Call Assert.AreEqual(IniWriteState.BeforeFirstSection, iniWriter.WriteState)
End Sub


Public Sub SectionWithComment()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Dim iniWriter As iniWriter
    Set iniWriter = NewIniWriter(writer)

    Call Assert.AreEqual(IniWriteState.Start, iniWriter.WriteState)

    Call iniWriter.WriteSection("Test Section", "My comment")
    Call Assert.AreEqual("[Test Section] ; My comment", ReadLine(writer, 1))
    Call Assert.AreEqual(IniWriteState.section, iniWriter.WriteState)
End Sub


Public Sub SectionWithoutComment()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Dim iniWriter As iniWriter
    Set iniWriter = NewIniWriter(writer)

    Call Assert.AreEqual(IniWriteState.Start, iniWriter.WriteState)

    iniWriter.WriteSection ("Test Section")
    Call Assert.AreEqual("[Test Section]", ReadLine(writer, 1))
    Call Assert.AreEqual(IniWriteState.section, iniWriter.WriteState)
End Sub


Public Sub KeyWithIndentation()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Dim iniWriter As iniWriter
    Set iniWriter = NewIniWriter(writer)

    iniWriter.Indentation = 2
    iniWriter.WriteSection ("Required")
    Call iniWriter.WriteKey("independence day", "july")
    'Debug.Print "'" & ReadLine(writer, 2) & "'"
    Call Assert.AreEqual("  independence day = july", ReadLine(writer, 2))
    iniWriter.Indentation = 0
End Sub


Public Sub KeyWithQuotesAndComment()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Dim iniWriter As iniWriter
    Set iniWriter = NewIniWriter(writer)

    iniWriter.UseValueQuotes = True
    iniWriter.WriteSection ("Required")
    Call iniWriter.WriteKey("thanksgiving", "November 25th", "Football!")
    iniWriter.UseValueQuotes = False
    Call Assert.AreEqual("thanksgiving = ""November 25th"" ; Football!", ReadLine(writer, 2))
End Sub


Public Sub FlushAndClose()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Dim iniWriter As iniWriter
    Set iniWriter = NewIniWriter(writer)

    Call iniWriter.WriteSection("Required")
    Call iniWriter.WriteKey("thanksgiving", "november 25th", "Football!")

    Call iniWriter.CloseMe
    Call Assert.AreEqual(IniWriteState.Closed, iniWriter.WriteState)
End Sub



Public Sub NotOrderedWriteState()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Dim iniWriter As iniWriter
    Set iniWriter = NewIniWriter(writer)
    
    On Error GoTo MyExit
    Call iniWriter.WriteKey("state", "Out of order")
    
MyExit:
Dim ex As Exception
    If Catch(ex, Err) Then
        If Not TypeOf ex Is InvalidOperationException Then
            Call Assert.Fail("Expected InvalidOperationException from iniWriter.WriteKey('state', 'Out of order') ")
        End If
    Else
        Call Assert.Fail("Expected InvalidOperationException from iniWriter.WriteKey('state', 'Out of order') ")
    End If
End Sub


Public Sub ReplaceEndOfLine()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Dim iniWriter As iniWriter
    Set iniWriter = NewIniWriter(writer)

    Call iniWriter.WriteSection("Required")
    Call iniWriter.WriteKey("thanksgiving", "November" & Chr(10) & " 25th")

    Call Assert.AreEqual("thanksgiving = November 25th", ReadLine(writer, 2))
End Sub

Private Function ReadLine(ByVal writer As StringWriter, ByVal line As Integer) As String
    Dim result As String
    result = ""
    Dim reader As StringReader
    Set reader = NewStringReader(writer.ToString())
    Dim i As Integer
    For i = 1 To line

        If i = line Then
            result = reader.ReadLine()
            Exit For
        End If
        Call reader.ReadLine
    Next

    ReadLine = result
End Function

