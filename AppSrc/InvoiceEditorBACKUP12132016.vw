#IFDEF ShellExecuteA
#ELSE
External_Function ShellExecuteA "ShellExecuteA" shell32.dll ;
    Handle hWnd         ;
    String lpOperation  ;
    String lpFile       ;
    String lpParameters ;
    String lpDirectory  ;
    DWord iShowCmd      ;
    Returns Handle
#ENDIF


Use Customer.DD
Use Location.DD
Use Event.DD
Use Invhdr.DD
Use Invdtl.DD
Use Opers.DD
Use Areas.DD
Use Order.DD
Use SalesRep.DD
Use Employer.DD
Use Employee.DD
Use Trans.DD
Use MastOps.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd

Use Operations_SL.sl

Use Windows.pkg
Use DFClient.pkg
Use cGlblDbForm.pkg
Use cGlblDbList.pkg
Use cGlblDbContainer3d.pkg
Use cTempusDbView.pkg
Use cDbTextEdit.pkg
Use szcalendar.pkg
Use InvoiceCreationProcess.bp
Use TransactionCostCalculator.bp

Use cGlblGrid.pkg
Use cComDbSpellText.pkg
Use Functions.pkg
Use cDbCJGrid.pkg

Register_Object oCustomerInvoice
Register_Object oWSTransactionService

Deferred_View Activate_oInvoiceEditor for ;
Object oInvoiceEditor is a cTempusDbView

    Property String psActivityType

    Function DataLossConfirmation Returns Integer
        Integer bCancel
        //
        If (not(Changed_State(oInvhdr_DD))) Begin
            Function_Return
        End
        Else Begin
            Get Confirm "Abandon Invoice Header Changes?" to bCancel
            Function_Return bCancel
        End
    End_Function

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object


    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
    End_Object

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oEmployer_DD
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

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oLocation_DD
        
        Procedure OnConstrain
            //Constrain Order.WorkType eq "S"
            //Constrain Order.JobCloseDate eq 0
            //Constrain Order.PromiseDate eq 0
            Constrain Order.Status eq "O"
            
            If (giUserRights LT "60") Begin
                Constrain Order.RepIdno eq giSalesRepId
            End
            
        End_Procedure
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oMastOps_DD
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD
        //Set Ordering to 5
//
//        Procedure OnConstrain
//            Forward Send OnConstrain
//            //
//            If (psActivityType(Self) <> "") Begin
//                Constrain Opers.ActivityType eq (psActivityType(Self))
//                Constrain Opers.Status eq "A"
//               
//            End
//        End_Procedure

//        Procedure OnConstrain
//            //Constrain Opers.ActivityType eq "Snow Removal"
//            Constrain Opers.Status eq "A"   
//        End_Procedure
    End_Object

    Object oTrans_DD is a Trans_DataDictionary
        Set Constrain_file to Opers.File_number
        Set DDO_Server to oOpers_DD
        Set DDO_Server to oOrder_DD
        Set DDO_Server to oEmployee_DD
    End_Object

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server to oOrder_DD
        Set Cascade_Delete_State to False
        Set No_Delete_State to True
        Set Ordering to 8

        Procedure OnConstrain
            Forward Send OnConstrain
            Constrain Invhdr.EditFlag eq 0
            Constrain Invhdr.VoidFlag eq 0
//            Constrain Invhdr.PrintFlag eq 0
//            Constrain Invhdr.PostFlag  eq 0
        End_Procedure
    End_Object

    Object oInvdtl_DD is a Invdtl_DataDictionary
        Set DDO_Server to oOpers_DD
        Set Constrain_file to Invhdr.File_number
        Set DDO_Server to oInvhdr_DD
        Send DefineAllExtendedFields
    End_Object

    Set Main_DD to oInvhdr_DD
    Set Server to oInvhdr_DD

    Set Border_Style to Border_Thick
    Set Size to 390 720
    Set Location to 3 3
    Set Label to "Invoice Editor"
    Set Verify_Data_Loss_Msg to get_DataLossConfirmation
    Set Verify_Exit_msg to get_DataLossConfirmation
    Set piMinSize to 390 720


//        Object oAreaForm is a dbForm
//            Set Size to 13 60
//            Set Location to 4 50
//            Set Prompt_Button_Mode to PB_PromptOn
//            Set Label to "Area:"
//            Set Label_Col_Offset to 3
//            Set Label_Justification_Mode to JMode_Right
//            Set Prompt_Object to Areas_SL
//            Set Form_Datatype to 0
//         End_Object

    Object oNewInvoiceGroup is a Group
        Set Size to 81 115
        Set Location to 3 5
        Set Label to 'Create New Invoice'
    
        Object oBeginDate is a cszDatePicker
            Set Location to 9 47
            Set Size to 13 62
            Set Label to "Begin Date:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Label_TextColor to clRed
            Set Prompt_Button_Mode to PB_PromptOn
        End_Object
    
        Object oEndDate is a cszDatePicker
            Set Location to 23 47
            Set Size to 13 62
            Set Label to "End Date:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Label_TextColor to clRed
            Set Prompt_Button_Mode to PB_PromptOn
        End_Object
        
        Object oCreateHeaderButton is a Button
            Set Size to 14 52
            Set Location to 38 10
            Set Label to "Single Invoice"
        
            Procedure OnClick
                Send CreateInvoice
            End_Procedure
        End_Object
        
        Procedure CreateInvoice
            Boolean bCancel bDateOverlap bDateGap
            Integer iJobNumber iRecId iDays iDayCount iAdjustDateResponse iImportDetailResponse
            String  sWorkType sDateError
            Date    dBegin dEnd dToday dAdjustedInvoiceStartDate
            //
            Sysdate dToday
            //
            Get Value of oBeginDate  to dBegin
            Get Value of oEndDate    to dEnd
            //
            Get psActivityType       to sWorkType
            Move (Left(sWorkType,1)) to sWorkType
            //

            If (dBegin <> 0 and dEnd <> 0) Begin                    // Checking if date range is entered
                Move (dEnd - dBegin) to iDays
                Increment               iDays
                If (iDays >= 1) Begin                           // Checking if Start Date is on or before StopDate
//                        If (dBegin < dToday and dEnd < dToday) Begin       // Checking if date range is befor todays date
                        Get IsSelectedJobNumber of Order_sl sWorkType True to iJobNumber    // Requesting the JobNumber to invoice for
                        If (not(iJobNumber)) Begin
                            Send Stop_Box "No job selected"
                            Procedure_Return
                        End

                        Open Invhdr
                        Constrain Invhdr.JobNumber matches iJobNumber
                        Constrain Invhdr.VoidFlag matches 0
                        Constrained_Find Last Invhdr by Index.2
                        If (Found) Begin
                            Move (Invhdr.StopDateRange+1) to dAdjustedInvoiceStartDate
                            //
                            If (dBegin <> dAdjustedInvoiceStartDate) Begin
                                Move (YesNoCancel_Box("Last Invoice found: " * String(Invhdr.InvoiceIdno)*"-"* ;
                                String(Invhdr.StartDateRange)*"-"* String(Invhdr.StopDateRange);
                                +"\n \nAdjust date range  to"* String(dAdjustedInvoiceStartDate)*"-"* String(dEnd), "Adjust Date range?")) to iAdjustDateResponse
                            
                            If (iAdjustDateResponse = MBR_Yes) Move dAdjustedInvoiceStartDate to dBegin
                            If (iAdjustDateResponse = MBR_No) Send Info_Box ("Dates range"* String(dBegin)*"-"* String(dEnd)* "will be used")
                            If (iAdjustDateResponse = MBR_Cancel) Begin
                                Send Info_Box ("Invoice Creation process was canceled")
                                Procedure_Return
                            End
                            End
                            
                        End
                        Else Begin
                            Send Info_Box ("No previous Invoices for Job# " + (String(iJobNumber)) + " found" )
                        End
                        //
                        Move (YesNoCancel_Box("Do you want to import the Transactions into the Invoice Detail?", "Import Invoice Detail?")) to iImportDetailResponse
                        If (iImportDetailResponse = MBR_Yes) Begin
                            Get DoCreateInvoiceForJobAndDates of oInvoiceCreationProcess iJobNumber dBegin dEnd to iRecId
                        End
                        If (iImportDetailResponse = MBR_No) Begin
                            Get DoCreateInvoiceHeader of oInvoiceCreationProcess iJobNumber dBegin dEnd to iRecId
                        End
                        If (iImportDetailResponse = MBR_Cancel) Begin
                            Send Info_Box ("Invoice Creation process was canceled")
                            Procedure_Return
                        End
//                        End // Future Dates Checker
//                        Else Begin
//                            Send Stop_Box "You can not create an Invoice for todays or future dates"
//                        End
                End
                Else Begin
                    Send Stop_Box "Start Date must be on or before Stop Date"
                End
            End
            Else Begin
                Send Stop_Box "No date range entered"
            End
            //Send Activate of oHeaderList
            //Send Refresh_Page   of oHeaderList FILL_FROM_TOP// FILL_FROM_CENTER
            
            
            If (iRecId) Begin
                Send Delete_Data of oCallCenterGrid
                Send KeyAction   of oRetrieveButton
                // As per sales request - retain date values
                //Set Value of oBeginDate to ""
                //Set Value of oEndDate to ""
                
                
                Send Find_By_Recnum of oInvhdr_DD Invhdr.File_Number iRecId
                Send Find           of oInvdtl_DD FIRST_RECORD 2
                Send End_of_Data    of oHeaderList
                Send Refresh_Page   of oHeaderList FILL_FROM_TOP// FILL_FROM_CENTER
            End
        End_Procedure

        Object oMonthlyRadioGroup is a RadioGroup
            Set Location to 54 6
            Set Size to 22 105
            Set Label to 'Monthly Options'
        
            Object oSnowMonthlyRadio is a Radio
                Set Size to 10 50
                Set Location to 10 13
                Set Label to 'Snow'
            End_Object
            
            Object oSweepingMonthlyRadio is a Radio
                Set Size to 10 50
                Set Location to 10 54
                Set Label to 'Sweeping'
            End_Object
        
            Procedure Notify_Select_State Integer iToItem Integer iFromItem
                Forward Send Notify_Select_State iToItem iFromItem\
                //for augmentation
            End_Procedure
            //If you set Current_Radio, you must set it AFTER the
            //radio objects have been created AND AFTER Notify_Select_State has been
            //created. i.e. Set in bottom-code of object at the end!!
        
            Set Current_Radio to 0
        
        End_Object

        Object oMonthlyInvoiceButton is a Button
            Set Size to 14 45
            Set Location to 38 64
            Set Label to 'Monthlies'
            Set psToolTip to "Creates the Monthly invoices for a selected date range"
        
            // fires when the button is clicked
            Procedure OnClick
                Boolean bCancel bSuccess
                String sWorkType
                Integer iOrderCount iLoopCounter iActivitySelection
                Integer[] iFoundOrderNumber iFoundMastOps
                String[] sMonthlyActivityType
                String[] sSelectedActivities
                Date    dBegin dEnd
                //
                Get Value of oBeginDate  to dBegin
                Get Value of oEndDate    to dEnd
                
                Get Current_Radio of oMonthlyRadioGroup to iActivitySelection
                If (iActivitySelection=0) Begin
//                    Move "Snow Removal" to sMonthlyActivityType[0]
                    Move "S" to sWorkType
                End
                Else If (iActivitySelection=1) Begin
//                    Move "Sweeping" to sMonthlyActivityType[0]
//                    Move "Other" to sMonthlyActivityType[1]
//                    Move "Misc" to sMonthlyActivityType[2]
                    Move "SW" to sWorkType
                End

                // Popup Prompt with multi Selection
                
                If ((dBegin <> 0) and (dEnd <> 0)) Begin
                    Get Confirm ("Do you want to continue to create monthly invoices from" * String(dBegin) * "thru" * String(dEnd) * "?") to bCancel
                    If (not(bCancel)) Begin
                        // Lawn Care    ==> Order.WorkType = "M" // Mowing
                        //              ==> MastOps.ActivityType = "Lawn Care"
                        // Snow Removal ==> Order.WorkType = "S"    // Snow Removal
                        //              ==> MastOps.ActivityType = "Snow"

                        Move "0" to iOrderCount
                        Clear Order
                        Constraint_Set 1
                        //Constrain Order.MonthlyBilling eq "1"
                        Constrain Order.BillingType eq "M"
                        Constrain Order.WorkType eq sWorkType
                        Constrain Order.Status eq "O"
                        Constrained_Find First Order by 1
                        While (Found)
                            Move Order.JobNumber to iFoundOrderNumber[iOrderCount]
                            Increment iOrderCount
                            Constrained_Find Next
                        Loop
                        Constraint_Set 1 Delete
                        If (iOrderCount<>0) Begin
                            Get Confirm ("We have found" * (String(iOrderCount)) * "Monthly orders. \n\n Create all Monthly invoices?") to bCancel
                            If (not(bCancel)) Get DoCreateMonthlyInvoice of oInvoiceCreationProcess iFoundOrderNumber sSelectedActivities dBegin dEnd to bSuccess
                            If (bSuccess) Send Refresh_Page       of oHeaderList FILL_FROM_CENTER                            
                        End

                    End
                    Else Send Info_Box ("Monthly invoice process canceled!") "Process Canceled"
                End
                Else Send Info_Box "Please enter a DateRange"
                
                
            End_Procedure
        
        End_Object
        
//        Procedure DoMonthlies
//            Boolean bCancel bRan
//            String sMonthlyActivityType sWorkType
//            Integer iOrderCount iMastOpsCount iLoopCounter iActivitySelection
//            Integer[] iFoundOrderNumber iFoundMastOps
//            Date    dBegin dEnd
//            //
//            Get Value of oBeginDate  to dBegin
//            Get Value of oEndDate    to dEnd
//            
//            Get Current_Radio of oMonthlyRadioGroup to iActivitySelection
//            If (iActivitySelection=0) Begin
//                Move "Snow Removal" to sMonthlyActivityType
//                Move "S" to sWorkType
//            End
//            Else If (iActivitySelection=1) Begin
//                Move "Sweeping" to sMonthlyActivityType
//                Move "SW" to sWorkType
//            End
//
//            If ((dBegin <> 0) and (dEnd <> 0)) Begin
//                Get Confirm ("Do you want to continue to create monthly invoices from" * String(dBegin) * "thru" * String(dEnd) *"for" * sMonthlyActivityType * "?") to bCancel
//                If (not(bCancel)) Begin
//                    // Lawn Care    ==> Order.WorkType = "SW" // Sweeping
//                    //              ==> MastOps.ActivityType = "Lawn Care"
//                    // Snow Removal ==> Order.WorkType = "S"    // Snow Removal
//                    //              ==> MastOps.ActivityType = "Snow"
//
//                    Move "0" to iOrderCount
//                    Clear Order
//                    Constraint_Set 1
//                    Constrain Order.MonthlyBilling eq "1"
//                    //Constrain Order.BillingType "M"
//                    Constrain Order.WorkType eq sWorkType
//                    Constrain Order.Status eq "O"
//                    Constrained_Find First Order by 1
//                    While (Found)
//                        Move Order.JobNumber to iFoundOrderNumber[iOrderCount]
//                        Increment iOrderCount
//                        Constrained_Find Next
//                    Loop
//
//                    Move "0" to iMastOpsCount
//                    Clear MastOps
//                    Constraint_Set 2
//                    Constrain MastOps.ActivityType eq sMonthlyActivityType
//                    //Constrain MastOps.IsMonthly eq "1"
//                    Constrained_Find First MastOps by 1
//                    While (Found)
//                        Move MastOps.MastOpsIdno to iFoundMastOps[iMastOpsCount]
//                        Increment iMastOpsCount 
//                        Constrained_Find Next
//                    Loop
//                    
//                    Get Confirm ("We have found" * (String(iOrderCount)) * "orders and" * (String(iMastOpsCount)) *" monthly MastOps - continue?") to bCancel
//                    If (not(bCancel)) Get DoCreateMonthlyInvoice of oInvoiceCreationProcess iFoundOrderNumber iFoundMastOps iOrderCount iMastOpsCount dBegin dEnd to bRan
//                    If (bRan) Send Refresh_Page       of oHeaderList FILL_FROM_CENTER
//                End
//                Else Send Info_Box ("Monthly invoice process canceled!") "Process Canceled"
//            End
//            Else Send Info_Box "Please enter a DateRange"
//        End_Procedure //DoMonthlies
//
//        Object oMonthlyInvoiceButton is a Button
//            Set Size to 14 45
//            Set Location to 41 60
//            Set Label to 'Monthlies'
//            Set psToolTip to "Creates the Monthly invoices for a selected date range"
//        
//            // fires when the button is clicked
//            Procedure OnClick
//
//            End_Procedure
//        
//        End_Object
        
    End_Object
    
    Object oInvoiceOptionsGroup is a Group
        Set Size to 28 113
        Set Location to 85 6
        Set Label to 'Invoice Options'
        
        Object oClearButton is a Button
            Set Size to 15 30
            Set Location to 9 80
            Set Label to "Clear"
            Set peAnchors to anTopRight
        
            Procedure OnClick
                Send DoClearInvoice
            End_Procedure
        End_Object
    
        Object oVoidButton is a Button
            Set Size to 15 30
            Set Location to 9 5
            Set Label to "Void"
            Set peAnchors to anTopRight
        
            Procedure OnClick
                Send DoVoidInvoice
            End_Procedure
        End_Object
    
        Object oPrintButton is a Button
            Set Size to 15 30
            Set Location to 9 43
            Set Label to "Print"
            Set peAnchors to anTopRight
        
            Procedure OnClick
                Send DoPrintInvoice
            End_Procedure
        End_Object

    End_Object

    Object oHeaderList is a cGlblDbList
        Set Size to 111 590
        Set Location to 2 124
        Set Move_Value_Out_State to False

        Begin_Row
            Entry_Item Invhdr.InvoiceIdno
            Entry_Item Invhdr.InvoiceDate
            Entry_Item (BuildDateRange(Self, Invhdr.StartDateRange, Invhdr.StopDateRange))
            Entry_Item Order.JobNumber
            Entry_Item Location.Name
            Entry_Item Invhdr.TaxTotal
            Entry_Item Invhdr.TotalAmount
            Entry_Item SalesRep.LastName
        End_Row

        Set Main_File to Invhdr.File_number

        Set Form_Width 0 to 47
        Set Header_Label 0 to "Invoice#"
        Set Header_Justification_Mode 0 to JMode_Right
        Set Form_Width 1 to 60
        Set Header_Label 1 to "Date"
        Set Form_Width 2 to 90
        Set Header_Label 2 to "Cost Date Range"
        Set Form_Width 4 to 150
        Set Header_Label 4 to "Location"
        Set Form_Width 5 to 65
        Set Header_Label 5 to "Sales Tax"
        Set Header_Justification_Mode 5 to JMode_Right
        Set Form_Width 6 to 96
        Set Header_Label 6 to "Total"
        Set Header_Justification_Mode 6 to JMode_Right
        Set Form_Width 7 to 180
        Set Header_Label 7 to "Sales Rep"
        Set Form_Width 3 to 48
        Set Header_Label 3 to "JobNumber"
        
        Set peAnchors to anTopLeftRight
        Set peResizeColumn to rcSelectedColumn
        Set piResizeColumn to 1
        Set Auto_Index_State to False
        Set pbUseServerOrdering to True
        Set piMinSize to 75 450

        Procedure Item_Change Integer iFromItem Integer iToItem Returns Integer
            Integer iRetVal
            Forward Get msg_Item_Change iFromItem iToItem to iRetVal
            
            Send EmptyGrid of oCallCenterGrid
            
            Procedure_Return iRetVal
        End_Procedure

// BEN Commented out for performance reasons 01/15/2012
//
//        Procedure Refresh Integer iMode
//            Forward Send Refresh iMode
//            //
//            Send Delete_Data of oCallCenterGrid
//            Send KeyAction   of oRetrieveButton
//        End_Procedure
        
    End_Object

    Object oDetailContainer is a cGlblDbContainer3d
        Set Server to oInvdtl_DD
        Set Size to 201 707
        Set Location to 116 7
        Set Border_Style to Border_None
        Set peAnchors to anAll

        Object oDetailGrid is a DbGrid
            Set Location to 1 3

            Function Child_Entering Returns Integer
                Integer iRetval iRecId
                // Check with header to see if it is saved.
                Delegate Get IsSavedHeader to iRetval
                //
                If (iRetval = 0) Begin
                    Get Current_Record  of oInvdtl_DD to iRecId
                    Send Find_By_Recnum of oInvdtl_DD Invdtl.File_Number iRecId
                End
                //
                Function_Return iRetval // if non-zero do not enter
            End_Function  // Child_Entering

            Procedure Prompt_Callback Integer hPrompt
                Forward Send Prompt_Callback hPrompt
                Set piUpdateColumn of hPrompt to 0
                Set pbAutoServer of hPrompt to False
            End_Procedure

            Procedure Prompt
                Integer iCol iRecId iLocationIdno iCurrOpers iCurrDDOpers iNewSelectedOpers iAttachOpersIdno iAttachMastOpsIdno
                Number nEquipSellRate nAttachSellRate
                String sNeedsAttachCat sAttachOperName sAttachOperDesc sDescription
                //
                Get Current_Col                 to iCol
                Send Refind_Records of oInvdtl_DD
                Get Current_Record of oOpers_DD to iRecId
                Get Field_Current_Value of oOpers_DD Field Opers.OpersIdno to iCurrDDOpers
                Move Invdtl.OpersIdno to iCurrOpers
                //
                Move Invhdr.LocationIdno to iLocationIdno
                
                If (iCol = 2) Begin
                    Get DoInvoicePrompt of Operations_SL iCurrOpers iLocationIdno "" "" to iNewSelectedOpers
                    //Forward Send Prompt
                    //Send Refind_Records of oOpers_DD
                    //If (iCurrOpers <> iNewSelectedOpers) Begin
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.Price to Opers.SellRate
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.Description to Opers.Description
                        Get Field_Current_Value of oInvdtl_DD Field Invdtl.Price to nEquipSellRate                    
                    //End
                    // Needs attachment?

                    Move MastOps.NeedsAttachment to sNeedsAttachCat
                    If (sNeedsAttachCat <> "NONE") Begin
                        Get DoInvoiceAttachPrompt of Operations_SL ;
                        iAttachOpersIdno iLocationIdno "Attachment" sNeedsAttachCat ;
                        (&sAttachOperName) (&sAttachOperDesc) (&iAttachMastOpsIdno) (&nAttachSellRate) to iAttachOpersIdno
                        //Adjust New Description
                        Get Field_Current_Value of oInvdtl_DD Field Invdtl.Description to sDescription
                        Append sDescription (" " + sAttachOperDesc)
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachOpersIdno to iAttachOpersIdno
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachMastOpsIdno to iAttachMastOpsIdno
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachOpersName to sAttachOperName
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachOpersDescription to sAttachOperDesc
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.Price to (nEquipSellRate+nAttachSellRate)
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.Description to sDescription                                
                    End
                    Else Begin
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachOpersIdno to 0
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachMastOpsIdno to 0
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachOpersName to ""
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachOpersDescription to ""
                    End
                    //Find Opers Record
                    Move iNewSelectedOpers to Opers.OpersIdno
                    Send Request_Find of oOpers_DD EQ Opers.File_Number 1  
                End
            End_Procedure

            Procedure Request_Clear
                If (Changed_State(oInvdtl_DD)) Begin
                    Forward Send Request_Clear
                End
                Else Begin
                    Send Add_New_Row 0
                End
            End_Procedure

            Function DataLossConfirmation Returns Integer
                Integer bCancel
                //
                If (not(Changed_State(oInvhdr_DD))) Begin
                    Function_Return
                End
                Else Begin
                    Get Confirm "Abandon Invoice Detail Changes?" to bCancel
                    Function_Return bCancel
                End
            End_Function

            Function AttachmentName Returns String
                String sAttchName
                Integer iAttachEquipIdno
                Boolean bChanged
                Move 0 to iAttachEquipIdno
                //
                Move InvDtl.AttachOpersIdno to iAttachEquipIdno
                Get Changed_State of oInvdtl_DD to bChanged
                If (bChanged) Get Field_Current_Value of oInvdtl_DD Field InvDtl.AttachOpersIdno to iAttachEquipIdno 
                //
                Open Equipmnt
                Clear Equipmnt
                Move iAttachEquipIdno to Equipmnt.EquipIdno
                Find EQ Equipmnt by Index.1
                If (Found) Begin
                    Move (Trim(Equipmnt.Description)) to sAttchName
                End
                Else Begin
                    Move "" to sAttchName
                End
                Function_Return sAttchName
            End_Function

            Set Size to 119 703
            Set Wrap_State to True
            Set Child_Table_State to True
            Set Verify_Data_Loss_Msg to get_DataLossConfirmation
            Set Verify_Exit_msg to get_DataLossConfirmation
            Set peAnchors to anAll
            Set peResizeColumn to rcAll
            Set Ordering to 2
            Set Color to clWhite
            Set peDisabledColor to clWhite
            Set peDisabledTextColor to clGray //clBlack
            Set TextColor to clBlack
    
            Begin_Row
                Entry_Item Invdtl.Sequence
                Entry_Item Invdtl.StartDate
                Entry_Item Opers.Name
                Entry_Item Invdtl.AttachOpersName
                Entry_Item Invdtl.StartTime
                Entry_Item Invdtl.StopTime
                Entry_Item Invdtl.Quantity
                Entry_Item Invdtl.Price
                Entry_Item Invdtl.TaxAmount
                Entry_Item Invdtl.Total
            End_Row
    
            Set Main_File to Invdtl.File_number
    
            Set Form_Width 0 to 28
            Set Header_Label 0 to "Seq"
            Set Header_Justification_Mode 0 to JMode_Right

            Set Form_Width 1 to 46
            Set Header_Label 1 to "Date"

            Set Form_Width 2 to 145
            Set Header_Label 2 to "Item"
            Set Form_Button_Value 2 to "..."
            Set Form_Button 2 to Form_Button_Prompt
            
            Set Header_Label 3 to "Attachment"
            Set Form_Width 3 to 120            
            Set Column_Shadow_State 3 to True

            Set Form_Width 4 to 40
            Set Header_Label 4 to "Start"

            Set Form_Width 5 to 40
            Set Header_Label 5 to "Stop"

            Set Form_Width 6 to 48
            Set Header_Label 6 to "Hrs/Qty"
            Set Header_Justification_Mode 6 to JMode_Right

            Set Form_Width 7 to 60
            Set Header_Label 7 to "Rate"
            Set Header_Justification_Mode 7 to JMode_Right

            Set Form_Width 8 to 60
            Set Header_Label 8 to "Sales Tax"
            Set Header_Justification_Mode 8 to JMode_Right
            Set Column_Shadow_State 8 to True
            
            Set Form_Width 9 to 70
            Set Header_Label 9 to "Total"
            Set Header_Justification_Mode 9 to JMode_Right
            Set pbEmbeddedPrompts to True
            
        End_Object

////////////////////////////////////////////////////////////////////////////NEW GRID/////////////////////////////////////////////////////
//        Object oDbCJGrid1 is a cDbCJGrid
//            Set Size to 110 693
//            Set Location to 4 8
//            Set pbEditOnClick to True
//            Set peAnchors to anTopRight
//
//            Object oInvdtl_Sequence is a cDbCJGridColumn
//                Entry_Item Invdtl.Sequence
//                Set piWidth to 44
//                Set psCaption to "Seq."
//            End_Object
//
//            Object oInvdtl_StartDate is a cDbCJGridColumn
//                Entry_Item Invdtl.StartDate
//                Set piWidth to 74
//                Set psCaption to "StartDate"
//                Set peDataType to Date_Window
//            End_Object
//
//            Object oOpers_Name is a cDbCJGridColumn
//                Entry_Item Opers.Name
//                Set piWidth to 272
//                Set psCaption to "Name"
//                Set Prompt_Button_Mode to PB_PromptOn
//                Set pbAllowRemove to False
//                Set pbAllowDrag to False
//                Set pbResizable to False
//                Set pbEditable to False
//            End_Object
//
//            Object oInvdtl_AttachOpersName is a cDbCJGridColumn
//                Entry_Item Invdtl.AttachOpersName
//                Set piWidth to 248
//                Set psCaption to "Attachment"
//            End_Object
//
//            Object oInvdtl_StartTime is a cDbCJGridColumn
//                Entry_Item Invdtl.StartTime
//                Set piWidth to 108
//                Set psCaption to "StartTime"
//            End_Object
//
//            Object oInvdtl_StopTime is a cDbCJGridColumn
//                Entry_Item Invdtl.StopTime
//                Set piWidth to 110
//                Set psCaption to "StopTime"
//            End_Object
//
//            Object oInvdtl_Quantity is a cDbCJGridColumn
//                Entry_Item Invdtl.Quantity
//                Set piWidth to 87
//                Set psCaption to "Quantity"
//            End_Object
//
//            Object oInvdtl_Price is a cDbCJGridColumn
//                Entry_Item Invdtl.Price
//                Set piWidth to 88
//                Set psCaption to "Price"
//            End_Object
//
//            Object oInvdtl_TaxAmount is a cDbCJGridColumn
//                Entry_Item Invdtl.TaxAmount
//                Set piWidth to 89
//                Set psCaption to "TaxAmount"
//            End_Object
//
//            Object oInvdtl_Total is a cDbCJGridColumn
//                Entry_Item Invdtl.Total
//                Set piWidth to 92
//                Set psCaption to "Total"
//            End_Object
//
//            Procedure OnRowDoubleClick Integer iRow Integer iCol
//                Forward Send OnRowDoubleClick iRow iCol
//                Send Prompt
//            End_Procedure
//
//            Procedure Prompt
//                Integer iCol iRecId iLocationIdno iCurrOpers iCurrDDOpers iNewSelectedOpers iAttachOpersIdno iAttachMastOpsIdno
//                Number nEquipSellRate nAttachSellRate
//                String sNeedsAttachCat sAttachOperName sAttachOperDesc sDescription
//                //
//                Get Current_Col                 to iCol
//                Send Refind_Records of oInvdtl_DD
//                Get Current_Record of oOpers_DD to iRecId
//                Get Field_Current_Value of oOpers_DD Field Opers.OpersIdno to iCurrDDOpers
//                Move Invdtl.OpersIdno to iCurrOpers
//                //
//                Move Invhdr.LocationIdno to iLocationIdno
//                
//                If (iCol = 2) Begin
//                    Get DoInvoicePrompt of Operations_SL iCurrOpers iLocationIdno "" "" to iNewSelectedOpers
//                    //Forward Send Prompt
//                    //Send Refind_Records of oOpers_DD
//                    If (iCurrOpers <> iNewSelectedOpers) Begin
//                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.Price to Opers.SellRate
//                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.Description to Opers.Description
//                        Get Field_Current_Value of oInvdtl_DD Field Invdtl.Price to nEquipSellRate
//                        //
//                        Move MastOps.NeedsAttachment to sNeedsAttachCat
//                        If (sNeedsAttachCat <> "NONE") Begin
//                            Get DoInvoiceAttachPrompt of Operations_SL ;
//                            iAttachOpersIdno iLocationIdno "Attachment" sNeedsAttachCat ;
//                            (&sAttachOperName) (&sAttachOperDesc) (&iAttachMastOpsIdno) (&nAttachSellRate) to iAttachOpersIdno
//                            //Adjust New Description
////                                Get Field_Current_Value of oInvdtl_DD Field Invdtl.Description to sDescription
////                                Append sDescription (" " + sAttachOperDesc)
//                            Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachOpersIdno to iAttachOpersIdno
//                            Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachMastOpsIdno to iAttachMastOpsIdno
//                            Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachOpersName to sAttachOperName
//                            Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachOpersDescription to sAttachOperDesc
//                            Set Field_Changed_Value of oInvdtl_DD Field Invdtl.Price to (nEquipSellRate+nAttachSellRate)
////                                Set Field_Changed_Value of oInvdtl_DD Field Invdtl.Description to sDescription                                
//                        End
//                        Else Begin
//                            Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachOpersIdno to 0
//                            Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachMastOpsIdno to 0
//                            Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachOpersName to ""
//                            Set Field_Changed_Value of oInvdtl_DD Field Invdtl.AttachOpersDescription to ""
//                        End
//                        //Find Opers Record
//                        Move iNewSelectedOpers to Opers.OpersIdno
//                        Send Request_Find of oOpers_DD EQ Opers.File_Number 1  
//                        
//                    End
//                        ///////////////////////
//                End
//            End_Procedure
//        End_Object
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////




        Object oInvdtl_Description is a cComDbSpellText //cDbTextEdit

            Property Boolean pbText
            Property Boolean pbChangedText
            Property Integer piRecId
            Property String  psText

            Entry_Item Invdtl.Description
            Set Location to 123 45
            Set Size to 69 529
            Set Label to "Description:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
            Set peAnchors to anBottomLeftRight

            Procedure OnCreate
                Forward Send OnCreate
                //Set the ActiveX properties here...
                Set ComDebugOption to OLEDebug_Actions
                Set ComMaxLength   to 2048
            End_Procedure
        
            Procedure Request_Save
                Send Next
            End_Procedure

//            Procedure Next
//                Set pbText to False
//                Send Activate of oDetailGrid
//            End_Procedure
    
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
                Set piRecId to (Current_Record(oInvdtl_DD))
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
                    Send ChangeAllFileModes DF_FILEMODE_READONLY
                    Set_Attribute DF_FILE_MODE of Invdtl.File_Number to DF_FILEMODE_DEFAULT
                    Get piRecId                                      to iRecId
                    If (Invdtl.Recnum <> iRecId) Begin
                        Clear Invdtl
                        Move iRecId to Invdtl.Recnum
                        Find eq Invdtl.Recnum
                    End
                    Get psText to sText
                    Reread
                    Move sText to Invdtl.Description
                    SaveRecord Invdtl
                    Unlock
                    Send ChangeAllFileModes DF_FILEMODE_DEFAULT
                    Set pbChangedText                                  to False
                End
                //
                
                Procedure_Return iRetval
            End_Procedure

            //Boolean bTest
            On_Key kNext_Item Send Activate of oDetailGrid
    
//            Procedure OnComLosingFocus
//                Boolean bChanged
//                Integer iRetval
//                String  sText
//                //
//                Get pbChangedText to bChanged
//                If (bChanged) Begin
//                    Get psText                                                         to sText
//                    Set Field_Changed_Value of oQuotedtl_DD Field Quotedtl.Description to sText
//                    Send Request_Save       of oQuotedtl_DD
//                    Set pbChangedText                                                  to False
//                End
//            End_Procedure
    
//            Procedure Next
//                Send Request_Save
//                Send Activate of oDetailGrid
//            End_Procedure
        End_Object

        Object oCurrentProfit is a cGlblDbForm
            Entry_Item (1-(Invhdr.TotalCost/Invhdr.TotalAmount)*100)
            Set Size to 13 69
            Set Location to 181 623
            Set Label to "Profit:"
            Set peAnchors to anBottomRight
            Set Label_Col_Offset to 5
            Set TextColor to clBlack
            Set Enabled_State to False
            Set Form_Datatype to Mask_Numeric_Window
            Set Label_Justification_Mode to JMode_Right
            Set Form_Mask to "#,###,##0.00 %"
            Set Form_Mask of oCurrentProfit to "#0.00 %"
        End_Object

        Object oInvhdr_TotalCost is a cGlblDbForm
            Entry_Item Invhdr.TotalCost
            Set Server to oInvhdr_DD
            Set Location to 166 623
            Set Size to 13 69
            Set Label to "Cost:"
            Set Label_Col_Offset to 20
            Set peAnchors to anBottomRight
            Set TextColor to clBlack
            Set Enabled_State to False
            Set Form_Datatype to Mask_Numeric_Window
            Set Form_Mask to "$ #,###,##0.00"
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oInvhdr_TotalAmount is a cGlblDbForm
            Entry_Item Invhdr.TotalAmount
            Set Server to oInvhdr_DD
            Set Location to 151 623
            Set Size to 13 69
            Set Label to "Total:"
            Set Label_Col_Offset to 5
            Set Enabled_State to False
            Set peAnchors to anBottomRight
            Set TextColor to clBlack
            Set Form_Datatype to Mask_Numeric_Window
            Set Form_Mask to "$ #,###,##0.00"
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oRefreshButton is a Button
            Set Size to 12 15
            Set Location to 166 604
            Set Bitmap to "refresh.bmp"
            Set peAnchors to anBottomRight
        
            // fires when the button is clicked
            Procedure OnClick
                Integer iJobNumber iInvoiceIdno iRecNum
                Date dStart dStop
                Number nTotalCurrentCost
                    
                Move Invhdr.InvoiceIdno to iInvoiceIdno            
                Move Invhdr.StartDateRange to dStart
                Move Invhdr.StopDateRange to dStop
                Move Invhdr.JobNumber to iJobNumber
                If (dStart > "0" and dStop > "0") Begin
                    Get CalculateCostForDateRange of oTransactionCostCalculator iJobNumber dStart dStop to nTotalCurrentCost
                    Reread Invhdr
                        Move nTotalCurrentCost to Invhdr.TotalCost
                        SaveRecord Invhdr
                    Unlock                    
                End
                Else Send Info_Box ("No Daterange defined for this invoice")
                //
                Get Current_Record of oInvhdr_DD to iRecNum
                Send Refind_Records of oInvhdr_DD
                Send Request_Assign of oInvhdr_DD
                //
            End_Procedure
        End_Object

        Object oInvhdr_SubTotal is a cGlblDbForm
            Entry_Item Invhdr.SubTotal
            Set Server to oInvhdr_DD
            Set Location to 121 623
            Set Size to 13 69
            Set Label to "SubTotal:"
            Set Enabled_State to False
            Set peAnchors to anBottomRight
            Set TextColor to clBlack
            Set Form_Datatype to Mask_Numeric_Window
            Set Form_Mask to "$ #,###,##0.00"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 5
        End_Object

        Object oInvhdr_TaxTotal is a cGlblDbForm
            Entry_Item Invhdr.TaxTotal
            Set Server to oInvhdr_DD
            Set Location to 136 623
            Set Size to 13 69
            Set Label to "Sales Tax"
            Set Label_Col_Offset to 5
            Set Enabled_State to False
            Set peAnchors to anBottomRight
            Set TextColor to clBlack
            Set Form_Datatype to Mask_Numeric_Window
            Set Form_Mask to "$ #,###,##0.00"
            Set Label_Justification_Mode to JMode_Right
        End_Object




//        Object oButton1 is a Button
//            Set Location to 152 1
//            Set Label to 'oButton1'
//        
//            // fires when the button is clicked
//            Procedure OnClick
//                String sDate
//                Integer iStatus
//                Send GetDateAndStatus of oInvoicePostingProcess (&sDate) (&iStatus)
//                Showln ("Date:"*sDate*"-Status"*String(iStatus))
//            End_Procedure
//        
//        End_Object
                
//        Object oCollectButton is a Button
//            Set Size to 14 160
//            Set Location to 94 307
//            Set Label to "Collect && Process Auto-Attendant Transactions"
//            Set peAnchors to anBottomRight
//        
//            Procedure OnClick
//                Integer iCount
//                //
//                Get DoCollectAndProcessTransactions of oCollectTransactionsProcess to iCount
//            End_Procedure
//        End_Object

//        Object oLocationNoteButton is a Button
//            Set Size to 14 160
//            Set Location to 109 307
//            Set Label to "Collect && Process Area && Location Notes"
//            Set peAnchors to anBottomRight
//        
//            Procedure OnClick
//                Integer iCount
//                //
//                Get DoCollectAndProcessLocationNotes of oCollectLocationNotesProcess to iCount
//                Get DoCollectAndProcessAreaNotes     of oCollectAreaNotesProcess     to iCount
//            End_Procedure
//        
//        End_Object

    End_Object

    Object oCallCenterTextBox is a TextBox
        Set Size to 10 81
        Set Location to 319 10
        Set Label to "Recent Call Center Activity"
        Set TextColor to clRed
        Set peAnchors to anBottomLeftRight
        Set Visible_State to False
    End_Object

    Object oCallCenterGrid is a cGlblGrid

        Property tWStLocnotes[] ptNotes
        Property Boolean pbFilled

        Set Location to 331 10
        Set Size to 57 599
    
        Set Line_Width to 6 0
    
        Set Form_Width 0 to 50
        Set Header_Label 0 to "Date"
    
        Set Form_Width    item 1 to 28
        Set Header_Label 1 to "Time"
    
        Set Form_Width    item 2 to 86
        Set Header_Label 2 to "By"

        Set Header_Label 3 to "Status"
        Set Form_Width 3 to 60

        Set Header_Label 4 to "Request Description"
        Set Form_Width 4 to 100

        Set Header_Label 5 to "Assigned To"
        Set Form_Width 5 to 90

        Set peAnchors to anBottomLeftRight
        Set peResizeColumn to rcSelectedColumn
        Set piResizeColumn to 4
        Set CurrentCellColor to clYellow
        Set CurrentCellTextColor to clBlack
        Set CurrentRowColor to clYellow
        Set CurrentRowTextColor to clBlack
        Set Highlight_Row_State to True
    
        Procedure AddReadOnlyItem String sValue //Boolean bNumber
            Integer iItem
            //
            Move (Item_Count(Self))                       to iItem
            Send Add_Item msg_None                           sValue
//            If (bNumber) Begin
//                Set Form_Datatype item iItem              to MASK_NUMERIC_WINDOW
//            End
            Set Entry_State item ((Item_Count(Self)) - 1) to False
        End_Procedure

        Procedure DoFillGrid tWStLocnotes[] tNotes
            Integer iItems iItem iUserId iL
            String  sUser sStatus sTime
            //
            Set ptNotes                to tNotes
            Set pbFilled               to False
            Set Dynamic_Update_State   to False
            Send Delete_Data
            Set Select_Mode            to Multi_Select
            //
            Move (SizeOfArray(tNotes)) to iItems
            Decrement iItems
            For iItem from 0 to iItems
                Move tNotes[iItem].iCreatedBy to iUserId
                Clear User
                Move iUserId to User.UserId
                Find eq User.UserId
                Move (trim(User.FirstName) * Trim(User.LastName)) to sUser
                //
                Move tNotes[iItem].sCreatedTime to sTime
                Move (Left(sTime,5))            to sTime
                //
                Move tNotes[iItem].sStatus   to sStatus
                Move (Length(sStatus))       to iL
                Move (Mid(sStatus,(iL-2),3)) to sStatus
                //
                Send AddReadOnlyItem tNotes[iItem].dCreatedDate
                Send AddReadOnlyItem sTime
                Send AddReadOnlyItem sUser
                Send AddReadOnlyItem sStatus
                Send AddReadOnlyItem tNotes[iItem].sReqtypesCode
                Send AddReadOnlyItem tNotes[iItem].sAssignedTo
            Loop
            //
            Set Select_Mode          to No_Select
            Set Dynamic_Update_State to True
            Set pbFilled             to True
            Set Current_Item         to 0
        End_Procedure  // DoFillGrid
        
        Procedure EmptyGrid
            Send Delete_Data of oCallCenterGrid
        End_Procedure
    
        Procedure DoDisplayCurrent
            tWStLocnotes[] tNotes
            Integer iCur iItem
            String  sRowId sPage sWorkspaceWSFile
            Handle  hoWorkspace hoIniFile hWnd hInstance
            //
            Get ptNotes               to tNotes
            Get Current_Item          to iCur
            Move (iCur / 6)           to iItem
            Move tNotes[iItem].sRowId to sRowId
            //
            Move (phoWorkSpace(ghoApplication))                                to hoWorkspace
            Get psWorkspaceWSFile of hoWorkspace                               to sWorkspaceWSFile 
            Get Create U_cIniFile                                              to hoIniFile
            Set psFilename        of hoIniFile                                 to sWorkspaceWSFile 
            Get ReadString        of hoIniFile "WebServices" "WebsiteRoot" " " to sPage
            Move (sPage + "/CallCenterUpdateItem.asp?RowId=" + sRowId)         to sPage
//            Move ("http://208.79.212.77/IRTest/CallCenterUpdateItem.asp?RowId=" + sRowId) to sPage
            //WebsiteRoot=http://208.79.212.77/IRTest
            Move (ShellExecuteA (hWnd, "open", (trim(sPage)), '', '', 1))      to hInstance
        End_Procedure  // DoDisplayCurrent
    End_Object

    Object oRetrieveButton is a Button
        Set Size to 14 90
        Set Location to 328 621
        Set Label to "Retrieve Recent Activity"
        Set peAnchors to anBottomRight
    
        Procedure OnClick
            Send RetrieveCallCenterActivity
        End_Procedure
    End_Object

    Object oViewButton is a Button
        Set Size to 14 90
        Set Location to 343 621
        Set Label to "View Selected Item"
        Set peAnchors to anBottomRight
    
        Procedure OnClick
            // http://208.79.212.77/IRTest/CallCenterUpdateItem.asp?RowId=1a000000
            Send DoDisplayCurrent of oCallCenterGrid
        End_Procedure
    End_Object

    Procedure RetrieveCallCenterActivity
        tWStLocnotes[] tNotes
        Integer iJobNumber iItems
        Date    dNoteDate dNoteStopDate
        //
        Send Cursor_Wait        of Cursor_Control
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.JobNumber                                to iJobNumber
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.StartDateRange                           to dNoteDate
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.StopDateRange                            to dNoteStopDate
        Move (dNoteDate - 1)                                                                        to dNoteDate
        Get wsGetSelectedLocationNotes of oWSTransactionService iJobNumber dNoteDate dNoteStopDate  to tNotes
        Move (SizeOfArray(tNotes))                                                                  to iItems
        If (iItems) Begin
            Send DoFillGrid   of oCallCenterGrid tNotes
            Set Visible_State of oCallCenterTextBox to True
        End
        Else Begin
            Set Visible_State of oCallCenterTextBox to False
        End
        Send Cursor_Ready of Cursor_Control
    End_Procedure

    Function IsSavedHeader Returns Integer
        Integer iRecId
        //
        Get Current_Record of oInvhdr_DD to iRecId
        //
        If (iRecId = 0) Begin
            Send Stop_Box "No Invoice selected"
            Function_Return 1
        End
    End_Function
                
    Procedure DoClearInvoice
        Boolean bCancel
        Integer iInvId
        //
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno to iInvId
        Get Confirm ("Clear invoice number" * String(iInvId) + "?")    to bCancel
        If (not(bCancel)) Begin
            Set Field_Changed_Value of oInvhdr_DD Field Invhdr.EditFlag to 1
            Send Request_Save       of oInvhdr_DD
            Send Refresh_Page       of oHeaderList FILL_FROM_CENTER
        End
    End_Procedure

    Procedure DoVoidben	650Invoice
        Boolean bCancel
        Integer iInvId iCountforme
        //
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno to iInvId
        Get Confirm ("Void invoice number" * String(iInvId) + "?")     to bCancel
        If (not(bCancel)) Begin
            
            If (Invhdr.CreatedDate < "12/26/2013") Begin
                // free the Trans records to be invoiced later
                Clear Invhdr
                Move iInvId to Invdtl.InvoiceIdno
                Find GE Invdtl by Index.2
                While ((Found) and Invdtl.InvoiceIdno = iInvId)
                    Clear Trans
                    Move Invdtl.TransIdno to Trans.TransIdno
                    Find EQ Trans by Index.1
                    If (Found) Begin
                        Reread Trans
                        Move 0 to Trans.InvoicedFlag
                        Move 0 to Trans.InvoiceDate
                        SaveRecord Trans
                        Unlock
                    End
                    Find gt Invdtl.InvoiceIdno
                Loop
            End
            Else Begin
                // free the Trans records based on the Trans.InvoiceIdno                
                Clear Trans
                Move iInvId             to Trans.InvoiceIdno
                Move "1"                to Trans.InvoicedFlag
                Find GE Trans by Index.11
                While ((Found) and Trans.InvoiceIdno = iInvId and Trans.InvoicedFlag = "1")                   
                    Reread Trans
                    Move 0 to Trans.InvoiceIdno
                    Move 0 to Trans.InvoicedFlag
                    Move 0 to Trans.InvoiceDate
                    SaveRecord Trans
                    Unlock
                    Move iInvId to Trans.InvoiceIdno
                    Move "1"    to Trans.InvoicedFlag
                    Find GT Trans by Index.11
                Loop
                // 
            End
            
            Set Field_Changed_Value of oInvhdr_DD Field Invhdr.EditFlag to 1
            Set Field_Changed_Value of oInvhdr_DD Field Invhdr.VoidFlag to 1
            Send Request_Save       of oInvhdr_DD
            Send Refresh_Page       of oHeaderList FILL_FROM_CENTER
        End
    End_Procedure

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
            Send DoClearInvoice
        End
        #ENDIF
    End_Procedure

    Procedure Request_Delete
    End_Procedure

//    Object oMonthlyRadioGroup is a RadioGroup
//        Set Location to 59 6
//        Set Size to 22 105
//        Set Label to 'Monthly Options'
//    
//        Object oSnowMonthlyRadio is a Radio
//            Set Size to 10 50
//            Set Location to 10 13
//            Set Label to 'Snow'
//        End_Object
//        Object oSweepMonthlyRadio is a Radio
//            Set Size to 10 50
//            Set Location to 10 60
//            Set Label to 'Sweep'
//        End_Object
//    
//        Procedure Notify_Select_State Integer iToItem Integer iFromItem
//            Forward Send Notify_Select_State iToItem iFromItem\
//            //for augmentation
//        End_Procedure
//        //If you set Current_Radio, you must set it AFTER the
//        //radio objects have been created AND AFTER Notify_Select_State has been
//        //created. i.e. Set in bottom-code of object at the end!!
//    
//        Set Current_Radio to 0
//    
//    End_Object



//    Procedure DoUpdateRemoteDataFiles
//        String sResult
//        //
//        Get DoUpdateMastOps  of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateAreas    of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateCustomer of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateLocation of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateOpers    of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateOrder    of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateInvoice  of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateEmployer of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateEmployee of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateEquipmnt of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateUser     of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateReqtypes of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//    End_Procedure
//    //
//    On_Key Key_Alt+Key_F12 Send DoUpdateRemoteDataFiles

Cd_End_Object
