VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IniSectionCollection"
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
Implements ICollection
Implements IEnumerable

    ' Fields
    Private me_list As OrderedList
    
    ' Methods
    Public Sub Add(ByVal section As IniSection)
        If me_list.Contains(section.name) Then
            Throw NewArgumentException("IniSection already exists")
        End If
        Call me_list.Add(section.name, section)
    End Sub

    Public Sub CopyTo(ByVal DstArr As Variant, ByVal index As Integer)
        Call me_list.CopyTo(DstArr, index)
    End Sub

    Public Function NewEnum() As IUnknown
        
        Set NewEnum = CreateEnumerator(GetEnumerator)
    End Function

    Public Function GetEnumerator() As IEnumerator
        GetEnumerator = me_list.GetEnumerator
    End Function

    Public Sub Remove(ByVal config As String)
        Call me_list.Remove(config)
    End Sub


    ' Properties
    Public Property Get Count() As Integer
        
        Count = me_list.Count
       
    End Property

    Public Property Get IsSynchronized() As Boolean
        
        IsSynchronized = me_list.IsSynchronized
        
    End Property

    Public Property Get Item(ByVal indexOrConfigName As Variant) As IniSection
Attribute Item.VB_UserMemId = 0
        On Error Resume Next
        
        Set Item = me_list.Item(indexOrConfigName)
         
    End Property


    Public Property Get SyncRoot() As Object
        
            SyncRoot = me_list.SyncRoot
        
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
    Set me_list = New OrderedList
End Sub

Private Sub ICollection_CopyTo(arr As Variant, ByVal index As Long)
    Call Me.CopyTo(arr, index)
End Sub

Private Property Get ICollection_Count() As Long
    ICollection_Count = Me.Count
End Property

Private Function ICollection_GetEnumerator() As VBCorLib.IEnumerator
    Set ICollection_GetEnumerator = Me.GetEnumerator
End Function

Private Function ICollection_NewEnum() As stdole.IUnknown
    Set ICollection_NewEnum = Me.NewEnum
End Function

Private Function IEnumerable_GetEnumerator() As VBCorLib.IEnumerator
    Set IEnumerable_GetEnumerator = Me.GetEnumerator
End Function

Private Function IEnumerable_NewEnum() As stdole.IUnknown
    Set IEnumerable_NewEnum = Me.NewEnum
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
