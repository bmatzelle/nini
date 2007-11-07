VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ConfigBase"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Attribute VB_Ext_KEY = "SavedWithClassBuilder6" ,"Yes"
Attribute VB_Ext_KEY = "Member0" ,"IConfigSource"
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
Implements IConfig
Implements IObject

'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent KeyRemoved[(arg1, arg2, ... , argn)]
Public Event KeyRemoved(sender As IObject, e As ConfigKeyEventArgs)

'To fire this event, use RaiseEvent with the following syntax:
'RaiseEvent KeySet[(arg1, arg2, ... , argn)]
Public Event KeySet(sender As IObject, e As ConfigKeyEventArgs)


' Fields
Private my_aliasText As AliasText
Private configName As String
Private my_configSource As IConfigSource
Private format As IFormatProvider
Private keys As OrderedList


Friend Sub Init(ByVal name As String, ByVal source As IConfigSource)

    Set format = NumberFormatInfo.CurrentInfo
    Set keys = New OrderedList
    
    configName = name
    Set my_configSource = source
    Set my_aliasText = NewAliasText()
End Sub



Private Sub Class_Terminate()
    Set my_aliasText = Nothing
    Set my_configSource = Nothing
End Sub

Public Property Get configSource() As IConfigSource
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.ConfigSource
    Set configSource = my_configSource
End Property



Public Property Let name(ByVal vData As String)
'used when assigning a value to the property, on the left side of an assignment.
'Syntax: X.name = 5
    configName = vData
End Property


Public Property Get name() As String
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.name
    name = configName
End Property



Public Property Get alias() As AliasText
'used when retrieving value of a property, on the right side of an assignment.
'Syntax: Debug.Print X.Alias
    Set alias = my_aliasText
End Property



Public Function Contains(ByVal key As String) As Boolean
    
    Contains = keys.Contains(key)
End Function

Public Sub Add(ByVal key As String, ByVal value As String)
    Call keys.Add(key, value)
End Sub

 


Public Function GetValue(ByVal key As String, Optional ByVal defaultValue As String) As String
Attribute GetValue.VB_UserMemId = 0
Dim str As String
    
   
    On Error GoTo theExit
        str = keys.Item(key)
theExit:
    If str = "" Then str = defaultValue
    GetValue = str
End Function

Public Function GetExpanded(ByVal key As String) As String
    GetExpanded = my_configSource.GetExpanded(Me, key)
End Function

Public Function GetString(ByVal key As String, Optional ByVal defaultValue As String) As String
     GetString = Me.GetValue(key, defaultValue)

End Function

Public Function GetInt(ByVal key As String, Optional ByVal defaultValue As Variant, Optional ByVal fromAlias As Boolean) As Integer
Dim tmpalias As String
Dim tpmstr As String
Dim tmpdefault As String
    If fromAlias Then
        tmpalias = Me.GetValue(key)
        If tmpalias = "" Then
           tpmstr = CStr(defaultValue)
        Else
            tpmstr = CStr(GetIntAlias(key, tmpalias))
        End If
        
    Else
        If Not (IsMissing(defaultValue) Or IsEmpty(defaultValue)) Then
            tmpdefault = CStr(defaultValue)
        End If
        tpmstr = Me.GetValue(key, tmpdefault)
    End If
    
    If (IsMissing(defaultValue) Or IsEmpty(defaultValue)) And (tpmstr = "") Then
        Throw NewArgumentException(("Value not found: " & key))
    Else
        On Error GoTo CatchMe
        GetInt = CInt(tpmstr)
        Exit Function
CatchMe:
        Throw NewArgumentOutOfRangeException("vb6 integers are limited to 16 bits")
    End If
End Function

Public Function GetLong(ByVal key As String, Optional ByVal defaultValue As Long) As Long
Dim tmpstr As String
    
    If Not IsMissing(defaultValue) Then
        tmpstr = CStr(defaultValue)
    End If
    tmpstr = Me.GetValue(key, tmpstr)
    
    On Error GoTo CatchMe
        GetLong = CLng(tmpstr)
        Exit Function
CatchMe:
        Throw NewArgumentOutOfRangeException("vb6 integers are limited to 32 bits")
End Function

Public Function GetBoolean(ByVal key As String, Optional ByVal defaultValue As Boolean) As Boolean
Dim str As String
    str = Me.GetValue(key)
    If IsMissing(defaultValue) Then
        If (str = "") Then
            Throw NewArgumentException(("Value not found: " & key))
        End If
        GetBoolean = GetBooleanAlias(str)
    Else
        If (str = "") Then
            GetBoolean = defaultValue
        Else
            On Error GoTo boolHandler
            GetBoolean = GetBooleanAlias(str)
            Exit Function
boolHandler:
            Err.Clear
            Throw NewArgumentException("expected a Boolean for key value")
        End If
    End If
    
End Function

Private Function GetBooleanAlias(ByVal key As String) As Boolean
    If my_aliasText.ContainsBoolean(key) Then
        GetBooleanAlias = my_aliasText.GetBoolean(key)
        Exit Function
    End If
    If Not my_configSource.alias.ContainsBoolean(key) Then
        Throw NewArgumentException(("Alias value not found: " & key & ". Add it to the Alias property."))
    End If
    GetBooleanAlias = my_configSource.alias.GetBoolean(key)
End Function

Public Function GetFloat(ByVal key As String, Optional ByVal defaultValue As Single) As Single
    Dim tmpstr As String
    If Not IsMissing(defaultValue) Then
        tmpstr = CStr(defaultValue)
    End If
    
    tmpstr = Me.GetValue(key, tmpstr)
    GetFloat = CSng(tmpstr)
End Function

Public Function GetDouble(ByVal key As String, Optional ByVal defaultValue As Double) As Double
    Dim tmpstr As String
    
    If Not IsMissing(defaultValue) Then
        tmpstr = CStr(defaultValue)
    End If
    tmpstr = GetValue(key, tmpstr)
    GetDouble = CDbl(tmpstr)
End Function

Public Function GetKeys() As String()
Dim tmparr() As String
Dim tmpkeys As ArrayList
    Set tmpkeys = keys.keys
    If tmpkeys.Count > 0 Then
        ReDim tmparr(0 To tmpkeys.Count - 1)
        Call tmpkeys.CopyTo(tmparr)
        GetKeys = tmparr
    End If
End Function

Public Function GetValues() As String()
    Dim tmparr() As String
    ReDim tmparr(0 To keys.Count - 1)
    Call cArray.Copy(keys.Values, tmparr, keys.Count)
    GetValues = tmparr
End Function

Public Sub SetValue(ByVal key As String, ByVal value As Variant)
Dim strValue As String
    If IsObject(value) Then
        If value Is VBCorLib.Object Then
            strValue = value.ToString
        End If
    Else
        strValue = CStr(value)
    End If
    
    If IsObject(value) Then
        If (value Is Nothing) Then
            Throw NewArgumentNullException("Value cannot be null")
        End If
    End If
    
    If Not Me.Contains(key) Then
        Call Me.Add(key, strValue)
    Else
        keys.Item(key) = strValue
    End If
    
    If Me.configSource.AutoSave Then
        Me.configSource.Save
    End If
    RaiseEvent KeySet(Me, NewConfigKeyEventArgs(key, strValue))
End Sub




Public Sub Remove(ByVal key As String)
Dim keyValue As String
    If (Not Me.GetValue(key) = "") Then
        
        keyValue = Me.GetValue(key)
        
        Call keys.Remove(key)
        RaiseEvent KeyRemoved(Me, NewConfigKeyEventArgs(key, keyValue))
    End If

End Sub


Private Function GetIntAlias(ByVal key As String, ByVal alias As String) As Integer
    If my_aliasText.ContainsInt(key, alias) Then
        GetIntAlias = my_aliasText.GetInt(key, alias)
    Else
        GetIntAlias = my_configSource.alias.GetInt(key, alias)
    End If
End Function

 

 





Private Property Get IConfig_alias() As AliasText
    Set IConfig_alias = Me.alias()
End Property

Private Property Get IConfig_configSource() As IConfigSource
    Set IConfig_configSource = Me.configSource
End Property

Private Function IConfig_Contains(ByVal key As String) As Boolean
    IConfig_Contains = Me.Contains(key)
End Function

Private Function IConfig_Equals(value As Variant) As Boolean
    IConfig_Equals = Me.Equals(value)
End Function

Private Function IConfig_GetBoolean(ByVal key As String, Optional ByVal defaultValue As Boolean) As Boolean
    If IsMissing(defaultValue) Then
        IConfig_GetBoolean = Me.GetBoolean(key)
    Else
        IConfig_GetBoolean = Me.GetBoolean(key, defaultValue)
    End If
End Function


Private Function IConfig_GetDouble(ByVal key As String, Optional ByVal defaultValue As Double) As Double
    IConfig_GetDouble = Me.GetDouble(key, defaultValue)
End Function

Private Function IConfig_GetExpanded(ByVal key As String) As String
    IConfig_GetExpanded = Me.GetExpanded(key)
End Function

Private Function IConfig_GetFloat(ByVal key As String, Optional ByVal defaultValue As Single) As Single
    IConfig_GetFloat = Me.GetFloat(key, defaultValue)
End Function

Private Function IConfig_GetHashCode() As Long
    IConfig_GetHashCode = Me.GetHashCode
End Function

Private Function IConfig_GetInt(ByVal key As String, Optional ByVal defaultValue As Variant, Optional ByVal fromAlias As Boolean) As Integer
    IConfig_GetInt = Me.GetInt(key, defaultValue, fromAlias)
End Function

Private Function IConfig_GetKeys() As String()
    IConfig_GetKeys = Me.GetKeys
End Function

Private Function IConfig_GetLong(ByVal key As String, Optional ByVal defaultValue As Long) As Long
    IConfig_GetLong = Me.GetLong(key, defaultValue)
End Function

Private Function IConfig_GetString(ByVal key As String, Optional ByVal defaultValue As String) As String
    IConfig_GetString = Me.GetString(key, defaultValue)
End Function

Private Function IConfig_GetValue(ByVal key As String, Optional ByVal defaultValue As String) As String
   IConfig_GetValue = Me.GetValue(key, defaultValue)
End Function

Private Function IConfig_GetValues() As String()
    IConfig_GetValues = Me.GetValues()
End Function

Private Property Let IConfig_name(RHS As String)
     Me.name = RHS
End Property

Private Property Get IConfig_name() As String
    IConfig_name = Me.name
End Property

Private Sub IConfig_Remove(ByVal key As String)
    Call Me.Remove(key)
End Sub


Private Sub IConfig_SetValue(ByVal key As String, ByVal value As Variant)
    Call Me.SetValue(key, value)
End Sub

Private Function IConfig_ToString() As String
    IConfig_ToString = Me.ToString
End Function

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
