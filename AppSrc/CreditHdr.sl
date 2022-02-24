// CreditHdr.sl
// CreditHdr Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use Invhdr.DD
Use cCreditHdrGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd

CD_Popup_Object CreditHdr_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 196 498
    Set Label To "CreditHdr Lookup List"
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

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server To oOrder_DD
    End_Object // oInvhdr_DD

    Object oCreditHdr_DD is a cCreditHdrGlblDataDictionary
        Set DDO_Server To oInvhdr_DD
    End_Object // oCreditHdr_DD

    Set Main_DD To oCreditHdr_DD
    Set Server  To oCreditHdr_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 167 488
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "CreditHdr_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oCreditHdr_CreditIdno is a cDbCJGridColumn
            Entry_Item CreditHdr.CreditIdno
            Set piWidth to 73
            Set psCaption to "Credit #"
        End_Object // oCreditHdr_CreditIdno

        Object oCreditHdr_CreditDate is a cDbCJGridColumn
            Entry_Item CreditHdr.CreditDate
            Set piWidth to 91
            Set psCaption to "Date"
        End_Object // oCreditHdr_CreditDate

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 197
            Set psCaption to "Customer"
        End_Object // oCustomer_Name

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 225
            Set psCaption to "Location"
        End_Object // oLocation_Name

        Object oOrder_Title is a cDbCJGridColumn
            Entry_Item Order.Title
            Set piWidth to 268
            Set psCaption to "Order"
        End_Object // oOrder_Title


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 177 335
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 177 389
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 177 443
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // CreditHdr_sl
