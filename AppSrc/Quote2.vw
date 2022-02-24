Use Windows.pkg
Use DFClient.pkg
Use cGlblDbForm.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use cSnowrepDataDictionary.dd
Use Contact.DD
Use cQuotehdrDataDictionary.dd
Use MastOps.DD
Use cQuotedtlDataDictionary.dd
Use cCJGrid.pkg
Use cDbCJGrid.pkg
Use cDbTextEdit.pkg
Use PM_Invoice.rv

Deferred_View Activate_oQuote2 for ;
Object oQuote2 is a dbView
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
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oCustomer_DD
        Set Constrain_File to Customer.File_Number
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set Constrain_File to Contact.File_Number
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD    
    End_Object

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oContact_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oQuotedtl_DD is a cQuotedtlDataDictionary
        Set Constrain_file to Quotehdr.File_number
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oQuotehdr_DD
        Send DefineAllExtendedFields
    End_Object

    Set Main_DD to oQuotehdr_DD
    Set Server to oQuotehdr_DD

    Set Border_Style to Border_Thick
    Set Label to "Job Plan/Invoice"
    Set Size to 500 559
    Set Location to -1 47

    Object oQuotehdr_QuotehdrID is a cGlblDbForm
        Entry_Item Quotehdr.QuotehdrID
        Set Location to 32 98
        Set Size to 13 54
        Set Label to "QuotehdrID:"
        
        Procedure Refresh Integer iMode
            Boolean bQuoteExists bQuoteIsJob
            Move (Quotehdr.JobNumber >0) to bQuoteIsJob
            Move (Quotehdr.Recnum >0) to bQuoteExists
            //
            Forward Send Refresh iMode
            //
//            Set Enabled_State of oQuoteWizardButton to (not(bQuoteExists))
           // Set Enabled_State of oCloneButton to bQuoteExists
          //  Set Enabled_State of oCreateOrderButton to (bQuoteExists and not(bQuoteIsJob))
            Set Enabled_State of oCustomer_CustomerIdno to (not(bQuoteExists))
            Set Enabled_State of oContact_ContactIdno to (not(bQuoteIsJob)) 
            Set Enabled_State of oLocation_LocationIdno to (not(bQuoteIsJob))
            Set Enabled_State of oSalesRep_RepIdno to (not(bQuoteIsJob))
            Set Enabled_State of oQuotehdr_JobNumber to (not(bQuoteIsJob))
            Set Enabled_State of oQuotehdr_OrderDate to (not(bQuoteIsJob))
            Set Enabled_State of oQuotehdr_QuoteDate to (not(bQuoteIsJob))
            // per Ben 8/22/12 keep editable Set Enabled_State of oQuotehdr_QuoteLostMemo to (not(bQuoteIsJob))
//            Set Enabled_State of oQuotehdr_WorkType to (not(bQuoteIsJob))
            Set Enabled_State of oQuotehdr_Status   to (Quotehdr.Status <> "W" and Quotehdr.Status <> "R")
            //Set Enabled_State of oViewOrderButton   to bQuoteIsJob
        End_Procedure
        
        
    End_Object

    Object oCustomer_CustomerIdno is a cGlblDbForm
        Entry_Item Customer.CustomerIdno
        Set Location to 49 98
        Set Size to 13 54
        Set Label to "CustomerIdno:"
    End_Object

    Object oContact_ContactIdno is a cGlblDbForm
        Entry_Item Contact.ContactIdno
        Set Location to 66 98
        Set Size to 13 54
        Set Label to "ContactIdno:"
    
       Procedure Prompt
            Boolean bSelected
            Handle  hoServer
            RowID   riContact riCustomer
            //
            Get Server                            to hoServer
            Move (GetRowID(Contact.File_Number )) to riContact
            Move (GetRowId(Customer.File_Number)) to riCustomer
            //
            Get IsSelectedContact of Contact_sl (&riContact) (&riCustomer) to bSelected
            //
            If  (bSelected and not(IsNullRowId(riContact))) Begin
                Send FindByRowId of hoServer Contact.File_Number riContact
            End
        End_Procedure
        
    End_Object

    Object oLocation_LocationIdno is a cGlblDbForm
        Entry_Item Location.LocationIdno
        Set Server to oLocation_DD
        Set Location to 84 98
        Set Size to 13 54
        Set Label to "LocationIdno:"
       
    Procedure Prompt_Callback Integer hPrompt
        Set Auto_Server_State of hPrompt to True
     End_Procedure
         
    End_Object 
  

    Object oQuotehdr_JobNumber is a cGlblDbForm
        Entry_Item Quotehdr.JobNumber
        Set Location to 32 158
        Set Size to 13 54
        Set Label to "Job Number"
        Set Label_Col_Offset to -6
        Set Label_Justification_Mode to JMode_Top
    End_Object

    Object oCustomer_Name is a cGlblDbForm
        Entry_Item Customer.Name

        Set Server to oContact_DD
        Set Location to 49 157
        Set Size to 13 189
        Set Label_Color to cl3DDkShadow
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

    Object oContact_LastName is a cGlblDbForm
        Entry_Item Contact.LastName

        Set Server to oContact_DD
        Set Location to 66 157
        Set Size to 13 96
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

    Object oContact_FirstName is a cGlblDbForm
        Entry_Item Contact.FirstName

        Set Server to oContact_DD
        Set Location to 66 258
        Set Size to 13 87
    End_Object

    Object oLocation_Name is a cGlblDbForm
        Entry_Item Location.Name

        Set Server to oLocation_DD
        Set Location to 84 157
        Set Size to 13 188
        Set Prompt_Button_Mode to PB_PromptOff
       
        Procedure Prompt_Callback Integer hPrompt
            Set Auto_Server_State of hPrompt to True
        End_Procedure
          
    End_Object

    Object oDbCJGrid1 is a cDbCJGrid
        Set Server to oQuotedtl_DD
        Set Size to 255 489
        Set Location to 144 35
        Set pbUseAlternateRowBackgroundColor to True
        Set pbUseEditTextAlignment to False
   
   

        Object oQuotedtl_MastOpsIdno is a cDbCJGridColumn
       
       Procedure Prompt
                Integer iCol iRecId
                Get Current_Record of oMastops_DD to iRecId
                Forward Send Prompt
               
            If (Current_Record(oMastops_DD) <> iRecId) Begin
                Set Field_Changed_Value of oQuotedtl_DD Field Quotedtl.Price       to MastOps.SellRate
                Set Field_Changed_Value of oQuotedtl_DD Field Quotedtl.Description to MastOps.Description
                End
        End_Procedure
            Entry_Item MastOps.MastOpsIdno
            Set piWidth to 77
            Set psCaption to "Mast Op ID"
        End_Object

        Object oQuotedtl_Description is a cDbCJGridColumn
            Entry_Item Quotedtl.Description
            Set piWidth to 400
            Set psCaption to "Description"
            Set pbMultiLine to True
        End_Object

        Object oQuotedtl_Quantity is a cDbCJGridColumn
            Entry_Item Quotedtl.Quantity
            Set piWidth to 117
            Set psCaption to "Quantity"
        End_Object

        Object oQuotedtl_Price is a cDbCJGridColumn
            Entry_Item Quotedtl.Price
            Set piWidth to 97
            Set psCaption to "Price"
        End_Object

        Object oQuotedtl_Amount is a cDbCJGridColumn
            Entry_Item Quotedtl.Amount
            Set piWidth to 118
            Set psCaption to "Amount"
        End_Object
    End_Object

    Object oQuotehdr_Amount is a cGlblDbForm
        Entry_Item Quotehdr.Amount
        Set Location to 407 453
        Set Size to 13 71
        Set Label to "Total Value:"
    End_Object
    
       Object oPrintButton is a Button
        Set Size to 14 54
        Set Location to 471 413
        Set Label to "Print Quote"
        
        Procedure OnClick
            Integer iQuote
            //
            Get Field_Current_Value of oQuotehdr_DD Field Quotehdr.QuotehdrID to iQuote
            If (iQuote <> 0) Begin
                Send DoJumpStartReport of oPrintQuotes iQuote
            End
        End_Procedure
    End_Object

    Object oQuotehdr_QuoteDate is a cdbszDatePicker
        Entry_Item Quotehdr.QuoteDate
        Set Location to 33 456
        Set Size to 13 66
        Set Label to "Quote Date:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuotehdr_CloseDate is a cdbszDatePicker
        Entry_Item Quotehdr.CloseDate
        Set Location to 49 456
        Set Size to 13 66
        Set Label to "CloseDate:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuotehdr_Probability is a dbComboForm
        Entry_Item Quotehdr.Probability
        Set Location to 66 456
        Set Size to 13 66
        Set Label to "Probability:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSalesRep_RepIdno is a cGlblDbForm
        Entry_Item SalesRep.RepIdno

        Set Server to oContact_DD
        Set Location to 101 98
        Set Size to 13 54
        Set Label to "Rep Idno:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSalesRep_LastName is a cGlblDbForm
        Entry_Item SalesRep.LastName

        Set Server to oContact_DD
        Set Location to 101 157
        Set Size to 13 97
        Set Prompt_Button_Mode to PB_PromptOff

    End_Object

    Object oQuotehdr_Status is a dbComboForm
        Entry_Item Quotehdr.Status
        Set Location to 83 456
        Set Size to 13 66
        Set Label to "Status:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuotehdr_OrderDate is a cGlblDbForm
        Entry_Item Quotehdr.OrderDate
        Set Location to 32 216
        Set Size to 13 66
        Set Label to "Order Date:"
        Set Label_Col_Offset to -11
        Set Label_Justification_Mode to JMode_Top
    End_Object

    

    Object oQuotedtl_Description1 is a cDbTextEdit
        Entry_Item Quotedtl.Description

        Set Server to oQuotedtl_DD
        Set Location to 411 79
        Set Size to 60 244
        Set Label to "Description:"
    End_Object
    
    Procedure DoViewQuote Integer iQuotehdrIdno
        Send Request_Clear_All
        If (iQuotehdrIdno) Begin
            Move iQuotehdrIdno to Quotehdr.QuotehdrID
            Send Find of oQuotehdr_DD EQ 1
        End
        Send Activate_View
    End_Procedure
Cd_End_Object
