VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ArgvCSTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'#Region "Tests"
'<Test()>
Public Sub AddSwitch()
    Dim arguments() As String
    arguments = NewStrings("--help", "-d", "doc.xml", "/pet:cat")
    Dim source As ArgvConfigSource
    Set source = NewArgvConfigSource(Join(arguments, "  "))

    Call source.AddSwitch("Base", "help", "h")
    Call source.AddSwitch("Base", "doc", "d")

    Dim config As IConfig
    Set config = source.Configs("Base")
    Call Assert.AreEqual("", config.GetValue("help"))
    Call Assert.AreEqual("", config.GetValue("h"))
    Call Assert.AreEqual("", config.GetValue("not here"))
    Call Assert.AreEqual("", config.GetValue("pets"))
    Call Assert.AreEqual("doc.xml", config.GetValue("doc"))

    Call source.AddSwitch("Pets", "pet")
    Set config = source.Configs("Pets")
    Call Assert.AreNotEqual("", config.GetValue("pet"))
    Call Assert.AreEqual("cat", config.GetValue("pet"))
End Sub

'<Test()>
Public Sub AddSwitchCase()
    Dim arguments As String
    arguments = "-H"
    Dim source As ArgvConfigSource
    Set source = NewArgvConfigSource(arguments)

    Call source.AddSwitch("Base", "help", "h")
    Call source.AddSwitch("Base", "heat", "H")

    Dim config As IConfig
    Set config = source.Configs("Base")
    Call Assert.AreEqual("", config.GetValue("nothere"))
    Call Assert.AreEqual("", config.GetValue("help"))
    Call Assert.IsNotNull(config.GetValue("heat"))
End Sub

'<Test()>
Public Sub GetArguments()
    Dim arguments() As String
    arguments = NewStrings("--help", "-d", "doc.xml", "/pet:cat")
    Dim source As ArgvConfigSource
    Set source = NewArgvConfigSource(Join(arguments, " "))

    Call source.AddSwitch("Base", "help", "h")
    Call source.AddSwitch("Base", "doc", "d")
    Call source.AddSwitch("Base", "short")

    Dim args() As String
    args = source.GetArguments()
    'Call Assert.AreSame(arguments, args, " expected GetArguments to return all arguments")
    ' must be a different instance
    Call Assert.AreEqual(4, cArray.GetLength(args))
    Call Assert.AreEqual("--help", args(0))
    Call Assert.AreEqual("-d", args(1))
    Call Assert.AreEqual("doc.xml", args(2))
    Call Assert.AreEqual("/pet:cat", args(3))
End Sub

'<Test()>
Public Sub GetStringWithColon()
    Dim arguments() As String
    arguments = NewStrings("-c", """D:\test directory""")

    Dim source As ArgvConfigSource
    Set source = NewArgvConfigSource(Join(arguments, " "))
    Call source.AddSwitch("Base", "colon", "c")

    Call Assert.AreEqual("D:\test directory", source.Configs("Base").GetString("colon"))
End Sub

Public Sub EmptyCommandLine()
 Dim writer As StringBuilder
 Dim argvsource As ArgvConfigSource
    Set writer = NewStringBuilder()
    writer.AppendLine ("[Pets]")
    writer.AppendLine (" cat = muffy")
    writer.AppendLine (" dog = rover")
    writer.AppendLine (" bird = tweety")
    Dim source As INIConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))
    

    Set argvsource = NewArgvConfigSource("")
    
    'add's a command line switch -a or -auto
    Call argvsource.AddSwitch("application", "auto", "a")
    
    'add's a command line switch -h or -help that takes no arguments but will give command help to users
    Call argvsource.AddSwitch("application", "help", "h")
    
    'add's a command line switch -d or -date to override the application date
    Call argvsource.AddSwitch("application", "date", "d")
    
    Call argvsource.AddSwitch("application", "start_interval", "s")
    
    Call argvsource.AddSwitch("application", "end_interval", "e")
    
    Call argvsource.AddSwitch("path", "report_settings", "r")
    
    Call source.Merge(argvsource)
    source.ReplaceKeyValues
    source.ExpandKeyValues
End Sub

'#End Region

'#Region "Private methods"
'#End Region

