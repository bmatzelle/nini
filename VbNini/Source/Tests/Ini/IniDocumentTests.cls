VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IniDocumentTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

        '<Test()>
        Public Sub GetSection()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("; Test")
            writer.WriteLine ("[Nini Thing]")
            Dim doc As iniDocument
            Set doc = NewIniDocument(NewStringReader(writer.ToString()))

            Call Assert.AreEqual(1, doc.sections.Count)
            Call Assert.AreEqual("Nini Thing", doc.sections("Nini Thing").Name)
            Call Assert.AreEqual("Nini Thing", doc.sections(0).Name)
            Call Assert.IsNothing(doc.sections("Non Existant"))
        End Sub

        '<Test()>
        Public Sub GetKey()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("[Nini]")
            writer.WriteLine (" my key = something")
            Dim doc As iniDocument
            Set doc = NewIniDocument(NewStringReader(writer.ToString()))

            Dim section As IniSection
            Set section = doc.sections("Nini")
            Call Assert.IsTrue(section.Contains("my key"))
            Call Assert.AreEqual("something", section.GetValue("my key"))
            Call Assert.IsFalse(section.Contains("not here"))
        End Sub

        '<Test()>
        Public Sub SetSection()
            Dim doc As iniDocument
            Set doc = NewIniDocument()

            Dim section As IniSection
            Set section = NewIniSection("new section")
            Call doc.sections.Add(section)
            Call Assert.AreEqual("new section", doc.sections(0).Name)
            Call Assert.AreEqual("new section", doc.sections("new section").Name)

            Set section = NewIniSection("a section", "a comment")
            Call doc.sections.Add(section)
            Call Assert.AreEqual("a comment", doc.sections(1).comment)
        End Sub

        '<Test()>
        Public Sub SetKey()
            Dim doc As iniDocument
            Set doc = NewIniDocument()

            Dim section As IniSection
            Set section = NewIniSection("new section")
            Call doc.sections.Add(section)

            Call section.SetValue("new key", "some value")

            Call Assert.IsTrue(section.Contains("new key"))
            Call Assert.AreEqual("some value", section.GetValue("new key"))
        End Sub

        '<Test()>
        '<ExpectedException(GetType(IniException))>
        Public Sub ParserError()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("[Nini Thing")
            writer.WriteLine (" my key = something")
            Dim doc As iniDocument
            On Error GoTo CatchIt
            Set doc = NewIniDocument(NewStringReader(writer.ToString()))
CatchIt:
        Dim exc As Exception
        If Catch(exc) Then
            If Not TypeOf exc Is IniException Then
                Call Assert.Fail("Expected Exception IniException")
            End If
        End If
        End Sub

        '<Test()>
        Public Sub RemoveSection()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("[Nini Thing]")
            writer.WriteLine (" my key = something")
            writer.WriteLine ("[Parser]")
            Dim doc As iniDocument
            Set doc = NewIniDocument(NewStringReader(writer.ToString()))

            Call Assert.IsNotNothing(doc.sections("Nini Thing"))
            doc.sections.Remove ("Nini Thing")
            Call Assert.IsNothing(doc.sections("Nini Thing"))
        End Sub

        '<Test()>
        Public Sub RemoveKey()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("[Nini]")
            writer.WriteLine (" my key = something")
            Dim doc As iniDocument
            Set doc = NewIniDocument(NewStringReader(writer.ToString()))

            Call Assert.IsTrue(doc.sections("Nini").Contains("my key"))
            doc.sections("Nini").Remove ("my key")
            Call Assert.IsFalse(doc.sections("Nini").Contains("my key"))
        End Sub

        '<Test()>
        Public Sub GetAllKeys()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("[Nini]")
            writer.WriteLine (" ; a comment")
            writer.WriteLine (" my key = something")
            writer.WriteLine (" dog = rover")
            writer.WriteLine (" cat = muffy")
            Dim doc As iniDocument
            Set doc = NewIniDocument(NewStringReader(writer.ToString()))

            Dim section As IniSection
            Set section = doc.sections("Nini")

            Call Assert.AreEqual(4, section.ItemCount)
            Call Assert.AreEqual(3, cArray.GetLength(section.GetKeys()))
            Call Assert.AreEqual("my key", section.GetKeys()(0))
            Call Assert.AreEqual("dog", section.GetKeys()(1))
            Call Assert.AreEqual("cat", section.GetKeys()(2))
        End Sub
        
        
        Public Sub UseingIniReader()
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
            
            
        End Sub
        
        
        
        
        
        '<Test()>
        Public Sub SaveDocumentWithComments()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("; some comment")
            writer.WriteLine ("")
            ' empty line
            writer.WriteLine ("[new section]")
            writer.WriteLine (" dog = rover")
            writer.WriteLine ("")
            ' Empty line
            writer.WriteLine ("; a comment")
            writer.WriteLine (" cat = muffy")
            Dim doc As iniDocument
            Set doc = NewIniDocument(NewStringReader(writer.ToString()))

            Dim newWriter As StringWriter
            Set newWriter = NewStringWriter()
            Call doc.Save_textWriter(newWriter)

            Dim reader As StringReader
            Set reader = NewStringReader(newWriter.ToString())
            Call Assert.AreEqual("; some comment", reader.ReadLine())
            Call Assert.AreEqual("", reader.ReadLine())
            Call Assert.AreEqual("[new section]", reader.ReadLine())
            Call Assert.AreEqual("dog = rover", reader.ReadLine())
            Call Assert.AreEqual("", reader.ReadLine())
            Call Assert.AreEqual("; a comment", reader.ReadLine())
            Call Assert.AreEqual("cat = muffy", reader.ReadLine())

            writer.CloseWriter
        End Sub

        '<Test()>
        Public Sub SaveToStream()
            Dim filePath As String
            filePath = "SaveToStream.ini"
            Dim stream As FileStream
            Set stream = NewFileStream(filePath, FileMode.Create)

            ' Create a new document and save to stream
            Dim doc As iniDocument
            Set doc = NewIniDocument()
            Dim section As IniSection
            Set section = NewIniSection("Pets")
            Call section.SetValue("dog", "rover")
            Call section.SetValue("cat", "muffy")
            Call doc.sections.Add(section)
            Call doc.Save_stream(stream)
            stream.CloseStream

            Dim newDoc As iniDocument
            Set newDoc = NewIniDocument(NewFileStream(filePath, FileMode.OpenExisting))
            Set section = newDoc.sections("Pets")
            Call Assert.IsNotNothing(section)
            Call Assert.AreEqual(2, cArray.GetLength(section.GetKeys()))
            Call Assert.AreEqual("rover", section.GetValue("dog"))
            Call Assert.AreEqual("muffy", section.GetValue("cat"))

            stream.CloseStream

            File.Delete (filePath)
        End Sub

        '<Test()>
        Public Sub SambaStyleDocument()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("; some comment")
            writer.WriteLine ("# another comment")
            ' empty line
            writer.WriteLine ("[test]")
            writer.WriteLine (" cat = cats are not tall\ ")
            writer.WriteLine (" animals ")
            writer.WriteLine (" dog = dogs \ ")
            writer.WriteLine ("        do not eat cats ")
            Dim doc As iniDocument
            Set doc = NewIniDocument(NewStringReader(writer.ToString()), IniFileType.SambaStyle)

            Call Assert.AreEqual("cats are not tall animals", doc.sections("test").GetValue("cat"))
            Call Assert.AreEqual("dogs         do not eat cats", doc.sections("test").GetValue("dog"))
        End Sub

        '<Test()>
        Public Sub PythonStyleDocument()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("; some comment")
            writer.WriteLine ("# another comment")
            ' empty line
            writer.WriteLine ("[test]")
            writer.WriteLine (" cat: cats are not tall animals ")
            writer.WriteLine (" dog : dogs bark")
            Dim doc As iniDocument
            Set doc = NewIniDocument(NewStringReader(writer.ToString()), IniFileType.PythonStyle)

            Call Assert.AreEqual("cats are not tall animals", doc.sections("test").GetValue("cat"))
            Call Assert.AreEqual("dogs bark", doc.sections("test").GetValue("dog"))
        End Sub

        '<Test()>
        Public Sub DuplicateSections()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("[Test]")
            writer.WriteLine (" my key = something")
            writer.WriteLine ("[Test]")
            writer.WriteLine (" another key = something else")
            writer.WriteLine ("[Test]")
            writer.WriteLine (" value 0 = something 0")
            writer.WriteLine (" value 1 = something 1")
            Dim doc As iniDocument
            'MsgBox writer.ToString()
            Set doc = NewIniDocument(NewStringReader(writer.ToString()))

            Call Assert.IsNotNothing(doc.sections("Test"))
            Call Assert.AreEqual(1, doc.sections.Count)
            Call Assert.AreEqual(2, doc.sections("Test").ItemCount)
            Call Assert.AreEqual("", doc.sections("Test").GetValue("my key"))
            Call Assert.AreNotEqual("", doc.sections("Test").GetValue("value 0"))
            Call Assert.AreNotEqual("", doc.sections("Test").GetValue("value 1"))
        End Sub

        '<Test()>
        Public Sub DuplicateKeys()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("[Test]")
            writer.WriteLine (" a value = something 0")
            writer.WriteLine (" a value = something 1")
            writer.WriteLine (" a value = something 2")
            Dim doc As iniDocument
            Set doc = NewIniDocument(NewStringReader(writer.ToString()))

            Call Assert.IsNotNothing(doc.sections("Test"))
            Call Assert.AreEqual(1, doc.sections.Count)
            Call Assert.AreEqual(1, doc.sections("Test").ItemCount)
            Call Assert.AreNotEqual("", doc.sections("Test").GetValue("a value"))
            Call Assert.AreEqual("something 0", doc.sections("Test").GetValue("a value"))
        End Sub

        '<Test()>
        Public Sub MysqlStyleDocument()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("# another comment")
            ' empty line
            writer.WriteLine ("[test]")
            writer.WriteLine (" quick ")
            writer.WriteLine (" cat = cats are not tall animals ")
            writer.WriteLine (" dog : dogs bark")
            Dim doc As iniDocument
            Set doc = NewIniDocument(NewStringReader(writer.ToString()), IniFileType.MysqlStyle)

            Call Assert.IsTrue(doc.sections("test").Contains("quick"))
            Call Assert.AreEqual("", doc.sections("test").GetValue("quick"))
            Call Assert.AreEqual("cats are not tall animals", doc.sections("test").GetValue("cat"))
            Call Assert.AreEqual("dogs bark", doc.sections("test").GetValue("dog"))
        End Sub

        '<Test()>
        Public Sub WindowsStyleDocument()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("; another comment")
            ' empty line
            writer.WriteLine ("[test]")
            writer.WriteLine (" cat = cats are not ; tall ")
            writer.WriteLine (" dog = dogs ""bark""")
            Dim doc As iniDocument
            Set doc = NewIniDocument(NewStringReader(writer.ToString()), IniFileType.WindowsStyle)

            Dim section As IniSection
            Set section = doc.sections("test")
            Call Assert.AreEqual("cats are not ; tall", section.GetValue("cat"))
            Call Assert.AreEqual("dogs ""bark""", section.GetValue("dog"))
        End Sub

        '<Test()>
        Public Sub SaveAsPythonStyle()
            Dim filePath As String
            filePath = "Save.ini"
            Dim stream As FileStream
            Set stream = NewFileStream(filePath, FileMode.Create)

            ' Create a new document and save to stream
            Dim doc As iniDocument
            Set doc = NewIniDocument()
            doc.FileType = IniFileType.PythonStyle
            Dim section As IniSection
            Set section = NewIniSection("Pets")
            Call section.SetValue(, , "my comment")
            Call section.SetValue("dog", "rover")
            Call doc.sections.Add(section)
            Call doc.Save_stream(stream)
            stream.CloseStream

            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("[Pets]")
            writer.WriteLine ("# my comment")
            writer.WriteLine ("dog : rover")

            Dim reader As StreamReader
            Set reader = NewStreamReader(filePath)
            Call Assert.AreEqual(writer.ToString(), reader.ReadToEnd())
            reader.CloseReader

            File.Delete (filePath)
        End Sub

        '<Test()>
        Public Sub SaveAsMysqlStyle()
            Dim filePath As String
            filePath = "Save.ini"
            Dim stream As FileStream
            Set stream = NewFileStream(filePath, FileMode.Create)

            ' Create a new document and save to stream
            Dim doc As iniDocument
            Set doc = NewIniDocument()
            doc.FileType = IniFileType.MysqlStyle
            Dim section As IniSection
            Set section = NewIniSection("Pets")
            Call section.SetValue(, , "my comment")
            Call section.SetValue("dog", "rover")
            Call doc.sections.Add(section)
            Call doc.Save_stream(stream)
            stream.CloseStream

            Dim writer As StringWriter
            Set writer = NewStringWriter()
            writer.WriteLine ("[Pets]")
            writer.WriteLine ("# my comment")
            writer.WriteLine ("dog = rover")

            Dim reader As StreamReader
            Set reader = NewStreamReader(filePath)
            'Debug.Print reader.ReadToEnd()
            Call Assert.AreEqual(writer.ToString(), reader.ReadToEnd)
            reader.CloseReader

            Dim iniDoc As iniDocument
            Set iniDoc = NewIniDocument()
            iniDoc.FileType = IniFileType.MysqlStyle
            iniDoc.Load_Path (filePath)

            File.Delete (filePath)
        End Sub

        '<Test()>
        '<ExpectedException(GetType(IniException))>
        Public Sub SambaLoadAsStandard()
            Dim filePath As String
            filePath = "Save.ini"
            Dim stream As FileStream
            Set stream = NewFileStream(filePath, FileMode.Create)

            ' Create a new document and save to stream
            Dim doc As iniDocument
            Set doc = NewIniDocument()
            doc.FileType = IniFileType.SambaStyle
            Dim section As IniSection
            Set section = NewIniSection("Pets")
            Call section.SetValue("my comment")
            Call section.SetValue("dog", "rover")
            Call doc.sections.Add(section)
            Call doc.Save_stream(stream)
            stream.CloseStream

            Dim iniDoc As iniDocument
            Set iniDoc = NewIniDocument()
            On Error GoTo CatchMe
            iniDoc.FileType = IniFileType.Standard
            iniDoc.Load_Path (filePath)

            File.Delete (filePath)
CatchMe:
            Dim ex As Exception
            If Catch(ex, Err) Then
                Call Assert.IsFalse(TypeOf ex Is IniException, "Expected IniException")
            End If
        End Sub

