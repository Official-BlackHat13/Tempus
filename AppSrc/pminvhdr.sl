// pminvhdr.sl
// pminvhdr Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use pminvhdr.dd
Use cSalesTaxGroupGlblDataDictionary.dd

CD_Popup_Object pminvhdr_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 610
    Set Label To "pminvhdr Lookup List"
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

    Object opminvhdr_DD is a pminvhdr_DataDictionary
        Set DDO_Server To oOrder_DD
    End_Object // opminvhdr_DD

    Set Main_DD To opminvhdr_DD
    Set Server  To opminvhdr_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 600
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "pminvhdr_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object opminvhdr_InvoiceNumber is a cDbCJGridColumn
            Entry_Item pminvhdr.InvoiceNumber
            Set piWidth to 72
            Set psCaption to "Invoice #"
        End_Object // opminvhdr_InvoiceNumber

        Object opminvhdr_QuoteHdrID is a cDbCJGridColumn
            Entry_Item pminvhdr.QuoteHdrID
            Set piWidth to 72
            Set psCaption to "Quote #"
        End_Object // opminvhdr_QuoteHdrID

        Object oOrder_JobNumber is a cDbCJGridColumn
            Entry_Item Order.JobNumber
            Set piWidth to 72
            Set psCaption to "Job #"
        End_Object // oOrder_JobNumber

        Object oOrder_Title is a cDbCJGridColumn
            Entry_Item Order.Title
            Set piWidth to 225
            Set psCaption to "Job Title"
        End_Object // oOrder_Title

        Object opminvhdr_CustomerIdno is a cDbCJGridColumn
            Entry_Item pminvhdr.CustomerIdno
            Set piWidth to 72
            Set psCaption to "Cust. #"
        End_Object // opminvhdr_CustomerIdno

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 225
            Set psCaption to "Customer Name"
        End_Object // oCustomer_Name

        Object opminvhdr_LocationIdno is a cDbCJGridColumn
            Entry_Item pminvhdr.LocationIdno
            Set piWidth to 72
            Set psCaption to "Location #"
        End_Object // opminvhdr_LocationIdno

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 225
            Set psCaption to "Location Name"
        End_Object // oLocation_Name

        Object opminvhdr_SlsRepIdno is a cDbCJGridColumn
            Entry_Item pminvhdr.SlsRepIdno
            Set piWidth to 72
            Set psCaption to "Rep.#"
        End_Object // opminvhdr_SlsRepIdno

        Object oSalesRep_LastName is a cDbCJGridColumn
            Entry_Item SalesRep.LastName
            Set piWidth to 225
            Set psCaption to "Rep. Name"
        End_Object // oSalesRep_LastName

        Object opminvhdr_InvoiceDate is a cDbCJGridColumn
            Entry_Item pminvhdr.InvoiceDate
            Set piWidth to 90
            Set psCaption to "Inv. Date"
        End_Object // opminvhdr_InvoiceDate

        Object opminvhdr_Amount is a cDbCJGridColumn
            Entry_Item pminvhdr.Amount
            Set piWidth to 99
            Set psCaption to "Inv. Amt."
        End_Object // opminvhdr_Amount


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 447
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 501
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 555
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // pminvhdr_sl
