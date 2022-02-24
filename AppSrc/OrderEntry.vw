Use Windows.pkg
Use DFClient.pkg
Use dfTabDlg.pkg
Use dfLine.pkg
Use DFEntry.pkg
Use dfcentry.pkg
Use cTempusDbView.pkg
Use cDbTextEdit.pkg
Use cComDbSpellText.pkg
Use cGlblDbComboForm.pkg
Use cGlblDbForm.pkg
Use cGlblDbCheckBox.pkg
Use dfTable.pkg
Use vWin32fh.pkg
Use WinUuid.pkg

Use tAttachment.pkg

Use Customer.DD
Use Location.DD
Use Order.DD
Use Areas.DD
Use MastOps.DD
Use Opers.DD
Use Trans.DD
Use Invhdr.DD
Use cJobcostsDataDictionary.dd
Use cLocnotesDataDictionary.dd
Use Invdtl.DD
Use SalesRep.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSnowrepDataDictionary.dd
Use Contact.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use cOrderDtlGlblDataDictionary.dd
Use cProdNoteGlblDataDictionary.dd
Use Eshead.DD
Use cQuotehdrDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use cCustomerContractsGlblDataDictionary.dd
Use cAttachmentsGlblDataDictionary.dd

Use PrintJobSheet.rv
Use PrintCostSheet.rv
Use CustomerInvoice.rv
Use PrintOrderDetail.rv
Use PrintProjectCostSheet.rv
Use JobSheetReport.rv
Use OrderInvoicePreviewReport.rv

Use UserInputDialog.dg
Use ContractDetails.dg
Use CustomerContract.bp
Use APForm.vw
Use Project.sl
Use CustomerContracts.sl

Use OperationsProcess.bp
Use InvoiceCreationProcess.bp
Use OrderEmailNotification.bp
Use cDbCJGrid.pkg
Use dfallent.pkg
Use Functions.pkg
Use cCJCommandBarSystem.pkg
Use dbSuggestionForm.pkg
Use cTextEdit.pkg
Use cdbCJGridColumn.pkg
Use cCJGridColumnButton.pkg
Use VdfBase.pkg
Use cDbCJGridColumnSuggestion.pkg
Use cCJGroupedGrid.pkg
Use cImageContainer.pkg
Use cDbImageContainer.pkg
Use cImageGallery.pkg
Use cWsDbImageContainer.pkg
Use cCharTranslate.pkg
Use cSeqFileHelper.pkg



Activate_View Activate_oOrderEntry for oOrderEntry
Object oOrderEntry is a cTempusDbView
    Set piMinViewRights to 50
    // 0 - Not Yet Specified
    // 50 - Sales (50)
    // 55 - Sales Special (55)
    // 60 - Operations (60)
    // 65 - Operations - Temp Changed (65)
    // 70 - Administration (70)
    // 80 - Management (80)
    // 90 - System Admin (90)
    
    Property Boolean pbShowOpsGridDetails False
    Property Boolean pbShowSalesGridDetails True
    Property Boolean psUserGroup

    Procedure doReceiveMessage String sOrderIdno
        Move sOrderIdno to Order.JobNumber
        Find EQ Order by 1
        If ((Found) and Order.JobNumber = sOrderIdno) Begin
            Send DoViewOrder of oOrderEntry Order.Recnum
        End

    End_Procedure

    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oMastops_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oCustomerContracts_DD is a cCustomerContractsGlblDataDictionary
//        Set pbUseDDRelates to True
//        Set DDO_Server to oCustomer_DD
//        Set Field_Related_FileField Field CustomerContracts.CustomerIdno to File_Field Customer.CustomerIdno
    End_Object

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oCustomer_DD

        Procedure Relate_Main_File
            Clear Propmgr
            If (Location.PropmgrIdno <> 0) Begin
                Move Location.PropmgrIdno to Propmgr.ContactIdno
                Find eq Propmgr.ContactIdno
            End
        End_Procedure
    End_Object

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oContact_DD
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD
    End_Object

    Object oEshead_DD is a Eshead_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oContact_DD
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oMastops_DD
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set Cascade_Delete_State to True
        Set DDO_Server to oLocation_DD
        //Set Constrain_File to Location.File_Number

        Function Validate_Delete Returns Integer
            Integer iRetval
            //
            Forward Get Validate_Delete to iRetval
            //
            If (not(iRetval)) Begin
                Attach Invhdr
                Find ge Invhdr.JobNumber
                If ((Found) and Invhdr.JobNumber = Order.JobNumber) Begin
                    Send UserError "This Order has been invoiced" "Validation Error"
                    Move 1 to iRetval
                End
                Attach Trans
                Find GE Trans.JobNumber
                If ((Found) and Trans.JobNumber = Order.JobNumber) Begin
                    Send UserError "This Order has Transactions" "Validation Error"
                    Move 1 to iRetval
                End
                Attach Jobcosts
                Find GE Jobcosts.JobNumber
                If ((Found) and Jobcosts.JobNumber = Order.JobNumber) Begin
                    Send UserError "This Order has JobCost" "Validation Error"
                    Move 1 to iRetval
                End
            End
            Function_Return iRetval
        End_Function
        
        Function IsPropertyManager Returns String
            Integer iStatus
            String  sManager
            //
            Get_Attribute DF_FILE_STATUS of Propmgr.File_Number to iStatus
            If (iStatus <> DF_FILE_INACTIVE) Begin
                Move (Trim(Propmgr.FirstName) * Trim(Propmgr.LastName)) to sManager
            End
            Function_Return sManager
        End_Function

    End_Object

    Object oAttachments_DD is a cAttachmentsGlblDataDictionary
        Set pbUseDDRelates to True
        Set DDO_Server to oCustomerContracts_DD
        Set Field_Related_FileField Field Attachments.ContractIdno to File_Field CustomerContracts.ContractIdno
        Set Constrain_File to Order.File_Number
        Set pbUseDDRelates to True
        Set DDO_Server to oOrder_DD
        Set Field_Related_FileField Field Attachments.JobNumber to File_Field Order.JobNumber
    End_Object

    Object oJobcosts_DD is a cJobcostsDataDictionary
        Set DDO_Server to oMastops_DD
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD
    End_Object

    Object oProdNote_DD is a cProdNoteGlblDataDictionary
        Set DDO_Server to oSalesRep_DD
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD

        Procedure OnConstrain
            Forward Send OnConstrain
            Constrain ProdNote.DeletedFlag eq 0
        End_Procedure
        
    End_Object

    Object oOrderDtl_DD is a cOrderDtlGlblDataDictionary
        Set DDO_Server to oMastops_DD
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD
    End_Object

    Object oLocnotes_DD is a cLocnotesDataDictionary
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD
    End_Object

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD
        Procedure OnConstrain
            Constrain Invhdr.VoidFlag eq 0
        End_Procedure
        
    End_Object

    Object oInvdtl_DD is a Invdtl_DataDictionary
        Set DDO_Server to oOpers_DD
        Set Constrain_file to Opers.File_number
        Set DDO_Server to oInvhdr_DD
    End_Object

    Object oTrans_DD is a Trans_DataDictionary
        Set DDO_Server to oOpers_DD
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD

    Set Border_Style to Border_Thick
    Set Size to 322 580
    Set Location to 1 0
    Set Label to "Order Entry/Edit"
    Set peAnchors to anTopLeftRight
    Set piMinSize to 250 580
    Set Maximize_Icon to True
    //Set pbAutoActivate to True


    Object oOrderHeaderContainer is a dbContainer3d
        Set Size to 33 571
        Set Location to 3 4
        Set peAnchors to anTopLeftRight

        Object oOrder_JobNumber is a dbForm
            Entry_Item Order.JobNumber
            Set Location to 10 5
            Set Size to 13 40
            Set Label to "Job#:"
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            Set Label_FontWeight to fw_Bold
            Set FontWeight to fw_Bold

            Procedure Request_Find Integer iMode Integer iEntUpdtFlag
                Send Request_Superfind iMode
            End_Procedure

            Procedure Next
                Send Request_Superfind EQ
                Forward Send Next
            End_Procedure


            Procedure Prompt_Callback Integer hPrompt
                If (Current_Record(oLocation_DD)) Begin
                    Set Auto_Server_State of hPrompt to True
                End
                Else Begin
                    Set Auto_Server_State of hPrompt to False
                End
            End_Procedure
            
             Procedure Refresh Integer iMode
                Integer iProdNotes iAcknowledged                        
                Boolean bIsCostComplete bIsJobSelected bIsJobCanceled bIsJobClosed bIsJobOpen bHasInvoiceAmt bJobIsLocked
                Boolean bHasProdNote bHasOpenProdNote bStandard bMonthly bTimeAndMat bNoCharge
                Boolean bJobInvoiced bHasMinSlsRights bHasMinOpsRights bHasMinAdmRights bHasMinSysAdmRights
                
                
                Forward Send Refresh iMode  

                Move (Order.JobNumber > 0) to bIsJobSelected
                Move (Order.OpsCostOK >0)  to bIsCostComplete
                Move (Order.Status = "O") to bIsJobOpen
                Move (Order.Status = "X")  to bIsJobCanceled 
                Move (Order.Status = "C") to bIsJobClosed
                Move (Order.InvoiceAmt >0) to bHasInvoiceAmt
                Move (Order.LockedFlag > 0) to bJobIsLocked
                // Count Prodnotes and change TabTitle
                Send CountProdNotes Order.JobNumber (&iProdNotes) (&iAcknowledged) (&bHasProdNote)
                Set Label of oProdNoteTabPage to ("Production Notes ("+String(iAcknowledged)+"/"+String(iProdNotes)+")")  
                Move (iProdNotes>0) to bHasProdNote
                Move (iProdNotes-iAcknowledged>0) to bHasOpenProdNote
                // 
                Move (giUserRights>=50) to bHasMinSlsRights
                Move (giUserRights>=60) to bHasMinOpsRights
                Move (giUserRights>=70) to bHasMinAdmRights
                Move (giUserRights>=90) to bHasMinSysAdmRights
                Move (Order.BillingType="S") to bStandard
                Move (Order.BillingType="M") to bMonthly
                Move (Order.BillingType="T") to bTimeAndMat
                Move (Order.BillingType="N") to bNoCharge
                Move (Order.SalesInvoiceOK>0) to bJobInvoiced
                //
                Set Enabled_State of oLockStateButton to (bHasMinAdmRights and bIsJobSelected)
                If (bJobIsLocked) Begin
                    Set Bitmap of oLockStateButton to "locked.bmp"
                End
                Else Begin
                    Set Bitmap of oLockStateButton to "unlocked.bmp"
                End
                //
                Set Enabled_State of oOpsCostOkButton to ((bHasMinOpsRights) and (bIsJobSelected) and (not(bIsCostComplete)) and (not(bIsJobCanceled)) and (not(bIsJobClosed)) or bHasMinSysAdmRights and (not(bJobIsLocked)))
                If (bIsCostComplete) Set Label of oOpsCostOKButton to ("Cost"*String(Order.OpsCostOK))
                Else Set Label of oOpsCostOkButton to "Ready to Invoice"               
                Set Enabled_State of oCreateInvoiceButton to (((bIsJobSelected) and (bIsCostComplete)) and bIsJobClosed and (not(bIsJobCanceled)) and (not(bJobInvoiced)) and not(bHasOpenProdNote))
                Case Begin
                    Case (bJobInvoiced)
                        Set Label of oCreateInvoiceButton to ("Invoice"*String(Order.SalesInvoiceOK))
                        Case Break
                    Case (bHasOpenProdNote)
                        Set Label of oCreateInvoiceButton to ("Open ProdNotes")
                        Case Break
                    Case Else
                        Set Label of oCreateInvoiceButton to "Create Invoice"
                Case End
                // Order Status
                Set Enabled_State of oOrder_Status to (bIsJobSelected and bHasMinAdmRights and (not(bIsJobCanceled) or bHasMinAdmRights))
                Case Begin
                    Case (bIsJobOpen)
                        Set Label_TextColor of oOrder_Status to clGreen
                        Case Break
                    Case (bIsJobClosed)
                        Set Label_TextColor of oOrder_Status to clRed
                        Case Break
                    Case (bIsJobCanceled)
                        Set Label_TextColor of oOrder_Status to clBlue
                        Case Break
                Case End
                //
                Set Enabled_State of oViewQuoteButton to (Order.QuoteReference <> 0)
                Set Enabled_State of oPrintJobSheetButton to (bIsJobSelected)
                Set Enabled_State of oPrintInvoicePrevButton to (bIsJobSelected)
                Set Enabled_State of oPrintJobCostButton to (bIsJobSelected)
                Set Enabled_State of oJobCostButton to ((bIsJobSelected)and not(bIsJobClosed))
                Set Enabled_State of oExport_Button to (bIsJobSelected)
                Set Enabled_State of oSendNotificationButton to (bIsJobSelected and bIsJobOpen)
                //
                Set Enabled_State of oAddButton to (bIsJobSelected and bIsJobOpen and bHasMinOpsRights)
                Set Enabled_State of oDeleteButton to (bIsJobSelected and bIsJobOpen and bHasMinOpsRights)
                Set Enabled_State of oAcknowledgeButton to (bIsJobSelected and bHasMinSlsRights and bHasProdNote and not(bJobInvoiced))
                //
                If (Order.ProjectId <>0) Begin
                    Move Order.ProjectId to Project.ProjectId
                    Find EQ Project by 1
                    Set Value of oProjectDiscription to Project.Description    
                End
                Else Begin
                    Set Value of oProjectDiscription to ""
                End
                // All Panels
                //Set Enabled_State of oOrderCenterTabDialog to (not(bJobIsLocked))
                Set Enabled_State of oOrder_BillingType to (bIsJobSelected and bIsJobOpen or (not(bJobIsLocked) and bHasMinSysAdmRights))
                Set Enabled_State of oCustomer_Name to (not(bIsJobSelected) and not(bIsJobCanceled) and not(bIsJobClosed) or (not(bJobIsLocked) and bHasMinSysAdmRights))
                Set Enabled_State of oLocation_Name to (not(bIsJobSelected) and not(bIsJobCanceled) and not(bIsJobClosed) or (not(bJobIsLocked) and bHasMinSysAdmRights))
                Set Enabled_State of oSalesRep_LastName to (not(bIsJobSelected) and not(bIsJobCanceled) and not(bIsJobClosed) or (not(bJobIsLocked) and bHasMinAdmRights))
                Set Enabled_State of oSalesRep_FirstName to (not(bIsJobSelected) and not(bIsJobCanceled) and not(bIsJobClosed) or (not(bJobIsLocked) and bHasMinAdmRights))
                // Specification Tab
                Set Enabled_State of oSpecsTabPage to (bHasMinOpsRights)
                Set Enabled_State of oClearProjectButton to (bHasMinAdmRights and not(bIsJobCanceled) and not(bIsJobClosed) or (not(bJobIsLocked) and bHasMinSysAdmRights))
                Set Enabled_State of oProjectID to (bHasMinAdmRights and not(bIsJobCanceled) or (not(bJobIsLocked) and bHasMinSysAdmRights))
                Set Enabled_State of oOrder_Planner to (bHasMinAdmRights and not(bIsJobCanceled) and not(bIsJobClosed) or (not(bJobIsLocked) and bHasMinSysAdmRights))
                Set Enabled_State of oOrder_CEPM_JobNumber to (bHasMinAdmRights and not(bIsJobCanceled) and not(bIsJobClosed) or (not(bJobIsLocked) and bHasMinSysAdmRights))
                Set Enabled_State of oBillingGroup to (bHasMinAdmRights and not(bIsJobCanceled) and not(bIsJobClosed) or (not(bJobIsLocked) and bHasMinSysAdmRights))
                // Attachment Tab
                Set Enabled_State of oAttachmentsGrid to (bIsJobSelected and bIsJobOpen and not(bJobIsLocked))
                Set Enabled_State of oDragAndDropContainer to (bIsJobSelected and bIsJobOpen and not(bJobIsLocked))
                Set pbAcceptDropFiles of oDragAndDropContainer to (bIsJobSelected and bIsJobOpen and not(bJobIsLocked))
                // Production Note Tab
                Set Enabled_State of oProdNoteTabPage to (True)
                Set Enabled_State of oNotesTabPage to (True)
                Set Enabled_State of oInvoicesTabPage to (True)
                Set Enabled_State of oOrderDtl_Description to (not(bIsJobCanceled) and not(bJobInvoiced))
                //Set Read_Only_State of oOrderDtlGrid to (not(bIsJobCanceled) and bJobInvoiced) 
                Set pbReadOnly of oOrderDtlDbCJGrid to (not(bIsJobCanceled) and bJobInvoiced)
                Set pbEnableButton of oOrderDtlCompletedCJGridColumnButton to (not(pbReadOnly(oOrderDtlDbCJGrid)))
                //
            End_Procedure
            
            Procedure CountProdNotes Integer iJobNumber Integer ByRef iProdNotes Integer ByRef iAcknowledged
                Constraint_Set 1
                Constrain ProdNote.JobNumber eq iJobNumber
                Constrain ProdNote.DeletedFlag eq 0
                Constrained_Find First ProdNote by 2
                While (Found)
                    // Count ProdNotes
                    Increment iProdNotes
                    If (ProdNote.AcknowledgedDate<>0) Begin
                        Increment iAcknowledged
                    End
                    Constrained_Find Next 
                Loop
                Constraint_Set 1 Delete
            End_Procedure
            
        End_Object

        Object oOrder_Title is a dbForm
            Entry_Item Order.Title
            Set Location to 10 48
            Set Size to 13 219
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 1
            Set Label to "Title"
            Set Label_FontWeight to fw_Bold
        End_Object

        Object oOrder_WorkType is a dbComboForm
            Entry_Item Order.WorkType
            Set Location to 10 269
            Set Size to 13 76
            Set Label to "Type"
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            Set Combo_Sort_State to False
            Set Label_FontWeight to fw_Bold
        End_Object

        Object oOrder_Status is a dbComboForm
            Entry_Item Order.Status
            Set Location to 10 481
            Set Size to 13 77
            Set Label to "Status"
            Set Label_Justification_Mode to JMode_Top
            Set Label_FontWeight to fw_Bold
            Set Allow_Undefined_State to False
            Set Combo_Sort_State to False
            Set peAnchors to anTopRight
            Set Label_Col_Offset to 0

            Procedure OnChange
                
            End_Procedure

            Procedure Combo_Item_Changed
                Boolean bHasRecord bShouldSave bCancel
                Integer iEstIdno iQuoteIdno
                String sOldStatus sNewStatus sSpecMsg sCancelText
                Date dToday dOldCanceledDate dOldCloseDate
                // Collect previous values
                Move Order.Status to sOldStatus
                Move Order.PromiseDate to dOldCanceledDate
                Move Order.JobCloseDate to dOldCloseDate
                //
                Sysdate dToday
                //
                Get Field_Current_Value of oOrder_DD Field Order.Status to sNewStatus
                Get Field_Current_Value of oOrder_DD Field Order.Specification to sSpecMsg
                //
                Forward Send Combo_Item_Changed
                
                Case Begin
                    Case (sNewStatus = "X") //Canceled
                        Get Confirm ("CANCEL Job#"*String(Order.JobNumber)*" \n \n Do you want to cancel Job#" * String(Order.JobNumber)*"?") to bCancel
                        If (not(bCancel)) Begin
                            If (Length(sSpecMsg)<>0) Move (sSpecMsg +"\n") to sSpecMsg
                            Get PopupUserInput of oUserInputDialog "Order Cancalation" "Please discribe the reason for canceling this Order" "" False to sCancelText
                            Set Field_Changed_Value of oOrder_DD Field Order.Specification to (sSpecMsg*"CANCELED:"*sCancelText*"-"*gsUserFullName)
                            Set Field_Changed_Value of oOrder_DD Field Order.JobCloseDate to dToday
                            Set Field_Changed_Value of oOrder_DD Field Order.PromiseDate to dToday
                            Set Field_Changed_Value of oOrder_DD Field Order.LockedFlag to 1
                            Send Request_Save of oOrder_DD
                            //Free up Estimate/Quote for re-use
                            Get Field_Current_Value of oOrder_DD Field Order.EsheadReference to iEstIdno
                            Get Field_Current_Value of oOrder_DD Field Order.QuoteReference to iQuoteIdno
                            If (iEstIdno<>0) Begin
                                // Estimate unlock
                                Clear Eshead
                                Move iEstIdno to Eshead.ESTIMATE_ID
                                Find EQ Eshead.ESTIMATE_ID
                                If ((Found) and Eshead.ESTIMATE_ID = iEstIdno) Begin
                                    Move "" to Eshead.OrderDate
                                    Move "" to Eshead.OrderReference
                                    Move 0 to Eshead.LockedFlag
                                    Move "P" to Eshead.Status
                                    SaveRecord Eshead
                                End
                            End 
                        End
                        If (bCancel) Begin
                            Set Field_Changed_Value of oOrder_DD Field Order.Status to sOldStatus
                            Set Field_Changed_Value of oOrder_DD Field Order.PromiseDate to dOldCanceledDate
                            Set Field_Changed_Value of oOrder_DD Field Order.JobCloseDate to dOldCloseDate
                            Set Field_Changed_Value of oOrder_DD Field Order.LockedFlag to 0
                            Send Request_Save of oOrder_DD
                        End
                        Case Break
                    Case (sNewStatus = "C") //Closed
                        Set Field_Changed_Value of oOrder_DD Field Order.JobCloseDate to dToday
                        Set Field_Changed_Value of oOrder_DD Field Order.PromiseDate to ''
                        Set Field_Changed_Value of oOrder_DD Field Order.LockedFlag to 1
                        Case Break                        
                    Case (sNewStatus = "O") //Open
                        Set Field_Changed_Value of oOrder_DD Field Order.JobCloseDate to ''
                        Set Field_Changed_Value of oOrder_DD Field Order.PromiseDate to ''
                        Set Field_Changed_Value of oOrder_DD Field Order.LockedFlag to 0
                        Case Break
                    Case Else //All other values
                        Send Request_Save of oOrder_DD
                Case End
                
                
                //Save changes instantly
                Get HasRecord of oOrder_DD to bHasRecord
                Get Should_Save of oOrder_DD to bShouldSave
                If (bHasRecord and bShouldSave) Begin
                    // Request Cancalation Reason
                    // Save to Order.Notes field
                    Send Request_Save of oOrder_DD
                End
                
            End_Procedure
            
        End_Object

        Object oLockStateButton is a Button
            Set Size to 15 17
            Set Location to 8 460
            Set Label to 'LockUnlock'
            Set Bitmap to "unlocked.bmp"
            Set peAnchors to anTopRight
        
            // fires when the button is clicked
            Procedure OnClick
                Boolean bOrderLockStatus bHasRecord bFail
                Handle hoDD
                //
                Move oOrder_DD to hoDD
                //
                Get HasRecord of hoDD to bHasRecord
                If (bHasRecord) Begin
                    Get Field_Current_Value of hoDD Field Order.LockedFlag to bOrderLockStatus
                    Set Field_Changed_Value of hoDD Field Order.LockedFlag to (not(bOrderLockStatus))
                    Get Request_Validate of hoDD to bFail
                    If (not(bFail)) Begin
                        Send Request_Save of oOrder_DD
                    End
                End
            End_Procedure
        
        End_Object

        Object oOrder_Division is a cGlblDbForm
            Entry_Item Order.Division
            Set Location to 10 348
            Set Size to 13 57
            Set Label to "Divisions"
            Set Entry_State to False
            Set Label_Col_Offset to 0
            Set Label_FontWeight to fw_Bold
            Set Label_Justification_Mode to JMode_Top
            Set peAnchors to anTopLeftRight
            Set Enabled_State to False
        End_Object

        Object oForm1 is a cGlblDbForm
            Entry_Item (Order.LineItemCompCount/Order.LineItemReqCount*100)
            Set Size to 13 49
            Set Location to 10 408
            Set Label to "Completed"
            Set Form_Mask to "##0 %"
            Set Entry_State to False
            Set Label_Col_Offset to 0
            Set Label_FontWeight to fw_Bold
            Set Label_Justification_Mode to JMode_Top
            Set peAnchors to anTopRight
            Set Enabled_State to False
            Set Form_Datatype to Mask_Numeric_Window
        
            // OnChange is called on every changed character
        //    Procedure OnChange
        //        String sValue
        //    
        //        Get Value to sValue
        //    End_Procedure
        
        End_Object
    End_Object

    Object oOrderCenterTabDialog is a dbTabDialog
        Set Size to 84 571
        Set Location to 36 4
    
        Set Rotate_Mode to RM_Rotate
        Set peAnchors to anTopLeftRight

        Object oDetailsTabPage is a dbTabPage
            Set Label to 'Details'

            Object oCustomer_Name is a DbSuggestionForm
                Entry_Item Customer.Name
                Set Enabled_State to False
                Set Location to 4 41
                Set Size to 13 381
                Set Label to "Customer:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopLeftRight
                Set pbFullText to True
                
                Procedure OnChange
                    If (HasRecord(oCustomer_DD)) Set Label_TextColor to clBlack
                    Else Set Label_TextColor to clRed              
                End_Procedure

                Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                    Send Activate_oCustomerEntry                   
                End_Procedure
            End_Object
            
            Object oLocation_Name is a DbSuggestionForm
                Entry_Item Location.Name
                Set Location to 19 41
                Set Size to 13 381
                Set Label to "Location:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopLeftRight
                Set pbFullText to True

                Procedure OnChange
                    If (HasRecord(oLocation_DD)) Set Label_TextColor to clBlack
                    Else Set Label_TextColor to clRed              
                End_Procedure

                Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                    Send Activate_oLocationEntry                   
                End_Procedure
            End_Object

            Object oSalesRep_LastName is a DbSuggestionForm
                Entry_Item SalesRep.LastName
                Set Location to 34 41
                Set Size to 13 69
                Set Label to "SalesRep:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set pbFullText to True
                
                Procedure OnChange
                    If (HasRecord(oSalesRep_DD)) Set Label_TextColor to clBlack
                    Else Set Label_TextColor to clRed              
                End_Procedure            
            End_Object

            Object oSalesRep_FirstName is a DbSuggestionForm
                Entry_Item SalesRep.FirstName
                Set Location to 34 112
                Set Size to 13 79
                Set Label_Col_Offset to 0
                Set pbFullText to True
                
                Procedure OnChange
                    If (HasRecord(oSalesRep_DD)) Set Label_TextColor to clBlack
                    Else Set Label_TextColor to clRed              
                End_Procedure      
            End_Object

            Object oOrder_PO_Number is a cGlblDbForm
                Entry_Item Order.PO_Number
                Set Location to 34 221
                Set Size to 13 200
                Set Label to "PO#:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object
            
            Object oOrder_JobOpenDate is a cGlblDbForm
                Entry_Item Order.JobOpenDate
                Set Location to 4 483
                Set Size to 13 75
                Set Label to "Opened On:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 5
                Set Enabled_State to False
                Set Entry_State to False
                Set peAnchors to anTopRight
            End_Object
            
            Object oOrder_JobCloseDate is a cGlblDbForm
                Entry_Item Order.JobCloseDate
                Set Location to 34 483
                Set Size to 13 75
                Set Label to "Closed On:"
                Set Label_Col_Offset to 5
                Set Label_Justification_Mode to JMode_Right
                Set Enabled_State to False
                Set Entry_State to False
                Set peAnchors to anTopRight
            End_Object
            Object oOrder_PromiseDate is a cGlblDbForm
                Entry_Item Order.PromiseDate
                Set Location to 19 483
                Set Size to 13 75
                Set Label to "Canceled On:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 5
                Set Enabled_State to False
                Set Entry_State to False
                Set peAnchors to anTopRight
            End_Object

            Object oLineControl1 is a LineControl
                Set Size to 3 549
                Set Location to 50 7
                Set peAnchors to anTopLeftRight
            End_Object

            Object oOrder_EsheadReference is a cGlblDbForm
                Entry_Item Order.EsheadReference
                Set Location to 53 41
                Set Size to 13 34
                Set Label to "Estimate#:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set Enabled_State to False
                
                Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                    String sEsheadIdno
                    Forward Send Mouse_Click iWindowNumber iPosition
                    Get Field_Current_Value of oOrder_DD Field Order.EsheadReference to sEsheadIdno
                    If (sEsheadIdno<>0) Begin
                        //Runprogram background "TempusEstimating.exe" (String(sEsheadIdno))
                        Send DoCallFromClient to oRPCClient sEsheadIdno "oEstimate"
                    End
                End_Procedure
            End_Object

            Object oOrder_EsheadAmount is a cGlblDbForm
                Entry_Item Order.EsheadAmount
                Set Location to 53 76
                Set Size to 13 57
                Set Enabled_State to False
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oOrder_EstHoursTotal is a cGlblDbForm
                Entry_Item Order.EstHoursTotal
                Set Location to 53 134
                Set Size to 13 38
                Set Label_Col_Offset to 0
                Set Enabled_State to False
            End_Object

            Object oOrder_QuoteReference is a cGlblDbForm
                Entry_Item Order.QuoteReference
                Set Location to 53 221
                Set Size to 13 33
                Set Label to "Quote#:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set Enabled_State to False
    
                Procedure Refresh Integer iMode
                    Forward Send Refresh iMode
                    //
                    Set Enabled_State to False
                    //
                    If (Focus(Self) = Self) Begin
                        Send Activate of oOrder_JobNumber
                    End
                End_Procedure
                
                Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                    String sQuoteIdno
                    Forward Send Mouse_Click iWindowNumber iPosition
                    Get Field_Current_Value of oOrder_DD Field Order.QuoteReference to sQuoteIdno
                    If (sQuoteIdno<>0) Begin
                        Send DoViewQuote of oQuoteEntry sQuoteIdno
                    End
                End_Procedure
            End_Object

            Object oOrder_QuoteAmount is a cGlblDbForm
                Entry_Item Order.QuoteAmount
                Set Location to 53 258
                Set Size to 13 56
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set Enabled_State to False
            End_Object

            Object oOrder_BillingType is a dbComboForm
                Entry_Item Order.BillingType
                Set Location to 53 354
                Set Size to 12 66
                Set Label to "Billing:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopLeftRight
            End_Object

            Object oSendNotificationButton is a Button
                Set Size to 14 76
                Set Location to 52 483
                Set Label to 'Send Notification'
                Set peAnchors to anTopRight
            
                // fires when the button is clicked
                Procedure OnClick
                    Set Enabled_State of oSendNotificationButton to False //prevent double notification - Matt Holmstrom clicked multiple time
                    Boolean bSuccess
                    String sFilePath sFileName
                    Send DoJumpStartReport of oJobSheetReportView Order.JobNumber (&sFilePath) (&sFileName) False
                    Send DoJumpStartReport of oOrderInvoicePreviewReportView Order.JobNumber  (&sFilePath) (&sFileName) False
                    Get DoSendOrderEmailNotification of oOrderEmailNotification Order.JobNumber False to bSuccess
                    Set Enabled_State of oSendNotificationButton to True
                End_Procedure
            
            End_Object           
            
        End_Object

        Object oSpecsTabPage is a dbTabPage
            Set Label to "Specifications"

            Object oLocation_ContactName is a dbForm
                Entry_Item (IsPropertyManager(oOrder_DD))
                Set Location to 6 64
                Set Size to 13 231
                Set Label to "Property Manager:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 2
                Set Enabled_State to False
                Set Entry_State to False
            End_Object

            Object oLocation_Phone1 is a dbForm
                Entry_Item Location.ContactPhone1
                Set Location to 21 64
                Set Size to 13 65
                Set Label to "Phones:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 2
                Set Enabled_State to False
                Set Entry_State to False
            End_Object

            Object oLocation_PhoneType1 is a cGlblDbComboForm
                Entry_Item Location.ContactPhnType1
    
                Set Server to oLocation_DD
                Set Location to 21 132
                Set Size to 13 46
                Set Enabled_State to False
            End_Object

            Object oLocation_Phone2 is a dbForm
                Entry_Item Location.ContactPhone2
                Set Location to 21 182
                Set Size to 13 65
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 2
                Set Prompt_Button_Mode to PB_PromptOff
                Set Enabled_State to False
            End_Object

            Object oLocation_ContactPhnType2 is a cGlblDbComboForm
                Entry_Item Location.ContactPhnType2
                Set Server to oLocation_DD
                Set Location to 21 249
                Set Size to 13 46
                Set Enabled_State to False
            End_Object

            Object oProjectID is a cGlblDbForm
                Entry_Item Order.ProjectId
                Set Label to "Project:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 1
                Set Location to 36 64
                Set Size to 13 37
                Set Prompt_Button_Mode to PB_PromptOn
                
                Procedure Prompt
                    Integer iProjIdno iCustIdno iRepIdno
                    Boolean bOk
                    Move Order.ProjectId to iProjIdno
                    Move Order.CustomerIdno to iCustIdno
                    Move Order.RepIdno to iRepIdno
                    Get DoProjectPrompt of Project_sl (&iProjIdno) iCustIdno iRepIdno to bOk
                    If (bOk) Begin
                        Set Field_Changed_Value of oOrder_DD Field Order.ProjectId to iProjIdno
                        Send Request_Save of oOrder_DD        
                    End
                End_Procedure
                
            End_Object

            Object oProjectDiscription is a Form
                Set Size to 13 143
                Set Location to 36 103
                Set Enabled_State to False
            
                //OnChange is called on every changed character
            
                //Procedure OnChange
                //    String sValue
                //
                //    Get Value to sValue
                //End_Procedure
            
            End_Object

            Object oClearProjectButton is a Button
                Set Size to 13 46
                Set Location to 36 249
                Set Label to "Clear"
            
                // fires when the button is clicked
                Procedure OnClick
                    Boolean bError
                    //
                    Send Refind_Records of oOrder_DD
                    Set Field_Changed_Value of oOrder_DD Field Order.ProjectId to 0
                    Get Request_Validate of oOrder_DD to bError
                    If (not(bError)) Begin
                        Send Request_Save of oOrder_DD
                    End
                    
                End_Procedure
            
            End_Object

            Object oOrder_CEPM_JobNumber is a cGlblDbForm
                Entry_Item Order.CEPM_JobNumber
                Set Location to 5 393
                Set Size to 13 54
                Set Label to "Job# @ CEPM:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopRight
            End_Object
            
            Object oOrder_Planner is a dbForm
                Entry_Item Order.Planner
                Set Location to 20 393
                Set Size to 13 54
                Set Label to "Planner:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                Set peAnchors to anTopRight
            End_Object

//            Object oSalesRepForm is a Form
//                Set Size to 13 100
//                Set Location to 55 60
//                Set Label to "Sales Rep:"
//                Set Label_Col_Offset to 3
//                Set Label_Justification_Mode to JMode_Right
//                Set Enabled_State to False
//
//                Procedure DoDisplaySalesRep String sWorkType
//                    If (Propmgr.ContactIdno <> Location.PropmgrIdno) Begin
//                        Clear Propmgr
//                        Move Location.PropmgrIdno to Propmgr.ContactIdno
//                        Find eq Propmgr.ContactIdno
//                    End
//                    Clear SalesRep
//                    If (sWorkType = "S") Begin
//                        Move Propmgr.SnowRepIdno to SalesRep.RepIdno
//                    End
//                    Else Begin
//                        Move Propmgr.RepIdno     to SalesRep.RepIdno
//                    End
//                    Find eq SalesRep.RepIdno
//                    Set Value to (Trim(SalesRep.FirstName) * Trim(SalesRep.LastName))
//                End_Procedure
//            End_Object

//            Object oOrder_Division is a cGlblDbComboForm
//                Entry_Item Order.Division
//                Set Location to 51 64
//                Set Size to 12 231
//                Set Label to "Division:"
//                Set Label_Col_Offset to 3
//                Set Label_Justification_Mode to JMode_Right
//                
//                Procedure Combo_Fill_List
//                    Send Combo_Delete_Data
//                    Send Combo_Add_Item "Excavation"
//                    Send Combo_Add_Item "Red Rock"
//                    Send Combo_Add_Item "Northern Salt"
//                    Send Combo_Add_Item "Special"
//                End_Procedure
//
//            End_Object

            Object oBillingGroup is a dbGroup
                Set Size to 66 109
                Set Location to 0 452
                Set Label to 'Options'
                Set peAnchors to anTopRight

                Object oOrder_InvoiceOnly is a cGlblDbCheckBox
                    Entry_Item Order.InvoiceOnly
                    Set Location to 9 9
                    Set Size to 10 75
                    Set Label to "Invoicing Only"
                End_Object

                Object oOrder_MonthlyBilling is a cGlblDbCheckBox
                    Entry_Item Order.MonthlyBilling
                    Set Location to 18 9
                    Set Size to 10 75
                    Set Label to "Monthly Billing"
                End_Object

                Object oOrder_RoundingExempt is a cGlblDbCheckBox
                    Entry_Item Order.RoundingExempt
                    Set Location to 27 9
                    Set Size to 10 75
                    Set Label to "Rounding Exempt"
                End_Object

                Object oOrder_PrevWageStatus is a cGlblDbCheckBox
                    Entry_Item Order.PrevWageStatus
                    Set Location to 36 9
                    Set Size to 13 20
                    Set Label to "Prevailing Wage Job"
                End_Object

                Object oOrder_WriteOffFlag is a cGlblDbCheckBox
                    Entry_Item Order.WriteOffFlag
                    Set Location to 45 9
                    Set Size to 10 93
                    Set Label to "Write Off"
                End_Object

                Object oOrder_GEOExclusion is a cGlblDbCheckBox
                    Entry_Item Order.GEOExclusion
                    Set Location to 54 9
                    Set Size to 10 60
                    Set Label to "GEO Exclusion"
                End_Object
            End_Object

            Object oOrder_ScheduledOpenDate is a dbForm
                Entry_Item Order.ScheduledOpenDate
                Set Location to 35 393
                Set Size to 13 54
                Set Label to "Schedule Start:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                Set Form_Datatype to Mask_Date_Window
                Set Prompt_Button_Mode to PB_PromptOn
                Set Prompt_Object to oMonthCalendarPrompt
            End_Object

            Object oOrder_ScheduledCloseDate is a dbForm
                Entry_Item Order.ScheduledCloseDate
                Set Location to 50 393
                Set Size to 13 54
                Set Label to "Schedule End:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set Form_Datatype to Mask_Date_Window
                Set Prompt_Button_Mode to PB_PromptOn
                Set Prompt_Object to oMonthCalendarPrompt
            End_Object

        End_Object

        Object oAttachmemtsDBTabPage is a dbTabPage
            Set Label to 'Attachments'
            //Set Button_Shadow_State to True

            Object oOpenDialog1 is a OpenDialog
                Set Filter_String to 'All Files|*.*'
                Set Initial_Folder to 'C:\'
                Set Filter_Index to 3
                Set MultiSelect_State to True
                
                //Show_Dialog is a predefined function in the OpenDialog class.
                //Call the OpenDialog via:
            
                //get Show_Dialog to iIntegerVariable
            
                //DoCallOpenDialog is NOT a predefined method in the OpenDialog class,
                //DoCallOpenDialog is just a code sample.
                //You can call DoCallOpenDialog from another object, such as a button.
            
                //Procedure DoCallOpenDialog
                //    Boolean bOk
                //
                //    Get Show_Dialog To bOk
                //    If (bOk) Begin
                //        
                //    End
                //End_Procedure

            End_Object

            Object oDragAndDropContainer is a dbContainer3d
                Set Size to 68 442
                Set Location to 1 1
                Set pbAcceptDropFiles to True
                //Set Bitmap_Style to Bitmap_Center

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
                        Send ProcessDroppedFiles ArrayOfDroppedFiles False
                        // clear the property so it is ready for next drop 
                        Move EmptyArray to ArrayOfDroppedFiles
                    End
            
                    Set pArrayOfDroppedFiles to ArrayOfDroppedFiles
            
                End_Procedure

                Procedure ProcessDroppedFiles String[] ArrayOfDroppedFiles Boolean bIsContract
                    Integer iArraySize i iSeq iDotPos iSlashPos iJobNumber iRetval iFileSize iCustIdno iContractIdno
                    String sYear sMonth sDay sHr sMin sSec sSourceFile sFileName sNewFileName sFileExt sTargetPath sTargetFile
                    String sHexUUID
                    Handle hoDD hoWorkspace
                    Boolean bSuccess bFail bIsImage bCustPathExists bLocPathExists bIsTemp
                    Date dContractStartDate dContractExpiryDate
                    //
                    Move (SizeOfArray(ArrayOfDroppedFiles)) to iArraySize
                    Move Order.JobNumber to iJobNumber
                    // Continue Sequence.
                    Constraint_Set 1
                    Constrain Attachments.JobNumber eq iJobNumber
                    Constrained_Find Last Attachments by 7
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
                        // Get file properties
                        Get FileProperties sSourceFile (&sFileName) (&sFileExt) (&iFileSize) to bSuccess
                        Get IsImageFile sFileExt to bIsImage
                        Get RandomHexUUID to sHexUUID // to make new unique filename
                        Move (sHexUUID+sFileExt) to sNewFileName
                        //
                        Date dToday
                        Sysdate dToday sHr sMin sSec
                        //
                        //Set upload properties for either contract or regular attachment
                        If (bIsContract) Begin
                            //Contracts are stored in particular folder in TUG drive.
                            String sTugContractsPath sCustomerPath sLocationPath                            
                            Move ("\\fs\tug\Contracts\") to sTugContractsPath //This path should always exist!
                            Move (sTugContractsPath+(Trim(Customer.Name))) to sCustomerPath
                            File_Exist sCustomerPath bCustPathExists
                            If (not(bCustPathExists)) Make_Directory sCustomerPath //
                            Move (sCustomerPath+"\"+(Trim(Location.Name))) to sLocationPath
                            File_Exist sLocationPath bLocPathExists
                            If (not(bLocPathExists)) Make_Directory sLocationPath
                            Move (sLocationPath+"\") to sTargetPath
                        End
                        Else Begin
                            Get psHome of (phoWorkspace(ghoApplication)) to sTargetPath
                            Move (sTargetPath+"Bitmaps\Attachments\") to sTargetPath
                        End
                        // Create the file at target path
                        Move (sTargetPath+sNewFileName) to sTargetFile                
                        Get vCopyFile sSourceFile sTargetFile to iRetval
                        // Once the file is copied to its designated location, create records
                        If (iRetval=0) Begin
                            If (bIsContract) Begin
                                // Contracts are recorded in separate table and stored in different location
                                // The attachments table only holds references to the contract. This way, a single contract can be utilized on multiple Jobs, as typical in Winter Jobs
                                // we will need to create contract record first
                                Move (Customer.CustomerIdno) to iCustIdno
                                Get CreateRecord of oCustomerContract iCustIdno sFileName sNewFileName (&iContractIdno) to bSuccess
                                If (not(bSuccess)) Procedure_Return
                            End
                            // Store all in Attachment Table       
                            Move oAttachments_DD to hoDD
                            Send Clear of hoDD
                            Move iContractIdno to CustomerContracts.ContractIdno
                            Send Request_Find of hoDD EQ CustomerContracts.File_Number 1
                            Increment iSeq
                            Set Field_Changed_Value of hoDD Field Attachments.JobNumber             to iJobNumber
                            Set Field_Changed_Value of hoDD Field Attachments.CreatedBy             to gsUsername
                            Set Field_Changed_Value of hoDD Field Attachments.CreatedDate           to dToday
                            Set Field_Changed_Value of hoDD Field Attachments.CreatedTime           to (sHr+":"+sMin+":"+sSec)
                            Set Field_Changed_Value of hoDD Field Attachments.Name                  to sFileName
                            Set Field_Changed_Value of hoDD Field Attachments.Sequence              to iSeq
                            Set Field_Changed_Value of hoDD Field Attachments.FileName              to sNewFileName
                            Set Field_Changed_Value of hoDD Field Attachments.OrderFlag             to bIsImage
                            //
                            Set Field_Changed_Value of hoDD Field Attachments.ContractFlag          to bIsContract
                            //
                            Get Request_Validate    of hoDD                                     to bFail
                            If (not(bFail)) Begin
                                Send Request_Save       of hoDD
                            End
                            Else Begin
                                Send Stop_Box "Processing stopped at Attachments Validation" "Processing Error"
                                Procedure_Return
                            End    
                        End
                        Else Begin
                            Send Stop_Box ("Could not create "+ sSourceFile + " in "+ sTargetPath) "File creation error"
                        End
                        
                    Loop
                End_Procedure

                Object oAttachmentsGrid is a cDbCJGrid
                    Set Server to oAttachments_DD
                    Set Size to 65 437
                    Set Location to 0 0
                    Set pbAllowDeleteRow to False
                    Set pbAllowInsertRow to False
                    Set peAnchors to anAll
                    Set pbShowRowFocus to True
                    Set pbAllowAppendRow to False
                    Set piHighlightBackColor to clLtGray
                    Set pbSelectionEnable to True
                    Set pbUseAlternateRowBackgroundColor to True
                    Set pbSelectTextOnEdit to False

                    Object oAttachmentsCJContextMenu is a cCJContextMenu
                        Object oPreviewMenuItem is a cCJMenuItem
                            Set psCaption to "Preview"
                            Set psTooltip to "Preview"

                            Procedure OnExecute Variant vCommandBarControl
                                Forward Send OnExecute vCommandBarControl
                                String sFilePath sFileName sFullFileName sTugContractsPath sCustomerPath sLocationPath
                                Boolean bFilePathExists bFileExists bIsContract bCustPathExists bLocPathExists
                                //
                                Move (Trim(Attachments.FileName)) to sFileName
                                Move Attachments.ContractFlag to bIsContract
                                //
                                If (bIsContract) Begin
                                    //Contracts are stored in particular folder in TUG drive.
                                    Move ("\\fs\tug\Contracts\") to sTugContractsPath //This path should always exist!
                                    Move (sTugContractsPath+(Trim(Customer.Name))) to sCustomerPath
                                    File_Exist sCustomerPath bCustPathExists
                                    If (not(bCustPathExists)) Procedure_Return
                                    Move (sCustomerPath+"\"+(Trim(Location.Name))) to sLocationPath
                                    File_Exist sLocationPath bLocPathExists
                                    If (not(bLocPathExists)) Procedure_Return
                                    Move sLocationPath to sFilePath
                                End
                                Else Begin
                                    Get psHome of (phoWorkspace(ghoApplication)) to sFilePath
                                    Move (sFilePath+"Bitmaps\Attachments") to sFilePath
                                    File_Exist sFilePath bFilePathExists
                                    If (not(bFilePathExists)) Procedure_Return
                                End
                                //
                                Move (sFilePath+"\"+sFileName) to sFullFileName
                                File_Exist sFullFileName bFileExists
                                If (not(bFileExists)) Begin
                                    Send UserError ("File "+sFileName+" does not exists. Please contact IT.") "File Error"
                                    Procedure_Return
                                End
                                //
                                Runprogram Shell background sFullFileName
                            End_Procedure
                        End_Object

                        Object oDeleteMenuItem is a cCJMenuItem
                            Set psCaption to "Delete"
                            Set psTooltip to "Delete"

                            Procedure OnExecute Variant vCommandBarControl
                                Forward Send OnExecute vCommandBarControl
                                String sAttachIdno sAttachFileName sAttachName sTargetPath sTargetFile sCustomerName sLocationName
                                Integer eResponse iRetVal iJobNumber
                                Boolean bFail bSuccess bFileExists bIsLastRecord bIsContract bTargetPathExists bTargetFileExists bPathError bError
                                Handle hoDD
                                //
                                Move Order.JobNumber to iJobNumber
                                Move (Trim(Attachments.AttachIdno)) to sAttachIdno
                                Move (Trim(Attachments.FileName)) to sAttachFileName
                                Move (Trim(Attachments.Name)) to sAttachName
                                Move (Attachments.ContractFlag) to bIsContract
                                Move (Trim(Customer.Name)) to sCustomerName
                                Move (Trim(Location.Name)) to sLocationName
                                //Send Info_Box ("You decited to delete "+ sAttachName +" aka. " + sAttachFileName + " (AttachIdno: " +sAttachIdno+")" ) "Removing Attachment"
                                Move (YesNo_Box("Do you want to "+If(bIsContract,"detach","remove")*sAttachName + " from Job#"+ String(iJobNumber)+"?",(""+If(bIsContract,"Detach","Remove")* "this file?"),MB_DEFBUTTON1)) to eResponse
                                If (eResponse = MBR_Yes) Begin
                                    If (bIsContract) Begin
                                        String sTugContractsPath sCustomerPath sLocationPath
                                        Boolean bCustPathExists bLocPathExists
                                        //Since contracts are only attached to an Order, we can remove the Attachment record without double checking if it is attached to another record.
                                        Send Request_Delete of oAttachments_DD
                                        //Detach the Contract Record
                                        If (CustomerContracts.AssignedCount<>0) Begin
                                            //Contract is still assigned to another Order. Dont do anything.
                                        End
                                        Else Begin
                                            //Contracts are stored in particular folder in TUG drive.
                                            //Gather all required information
                                            Move ("\\fs\tug\Contracts\") to sTugContractsPath //This path should always exist!
                                            Move (sTugContractsPath+sCustomerName) to sCustomerPath
                                            File_Exist sCustomerPath bCustPathExists
                                            If (not(bCustPathExists)) Move True to bPathError //
                                            Move (sCustomerPath+"\"+sLocationName) to sLocationPath
                                            File_Exist sLocationPath bLocPathExists
                                            If (not(bLocPathExists)) Move True to bPathError
                                            Move (sLocationPath+"\") to sTargetPath
                                            Move (sTargetPath+sAttachFileName) to sTargetFile
                                            //Contract is no longer assigned. Contract Record can be deleted/set inactive
                                            //Contract records can only be deleted when they are no longer assigned.
                                            //Only Administrative staff has the right to delete the contracts within TUG.
                                            //Send Request_Delete of oCustomerContracts_DD
                                            // can the file be deleted as well?
                                            
                                        End
                                        
                                    End
                                    Else Begin
                                        //If it is an attachment, just remove Link to Order Record
                                        Reread Attachments
                                            Move 0 to Attachments.JobNumber
                                            //Move 1 to Attachments.ChangedFlag
                                            SaveRecord Attachments
                                        Unlock
                                        // was this the last record?
                                        Move (Attachments.EstimateIdno=0 and Attachments.QuoteIdno=0 and Attachments.JobNumber=0 and Attachments.InvoiceIdno=0) to bIsLastRecord
                                        If (bIsLastRecord) Begin
                                            // Delete File from storage if it is the last record.
                                            Get psHome of (phoWorkspace(ghoApplication)) to sTargetPath
                                            Move (sTargetPath+"Bitmaps\Attachments") to sTargetPath
                                            File_Exist sTargetPath bTargetPathExists
                                            If (not(bTargetPathExists)) Move True to bPathError
                                            Move (sTargetPath+"\"+sAttachFileName) to sTargetFile
                                            File_Exist sTargetFile bFileExists
                                            If (not(bPathError) and bFileExists) Begin
                                                //Attachment record can be removed
                                                Send Request_Delete of oAttachments_DD
                                                Get vDeleteFile sTargetFile to iRetVal
                                                Get ShowLastError to iRetval
                                                If (iRetVal=0) Begin
                                                    //Physical file was successfully deleted
                                                End
                                                Else Begin
                                                    Send UserError "File could not be deleted." "Error deleting file."
                                                End
                                            End
                                            Else Begin
                                                Get YesNo_Box ('File "'+sAttachName+'" was not found. Remove record from the database?') "Remove Record?" MB_DEFBUTTON1 to eResponse
                                                If (eResponse=MBR_Yes) Begin
                                                    Send Request_Delete of oAttachments_DD
                                                End
                                            End
                                        End
                                    End
                                End
//                                Send Refind_Records of oOrder_DD
//                                Send MoveToFirstRow of oAttachmentsGrid
                                Send Clear_All of oOrder_DD
                                Move iJobNumber to Order.JobNumber
                                Send Find of oOrder_DD EQ 1
                            End_Procedure
                        End_Object
                        
                        //ToDo: Build Copy function
//                        Object oCopyMenuItem is a cCJMenuItem
//                            Set psCaption to "Copy"
//                            Set psTooltip to "Copy"
//                            
//                            Procedure OnExecute Variant vCommandBarControl
//                                Forward Send OnExecute vCommandBarControl
//                                String sFilePath sFileName sFullFileName sBuffer
//                                //
//                                Move Attachments.FileName to sFileName
//                                Get psHome of (phoWorkspace(ghoApplication)) to sFilePath
//                                Move (sFilePath+"Bitmaps\Attachments\") to sFilePath
//                                Move (sFilePath+sFileName) to sFullFileName
//                                //Showln ("- sTargetFile: "+ sFullFileName)
//                                //
//                                Direct_Input sFullFileName
//                                Direct_Output "Clipboard:" 
//                                Showln "Contents of Clipboard"
//                                While (not (SeqEof))
//                                    // Read from the text file
//                                    Readln sBuffer
//                                    // Write to clipboard
//                                    Writeln sBuffer
//                                Loop
//                                Close_Input
//                                Close_Output
//                            End_Procedure
//                            
//                        End_Object
                    End_Object
    
                    Object oAttachments_Sequence is a cDbCJGridColumn
                        Entry_Item Attachments.Sequence
                        Set piWidth to 56
                        Set psCaption to "Seq."
                    End_Object
    
                    Object oAttachments_Name is a cDbCJGridColumn
                        Entry_Item Attachments.Name
                        Set piWidth to 188
                        Set psCaption to "Name"
                        
                        Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue                       
                            Variant vFont
                            Handle hoFont
                            //
                            Boolean bIsContract
                            Get RowValue of oAttachments_ContractFlag iRow to bIsContract
                            If (bIsContract) Begin
                                Get Create (RefClass(cComStdFont)) to hoFont
                                Get ComFont of hoGridItemMetrics to vFont
                                Set pvComObject of hoFont to vFont
                                Set ComBold of hoFont to True
                                Send Destroy of hoFont
                            End
                            Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                        End_Procedure
                    End_Object
    
                    Object oAttachments_Description is a cDbCJGridColumn
                        Entry_Item Attachments.Description
                        Set piWidth to 399
                        Set psCaption to "Description"
                        Set pbMultiLine to True
                    End_Object
   
                    Object oAttachments_OrderFlag is a cDbCJGridColumn
                        Entry_Item Attachments.OrderFlag
                        Set piWidth to 86
                        Set psCaption to "Print"
                        Set pbCheckbox to True

                        Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                            String sSourceFile sFileExt
                            Integer iDotPos
                            Boolean bIsImage
                            // Get file Extension
                            Move Attachments.FileName to sSourceFile
                            Move ((Length(sSourceFile)) - (RightPos(".", sSourceFile))) to iDotPos
                            Move (Right(sSourceFile, (iDotPos+1))) to sFileExt
                            //
                            Get IsImageFile sFileExt to bIsImage
                            Set pbEditable of oAttachments_OrderFlag to bIsImage
                            
                            //Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                        End_Procedure
                    End_Object

                    Object oAttachments_FileName is a cDbCJGridColumn
                        Entry_Item Attachments.FileName
                        Set piWidth to 200
                        Set psCaption to "FileName"
                        Set pbVisible to False
                    End_Object

                    Object oAttachments_ContractFlag is a cDbCJGridColumn
                        Entry_Item Attachments.ContractFlag
                        Set piWidth to 18
                        Set psCaption to "Contract"
                        Set pbCheckbox to True
                        Set Enabled_State to False
                        Set pbVisible to False
                    End_Object

                    Object oAttachments_ContractIdno is a cDbCJGridColumn
                        Entry_Item Attachments.ContractIdno
                        Set piWidth to 72
                        Set psCaption to "ContractIdno"
                        Set Enabled_State to False
                        Set pbVisible to False
                    End_Object
                    

//                    Object oCJGridColumnButton1 is a cCJGridColumnButton
//                        Set piWidth to 58
//                        Set piWidthButton to 58
//                        Set psCaptionButton to "Delete"
//                        Set psCaption to "Delete"
//                        //Set Color to clGray
//                        Set peHeaderAlignment to xtpAlignmentCenter
//                        Set piCaptionColorButton to clBlack
//                        Set psFontNameButton to ""
//                        
//                        
//                        Function ButtonPaint Handle hoGridItemMetrics Integer iRow String ByRef sValue Returns Boolean
//                            //yu can return false for rows you don't want to paint the button
//                            If (Attachments.AttachIdno<>0) Begin
//                                Function_Return True
//                            End
//                            Else Begin
//                                Function_Return False
//                            End
//                        End_Function
//                         
//                        Procedure ButtonAction Integer iRow Integer iCol Short llButton Short llShift
//                            String sAttachIdno sAttachFileName sAttachName sTargetPath sTargetFile
//                            Integer eResponse iRetVal
//                            Boolean bFail bIsLastRecord
//                            Handle hoDD
//                            //
//                            Move (Trim(Attachments.AttachIdno)) to sAttachIdno
//                            Move (Trim(Attachments.FileName)) to sAttachFileName
//                            Move (Trim(Attachments.Name)) to sAttachName
//
//                            //Send Info_Box ("You decited to delete "+ sAttachName +" aka. " + sAttachFileName + " (AttachIdno: " +sAttachIdno+")" ) "Removing Attachment"
//                            Move (YesNo_Box("Do you want to remove " + sAttachName + " from Job#"+ String(Order.JobNumber)+"?","Remove Attached File",MB_DEFBUTTON1)) to eResponse
//                            If (eResponse = MBR_Yes) Begin
//                                // Remove Link to Order Record
//                                Move 0 to Attachments.JobNumber
//                                //Move 1 to Attachments.ChangedFlag
//                                SaveRecord Attachments
//                                // was this the last record?
//                                Move (Attachments.EstimateIdno=0 and Attachments.QuoteIdno=0 and Attachments.JobNumber=0 and Attachments.InvoiceIdno=0) to bIsLastRecord
//                                If (bIsLastRecord) Begin
//                                    Get psHome of (phoWorkspace(ghoApplication)) to sTargetPath
//                                    Move (sTargetPath+"Bitmaps\Attachments\") to sTargetPath
//                                    Move (sTargetPath+sAttachFileName) to sTargetFile
//                                    Get vDeleteFile sTargetFile to iRetVal
//                                    Get ShowLastError to iRetval
//                                    If (iRetVal=0) Begin
//                                        Delete Attachments
//                                    End
//                                End
//                            End
//                            Send MoveToFirstRow of oAttachmentsGrid
//                            
//                        End_Procedure
//                        
//                        
//                    End_Object

                    Procedure OnComRowRClick Variant llRow Variant llItem
                        Send Popup of oAttachmentsCJContextMenu
                    End_Procedure

//                    Procedure OnRowChanged Integer iOldRow Integer iNewSelectedRow
//                        Forward Send OnRowChanged iOldRow iNewSelectedRow
//                        Set psImage of oDbImageContainer1 to (Trim(Attachments.FileName))
//                    End_Procedure

//
//                    Procedure OnComRowDblClick Variant llRow Variant llItem
//                        String sFilePath sFileName sFullFileName
//                        //
//                        Move Attachments.FileName to sFileName
//                        Get psHome of (phoWorkspace(ghoApplication)) to sFilePath
//                        Move (sFilePath+"Bitmaps\Attachments\") to sFilePath
//                        Move (sFilePath+sFileName) to sFullFileName
//                        //Showln ("- sTargetFile: "+ sFullFileName)
//                        //
//                        Runprogram Shell background sFullFileName
//                    End_Procedure
                    
                End_Object

//                Procedure OnFileDropped String sFilename Boolean bLast
//                    Showln "File Drop: " sFileName " " bLast
//                End_Procedure
            End_Object
            
            Object oUploadFilesButton is a Button
                Set Size to 15 16
                Set Location to 3 547
                Set peAnchors to anTopRight
                Set psImage to "ActionAddRecord.ico"
                Set peImageAlign to Button_ImageList_Align_Center
                
                Procedure OnClick
                    Boolean bOpen bReadOnly bHasOrderRecord 
                    String sFileTitle sTargetAddress sTargetFilename sRandom sFileExt sTarget
                    Integer iDotPos iAttach
                    String[] sSelectedFiles
                    //
                    Move (Order.JobNumber<>0) to bHasOrderRecord
                    //
                    If (bHasOrderRecord) Begin
                        Get Show_Dialog of oOpenDialog1 to bOpen
                        If bOpen Begin
                            Get TickReadOnly_State of oOpenDialog1 to bReadOnly
                            
                            Get Selected_Files of oOpenDialog1 to sSelectedFiles
                            For iAttach from 0 to (SizeOfArray(sSelectedFiles)-1)
                                If (bReadOnly) Append sSelectedFiles[iAttach] ' (Read-Only)' 
                            Loop
                            //Upload files
                            Send ProcessDroppedFiles of oDragAndDropContainer sSelectedFiles False
                        End
                        //Else Send Info_Box "Picture Upload was canceled"
                    End // bHasLocationRecord
                    Else Begin
                        Send UserError "Please select an Order first." "No Order selected"
                    End
                End_Procedure // OnClick
            End_Object
            
            Object oAttachmentsDbImageContainer is a cDbImageContainer
                Entry_Item Attachments.FileName

                Set Server to oAttachments_DD
                Set peImageStyle to ifFitOneSide
                Set Size to 63 97
                Set Location to 3 448
                Set peAnchors to anTopBottomRight
                Set pbSelectImage to False
                Set pbAutoTooltip to False
                Set pbLoadThumbnail to False
                Set pbShowScrollBars to False
                Set psImagePath to ((phoWorkspace(ghoApplication))+"Bitmaps\Attachments\")

                Procedure Refresh Integer eMode
                    Forward Send Refresh eMode
                End_Procedure
                
                Procedure Activating
                    Forward Send Activating
                    //
                    String sFilePath
                    Get psHome of (phoWorkspace(ghoApplication)) to sFilePath
                    Move (sFilePath+"Bitmaps\Attachments\") to sFilePath
                    Set psImagePath to sFilePath
                    //
                    Boolean bIsDataBound
                    Integer iDataFile iDataField
                    Get IsDataBound of oAttachmentsDbImageContainer to bIsDataBound
                    Get Data_File to iDataFile
                    Get Data_Field to iDataField
                    
                End_Procedure
            End_Object

            Object oUploadContractButton is a Button
                Set Size to 15 16
                Set Location to 19 547
                Set peAnchors to anTopRight
                Set psImage to "Order.ico"
                Set peImageAlign to Button_ImageList_Align_Center
                Set pbCenterToolTip to True
                Set psToolTip to "Add Customer Signed Contract"
//                Set Visible_State to False
                
                Procedure OnClick
                    Integer eResponse
                    Boolean bHasOrderRecord
                    //
                    Move (Order.JobNumber<>0) to bHasOrderRecord
                    //
                    If (bHasOrderRecord) Begin
                        Move (YesNoCancel_Box("Would you like to UPLOAD a signed contract for this Job?", "UPLOAD CONTRACT", MB_DEFBUTTON1)) to eResponse
                        If (eResponse=MBR_Yes) Begin
                            //Prompt for file upload here
                            Boolean bOpen bReadOnly bHasLocationRecord bFail
                            String sFileTitle sTargetAddress sTargetFilename sRandom sFileExt sTarget
                            Integer iDotPos iAttach
                            String[] sSelectedFiles
                            //
                            Move (Location.LocationIdno>0) to bHasLocationRecord
                            //
                            If (bHasLocationRecord) Begin
                                Get Show_Dialog of oOpenDialog1 to bOpen
                                If bOpen Begin
                                    Get TickReadOnly_State of oOpenDialog1 to bReadOnly
                                    
                                    Get Selected_Files of oOpenDialog1 to sSelectedFiles
                                    For iAttach from 0 to (SizeOfArray(sSelectedFiles)-1)
                                        If (bReadOnly) Append sSelectedFiles[iAttach] ' (Read-Only)' 
                                    Loop
                                    //Upload files
                                    Send ProcessDroppedFiles of oDragAndDropContainer sSelectedFiles True
                                End
                                //Else Send Info_Box "Picture Upload was canceled"
                            End // bHasLocationRecord
                        End
                        If (eResponse=MBR_No) Begin
                            Move (YesNo_Box("Would you like to SELECT and existing contract for this Job?", "ASSIGN CONTRACT", MB_DEFBUTTON1)) to eResponse
                            If (eResponse=MBR_Yes) Begin
                                //Popup Contract Prompt, showing non-expired contracts for current customer
                                Boolean bSuccess
                                Integer iContractIdno iJobNumber iAssignedCount
                                String sFileName sNewFileName sHr sMin sSec
                                Date dToday
                                //
                                Sysdate dToday sHr sMin sSec
                                Move Order.JobNumber to iJobNumber
                                Get SelectExistingContract of CustomerContracts_sl Customer.CustomerIdno Order.JobOpenDate (&iContractIdno) (&sFileName) (&sNewFileName) to bSuccess
                                If (bSuccess) Begin
                                    Integer iSeq
                                    Handle hoDD
                                    // Continue Sequence.
                                    Constraint_Set 1
                                    Constrain Attachments.JobNumber eq iJobNumber
                                    Constrained_Find Last Attachments by 7
                                    If (Found) Begin
                                        Move (Attachments.Sequence) to iSeq 
                                    End
                                    Else Begin
                                        Move 0 to iSeq
                                    End
                                    Constraint_Set 1 Delete
                                    //
                                    Move oAttachments_DD to hoDD
                                    Send Clear of hoDD
                                    Move iContractIdno to CustomerContracts.ContractIdno
                                    Send Request_Find of hoDD EQ CustomerContracts.File_Number 1
                                    Increment iSeq
                                    Set Field_Changed_Value of hoDD Field Attachments.JobNumber             to iJobNumber
                                    Set Field_Changed_Value of hoDD Field Attachments.CreatedBy             to gsUsername
                                    Set Field_Changed_Value of hoDD Field Attachments.CreatedDate           to dToday
                                    Set Field_Changed_Value of hoDD Field Attachments.CreatedTime           to (sHr+":"+sMin+":"+sSec)
                                    Set Field_Changed_Value of hoDD Field Attachments.Name                  to sFileName
                                    Set Field_Changed_Value of hoDD Field Attachments.Sequence              to iSeq
                                    Set Field_Changed_Value of hoDD Field Attachments.FileName              to sNewFileName
                                    Set Field_Changed_Value of hoDD Field Attachments.OrderFlag             to 0
                                    Set Field_Changed_Value of hoDD Field Attachments.ContractFlag          to (iContractIdno<>0)
                                    //
                                    Get Request_Validate    of hoDD                                     to bFail
                                    If (not(bFail)) Begin
                                        Send Request_Save       of hoDD
                                        Move (Err) to bFail
                                    End
                                    If (bFail) Begin
                                        Send Clear of hoDD
                                        Send MoveToFirstRow of oAttachmentsGrid
                                        Send Stop_Box "Processing stopped at Attachments Validation" "Processing Error"
                                        Procedure_Return
                                    End
                                    //Get IncrementContractAssignment of oCustomerContracts iContractIdno to iAssignedCount
                                End
                            End
                        End                        
                    End
                    Else Begin
                        Send UserError "Please select an Order first." "No Order selected"
                    End
                    //

                End_Procedure // OnClick
            End_Object

            Procedure Activating
                Forward Send Activating
            End_Procedure
            
        End_Object

//        Object oAttachmentPictureTabPage is a dbTabPage
//            Set Label to 'Attachments (Picture)'
//            Set pbHighlightTab to False
//
//            Object oImageGallery1 is a cImageGallery
//                Set Size to 66 560
//                Set Location to 2 3
//                Set peAnchors to anAll
//                
//                { DesignTime = False }
//                Property Integer piCurrentRows
//                { DesignTime = False }
//                Property Integer piCurrentColumns
//                { DesignTime = False }
//                Property Handle phoCurrentImageContainer
//        
//                Property Integer piImageDisplayWidth 50
//                Property Integer piImageDisplayHeight 50
//                
//                Procedure DisplayImagePage Integer iPage
//                    Handle[] hoImageContainers
//                    tPictureNames PictureNames
//                    Integer iImageContainers iImageContainerElement iPictureElement iPictures
//                    String sSetImageName
//                    Boolean bChangesMade
//        
//                    Get phoImageContainers to hoImageContainers
//                    Get pPictureNames to PictureNames
//        
//                    Move (SizeOfArray (hoImageContainers)) to iImageContainers
//                    Move (SizeOfArray (PictureNames.sPictureNames)) to iPictures
//                    Move ((iPage - 1) * iImageContainers) to iPictureElement
//                    Decrement iImageContainers
//        
//                    For iImageContainerElement from 0 to iImageContainers
//                        If (iPictureElement < iPictures) Begin
//                            Set psImage of hoImageContainers[iImageContainerElement] to PictureNames.sPictureNames[iPictureElement]
//                            Get psImage of hoImageContainers[iImageContainerElement] to sSetImageName
//                            If (sSetImageName <> "") Begin
//                                Set pbVisible of hoImageContainers[iImageContainerElement] to True
//                                Increment iPictureElement
//                            End
//                            Else Begin
//                                Move (RemoveFromArray (PictureNames.sPictureNames, iPictureElement)) to PictureNames.sPictureNames
//                                Decrement iPictures
//                                Move True to bChangesMade
//                                Set pbVisible of hoImageContainers[iImageContainerElement] to False
//                                Decrement iImageContainerElement
//                            End
//                        End
//                        Else Begin
//                            Set psImage of hoImageContainers[iImageContainerElement] to ""
//                            Set pbVisible of hoImageContainers[iImageContainerElement] to False
//                        End
//                    Loop
//        
//                    If (bChangesMade) Begin
//                        Set pPictureNames to PictureNames
//                        Send CalculatePages False
//                    End
//                End_Procedure
//        
//                Procedure RemoveImageContainers
//                    Handle[] hoImageContainers
//                    Integer iElements iElement
//        
//                    Get phoImageContainers to hoImageContainers
//                    Move (SizeOfArray (hoImageContainers)) to iElements
//                    Decrement iElements
//                    For iElement from 0 to iElements
//                        Send Destroy of hoImageContainers[iElement]
//                    Loop
//                End_Procedure
//
//                
//                Procedure BuildDisplay
//                    Integer iSize iWidth iHeight iColumns iRows iColumn iRow
//                    Integer iElement iImageContainerSize iCurrentRows iCurrentColumns
//                    Integer iImageDisplayWidth iImageDisplayHeight iBackColor
//                    Handle[] hoImageContainers
//                    Handle hWnd
//                    Boolean bUseBlackBackground bShowThumbnails bShowScrollBars
//        
//                    Get Window_Handle to hWnd
//                    If (hWnd = 0) Begin
//                        Procedure_Return
//                    End
//        
//                    Get Size to iSize
//                    Get piImageDisplayHeight to iImageDisplayHeight
//                    Get piImageDisplayWidth to iImageDisplayWidth
//        
//                    Move (Low (iSize)) to iWidth
//                    Move (Hi (iSize)) to iHeight
//        
//                    Move ((iWidth - 10) / (iImageDisplayWidth + 5)) to iColumns
//                    Move ((iHeight - 10) / (iImageDisplayHeight + 2)) to iRows
//        
//                    Get piCurrentColumns to iCurrentColumns
//                    Get piCurrentRows to iCurrentRows
//        
//                    If (iCurrentColumns <> iColumns or iCurrentRows <> iRows) Begin
//                        Set piCurrentColumns to iColumns
//                        Set piCurrentRows to iRows
////                        Get ReadDword of ghoApplication "Preferences" "BlackBackground" False to bUseBlackBackground
////                        If (bUseBlackBackground) Begin
////                            Move clBlack to iBackColor
////                        End
////                        Else Begin
////                            Move clBtnFace to iBackColor
////                        End
////        
//                        Set Color to iBackColor
//        
//                        Send RemoveImageContainers
//        
////                        Get ReadDword of ghoApplication "Preferences" "ShowThumbnails" False to bShowThumbnails
////                        Get ReadDword of ghoApplication "Preferences" "ShowScrollBars" False to bShowScrollBars
//        
//                        For iRow from 1 to iRows
//                            For iColumn from 1 to iColumns
//                                Move (SizeOfArray (hoImageContainers)) to iElement
//                                Get CreateNamed (RefClass (cGalleryImageContainer)) (SFormat ("ImageContainer_Row_%1_Column_%2", iRow, iColumn)) to hoImageContainers[iElement]
//                                Set pbLoadThumbnail of hoImageContainers[iElement] to bShowThumbnails
//                                Set pbShowScrollBars of hoImageContainers[iElement] to bShowScrollBars
//                                Set Size of hoImageContainers[iElement] to iImageDisplayHeight iImageDisplayWidth
//                                Set pbSelectImage of hoImageContainers[iElement] to False
//                                Set pcBackColor of hoImageContainers[iElement] to iBackColor
//                                Set Location of hoImageContainers[iElement] to ((iRow - 1) * (iImageDisplayHeight + 2) + 5) ((iColumn - 1) * (iImageDisplayWidth + 5) + 5)
//                                Send Add_Focus of hoImageContainers[iElement] Self
//                            Loop
//                        Loop
//        
//                        Set phoImageContainers to hoImageContainers
//                    End
//                End_Procedure
//
//                Procedure Activating
//                    Forward Send Activating
//                    Send BuildDisplay
//                End_Procedure
//            End_Object
//
//
//            
//            
//        End_Object

        Object oProdNoteTabPage is a dbTabPage
            Set Label to 'Production Notes'
            Set pbHighlightTab to True

            Object oProductionNoteGrid is a cDbCJGrid
                Set Server to oProdNote_DD
                Set Size to 64 488
                Set Location to 3 2
                Set peAnchors to anAll
                Set pbAllowDeleteRow to False
                Set pbAllowAppendRow to False
                Set pbAllowInsertRow to False
                Set pbEditOnClick to False
                Set pbReadOnly to True
                Set pbSelectionEnable to True
                Set piHighlightBackColor to clLtGray
                Set piHighlightForeColor to clBlack
                Set piSelectedRowBackColor to clLtGray
                Set piSelectedRowForeColor to clBlack

                Object oProdNote_CreatedDate is a cDbCJGridColumn
                    Entry_Item ProdNote.CreatedDate
                    Set piWidth to 73
                    Set psCaption to "Created"
                    Set pbEditable to False
                End_Object

                Object oProdNote_Note is a cDbCJGridColumn
                    Entry_Item ProdNote.Note
                    Set piWidth to 486
                    Set psCaption to "Note"
                    Set pbMultiLine to True
                End_Object

                Object oProdNote_CreatedBy is a cDbCJGridColumn
                    Entry_Item ProdNote.CreatedBy
                    Set piWidth to 99
                    Set psCaption to "CreatedBy"
                    Set pbEditable to False
                End_Object

                Object oProdNote_AcknowledgedDate is a cDbCJGridColumn
                    Entry_Item ProdNote.AcknowledgedDate
                    Set piWidth to 89
                    Set psCaption to "Acknowledged"
                    Set pbEditable to False
                End_Object

                Object oProdNote_AcknowledgedBy is a cDbCJGridColumn
                    Entry_Item ProdNote.AcknowledgedBy
                    Set piWidth to 107
                    Set psCaption to "AcknowledgedBy"
                End_Object

                Procedure Refresh Integer eMode
                    Forward Send Refresh eMode
                End_Procedure

            End_Object

            Object oGroup1 is a Group
                Set Size to 63 67
                Set Location to 3 494
                Set Label to 'Options'
                Set peAnchors to anTopBottomRight

                Object oAddButton is a Button
                    Set Location to 13 10
                    Set Label to 'Add'
                    Set peAnchors to anTopBottomRight
                
                    // fires when the button is clicked
                    Procedure OnClick
                        String sProdNote
                        Get PopupUserInput of oUserInputDialog "Production Note" "Please enter your production note" "" False to sProdNote
                        //
                        Send Clear of oProdNote_DD
                        Set Field_Changed_Value of oProdNote_DD Field ProdNote.Note to sProdNote
                        Send Request_Save of oProdNote_DD
                    End_Procedure
                
                End_Object
                Object oDeleteButton is a Button
                    Set Location to 28 10
                    Set Label to 'Delete'
                    Set peAnchors to anTopBottomRight
                
                    // fires when the button is clicked
                    Procedure OnClick
                        String sProdNote sJobNumber
                        Boolean bCancel
                        Date dToday
                        Sysdate dToday
                        Get Field_Current_Value of oProdNote_DD Field ProdNote.Note to sProdNote
                        Get Field_Current_Value of oOrder_DD Field Order.JobNumber to sJobNumber
                        Get Confirm ("Delete Prod Note: \n\n ''"+ sProdNote +"'' from Order" * sJobNumber) to bCancel
                        If (not(bCancel)) Begin
                            //Send Request_Delete of oProdNote_DD
                            Set Field_Changed_Value of oProdNote_DD Field ProdNote.DeletedFlag to 1
                            Set Field_Changed_Value of oProdNote_DD Field ProdNote.DeletedDate to dToday
                            Set Field_Changed_Value of oProdNote_DD Field ProdNote.DeletedBy to gsUserFullName
                            Send Request_Save of oProdNote_DD
                            Send MovetoFirstRow of oProductionNoteGrid
                        End
                    End_Procedure
                
                End_Object
                Object oAcknowledgeButton is a Button
                    Set Location to 43 10
                    Set Label to 'Acknowledge'
                    Set peAnchors to anTopBottomRight
                
                    // fires when the button is clicked
                    Procedure OnClick
                        Integer iProdNote
                        Date dToday dAckDate
                        Sysdate dToday
                        Get Field_Current_Value of oProdNote_DD Field ProdNote.ProdNoteIdno to iProdNote
                        Get Field_Current_Value of oProdNote_DD Field ProdNote.AcknowledgedDate to dAckDate
                        If (iProdNote<>0) Begin
                            If (dAckDate=0) Begin // Ignore when already filled in
                            Set Field_Changed_Value of oProdNote_DD Field ProdNote.AcknowledgedDate to dToday
                            Set Field_Changed_Value of oProdNote_DD Field ProdNote.AcknowledgedBy to gsUserFullName
                            Send Request_Save of oProdNote_DD                                
                            End
                        End
                        Else Begin
                            Send Info_Box ("No Production Note selected") "Select Production Note"
                        End
                    End_Procedure
                
                End_Object
            End_Object

            Procedure Entering Returns Integer
                Integer iRetVal
                Forward Get msg_Entering to iRetVal
                Send Activate of oProductionNoteGrid
                Procedure_Return iRetVal
            End_Procedure
        End_Object

        Object oNotesTabPage is a dbTabPage
            Set Label to "Job Notes"

            Object oOrder_Specification is a cDbTextEdit
                Entry_Item Order.Specification
                Set Location to 4 3
                Set Size to 60 560
                Set peAnchors to anAll
            End_Object
        End_Object

//        Object oDbTabPage1 is a dbTabPage
//            Set Label to 'Job Cost'
//
//            Object oDbCJGrid1 is a cDbCJGrid
//                Set Server to oJobcosts_DD
//                Set Size to 66 561
//                Set Location to 2 2
//
//                Object oJobcosts_JobcostsId is a cDbCJGridColumn
//                    Entry_Item Jobcosts.JobcostsId
//                    Set piWidth to 69
//                    Set psCaption to "JobcostsId"
//                    Set pbVisible to False
//                End_Object
//
//                Object oJobcosts_WorkDate is a cDbCJGridColumn
//                    Entry_Item Jobcosts.WorkDate
//                    Set piWidth to 61
//                    Set psCaption to "WorkDate"
//                End_Object
//
//                Object oMastOps_Name is a cDbCJGridColumn
//                    Entry_Item MastOps.Name
//                    Set piWidth to 324
//                    Set psCaption to "Name"
//                End_Object
//
//                Object oJobcosts_Notes is a cDbCJGridColumn
//                    Entry_Item Jobcosts.Notes
//                    Set piWidth to 338
//                    Set psCaption to "Notes"
//                End_Object
//
//                Object oJobcosts_Quantity is a cDbCJGridColumn
//                    Entry_Item Jobcosts.Quantity
//                    Set piWidth to 62
//                    Set psCaption to "Quantity"
//                End_Object
//
//                Object oJobcosts_UnitCost is a cDbCJGridColumn
//                    Entry_Item Jobcosts.UnitCost
//                    Set piWidth to 122
//                    Set psCaption to "UnitCost"
//                End_Object
//
//                Object oJobcosts_TotalCost is a cDbCJGridColumn
//                    Entry_Item Jobcosts.TotalCost
//                    Set piWidth to 74
//                    Set psCaption to "TotalCost"
//                End_Object
//
//                
//            End_Object
//        End_Object

//        Object oJobCostTabPage is a dbTabPage
//            Set Label to "Job Cost Detail"
//
//            Object oOrder_LaborCost is a cGlblDbForm
//                Entry_Item Order.LaborCost
//                Set Location to 13 70
//                Set Size to 13 66
//                Set Label to "Labor Cost:"
//                Set Label_Col_Offset to 3
//                Set Label_Justification_Mode to JMode_Right
//                Set Enabled_State to False
//            End_Object
//
//            Object oOrder_TravelCost is a cGlblDbForm
//                Entry_Item Order.TravelCost
//                Set Location to 32 70
//                Set Size to 13 67
//                Set Label to "Travel Cost:"
//                Set Label_Col_Offset to 3
//                Set Label_Justification_Mode to JMode_Right
//                Set Enabled_State to False
//            End_Object
//
//            Object oOrder_JobCostTotal is a cGlblDbForm
//                Entry_Item Order.JobCostTotal
//                Set Location to 51 70
//                Set Size to 13 66
//                Set Label to "Equip/Mat/OS:"
//                Set Label_Col_Offset to 3
//                Set Label_Justification_Mode to JMode_Right
//                Set Enabled_State to False
//            End_Object
//
//            Object oDbGrid1 is a dbGrid
//                Set Server to oTrans_DD
//                Set Size to 95 232
//                Set Location to 12 144
//                
//                Function MinInHours Returns Number
//                    Number nNumber
//                    Move Trans.ElapsedMinutes to nNumber
//                    Calc (nNumber/60.00) to nNumber
//                    Function_Return nNumber
//                End_Function
//
//                Begin_Row
//                    Entry_Item MastOps.Name
//                    Entry_Item (MinInHours(Self))
//                End_Row
//
//                Set Form_Width 0 to 182
//                Set Header_Label 0 to "Name"
//                Set Form_Width 1 to 42
//                Set Header_Label 1 to "Hours"
//                Set peDisabledColor to clBlack
//                Set peDisabledTextColor to clBlack
//            End_Object
//
//        End_Object
        
        Object oInvoicesTabPage is a dbTabPage
            Set Label to "Invoices"

            Object oInvoiceGrid is a cDbCJGrid
                Set Server to oInvhdr_DD
                Set Size to 47 560
                Set Location to 4 3
                Set peAnchors to anAll
                Set pbAllowEdit to False
                Set pbAutoAppend to False
                Set pbAllowInsertRow to False
                Set pbAllowDeleteRow to False
                Set pbAllowAppendRow to False

                Object oInvhdr_InvoiceIdno is a cDbCJGridColumn
                    Entry_Item Invhdr.InvoiceIdno
                    Set piWidth to 92
                    Set psCaption to "Inv #"
                End_Object

                Object oInvhdr_InvoiceDate is a cDbCJGridColumn
                    Entry_Item Invhdr.InvoiceDate
                    Set piWidth to 125
                    Set psCaption to "Invoice Date"
                End_Object

                Object oInvhdr_QBInvoiceNumber is a cDbCJGridColumn
                    Entry_Item Invhdr.QBInvoiceNumber
                    Set piWidth to 82
                    Set psCaption to "QB Inv #"
                End_Object

                Object oInvhdr_Terms is a cDbCJGridColumn
                    Entry_Item Invhdr.Terms
                    Set piWidth to 112
                    Set psCaption to "Terms"
                End_Object

                Object oInvhdr_QBPaidFlag is a cDbCJGridColumn
                    Entry_Item Invhdr.QBPaidFlag
                    Set piWidth to 75
                    Set psCaption to "Paid"
                    Set pbCheckbox to True
                    Set peTextAlignment to xtpAlignmentCenter
                End_Object

                Object oInvhdr_StartDateRange is a cDbCJGridColumn
                    Set piWidth to 273
                    Set psCaption to "Inv. Date Range"
                    
                    Procedure OnSetCalculatedValue String ByRef sValue
                        Move (String(Invhdr.StartDateRange) *"-"* String(Invhdr.StopDateRange)) to sValue
                    End_Procedure
                    
                End_Object

                Object oInvhdr_TotalAmount is a cDbCJGridColumn
                    Entry_Item Invhdr.TotalAmount
                    Set piWidth to 221
                    Set psCaption to "Total Amount"
                    Set psMask to "$ #,###,##0.00"
                End_Object

                Object oCJInvoiceContextMenu is a cCJContextMenu
             
                    Object oPrintInvoice is a cCJMenuItem
                        Set psCaption to "Print/Preview Invoice"
                        Set psTooltip to "Print/Preview Invoice"

                        Procedure OnExecute Variant vCommandBarControl
                            Forward Send OnExecute vCommandBarControl
                            Integer iInvIdno
                            Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno to iInvIdno
                            If (iInvIdno>0) Begin
                                Send DoJumpStartReport of oCustomerInvoice iInvIdno                        
                            End
                        End_Procedure
                        
                        
                    End_Object
                    
                    
                        Object oInvToolsMenuItem is a cCJMenuItem
                            Set psCaption to "InvTools"
                            Set psTooltip to "InvTools"
                            Set peControlType to xtpControlPopup
    
                            Object oVoidInvoiceMenuItem is a cCJMenuItem
                                Set psCaption to "Void Invoice"
                                Set psTooltip to "Void Invoice"

                                Procedure OnExecute Variant vCommandBarControl
                                    Boolean bHasRecord bSuccess
                                    Integer iInvIdno
                                    Forward Send OnExecute vCommandBarControl
                                    Get HasRecord of oInvhdr_DD to bHasRecord
                                    If (bHasRecord) Begin
                                        Send Refind_Records of oInvhdr_DD
                                        // Run full Void process to release transactions
                                        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno to iInvIdno
                                        Get DoVoidInvoice of oInvoiceCreationProcess iInvIdno to bSuccess
                                        If (bSuccess) Begin
                                            Send Info_Box ("Invoice#"*String(iInvIdno)*"was voided successfully.") "Invoice Voided"
                                        End
                                        //Set Field_Changed_Value of oInvhdr_DD Field Invhdr.VoidFlag to 1
                                        //Send Request_Save of oInvhdr_DD
                                    End
                                    Send MovetoFirstRow to oInvoiceGrid
                                End_Procedure
                            End_Object
    
                        End_Object

                    Procedure OnCreate
                        Forward Send OnCreate
                        If (giUserRights <70) Begin
                            Set pbVisible of oInvToolsMenuItem to False
                        End
                    End_Procedure
                    
                End_Object

                Procedure OnComRowDblClick Variant llRow Variant llItem
                    Integer iInvId
                    Boolean bCancel
                    
                    Forward Send OnComRowDblClick llRow llItem
                    
                    Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno to iInvId
                    If (iInvId>0) Begin
                        Send DoJumpStartReport of oCustomerInvoice iInvId                        
                    End
                    
                End_Procedure

                Procedure OnComRowRClick Variant llRow Variant llItem
                    //Forward Send OnComRowRClick llRow llItem
                    Send Popup of oCJInvoiceContextMenu
                End_Procedure

            End_Object

            Object oOrder_InvoiceAmt is a cGlblDbForm
                Entry_Item Order.InvoiceAmt
                Set Location to 54 437
                Set Size to 13 124
                Set Label to "Invoice Amount:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                Set Enabled_State to False
                Set Entry_State to False
                Set Form_Datatype to Mask_Numeric_Window
                Set Form_Mask to "$ #,###,##0.00"
                Set peAnchors to anBottomLeftRight
            End_Object
        End_Object
    
    End_Object

    Object oOrderDetailContainer is a cGlblDbContainer3d
        Set Size to 177 571
        Set Location to 123 5
        Set Border_Style to Border_Normal
        Set peAnchors to anAll

        Object oOrderDtlDbCJGrid is a cDbCJGrid
            Set Server to oOrderDtl_DD
            Set Size to 121 562
            Set Location to 3 4
            Set Ordering to 3
            Set peAnchors to anAll
            Set pbHotTracking to True
            Set pbShowRowFocus to True

            Procedure PromptUpdate Handle hoPrompt
                String[] SelectedItem
                Handle hoDD
                //
                Get Server to hoDD
                Send Refind_Records of hoDD
                //
                Get SelectedColumnValues of hoPrompt 1 to SelectedItem //receiving the selected MastOpsIdno (Column 1)
                If (SizeOfArray(SelectedItem)) Begin
                    Clear MastOps //just to be sure
                    Move SelectedItem[0] to MastOps.MastOpsIdno
                    Send Request_Find of hoDD EQ MastOps.File_Number 1
                    Send UpdateCurrentValue of oOrderDtl_InvoiceDescription (Trim(MastOps.Description))
                    Send UpdateCurrentValue of oOrderDtl_Price MastOps.SellRate
                End
            End_Procedure

            Procedure ToggleThisLineItemStatus
                Integer eResponse
                DateTime dtNow
                Move (YesNo_Box((If(not(SelectedRowValue(oOrderDtl_CompletedFlag)),"Complete","Release"))+" this line item categorized as"*Trim(SelectedRowValue(oWorkType_WorkTypeId))*"?", "", MB_DEFBUTTON2)) to eResponse
                If (eResponse = MBR_YES) Begin
                    Send Cursor_Wait to Cursor_Control
                    Move (CurrentDateTime()) to dtNow
                    Send UpdateCurrentValue of oOrderDtl_CompletedFlag (not(SelectedRowValue(oOrderDtl_CompletedFlag)))
                    Send UpdateCurrentValue of oOrderDtl_CompletedBy (If(SelectedRowValue(oOrderDtl_CompletedFlag)=1,gsUsername,''))
                    Send UpdateCurrentValue of oOrderDtl_CompletedDateTime (If(SelectedRowValue(oOrderDtl_CompletedFlag)=1,String(dtNow),''))
                    Send Request_Save of oOrderDtl_DD
                    Send Cursor_Ready to Cursor_Control  
                End
            End_Procedure

            Object oOrderDtl_OrderDtlIdno is a cDbCJGridColumn
                Entry_Item OrderDtl.OrderDtlIdno
                Set piWidth to 72
                Set psCaption to "OrderDtlIdno"
                Set pbVisible to False
            End_Object

            Object oOrderDtl_Sequence is a cDbCJGridColumn
                Entry_Item OrderDtl.Sequence
                Set piWidth to 16
                Set psCaption to "Seq."
                Set piMaximumWidth to 20
                Set piMinimumWidth to 15
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
                
            End_Object

            Object oMastOps_Name is a cDbCJGridColumnSuggestion
                Entry_Item MastOps.Name
                Set piWidth to 82
                Set psCaption to "Name"
                Set pbFullText to True
                Set piStartAtChar to 1
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure

                Procedure OnSelectSuggestion String sSearch tSuggestion Suggestion
                    Forward Send OnSelectSuggestion sSearch Suggestion
                    If (Suggestion.aValues[0]=(Trim(MastOps.Name))) Begin
                        Send UpdateCurrentValue of oOrderDtl_InvoiceDescription (Trim(MastOps.Description))
                        Send UpdateCurrentValue of oOrderDtl_Price MastOps.SellRate
                    End
                End_Procedure
                
                Procedure Prompt_Callback Handle hoPrompt
                    String sValue
                    //
                    Set peUpdateMode of hoPrompt to umPromptCustom
                    Set piUpdateColumn of hoPrompt to 0 // on name column
                    Set phmPromptUpdateCallback of hoPrompt to (RefProc(PromptUpdate))
                    Get SelectedRowValue of oMastOps_Name to sValue
                    Set psSeedValue of hoPrompt to sValue
                End_Procedure
            End_Object

            Object oWorkType_WorkTypeId is a cDbCJGridColumn
                Entry_Item WorkType.WorkTypeId
                Set piWidth to 41
                Set psCaption to "Division"
                Set pbFocusable to False
                Set pbEditable to False
                Set piMaximumWidth to 50
                Set piMinimumWidth to 25
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
            End_Object

            Object oOrderDtl_InvoiceDescription is a cDbCJGridColumn
                Entry_Item OrderDtl.InvoiceDescription
                Set piWidth to 165
                Set psCaption to "Description"
                Set pbMultiLine to True
                Set peTextAlignment to xtpAlignmentWordBreak
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
            End_Object

            Object oOrderDtl_Quantity is a cDbCJGridColumn
                Entry_Item OrderDtl.Quantity
                Set piWidth to 44
                Set psCaption to "Quantity"
                Set piMinimumWidth to 80
                Set piMaximumWidth to 80
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
            End_Object

            Object oOrderDtl_Price is a cDbCJGridColumn
                Entry_Item OrderDtl.Price
                Set piWidth to 55
                Set psCaption to "Price"
                Set piMinimumWidth to 100
                Set piMaximumWidth to 100
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
            End_Object

            Object oOrderDtl_TaxAmount is a cDbCJGridColumn
                Entry_Item OrderDtl.TaxAmount
                Set piWidth to 39
                Set psCaption to "Tax"
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
            End_Object

            Object oOrderDtl_Amount is a cDbCJGridColumn
                Entry_Item OrderDtl.Amount
                Set piWidth to 70
                Set psCaption to "Amount"
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
            End_Object

            Object oOrderDtl_Instructions is a cDbCJGridColumn
                Entry_Item OrderDtl.Instructions
                Set piWidth to 150
                Set psCaption to "Instructions"
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
            End_Object

            Object oOrderDtl_Sqft is a cDbCJGridColumn
                Entry_Item OrderDtl.Sqft
                Set piWidth to 61
                Set psCaption to "Sqft"
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
            End_Object

            Object oOrderDtl_Lnft is a cDbCJGridColumn
                Entry_Item OrderDtl.Lnft
                Set piWidth to 43
                Set psCaption to "Lnft"
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
            End_Object

            Object oOrderDtl_MatQuantity is a cDbCJGridColumn
                Entry_Item OrderDtl.MatQuantity
                Set piWidth to 33
                Set psCaption to "MatQuantity"
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
            End_Object

            Object oOrderDtl_TotalManHours is a cDbCJGridColumn
                Entry_Item OrderDtl.TotalManHours
                Set piWidth to 27
                Set psCaption to "TotalManHours"
                
                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Number nStatus
                    Handle hoFont
                    Variant vFont
                    Get RowValue of oOrderDtl_CompletedFlag iRow to nStatus
                    If (nStatus<>0) Begin // Anytime the status has been altered, make font bold
                        Get Create (RefClass(cComStdFont)) to hoFont
                        Get ComFont of hoGridItemMetrics to vFont
                        Set pvComObject of hoFont to vFont
                        Set ComBold of hoFont to True
                        Send Destroy of hoFont
                    End
                    Case Begin
                        Case (nStatus=0) // Not started, remain Black
                            Set ComForeColor of hoGridItemMetrics to clBlack
                            Case Break
                        Case (nStatus=1) // Completed, change to Green
                            Set ComForeColor of hoGridItemMetrics to clGreen
                            Case Break
                        Case Else // Anything Else, assume its WIP, change to Orange
                            Set ComForeColor of hoGridItemMetrics to clOrange
                    Case End
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure

                Procedure OnEndEdit String sOldValue String sNewValue
                    Forward Send OnEndEdit sOldValue sNewValue
                End_Procedure

                Function OnExiting Returns Boolean
                    Boolean bRetVal
                    Forward Get OnExiting to bRetVal
                    
                    Function_Return bRetVal
                End_Function
                
                Procedure OnExit
                    Forward Send OnExit
                End_Procedure

                
                
            End_Object

            Object oOrderDtl_CompletedReqFlag is a cDbCJGridColumn
                Entry_Item OrderDtl.CompletedReqFlag
                Set piWidth to 18
                Set psCaption to "CompletedReqFlag"
                Set pbEditable to False
                Set pbCheckbox to True
                Set pbVisible to False
            End_Object

            Object oOrderDtl_CompletedFlag is a cDbCJGridColumn
                Entry_Item OrderDtl.CompletedFlag
                Set piWidth to 18
                Set psCaption to "CompletedFlag"
                Set pbEditable to False
                Set pbCheckbox to False
                Set pbVisible to False
            End_Object

            Object oOrderDtl_SubOnlyFlag is a cDbCJGridColumn
                Entry_Item OrderDtl.SubOnlyFlag
                Set pbEditable to False
                Set piWidth to 18
                Set psCaption to "SubOnlyFlag"
                Set pbCheckbox to True
                Set pbVisible to False
            End_Object

            Object oOrderDtl_CompletedDateTime is a cDbCJGridColumn
                Entry_Item OrderDtl.CompletedDateTime
                Set pbVisible to False
                Set piWidth to 207
                Set psCaption to "CompletedDateTime"
            End_Object

            Object oOrderDtl_CompletedBy is a cDbCJGridColumn
                Entry_Item OrderDtl.CompletedBy
                Set pbVisible to False
                Set piWidth to 450
                Set psCaption to "CompletedBy"
            End_Object

            Object oOrderDtlCompletedCJGridColumnButton is a cCJGridColumnButton
                Set psCaption to "Complete"
                Set piWidth to 66
                Set piWidthButton to 64
                Set piHeightButton to 30
                Set psCaptionButton to "Complete"
                Set piCaptionColorButton to clGrayText
                Set psFontNameButton to "Segoe UI"
                Set piFontSizeButton to 8
                Set pbUseColumnTextAlignment to True
                Set piAlignmentButton to xtpAlignmentCenter
                Set peTextAlignment to xtpAlignmentCenter
                Set peIconAlignment to xtpAlignmentIconCenter
                Set piFontWeightButton to 9
                //Set psIconButton to "Order.ico" //All states set.     
                //Set psIconButtonNormal to "Item_Completed_32x32.ico" //This is the image displayed when the item is displayed normally.      
                //Set psIconButtonHot to "Item_Completed_32x32.ico" //This is the image displayed when the mouse Pointer is positioned over the item.      
                //Set psIconButtonPressed to "Item_Completed_32x32.ico" //This is the image displayed when the item is in currently pressed my the mouse cursor.      
                //Set psIconButtonDisabled to "Item_Completed_32x32_gray.ico" //This is the image displayed when the item is in disabled.     
                Set pbFocusable to False
                Set pbComboEntryState to False
                Set piMinimumWidth to 66
                
                Function ButtonPaint Handle hoGridItemMetrics Integer iRow String ByRef sValue Returns Boolean
                    Function_Return ((RowValue(oOrderDtl_CompletedReqFlag,iRow)<>0) and (RowValue(oOrderDtl_CompletedFlag,iRow)=0)) //Don't show button if no work is required/estimated
                    //Function_Return (True) // Always Print
                End_Function
            
                Procedure ButtonAction Integer iRow Integer iCol Short llButton Short llShift
                    Send ToggleThisLineItemStatus
                End_Procedure

                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
            
            End_Object

            Object oOrderDtlStatusCJGridColumnButton is a cCJGridColumnButton
                Set psCaption to "Status"
                Set piWidth to 55
                Set piWidthButton to 52
                Set piHeightButton to 28
                Set psCaptionButton to ""
                Set piCaptionColorButton to clGrayText
                Set psFontNameButton to "Segoe UI"
                Set piFontSizeButton to 12
                Set pbUseColumnTextAlignment to True
                Set piAlignmentButton to xtpAlignmentCenter
                Set peTextAlignment to xtpAlignmentCenter
                Set peIconAlignment to xtpAlignmentIconCenter
                Set piFontWeightButton to 9    
                Set psIconButton to "Item_Completed_32x32.ico"
                //Set psIconButtonNormal to "Item_Completed_32x32.ico" //This is the image displayed when the item is displayed normally.      
                //Set psIconButtonHot to "Item_Completed_32x32.ico" //This is the image displayed when the mouse Pointer is positioned over the item.      
                //Set psIconButtonPressed to "Item_Completed_32x32.ico" //This is the image displayed when the item is in currently pressed my the mouse cursor.      
                //Set psIconButtonDisabled to "Item_Completed_32x32.ico" //This is the image displayed when the item is in disabled.     
                Set pbFocusable to False
                Set pbComboEntryState to False
                Set pbThemedButton to False
                Set pbEnableButton to False
                
                Function ButtonPaint Handle hoGridItemMetrics Integer iRow String ByRef sValue Returns Boolean
                    Function_Return ((RowValue(oOrderDtl_CompletedReqFlag,iRow)>0) and (RowValue(oOrderDtl_CompletedFlag,iRow)=1)) //Don't show button if no work is required/estimated
                    //Function_Return (True) // Always Print
                End_Function
            
                Procedure ButtonAction Integer iRow Integer iCol Short llButton Short llShift
                    Send ToggleThisLineItemStatus
                End_Procedure

                Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                    Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                End_Procedure
            
            End_Object

            Object oDtlGridCJContextMenu is a cCJContextMenu
                
                Procedure OnPopupInit Variant vCommandBarControl Handle hoCommandBarControls
                    Forward Send OnPopupInit vCommandBarControl hoCommandBarControls
                    Set psCaption of oOperationsDetailMenuItem to (If(pbShowOpsGridDetails(Self)=True,'Hide Operations Detail', 'Show Operations Detail'))
                    Set psCaption of oSalesDetailMenuItem to (If(pbShowSalesGridDetails(Self)=True,'Hide Sales Detail', 'Show Sales Detail'))
                End_Procedure
                
                Object oToggleStatusMenuItem is a cCJMenuItem
                    Set psCaption to "Toggle Status"
                    Set psTooltip to "Toggle Status"

                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        Send ToggleThisLineItemStatus
                    End_Procedure
                End_Object

//                Object oSetWIPMenuItem is a cCJMenuItem
//                    Set psCaption to "Set WIP"
//                    Set psTooltip to "Set WIP"
//                    Set peControlType to xtpControlPopup
//
//                    Object o25MenuItem is a cCJMenuItem
//                        Set psCaption to "25%"
//                        Set psTooltip to "25%"
//
//                        Procedure OnExecute Variant vCommandBarControl
//                            Forward Send OnExecute vCommandBarControl
//                            Send UpdateCurrentValue of oOrderDtl_CompletedFlag 0.25
//                        End_Procedure
//                    End_Object
//
//                    Object o50MenuItem is a cCJMenuItem
//                        Set psCaption to "50%"
//                        Set psTooltip to "50%"
//
//                        Procedure OnExecute Variant vCommandBarControl
//                            Forward Send OnExecute vCommandBarControl
//                            Send UpdateCurrentValue of oOrderDtl_CompletedFlag 0.50
//                        End_Procedure
//                    End_Object
//
//                    Object o75MenuItem is a cCJMenuItem
//                        Set psCaption to "75%"
//                        Set psTooltip to "75%"
//
//                        Procedure OnExecute Variant vCommandBarControl
//                            Forward Send OnExecute vCommandBarControl
//                            Send UpdateCurrentValue of oOrderDtl_CompletedFlag 0.75
//                        End_Procedure
//                    End_Object
//
//                End_Object

                Object oOperationsDetailMenuItem is a cCJMenuItem
                    Set psCaption to "Operations Detail [Show/Hide]"
                    Set psTooltip to "Operations Detail"

                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        Set pbShowOpsGridDetails to (not(pbShowOpsGridDetails(Self)))
                        Send Activating of oOrderDtlDbCJGrid
                    End_Procedure

                End_Object

                Object oSalesDetailMenuItem is a cCJMenuItem
                    Set psCaption to "Sales Detail [Show/Hide]"
                    Set psTooltip to "Sales Detail"

                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        Set pbShowSalesGridDetails to (not(pbShowSalesGridDetails(Self)))
                        Send Activating of oOrderDtlDbCJGrid
                    End_Procedure
                End_Object


            End_Object

            Procedure OnRowRightClick Integer iRow Integer iCol
                //Forward Send OnRowRightClick iRow iCol
                Send Popup of oDtlGridCJContextMenu
            End_Procedure

            Procedure Refresh Integer eMode
                Forward Send Refresh eMode
            End_Procedure

            Procedure Activating
                Forward Send Activating
                //OpsDetail
                Set pbVisible of oOrderDtl_Instructions to (pbShowOpsGridDetails(Self))
                Set pbVisible of oOrderDtl_Sqft to (pbShowOpsGridDetails(Self))
                Set pbVisible of oOrderDtl_Lnft to (pbShowOpsGridDetails(Self))
                Set pbVisible of oOrderDtl_MatQuantity to (pbShowOpsGridDetails(Self))
                Set pbVisible of oOrderDtl_TotalManHours to (pbShowOpsGridDetails(Self))
                //Set pbVisible of oOrderDtl_SubOnlyFlag to (pbShowOpsGridDetails(Self))
                //Set pbVisible of oOrderDtl_CompletedFlag to (pbShowOpsGridDetails(Self))
                Set pbVisible of oOrderDtlCompletedCJGridColumnButton to (pbShowOpsGridDetails(Self))
                Set pbEditable of oOrderDtlCompletedCJGridColumnButton to (giUserRights>=60)
                //Sales Detail
                Set pbVisible of oMastOps_Name to (pbShowSalesGridDetails(Self))
                Set pbVisible of oOrderDtl_InvoiceDescription to (pbShowSalesGridDetails(Self))
                Set pbVisible of oOrderDtl_Quantity to (pbShowSalesGridDetails(Self))
                Set pbVisible of oOrderDtl_Price to (pbShowSalesGridDetails(Self))
                Set pbVisible of oOrderDtl_TaxAmount to (pbShowSalesGridDetails(Self))
                Set pbVisible of oOrderDtl_Amount to (pbShowSalesGridDetails(Self))
            End_Procedure
            
        End_Object

//        Object oOrderDtlGrid is a dbGrid
//            Set Server to oOrderDtl_DD
//            Set Location to 3 5
//    
////            Function Child_Entering Returns Integer
////                Integer iRetval iRecId
////                // Check with header to see if it is saved.
////                Delegate Get IsSavedHeader to iRetval
////                //
////                If (iRetval = 0) Begin
////                    Get Current_Record  of oQuotedtl_DD to iRecId
////                    Send Find_By_Recnum of oQuotedtl_DD Quotedtl.File_Number iRecId
////                End
////                //
////                Function_Return iRetval // if non-zero do not enter
////            End_Function  // Child_Entering
//    
////                    Procedure Prompt_Callback Integer hoPrompt
////                      Integer iCol
////                      //
////                      Get Current_Col to iCol
////                      If (iCol = 1) Begin
////                          Set Ordering       of hoPrompt to 2
////                          Set Initial_Column of hoPrompt to 2
////                      End
////                    End_Procedure
//    
//            Procedure Prompt
//                Integer iCol iRecId
//                Boolean bErr
//                //
//                Get Current_Col                   to iCol
//                Get Current_Record of oMastops_DD to iRecId
//                //
//                If (iCol = 2) Begin
//                    Forward Send Prompt
//                End
//                Else Begin
//                    Forward Send Prompt
//                End
//                //
//                If (Current_Record(oMastops_DD) <> iRecId) Begin
//                    Set Field_Changed_Value of oOrderDtl_DD Field OrderDtl.Price       to MastOps.SellRate
//                    Set Field_Changed_Value of oOrderDtl_DD Field OrderDtl.InvoiceDescription to MastOps.Description
//                End
//                Get Request_Validate of oOrderDtl_DD to bErr
//                If (not(bErr)) Begin
//                    Send Request_Save of oOrderDtl_DD
//                End
//            End_Procedure
//    
//            Procedure Request_Clear
//                If (Changed_State(oOrderDtl_DD)) Begin
//                    Forward Send Request_Clear
//                End
//                Else Begin
//                    Send Add_New_Row 0
//                End
//            End_Procedure
//    
//            Function DataLossConfirmation Returns Integer
//                Integer bCancel
//                //
//                If (not(Changed_State(oOrderDtl_DD))) Begin
//                    Function_Return
//                End
//                Else Begin
//                    Get Confirm "Abandon Order Detail Changes?" to bCancel
//                    Function_Return bCancel
//                End
//            End_Function
//    
//            Set Size to 122 561
//    
//            Begin_Row
//                Entry_Item OrderDtl.OrderDtlIdno
//                Entry_Item OrderDtl.Sequence
//                Entry_Item MastOps.Name
//                Entry_Item WorkType.ShortCut
//                Entry_Item OrderDtl.Quantity
//                Entry_Item OrderDtl.Price
//                Entry_Item OrderDtl.TaxAmount
//                Entry_Item OrderDtl.Amount
//                Entry_Item OrderDtl.Instructions
//                Entry_Item OrderDtl.Sqft
//                Entry_Item OrderDtl.Lnft
//                Entry_Item OrderDtl.MatQuantity
//                Entry_Item OrderDtl.TotalManHours
//            End_Row
//    
//            Set Main_File to OrderDtl.File_number
//    
//            Set Form_Width 0 to 1
//            Set Header_Label 0 to "ID"
//            Set Column_Shadow_State 0 to True
//
//            Set Form_Width 1 to 20
//            Set Header_Label 1 to "Seq"
//            Set Header_Justification_Mode 1 to JMode_Right
//    
//            Set Form_Width 2 to 100
//            Set Header_Label 2 to "Operation Name"
//            Set Column_Prompt_Object 2 to MastOps_sl
//    
//            Set Form_Width 4 to 30
//            Set Header_Label 4 to "Qty"
//            Set Header_Justification_Mode 4 to JMode_Right
//            Set Column_Shadow_State 4 to False
//    
//            Set Form_Width 5 to 54
//            Set Header_Label 5 to "Price"
//            Set Header_Justification_Mode 5 to JMode_Right
//            Set Column_Shadow_State 5 to False
//            
//            Set Form_Width 6 to 48
//            Set Header_Label 6 to "Tax Amount"
//            Set Column_Shadow_State 6 to True
//       
//    
//            Set Form_Width 7 to 56
//            Set Header_Label 7 to "Amount"
//            Set Header_Justification_Mode 7 to JMode_Right
//            Set Column_Shadow_State 7 to True
//            Set Form_Width 8 to 90
//            Set Header_Label 8 to "Instructions"
//            Set Form_Width 9 to 40
//            Set Header_Label 9 to "Sqft"
//            Set Form_Width 10 to 40
//            Set Header_Label 10 to "Lnft"
//            Set Form_Width 11 to 35
//            Set Header_Label 11 to "Mat. Qty"
//            Set Form_Width 12 to 45
//            Set Header_Label 12 to "Man Hours"
//            Set Form_Width 3 to 14
//            Set Header_Label 3 to "ShortCut"
//
//            
//
//    
//            Set peAnchors to anAll
//            Set peResizeColumn to rcSelectedColumn
//            Set piResizeColumn to 2
//            Set Ordering to 3
//            Set Child_Table_State to True
//            Set Color to clWhite
//            //Set peDisabledColor to clWhite
//            //Set peDisabledTextColor to clBlack
//            Set CurrentRowColor to clLtGray
//            Set CurrentCellColor to clLtGray
//            Set TextColor to clBlack
//            Set Wrap_State to True
//            Set Horz_Scroll_Bar_Visible_State to False
//            
//            Procedure Change_Row_Color Integer iColor
//                Integer iBase iItem iItems
//             
//                Get Base_Item to iBase               // first item of current row
//                Get Item_Limit to iItems              // items per row
//                Move (iBase+iItems-1) to iItems     // last item in the current row
//             
//                For iItem from iBase to iItems         // set all items in row to color 
//                    Set ItemColor iItem to iColor
//                Loop
//                Procedure_Return
//            End_Procedure // Change_Row_Color
//            
//            Procedure Entry_Display Integer iFile Integer iType
//                Integer iColor iItem
//                
////                Case Begin
////                    Case (Quotedtl.EstimateItemID>0)
////                        //Move 13106938 to iColor // Yellow
////                        Case Break
////                    Case Else
//                        Move clWhite to iColor 
////                Case End
//    
//                Send Change_Row_Color iColor
//                Forward Send Entry_Display iFile iType
//            End_Procedure 
//
//            Procedure Refresh Integer notifyMode
//                Forward Send Refresh notifyMode
//                //
//                Boolean bHastDtlRec bJobIsLocked bIsJobCanceled bJobInvoiced
//                Move (Order.LockedFlag > 0) to bJobIsLocked
//                Move (HasRecord(oOrderDtl_DD)) to bHastDtlRec
//                Move (Order.Status = "X")  to bIsJobCanceled
//                Move (Order.SalesInvoiceOK>0) to bJobInvoiced
//                Set Enabled_State of oOrderDtlGrid to (HasRecord(oOrder_DD))
//                Set Enabled_State of oOrderDtl_Description to (not(bIsJobCanceled) and not(bJobInvoiced) and not(bJobIsLocked) and bHastDtlRec)
//            End_Procedure           
//            
//        End_Object
        

        
        
        Object oOrderDtl_Description is a cComDbSpellText

            Property Boolean pbText
            Property Boolean pbChangedText
            Property Integer piRecId
            Property String  psText

            Entry_Item OrderDtl.InvoiceDescription

            Set Server to oOrderDtl_DD
            Set Size to 40 397
            Set Location to 129 5
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

            Procedure Next
                Set pbText to False
                //Send Activate of oOrderDtlGrid
                //Send Activate of oOrderDtlDbCJGrid
            End_Procedure
    
            Procedure OnComChange
                String sText
                //
                If (pbText(Self)) Begin
                    Set pbChangedText                                                  to True
                    Get ComText                                                        to sText
                    Set psText                                                         to sText
                End
            End_Procedure

            Procedure OnComGainedFocus
                Set pbText  to True
                Set piRecId to (Current_Record(oOrderDtl_DD))
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
                    Set_Attribute DF_FILE_MODE of OrderDtl.File_Number to DF_FILEMODE_DEFAULT
                    Get piRecId                                        to iRecId
                    If (OrderDtl.Recnum <> iRecId) Begin
                        Clear OrderDtl
                        Move iRecId to OrderDtl.Recnum
                        Find eq OrderDtl.Recnum
                    End
                    Get psText                                         to sText
                    Reread
                    Move sText                                         to OrderDtl.InvoiceDescription
                    SaveRecord OrderDtl
                    Unlock
                    Send ChangeAllFileModes DF_FILEMODE_DEFAULT
                    Set pbChangedText                                  to False
                End
                //
                Procedure_Return iRetval
            End_Procedure

            Embed_ActiveX_Resource 
            k7IAAOQBAAADAAgAC/JXRyAAAABfAGUAeAB0AGUAbgB0AHgAukcAAAMACAAK8ldHIAAAAF8AZQB4AHQAZQBuAHQAeQDABwAADQAEAHXzDbw4AAAAZgBvAG4AdAADUuML
            kY/OEZ3jAKoAS7hRAQAAAJABREIBAAhTZWdvZSBVSQAIAAgAu1dWszAAAABmAG8AbgB0AG4AYQBtAGUACAAAAFMAZQBnAG8AZQAgAFUASQAEAAgAO7lUkyAAAABmAG8A
            bgB0AHMAaQB6AGUAAAAEQQgAFQBhY0UUaAAAAGMAdQBzAHQAbwBtAGQAaQBjAHQAaQBvAG4AYQByAHkAZgBuAGEAbQBlABcAAABDADoAXABXAGkAbgBkAG8AdwBzAFwA
            QwBIAEMAVQBTAFQATwBNAC4AQwBVAEQACwAQADm40+QwAAAAYwBoAGUAYwBrAG8AbgBmAG8AYwB1AHMAbABvAHMAcwAAAAAAAwALAI4wQcAoAAAAbQBzAGYAbwByAGUA
            YwBvAGwAbwByAP8AAAAAAAMACwCSdEWwKAAAAG0AcwBiAGEAYwBrAGMAbwBsAG8AcgD///8AAAADAA0A6TE+s1D+//9zAHEAdQBpAGcAZwBsAGUAYwBvAGwAbwByAP8A
            AAAAAA.
            End_Embed_ActiveX_Resource 
    
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
            Entry_Item Order.OrderSubtotal
            Set Server to oOrder_DD
            Set Location to 127 491
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
            Set Location to 142 453
            Set Size to 13 38
            Set Label to "Sales Tax:"
            Set Form_Datatype to Mask_Numeric_Window
            Set Form_Mask to "#0.0000 %"
            Set Form_Justification_Mode to Form_DisplayRight
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
            Set peAnchors to anBottomRight
            
            Procedure OnChange
                String sHasReqValue
                If (SalesTaxGroup.SalesTaxIdno = 0) Set Label_TextColor to clRed
                Else Set Label_TextColor to clBlack                
            End_Procedure
        End_Object

        Object oQuotehdr_TaxTotal is a cGlblDbForm
            Entry_Item Order.OrderTaxTotal

            Set Server to oOrder_DD
            Set Location to 142 491
            Set Size to 13 68
            Set Enabled_State to False
            Set Entry_State to False
            Set Form_Datatype to Mask_Numeric_Window
            Set Form_Mask to "$ #,###,##0.00"
            Set peAnchors to anBottomRight
        End_Object

        Object oLineControl2 is a LineControl
            Set Size to 2 137
            Set Location to 157 421
            Set peAnchors to anBottomRight
        End_Object
        
        
        
        Object oQuotehdr_Amount is a cGlblDbForm
            Entry_Item Order.OrderTotalAmount
            Set Enabled_State to False
            Set Location to 159 491
            Set Size to 13 68
            Set Label to "Total:"
            Set peAnchors to anBottomRight
            Set Label_FontWeight to fw_Bold
            Set Form_Datatype to Mask_Numeric_Window
            Set Form_Mask to "$ #,###,##0.00"
            Set Label_Col_Offset to 70
        End_Object
        
        
        
    End_Object

    Object oViewQuoteButton is a Button
        Set Location to 303 5
        Set Label to "View Quote"
        Set peAnchors to anBottomLeft
    
        Procedure OnClick
            Send DoViewQuote of oQuoteEntry Order.QuoteReference
        End_Procedure
    End_Object

    Object oExport_Button is a Button
        Set Size to 14 69
        Set Location to 303 59
        Set Label to 'Add to my Calendar'
        Set peAnchors to anBottomLeft
    
        // fires when the button is clicked
        Procedure OnClick
            Integer iJobNumber iQuoteIdno
            Get Field_Current_Value of oOrder_DD Field Order.JobNumber to iJobNumber
            Get Field_Current_Value of oOrder_DD Field Order.QuoteReference to iQuoteIdno
            
            Send BuildCalendarJobObject iJobNumber
            ////////////////////////////////////////////////////////////////////////////
            
        End_Procedure
    
    End_Object

    Object oJobCostButton is a Button
        Set Size to 14 78
        Set Location to 303 133
        Set Label to 'Job Cost Entry/Edit'
        Set peAnchors to anBottomLeft
    
        // fires when the button is clicked
        Procedure OnClick
            Integer iRecID
            Get Field_Current_Value of oOrder_DD Field Order.Recnum to iRecID
            Send DoViewJobCost of oJobCost iRecID
        End_Procedure
    
    End_Object
    
     Object oPrintJobSheetButton is a Button
        Set Size to 14 62
        Set Location to 303 217
        Set Label to "Job Sheet"        
         Set peAnchors to anBottomLeft
        //Set Bitmap to "doc.bmp/3d"
    
        Procedure OnClick
            Integer iJobNumber
            String sFilePath sFileName
            //
            Get Field_Current_Value of oOrder_DD Field Order.JobNumber to iJobNumber
            If (iJobNumber <> 0) Begin
                //Send DoJumpStartReport of PrintJobSheet iJobNumber
                Send DoJumpStartReport of oJobSheetReportView iJobNumber (&sFilePath) (&sFileName) True
                
            End
        End_Procedure
    End_Object

     Object oPrintJobCostButton is a Button
        Set Size to 14 64
        Set Location to 303 283
        Set Label to "Cost Sheet"
         Set peAnchors to anBottomLeft
    
        Procedure OnClick
            Integer iJobNumber iProjectIdno
            //
            Get Field_Current_Value of oOrder_DD Field Order.JobNumber to iJobNumber
            Get Field_Current_Value of oOrder_DD Field Order.ProjectId to iProjectIdno
            If (iProjectIdno<>0) Begin
                Send DoJumpStartReport of PrintProjectCostSheet iProjectIdno
            End
            Else If (iJobNumber <> 0) Begin
                Send DoJumpStartReport of PrintCostSheet iJobNumber
            End
        End_Procedure
     End_Object
     
    Object oOpsCostOkButton is a Button
        Set Size to 14 70
        Set Location to 303 426
        Set Label to "Ready to Invoice"
        Set peAnchors to anBottomLeft
    
        Procedure OnClick
            Send Timestamp
        End_Procedure
    
        Procedure Timestamp
            Date dToday
            Integer iJobNumber
            Boolean bCancel bOpsCostOk
            Sysdate dToday
            Send Refind_Records of oOrder_DD
            Get Field_Current_Value of oOrder_DD Field Order.JobNumber to iJobNumber
            Get Field_Current_Value of oOrder_DD Field Order.OpsCostOK_Flag to bOpsCostOk
            If (not(bOpsCostOk)) Begin
                Get Confirm ("This will set the Job Costing for Job:" * String(iJobNumber) * "to complete! \n \n Are you sure you want to Continue?") to bCancel
                If (not(bCancel)) Begin
                   Set Field_Changed_Value of oOrder_DD Field Order.OpsCostOK to dToday
                   Set Field_Changed_Value of oOrder_DD Field Order.OpsCostOK_Flag to 1
                   Set Field_Changed_Value of oOrder_DD Field Order.JobCloseDate to dToday
                   Set Field_Changed_Value of oOrder_DD Field Order.Status to "C" 
                   Set Field_Changed_Value of oOrder_DD Field Order.LockedFlag to 1   
                   Send Request_Save of oOrder_DD
                End
                If (bCancel) Begin
                    Send Info_Box ("Job Costing for Job:" * String(iJobNumber) * "not completed - please try again")
                End
            End
            Else Begin
                Get Confirm ("This will reset the Job Costing for Job:" * String(iJobNumber) * "! \n \n Are you sure you want to Continue?") to bCancel
                If (not(bCancel)) Begin
                   Set Field_Changed_Value of oOrder_DD Field Order.OpsCostOK to ""
                   Set Field_Changed_Value of oOrder_DD Field Order.OpsCostOK_Flag to 0
                   Set Field_Changed_Value of oOrder_DD Field Order.JobCloseDate to ''
                   Set Field_Changed_Value of oOrder_DD Field Order.Status to "O" 
                   Set Field_Changed_Value of oOrder_DD Field Order.LockedFlag to 0
                   Send Request_Save of oOrder_DD
                End
            End
        End_Procedure
   
    End_Object

    Object oCreateInvoiceButton is a Button
        Set Size to 14 70
        Set Location to 303 500
        Set Label to "Create Invoice"
        Set peAnchors to anBottomLeft
    
        // fires when the button is clicked
        Procedure OnClick
            Boolean bCancel bSuccess
            Integer eResponse
            Send Refind_Records of oOrder_DD
            //Send Request_Save of oOrder_DD
            // Show Printout of Invoice first.
            Integer iJobNumber
            Get Field_Current_Value of oOrder_DD Field Order.JobNumber to iJobNumber
            If (iJobNumber <> 0) Begin
                Get DoJumpStartReport_W_Confirm of PrintOrderDetail iJobNumber to eResponse
                If (eResponse = MBR_Yes) Begin
                    // POPUP MODAL OF AP FORM
                    Get PromptAPForm of oAPForm Location.LocationIdno to bSuccess
                    If (bSuccess) Begin
                        Send TriggerInvoice
                        //Send Refind_Records of oOrder_DD
                        Send Activate of oOrder_JobNumber
                        Send Find of oOrder_DD EQ 1
                    End
                    Else Begin
                        Send Stop_Box "Please review, update if required and confirm AP Form before proceeding!" "STOP!"
                    End
                End                
            End
        End_Procedure
    
    End_Object

    Object oPrintInvoicePrevButton is a Button
        Set Size to 14 69
        Set Location to 303 351
        Set Label to 'Invoice Preview'
        Set peAnchors to anBottomLeft
    
        // fires when the button is clicked
        Procedure OnClick
            Integer iJobNumber
            String sFilePath sFileName
            Get Field_Current_Value of oOrder_DD Field Order.JobNumber to iJobNumber
            If (iJobNumber <> 0) Begin
                Send DoJumpStartReport of oOrderInvoicePreviewReportView iJobNumber (&sFilePath) (&sFileName) True
            End
        End_Procedure
    
    End_Object
     
//    Procedure Request_Clear
//        Forward Send Request_Clear
//        //
//        Set Value of oSalesRepForm to ""
//    End_Procedure
//
//    Procedure Request_Clear_All
//        Forward Send Request_Clear_All
//        //
//        Set Value of oSalesRepForm to ""
//    End_Procedure

//    Object oPrintJobSheetButton is a Button
//        Set Size to 14 60
//        Set Location to 270 75
//        Set Label to "Print Job Sheet"
//    
//        Procedure OnClick
//            Integer iJobNumber
//            //
//            Get Field_Current_Value of oOrder_DD Field Order.JobNumber to iJobNumber
//            If (iJobNumber <> 0) Begin
//                Send DoJumpStartReport of oPrintJobSheet iJobNumber
//            End
//        End_Procedure    
//    End_Object

    Procedure Request_Save
        Boolean bNew
        Integer hoServer iErrors iCreated
        //
        Get Server                      to hoServer
        Move (not(HasRecord(hoServer))) to bNew
        //
        Forward Send Request_Save
        //
        If (bNew and not(Changed_State(hoServer))) Begin
            Get DoAddUniversalMastOpsToLocation of oOperationsProcess Location.LocationIdno Order.WorkType (&iErrors) to iCreated
            If (iErrors > 0) Begin
                Send Info_Box (String(iCreated) * "Operations created." * String(iErrors) * "errors.")
            End
        End
    End_Procedure

    Register_Object oQuoteEntry
    //

    Procedure DoReassignOrder
        Boolean bCancel bFail bFound
        Integer hoDD iRecId iJobNumber iWasIdno iIsIdno iCustIdno iMastOpsIdno iDisplay
        //
        Get Server to hoDD
        If (not(HasRecord(hoDD))) Begin
            Procedure_Return
        End
        Get Confirm "This procedure will select a new location record and update all Order history. Continue?" to bCancel
        If (bCancel) Begin
            Procedure_Return
        End
        Send Refind_Records    of hoDD
        Move Order.Recnum                     to iRecId
        Move Order.JobNumber                  to iJobNumber
        Move Order.LocationIdno               to iWasIdno
        Get IsSelectedLocation of Location_sl to iIsIdno
        //
        Get Confirm ("Order will be assigned to Location ID" * String(iIsIdno) + ". Continue?") to bCancel
        If (bCancel) Begin
            Procedure_Return
        End
        //
        If (Location.Recnum = 0 or Location.LocationIdno <> iIsIdno) Begin
            Clear Location
            Move iIsIdno to Location.LocationIdno
            Find eq Location.LocationIdno
        End
        Move Location.CustomerIdno to iCustIdno
        If (Order.Recnum <> iRecId) Begin
            Clear Order
            Move iRecId to Order.Recnum
            Find eq Order.Recnum
        End
        Send ChangeAllFileModes DF_FILEMODE_READONLY
        Set_Attribute DF_FILE_MODE of Order.File_Number    to DF_FILEMODE_DEFAULT
        Set_Attribute DF_FILE_MODE of Opers.File_Number    to DF_FILEMODE_DEFAULT
        Set_Attribute DF_FILE_MODE of System.File_Number   to DF_FILEMODE_DEFAULT
        Set_Attribute DF_FILE_MODE of Trans.File_Number    to DF_FILEMODE_DEFAULT
        Set_Attribute DF_FILE_MODE of Invhdr.File_Number   to DF_FILEMODE_DEFAULT
        Set_Attribute DF_FILE_MODE of Invdtl.File_Number   to DF_FILEMODE_DEFAULT
        Set_Attribute DF_FILE_MODE of Locnotes.File_Number to DF_FILEMODE_DEFAULT
        Reread
        Move iIsIdno   to Order.LocationIdno
        Move iCustIdno to Order.CustomerIdno
        Move 1         to Order.ChangedFlag
        SaveRecord Order
        Unlock
        //
        Clear Trans
        Move iJobNumber to Trans.JobNumber
        Find ge Trans.JobNumber
        While ((Found) and Trans.JobNumber = iJobNumber)
            Clear Opers
            Move Trans.OpersIdno to Opers.OpersIdno
            Find eq Opers.OpersIdno
            If (Found) Begin
                Move Opers.MastOpsIdno to iMastOpsIdno
                Move Opers.Display     to iDisplay
                Clear MastOps
                Move iMastOpsIdno      to MastOps.MastOpsIdno
                Find eq MastOps.MastOpsIdno
                Clear Opers
                Move iIsIdno      to Opers.LocationIdno
                Move iMastOpsIdno to Opers.MastOpsIdno
                Find eq Opers by Index.4
                If (not(Found)) Begin
                    Reread
                    Add 1 to System.LastOpers
                    SaveRecord System
                    Move System.LastOpers        to Opers.OpersIdno
                    Move iCustIdno               to Opers.CustomerIdno
                    Move iIsIdno                 to Opers.LocationIdno
                    Move iMastOpsIdno            to Opers.MastOpsIdno
                    Move MastOps.Name            to Opers.Name
                    Move MastOps.SellRate        to Opers.SellRate
                    Move MastOps.CostRate        to Opers.CostRate
                    Move MastOps.CalcBasis       to Opers.CalcBasis
                    Move MastOps.ActivityType    to Opers.ActivityType
                    Move MastOps.Description     to Opers.Description
                    Move iDisplay                to Opers.Display
                    Move MastOps.Status          to Opers.Status
                    Move MastOps.DisplaySequence to Opers.DisplaySequence
                    Move 1                       to Opers.ChangedFlag
                    SaveRecord Opers
                    Unlock
                End
                Reread
                Move iCustIdno           to Trans.CustomerIdno
                Move iIsIdno             to Trans.LocationIdno
                Move Opers.OpersIdno     to Trans.OpersIdno
                Move Location.AreaNumber to Trans.AreaNumber
                SaveRecord Trans
                Unlock
            End
            Find gt Trans.JobNumber
        Loop
        //
        Clear Invhdr
        Move iJobNumber to Invhdr.JobNumber
        Find ge Invhdr.JobNumber
        Move ((Found) and Invhdr.JobNumber = iJobNumber) to bFound
        While (bFound)
            Reread
            Move iIsIdno   to Invhdr.LocationIdno
            Move iCustIdno to Invhdr.CustomerIdno
            SaveRecord Invhdr
            Unlock
            //
            Clear Invdtl
            Move Invhdr.InvoiceIdno to Invdtl.InvoiceIdno
            Find ge Invdtl.InvoiceIdno
            While ((Found) and Invdtl.InvoiceIdno = Invhdr.InvoiceIdno)
                Clear Opers
                Move Invdtl.OpersIdno to Opers.OpersIdno
                Find eq Opers.OpersIdno
                If (Found) Begin
                    Move Opers.MastOpsIdno to iMastOpsIdno
                    Move Opers.Display     to iDisplay
                    Clear MastOps
                    Move iMastOpsIdno      to MastOps.MastOpsIdno
                    Find eq MastOps.MastOpsIdno
                    Clear Opers
                    Move iIsIdno      to Opers.LocationIdno
                    Move iMastOpsIdno to Opers.MastOpsIdno
                    Find eq Opers by Index.4
                    If (not(Found)) Begin
                        Reread
                        Add 1 to System.LastOpers
                        SaveRecord System
                        Move System.LastOpers        to Opers.OpersIdno
                        Move iCustIdno               to Opers.CustomerIdno
                        Move iIsIdno                 to Opers.LocationIdno
                        Move iMastOpsIdno            to Opers.MastOpsIdno
                        Move MastOps.Name            to Opers.Name
                        Move MastOps.SellRate        to Opers.SellRate
                        Move MastOps.CostRate        to Opers.CostRate
                        Move MastOps.CalcBasis       to Opers.CalcBasis
                        Move MastOps.ActivityType    to Opers.ActivityType
                        Move MastOps.Description     to Opers.Description
                        Move iDisplay                to Opers.Display
                        Move MastOps.Status          to Opers.Status
                        Move MastOps.DisplaySequence to Opers.DisplaySequence
                        Move 1                       to Opers.ChangedFlag
                        SaveRecord Opers
                        Unlock
                    End
                    Reread
                    Move Opers.OpersIdno     to Invdtl.OpersIdno
                    Move Location.AreaNumber to Invdtl.AreaNumber
                    SaveRecord Invdtl
                    Unlock
                End
                Find gt Invdtl.InvoiceIdno
            Loop
            //
            Find gt Invhdr.JobNumber
            Move ((Found) and Invhdr.JobNumber = iJobNumber) to bFound
        Loop
        //
        Clear Locnotes
        Move iJobNumber to Locnotes.JobNumber
        Find ge Locnotes.JobNumber
        While ((Found) and Locnotes.JobNumber = iJobNumber)
            Reread
            Move iIsIdno to Locnotes.LocationIdno
            SaveRecord Locnotes
            Unlock
            Find gt Locnotes.JobNumber
        Loop
        //
        Send ChangeAllFileModes DF_FILEMODE_DEFAULT
        //
        Send Find_By_Recnum of hoDD Order.File_Number iRecId
    End_Procedure
    //
    On_Key kUser2 Send DoReassignOrder

    Procedure DoCreateOrder Integer iCustomerIdno Integer iLocationIdno
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

    Procedure DoCreateInvoiceFromQuote
        Integer iCount iRecId
        //
        Send Refind_Records of oOrder_DD
        Get DoMaintainOpersFromQuote of oOperationsProcess Location.LocationIdno Order.QuoteReference to iCount
        Get DoCreateInvoiceFromOrder of oInvoiceCreationProcess Order.JobNumber Order.QuoteReference  to iRecId
    End_Procedure

    Procedure DoViewOrder Integer iRecId
        Handle hoServer
        //
        If (iRecId) Begin
            Send Activate_View
            Send Request_Clear_All
            Get Server to hoServer
            Send Find_By_Recnum     of hoServer Order.File_Number iRecId
            Set Field_Changed_State of hoServer Field Order.JobOpenDate to False
        End
    End_Procedure
        
//        
        
    Procedure DoViewJobCost
        Integer iRecID
        
        Send Refind_Records of oOrder_DD
        Move Recnum to iRecID
        Send DoViewJobCost of oJobCost iRecID
    End_Procedure

    Object oCharTranslate is a cCharTranslate
    End_Object

    Object oSeqFileHelper is a cSeqFileHelper
    End_Object

    Function DateTimeToTimeStamp DateTime dtNow Integer ByRef iYear Integer ByRef iMonth Integer ByRef iDay Integer ByRef iHr Integer ByRef iMin Integer ByRef iSec Returns String
        String sDateStampWTime
        Move (DateGetYear(dtNow)) to iYear
        Move (DateGetMonth(dtNow)) to iMonth
        Move (DateGetDay(dtNow)) to iDay
        Move (DateGetHour(dtNow)) to iHr
        Move (DateGetMinute(dtNow)) to iMin
        Move (DateGetSecond(dtNow)) to iSec
        Move (String(iYear)+String(iMonth)+String(iDay)+"T"+String(iHr)+String(iMin)+String(iSec)) to sDateStampWTime
        Function_Return sDateStampWTime
    End_Function

    Procedure BuildCalendarJobObject Integer iJobNumber
        String sFileTitle sTargetAddress sTargetFilename sFileExt sTarget  
        String sPlainTxtMsg sPlain_Desc sHTML_Message sHTML_Desc
        String sDateStampWTime sObjectStart sObjectEnd
        String[] sTo
        
        DateTime dtNow
        Integer iYear iMonth iDay iHr iMin iSec
        //DateTime
        Get DateTimeToTimeStamp dtNow (&iYear) (&iMonth) (&iDay) (&iHr)  (&iMin) (&iSec) to sDateStampWTime
        
        
        // Read Config.ws file information for RootURL
        String sWorkspaceWSFile sWebsiteRoot
        Handle hoWorkspace hoIniFile
        //
        Forward Send Construct_object
        //
        Move (phoWorkSpace(ghoApplication))                                    to hoWorkspace
        Get psWorkspaceWSFile of hoWorkspace                                   to sWorkspaceWSFile 
        Get Create U_cIniFile                                                  to hoIniFile
        Set psFilename        of hoIniFile                                     to sWorkspaceWSFile 
        Get ReadString        of hoIniFile "WebServices" "WebsiteRoot"     " " to sWebsiteRoot
        Send Destroy          of hoIniFile 
        
        // Find Order
        Open Order
        Clear Order
        Move iJobNumber to Order.JobNumber
        Find EQ Order by Index.1
        Relate Order                  
        //
        //PREPARE FILE ATTACHMENTS
        String sProgramPath sHomePath sReportsCacheFilePath sJSFileName sJSFilePath sOrderDtlPDFFilePath
        String sAttachmentPath sAttachmentFilePath
        tAttachment[] stAttachment
        Address pBase64 aEncodeBuffer
        Integer iArgSize iAttachCount iVoid iEncodeBinSize
        Get psProgramPath of (phoWorkspace(ghoApplication)) to sProgramPath
        Get psHome of (phoWorkspace(ghoApplication)) to sHomePath
        Get_Argument_Size to iArgSize
        Set_Argument_Size (20971520) // 20MB
        //
        // JOBSHEET PDF
        // ToDo: In preparation for RunJobSheetReport one more time!
        Send DoJumpStartReport of oJobSheetReportView iJobNumber (&sJSFilePath) (&sJSFileName) False
        Get ReadBinFileToBuffer of oSeqFileHelper (sJSFilePath+sJSFileName) (&iEncodeBinSize) to aEncodeBuffer
        Move (Base64EncodeToStr(oCharTranslate,aEncodeBuffer,iEncodeBinSize)) to stAttachment[iAttachCount].sBase64
        Move (Free(aEncodeBuffer)) to iVoid
        Move (sJSFileName) to stAttachment[iAttachCount].sFileName
        Increment iAttachCount
        // ALL OTHER ATTACHMENTS
        Clear Attachments
        Move Order.JobNumber to Attachments.JobNumber
        Find GE Attachments by 7
        While ((Found) and Attachments.JobNumber = Order.JobNumber)
            If (Attachments.OrderFlag=1) Begin
                Move (Trim(Attachments.FileName)) to stAttachment[iAttachCount].sFileName
                Move ("Bitmaps\Attachments\") to sAttachmentPath
                Move (sHomePath+sAttachmentPath+stAttachment[iAttachCount].sFileName) to sAttachmentFilePath
                Get ReadBinFileToBuffer of oSeqFileHelper (sAttachmentFilePath) (&stAttachment[iAttachCount].iEncodeSize) to aEncodeBuffer
                Move (Base64EncodeToStr(oCharTranslate,aEncodeBuffer,stAttachment[iAttachCount].iEncodeSize)) to stAttachment[iAttachCount].sBase64
                Move (Free(aEncodeBuffer)) to iVoid
                Increment iAttachCount
            End
            Find GT Attachments by 7
        Loop
        // Service Address for body            
        Move "" to sPlainTxtMsg
        Move "" to sHTML_Message
        Append sHTML_Message ("<html><body>")
        Append sHTML_Message ("<p><strong>Job#: </strong><a href='"+sWebsiteRoot+"/TempusField/Index.html#Orders/Job-"+String(Order.JobNumber)+"'>"+trim(Order.JobNumber)*"</a></p>")
        Append sHTML_Message ("<p><strong><u>Service Location:</u></strong><br />")
        Append sHTML_Message (Trim(Location.Name)+"<br />")
        Append sHTML_Message (Trim(Location.Address1)+"<br />")
        Append sHTML_Message (trim(Location.City) + "," * trim(Location.State) *  (IsNineDigitCode(Self,Location.Zip)) +"</p>")
        Append sHTML_Message ("<hr />")
        Append sHTML_Message ("<p><strong><u>Job Description:</u></strong></p>")
        
        Append sPlainTxtMsg ("Job#:" * trim(Order.JobNumber)+"\n")
        Append sPlainTxtMsg ("Service Location: \n")
        Append sPlainTxtMsg ( trim(Location.Name) * "\n" )
        Append sPlainTxtMsg ( trim(Location.Address1) * "\n" )
        Append sPlainTxtMsg ( trim(Location.City) + "," * trim(Location.State) *  (IsNineDigitCode(Self,Location.Zip)) * "\n\n" )
        Append sPlainTxtMsg ("------------------------------------------------------------------------------------------ \n")
        Append sPlainTxtMsg ("Job Description:\n")
        
        // Loop to Generate Detail
        // LineItem Description
        // Build HTML Table Shell with Header
        Append sHTML_Message ("<table width='100%' border='2' cellpadding='3'>")
        Append sHTML_Message ("<tr>")
        Append sHTML_Message ("<th scope='col'>Seq.</th>")
        Append sHTML_Message ("<th scope='col'>Description</th>")
        Append sHTML_Message ("</tr>")
        Open OrderDtl
        Clear OrderDtl
        Move Order.JobNumber to OrderDtl.JobNumber
        Find GE OrderDtl by Index.3
        While ((Found) and Order.JobNumber = OrderDtl.JobNumber)
            //HTML
            Move (Replaces(String(Character(10)),OrderDtl.InvoiceDescription,"")) to sHTML_Desc
            Move (Replaces(String(Character(13)),sHTML_Desc,"<br />")) to sHTML_Desc
            Append sHTML_Message ("<tr><td>"+String(OrderDtl.Sequence)+"</td>"+"<td>"+sHTML_Desc+"</td></tr>")
            Append sHTML_Message ("<tr><td>&nbsp;</td>"+"<td>Special Instructions:"*OrderDtl.Instructions*"- SQFT:"*String(OrderDtl.Sqft)*"- LNFT:"*String(OrderDtl.Lnft)*"- Mat Qty:"*String(OrderDtl.MatQuantity)*"- Man Hours:"*String(OrderDtl.TotalManHours)+"</td></tr>")
            //PLAIN
            Move (Replaces(String(Character(10)),OrderDtl.InvoiceDescription,"")) to sPlain_Desc
            Move (Replaces(String(Character(13)),sPlain_Desc,"\n")) to sPlain_Desc
            Append sPlainTxtMsg ("("*String(OrderDtl.Sequence)*")"*sPlain_Desc*"\n")
            Append sPlainTxtMsg ("Special Instructions:"*OrderDtl.Instructions*"- SQFT:"*String(OrderDtl.Sqft)*"- LNFT:"*String(OrderDtl.Lnft)*"- Mat Qty:"*String(OrderDtl.MatQuantity)*"- Man Hours:"*String(OrderDtl.TotalManHours)*"\n\n")
            Append sPlainTxtMsg (" \n")
            //
            //ATTENDEES
            //
            Find GT OrderDtl by Index.3
        Loop 
        //HTML
        Append sHTML_Message ("</table>")
        Append sHTML_Message ("<hr />")
        Append sHTML_Message ("Sales Rep:"*(Trim(SalesRep.FirstName))*(Trim(SalesRep.LastName))+"<br />")
        Append sHTML_Message ("Sales Rep Phone#:"*Trim(SalesRep.Phone2)+"<br />")
        Append sHTML_Message ("<hr />")
        //
        Append sHTML_Message ("<table>")
        Append sHTML_Message ("<table width='300px' border='2' cellpadding='3'>"+;
        "<tr>    <th width='150px' scope='col'>Item</th>    <th width='150px' scope='col'>Equip# / Labor#</th></tr>"+;
        "<tr>    <td>Sweeping</td>    <td>992</td>  </tr>"+;
        "<tr>    <td>Marking</td>    <td>993</td>  </tr>"+;
        "<tr>    <td>Asphalt</td>    <td>994</td>  </tr>"+;
        "<tr>    <td>Concrete</td>    <td>995</td>  </tr>"+;
        "<tr>    <td>Travel Time</td>    <td>998</td>  </tr>"+;
        "<tr>    <td>Non-Charge</td>    <td>99</td>  </tr>"+;
        "<tr>    <td>Staging</td>    <td>98</td>  </tr>")
        Append sHTML_Message ("</table>")
        Append sHTML_Message ("</body></html>")
        //PLAIN
        Append sPlainTxtMsg ("------------------------------------------------------------------------------------------ \n")
        Append sPlainTxtMsg ("Sales Rep: " * (Trim(SalesRep.FirstName)) * (Trim(SalesRep.LastName)) * "\n")
        Append sPlainTxtMsg ("Sales Rep Phone #: " * (SalesRep.Phone2) * "\n")
        Append sPlainTxtMsg ("------------------------------------------------------------------------------------------ \n")
        Append sPlainTxtMsg ("Mobile Labor Codes: \n")
        Append sPlainTxtMsg ("Sweeper			992 \n")
        Append sPlainTxtMsg ("Marking			993	\n")
        Append sPlainTxtMsg ("Asphalt			994 \n")
        Append sPlainTxtMsg ("Concrete			995 \n")
        Append sPlainTxtMsg ("Travel Time		996 \n")
        Append sPlainTxtMsg ("Misc. PM			998 \n")
        Append sPlainTxtMsg ("Non-Charge		99  \n")
        
    
        Get psHome of (phoWorkspace(ghoApplication)) to sTarget
        If (not(Right(sTarget,1) = "\")) Begin
            Move (sTarget + "\")                     to sTarget
        End
        Move Order.JobNumber to sFileTitle
        Move ".ics" to sFileExt
        Move (sTarget + "Data\Cal_Items\" + sFileTitle + sFileExt) to sTargetAddress
        Direct_Output sTargetAddress  
            Writeln "BEGIN:VCALENDAR"
            Writeln "PRODID:-//Microsoft Corporation//Outlook 14.0 MIMEDIR//EN"
            Writeln "VERSION:2.0"
            Writeln "METHOD:PUBLISH" // requied by Outlook
            Writeln "X-MS-OLK-FORCEINSPECTOROPEN:TRUE"
            Writeln ("Begin:VTIMEZONE")
            Writeln ("TZID:Central Standard Time")
            Writeln ("Begin:STANDARD")
            Writeln ("DTSTART:16011104T020000")
            Writeln ("RRULE:FREQ=YEARLY;BYDAY=1SU;BYMONTH=11")
            Writeln ("TZOFFSETFROM:-0500")
            Writeln ("TZOFFSETTO:-0600")
            Writeln ("End:STANDARD")
            Writeln ("Begin:DAYLIGHT")
            Writeln ("DTSTART:16010311T020000")
            Writeln ("RRULE:FREQ=YEARLY;BYDAY=2SU;BYMONTH=3")
            Writeln ("TZOFFSETFROM:-0600")
            Writeln ("TZOFFSETTO:-0500")
            Writeln ("End:DAYLIGHT")
            Writeln ("End:VTIMEZONE")
            Writeln "BEGIN:VEVENT"
            Writeln "CLASS:PUBLIC"
            Writeln ("CREATED;TZID=Central Standard Time:"+sDateStampWTime)
            Move (String(iYear)+String(iMonth)+String(iDay)+"T"+String(iHr)+String(iMin)+String(iSec)) to sDateStampWTime
            Writeln ("DTEND;TZID=Central Standard Time:"+sDateStampWTime) //STOP DATE AND TIME
            Writeln ("UID:" +sDateStampWTime+"-"+String(Random(10000000)) + "-example.com") // required by Outlok
            Writeln ("DTSTAMP;TZID=Central Standard Time:"+sDateStampWTime) // required by Outlook
            Writeln ("DTSTART;TZID=Central Standard Time:"+sDateStampWTime) //START DATE AND TIME
            Writeln ("SUMMARY;LANGUAGE=en-us:" + (Trim(Location.Name)) + " - " + (Trim(Order.Title)) + " - Job#: " + String(Order.JobNumber) )
            Writeln ("LOCATION:"+ String(Trim(Location.Address1))+", "+ String(Trim(Location.City)) +", " + String(Trim(Location.State)) + " " + (IsNineDigitCode(Self,Location.Zip)))
//            //Writeln ("DESCRIPTION:" + sPlainTxtMsg)
            For iAttachCount from 0 to (SizeOfArray(stAttachment)-1) 
                Writeln ("ATTACH;ENCODING=BASE64;VALUE=BINARY;X-FILENAME="+stAttachment[iAttachCount].sFileName+":"+stAttachment[iAttachCount].sBase64)
            Loop
            //Writeln ('ATTENDEE;CN="IT Depatment";RSVP=TRUE:mailto:it@interstatepm.com')
            //Writeln ('ORGANIZER;CN="Ben (Scheduler)":mailto:it@interstatepm.com')
            Writeln ("X-ALT-DESC;FMTTYPE=text/html:" + sHTML_Message) //HTML Version
            Writeln "X-MICROSOFT-CDO-BUSYSTATUS:BUSY"
            Writeln "X-MICROSOFT-CDO-IMPORTANCE:1"
            Writeln "END:VEVENT"
            Writeln "END:VCALENDAR"
        Close_Output 
        // Reset Argument size
        Set_Argument_Size iArgSize
        //Open the File
        Runprogram Shell background sTargetAddress
        
    End_Procedure

    Procedure TriggerInvoice
        Date dToday dStartDateRange dStopDateRange
        Integer iHr iMin iSec iJobNumber iQuoteID iNewInvoiceIdno iRepidno 
        Integer eResponse
        Sysdate dToday iHr iMin iSec
        String sInvoiceType
        Boolean bCancel 
        
        Move Order.JobNumber to iJobNumber
        Move Order.BillingType to sInvoiceType

        Case Begin
            Case (sInvoiceType = "S") //Standard Invoice (Single) to be created automatically from Order Detail
                Get Confirm ("This will Create the Invoice for Job#: " + String(iJobNumber)  + "\n \n Do you want to Continue?") to bCancel
                If (not(bCancel)) Begin
                    Get DoCreateInvoiceFromOrder of oInvoiceCreationProcess iJobNumber to iNewInvoiceIdno
                    If (iNewInvoiceIdno<>0) Begin
                        Clear Invhdr
                        Move iNewInvoiceIdno to Invhdr.InvoiceIdno
                        Find eq Invhdr.InvoiceIdno
                        If (Found) Begin
                            Clear Order
                            Move iJobNumber to Order.JobNumber
                            Find eq Order.JobNumber
                            If (Found) Begin                        
                                Reread Order
                                    Move iNewInvoiceIdno to Order.InvoiceReference
                                    //Move Order.OrderTotalAmount to Order.InvoiceAmt
                                    Move 1 to Order.SalesInvoiceOK_Flag
                                    Move dToday to Order.SalesInvoiceOK
                                    Move 1 to Order.LockedFlag
                                    Move "0" to Order.ReturnFlag
                                    Move 1 to Order.ChangedFlag
                                    SaveRecord Order
                                Unlock
                            End
                        End    
                    End
                    
                End     
                If (bCancel) Begin
                    Send Info_Box "Invoice was not created." "Process Canceled"
                End
            Case Break
            Case (sInvoiceType = "M" or sInvoiceType = "T" or sInvoiceType = "N")
                Move (YesNo_Box("Use Order detail to generate the Invoice?")) to eResponse
                If (eResponse = MBR_No) Begin
                    Send Info_Box "Use the Invoice Editor to manually create your Invoice"
                    Send Activate_oInvoiceEditor
                End
                If (eResponse = MBR_Yes) Begin
                    Get DoCreateInvoiceFromOrder of oInvoiceCreationProcess iJobNumber to iNewInvoiceIdno
                    
                    Clear Invhdr
                    Move iNewInvoiceIdno to Invhdr.InvoiceIdno
                    Find eq Invhdr.InvoiceIdno
                    If (Found) Begin
                        Clear Order
                        Move iJobNumber to Order.JobNumber
                        Find eq Order.JobNumber
                        If (Found) Begin                        
                            Reread Order
                                Move iNewInvoiceIdno to Order.InvoiceReference
                                Move Quotehdr.Amount to Order.InvoiceAmt
                                Move 1 to Order.SalesInvoiceOK_Flag
                                Move dToday to Order.SalesInvoiceOK
                                Move 1 to Order.LockedFlag
                                Move "0" to Order.ReturnFlag
                                SaveRecord Order
                            Unlock
                        End
                    End
                End
            Case Break
            Case Else
                Send Stop_Box ("There is no definition to Invoice Type:" * sInvoiceType) "Invoice Type Error"
        Case End
        //
        //
    End_Procedure    

    Procedure Activate_View
        If (giUserRights GE piMinViewRights(Self)) Begin
            Forward Send Activate_View
        End
        Else Begin
            Send Info_Box "You have no permission to open this view!"
        End        
    End_Procedure

    Procedure Activating
        Forward Send Activating
        //Show SalesGridDetails to Sales, Admin, Management, SystemAdmin
        Set pbShowSalesGridDetails to ((giUserRights>=50 and giUserRights<60) or (giUserRights>=65))
        Set pbShowOpsGridDetails to (giUserRights>=60)
        
    End_Procedure

End_Object
