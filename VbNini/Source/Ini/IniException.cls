VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IniException"
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
' This is the base implementation of an ApplicationException class.
'
'
Option Explicit
Implements IObject
Implements Exception
Implements ApplicationException

' Default Values
Private Const DEF_HRESULT   As Long = 5   ' Invalid procedure call or argument
Private Const DEF_MESSAGE   As String = vbNullString

' Property names used with the PropertyBag
Private Const PROP_BASE As String = "Base"

' The ExceptionBase class handles everything this class will perform.
Private mBase As VBCorLib.ExceptionBase

' Fields
Private Me_iniReader As iniReader
Private Me_message As String

' Methods

''
' Use this method to initialize a new instance of the class.
'
Friend Sub Init(Optional ByRef message As String, Optional ByRef InnerException As Exception)
    
    
    If message = "" Then message = "An error has occurred"
    Me_message = message
    
    Set mBase = Nothing
    Set mBase = Cor.NewExceptionBase(Me, App.Title, message, InnerException, DEF_HRESULT)
    

End Sub





Friend Sub Init_IniReader(ByVal reader As iniReader, Optional ByVal message As String)
    Set Me_iniReader = reader
    Call Init(message)
End Sub

'Sub Init_New(ByVal info As SerializationInfo, ByVal context As StreamingContext)
'    mBase.New(info, context)
'    Me.iniReader = Nothing
'    Me.message = ""
'End Sub

'Public Sub New(ByVal message As String, ByVal exception As Exception)
'    mBase.New(message, exception)
'    Me.iniReader = Nothing
'    Me.message = ""
'End Sub

''<SecurityPermission(SecurityAction.Demand, SerializationFormatter:=True)>
'Public Sub GetObjectData(ByVal info As SerializationInfo, ByVal context As StreamingContext)
'    mBase.GetObjectData(info, context)
'    If (Not Me.iniReader Is Nothing) Then
'        info.AddValue("lineNumber", Me_iniReader.LineNumber)
'        info.AddValue("linePosition", Me_iniReader.LinePosition)
'    End If
'End Sub


' Properties
Public Property Get LineNumber() As Integer
    LineNumber = IIf((Me_iniReader Is Nothing), 0, Me_iniReader.LineNumber)
End Property

Public Property Get LinePosition() As Integer
        LinePosition = IIf((Me_iniReader Is Nothing), 0, Me_iniReader.LinePosition)
End Property

''
' Gets the error message associated with the Subclass exception.
'
' @return A custom message set by the Subclass, or a default
' message of "An Error has occurred."
' @remarks Generally this property is set to a meaningful message that
' is related to the exception that is being thrown. The message should
' be human readable.
' <p>This property can be set in the constructor <b>NewException</b>.
'
Public Property Get message() As String
    If (Me_iniReader Is Nothing) Then
        message = mBase.message
        Exit Function
    End If
    message = cString.format("{0} - Line: {1}, Position: {2}.", Me_message, Me.LineNumber, Me.LinePosition)
    
End Property





Public Property Get Data() As IDictionary
    Set Data = mBase.Data
End Property


''
' Gets a link to a help file associated with the exception.
'
' @return The Uniform Resource Name (URN) or Uniform Resource Locator (URL).
' @remarks The return value, which represents a help file, is a URN or URL. For example, the HelpLink value could be:<br>
' "http://www.myhelpsite.com"
'
Public Property Get HelpLink() As String
    HelpLink = mBase.HelpLink
End Property

''
' Sets a link to a help file associated with the exception.
'
' @param RHS Set the Uniform Resource Name (URN) or Uniform Resource Locator (URL).
' @remarks The return value, which represents a help file, is a URN or URL. For example, the HelpLink value could be:<br>
' "http://www.myhelpsite.com"
'
Public Property Let HelpLink(ByVal RHS As String)
    mBase.HelpLink = RHS
End Property

''
' Gets the HRESULT, a coded numerical value that is assigned to a specific exception.
'
' @return The value of the associated HResult.
' @remarks An HResult is associated with an error result code. This allows for VB specific
' error codes to be returned.
' @see Exception
'
Public Property Get HResult() As Long
    HResult = mBase.HResult
End Property

''
' Sets the HRESULT, a coded numerical value that is assigned to a specific exception.
'
' @param RHS The value of the associated HResult.
' @remarks An HResult is associated with an error result code. This allows for VB specific
' error codes to be returned. This is the same as <b>Err.Number</b>.
' @see Exception
'
Public Property Let HResult(ByVal RHS As Long)
    mBase.HResult = RHS
End Property

''
' Gets a description of the source of the exception.
'
' @return A description of the source of the exception.
' @remarks The source of an exception generally will contain the name of
' the function being called when the exception was thrown. This is to help
' narrow down exactly where the exception had occurred.
'
Public Property Get source() As String
    source = mBase.source
End Property

''
' Sets a description of the source of the exception.
'
' @param RHS A description of the source of the exception.
' @remarks The source of an exception generally will contain the name of
' the function being called when the exception was thrown. This is to help
' narrow down exactly where the exception had occurred.
'
Public Property Let source(ByVal RHS As String)
    mBase.source = RHS
End Property



''
' Gets the exception that caused the Subclassed exception to be thrown.
'
' @return The inner exception that caused the current exception to be thrown.
' @remarks when an exception is thrown and that exception causes another
' exception to be thrown, then the <b>InnerException</b> of the new <b>Exception</b>
' object should contain the exception that caused it to be thrown.
'
Public Property Get InnerException() As Exception
    Set InnerException = mBase.InnerException
End Property

''
' Gets the original exception that caused the chain of exceptions to occur.
'
' @return The <b>Exception</b> that caused the chain of exceptions to occur.
' @remarks If exceptions set their <b>InnerException</b> to a previously thrown
' exception, then a chain of exceptions can be created. Using this function will
' traverse that chain of exceptions until the original exception is reached. That
' exception with then be returned to the caller.
' <p>When an <b>InnerException</b> of Nothing is reached, then then the exception object is returned
' as the base exception because it did not have an inner exception, so it is assumed that
' the exception object is the last in the chain and therefore the cause of the
' chain of exceptions being iterated.
'
Public Function GetBaseException() As Exception
    Set GetBaseException = mBase.GetBaseException
End Function

''
' Returns the exception message prepended with the type name of the Subclass Exception.
'
' @return A formatted message containing the original message and possible type of exception.
' @remarks A general format might look like this:<br>
' VBCorLib.SystemException: An Error has occurred.
' <p>A listing of all inner exceptions will be included in the return value.</p>
'
Public Function ToString() As String
    ToString = mBase.ToString(message)
End Function

''
' Provides a basic implementation of the Equals function of the <b>IObject</b> interface.
'
' @param Value The value to determine if is the same object instance as the exception.
' @return Returns True if Value is the same instance as the exception object, False otherwise.
'
Public Function Equals(ByRef value As Variant) As Boolean
    Equals = mBase.Equals(value)
End Function

''
' Provides a basic implementation of the GetHashcode function of the <b>IObject</b> interface.
'
' @return A 32-bit value used to help identify the exception object.
' @remarks The value generated is not unique across all hashcodes. Additional
' measures must be taken to find a unique value that happens to have the same
' hashcode as the exception object.
'
Public Function GetHashCode() As Long
    GetHashCode = mBase.GetHashCode
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   Friend Interface
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''




'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   Class Events
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub Class_InitProperties()
    Call Init(DEF_MESSAGE, Nothing)
End Sub

Private Sub Class_ReadProperties(PropBag As PropertyBag)
    Set mBase = PropBag.ReadProperty(PROP_BASE)
End Sub

Private Sub Class_WriteProperties(PropBag As PropertyBag)
    Call PropBag.WriteProperty(PROP_BASE, mBase)
End Sub


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' Exception Interface
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Property Get ApplicationException_Data() As VBCorLib.IDictionary
    Set ApplicationException_Data = Data
End Property

Private Property Get Exception_Data() As VBCorLib.IDictionary
    Set Exception_Data = Data
End Property

Private Function Exception_Equals(value As Variant) As Boolean
    Exception_Equals = Equals(value)
End Function

Private Function Exception_GetBaseException() As VBCorLib.Exception
    Set Exception_GetBaseException = GetBaseException
End Function

Private Function Exception_GetHashCode() As Long
    Exception_GetHashCode = GetHashCode
End Function

Private Property Let Exception_HelpLink(ByVal RHS As String)
    HelpLink = RHS
End Property

Private Property Get Exception_HelpLink() As String
    Exception_HelpLink = HelpLink
End Property

Private Property Let Exception_HResult(ByVal RHS As Long)
    HResult = RHS
End Property

Private Property Get Exception_HResult() As Long
    Exception_HResult = HResult
End Property

Private Property Get Exception_InnerException() As VBCorLib.Exception
    Set Exception_InnerException = InnerException
End Property

Private Property Get Exception_Message() As String
    Exception_Message = message
End Property

Private Property Let Exception_Source(ByVal RHS As String)
    source = RHS
End Property

Private Property Get Exception_Source() As String
    Exception_Source = source
End Property

Private Function Exception_ToString() As String
    Exception_ToString = ToString
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   IObject interface
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


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
' ApplicationException Interface
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Function ApplicationException_Equals(value As Variant) As Boolean
    ApplicationException_Equals = Equals(value)
End Function

Private Function ApplicationException_GetBaseException() As VBCorLib.Exception
    Set ApplicationException_GetBaseException = GetBaseException
End Function

Private Function ApplicationException_GetHashCode() As Long
    ApplicationException_GetHashCode = GetHashCode
End Function

Private Property Let ApplicationException_HelpLink(ByVal RHS As String)
    HelpLink = RHS
End Property

Private Property Get ApplicationException_HelpLink() As String
    ApplicationException_HelpLink = HelpLink
End Property

Private Property Let ApplicationException_HResult(ByVal RHS As Long)
    HResult = RHS
End Property

Private Property Get ApplicationException_HResult() As Long
    ApplicationException_HResult = HResult
End Property

Private Property Get ApplicationException_InnerException() As VBCorLib.Exception
    Set ApplicationException_InnerException = InnerException
End Property

Private Property Get ApplicationException_Message() As String
    ApplicationException_Message = message
End Property

Private Property Let ApplicationException_Source(ByVal RHS As String)
    source = RHS
End Property

Private Property Get ApplicationException_Source() As String
    ApplicationException_Source = source
End Property

Private Function ApplicationException_ToString() As String
    ApplicationException_ToString = ToString
End Function

