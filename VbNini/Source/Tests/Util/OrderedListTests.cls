VERSION 1.0 CLASS
BEGIN
  MultiUse = -1  'True
  Persistable = 0  'NotPersistable
  DataBindingBehavior = 0  'vbNone
  DataSourceBehavior  = 0  'vbNone
  MTSTransactionMode  = 0  'NotAnMTSObject
END
Attribute VB_Name = "OrderedListTests"
Attribute VB_GlobalNameSpace = False
Attribute VB_Creatable = True
Attribute VB_PredeclaredId = False
Attribute VB_Exposed = False
Option Explicit

Public Sub BasicOrder()
    Dim list As OrderedList
    Set list = NewOrderedList()

    Call list.Add("One", 1)
    Call list.Add("Two", 2)
    Call list.Add("Three", 3)

    Call Assert.AreEqual(1, list(0))
    Call Assert.AreEqual(2, list(1))
    Call Assert.AreEqual(3, list(2))

    Call Assert.AreEqual(1, list("One"))
    Call Assert.AreEqual(2, list("Two"))
    Call Assert.AreEqual(3, list("Three"))
End Sub
