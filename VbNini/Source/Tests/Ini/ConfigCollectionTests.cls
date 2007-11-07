VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ConfigCollTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

'#Region "Private variables"
Private eventConfig As IConfig
Private eventCollection As ConfigCollection
Private WithEvents eventTestCollection As ConfigCollection
Attribute eventTestCollection.VB_VarHelpID = -1
Private WithEvents source As IniConfigSource
Attribute source.VB_VarHelpID = -1
Private configAddedCount As Integer
Private configRemovedCount As Integer
'#End Region

'#Region "Unit tests"
'<Test()>
Public Sub GetConfig()
    Dim config1 As ConfigBase
    Set config1 = NewConfigBase("Test1", Nothing)
    Dim config2 As ConfigBase
    Set config2 = NewConfigBase("Test2", Nothing)
    Dim config3 As ConfigBase
    Set config3 = NewConfigBase("Test3", Nothing)
    
    Dim collection As ConfigCollection
    Set collection = NewConfigCollection(Nothing)

    Call collection.Add(config1)
    Call Assert.AreEqual(1, collection.Count)
    Call Assert.AreEqual(config1, collection(0))

    Call collection.Add(config2)
    Call collection.Add(config3)
    Call Assert.AreEqual(3, collection.Count)

    Call Assert.AreEqual(config2, collection("Test2"))
    Call Assert.AreEqual(config3, collection("Test3"))
    Call Assert.AreEqual(config3, collection(2))
End Sub

'<Test()>
'<ExpectedException(GetType(ArgumentException))>
Public Sub AlreadyExistsException()
    Dim config As ConfigBase
    Set config = NewConfigBase("Test", Nothing)
    Dim collection As ConfigCollection
    Set collection = NewConfigCollection(Nothing)
    On Error GoTo CatchMe
    Call collection.Add(config)
    Call collection.Add(config)
    ' exception
CatchMe:
    Dim ex As Exception
    If Catch(ex) Then
        Call Assert.IsTrue(TypeOf ex Is ArgumentException)
    Else
        Call Assert.IsTrue(TypeOf ex Is ArgumentException)
    End If
End Sub

'<Test()>
Public Sub NameAlreadyExists()
    Dim config1 As ConfigBase
    Set config1 = NewConfigBase("Test", Nothing)
    Dim config2 As ConfigBase
    Set config2 = NewConfigBase("Test", Nothing)
    Dim collection As ConfigCollection
    Set collection = NewConfigCollection(Nothing)
    Call collection.Add(config1)
    Call collection.Add(config2)
    ' merges, no exception
End Sub

'<Test()>
Public Sub AddAndRemove()
    Dim config1 As ConfigBase
    Set config1 = NewConfigBase("Test", Nothing)
    Dim config2 As ConfigBase
    Set config2 = NewConfigBase("Another", Nothing)
    Dim collection As ConfigCollection
    Set collection = NewConfigCollection(Nothing)
    Call collection.Add(config1)
    Call collection.Add(config2)

    Call Assert.AreEqual(2, collection.Count)
    Call Assert.IsNotNothing(collection("Test"))
    Call Assert.IsNotNothing(collection("Another"))

    Call collection.Remove(config2)
    Call Assert.AreEqual(1, collection.Count)
    Call Assert.IsNotNothing(collection("Test"))
    Call Assert.IsNothing(collection("Another"))
End Sub

'<Test()>
Public Sub ConfigCollectionEvents()

    Set source = NewIniConfigSource()

    Call Assert.AreEqual(configAddedCount, 0)

    Set eventCollection = Nothing
    Dim config As IConfig
    Set config = source.AddConfig("Test")
    Set eventTestCollection = source.Configs
    Call Assert.IsTrue(source.Configs Is eventCollection)
    Call Assert.AreEqual(configAddedCount, 1)
    Call Assert.AreEqual("Test", eventConfig.Name)

    Set eventCollection = Nothing
    Set config = source.Configs.AddByName("Test 2")
    Call Assert.IsTrue(source.Configs Is eventCollection)
    Call Assert.AreEqual(configAddedCount, 2)
    Call Assert.AreEqual("Test 2", eventConfig.Name)

    Set eventCollection = Nothing
    Call source.Configs.RemoveAt(0)
    Call Assert.IsTrue(source.Configs Is eventCollection)
    Call Assert.AreEqual(configAddedCount, 2)
    Call Assert.AreEqual("Test", eventConfig.Name)
End Sub

Public Sub TestFixtureSetup()
    Set eventConfig = Nothing
    Set eventCollection = Nothing
    configAddedCount = 0
    configRemovedCount = 0
End Sub
'#End Region





Private Sub source_ConfigAdded(ByVal sender As Object, ByVal e As VBNini.ConfigEventArgs)
    'Debug.Assert False
    configAddedCount = configAddedCount + 1
    Set eventConfig = e.config
    Set eventCollection = sender
End Sub

Private Sub source_ConfigRemoved(ByVal sender As Object, ByVal e As VBNini.ConfigEventArgs)
    'Debug.Assert False
    configRemovedCount = configRemovedCount + 1
    Set eventConfig = e.config
    Set eventCollection = sender
End Sub

