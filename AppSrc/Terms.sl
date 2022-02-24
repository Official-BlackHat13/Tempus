// Terms.sl
// Terms Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cTermsGlblDataDictionary.dd

CD_Popup_Object Terms_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 170
    Set Label To "Terms Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oTerms_DD is a cTermsGlblDataDictionary
    End_Object // oTerms_DD

    Set Main_DD To oTerms_DD
    Set Server  To oTerms_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 160
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Terms_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oTerms_Value is a cDbCJGridColumn
            Entry_Item Terms.Value
            Set piWidth to 262
            Set psCaption to "Value"
        End_Object // oTerms_Value


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 7
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 61
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 115
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Terms_sl
