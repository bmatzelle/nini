VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "iniReader"
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




Public Enum IniReadState
    ' Fields
    Closed = 0
    EndOfFile = 1
    [Error] = 2
    Initial = 3
    Interactive = 4
End Enum

 


    ' Fields
    Private me_acceptCommentAfterKey As Boolean
    Private me_acceptNoAssignmentOperator As Boolean
    Private me_assignDelimiters() As Integer
    Private me_column As Long
    Private Me_comment As StringBuilder
    Private me_commentDelimiters() As Integer
    Private me_consumeAllKeyText As Boolean
    Private Me_disposed As Boolean
    Private me_hasComment As Boolean
    Private me_ignoreComments As Boolean
    Private me_iniType As my_iniType
    Private me_lineContinuation As Boolean
    Private me_LineNumber As Long
    Private Me_name As StringBuilder
    Private me_ReadState As IniReadState
    Private me_textReader As TextReader
    Private me_Value As StringBuilder

    Friend Sub Init_stream(ByVal stream As stream)
        Call Init_Reader(NewStreamReader(stream))
    End Sub

    Friend Sub Init_Reader(ByVal reader As TextReader)
        me_LineNumber = 1
        me_column = 1
        me_iniType = EmptyItem
        Set me_textReader = Nothing
        me_ignoreComments = False
        Set Me_name = New StringBuilder
        Set me_Value = New StringBuilder
        Set Me_comment = New StringBuilder
        me_ReadState = IniReadState.Initial
        me_hasComment = False
        Me_disposed = False
        me_lineContinuation = False
        me_acceptCommentAfterKey = True
        me_acceptNoAssignmentOperator = False
        me_consumeAllKeyText = False
        me_commentDelimiters = cString.ToCharArray(";")
        me_assignDelimiters = cString.ToCharArray("=")
        Set me_textReader = reader
    End Sub

    Friend Sub Init_Path(ByVal filePath As String)
        me_LineNumber = 1
        me_column = 1
        me_iniType = EmptyItem
        Set me_textReader = Nothing
        me_ignoreComments = False
        Set Me_name = New StringBuilder
        Set me_Value = New StringBuilder
        Set Me_comment = New StringBuilder
        me_ReadState = IniReadState.Initial
        me_hasComment = False
        Me_disposed = False
        me_lineContinuation = False
        me_acceptCommentAfterKey = True
        me_acceptNoAssignmentOperator = False
        me_consumeAllKeyText = False
        me_commentDelimiters = cString.ToCharArray(";")
        me_assignDelimiters = cString.ToCharArray("=")
        Set me_textReader = NewStreamReader(filePath)
    End Sub

    Public Sub iniClose()
        Reset
        me_ReadState = IniReadState.Closed
        If (Not me_textReader Is Nothing) Then
            me_textReader.CloseReader
        End If
    End Sub

    Private Sub ConsumeToEnd()
        Dim ch As Integer
        ch = -1
        Do
            ch = ReadChar
        Loop While Not EndOfLine(ch)
    End Sub


    Private Function EndOfLine(ByVal ch As Integer) As Boolean
        EndOfLine = (ch = 10) Or (ch = -1)
    End Function

    
    Public Function GetAssignDelimiters() As Integer()
        Dim destinationArray() As Integer
        ReDim destinationArray(0 To cArray.getLength(me_assignDelimiters) - 1)
        Call cArray.Copy(me_assignDelimiters, destinationArray, cArray.getLength(me_assignDelimiters))
        GetAssignDelimiters = destinationArray
    End Function

    Public Function GetCommentDelimiters() As Integer()
        Dim destinationArray() As Integer
        ReDim destinationArray(0 To cArray.getLength(me_commentDelimiters) - 1)
        Call cArray.Copy(me_commentDelimiters, destinationArray, cArray.getLength(me_commentDelimiters))
        GetCommentDelimiters = destinationArray
    End Function

    Private Function HasCharacter(characters() As Integer, ByVal ch As Integer) As Boolean
        Dim i As Integer
        For i = 0 To cArray.getLength(characters) - 1
            If (ch = characters(i)) Then
                HasCharacter = True
            End If
        Next i
        
    End Function

    Private Function IsAssign(ByVal ch As Integer) As Boolean
        IsAssign = HasCharacter(me_assignDelimiters, ch)
    End Function

    Private Function IsComment(ByVal ch As Integer) As Boolean
        IsComment = HasCharacter(me_commentDelimiters, ch)
    End Function

    Private Function IsWhitespace(ByVal ch As Integer) As Boolean
        IsWhitespace = ((((ch = &H20) Or (ch = 9)) Or (ch = 13)) Or (ch = 10))
    End Function

    Public Function MoveToNextKey() As Boolean
        Dim flag As Boolean
        
        Do While True
            flag = Read
            If (iniType = my_iniType.section) Then
                MoveToNextKey = False: Exit Function
            End If
            If Not ((iniType <> my_iniType.key) And flag) Then
                MoveToNextKey = flag: Exit Function
            End If
        Loop
    End Function

    Public Function MoveToNextSection() As Boolean
        Dim flag As Boolean
        Do While True
            flag = Read
            If Not ((iniType <> my_iniType.section) And flag) Then
                MoveToNextSection = flag: Exit Function
            End If
        Loop
    End Function

    Private Function PeekChar() As Integer
        PeekChar = me_textReader.Peek
    End Function

    Public Function Read() As Boolean
        Dim flag As Boolean
        If (Not ReadState = IniReadState.EndOfFile) And (Not ReadState = IniReadState.Closed) Then
            me_ReadState = IniReadState.Interactive
            flag = ReadNext
        End If
        Read = flag
    End Function

    Private Function ReadChar() As Integer
        Dim num As Integer
        num = me_textReader.Read
        If (num = 10) Then
            me_LineNumber = me_LineNumber + 1
            me_column = 1
            ReadChar = num: Exit Function
        End If
        me_column = me_column + 1
        ReadChar = num: Exit Function
    End Function

    Private Sub ReadComment()
        Dim ch As Integer
        ch = -1
        SkipWhitespace
        me_hasComment = True
        Do
            ch = ReadChar
            Me_comment.AppendChar ch
        Loop While Not EndOfLine(ch)
        Call RemoveTrailingWhitespace(Me_comment)
    End Sub

    Private Sub ReadKey()
        Dim ch As Integer
        ch = -1
        me_iniType = my_iniType.key
        Do While True
            ch = PeekChar
            If IsAssign(ch) Then
                ReadChar
                Exit Do
            End If
            If EndOfLine(ch) Then
                If Not AcceptNoAssignmentOperator Then
                    Throw NewIniException(Me, cString.format("Expected assignment operator ({0})", me_assignDelimiters(0)))
                End If
                Exit Do
            End If
            Call Me_name.AppendChar(ReadChar)
        Loop
        ReadKeyValue
        SearchForComment
        Call RemoveTrailingWhitespace(Me_name)
    End Sub

    Private Sub ReadKeyValue()
        Dim flag2 As Boolean
        Dim ch As Integer
        Dim flag As Boolean
        Dim num2 As Integer
        
        ch = -1
        
        SkipWhitespace
Label_0197:
        flag2 = True
        ch = PeekChar
        If Not IsWhitespace(ch) Then
            num2 = num2 + 1
        End If
        If (Not ConsumeAllKeyText And (ch = &H22)) Then
            ReadChar
            If Not (flag Or (num2 <> 1)) Then
                flag = True
                GoTo Label_0197
            End If
        Else
            If (flag And EndOfLine(ch)) Then
                Throw NewIniException(Me, "Expected closing quote ("")")
            End If
            If (me_lineContinuation And (ch = &H5C)) Then
                Dim builder As New StringBuilder
                Call builder.AppendChar(ReadChar)
                Do While ((PeekChar <> 10) And IsWhitespace(PeekChar))
                    If (PeekChar <> 13) Then
                        Call builder.AppendChar(ReadChar)
                    Else
                        ReadChar
                    End If
                Loop
                If (PeekChar = 10) Then
                    ReadChar
                    GoTo Label_0197
                End If
                Call me_Value.Append(builder.ToString)
            End If
            If ((me_consumeAllKeyText Or ((Not me_acceptCommentAfterKey Or Not IsComment(ch)) Or flag)) And Not EndOfLine(ch)) Then
                me_Value.AppendChar ReadChar
                GoTo Label_0197
            End If
        End If
        If Not flag Then
            Call RemoveTrailingWhitespace(me_Value)
        End If
    End Sub

    Private Function ReadNext() As Boolean
        Dim flag As Boolean
        Dim ch As Integer
        flag = True
        ch = PeekChar
        
        Reset
        If IsComment(ch) Then
            me_iniType = EmptyItem
            ReadChar
            ReadComment
            ReadNext = flag: Exit Function
        End If
        Select Case ch
            Case &H20, 9, 13
                SkipWhitespace
                ReadNext
                ReadNext = flag: Exit Function
            Case &H5B
                ReadSection
                ReadNext = flag: Exit Function
            Case 10
                ReadChar
                ReadNext = flag: Exit Function
            Case -1
                me_ReadState = IniReadState.EndOfFile
                ReadNext = False: Exit Function
        End Select
        ReadKey
        ReadNext = flag: Exit Function
    End Function

    Private Sub ReadSection()
        Dim ch As Integer
        ch = -1
        me_iniType = my_iniType.section
        ch = ReadChar
        Do While True
            ch = PeekChar
            If (ch = &H5D) Then
                ConsumeToEnd
                Call RemoveTrailingWhitespace(Me_name)
                Exit Sub
            End If
            If EndOfLine(ch) Then
                Throw NewIniException(Me, "Expected section end (])")
            End If
            Call Me_name.AppendChar(ReadChar)
        Loop
    End Sub

    Private Sub RemoveTrailingWhitespace(ByVal builder As StringBuilder)
        Dim str As String
        str = builder.ToString
        Call builder.Remove(0, builder.Length)
        builder.Append (cString.TrimEnd(str))
        
    End Sub

    Private Sub Reset()
        Call Me_name.Remove(0, Me_name.Length)
        Call me_Value.Remove(0, me_Value.Length)
        Call Me_comment.Remove(0, Me_comment.Length)
        me_iniType = EmptyItem
        me_hasComment = False
    End Sub

    Private Sub SearchForComment()
        Dim i As Integer
        i = ReadChar
        Do While Not EndOfLine(i)
            If IsComment(i) Then
                If me_ignoreComments Then
                    ConsumeToEnd
                Else
                    ReadComment
                End If
                Exit Do
            End If
            i = ReadChar
        Loop
    End Sub

    Public Sub SetAssignDelimiters(delimiters() As Integer)
        If (cArray.getLength(delimiters) < 1) Then
            Throw NewArgumentException("Must supply at least one delimiter")
        End If
        me_assignDelimiters = delimiters
    End Sub

    Public Sub SetCommentDelimiters(delimiters() As Integer)
        If (cArray.getLength(delimiters) < 1) Then
            Throw NewArgumentException("Must supply at least one delimiter")
        End If
        me_commentDelimiters = delimiters
    End Sub

    Private Sub SkipWhitespace()
        Do While IsWhitespace(PeekChar)
            If EndOfLine(PeekChar) Then
                Exit Do
            End If
            ReadChar
        Loop
    End Sub


    ' Properties
    Public Property Get AcceptCommentAfterKey() As Boolean
        
            AcceptCommentAfterKey = me_acceptCommentAfterKey
    End Property
    Public Property Let AcceptCommentAfterKey(ByVal value As Boolean)
            me_acceptCommentAfterKey = value
    End Property

    Public Property Get AcceptNoAssignmentOperator() As Boolean
        AcceptNoAssignmentOperator = me_acceptNoAssignmentOperator
    End Property
    Public Property Let AcceptNoAssignmentOperator(ByVal RHS As Boolean)
        me_acceptNoAssignmentOperator = RHS
    End Property
            

    Public Property Get comment() As String
        
            comment = IIf(me_hasComment, Me_comment.ToString, "")
        
    End Property

    Public Property Get ConsumeAllKeyText() As Boolean
        
            ConsumeAllKeyText = me_consumeAllKeyText
    End Property
    
    Public Property Let ConsumeAllKeyText(ByVal value As Boolean)
            me_consumeAllKeyText = value
        
    End Property

    Public Property Get IgnoreComments() As Boolean
        IgnoreComments = me_ignoreComments
    End Property
        
    Public Property Let IgnoreComments(ByVal value As Boolean)
            me_ignoreComments = value
    End Property

    Public Property Get LineContinuation() As Boolean
            LineContinuation = me_lineContinuation
    End Property
    Public Property Let LineContinuation(ByVal value As Boolean)
            me_lineContinuation = value
    End Property

    Public Property Get LineNumber() As Long
        LineNumber = me_LineNumber
        
    End Property

    Public Property Get LinePosition() As Long
        
        LinePosition = me_column
        
    End Property

    Public Property Get name() As String
        
        name = Trim(Me_name.ToString)
        
    End Property

    Public Property Get ReadState() As IniReadState
        
        ReadState = me_ReadState
        
    End Property

    Public Property Get iniType() As my_iniType
        
            iniType = me_iniType
        
    End Property

    Public Property Get value() As String
        
            value = me_Value.ToString
        
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
