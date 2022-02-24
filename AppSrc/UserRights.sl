// UserRights.sl
// UserRights Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cUserRightsGlblDataDictionary.dd

CD_Popup_Object UserRights_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 218
    Set Label To "UserRights Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oUserRights_DD is a cUserRightsGlblDataDictionary
    End_Object 

    Set Main_DD To oUserRights_DD
    Set Server  To oUserRights_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 208
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "UserRights_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oUserRights_Discription is a cDbCJGridColumn
            Entry_Item UserRights.Discription
            Set piWidth to 262
            Set psCaption to "Discription"
        End_Object 

        Object oUserRights_EditLevel is a cDbCJGridColumn
            Entry_Item UserRights.EditLevel
            Set piWidth to 84
            Set psCaption to "EditLevel"
        End_Object 


    End_Object 

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 55
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object 

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 109
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object 

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 163
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object 

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // UserRights_sl
