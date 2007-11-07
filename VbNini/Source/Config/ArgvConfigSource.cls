VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ArgvConfigSource"
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
Attribute MyBase.VB_VarHelpID = -1
    
    ' Fields
    Private Me_arguments() As String
    Private Me_parser As ArgvParser
    
    ' Methods
    Friend Sub Init(ByVal arguments As String)
        Set Me_parser = New ArgvParser
        Call Me_parser.Init(arguments)
        Me_arguments = Me_parser.ArgumentArray
        
    End Sub
    
    Friend Sub Init_Array(arguments() As String)
        Set Me_parser = New ArgvParser
        Call Me_parser.Init_Array(arguments)
        Me_arguments = Me_parser.ArgumentArray
        
    End Sub
    
    Public Sub AddSwitch(ByVal configName As String, ByVal longName As String, Optional ByVal shortName As String)
        Dim config As IConfig
        Set config = GetConfig(configName)
        If (Not shortName = "") Then
            If (Len(shortName) < 1) Then
                If (Len(shortName) > 2) Then
                    Throw NewArgumentException("Short name may only be 1 or 2 characters")
                End If
            End If
        End If
        If itemExists(longName) Then
            Call config.SetValue(longName, Me_parser.Item(longName))
        ElseIf (Not shortName = "") Then
            If itemExists(shortName) Then
                Call config.SetValue(longName, Me_parser.Item(shortName))
            End If
        End If
    End Sub
    Private Function itemExists(name) As Boolean
        On Error GoTo myexit
        Dim x As Variant
        x = Me_parser.Item(name)
        itemExists = True
myexit:
    End Function
    
    
    Public Function GetArguments() As String()
        Dim destinationArray() As String
        ReDim destinationArray(0 To cArray.getLength(Me_arguments) - 1)
        Call cArray.Copy(Me_arguments, destinationArray, cArray.getLength(Me_arguments))
        GetArguments = destinationArray
    End Function

    Private Function GetConfig(ByVal name As String) As IConfig
        Dim config As IConfig
        
        On Error Resume Next
        If (MyBase.Configs.Item(name) Is Nothing) Then
        On Error GoTo 0
            Set config = NewConfigBase(name, Me)
            Call MyBase.Configs.Add(config)
            Set GetConfig = config
        Else
        On Error GoTo 0
            Set GetConfig = MyBase.Configs.Item(name)
        End If
        
    End Function

    Public Sub Reload()
        Throw NewArgumentException("Source cannot be reloaded")
    End Sub

    Public Sub Save()
        Throw NewArgumentException("Source is read only")
    End Sub










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
    MyBase.Merge (source)
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
    Call Me.Init(Command$)
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
    Call Me.Init(Command$)
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
