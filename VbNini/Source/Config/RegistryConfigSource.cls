VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "RegistryConfigSource"
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


    Public Enum RegistryRecurse
        ' Fields
        Flattened = 1
        Namespacing = 2
        None = 0
    End Enum

 

    Private WithEvents MyBase As ConfigSourceBase
    
    ' Fields
    Private Me_DefaultKey As registryKey

    
    ' Methods
    Public Function AddConfig(ByVal name As String, Optional key As registryKey) As IConfig
        Dim config As RegistryConfig
        
        If key Is Nothing Then
            If (Me.defaultKey Is Nothing) Then
                Throw NewApplicationException("You must set DefaultKey")
            End If
            Set key = defaultKey
        End If

        Set config = New RegistryConfig
        Call config.Init(name, Me)
        config.key = key
        config.ParentKey = True
        Call MyBase.Configs.Add(config)
        Set AddConfig = config
    End Function


    Public Sub AddMapping(ByVal registryKey As registryKey, ByVal path As String, Optional recurse As RegistryRecurse)
        Dim key As registryKey
        Dim subKeyNames() As String
        
        If recurse = None Then
            Set key = registryKey.OpenSubKey(path, True)
            If (key Is Nothing) Then
                Throw NewArgumentException("The specified key does not exist")
            End If
            Call LoadKeyValues(key, ShortKeyName(key))
        Else
            Set key = registryKey.OpenSubKey(path, True)
            If (key Is Nothing) Then
                Throw NewArgumentException("The specified key does not exist")
            End If
            If (recurse = RegistryRecurse.Namespacing) Then
                Call LoadKeyValues(key, path)
            Else
                Call LoadKeyValues(key, ShortKeyName(key))
            End If
            
            subKeyNames = key.GetSubKeyNames
            Dim i As Integer
            For i = 0 To cArray.getLength(subKeyNames) - 1
                Select Case recurse
                    Case RegistryRecurse.Flattened
                        Call AddMapping(key, subKeyNames(i), recurse)
                        
                    Case RegistryRecurse.Namespacing
                        Call AddMapping(registryKey, (path & "\" & subKeyNames(i)), recurse)
                        
                End Select
            Next i
        End If
    End Sub



    Private Sub LoadKeyValues(ByVal key As registryKey, ByVal keyName As String)
        Dim config As RegistryConfig
        Dim valueNames() As String
        Dim str As Variant
        
        Set config = New RegistryConfig
        Call config.Init(keyName, Me)
        config.key = key
        valueNames = key.GetValueNames
        
        For Each str In valueNames
            Call config.Add(CStr(str), key.GetValue(CStr(str)))
        Next
        Call MyBase.Configs.Add(config)
    End Sub

    Private Sub MergeConfigsIntoDocument()
        Dim config As IConfig
        Dim config2 As RegistryConfig
        Dim keys() As String
        
        For Each config In MyBase.Configs
            If TypeOf config Is RegistryConfig Then
                
                Set config2 = config
                If config2.ParentKey Then
                    config2.key = config2.key.CreateSubKey(config2.name)
                End If
                Call RemoveKeys(config2)
                 keys = config.GetKeys
                Dim i As Integer
                If Not cArray.IsNull(keys) Then
                    For i = 0 To cArray.getLength(keys) - 1
                        Call config2.key.SetValue(keys(i), config.GetValue(keys(i)))
                    Next i
                End If
                config2.key.Flush
            End If
        Next
    End Sub

    Public Sub Reload()
        ReloadKeys
    End Sub

    Private Sub ReloadKeys()
        Dim num As Integer
        Dim keyArray() As registryKey
        
        Dim tmpRegistryConfig As RegistryConfig
        ReDim keyArray(0 To MyBase.Configs.Count - 1)

        If Not cArray.IsNull(keyArray) Then
            For num = 0 To cArray.getLength(keyArray) - 1
                Set tmpRegistryConfig = Me.Configs.Item(num)
                Set keyArray(num) = tmpRegistryConfig.key
            Next num
        End If
        MyBase.Configs.Clear
        If Not cArray.IsNull(keyArray) Then
            For num = 0 To cArray.getLength(keyArray) - 1
                Call LoadKeyValues(keyArray(num), ShortKeyName(keyArray(num)))
            Next num
        End If
    End Sub

    Private Sub RemoveKeys(ByVal config As RegistryConfig)
        Dim str As Variant
        For Each str In config.key.GetValueNames
            If Not config.Contains(CStr(str)) Then
                Call config.key.DeleteValue(CStr(str))
            End If
        Next
    End Sub

    Public Sub Save()
        Dim config As RegistryConfig
        Dim keys() As String
        Dim i As Integer
        Dim j As Integer
        
        MergeConfigsIntoDocument
        
        For i = 0 To MyBase.Configs.Count - 1
            If TypeOf MyBase.Configs.Item(i) Is RegistryConfig Then
                Set config = MyBase.Configs.Item(i)
                keys = config.GetKeys
                If Not cArray.IsNull(keys) Then
                    For j = 0 To cArray.getLength(keys) - 1
                        Call config.key.SetValue(keys(j), config.GetValue(keys(j)))
                    Next j
                End If
            End If
        Next i
    End Sub

    Private Function ShortKeyName(ByVal key As registryKey) As String
        Dim num As Integer
        num = cString.LastIndexOfAny(key.name, "\")
        ShortKeyName = IIf((num = -1), key.name, Mid$(key.name, num + 2))
    End Function


    ' Properties
    Public Property Get defaultKey() As registryKey
        
            Set defaultKey = Me_DefaultKey
    End Property
    Public Property Let defaultKey(ByVal RHS As registryKey)
            Set Me_DefaultKey = RHS
        
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

''
' Returns a string representation of this object instance.
' The default method simply returns the application name
' and class name in which this class resides.
'
' A Person class may return the person's name instead.
'
Public Function ToString() As String
    ToString = Object.ToString(Me, App)
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
    'Call Me.Init
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
    'Call Me.Init
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
