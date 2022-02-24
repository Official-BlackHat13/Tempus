// Invhdr.sl
// Invhdr Lookup List

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
Use cSalesTaxGroupGlblDataDictionary.dd

CD_Popup_Object Invhdr_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 551
    Set Label To "Invhdr Lookup List"
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

    Set Main_DD To oInvhdr_DD
    Set Server  To oInvhdr_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 541
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Invhdr_sl_oSelList"
        Set pbAutoServer to True
        
        Object oInvhdr_QBInvoiceNumber is a cDbCJGridColumn
            Entry_Item Invhdr.QBInvoiceNumber
            Set piWidth to 105
            Set psCaption to "QuickBooks Inv. #"
        End_Object // oInvhdr_QBInvoiceNumber
        
        Object oInvhdr_InvoiceIdno is a cDbCJGridColumn
            Entry_Item Invhdr.InvoiceIdno
            Set piWidth to 85
            Set psCaption to "Tempus Inv. #"
        End_Object // oInvhdr_InvoiceIdno



        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 187
            Set psCaption to "Customer"
        End_Object // oCustomer_Name

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 188
            Set psCaption to "Location"
        End_Object // oLocation_Name

        Object oSalesRep_LastName is a cDbCJGridColumn
            Entry_Item SalesRep.LastName
            Set piWidth to 88
            Set psCaption to "Sales Rep"
        End_Object // oSalesRep_LastName

        Object oOrder_Title is a cDbCJGridColumn
            Entry_Item Order.Title
            Set piWidth to 293
            Set psCaption to "Title"
        End_Object // oOrder_Title


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 388
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 442
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 496
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Invhdr_sl
