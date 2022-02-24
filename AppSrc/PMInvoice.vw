Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use cSnowrepDataDictionary.dd
Use Contact.DD
Use cQuotehdrDataDictionary.dd
Use MastOps.DD
Use cQuotedtlDataDictionary.dd
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg

Deferred_View Activate_oPMInvoice for ;
Object oPMInvoice is a dbView
    Object oMastOps_DD is a Mastops_DataDictionary
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
          Set Constrain_File to Customer.File_Number
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set Constrain_File to Customer.File_Number
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oQuotehdr_DD is a cQuotehdrDataDictionary   
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oContact_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oQuotedtl_DD is a cQuotedtlDataDictionary
        Send DefineAllExtendedFields
        Set Constrain_File to Quotehdr.File_Number
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oQuotehdr_DD
    End_Object

    Set Main_DD to oQuotedtl_DD
    Set Server to oQuotedtl_DD

    Set Border_Style to Border_Thick
    Set Size to 438 565
    Set Location to 2 73

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 236 500
        Set Location to 129 30

        Object oMastOps_MastOpsIdno is a cDbCJGridColumn
            Entry_Item MastOps.MastOpsIdno
            Set piWidth to 74
            Set psCaption to "MastOpsIdno"
             
             Procedure Prompt
                Integer iCol iRecId
                Get Current_Record of oMastops_DD to iRecId
                Forward Send Prompt
               
            If (Current_Record(oMastops_DD) <> iRecId) Begin
                Set Field_Changed_Value of oQuotedtl_DD Field Quotedtl.Price       to MastOps.SellRate
                Set Field_Changed_Value of oQuotedtl_DD Field Quotedtl.Description to MastOps.Description
                End
             End_Procedure
             
        End_Object

        Object oQuotedtl_Description is a cDbCJGridColumn
             Entry_Item Quotedtl.Description
            Set piWidth to 416
            Set psCaption to "Description"
            Set pbMultiLine to True
            Set piMaximumWidth to 400
        End_Object

        Object oQuotedtl_Quantity is a cDbCJGridColumn
            Entry_Item Quotedtl.Quantity
            Set piWidth to 83
            Set psCaption to "Quantity"
        End_Object

        Object oQuotedtl_Price is a cDbCJGridColumn
            Entry_Item Quotedtl.Price
            Set piWidth to 93
            Set psCaption to "Price"
        End_Object

        Object oQuotedtl_Amount is a cDbCJGridColumn
            Entry_Item Quotedtl.Amount
            Set piWidth to 84
            Set psCaption to "Amount"
        End_Object
    End_Object

    Object oCustomer_Name is a cGlblDbForm
        Entry_Item Customer.Name
        Set Location to 22 143
        Set Size to 13 169
        Set Label to "Customer"
        Set Prompt_Button_Mode to PB_PromptOn
        Set Label_Col_Offset to 0
        Set Label_Justification_Mode to JMode_Top
    End_Object

    Object oQuotehdr_Amount is a cGlblDbForm
        Entry_Item Quotehdr.Amount
        Set Location to 369 465
        Set Size to 13 66
        Set Label to "Invoice Total:"
        Set Label_Col_Offset to 5
        Set Label_FontWeight to 600
        Set Label_Justification_Mode to JMode_Right
        Set Label_FontUnderLine to True
    End_Object

    Object oLocation_Name is a cGlblDbForm
        Entry_Item Location.Name
        Set Location to 38 143
        Set Size to 13 169
        Set Label to "Location:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOn
    End_Object

    Object oContact_LastName is a cGlblDbForm
        Entry_Item Contact.LastName
        Set Location to 53 143
        Set Size to 13 169
        Set Label to "Contact:"
        Set Prompt_Button_Mode to PB_PromptOn
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSalesRep_LastName is a cGlblDbForm
        Entry_Item SalesRep.LastName
        Set Location to 22 359
        Set Size to 13 103
        Set Label to "Rep::"
        Set Prompt_Button_Mode to PB_PromptOff
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuotehdr_QuotehdrID is a cGlblDbForm
        Entry_Item Quotehdr.QuotehdrID
        Set Location to 22 79
        Set Size to 13 54
        Set Label to "QuotehdrID:"
    End_Object

Cd_End_Object
