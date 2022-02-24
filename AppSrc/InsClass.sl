// InsClass.sl
// InsClass Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cInsClassGlblDataDictionary.dd

CD_Popup_Object InsClass_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 218
    Set Label To "InsClass Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oInsClass_DD is a cInsClassGlblDataDictionary
    End_Object // oInsClass_DD

    Set Main_DD To oInsClass_DD
    Set Server  To oInsClass_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 208
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "InsClass_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oInsClass_ClassCode is a cDbCJGridColumn
            Entry_Item InsClass.ClassCode
            Set piWidth to 84
            Set psCaption to "Code"
        End_Object // oInsClass_ClassCode

        Object oInsClass_ClassDescription is a cDbCJGridColumn
            Entry_Item InsClass.ClassDescription
            Set piWidth to 262
            Set psCaption to "Classification"
        End_Object // oInsClass_ClassDescription


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 55
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 109
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 163
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // InsClass_sl
