// Sht_Hdr.sl
// Sht_Hdr Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use cProjectDataDictionary.dd
Use Order.DD
Use Invhdr.DD
Use cSht_HdrGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd

CD_Popup_Object Sht_Hdr_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 416
    Set Label to "Snow Sheet Lookup List"
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

    Object oProject_DD is a cProjectDataDictionary
    End_Object // oProject_DD

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oProject_DD
        Set DDO_Server To oSalesRep_DD
    End_Object // oOrder_DD

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server To oOrder_DD
    End_Object // oInvhdr_DD

    Object oSht_Hdr_DD is a cSht_HdrGlblDataDictionary
        Set DDO_Server To oInvhdr_DD
    End_Object // oSht_Hdr_DD

    Set Main_DD To oSht_Hdr_DD
    Set Server  To oSht_Hdr_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 406
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Sht_Hdr_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oSht_Hdr_Sht_Hdr_ID is a cDbCJGridColumn
            Entry_Item Sht_Hdr.Sht_Hdr_ID
            Set piWidth to 70
            Set psCaption to "Snow Sheet ID"
        End_Object // oSht_Hdr_Sht_Hdr_ID

        Object oInvhdr_InvoiceIdno is a cDbCJGridColumn
            Entry_Item Invhdr.InvoiceIdno
            Set piWidth to 70
            Set psCaption to "Tempus Inv. ID"
        End_Object // oInvhdr_InvoiceIdno

        Object oSht_Hdr_QB_Invoice_ID is a cDbCJGridColumn
            Entry_Item Sht_Hdr.QB_Invoice_ID
            Set piWidth to 70
            Set psCaption to "QBooks Inv. ID"
        End_Object

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 150
            Set psCaption to "Customer"
        End_Object // oCustomer_Name

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 150
            Set psCaption to "Location"
        End_Object // oLocation_Name


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 253
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 307
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 361
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Sht_Hdr_sl
