// SalesTaxGroup.sl
// SalesTaxGroup Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cSalesTaxGroupGlblDataDictionary.dd

CD_Popup_Object SalesTaxGroup_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 261
    Set Label To "SalesTaxGroup Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object // oSalesTaxGroup_DD

    Set Main_DD To oSalesTaxGroup_DD
    Set Server  To oSalesTaxGroup_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 251
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "SalesTaxGroup_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oSalesTaxGroup_SalesTaxIdno is a cDbCJGridColumn
            Entry_Item SalesTaxGroup.SalesTaxIdno
            Set piWidth to 85
            Set psCaption to "SalesTaxIdno"
        End_Object // oSalesTaxGroup_SalesTaxIdno

        Object oSalesTaxGroup_Name is a cDbCJGridColumn
            Entry_Item SalesTaxGroup.Name
            Set piWidth to 262
            Set psCaption to "Name"
        End_Object // oSalesTaxGroup_Name

        Object oSalesTaxGroup_Rate is a cDbCJGridColumn
            Entry_Item SalesTaxGroup.Rate
            Set piWidth to 73
            Set psCaption to "Rate"
        End_Object // oSalesTaxGroup_Rate


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 98
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 152
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 206
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // SalesTaxGroup_sl
