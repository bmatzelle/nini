VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IConfig"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
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
Public Event KeySet(sender As IObject, e As ConfigKeyEventArgs)
Public Event KeyRemoved(sender As IObject, e As ConfigKeyEventArgs)

Public Property Get configSource() As IConfigSource
        Throw NewNotImplementedException("this is just an interface definition ")
End Property


Public Property Get name() As String
        Throw NewNotImplementedException("this is just an interface definition ")
End Property

Public Property Let name(RHS As String)
       Throw NewNotImplementedException("this is just an interface definition ")
End Property

Public Property Get alias() As AliasText
       Throw NewNotImplementedException("this is just an interface definition ")
End Property

Public Function Contains(ByVal key As String) As Boolean
    Throw NewNotImplementedException("this is just an interface definition ")
End Function

Public Function GetValue(ByVal key As String, Optional ByVal defaultValue As String) As String
Attribute GetValue.VB_UserMemId = 0
    Throw NewNotImplementedException("this is just an interface definition ")
End Function


Public Function GetExpanded(ByVal key As String) As String
    Throw NewNotImplementedException("this is just an interface definition ")
End Function

Public Function GetString(ByVal key As String, Optional ByVal defaultValue As String) As String
    Throw NewNotImplementedException("this is just an interface definition ")
End Function


Public Function GetInt(ByVal key As String, Optional ByVal defaultValue As Variant, Optional ByVal fromAlias As Boolean) As Integer
    Throw NewNotImplementedException("this is just an interface definition ")
End Function


Public Function GetLong(ByVal key As String, Optional ByVal defaultValue As Long) As Long
    Throw NewNotImplementedException("this is just an interface definition ")
End Function

Public Function GetBoolean(ByVal key As String, Optional ByVal defaultValue As Boolean) As Boolean
    Throw NewNotImplementedException("this is just an interface definition ")
End Function


Public Function GetFloat(ByVal key As String, Optional ByVal defaultValue As Single) As Single
    Throw NewNotImplementedException("this is just an interface definition ")
End Function

Public Function GetDouble(ByVal key As String, Optional ByVal defaultValue As Double) As Double
    Throw NewNotImplementedException("this is just an interface definition ")
End Function


Public Function GetKeys() As String()
    Throw NewNotImplementedException("this is just an interface definition ")
End Function

Public Function GetValues() As String()
    Throw NewNotImplementedException("this is just an interface definition ")
End Function

Public Sub SetValue(ByVal key As String, ByVal value As Variant)
    Throw NewNotImplementedException("this is just an interface definition ")
End Sub

Public Sub Remove(ByVal key As String)
    Throw NewNotImplementedException("this is just an interface definition ")
End Sub

