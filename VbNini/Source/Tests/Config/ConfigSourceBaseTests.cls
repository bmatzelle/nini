VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ConfigSBTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'#Region "Private variables"
        Private eventConfig As IConfig
        Private eventSource As IConfigSource
        Private reloadedCount As Integer
        Private savedCount As Integer
        Private keyName As String
        Private keyValue As String
        Private keySetCount As Integer
        Private keyRemovedCount As Integer
        Private WithEvents eventTestconfig As ConfigBase
Attribute eventTestconfig.VB_VarHelpID = -1
        Private WithEvents eventTestsource As INIConfigSource
Attribute eventTestsource.VB_VarHelpID = -1
        '#End Region

        '#Region "Unit tests"
        '<Test()>
        Public Sub Merge()
            Dim xmlWriter As StringWriter
            Set xmlWriter = NewStringWriter()
            Call NiniWriter(xmlWriter)
            Call WriteSection(xmlWriter, "Pets")
            Call WriteKey(xmlWriter, "cat", "muffy")
            Call WriteKey(xmlWriter, "dog", "rover")
            Call WriteKey(xmlWriter, "bird", "tweety")
            Call WriteEndsection(xmlWriter)
            Call WriteEndDocument(xmlWriter)

            Dim reader As StringReader
            Set reader = NewStringReader(xmlWriter.ToString())
            'Dim xmlReader As New XmlTextReader(reader)
            Dim xmlSource As XmlConfigSource
            Set xmlSource = NewXmlConfigSource(reader)

            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            Call writer.AppendLine("[Test]")
            Call writer.AppendLine("[People]")
            Call writer.AppendLine(" woman = Jane")
            Call writer.AppendLine(" man = John")
            Dim iniSource As INIConfigSource
            Set iniSource = NewIniConfigSource(NewStringReader(writer.ToString()))

            Call xmlSource.Merge(iniSource)

            Dim config As IConfig
            Set config = xmlSource.Configs("Pets")
            Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("muffy", config.GetValue("cat"))
            Call Assert.AreEqual("rover", config.GetValue("dog"))

            Set config = xmlSource.Configs("People")
            Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("Jane", config.GetValue("woman"))
            Call Assert.AreEqual("John", config.GetValue("man"))
        End Sub

        '<ExpectedException(GetType(ArgumentException))>
        Public Sub MergeItself()
            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            Call writer.AppendLine("[Test]")
            Call writer.AppendLine("[People]")
            Call writer.AppendLine(" woman = Jane")
            Call writer.AppendLine(" man = John")
            Dim iniSource As INIConfigSource
            Set iniSource = NewIniConfigSource(NewStringReader(writer.ToString()))
            On Error GoTo CatchMe
            Call iniSource.Merge(iniSource)
CatchMe:
            Dim ex As Exception
            If Catch(ex) Then
                Call Assert.IsTrue(TypeOf ex Is ArgumentException)
            Else
                Call Assert.IsTrue(TypeOf ex Is ArgumentException)
            End If
            ' exception
        End Sub

        '<ExpectedException(GetType(ArgumentException))>
        Public Sub MergeExisting()
            Dim xmlWriter As StringWriter
            Set xmlWriter = NewStringWriter()
            Call NiniWriter(xmlWriter)
            Call WriteSection(xmlWriter, "Pets")
            Call WriteKey(xmlWriter, "cat", "muffy")
            Call WriteEndsection(xmlWriter)
            Call WriteEndDocument(xmlWriter)

            Dim reader As StringReader
            Set reader = NewStringReader(xmlWriter.ToString())
            'Dim xmlReader As New XmlTextReader(reader)
            Dim xmlSource As XmlConfigSource
            Set xmlSource = NewXmlConfigSource(reader)

            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            Call writer.AppendLine("[Test]")
            Call writer.AppendLine("[People]")
            Call writer.AppendLine(" woman = Jane")
            Dim iniSource As INIConfigSource
            Set iniSource = NewIniConfigSource(NewStringReader(writer.ToString()))

            On Error GoTo CatchMe
            Call xmlSource.Merge(iniSource)
            Call xmlSource.Merge(iniSource)
CatchMe:
            Dim ex As Exception
            If Catch(ex) Then
                Call Assert.IsTrue(TypeOf ex Is ArgumentException)
            Else
                Call Assert.Fail("Expected ArgumentException")
            End If
            ' exception
        End Sub

        '<Test()>
        Public Sub AutoSave()
            Dim filePath As String
            filePath = "AutoSaveTest.ini"

            Dim writer As StreamWriter
            Set writer = NewStreamWriter(filePath)
            Call writer.WriteLine("; some comment")
            Call writer.WriteLine("[new section]")
            Call writer.WriteLine(" dog = Rover")
            Call writer.WriteLine("")
            ' empty line
            Call writer.WriteLine("; a comment")
            Call writer.WriteLine(" cat = Muffy")
            writer.CloseWriter

            Dim source As INIConfigSource
            Set source = NewIniConfigSource(filePath)
            source.AutoSave = True
            Dim config As IConfig
            Set config = source.Configs("new section")
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual("Muffy", config.GetValue("cat"))

            Call config.SetValue("dog", "Spots")
            Call config.SetValue("cat", "Misha")

            Call Assert.AreEqual("Spots", config.GetValue("dog"))
            Call Assert.AreEqual("Misha", config.GetValue("cat"))

            Set source = NewIniConfigSource(filePath)
            Set config = source.Configs("new section")
            Call Assert.AreEqual("Spots", config.GetValue("dog"))
            Call Assert.AreEqual("Misha", config.GetValue("cat"))

            File.Delete (filePath)
        End Sub

        '<Test()>
        Public Sub AddConfig()
            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            Call writer.AppendLine("[Test]")
            Call writer.AppendLine("[Test]")
            Call writer.AppendLine(" bool 1 = TrUe")
            Dim source As INIConfigSource
            Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

            Dim newConfig As IConfig
            Set newConfig = source.AddConfig("NewConfig")
            Call newConfig.SetValue("NewKey", "NewValue")
            Call newConfig.SetValue("AnotherKey", "AnotherValue")

            Dim config As IConfig
            Set config = source.Configs("NewConfig")
            Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("NewValue", config.GetValue("NewKey"))
            Call Assert.AreEqual("AnotherValue", config.GetValue("AnotherKey"))
        End Sub

        '<Test()>
        Public Sub ExpandText()
            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            Call writer.AppendLine("[Test]")
            Call writer.AppendLine(" author = Brent")
            Call writer.AppendLine(" domain = ${protocol}://nini.sf.net/")
            Call writer.AppendLine(" apache = Apache implements ${protocol}")
            Call writer.AppendLine(" developer = author of Nini: ${author} !")
            Call writer.AppendLine(" love = We love the ${protocol} protocol")
            Call writer.AppendLine(" combination = ${author} likes ${protocol}")
            Call writer.AppendLine(" fact = fact: ${apache}")
            Call writer.AppendLine(" protocol = http")
            Dim source As INIConfigSource
            Set source = NewIniConfigSource(NewStringReader(writer.ToString()))
            source.ExpandKeyValues

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
        Public Sub ExpandTextOtherSection()
            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            Call writer.AppendLine("[web]")
            Call writer.AppendLine(" apache = Apache implements ${protocol}")
            Call writer.AppendLine(" protocol = http")
            Call writer.AppendLine("[server]")
            Call writer.AppendLine(" domain = ${web|protocol}://nini.sf.net/")
            Dim source As INIConfigSource
            Set source = NewIniConfigSource(NewStringReader(writer.ToString()))
            source.ExpandKeyValues

            Dim config As IConfig
            Set config = source.Configs("web")
            Call Assert.AreEqual("http", config.GetValue("protocol"))
            Call Assert.AreEqual("Apache implements http", config.GetValue("apache"))
            Set config = source.Configs("server")
            Call Assert.AreEqual("http://nini.sf.net/", config.GetValue("domain"))
        End Sub

        '<Test()>
        Public Sub ExpandKeyValuesMerge()
            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            
            Call writer.AppendLine("[web]")
            Call writer.AppendLine(" protocol = http")
            Call writer.AppendLine("[server]")
            Call writer.AppendLine(" domain1 = ${web|protocol}://nini.sf.net/")
            Dim source As INIConfigSource
            Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

            Dim newWriter As StringBuilder
            Set newWriter = NewStringBuilder()
            Call newWriter.AppendLine("[web]")
            Call newWriter.AppendLine(" apache = Apache implements ${protocol}")
            Call newWriter.AppendLine("[server]")
            Call newWriter.AppendLine(" domain2 = ${web|protocol}://nini.sf.net/")
            Dim newSource As INIConfigSource
            Set newSource = NewIniConfigSource(NewStringReader(newWriter.ToString()))
            Call source.Merge(newSource)
            source.ExpandKeyValues

            Dim config As IConfig
            Set config = source.Configs("web")
            Call Assert.AreEqual("http", config.GetValue("protocol"))
            Call Assert.AreEqual("Apache implements http", config.GetValue("apache"))
            Set config = source.Configs("server")
            Call Assert.AreEqual("http://nini.sf.net/", config.GetValue("domain1"))
            Call Assert.AreEqual("http://nini.sf.net/", config.GetValue("domain2"))
        End Sub

        '<Test()>
        Public Sub AddNewConfigsAndKeys()
            ' Add some new configs and keys here and test.
            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            Call writer.AppendLine("[Pets]")
            Call writer.AppendLine(" cat = muffy")
            Call writer.AppendLine(" dog = rover")
            Dim source As INIConfigSource
            Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

            Dim config As IConfig
            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Pets", config.Name)
            Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))

            Dim newConfig As IConfig
            Set newConfig = source.AddConfig("NewTest")
            Call newConfig.SetValue("Author", "Brent")
            Call newConfig.SetValue("Birthday", "February 8th")

            Set newConfig = source.AddConfig("AnotherNew")

            Call Assert.AreEqual(3, source.Configs.Count)
            Set config = source.Configs("NewTest")
            Call Assert.IsNotNull(config)
            Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("February 8th", config.GetValue("Birthday"))
            Call Assert.AreEqual("Brent", config.GetValue("Author"))
        End Sub

        '<Test()>
        Public Sub GetBooleanSpace()
            Dim xmlWriter As StringWriter
            Set xmlWriter = NewStringWriter()
            Call NiniWriter(xmlWriter)
            Call WriteSection(xmlWriter, "Pets")
            Call WriteKey(xmlWriter, "cat", "muffy")
            Call WriteKey(xmlWriter, "dog", "rover")
            Call WriteKey(xmlWriter, "Is Mammal", "False")
            Call WriteEndsection(xmlWriter)
            Call WriteEndDocument(xmlWriter)

            Dim reader As StringReader
            Set reader = NewStringReader(xmlWriter.ToString())
            'Dim xmlReader As New XmlTextReader(reader)
            Dim source As XmlConfigSource
            Set source = NewXmlConfigSource(reader)

            Call source.alias.AddAliasBool("true", True)
            Call source.alias.AddAliasBool("false", False)

            Call Assert.IsFalse(source.Configs("Pets").GetBoolean("Is Mammal", False))
        End Sub

        '<Test()>
        Public Sub RemoveNonExistingKey()
            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            
            Call writer.AppendLine("[Pets]")
            Call writer.AppendLine(" cat = muffy")
            Call writer.AppendLine(" dog = rover")
            Dim source As INIConfigSource
            Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

            ' This should not throw an exception
            Call source.Configs("Pets").Remove("Not here")
        End Sub

        '<Test()>
        Public Sub SavingWithNonStrings()
            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            
            Call writer.AppendLine("[Pets]")
            Call writer.AppendLine(" cat = muffy")
            Dim source As INIConfigSource
            Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

            Dim newWriter As StringWriter
            Set newWriter = NewStringWriter()
            Dim config As IConfig
            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Pets", config.Name)
            Call config.SetValue("count", 1)

            Call source.Save_textWriter(newWriter)
        End Sub

        '<Test()>
        Public Sub ConfigSourceEvents()
            Dim filePath As String
            filePath = "EventTest.ini"

            Set eventTestsource = NewIniConfigSource()
            'AddHandler source.Saved, AddressOf source_saved
            'AddHandler source.Reloaded, AddressOf source_reloaded

            Call Assert.IsNothing(eventConfig)
            Call Assert.IsNothing(eventSource)

            Dim config As IConfig
            Set config = eventTestsource.AddConfig("Test")

            Set eventSource = Nothing
            Call Assert.AreEqual(savedCount, 0)
            Call eventTestsource.Save_path(filePath)
            Call Assert.AreEqual(savedCount, 1)
            Call Assert.IsTrue(eventTestsource Is eventSource)

            Set eventSource = Nothing
            Call eventTestsource.save
            Call Assert.AreEqual(savedCount, 2)
            Call Assert.IsTrue(eventTestsource Is eventSource)

            Set eventSource = Nothing
            Call Assert.AreEqual(reloadedCount, 0)
            Call eventTestsource.Reload
            Call Assert.AreEqual(reloadedCount, 1)
            Call Assert.IsTrue(eventTestsource Is eventSource)

            File.Delete (filePath)
        End Sub

        '<Test()>
        Public Sub ConfigEvents()
            Dim source As IConfigSource
            Set source = NewIniConfigSource()

            'Dim eventTestconfig As IConfig
            Set eventTestconfig = source.AddConfig("Test")
            'AddHandler config.KeySet, AddressOf config_keySet
            'AddHandler config.KeyRemoved, AddressOf config_keyRemoved

            ' Set key events
            Call Assert.AreEqual(keySetCount, 0)

            Call eventTestconfig.SetValue("Test 1", "Value 1")
            Call Assert.AreEqual(keySetCount, 1)
            Call Assert.AreEqual("Test 1", keyName)
            Call Assert.AreEqual("Value 1", keyValue)

            Call eventTestconfig.SetValue("Test 2", "Value 2")
            Call Assert.AreEqual(keySetCount, 2)
            Call Assert.AreEqual("Test 2", keyName)
            Call Assert.AreEqual("Value 2", keyValue)

            ' Remove key events
            Call Assert.AreEqual(keyRemovedCount, 0)

            Call eventTestconfig.Remove("Test 1")
            Call Assert.AreEqual(keyRemovedCount, 1)
            Call Assert.AreEqual("Test 1", keyName)
            Call Assert.AreEqual("Value 1", keyValue)

            Call eventTestconfig.Remove("Test 2")
            Call Assert.AreEqual(keyRemovedCount, 2)
            Call Assert.AreEqual("Test 2", keyName)
            Call Assert.AreEqual("Value 2", keyValue)
        End Sub

        '<Test()>
        Public Sub ExpandKeyValuesConfigError()
            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            
            Call writer.AppendLine("[server]")
            Call writer.AppendLine(" domain1 = ${web|protocol}://nini.sf.net/")
            Dim source As INIConfigSource
            Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

            On Error GoTo Try1
                Call source.ExpandKeyValues
Try1:
            Dim ex As Exception
            If Catch(ex) Then
                Call Assert.AreEqual("Expand config not found: web", ex.Message)
            End If
        End Sub

        '<Test()>
        Public Sub ExpandKeyValuesKeyError()
            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            
            Call writer.AppendLine("[web]")
            Call writer.AppendLine("not-protocol = hah!")
            Call writer.AppendLine("[server]")
            Call writer.AppendLine(" domain1 = ${web|protocol}://nini.sf.net/")
            Dim source As INIConfigSource
            Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

            On Error GoTo Try1
                Call source.ExpandKeyValues
Try1:
            Dim ex As Exception
            If Catch(ex) Then
                Call Assert.AreEqual("Expand key not found: protocol", ex.Message)
            End If
        End Sub

        '<Test()>
        Public Sub ExpandKeyInfiniteRecursion()
            Dim writer As StringBuilder
            Set writer = NewStringBuilder()
            
            Call writer.AppendLine("[replace]")
            Call writer.AppendLine("test = ${test} broken")
            Dim source As INIConfigSource
            Set source = NewIniConfigSource(NewStringReader(writer.ToString()))

            On Error GoTo Try1
                Call source.ExpandKeyValues
Try1:
            Dim ex As Exception
            If Catch(ex) Then
                Call Assert.AreEqual("Key cannot have a expand value of itself: test", ex.Message)
            End If
        End Sub

        '<Test()>
        Public Sub ConfigBaseGetErrors()
            Dim writer As StringBuilder
            Dim ex As Exception
            Set writer = NewStringBuilder()
            
            Call writer.AppendLine("[web]")
            Call writer.AppendLine("; No keys")
            Dim source As INIConfigSource
            Set source = NewIniConfigSource(NewStringReader(writer.ToString()))
            Dim config As IConfig
            Set config = source.Configs("web")

            On Error GoTo Try1
                config.GetInt ("not_there")
Try1:
            If Catch(ex) Then
                Call Assert.AreEqual("Value not found: not_there", ex.Message)
            End If
            
            On Error GoTo Try2
                config.GetFloat ("not_there")
Try2:
            If Catch(ex) Then
                Call Assert.AreEqual("Value not found: not_there", ex.Message)
            End If
            
            On Error GoTo Try3
                config.GetDouble ("not_there")
Try3:
            If Catch(ex) Then
                Call Assert.AreEqual("Value not found: not_there", ex.Message)
            End If
            
            On Error GoTo Try4
                config.GetLong ("not_there")
Try4:
            If Catch(ex) Then
                Call Assert.AreEqual("Value not found: not_there", ex.Message)
            End If
            
            On Error GoTo Try5
                config.GetBoolean ("not_there")
Try5:
            If Catch(ex) Then
                Call Assert.AreEqual("Value not found: not_there", ex.Message)
            End If
        End Sub

        '<SetUp()>
        Public Sub Setup()
            Set eventConfig = Nothing
            Set eventSource = Nothing
            savedCount = 0
            reloadedCount = 0
            keySetCount = 0
            keyRemovedCount = 0
            
        End Sub
        '#End Region
        '#Region "Private methods"
Private Sub eventTestconfig_KeySet(sender As VBCorLib.IObject, e As VBNini.ConfigKeyEventArgs)
    keySetCount = keySetCount + 1
    keyName = e.keyName
    keyValue = e.keyValue
    Set eventConfig = sender
End Sub

Private Sub eventTestconfig_KeyRemoved(sender As VBCorLib.IObject, e As VBNini.ConfigKeyEventArgs)
    keyRemovedCount = keyRemovedCount + 1
    keyName = e.keyName
    keyValue = e.keyValue
    Set eventConfig = sender
End Sub


Private Sub eventTestsource_Reloaded(sender As VBCorLib.IObject, e As VBCorLib.EventArgs)
    reloadedCount = reloadedCount + 1
    Set eventSource = sender
End Sub

Private Sub eventTestsource_Saved(sender As VBCorLib.IObject, e As VBCorLib.EventArgs)
    savedCount = savedCount + 1
    Set eventSource = sender
End Sub




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




