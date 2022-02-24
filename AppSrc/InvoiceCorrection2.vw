Use Windows.pkg
Use DFClient.pkg
Use dfTable.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use Invhdr.DD
Use MastOps.DD
Use Opers.DD

Use Invdtl.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use cDbTextEdit.pkg

Deferred_View Activate_oInvoiceCorrection2 for ;
Object oInvoiceCorrection2 is a dbView
    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
    End_Object

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
         Set Constrain_File to Location.File_Number
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server to oOrder_DD
    End_Object

    Object oInvdtl_DD is a Invdtl_DataDictionary
        Set Constrain_File to Invhdr.File_Number
        Set DDO_Server to oOpers_DD
        Set DDO_Server to oInvhdr_DD
    End_Object

    Set Main_DD to oInvdtl_DD
    Set Server to oInvdtl_DD

    Set Border_Style to Border_Thick
    Set Size to 387 484
    Set Location to 4 25

    Object oInvhdr_InvoiceIdno is a cGlblDbForm
        Entry_Item Invhdr.InvoiceIdno
        Set Location to 11 53
        Set Size to 13 54
        Set Label to "InvoiceIdno:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oCustomer_Name is a cGlblDbForm
        Entry_Item Customer.Name
        Set Location to 27 53
        Set Size to 13 165
        Set Label to "Customer:"
        Set Prompt_Button_Mode to PB_PromptOff
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oLocation_Name is a cGlblDbForm
        Entry_Item Location.Name
        Set Location to 43 53
        Set Size to 13 165
        Set Label to "Location:"
        Set Prompt_Button_Mode to PB_PromptOff
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oInvdtl_Description is a cDbTextEdit
        Entry_Item Invdtl.Description
        Set Location to 273 11
        Set Size to 43 349
        Set Label to "Invoice Description:"
    End_Object

    Object oTextBox1 is a TextBox
        Set Size to 10 31
        Set Location to 12 118
        Set Label to 'Find = F9'
    End_Object

    Object oOpers_Description is a cDbTextEdit
        Entry_Item Opers.Description
        Set Location to 330 12
        Set Size to 52 348
        Set Label to "Opers Description:"
    End_Object
    
    Object oButton1 is a Button
        Set Size to 14 56
        Set Location to 300 383
        Set Label to 'Print Invoice'
        //Set peAnchors to anAll
    
        // fires when the button is clicked
        Procedure OnClick
             Send DoPrintInvoice
        End_Procedure
    
    End_Object

    Object oDbGrid1 is a dbGrid
        Set Size to 196 438
        Set Location to 60 8

        Begin_Row
            Entry_Item Invdtl.Sequence
            Entry_Item Opers.OpersIdno
            Entry_Item Opers.Name
            Entry_Item Invdtl.Quantity
            Entry_Item Invdtl.Price
            Entry_Item Invdtl.Total
        End_Row

        Set Main_File to Invdtl.File_Number

        Set Form_Width 0 to 33
        Set Header_Label 0 to "Seq"
        
        Set Form_Width 1 to 55
        Set Header_Label 1 to "Op ID"
        
        Set Form_Width 2 to 203
        Set Header_Label 2 to "Operation"
        
        Set Form_Width 3 to 48 
        Set Header_Label 3 to "Qty/Hrs"
        
        Set Form_Width 4 to 48
        Set Header_Label 4 to "Price"
       
        Set Form_Width 5 to 48
        Set Header_Label 5 to "Total"
      
        
    End_Object

    Object oInvhdr_TotalAmount is a cGlblDbForm
        Entry_Item Invhdr.TotalAmount
        Set Location to 271 385
        Set Size to 13 54
        Set Label to "Total:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Enabled_State to False
        Set Entry_State to False
    End_Object

Procedure DoPrintInvoice
        #IFDEF TEMPUS_LINK
        #ELSE
        Boolean bCancel
        Integer iInvId
        //
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno to iInvId
        Get Confirm ("Print invoice" * String(iInvId) + "?")           to bCancel
        If (not(bCancel)) Begin
            Send DoJumpStartReport of oCustomerInvoice iInvId
//            Send DoClearInvoice
        End
        #ENDIF
    End_Procedure
Cd_End_Object
