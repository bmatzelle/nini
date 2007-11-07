VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ConfigBaseTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'<Test()>
Public Sub GetConfig()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Pets]")
    writer.AppendLine (" cat = muffy")
    writer.AppendLine (" dog = rover")
    writer.AppendLine (" bird = tweety")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim config As IConfig
    Set config = source.Configs("Pets")
    Call Assert.AreEqual("Pets", config.Name)
    Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual(source, config.ConfigSource)
End Sub

'<Test()>
Public Sub GetString()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Test]")
    writer.AppendLine (" cat = muffy")
    writer.AppendLine (" dog = rover")
    writer.AppendLine (" bird = tweety")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))
    Dim config As IConfig
    Set config = source.Configs("Test")

    Call Assert.AreEqual("muffy", config.GetValue("cat"))
    Call Assert.AreEqual("rover", config.GetValue("dog"))
    Call Assert.AreEqual("muffy", config.GetString("cat"))
    Call Assert.AreEqual("rover", config.GetString("dog"))
    Call Assert.AreEqual("my default", config.GetValue("Not Here", "my default"))
    Call Assert.AreEqual("", config.GetValue("Not Here 2"))
End Sub

'<Test()>
Public Sub GetInt()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Test]")
    writer.AppendLine (" value 1 = 495")
    writer.AppendLine (" value 2 = 49588")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))
    Dim config As IConfig
    Set config = source.Configs("Test")

    Call Assert.AreEqual(495, config.GetInt("value 1"))
    
    Call Assert.AreEqual(123, config.GetInt("Not Here", 123))
    On Error GoTo CatchMe
    Call config.GetInt("value 2")
CatchMe:
    Dim ex2 As Exception
    If Catch(ex2) Then
        Assert.IsTrue (TypeOf ex2 Is ArgumentOutOfRangeException)
    End If
    
'    On Error GoTo MyExit
'        Call config.GetInt("Not Here Also")
'        Call Assert.Fail
'MyExit:
End Sub

'<Test()>
Public Sub GetLong()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Test]")
    writer.AppendLine (" value 1 = 40000")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))
    Dim config As IConfig
    Set config = source.Configs("Test")

    Call Assert.AreEqual(40000#, config.GetLong("value 1"))
    Call Assert.AreEqual(50000#, config.GetLong("Not Here", 50000#))

    On Error GoTo MyExit
        config.GetLong ("Not Here Also")
        'Call Assert.Fail
MyExit:
End Sub

'<Test()>
Public Sub GetFloat()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Test]")
    writer.AppendLine (" value 1 = 494.59")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))
    Dim config As IConfig
    Set config = source.Configs("Test")

    Call Assert.AreEqual(494.59, config.GetFloat("value 1"))
    Call Assert.AreEqual(CSng(5656.2853), config.GetFloat("Not Here", CSng(5656.2853)))
End Sub

'<Test()>
Public Sub BooleanAlias()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Test]")
    writer.AppendLine (" bool 1 = TrUe")
    writer.AppendLine (" bool 2 = FalSe")
    writer.AppendLine (" bool 3 = ON")
    writer.AppendLine (" bool 4 = OfF")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim config As IConfig
    Set config = source.Configs("Test")
    Call config.alias.AddAliasBool("true", True)
    Call config.alias.AddAliasBool("false", False)
    Call config.alias.AddAliasBool("on", True)
    Call config.alias.AddAliasBool("off", False)

    Call Assert.IsTrue(config.GetBoolean("bool 1"))
    Call Assert.IsFalse(config.GetBoolean("bool 2"))
    Call Assert.IsTrue(config.GetBoolean("bool 3"))
    Call Assert.IsFalse(config.GetBoolean("bool 4"))
    Call Assert.IsTrue(config.GetBoolean("Not Here", True))
End Sub

'<Test()>
'<ExpectedException(GetType(ArgumentException))>
Public Sub BooleanAliasNoDefault()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Test]")
    writer.AppendLine (" bool 1 = TrUe")
    writer.AppendLine (" bool 2 = FalSe")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim config As IConfig
    Set config = source.Configs("Test")
    Call config.alias.AddAliasBool("true", True)
    Call config.alias.AddAliasBool("false", False)
    
    On Error GoTo CatchMe
    Call Assert.IsTrue(config.GetBoolean("Not Here", True))
    Call Assert.IsFalse(config.GetBoolean("Not Here Also"))

CatchMe:
    Dim ex As Exception
    If Catch(ex) Then
        Call Assert.IsFalse(TypeOf ex Is ArgumentException, "Expected ArgumentException")
    End If
End Sub

'<Test()>
'<ExpectedException(GetType(ArgumentException))>
Public Sub NonBooleanParameter()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Test]")
    writer.AppendLine (" bool 1 = not boolean")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim config As IConfig
    Set config = source.Configs("Test")
    Call config.alias.AddAliasBool("true", True)
    Call config.alias.AddAliasBool("false", False)
    On Error GoTo CatchMe
    Call Assert.IsTrue(config.GetBoolean("bool 1"))
CatchMe:
    Dim ex As Exception
    If Catch(ex) Then
        Call Assert.IsTrue(TypeOf ex Is ArgumentException, "Expected ArgumentException")
    End If
End Sub

'<Test()>
Public Sub GetIntAlias()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Test]")
    writer.AppendLine (" node type = TEXT")
    writer.AppendLine (" error code = WARN")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Const WARN As Integer = 100
    Const ERROR_constant As Integer = 200
    Dim config As IConfig
    Set config = source.Configs("Test")
    Call config.alias.AddAliasInt("error code", "waRn", WARN)
    Call config.alias.AddAliasInt("error code", "eRRor", ERROR_constant)
    'Call config.alias.AddAliasInt("node type", New SystemException.Xml.XmlNodeType())
    Call config.alias.AddAliasInt("default", "age", 31)

    Call Assert.AreEqual(WARN, config.GetInt("error code", , True))
    'Call Assert.AreEqual(CInt(System.Xml.XmlNodeType.text), config.GetInt("node type", True))
    Call Assert.AreEqual(31, config.GetInt("default", 31, True))
End Sub

'<Test()>
Public Sub GetKeys()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Test]")
    writer.AppendLine (" bool 1 = TrUe")
    writer.AppendLine (" bool 2 = FalSe")
    writer.AppendLine (" bool 3 = ON")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim config As IConfig
    Set config = source.Configs("Test")
    Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("bool 1", config.GetKeys()(0))
    Call Assert.AreEqual("bool 2", config.GetKeys()(1))
    Call Assert.AreEqual("bool 3", config.GetKeys()(2))
End Sub

'<Test()>
Public Sub GetValues()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Test]")
    writer.AppendLine (" key 1 = value 1")
    writer.AppendLine (" key 2 = value 2")
    writer.AppendLine (" key 3 = value 3")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim config As IConfig
    Set config = source.Configs("Test")
    Call Assert.AreEqual(3, cArray.GetLength(config.GetValues()))
    Call Assert.AreEqual("value 1", config.GetValues()(0))
    Call Assert.AreEqual("value 2", config.GetValues()(1))
    Call Assert.AreEqual("value 3", config.GetValues()(2))
End Sub

'<Test()>
Public Sub SetAndRemove()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Pets]")
    writer.AppendLine (" cat = muffy")
    writer.AppendLine (" dog = rover")
    writer.AppendLine (" bird = tweety")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim config As IConfig
    Set config = source.Configs("Pets")
    Call Assert.AreEqual("Pets", config.Name)
    Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))

    Call config.SetValue("snake", "cobra")
    Call Assert.AreEqual(4, cArray.GetLength(config.GetKeys()))

    ' Test removing
    Call Assert.AreNotEqual("", config.GetValue("dog"))
    Call config.Remove("dog")
    Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("", config.GetValue("dog"))
    Call Assert.AreNotEqual("", config.GetValue("snake"))
End Sub

'<Test()>
Public Sub Rename()
    Dim source As IniConfigSource
    Set source = NewIniConfigSource()

    Dim config As IConfig
    Set config = source.AddConfig("Pets")
    Call config.SetValue("cat", "Muffy")
    Call config.SetValue("dog", "Rover")

    config.Name = "MyPets"
    Call Assert.AreEqual("MyPets", config.Name)

    Call Assert.IsNothing(source.Configs("Pets"))
    Dim newConfig As IConfig
    Set newConfig = source.Configs("MyPets")

    Call Assert.AreEqual(config, newConfig)

    Call Assert.AreEqual(2, cArray.GetLength(newConfig.GetKeys()))
End Sub

'<Test()>
Public Sub Contains()
    Dim source As IniConfigSource
    Set source = NewIniConfigSource()

    Dim config As IConfig
    Set config = source.AddConfig("Pets")
    Call config.SetValue("cat", "Muffy")
    Call config.SetValue("dog", "Rover")

    Call Assert.IsTrue(config.Contains("cat"))
    Call Assert.IsTrue(config.Contains("dog"))

    config.Remove ("cat")
    Call Assert.IsFalse(config.Contains("cat"))
    Call Assert.IsTrue(config.Contains("dog"))
End Sub

'<Test()>
Public Sub ExpandString()
    Dim writer  As StringBuilder
    Set writer = NewStringBuilder()
    
    writer.AppendLine ("[web]")
    writer.AppendLine (" apache = Apache implements ${protocol}")
    writer.AppendLine (" protocol = http")
    writer.AppendLine ("[server]")
    writer.AppendLine (" domain = ${web|protocol}://nini.sf.net/")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim config As IConfig
    Set config = source.Configs("web")
    Call Assert.AreEqual("http", config.GetValue("protocol"))
    Call Assert.AreEqual("Apache implements ${protocol}", config.GetValue("apache"))
    Call Assert.AreEqual("Apache implements http", config.GetExpanded("apache"))
    Call Assert.AreEqual("Apache implements ${protocol}", config.GetValue("apache"))
    Set config = source.Configs("server")
    Call Assert.AreEqual("http://nini.sf.net/", config.GetExpanded("domain"))
    Call Assert.AreEqual("${web|protocol}://nini.sf.net/", config.GetValue("domain"))
End Sub

'<Test()>
Public Sub ExpandWithEndBracket()
    Dim writer As StringBuilder
    Set writer = NewStringBuilder()
    writer.AppendLine ("[web]")
    writer.AppendLine (" apache = } Apache implements ${protocol}")
    writer.AppendLine (" protocol = http")
    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim config As IConfig
    Set config = source.Configs("web")
    Call Assert.AreEqual("} Apache implements http", config.GetExpanded("apache"))
End Sub

'<Test()>
Public Sub ExpandBackToBack()
    Dim writer As StringBuilder
    
    Set writer = NewStringBuilder()
    
    Call writer.AppendLine("[web]")
    
    Call writer.AppendLine(" apache = Protocol: ${protocol}${version}")
    Call writer.AppendLine(" protocol = http")
    Call writer.AppendLine(" version = 1.1")
    

    Dim source As IniConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim config As IConfig
    Set config = source.Configs("web")
    Call Assert.AreEqual("Protocol: http1.1", config.GetExpanded("apache"))
End Sub

