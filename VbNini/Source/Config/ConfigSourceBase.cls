VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ConfigSourceBase"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Member0" ,"IConfig"
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
    

' Fields
Private my_Alias As AliasText
Private my_AutoSave As Boolean
Private WithEvents configList As ConfigCollection
Attribute configList.VB_VarHelpID = -1
Private sourceList As ArrayList

' Methods
    Friend Sub Init()
        Set configList = NewConfigCollection(Me)
    End Sub

    Public Function AddConfig(ByVal name As String) As IConfig
        Set AddConfig = configList.AddByName(name)
    End Function

    Private Function Expand(ByVal config As IConfig, ByVal key As String, ByVal SetValue As Boolean) As String
         Dim str As String
        Dim newValue As String
        
        
        If Not (config.Contains(key)) Then
            Throw NewArgumentException(cString.format("[{0}] not found in [{1}]", key, config.name))
        End If
        
        str = config.GetValue(key)
        Do While True
            Dim index As Long
            index = InStr(1, str, "${") - 1
            If (index = -1) Then
                Exit Do
            End If
            Dim num2 As Integer
            If Not index + 2 > Len(str) Then
                num2 = InStr(index + 2, str, "}")
            End If
            If (num2 = -1) Then
                Exit Do
            End If
            Dim search As String
            
            search = Mid$(str, (index + 3), (num2 - (index + 3)))
            If (search = key) Then
                Throw NewArgumentException(("Key cannot have a expand value of itself: " & key))
            End If
            
            newValue = ExpandValue(config, search)
            str = Replace(str, ("${" & search & "}"), newValue)
        Loop
        If SetValue Then
            Call config.SetValue(key, str)
        End If
        Expand = str
    End Function

    Public Sub ExpandKeyValues()
        Dim keys() As String
        Dim config As IConfig
        
        For Each config In configList
            keys = config.GetKeys
            Dim i As Integer
            If Not cArray.IsNull(keys) Then
                For i = 0 To cArray.getLength(keys) - 1
                    Call Expand(config, keys(i), True)
                Next i
            End If
        Next
        
        
    End Sub

    Private Function ExpandValue(ByVal config As IConfig, ByVal search As String) As String
        Dim str As String
        Dim strArray() As String
        strArray = Split(search, "|")
        If (cArray.getLength(strArray) > 1) Then
            Dim config2 As IConfig
            Set config2 = Me.Configs.Item(strArray(0))
            If (config2 Is Nothing) Then
                Throw NewArgumentException("Expand config not found: " & strArray(0))
            End If
            str = config2.GetValue(strArray(1))
            If Not config2.Contains(strArray(1)) Then
                Throw NewArgumentException("Expand key not found: " & strArray(1))
            End If
            ExpandValue = str
        Else
            
            If Not config.Contains(search) Then
                Throw NewArgumentException(("Key not found: " & search))
            End If
            str = config.GetValue(search)
            ExpandValue = str
        End If
    End Function

    Public Function GetExpanded(ByVal config As IConfig, ByVal key As String) As String
        GetExpanded = Expand(config, key, False)
    End Function

    Public Sub Merge(ByVal source As IConfigSource)
        If Not sourceList.Contains(source) Then
            Call sourceList.Add(source)
        End If
        Dim config As IConfig
        For Each config In source.Configs
            Call Configs.Add(config)
        Next
    End Sub

    

    

    Public Sub Reload()
        RaiseEvent Reloaded(Me, New EventArgs)
    End Sub

    Public Sub ReplaceKeyValues()
        Me.ExpandKeyValues
    End Sub

    Public Sub Save()
        RaiseEvent Saved(Me, New EventArgs)
    End Sub


    ' Properties
    Public Property Get alias() As AliasText
        Set alias = my_Alias
    End Property

    Public Property Get AutoSave() As Boolean
        
            AutoSave = my_AutoSave
    End Property
    Public Property Let AutoSave(ByVal value As Boolean)
            my_AutoSave = value
        
    End Property

    Public Property Get Configs() As ConfigCollection
        
            Set Configs = configList
        
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


Private Sub Class_Initialize()
    Set configList = NewConfigCollection(Me)
    Set sourceList = NewArrayList()
    Set my_Alias = NewAliasText()
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
    Set IConfigSource_Configs = Me.Configs
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

