VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "constr"
Attribute VB_GlobalNameSpace = True
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
Option Explicit

Public Enum my_iniType
    EmptyItem = 2
    key = 1
    section = 0
End Enum


Public Function NewConfigSourceBase() As ConfigSourceBase
    Set NewConfigSourceBase = New ConfigSourceBase
    NewConfigSourceBase.Init
End Function



Public Function NewIniConfig(name As String, source As IConfigSource) As IniConfig
    Set NewIniConfig = New IniConfig
    Call NewIniConfig.Init(name, source)
End Function

Public Function NewXmlConfigSource(Optional PathReaderOrDomDocument As Variant) As XmlConfigSource
    Set NewXmlConfigSource = New XmlConfigSource
    If IsEmpty(PathReaderOrDomDocument) Or IsMissing(PathReaderOrDomDocument) Then
        Call NewXmlConfigSource.Init
        Exit Function
    End If
    If TypeName(PathReaderOrDomDocument) = "String" Then
        Call NewXmlConfigSource.Init_Path(PathReaderOrDomDocument)
        Exit Function
    End If
    If TypeOf PathReaderOrDomDocument Is TextReader Then
        Call NewXmlConfigSource.Init_Reader(PathReaderOrDomDocument)
        Exit Function
    End If
    If TypeOf PathReaderOrDomDocument Is DOMDocument Then
        Dim ddoc As DOMDocument
        Set ddoc = PathReaderOrDomDocument
        Call NewXmlConfigSource.Init_DOMDocument(ddoc)
        Exit Function
    End If
End Function


Public Function NewDotNetConfigSource(Optional PathReaderOrDomDocument As Variant) As DotNetConfigSource
    Set NewDotNetConfigSource = New DotNetConfigSource
    If IsEmpty(PathReaderOrDomDocument) Or IsMissing(PathReaderOrDomDocument) Then
        Call NewDotNetConfigSource.Init
        Exit Function
    End If
    If TypeName(PathReaderOrDomDocument) = "String" Then
        Call NewDotNetConfigSource.Init_Path(PathReaderOrDomDocument)
        Exit Function
    End If
    If TypeOf PathReaderOrDomDocument Is TextReader Then
        'Debug.Assert False
        Call NewDotNetConfigSource.Init_Reader(PathReaderOrDomDocument)
        Exit Function
    End If
    If TypeOf PathReaderOrDomDocument Is DOMDocument Then
        Dim ddoc As DOMDocument
        Debug.Assert False
        'Set ddoc = PathReaderOrDomDocument
        'Call NewDotNetConfigSource.Init_DOMDocument(ddoc)
        Exit Function
    End If
End Function

Public Function NewOrderedList() As OrderedList
    Set NewOrderedList = New OrderedList
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
    Call NewIniSection.Init(name, comment)
End Function

Public Function NewAliasText() As AliasText
    Set NewAliasText = New AliasText
    
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

Public Function NewConfigBase(ByVal name As String, ByVal source As IConfigSource) As ConfigBase
    Set NewConfigBase = New ConfigBase
    Call NewConfigBase.Init(name, source)
End Function

Public Function NewConfigCollection(ByVal owner As IConfigSource) As ConfigCollection
    Set NewConfigCollection = New ConfigCollection
    Call NewConfigCollection.Init(owner)
End Function

Public Function NewRegistryConfigSource() As RegistryConfigSource
    Set NewRegistryConfigSource = New RegistryConfigSource
End Function
