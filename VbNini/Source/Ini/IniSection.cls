VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IniSection"
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

'
' This is the base implementation of an object that can be
' utilized within the VBCorLib library. By implementing the
' standard IObject interface, this class can be utilized in
' additional ways by VBCorLib.
'
Option Explicit
Implements IObject
' Fields
    Private Me_comment As String
    Private Me_commentCount As Integer
    Private Me_configList As OrderedList
    Private Me_name As String

' Methods
    Friend Sub Init(ByVal name As String, Optional ByVal comment As String = "")

        Set Me_configList = New OrderedList
        Me_commentCount = 0
        Me_name = name
        Me_comment = comment
      
    End Sub

    Public Function Contains(ByVal key As String) As Boolean
        On Error Resume Next
        Contains = (Not Me_configList.Item(key) Is Nothing)
    End Function

    Public Function GetItem(ByVal index As Integer) As INIItem
        Set GetItem = Me_configList.Item(index)
    End Function

    Public Function GetKeys() As String()
        Dim list As ArrayList
        
        Dim Item As INIItem
        Dim i As Integer
        Dim arr() As String
        
        Set list = NewArrayList()
        For i = 0 To Me_configList.Count - 1
            Set Item = Me_configList.Item(i)
            If (Item.myType = my_iniType.key) Then
                list.Add (Item.name)
            End If
        Next i
        If list.Count = 0 Then
            GetKeys = arr
            Exit Function
        End If
        ReDim arr(0 To list.Count - 1)
        Call list.CopyTo(arr)
        GetKeys = arr

    End Function

    Public Function GetValue(ByVal key As String) As String
        Dim str As String
        Dim Item As INIItem
        On Error Resume Next
        If Me.Contains(key) Then
            Set Item = Me_configList.Item(key)
            str = Item.value
        End If
        GetValue = str
    End Function

    Public Sub Remove(ByVal key As String)
        If Me.Contains(key) Then
            Call Me_configList.Remove(key)
        End If
    End Sub

    Public Sub SetValue(Optional ByVal key As Variant, Optional ByVal value As Variant, Optional ByVal comment As Variant)
        Dim Item As INIItem
        On Error GoTo CatchIt
        If IsEmpty(comment) Or IsMissing(comment) Then
            comment = ""
        End If
        
        If (IsEmpty(key) And IsEmpty(value)) Or (IsMissing(key) And IsMissing(value)) Then
            
            key = "#comment" & Me_commentCount

            Set Item = NewIniItem(key, "", my_iniType.EmptyItem, comment)
            Call Me_configList.Add(key, Item)
            Me_commentCount = Me_commentCount + 1
            Exit Sub
        End If

        If Not (IsEmpty(key) Or IsEmpty(value)) Then
            If Not (IsMissing(key) Or IsMissing(value)) Then
                If Me.Contains(key) Then
                    Set Item = Me_configList.Item(key)
                    Item.value = value
                    Item.comment = comment
                Else
                    Set Item = NewIniItem(key, value, my_iniType.key, comment)
                    Call Me_configList.Add(key, Item)
                End If
                Exit Sub
            End If
        End If
CatchIt:
    'Debug.Assert False
    End Sub


    ' Properties
    Public Property Get comment() As String
        
        comment = Me_comment
        
    End Property

    Public Property Get ItemCount() As Integer
        
        ItemCount = Me_configList.Count
        
    End Property

    Public Property Get name() As String
        
            name = Me_name
        
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
