VERSION 5.00
Object = "{BF02AA53-52CE-47D8-876F-0D0A78F085A7}#2.1#0"; "SimplyVBUnitUI.ocx"
Begin VB.Form frmSimplyVBUnit2Runner 
   Caption         =   "Form1"
   ClientHeight    =   6096
   ClientLeft      =   60
   ClientTop       =   456
   ClientWidth     =   8688
   KeyPreview      =   -1  'True
   LinkTopic       =   "Form1"
   ScaleHeight     =   6096
   ScaleWidth      =   8688
   Begin SimplyVBUnitUI.SimplyVBUnitCtl SimplyVBUnitCtl1 
      Height          =   5895
      Left            =   600
      TabIndex        =   0
      Top             =   0
      Width           =   6975
      _ExtentX        =   12298
      _ExtentY        =   10393
   End
End
Attribute VB_Name = "frmSimplyVBUnit2Runner"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = False
Attribute VB_PredeclaredId = True
Attribute VB_Exposed = False
'
' frmSimplyVBUnit2Runner V2.1
'
' ** NOTE **
' Please set <Tools\Options\General\Error Trapping> to <Break on Unhandled Errors>
'
Option Explicit

' Namespaces Available:
'       Assert.*            ie. Call Assert.AreEqual Expected, Actual
'
' Public Functions Availabe:
'       AddTest '<TestObject>
'       AddListener <ITestListener Object>
'       AddFilter <ITestFilter Object>
'       RemoveFilter <ITestFilter Object>
'       WriteLine "Message"
'
' Adding a testcase:
'   Use AddTest <object>
'
' Steps to create a TestCase:
'
'   1. Add a new class
'   2. Name it as desired
'   3. (Optionally) Add a Setup/Teardown method to be run before and after every test.
'   4. (Optionally) Add a TestFixtureSetup/TestFixtureTeardown method to be run at the
'      before the first test and after the last test.
'   5. Add public Subs of the tests you want run. No parameters.
'
'      Public Sub MyTest()
'          Call Assert.AreEqual a, b
'      End Sub
'
Private Sub Form_Load()
    ' Add tests here
    '
    ' AddTest '<TestObject>
    AddTest New OrderedListTests, "OrderedListTests"
    AddTest New IniWriterTests, "IniWriterTests"
    AddTest New IniReaderTests, "IniReaderTests"
    AddTest New IniDocumentTests, "IniDocumentTests"
    AddTest New AliasTextTests, "AliasTextTests"
    AddTest New ArgvCSTests, "ArgvConfigSourceTests"
    AddTest New ConfigBaseTests, "ConfigBaseTests"
    AddTest New ConfigCollTests, "ConfigCollectionTests"
    AddTest New ConfigSBTests, "ConfigSourceBaseTests"
    AddTest New IniConfigSTests, "IniConfigSourceTests"
    AddTest New RegistryCSTests, "RegistryConfigSourceTests"
    AddTest New XmlConfigSTests, "XmlConfigSourceTests"
    AddTest New DotNetConfigSTests, "DotNetConfigSourceTests"
End Sub



Private Sub Form_Initialize()
    Caption = "SimplyVBUnit V2 - " & App.Title
    Call Me.SimplyVBUnitCtl1.Init(App.EXEName)
End Sub
Private Sub Form_KeyDown(KeyCode As Integer, Shift As Integer)
    If KeyCode = vbKeyEscape Then Unload Me
End Sub


