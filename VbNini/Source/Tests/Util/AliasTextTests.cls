VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "AliasTextTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'<Test()>
Public Sub GetBoolean()
    Dim alias As AliasText
    Set alias = New AliasText

    Call Assert.IsFalse(alias.ContainsBoolean("on"))
    Call Assert.IsFalse(alias.ContainsBoolean("off"))
    Call alias.AddAliasBool("oN", True)
    Call alias.AddAliasBool("oFF", False)

    Call Assert.IsTrue(alias.ContainsBoolean("oN"))
    Call Assert.IsTrue(alias.ContainsBoolean("off"))

    Call Assert.IsTrue(alias.GetBoolean("oN"))
    Call Assert.IsFalse(alias.GetBoolean("OfF"))
End Sub

'<Test()>
Public Sub GetDefaultAliases()
    Dim alias As New AliasText

    Call Assert.IsTrue(alias.ContainsBoolean("true"))
    Call Assert.IsTrue(alias.ContainsBoolean("false"))

    Call Assert.IsTrue(alias.GetBoolean("tRUe"))
    Call Assert.IsFalse(alias.GetBoolean("FaLse"))
End Sub

'<Test()>
'<ExpectedException(GetType(ArgumentException))>
Public Sub NonExistantBooleanText()
    Dim alias As New AliasText
    Call alias.AddAliasBool("true", True)
    Call alias.AddAliasBool("faLSe", False)
    On Error GoTo CatchMe
    Call Assert.IsTrue(alias.GetBoolean("Not present"))
CatchMe:
    Dim ex As Exception
    If Catch(ex, Err) Then
        Call Assert.IsFalse(TypeOf ex Is ArgumentException, "Expected ArgumentException")
    End If
End Sub

'<Test()>
Public Sub GetInt()
    Dim alias As New AliasText

    Call Assert.IsFalse(alias.ContainsInt("error code", "warn"))
    Call Assert.IsFalse(alias.ContainsInt("error code", "error"))
    Call alias.AddAliasInt("error code", "WaRn", 100)
    Call alias.AddAliasInt("error code", "ErroR", 200)

    Call Assert.IsTrue(alias.ContainsInt("error code", "warn"))
    Call Assert.IsTrue(alias.ContainsInt("error code", "error"))

    Call Assert.AreEqual(100, alias.GetInt("error code", "warn"))
    Call Assert.AreEqual(200, alias.GetInt("error code", "ErroR"))
End Sub

'<Test()>
'<ExpectedException(GetType(ArgumentException))>
Public Sub GetIntNonExistantText()
    Dim alias As New AliasText
    Call alias.AddAliasInt("error code", "WaRn", 100)
    On Error GoTo CatchMe
    Call Assert.AreEqual(100, alias.GetInt("error code", "not here"))
CatchMe:
    Dim ex As Exception
    If Catch(ex, Err) Then
        Call Assert.IsFalse(TypeOf ex Is ArgumentException, "Expected ArgumentException")
    End If
End Sub

'<Test()>
'<ExpectedException(GetType(ArgumentException))>
Public Sub GetIntNonExistantKey()
    Dim alias As New AliasText
    Call alias.AddAliasInt("error code", "WaRn", 100)
    On Error GoTo CatchMe
    Call Assert.AreEqual(100, alias.GetInt("not exist", "warn"))
CatchMe:
    Dim ex As Exception
    If Catch(ex, Err) Then
        Call Assert.IsFalse(TypeOf ex Is ArgumentException, "Expected ArgumentException")
    End If
End Sub

''<Test()>
'Public Sub GetIntEnum()
'    Dim alias As New AliasText
'    Call alias.AddAliasInt("node type", )
'
'    Call Assert.AreEqual(CInt(System.Xml.XmlNodeType.text), alias.GetInt("node type", "teXt"))
'    Call Assert.AreEqual(CInt(System.Xml.XmlNodeType.Attribute), alias.GetInt("node type", "aTTribute"))
'
'    Try
'        Call alias.GetInt("node type", "not here")
'    Catch
'    'End Try
'End Sub

'<Test()>
Public Sub GlobalAlias()
    Dim writer As New StringWriter
    Call writer.WriteLine("[Test]")
    Call writer.WriteLine(" TurnOff = true")
    Call writer.WriteLine(" ErrorCode = WARN")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Call source.alias.AddAliasBool("true", True)
    Call source.alias.AddAliasInt("ErrorCode", "warn", 35)

    Dim config As IConfig
    Set config = source.Configs("Test")

    Call Assert.AreEqual(35, config.GetInt("ErrorCode", , True))
    Call Assert.IsTrue(config.GetBoolean("TurnOff"))

    Call config.alias.AddAliasBool("true", False)
    Call config.alias.AddAliasInt("ErrorCode", "warn", 45)

    Call Assert.AreEqual(45, config.GetInt("ErrorCode", , True))
    Call Assert.IsFalse(config.GetBoolean("TurnOff"))
End Sub

