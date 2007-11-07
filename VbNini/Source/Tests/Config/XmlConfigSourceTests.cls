VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "XmlConfigSTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'#Region "Tests"
        '<Test()>
        Public Sub GetConfig()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            Call NiniWriter(writer)
            Call WriteSection(writer, "Pets")
            Call WriteKey(writer, "cat", "muffy")
            Call WriteKey(writer, "dog", "rover")
            Call WriteKey(writer, "bird", "tweety")
            Call WriteEndsection(writer)
            Call WriteEndDocument(writer)
            Debug.Print writer.ToString()
            Dim reader As StringReader
            Set reader = NewStringReader(writer.ToString())
            'Dim xmlReader As New XmlTextReader(reader)
            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(reader)

            Dim config As IConfig
            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Pets", config.Name)
            Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual(source, config.configSource)
        End Sub

        '<Test()>
        Public Sub GetConfigNotXmlDocument()
            Dim textWriter As StringWriter
            Set textWriter = NewStringWriter()
            Call NiniWriter(textWriter)
            Call WriteSection(textWriter, "Pets")
            Call WriteKey(textWriter, "cat", "muffy")
            Call WriteKey(textWriter, "dog", "rover")
            Call WriteKey(textWriter, "bird", "tweety")
            Call WriteEndsection(textWriter)
            Call WriteEndDocument(textWriter)

            Dim reader As StringReader
            Set reader = NewStringReader(textWriter.ToString())
            'Dim xmlReader As XmlTextReader
            'Set xmlReader = NewXmlTextReader(reader)
            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(reader)

            Dim config As IConfig
            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Pets", config.Name)
            Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual(source, config.configSource)
        End Sub

        '<Test()>
        Public Sub GetString()
            Dim textWriter As StringWriter
            Set textWriter = NewStringWriter()
            Call NiniWriter(textWriter)
            Call WriteSection(textWriter, "Pets")
            Call WriteKey(textWriter, "cat", "muffy")
            Call WriteKey(textWriter, "dog", "rover")
            Call WriteKey(textWriter, "bird", "tweety")
            Call WriteEndsection(textWriter)
            Call WriteEndDocument(textWriter)

            Dim reader As StringReader
            Set reader = NewStringReader(textWriter.ToString())
            'Dim xmlReader As XmlTextReader
            'Set xmlReader = NewXmlTextReader(reader)
            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(reader)

            Dim config As IConfig
            Set config = source.Configs("Pets")

            Call Assert.AreEqual("muffy", config.GetValue("cat"))
            Call Assert.AreEqual("rover", config.GetValue("dog"))
            Call Assert.AreEqual("muffy", config.GetString("cat"))
            Call Assert.AreEqual("rover", config.GetString("dog"))
            Call Assert.AreEqual("my default", config.GetValue("Not Here", "my default"))
            Call Assert.AreEqual("", config.GetValue("Not Here 2"))
        End Sub

        '<Test()>
        Public Sub GetInt()
            Dim textWriter As StringWriter
            Set textWriter = NewStringWriter()
            Call NiniWriter(textWriter)
            Call WriteSection(textWriter, "Pets")
            Call WriteKey(textWriter, "value 1", "495")
            Call WriteEndsection(textWriter)
            Call WriteEndDocument(textWriter)

            Dim reader As StringReader
            Set reader = NewStringReader(textWriter.ToString())
            'Dim xmlReader As XmlTextReader
            'Set xmlReader = NewXmlTextReader(reader)
            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(reader)

            Dim config As IConfig
            Set config = source.Configs("Pets")

            Call Assert.AreEqual(495, config.GetInt("value 1"))
            Call Assert.AreEqual(123, config.GetInt("Not Here", 123))

            On Error GoTo MyExit
                Call config.GetInt("Not Here Also")
                Call Assert.Fail
MyExit:
            Dim ex As Exception
            If Catch(ex) Then
            End If
        End Sub

        '<Test()>
        Public Sub SetAndSave()
            Dim filePath As String
            filePath = "Test.xml"

            Dim textWriter As StreamWriter
            Set textWriter = File.CreateText(filePath)
            Call NiniWriter(textWriter)
            Call WriteSection(textWriter, "new section")
            Call WriteKey(textWriter, "dog", "Rover")
            Call WriteKey(textWriter, "cat", "Muffy")
            Call WriteEndsection(textWriter)
            Call WriteEndDocument(textWriter)
            textWriter.CloseWriter

            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(filePath)

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
            source.Save

            Set source = NewXmlConfigSource(filePath)
            Set config = source.Configs("new section")
            Call Assert.AreEqual("Spots", config.GetValue("dog"))
            Call Assert.AreEqual("Misha", config.GetValue("cat"))
            Call Assert.AreEqual("SomeValue", config.GetValue("DoesNotExist"))

            Call File.Delete(filePath)
        End Sub

        '<Test()>
        Public Sub MergeAndSave()
            Dim xmlFileName As String
            xmlFileName = "NiniConfig.xml"

            Dim textWriter As StreamWriter
            Set textWriter = NewStreamWriter(xmlFileName)
            Call NiniWriter(textWriter)
            Call WriteSection(textWriter, "Pets")
            Call WriteKey(textWriter, "cat", "Muffy")
            Call WriteKey(textWriter, "dog", "Rover")
            Call WriteKey(textWriter, "bird", "Tweety")
            Call WriteEndsection(textWriter)
            Call WriteEndDocument(textWriter)
            textWriter.CloseWriter

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

            Dim xmlSource As XmlConfigSource
            Set xmlSource = NewXmlConfigSource(xmlFileName)

            Call xmlSource.Merge(iniSource)

            Dim config As IConfig
            Set config = xmlSource.Configs("Pets")
            Call Assert.AreEqual(4, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("Becky", config.GetValue("cat"))
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual("Saurus", config.GetValue("lizard"))

            Set config = xmlSource.Configs("People")
            Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("Jane", config.GetValue("woman"))
            Call Assert.AreEqual("John", config.GetValue("man"))

            Call config.SetValue("woman", "Tara")
            Call config.SetValue("man", "Quentin")

            xmlSource.Save

            Set xmlSource = NewXmlConfigSource(xmlFileName)

            Set config = xmlSource.Configs("Pets")
            Call Assert.AreEqual(4, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("Becky", config.GetValue("cat"))
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual("Saurus", config.GetValue("lizard"))

            Set config = xmlSource.Configs("People")
            Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("Tara", config.GetValue("woman"))
            Call Assert.AreEqual("Quentin", config.GetValue("man"))

            File.Delete (xmlFileName)
        End Sub

        '<Test()>
        Public Sub SaveToNewPath()
            Dim filePath As String
            filePath = "Test.xml"
            Dim newPath As String
            newPath = "TestNew.xml"

            Dim textWriter As StreamWriter
            Set textWriter = NewStreamWriter(filePath)
            
            Call NiniWriter(textWriter)
            Call WriteSection(textWriter, "Pets")
            Call WriteKey(textWriter, "cat", "Muffy")
            Call WriteKey(textWriter, "dog", "Rover")
            Call WriteEndsection(textWriter)
            Call WriteEndDocument(textWriter)
            textWriter.CloseWriter

            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(filePath)
            Dim config As IConfig
            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual("Muffy", config.GetValue("cat"))

            Call source.Save_path(newPath)

            Set source = NewXmlConfigSource(newPath)
            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual("Muffy", config.GetValue("cat"))

            Call File.Delete(filePath)
            Call File.Delete(newPath)
        End Sub

        '<Test()>
        Public Sub SaveToWriter()
            Dim newPath As String
            newPath = "TestNew.xml"

            Dim writer As StringWriter
            Set writer = NewStringWriter()
            Call NiniWriter(writer)
            Call WriteSection(writer, "Pets")
            Call WriteKey(writer, "cat", "Muffy")
            Call WriteKey(writer, "dog", "Rover")
            Call WriteEndsection(writer)
            Call WriteEndDocument(writer)
            Call writer.CloseWriter

            Dim reader As StringReader
            Set reader = NewStringReader(writer.ToString())
            'Dim xmlReader As New XmlTextReader(reader)
            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(reader)

            Dim config As IConfig
            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual("Muffy", config.GetValue("cat"))

            Dim textWriter As StreamWriter
            Set textWriter = NewStreamWriter(newPath)
            Call source.Save_textWriter(textWriter)
            Call textWriter.CloseWriter
            ' save to disk
            Set source = NewXmlConfigSource(newPath)
            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual("Muffy", config.GetValue("cat"))

            Call File.Delete(newPath)
        End Sub

        '<Test()>
        Public Sub ReplaceText()
            Dim textWriter As StringWriter
            Set textWriter = NewStringWriter()
            'Dim xmlWriter As XmlTextWriter =
            Call NiniWriter(textWriter)
            Call WriteSection(textWriter, "Test")
            Call WriteKey(textWriter, "author", "Brent")
            Call WriteKey(textWriter, "domain", "${protocol}://nini.sf.net/")
            Call WriteKey(textWriter, "apache", "Apache implements ${protocol}")
            Call WriteKey(textWriter, "developer", "author of Nini: ${author} !")
            Call WriteKey(textWriter, "love", "We love the ${protocol} protocol")
            Call WriteKey(textWriter, "combination", "${author} likes ${protocol}")
            Call WriteKey(textWriter, "fact", "fact: ${apache}")
            Call WriteKey(textWriter, "protocol", "http")
            Call WriteKey(textWriter, "test", "{http}")
            Call WriteEndsection(textWriter)
            Call WriteEndDocument(textWriter)

            Dim reader As StringReader
            Set reader = NewStringReader(textWriter.ToString())
            'Dim xmlReader As XmlTextReader
            'Set xmlReader = NewXmlTextReader(reader)
            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(reader)
            Call source.ReplaceKeyValues

            Dim config As IConfig
            Set config = source.Configs("Test")
            Call Assert.AreEqual("http", config.GetValue("protocol"))
            Call Assert.AreEqual("fact: Apache implements http", config.GetValue("fact"))
            Call Assert.AreEqual("http://nini.sf.net/", config.GetValue("domain"))
            Call Assert.AreEqual("Apache implements http", config.GetValue("apache"))
            Call Assert.AreEqual("We love the http protocol", config.GetValue("love"))
            Call Assert.AreEqual("author of Nini: Brent !", config.GetValue("developer"))
            Call Assert.AreEqual("Brent likes http", config.GetValue("combination"))
        End Sub

        '<Test()>
        Public Sub SaveNewSection()
            Dim filePath As String
            filePath = "Test.xml"

            Dim textWriter As StringWriter
            Set textWriter = NewStringWriter()
            Call NiniWriter(textWriter)
            Call WriteSection(textWriter, "new section")
            Call WriteKey(textWriter, "dog", "Rover")
            Call WriteKey(textWriter, "cat", "Muffy")
            Call WriteEndsection(textWriter)
            Call WriteEndDocument(textWriter)

            Dim doc As New DOMDocument
            Call doc.loadXML(textWriter.ToString())
            Call doc.Save(filePath)

            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(filePath)
            Dim config As IConfig
            Set config = source.AddConfig("test")
            Call Assert.IsNotNull(source.Configs("test"))
            Call source.Save

            Set source = NewXmlConfigSource(filePath)
            Set config = source.Configs("new section")
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual("Muffy", config.GetValue("cat"))
            Call Assert.IsNotNull(source.Configs("test"))

            Call File.Delete(filePath)
        End Sub

        '<Test()>
        Public Sub RemoveConfigAndKeyFromFile()
            Dim filePath As String
            filePath = "Test.xml"

            Dim xmlWriter As StreamWriter
            Set xmlWriter = NewStreamWriter(filePath)
            Call NiniWriter(xmlWriter)
            Call WriteSection(xmlWriter, "test 1")
            Call WriteKey(xmlWriter, "dog", "Rover")
            Call WriteEndsection(xmlWriter)
            Call WriteSection(xmlWriter, "test 2")
            Call WriteKey(xmlWriter, "cat", "Muffy")
            Call WriteKey(xmlWriter, "lizard", "Lizzy")
            Call WriteEndsection(xmlWriter)
            Call WriteEndDocument(xmlWriter)
            Call xmlWriter.CloseWriter

            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(filePath)
            Call Assert.IsNotNothing(source.Configs("test 1"))
            Call Assert.IsNotNothing(source.Configs("test 2"))
            Call Assert.AreNotEqual("", source.Configs("test 2").GetValue("cat"))

            Call source.Configs.Remove(source.Configs("test 1"))
            Call source.Configs("test 2").Remove("cat")
            Call source.AddConfig("cause error")
            Call source.Save

            Set source = NewXmlConfigSource(filePath)
            Call Assert.IsNothing(source.Configs("test 1"))
            Call Assert.IsNotNull(source.Configs("test 2"))
            Call Assert.AreEqual("", source.Configs("test 2").GetValue("cat"))

            Call File.Delete(filePath)
        End Sub

        '<Test()>
        Public Sub ToStringTest()
            Dim writer As StringWriter
            Set writer = NewStringWriter()
            
            Call NiniWriter(writer)
            Call WriteSection(writer, "Pets")
            Call WriteKey(writer, "cat", "Muffy")
            Call WriteKey(writer, "dog", "Rover")
            Call WriteEndsection(writer)
            Call WriteEndDocument(writer)
            Call writer.CloseWriter

            Dim reader As StringReader
            Set reader = NewStringReader(writer.ToString())
            
            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(reader)

            Dim eol As String
            eol = Environment.NewLine

            Dim compare As String
            compare = "<?xml version=""1.0"" encoding=""utf-16""?>" + eol + "<Nini>" + eol + "  <Section Name=""Pets"">" + eol + "    <Key Name=""cat"" Value=""Muffy"" />" + eol + "    <Key Name=""dog"" Value=""Rover"" />" + eol + "  </Section>" + eol + "</Nini>"
            'Call Assert.AreEqual(compare, source.ToString())
        End Sub

        '<Test()>
        Public Sub EmptyConstructor()
            Dim filePath As String
            filePath = "EmptyConstructor.xml"
            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource()

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

            Set source = NewXmlConfigSource(filePath)
            Set config = source.Configs("Pets")

            Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("Muffy", config.GetValue("cat"))
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual("Tweety", config.GetValue("bird"))

            File.Delete (filePath)
        End Sub

        '<Test()>
        Public Sub Reload()
            Dim filePath As String
            filePath = "Reload.xml"
            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource()

            Dim petConfig As IConfig
            Set petConfig = source.AddConfig("Pets")
            Call petConfig.SetValue("cat", "Muffy")
            Call petConfig.SetValue("dog", "Rover")
            Dim weatherConfig As IConfig
            Set weatherConfig = source.AddConfig("Weather")
            Call weatherConfig.SetValue("skies", "cloudy")
            Call weatherConfig.SetValue("precipitation", "rain")
            source.Save_path (filePath)

            Call Assert.AreEqual(2, cArray.GetLength(petConfig.GetKeys()))
            Call Assert.AreEqual("Muffy", petConfig.GetValue("cat"))
            Call Assert.AreEqual(2, source.Configs.Count)

            Dim newSource As XmlConfigSource
            Set newSource = NewXmlConfigSource(filePath)

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
            Call source.Save
            ' saves new value
            ' Reload the new source and check for changes
            Call newSource.Reload
            Call Assert.IsTrue(compareConfig Is newSource.Configs("Pets"), "References after are not equal")
            Call Assert.AreEqual(1, newSource.Configs.Count)
            Call Assert.AreEqual(3, cArray.GetLength(newSource.Configs("Pets").GetKeys()))
            Call Assert.AreEqual("Lizzy", newSource.Configs("Pets").GetValue("lizard"))
            Call Assert.AreEqual("Misha", newSource.Configs("Pets").GetValue("cat"))
            Call Assert.AreEqual("", newSource.Configs("Pets").GetValue("dog"))

            Call File.Delete(filePath)
        End Sub

        '<Test()>
        Public Sub SaveToStream()
            Dim filePath As String
            filePath = "SaveToStream.ini"
            Dim stream As FileStream
            Set stream = NewFileStream(filePath, FileMode.Create)

            ' Create a new document and save to stream
            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource()
            Dim config As IConfig
            Set config = source.AddConfig("Pets")
            Call config.SetValue("dog", "rover")
            Call config.SetValue("cat", "muffy")
            Call source.Save_stream(stream)
            Call stream.CloseStream

            Dim newSource As XmlConfigSource
            Set newSource = NewXmlConfigSource(filePath)
            Set config = newSource.Configs("Pets")
            Call Assert.IsNotNull(config)
            Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("rover", config.GetString("dog"))
            Call Assert.AreEqual("muffy", config.GetString("cat"))

            Call stream.CloseStream

            File.Delete (filePath)
        End Sub

        '<Test()>
        Public Sub LoadReader()
            Dim textWriter As StringWriter
            Set textWriter = NewStringWriter()
            Call NiniWriter(textWriter)
            Call WriteSection(textWriter, "Pets")
            Call WriteKey(textWriter, "cat", "muffy")
            Call WriteKey(textWriter, "dog", "rover")
            Call WriteKey(textWriter, "bird", "tweety")
            Call WriteEndsection(textWriter)
            Call WriteEndDocument(textWriter)

            Dim reader As StringReader
            Set reader = NewStringReader(textWriter.ToString())
            'Dim xmlReader As New XmlTextReader(reader)
            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(reader)

            Dim config As IConfig
            Set config = source.Configs("Pets")
            Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("rover", config.GetValue("dog"))

            Call config.SetValue("dog", "new name")
            Call config.Remove("bird")

            Set reader = NewStringReader(textWriter.ToString())
            
            Call source.Load_TextReader(reader)

            Set config = source.Configs("Pets")
            Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("rover", config.GetValue("dog"))
        End Sub
        '#End Region

        '#Region "Private methods"
        Private Function NiniWriter(ByRef writer As textWriter) 'As XmlTextWriter
            'Dim result As New XmlTextWriter(writer)
            'result.Indentation = 0
            
            'result.WriteStartDocument()
            Call writer.WriteLine("<Nini>")

            
        End Function
        
        Private Function WriteEndDocument(ByRef writer As textWriter) 'As XmlTextWriter
            'Dim result As New XmlTextWriter(writer)
            'result.Indentation = 0
            
            'result.WriteStartDocument()
            Call writer.WriteLine("</Nini>")

            
        End Function
        
        Private Sub WriteSection(ByRef writer As textWriter, ByVal sectionName As String)
            writer.WriteValue ("  <Section ")
            Call writer.WriteLine("Name=""{0}"" >", sectionName)
        End Sub
        
        Private Sub WriteEndsection(ByRef writer As textWriter)
            writer.WriteLine ("  </Section>")
        End Sub
        
        Private Sub WriteKey(ByRef writer As textWriter, ByVal key As String, ByVal value As String)
            Call writer.WriteValue("    <Key ")
            Call writer.WriteValue("Name=""{0}"" ", key)
            Call writer.WriteLine("Value=""{0}"" />", value)
            'writer.WriteEndElement()
        End Sub
        '#End Region

