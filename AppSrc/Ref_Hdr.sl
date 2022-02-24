// Ref_Hdr.sl
// Ref_Hdr Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cRef_HdrGlblDataDictionary.dd

CD_Popup_Object Ref_Hdr_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 236
    Set Label To "Reference List Lookup"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oRef_Hdr_DD is a cRef_HdrGlblDataDictionary
    End_Object // oRef_Hdr_DD

    Set Main_DD To oRef_Hdr_DD
    Set Server  To oRef_Hdr_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 226
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Ref_Hdr_sl_oSelList"
        Set Ordering to 2                                  ///Index 2??
        Set pbAutoServer to True

        Object oRef_Hdr_Description is a cDbCJGridColumn
            Entry_Item Ref_Hdr.Description
            Set piWidth to 234
            Set psCaption to "Description"
        End_Object // oRef_Hdr_Description

Object oRef_Hdr_Sales_Rep is a cDbCJGridColumn
            Entry_Item Ref_Hdr.SalesRep
            Set piWidth to 105
            Set psCaption to "Sales Rep"
        End_Object // oRef_Hdr_Description

    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 73
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 127
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 181
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Ref_Hdr_sl
