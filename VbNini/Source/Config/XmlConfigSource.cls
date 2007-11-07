VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "XmlConfigSource"
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

    Private WithEvents MyBase As ConfigSourceBase
Attribute MyBase.VB_VarHelpID = -1
    
    ' Fields
    Private Me_configDoc As DOMDocument
    Private Me_savePath As String

'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent Saved[(arg1, arg2, ... , argn)]
Public Event Saved(sender As IObject, e As EventArgs)
'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent Reloaded[(arg1, arg2, ... , argn)]
Public Event Reloaded(sender As IObject, e As EventArgs)
Public Event ConfigRemoved(ByVal sender As Object, ByVal e As ConfigEventArgs)
Public Event ConfigAdded(ByVal sender As Object, ByVal e As ConfigEventArgs)

    ' Methods
    Friend Sub Init()
        Set Me_configDoc = Nothing
        Me_savePath = ""
        Set Me_configDoc = New DOMDocument
        Me_configDoc.loadXML ("<Nini/>")
        Call PerformLoad(Me_configDoc)
    End Sub
    
    Friend Sub Init_Path(ByVal path As String)
        Set Me_configDoc = Nothing
        Me_savePath = ""
        Call Me.Load_Path(path)
    End Sub

    Friend Sub Init_Reader(ByVal reader As TextReader)
        Set Me_configDoc = Nothing
        Me_savePath = ""
        
        Call Me.Load_TextReader(reader)
    End Sub
    
    Friend Sub Init_DOMDocument(DOMDoc As DOMDocument)
        Set Me_configDoc = Nothing
        Me_savePath = ""
        Set Me_configDoc = DOMDoc
        Call PerformLoad(Me_configDoc)
    End Sub
    
    
    Private Sub CreateKey(ByVal sectionNode As IXMLDOMNode, ByVal key As String, ByVal value As String)
        Dim newChild As IXMLDOMNode
        Dim tmpnode As IXMLDOMAttribute
        Dim attribute2 As IXMLDOMAttribute
        
        Set newChild = Me_configDoc.createElement("Key")
        Set tmpnode = Me_configDoc.createAttribute("Name")
        Set attribute2 = Me_configDoc.createAttribute("Value")
        
        tmpnode.value = key
        attribute2.value = value
        Call newChild.Attributes.setNamedItem(tmpnode)
        Call newChild.Attributes.setNamedItem(attribute2)
        Call sectionNode.appendChild(newChild)
    End Sub

    Private Function GetKeyByName(ByVal sectionNode As IXMLDOMNode, ByVal name As String) As IXMLDOMNode
        Dim node2 As IXMLDOMNode
        For Each node2 In sectionNode.childNodes
            If (node2.nodeType = NODE_ELEMENT) Then
                If (node2.nodeName = "Key") Then
                    If (node2.Attributes.getNamedItem("Name").nodeValue = name) Then
                        Set GetKeyByName = node2
                    End If
                End If
            End If
        Next
        
    End Function

    Private Function GetSectionByName(ByVal name As String) As IXMLDOMNode
        Dim node2 As IXMLDOMNode
        For Each node2 In Me_configDoc.documentElement.childNodes
            If (node2.nodeType = NODE_ELEMENT) Then
                If (node2.nodeName = "Section") Then
                        
                        If (node2.Attributes.getNamedItem("Name").nodeValue = name) Then
                            Set GetSectionByName = node2
                        End If
                    
                End If
            End If
        Next
        
    End Function

    Private Function IsSavable() As Boolean
        IsSavable = ((Not Me_savePath = "") And (Not Me_configDoc Is Nothing))
    End Function

    Public Sub Load_Path(ByVal path As String)
        Me_savePath = path
        Set Me_configDoc = New DOMDocument
        Call Me_configDoc.Load(path)
        Call PerformLoad(Me_configDoc)
    End Sub

    Public Sub Load_TextReader(ByVal reader As TextReader)
        Set Me_configDoc = New DOMDocument
        
        Call Me_configDoc.loadXML(reader.ReadToEnd)
        Call PerformLoad(Me_configDoc)
    End Sub

    Private Sub LoadKeys(ByVal node As IXMLDOMNode, ByVal config As ConfigBase)
        Dim node2 As IXMLDOMNode
        For Each node2 In node.childNodes
            If (node2.nodeType = NODE_ELEMENT) Then
                If (node2.nodeName = "Key") Then
                    Call config.Add(node2.Attributes.getNamedItem("Name").nodeValue, node2.Attributes.getNamedItem("Value").nodeValue)
                End If
            End If
        Next
    End Sub

    Private Sub LoadSections(ByVal rootNode As IXMLDOMNode)
        Dim config As ConfigBase
        Dim node As IXMLDOMNode
        For Each node In rootNode.childNodes
            If (node.nodeType = NODE_ELEMENT) Then
                    If (node.nodeName = "Section") Then
                    Set config = NewConfigBase(node.Attributes.getNamedItem("Name").nodeTypedValue, Me)
                    Call MyBase.Configs.Add(config)
                    Call LoadKeys(node, config)
                End If
            End If
        Next
    End Sub
    
    
    
    Private Sub MergeConfigsIntoDocument()
        RemoveSections
        Dim config As IConfig
        For Each config In MyBase.Configs
            Dim keys() As String: keys = config.GetKeys
            Dim sectionByName As IXMLDOMNode
            Set sectionByName = GetSectionByName(config.name)
            
            If (sectionByName Is Nothing) Then
                Set sectionByName = sectionNode(config.name)
                Call Me_configDoc.documentElement.appendChild(sectionByName)
            End If
            Call RemoveKeys(config.name)
            Dim i As Integer
            If Not cArray.IsNull(keys) Then
                For i = 0 To cArray.getLength(keys) - 1
                    Call SetKey(sectionByName, keys(i), config.GetValue(keys(i)))
                Next i
            End If
        Next
    End Sub

    Private Sub MergeDocumentIntoConfigs()
        Dim name As String
        Dim config As IConfig
        Dim node As IXMLDOMNode
        Call RemoveConfigs
        For Each node In Me_configDoc.documentElement.childNodes
            If (node.nodeType = NODE_ELEMENT) Then
                If (node.nodeName = "Section") Then
                    name = node.Attributes.getNamedItem("Name").nodeValue
                    Set config = MyBase.Configs.Item(name)
                    If (config Is Nothing) Then
                        Set config = NewConfigBase(name, Me)
                        Call MyBase.Configs.Add(config)
                    End If
                    Call RemoveConfigKeys(config)
                End If
            End If
        Next
    End Sub

    Private Sub PerformLoad(ByRef document As DOMDocument)
        MyBase.Configs.Clear
        Call MyBase.Merge(Me)
        On Error Resume Next
        If (Not document.documentElement.nodeName = "Nini") Then
            On Error GoTo 0
            Throw NewArgumentException("Did not find Nini XML root node")
        End If
        On Error GoTo 0
        Call LoadSections(document.documentElement)
    End Sub

    Public Sub Reload()
        If (Me_savePath = "") Then
            Throw NewArgumentException("Error reloading: You must have the loaded the source from a file")
        End If
        Set Me_configDoc = New DOMDocument
        Call Me_configDoc.Load(Me_savePath)
        Call MergeDocumentIntoConfigs
        'Call MyBase.Reload
    End Sub

    Private Sub RemoveConfigKeys(ByVal config As IConfig)
        Dim sectionByName As IXMLDOMNode
        Dim keys() As String
        Dim str As Variant
        keys = config.GetKeys
        Set sectionByName = GetSectionByName(config.name)
        For Each str In keys
            If (GetKeyByName(sectionByName, CStr(str)) Is Nothing) Then
                Call config.Remove(CStr(str))
            End If
        Next
        Dim node2 As IXMLDOMNode
        For Each node2 In sectionByName.childNodes
            If (node2.nodeType = NODE_ELEMENT) Then
                If (node2.nodeName = "Key") Then
                    Call config.SetValue(node2.Attributes.getNamedItem("Name").nodeValue, node2.Attributes.getNamedItem("Value").nodeValue)
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
            If (GetSectionByName(config.name) Is Nothing) Then
                Call MyBase.Configs.Remove(config)
            End If
            i = i - 1
        Loop
    End Sub

    Private Sub RemoveKeys(ByVal sectionName As String)
        Dim sectionByName As IXMLDOMNode
        Dim attr As IXMLDOMAttribute
        
        Set sectionByName = GetSectionByName(sectionName)
        If (Not sectionByName Is Nothing) Then
            Dim node2 As IXMLDOMNode
            For Each node2 In sectionByName.childNodes
                If (node2.nodeType = NODE_ELEMENT) Then
                    If (node2.nodeName = "Key") Then
                        Set attr = node2.Attributes.getNamedItem("Name")
                        If (attr Is Nothing) Then
                            Throw NewArgumentException("Name attribute not found in key")
                        End If
                        If (MyBase.Configs.Item(sectionName).GetValue(CStr(attr.value)) = "") Then
                            Call sectionByName.removeChild(node2)
                        End If
                    End If
                End If
            Next
        End If
    End Sub

    Private Sub RemoveSections()
        Dim attr As IXMLDOMAttribute
        Dim node As IXMLDOMNode
        For Each node In Me_configDoc.documentElement.childNodes
            If (node.nodeType = NODE_ELEMENT) Then
                If (node.nodeName = "Section") Then
                    Set attr = node.Attributes.getNamedItem("Name")
                    If (attr Is Nothing) Then
                        Throw NewArgumentException("Section name attribute not found")
                    End If
                    If (MyBase.Configs.Item(attr.value) Is Nothing) Then
                        Call Me_configDoc.documentElement.removeChild(node)
                    End If
                End If
            End If
        Next
    End Sub

    Public Sub Save()
        If Not IsSavable Then
            Throw NewArgumentException("Source cannot be saved in this state")
        End If
        Call MergeConfigsIntoDocument
        Call Me_configDoc.Save(Me_savePath)
        'MyBase.Save
    End Sub

    Public Sub Save_stream(ByVal stream As stream)
        Call Me.Save_textWriter(NewStreamWriter(stream))
    End Sub

    Public Sub Save_textWriter(ByVal writer As textWriter)
        Call MergeConfigsIntoDocument
        
        Call writer.WriteValue(Me_configDoc.xml)
        Me_savePath = ""
        'Call MyBase.OnSaved(New EventArgs)
    End Sub

    Public Sub Save_path(ByVal path As String)
        Me_savePath = path
        Me.Save
    End Sub

    Private Function sectionNode(ByVal name As String) As IXMLDOMNode
        Dim node As IXMLDOMNode
        Dim attr As IXMLDOMAttribute
        Set node = Me_configDoc.createElement("Section")
        Set attr = Me_configDoc.createAttribute("Name")
        attr.value = name
        Call node.Attributes.setNamedItem(attr)
        Set sectionNode = node
    End Function

    Private Sub SetKey(ByVal sectionNode As IXMLDOMNode, ByVal key As String, ByVal value As String)
        Dim keyByName As IXMLDOMNode
        Set keyByName = GetKeyByName(sectionNode, key)
        If (keyByName Is Nothing) Then
            Call CreateKey(sectionNode, key, value)
        Else
            keyByName.Attributes.getNamedItem("Value").nodeValue = value
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
        MergeConfigsIntoDocument
      
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
    ConfigSourceBase_GetExpanded = MyBase.GetExpanded(config, key)
End Function


Private Function ConfigSourceBase_GetHashCode() As Long
    ConfigSourceBase_GetHashCode = Me.GetHashCode
End Function

Private Sub ConfigSourceBase_Init()
    Call Me.Init
End Sub

Private Sub ConfigSourceBase_Merge(ByVal source As IConfigSource)
    MyBase.Merge (source)
End Sub


Private Sub ConfigSourceBase_Reload()
Me.Reload
End Sub

Private Sub ConfigSourceBase_ReplaceKeyValues()
    MyBase.ReplaceKeyValues
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
