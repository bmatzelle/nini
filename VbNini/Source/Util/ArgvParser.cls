VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "ArgvParser"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
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
    Private Me_parameters As Collection
    Private Me_ArgArray() As String

' Methods
    Friend Sub Init(ByVal args As String)
        Dim matchs As MatchCollection
        Dim match As match
        Dim regex As RegExp
       
        Set regex = New RegExp
        regex.Pattern = "(['""][^""]+['""])\s*|([^\s]+)\s*"
        regex.Global = True
        regex.MultiLine = True
        
        Set matchs = regex.Execute(args)
        
        If Not matchs.Count = 0 Then
            ReDim Me_ArgArray(0 To matchs.Count - 1)
            Dim i As Integer
            For i = 1 To matchs.Count
                Set match = matchs.Item(i - 1)
                
                Me_ArgArray(i - 1) = Trim(match.value)
            Next i
        Else
            ReDim Me_ArgArray(0 To 0)
        End If
        Call Extract(Me_ArgArray)
    End Sub

    Friend Sub Init_Array(args() As String)
        Me_ArgArray = args
        Call Extract(args)
    End Sub

    Private Sub Extract(args() As String)
        Set Me_parameters = New Collection
        Dim regex As New RegExp
        Dim trimChars() As Integer '
        
        Dim match As match
        Dim key As String
        Dim str2 As Variant
        Const name As Long = 1
        Const value As Long = 3
        
        regex.Pattern = "^([/-]|--){1}(\w+)([:=])?(.+)?$"
        trimChars = cString.ToCharArray("""'")
        
        For Each str2 In args
            On Error Resume Next
            Set match = Nothing
            Set match = regex.Execute(CStr(str2)).Item(0)
            On Error GoTo 0
            If match Is Nothing Then
                If (Not key = "") Then
                    Call Me_parameters.Remove(key)
                    Call Me_parameters.Add(cString.Trim(CStr(str2), trimChars), key)
                End If
            Else
                
                key = match.SubMatches.Item(name)
                'Debug.Print cString.Trim(match.SubMatches.Item(value), cString.FromCharArray(trimChars))
                Call Me_parameters.Add(cString.Trim(match.SubMatches.Item(value), cString.FromCharArray(trimChars)), key)
            End If
        Next
    End Sub


    ' Properties
    Public Property Get Item(ByVal param As String) As String
        
            Item = Me_parameters.Item(param)
        
    End Property

    Public Property Get ArgumentArray() As String()
        ArgumentArray = Me_ArgArray
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
