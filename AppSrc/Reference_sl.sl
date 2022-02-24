// Reference_sl.sl
// Referenc Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cReferencGlblDataDictionary.dd
Use dfcentry.pkg

CD_Popup_Object Referenc_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 377
    Set Label To "Referenc Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oReferenc_DD is a cReferencGlblDataDictionary
    End_Object // oReferenc_DD

    Set Main_DD To oReferenc_DD
    Set Server  To oReferenc_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 367
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Referenc_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oReferenc_ReferenceIdno is a cDbCJGridColumn
            Entry_Item Referenc.ReferenceIdno
            Set piWidth to 51
            Set psCaption to "Idno"
        End_Object // oReferenc_ReferenceIdno

        Object oReferenc_Company is a cDbCJGridColumn
            Entry_Item Referenc.Company
            Set piWidth to 248
            Set psCaption to "Company"
        End_Object // oReferenc_Company

        Object oReferenc_Name is a cDbCJGridColumn
            Entry_Item Referenc.Name
            Set piWidth to 251
            Set psCaption to "Name"
        End_Object // oReferenc_Name


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 214
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 268
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 322
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Referenc_sl
