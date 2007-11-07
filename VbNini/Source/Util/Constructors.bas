Attribute VB_Name = "Constructors"
'
' Nini Configuration Project.
' Copyright (C) 2004 Brent R. Matzelle.  All rights reserved.
' Port to VB6 by David Lewis, 2007
'
' This software is published under the terms of the MIT X11 license, a copy of
' which has been included with this distribution in the LICENSE.txt file.
'

Option Explicit

Public Function NewNotImplementedException(ByVal message As String, Optional ByVal InnerException As Exception) As Exception
    Dim tmpException As NotImplementedException
    Set tmpException = New NotImplementedException
    Call tmpException.Init(message, InnerException)

    Set NewNotImplementedException = tmpException
End Function

Public Function NewConfigEventArgs(ByVal config As IConfig) As ConfigEventArgs
    Set NewConfigEventArgs = New ConfigEventArgs
    Call NewConfigEventArgs.Init(config)
End Function

Public Function NewConfigKeyEventArgs(ByVal keyName As String, ByVal keyValue As String) As ConfigKeyEventArgs
    Set NewConfigKeyEventArgs = New ConfigKeyEventArgs
    
    Call NewConfigKeyEventArgs.Init(keyName, keyValue)
End Function


Public Function NewConfigCollection(ByVal owner As IConfigSource) As ConfigCollection
    Set NewConfigCollection = New ConfigCollection
    Call NewConfigCollection.Init(owner)
End Function

Public Function NewConfigBase(ByVal name As String, ByVal source As IConfigSource) As ConfigBase
    Set NewConfigBase = New ConfigBase
    Call NewConfigBase.Init(name, source)
End Function


Public Function NewIniException(reader As iniReader, Optional message As String) As IniException
    Set NewIniException = New IniException
    Call NewIniException.Init_IniReader(reader, message)
End Function

Public Function NewAliasText() As AliasText
    Set NewAliasText = New AliasText
    
End Function
Public Function NewArgvConfigSource(arguments As Variant) As ArgvConfigSource
    Set NewArgvConfigSource = New ArgvConfigSource
    If IsArray(arguments) Then
        Dim tmparr() As String
        ReDim tmparr(0 To cArray.getLength(arguments) - 1)
        Call cArray.Copy(arguments, tmparr, cArray.getLength(arguments))
        Call NewArgvConfigSource.Init_Array(tmparr)
    End If
    If TypeName(arguments) = "String" Then
        
            Call NewArgvConfigSource.Init(arguments)
        
    End If
End Function
Public Function NewIniWriter(PathStreamOrWriter As Variant) As iniWriter
    Set NewIniWriter = New iniWriter
    If TypeName(PathStreamOrWriter) = "String" Then
        Call NewIniWriter.Init_Path(PathStreamOrWriter)
        Exit Function
    End If
    If TypeOf PathStreamOrWriter Is stream Then
        Call NewIniWriter.Init_stream(PathStreamOrWriter)
        Exit Function
    End If
    If TypeOf PathStreamOrWriter Is textWriter Then
        Call NewIniWriter.Init_writer(PathStreamOrWriter)
        Exit Function
    End If
End Function


Public Function NewIniReader(PathStreamOrReader As Variant) As iniReader
    Set NewIniReader = New iniReader
    
    If TypeName(PathStreamOrReader) = "String" Then
        Call NewIniReader.Init_Path(PathStreamOrReader)
        Exit Function
    End If
    
    If TypeOf PathStreamOrReader Is TextReader Then
        Call NewIniReader.Init_Reader(PathStreamOrReader)
        Exit Function
    End If
    
    If TypeOf PathStreamOrReader Is stream Then
        Call NewIniReader.Init_stream(PathStreamOrReader)
        Exit Function
    End If
End Function

Public Function NewIniDocument(Optional PathStreamOrReader As Variant, Optional Filetype As IniFileType = Standard) As iniDocument
    Set NewIniDocument = New iniDocument
    
    If IsMissing(PathStreamOrReader) Then
        Call NewIniDocument.Init
        Exit Function
    End If
    
    If TypeOf PathStreamOrReader Is iniReader Then
        Call NewIniDocument.Init_IniReader(PathStreamOrReader)
        Exit Function
    End If
    
    If TypeName(PathStreamOrReader) = "String" Then
        Call NewIniDocument.Init_Path(PathStreamOrReader, Filetype)
        Exit Function
    End If
    
    If TypeOf PathStreamOrReader Is TextReader Then
        Call NewIniDocument.Init_textReader(PathStreamOrReader, Filetype)
        Exit Function
    End If
    
    If TypeOf PathStreamOrReader Is stream Then
        Call NewIniDocument.Init_stream(PathStreamOrReader, Filetype)
        Exit Function
    End If
    
End Function

Public Function NewIniSection(name As String, Optional comment As String) As IniSection
    
    Set NewIniSection = New IniSection
    Call NewIniSection.Init(Trim(name), comment)
End Function

Public Function NewIniConfig(name As String, source As IConfigSource) As IniConfig
    Set NewIniConfig = New IniConfig
    Call NewIniConfig.Init(name, source)
End Function



Public Function NewIniConfigSource(Optional PathStreamReaderOrDoc As Variant) As INIConfigSource
    Set NewIniConfigSource = New INIConfigSource
    
    If IsMissing(PathStreamReaderOrDoc) Then
        Call NewIniConfigSource.Init_Reader(NewStringReader(""))
        Exit Function
    End If
    
    If TypeOf PathStreamReaderOrDoc Is iniDocument Then
        Call NewIniConfigSource.Init_Document(PathStreamReaderOrDoc)
        Exit Function
    End If
    
    If TypeName(PathStreamReaderOrDoc) = "String" Then
        Call NewIniConfigSource.Init_FilePath(PathStreamReaderOrDoc)
        Exit Function
    End If
    
    If TypeOf PathStreamReaderOrDoc Is TextReader Then
        Call NewIniConfigSource.Init_Reader(PathStreamReaderOrDoc)
        Exit Function
    End If
    
    If TypeOf PathStreamReaderOrDoc Is stream Then
        Call NewIniConfigSource.Init_stream(PathStreamReaderOrDoc)
        Exit Function
    End If
End Function




Public Function NewIniItem(ByVal name As String, ByVal value As String, ByVal myType As my_iniType, ByVal comment As String) As INIItem
    Set NewIniItem = New INIItem
    Call NewIniItem.Init(name, value, myType, comment)
End Function

Public Function NewConfigSourceBase() As ConfigSourceBase
    Set NewConfigSourceBase = New ConfigSourceBase
    NewConfigSourceBase.Init
End Function
