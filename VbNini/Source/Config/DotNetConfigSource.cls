VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "DotNetConfigSource"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'
' Nini Configuration Project.
' Copyright (C) 2004 Brent R. Matzelle.  All rights reserved.
' Port to VB6 by David Lewis, 2007
'
' This software is published under the terms of the MIT X11 license, a copy of
' which has been included with this distribution in the LICENSE.txt file.
'

'
' This is the base implementation of an object that can be
' utilized within the VBCorLib library. By implementing the
' standard IObject interface, this class can be utilized in
' additional ways by VBCorLib.
'
Option Explicit
Implements IObject
Implements ConfigSourceBase
Implements IConfigSource

'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent Saved[(arg1, arg2, ... , argn)]
Public Event Saved(sender As IObject, e As EventArgs)
'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent Reloaded[(arg1, arg2, ... , argn)]
Public Event Reloaded(sender As IObject, e As EventArgs)
Public Event ConfigRemoved(ByVal sender As Object, ByVal e As ConfigEventArgs)
Public Event ConfigAdded(ByVal sender As Object, ByVal e As ConfigEventArgs)

Private WithEvents MyBase As ConfigSourceBase

    
     ' Fields
    Private Me_configDoc As DOMDocument
    Private Me_savePath As String
    Private Me_sections() As String
    
    ' Methods
    Friend Sub Init()
        Me_sections = cArray.NewArray(ciString)
        Set Me_configDoc = Nothing
        Me_savePath = ""
        Set Me_configDoc = New DOMDocument
        Me_configDoc.loadXML ("<configuration><configSections/></configuration>")
        Call PerformLoad(Me_configDoc)
    End Sub

    Friend Sub Init_Sections(sections() As String)
        Me_sections = cArray.NewArray(ciString)
        Me_configDoc = Nothing
        Me_savePath = ""
        Me_sections = sections
        Load
    End Sub

   Friend Sub Init_Reader(ByVal reader As TextReader)
        Set Me_configDoc = Nothing
        Me_savePath = ""
        Call Load_TextReader(reader)
    End Sub
    
    Friend Sub Init_DOMDocument(DOMDoc As DOMDocument)
        Set Me_configDoc = Nothing
        Me_savePath = ""
        Set Me_configDoc = DOMDoc
        Call PerformLoad(Me_configDoc)
    End Sub


    Friend Sub Init_Path(ByVal path As String)
        Me_sections = cArray.NewArray(ciString)
        Set Me_configDoc = Nothing
        Me_savePath = ""
        Call Load_Path(path)
    End Sub

'    Friend Sub Init_XmlReader(ByVal reader As XmlReader)
'        Me.sections = Nothing
'        Me_configDoc = Nothing
'        Me.savePath = Nothing
'        Me.Load (reader)
'    End Sub

    Private Sub CreateKey(ByVal sectionNode As IXMLDOMNode, ByVal key As String, ByVal value As String)
        Dim newChild As IXMLDOMNode
        Dim node As IXMLDOMAttribute
        Dim attribute2 As IXMLDOMAttribute
        Set newChild = Me_configDoc.createElement("add")
        Set node = Me_configDoc.createAttribute("key")
        Set attribute2 = Me_configDoc.createAttribute("value")
        
        node.value = key
        attribute2.value = value
        Call newChild.Attributes.setNamedItem(node)
        Call newChild.Attributes.setNamedItem(attribute2)
        Call sectionNode.appendChild(newChild)
    End Sub

    Private Function GetChildElement(ByVal name As String) As IXMLDOMNode
        Set GetChildElement = GetChildElement_FromParent(Me_configDoc.documentElement, name)
    End Function

    Private Function GetChildElement_FromParent(ByVal parentNode As IXMLDOMNode, ByVal name As String) As IXMLDOMNode
        Dim node2 As IXMLDOMNode
        For Each node2 In parentNode.childNodes
            If (node2.nodeType = NODE_ELEMENT) Then
                If (node2.nodeName = name) Then
                    Set GetChildElement_FromParent = node2
                    Exit Function
                End If
            End If
        Next
        Set GetChildElement_FromParent = Nothing
    End Function

    Public Static Function GetFullConfigPath() As String
        GetFullConfigPath = (App.path & ".config")
    End Function

    Private Function GetKey(ByVal sectionNode As IXMLDOMNode, ByVal keyName As String) As IXMLDOMNode
        Dim node2 As IXMLDOMNode
        For Each node2 In sectionNode.childNodes
            If (node2.nodeType = NODE_ELEMENT) Then
                If (node2.nodeName = "add") Then
                    If (node2.Attributes.getNamedItem("key").nodeValue = keyName) Then
                        Set GetKey = node2
                        Exit Function
                    End If
                End If
            End If
        Next
        Set GetKey = Nothing
    End Function

    Private Function IsSavable() As Boolean
        If ((Not Me_savePath = "") Or (Not Me_configDoc Is Nothing)) Then
            IsSavable = True
        End If
        
    End Function

    Private Sub Load()
       Call Load_Path(App.path & ".config")
    End Sub

    Public Sub Load_Path(ByVal path As String)
        Me_savePath = path
        Set Me_configDoc = New DOMDocument
        Call Me_configDoc.Load(Me.SavePath)
        Call PerformLoad(Me_configDoc)
    End Sub

    Public Sub Load_TextReader(ByVal reader As TextReader)
        Set Me_configDoc = New DOMDocument
        Me_configDoc.loadXML (reader.ReadToEnd)
        Call PerformLoad(Me_configDoc)
    End Sub

'    Private Sub LoadCollection(ByVal name As String, ByVal collection As NameValueCollection)
'        Dim config As ConfigBase
'        Dim i As Integer
'        config = NewConfigBase(name, Me)
'        If (collection Is Nothing) Then
'            Throw NewArgumentException("Section was not found")
'        Else
'
'            For i = 0 To collection.Count - 1
'                Call config.Add(collection.keys.Item(i), collection.Item(i))
'            Next i
'            MyBase.Configs.Add (config)
'        End If
'    End Sub

    Private Sub LoadKeys(ByVal rootNode As IXMLDOMNode, ByVal config As ConfigBase)
        Dim childElement As IXMLDOMNode
        Dim node2 As IXMLDOMNode
        Set childElement = GetChildElement_FromParent(rootNode, config.name)
        On Error GoTo myexit
        For Each node2 In childElement.childNodes
            
            If (node2.nodeType = NODE_ELEMENT) Then
                If (node2.nodeName = "add") Then
                    Call config.Add(node2.Attributes.getNamedItem("key").nodeValue, node2.Attributes.getNamedItem("value").nodeValue)
                End If
            End If
        Next
myexit:
    End Sub

    Private Sub LoadOtherSection(ByVal rootNode As IXMLDOMNode, ByVal nodeName As String)
        Dim childElement As IXMLDOMNode
        Dim config As ConfigBase
        Set childElement = GetChildElement_FromParent(rootNode, nodeName)
        If (Not childElement Is Nothing) Then
            Set config = NewConfigBase(childElement.nodeName, Me)
            Call MyBase.Configs.Add(config)
            Call LoadKeys(rootNode, config)
        End If
    End Sub

    Private Sub LoadSections(ByVal rootNode As IXMLDOMNode)
        Dim childElement As IXMLDOMNode
        Dim config As ConfigBase
        Dim node2 As IXMLDOMNode
        
        Call LoadOtherSection(rootNode, "appSettings")
        Set childElement = GetChildElement_FromParent(rootNode, "configSections")
        If (Not childElement Is Nothing) Then

            For Each node2 In childElement.childNodes
                If (node2.nodeType = NODE_ELEMENT) Then
                    If (node2.nodeName = "section") Then
                        Set config = NewConfigBase(node2.Attributes.getNamedItem("name").nodeValue, Me)
                        Call MyBase.Configs.Add(config)
                        Call LoadKeys(rootNode, config)
                    End If
                End If
            Next
        End If
    End Sub

    Private Sub MergeConfigsIntoDocument()
        RemoveSections
        Dim config As IConfig
        Dim keys() As String
        Dim childElement As IXMLDOMNode
        For Each config In MyBase.Configs
            keys = config.GetKeys
            Call RemoveKeys(config.name)
            Set childElement = GetChildElement(config.name)
            If (childElement Is Nothing) Then
                Set childElement = sectionNode(config.name)
            End If
            Dim i As Integer
            If Not cArray.IsNull(keys) Then
                For i = 0 To cArray.getLength(keys) - 1
                    Call SetKey(childElement, keys(i), config.GetValue(keys(i)))
                Next i
            End If
        Next
    End Sub

    Private Sub MergeDocumentIntoConfigs()
        Dim name As String
        Dim childElement As IXMLDOMNode
        Dim config As IConfig
        Dim node2 As IXMLDOMNode
        RemoveConfigs
        Set childElement = GetChildElement("configSections")
        If (Not childElement Is Nothing) Then
            
            For Each node2 In childElement.childNodes
                If (node2.nodeType = NODE_ELEMENT) Then
                    If (node2.nodeName = "section") Then
                        name = node2.Attributes.getNamedItem("name").nodeValue
                        Set config = MyBase.Configs.Item(name)
                        If (config Is Nothing) Then
                            Set config = NewConfigBase(name, Me)
                            Call MyBase.Configs.Add(config)
                        End If
                        Call RemoveConfigKeys(config)
                    End If
                End If
            Next
        End If
    End Sub

    Private Sub PerformLoad(ByVal document As DOMDocument)
        MyBase.Configs.Clear
        Call MyBase.Merge(Me)
        If (document.documentElement.nodeName <> "configuration") Then
            Throw NewArgumentException("Did not find configuration node")
        End If
        Call LoadSections(document.documentElement)
    End Sub

    Public Sub Reload()
        If (Me_savePath = "") Then
            Throw NewArgumentException("Error reloading: You must have the loaded the source from a file")
        End If
        Set Me_configDoc = New DOMDocument
        Call Me_configDoc.Load(Me.SavePath)
        Call MergeDocumentIntoConfigs
        'MyBase.Reload
    End Sub

    Private Sub RemoveConfigKeys(ByVal config As IConfig)
        Dim childElement As IXMLDOMNode
        Dim keys() As String
        Dim str As Variant
        Dim node2 As IXMLDOMNode
        
        Set childElement = GetChildElement(config.name)
        keys = config.GetKeys
        If Not cArray.IsNull(keys) Then
            For Each str In keys
                If (GetKey(childElement, CStr(str)) Is Nothing) Then
                    Call config.Remove(CStr(str))
                End If
            Next
        End If
        For Each node2 In childElement.childNodes
            If (node2.nodeType = NODE_ELEMENT) Then
                If (node2.nodeName = "add") Then
                    Call config.SetValue(node2.Attributes.getNamedItem("key").nodeValue, _
                    node2.Attributes.getNamedItem("value").nodeValue)
                End If
            End If
        Next
    End Sub

    Private Sub RemoveConfigs()
        Dim config As IConfig
        Dim i As Integer
        i = (MyBase.Configs.Count - 1)
        Do While (i > -1)
            Set config = MyBase.Configs.Item(i)
            If (GetChildElement(config.name) Is Nothing) Then
                Call MyBase.Configs.Remove(config)
            End If
            i = i - 1
        Loop
    End Sub

    Private Sub RemoveKeys(ByVal sectionName As String)
        Dim childElement As IXMLDOMNode
        Dim attr As IXMLDOMAttribute
        Set childElement = GetChildElement(sectionName)
        If (Not childElement Is Nothing) Then
            Dim node2 As IXMLDOMNode
            For Each node2 In childElement.childNodes
                If (node2.nodeType = NODE_ELEMENT) Then
                    If (node2.nodeName = "add") Then
                        Set attr = node2.Attributes.getNamedItem("key")
                        If (attr Is Nothing) Then
                            Throw NewArgumentException("Key attribute not found in node")
                        End If
                        If (MyBase.Configs.Item(sectionName).GetValue(attr.value) = "") Then
                            Call childElement.removeChild(node2)
                        End If
                    End If
                End If
            Next
        End If
    End Sub

    Private Sub RemoveSections()
        Dim attr As IXMLDOMAttribute
        Dim childElement As IXMLDOMNode
        Dim oldChild As IXMLDOMNode
        Set childElement = GetChildElement("configSections")
        If (Not childElement Is Nothing) Then
            Dim node2 As IXMLDOMNode
            For Each node2 In childElement.childNodes
                If (node2.nodeType = NODE_ELEMENT) Then
                    If (node2.nodeName = "section") Then
                        Set attr = node2.Attributes.getNamedItem("name")
                        If (attr Is Nothing) Then
                            Throw NewArgumentException("Section name attribute not found")
                        End If
                        If (MyBase.Configs.Item(attr.value) Is Nothing) Then
                            Call node2.parentNode.removeChild(node2)
                            
                            Set oldChild = GetChildElement(attr.value)
                            If (Not oldChild Is Nothing) Then
                                Call Me_configDoc.documentElement.removeChild(oldChild)
                            End If
                        End If
                    End If
                End If
            Next
        End If
    End Sub

    Public Sub Save()
        If Not IsSavable Then
            Throw NewArgumentException("Source cannot be saved in this state")
        End If
        Call MergeConfigsIntoDocument
        Call Me_configDoc.Save(Me.SavePath)
        'MyBase.Save
    End Sub

    Public Sub Save_stream(ByVal stream As stream)
        Call Me.Save_textWriter(NewStreamWriter(stream))
    End Sub

    Public Sub Save_textWriter(ByVal writer As textWriter)
        If Not IsSavable Then
            Throw NewArgumentException("Source cannot be saved in this state")
        End If
        Call MergeConfigsIntoDocument
        
        Call writer.WriteValue(Me_configDoc.xml)
        Me_savePath = ""
        
    End Sub

    Public Sub Save_path(ByVal path As String)
        If Not IsSavable Then
            Throw NewArgumentException("Source cannot be saved in this state")
        End If
        Me_savePath = path
        Call Save
    End Sub

    Private Function sectionNode(ByVal name As String) As IXMLDOMNode
        Dim newChild As IXMLDOMNode
        Dim node As IXMLDOMAttribute
        Dim node3 As IXMLDOMNode
        
        Set newChild = Me_configDoc.createElement("section")
        Set node = Me_configDoc.createAttribute("name")
        
        node.value = name
        Call newChild.Attributes.setNamedItem(node)
        Set node = Me_configDoc.createAttribute("type")
        node.value = "System.Configuration.NameValueSectionHandler"
        Call newChild.Attributes.setNamedItem(node)
        Call GetChildElement("configSections").appendChild(newChild)
        Set node3 = Me_configDoc.createElement(name)
        Call Me_configDoc.documentElement.appendChild(node3)
        Set sectionNode = node3
    End Function

    Private Sub SetKey(ByVal sectionNode As IXMLDOMNode, ByVal key As String, ByVal value As String)
        Dim node As IXMLDOMNode
        Set node = GetKey(sectionNode, key)
        If (node Is Nothing) Then
            Call CreateKey(sectionNode, key, value)
        Else
            node.Attributes.getNamedItem("value").nodeValue = value
        End If
    End Sub

''
' Returns a string representation of this object instance.
' The default method simply returns the application name
' and class name in which this class resides.
'
' A Person class may return the person's name instead.
'
    Public Function ToString() As String
        Call MergeConfigsIntoDocument
        
        ToString = Me_configDoc.xml
    End Function


    ' Properties
    Public Property Get SavePath() As String
        
            SavePath = Me_savePath
         
    End Property









''
' This function determines if the value passed in is the same
' as the current object instance. Meaning, are the Value and
' this object the same object in memory.
'
' This should be overriden for different forms of equality.
' An example would be if this class contained a Name property
' and equality is determined by the names.
'
Public Function Equals(ByRef value As Variant) As Boolean
    Equals = Object.Equals(Me, value)
End Function

''
' Returns a psuedo-unique number used to help identify this
' object in memory. The current method is to return the value
' obtained from ObjPtr. If a different method needs to be impelmented
' then change the method here in this function.
'
' An override might be necessary if the hashcode should be
' derived from a value contained within the class.
'
Public Function GetHashCode() As Long
    GetHashCode = ObjPtr(CUnk(Me))
End Function






Public Function AddConfig(ByVal name As String) As IConfig
    Set AddConfig = MyBase.AddConfig(name)
End Function

Public Property Get alias() As AliasText
    Set alias = MyBase.alias()
End Property

Public Property Let AutoSave(ByVal RHS As Boolean)
    MyBase.AutoSave = RHS
End Property

Public Property Get AutoSave() As Boolean
    AutoSave = MyBase.AutoSave
End Property

Public Property Get Configs() As ConfigCollection
    Set Configs = MyBase.Configs
End Property


Public Sub ExpandKeyValues()
    MyBase.ExpandKeyValues
End Sub

Public Function GetExpanded(ByVal config As IConfig, ByVal key As String) As String
    GetExpanded = MyBase.GetExpanded(config, key)
End Function


Public Sub Merge(ByVal source As IConfigSource)
    Call MyBase.Merge(source)
End Sub


Public Sub ReplaceKeyValues()
    MyBase.ReplaceKeyValues
End Sub


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   ConfigSourceBase Interface
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''


Private Function ConfigSourceBase_AddConfig(ByVal name As String) As IConfig
    Set ConfigSourceBase_AddConfig = MyBase.AddConfig(name)
End Function

Private Property Get ConfigSourceBase_alias() As AliasText
    Set ConfigSourceBase_alias = MyBase.alias()
End Property

Private Property Let ConfigSourceBase_AutoSave(ByVal RHS As Boolean)
    MyBase.AutoSave = RHS
End Property

Private Property Get ConfigSourceBase_AutoSave() As Boolean
    ConfigSourceBase_AutoSave = MyBase.AutoSave
End Property

Private Property Get ConfigSourceBase_Configs() As ConfigCollection
    Set ConfigSourceBase_Configs = MyBase.Configs
End Property


Private Function ConfigSourceBase_Equals(value As Variant) As Boolean
   ConfigSourceBase_Equals = Me.Equals(value)
End Function

Private Sub ConfigSourceBase_ExpandKeyValues()
    MyBase.ExpandKeyValues
End Sub

Private Function ConfigSourceBase_GetExpanded(ByVal config As IConfig, ByVal key As String) As String
    ConfigSourceBase_GetExpanded = Me.GetExpanded(config, key)
End Function


Private Function ConfigSourceBase_GetHashCode() As Long
    ConfigSourceBase_GetHashCode = Me.GetHashCode
End Function

Private Sub ConfigSourceBase_Init()
    Call Me.Init
End Sub

Private Sub ConfigSourceBase_Merge(ByVal source As IConfigSource)
    Call Me.Merge(source)
End Sub


Private Sub ConfigSourceBase_Reload()
Me.Reload
End Sub

Private Sub ConfigSourceBase_ReplaceKeyValues()
    Me.ReplaceKeyValues
End Sub


Private Sub ConfigSourceBase_Save()
Me.Save
End Sub

Private Function ConfigSourceBase_ToString() As String
    ConfigSourceBase_ToString = Me.ToString
End Function




'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   IConfigSource Interface
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function IConfigSource_AddConfig(ByVal name As String) As IConfig
    Set IConfigSource_AddConfig = MyBase.AddConfig(name)
End Function

Private Property Get IConfigSource_alias() As AliasText
    Set IConfigSource_alias = MyBase.alias()
End Property

Private Property Let IConfigSource_AutoSave(RHS As Boolean)
MyBase.AutoSave = RHS
End Property



Private Property Get IConfigSource_AutoSave() As Boolean
    IConfigSource_AutoSave = MyBase.AutoSave
End Property

Private Property Get IConfigSource_Configs() As ConfigCollection
    Set IConfigSource_Configs = MyBase.Configs
End Property


Private Function IConfigSource_Equals(value As Variant) As Boolean
   IConfigSource_Equals = Me.Equals(value)
End Function

Private Sub IConfigSource_ExpandKeyValues()
    MyBase.ExpandKeyValues
End Sub

Private Function IConfigSource_GetExpanded(ByVal config As IConfig, ByVal key As String) As String
    IConfigSource_GetExpanded = MyBase.GetExpanded(config, key)
End Function


Private Function IConfigSource_GetHashCode() As Long
    IConfigSource_GetHashCode = Me.GetHashCode
End Function

Private Sub IConfigSource_Init()
    Call Me.Init
End Sub

Private Sub IConfigSource_Merge(ByVal source As IConfigSource)
    MyBase.Merge (source)
End Sub


Private Sub IConfigSource_Reload()
Me.Reload
End Sub

Private Sub IConfigSource_ReplaceKeyValues()
    MyBase.ReplaceKeyValues
End Sub


Private Sub IConfigSource_Save()
Me.Save
End Sub

Private Function IConfigSource_ToString() As String
    IConfigSource_ToString = Me.ToString
End Function





'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   IObject Interface
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function IObject_Equals(value As Variant) As Boolean
    IObject_Equals = Equals(value)
End Function

Private Function IObject_GetHashcode() As Long
    IObject_GetHashcode = GetHashCode
End Function

Private Function IObject_ToString() As String
    IObject_ToString = ToString
End Function

Private Sub Class_Initialize()
    Set MyBase = New ConfigSourceBase
    MyBase.Init
End Sub

Private Sub Class_Terminate()
    Set MyBase = Nothing
End Sub



Private Sub MyBase_ConfigAdded(ByVal sender As Object, ByVal e As ConfigEventArgs)
    RaiseEvent ConfigAdded(sender, e)
End Sub

Private Sub MyBase_ConfigRemoved(ByVal sender As Object, ByVal e As ConfigEventArgs)
    RaiseEvent ConfigRemoved(sender, e)
End Sub

Private Sub MyBase_Reloaded(sender As VBCorLib.IObject, e As VBCorLib.EventArgs)
    RaiseEvent Reloaded(sender, e)
End Sub

Private Sub MyBase_Saved(sender As VBCorLib.IObject, e As VBCorLib.EventArgs)
    RaiseEvent Saved(sender, e)
End Sub
