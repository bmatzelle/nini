VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "IConfigSource"
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
Public Event Reloaded(sender As IObject, e As ConfigEventArgs) 'As EventHandler Implements Nini.Config.IConfigSource.Reloaded
Public Event Saved(sender As IObject, e As ConfigEventArgs) 'As EventHandler Implements Nini.Config.IConfigSource.Saved
    
    Public Property Get Configs() As ConfigCollection  'Implements Nini.Config.IConfigSource.Configs
         Throw NewNotImplementedException("")
    End Property
    
    Public Property Get AutoSave() As Boolean 'Implements Nini.Config.IConfigSource.AutoSave
        Throw NewNotImplementedException("")
    End Property
    
    Public Property Let AutoSave(RHS As Boolean)
        Throw NewNotImplementedException("")
    End Property
   
    
    Public Property Get alias() As AliasText 'Implements Nini.Config.IConfigSource.[Alias]
        Throw NewNotImplementedException("")
    End Property
    
    Public Sub Merge(ByVal source As IConfigSource) 'Implements Nini.Config.IConfigSource.Merge
        Throw NewNotImplementedException("")
    End Sub
    
    Public Sub Save() 'Implements Nini.Config.IConfigSource.Save
        Throw NewNotImplementedException("")
    End Sub
    
    Public Sub Reload() 'Implements Nini.Config.IConfigSource.Reload
        Throw NewNotImplementedException("")
    End Sub
    
    Public Function AddConfig(ByVal name As String) As IConfig 'Implements Nini.Config.IConfigSource.AddConfig
        Throw NewNotImplementedException("")
    End Function
    
    Public Function GetExpanded(ByVal config As IConfig, ByVal key As String) As String 'Implements Nini.Config.IConfigSource.GetExpanded
        Throw NewNotImplementedException("")
    End Function
    
    Public Sub ExpandKeyValues() 'Implements Nini.Config.IConfigSource.ExpandKeyValues
        Throw NewNotImplementedException("")
    End Sub
    
    Public Sub ReplaceKeyValues() 'Implements Nini.Config.IConfigSource.ReplaceKeyValues
        Throw NewNotImplementedException("")
    End Sub





