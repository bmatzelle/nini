VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IniReaderTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'#Region "General Tests"
'<Test()>
Public Sub NormalComment()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("")
    writer.WriteLine (" ; Something")
    writer.WriteLine (" ;   Some comment  ")
    writer.WriteLine (" ;")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))

    Call Assert.AreEqual(IniReadState.Initial, reader.ReadState)
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual(IniReadState.Interactive, reader.ReadState)
    Call Assert.AreEqual(my_iniType.EmptyItem, reader.iniType)
    Call Assert.AreEqual("", reader.Name)
    Call Assert.AreEqual("", reader.Comment)

    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual(my_iniType.EmptyItem, reader.iniType)
    Call Assert.AreEqual("Something", reader.Comment)

    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual(my_iniType.EmptyItem, reader.iniType)
    Call Assert.AreEqual("Some comment", reader.Comment)

    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("", reader.Comment)

    Assert.IsFalse (reader.Read())
End Sub

'<Test()>
Public Sub NormalSectionAndKey()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Logging]")
    writer.WriteLine (" great logger =   log4net  ")
    writer.WriteLine ("  [Pets] ; pets comment  ")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))

    Call Assert.AreEqual(IniReadState.Initial, reader.ReadState)
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual(IniReadState.Interactive, reader.ReadState)
    Call Assert.AreEqual(my_iniType.Section, reader.iniType)
    Call Assert.AreEqual("Logging", reader.Name)
    Call Assert.AreEqual("", reader.Value)
    'Assert.IsNull (reader.Comment)

    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual(my_iniType.Key, reader.iniType)
    Call Assert.AreEqual("great logger", reader.Name)
    Call Assert.AreEqual("log4net", reader.Value)
    Call Assert.AreEqual("", reader.Comment)

    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual(my_iniType.Section, reader.iniType)
    Call Assert.AreEqual("Pets", reader.Name)
    Call Assert.AreEqual("", reader.Value)
    'Assert.IsNull (reader.Comment)
End Sub

'<Test()>
Public Sub KeyWithQuotes()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Nini]")
    writer.WriteLine ("  whitespace = ""  remove thing""  ")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))

    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual(my_iniType.Key, reader.iniType)
    Call Assert.AreEqual("whitespace", reader.Name)
    Call Assert.AreEqual("  remove thing", reader.Value)
    Call Assert.AreEqual("", reader.Comment)

    Call Assert.IsFalse(reader.Read())
End Sub

'<Test()>
'<ExpectedException(GetType(IniException))>
Public Sub SectionWithNoEndBracket()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Nini")
    writer.WriteLine ("")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
On Error GoTo CatchMe
    Assert.IsTrue (reader.Read())

CatchMe:
Dim ex As Exception
    If Catch(ex, Err) Then
        If Not TypeOf ex Is IniException Then
            Assert.Fail ("expected IniException but got " & ex.ToString)
        End If
    Else
        Assert.Fail ("expected IniException but got Nothing")
    End If
End Sub

'[ExpectedException (typeof (IniException))]
'<Test()>
Public Sub LinePositionAndNumber()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("; Test")
    writer.WriteLine ("; Test 1")
    writer.WriteLine ("[Nini Thing")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))

    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())

    On Error GoTo CatchMe
        Call reader.Read
        
CatchMe:
Dim ex As Exception
Dim iniEx As IniException
    If Catch(ex, Err) Then
        If Not TypeOf ex Is IniException Then
            Assert.Fail ("expected IniException but got " & ex.ToString)
        Else
            Set iniEx = ex
            Call Assert.AreEqual(3, iniEx.LineNumber)
            Call Assert.AreEqual(13, iniEx.LinePosition)
        End If
    Else
        Assert.Fail ("expected IniException but got Nothing")
    End If
        
    
End Sub

'<Test()>
Public Sub KeysWithSameName()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Nini]")
    writer.WriteLine (" superkey = legal ")
    writer.WriteLine ("[Pets]")
    writer.WriteLine (" superkey = legal ")
    writer.WriteLine (" superkey = overrides original ")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))

    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())

    Call reader.Read
End Sub

'<Test()>
Public Sub SectionsWithSameName()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Nini]")
    writer.WriteLine (" some key = something")
    writer.WriteLine ("[Nini]")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))

    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    On Error GoTo CatchMe
        Call reader.Read
CatchMe:
Dim ex As IniException
    If Catch(ex, Err) Then
        Call Assert.AreEqual(3, ex.LineNumber)
        Call Assert.AreEqual(6, ex.LinePosition)
    End If
End Sub

'<Test()>
Public Sub IgnoreComments()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Nini]")
    writer.WriteLine (" some key = something ; my comment 1")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))

    Assert.IsTrue (reader.Read())
    reader.IgnoreComments = True
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("", reader.Comment)
End Sub

'<Test()>
'<ExpectedException(GetType(IniException))>
Public Sub NoEndingQuote()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Nini]")
    writer.WriteLine (" some key = "" something ")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    On Error GoTo CatchMe
    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())

CatchMe:
Dim ex As Exception
    If Catch(ex, Err) Then
        If Not TypeOf ex Is IniException Then
            Assert.Fail ("expected IniException but got " & ex.ToString)
        End If
    Else
        Assert.Fail ("expected IniException but got Nothing")
    End If
End Sub

'<Test()>
'<ExpectedException(GetType(IniException))>
Public Sub KeyWithNoEquals()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Nini]")
    writer.WriteLine (" some key ")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    
    On Error GoTo CatchMe
    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())

CatchMe:
Dim ex As Exception
    If Catch(ex, Err) Then
        If Not TypeOf ex Is IniException Then
            Assert.Fail ("expected IniException but got " & ex.ToString)
        End If
    Else
        Assert.Fail ("expected IniException but got Nothing")
    End If
End Sub

'<Test()>
Public Sub MoveToNextSection()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("; Test")
    writer.WriteLine ("; Test 1")
    writer.WriteLine ("[Nini Thing]")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))

    Assert.IsTrue (reader.MoveToNextSection())
    Call Assert.AreEqual(4, reader.LineNumber)
    Call Assert.AreEqual(my_iniType.Section, reader.iniType)
    Assert.IsFalse (reader.MoveToNextSection())
End Sub

'<Test()>
Public Sub MoveToNextKey()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("; Test")
    writer.WriteLine ("; Test 1")
    writer.WriteLine ("[Nini Thing]")
    writer.WriteLine ("; Test")
    writer.WriteLine (" my key = new key")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))

    Assert.IsFalse (reader.MoveToNextKey())
    Call Assert.AreEqual(4, reader.LineNumber)
    Assert.IsTrue (reader.MoveToNextKey())
    Call Assert.AreEqual(6, reader.LineNumber)
    Call Assert.AreEqual(my_iniType.Key, reader.iniType)
    Call Assert.AreEqual("my key", reader.Name)
End Sub

'<Test()>
Public Sub NoSectionsOrKeys()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    Call reader.Read
    Assert.IsTrue (True)
End Sub

'<Test()>
Public Sub CommentCharInString()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("Value = ""WEB;www.google.com|WEB;www.yahoo.com""")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))

    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("Value", reader.Name)
    Call Assert.AreEqual("WEB;www.google.com|WEB;www.yahoo.com", reader.Value)
End Sub

'<Test()>
Public Sub ConsumeAllKeyText()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("email = ""John Smith""; <jsmith@something.com>")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    reader.ConsumeAllKeyText = True

    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("email", reader.Name)
    Call Assert.AreEqual("""John Smith""; <jsmith@something.com>", reader.Value)
End Sub

'<Test()>
Public Sub AcceptNoKeyEndings()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Mysql]")
    writer.WriteLine ("quick")
    writer.WriteLine (" my key = new key")
    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))

    reader.AcceptNoAssignmentOperator = True

    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("quick", reader.Name)
    Call Assert.AreEqual("", reader.Value)
End Sub
'#End Region

'#Region "No end of line tests"
'<Test()>
Public Sub NoEndOfLineComment()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Call writer.WriteValue(" ;   Some comment  ")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    Call reader.Read
    Assert.IsTrue (True)
End Sub

'<Test()>
Public Sub NoEndOfLineKey()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Nini Thing]")
    Call writer.WriteValue(" somekey = key ")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    Call reader.Read
    Assert.IsTrue (True)
End Sub

'<Test()>
Public Sub NoEndOfLineKeyNoValue()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Call writer.WriteLine("[Nini Thing]")
    Call writer.WriteValue(" somekey = ")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    Call reader.Read
    Assert.IsTrue (True)
End Sub

'<Test()>
Public Sub NoEndOfLineSection()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteValue ("[Nini Thing]")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    Call reader.Read
    Assert.IsTrue (True)
End Sub

'<Test()>
Public Sub EndCommentUnix()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Test]")
    writer.WriteLine ("; Test")
    writer.WriteLine (" float1 = 1.0 ;")
    ' no space after comment
    writer.WriteLine (" float2 = 2.0")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(ConvertToUnix(writer.ToString())))

    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("float1", reader.Name, "float1 not found")
    Call Assert.AreEqual("1.0", reader.Value, "float1 value not found")
    Call Assert.IsTrue(reader.Read(), "Could not find last float")
    Call Assert.AreEqual("float2", reader.Name)
    Call Assert.AreEqual("2.0", reader.Value)
End Sub

'<Test()>
'<ExpectedException(GetType(IniException))>
Public Sub NoLineContinuation()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Test]")
    writer.WriteLine (" option = this will be \ ")
    writer.WriteLine ("continued later")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    
    On Error GoTo CatchMe
    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
CatchMe:
Dim ex As Exception
    If Catch(ex, Err) Then
        If Not TypeOf ex Is IniException Then
            Assert.Fail ("expected IniException but got " & ex.ToString)
        End If
    Else
        Assert.Fail ("expected IniException but got Nothing")
    End If
End Sub

'<Test()>
Public Sub LineContinuation()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Test]")
    writer.WriteLine (" option = this will be \ ")
    writer.WriteLine ("continued later")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    reader.LineContinuation = True

    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("this will be continued later", reader.Value)
    Assert.IsFalse (reader.Read())
End Sub

'<Test()>
Public Sub LineContinuationMoreSpace()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Test]")
    writer.WriteLine (" option = this will be \ ")
    writer.WriteLine ("     continued later")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    reader.LineContinuation = True

    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("this will be      continued later", reader.Value)
    Assert.IsFalse (reader.Read())
End Sub

'<Test()>
Public Sub LineContinuationAnotherChar()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Test]")
    writer.WriteLine (" option1 = this will be \ continued")
    writer.WriteLine (" option2 = this will be continued")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    reader.LineContinuation = True

    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("this will be \ continued", reader.Value)
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("this will be continued", reader.Value)
    Assert.IsFalse (reader.Read())
End Sub

'<Test()>
Public Sub LineContinuationNoSpace()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Test]")
    writer.WriteLine (" option = this will be \")
    writer.WriteLine ("continued later")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    reader.LineContinuation = True

    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("this will be continued later", reader.Value)
    Assert.IsFalse (reader.Read())
End Sub

'<Test()>
Public Sub CommentAfterKey()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Test]")
    writer.WriteLine (" option = someValue ; some comment")
    writer.WriteLine ("")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    reader.AcceptCommentAfterKey = True

    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("someValue", reader.Value)
    Call Assert.AreEqual("some comment", reader.Comment)
    Assert.IsTrue (reader.Read())
End Sub

'<Test()>
Public Sub NoCommentAfterKey()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Test]")
    writer.WriteLine (" option = someValue ; some comment")
    writer.WriteLine ("")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))
    reader.AcceptCommentAfterKey = False

    Assert.IsTrue (reader.Read())
    Assert.IsTrue (reader.Read())
    Call Assert.AreEqual("someValue ; some comment", reader.Value)
    Assert.IsTrue (reader.Read())
End Sub

'<Test()>
Public Sub GetAndSetDelimiters()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Test]")
    writer.WriteLine (" option = someValue ; some comment")

    Dim reader As IniReader
    Set reader = NewIniReader(NewStringReader(writer.ToString()))

    Call Assert.AreEqual(AscW("="), reader.GetAssignDelimiters()(0))
    Call reader.SetAssignDelimiters(NewIntegers(AscW(":"), AscW("=")))
    Call Assert.AreEqual(AscW(":"), reader.GetAssignDelimiters()(0))
    Call Assert.AreEqual(AscW("="), reader.GetAssignDelimiters()(1))

    Call Assert.AreEqual(AscW(";"), reader.GetCommentDelimiters()(0))
    Call reader.SetCommentDelimiters(NewIntegers(AscW("#"), AscW(";")))
    Call Assert.AreEqual(AscW("#"), reader.GetCommentDelimiters()(0))
    Call Assert.AreEqual(AscW(";"), reader.GetCommentDelimiters()(1))
End Sub
'#End Region

'#Region "Private methods"
Private Function ConvertToUnix(ByVal text As String) As String
    ConvertToUnix = Replace(text, Chr(13) & Chr(10), Chr(10))
End Function
'#End Region

