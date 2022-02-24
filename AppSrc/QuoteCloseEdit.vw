Use Windows.pkg
Use DFClient.pkg
Use cDbCJGrid.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use cSnowrepDataDictionary.dd
Use Contact.DD
Use cQuotehdrDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use szcalendar.pkg
Deferred_View Activate_oQuoteCloseEdit for ;
Object oQuoteCloseEdit is a dbView
    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set Constrain_File to SalesRep.File_Number
        Procedure OnConstrain
              Constrain QuoteHdr.Status eq "P"
        End_Procedure
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oContact_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Set Main_DD to oQuotehdr_DD
    Set Server to oQuotehdr_DD

    Set Border_Style to Border_Thick
    Set Size to 351 550
    Set Location to 30 44

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 285 515
        Set Location to 49 19

        Object oQuotehdr_QuotehdrID is a cDbCJGridColumn
            Entry_Item Quotehdr.QuotehdrID
            Set piWidth to 50
            Set psCaption to "Quote ID"
        End_Object

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 192
            Set psCaption to "Customer"
        End_Object

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 207
            Set psCaption to "Location"
        End_Object

        Object oQuotehdr_QuoteDate is a cDbCJGridColumn
            Entry_Item Quotehdr.QuoteDate
            Set piWidth to 83
            Set psCaption to "Quote Date"
        End_Object

        Object oQuotehdr_Status is a cDbCJGridColumn
            Entry_Item Quotehdr.Status
            Set piWidth to 53
            Set psCaption to "Status"
            Set pbComboButton to True
        End_Object

        Object oQuotehdr_Probability is a cDbCJGridColumn
            Entry_Item Quotehdr.Probability
            Set piWidth to 54
            Set psCaption to "Probability"
            Set pbComboButton to True
        End_Object

        Object oQuotehdr_CloseDate is a cDbCJGridColumn
            Entry_Item Quotehdr.CloseDate
            Set piWidth to 70
            Set psCaption to "Close Date"
        End_Object

        Object oQuotehdr_Amount is a cDbCJGridColumn
            Entry_Item Quotehdr.Amount
            Set piWidth to 63
            Set psCaption to "Amount"
        End_Object
    End_Object

    Object oSalesRep_LastName is a cGlblDbForm
        Entry_Item SalesRep.LastName
        Set Location to 16 76
        Set Size to 13 109
        Set Label to "Sales Rep:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

Cd_End_Object
