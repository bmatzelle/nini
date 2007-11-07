VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "OrderedList"
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
'Implements IDictionary


Private list As ArrayList
Private table As Collection

Public Sub Add(Key As Variant, value As Variant)
    Call list.Add(NewDictionaryEntry(Key, value))
    Call table.Add(value, CStr(Key))
End Sub

Public Sub Clear()
    Set table = New Collection
    list.Clear
End Sub

Public Function Contains(ByVal Key As Variant) As Boolean
On Error GoTo exitsub
    Dim tmpobj As Variant
    If Not IsObject(Key) Then
        tmpobj = table.Item(CStr(Key))
    Else
        Set tmpobj = table.Item(CStr(Key))
    End If
    
    Contains = True
exitsub:
End Function

Public Sub CopyTo(DstArray As Variant, ByVal index As Integer)
    Call list.CopyTo(DstArray, index)
End Sub


Public Function GetEnumerator() As VBCorLib.IEnumerator
    GetEnumerator = list.GetEnumerator
End Function

Public Function NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
Attribute NewEnum.VB_MemberFlags = "40"
    Set NewEnum = CreateEnumerator(GetEnumerator)
End Function

Private Function IndexOf(ByVal Key As Variant) As Integer
    Dim i As Integer
    Dim entry As DictionaryEntry
    IndexOf = -1
    For i = 0 To list.Count - 1
        Set entry = list.Item(i)
        If IsObject(Key) Then
            If entry.Key.Equals(Key) Then
                IndexOf = i
            End If
        Else
            If entry.Key = Key Then
                IndexOf = i
            End If
        End If
    Next i
    
End Function

Public Sub Insert(ByVal index As Integer, ByVal Key As Variant, ByVal value As Object)
    If (index > Me.Count) Then
        Throw NewArgumentOutOfRangeException("index")
    End If
    Call table.Add(value, CStr(Key))
    Call list.Insert(index, NewDictionaryEntry(Key, value))
End Sub

Public Sub Remove(ByVal Key As String)
    Call table.Remove(Key)
    Call list.RemoveAt(IndexOf(Key))
End Sub

Public Sub RemoveAt(ByVal index As Integer)
    Dim entry As DictionaryEntry
    If (index >= Me.Count) Then
        Throw NewArgumentOutOfRangeException("index")
    End If
    entry = list.Item(index)
    Call table.Remove(CStr(entry.Key))
    Call list.RemoveAt(index)
End Sub

 

    ' Properties
Public Property Get Count() As Integer
    Count = list.Count
End Property

Public Property Get IsFixedSize() As Boolean
    IsFixedSize = False
End Property

Public Property Get IsReadOnly() As Boolean
    IsReadOnly = False
End Property

Public Property Get IsSynchronized() As Boolean
    IsSynchronized = False
End Property

Public Property Get Item(ByVal keyOrIndex As Variant) As Variant
Attribute Item.VB_UserMemId = 0
    On Error Resume Next
    Dim dict As DictionaryEntry
    If VarType(keyOrIndex) = vbInteger Then
        'Debug.Print list.Item(keyOrIndex).key
        Set dict = list.Item(keyOrIndex)
        If IsObject(dict.value) Then
            Set Item = dict.value
        Else
            Item = dict.value
        End If
    Else
        If IsObject(table(CStr(keyOrIndex))) Then
            Set Item = table(CStr(keyOrIndex))
        Else
            Item = table(CStr(keyOrIndex))
        End If
    End If
End Property


Public Property Let Item(ByVal keyOrIndex As Variant, value As Variant)
Dim Key As String
    If VarType(keyOrIndex) = vbInteger Then
        If ((keyOrIndex < 0) Or (keyOrIndex >= Me.Count)) Then
            Throw NewArgumentOutOfRangeException("index")
        End If
        
       
        Key = list.Item(keyOrIndex).Key
        list.Item(keyOrIndex) = NewDictionaryEntry(Key, value)
        table.Item(CStr(Key)) = value

    Else
        Key = keyOrIndex
        If Me.Contains(CStr(keyOrIndex)) Then
            If IsObject(value) Then
                Set table.Item(CStr(Key)) = value
            Else
                Call table.Remove(CStr(Key))
                Call table.Add(value, CStr(Key))
            End If
            Set list.Item(IndexOf(Key)) = NewDictionaryEntry(CStr(Key), value)
        Else
            Call Me.Add(Key, value)
        End If
    End If
End Property

Public Property Get keys() As ICollection
    Dim tmplist As ArrayList
    Dim i As Integer

    Set tmplist = NewArrayList
    
    For i = 0 To list.Count - 1
        tmplist.Add (list.Item(i).Key)
    Next i
    Set keys = tmplist

End Property

Public Property Get SyncRoot() As Object
    Set SyncRoot = Me
End Property
Public Property Get Values() As String()
    Dim i As Integer
    Dim tmpValues As ArrayList
    Set tmpValues = NewArrayList()
    
    For i = 0 To list.Count - 1
        Call tmpValues.Add(list.Item(i).value)
    Next i
    Values = tmpValues.ToArray(ciString)
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
'   Class Interface
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Class_Initialize()
    Set list = NewArrayList()
    Set table = New Collection
End Sub

'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   ICollection Interface
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub ICollection_CopyTo(arr As Variant, ByVal index As Long)
    Call Me.CopyTo(arr, index)
End Sub

Private Property Get ICollection_Count() As Long
    ICollection_Count = list.Count
End Property

Private Function ICollection_GetEnumerator() As VBCorLib.IEnumerator
    Set ICollection_GetEnumerator = list.GetEnumerator
End Function

Private Function ICollection_NewEnum() As stdole.IUnknown
    Set ICollection_NewEnum = CreateEnumerator(list.GetEnumerator)
End Function


''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
''   IDictionary Interface
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'Private Sub IDictionary_Add(Key As Variant, value As Variant)
'    Call Me.Add(Key, value)
'End Sub
'
'Private Sub IDictionary_Clear()
'    Me.Clear
'End Sub
'
'Private Property Let IDictionary_CompareMode(ByVal RHS As Scripting.CompareMethod)
'
'End Property
'
'Private Property Get IDictionary_CompareMode() As Scripting.CompareMethod
'
'End Property
'
'Private Function IDictionary_Contains(Key As Variant) As Boolean
'    IDictionary_Contains = Me.Contains(Key)
'End Function
'
'Private Sub IDictionary_CopyTo(arr As Variant, ByVal index As Long)
'    Call Me.CopyTo(arr, index)
'End Sub
'
'Private Property Get IDictionary_Count() As Long
'    IDictionary_Count = Me.Count
'End Property
'
'Private Function IDictionary_Exists(Key As Variant) As Boolean
'
'End Function
'
'Private Function IDictionary_GetEnumerator() As VBCorLib.IEnumerator
'    Set IDictionary_GetEnumerator = Me.GetEnumerator
'End Function
'
'Private Property Get IDictionary_HashVal(Key As Variant) As Variant
'
'End Property
'
'Private Property Get IDictionary_IsFixedSize() As Boolean
'    IDictionary_IsFixedSize = Me.IsFixedSize
'End Property
'
'Private Property Get IDictionary_IsReadOnly() As Boolean
'    IDictionary_IsReadOnly = Me.IsReadOnly
'End Property
'
'Private Property Set IDictionary_Item(Key As Variant, RHS As Variant)
'     Set Me.Item(Key) = RHS
'End Property
'
'Private Property Let IDictionary_Item(Key As Variant, RHS As Variant)
'    Set Me.Item(Key) = RHS
'End Property
'
'Private Property Get IDictionary_Item(Key As Variant) As Variant
'    Set IDictionary_Item = Me.Item(Key)
'End Property
'
'Private Function IDictionary_Items() As Variant
'
'End Function
'
'Private Property Let IDictionary_Key(Key As Variant, RHS As Variant)
'
'End Property
'
'
'
'Private Function IDictionary_Keys() As Variant
' Set IDictionary_Keys = Me.keys
'End Function
'
'
'Private Function IDictionary_NewEnum() As stdole.IUnknown
'    Set ICollection_NewEnum = CreateEnumerator(list.GetEnumerator)
'End Function
'
'Private Sub IDictionary_Remove(Key As Variant)
'    Call Me.Remove(Key)
'End Sub
'
'Private Sub IDictionary_RemoveAll()
'Me.Clear
'End Sub
'
'Private Property Get IDictionary_Values() As VBCorLib.ICollection
'    Set IDictionary_Values = Me.Values
'
'End Property


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   IEnumerable Interface
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function IEnumerable_GetEnumerator() As VBCorLib.IEnumerator
    Set IEnumerable_GetEnumerator = Me.GetEnumerator
End Function

Private Function IEnumerable_NewEnum() As stdole.IUnknown
    Set IEnumerable_NewEnum = CreateEnumerator(list.GetEnumerator)
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
