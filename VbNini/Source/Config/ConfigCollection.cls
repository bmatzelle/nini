VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ConfigCollection"
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
Implements IEnumerable
Private my_configList As ArrayList
Private my_owner As IConfigSource
    
Public Event ConfigRemoved(ByVal sender As Object, ByVal e As ConfigEventArgs)
Public Event ConfigAdded(ByVal sender As Object, ByVal e As ConfigEventArgs)
    
' Methods
    Friend Sub Init(ByVal owner As IConfigSource)
        Set my_owner = owner
    End Sub

    Public Sub Add(ByVal config As ConfigBase)
        Dim config2 As ConfigBase
        Dim keys() As String
        
        Dim i As Integer
        
        If my_configList.Contains(config) Then
            Throw NewArgumentException("IConfig already exists")
        End If
        Set config2 = Me.Item(config.name)
        If (Not config2 Is Nothing) Then
            keys = config.GetKeys
           
            If Not cArray.IsNull(keys) Then
                For i = 0 To UBound(keys)
                    Call config2.SetValue(keys(i), config.GetValue(keys(i)))
                Next i
            End If
            
        Else
            Call my_configList.Add(config)
            RaiseEvent ConfigAdded(Me, NewConfigEventArgs(config))
        End If
        keys = Me.Item(config.name).GetKeys
    End Sub

    Public Function AddByName(ByVal name As String) As IConfig
        Dim base2 As ConfigBase
        Set base2 = Nothing
        If (Not Me.Item(name) Is Nothing) Then
            Throw NewArgumentException("An IConfig of that name already exists")
        End If
        
        Set base2 = NewConfigBase(name, my_owner)
        Call my_configList.Add(base2)
        
        Set AddByName = base2
        RaiseEvent ConfigAdded(Me, NewConfigEventArgs(base2))
    End Function

    Public Sub Clear()
        my_configList.Clear
    End Sub

    Public Function Contains(ByVal config As Variant) As Boolean
        Contains = my_configList.Contains(config)
    End Function

    Public Sub CopyTo(DstArr As Variant, ByVal index As Integer)
        Call my_configList.CopyTo(DstArr, index)
    End Sub

Public Property Get NewEnum() As IUnknown
Attribute NewEnum.VB_UserMemId = -4
Attribute NewEnum.VB_MemberFlags = "40"
    'this property allows you to enumerate
    'this collection with the For...Each syntax
    Set NewEnum = CreateEnumerator(my_configList.GetEnumerator)
End Property


    Public Function GetEnumerator() As Object
       Dim tmpenumerable As IEnumerable
       Set tmpenumerable = my_configList
        Set GetEnumerator = tmpenumerable.GetEnumerator
    End Function

    Public Function IndexOf(ByVal config As Object) As Integer
         IndexOf = my_configList.IndexOf(config)
    End Function

    Public Sub Insert(ByVal index As Integer, ByVal config As Variant)
        Call my_configList.Insert(index, config)
    End Sub





    Public Sub Remove(ByVal config As Object)
        Call my_configList.Remove(config)
        RaiseEvent ConfigRemoved(Me, NewConfigEventArgs(config))
    End Sub



    Public Sub RemoveAt(ByVal index As Integer)
        Dim config As IConfig
        
        Set config = my_configList.Item(index)
        Call my_configList.RemoveAt(index)
        RaiseEvent ConfigRemoved(Me, NewConfigEventArgs(config))
    End Sub

'    Private Function System.Collections.IList.Add(ByVal config As Object) As Integer 'Implements IList.Add
'        Dim config2 As IConfig = TryCast(config,IConfig)
'        If (config2 Is Nothing) Then
'            Throw New Exception("Must be an IConfig")
'        End If
'        Me.Add (config2)
'        Return Me.IndexOf(config2)
'    End Function


    ' Properties
    Public Property Get Count() As Integer
       
            Count = my_configList.Count
        
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

    Public Property Get Item(ByVal configNameOrIndex As Variant) As ConfigBase
Attribute Item.VB_UserMemId = 0
        If VarType(configNameOrIndex) = vbInteger Then
            Set Item = my_configList.Item(configNameOrIndex)
        Else
            Dim config2 As ConfigBase
            Set Item = Nothing
            For Each config2 In my_configList
                If (config2.name = CStr(configNameOrIndex)) Then
                    Set Item = config2: Exit Property
                End If
            Next
            
        End If
    End Property


    Public Property Get SyncRoot() As Object
        
            Set SyncRoot = Me
        
    End Property

'    Private Property System.Collections.IList.Item(ByVal index As Integer) As Object
'        Get
'            Return my_configList.Item(index)
'        End Get
'        Set(ByVal value As Object)
'        End Set
'    End Property



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
    Set my_configList = NewArrayList()
End Sub

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
