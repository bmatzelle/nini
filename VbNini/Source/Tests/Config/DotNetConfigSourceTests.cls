VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "DotNetConfigSTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'#Region "Tests"
'<Test()>
Public Sub GetConfig()
    Dim doc As DOMDocument
    Set doc = NiniDoc()
    Call AddSection(doc, "Pets")
    Call AddKey(doc, "Pets", "cat", "muffy")
    Call AddKey(doc, "Pets", "dog", "rover")
    Call AddKey(doc, "Pets", "bird", "tweety")

    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource(DocumentToReader(doc))

    Dim config As IConfig
    Set config = source.Configs("Pets")
    Call Assert.AreEqual("Pets", config.Name)
    Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual(source, config.ConfigSource)
End Sub

'<Test()>
Public Sub GetString()
    Dim doc As DOMDocument
    Set doc = NiniDoc()
    Call AddSection(doc, "Pets")
    Call AddKey(doc, "Pets", "cat", "muffy")
    Call AddKey(doc, "Pets", "dog", "rover")
    Call AddKey(doc, "Pets", "bird", "tweety")

    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource(DocumentToReader(doc))
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
    Dim doc As DOMDocument
    Set doc = NiniDoc()
    Call AddSection(doc, "Pets")
    Call AddKey(doc, "Pets", "value 1", "495")

    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource(DocumentToReader(doc))

    Dim config As IConfig
    Set config = source.Configs("Pets")

    Call Assert.AreEqual(495, config.GetInt("value 1"))
    Call Assert.AreEqual(123, config.GetInt("Not Here", 123))

    On Error GoTo CatchMe
        config.GetInt ("Not Here Also")
        Call Assert.Fail
CatchMe:
    Dim ex As Exception
    If Catch(ex) Then
    End If
End Sub

'<Test()>
Public Sub SetAndSave()
    Dim filePath As String
    filePath = "Test.xml"

    Dim doc As DOMDocument
    Set doc = NiniDoc()
    Call AddSection(doc, "NewSection")
    Call AddKey(doc, "NewSection", "dog", "Rover")
    Call AddKey(doc, "NewSection", "cat", "Muffy")
    doc.save (filePath)

    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource(filePath)

    Dim config As IConfig
    Set config = source.Configs("NewSection")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))

    Call config.SetValue("dog", "Spots")
    Call config.SetValue("cat", "Misha")
    Call config.SetValue("DoesNotExist", "SomeValue")

    Call Assert.AreEqual("Spots", config.GetValue("dog"))
    Call Assert.AreEqual("Misha", config.GetValue("cat"))
    Call Assert.AreEqual("SomeValue", config.GetValue("DoesNotExist"))
    Call source.save

    Set source = NewDotNetConfigSource(filePath)
    Set config = source.Configs("NewSection")
    Call Assert.AreEqual("Spots", config.GetValue("dog"))
    Call Assert.AreEqual("Misha", config.GetValue("cat"))
    Call Assert.AreEqual("SomeValue", config.GetValue("DoesNotExist"))

    File.Delete (filePath)
End Sub

'<Test()>
Public Sub MergeAndSave()
    Dim xmlFileName As String
    xmlFileName = "NiniConfig.xml"

    Dim doc As DOMDocument
    Set doc = NiniDoc()
    Call AddSection(doc, "Pets")
    Call AddKey(doc, "Pets", "cat", "Muffy")
    Call AddKey(doc, "Pets", "dog", "Rover")
    Call AddKey(doc, "Pets", "bird", "Tweety")
    doc.save (xmlFileName)

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
    Dim iniSource As IniConfigSource
    Set iniSource = NewIniConfigSource(NewStringReader(writer.ToString()))

    Dim xmlSource As DotNetConfigSource
    Set xmlSource = NewDotNetConfigSource(xmlFileName)

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

    Call xmlSource.save

    Set xmlSource = NewDotNetConfigSource(xmlFileName)

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

    Dim doc As DOMDocument
    Set doc = NiniDoc()
    Call AddSection(doc, "Pets")
    Call AddKey(doc, "Pets", "cat", "Muffy")
    Call AddKey(doc, "Pets", "dog", "Rover")
    Call doc.save(filePath)

    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource(filePath)
    Dim config As IConfig
    Set config = source.Configs("Pets")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))

    Call source.Save_path(newPath)

    Set source = NewDotNetConfigSource(newPath)
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

    Dim doc As DOMDocument
    Set doc = NiniDoc()
    Call AddSection(doc, "Pets")
    Call AddKey(doc, "Pets", "cat", "Muffy")
    Call AddKey(doc, "Pets", "dog", "Rover")

    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource(DocumentToReader(doc))
    Dim config As IConfig
    Set config = source.Configs("Pets")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))

    Dim textWriter As StreamWriter
    Set textWriter = NewStreamWriter(newPath)
    Call source.Save_textWriter(textWriter)
    textWriter.CloseWriter
    ' save to disk
    Set source = NewDotNetConfigSource(newPath)
    Set config = source.Configs("Pets")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))

    File.Delete (newPath)
End Sub

'<Test()>
Public Sub ReplaceText()
    Dim doc As DOMDocument
    Set doc = NiniDoc()
    Call AddSection(doc, "Test")
    Call AddKey(doc, "Test", "author", "Brent")
    Call AddKey(doc, "Test", "domain", "${protocol}://nini.sf.net/")
    Call AddKey(doc, "Test", "apache", "Apache implements ${protocol}")
    Call AddKey(doc, "Test", "developer", "author of Nini: ${author} !")
    Call AddKey(doc, "Test", "love", "We love the ${protocol} protocol")
    Call AddKey(doc, "Test", "combination", "${author} likes ${protocol}")
    Call AddKey(doc, "Test", "fact", "fact: ${apache}")
    Call AddKey(doc, "Test", "protocol", "http")

    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource(DocumentToReader(doc))
    source.ReplaceKeyValues

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

    Dim doc As DOMDocument
    Set doc = NiniDoc()
    Call AddSection(doc, "NewSection")
    Call AddKey(doc, "NewSection", "dog", "Rover")
    Call AddKey(doc, "NewSection", "cat", "Muffy")
    doc.save (filePath)

    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource(filePath)
    Dim config As IConfig
    Set config = source.AddConfig("test")
    Call Assert.IsNotNull(source.Configs("test"))
    source.save

    Set source = NewDotNetConfigSource(filePath)
    Set config = source.Configs("NewSection")
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))
    Call Assert.IsNotNull(source.Configs("test"))

    File.Delete (filePath)
End Sub

''<Test()>
'Public Sub ToStringTest()
'    Dim doc As DOMDocument
'    Set doc = NiniDoc()
'    Call AddSection(doc, "Pets")
'    Call AddKey(doc, "Pets", "cat", "Muffy")
'    Call AddKey(doc, "Pets", "dog", "Rover")
'
'    Dim source As DotNetConfigSource
'    Set source = NewDotNetConfigSource(DocumentToReader(doc))
'    Dim eol As String
'    eol = Environment.NewLine
'
'    Dim compare As String
'    'compare = "<?xml version=""1.0"" encoding=""utf-16""?>" + eol + "<configuration>" + eol + "  <configSections>" + eol + "    <section name=""Pets"" " + "type=""System.Configuration.NameValueSectionHandler"" />" + eol + "  </configSections>" + eol + "  <Pets>" + eol + "    <add key=""cat"" value=""Muffy"" />" + eol + "    <add key=""dog"" value=""Rover"" />" + eol + "  </Pets>" + eol + "</configuration>"
'    'Call Assert.AreEqual(compare, source.ToString())
'End Sub

'<Test()>
Public Sub EmptyConstructor()
    Dim filePath As String
    filePath = "EmptyConstructor.xml"
    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource()

    Dim config As IConfig
    Set config = source.AddConfig("Pets")
    Call config.SetValue("cat", "Muffy")
    Call config.SetValue("dog", "Rover")
    Call config.SetValue("bird", "Tweety")
    Call source.Save_path(filePath)

    Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("Muffy", config.GetValue("cat"))
    Call Assert.AreEqual("Rover", config.GetValue("dog"))
    Call Assert.AreEqual("Tweety", config.GetValue("bird"))

    Set source = NewDotNetConfigSource(filePath)
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
    filePath = "ReloadDot.xml"
    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource()

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

    Dim newSource As DotNetConfigSource
    Set newSource = NewDotNetConfigSource(filePath)

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
    Call Assert.AreEqual("", newSource.Configs("Pets").GetValue("dog"))

    File.Delete (filePath)
End Sub

'<Test()>
Public Sub SaveToStream()
    Dim filePath As String
    filePath = "SaveToStream.ini"
    Dim stream As FileStream
    Set stream = NewFileStream(filePath, FileMode.Create)

    ' Create a new document and save to stream
    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource()
    Dim config As IConfig
    Set config = source.AddConfig("Pets")
    Call config.SetValue("dog", "rover")
    Call config.SetValue("cat", "muffy")
    Call source.Save_stream(stream)
    Call stream.CloseStream

    Dim newSource As DotNetConfigSource
    Set newSource = NewDotNetConfigSource(filePath)
    Set config = newSource.Configs("Pets")
    Call Assert.IsNotNull(config)
    Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("rover", config.GetString("dog"))
    Call Assert.AreEqual("muffy", config.GetString("cat"))

    Call stream.CloseStream

    Call File.Delete(filePath)
End Sub

'<Test()>
Public Sub NoConfigSectionsNode()
    Dim filePath As String
    filePath = "AppSettings.xml"

    ' Create an XML document with no configSections node
    Dim doc As DOMDocument
    Set doc = New DOMDocument
    Call doc.loadXML("<configuration></configuration>")

    Dim node As IXMLDOMNode
    Set node = doc.createElement("appSettings")
    Call doc.documentElement.appendChild(node)
    Call AddKey(doc, "appSettings", "Test", "Hello")


    Call doc.save(filePath)

    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource(filePath)

    Dim config As IConfig
    Set config = source.Configs("appSettings")
    Call Assert.AreEqual("Hello", config.GetString("Test"))

    Call File.Delete(filePath)
End Sub

'<Test()>
Public Sub LoadReader()
    Dim doc As DOMDocument
    Set doc = NiniDoc()
    Call AddSection(doc, "Pets")
    Call AddKey(doc, "Pets", "cat", "muffy")
    Call AddKey(doc, "Pets", "dog", "rover")
    Call AddKey(doc, "Pets", "bird", "tweety")

    Dim source As DotNetConfigSource
    Set source = NewDotNetConfigSource(DocumentToReader(doc))

    Dim config As IConfig
    Set config = source.Configs("Pets")
    Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("rover", config.GetValue("dog"))

    Call config.SetValue("dog", "new name")
    Call config.Remove("bird")

    Call source.Load_TextReader(DocumentToReader(doc))

    Set config = source.Configs("Pets")
    Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
    Call Assert.AreEqual("rover", config.GetValue("dog"))
End Sub
'#End Region

'#Region "Private methods"
Private Function NiniDoc() As DOMDocument
    Dim doc As New DOMDocument
    doc.loadXML ("<configuration><configSections/></configuration>")

    Set NiniDoc = doc
End Function

Private Sub AddSection(ByVal doc As DOMDocument, ByVal sectionName As String)
    Dim node As IXMLDOMNode
    Set node = doc.selectSingleNode("/configuration/configSections")

    Dim sectionNode As IXMLDOMNode
    Set sectionNode = doc.createElement("section")
    Call node.appendChild(sectionNode)

    Dim attrNode As IXMLDOMNode
    Set attrNode = doc.createAttribute("name")
    
    attrNode.nodeValue = sectionName
    Call sectionNode.Attributes.setNamedItem(attrNode)

    Set attrNode = doc.createAttribute("type")
    attrNode.nodeValue = "System.Configuration.NameValueSectionHandler"
    Call sectionNode.Attributes.setNamedItem(attrNode)

    If cString.IndexOfAny(sectionName, (" ")) <> -1 Then
        Console.WriteLine (sectionName)
    End If
    Set sectionNode = doc.createElement(sectionName)
    Call doc.documentElement.appendChild(sectionNode)
End Sub

Private Sub AddKey(ByVal doc As DOMDocument, ByVal section As String, ByVal key As String, ByVal value As String)
    Dim sectionNode As IXMLDOMNode
    Set sectionNode = doc.selectSingleNode("/configuration/" + section)

    Dim keyNode As IXMLDOMElement
    Set keyNode = doc.createElement("add")
    Dim attrNode As IXMLDOMAttribute
    Set attrNode = doc.createAttribute("key")
    attrNode.value = key
    Call keyNode.Attributes.setNamedItem(attrNode)

    Set attrNode = doc.createAttribute("value")
    attrNode.value = value
    Call keyNode.Attributes.setNamedItem(attrNode)

    Call sectionNode.appendChild(keyNode)
End Sub

Private Function DocumentToReader(ByVal doc As DOMDocument) As StringReader
    Dim reader As StringReader
    Set reader = NewStringReader(doc.xml)
    Set DocumentToReader = reader
End Function
'#End Region

