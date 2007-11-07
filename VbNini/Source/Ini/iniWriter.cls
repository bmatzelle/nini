VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "iniWriter"
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
    Public Enum IniWriteState
        ' Fields
        BeforeFirstSection = 1
        Closed = 3
        section = 2
        Start = 0
    End Enum


 ' Fields
    Private Me_AssignDelimiter As Integer
    Private Me_BaseStream As stream
    Private Me_CommentDelimiter As Integer
    Private Me_disposed As Boolean
    Private Me_eol As String
    Private Me_indentation As Integer
    Private Me_indentationBuffer As StringBuilder
    Private Me_textWriter As textWriter
    Private Me_UseValueQuotes As Boolean
    Private Me_WriteState As IniWriteState
 ' Methods
    Friend Sub Init_stream(ByVal stream As stream)
        Call Init_writer(NewStreamWriter(stream))
    End Sub

    Friend Sub Init_writer(ByVal writer As textWriter)
        Me_indentation = 0
        Me_UseValueQuotes = False
        Me_WriteState = IniWriteState.Start
        Me_CommentDelimiter = AscW(";")
        Me_AssignDelimiter = AscW("=")
        Set Me_textWriter = Nothing
        Me_eol = ChrW(13) & ChrW(10)
        Set Me_indentationBuffer = NewStringBuilder
        Set Me_BaseStream = Nothing
        Me_disposed = False
        Set Me_textWriter = writer
        Dim writer2 As StreamWriter
        If TypeOf writer Is StreamWriter Then
            Set writer2 = writer
            
            If (Not writer2 Is Nothing) Then
                Set Me_BaseStream = writer2.BaseStream
            End If
        End If
    End Sub

    Friend Sub Init_Path(ByVal filePath As String)
        Call Init_stream(NewFileStream(filePath, FileMode.Create, FileAccess.WriteAccess, FileShare.None))
    End Sub

    Public Sub CloseMe()
        Me_textWriter.CloseWriter
        Me_WriteState = IniWriteState.Closed
    End Sub

    Private Function myComment(ByVal text As String) As String
        myComment = IIf((text = ""), "", _
            " " & ChrW$(Me_CommentDelimiter) & " " & text)
    End Function

    

    Public Sub Flush()
        Me_textWriter.Flush
    End Sub

    Private Function GetKeyValue(ByVal text As String) As String
        If UseValueQuotes Then
            GetKeyValue = MassageValue("""" & text & """")
            Exit Function
        End If
        GetKeyValue = MassageValue(text)
    End Function

    Private Function MassageValue(ByVal text As String) As String
        MassageValue = Replace(text, ChrW(10), "")
    End Function

    Public Function ToString() As String
        ToString = Me_textWriter.ToString
    End Function

    Private Sub ValidateState()
        If (Me.WriteState = IniWriteState.Closed) Then
            Throw NewInvalidOperationException("The writer is closed")
        End If
    End Sub

    Private Sub ValidateStateKey()
        ValidateState
        Select Case Me.WriteState
            Case IniWriteState.Start, IniWriteState.BeforeFirstSection
                Throw NewInvalidOperationException("The WriteState is not Section")
            Case IniWriteState.Closed
                Throw NewInvalidOperationException("The writer is closed")
        End Select
    End Sub

    Private Sub WriteValue(ByVal value As String)
        Call Me_textWriter.WriteValue((Me_indentationBuffer.ToString & value))
    End Sub

    Public Sub WriteEmpty(Optional ByVal comment As String)
        If IsMissing(comment) Then
            ValidateState
            If (Me_WriteState = IniWriteState.Start) Then
                Me_WriteState = IniWriteState.BeforeFirstSection
            End If
            WriteLine ("")
        Else
            ValidateState
            If (Me_WriteState = IniWriteState.Start) Then
                Me_WriteState = IniWriteState.BeforeFirstSection
            End If
            If (comment = "") Then
                WriteLine ("")
            Else
                WriteLine ((Chr(Me_CommentDelimiter) & " " & comment))
            End If
        End If
    End Sub



    Public Sub WriteKey(ByVal key As String, ByVal value As String, Optional ByVal comment As String)
        If IsMissing(comment) Then
            ValidateStateKey
            Call WriteLine(cString.TrimEnd(Join( _
            NewStrings(key, " ", Chr(AssignDelimiter), " ", GetKeyValue(value)))))
            
        Else
            ValidateStateKey
            Call WriteLine(key & " " & Chr(AssignDelimiter) & " " & _
            GetKeyValue(value) & myComment(comment))
        End If
    End Sub

    Private Sub WriteLine(ByVal value As String)
        Call WriteValue((value & Me_eol))
    End Sub

    Public Sub WriteSection(ByVal section As String, Optional ByVal comment As String)
        If IsMissing(comment) Then
            ValidateState
            Me_WriteState = IniWriteState.section
            Call WriteLine(("[" & section & "]"))
        Else
            ValidateState
            Me_WriteState = IniWriteState.section
            
           
            Call WriteLine("[" & section & "]" & myComment(comment))
        End If
        
    End Sub


    ' Properties
    Public Property Get AssignDelimiter() As Integer
        
            AssignDelimiter = Me_AssignDelimiter
    End Property
    
    Public Property Let AssignDelimiter(ByVal value As Integer)
        Me_AssignDelimiter = value
        
    End Property

    Public Property Get BaseStream() As stream
        
            BaseStream = Me_BaseStream
        
    End Property

    Public Property Get CommentDelimiter() As Integer
        
            CommentDelimiter = Me_CommentDelimiter
    End Property
    Public Property Let CommentDelimiter(ByVal RHS As Integer)
        Me_CommentDelimiter = RHS
        
    End Property

    Public Property Get Indentation() As Integer
        
            Indentation = Me_indentation
    End Property
    Public Property Let Indentation(ByVal value As Integer)
            If (value < 0) Then
                Throw NewArgumentException("Negative values are illegal")
            End If
            Me_indentation = value
            Call Me_indentationBuffer.Remove(0, Me_indentationBuffer.Length)
            Dim i As Integer
            For i = 0 To value - 1
                Call Me_indentationBuffer.Append(" ")
            Next i
    End Property

    Public Property Get UseValueQuotes() As Boolean
        
            UseValueQuotes = Me_UseValueQuotes
    End Property
    Public Property Let UseValueQuotes(ByVal value As Boolean)
            Me_UseValueQuotes = value
        
    End Property

    Public Property Get WriteState() As IniWriteState
        
            WriteState = Me_WriteState
        
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

Private Sub Class_Terminate()
    If Not Me_textWriter Is Nothing Then Me_textWriter.CloseWriter
    If Not Me_BaseStream Is Nothing Then Me_BaseStream.CloseStream

End Sub
