// ProdNote.sl
// ProdNote Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use cProdNoteGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use dfSelLst.pkg

CD_Popup_Object ProdNote_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 400
    Set Label To "ProdNote Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD is a Areas_DataDictionary
    End_Object // oAreas_DD

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
    End_Object // oLocation_DD

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object // oSalesRep_DD

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oSalesRep_DD
    End_Object // oOrder_DD

    Object oProdNote_DD is a cProdNoteGlblDataDictionary
        Set DDO_Server To oOrder_DD
        Set DDO_Server To oSalesRep_DD
    End_Object // oProdNote_DD

    Set Main_DD To oProdNote_DD
    Set Server  To oProdNote_DD

    Object oSelList is a dbList
        Set Size to 100 385
        Set Location to 5 7

        Begin_Row
            Entry_Item ProdNote.ProdNoteIdno
            Entry_Item Order.JobNumber
            Entry_Item ProdNote.CreatedBy
            Entry_Item ProdNote.CreatedDate
            Entry_Item ProdNote.Note
        End_Row

        Set Main_File to ProdNote.File_Number

        Set Form_Width 0 to 48
        Set Header_Label 0 to "ProdNoteIdno"
        Set Form_Width 1 to 48
        Set Header_Label 1 to "JobNumber"
        Set Form_Width 2 to 40
        Set Header_Label 2 to "CreatedBy"
        Set Form_Width 3 to 60
        Set Header_Label 3 to "CreatedDate"
        Set Form_Width 4 to 184
        Set Header_Label 4 to "Note"
    End_Object
    
    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 237
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 291
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 345
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // ProdNote_sl
