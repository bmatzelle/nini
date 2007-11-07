VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IniConfigSTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'<Test()>
Public Sub SetAndSave()
    Dim filePath As String
    filePath = "Test.ini"
    
    Dim writer As StreamWriter
    Set writer = NewStreamWriter(filePath)
    writer.WriteLine ("; some comment")
    writer.WriteLine ("[new section]")
    writer.WriteLine (" dog = Rover")
    writer.WriteLine ("")
    ' empty line
    writer.WriteLine ("; a comment")
    writer.WriteLine (" cat = Muffy")
    writer.CloseWriter

    Dim source As INIConfigSource
    Set source = NewIniConfigSource(filePath)
    Dim config As IConfig
    Set config = source.Configs("new section")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))

    Call config.SetValue("dog", "Spots")
    Call config.SetValue("cat", "Misha")
    Call config.SetValue("DoesNotExist", "SomeValue")

    Call Assert.AreEqual("Spots", config.GetValue("dog"))
    Call Assert.AreEqual("Misha", config.GetValue("cat"))
    Call Assert.AreEqual("SomeValue", config.GetValue("DoesNotExist"))
    source.save

    Set source = NewIniConfigSource(filePath)
    Set config = source.Configs("new section")
    Call Assert.AreEqual("Spots", config.GetValue("dog"))
    Call Assert.AreEqual("Misha", config.GetValue("cat"))
    Call Assert.AreEqual("SomeValue", config.GetValue("DoesNotExist"))

    File.Delete (filePath)
End Sub

'<Test()>
Public Sub MergeAndSave()
    Dim fileName As String
    fileName = "NiniConfig.ini"

    Dim fileWriter As StreamWriter
    Set fileWriter = NewStreamWriter(fileName)
    fileWriter.WriteLine ("[Pets]")
    fileWriter.WriteLine ("cat = Muffy")
    ' overwrite
    fileWriter.WriteLine ("dog = Rover")
    ' new
    fileWriter.WriteLine ("bird = Tweety")
    fileWriter.CloseWriter

    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Pets]")
    writer.WriteLine ("cat = Becky")
    ' overwrite
    writer.WriteLine ("lizard = Saurus")
    ' new
    writer.WriteLine ("[People]")
    writer.WriteLine (" woman = Jane")
    writer.WriteLine (" man = John")
    Dim iniSource As INIConfigSource
    Set iniSource = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim source As INIConfigSource
    Set source = NewIniConfigSource(fileName)

    Call source.Merge(iniSource)

    Dim config As IConfig
    Set config = source.Configs("Pets")
    Call Assert.AreEqual(4, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("Becky", config.GetValue("cat"))
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Saurus", config.GetValue("lizard"))

    Set config = source.Configs("People")
    Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("Jane", config.GetValue("woman"))
    Call Assert.AreEqual("John", config.GetValue("man"))

    Call config.SetValue("woman", "Tara")
    Call config.SetValue("man", "Quentin")

    source.save

    Set source = NewIniConfigSource(fileName)

    Set config = source.Configs("Pets")
    Call Assert.AreEqual(4, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("Becky", config.GetValue("cat"))
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Saurus", config.GetValue("lizard"))

    Set config = source.Configs("People")
    Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("Tara", config.GetValue("woman"))
    Call Assert.AreEqual("Quentin", config.GetValue("man"))

    File.Delete (fileName)
End Sub

    Public Sub UseingIniDocument()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("[Nini]")
            writer.WriteLine (" ; a comment")
            writer.WriteLine (" my key = something")
            writer.WriteLine (" dog = rover")
            writer.WriteLine (" cat = muffy")
            
            Dim tmpIniReader As VBNini.iniReader
            
            Set tmpIniReader = NewIniReader(NewStringReader(writer.ToString()))
            
            tmpIniReader.ConsumeAllKeyText = True
            Dim tmpIniDocument As iniDocument
            Set tmpIniDocument = NewIniDocument(tmpIniReader)
            
            Dim tmpIniConfigSource As INIConfigSource
            Set tmpIniConfigSource = NewIniConfigSource(tmpIniDocument)
            
        End Sub


'<Test()>
Public Sub SaveToNewPath()
    Dim filePath As String
    filePath = "Test.ini"
    Dim newPath As String
    newPath = "TestNew.ini"

    Dim writer As StreamWriter
    Set writer = NewStreamWriter(filePath)
    writer.WriteLine ("; some comment")
    writer.WriteLine ("[new section]")
    writer.WriteLine (" dog = Rover")
    writer.WriteLine (" cat = Muffy")
    writer.CloseWriter

    Dim source As INIConfigSource
    Set source = NewIniConfigSource(filePath)
    Dim config As IConfig
    Set config = source.Configs("new section")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))

    source.Save_path (newPath)

    Set source = NewIniConfigSource(newPath)
    Set config = source.Configs("new section")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))

    Call File.Delete(filePath)
    Call File.Delete(newPath)
End Sub

'<Test()>
Public Sub SaveToWriter()
    Dim newPath As String
    newPath = "TestNew.ini"

    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Call writer.WriteLine("; some comment")
    Call writer.WriteLine("[new section]")
    Call writer.WriteLine(" dog = Rover")
    Call writer.WriteLine(" cat = Muffy")
    Dim source As INIConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Call Assert.AreEqual("", source.SavePath)
    Dim config As IConfig
    Set config = source.Configs("new section")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))

    Dim textWriter As StreamWriter
    Set textWriter = NewStreamWriter(newPath)
    Call source.Save_textWriter(textWriter)
    textWriter.CloseWriter
    
    ' save to disk
    Set source = NewIniConfigSource(newPath)
    Call Assert.AreEqual(newPath, source.SavePath)
    Set config = source.Configs("new section")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))

    Call File.Delete(newPath)
End Sub

'<Test()>
Public Sub SaveAfterTextWriter()
    Dim filePath As String
    filePath = "Test.ini"

    Dim writer As StreamWriter
    Set writer = NewStreamWriter(filePath)
    Call writer.WriteLine("[new section]")
    Call writer.WriteLine(" dog = Rover")
    writer.CloseWriter

    Dim source As INIConfigSource
    Set source = NewIniConfigSource(filePath)
    Call Assert.AreEqual(filePath, source.SavePath)
    Dim textWriter As StringWriter
    Set textWriter = NewStringWriter()
    Call source.Save_textWriter(textWriter)
    Call Assert.AreEqual("", source.SavePath)

    File.Delete (filePath)
End Sub

'<Test()>
Public Sub SaveNewSection()
    Dim filePath As String
    filePath = "Test.xml"

    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("; some comment")
    writer.WriteLine ("[new section]")
    writer.WriteLine (" dog = Rover")
    writer.WriteLine (" cat = Muffy")
    Dim source As INIConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim config As IConfig
    Set config = source.AddConfig("test")
    Call Assert.IsNotNull(source.Configs("test"))
    source.Save_path (filePath)

    Set source = NewIniConfigSource(filePath)
    Set config = source.Configs("new section")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))
    Call Assert.IsNotNull(source.Configs("test"))

    Call File.Delete(filePath)
End Sub

'<Test()>
Public Sub RemoveConfigAndKeyFromFile()
    Dim filePath As String
    filePath = "Test.ini"

    Dim writer As StreamWriter
    Set writer = NewStreamWriter(filePath)
    Call writer.WriteLine("[test 1]")
    Call writer.WriteLine(" dog = Rover")
    Call writer.WriteLine("[test 2]")
    Call writer.WriteLine(" cat = Muffy")
    Call writer.WriteLine(" lizard = Lizzy")
    Call writer.CloseWriter

    Dim source As INIConfigSource
    Set source = NewIniConfigSource(filePath)
    Call Assert.IsNotNothing(source.Configs("test 1"))
    Call Assert.IsNotNothing(source.Configs("test 2"))
    Call Assert.AreNotEqual("", source.Configs("test 2").GetValue("cat"))

    Call source.Configs.Remove(source.Configs("test 1"))
    Call source.Configs("test 2").Remove("cat")
    Call source.AddConfig("cause error")
    source.save

    Set source = NewIniConfigSource(filePath)
    Call Assert.IsNothing(source.Configs("test 1"))
    Call Assert.IsNotNothing(source.Configs("test 2"))
    Call Assert.AreEqual("", source.Configs("test 2").GetValue("cat"))

    File.Delete (filePath)
End Sub

'<Test()>
Public Sub ToStringTest()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    writer.WriteLine ("[Test]")
    writer.WriteLine (" cat = muffy")
    writer.WriteLine (" dog = rover")
    writer.WriteLine (" bird = tweety")
    Dim source As INIConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim eol As String
    eol = Environment.NewLine

    Dim compare As String
    compare = "[Test]" + eol + "cat = muffy" + eol + "dog = rover" + eol + "bird = tweety" + eol
    Call Assert.AreEqual(compare, source.ToString())
End Sub

'<Test()>
Public Sub EmptyConstructor()
    Dim filePath As String
    filePath = "EmptyConstructor.ini"
    Dim source As INIConfigSource
    Set source = NewIniConfigSource()

    Dim config As IConfig
    Set config = source.AddConfig("Pets")
    Call config.SetValue("cat", "Muffy")
    Call config.SetValue("dog", "Rover")
    Call config.SetValue("bird", "Tweety")
    source.Save_path (filePath)

    Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Tweety", config.GetValue("bird"))

    Set source = NewIniConfigSource(filePath)
    Set config = source.Configs("Pets")

    Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Tweety", config.GetValue("bird"))

    Call File.Delete(filePath)
End Sub

'<Test()>
Public Sub Reload()
    Dim filePath As String
    filePath = "Reload.ini"

    ' Create the original source file
    Dim source As INIConfigSource
    Set source = NewIniConfigSource()

    Dim petConfig As IConfig
    Set petConfig = source.AddConfig("Pets")
    Call petConfig.SetValue("cat", "Muffy")
    Call petConfig.SetValue("dog", "Rover")
    Dim weatherConfig As IConfig
    Set weatherConfig = source.AddConfig("Weather")
    Call weatherConfig.SetValue("skies", "cloudy")
    Call weatherConfig.SetValue("precipitation", "rain")
    Call source.Save_path(filePath)

    Call Assert.AreEqual(2, cArray.GetLength(petConfig.GetKeys()))
    Call Assert.AreEqual("Muffy", petConfig.GetValue("cat"))
    Call Assert.AreEqual(2, source.Configs.Count)

    ' Create another source file to set values and reload
    Dim newSource As INIConfigSource
    Set newSource = NewIniConfigSource(filePath)

    Dim compareConfig As IConfig
    Set compareConfig = newSource.Configs("Pets")
    Call Assert.AreEqual(2, cArray.GetLength(compareConfig.GetKeys()))
    Call Assert.AreEqual("Muffy", compareConfig.GetValue("cat"))
    Call Assert.IsTrue(compareConfig Is newSource.Configs("Pets"), "References before are not equal")

    ' Set the new values to source
    Call source.Configs("Pets").SetValue("cat", "Misha")
    Call source.Configs("Pets").SetValue("lizard", "Lizzy")
    Call source.Configs("Pets").SetValue("hampster", "Surly")
    Call source.Configs("Pets").Remove("dog")
    Call source.Configs.Remove(weatherConfig)
    Call source.save
    ' saves new value
    ' Reload the new source and check for changes
    Call newSource.Reload
    Call Assert.IsTrue(compareConfig Is newSource.Configs("Pets"), "References after are not equal")
    Call Assert.AreEqual(1, newSource.Configs.Count)
    Call Assert.AreEqual(3, cArray.GetLength(newSource.Configs("Pets").GetKeys()))
    Call Assert.AreEqual("Lizzy", newSource.Configs("Pets").GetValue("lizard"))
    Call Assert.AreEqual("Misha", newSource.Configs("Pets").GetValue("cat"))
    Call Assert.IsTrue("" = newSource.Configs("Pets").GetValue("dog"))

    File.Delete (filePath)
End Sub

'<Test()>
Public Sub FileClosedOnParseError()
    Dim filePath As String
    filePath = "Reload.ini"

    Dim writer As StreamWriter
    Set writer = NewStreamWriter(filePath)
    writer.WriteLine (" no section = boom!")
    writer.CloseWriter

    'Try
        Dim source As INIConfigSource
    Set source = NewIniConfigSource(filePath)
    'Catch
        ' The file was still opened on a parse error
        File.Delete (filePath)
    'End Try
End Sub

'<Test()>
Public Sub SaveToStream()
    Dim filePath As String
    filePath = "SaveToStream.ini"
    Dim stream As FileStream
    Set stream = NewFileStream(filePath, FileMode.Create)

    ' Create a new document and save to stream
    Dim source As INIConfigSource
    Set source = NewIniConfigSource()
    Dim config As IConfig
    Set config = source.AddConfig("Pets")
    Call config.SetValue("dog", "rover")
    Call config.SetValue("cat", "muffy")
    Call source.Save_stream(stream)
    Call stream.CloseStream

    Dim newSource As INIConfigSource
    Set newSource = NewIniConfigSource(filePath)
    Set config = newSource.Configs("Pets")
    Call Assert.IsNotNothing(config)
    Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("rover", config.GetString("dog"))
    Call Assert.AreEqual("muffy", config.GetString("cat"))

    stream.CloseStream

    File.Delete (filePath)
End Sub

'<Test()>
Public Sub CaseInsensitive()
    Dim writer As StringWriter
    Set writer = NewStringWriter()
    Call writer.WriteLine("[Pets]")
    Call writer.WriteLine("cat = Becky")
    ' overwrite
    Dim source As INIConfigSource
    Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

    source.CaseSensitive = False
    Call Assert.AreEqual("Becky", source.Configs("Pets").GetValue("CAT"))

    Call source.Configs("Pets").SetValue("cAT", "New Name")
    Call Assert.AreEqual("New Name", source.Configs("Pets").GetValue("CAt"))

    Call source.Configs("Pets").Remove("CAT")
    Call Assert.IsTrue("" = source.Configs("Pets").GetValue("CaT"))
End Sub

'<Test()>
Public Sub LoadPath()
    Dim filePath As String
    filePath = "Test.ini"

    Dim writer As StreamWriter
    Set writer = NewStreamWriter(filePath)
    writer.WriteLine ("; some comment")
    writer.WriteLine ("[new section]")
    writer.WriteLine (" dog = Rover")
    writer.WriteLine ("")
    ' empty line
    writer.WriteLine ("; a comment")
    writer.WriteLine (" cat = Muffy")
    Call writer.CloseWriter

    Dim source As INIConfigSource
    Set source = NewIniConfigSource(filePath)
    Dim config As IConfig
    Set config = source.Configs("new section")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))

    Call config.SetValue("dog", "Spots")
    Call config.SetValue("cat", "Misha")
    Call config.SetValue("DoesNotExist", "SomeValue")

    source.Load_filePath (filePath)

    Set config = source.Configs("new section")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))

    File.Delete (filePath)
End Sub

