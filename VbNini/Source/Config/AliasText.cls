VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "AliasText"
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



'
' This is the base implementation of an object that can be
' utilized within the VBCorLib library. By implementing the
' standard IObject interface, this class can be utilized in
' additional ways by VBCorLib.
'
Option Explicit
Implements IObject


' Fields
Private booleanAlias As hashtable

Private intAlias As hashtable


Private Sub Class_Initialize()
    Set intAlias = InsensitiveHashtable()
    Set booleanAlias = InsensitiveHashtable
    DefaultAliasLoad
End Sub

' Methods


Public Sub AddAliasBool(ByVal alias As String, ByVal value As Boolean)
    booleanAlias.Item(alias) = value
End Sub

Public Sub AddAliasInt(ByVal Key As String, ByVal alias As String, ByVal value As Integer)
Dim hashtable As hashtable
    Set hashtable = InsensitiveHashtable
    If intAlias.Contains(Key) Then
        Set hashtable = intAlias.Item(Key)
        hashtable.Item(alias) = value
    Else
        Set hashtable = InsensitiveHashtable
        hashtable.Item(alias) = value
        Call intAlias.Add(Key, hashtable)
    End If

End Sub

Public Function ContainsBoolean(ByVal Key As String) As Boolean
    ContainsBoolean = booleanAlias.Contains(Key)

End Function
Public Function ContainsInt(ByVal Key As String, ByVal alias As String) As Boolean
    Dim flag As Boolean
    If intAlias.Contains(Key) Then
        flag = intAlias.Item(Key).Contains(alias)
    End If
    ContainsInt = flag

End Function

Private Sub DefaultAliasLoad()
    Call Me.AddAliasBool("True", True)
    Call Me.AddAliasBool("False", False)
    
        
    Call Me.AddAliasBool("1", True)
    Call Me.AddAliasBool("0", False)
    
    Call Me.AddAliasBool("Yes", True)
    Call Me.AddAliasBool("No", False)
    
End Sub
Public Function GetBoolean(ByVal Key As String) As Boolean
    GetBoolean = booleanAlias.Item(Key)
End Function

Public Function GetInt(ByVal Key As String, ByVal alias As String) As Integer
    GetInt = intAlias.Item(Key).Item(alias)
End Function

Private Function InsensitiveHashtable() As hashtable
    Set InsensitiveHashtable = NewHashtable(, New CaseInsensitiveHashCodePrvdr, New CaseInsensitiveComparer)
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

