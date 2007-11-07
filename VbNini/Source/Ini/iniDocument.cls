VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "iniDocument"
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

Public Enum IniFileType
    ' Fields
    MysqlStyle = 3
    PythonStyle = 1
    SambaStyle = 2
    Standard = 0
    WindowsStyle = 4
End Enum


' Fields
    Private me_fileType As IniFileType
    Private me_initialComment As ArrayList
    Private Me_sections As IniSectionCollection

' Methods
    Friend Sub Init()
        Set Me_sections = New IniSectionCollection
        Set me_initialComment = New ArrayList
        me_fileType = IniFileType.Standard
    End Sub

    Friend Sub Init_IniReader(ByVal reader As iniReader)
        Set Me_sections = New IniSectionCollection
        Set me_initialComment = New ArrayList
        me_fileType = IniFileType.Standard
        Call Load_iniReader(reader)
    End Sub

    Friend Sub Init_stream(ByVal stream As stream, Optional ByVal Filetype As IniFileType = IniFileType.Standard)
        Set Me_sections = New IniSectionCollection
        Set me_initialComment = NewArrayList
        me_fileType = IniFileType.Standard
        me_fileType = Filetype
        Call Load_stream(stream)
    End Sub

    
    Friend Sub Init_textReader(ByVal reader As TextReader, Optional ByVal Filetype As IniFileType = IniFileType.Standard)
        Set Me_sections = New IniSectionCollection
        Set me_initialComment = New ArrayList
        me_fileType = IniFileType.Standard
        me_fileType = Filetype
        Call Load_TextReader(reader)
    End Sub


    
    Friend Sub Init_Path(ByVal filePath As String, Optional ByVal Filetype As IniFileType = IniFileType.Standard)
        Set Me_sections = New IniSectionCollection
        Set me_initialComment = NewArrayList()
        me_fileType = IniFileType.Standard
        me_fileType = Filetype
        Call Load_Path(filePath)
    End Sub



    Private Function GetIniReader(ByVal reader As TextReader, ByVal Filetype As IniFileType) As iniReader
        Dim reader2 As iniReader
        Set reader2 = NewIniReader(reader)
        Select Case Filetype
            Case IniFileType.Standard
                Set GetIniReader = reader2
            Case IniFileType.PythonStyle
                reader2.AcceptCommentAfterKey = False
                Call reader2.SetCommentDelimiters(cString.ToCharArray(";#"))
                Call reader2.SetAssignDelimiters(cString.ToCharArray(":"))
                Set GetIniReader = reader2
            Case IniFileType.SambaStyle
                reader2.AcceptCommentAfterKey = False
                Call reader2.SetCommentDelimiters(cString.ToCharArray(";#"))
                reader2.LineContinuation = True
                Set GetIniReader = reader2
            Case IniFileType.MysqlStyle
                reader2.AcceptCommentAfterKey = False
                reader2.AcceptNoAssignmentOperator = True
                Call reader2.SetCommentDelimiters(cString.ToCharArray(";#"))
                Call reader2.SetAssignDelimiters(cString.ToCharArray(":="))
                Set GetIniReader = reader2
            Case IniFileType.WindowsStyle
                reader2.ConsumeAllKeyText = True
                Set GetIniReader = reader2
            Case Else
                Set GetIniReader = reader2
        End Select
        
    End Function

    Private Function GetIniWriter(ByVal reader As textWriter, ByVal Filetype As IniFileType) As iniWriter
        Dim writer As iniWriter
        Set writer = New iniWriter
        Call writer.Init_writer(reader)
        Select Case Filetype
            Case IniFileType.Standard, IniFileType.WindowsStyle
                Set GetIniWriter = writer
            Case IniFileType.PythonStyle
                writer.AssignDelimiter = AscW(":")
                writer.CommentDelimiter = AscW("#")
                 Set GetIniWriter = writer
            Case IniFileType.SambaStyle, IniFileType.MysqlStyle
                writer.AssignDelimiter = AscW("=")
                writer.CommentDelimiter = AscW("#")
                 Set GetIniWriter = writer
            Case Else
                 Set GetIniWriter = writer
        End Select
        
    End Function

    Public Sub Load_iniReader(ByVal reader As iniReader)
        Call Load_Reader(reader)
    End Sub

    Public Sub Load_stream(ByVal stream As stream)
        Call Load_TextReader(NewStreamReader(stream))
    End Sub

    Public Sub Load_TextReader(ByVal reader As TextReader)
        Call Me.Load_iniReader(GetIniReader(reader, Me.Filetype))
    End Sub

    Public Sub Load_Path(ByVal filePath As String)
        Call Load_TextReader(NewStreamReader(filePath))
    End Sub

    Private Sub Load_Reader(ByVal reader As iniReader)
        reader.IgnoreComments = False
        Dim flag As Boolean
        Dim section As IniSection
        On Error GoTo CatchIt
            Do While reader.Read
                    Select Case reader.iniType
                        Case my_iniType.section
                            flag = True
                            If (Not Me.sections.Item(reader.name) Is Nothing) Then
                                Call Me.sections.Remove(reader.name)
                            End If
                            Set section = NewIniSection(reader.name, reader.comment)
                            Call Me.sections.Add(section)
                            GoTo Label_00E9
                        Case my_iniType.key
                            If section.GetValue(reader.name) = "" Then
                                Call section.SetValue(reader.name, reader.value, reader.comment)
                            End If
                            GoTo Label_00E9
                        Case my_iniType.EmptyItem
                            If Not flag Then
                                Call me_initialComment.Add(reader.comment)
                                GoTo Label_00E9
                            End If
                            
                        Case Else
                            GoTo Label_00E9
                    End Select
                    Call section.SetValue(, , reader.comment)
Label_00E9:
                Loop

CatchIt:
    'Debug.Assert Not Err.Number = 0
    reader.iniClose
    
 
    End Sub

    Public Sub Save_stream(ByVal stream As stream)
        Call Me.Save_textWriter(NewStreamWriter(stream))
    End Sub

    Public Sub Save_textWriter(ByVal txtWriter As textWriter)
        Dim tmpiniWriter As iniWriter
        
        Dim Item As INIItem
        Dim section As IniSection
        Dim tmpVar As Variant
        
        
        Set tmpiniWriter = GetIniWriter(txtWriter, Filetype)
        
        For Each tmpVar In me_initialComment
            tmpiniWriter.WriteEmpty (CStr(tmpVar))
        Next
        Dim i As Integer
        For i = 0 To Me.sections.Count - 1
            Set section = Me.sections.Item(i)
            Call tmpiniWriter.WriteSection(section.name, section.comment)
            Dim j As Integer
            For j = 0 To section.ItemCount - 1
                Set Item = section.GetItem(j)
                Select Case Item.myType
                    Case my_iniType.key
                        Call tmpiniWriter.WriteKey(Item.name, Item.value, Item.comment)
                        'Exit Select
                    Case my_iniType.EmptyItem
                        tmpiniWriter.WriteEmpty (Item.comment)
                        'Exit Select
                End Select
            Next j
        Next i
        tmpiniWriter.CloseMe
    End Sub

    Public Sub SavePath(ByVal filePath As String)
        Dim textWriter As StreamWriter
        Set textWriter = NewStreamWriter(filePath)
        Call Save_textWriter(textWriter)
        textWriter.CloseWriter
    End Sub


    ' Properties
    Public Property Get Filetype() As IniFileType
            Filetype = me_fileType
    End Property
    
    Public Property Let Filetype(ByVal value As IniFileType)
            me_fileType = value
    End Property

    Public Property Get sections() As IniSectionCollection
        
            Set sections = Me_sections
        
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

