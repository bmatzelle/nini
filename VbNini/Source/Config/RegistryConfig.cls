VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "RegistryConfig"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = True
'
' This is the base implementation of an object that can be
' utilized within the VBCorLib library. By implementing the
' standard IObject interface, this class can be utilized in
' additional ways by VBCorLib.
'
Option Explicit
Implements IObject
Implements IConfig
Implements ConfigBase

    Private MyBase As ConfigBase
    ' Fields
    Private Me_Key As registryKey
    Private Me_ParentKey As Boolean
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    ' Methods
    Friend Sub Init(ByVal name As String, ByVal source As IConfigSource)
        Set MyBase = NewConfigBase(name, source)
        Set Me_Key = Nothing
        Me_ParentKey = False
    End Sub


    ' Properties
    Public Property Get key() As registryKey
        
            Set key = Me_Key
    End Property

    Public Property Let key(ByVal value As registryKey)
        Set Me_Key = value
        
    End Property

    Public Property Get ParentKey() As Boolean
        ParentKey = Me_ParentKey
    End Property
    Public Property Let ParentKey(ByVal value As Boolean)
        Me_ParentKey = value
        
    End Property

    Public Sub Add(ByVal key As String, ByVal value As String)
        Call MyBase.Add(key, value)
    End Sub
    
    Public Property Get alias() As AliasText
        Set alias = MyBase.alias
    End Property
    
    Public Property Get configSource() As IConfigSource
        Set configSource = MyBase.configSource
    End Property
    
    Public Function Contains(ByVal key As String) As Boolean
        Contains = MyBase.Contains(key)
    End Function
    
    Public Function Equals(value As Variant) As Boolean
        Equals = MyBase.Equals(value)
    End Function
    
    Public Function GetBoolean(ByVal key As String, Optional ByVal defaultValue As Boolean) As Boolean
        GetBoolean = MyBase.GetBoolean(key, defaultValue)
    End Function
    
    Public Function GetDouble(ByVal key As String, Optional ByVal defaultValue As Double) As Double
        GetDouble = MyBase.GetDouble(key, defaultValue)
    End Function
    
    Public Function GetExpanded(ByVal key As String) As String
        GetExpanded = MyBase.GetExpanded(key)
    End Function
    
    Public Function GetFloat(ByVal key As String, Optional ByVal defaultValue As Single) As Single
        GetFloat = MyBase.GetFloat(key, defaultValue)
    End Function
    
    Public Function GetInt(ByVal key As String, Optional ByVal defaultValue As Variant, Optional ByVal fromAlias As Boolean) As Integer
        GetInt = MyBase.GetInt(key, defaultValue, fromAlias)
    End Function
    
    Public Function GetKeys() As String()
        GetKeys = MyBase.GetKeys
    End Function
    
    Public Function GetLong(ByVal key As String, Optional ByVal defaultValue As Long) As Long
        GetLong = MyBase.GetLong(key, defaultValue)
    End Function
    
    Public Function GetString(ByVal key As String, Optional ByVal defaultValue As String) As String
        GetString = MyBase.GetString(key, defaultValue)
    End Function
    
    Public Function GetValue(ByVal key As String, Optional ByVal defaultValue As String) As String
        GetValue = MyBase.GetValue(key, defaultValue)
    End Function
    
    Public Function GetValues() As String()
        GetValues = MyBase.GetValues
    End Function
    
    Public Property Let name(ByVal RHS As String)
        MyBase.name = RHS
    End Property
    
    Public Property Get name() As String
        name = MyBase.name
    End Property
    
    Public Sub Remove(ByVal key As String)
        MyBase.Remove (key)
    End Sub
    
    Public Sub SetValue(ByVal key As String, ByVal value As Variant)
        Call MyBase.SetValue(key, value)
    End Sub
    




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
'   ConfigBase Interface
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub ConfigBase_Add(ByVal key As String, ByVal value As String)
    Call Add(key, value)
End Sub

Private Property Get ConfigBase_alias() As AliasText
    Set ConfigBase_alias = alias
End Property

Private Property Get ConfigBase_configSource() As IConfigSource
    Set ConfigBase_configSource = configSource
End Property

Private Function ConfigBase_Contains(ByVal key As String) As Boolean
    ConfigBase_Contains = Contains(key)
End Function

Private Function ConfigBase_Equals(value As Variant) As Boolean
    ConfigBase_Equals = Equals(value)
End Function

Private Function ConfigBase_GetBoolean(ByVal key As String, Optional ByVal defaultValue As Boolean) As Boolean
    ConfigBase_GetBoolean = GetBoolean(key, defaultValue)
End Function

Private Function ConfigBase_GetDouble(ByVal key As String, Optional ByVal defaultValue As Double) As Double
    ConfigBase_GetDouble = GetDouble(key, defaultValue)
End Function

Private Function ConfigBase_GetExpanded(ByVal key As String) As String
    ConfigBase_GetExpanded = GetExpanded(key)
End Function

Private Function ConfigBase_GetFloat(ByVal key As String, Optional ByVal defaultValue As Single) As Single
    ConfigBase_GetFloat = GetFloat(key, defaultValue)
End Function

Private Function ConfigBase_GetHashCode() As Long
    ConfigBase_GetHashCode = GetHashCode()
End Function

Private Function ConfigBase_GetInt(ByVal key As String, Optional ByVal defaultValue As Variant, Optional ByVal fromAlias As Boolean) As Integer
    ConfigBase_GetInt = GetInt(key, defaultValue, fromAlias)
End Function

Private Function ConfigBase_GetKeys() As String()
    ConfigBase_GetKeys = GetKeys
End Function

Private Function ConfigBase_GetLong(ByVal key As String, Optional ByVal defaultValue As Long) As Long
    ConfigBase_GetLong = GetLong(key, defaultValue)
End Function

Private Function ConfigBase_GetString(ByVal key As String, Optional ByVal defaultValue As String) As String
    ConfigBase_GetString = GetString(key, defaultValue)
End Function

Private Function ConfigBase_GetValue(ByVal key As String, Optional ByVal defaultValue As String) As String
    ConfigBase_GetValue = GetValue(key, defaultValue)
End Function

Private Function ConfigBase_GetValues() As String()
    ConfigBase_GetValues = GetValues
End Function

Private Property Let ConfigBase_name(ByVal RHS As String)
    name = RHS
End Property

Private Property Get ConfigBase_name() As String
    ConfigBase_name = name
End Property

Private Sub ConfigBase_Remove(ByVal key As String)
    Remove (key)
End Sub

Private Sub ConfigBase_SetValue(ByVal key As String, ByVal value As Variant)
    Call SetValue(key, value)
End Sub

Private Function ConfigBase_ToString() As String
    ConfigBase_ToString = ToString
End Function


'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
'   IConfig Interface
'''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
Private Sub IConfig_Add(ByVal key As String, ByVal value As String)
    Call Add(key, value)
End Sub

Private Property Get IConfig_alias() As AliasText
    Set IConfig_alias = alias
End Property

Private Property Get IConfig_configSource() As IConfigSource
    Set IConfig_configSource = configSource
End Property

Private Function IConfig_Contains(ByVal key As String) As Boolean
    IConfig_Contains = Contains(key)
End Function

Private Function IConfig_Equals(value As Variant) As Boolean
    IConfig_Equals = Equals(value)
End Function

Private Function IConfig_GetBoolean(ByVal key As String, Optional ByVal defaultValue As Boolean) As Boolean
    IConfig_GetBoolean = GetBoolean(key, defaultValue)
End Function

Private Function IConfig_GetDouble(ByVal key As String, Optional ByVal defaultValue As Double) As Double
    IConfig_GetDouble = GetDouble(key, defaultValue)
End Function

Private Function IConfig_GetExpanded(ByVal key As String) As String
    IConfig_GetExpanded = GetExpanded(key)
End Function

Private Function IConfig_GetFloat(ByVal key As String, Optional ByVal defaultValue As Single) As Single
    IConfig_GetFloat = GetFloat(key, defaultValue)
End Function

Private Function IConfig_GetHashCode() As Long
    IConfig_GetHashCode = GetHashCode()
End Function

Private Function IConfig_GetInt(ByVal key As String, Optional ByVal defaultValue As Variant, Optional ByVal fromAlias As Boolean) As Integer
    IConfig_GetInt = GetInt(key, defaultValue, fromAlias)
End Function

Private Function IConfig_GetKeys() As String()
    IConfig_GetKeys = GetKeys
End Function

Private Function IConfig_GetLong(ByVal key As String, Optional ByVal defaultValue As Long) As Long
    IConfig_GetLong = GetLong(key, defaultValue)
End Function

Private Function IConfig_GetString(ByVal key As String, Optional ByVal defaultValue As String) As String
    IConfig_GetString = GetString(key, defaultValue)
End Function

Private Function IConfig_GetValue(ByVal key As String, Optional ByVal defaultValue As String) As String
    IConfig_GetValue = GetValue(key, defaultValue)
End Function

Private Function IConfig_GetValues() As String()
    IConfig_GetValues = GetValues
End Function



Private Property Let IConfig_name(RHS As String)
    name = RHS
End Property

Private Property Get IConfig_name() As String
    IConfig_name = name
End Property

Private Sub IConfig_Remove(ByVal key As String)
    Remove (key)
End Sub

Private Sub IConfig_SetValue(ByVal key As String, ByVal value As Variant)
    Call SetValue(key, value)
End Sub

Private Function IConfig_ToString() As String
    IConfig_ToString = ToString
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
