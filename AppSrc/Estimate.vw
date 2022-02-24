// Z:\VDF17.0 Workspaces\Tempus\AppSrc\Estimate.vw
// Estimate
//
Use Windows.pkg
Use DFClient.pkg
Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use cDbCJGridColumn.pkg
Use cTempusDbView.pkg
Use cGlblDbForm.pkg
Use dfTable.pkg
Use cDbTextEdit.pkg
Use cComDbSpellText.pkg
Use cGlblDbComboForm.pkg
Use bpEstTtl.pkg
Use dbSuggestionForm.pkg
Use vWin32fh.pkg
Use UserInputDialog.dg
Use cImageList32.pkg
Use cDbImageContainer.pkg

Use Customer.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use SalesRep.DD
Use Contact.DD
Use cJcdeptDataDictionary.dd
Use cJccntrDataDictionary.dd
Use JCOPER.DD
Use Eshead.DD
Use Escomp.DD
Use Esitem.DD
Use cWorkTypeGlblDataDictionary.dd
Use MastOps.DD
Use cAttachmentsGlblDataDictionary.dd
Use cCustomerContractsGlblDataDictionary.dd

//Use PrintEstimate.rv
Use EstimateReport.rv
Use Estimate_DetailsReport.rv

Use UserInputDialog.dg
//Use EstimateWizard.dg
Use CompItem.dg //commend out to see DDO structure
Use FreeMultiSelectionDialog.dg

Use OrderProcess.bp
Use OrderEmailNotification.bp
Use OperationsProcess.bp
Use PMInvoiceFromQuote.bp
Use QuoteEstimateSync.bp

Use PrintJobSpecs.rv
Use JobSheetReport.rv
Use OrderInvoicePreviewReport.rv
Use dfLine.pkg
Use dfallent.pkg
Use dfTabDlg.pkg



Activate_View Activate_oEstimate for oEstimate

Object oEstimate is a cTempusDbView
    Set Location to 1 1
    Set Size to 362 580
    Set Label to "Estimate"
    Set Border_Style to Border_Thick
    Set piMinSize to 300 500
    Set Maximize_Icon to True

//    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
//    End_Object
//
//    Object oMastOps_DD is a Mastops_DataDictionary
//        Set DDO_Server to oWorkType_DD
//    End_Object

    Object oJcdept_DD is a cJcdeptDataDictionary
    End_Object

    Object oJccntr_DD is a cJccntrDataDictionary
        Set DDO_Server to oJcdept_DD
    End_Object

    Object oJcoper_DD is a Jcoper_DataDictionary
        Set DDO_Server to oJccntr_DD
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD is a Areas_DataDictionary
    End_Object // oAreas_DD
    
    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object // oSalesRep_DD

    Object oContact_DD is a Contact_DataDictionary
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oCustomer_DD
    End_Object // oContact_DD

    Object oEshead_DD is a Eshead_DataDictionary
        Set DDO_Server to oLocation_DD
        Set DDO_Server to oContact_DD
        Set DDO_Server to oSalesRep_DD
        // this lets you save a new parent DD from within child DD
        //Set Allow_Foreign_New_Save_State to True
    End_Object // oEshead_DD

    Object oEscomp_DD is a Escomp_DataDictionary
        Set DDO_Server to oEshead_DD
        Set Constrain_File to Eshead.File_Number
    End_Object // oEscomp_DD

    Object oEsitem_DD is a Esitem_DataDictionary
        Set DDO_Server to oJcoper_DD
        Set Constrain_file to Escomp.File_number
        Set DDO_Server to oEscomp_DD
        
        Procedure OnConstrain
            Constrain Esitem as (Jcoper.PRINT_FLAGS contains "J" or Jcoper.PRINT_FLAGS contains "L")
        End_Procedure
    End_Object

    Object oCustomerContracts_DD is a cCustomerContractsGlblDataDictionary
    End_Object

    Object oAttachments_DD is a cAttachmentsGlblDataDictionary
        Set pbUseDDRelates to True
        Set DDO_Server to oCustomerContracts_DD        
        Set Field_Related_FileField Field Attachments.ContractIdno to File_Field CustomerContracts.ContractIdno
        Set Constrain_File to Eshead.File_Number
        Set DDO_Server to oEshead_DD
        Set pbUseDDRelates to True
        Set Field_Related_FileField Field Attachments.EstimateIdno to File_Field Eshead.ESTIMATE_ID
    End_Object
    
    Set Main_DD to oEshead_DD
    Set Server to oEshead_DD

    //-----------------------------------------------------------------------
    // Create custom confirmation messages for save and delete
    // We must create the new functions and assign verify messages
    // to them.
    //-----------------------------------------------------------------------

    Function ConfirmDeleteHeader Returns Boolean
        Boolean bFail
        Get Confirm "Delete Entire Header and all detail?" to bFail
        Function_Return bFail
    End_Function // ConfirmDeleteHeader

    // Only confirm on the saving of new records
    Function ConfirmSaveHeader Returns Boolean
        Boolean bNoSave bHasRecord
        Handle  hoSrvr
        Get Server to hoSrvr
        Get HasRecord of hoSrvr to bHasRecord
        If not bHasRecord Begin
            Get Confirm "Save this NEW header?" to bNoSave
        End
        Function_Return bNoSave
    End_Function // ConfirmSaveHeader

    // Define alternate confirmation Messages
    Set Verify_Save_MSG       to (RefFunc(ConfirmSaveHeader))
    Set Verify_Delete_MSG     to (RefFunc(ConfirmDeleteHeader))
    // Saves in header should not clear the view
    Set Auto_Clear_Deo_State to False

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 26 570
        Set Location to 3 4
        Set peAnchors to anTopLeftRight

        Object oEshead_ESTIMATE_ID is a cGlblDbForm
            Entry_Item Eshead.ESTIMATE_ID
            Set Location to 5 46
            Set Size to 13 42
            Set Label to "Estimate#:"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
            Set Label_FontWeight to fw_Bold
    
            Procedure Refresh Integer notifyMode
                Forward Send Refresh notifyMode
                Boolean bHasEsheadRec bHasEscompRec bHasEsitemRec bHasQuoteRecord bHasOrder bEstimateIsLocked bHasAdminRights bHasSysAdminRights
                
                Get HasRecord of oEshead_DD to bHasEsheadRec
                Get HasRecord of oEscomp_DD to bHasEscompRec
                Get HasRecord of oEsitem_DD to bHasEsitemRec
                Move (Eshead.QuoteReference <> 0) to bHasQuoteRecord
                Move (Eshead.OrderReference <> 0) to bHasOrder
                Move (Eshead.LockedFlag <> 0) to bEstimateIsLocked
                Move (giUserRights >=70) to bHasAdminRights
                Move (giUserRights >=90) to bHasSysAdminRights
                //Specifications Button
                Set Enabled_State of oLockStateButton to bHasEsheadRec //(bHasAdminRights and bEstimateIsLocked) //Once user rights are established
//                Set Visible_State of oTestButton to (bHasSysAdminRights)
                If (bEstimateIsLocked) Begin
                    Set Bitmap of oLockStateButton to "locked.bmp"
                End
                Else Begin
                    Set Bitmap of oLockStateButton to "unlocked.bmp"
                End
                Set Enabled_State of oSpecificationsButton to ((bHasEsheadRec and not(bHasOrder)) or (bHasEsheadRec and bHasOrder and not(bEstimateIsLocked)))
                If (not(bHasEsheadRec)) Set Label of oSpecificationsButton to "Add/Edit Items"
                Else Set Label of oSpecificationsButton to "Add/Edit Items"
                //Add/Edit & Delete Button
                Set Enabled_State of oAddCompButton to (bHasEsheadRec and not(bHasOrder))
                Set Enabled_State of oDeletCompButton to (bHasEsheadRec and not(bHasOrder))
                
//                //QuoteSyncButton
//                Set Enabled_State of oQuoteEstimateSyncButton   to (bHasEsheadRec and bHasEscompRec)
//                If (not(bHasQuoteRecord)) Set Label of oQuoteEstimateSyncButton to "Create Quote"
//                Else Set Label of oQuoteEstimateSyncButton to "Sync Quote"
                // Print Button
                Set Enabled_State of oPrintButton to (bHasEsheadRec)
                Set Enabled_State of oCloneButton to (bHasEsheadRec)
                //CreateOrderButton
                Set Enabled_State of oCreateOrderButton to (bHasEsheadRec and bHasEscompRec and not(bHasOrder) and not(bEstimateIsLocked))
                // Entry Fields
                Set Enabled_State of oCustomerName to (not(bHasOrder) or not(bEstimateIsLocked))
                Set Enabled_State of oLocationName to (not(bHasOrder) or not(bEstimateIsLocked))
                Set Enabled_State of oContactFirstName to (not(bHasOrder) or not(bEstimateIsLocked))
                Set Enabled_State of oContactLastName to (not(bHasOrder)or not(bEstimateIsLocked))
                Set Enabled_State of oSalesRepFirstName to (not(bHasOrder)or not(bEstimateIsLocked))
                Set Enabled_State of oSalesRepLastName to (not(bHasOrder)or not(bEstimateIsLocked))
                Set Enabled_State of oEshead_TITLE to (not(bHasOrder)or not(bEstimateIsLocked))
                Set Enabled_State of oEshead_BillingType to (not(bHasOrder) or not(bEstimateIsLocked))
                Set Enabled_State of oEshead_WorkType to (not(bHasOrder) or not(bEstimateIsLocked))
                Set Enabled_State of oEshead_Status to (not(bHasOrder) or not(bEstimateIsLocked))
                Set Enabled_State of oComDbSpellText1 to (not(bHasOrder) or not(bEstimateIsLocked))
                // Attachment Tab
                Set Enabled_State of oAttachmentsGrid to (bHasEsheadRec and not(bEstimateIsLocked))
                Set Enabled_State of oDragAndDropContainer to (bHasEsheadRec and not(bEstimateIsLocked))
                Set pbAcceptDropFiles of oDragAndDropContainer to (bHasEsheadRec and not(bEstimateIsLocked))
            End_Procedure
 
        End_Object
        
        Object oEshead_TITLE is a cGlblDbForm
            Entry_Item Eshead.TITLE
            Set Location to 5 90
            Set Size to 13 238
            Set Label_Col_Offset to 0
            Set peAnchors to anTopLeftRight
            Set Label_FontWeight to fw_Bold
        End_Object

        Object oLockStateButton is a Button
            Set Size to 15 17
            Set Location to 4 332
            Set Label to 'oButton2'
            Set Bitmap to "unlocked.bmp"
            Set peAnchors to anTopRight
        
            // fires when the button is clicked
            Procedure OnClick
                Date dToday
                Sysdate dToday
                String sEnteredDate

                Boolean bEstimateLockStatus bHasRecord bShouldSave
                //
                Get Field_Current_Value of oEshead_DD Field Eshead.LockedFlag to bEstimateLockStatus
                If (bEstimateLockStatus = True) Begin
                    Get PopupUserInput of oUserInputDialog "Unlock Estimate" "Please enter password to unlock the Estimate" "" FALSE to sEnteredDate
                    If (sEnteredDate = dToday) Begin
                        Set Field_Changed_Value of oEshead_DD Field Eshead.LockedFlag to 0
                    End
                    Else Begin
                        Send Info_Box "Wrong Password Entered - Estimate not Unlocked" "Wrong Password"
                    End
                End
                Else Begin
                    Set Field_Changed_Value of oEshead_DD Field Eshead.LockedFlag to 1
                End
                                
                Get HasRecord of oEshead_DD to bHasRecord
                Get Should_Save of oEshead_DD to bShouldSave
                If (bHasRecord and bShouldSave) Begin
                    Send Request_Save of oEshead_DD
                End
            End_Procedure
        
        End_Object

        Object oEshead_WorkType is a cGlblDbComboForm
            Entry_Item Eshead.WorkType
            Set Location to 5 379
            Set Size to 12 77
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
            Set Label to "Type:"
            Set Label_FontWeight to fw_Bold
            Set peAnchors to anTopRight
            
            Procedure OnChange
                String sHasReqValue
                Get Value of (Self) to sHasReqValue
                If ((Length(sHasReqValue)) > 0) Set Label_TextColor to clBlack
                Else Set Label_TextColor to clRed                
            End_Procedure
        End_Object

        Object oEshead_Status is a cGlblDbComboForm
            Entry_Item Eshead.Status
            Set Location to 5 492
            Set Size to 12 67
            Set Label to "Status:"
            Set Label_Col_Offset to 2
            Set Label_FontWeight to fw_Bold
            Set Label_Justification_Mode to JMode_Right
            Set peAnchors to anTopRight
        End_Object
    End_Object

//    Object oEshead_Q1_TTL__ is a cGlblDbForm
//        Entry_Item Eshead.Q1_TTL__
//        Set Location to 333 45
//        Set Size to 13 66
//        Set Label to "Q1 TTL  :"
//        Set Label_Col_Offset to 5
//        Set Label_Justification_Mode to JMode_Right
//    End_Object
    
    Procedure doReceiveMessage String sEstimateIdno
        Send Request_Clear_All
        Move sEstimateIdno to Eshead.ESTIMATE_ID 
        Send Find of oEshead_DD EQ 1
    End_Procedure
    
//    Procedure Activating
//        If (giEstimateIdno) Begin
//            Send Request_Clear_All
//            //Showln ( "ACTIVATING - giEstimateIdno" + (String(giEstimateIdno)))
//            Move giEstimateIdno to Eshead.ESTIMATE_ID
//            Send Find of oEshead_DD EQ 1
//        End
//        Send Refind_Records of oEshead_DD
//        Forward Send Activating
//    End_Procedure

    Procedure Closing_View
        Forward Send Closing_View
        Send Exit_Application
    End_Procedure

    Function DoDeleteComponentItems Integer iEscompIdno Returns Boolean
        Boolean bCompleted 
        Boolean bCancel
        Integer iQuoteDtlIdno
        //
        If (not(HasRecord(oEshead_DD))) Begin
            Procedure_Return
        End
        If (not(HasRecord(oEscomp_DD))) Begin
            Procedure_Return
        End
        //
        Get Confirm ("Delete Estimate Component "* Escomp.DESCRIPTION *"? ") to bCancel
        If bCancel Procedure_Return
        //
        Send Refind_Records of oEshead_DD
        If (Found) Begin
            Move Eshead.ESTIMATE_ID to Escomp.ESTIMATE_ID
            Find ge Escomp.ESTIMATE_ID
            If ((Found) and Escomp.ESTIMATE_ID = Eshead.ESTIMATE_ID) Begin
                Move Escomp.ESTIMATE_ID  to Esitem.ESTIMATE_ID
                Move iEscompIdno to Esitem.COMPONENT_ID
                Move -9999999            to Esitem.OPCODE
                Find ge Esitem by Index.2
                While ((Found) and Esitem.ESTIMATE_ID = Escomp.ESTIMATE_ID and Esitem.COMPONENT_ID = iEscompIdno)
                    // Find QuoteDetail
                    Move Esitem.QuoteDtlReference to iQuoteDtlIdno
                    If (iQuoteDtlIdno>0) Begin
                        Send DeleteQuoteDetail of oDeleteStandards iQuoteDtlIdno
                    End
                    
                    Reread Esitem
                        Delete Esitem
                    Unlock
                    Clear Esitem
                    Move Escomp.ESTIMATE_ID  to Esitem.ESTIMATE_ID
                    Move Escomp.COMPONENT_ID to Esitem.COMPONENT_ID
                    Move -9999999            to Esitem.OPCODE
                    Find ge Esitem by Index.2
                Loop
                Function_Return True
            End
        End
    End_Function
    //
    //On_Key Key_Alt+Key_F2 Send DoDeleteComponentItems

    Procedure DoCalcEngine
        Integer iEsheadRecId iEscompRecId iStatus
        Boolean bHasEscompRec bError
        //
        Get Current_Record of oEshead_DD to iEsheadRecId
        Get Current_Record of oEscomp_DD to iEscompRecId
        //
        If (not(iEsheadRecId)) Begin
            Send Info_Box "No Estimate selected or created"
            Procedure_Return
        End
        //
//        Get HasRecord of oEscomp_DD to bHasEscompRec
        If (not(iEscompRecId)) Begin
            //
            Clear Escomp
            //
            Set Field_Changed_Value of oEscomp_DD Field Escomp.ESTIMATE_ID      to Eshead.ESTIMATE_ID
            Set Field_Changed_Value of oEscomp_DD Field Escomp.DESCRIPTION      to Eshead.TITLE
            Set Field_Changed_Value of oEscomp_DD Field Escomp.CREATION_DATE    to Eshead.CREATION_DATE
            Set Field_Changed_Value of oEscomp_DD Field Escomp.QTY1             to 1
            Set Field_Changed_Value of oEscomp_DD Field Escomp.QTY2             to 2
            Set Field_Changed_Value of oEscomp_DD Field Escomp.QTY3             to 3
            Get Request_Validate of oEscomp_DD                                  to bError
            If (not(bError)) Begin
                Send Request_Save of oEscomp_DD
            End
        End
        //
        Send Refind_Records of oEscomp_DD
        //
        Get Field_Current_Value of oEscomp_DD Field Escomp.Recnum           to iEscompRecId
        Send DoSpecifications of oComponentItemDialog iEscompRecId False True //1st boolean = bLocked, 2nd = bTrigger
        
//            //
//            Get_Attribute DF_FILE_STATUS of Escomp.File_Number to iStatus
//            If (iStatus = DF_FILE_ACTIVE) Begin
//                
//                //Send Find_By_Recnum   of hoDD Quotehdr.File_Number iEsheadRecId
//            End
    End_Procedure
        
    Procedure DoMaintenanceCalculate
        Integer hEsheadDD
        String  sEstimateId
        Boolean bReadOnly bCanceled
        //        Get pbReadOnly to bReadOnly
        //        If bReadOnly Procedure_Return
        If (Quotehdr.JobNumber <> 0) Procedure_Return
         //
        //        Move Eshead_DD to hEsheadDD
        //        If (not(Current_Record(hEsheadDD))) Procedure_Return
        //        Send Activate of EstimateContainer
        Move Quotehdr.QuotehdrID to sEstimateId
        //        Get Field_Current_Value of hEsheadDD Field Eshead.Estimate_id to sEstimateId
        Send Info_Box ("Maintenance recalc for Estimate" * sEstimateId)
        Send DoZeroEstimateTotals of ZeroEstimateTotalsProcess sEstimateId
        Set pbNoBackout  of oCalcEngine to True
        Set pbNoPreview  of ghoApplication to True //suppresses preview links message box in calc engine process
        //        Send DoCalculate of EstimateContainer
        //Get DoCalcEngine of oCalcEngine CE_BATCH bComponent bDebug to bCanceled
        Get DoCalcEngine of oCalcEngine CE_BATCH False False to bCanceled
        //
        Send Request_Assign of oQuotehdr_DD
        Set pbNoBackout  of oCalcEngine to False
        Set pbNoPreview  of ghoApplication to False 
    End_Procedure
    
    Procedure DoReloadStandards
        Send DoLoadStandards of oCalcEngine
    End_Procedure

    Object oDbComponentGroup is a dbGroup
        Set Size to 227 255
        Set Location to 131 5
        Set Label to 'Components'
        Set peAnchors to anTopBottomLeft

        Object oDetailGrid is a cDbCJGrid
            Set Size to 198 243
            Set Location to 10 6
            Set Server to oEscomp_DD
            Set Ordering to 3
            Set peAnchors to anAll
            Set psLayoutSection to "oEstimate_oDetailGrid"
            Set pbHeaderPrompts to True
            Set pbAllowColumnRemove to False
            Set pbAllowColumnReorder to False
            Set pbAllowColumnResize to False
            Set pbAllowInsertRow to False
            Set pbAllowAppendRow to True
            Set pbEditOnClick to True
            Set pbEditOnKeyNavigation to True
            Set piSelectedRowBackColor to clLtGray
            Set pbSelectionEnable to True
            Set TextColor to clBlack
            Set piHighlightForeColor to clBlack

            Procedure AddNewEscomp
                String sEsheadTitle
                Number nCurSequence
                Send Activate of oDetailGrid
                Send MovetoLastRow of oDetailGrid
                Get Field_Current_Value of oEscomp_DD Field Escomp.Sequence to nCurSequence
                Send Request_AppendRow
                Get PopupUserInput of oUserInputDialog "Add Component" "Please enter a component Title" "" False to sEsheadTitle
                Set Field_Changed_Value of oEscomp_DD Field Escomp.Sequence to (nCurSequence+1.0)
                Set Field_Changed_Value of oEscomp_DD Field Escomp.DESCRIPTION to sEsheadTitle
                Send Request_Save of oEscomp_DD
            End_Procedure

            Object oEscomp_Sequence is a cDbCJGridColumn
                Entry_Item Escomp.Sequence
                Set piWidth to 45
                Set psCaption to "Seq."
            End_Object

            Object oEscomp_DESCRIPTION is a cDbCJGridColumn
                Entry_Item Escomp.DESCRIPTION
                Set piWidth to 247
                Set psCaption to "Component Title"

                Procedure OnSelectedRowDataChanged String sOldValue String sValue
                    Forward Send OnSelectedRowDataChanged sOldValue sValue
                End_Procedure

            End_Object

            Object oEscomp_Q1_X__ is a cDbCJGridColumn
                Entry_Item Escomp.Q1_X_$
                Set piWidth to 133
                Set psCaption to "Total"
                Set piDisabledTextColor to clDefault
            End_Object


            Procedure OnRowChanged Integer iOldRow Integer iNewSelectedRow
                Forward Send OnRowChanged iOldRow iNewSelectedRow
                Set Label of oDbItemGroup to ("Items of "+Escomp.DESCRIPTION)
            End_Procedure

            Procedure OnEntering
                Integer eResponse
                Boolean bHasParentRecord
                Get HasRecord of oEshead_DD to bHasParentRecord
                If (not(bHasParentRecord)) Begin
                    Move (YesNo_Box("Save Estimate Header?", "Save Estimate", MB_DEFBUTTON1)) to eResponse
                    If (eResponse = MBR_YES) Begin
                        Send Request_Save of oEshead_DD
                    End  

                End
                
                Forward Send OnEntering
                
            End_Procedure

    
        End_Object // oDetailGrid
        Object oAddCompButton is a Button
            Set Size to 14 39
            Set Location to 210 5
            Set Label to 'Add'
            Set peAnchors to anBottomLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send AddNewEscomp of oDetailGrid
            End_Procedure
        
        End_Object
        Object oDeletCompButton is a Button
            Set Size to 14 39
            Set Location to 210 46
            Set Label to 'Delete'
            Set peAnchors to anBottomLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Integer iEscompIdno iEsheadId
                Boolean bSuccess
                Move Eshead.ESTIMATE_ID to iEsheadId
                Move Escomp.COMPONENT_ID to iEscompIdno
                Get DoDeleteComponentItems iEscompIdno to bSuccess
                If (bSuccess) Begin
                    Send Request_Delete of oEscomp_DD
                    Send Request_Clear_All
                    Move iEsheadId to Eshead.ESTIMATE_ID
                    Send Find of oEshead_DD EQ 1
                End
            End_Procedure
        
        End_Object
        Object oEshead_Q1_X__ is a cGlblDbForm
            Entry_Item Eshead.Q1_X_$
            Set Location to 209 156
            Set Size to 13 93
            Set Label to "Estimate Total:"
            Set peAnchors to anBottomRight
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
            Set Label_FontWeight to fw_Bold
            Set FontWeight to fw_Bold
        End_Object
    End_Object

    Object oDbItemGroup is a dbGroup
        Set Size to 226 305
        Set Location to 132 266
        Set Label to 'Items'
        Set peAnchors to anAll

        Object oESITEMGrid is a cDbCJGrid
            Set Server to oEsitem_DD
            Set pbAllowColumnRemove to False
            Set pbAllowColumnReorder to False
            Set pbAllowColumnResize to False
            Set Size to 116 289
            Set Location to 11 8
            Set pbAllowDeleteRow to False
            Set pbAllowAppendRow to False
            Set pbAllowInsertRow to False
            Set pbAutoAppend to False
            Set piSelectedRowBackColor to clLtGray
            Set pbSelectionEnable to True
            Set TextColor to clBlack
            Set piHighlightForeColor to clBlack
            Set piShadeSortColor to clBlack
            Set peAnchors to anAll
            Set pbHeaderReorders to True
            Set pbHeaderTogglesDirection to True
            Set Ordering to 5

            Object oEsitem_Sequence is a cDbCJGridColumn
                Entry_Item Esitem.Sequence
                Set piWidth to 35
                Set psCaption to "Seq."
            End_Object

            Object oJcoper_NAME is a cDbCJGridColumn
                Entry_Item Jcoper.NAME
                Set piWidth to 334
                Set psCaption to "Name"
                Set piDisabledTextColor to clBlack
            End_Object
    
            Object oEsitem_PROD_UNITS1 is a cDbCJGridColumn
                Entry_Item Esitem.PROD_UNITS1
                Set piWidth to 136
                Set psCaption to "Item Price"
                Set piDisabledTextColor to clBlack
            End_Object

            Procedure OnComRowDblClick Variant llRow Variant llItem
                Forward Send OnComRowDblClick llRow llItem
                Integer iEsheadId iEscompIdno
                Send Request_Save of oEshead_DD
                Get Field_Current_Value of oEshead_DD Field Eshead.ESTIMATE_ID to iEsheadId
                Send Request_Save of oEscomp_DD
                Get Field_Current_Value of oEscomp_DD Field Escomp.COMPONENT_ID to iEscompIdno
//                Send Request_Clear_All
//                Move iEsheadId to Eshead.ESTIMATE_ID
//                Send Find of oEshead_DD EQ 1
//                Move iEscompIdno to Escomp.COMPONENT_ID
//                Send Find of oEscomp_DD EQ 1
                
                
                Send DoCalcEngine
                //Send Refind_Records of oEshead_DD
                //Send RefreshDataFromExternal of oESITEMGrid 0
                Send Request_Clear_All
                Move iEsheadId to Eshead.ESTIMATE_ID
                Send Find of oEshead_DD EQ 1
            End_Procedure
        End_Object
        
        Object oSpecificationsButton is a Button
            Set Size to 14 80
            Set Location to 131 8
            Set Label to "Add/Edit Items"
            Set peAnchors to anBottomLeft
           // Set peAnchors to anTopRight
        
            Procedure OnClick
                Integer iEsheadId iEscompIdno
                Send Request_Save of oEshead_DD
                Get Field_Current_Value of oEshead_DD Field Eshead.ESTIMATE_ID to iEsheadId
                Send Request_Save of oEscomp_DD
                Get Field_Current_Value of oEscomp_DD Field Escomp.COMPONENT_ID to iEscompIdno
    //                Send Request_Clear_All
    //                Move iEsheadId to Eshead.ESTIMATE_ID
    //                Send Find of oEshead_DD EQ 1
    //                Move iEscompIdno to Escomp.COMPONENT_ID
    //                Send Find of oEscomp_DD EQ 1
                
                
                Send DoCalcEngine
                //Send Refind_Records of oEshead_DD
                //Send RefreshDataFromExternal of oESITEMGrid 0
                Send Request_Clear_All
                Move iEsheadId to Eshead.ESTIMATE_ID
                Send Find of oEshead_DD EQ 1
            End_Procedure
            
        End_Object
      
        Object oEscomp_Q1_X__1 is a cGlblDbForm
            Entry_Item Escomp.Q1_X_$
    
            Set Server to oEscomp_DD
            Set Location to 130 208
            Set Size to 13 89
            Set Label to "Component Total"
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
            Set peAnchors to anBottomRight
        End_Object

        Object oComDbSpellText1 is a cComDbSpellText
            Property Boolean pbText
            Property Boolean pbChangedText
            Property Integer piRecId
            Property String  psText
            
            Entry_Item Esitem.INSTRUCTION
            Set Server to oEsitem_DD
            Set Size to 63 289
            Set Location to 158 7
            Set peAnchors to anBottomLeftRight
            Set Label to "Description:"
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
        
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
                Send Activate of oESITEMGrid
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
                Set piRecId to (Current_Record(oEsitem_DD))
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
                    Set_Attribute DF_FILE_MODE of Esitem.File_Number to DF_FILEMODE_DEFAULT
                    Get piRecId                                        to iRecId
                    If (Esitem.Recnum <> iRecId) Begin
                        Clear Esitem
                        Move iRecId to Esitem.Recnum
                        Find eq Esitem.Recnum
                    End
                    Get psText                                         to sText
                    Reread
                    Move sText                                         to Esitem.INSTRUCTION
                    SaveRecord Esitem
                    Unlock
                    Send ChangeAllFileModes DF_FILEMODE_DEFAULT
                    Set pbChangedText                                  to False
                End
                //
                Procedure_Return iRetval
            End_Procedure

            Embed_ActiveX_Resource 
            k7IAAAwCAAADAAgAC/JXRyAAAABfAGUAeAB0AGUAbgB0AHgAMTQAAAMACAAK8ldHIAAAAF8AZQB4AHQAZQBuAHQAeQAyDAAADQAEAHXzDbw4AAAAZgBvAG4AdAADUuML
            kY/OEZ3jAKoAS7hRAQAAAJABkF8BAAhTZWdvZSBVSQAIAAgAu1dWszAAAABmAG8AbgB0AG4AYQBtAGUACAAAAFMAZQBnAG8AZQAgAFUASQAEAAgAO7lUkyAAAABmAG8A
            bgB0AHMAaQB6AGUAAAAQQQgAFQBhY0UUaAAAAGMAdQBzAHQAbwBtAGQAaQBjAHQAaQBvAG4AYQByAHkAZgBuAGEAbQBlABcAAABDADoAXABXAGkAbgBkAG8AdwBzAFwA
            QwBIAEMAVQBTAFQATwBNAC4AQwBVAEQACwANAJeCBTcoAAAAaQBnAG4AbwByAGUAYQBsAGwAYwBhAHAAcwAAAAsAEAA5uNPkMAAAAGMAaABlAGMAawBvAG4AZgBvAGMA
            dQBzAGwAbwBzAHMAAAAAAAMACwCOMEHAKAAAAG0AcwBmAG8AcgBlAGMAbwBsAG8AcgD/AAAAAAADAAsAknRFsCgAAABtAHMAYgBhAGMAawBjAG8AbABvAHIA////AAAA
            AwANAOkxPrMo/v//cwBxAHUAaQBnAGcAbABlAGMAbwBsAG8AcgD/AAAAAAA.
            End_Embed_ActiveX_Resource 
            
        End_Object
    End_Object

    Object oDbTabDialog1 is a dbTabDialog
        Set Size to 99 568
        Set Location to 29 5
    
        Set Rotate_Mode to RM_Rotate
        Set peAnchors to anTopLeftRight

        Object oDetailsDbTabPage is a dbTabPage
            Set Label to 'Details'

            Object oDbContainer3d2 is a dbContainer3d
                Set Size to 83 562
                Set Location to 0 1
                Set peAnchors to anTopLeftRight
        
                Object oCustomerName is a DbSuggestionForm
                    Entry_Item Customer.Name
                    Set Server to oLocation_DD
                    Set Size to 14 278
                    Set Location to 3 46
                    Set peAnchors to anLeftRight
                    Set Label to "Customer:"
                    Set Label_Justification_mode to JMode_Right
                    Set Label_Col_Offset to 2
                    Set Label_row_Offset to 0            
                    Set pbFullText to True
                    
                    Procedure OnChange
                        If (HasRecord(oCustomer_DD)) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed              
                    End_Procedure
                    
                    Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                        Send Activate_oCustomerEntry                   
                    End_Procedure
                    
                End_Object // oCustomerName
                
                Object oContactFirstName is a DbSuggestionForm
                    Entry_Item Contact.FirstName
                    Set Server to oContact_DD
                    Set Size to 13 125
                    Set Location to 19 46
                    Set Label to "Contact:"
                    Set Label_Justification_mode to JMode_Right
                    Set Label_Col_Offset to 2
                    Set Label_row_Offset to 0
                    Set pbFullText to True
                    
                    Procedure OnChange
                        If (HasRecord(oContact_DD)) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed              
                    End_Procedure
                    
                    Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                        Send Activate_oContactEntry                   
                    End_Procedure
                    
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
                                
                End_Object // oContactFirstName
                Object oContactLastName is a DbSuggestionForm
                    Entry_Item Contact.LastName
                    Set Server to oContact_DD
                    Set Size to 13 151
                    Set Location to 19 173
                    Set peAnchors to anLeftRight
                    Set Label_Justification_mode to jMode_Left
                    Set Label_Col_Offset to 0
                    Set Label_row_Offset to 0
                    Set pbFullText to True
                    
                    Procedure OnChange
                        If (HasRecord(oContact_DD)) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed              
                    End_Procedure
                    
                    Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                        Send Activate_oContactEntry                   
                    End_Procedure
                    
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
        
                End_Object // oContactLastName
                
                Object oContactEmailAddress is a cGlblDbForm
                    Entry_Item Contact.EmailAddress
        
                    Set Server to oContact_DD
                    Set Size to 13 237
                    Set Location to 34 87
                    Set peAnchors to anLeftRight
                    Set Label_Justification_mode to jMode_Left
                    Set Label_Col_Offset to 0
                    Set Label_row_Offset to 0
                    Set Enabled_State to False
                    Set Entry_State to False
                End_Object // oContactEmailAddress
                
                Object oLocationName is a DbSuggestionForm
                    Entry_Item Location.Name
        
                    Set Server to oLocation_DD
                    Set Size to 13 278
                    Set Location to 49 46
                    Set peAnchors to anLeftRight
                    Set Label to "Location:"
                    Set Label_Justification_mode to JMode_Right
                    Set Label_Col_Offset to 2
                    Set Label_row_Offset to 0
                    Set pbFullText to True
                    
                    Procedure OnChange
                        If (HasRecord(oLocation_DD)) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed              
                    End_Procedure
                    
                    Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                        Send Activate_oLocationEntry                   
                    End_Procedure
                End_Object // oLocationName
                
                Object oSalesRepFirstName is a DbSuggestionForm
                    Entry_Item SalesRep.FirstName
                    Set Size to 13 125
                    Set Location to 64 46
                    Set Label to "Sales Rep:"
                    Set Label_Justification_mode to JMode_Right
                    Set Label_Col_Offset to 2
                    Set Label_row_Offset to 0
                    Set pbFullText to True
                    
                    Procedure OnChange
                        If (HasRecord(oSalesRep_DD)) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed              
                    End_Procedure
                                
                    Procedure Prompt_Callback Integer hPrompt
                        Set pbAutoServer of hPrompt to False
                    End_Procedure
                    
                End_Object // oSalesRepFirstName
                Object oSalesRepLastName is a DbSuggestionForm
                    Entry_Item SalesRep.LastName
                    Set Size to 13 152
                    Set Location to 64 172
                    Set peAnchors to anLeftRight
                    Set Label_Justification_mode to jMode_Left
                    Set Label_Col_Offset to 0
                    Set Label_row_Offset to 0
                    Set pbFullText to True
                    
                    Procedure OnChange
                        If (HasRecord(oSalesRep_DD)) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed              
                    End_Procedure
                    
                    Procedure Prompt_Callback Integer hPrompt
                        Set pbAutoServer of hPrompt to False
                    End_Procedure
                    
                End_Object // oSalesRepLastName
                
                Object oEshead_QuoteReference is a cGlblDbForm
                    Entry_Item Eshead.QuoteReference
                    Set Location to 38 436
                    Set Size to 13 44
                    Set Label to "Quote:"
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to JMode_Right
                    Set Enabled_State to False
                    Set peAnchors to anTopRight
                    
                    Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                        String sQuoteIdno
                        Forward Send Mouse_Click iWindowNumber iPosition
                        Get Field_Current_Value of oEshead_DD Field Eshead.QuoteReference to sQuoteIdno
                        If (sQuoteIdno<>0) Begin
                            //Runprogram background "TempusEstimating.exe" (String(sEsheadIdno))
                            Send DoCallFromClient to oRPCClient sQuoteIdno "oQuoteEntry"
                        End
                    End_Procedure
                End_Object
                
                Object oQuoteEstimateSyncButton is a Button
                    Set Enabled_State to False
                    Set Size to 13 70
                    Set Location to 38 483
                    Set Label to "Create / Sync Quote"
                    Set peAnchors to anTopRight
                
                    // fires when the button is clicked
                    Procedure OnClick
                        Integer iQuoteIdno iNewQuoteIdno iEsheadId iJobNumber
                        Send Refind_Records of oEshead_DD
                        Send Request_Assign of oEshead_DD
                        Get Field_Current_Value of oEshead_DD Field Eshead.ESTIMATE_ID to iEsheadId
                        Get Field_Current_Value of oEshead_DD Field Eshead.QuoteReference to iQuoteIdno
                        Get Field_Current_Value of oEshead_DD Field Eshead.OrderReference to iJobNumber
                        If (iEsheadId = 0) Begin
                            Send Stop_Box "No Estimate Selected"
                        End
                        Else Begin
                            Get DoCreateQuoteFromEstimate of oQuoteEstimateSync iEsheadId iQuoteIdno to iNewQuoteIdno
                            Reread Eshead
                                Move iNewQuoteIdno to Eshead.QuoteReference
                                SaveRecord Eshead
                            Unlock
                            Send Request_Clear_All
                            Move iEsheadId to Eshead.ESTIMATE_ID
                            Send Find of oEshead_DD EQ 1
                        End
                        
                    End_Procedure
                
                End_Object
        
                Object oLineControl1 is a LineControl
                    Set Size to 6 218
                    Set Location to 27 338
                    Set peAnchors to anTopRight
                End_Object
        
                Object oEshead_OrderReference is a cGlblDbForm
                    Entry_Item Eshead.OrderReference
                    Set Location to 64 436
                    Set Size to 13 44
                    Set Label to "Job#:"
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to JMode_Right
                    Set Enabled_State to False
                    Set peAnchors to anTopRight
                    
                    Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                        String sJobNumber
                        Forward Send Mouse_Click iWindowNumber iPosition
                        Get Field_Current_Value of oEshead_DD Field Eshead.OrderReference to sJobNumber
                        If (sJobNumber<>0) Begin
                            //Runprogram background "TempusEstimating.exe" (String(sEsheadIdno))
                            Send DoCallFromClient to oRPCClient sJobNumber "oOrderEntry"
                        End
                    End_Procedure
                End_Object
        
                Object oCreateOrderButton is a Button
                    Set Size to 14 70
                    Set Location to 63 483
                    Set Label to "Create Order"
                    Set peAnchors to anTopRight
            
                    Procedure OnClick
                        Boolean bCancel bSuccess
                        Integer iJobNumber iCreated iErrors iEsheadIdno iLocIdno iRows
                        String sWorkType sFilePath sFileName
                        tDataSourceRow[] TheData
                        String[] sSelectedItems
                        //
                        Move "All pictures/maps have been added to the Estimate." to TheData[iRows].sValue[0]
                        Move 'PICTURES' to TheData[iRows].sValue[1]
                        Move False to TheData[iRows].sValue[2]
                        Move True to TheData[iRows].vTag //Flagged as required
                        Increment iRows
                        Move "Items for each required division have been added to the Estimate Detail." to TheData[iRows].sValue[0]
                        Move 'DETAILS' to TheData[iRows].sValue[1]
                        Move False to TheData[iRows].sValue[2]
                        Move True to TheData[iRows].vTag //Flagged as required
                        Increment iRows
                        Move "Do you want to create the Order now?" to TheData[iRows].sValue[0]
                        Move 'CREATE' to TheData[iRows].sValue[1]
                        Move False to TheData[iRows].sValue[2]
                        Move True to TheData[iRows].vTag //Flagged as required
                        Increment iRows
                        //
                        Get PopupMultiSelectDialog of oFreeMultiSelectionDialog "Estimate Requirements Checklist" 'All items must be checked before creating an Order' TheData (&sSelectedItems) to bSuccess
                        //Get Confirm ("Do you want to create the Order now?" ) to bCancel // replaced by FreeMultoSelectionDialog
                        If (bSuccess) Begin
                            Send Refind_Records of oEshead_DD
                            Get Field_Current_Value of oEshead_DD Field Eshead.ESTIMATE_ID to iEsheadIdno
                            Get Field_Current_Value of oEshead_DD Field Eshead.OrderReference to iJobNumber
                            Get Field_Current_Value of oEshead_DD Field Eshead.LocationIdno to iLocIdno
                            Get Field_Current_Value of oEshead_DD Field Eshead.WorkType to sWorkType
                            If (iJobNumber <> 0) Begin
                                Send Stop_Box ("Only one Order per Estimate") "Order Exists"
                                Procedure_Return
                            End
                            Else Begin
                                Get DoCreateOrderFromEstimate of oOrderProcess iEsheadIdno to iJobNumber
                                If (iJobNumber <>0) Begin
                                    // Have all Attachments show up under the new Order.
                                    Clear Attachments
                                    Move iEsheadIdno to Attachments.EstimateIdno
                                    Find GE Attachments by 5
                                    While ((Found) and Attachments.EstimateIdno = iEsheadIdno)
                                        Reread Attachments
                                            Move iJobNumber to Attachments.JobNumber
                                            Move 1 to Attachments.ChangedFlag
                                            Move Attachments.EstimateFlag to Attachments.OrderFlag
                                            SaveRecord Attachments
                                        Unlock
                                        Find GT Attachments by 5
                                    Loop
                                    // Notify all 
                                    Send DoJumpStartReport of oJobSheetReportView iJobNumber (&sFilePath) (&sFileName) False
                                    Send DoJumpStartReport of oOrderInvoicePreviewReportView iJobNumber (&sFilePath) (&sFileName) False
                                    Get DoSendOrderEmailNotification of oOrderEmailNotification iJobNumber True to bSuccess
                                    //
                                    Get DoAddUniversalMastOpsToLocation of oOperationsProcess iLocIdno sWorkType (&iErrors) to iCreated
                                    If (iErrors > 1) Begin
                                        Send Info_Box (String(iCreated) * "Operations created." * String(iErrors) * "errors.")
                                    End
                                    Send Request_Clear_All
                                    Move iEsheadIdno to Eshead.ESTIMATE_ID 
                                    Send Find of oEshead_DD EQ 1
                                    Send DoCallFromClient to oRPCClient iJobNumber "oOrderEntry"
                                End
                            End
                        End
                        Else Begin
                            Send Info_Box "Please make sure to complete and then check all Items on the list before creating the Order." "Info"
                        End
                    End_Procedure    
                    
                End_Object
        
                Object oEshead_BillingType is a cGlblDbComboForm
                    Entry_Item Eshead.BillingType
                    Set Location to 7 370
                    Set Size to 12 77
                    Set Label to "Billing:"
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to JMode_Right
                    Set peAnchors to anTopRight
                    
                    Procedure OnChange
                        String sHasReqValue
                        Get Value of (Self) to sHasReqValue
                        If ((Length(sHasReqValue)) > 0) Set Label_TextColor to clBlack
                        Else Set Label_TextColor to clRed                
                    End_Procedure
                End_Object
        
                Object oEshead_CREATION_DATE is a cGlblDbForm
                    Entry_Item Eshead.CREATION_DATE
                    Set Location to 7 485
                    Set Size to 13 68
                    Set Label to "Created:"
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to JMode_Right
                    Set peAnchors to anTopRight
                    Set Entry_State to False
                End_Object
        
                Object oPrintButton is a Button
                    Set Size to 14 69
                    Set Location to 30 335
                    Set Label to 'Estimate'
                    Set peAnchors to anTopRight
                    Set psImage to "DRPrint.ico"
                
                    // fires when the button is clicked
                    Procedure OnClick
                        Integer iEstimate
                        String sFilePath sFileName
                        Move Eshead.ESTIMATE_ID to iEstimate
                        If (iEstimate<>0) Begin
                            Send DoJumpStartReport of oEstimateReportView iEstimate (&sFilePath) (&sFileName) True
                        End
                    End_Procedure
                
                End_Object
        
                Object oCloneButton is a Button
                    Set Size to 14 69
                    Set Location to 60 335
                    Set Label to "Clone"
                    Set peAnchors to anTopRight
                    Set psImage to "ActionCopy.ico"
                
                    // fires when the button is clicked
                    Procedure OnClick
                        Send DoCloneEstimate
                    End_Procedure
                
                End_Object
                
//                Object oTestButton is a Button
//                    Set Size to 14 41
//                    Set Location to 32 5
//                    Set Label to "Test"
//                    Set peAnchors to anTopRight
//                    Set psImage to "ActionAbout.ico"
//                    Set Visible_State to False
//                
//                    // fires when the button is clicked
//                    Procedure OnClick
//                        Integer iJobNumber
//                        Get CreateOrderFromEstimate of oOrderProcess Eshead.ESTIMATE_ID to iJobNumber
//                    End_Procedure
//                
//                End_Object
                
                
        
            Procedure DoCloneEstimate
                Boolean bCancel bOk
                Integer iEsheadIdno iEscompIdno iEsitemIdno iEsheadRecId iNewEscompRecId iEscompRecId iEsitemRecId
                Integer iNewCust iNewLoc iNewContact
                Date dToday
                //
                Get Confirm ("Clone Estimate?") to bCancel
                If (not(bCancel)) Begin
                    Move Eshead.ESTIMATE_ID to iEsheadIdno
                    Send ChangeAllFileModes DF_FILEMODE_READONLY
                    Set_Attribute DF_FILE_MODE of System.File_Number to DF_FILEMODE_DEFAULT
                    Set_Attribute DF_FILE_MODE of Eshead.File_Number to DF_FILEMODE_DEFAULT                 
                    Set_Attribute DF_FILE_MODE of Escomp.File_Number to DF_FILEMODE_DEFAULT
                    Set_Attribute DF_FILE_MODE of Esitem.File_Number to DF_FILEMODE_DEFAULT
                    //
                    Get Confirm ("Change Customer, Location or Contact?") to bCancel
                    If (not(bCancel)) Begin
                        Get IsSelectedCustomer of Customer_sl (&iNewCust) to bOk
                        Get IsSelectedLocation of Location_sl iNewCust to iNewLoc
                        Get SelectContact of Contact_sl iNewCust (&iNewContact) to bOk
                    End
                    //
                    If (bOK and (iNewCust or iNewLoc or iNewContact)) Begin
                        Move Customer.CustomerIdno to Eshead.CustomerIdno
                        Move Location.LocationIdno to Eshead.LocationIdno
                        Move Contact.ContactIdno  to Eshead.ContactIdno
                    End
                    //
                    Sysdate dToday
                    Reread
                    Add 1 to System.LastEstimate
                    SaveRecord System
                    //
                    Move 0                          to Eshead.Recnum
                    Move System.LastEstimate        to Eshead.ESTIMATE_ID
                    Move dToday                     to Eshead.CREATION_DATE
                    Move 0                          to Eshead.OrderReference
                    Move 0                          to Eshead.QuoteReference
                    Move 0                          to Eshead.LockedFlag
                    Move "Y"                        to Eshead.NEEDS_CALCED
                    Move "P"                        to Eshead.Status
                    Move iEsheadIdno                to Eshead.CloneReference
                    SaveRecord Eshead
                    Unlock
                    Move Eshead.Recnum to iEsheadRecId
                    If (iEsheadRecId<>0) Begin
                        //Find Escomp Record
                        Clear Escomp
                        Move iEsheadIdno to Escomp.ESTIMATE_ID
                        Find GE Escomp by 2
                        While ((Found) and Escomp.ESTIMATE_ID = iEsheadIdno)
                            Move Escomp.COMPONENT_ID to iEscompIdno
                            Move Escomp.Recnum to iEscompRecId
                            //
                            Reread
                            Add 1 to System.EscompId
                            SaveRecord System
                            //Create new Escomp Record
                            Move 0 to Escomp.Recnum
                            Move System.EscompId            to Escomp.COMPONENT_ID
                            Move System.LastEstimate        to Escomp.ESTIMATE_ID
                            Move dToday                     to Escomp.CREATION_DATE
                            Move "Y"                        to Escomp.NEEDS_CALCED
                            
                            SaveRecord Escomp
                            Unlock
                            Move Escomp.Recnum to iNewEscompRecId
                            If (iNewEscompRecId <> 0) Begin
                                //Find EsItem Record
                                Clear Esitem
                                Move iEsheadIdno to Esitem.ESTIMATE_ID
                                Move iEscompIdno to Esitem.COMPONENT_ID
                                Find GE Esitem by 3
                                While ((Found) and Esitem.ESTIMATE_ID = iEsheadIdno and Esitem.COMPONENT_ID = iEscompIdno)
                                    Move Esitem.Recnum to iEsitemRecId
                                    Reread
                                    Add 1 to System.EsitemId
                                    SaveRecord System
                                    //Create new EsItem record
                                    Move 0 to Esitem.Recnum
                                    Move 0 to Esitem.QuoteDtlReference
                                    Move 0 to Esitem.OrderDtlReference
                                    Move System.EsitemId to Esitem.ITEM_ID
                                    Move System.EscompId to Esitem.COMPONENT_ID
                                    Move System.LastEstimate to Esitem.ESTIMATE_ID
                                    SaveRecord Esitem
                                    Unlock
                                    //
                                    Clear Esitem
                                    Move iEsitemRecId to Esitem.Recnum
                                    Find eq Esitem.Recnum
                                    Move iEsheadIdno to Esitem.ESTIMATE_ID
                                    Move iEscompIdno to Esitem.COMPONENT_ID
                                    Find GT Esitem by 3
                                Loop
                                
                            End
                            Clear Escomp
                            Move iEscompRecId to Escomp.Recnum
                            Find EQ Escomp.Recnum
                            Find GT Escomp by 2
                        Loop
                        Send Clear_All of oEshead_DD
                        Send Find_By_Recnum of oEshead_DD Eshead.File_Number iEsheadRecId
                    End
                    //
                    Send ChangeAllFileModes DF_FILEMODE_DEFAULT
                End
                Send Info_Box ("Cloning Successful - Your new Estimate# is:" * String(Eshead.ESTIMATE_ID))
                Send DoCalcEngine
                Send Activate of oEshead_ESTIMATE_ID
            End_Procedure

            Object oPrintButton is a Button
                Set Size to 14 69
                Set Location to 45 335
                Set Label to "Details"
                Set peAnchors to anTopRight
                Set psImage to "DRPrint.ico"
            
                // fires when the button is clicked
                Procedure OnClick
                    Integer iEstimate
                    //
//                        Get Field_Current_Value of oEshead_DD Field Eshead.ESTIMATE_ID to iEstimate
//                        If (iEstimate <> 0) Begin
//                            Send DoJumpStartReport of oPrintEstimate iEstimate
//                        End
                    Move Eshead.ESTIMATE_ID to iEstimate
                    If (iEstimate<>0) Begin
                        Send DoJumpStartReport of oEstimate_DetailsReportView iEstimate
                    End
                End_Procedure
            
            End_Object
        
            End_Object
        End_Object

        Object oDbTabPage1 is a dbTabPage
            Set Label to 'Attachments'
            
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
                Set Size to 82 444
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
                    Integer iArraySize i iSeq iDotPos iSlashPos iEsheadIdno iRetval iFileSize
                    String sYear sMonth sDay sHr sMin sSec sSourceFile sFileName sNewFileName sFileExt sTargetPath sTargetFile
                    Handle hoDD hoWorkspace
                    Boolean bSuccess bFail bIsImage
                    
                    Move (SizeOfArray(ArrayOfDroppedFiles)) to iArraySize
                    Move Eshead.ESTIMATE_ID to iEsheadIdno
                    
                    Constraint_Set 1
                    Constrain Attachments.EstimateIdno eq iEsheadIdno
                    Constrained_Find Last Attachments by 8
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
                        //
                        // Only allow image Files
                        Get IsImageFile sFileExt to bIsImage
                        // Generate Filename
                        Date dToday
                        Sysdate dToday sHr sMin sSec
                        //
                        Move (DateGetYear(dToday)) to sYear
                        Move (DateGetMonth(dToday)) to sMonth
                        Move (DateGetDay(dToday)) to sDay
                        Move (sYear+"_"+sMonth+"_"+sDay+"-"+sHr+"_"+sMin+"_"+sSec+"_"+String(i)+sFileExt) to sNewFileName
                        //Showln sNewFileName
                        Get psHome of (phoWorkspace(ghoApplication)) to sTargetPath
                        Move (sTargetPath+"Bitmaps\Attachments\") to sTargetPath
                        Move (sTargetPath+sNewFileName) to sTargetFile
                        //Showln ("- sTargetFile: "+ sTargetFile)
                        // Use CopyFile to move file to target address
                        //CopyFile sSourceFile to sTargetFile
                        Get vCopyFile sSourceFile sTargetFile to iRetval
                        If (iRetval=0) Begin
                            Increment iSeq
                            // Store all in Attachment Table       
                            Move oAttachments_DD to hoDD
                            Send Clear of hoDD
                            Set Field_Changed_Value of hoDD Field Attachments.EstimateIdno      to iEsheadIdno
                            Set Field_Changed_Value of hoDD Field Attachments.CreatedBy         to gsUsername
                            Set Field_Changed_Value of hoDD Field Attachments.CreatedDate       to dToday
                            Set Field_Changed_Value of hoDD Field Attachments.CreatedTime       to (sHr+":"+sMin+":"+sSec)
                            Set Field_Changed_Value of hoDD Field Attachments.Name              to sFileName
                            Set Field_Changed_Value of hoDD Field Attachments.Sequence          to iSeq
                            Set Field_Changed_Value of hoDD Field Attachments.FileName          to sNewFileName
                            Set Field_Changed_Value of hoDD Field Attachments.EstimateFlag      to bIsImage
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
                            Send Stop_Box ("There was an error attaching "+ sSourceFile + " Estimate# "+ String(iEsheadIdno)) "Error Attaching File"
                        End
                        
                    Loop
                End_Procedure

                Object oAttachmentsGrid is a cDbCJGrid
                    Set Server to oAttachments_DD
                    Set Size to 77 438
                    Set Location to 1 2
                    Set pbAllowDeleteRow to False
                    Set pbAllowInsertRow to False
                    Set peAnchors to anAll
                    Set pbShowRowFocus to True
                    Set pbAllowAppendRow to False
                    Set pbAllowColumnRemove to False
                    Set pbAllowColumnReorder to False
                    Set piHighlightBackColor to clLtGray
                    Set pbSelectionEnable to True
                    Set pbUseAlternateRowBackgroundColor to True


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
                                Integer eResponse iRetVal iEstimateIdno
                                Boolean bFail bIsLastRecord bIsContract
                                Handle hoDD
                                //
                                Move (Eshead.ESTIMATE_ID) to iEstimateIdno
                                Move (Trim(Attachments.AttachIdno)) to sAttachIdno
                                Move (Trim(Attachments.FileName)) to sAttachFileName
                                Move (Trim(Attachments.Name)) to sAttachName
                                Move (Attachments.ContractFlag) to bIsContract
                                Move (Trim(Customer.Name)) to sCustomerName
                                Move (Trim(Location.Name)) to sLocationName
    
                                //Send Info_Box ("You decited to delete "+ sAttachName +" aka. " + sAttachFileName + " (AttachIdno: " +sAttachIdno+")" ) "Removing Attachment"
                                Move (YesNo_Box("Do you want to remove " + sAttachName + " from Estimate#"+ String(iEstimateIdno)+"?","Remove Attached File",MB_DEFBUTTON1)) to eResponse
                                If (eResponse = MBR_Yes) Begin
                                    If (bIsContract) Begin
                                        String sTugContractsPath sCustomerPath sLocationPath
                                        Boolean bCustPathExists bLocPathExists bPathError bTargetPathExists bFileExists
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
                                        Reread Attachments
                                            // Remove Link to Quote Record
                                            Move 0 to Attachments.EstimateIdno
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
                                Send Clear_All of oEshead_DD
                                Move iEstimateIdno to Eshead.ESTIMATE_ID
                                Send Find of oEshead_DD EQ 1
                                //Send MoveToFirstRow of oAttachmentsGrid
                            End_Procedure
                        End_Object
                    End_Object


                    Object oAttachments_Sequence is a cDbCJGridColumn
                        Entry_Item Attachments.Sequence
                        Set piWidth to 62
                        Set psCaption to "Seq."
                    End_Object
    
                    Object oAttachments_Name is a cDbCJGridColumn
                        Entry_Item Attachments.Name
                        Set piWidth to 298
                        Set psCaption to "Name"
                    End_Object
    
                    Object oAttachments_Description is a cDbCJGridColumn
                        Entry_Item Attachments.Description
                        Set piWidth to 293
                        Set psCaption to "Description"
                    End_Object
    
                    Object oAttachments_EstimateFlag is a cDbCJGridColumn
                        Entry_Item Attachments.EstimateFlag
                        Set piWidth to 77
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
                            Set pbEditable of oAttachments_EstimateFlag to bIsImage
                            
                            //Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                        End_Procedure
                    End_Object
                    
                    Procedure OnComRowRClick Variant llRow Variant llItem
                        Send Popup of oAttachmentsCJContextMenu
                    End_Procedure

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

            Object oAttachmentsDbImageContainer is a cDbImageContainer
                Entry_Item Attachments.FileName

                Set Server to oAttachments_DD
                Set peImageStyle to ifFitOneSide
                Set Size to 71 97
                Set Location to 4 448
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

            Object oUploadFilesButton is a Button
                Set Size to 15 16
                Set Location to 3 547
                Set peAnchors to anTopRight
                Set psImage to "ActionAddRecord.ico"
                Set peImageAlign to Button_ImageList_Align_Center
                
                Procedure OnClick
                    Boolean bOpen bReadOnly bHasEstimateRec 
                    String sFileTitle sTargetAddress sTargetFilename sRandom sFileExt sTarget
                    Integer iDotPos iAttach
                    String[] sSelectedFiles
                    //
                    Move (Eshead.ESTIMATE_ID<>0) to bHasEstimateRec
                    //
                    If (bHasEstimateRec) Begin
                        Get Show_Dialog of oOpenDialog1 to bOpen
                        If bOpen Begin
                            Get TickReadOnly_State of oOpenDialog1 to bReadOnly
                            
                            Get Selected_Files of oOpenDialog1 to sSelectedFiles
                            For iAttach from 0 to (SizeOfArray(sSelectedFiles)-1)
                                If (bReadOnly) Append sSelectedFiles[iAttach] ' (Read-Only)' 
                            Loop
                            //Upload files
                            Send ProcessDroppedFiles of oDragAndDropContainer sSelectedFiles
                        End
                        //Else Send Info_Box "Picture Upload was canceled"
                    End // bHasLocationRecord
                    Else Begin
                        Send UserError "Please select an Estimate first." "No Estimate selected"
                    End
                End_Procedure // OnClick
            End_Object

        End_Object
    
    End_Object

    //
    On_Key Key_Alt+Key_F12 Send DoReloadStandards
    On_Key Key_Alt+Key_F5 Send DoMaintenanceCalculate

End_Object // oEstimate
