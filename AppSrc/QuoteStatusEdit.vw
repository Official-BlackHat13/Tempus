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

Deferred_View Activate_oQuoteStatusEdit for ;
Object oQuoteStatusEdit is a dbView
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
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oContact_DD
        Set DDO_Server to oLocation_DD
        Set Constrain_File to SalesRep.File_Number
  
     Procedure OnConstrain
        Constrain QuoteHdr.Status ne "L"
        Constrain QuoteHdr.Status ne "W"
     End_Procedure

    End_Object

    Set Main_DD to oQuotehdr_DD
    Set Server to oQuotehdr_DD

    Set Border_Style to Border_Thick
    Set Size to 370 687
    Set Location to 2 2
    Set Label to "Quote Status Edit"

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 281 622
        Set Location to 62 32

        Object oQuotehdr_QuotehdrID is a cDbCJGridColumn
            Entry_Item Quotehdr.QuotehdrID
            Set piWidth to 62
            Set psCaption to "Quote #"
            Set pbEditable to False
            Set peHeaderAlignment to xtpAlignmentCenter
        End_Object

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 237
            Set psCaption to "Customer"
            Set pbEditable to False
            Set peHeaderAlignment to xtpAlignmentCenter
        End_Object

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 279
            Set psCaption to "Location"
            Set pbEditable to False
            Set peHeaderAlignment to xtpAlignmentCenter
        End_Object

        Object oQuotehdr_QuoteDate is a cDbCJGridColumn
            Entry_Item Quotehdr.QuoteDate
            Set piWidth to 139
            Set psCaption to "Quote Date"
            Set pbEditable to False
            Set peHeaderAlignment to xtpAlignmentCenter
            Set peTextAlignment to xtpAlignmentRight
        End_Object

        Object oQuotehdr_Amount is a cDbCJGridColumn
            Entry_Item Quotehdr.Amount
            Set piWidth to 118
            Set psCaption to "Amount"
            Set piDisabledTextColor to clBlack
            Set pbEditable to False
            Set peHeaderAlignment to xtpAlignmentCenter
        End_Object

        Object oQuotehdr_Status is a cDbCJGridColumn
            Entry_Item Quotehdr.Status
            Set piWidth to 98
            Set psCaption to "Status"
            Set pbComboButton to True
            Set peHeaderAlignment to xtpAlignmentCenter
        End_Object
    End_Object

    Object oQuotehdr_RepIdno is a cGlblDbForm
        Entry_Item SalesRep.RepIdno
        Set Location to 28 98
        Set Size to 13 54
        Set Label to "Sales Rep:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSalesRep_LastName is a cGlblDbForm
        Entry_Item SalesRep.LastName
        Set Location to 28 158
        Set Size to 13 93
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

Cd_End_Object
