// DivisionMgr.sl
// DivisionMgr Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cDivisionMgrGlblDataDictionary.dd

CD_Popup_Object DivisionMgr_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 610
    Set Label To "DivisionMgr Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object 

    Set Main_DD To oDivisionMgr_DD
    Set Server  To oDivisionMgr_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 600
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "DivisionMgr_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oDivisionMgr_DivMgrIdno is a cDbCJGridColumn
            Entry_Item DivisionMgr.DivMgrIdno
            Set piWidth to 72
            Set psCaption to "Idno"
        End_Object

        Object oDivisionMgr_FirstName is a cDbCJGridColumn
            Entry_Item DivisionMgr.FirstName
            Set piWidth to 250
            Set psCaption to "First Name"
        End_Object 

        Object oDivisionMgr_LastName is a cDbCJGridColumn
            Entry_Item DivisionMgr.LastName
            Set piWidth to 250
            Set psCaption to "Last Name"
        End_Object 

        Object oDivisionMgr_Email is a cDbCJGridColumn
            Entry_Item DivisionMgr.Email
            Set piWidth to 250
            Set psCaption to "Email Address"
        End_Object 

        Object oDivisionMgr_CellPhone is a cDbCJGridColumn
            Entry_Item DivisionMgr.CellPhone
            Set piWidth to 250
            Set psCaption to "Cell Phone"
        End_Object 

        Object oDivisionMgr_Status is a cDbCJGridColumn
            Entry_Item DivisionMgr.Status
            Set piWidth to 48
            Set psCaption to "Status"
        End_Object 


    End_Object 

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 447
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object 

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 501
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object 

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 555
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object 

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // DivisionMgr_sl
