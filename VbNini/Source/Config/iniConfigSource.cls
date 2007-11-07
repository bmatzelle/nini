VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "INIConfigSource"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Top_Level" ,"Yes"
'
' Nini Configuration Project.
' Copyright (C) 2004 Brent R. Matzelle.  All rights reserved.
' Port to VB6 by David Lewis, 2007
'
' This software is published under the terms of the MIT X11 license, a copy of
' which has been included with this distribution in the LICENSE.txt file.
'

Option Explicit
Implements IConfigSource
Implements IObject
'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent Saved[(arg1, arg2, ... , argn)]
Public Event Saved(sender As IObject, e As EventArgs)
'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent Reloaded[(arg1, arg2, ... , argn)]
Public Event Reloaded(sender As IObject, e As EventArgs)
Public Event ConfigRemoved(ByVal sender As Object, ByVal e As ConfigEventArgs)
Public Event ConfigAdded(ByVal sender As Object, ByVal e As ConfigEventArgs)

Private WithEvents MyBase As ConfigSourceBase
Attribute MyBase.VB_VarHelpID = -1

'Base Fields
'Private my_Alias As AliasText
'Private my_AutoSave As Boolean
'Private WithEvents configList As ConfigCollection
'Private sourceList As ArrayList

'Implimentation Fields
Private Me_caseSensitive As Boolean
Private Me_iniDocument As iniDocument
Private Me_savePath As String


' Methods
    Friend Sub Init_Document(ByVal document As iniDocument)
        Set Me_iniDocument = Nothing
        Me_savePath = ""
        Me_caseSensitive = True
        Set Me_iniDocument = New iniDocument
        Call Load_iniDocument(document)
    End Sub
    Friend Sub Init_stream(ByVal stream As stream)
        Me_iniDocument = Nothing
        Me_savePath = ""
        Me_caseSensitive = True
        Call Load_stream(stream)

    End Sub
    Friend Sub Init_Reader(ByVal reader As TextReader)
        Set Me_iniDocument = Nothing
        Me_savePath = ""
        Me_caseSensitive = True
        Call Load_TextReader(reader)

    End Sub
    Friend Sub Init_FilePath(ByVal filePath As String)
        Set Me_iniDocument = Nothing
        Me_savePath = ""
        Me_caseSensitive = True
        Call Load_filePath(filePath)

    End Sub


    Public Function AddConfig(ByVal name As String) As IConfig
        Set AddConfig = MyBase.AddConfig(name)
    End Function

    

    Public Sub ExpandKeyValues()
        Call MyBase.ExpandKeyValues
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


    ' Properties
    Public Property Get alias() As AliasText
        Set alias = MyBase.alias
    End Property

    Public Property Get AutoSave() As Boolean
        
            AutoSave = MyBase.AutoSave
    End Property
    Public Property Let AutoSave(ByVal value As Boolean)
            MyBase.AutoSave = value
        
    End Property

    Public Property Get Configs() As ConfigCollection
        
            Set Configs = MyBase.Configs
        
    End Property


    Private Function IsSavable() As Boolean
        IsSavable = (Not SavePath = "")
    End Function

    Private Sub Load()
        Dim config As IniConfig
        Dim section As IniSection
        Dim Item As INIItem
        Dim i As Integer
        For i = 0 To Me_iniDocument.sections.Count - 1
            Set section = Me_iniDocument.sections(i)
            Set config = NewIniConfig(section.name, Me)
            Dim j As Integer
            For j = 0 To section.ItemCount - 1
                Set Item = section.GetItem(j)
                If (Item.myType = my_iniType.key) Then
                    Call config.Add(Item.name, Item.value)
                End If
            Next j
            Call MyBase.Configs.Add(config)
        Next i
    End Sub

    Public Sub Load_iniDocument(ByVal document As iniDocument)
        MyBase.Configs.Clear
        Call MyBase.Merge(Me)
        Set Me_iniDocument = document
        Load
    End Sub

    Public Sub Load_stream(ByVal stream As stream)
        Call Load_TextReader(NewStreamReader(stream))
    End Sub

    Public Sub Load_TextReader(ByVal reader As TextReader)
        Call Load_iniDocument(NewIniDocument(reader))
    End Sub

    Public Sub Load_filePath(ByVal filePath As String)
        Call Load_TextReader(NewStreamReader(filePath))
        Me_savePath = filePath
    End Sub

    Private Sub MergeConfigsIntoDocument()
        RemoveSections
        Dim config As IConfig
        Dim section As IniSection
        Dim keys() As String
        Dim i As Integer
        For Each config In Configs
            keys = config.GetKeys
            If (Me_iniDocument.sections.Item(config.name) Is Nothing) Then
                Set section = NewIniSection(config.name)
                
                Call Me_iniDocument.sections.Add(section)
            Else
                Call Me_iniDocument.sections.Remove(config.name)
                Call Me_iniDocument.sections.Add(NewIniSection(config.name))
            End If
            'Call RemoveKeys(config.name)
            If Not cArray.IsNull(keys) Then
                For i = 0 To cArray.getLength(keys) - 1
                    Call Me_iniDocument.sections.Item(config.name).SetValue(keys(i), config.GetValue(keys(i)))
                Next i
            End If
        Next
    End Sub

    Private Sub MergeDocumentIntoConfigs()
        RemoveConfigs
        Dim section As IniSection
        Dim i As Integer
        Dim config As IConfig
        For i = 0 To Me_iniDocument.sections.Count - 1
            Set section = Me_iniDocument.sections.Item(i)
            Set config = MyBase.Configs.Item(section.name)
            If (config Is Nothing) Then
                Set config = NewConfigBase(section.name, Me)
                Call Configs.Add(config)
            End If
            Call RemoveConfigKeys(config)
        Next i
    End Sub

    Public Sub Reload()
        If (Me_savePath = "") Then
            Throw NewArgumentException("Error reloading: You must have the loaded the source from a file")
        End If
        Set Me_iniDocument = NewIniDocument(Me_savePath)
        MergeDocumentIntoConfigs
        'MyBase.Reload
        RaiseEvent Reloaded(Me, New EventArgs)
    End Sub

    Private Sub RemoveConfigKeys(ByVal config As IConfig)
        Dim section As IniSection
        Dim keys() As String
        Dim strArray2() As String
        Dim str As Variant
        Dim key As String
        keys = config.GetKeys
        Set section = Me_iniDocument.sections.Item(config.name)
        If Not cArray.IsNull(keys) Then
        For Each str In keys
            If Not section.Contains(CStr(str)) Then
                config.Remove (CStr(str))
            End If
        Next
        End If
        strArray2 = section.GetKeys
        Dim i As Integer
        If Not cArray.IsNull(strArray2) Then
            For i = 0 To cArray.getLength(strArray2) - 1
                key = strArray2(i)
                Call config.SetValue(key, section.GetItem(i).value)
            Next i
        End If
    End Sub

    Private Sub RemoveConfigs()
        Dim config As IConfig
        Dim i As Integer
        i = (MyBase.Configs.Count - 1)
        Do While (i > -1)
            Set config = MyBase.Configs.Item(i)
            If (Me_iniDocument.sections.Item(config.name) Is Nothing) Then
                Call MyBase.Configs.Remove(config)
            End If
            i = i - 1
        Loop
    End Sub

    Private Sub RemoveKeys(ByVal sectionName As String)
        Dim section As IniSection
        Set section = Me_iniDocument.sections.Item(sectionName)
        If (Not section Is Nothing) Then
            Dim tmpstr As Variant
            Dim str As String
            Dim tmpkeys() As String
            tmpkeys = section.GetKeys
            If Not cArray.IsNull(tmpkeys) Then
                For Each tmpstr In section.GetKeys
                    str = CStr(tmpstr)
                    If (MyBase.Configs.Item(sectionName).Contains(str)) Then
                        Call section.Remove(str)
                    End If
                Next
            End If
        End If
    End Sub

    Private Sub RemoveSections()
        Dim section As IniSection
        Dim i As Integer
        For i = 0 To Me_iniDocument.sections.Count - 1
            Set section = Me_iniDocument.sections.Item(i)
            If Not section Is Nothing Then
                If (MyBase.Configs.Item(section.name) Is Nothing) Then
                    Call Me_iniDocument.sections.Remove(section.name)
                End If
            End If
        Next i
    End Sub

    Public Sub Save()
        If Not IsSavable Then
            Throw NewArgumentException("Source cannot be saved in this state")
        End If
        MergeConfigsIntoDocument
        Call Me_iniDocument.SavePath(Me.SavePath)
        'MyBase.Save
        RaiseEvent Saved(Me, New EventArgs)
    End Sub

    Public Sub Save_stream(ByVal stream As stream)
        MergeConfigsIntoDocument
        Call Me_iniDocument.Save_stream(stream)
        Me_savePath = ""
        'MyBase.Save
        RaiseEvent Saved(Me, New EventArgs)
    End Sub

    Public Sub Save_textWriter(ByVal writer As textWriter)
        MergeConfigsIntoDocument
        Call Me_iniDocument.Save_textWriter(writer)
        Me_savePath = ""
        'MyBase.Save
        RaiseEvent Saved(Me, New EventArgs)
    End Sub

    Public Sub Save_path(ByVal path As String)
        Me_savePath = path
        Me.Save
    End Sub




    ' Properties
    Public Property Get CaseSensitive() As Boolean
        
            CaseSensitive = Me_caseSensitive
    End Property
    
    Public Property Let CaseSensitive(ByVal RHS As Boolean)
            Me_caseSensitive = RHS
        
    End Property

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
'    Dim tmpINIsource As INIConfigSource
'    If TypeOf value Is INIConfigSource Then
'        Set tmpINIsource = value
'        Equals = (tmpINIsource.SavePath = Me.SavePath)
'    Else
        Equals = Object.Equals(Me, value)
'    End If
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

''
' Returns a string representation of this object instance.
' The default method simply returns the application name
' and class name in which this class resides.
'
' A Person class may return the person's name instead.
'
Public Function ToString() As String
    Dim textWriter As New StringWriter
    MergeConfigsIntoDocument
    Call Me_iniDocument.Save_textWriter(textWriter)
    ToString = textWriter.ToString
End Function


Private Sub Class_Initialize()
    Set MyBase = NewConfigSourceBase()
    'Set configList = NewConfigCollection(Me)
    'Set sourceList = NewArrayList
    'Set my_Alias = New AliasText
    Me_savePath = ""
    Me_caseSensitive = True
    Set Me_iniDocument = NewIniDocument()
    
End Sub

Private Sub configList_ConfigAdded(ByVal sender As Object, ByVal e As ConfigEventArgs)
RaiseEvent ConfigAdded(sender, e)
End Sub

Private Sub configList_ConfigRemoved(ByVal sender As Object, ByVal e As ConfigEventArgs)
RaiseEvent ConfigRemoved(sender, e)
End Sub

Private Function IConfigSource_AddConfig(ByVal name As String) As IConfig
    Set IConfigSource_AddConfig = Me.AddConfig(name)
End Function

Private Property Get IConfigSource_alias() As AliasText
    Set IConfigSource_alias = Me.alias
End Property

Private Property Let IConfigSource_AutoSave(RHS As Boolean)
    Me.AutoSave = RHS
End Property

Private Property Get IConfigSource_AutoSave() As Boolean
    IConfigSource_AutoSave = Me.AutoSave
End Property

Private Property Get IConfigSource_Configs() As ConfigCollection
    Set IConfigSource_Configs = Configs
End Property

Private Sub IConfigSource_ExpandKeyValues()
    Me.ExpandKeyValues
End Sub

Private Function IConfigSource_GetExpanded(ByVal config As IConfig, ByVal key As String) As String
    IConfigSource_GetExpanded = Me.GetExpanded(config, key)
End Function

Private Sub IConfigSource_Merge(ByVal source As IConfigSource)
    Me.Merge (source)
End Sub

Private Sub IConfigSource_Reload()
    Me.Reload
End Sub

Private Sub IConfigSource_ReplaceKeyValues()
    Me.ReplaceKeyValues
End Sub

Private Sub IConfigSource_Save()
    Me.Save
End Sub

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


Private Sub MyBase_ConfigAdded(ByVal sender As Object, ByVal e As ConfigEventArgs)
RaiseEvent ConfigAdded(sender, e)
End Sub

Private Sub MyBase_ConfigRemoved(ByVal sender As Object, ByVal e As ConfigEventArgs)
RaiseEvent ConfigRemoved(sender, e)
End Sub

'Private Sub MyBase_Reloaded(sender As Object, e As ConfigEventArgs)
'
'End Sub
'
'Private Sub MyBase_Saved(sender As Object, e As ConfigEventArgs)
'
'End Sub
Private Sub MyBase_Reloaded(sender As VBCorLib.IObject, e As VBCorLib.EventArgs)
RaiseEvent Reloaded(Me, e)
End Sub

Private Sub MyBase_Saved(sender As VBCorLib.IObject, e As VBCorLib.EventArgs)
RaiseEvent Saved(Me, e)
End Sub
