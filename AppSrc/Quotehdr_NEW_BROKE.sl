// Quotehdr.sl
// Quotehdr Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use SalesRep.DD
Use Contact.DD
Use cQuotehdrDataDictionary.dd

Object Quotehdr_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 610
    Set Label To "Quotehdr Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object 

    Object oAreas_DD is a Areas_DataDictionary
    End_Object 

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object 

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
        Set DDO_Server To oSalesTaxGroup_DD
    End_Object 

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object 

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server To oCustomer_DD
    End_Object 

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oContact_DD
        Set DDO_Server To oSalesRep_DD
    End_Object 

    Set Main_DD To oQuotehdr_DD
    Set Server  To oQuotehdr_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 600
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Quotehdr_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oQuotehdr_QuotehdrID is a cDbCJGridColumn
            Entry_Item Quotehdr.QuotehdrID
            Set piWidth to 105
            Set psCaption to "Quote#"
        End_Object 

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 262
            Set psCaption to "Cutomer"
        End_Object 

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 262
            Set psCaption to "Location"
        End_Object 

        Object oQuotehdr_QuoteLostMemo is a cDbCJGridColumn
            Entry_Item Quotehdr.QuoteLostMemo
            Set piWidth to 262
            Set psCaption to "Titel"
        End_Object 

        Object oContact_LastName is a cDbCJGridColumn
            Entry_Item Contact.LastName
            Set piWidth to 262
            Set psCaption to "Contact"
        End_Object 

        Object oSalesRep_LastName is a cDbCJGridColumn
            Entry_Item SalesRep.LastName
            Set piWidth to 262
            Set psCaption to "Sales Rep"
        End_Object 

        Object oQuotehdr_Amount is a cDbCJGridColumn
            Entry_Item Quotehdr.Amount
            Set piWidth to 136
            Set psCaption to "Total"
        End_Object 


    End_Object 

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 447
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object 

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 501
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object 

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 555
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object 

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


End_Object // Quotehdr_sl
