Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Contact.DD
Use cQuotehdrDataDictionary.dd
Use MastOps.DD
Use cQuotedtlDataDictionary.dd
Use cTempusDbView.pkg
Use cGlblDbForm.pkg

//Use QuoteWizard.dg
Use dfTable.pkg
Use cDbTextEdit.pkg

#IFDEF qtAll
#ELSE
Enum_List
    Define qtAll
    Define qtPavementMaintenance
    Define qtSnowRemoval
End_Enum_List
#ENDIF

Deferred_View Activate_oQuoteEntry for ;
Object oQuoteEntry is a cTempusDbView

    Property Integer peQuoteType qtPavementMaintenance

    Object oMastops_DD is a Mastops_DataDictionary
        Procedure OnConstrain
            If (peQuoteType(Self) = qtPavementMaintenance) Begin
                Constrain MastOps.ActivityType eq "Pavement Mnt."
            End
        End_Procedure
    End_Object

    Object oSalesrep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oContact_DD is a Contact_DataDictionary
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set DDO_Server to oContact_DD
        Set DDO_Server to oSalesrep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oQuotedtl_DD is a cQuotedtlDataDictionary
        Set DDO_Server to oMastops_DD
        Set DDO_Server to oQuotehdr_DD
        Set Constrain_file to Quotehdr.File_number
        Send DefineAllExtendedFields
    End_Object

    Set Main_DD to oQuotehdr_DD
    Set Server to oQuotehdr_DD

    Set Border_Style to Border_Thick
    Set Size to 270 470
    Set Location to 2 2
    Set Label to "Quote Entry"
    Set piMinSize to 270 470

    Object oQuotehdr_QuotehdrID is a cGlblDbForm
        Entry_Item Quotehdr.QuotehdrID
        Set Location to 10 51
        Set Size to 13 54
        Set Label to "Quote ID:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right

        Procedure Refresh Integer iMode
            Forward Send Refresh iMode
            //
            Set Enabled_State of oQuoteWizardButton to (Quotehdr.Recnum = 0)
        End_Procedure
    End_Object

    Object oQuotehdr_QuoteDate is a cdbszDatePicker // cGlblDbForm
        Entry_Item Quotehdr.QuoteDate
        Set Location to 10 224
        Set Size to 13 60
        Set Label to "Quote Date:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oCustomer_CustomerIdno is a cGlblDbForm
        Entry_Item Customer.CustomerIdno
        Set Location to 25 51
        Set Size to 13 54
        Set Label to "Customer:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oCustomer_Name is a cGlblDbForm
        Entry_Item Customer.Name
        Set Location to 25 109
        Set Size to 13 175
        Set Enabled_State to False
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

    Object oContact_ContactIdno is a cGlblDbForm
        Entry_Item Contact.ContactIdno
        Set Location to 40 51
        Set Size to 13 54
        Set Label to "Contact:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oContact_LastName is a cGlblDbForm
        Entry_Item Contact.LastName
        Set Location to 40 109
        Set Size to 13 90
        Set Prompt_Button_Mode to PB_PromptOff
        Set Enabled_State to False
    End_Object

    Object oContact_FirstName is a cGlblDbForm
        Entry_Item Contact.FirstName

        Set Server to oContact_DD
        Set Location to 40 203
        Set Size to 13 80
        Set Enabled_State to False
    End_Object

    Object oLocation_LocationNbr is a cGlblDbForm
        Entry_Item Location.LocationNbr
        Set Server to oLocation_DD
        Set Location to 55 51
        Set Size to 13 54
        Set Label to "Location:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oLocation_Name is a cGlblDbForm
        Entry_Item Location.Name
        Set Server to oLocation_DD
        Set Location to 55 109
        Set Size to 13 175
        Set Prompt_Button_Mode to PB_PromptOff
        Set Enabled_State to False
    End_Object

    Object oSalesRep_RepIdno is a cGlblDbForm
        Entry_Item SalesRep.RepIdno
        Set Location to 70 51
        Set Size to 13 54
        Set Label to "Sales Rep:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSalesRep_LastName is a cGlblDbForm
        Entry_Item SalesRep.LastName
        Set Location to 70 109
        Set Size to 13 90
        Set Prompt_Button_Mode to PB_PromptOff
        Set Enabled_State to False
    End_Object

    Object oSalesRep_FirstName is a cGlblDbForm
        Entry_Item SalesRep.FirstName
        Set Location to 70 203
        Set Size to 13 80
        Set Enabled_State to False
    End_Object

    Object oQuoteWizardButton is a Button
        Set Size to 14 80
        Set Location to 5 380
        Set Label to "Quote Wizard"
        Set peAnchors to anTopRight
    
        Procedure OnClick
            Send DoQuoteWizard
        End_Procedure
    End_Object

    Object oQuoteGrid is a dbGrid

        Function Child_Entering Returns Integer
            Integer iRetval iRecId
            // Check with header to see if it is saved.
            Delegate Get IsSavedHeader to iRetval
            //
            If (iRetval = 0) Begin
                Get Current_Record  of oQuotedtl_DD to iRecId
                Send Find_By_Recnum of oQuotedtl_DD Quotedtl.File_Number iRecId
            End
            //
            Function_Return iRetval // if non-zero do not enter
        End_Function  // Child_Entering

//        Procedure Prompt_Callback Integer hoPrompt
//            Integer iCol
//            //
//            Get Current_Col to iCol
//            If (iCol = 1) Begin
//                Set Ordering       of hoPrompt to 2
//                Set Initial_Column of hoPrompt to 2
//            End
//        End_Procedure

        Procedure Prompt
            Integer iCol iRecId
            //
            Get Current_Col                   to iCol
            Get Current_Record of oMastops_DD to iRecId
            //
            If (iCol = 2) Begin
                Send DoQuotePrompt of Mastops_sl
            End
            Else Begin
                Forward Send Prompt
            End
            //
            If (Current_Record(oMastops_DD) <> iRecId) Begin
                Set Field_Changed_Value of oQuotedtl_DD Field Quotedtl.Price       to MastOps.SellRate
                Set Field_Changed_Value of oQuotedtl_DD Field Quotedtl.Description to MastOps.Description
            End
        End_Procedure

        Procedure Request_Clear
            If (Changed_State(oQuotedtl_DD)) Begin
                Forward Send Request_Clear
            End
            Else Begin
                Send Add_New_Row 0
            End
        End_Procedure

        Function DataLossConfirmation Returns Integer
            Integer bCancel
            //
            If (not(Changed_State(oQuotehdr_DD))) Begin
                Function_Return
            End
            Else Begin
                Get Confirm "Abandon Quote Detail Changes?" to bCancel
                Function_Return bCancel
            End
        End_Function

        Set Size to 95 459
        Set Location to 93 5

        Begin_Row
            Entry_Item Quotedtl.QuotedtlID
            Entry_Item MastOps.MastOpsIdno
            Entry_Item MastOps.Name
            Entry_Item MastOps.CalcBasis
            Entry_Item Quotedtl.Quantity
            Entry_Item Quotedtl.Price
            Entry_Item Quotedtl.Amount
        End_Row

        Set Main_File to Quotedtl.File_number

        Set Server to oQuotedtl_DD

        Set Form_Width 0 to 0
        Set Header_Label 0 to "ID"

        Set Column_Shadow_State 0 to True
        Set Header_Label 1 to "Oper ID"
        Set Column_Shadow_State 1 to True

        Set Form_Width 2 to 188
        Set Header_Label 2 to "Operation Name"

        Set Form_Width 3 to 103
        Set Header_Label 3 to "Calc Basis"
        Set Column_Combo_State 3 to True

        Set Form_Width 4 to 48
        Set Header_Label 4 to "Quantity"
        Set Header_Justification_Mode 4 to JMode_Right

        Set Form_Width 5 to 54
        Set Header_Label 5 to "Price"
        Set Header_Justification_Mode 5 to JMode_Right

        Set Form_Width 6 to 54
        Set Header_Label 6 to "Amount"
        Set Header_Justification_Mode 6 to JMode_Right

        Set peAnchors to anAll
        Set Wrap_State to True
        Set peResizeColumn to rcSelectedColumn
        Set piResizeColumn to 2
        Set Ordering to 2
        Set Child_Table_State to True
        Set Color to clWhite
        Set peDisabledColor to clWhite
        Set peDisabledTextColor to clBlack
        Set TextColor to clBlack
    End_Object

    Object oQuotehdr_Amount is a cGlblDbForm
        Entry_Item Quotehdr.Amount
        Set Location to 195 393
        Set Size to 13 54
        Set Label to "Total:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set peAnchors to anBottomRight
    End_Object

    Object oQuotedtl_Description is a cDbTextEdit
        Entry_Item Quotedtl.Description

        Set Server to oQuotedtl_DD
        Set Location to 200 5
        Set Size to 60 335
        Set Label to "Description:"
        Set peAnchors to anBottomLeftRight
    End_Object

    Object oPrintButton is a Button
        Set Size to 14 54
        Set Location to 215 393
        Set Label to "Print Quote"
        Set peAnchors to anBottomRight
    
        // fires when the button is clicked
        Procedure OnClick
            Integer iQuote
            Get Field_Current_Value of oQuotehdr_DD Field Quotehdr.QuotehdrID to iQuote
            If (iQuote <> 0) Begin
                Send DoJumpStartReport of oPrintQuotes iQuote
            End
        End_Procedure
    
    End_Object

    Function IsSavedHeader Returns Integer
        Integer iRecId
        //
        Get Current_Record of oQuotehdr_DD to iRecId
        //
        If (iRecId = 0) Begin
            Send Stop_Box "No Quote created/selected"
            Function_Return 1
        End
    End_Function

    Procedure DoQuoteWizard
        Integer iRecId
        //
        Get DoQuoteWizard of oQuoteWizardPanel to iRecId
        //
        If (iRecId) Begin
            Send Find_By_Recnum of oQuotehdr_DD Quotehdr.File_Number iRecId
            Send Activate of oQuotehdr_QuotehdrID
        End
    End_Procedure

Cd_End_Object
