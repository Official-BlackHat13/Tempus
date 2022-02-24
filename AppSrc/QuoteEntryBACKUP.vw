Use Windows.pkg
Use DFClient.pkg
Use cTempusDbView.pkg
Use cGlblDbForm.pkg
Use dfTable.pkg
Use cDbTextEdit.pkg
Use cComDbSpellText.pkg
Use cGlblDbComboForm.pkg
Use dfTabDlg.pkg
Use dfLine.pkg
Use dbSuggestionForm.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Contact.DD
Use cQuotehdrDataDictionary.dd
Use MastOps.DD
Use cQuotedtlDataDictionary.dd
Use cSnowrepDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cWorkTypeGlblDataDictionary.dd
Use Order.DD
Use Eshead.DD
Use cAttachmentsGlblDataDictionary.dd

Use OrderProcess.bp
Use PMInvoiceFromQuote.bp //Cergol
Use QuoteToEstimate.bp
Use QuoteToOrder.bp


//Use QuoteWizard.dg

#IFDEF qtAll
#ELSE
Enum_List
    Define qtAll
    Define qtPavementMaintenance
    Define qtSnowRemoval
End_Enum_List
#ENDIF

Activate_View Activate_oQuoteEntry for oQuoteEntry
Object oQuoteEntry is a cTempusDbView

    Procedure doReceiveMessage String sQuoteIdno
        Send Request_Clear_All
        Move sQuoteIdno to Quotehdr.QuotehdrID
        Send Find of oQuotehdr_DD EQ 1
    End_Procedure

    Property Integer peQuoteType qtPavementMaintenance

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
    End_Object

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oMastops_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
        Procedure OnConstrain
            Constrain MastOps.Status       eq "A"
        End_Procedure
    End_Object

    Object oSalesrep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oContact_DD is a Contact_DataDictionary
//        Set DDO_Server to oSnowrep_DD
//        Set DDO_Server to oSalesrep_DD
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oEshead_DD is a Eshead_DataDictionary
        Set DDO_Server to oSalesrep_DD
        Set DDO_Server to oContact_DD
        Set Constrain_file to Contact.File_number
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesrep_DD
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD
    End_Object

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set DDO_Server to oContact_DD
        Set DDO_Server to oSalesrep_DD
        Set DDO_Server to oLocation_DD
        //Set Add_System_File to Order.File_Number DD_LOCK_ON_ALL
               
        Procedure Save_Main_File
            Forward Send Save_Main_File
            //
            If (Quotehdr.JobNumber <> 0) Begin
                Clear Order
                Move Quotehdr.JobNumber to Order.JobNumber
                Find eq Order.JobNumber
                If (Found) Begin
                    Move Quotehdr.Amount to Order.QuoteAmount            ///////////////MOVE QUOTEAMOUNT HERE///////////////////
                    Save Order
                End
            End
        End_Procedure

    End_Object

    Object oAttachments_DD is a cAttachmentsGlblDataDictionary
        //Set DDO_Server to oOrder_DD
        //Set DDO_Server to oEshead_DD
        Set DDO_Server to oQuotehdr_DD
        Set Constrain_file to Quotehdr.File_number
        //
        Set pbUseDDRelates to True
        //
        Send Remove_Server_File oOrder_DD
        Send Remove_Server_File oEshead_DD
        //
        Set Field_Related_FileField Field Attachments.QuoteIdno to File_Field Quotehdr.QuotehdrID
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
    Set Size to 350 580
    Set Location to 1 1
    Set Label to "Quote Entry"
    Set piMinSize to 250 580

    Object oHeaderContainer1 is a dbContainer3d
        Set Size to 23 573
        Set Location to 3 4
        Set peAnchors to anTopLeftRight

        Object oQuotehdr_QuotehdrID is a cGlblDbForm
            Entry_Item Quotehdr.QuotehdrID
            Set Location to 3 40
            Set Size to 13 48
            Set Label to "Quote#:"
            Set Label_Col_Offset to 3
            //Set Prompt_Button_Mode to PB_PromptOn
            Set Label_Justification_Mode to JMode_Right
            Set Label_FontWeight to fw_Bold
            Set FontWeight to fw_Bold
    
            Procedure Request_Find Integer iMode Integer iEntUpdtFlag
                Send Request_Superfind iMode
            End_Procedure

            Procedure Next
                Send Request_Superfind EQ
                Forward Send Next
            End_Procedure
    
            Procedure Refresh Integer iMode
                Forward Send Refresh iMode
                //
                Boolean bQuoteExists bQuoteIsJob bQuoteLocked bQuoteOnly bHasAdminRights
                Move (Quotehdr.JobNumber >0) to bQuoteIsJob
                Move (Quotehdr.Recnum >0) to bQuoteExists
                Move (Quotehdr.LockedFlag > 0) to bQuoteLocked
                Move (giUserRights >=70) to bHasAdminRights
                //Move (Quotehdr.BillingType = "T" or Quotehdr.BillingType = "N") to bQuoteOnly
                Set Enabled_State of oLockStateButton to (bHasAdminRights and bQuoteExists)
                If (bQuoteLocked) Begin
                    Set Bitmap of oLockStateButton to "locked.bmp"
                End
                Else Begin
                    Set Bitmap of oLockStateButton to "unlocked.bmp"
                End
                
                // Level 1
                Set Enabled_State of oCloneButton to bQuoteExists
                Set Enabled_State of oPrintQuoteButton to bQuoteExists
                Set Enabled_State of oViewOrderButton   to bQuoteIsJob
                Set Enabled_State of oEmailButton to bQuoteExists
                Set Enabled_State of oCreateOrderButton to (bQuoteExists and not(bQuoteIsJob))
                // Level 2
                Set Enabled_State of oQuotehdr_Status   to (Quotehdr.Status <> "W" and Quotehdr.Status <> "R" or not(bQuoteLocked))
                // Level 3
                Set Enabled_State of oCustomer_Name to (not(bQuoteExists) or not(bQuoteLocked))
                Set Enabled_State of oContact_FirstName to (not(bQuoteIsJob) or not(bQuoteLocked))
                Set Enabled_State of oContact_LastName to (not(bQuoteIsJob) or not(bQuoteLocked)) 
                Set Enabled_State of oLocation_Name to (not(bQuoteIsJob) or not(bQuoteLocked))
                Set Enabled_State of oSalesRep_FirstName to (not(bQuoteIsJob) or not(bQuoteLocked))
                Set Enabled_State of oSalesRep_LastName to (not(bQuoteIsJob) or not(bQuoteLocked))
                Set Enabled_State of oQuotehdr_Probability to (not(bQuoteIsJob) or not(bQuoteLocked))
                Set Enabled_State of oQuotehdr_CloseDate to (not(bQuoteIsJob) or not(bQuoteLocked))
                Set Enabled_State of oQuotehdr_QuoteDate to (not(bQuoteIsJob) or not(bQuoteLocked))
                Set Enabled_State of oQuotehdr_EstHours to (not(bQuoteIsJob) or not(bQuoteLocked))
                Set Enabled_State of oQuotehdr_QuoteLostMemo to (not(bQuoteIsJob) or not(bQuoteLocked))
                Set Enabled_State of oQuotehdr_WorkType to (not(bQuoteIsJob) or not(bQuoteLocked))
                // Level 4
                Set Enabled_State of oQuoteHeaderGroup to (not(bQuoteLocked))
                Set Read_Only_State of oQuoteDtlGrid to (bQuoteLocked)
                Set Enabled_State of oQuotedtl_Description to (not(bQuoteLocked))
            End_Procedure
        End_Object

        Object oQuotehdr_QuoteLostMemo is a cGlblDbForm
            Entry_Item Quotehdr.QuoteLostMemo
            Set Location to 3 91
            Set Size to 13 251
            Set peAnchors to anTopLeftRight
            
            Procedure OnChange
                If (Length(Value(Self))> 0) Set Label_TextColor to clBlack
                Else Set Label_TextColor to clRed                
            End_Procedure
        End_Object

        Object oLockStateButton is a Button
            Set Size to 15 17
            Set Location to 2 350
            Set Label to 'oButton2'
            Set Bitmap to "unlocked.bmp"
            Set peAnchors to anTopRight
        
            // fires when the button is clicked
            Procedure OnClick
                Boolean bQuoteLockStatus bHasRecord bShouldSave
                //
                Get Field_Current_Value of oQuotehdr_DD Field Quotehdr.LockedFlag to bQuoteLockStatus
                Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.LockedFlag to (not(bQuoteLockStatus))                
                Get HasRecord of oQuotehdr_DD to bHasRecord
                Get Should_Save of oQuotehdr_DD to bShouldSave
                If (bHasRecord and bShouldSave) Begin
                    Send Request_Save of oQuotehdr_DD
                End
            End_Procedure
        
        End_Object

        Object oQuotehdr_WorkType is a cGlblDbComboForm
            Entry_Item Quotehdr.WorkType
            Set Location to 3 395
            Set Size to 12 59
            Set Label to "Type:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set peAnchors to anTopRight
            Set Label_FontWeight to fw_Bold
        End_Object

        Object oQuotehdr_Status is a cGlblDbComboForm
            Entry_Item Quotehdr.Status
            Set Location to 3 502
            Set Size to 12 60
            Set Label to "Status:"
            Set Label_Col_Offset to 3
            Set Combo_Sort_State to False
            Set peAnchors to anTopRight
            Set Label_Justification_Mode to JMode_Right
            Set Label_FontWeight to fw_Bold
        End_Object
    End_Object

    Object oDetailContainer is a cGlblDbContainer3d
        Set Server to oQuotedtl_DD
        Set Size to 196 573
        Set Location to 124 4
        Set peAnchors to anAll

        Object oQuoteDtlGrid is a dbGrid
            Set Location to 3 4
    
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
    
//                    Procedure Prompt_Callback Integer hoPrompt
//                      Integer iCol
//                      //
//                      Get Current_Col to iCol
//                      If (iCol = 1) Begin
//                          Set Ordering       of hoPrompt to 2
//                          Set Initial_Column of hoPrompt to 2
//                      End
//                    End_Procedure
    
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
    
            Set Size to 141 563
    
            Begin_Row
                Entry_Item Quotedtl.QuotedtlID
                Entry_Item Quotedtl.Sequence
                Entry_Item MastOps.Name
                Entry_Item MastOps.CalcBasis
                Entry_Item Quotedtl.Quantity
                Entry_Item Quotedtl.Price
                Entry_Item Quotedtl.TaxAmount
                Entry_Item Quotedtl.Amount
            End_Row
    
            Set Main_File to Quotedtl.File_number
    
            Set Form_Width 0 to 1
            Set Header_Label 0 to "ID"
            Set Column_Shadow_State 0 to True

            Set Form_Width 1 to 30
            Set Header_Label 1 to "Seq"
            Set Header_Justification_Mode 1 to JMode_Right
    
            Set Form_Width 2 to 181
            Set Header_Label 2 to "Operation Name"
    
            Set Form_Width 3 to 51
            Set Header_Label 3 to "Calc Basis"
            Set Column_Combo_State 3 to True
            Set Column_Shadow_State 3 to True
    
            Set Form_Width 4 to 48
            Set Header_Label 4 to "Quantity"
            Set Header_Justification_Mode 4 to JMode_Right
            Set Column_Shadow_State 4 to False
    
            Set Form_Width 5 to 54
            Set Header_Label 5 to "Price"
            Set Header_Justification_Mode 5 to JMode_Right
            Set Column_Shadow_State 5 to False
            
            Set Form_Width 6 to 48
            Set Header_Label 6 to "Tax Amount"
            Set Column_Shadow_State 6 to True
       
    
            Set Form_Width 7 to 71
            Set Header_Label 7 to "Amount"
            Set Header_Justification_Mode 7 to JMode_Right
            Set Column_Shadow_State 7 to True

            

    
            Set peAnchors to anAll
            Set peResizeColumn to rcSelectedColumn
            Set piResizeColumn to 2
            Set Ordering to 2
            Set Child_Table_State to True
            Set Color to clWhite
            //Set peDisabledColor to clWhite
            //Set peDisabledTextColor to clWhite
            Set CurrentRowColor to clLtGray
            Set CurrentCellColor to clLtGray
            Set TextColor to clBlack
            Set Wrap_State to True
            Set Horz_Scroll_Bar_Visible_State to False
            
            Procedure Change_Row_Color Integer iColor
                Integer iBase iItem iItems
             
                Get Base_Item to iBase               // first item of current row
                Get Item_Limit to iItems              // items per row
                Move (iBase+iItems-1) to iItems     // last item in the current row
             
                For iItem from iBase to iItems         // set all items in row to color 
                    Set ItemColor iItem to iColor
                Loop
                Procedure_Return
            End_Procedure // Change_Row_Color
            
            Procedure Entry_Display Integer iFile Integer iType
                Integer iColor iItem
                
                Case Begin
                    Case (Quotedtl.EstimateItemID>0)
                        Move 13106938 to iColor // Yellow
                        Case Break
                    Case Else
                        Move clWhite to iColor 
                Case End
    
                Send Change_Row_Color iColor
                Forward Send Entry_Display iFile iType
            End_Procedure 

            Procedure Item_Change Integer iFromItem Integer iToItem Returns Integer
                Integer iRetVal
                Forward Get msg_Item_Change iFromItem iToItem to iRetVal
                If (iFromItem = 2 and iToItem = 4) Begin
                    Send Activate to oQuotedtl_Description
                End
                Procedure_Return iRetVal
            End_Procedure
            
            
        End_Object
        
        
        
        Object oQuotedtl_Description is a cComDbSpellText

            Property Boolean pbText
            Property Boolean pbChangedText
            Property Integer piRecId
            Property String  psText

            Entry_Item Quotedtl.Description
            Set Size to 40 395
            Set Location to 147 5
            Set peAnchors to anBottomLeftRight

            Procedure OnCreate
                Forward Send OnCreate
                //Set the ActiveX properties here...
                Set ComDebugOption to OLEDebug_Actions
                Set ComMaxLength   to 512
            End_Procedure
        
            Procedure Request_Save
                Send Next
            End_Procedure

            Procedure Next
                Set pbText to False
                Send Activate of oQuoteDtlGrid
            End_Procedure
    
            Procedure OnComChange
                String sText
                //
                If (pbText(Self)) Begin
                    Set pbChangedText                                                  to True
                    Get ComText                                                        to sText
//                    Set Field_Changed_Value of oQuotedtl_DD Field Quotedtl.Description to sText
//                    Send Request_Save       of oQuotedtl_DD
                    Set psText                                                         to sText
                End
            End_Procedure

            Procedure OnComGainedFocus
                Set pbText  to True
                Set piRecId to (Current_Record(oQuotedtl_DD))
            End_Procedure

            Procedure OnComDebugEvent String llDebugInfo
                Showln llDebugInfo
            End_Procedure

            Procedure Exiting Integer iObj Returns Integer
                Boolean bChanged
                Integer iRetval iRecId
                String  sText
                //
                Forward Get msg_Exiting iObj to iRetval
                If (iRetval) Begin
                    Procedure_Return iRetval
                End
                //
                Get pbChangedText to bChanged
                If (bChanged) Begin
                    
                    //Send ChangeAllFileModes DF_FILEMODE_READONLY
                    //Set_Attribute DF_FILE_MODE of Quotedtl.File_Number to DF_FILEMODE_DEFAULT
                    Get piRecId                                        to iRecId
                    If (Quotedtl.Recnum <> iRecId) Begin
                        Clear Quotedtl
                        Move iRecId to Quotedtl.Recnum
                        Find eq Quotedtl.Recnum
                    End
                    Get psText                                         to sText
                    Set Field_Changed_Value of oQuotedtl_DD Field Quotedtl.Description to sText
                    Send Request_Save of oQuotedtl_DD
//                    Reread
//                    Move sText                                         to Quotedtl.Description
//                    SaveRecord Quotedtl
//                    Unlock
                    //Send ChangeAllFileModes DF_FILEMODE_DEFAULT
                    Set pbChangedText                                  to False
                End
                //
                Procedure_Return iRetval
            End_Procedure

            Procedure Entering Returns Integer
                Integer iRetVal
                Forward Get msg_Entering to iRetVal
                
                Procedure_Return iRetVal
            End_Procedure

            Procedure Activating
                Forward Send Activating
            End_Procedure

            Procedure OnSetFocus
                Forward Send OnSetFocus
            End_Procedure

    
//                    Procedure OnComLosingFocus
//                        Boolean bChanged
//                        Integer iRetval
//                        String  sText
//                        //
//                        Get pbChangedText to bChanged
//                        If (bChanged) Begin
//                            Get psText                                                         to sText
//                            Set Field_Changed_Value of oQuotedtl_DD Field Quotedtl.Description to sText
//                            Send Request_Save       of oQuotedtl_DD
//                            Set pbChangedText                                                  to False
//                        End
//                    End_Procedure
    
        End_Object

        Object oQuotehdr_SubTotal is a cGlblDbForm
            Entry_Item Quotehdr.SubTotal
            Set Server to oQuotehdr_DD
            Set Location to 146 488
            Set Size to 13 68
            Set Label to "SubTotal:"
            Set Enabled_State to False
            Set Entry_State to False
            Set Form_Datatype to Mask_Numeric_Window
            Set Form_Mask to "$ #,###,##0.00"
            Set peAnchors to anBottomRight
            Set Label_Col_Offset to 70
        End_Object

        Object oSalesTaxGroup_Rate is a cGlblDbForm
            Entry_Item SalesTaxGroup.Rate
            Set Server to oLocation_DD
            Set Enabled_State to False
            Set Shadow_State to True
            Set Location to 161 450
            Set Size to 13 38
            Set Label to "Sales Tax:"
            Set Form_Datatype to Mask_Numeric_Window
            Set Form_Mask to "#0.0000 %"
            Set Form_Justification_Mode to Form_DisplayRight
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
            Set peAnchors to anBottomRight
            
            Procedure OnChange
                If (Value(Self)> 0) Set Label_TextColor to clBlack
                Else Set Label_TextColor to clRed                
            End_Procedure
        End_Object

        Object oQuotehdr_TaxTotal is a cGlblDbForm
            Entry_Item Quotehdr.TaxTotal

            Set Server to oQuotehdr_DD
            Set Location to 161 488
            Set Size to 13 68
            Set Enabled_State to False
            Set Entry_State to False
            Set Form_Datatype to Mask_Numeric_Window
            Set Form_Mask to "$ #,###,##0.00"
            Set peAnchors to anBottomRight
        End_Object

        Object oLineControl2 is a LineControl
            Set Size to 2 137
            Set Location to 175 418
            Set peAnchors to anBottomRight
        End_Object

        Object oQuotehdr_Amount is a cGlblDbForm
            Entry_Item Quotehdr.Amount
            Set Location to 178 488
            Set Size to 13 68
            Set Label to "Total:"
            Set peAnchors to anBottomRight
            Set Label_FontWeight to fw_Bold
            Set Form_Datatype to Mask_Numeric_Window
            Set Form_Mask to "$ #,###,##0.00"
            Set Label_Col_Offset to 70
        End_Object
        
        
        
    End_Object

    Object oViewOrderButton is a Button
        Set Location to 328 4
        Set Label to "View Order"
        Set peAnchors to anBottomLeft
    
        Procedure OnClick
            Send DoViewOrder
        End_Procedure    
    End_Object

    Object oCreateOrderButton is a Button
        Set Size to 14 54
        Set Location to 328 64
        Set Label to "Create Order"
        Set peAnchors to anBottomLeft

        Procedure OnClick
            Integer iQuoteIdno iEstimateRef iJobNumber
            Boolean bCancel
            Get Confirm ("Do you want to create the Order now?" ) to bCancel
            If (not(bCancel)) Begin
                Get Field_Current_Value of oQuotehdr_DD Field Quotehdr.QuotehdrID to iQuoteIdno
                Get Field_Current_Value of oQuotehdr_DD Field Quotehdr.EstimateReference to iEstimateRef
                // save any unsaved header changes
                Get Request_Validate of oQuotehdr_DD to bCancel
                If bCancel Begin 
                    Send Stop_Box "Data validation error. Can't save Quote header changes before creating the Order." "QUOTE VALIDATION ERROR"
                    Procedure_Return
                End
                Send Request_Save of oQuotehdr_DD

                Get CreateOrderNow iEstimateRef iQuoteIdno to iJobNumber
                Send DoViewOrder
            End
        End_Procedure    
    End_Object

    Object oCloneButton is a Button
        Set Size to 14 54
        Set Location to 328 126
        Set Label to "Clone Quote"
        Set peAnchors to anBottomLeft
    
        Procedure OnClick
            Send DoCloneQuote
        End_Procedure    
    End_Object

    Object oPrintQuoteButton is a Button
        Set Size to 14 54
        Set Location to 328 188
        Set Label to "Print Quote"
        Set peAnchors to anBottomLeft
    
        Procedure OnClick
            Integer iQuote
            //
            Get Field_Current_Value of oQuotehdr_DD Field Quotehdr.QuotehdrID to iQuote
            If (iQuote <> 0) Begin
                Send DoJumpStartReport of oPrintQuotes iQuote
            End
        End_Procedure
    End_Object
   
    Object oEmailButton is a Button
        Set Location to 328 250
        Set Label to 'Email Client'
        Set peAnchors to anBottomLeft
    
        // fires when the button is clicked
        Procedure OnClick
            String sContactEmail sEmailQuery sLocationName
            Move Contact.EmailAddress                      to sContactEmail
            Move Location.Name                             to sLocationName                                                    
            Move ("mailto:" + sContactEmail +"?subject=Interstate Companies - Quote for " + sLocationName +"")        to sEmailQuery  
            
            Runprogram Shell Background sEmailQuery
        End_Procedure
    
    End_Object

    Object oDbTabDialog1 is a dbTabDialog
        Set Size to 93 573
        Set Location to 26 4
    
        Set Rotate_Mode to RM_Rotate

        Object oDetailsTab is a dbTabPage
            Set Label to 'Details'

            Object oQuoteHeaderGroup is a dbContainer3d
                Set Size to 76 573
                Set Location to 2 2
                Set peAnchors to anTopLeftRight
                //Set Scope_State to True
            
                Object oCustomer_Name is a DbSuggestionForm //cGlblDbForm
                    Entry_Item Customer.Name
                    Set Location to 2 39
                    Set Size to 13 300
                    //Set Enabled_State to False
                    Set Label to "Customer:"
                    Set Label_Col_Offset to 3
                    Set peAnchors to anTopLeftRight
                    Set Label_Justification_Mode to JMode_Right
                    Set pbFullText to True
                    
                    Procedure OnChange
                        If (HasRecord(oCustomer_DD)) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed              
                    End_Procedure
                    
                    Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                        Send Activate_oCustomerEntry                   
                    End_Procedure
                    
                End_Object
        
                Object oContact_LastName is a DbSuggestionForm //cGlblDbForm
                     Entry_Item Contact.LastName
                     Set Location to 16 39
                     Set Size to 13 190
                     //Set Enabled_State to False
                    //Set Entry_State to False
                    Set Label to "Contact:"
                    Set Label_Col_Offset to 35
                    Set peAnchors to anTopLeftRight
                    Set pbFullText to True
                    
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
                     
                    Procedure OnChange
                        If (HasRecord(oContact_DD)) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed              
                    End_Procedure
                     
                 End_Object
        
                 Object oContact_FirstName is a DbSuggestionForm //cGlblDbForm
                     Entry_Item Contact.FirstName
                     Set Server to oContact_DD
                     Set Location to 16 229
                     Set Size to 13 110
                     //Set Enabled_State to False
                     //Set Entry_State to False
                     Set peAnchors to anTopRight
                     Set pbFullText to True
                     
                 End_Object
        
                Object oContact_EmailAddress is a cGlblDbForm
                    Entry_Item Contact.EmailAddress
                    Set Server to oContact_DD
                    Set Location to 30 64
                    Set Size to 13 275
                    Set Entry_State to False
                    Set Enabled_State to False
                    Set peAnchors to anTopLeftRight
                End_Object
            
        //        Object oCustomer_CustomerIdno is a cGlblDbForm
        //            Entry_Item Customer.CustomerIdno
        //            Set Location to 25 51
        //            Set Size to 13 54
        //            Set Label to "Customer:"
        //            Set Label_Col_Offset to 3
        //            Set Label_Justification_Mode to JMode_Right
        //            Set Prompt_Button_Mode to PB_PromptOn
        //        End_Object
        
            
        //        Object oContact_ContactIdno is a cGlblDbForm
        //            Entry_Item Contact.ContactIdno
        //            Set Location to 40 51
        //            Set Size to 13 54
        //            Set Label to "Contact:"
        //            Set Label_Col_Offset to 3
        //            Set Label_Justification_Mode to JMode_Right
        //            Set Prompt_Button_Mode to PB_PromptOn
        //     
        //            Procedure Prompt
        //                Boolean bSelected
        //                Handle  hoServer
        //                RowID   riContact riCustomer
        //                //
        //                Get Server                            to hoServer
        //                Move (GetRowID(Contact.File_Number )) to riContact
        //                Move (GetRowId(Customer.File_Number)) to riCustomer
        //                //
        //                Get IsSelectedContact of Contact_sl (&riContact) (&riCustomer) to bSelected
        //                //
        //                If  (bSelected and not(IsNullRowId(riContact))) Begin
        //                    Send FindByRowId of hoServer Contact.File_Number riContact
        //                End
        //            End_Procedure
        //    
        ////            Procedure Prompt_Callback Integer hPrompt
        ////                Set Auto_Server_State of hPrompt to True
        ////            End_Procedure
        //       
        //           
        //        End_Object
            
        //        Object oLocation_LocationIdno is a cGlblDbForm
        //            Entry_Item Location.LocationIdno
        //            Set Server to oLocation_DD
        //            Set Location to 72 51
        //            Set Size to 13 54
        //            Set Label to "Location:"
        //            Set Label_Col_Offset to 3
        //            Set Label_Justification_Mode to JMode_Right
        //            Set Prompt_Button_Mode to PB_PromptOn
        //            Boolean bIsCustomerSelected
        //// Commented out due to some problems with a location changing its customer            
        ////            Procedure Prompt_Callback Integer hPrompt
        ////                // Conditional Prompt_Callback
        ////                String sCustomerIdno
        ////                Get Field_Current_Value of oCustomer_DD Field Customer.CustomerIdno to sCustomerIdno
        ////                If (sCustomerIdno > 0) Move True to bIsCustomerSelected
        ////                Else Move False to bIsCustomerSelected
        ////                If (bIsCustomerSelected) Set Auto_Server_State of hPrompt to True
        ////            End_Procedure
        //            Procedure Prompt_Callback Integer hPrompt
        //                Set Auto_Server_State of hPrompt to True
        //            End_Procedure
        //            
        //        End_Object
            
                Object oLocation_Name is a DbSuggestionForm //cGlblDbForm
                    Entry_Item Location.Name
                    Set pbFullText to True
                    Set Server to oLocation_DD
                    Set Location to 44 39
                    Set Size to 13 300
                    //Set Enabled_State to False
                    Set Label to "Location"
                    Set Label_Col_Offset to 35
                    Set peAnchors to anTopLeftRight
                    
        //// Commented out due to some problems with a location changing its customer            
        //            Procedure Prompt_Callback Integer hPrompt
        //                // Conditional Prompt_Callback
        //                String sCustomerIdno
        //                Get Field_Current_Value of oCustomer_DD Field Customer.CustomerIdno to sCustomerIdno
        //                If (sCustomerIdno > 0) Move True to bIsCustomerSelected
        //                Else Move False to bIsCustomerSelected
        //                If (bIsCustomerSelected) Set Auto_Server_State of hPrompt to True
        //            End_Procedure
                    Procedure Prompt_Callback Integer hPrompt
                        Set Auto_Server_State of hPrompt to True
                    End_Procedure
                    
                    Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                        Send Activate_oLocationEntry                   
                    End_Procedure
                    
                    Procedure OnChange
                        If (HasRecord(oLocation_DD)) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed              
                    End_Procedure
                    
                End_Object
                
             ///Contact Last Name First Name - here
             
        //        Object oSalesRep_RepIdno is a cGlblDbForm
        //            Entry_Item SalesRep.RepIdno
        //            //Set Server to oQuotehdr_DD
        //            Set Location to 87 51
        //            Set Size to 13 54
        //            Set Label to "Sales Rep:"
        //            Set Label_Col_Offset to 3
        //            Set Label_Justification_Mode to JMode_Right
        //            Set Prompt_Button_Mode to PB_PromptOn
        //            
        //           Procedure Prompt_Callback Integer hPrompt
        //               Set Auto_Server_State of hPrompt to True
        //          End_Procedure
        //            
        //        End_Object
            
                Object oSalesRep_LastName is a DbSuggestionForm //cGlblDbForm
                    Entry_Item SalesRep.LastName
                    Set Location to 58 39
                    Set Size to 13 190
                    //Set Enabled_State to False
                    Set Label to "Sales Rep:"
                    Set Label_Col_Offset to 35
                    Set peAnchors to anTopLeftRight
                    Set Prompt_Button_Mode to PB_PromptOn
                    Set pbFullText to True
                    
                    Procedure Prompt_Callback Integer hPrompt
                        Set pbAutoServer of hPrompt to False
                    End_Procedure
                    //            
                    Procedure OnChange
                        If (HasRecord(oSalesrep_DD)) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed              
                    End_Procedure
                    
                End_Object
            
                Object oSalesRep_FirstName is a DbSuggestionForm //cGlblDbForm
                    Entry_Item SalesRep.FirstName
                    Set Location to 58 229
                    Set Size to 13 110
                    Set peAnchors to anTopRight
                    Set Prompt_Button_Mode to PB_PromptOn
                    //Set Enabled_State to False
                        
                    Procedure Prompt_Callback Integer hPrompt
                        Set pbAutoServer of hPrompt to False
                    End_Procedure
                    
                End_Object
        
                Object oQuotehdr_EstimateReference is a cGlblDbForm
                    Entry_Item Quotehdr.EstimateReference
                    Set Location to 1 392
                    Set Size to 13 60
                    Set Label to "Estimate:"
                    Set Label_Col_Offset to 45
                    Set Enabled_State to False
                    Set peAnchors to anTopRight
                    Set Entry_State to False
        
                    Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                        String sEsheadIdno
                        Forward Send Mouse_Click iWindowNumber iPosition
                        Get Field_Current_Value of oQuotehdr_DD Field Quotehdr.EstimateReference to sEsheadIdno
                        If (sEsheadIdno<>0) Begin
                            //Runprogram background "TempusEstimating.exe" (String(sEsheadIdno))
                            Send DoCallFromClient to oRPCClient sEsheadIdno "oEstimate"
                        End
                    End_Procedure
                End_Object
        
                Object oQuotehdr_EstHours is a cGlblDbForm
                    Entry_Item Quotehdr.EstHours
                    Set Location to 1 500
                    Set Size to 13 60
                    Set Label to "Est Hours:"
                    Set Label_Col_Offset to 40
                    Set peAnchors to anTopRight
                    
                    Procedure OnChange
                        If ((Value(Self)) <> 0) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed                
                    End_Procedure
                End_Object
        
                Object oLineControl1 is a LineControl
                    Set Size to 2 219
                    Set Location to 15 344
                    Set peAnchors to anTopRight
                End_Object
        
                Object oQuotehdr_QuoteDate is a cdbszDatePicker // cGlblDbForm
                    Entry_Item Quotehdr.QuoteDate
                    Set Location to 19 392
                    Set Size to 13 60
                    Set Label to "Quote Date:"
                    Set Label_Col_Offset to 45
                    Set peAnchors to anTopRight
                End_Object
        
                Object oQuotehdr_BillingType is a cGlblDbComboForm
                    Entry_Item Quotehdr.BillingType
                    Set Location to 19 500
                    Set Size to 12 60
                    Set Label to "BillingType:"
                    Set Label_Col_Offset to 40
                    Set peAnchors to anTopRight
        
                    Procedure Combo_Item_Changed
                        Forward Send Combo_Item_Changed
                        Boolean bHasRecord bShouldSave
                        Get HasRecord of oQuotehdr_DD to bHasRecord
                        Get Should_Save of oQuotehdr_DD to bShouldSave
                        If (bHasRecord and bShouldSave) Begin
                            Send Request_Save of oQuotehdr_DD
                        End
                    End_Procedure
                End_Object
        
                Object oQuotehdr_Probability is a cGlblDbComboForm
                    Entry_Item Quotehdr.Probability
                    Set Location to 34 392
                    Set Size to 13 60
                    Set Label to "Probability %:"
                    Set Label_Col_Offset to 45
                    Set peAnchors to anTopRight
                    
                    Procedure OnChange
                        If ((Value(Self)) <> "") Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed                
                    End_Procedure
                End_Object
        
                Object oQuotehdr_CloseDate is a cdbszDatePicker   //cGlblDbForm
                    Entry_Item Quotehdr.CloseDate
                    Set Location to 33 500
                    Set Size to 13 60
                    Set Label to "CloseDate:"
                    Set Label_Col_Offset to 40
                    Set Prompt_Button_Mode to PB_PromptOn
                    Set peAnchors to anTopRight
                    
                    Procedure OnChange
                        If ((Value(Self)) <> 0) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed                
                    End_Procedure
                End_Object
        
                Object oLineControl1 is a LineControl
                    Set Size to 2 219
                    Set Location to 49 343
                    Set peAnchors to anTopRight
                End_Object
            
                Object oQuotehdr_JobNumber is a cGlblDbForm
                    Entry_Item Quotehdr.JobNumber
                    Set Location to 54 392
                    Set Size to 13 60
                    Set Label to "Job Number:"
                    Set Label_Col_Offset to 45
                    Set Entry_State to False
                    Set Enabled_State to False
                    Set peAnchors to anTopRight
        
                    Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                        Forward Send Mouse_Click iWindowNumber iPosition
                        Send DoViewOrder
                    End_Procedure
                End_Object
            
                Object oQuotehdr_OrderDate is a cGlblDbForm
                    Entry_Item Quotehdr.OrderDate
                    Set Location to 54 500
                    Set Size to 13 60
                    Set Label to "Order Date:"
                    Set Label_Col_Offset to 40
                    Set Enabled_State to False
                    Set Entry_State to False
                    Set peAnchors to anTopRight            
                End_Object
            
        //        Object oQuotehdr_WorkType is a cGlblDbComboForm
        //            Entry_Item Quotehdr.WorkType
        //            Set Location to 32 315
        //            Set Size to 12 60
        //            Set Label to "WorkType:"
        //            Set Label_Col_Offset to 45
        //            Set Combo_Sort_State to False
        //            Set peAnchors to anTopRight
        //        End_Object
        
        //        Object oNewCustomerButton is a Button
        //            Set Size to 13 13
        //            Set Location to 11 235
        //            Set Label to '+'
        //            Set FontWeight to fw_Bold
        //        
        //            // fires when the button is clicked
        //            Procedure OnClick
        //                
        //            End_Procedure
        //        
        //        End_Object
        //
        //        Object oNewContact is a Button
        //            Set Size to 13 13
        //            Set Location to 26 235
        //            Set Label to '+'
        //            Set FontWeight to fw_Bold
        //        
        //            // fires when the button is clicked
        //            Procedure OnClick
        //                
        //            End_Procedure
        //        
        //        End_Object
        //
        //        Object oNewLocation is a Button
        //            Set Size to 13 13
        //            Set Location to 56 235
        //            Set Label to '+'
        //            Set FontWeight to fw_Bold
        //        
        //            // fires when the button is clicked
        //            Procedure OnClick
        //                
        //            End_Procedure
        //        
        //        End_Object
        //
        //        Object oLineControl3 is a LineControl
        //            Set Size to 87 3
        //            Set Location to 11 257
        //            Set Horizontal_State to False
        //        End_Object
        
        //        Object oLockUnlockButton is a Button
        //            Set Location to 9 111
        //            Set Label to 'Unlock'
        //            
        //            Boolean bLockFlag
        //            Move False to bLockFlag
        //        
        //            // fires when the button is clicked
        //            Procedure OnClick
        //                Set Enabled_State of oCustomer_CustomerIdno to True
        //                Set Enabled_State of oContact_ContactIdno to True 
        //                Set Enabled_State of oLocation_LocationIdno to True
        //                Set Enabled_State of oSalesRep_RepIdno to True
        //            End_Procedure
        //        
        //        End_Object
                
                
        // BEN - This procedure is triggered when exiting scope. On closing the view it triggers both "DataLossConfirmation" 
        // and the "Exiting_Scope" Procedure. When you agree to lose information it still saves the header. Development will be prosponed
        //        Procedure Exiting_Scope Handle hoNewScope Returns Integer
        //            Integer iFail
        //            Boolean bChangedState bQuoteExists
        //            Move (Quotehdr.Recnum >0) to bQuoteExists
        //            Get Changed_State of oQuotehdr_DD to bChangedState
        //            If (bChangedState) Begin
        //                If (bQuoteExists) Begin
        //                    Forward Get msg_Exiting_Scope hoNewScope to iFail
        //                    If (not(iFail)) Begin
        //                        Send Request_Save of oQuotehdr_DD
        //                    End 
        //                End
        //            End
        //            Procedure_Return iFail
        //        End_Procedure
        
        
            End_Object
        End_Object

        Object oDbTabPage1 is a dbTabPage
            Set Label to 'Attachments'
            
            Object oDragAndDropContainer is a dbContainer3d
                Set Size to 76 565
                Set Location to 1 1
                Set pbAcceptDropFiles to True
                Set Bitmap_Style to Bitmap_Center

                Property String[] pArrayOfDroppedFiles

                Set peAnchors to anAll


                Procedure OnFileDropped String sFilename Boolean bLast
                    Integer  iFiles
                    String[] ArrayOfDroppedFiles EmptyArray
                    
                    Get pArrayOfDroppedFiles to ArrayOfDroppedFiles
            
                    // Add the filename to the list of dropped files....
                    Move (SizeOfArray(ArrayOfDroppedFiles)) to iFiles
                    Move sFilename to ArrayOfDroppedFiles[iFiles] 
                    
                    // If this was the last file, process them and clear the list
                    If (bLast) Begin
                        Send ProcessDroppedFiles ArrayOfDroppedFiles
                        // clear the property so it is ready for next drop 
                        Move EmptyArray to ArrayOfDroppedFiles
                    End
            
                    Set pArrayOfDroppedFiles to ArrayOfDroppedFiles
            
                End_Procedure

                Procedure ProcessDroppedFiles String[] ArrayOfDroppedFiles
                    Integer iArraySize i iSeq iDotPos iSlashPos iQuoteIdno iRetval
                    String sYear sMonth sDay sHr sMin sSec sSourceFile sFileName sNewFileName sFileExt sTargetPath sTargetFile
                    Handle hoDD hoWorkspace
                    Boolean bSuccess bFail bIsImage
                    
                    Move (SizeOfArray(ArrayOfDroppedFiles)) to iArraySize
                    Move Quotehdr.QuotehdrID to iQuoteIdno
                    // Continue Sequence.
                    
                    Constraint_Set 1
                    Constrain Attachments.QuoteIdno eq iQuoteIdno
                    Constrained_Find Last Attachments by 6
                    If (Found) Begin
                        Move (Attachments.Sequence) to iSeq 
                    End
                    Else Begin
                        Move 0 to iSeq
                    End
                    Constraint_Set 1 Delete
                    
                    // display all items in array
                    For i from 0 to (iArraySize-1)
                        Move ArrayOfDroppedFiles[i] to sSourceFile
                        Showln ("File# "+String(i)+" File Path and Name: "+ sSourceFile)
                        // Get file Extension
                        Move ((Length(sSourceFile)) - (RightPos(".", sSourceFile))) to iDotPos
                        Move (Right(sSourceFile, (iDotPos+1))) to sFileExt
                        Showln ("- Target Extension: " + sFileExt)
                        // Get file Name
                        Move ((Length(sSourceFile)) - (RightPos("\", sSourceFile))) to iSlashPos
                        Move (Right(sSourceFile, (iSlashPos))) to sFileName
                        Showln ("- File Name: "+ sFileName)
                        // Only allow image Files
                        // Image (JPG/JPEG)|*.jpg;*.jpeg|Image File (PNG)|*.png|All Images|*.jpg;*.jpeg;*.png
                        Case Begin
                            Case (sFileExt = ".jpg" or sFileExt = ".JPG")
                                Move True to bIsImage
                                Case Break
                            Case (sFileExt = ".jpeg" or sFileExt = ".JPEG")
                                Move True to bIsImage
                                Case Break
                            Case (sFileExt = ".png" or sFileExt = ".PNG")
                                Move True to bIsImage
                                Case Break
                            Case (sFileExt = ".bmp" or sFileExt = ".BMP")
                                Move True to bIsImage
                                Case Break
                            Case Else
                                Move False to bIsImage
                        Case End
                        // Generate Filename
                        Date dToday
                        Sysdate dToday sHr sMin sSec
                        //
                        Move (DateGetYear(dToday)) to sYear
                        Move (DateGetMonth(dToday)) to sMonth
                        Move (DateGetDay(dToday)) to sDay
                        Move (sYear+"_"+sMonth+"_"+sDay+"-"+sHr+"_"+sMin+"_"+sSec+"_"+String(i)+sFileExt) to sNewFileName
                        Showln sNewFileName
                        Get psHome of (phoWorkspace(ghoApplication)) to sTargetPath
                        Move (sTargetPath+"Bitmaps\Attachments\") to sTargetPath
                        Move (sTargetPath+sNewFileName) to sTargetFile
                        Showln ("- sTargetFile: "+ sTargetFile)
                        // Use CopyFile to move file to target address
                        //CopyFile sSourceFile to sTargetFile
                        Get vCopyFile sSourceFile sTargetFile to iRetval
                        If (iRetval=0) Begin
                            Increment iSeq
                            // Store all in Attachment Table       
                            Move oAttachments_DD to hoDD
                            Send Clear of hoDD
                            Set Field_Changed_Value of hoDD Field Attachments.QuoteIdno         to iQuoteIdno
                            Set Field_Changed_Value of hoDD Field Attachments.CreatedBy         to gsUsername
                            Set Field_Changed_Value of hoDD Field Attachments.CreatedDate       to dToday
                            Set Field_Changed_Value of hoDD Field Attachments.CreatedTime       to (sHr+":"+sMin+":"+sSec)
                            Set Field_Changed_Value of hoDD Field Attachments.Name              to sFileName
                            Set Field_Changed_Value of hoDD Field Attachments.Sequence          to iSeq
                            Set Field_Changed_Value of hoDD Field Attachments.FileName          to sNewFileName
                            Set Field_Changed_Value of hoDD Field Attachments.OrderFlag         to bIsImage
                            Get Request_Validate    of hoDD                                     to bFail
                            If (not(bFail)) Begin
                                Send Request_Save       of hoDD
                            End
                            Else Begin
                                Send Stop_Box "Processing stopped"
                                Function_Return
                            End    
                        End
                        Else Begin
                            Send Stop_Box ("There was an error attaching "+ sSourceFile + " Quote# "+ String(iQuoteIdno)) "Error Attaching File"
                        End
                        
                    Loop
                End_Procedure

                Object oAttachmentsGrid is a cDbCJGrid
                    Set Server to oAttachments_DD
                    Set Size to 71 557
                    Set Location to 1 2
                    Set pbAllowDeleteRow to False
                    Set pbAllowInsertRow to False
                    Set peAnchors to anAll
    
                    Object oAttachments_Sequence is a cDbCJGridColumn
                        Entry_Item Attachments.Sequence
                        Set piWidth to 46
                        Set psCaption to "Seq."
                    End_Object
    
                    Object oAttachments_Name is a cDbCJGridColumn
                        Entry_Item Attachments.Name
                        Set piWidth to 137
                        Set psCaption to "Name"
                    End_Object
    
                    Object oAttachments_Description is a cDbCJGridColumn
                        Entry_Item Attachments.Description
                        Set piWidth to 157
                        Set psCaption to "Description"
                    End_Object
    
                    Object oAttachments_FileName is a cDbCJGridColumn
                        Entry_Item Attachments.FileName
                        Set piWidth to 291
                        Set psCaption to "File Name"
                    End_Object
    
                    Object oAttachments_OrderFlag is a cDbCJGridColumn
                        Entry_Item Attachments.OrderFlag
                        Set piWidth to 76
                        Set psCaption to "OrderFlag"
                        Set pbCheckbox to True
                    End_Object
    
                    Object oAttachments_CreatedBy is a cDbCJGridColumn
                        Entry_Item Attachments.CreatedBy
                        Set piWidth to 146
                        Set psCaption to "CreatedBy"
                    End_Object
    
                    Object oAttachments_UpdatedBy is a cDbCJGridColumn
                        Entry_Item Attachments.UpdatedBy
                        Set piWidth to 53
                        Set psCaption to "UpdatedBy"
                    End_Object

                    Object oCJGridColumnButton1 is a cCJGridColumnButton
                        Set piWidth to 68
                        Set piWidthButton to 58
                        Set psCaptionButton to "Delete"
                        Set psCaption to "Action"
                        //Set Color to clGray
                        Set peHeaderAlignment to xtpAlignmentCenter
                        Set piCaptionColorButton to clBlack
                        Set psFontNameButton to ""
                        
                        
                        Function ButtonPaint Handle hoGridItemMetrics Integer iRow String ByRef sValue Returns Boolean
                            //yu can return false for rows you don't want to paint the button
                            Function_Return True
                        End_Function
                         
                        Procedure ButtonAction Integer iRow Integer iCol Short llButton Short llShift
                            String sAttachIdno sAttachFileName sAttachName sTargetPath sTargetFile
                            Integer eResponse iRetVal
                            Boolean bFail bIsLastRecord
                            Handle hoDD
                            //
                            Move (Trim(Attachments.AttachIdno)) to sAttachIdno
                            Move (Trim(Attachments.FileName)) to sAttachFileName
                            Move (Trim(Attachments.Name)) to sAttachName

                            //Send Info_Box ("You decited to delete "+ sAttachName +" aka. " + sAttachFileName + " (AttachIdno: " +sAttachIdno+")" ) "Removing Attachment"
                            Move (YesNo_Box("Do you want to remove " + sAttachName + " from Job#"+ String(Order.JobNumber)+"?","Remove Attached File",MB_DEFBUTTON1)) to eResponse
                            If (eResponse = MBR_Yes) Begin
                                // Remove Link to Order Record
                                Move 0 to Attachments.JobNumber
                                //Move 1 to Attachments.ChangedFlag
                                SaveRecord Attachments
                                // was this the last record?
                                Move (Attachments.EstimateIdno=0 and Attachments.QuoteIdno=0 and Attachments.JobNumber=0 and Attachments.InvoiceIdno=0) to bIsLastRecord
                                If (bIsLastRecord) Begin
                                    Get psHome of (phoWorkspace(ghoApplication)) to sTargetPath
                                    Move (sTargetPath+"Bitmaps\Attachments\") to sTargetPath
                                    Move (sTargetPath+sAttachFileName) to sTargetFile
                                    Get vDeleteFile sTargetFile to iRetVal
                                    Get ShowLastError to iRetval
                                    If (iRetVal=0) Begin
                                        Delete Attachments
                                    End
                                End
                            End
                            Send MoveToFirstRow of oAttachmentsGrid
                            
                        End_Procedure
                        
                        
                    End_Object

                    Object oAttachments_EstimateIdno is a cDbCJGridColumn
                        Entry_Item Attachments.EstimateIdno
                        Set pbEditable to False
                        Set piWidth to 72
                        Set psCaption to "EstimateIdno"
                    End_Object

                    Object oAttachments_QuoteIdno is a cDbCJGridColumn
                        Entry_Item Attachments.QuoteIdno
                        Set pbEditable to False
                        Set piWidth to 72
                        Set psCaption to "QuoteIdno"
                    End_Object

                    Object oAttachments_JobNumber is a cDbCJGridColumn
                        Entry_Item Attachments.JobNumber
                        Set pbEditable to False
                        Set piWidth to 72
                        Set psCaption to "JobNumber"
                    End_Object

                    Object oAttachments_InvoiceIdno is a cDbCJGridColumn
                        Entry_Item Attachments.InvoiceIdno
                        Set pbEditable to False
                        Set piWidth to 72
                        Set psCaption to "InvoiceIdno"
                    End_Object
                End_Object

//                Procedure OnFileDropped String sFilename Boolean bLast
//                    Showln "File Drop: " sFileName " " bLast
//                End_Procedure
            End_Object

            
            
        End_Object
    
    End_Object

    Register_Object oOrderEntry
    //
    Procedure DoViewOrder
        Integer iRecId
        //
        Send Refind_Records of oQuotehdr_DD
        Clear Order
        Move Quotehdr.JobNumber to Order.JobNumber
        Find eq Order.JobNumber
        If (Found) Begin
            Send DoViewOrder of oOrderEntry Order.Recnum
        End
    End_Procedure

    Procedure Request_Save
        Forward Send Request_Save
    End_Procedure
    
    Function IsSavedHeader Returns Integer
        Integer iRecId eStatus
        //
        Get Current_Record of oQuotehdr_DD to iRecId
        //
        If (iRecId = 0) Begin
            Send Request_Save
            Get_Attribute DF_FILE_STATUS of Quotehdr.File_Number to eStatus
            If (eStatus <> DF_FILE_ACTIVE) Begin
                Send Stop_Box "No Quote created/selected"
                Function_Return 1
            End
        End
    End_Function

//    Procedure DoQuoteWizard
//        Integer iRecId
//        //
//        Get DoQuoteWizard of oQuoteWizardPanel to iRecId
//        //
//        If (iRecId) Begin
//            Send Find_By_Recnum of oQuotehdr_DD Quotehdr.File_Number iRecId
//        End
//        Send Activate of oQuotehdr_QuotehdrID
//    End_Procedure

    Procedure DoViewQuote Integer iQuotehdrIdno
        Send Request_Clear
        If (iQuotehdrIdno) Begin
            Move iQuotehdrIdno to Quotehdr.QuotehdrID
            Send Find of oQuotehdr_DD EQ 1
        End
        Send Activate_View
    End_Procedure

    Procedure DoCloneQuote
        Boolean bCancel bOk
        Integer iQuoteHdrId iHdrRecId iDtlRecId iNewCustomer iNewLocation iNewContact
        Date    dToday
        RowID riContact riCustomer
        //
        Get Confirm "Clone Quote?" to bCancel
        If (not(bCancel)) Begin
            //Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.Status to "R"
            //Send Request_Save       of oQuotehdr_DD
            Move Quotehdr.QuotehdrID                                      to iQuoteHdrId
            //
            Send ChangeAllFileModes DF_FILEMODE_READONLY
            Set_Attribute DF_FILE_MODE of System.File_Number   to DF_FILEMODE_DEFAULT
            Set_Attribute DF_FILE_MODE of Quotehdr.File_Number to DF_FILEMODE_DEFAULT                 
            Set_Attribute DF_FILE_MODE of Quotedtl.File_Number to DF_FILEMODE_DEFAULT
            //
            Sysdate dToday
            Reread
            Add 1 to System.QuoteHdrId
            SaveRecord System
            //
            Get Confirm "Change Customer or Location?" to bCancel
            If (not(bCancel)) Begin
                Get IsSelectedCustomer of Customer_sl (&iNewCustomer) to bOk
                Get IsSelectedLocation of Location_sl iNewCustomer  to iNewLocation
                Get SelectContact of Contact_sl (&iNewContact) to bOk
//                Move Customer.Name to Quotehdr.Organization
//                Move Location.Name to Quotehdr.LocationName
            End            
            //
            If (iNewCustomer or iNewLocation or iNewContact) Begin
                Move Customer.CustomerIdno to Quotehdr.CustomerIdno
                Move Location.LocationIdno to Quotehdr.LocationIdno
                Move Contact.ContactIdno  to Quotehdr.ContactIdno
                Move Customer.Name to Quotehdr.Organization
                Move Location.Name to Quotehdr.LocationName
            End

            Move 0                 to Quotehdr.Recnum
            Move System.QuoteHdrId to Quotehdr.QuotehdrID
            Move dToday            to Quotehdr.QuoteDate
            Move 0                 to Quotehdr.ExpirationDate
            Move 0                 to Quotehdr.JobNumber
            Move 0                 to Quotehdr.OrderDate
            Move 0                 to Quotehdr.CloseDate
            Move 0                 to Quotehdr.EstimateReference
            Move 0                 to Quotehdr.Probability
            Move 0                 to Quotehdr.LockedFlag
            Move "P"               to Quotehdr.Status
            Move iQuoteHdrId       to Quotehdr.CloneReference
            SaveRecord Quotehdr
            Unlock
            Move Quotehdr.Recnum   to iHdrRecId
            //
            If (iHdrRecId <> 0) Begin
                Clear Quotedtl
                Move iQuoteHdrId to Quotedtl.QuotehdrID
                Find ge Quotedtl.QuotehdrID
                While ((Found) and Quotedtl.QuotehdrID = iQuoteHdrId)
                    
                    Move Quotedtl.Recnum   to iDtlRecId
                    Reread
                    Add 1                  to System.QuoteDtlId
                    SaveRecord System
                    //
                    Move 0                 to Quotedtl.Recnum
                    Move System.QuoteDtlId to Quotedtl.QuotedtlID
                    Move System.QuotehdrID to Quotedtl.QuotehdrID
                    Saverecord Quotedtl
                    Unlock
                    //
                    Clear Quotedtl
                    Move iDtlRecId to Quotedtl.Recnum
                    Find eq Quotedtl.Recnum
                    Find gt Quotedtl.QuotehdrID
                Loop
                Send Clear_All      of oQuotehdr_DD
                Send Find_By_Recnum of oQuotehdr_DD Quotehdr.File_Number iHdrRecId
            End
            Send ChangeAllFileModes DF_FILEMODE_DEFAULT                
        End
        Send Activate of oQuotehdr_QuotehdrID
    End_Procedure

    Function CreateOrderNow Integer iEstimateRef Integer iQuoteIdno Returns Integer
        Integer iJobNumber
        Boolean bCancel
        Date dToday
        Sysdate dToday
        Integer eResponse iRecId iErrors iCreated

        //
        If (Quotehdr.BillingType = "T" or Quotehdr.BillingType = "N" or (giUserRights>=60 and (Quotehdr.BillingType = "S" or Quotehdr.BillingType = "M"))) Begin
            
            Send Info_Box "When creating Orders from Quotes, please remember to fill out Special Instructions on the Order" "Creating Orders from Quotes"
            Send Refind_Records of oQuotehdr_DD
            Get DoCreateOrderFromQuote of oQuoteToOrder iQuoteIdno to iJobNumber
            If (iJobNumber <>0) Begin
                Clear Order
                Move iJobNumber to Order.JobNumber
                Find EQ Order by 1
                //
                Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.JobNumber    to Order.JobNumber
                Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.OrderDate    to Order.JobOpenDate
                Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.Status       to "W"
                Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.LockedFlag   to 1
                Send Request_Save       of oQuotehdr_DD
                //
                Get DoAddUniversalMastOpsToLocation of oOperationsProcess Location.LocationIdno Quotehdr.WorkType (&iErrors) to iCreated
                If (iErrors > 1) Begin
                    Send Info_Box (String(iCreated) * "Operations created." * String(iErrors) * "errors.")
                End
                Send Activate of oQuotehdr_QuotehdrID
                Function_Return iJobNumber
            End
        End
        Else Begin 
            // Estimate is required for an Order
            If (iEstimateRef = 0) Begin //Estimate Required - Build Estimate now.
                Move (YesNo_Box("Estimate/Job Plan required - create now?", "Estimate/Job Plan required", MB_DEFBUTTON1)) to eResponse
                If (eResponse = MBR_Yes) Begin
                    // Open Estimating tables and create Header.
                    Get DoCreateEstimateFromQuote of oQuoteToEstimate iQuoteIdno to iEstimateRef
                    Move iEstimateRef to Quotehdr.EstimateReference
                    SaveRecord Quotehdr
                    If (iEstimateRef<>0) Begin
                        Send DoCallFromClient to oRPCClient iEstimateRef "oEstimate"                       
                    End
                End
                Else Begin
                    Send Info_Box "Order was not created." "Canceled"
                    Function_Return
                End
            End
            Else Begin
                // Estimate exists - create order
                //Send Info_Box "Send DoCreateOrderFromEstimate" "Action"
                Get DoCreateOrderFromEstimate of oOrderProcess iEstimateRef to iJobNumber
                If (iJobNumber <>0) Begin
                    Clear Order
                    Move iJobNumber to Order.JobNumber
                    Find EQ Order by 1
                    Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.JobNumber    to Order.JobNumber
                    Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.OrderDate    to Order.JobOpenDate
                    Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.Status       to "W"
                    Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.LockedFlag   to 1
                    Send Request_Save       of oQuotehdr_DD
                    //
                    Get DoAddUniversalMastOpsToLocation of oOperationsProcess Location.LocationIdno Quotehdr.WorkType (&iErrors) to iCreated
                    If (iErrors > 1) Begin
                        Send Info_Box (String(iCreated) * "Operations created." * String(iErrors) * "errors.")
                    End
                    Send Activate of oQuotehdr_QuotehdrID
                    Function_Return iJobNumber
                End
            End
        End
    End_Function
    
    
    
// BEN - Commented out to use later to send Invoices to 
//    Procedure DoCreatePMInvoice
//        // expectation is this will get more complex down the road
//        Integer iRecId iErrors iCreated
//        Get DoCreatePMInvoiceFromQuote of oPMInvoiceFromQuote Quotehdr.Recnum True to iRecId // True = use quotedtl table as line item source, false = use esitem
//        If (iRecId and pminvhdr.Recnum <> iRecId) Begin 
//            Clear pminvhdr
//            Move iRecId to pminvhdr.Recnum
//            Find eq pminvhdr.Recnum
//        End
//    End_Procedure

    Procedure DoCreateQuote Integer iCustomerIdno Integer iLocationIdno
        Integer hoDD
        //
        Get Server to hoDD
        Send Clear_All of hoDD
        Move iCustomerIdno to Customer.CustomerIdno
        Send Request_Find of hoDD EQ Customer.File_Number 1
        Move iLocationIdno to Location.LocationIdno
        Send Request_Find of hoDD EQ Location.File_Number 1
        Send Activate_View
    End_Procedure

End_Object
