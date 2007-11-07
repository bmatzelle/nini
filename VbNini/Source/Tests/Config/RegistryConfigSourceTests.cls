VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "RegistryCSTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

        '#Region "Tests"
        '<Test()>
        Public Sub GetSingleLevel()
            Dim source As RegistryConfigSource
            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\Pets")

            Dim config As IConfig
            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Pets", config.Name)
            Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual(source, config.ConfigSource)

            Call Assert.AreEqual("Chi-chi", config.GetValue("cat"))
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual(5, config.GetInt("count"))
        End Sub

        '<Test()>
        '<ExpectedException(GetType(ArgumentException))>
        Public Sub NonExistantKey()
            Dim source As RegistryConfigSource
            Set source = NewRegistryConfigSource()
            On Error GoTo CatchMe
            Call source.AddMapping(Registry.LocalMachine, "Software\Does\NotExist")
CatchMe:
            Dim ex As Exception
            If Catch(ex) Then
            Else
            End If
        End Sub

        '<Test()>
        Public Sub SetAndSaveNormal()
            Dim source As RegistryConfigSource
            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\Pets")

            Dim config As IConfig
            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Chi-chi", config.GetValue("cat"))
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual(5, config.GetInt("count"))

            Call config.SetValue("cat", "Muffy")
            Call config.SetValue("dog", "Spots")
            Call config.SetValue("DoesNotExist", "SomeValue")
            Call config.SetValue("count", 4)

            source.save

            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\Pets")

            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Muffy", config.GetValue("cat"))
            Call Assert.AreEqual("Spots", config.GetValue("dog"))
            Call Assert.AreEqual("SomeValue", config.GetValue("DoesNotExist"))
            Call Assert.AreEqual(4, config.GetInt("count"))
        End Sub

        '<Test()>
        Public Sub Flattened()
            Dim source As RegistryConfigSource
            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp", RegistryRecurse.Flattened)

            Dim config As IConfig
            Set config = source.Configs("NiniTestApp")
            Call Assert.AreEqual("Configuration Library", config.GetValue("Description"))

            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Pets", config.Name)
            Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual(source, config.ConfigSource)

            Call Assert.AreEqual("Chi-chi", config.GetValue("cat"))
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual(5, config.GetInt("count"))

            Call config.SetValue("cat", "Muffy")
            Call config.SetValue("dog", "Spots")
            Call config.SetValue("count", 4)

            source.save

            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\Pets")

            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Muffy", config.GetValue("cat"))
            Call Assert.AreEqual("Spots", config.GetValue("dog"))
            Call Assert.AreEqual(4, config.GetInt("count"))
        End Sub

        '<Test()>
        Public Sub Namespacing()
            Dim source As RegistryConfigSource
            Set source = NewRegistryConfigSource()
            Dim key As RegistryKey
            Set key = Registry.LocalMachine.OpenSubKey("Software")
            Call source.AddMapping(key, "NiniTestApp", RegistryRecurse.Namespacing)

            Dim config As IConfig
            Set config = source.Configs("NiniTestApp")
            Call Assert.AreEqual("Configuration Library", config.GetValue("Description"))

            Set config = source.Configs("NiniTestApp\Pets")
            Call Assert.AreEqual("NiniTestApp\Pets", config.Name)
            Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual(source, config.ConfigSource)

            Call Assert.AreEqual("Chi-chi", config.GetValue("cat"))
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual(5, config.GetInt("count"))

            Call config.SetValue("cat", "Muffy")
            Call config.SetValue("dog", "Spots")
            Call config.SetValue("count", 4)

            source.save

            Set source = NewRegistryConfigSource()
            Set key = Registry.LocalMachine.OpenSubKey("Software")
            Call source.AddMapping(key, "NiniTestApp", RegistryRecurse.Namespacing)

            Set config = source.Configs("NiniTestApp\Pets")
            Call Assert.AreEqual("Muffy", config.GetValue("cat"))
            Call Assert.AreEqual("Spots", config.GetValue("dog"))
            Call Assert.AreEqual(4, config.GetInt("count"))
        End Sub

        '<Test()>
        Public Sub MergeAndSave()
            Dim source As RegistryConfigSource
            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\Pets")

            Dim config As IConfig
            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Chi-chi", config.GetValue("cat"))
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual(5, config.GetInt("count"))

            Dim writer As StringWriter
            Set writer = NewStringWriter()
            Call writer.WriteLine("[Pets]")
            Call writer.WriteLine("cat = Becky")
            ' overwrite
            Call writer.WriteLine("lizard = Saurus")
            ' new
            Call writer.WriteLine("[People]")
            Call writer.WriteLine(" woman = Jane")
            Call writer.WriteLine(" man = John")
            Dim iniSource As IniConfigSource
            Set iniSource = NewIniConfigSource(NewStringReader(writer.ToString()))

            Call source.Merge(iniSource)

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

            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\Pets")

            Set config = source.Configs("Pets")
            Call Assert.AreEqual(4, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("Becky", config.GetValue("cat"))
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual("Saurus", config.GetValue("lizard"))

            Set config = source.Configs("People")
            Call Assert.IsNothing(config)
            ' you cannot merge new sections
            '
'           call Assert.AreEqual (2, config.GetKeys ().Length);
'           call Assert.AreEqual ("Tara", config.Get ("woman"));
'           call Assert.AreEqual ("Quentin", config.Get ("man"));
'
        End Sub

        '<Test()>
        Public Sub Reload()
            Dim source As RegistryConfigSource
            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\Pets")
            Call source.Configs("Pets").SetValue("cat", "Muffy")
            source.save

            Call Assert.AreEqual(3, cArray.GetLength(source.Configs("Pets").GetKeys()))
            Call Assert.AreEqual("Muffy", source.Configs("Pets").GetValue("cat"))

            Dim newSource As RegistryConfigSource
            Set newSource = NewRegistryConfigSource()
            Call newSource.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\Pets")
            Call Assert.AreEqual(3, cArray.GetLength(newSource.Configs("Pets").GetKeys()))
            Call Assert.AreEqual("Muffy", newSource.Configs("Pets").GetValue("cat"))

            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\Pets")
            Call source.Configs("Pets").SetValue("cat", "Misha")
            source.save
            ' saves new value
            newSource.Reload
            Call Assert.AreEqual(3, cArray.GetLength(newSource.Configs("Pets").GetKeys()))
            Call Assert.AreEqual("Misha", newSource.Configs("Pets").GetValue("cat"))
        End Sub

        '<Test()>
        Public Sub AddConfig()
            Dim source As RegistryConfigSource
            Set source = NewRegistryConfigSource()
            Dim key As RegistryKey
            Set key = Registry.LocalMachine.OpenSubKey("Software\NiniTestApp", True)

            Dim config As IConfig
            Set config = source.AddConfig("People", key)
            Call config.SetValue("woman", "Tara")
            Call config.SetValue("man", "Quentin")

            source.save

            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\People")

            Call Assert.AreEqual(1, source.Configs.Count)
            Set config = source.Configs("People")
            Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("Tara", config.GetValue("woman"))
            Call Assert.AreEqual("Quentin", config.GetValue("man"))
        End Sub

        '<Test()>
        Public Sub AddConfigDefaultKey()
            Dim source As RegistryConfigSource
            Set source = NewRegistryConfigSource()
            source.DefaultKey = Registry.LocalMachine.OpenSubKey("Software\NiniTestApp", True)

            Dim config As IConfig
            Set config = source.AddConfig("People")
            Call config.SetValue("woman", "Tara")
            Call config.SetValue("man", "Quentin")

            source.save

            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\People")

            Call Assert.AreEqual(1, source.Configs.Count)
            Set config = source.Configs("People")
            Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual("Tara", config.GetValue("woman"))
            Call Assert.AreEqual("Quentin", config.GetValue("man"))
        End Sub

        '<Test()>
        '<ExpectedException(GetType(ApplicationException))>
        Public Sub AddConfigNoDefaultKey()
            Dim source As RegistryConfigSource
            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\Pets")
            On Error GoTo CatchMe
            Dim config As IConfig
            Set config = source.AddConfig("People")
CatchMe:
            Dim ex As Exception
            If Catch(ex) Then
                Call Assert.IsTrue(TypeOf ex Is ApplicationException)
            Else
                Call Assert.Fail("Expected ApplicationException")
            End If
        End Sub

        '<Test()>
        Public Sub RemoveKey()
            Dim source As RegistryConfigSource
            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\Pets")

            Dim config As IConfig
            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Pets", config.Name)
            Call Assert.AreEqual(3, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual(source, config.ConfigSource)

            Call Assert.AreEqual("Chi-chi", config.GetValue("cat"))
            Call Assert.AreEqual("Rover", config.GetValue("dog"))
            Call Assert.AreEqual(5, config.GetInt("count"))

            Call config.Remove("dog")

            source.save

            Set source = NewRegistryConfigSource()
            Call source.AddMapping(Registry.LocalMachine, "Software\NiniTestApp\Pets")

            Set config = source.Configs("Pets")
            Call Assert.AreEqual("Pets", config.Name)
            Call Assert.AreEqual(2, cArray.GetLength(config.GetKeys()))
            Call Assert.AreEqual(source, config.ConfigSource)

            Call Assert.AreEqual("Chi-chi", config.GetValue("cat"))
            Call Assert.AreEqual("", config.GetValue("dog"))
            Call Assert.AreEqual(5, config.GetInt("count"))
        End Sub
        '#End Region

        '#Region "Setup/tearDown"
        '<SetUp()>
        Public Sub Setup()
            Dim software As RegistryKey
            Set software = Registry.LocalMachine.OpenSubKey("Software", True)

            Dim nini As RegistryKey
            Set nini = software.CreateSubKey("NiniTestApp")
            Call nini.SetValue("Description", "Configuration Library")
            Call nini.Flush

            Dim pets As RegistryKey
            Set pets = nini.CreateSubKey("Pets")
            Call pets.SetValue("dog", "Rover")
            Call pets.SetValue("cat", "Chi-chi")
            Call pets.SetValue("count", 5)
            ' set DWORD
            Call pets.Flush
        End Sub

        '<TearDown()>
        Public Sub TearDown()
            Dim software As RegistryKey
            Set software = Registry.LocalMachine.OpenSubKey("Software", True)
            Call software.DeleteSubKeyTree("NiniTestApp")
        End Sub
        '#End Region

        '#Region "Private methods"
        '#End Region

