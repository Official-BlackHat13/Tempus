Use GlobalAllEnt.pkg
Use Employer.DD
Use Employee.DD
Use Customer.DD
Use Location.DD
Use Trans.DD
Use Opers.DD
Use Areas.DD
Use SalesRep.DD
Use Equipmnt.DD
Use MastOps.DD
Use cWorkTypeGlblDataDictionary.dd
Use Order.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use cInsClassGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use cWebAppUserRightsGlblDataDictionary.dd
Use cTempusDbView.pkg
Use cGlblDbForm.pkg

Use Equipmnt.sl

Use TransAttachment.bp
Use TransactionCopyProcess.bp
Use SQLExecute.bp

Use TransactionsByEmployeeReport.rv

Use Attachment.sl
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use Windows.pkg
Use cCJCommandBarSystem.pkg

Activate_View Activate_oTransactions for oTransactions
Object oTransactions is a cTempusDbView

    Property Integer piEmployeeIdno
    Property Integer piEquipIdno
    Property String  psEquipmentID
    Property String  psAttachIdno
    Property String  psAttachOpersIdno
    Property Integer piOrder
    Property Date    pdStartTrans
    Property Date    pdStopTrans
    //
    //
    Property Number  pnHoursTotal 0
    Property Number  pnBulkTotal 0
    Property Number  pnBagTotal 0
    Property Number  pnGalTotal 0
    //
    Property String  psCostType
    Property Boolean pbPrevOvelap
    Property Boolean pbNextOverlap
    Property Integer piOverlapCount

    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
    End_Object

    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object
        
    Object oInsClass_DD is a cInsClassGlblDataDictionary
    End_Object

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
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

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oMastOps_DD
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEquipmnt_DD is a Equipmnt_DataDictionary
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oEmployer_DD
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oWebAppUserRights_DD
        Set DDO_Server to oInsClass_DD
        Set ParentNullAllowed InsClass.File_Number to True
        Set DDO_Server to oEmployer_DD
    End_Object

    Object oTrans_DD is a Trans_DataDictionary
        Set DDO_Server to oOrder_DD
        Set Constrain_file to Employee.File_number
        Set DDO_Server to oOpers_DD
        Set DDO_Server to oEmployee_DD

        Procedure OnConstrain
            If (pdStopTrans(Self)<>0) Begin
               Constrain Trans.StartDate Between (pdStartTrans(Self)) and (pdStopTrans(Self)) 
            End
            Else Begin
                Constrain Trans.StartDate eq (pdStartTrans(Self))
            End
        End_Procedure

        Procedure Creating
            Integer iEquipIdno
            String  sEquipmentID sAttachIdno sAttachOpersIdno
            //
            Forward Send Creating
            //
            Get piEquipIdno   to iEquipIdno
            Get psEquipmentID to sEquipmentID
            Get psAttachIdno  to sAttachIdno
            Get psAttachOpersIdno to sAttachOpersIdno
            //
            Move iEquipIdno   to Trans.EquipIdno
            Move sEquipmentID to Trans.EquipmentID
            Move sAttachIdno    to Trans.AttachEquipIdno
            Move sAttachOpersIdno to Trans.AttachOpersIdno
        End_Procedure

        Procedure Clear
            Integer iOrder
            //
            Get piOrder to iOrder
            //
            Forward Send Clear
            //
//            If (iOrder <> 0) Begin
//                Send Find_By_Recnum Order.File_Number iOrder
//            End
        End_Procedure

        Procedure Clear_Main_File
            Forward Send Clear_Main_File
        End_Procedure
                
    End_Object

    Set Main_DD to oEmployee_DD
    Set Server to oEmployee_DD

    Set Border_Style to Border_Thick
    Set Size to 265 650
    Set Location to 4 5
    Set Label to "Transactions Entry/Edit"
    Set piMinSize to 200 650
    Set View_Latch_State to False
    Set Maximize_Icon to True
      

    Object oEmployeeContainer is a dbContainer3d
        Set Size to 43 639
        Set Location to 3 6
        Set peAnchors to anTopLeftRight

        Object oEmployee_EmployeeIdno is a dbForm
            Entry_Item Employee.EmployeeIdno
            Set Location to 5 40
            Set Size to 13 42
            Set Label to "ID/Name:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 2

            Procedure Prompt
                Boolean bSelected
                Handle  hoServer
                RowID   riEmployee riEmployer
                //
                Get Server                            to hoServer
                Move (GetRowID(Employee.File_Number)) to riEmployee
                //
                Get IsSelectedEmployee of Employee_sl (&riEmployee) (&riEmployer) to bSelected
                //
                If  (bSelected and not(IsNullRowId(riEmployee))) Begin
                    Send FindByRowId of hoServer Employee.File_Number riEmployee
                End
            End_Procedure

            Procedure Refresh Integer notifyMode
                Forward Send Refresh notifyMode
                Boolean bHasEmplRec bICEmployer bHasSysAdminRights //bIsZach
                //
                Move (HasRecord(oEmployee_DD)) to bHasEmplRec
                Move (giUserRights>=90) to bHasSysAdminRights
                //Move (gsUsername="zach.larson") to bIsZach
                Set piEmployeeIdno to Employee.EmployeeIdno
                If (bHasEmplRec) Begin
                    Move (Employee.EmployerIdno = 101) to bICEmployer
                    Send RefreshFooterTotals of oTransCJDBGrid
                End
//                Set Enabled_State of oCopyToButton to (bICEmployer and (bHasSysAdminRights))
//                Set Visible_State of oCopyToButton to (bHasSysAdminRights)
            End_Procedure

            Procedure Exiting Handle hoDestination Returns Integer
                Integer iRetVal
                Forward Get msg_Exiting hoDestination to iRetVal
                Send RefreshDataFromDD of oTransCJDBGrid ropTop
                Procedure_Return iRetVal
            End_Procedure

        End_Object

        Object oEmployee_FirstName is a cGlblDbForm
            Entry_Item Employee.FirstName
            Set Location to 5 216
            Set Size to 13 89
            Set Enabled_State to False
        End_Object

        Object oEmployee_LastName is a dbForm
            Entry_Item Employee.LastName
            Set Location to 5 87
            Set Size to 13 120
            Set Enabled_State to False
            Set Prompt_Button_Mode to PB_PromptOff
        End_Object

        Object oEmployer_Name is a cGlblDbForm
            Entry_Item Employer.Name
            Set Location to 5 309
            Set Size to 13 122
            Set Enabled_State to False
            Set Prompt_Button_Mode to PB_PromptOff
        End_Object

//        Object oCopyToButton is a Button
//            Set Size to 13 50
//            Set Location to 5 439
//            Set Label to 'CopyTo'
//        
//            Procedure OnClick
//                Integer iFromEmpl iToEmpl iEmployerIdno
//                Boolean bSuccess bFail
//                Date dStartDate dStopDate
//                String sErrorMsg
//                // Collect all current required values
//                Get Value of oEmployee_EmployeeIdno to iFromEmpl
//                Get Value of oStartDate to dStartDate
//                Get Value of oStopDate to dStopDate
//                If (dStopDate = "") Begin
//                    Move dStartDate to dStopDate
//                End
//                // prompt for destination employee
//                Move 101 to iEmployerIdno
//                Get DoEmplPromptwEmployer of Employee_sl (&iToEmpl) (&iEmployerIdno) to bSuccess
//                If (bSuccess) Begin
//                    // Execute TransactionCopyProcess
//                    Get DoCopyTransactions of oTransactionCopyProcess iFromEmpl iToEmpl dStartDate dStopDate (&sErrorMsg) to bFail
//                    Send Info_Box sErrorMsg "Transaction Copy Process"
//                End
//                
//                
//            End_Procedure
//        
//        End_Object



        Object oStartDate is a Form
            Set Location to 22 40
            Set Size to 13 60
            Set Label to "Start Date:"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
            Set Form_Datatype to Mask_Date_Window
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt

            Procedure Activating
                Forward Send Activating
                Date dToday
                Sysdate dToday
                Set Value of oStartDate to dToday
            End_Procedure

            Procedure Exiting Handle hoDestination Returns Integer
                Integer iRetVal
                Forward Get msg_Exiting hoDestination to iRetVal
                //
                Date dStartTrans dStopTrans
                Integer iDateDifference iEmployeeIdno
                String sErrMsg
                Boolean bSuccess
                //
                Get Value of oStartDate to dStartTrans
                Get Value of oStopDate to dStopTrans
                //If the start date is changed to a value greater than current stop date, an error does not let the user proceed until fixed.
                If (dStartTrans>dStopTrans) Begin
                    //This automatically clears the value from the stop date field.
                    Set Value of oStopDate to ''
                    Move '' to dStopTrans
                End
                Get ValidateDateSelection dStartTrans dStopTrans False (&sErrMsg) to bSuccess
                If (bSuccess) Begin
                    Set pdStartTrans              of oTrans_DD to dStartTrans
                    Send Rebuild_Constraints of oTrans_DD
                    Send RefreshDataFromDD of oTransCJDBGrid ropTop           
                    Send MoveToFirstRow of oTransCJDBGrid
                    Send RefreshFooterTotals of oTransCJDBGrid
                End
                Else Begin
                    Send Stop_Box sErrMsg "Error"
                    Move (not(bSuccess)) to iRetVal
                End
                
                Procedure_Return iRetVal
            End_Procedure

        End_Object

        Object oStopDate is a Form
            Set Location to 22 111
            Set Size to 13 60
            Set Label to "-"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
            Set Form_Datatype to Mask_Date_Window
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt

//            Procedure Activating
//                Forward Send Activating
//                Date dToday
//                Sysdate dToday
//                Set Value of oStopDate to dToday
//            End_Procedure

            Procedure Exiting Handle hoDestination Returns Integer
                Integer iRetVal
                Forward Get msg_Exiting hoDestination to iRetVal
                //
                Date dStartTrans dStopTrans
                Integer iDateDifference iEmployeeIdno
                String sErrMsg
                Boolean bSuccess
                //
                Get Value of oStartDate to dStartTrans
                Get Value of oStopDate to dStopTrans
                //If the start date is changed to a value greater than current stop date, an error does not let the user proceed until fixed.
                If (dStopTrans<dStartTrans) Begin
                    //This automatically clears the value from the stop date field.
                    Set Value of oStartDate to dStopTrans
                    Move dStartTrans to dStopTrans
                End
                Get ValidateDateSelection dStartTrans dStopTrans False (&sErrMsg) to bSuccess
                If (bSuccess) Begin
                    Set pdStopTrans              of oTrans_DD to dStopTrans
                    //
                    Send Rebuild_Constraints of oTrans_DD
                    Send RefreshDataFromDD of oTransCJDBGrid ropTop            
                    Send MoveToFirstRow of oTransCJDBGrid
                    Send RefreshFooterTotals of oTransCJDBGrid
                End
                Else Begin
                    Send Stop_Box sErrMsg "Error"
                    Move (not(bSuccess)) to iRetVal
                End
                
                Procedure_Return iRetVal
            End_Procedure
        End_Object

        Object oCopyToButton is a Button
            Set Location to 22 176
            Set Label to 'CopyTo'
        
            Procedure OnClick
                Integer iFromEmpl iToEmpl iEmployerIdno eResponse
                Boolean bSuccess bFail
                Date dStartDate dStopDate
                String sErrorMsg
                // Collect all current required values
                Get Value of oEmployee_EmployeeIdno to iFromEmpl
                Get Value of oStartDate to dStartDate
                Get Value of oStopDate to dStopDate
                If (dStopDate = "") Begin
                    Move dStartDate to dStopDate
                End
                // prompt for destination employee
                Move (YesNo_Box("Is this for the same Employer", "Same Employer?", MB_DEFBUTTON1)) to eResponse
                If (eResponse = MBR_Yes) Move Employer.EmployerIdno to iEmployerIdno
                Else Move 0 to iEmployerIdno
                Get DoEmplPromptwEmployer of Employee_sl (&iToEmpl) (&iEmployerIdno) to bSuccess
                If (bSuccess) Begin
                    // Execute TransactionCopyProcess
                    Get DoCopyTransactions of oTransactionCopyProcess iFromEmpl iToEmpl dStartDate dStopDate (&sErrorMsg) to bFail
                    Send Info_Box sErrorMsg "Transaction Copy Process"
                End
                
                
            End_Procedure
        
        End_Object
 
        Object oPrintTransButton is a Button
            Set Location to 22 233
            Set Label to 'Print'
        
            // fires when the button is clicked
            Procedure OnClick
                Integer iEmplIdno
                Date dStartDate dStopDate
                // Collect all current required values
                Get Value of oEmployee_EmployeeIdno to iEmplIdno
                Get Value of oStartDate to dStartDate
                Get Value of oStopDate to dStopDate
                If (dStopDate = "") Begin
                    Move dStartDate to dStopDate
                End
                If (iEmplIdno <> 0 and dStartDate <> "" and dStartDate <> "") Begin
                    Send DoJumpStartReport of oTransactionsByEmployeeReportView iEmplIdno dStartDate dStopDate
                End
            End_Procedure
        
        End_Object
        
    End_Object

    Object oTransCJDBGrid is a cDbCJGrid
        Set Server to oTrans_DD
        Set Size to 213 638
        Set Location to 47 5
        Set peAnchors to anAll
        Set pbShowFooter to True
        //Set piSelectedRowBackColor to 4227327
        //Set pbSelectionEnable to True
        Set pbEditOnKeyNavigation to True
        Set pbEditOnClick to True
        Set Ordering to 3
        Set pbAllowColumnRemove to False
        Set pbAllowColumnReorder to False
        Set pbHotTracking to True
        Set pbShowRowFocus to True
        Set pbStaticData to True


        Object oTrans_TransIdno is a cDbCJGridColumn
            Entry_Item Trans.TransIdno
            Set piWidth to 40
            Set psCaption to "TransIdno"
            Set pbVisible to False
            Set piDisabledTextColor to clDkGray
        End_Object

        Object oOrder_JobNumber is a cDbCJGridColumn
            Entry_Item Order.JobNumber
            Set piWidth to 50
            Set psCaption to "Job#"
            Set piDisabledTextColor to clDkGray
            Set piMaximumWidth to 60
            Set piMinimumWidth to 50
                        
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Set ComForeColor of hoGridItemMetrics to clBlack
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure       

            Function OnEntering Returns Boolean
                Boolean bRetVal
                Forward Get OnEntering to bRetVal
                
                Function_Return bRetVal
            End_Function

        End_Object

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 127
            Set psCaption to "Name"
            Set pbEditable to False
            Set pbFocusable to False
            Set piDisabledTextColor to clDkGray

            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            
        End_Object

        Object oTrans_EquipIdno is a cDbCJGridColumn
            Entry_Item Trans.EquipIdno
            Set piWidth to 40
            Set psCaption to "Equip#"
            Set Prompt_Button_Mode to PB_PromptOn
            Set piDisabledTextColor to clDkGray
            Set piMinimumWidth to 40
            Set piMaximumWidth to 50
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Set ComForeColor of hoGridItemMetrics to clBlack
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            
            Procedure Prompt
                Integer iEquipIdno iOldValue iEmployerIdno
                Boolean bSuccess
                //
                Get SelectedRowValue of oTrans_EquipIdno to iEquipIdno
                Move iEquipIdno to iOldValue
                Move Employer.EmployerIdno to iEmployerIdno
                Get DoEquipPromptwEmployer of Equipmnt_sl (&iEquipIdno) iEmployerIdno to bSuccess
                Send UpdateCurrentValue of oTrans_EquipIdno iEquipIdno
                Send OnEndEdit iOldValue iEquipIdno
                //Get OnExiting to bSuccess
            End_Procedure
            
            
            

            Function OnExiting Returns Boolean
                Boolean bError bValid
                Forward Get OnExiting to bError
                
                //
                Integer iLocIdno iEquipIdno iEmployerIdno iAltEquipIdno iCurrOpersIdno iOpersIdno iAttachmentIdno iAttachOpersIdno iAttachMastOps
                String sErrMsg sEquipmentId sCostType sAttachCat sNewStopDate sNewStopTime
                //
                Handle hoDD
                Get Server          to hoDD
                Send Refind_Records of hoDD
                //
                //
//                Get SelectedRowValueBeforeEdit of oTrans_EquipIdno to sOldValue
//                Get SelectedRowValue of oTrans_EquipIdno to sNewValue
                If (Should_Save(hoDD)) Begin
                    Move Employee.EmployerIdno to iEmployerIdno
                    Get SelectedRowValue of oTrans_EquipIdno to iEquipIdno
                    Move Location.LocationIdno to iLocIdno
                    Get IsEquipEntryValid iLocIdno iEquipIdno (&sEquipmentId) (&iOpersIdno) (&iAltEquipIdno) (&sAttachCat) (&sCostType) (&sErrMsg) to bValid
                    //Get IsEquipmentValid iLocIdno iEquipIdno to bValid
                    If (bValid) Begin
                        
                        //Send UpdateGridStatus // Update Grid Status
                        Case Begin
                            Case (sCostType = 'Material' or sCostType = 'PerTime')
                                //Fill StopDate and StopTime with Values if existing
                                Get SelectedRowValue of oTrans_StartDate to sNewStopDate
                                If (Length(sNewStopDate)>1) Begin
                                    Send UpdateCurrentValue of oTrans_StopDate sNewStopDate
                                End
                                Get SelectedRowValue of oTrans_StartTime to sNewStopTime
                                If (Length(sNewStopTime)>1) Begin
                                    Send UpdateCurrentValue of oTrans_StopTime sNewStopTime
                                End
                                Case Break
                            Case Else
                                // Empty Qty Field
                                Send UpdateCurrentValue of oTrans_Quantity '0'
                                Case Break
                        Case End
                        // Attachment required?
                        If (sAttachCat <> "NONE") Begin
                            Clear MastOps
                            Move sAttachCat to MastOps.IsAttachment
                            Find GE MastOps by Index.6
                            If ((Found) and MastOps.CostType = "Attachment") Begin
                                Get AttachmentSelection of Equipmnt_sl iEmployerIdno sAttachCat to iAttachmentIdno
                                Get isAttachmentValid iLocIdno iAttachmentIdno (&iAttachOpersIdno) (&iAttachMastOps) (&sErrMsg) to bValid
                                If (bValid) Begin        
                                    Move iAttachmentIdno to Trans.AttachEquipIdno
                                    Move iAttachMastOps to Trans.AttachMastOpsIdno
                                    Move iAttachOpersIdno to Trans.AttachOpersIdno                                    
                                    Set Field_Changed_Value of hoDD Field Trans.AttachEquipIdno to iAttachmentIdno
                                    Set Field_Changed_Value of hoDD Field Trans.AttachMastOpsIdno to iAttachMastOps
                                    Set Field_Changed_Value of hoDD Field Trans.AttachOpersIdno to iAttachOpersIdno
                                    Send UpdateCurrentValue of oTrans_AttachEquipIdno iAttachmentIdno
                                    Send UpdateCurrentValue of oTrans_AttachMastOpsIdno iAttachMastOps
                                    Send UpdateCurrentValue of oTrans_AttachOpersIdno iAttachOpersIdno
                                End
                                If (not(bValid)) Begin
                                    If (sErrMsg <> "") Begin
                                        Send Info_Box (sErrMsg) "Attachment Error"
                                    End
                                    Move 0 to Trans.AttachEquipIdno
                                    Move 0 to Trans.AttachOpersIdno
                                    Move 0 to Trans.AttachMastOpsIdno
                                    Set Field_Changed_Value of hoDD Field Trans.AttachEquipIdno to 0
                                    Set Field_Changed_Value of hoDD Field Trans.AttachMastOpsIdno to 0
                                    Set Field_Changed_Value of hoDD Field Trans.AttachOpersIdno to 0
                                    Send UpdateCurrentValue of oTrans_AttachEquipIdno 0
                                    Send UpdateCurrentValue of oTrans_AttachMastOpsIdno 0
                                    Send UpdateCurrentValue of oTrans_AttachOpersIdno 0
                                End
                            End
                        End
                        Else Begin
                            Move 0 to Trans.AttachEquipIdno
                            Move 0 to Trans.AttachOpersIdno
                            Move 0 to Trans.AttachMastOpsIdno
                            Set Field_Changed_Value of hoDD Field Trans.AttachEquipIdno to 0
                            Set Field_Changed_Value of hoDD Field Trans.AttachMastOpsIdno to 0
                            Set Field_Changed_Value of hoDD Field Trans.AttachOpersIdno to 0
                            Send UpdateCurrentValue of oTrans_AttachEquipIdno 0
                            Send UpdateCurrentValue of oTrans_AttachMastOpsIdno 0
                            Send UpdateCurrentValue of oTrans_AttachOpersIdno 0
                        End
                        
                        Move iOpersIdno to Opers.OpersIdno
                        Send Request_Find of hoDD EQ Opers.File_Number 1
                        //
                        Set piEquipIdno to iEquipIdno
                        Set psEquipmentID to sEquipmentId
                        Move iEquipIdno to Trans.EquipIdno
                        Move sEquipmentId to Trans.EquipmentID
                        Send UpdateCurrentValue of oTrans_EquipIdno iEquipIdno
                        //
                        // Update Equipment Description
                        String sDescription
                        Clear Equipmnt
                        Move iAttachmentIdno to Equipmnt.EquipIdno
                        Find EQ Equipmnt.EquipIdno
                        If ((Found) and Equipmnt.EquipIdno = iAttachmentIdno) Begin
                            Move ("-"*Trim(Equipmnt.Description)) to sDescription
                        End
                        Clear Equipmnt
                        //Get Field_Current_Value of oTrans_DD Field Trans.EquipIdno to iEquipIdno
                        Move iEquipIdno to Equipmnt.EquipIdno
                        Find EQ Equipmnt.EquipIdno
                        If ((Found) and Equipmnt.EquipIdno = iEquipIdno) Begin
                            Move (Trim(Equipmnt.Description)*sDescription) to sDescription
                        End
                        Send UpdateCurrentValue of oEquipmntAttach_Description sDescription
                    End
                    If (not(bValid)) Begin
                        Send UserError sErrMsg "Validation Error"
                        Move True to bError
                        Function_Return (bError)
                    End
                    //
                End    
                // 
                Send UpdateGridStatus
                //                
                Function_Return (bError)
            End_Function

            
        End_Object

        Object oTrans_AttachEquipIdno is a cDbCJGridColumn
            Entry_Item Trans.AttachEquipIdno
            Set pbEditable to False
            Set pbFocusable to False
            Set piWidth to 72
            Set psCaption to "AttachEquipIdno"
            Set pbVisible to False         
            Set piDisabledTextColor to clDkGray   
        End_Object

        Object oTrans_AttachMastOpsIdno is a cDbCJGridColumn
            Entry_Item Trans.AttachMastOpsIdno
            Set pbEditable to False
            Set pbFocusable to False
            Set piWidth to 72
            Set psCaption to "AttachMastOpsIdno"
            Set pbVisible to False         
            Set piDisabledTextColor to clDkGray   
        End_Object

        Object oTrans_AttachOpersIdno is a cDbCJGridColumn
            Entry_Item Trans.AttachOpersIdno
            Set pbEditable to False
            Set pbFocusable to False
            Set piWidth to 72
            Set psCaption to "AttachOpersIdno"
            Set pbVisible to False         
            Set piDisabledTextColor to clDkGray   
        End_Object

        Object oEquipmntAttach_Description is a cDbCJGridColumn
            //Entry_Item Equipmnt.Description
            Set piWidth to 155
            Set psCaption to "Equipment"
            Set pbEditable to False
            Set pbFocusable to False
            Set piDisabledTextColor to clDkGray
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                Case End
                //
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            

            Procedure OnSetCalculatedValue String  ByRef sValue
                Forward Send OnSetCalculatedValue (&sValue)
                //
                Integer iEquipIdno iAttachIdno iRow
                Handle hoDD hoDataSource
                String sDescription
                //
                Get Server          to hoDD
                //
                Move Trans.EquipIdno to iEquipIdno
                Move Trans.AttachEquipIdno to iAttachIdno
                //
                Clear Equipmnt
                Move iAttachIdno to Equipmnt.EquipIdno
                Find EQ Equipmnt.EquipIdno
                If ((Found) and Equipmnt.EquipIdno = Trans.AttachEquipIdno) Begin
                    Move ("-"*Trim(Equipmnt.Description)) to sDescription
                End
                Clear Equipmnt
                //Get Field_Current_Value of oTrans_DD Field Trans.EquipIdno to iEquipIdno
                Move iEquipIdno to Equipmnt.EquipIdno
                Find EQ Equipmnt.EquipIdno
                If ((Found) and Equipmnt.EquipIdno = Trans.EquipIdno) Begin
                    Move (Trim(Equipmnt.Description)*sDescription) to sDescription
                End
                Move (sDescription) to sValue
            End_Procedure
            
            
        End_Object

        Object oMastOps_CostType is a cDbCJGridColumn
            Entry_Item MastOps.CostType
            Set piWidth to 80
            Set psCaption to "Cost Type"
            Set pbComboButton to True
            Set pbEditable to False
            Set pbFocusable to False
            Set piDisabledTextColor to clDkGray
            Set piMinimumWidth to 80
            Set piMaximumWidth to 90
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Set ComForeColor of hoGridItemMetrics to clBlack
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
        End_Object

        Object oMastOps_CalcBasis is a cDbCJGridColumn
            Entry_Item MastOps.CalcBasis
            Set piWidth to 80
            Set psCaption to "Calc Type"
            //Set pbComboButton to True
            Set pbEditable to False
            Set pbFocusable to False
            Set piDisabledTextColor to clDkGray
            Set piMinimumWidth to 80
            Set piMaximumWidth to 90
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Set ComForeColor of hoGridItemMetrics to clBlack
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
        End_Object
        
        

        Object oTrans_StartDate is a cDbCJGridColumn
            Entry_Item Trans.StartDate
            Set piWidth to 68
            Set psCaption to "StartDate"
            Set piDisabledTextColor to clDkGray
            Set piMinimumWidth to 70
            Set piMaximumWidth to 70
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Set ComForeColor of hoGridItemMetrics to clBlack
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            
            Procedure OnSelectedRowDataChanged String sOldValue String sValue
                Forward Send OnSelectedRowDataChanged sOldValue sValue
                //
                String sCostType
                Get SelectedRowValue of oMastOps_CostType to sCostType
                If (sCostType = "Material" or sCostType = "PerTime") Begin
                    Send UpdateCurrentValue of oTrans_StopDate sValue
                End
            End_Procedure
            
            Function OnExiting Returns Boolean
                Boolean bRetVal
                Forward Get OnExiting to bRetVal
                //
                Date    dStart dToday
                Sysdate dToday
                // If no Start Date set, assume to use date from StartDate field.
                If (not(HasRecord(oTrans_DD))) Begin
                    Get SelectedRowValue of oTrans_StartDate to dStart
                    //Get Field_Current_Value of oTrans_DD Field Trans.StartDate to dStart
                    If (dStart = "") Begin
                        Get pdStartTrans of oTrans_DD to dStart
                        Send UpdateCurrentValue of oTrans_StartDate dStart
                        //Set Field_Changed_Value of oTrans_DD Field Trans.StartDate to dStart 
                    End
                End
                Function_Return bRetVal
            End_Function 
            
        End_Object

        Object oTrans_StartTime is a cDbCJGridColumn
            Entry_Item Trans.StartTime
            Set piWidth to 60
            Set psCaption to "StartTime"
            Set piDisabledTextColor to clDkGray
            Set piMinimumWidth to 60
            Set piMaximumWidth to 60
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed iTransIdno
                String sCostType sStartDate sStartHr sStartMin
                DateTime dtCurr
                Boolean bIsTimeTrans
                Variant vFont
                Handle hoFont
                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Get RowValue of oMastOps_CostType iRow to sCostType
                Move (not(sCostType = "Material" or sCostType = "PerTime")) to bIsTimeTrans
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Boolean bPrevOverlap
                        Get RowValue of oTrans_PrevOverlap iRow to bPrevOverlap
                        If (bIsTimeTrans and bPrevOverlap) Begin
                            Set pbPrevOvelap to True
                            Set ComForeColor of hoGridItemMetrics to clRed
                        End
                        Else Begin
                            Set ComForeColor of hoGridItemMetrics to clBlack
                        End
                        //Set pbFocusable of Self to True
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            
            Procedure OnSelectedRowDataChanged String sOldValue String sValue
                Forward Send OnSelectedRowDataChanged sOldValue sValue
                //
                String sCostType
                Get SelectedRowValue of oMastOps_CostType to sCostType
                If (sCostType = "Material" or sCostType = "PerTime") Begin
                    Send UpdateCurrentValue of oTrans_StopTime sValue
                End
            End_Procedure
            
        End_Object

        Object oTrans_StartHr is a cDbCJGridColumn
            Entry_Item Trans.StartHr
            Set piWidth to 18
            Set psCaption to "StartHr"
            Set pbVisible to False
        End_Object

        Object oTrans_StartMin is a cDbCJGridColumn
            Entry_Item Trans.StartMin
            Set piWidth to 18
            Set psCaption to "StartMin"
            Set pbVisible to False
        End_Object

        Object oTrans_StopDate is a cDbCJGridColumn
            Entry_Item Trans.StopDate
            Set piWidth to 70
            Set psCaption to "StopDate"
            Set piDisabledTextColor to clDkGray
            Set piMaximumWidth to 70
            Set piMinimumWidth to 70
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Set ComForeColor of hoGridItemMetrics to clBlack
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            
        End_Object

        Object oTrans_StopTime is a cDbCJGridColumn
            Entry_Item Trans.StopTime
            Set piWidth to 60
            Set psCaption to "StopTime"
            Set piDisabledTextColor to clDkGray
            Set piMaximumWidth to 60
            Set piMinimumWidth to 60
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed iTransIdno
                String sCostType sStopDate sStopHr sStopMin
                DateTime dtCurr
                Boolean bIsTimeTrans
                Variant vFont
                Handle hoFont
                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Get RowValue of oMastOps_CostType iRow to sCostType
                Move (not(sCostType = "Material" or sCostType = "PerTime")) to bIsTimeTrans
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Boolean bNextOverlap
//                        Get RowValue of oTrans_TransIdno iRow to iTransIdno
//                        Get RowValue of oTrans_StopDate iRow to sStopDate
//                        Get RowValue of oTrans_StartHr iRow to sStopHr
//                        Get RowValue of oTrans_StartMin iRow to sStopMin
//                        Move sStopDate to dtCurr
//                        Move (DateSetHour(dtCurr, sStopHr)) to dtCurr
//                        Move (DateSetMinute(dtCurr, sStopMin)) to dtCurr
//                        Get HasNextOverlappingTrans iTransIdno dtCurr to bNextOverlap
                        Get RowValue of oTrans_NextOverlap iRow to bNextOverlap
                        If (bIsTimeTrans and bNextOverlap) Begin
                            Set ComForeColor of hoGridItemMetrics to clRed
                            Set pbNextOverlap to True
//                            Get Create (RefClass(cComStdFont)) to hoFont
//                            Get ComFont of hoGridItemMetrics to vFont
//                            Set pvComObject of hoFont to vFont
//                            Set ComBold of hoFont to True
//                            Send Destroy of hoFont
                        End
                        Else Begin
                            Set ComForeColor of hoGridItemMetrics to clBlack
                        End
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            
        End_Object

        Object oTrans_StopHr is a cDbCJGridColumn
            Entry_Item Trans.StopHr
            Set piWidth to 18
            Set psCaption to "StopHr"
            Set pbVisible to False
        End_Object

        Object oTrans_StopMin is a cDbCJGridColumn
            Entry_Item Trans.StopMin
            Set piWidth to 18
            Set psCaption to "StopMin"
            Set pbVisible to False
        End_Object

        Object oTrans_ElapsedHours is a cDbCJGridColumn
            Entry_Item Trans.ElapsedHours
            Set piWidth to 50
            Set psCaption to "Hours"
            Set pbEditable to False
            Set pbFocusable to False
            Set piDisabledTextColor to clDkGray
            Set peFooterAlignment to (xtpAlignmentCenter + xtpAlignmentVCenter + xtpAlignmentWordBreak)
            Set piMaximumWidth to 60
            Set piMinimumWidth to 50
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Set ComForeColor of hoGridItemMetrics to clBlack
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure

//            Procedure OnSetCalculatedValue String ByRef sValue
//                Forward Send OnSetCalculatedValue (&sValue)
//                Move Trans.ElapsedHours to sValue
//                Number nHours
//                Move sValue to nHours
//                Set pnHoursTotal to (pnHoursTotal(Self)+nHours)
//            End_Procedure
            
        End_Object

        Object oTrans_Quantity is a cDbCJGridColumn
            Entry_Item Trans.Quantity
            Set piWidth to 50
            Set psCaption to "Quantity"   
            Set pbFocusable to False
            Set piDisabledTextColor to clDkGray
            Set peFooterAlignment to xtpAlignmentWordBreak
            Set pbMultiLine to True
            Set piMaximumWidth to 100
            Set piMinimumWidth to 50
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Set ComForeColor of hoGridItemMetrics to clBlack
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
                
        End_Object

        Object oTrans_Comment is a cDbCJGridColumn
            //Entry_Item Trans.Comment
            Set piWidth to 100
            Set psCaption to "Info"
            Set pbEditable to False
            Set pbFocusable to False
            Set piDisabledTextColor to clDkGray
            Set piMinimumWidth to 100
            Set piMaximumWidth to 200
            Set pbMultiLine to True
            Set peTextAlignment to xtpAlignmentWordBreak
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Case Begin
                            Case (sValue contains "Warning:") 
                                Set ComForeColor of hoGridItemMetrics to clOrange
                                Case Break
                            Case (sValue contains "ALERT:")
                                Set ComForeColor of hoGridItemMetrics to clRed
                                Case Break
                            Case Else
                                Set ComForeColor of hoGridItemMetrics to clBlack
                                Case Break
                        Case End
                        Case Break
                    Case Else
                        Set ComForeColor of hoGridItemMetrics to clBlack
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure

            Procedure OnSetCalculatedValue String  ByRef sValue
                Forward Send OnSetCalculatedValue (&sValue)
                Number nHours
                Integer iVendInvFlag iVendInvIdno
                String sTimeWarn sVendInvWarn
                //
                Move Trans.ElapsedHours to nHours
                Move Trans.VendInvHdrIdno to iVendInvIdno
                Move Trans.VendInvoicedFlag to iVendInvFlag
                //
                Move (If(nHours>=24.00,"ALERT: EXTREMELY HIGH HOURS!",If(nHours>=12.00,"Warning: High Hours",''))) to sTimeWarn
                Move (If(iVendInvFlag<>0,("VendInv#:"*String(iVendInvIdno)),'')) to sVendInvWarn
                //
                Move (If(Length(Trim(Trans.Comment))>0,("Comment: "+Trim(Trans.Comment)),'')) to sValue
                Move (sValue+(If(Length(Trim(sValue))>0 and Length(Trim(sTimeWarn))>0,Character(10),'')+sTimeWarn)) to sValue
                Move (sValue+(If(Length(Trim(sValue))>0 and Length(Trim(sVendInvWarn))>0,Character(10),'')+sVendInvWarn)) to sValue
            End_Procedure
            
        End_Object

        Object oTrans_VendInvoicedFlag is a cDbCJGridColumn
            Entry_Item Trans.VendInvoicedFlag
            Set piWidth to 78
            Set psCaption to "Invoiced"
            Set pbCheckbox to True
            Set pbVisible to False
            Set pbEditable to False
            Set pbFocusable to False
            Set piDisabledTextColor to clDkGray
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Set ComForeColor of hoGridItemMetrics to clBlack
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            
        End_Object

        Object oTrans_PayrollProcessedFlag is a cDbCJGridColumn
            //Entry_Item Trans.PayrollProcessedFlag
            Set piWidth to 18
            Set psCaption to "PayrollProcessedFlag"
            Set pbCheckbox to True
            Set pbVisible to False
            Set pbEditable to False
            Set pbFocusable to False
            Set piDisabledTextColor to clDkGray
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iVendInvoiced iPayrollProcessed
                //
                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
                //Get RowValue of oTrans_PayrollProcessedFlag iRow to iPayrollProcessed
                Case Begin
                    Case (iVendInvoiced = 1 or iPayrollProcessed = 1)
                        Set ComForeColor of hoGridItemMetrics to clDkGray
                        Case Break
                    Case (iVendInvoiced = 0 and iPayrollProcessed = 0)
                        Set ComForeColor of hoGridItemMetrics to clBlack
                        Case Break
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            
        End_Object

        Object oTrans_TimeFlag is a cDbCJGridColumn
            Set pbVisible to False
            Set piWidth to 33
            Set psCaption to "Time"
            Set pbFocusable to False
            Set pbEditable to False
            Set pbCheckbox to True

            Procedure OnSetCalculatedValue String ByRef sValue
                Forward Send OnSetCalculatedValue (&sValue)
                Integer iTransIdno
                If (MastOps.CostType <> "Material" and MastOps.CostType <> "PerTime") Begin
                    Move 1 to sValue
                End
            End_Procedure
        End_Object

        Object oTrans_MatFlag is a cDbCJGridColumn
            Set pbVisible to False
            Set piWidth to 35
            Set psCaption to "Mat"
            Set pbFocusable to False
            Set pbEditable to False
            Set pbCheckbox to True

            Procedure OnSetCalculatedValue String ByRef sValue
                Forward Send OnSetCalculatedValue (&sValue)
                Integer iTransIdno
                If (MastOps.CostType = "Material" or MastOps.CostType = "PerTime") Begin
                    Move 1 to sValue
                End
            End_Procedure
        End_Object
                
        Object oTrans_PrevOverlap is a cDbCJGridColumn
            Set pbVisible to False
            Set piWidth to 36
            Set psCaption to "Prev"
            Set pbFocusable to False
            Set pbEditable to False
            Set pbCheckbox to True

//            Procedure OnSetCalculatedValue String ByRef sValue
//                Forward Send OnSetCalculatedValue (&sValue)
//                If (Trans.TransIdno<>0 and Trans.StartDate<>'' and Trans.StartTime<>'' and Trans.StopDate<>'' and Trans.StopTime<>'' and MastOps.CostType <> "Material" and MastOps.CostType <> "PerTime") Begin
//                    String sSqlQuery sResult
//                    Boolean bSuccess
//                    // PreviousOverlap occurs, when the current, timed transactions Start Date+Time is smaller (<) than a previous transactions Stop Date+Time
//                    Move ("SELECT Count(TransIdno) AS Result FROM (";
//                    + " SELECT TOP (100) PERCENT Trans.TransIdno, Trans.StartDate, Trans.StartTime FROM TRANSACTIONS as Trans";
//                    + " LEFT JOIN MastOps on Trans.MastOpsIdno = MastOps.MastOpsIdno";
//                    + " WHERE EmployeeIdno="+String(Trans.EmployeeIdno)+" and MastOps.CostType <> 'Material' and MastOps.CostType <> 'PerTime'";
//                    + " and (DATEADD(minute, "+String(Trans.StartMin)+", (DATEADD(hour, "+String(Trans.StartHr)+", '"+(IsSqlDate(Self, Trans.StartDate))+"')))) > (DATEADD(minute, Trans.StartMin, (DATEADD(hour, Trans.StartHr, Trans.StartDate))))";
//                    + " and (DATEADD(minute, "+String(Trans.StartMin)+", (DATEADD(hour, "+String(Trans.StartHr)+", '"+(IsSqlDate(Self, Trans.StartDate))+"')))) < (DATEADD(minute, Trans.StopMin, (DATEADD(hour, Trans.StopHr, Trans.StopDate))))";
//                    + " ORDER BY Trans.StartDate, Trans.StartTime) AS Trns") to sSqlQuery
//                    Get ExecuteSQLQuery of oSQLExecute sSqlQuery (&sResult) to bSuccess
//                    Move (sResult<>"0") to sValue
//                End
//            End_Procedure
        End_Object
        
        Object oTrans_NextOverlap is a cDbCJGridColumn
            Set pbVisible to False
            Set piWidth to 33
            Set psCaption to "Next"
            Set pbEditable to False
            Set pbFocusable to False
            Set pbCheckbox to True

//            Procedure OnSetCalculatedValue String ByRef sValue
//                Forward Send OnSetCalculatedValue (&sValue)
//                If (Trans.TransIdno<>0 and Trans.StartDate<>'' and Trans.StartTime<>'' and Trans.StopDate<>'' and Trans.StopTime<>'' and MastOps.CostType <> "Material" and MastOps.CostType <> "PerTime") Begin
//                    String sSqlQuery sResult
//                    Boolean bSuccess
//                    // NextOverlap occurs, when the current, timed transactions Stop Date+Time is larger (>) than a previous transactions Start Date+Time
//                    Move ("SELECT Count(TransIdno) AS Result FROM (";
//                    + " SELECT TOP (100) PERCENT Trans.TransIdno, Trans.StartDate, Trans.StartTime FROM TRANSACTIONS as Trans";
//                    + " LEFT JOIN MastOps on Trans.MastOpsIdno = MastOps.MastOpsIdno";
//                    + " WHERE EmployeeIdno="+String(Trans.EmployeeIdno)+" and MastOps.CostType <> 'Material' and MastOps.CostType <> 'PerTime'";
//                    + " and (DATEADD(minute, "+String(Trans.StopMin)+", (DATEADD(hour, "+String(Trans.StopHr)+", '"+(IsSqlDate(Self, Trans.StopDate))+"')))) > (DATEADD(minute, Trans.StartMin, (DATEADD(hour, Trans.StartHr, Trans.StartDate))))";
//                    + " and (DATEADD(minute, "+String(Trans.StopMin)+", (DATEADD(hour, "+String(Trans.StopHr)+", '"+(IsSqlDate(Self, Trans.StopDate))+"')))) < (DATEADD(minute, Trans.StopMin, (DATEADD(hour, Trans.StopHr, Trans.StopDate))))";
//                    + " ORDER BY Trans.StartDate, Trans.StartTime) AS Trns") to sSqlQuery
//                    Get ExecuteSQLQuery of oSQLExecute sSqlQuery (&sResult) to bSuccess
//                    Move (sResult<>"0") to sValue
//                End
//            End_Procedure
        End_Object

        Object oCJTransactionContextMenu is a cCJContextMenu
            Object oAddCommentMenuItem is a cCJMenuItem
                Set psCaption to "Add Comment"
                Set psTooltip to "Add Comment"

                Procedure OnExecute Variant vCommandBarControl
                    Forward Send OnExecute vCommandBarControl
                    String sAddComment sComment
                    Get PopupUserInput of oUserInputDialog "Transaction Comment" "Please add your transaction comment" "" False to sAddComment
                    Get Field_Current_Value of oTrans_DD Field Trans.Comment to sComment
                    Move (Trim(sComment)+If(Length(Trim(sComment))>0 and Length(Trim(sAddComment))>0," | ","")+Trim(sAddComment)) to sComment
                    Set Field_Changed_Value of oTrans_DD Field Trans.Comment to sComment
                End_Procedure
            End_Object
        End_Object
        
        
        
        Function IsEquipmentValid Integer iLocationIdno Integer iEquipIdno Returns Integer
            Clear Equipmnt MastOps Opers
            Move iEquipIdno to Equipmnt.EquipIdno
            Find eq Equipmnt.EquipIdno
            If (Found) Begin
                Set piEquipIdno   to Equipmnt.EquipIdno
                Set psEquipmentID to Equipmnt.EquipmentID
                Relate Equipmnt
                If (MastOps.Recnum <> 0) Begin
                    Move iLocationIdno       to Opers.LocationIdno 
                    Move MastOps.MastOpsIdno to Opers.MastOpsIdno  /// code to check Mastop# present in location opers records
                    Find eq Opers by Index.4
                    If (Found) Begin
                        Function_Return Opers.OpersIdno
                    End
                End
            End
        End_Function
        
        Function IsEquipEntryValid Integer iLocationIdno Integer iEquipIdno String ByRef sEquipmentId Integer ByRef iOpersIdno Integer ByRef iAltEquipIdno String ByRef sAttachCat String ByRef sCostType String ByRef sErrorMsg Returns Boolean
            Clear Equipmnt MastOps Opers
            Move iEquipIdno to Equipmnt.EquipIdno
            Find eq Equipmnt.EquipIdno
            If ((Found) and Equipmnt.Status = "A") Begin
                Relate Equipmnt
                Move Equipmnt.EquipmentID to sEquipmentId
                If (MastOps.Recnum <> 0) Begin
                    Move (Trim(MastOps.CostType)) to sCostType
                    Move (Trim(MastOps.NeedsAttachment)) to sAttachCat
                    Move iLocationIdno       to Opers.LocationIdno
                    Move MastOps.MastOpsIdno to Opers.MastOpsIdno
                    Find eq Opers by Index.4
                    If (Found) Begin
                        Move Opers.OpersIdno to iOpersIdno
                        Move Equipmnt.CEPM_EquipIdno to iAltEquipIdno
                        Function_Return True
                    End
                    Else Begin
                        Move ("Equipment "*(Trim(Equipmnt.Description))*" can't be used at this location!") to sErrorMsg
                        Function_Return False
                    End
                End
                Else Begin
                    Move "Equipment is not related to MastOps" to sErrorMsg
                    Function_Return False
                End
            End
            Else Begin
                Move "Equipment not found or Inactive" to sErrorMsg
                Function_Return False
            End
        End_Function        

        Function isAttachmentValid Integer iLocationIdno Integer iAttachIdno Integer ByRef iAttachOpersIdno Integer ByRef iAttachMastOps String ByRef sErrorMsg Returns Boolean
            Clear Equipmnt MastOps Opers
            If (iAttachIdno <> 0) Begin
                Move iAttachIdno to Equipmnt.EquipIdno
                Find eq Equipmnt.EquipIdno
                If ((Found) and Equipmnt.Status = "A") Begin
                    Relate Equipmnt
                    If (MastOps.Recnum <> 0 and MastOps.CostType = "Attachment") Begin
                        Move iLocationIdno       to Opers.LocationIdno
                        Move MastOps.MastOpsIdno to Opers.MastOpsIdno
                        Find eq Opers by Index.4
                        If (Found) Begin
                            Move Opers.OpersIdno to iAttachOpersIdno
                            Move Opers.MastOpsIdno to iAttachMastOps
                            Function_Return (Found)
                        End
                        Else Begin
                            Move "Attachment category not allowed at location" to sErrorMsg
                            Function_Return False
                        End
                    End
                    Else Begin
                        Move "Item not a Attachment code" to sErrorMsg
                        Function_Return False
                    End
                End
                Else Begin
                    Move "Attachment not found" to sErrorMsg
                    Function_Return False
                End
            End
            //No Attachment was selected
            Move "" to sErrorMsg
            Function_Return True
        End_Function        
        
        Procedure RefreshFooterTotals
            Handle hoDateSource
            tDataSourceRow[] TheData
            Integer iRows i iOverlapCount
            Number nTotalHours nBulkTotal nBagTotal nUnitTotal nGalTotal
            String sTotalHours sBulkTotal sBagTotal sUnitTotal sGalTotal
            String sCalcBasis
            //
            Get phoDataSource to hoDateSource
            Get DataSource of hoDateSource to TheData
            Move (SizeOfArray(TheData)) to iRows
            For i from 0 to (iRows-1)
                
                Move (TheData[i].sValue[9]) to sCalcBasis
                Move (iOverlapCount + TheData[i].sValue[25]+TheData[i].sValue[26]) to iOverlapCount
                Case Begin
                    Case (sCalcBasis = "Hours")
                        Move (nTotalHours + TheData[i].sValue[18]) to nTotalHours
                        Case Break
                    Case (sCalcBasis = "Pounds")
                        Move (nBulkTotal + TheData[i].sValue[19]) to nBulkTotal
                        Case Break
                    Case (sCalcBasis = "Bags")
                        Move (nBagTotal + TheData[i].sValue[19]) to nBagTotal
                        Case Break
                    Case (sCalcBasis = "Units")
                        Move (nUnitTotal + TheData[i].sValue[19]) to nUnitTotal
                        Case Break
                    Case (sCalcBasis = "Gallons")
                        Move (nGalTotal + TheData[i].sValue[19]) to nGalTotal
                        Case Break
                Case End
            Loop
            //
            Set piOverlapCount to iOverlapCount
            // Update Footer all
            //
            //Hours
            Move (String(nTotalHours)+ "(h)") to sTotalHours
            Set psFooterText of oTrans_ElapsedHours to sTotalHours
            // Material
            Move (String(nBulkTotal)+"(lbs)") to sBulkTotal
            Move (String(nBagTotal)+"(bags)") to sBagTotal
            Move (String(nUnitTotal)+"(units)") to sUnitTotal
            Move (String(nGalTotal)+"(gal)") to sGalTotal
            Set psFooterText of oTrans_Quantity to (If(nBulkTotal<>0,sBulkTotal,"")*If(nBagTotal<>0, sBagTotal,"")*If(nUnitTotal<>0, sUnitTotal,"")*If(nGalTotal<>0, sGalTotal,"")) 

        End_Procedure
        
        Function IsSqlDate Date dSource Returns String
            String sYYYY sMM sDD
            //
            Move (mid(String(dSource),2,1)) to sMM
            Move (mid(String(dSource),2,4)) to sDD
            Move (mid(String(dSource),4,7)) to sYYYY
            Function_Return (sYYYY + "-" + sMM + "-" + sDD)
        End_Function        

//        Function HasPrevOverlappingTrans Integer iTransIdno Returns Boolean
//            Boolean bOverlapping bSuccess
//            Integer iEmployeeIdno
//            String sSqlQuery sResult
//            
//            //Compare to Previous
//            // Find Previous Trans of this Employee, StopDate & Time has to be GE StartDate & Time of current Trans
//            Move iTransIdno to Trans.TransIdno
//            Find EQ Trans.TransIdno
//            If ((Found) and Trans.TransIdno = iTransIdno and Trans.StartDate<>'' and Trans.StartTime<>'' and Trans.StopDate<>'' and Trans.StopTime<>'') Begin
//                Move Trans.EmployeeIdno to iEmployeeIdno
//                Move ("SELECT Count(TransIdno) AS Result FROM (";
//                + " SELECT TOP (100) PERCENT Trans.TransIdno, Trans.StartDate, Trans.StartTime FROM TRANSACTIONS as Trans";
//                + " LEFT JOIN MastOps on Trans.MastOpsIdno = MastOps.MastOpsIdno";
//                + " WHERE EmployeeIdno="+String(iEmployeeIdno)+" and MastOps.CostType <> 'Material' and MastOps.CostType <> 'PerTime'";
//                + " and (DATEADD(minute, "+String(Trans.StartMin)+", (DATEADD(hour, "+String(Trans.StartHr)+", '"+(IsSqlDate(Self, Trans.StartDate))+"')))) < (DATEADD(minute, Trans.StopMin, (DATEADD(hour, Trans.StopHr, Trans.StopDate))))";
//                + " and (DATEADD(minute, "+String(Trans.StopMin)+", (DATEADD(hour, "+String(Trans.StopHr)+", '"+(IsSqlDate(Self, Trans.StopDate))+"')))) > (DATEADD(minute, Trans.StopMin, (DATEADD(hour, Trans.StopHr, Trans.StopDate))))";
//                + " ORDER BY Trans.StartDate, Trans.StartTime) AS Trns") to sSqlQuery
//                Get ExecuteSQLQuery of oSQLExecute sSqlQuery (&sResult) to bSuccess
//                Move (sResult<>"0") to bOverlapping
//            End    
//
//            Function_Return bOverlapping
//        End_Function
//        
//        Function HasNextOverlappingTrans Integer iTransIdno Returns Boolean
//            Boolean bOverlapping bSuccess
//            Integer iEmployeeIdno
//            String sSqlQuery sResult
//
//            //Compare to Previous
//            // Find Previous Trans of this Employee, StopDate & Time has to be GE StartDate & Time of current Trans
//            Move iTransIdno to Trans.TransIdno
//            Find EQ Trans.TransIdno
//            If ((Found) and Trans.TransIdno = iTransIdno and Trans.StartDate<>'' and Trans.StartTime<>'' and Trans.StopDate<>'' and Trans.StopTime<>'') Begin
//                Move Trans.EmployeeIdno to iEmployeeIdno
//                Move ("SELECT Count(TransIdno) AS Result FROM (";
//                + " SELECT TOP (100) PERCENT Trans.TransIdno, Trans.StartDate, Trans.StartTime from TRANSACTIONS as Trans";
//                + " LEFT JOIN MastOps on Trans.MastOpsIdno = MastOps.MastOpsIdno";
//                + " WHERE EmployeeIdno="+String(iEmployeeIdno)+" and MastOps.CostType <> 'Material' and MastOps.CostType <> 'PerTime'";
//                + " and (DATEADD(minute, "+String(Trans.StopMin)+", (DATEADD(hour, "+String(Trans.StopHr)+", '"+(IsSqlDate(Self, Trans.StopDate))+"')))) > (DATEADD(minute, Trans.StartMin, (DATEADD(hour, Trans.StartHr, Trans.StartDate))))";
//                + " and (DATEADD(minute, "+String(Trans.StartMin)+", (DATEADD(hour, "+String(Trans.StartHr)+", '"+(IsSqlDate(Self, Trans.StartDate))+"')))) < (DATEADD(minute, Trans.StartMin, (DATEADD(hour, Trans.StartHr, Trans.StartDate))))";
//                + " ORDER BY Trans.StartDate, Trans.StartTime) AS Trns") to sSqlQuery
//                Get ExecuteSQLQuery of oSQLExecute sSqlQuery (&sResult) to bSuccess
//                Move (sResult<>"0") to bOverlapping
//            End    
//
//            Function_Return bOverlapping
//        End_Function

        Procedure UpdateGridStatus
            //Send RefreshFooterTotals
            // If Labor, Enable StopDate and Time, Disable Quantity columnt
            // If Material, Disable StopDate and Time and make them the same as StartDate and Time
            String sCostType
            Boolean bIsTimeTrans bIsMatTrans bTransInvoiced bIsPayrollProcessed
            Get SelectedRowValue of oMastOps_CostType to sCostType
            Get SelectedRowValue of oTrans_VendInvoicedFlag to bTransInvoiced
            //Get SelectedRowValue of oTrans_PayrollProcessedFlag to bIsPayrollProcessed
            //
            Move (not(sCostType = 'Material' or sCostType = 'PerTime')) to bIsTimeTrans
            
            Set pbEditable of oOrder_JobNumber to (not(bTransInvoiced) and not(bIsPayrollProcessed))
            Set pbFocusable of oOrder_JobNumber to (not(bTransInvoiced) and not(bIsPayrollProcessed))
            Set pbEditable of oTrans_EquipIdno to (not(bTransInvoiced) and not(bIsPayrollProcessed))
            Set pbEditable of oTrans_AttachEquipIdno to (not(bTransInvoiced) and not(bIsPayrollProcessed))
            Set pbEditable of oTrans_StartDate to (not(bTransInvoiced) and not(bIsPayrollProcessed))
            Set pbEditable of oTrans_StartTime to (not(bTransInvoiced) and not(bIsPayrollProcessed))
            Set pbFocusable of oTrans_StopDate to (bIsTimeTrans and (not(bTransInvoiced) and not(bIsPayrollProcessed)))
            Set pbFocusable of oTrans_StopTime to (bIsTimeTrans and (not(bTransInvoiced) and not(bIsPayrollProcessed)))
            Set pbFocusable of oTrans_Quantity to (not(bIsTimeTrans) and (not(bTransInvoiced) and not(bIsPayrollProcessed)))
            //
            Send RefreshFooterTotals
        End_Procedure

        Procedure OnEnterObject Handle hoFrom
            Forward Send OnEnterObject hoFrom
        End_Procedure

        Function OnPostEntering Returns Boolean
            Boolean bRetVal            
            Send Stop_Box "No employee selected or wrong dates entered"
            Function_Return True
        End_Function

        Procedure OnEntering
            Forward Send OnEntering
            Boolean bFail
            Date dStartDate dStopDate
            String sErrorMsg
            //
            Set pdStartTrans to (Value(oStartDate))
            Set pdStopTrans to (Value(oStopDate))
            
            //Check if there is an employee
            Move (ValidateDateSelection(Self,pdStartTrans(oTransactions),pdStopTrans(oTransactions),False,(&sErrorMsg)) and (not(HasRecord(oEmployee_DD)))) to bFail
            If (bFail) Begin
                Set pbNeedPostEntering to True
            End
            Else Begin
//                Send UpdateGridStatus
            End
        End_Procedure

//        Function OnExiting Handle hoDestination Returns Boolean
//            Boolean bRetVal
//            Forward Get OnExiting hoDestination to bRetVal
//            Move (not(pbPrevOvelap(Self) or pbNextOverlap(Self))) to bRetVal
//            If (not(bRetVal)) Begin
//                Send Stop_Box "There are Transactions with overlapping times. Look for the RED start or stop time!" "Overlapping Transaction"
//            End
//            Function_Return bRetVal
//        End_Function

//        Procedure OnComFocusChanging Variant llNewRow Variant llNewColumn Variant llNewItem Boolean  ByRef llCancel
//            Forward Send OnComFocusChanging llNewRow llNewColumn llNewItem (&llCancel)
//            Send UpdateGridStatus            
//        End_Procedure

//        Procedure OnComSelectionChanged
//            Forward Send OnComSelectionChanged
//            Send UpdateGridStatus
//        End_Procedure
        
//        Function OnRowChanging Integer iCurrentSelectedRow Integer iNewRow Returns Boolean
//            Boolean bRetVal
//            Forward Get OnRowChanging iCurrentSelectedRow iNewRow to bRetVal
//            Send UpdateGridStatus
//            Function_Return bRetVal
//        End_Function

        Procedure OnRowChanged Integer iOldRow Integer iNewSelectedRow
            Forward Send OnRowChanged iOldRow iNewSelectedRow
            Send UpdateGridStatus
        End_Procedure

        Procedure OnComValueChanged Variant llRow Variant llColumn Variant llItem
            Forward Send OnComValueChanged llRow llColumn llItem
            Send UpdateGridStatus
        End_Procedure

        Procedure OnWrappingRow Boolean bForwardWrap Handle hoToColumn Boolean  ByRef bWrapRow Boolean  ByRef bCancel
            Forward Send OnWrappingRow bForwardWrap hoToColumn (&bWrapRow) (&bCancel)
            Send UpdateGridStatus
        End_Procedure

        Procedure OnComRowRClick Variant llRow Variant llItem
            Forward Send OnComRowRClick llRow llItem
            Send Popup of oCJTransactionContextMenu
        End_Procedure
                
    End_Object

//    Object oTransCJDBGrid is a cDbCJGrid
//        Set Server to oTrans_DD
//        Set Size to 213 636
//        Set Location to 49 8
//        Set pbShowRowFocus to True
//        Set pbUseFocusCellRectangle to False
//        Set pbShowFooter to True
//        Set piSelectedRowBackColor to clDkGray
//        Set piHighlightBackColor to clDkGray
//        Set piHighlightForeColor to clDkGray
//        Set piSelectedRowForeColor to clDkGray
//        Set peAnchors to anAll
//        Set pbEditOnClick to True
//        Set pbEditOnKeyNavigation to True
//
//        Object oTrans_JobNumber is a cDbCJGridColumn
//            Entry_Item Order.JobNumber
//            Set piWidth to 44
//            Set psCaption to "Job#"
//            Set pbAllowDrag to False
//            Set pbAllowRemove to False
//            Set pbDrawFooterDivider to False
//
//            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
//                Integer iVendInvoiced
//                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
//                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
//                Case Begin
//                    Case (iVendInvoiced = 1)
//                        Set ComForeColor of hoGridItemMetrics to clRed
//                        Set pbEditable of Self to False
//                        Case Break
//                    Case (iVendInvoiced = 0)
//                        Set ComForeColor of hoGridItemMetrics to clBlack
//                        Set pbEditable of Self to True
//                        Case Break
//                Case End
//                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
//            End_Procedure
//
//        End_Object
//
//        Object oLocation_Name is a cDbCJGridColumn
//            Entry_Item Location.Name
//            Set piWidth to 176
//            Set psCaption to "Location"
//            Set pbAllowDrag to False
//            Set pbAllowRemove to False
//            Set pbEditable to False
//            Set pbFocusable to False
//            Set pbDrawFooterDivider to False
//            
//            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
//                Integer iVendInvoiced
//                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
//                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
//                Case Begin
//                    Case (iVendInvoiced = 1)
//                        Set ComForeColor of hoGridItemMetrics to clRed
//                        Set pbEditable of Self to False
//                        Case Break
//                    Case (iVendInvoiced = 0)
//                        Set ComForeColor of hoGridItemMetrics to clBlack
//                        Set pbEditable of Self to True
//                        Case Break
//                Case End
//                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
//            End_Procedure
//            
//        End_Object
//
////        Object oTrans_EquipIdno is a cDbCJGridColumn
////            Entry_Item Trans.EquipIdno
////            Set piWidth to 70
////            Set psCaption to "Equip#"
////            Set Prompt_Button_Mode to PB_PromptOn
////            
////            Procedure Prompt
////                Integer iEquipIdno iOldValue iEmployerIdno
////                Boolean bSuccess
////                //
////                Get SelectedRowValue of oTrans_EquipIdno to iEquipIdno
////                Move iEquipIdno to iOldValue
////                Move Employer.EmployerIdno to iEmployerIdno
////                Get DoEquipPromptwEmployer of Equipmnt_sl (&iEquipIdno) iEmployerIdno to bSuccess
////                Send UpdateCurrentValue of oTrans_EquipIdno iEquipIdno
////                Send OnEndEdit iOldValue iEquipIdno
////            End_Procedure
////            
////            Procedure Prompt_Callback Handle hoPrompt
////                Forward Send Prompt_Callback hoPrompt
////            End_Procedure
////            
////            //ToDo: Attachment Slection on Transaction View should happen during the "OnEndEdit" procedure of oTrans_EquipIdno
////
////
////            Procedure OnEndEdit String sOldValue String sNewValue
////                Boolean bRetVal
////                Integer iLocIdno iEquipIdno iEmployerIdno iAltEquipIdno iCurrOpersIdno iOpersIdno iAttachmentIdno iAttachOpersIdno iAttachMastOps
////                String sErrMsg sEquipmentId sCostType sAttachCat
////                Boolean bValid
////                Handle hoDD
////                //
////                Forward Send OnEndEdit sOldValue sNewValue
////                //
////                Get Server                to hoDD
////                Send Refind_Records of hoDD
////                //
////                Move Employee.EmployerIdno to iEmployerIdno
////                Get SelectedRowValue of oTrans_EquipIdno to iEquipIdno
////                Move Location.LocationIdno to iLocIdno
////                //Get IsEquipEntryValid iLocIdno iEquipIdno (&sEquipmentId) (&iOpersIdno) (&iAltEquipIdno) (&sAttachCat) (&sCostType) (&sErrMsg) to bValid                
////                //Get IsEquipmentValid iLocIdno iEquipIdno to bValid
////                If (bValid) Begin
////                    Set piEquipIdno to Equipmnt.EquipIdno
////                    Set psEquipmentID to Equipmnt.EquipmentID
////                    Move iEquipIdno to Trans.EquipIdno
////                    Move sEquipmentId to Trans.EquipmentID
////                    // Attachment required?
////                    If (sAttachCat <> "NONE") Begin
////                        Clear MastOps
////                        Move sAttachCat to MastOps.IsAttachment
////                        Find GE MastOps by Index.6
////                        If ((Found) and MastOps.CostType = "Attachment") Begin
////                            Get AttachmentSelection of Equipmnt_sl iEmployerIdno sAttachCat to iAttachmentIdno
////                            Get isAttachmentValid iLocIdno iAttachmentIdno (&iAttachOpersIdno) (&iAttachMastOps) (&sErrMsg) to bValid
////                            If (bValid) Begin                                            
////                                Move iAttachmentIdno to Trans.AttachEquipIdno
////                                Move iAttachOpersIdno to Trans.AttachOpersIdno
////                                Move iAttachMastOps to Trans.AttachMastOpsIdno
////                            End
////                            If (not(bValid)) Begin
////                                If (sErrMsg <> "") Begin
////                                    Send Info_Box (sErrMsg) "Attachment Error"
////                                End
////                                Move 0 to Trans.AttachEquipIdno
////                                Move 0 to Trans.AttachOpersIdno
////                                Move 0 to Trans.AttachMastOpsIdno
////                            End
////                        End
////                    End
////                    
////                    Move iOpersIdno to Opers.OpersIdno
////                    Send Request_Find of hoDD EQ Opers.File_Number 1
////                End
////                If (not(bValid)) Begin
////                    Send Stop_Box sErrMsg "Validation Error"
////                End
////                Function_Return (not(bValid))
////            End_Procedure
////
////        End_Object
////
////        Object oTrans_AttachEquipIdno is a cDbCJGridColumn
////            Entry_Item Trans.AttachEquipIdno
////            Set piWidth to 72
////            Set psCaption to "AttachEquipIdno"
////            Set pbVisible to False
////        End_Object
////
////        Object oEquipmntAttach_Description is a cDbCJGridColumn
////            //Entry_Item Equipmnt.Description
////            Set piWidth to 250
////            Set psCaption to "Equipment"
////            Set pbEditable to False
////            Set pbFocusable to False
////
////            Procedure OnSetCalculatedValue String  ByRef sValue
////                Integer iEquipIdno iAttachIdno
////                String sDescription
////                Clear Equipmnt
////                //Get Field_Current_Value of oTrans_DD Field Trans.AttachEquipIdno to iAttachIdno
////                Move Trans.AttachEquipIdno to Equipmnt.EquipIdno
////                Find EQ Equipmnt.EquipIdno
////                If ((Found) and Equipmnt.EquipIdno = Trans.AttachEquipIdno) Begin
////                    Move ("-"*Trim(Equipmnt.Description)) to sDescription
////                End
////                Clear Equipmnt
////                //Get Field_Current_Value of oTrans_DD Field Trans.EquipIdno to iEquipIdno
////                Move Trans.EquipIdno to Equipmnt.EquipIdno
////                Find EQ Equipmnt.EquipIdno
////                If ((Found) and Equipmnt.EquipIdno = Trans.EquipIdno) Begin
////                    Move (Trim(Equipmnt.Description)*sDescription) to sValue
////                End
////                Forward Send OnSetCalculatedValue (&sValue)
////            End_Procedure
////            
////            
////        End_Object
//
//        Object oTrans_EquipIdno is a cDbCJGridColumn
//            Entry_Item Trans.EquipIdno
//            Set piWidth to 79
//            Set psCaption to "Equip/Mat#"
//            Set pbDrawFooterDivider to False
//            Set Prompt_Button_Mode to PB_PromptOn
//
//            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
//                Integer iVendInvoiced
//                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
//                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
//                Case Begin
//                    Case (iVendInvoiced = 1)
//                        Set ComForeColor of hoGridItemMetrics to clRed
//                        Set pbEditable of Self to False
//                        Case Break
//                    Case (iVendInvoiced = 0)
//                        Set ComForeColor of hoGridItemMetrics to clBlack
//                        Set pbEditable of Self to True
//                        Case Break
//                Case End
//                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
//            End_Procedure
//
//            Procedure Prompt
//                Integer iEmployerIdno iEquipIdno
//                Boolean bSuccess
//                Handle hoDD
//                //
//                Get Server to hoDD
//                //
//                Get SelectedRowValue of Self to iEquipIdno
//                Move Employer.EmployerIdno to iEmployerIdno
//                Get DoEquipPromptwEmployer of Equipmnt_sl (&iEquipIdno) iEmployerIdno to bSuccess
//                If (bSuccess) Begin
//                    Set Field_Changed_Value of hoDD Field Trans.EquipIdno to iEquipIdno
//                End
//                
//            End_Procedure
//
////            Function OnExiting Returns Boolean
////                Boolean bRetVal bEquipValid bMatValid bJobChanged bEquipChanged
////                Integer iEquipIdno iAltEquipIdno iOpersIdno
////                String sErrorMsg
////                Handle hoDD
////                Get Server to hoDD
////                Get Field_Changed_State of oTrans_DD Field Trans.JobNumber to bJobChanged
////                Get Field_Changed_State of hoDD Field Trans.EquipIdno to bEquipChanged
////                
////                If (bJobChanged or bEquipChanged) Begin
////                    Get Field_Current_Value of hoDD Field Trans.EquipIdno to iEquipIdno
////                    Get IsEquipmentValid of oEquipmnt_DD Location.LocationIdno iEquipIdno (&iOpersIdno) (&iAltEquipIdno) (&sErrorMsg) to bEquipValid
////                    Get IsMaterialValid of oEquipmnt_DD Location.LocationIdno iEquipIdno (&iOpersIdno) (&iAltEquipIdno) (&sErrorMsg) to bMatValid
////                    If ((not(bEquipValid)) and (not(bMatValid))) Begin
////                       Function_Return True
////                    End
////                    Else Begin
////                        Move iOpersIdno to Opers.OpersIdno
////                        Send Request_Find of hoDD EQ Opers.File_Number 1
////                        //
////                        
////                        //
////                        Forward Get OnExiting to bRetVal
////                        Function_Return bRetVal
////                    End
////                End
////            End_Function
//            
//        End_Object
//
//        Object oEquipmnt_Description is a cDbCJGridColumn
//            Set piWidth to 140
//            Set psCaption to "Equipment"
//            Set pbEditable to False
//            Set pbAllowRemove to False
//            Set pbAllowDrag to False
//            Set pbFocusable to False
//            Set pbDrawFooterDivider to False
//
//            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
//                Integer iVendInvoiced
//                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
//                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
//                Move Trans.VendInvoicedFlag to iVendInvoiced
//                Case Begin
//                    Case (iVendInvoiced = 1)
//                        Set ComForeColor of hoGridItemMetrics to clRed
//                        Set pbEditable of Self to False
//                        Case Break
//                    Case (iVendInvoiced = 0)
//                        Set ComForeColor of hoGridItemMetrics to clBlack
//                        Set pbEditable of Self to True
//                        Case Break
//                Case End
//                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
//            End_Procedure
//
//            Procedure OnSetCalculatedValue String ByRef sValue
//                //
//                Handle hoDD
//                Boolean bEquipChanged bAttachReq bOk
//                Integer iEquipIdno iChangedEquipIdno iEmployerIdno iAttachmentIdno
//                String sAttachmentCat sError
//                //
//                Get Server to hoDD
//                //Get Field_Changed_State of hoDD Field Trans.EquipIdno to bEquipChanged
//                Get Changed_State of hoDD to bEquipChanged
//                If (bEquipChanged) Begin
//                    Get Field_Current_Value of hoDD Field Trans.EquipIdno to iEquipIdno
//                End
//                Else Begin
//                    Move Trans.EquipIdno to iEquipIdno
//                End
//                //
//                Clear Equipmnt
//                Move iEquipIdno to Equipmnt.EquipIdno
//                Find EQ Equipmnt by Index.1
//                If ((Found) and iEquipIdno = Equipmnt.EquipIdno) Begin
//                    Move (Trim(Equipmnt.Description)) to sValue
//                End             
//                Forward Send OnSetCalculatedValue (&sValue)
//            End_Procedure
//        End_Object
//
//        Object oTrans_AttachEquipIdno is a cDbCJGridColumn
//            Entry_Item Trans.AttachEquipIdno
//            Set piWidth to 72
//            Set psCaption to "AttachEquipIdno"
//            Set pbVisible to False
//        End_Object
//
//        Object oAttachment_Description is a cDbCJGridColumn
//            Set piWidth to 152
//            Set psCaption to "Attachment"
//            Set pbEditable to False
//            Set pbFocusable to False
//            Set pbAllowRemove to False
//            Set pbAllowDrag to False
//            Set pbDrawFooterDivider to False
//
//            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
//                Integer iVendInvoiced
//                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
//                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
//                Case Begin
//                    Case (iVendInvoiced = 1)
//                        Set ComForeColor of hoGridItemMetrics to clRed
//                        Set pbEditable of Self to False
//                        Case Break
//                    Case (iVendInvoiced = 0)
//                        Set ComForeColor of hoGridItemMetrics to clBlack
//                        Set pbEditable of Self to True
//                        Case Break
//                Case End
//                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
//            End_Procedure
//
////            Procedure OnSetCalculatedValue String  ByRef sValue
////                Forward Send OnSetCalculatedValue (&sValue)
////                Integer iAttachEquipIdno
////                Boolean bChanged
////                //
////                //Get  of oTrans_AttachEquipIdno to iAttachEquipIdno
////                Clear Equipmnt
////                Move iAttachEquipIdno to Equipmnt.EquipIdno
////                Find EQ Equipmnt by Index.1
////                If ((Found) and iAttachEquipIdno = Equipmnt.EquipIdno) Begin
////                    Move (Trim(Equipmnt.Description)) to sValue
////                End           
////            End_Procedure
//        End_Object
//
//        Object oMastOps_CostType is a cDbCJGridColumn
//            Entry_Item MastOps.CostType
//            Set piWidth to 162
//            Set psCaption to "CostType"
//            Set pbComboButton to True
//            Set pbEditable to False
//            Set pbFocusable to False
//        End_Object
//
//        Object oTrans_StartDate is a cDbCJGridColumn
//            Entry_Item Trans.StartDate
//            Set piWidth to 57
//            Set psCaption to "StartDate"
//            Set pbDrawFooterDivider to False
//
//            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
//                Integer iVendInvoiced
//                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
//                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
//                Case Begin
//                    Case (iVendInvoiced = 1)
//                        Set ComForeColor of hoGridItemMetrics to clRed
//                        Set pbEditable of Self to False
//                        Case Break
//                    Case (iVendInvoiced = 0)
//                        Set ComForeColor of hoGridItemMetrics to clBlack
//                        Set pbEditable of Self to True
//                        Case Break
//                Case End
//                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
//            End_Procedure
//
//            Function OnExiting Returns Boolean
//                Boolean bRetVal
//                Forward Get OnExiting to bRetVal
//                //
//                Date    dStart dToday
//                Sysdate dToday
//                // If no Start Date set, assume to use date from StartDate field.
//                If (not(HasRecord(oTrans_DD))) Begin
//                    Get Field_Current_Value of oTrans_DD Field Trans.StartDate to dStart
//                    If (dStart = "") Begin
////                      Get Value               of oTrans_StartDate                to dStart
//                        Get pdStartTrans of oTrans_DD to dStart
//                        Set Field_Changed_Value of oTrans_DD Field Trans.StartDate to dStart 
//                    End
//                End
//                Function_Return bRetVal
//            End_Function           
//            
//        End_Object
//
//        Object oTrans_StartTime is a cDbCJGridColumn
//            Entry_Item Trans.StartTime
//            Set piWidth to 64
//            Set psCaption to "StartTime"
//            Set pbDrawFooterDivider to False
//            
//            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
//                Integer iVendInvoiced
//                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
//                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
//                Case Begin
//                    Case (iVendInvoiced = 1)
//                        Set ComForeColor of hoGridItemMetrics to clRed
//                        Set pbEditable of Self to False
//                        Case Break
//                    Case (iVendInvoiced = 0)
//                        Set ComForeColor of hoGridItemMetrics to clBlack
//                        Set pbEditable of Self to True
//                        Case Break
//                Case End
//                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
//            End_Procedure
//        End_Object
//
//        Object oTrans_StopDate is a cDbCJGridColumn
//            Entry_Item Trans.StopDate
//            Set piWidth to 89
//            Set psCaption to "StopDate"
//            Set pbDrawFooterDivider to False
//            
//            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
//                Integer iVendInvoiced
//                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
//                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
//                Case Begin
//                    Case (iVendInvoiced = 1)
//                        Set ComForeColor of hoGridItemMetrics to clRed
//                        Set pbEditable of Self to False
//                        Case Break
//                    Case (iVendInvoiced = 0)
//                        Set ComForeColor of hoGridItemMetrics to clBlack
//                        Set pbEditable of Self to True
//                        Case Break
//                Case End
//                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
//            End_Procedure
//        End_Object
//
//        Object oTrans_StopTime is a cDbCJGridColumn
//            Entry_Item Trans.StopTime
//            Set piWidth to 67
//            Set psCaption to "StopTime"
//            Set psFooterText to "Total:"
//            Set pbDrawFooterDivider to False
//            
//            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
//                Integer iVendInvoiced
//                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
//                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
//                Case Begin
//                    Case (iVendInvoiced = 1)
//                        Set ComForeColor of hoGridItemMetrics to clRed
//                        Set pbEditable of Self to False
//                        Case Break
//                    Case (iVendInvoiced = 0)
//                        Set ComForeColor of hoGridItemMetrics to clBlack
//                        Set pbEditable of Self to True
//                        Case Break
//                Case End
//                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
//            End_Procedure
//        End_Object
//
//        Object oTrans_ElapsedHours is a cDbCJGridColumn
//            Entry_Item Trans.ElapsedHours
//            Set piWidth to 68
//            Set psCaption to "Hours"
//            Set pbEditable to False
//            Set pbFocusable to False
//            Set pbAllowDrag to False
//            Set pbAllowRemove to False
//            
//            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
//                Integer iVendInvoiced
//                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
//                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
//                Case Begin
//                    Case (iVendInvoiced = 1)
//                        Set ComForeColor of hoGridItemMetrics to clRed
//                        Set pbEditable of Self to False
//                        Case Break
//                    Case (iVendInvoiced = 0)
//                        Set ComForeColor of hoGridItemMetrics to clBlack
//                        Set pbEditable of Self to True
//                        Case Break
//                Case End
//                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
//            End_Procedure
//        End_Object
//
//        Object oTrans_Quantity is a cDbCJGridColumn
//            Entry_Item Trans.Quantity
//            Set piWidth to 58
//            Set psCaption to "Quantity"
//            Set pbAllowDrag to False
//            Set pbAllowRemove to False
//            
//            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
//                Integer iVendInvoiced
//                //Get Field_Current_Value of oTrans_DD Field Trans.VendInvHdrIdno to iVendInvoiced
//                Get RowValue of oTrans_VendInvoicedFlag iRow to iVendInvoiced
//                Case Begin
//                    Case (iVendInvoiced = 1)
//                        Set ComForeColor of hoGridItemMetrics to clRed
//                        Set pbEditable of Self to False
//                        Case Break
//                    Case (iVendInvoiced = 0)
//                        Set ComForeColor of hoGridItemMetrics to clBlack
//                        Set pbEditable of Self to True
//                        Case Break
//                Case End
//                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
//            End_Procedure
//        End_Object
//
//        Object oTrans_VendInvoicedFlag is a cDbCJGridColumn
//            Entry_Item Trans.VendInvoicedFlag
//            Set piWidth to 33
//            Set psCaption to "Vend"
//            Set pbCheckbox to True
//            Set pbVisible to False
//        End_Object
//
//        Object oTrans_Comment is a cDbCJGridColumn
//            Entry_Item Trans.Comment
//            Set piWidth to 101
//            Set psCaption to "Comment"
//        End_Object
//
//        Object oTrans_VendInvoicedFlag1 is a cDbCJGridColumn
//            Entry_Item Trans.VendInvoicedFlag
//            Set pbCheckbox to True
//            Set piWidth to 18
//            Set psCaption to "VendInvoicedFlag"
//        End_Object
//
//
//
//        Function IsEquipmentValid Integer iLocationIdno Integer iEquipIdno Integer ByRef iOpersIdno String ByRef sErrorMsg Returns Boolean
//            Boolean bValid
//            Clear Equipmnt MastOps Opers
//            Move iEquipIdno to Equipmnt.EquipIdno
//            Find eq Equipmnt.EquipIdno
//            If ((Found) and Equipmnt.EquipIdno = iEquipIdno) Begin
//                If (Equipmnt.Status = "A") Begin
//                    Set piEquipIdno   to Equipmnt.EquipIdno
//                    Set psEquipmentID to Equipmnt.EquipmentID
//                    Relate Equipmnt
//                    If (MastOps.Recnum <> 0) Begin
//                        Move iLocationIdno       to Opers.LocationIdno 
//                        Move MastOps.MastOpsIdno to Opers.MastOpsIdno  /// code to check Mastop# present in location opers records
//                        Find eq Opers by Index.4
//                            If (Found) Begin
//                            Move Opers.OpersIdno to iOpersIdno
//                            Function_Return (iOpersIdno<>0)
//                        End
//                        Else Begin
//                            Move "Equipment category not allowed at location" to sErrorMsg
//                            Function_Return (False)
//                        End
//                    End                    
//                End
//                Else Begin
//                    Move "Equipment is Inactive" to sErrorMsg
//                    Function_Return (False)
//                End
//            End
//            Else Begin
//                Move "Equipment# not found - try again or use lookup function" to sErrorMsg
//                Function_Return (False)
//            End
//            
//        End_Function
//
//        Function isAttachmentValid Integer iLocationIdno Integer iAttachIdno Integer ByRef iAttachOpersIdno Integer ByRef iAttachMastOps String ByRef sErrorMsg Returns Boolean
//            Clear Equipmnt MastOps Opers
//            If (iAttachIdno <> 0) Begin
//                Move iAttachIdno to Equipmnt.EquipIdno
//                Find eq Equipmnt.EquipIdno
//                If ((Found) and Equipmnt.Status = "A") Begin
//                    Relate Equipmnt
//                    If (MastOps.Recnum <> 0 and MastOps.CostType = "Attachment") Begin
//                        Move iLocationIdno       to Opers.LocationIdno
//                        Move MastOps.MastOpsIdno to Opers.MastOpsIdno
//                        Find eq Opers by Index.4
//                        If (Found) Begin
//                            Move Opers.OpersIdno to iAttachOpersIdno
//                            Move Opers.MastOpsIdno to iAttachMastOps
//                            Function_Return (Found)
//                        End
//                        Else Begin
//                            Move "Attachment category not allowed at location" to sErrorMsg
//                            Function_Return False
//                        End
//                    End
//                    Else Begin
//                        Move "Item not a Attachment code" to sErrorMsg
//                        Function_Return False
//                    End
//                End
//                Else Begin
//                    Move "Attachment not found" to sErrorMsg
//                    Function_Return False
//                End
//            End
//            //No Attachment was selected
//            Move "" to sErrorMsg
//            Function_Return True
//        End_Function
//
//        Function OnPostEntering Returns Boolean
//            Boolean bRetVal            
//            Send Stop_Box "No employee selected"
//            Function_Return True
//        End_Function
//
//        Procedure OnEntering
//            Forward Send OnEntering
//            Boolean bFail
//            //Check if there is an employee
//            Move (not(HasRecord(oEmployee_DD))) to bFail
//            If (bFail) Begin
//                Set pbNeedPostEntering to True
//            End
//            
//        End_Procedure
//        
//        Procedure RefreshFooterTotals
//            // Count all
//            Set pnHoursTotal to 0
//            Number nTotalHours nBulkTotal nBagTotal nGalTotal
//            String sTotalHours sBulkTotal sBagTotal sGalTotal
//            Integer iEmployeeIdno
//            Date dTransStartDate dTransStopDate
//            //
//            Get piEmployeeIdno to iEmployeeIdno
//            Get pdStartTrans to dTransStartDate
//            Get pdStopTrans to dTransStopDate
//            If (dTransStopDate="") Begin
//                Move dTransStartDate to dTransStopDate
//            End
//            //
//            Constraint_Set 1
//            Constrain Trans.EmployeeIdno eq iEmployeeIdno
//            Constrain Trans.StartDate Between dTransStartDate and dTransStopDate
//            Constrained_Find First Trans by 3
//            While (Found)
//                Relate Trans
//                If (MastOps.CostType <> "Material") Begin
//                    Add Trans.ElapsedHours to nTotalHours
//                End
//                If (MastOps.CostType = "Material") Begin
//                    Case Begin
//                        Case (MastOps.CalcBasis = "Pounds")
//                            Add (Trans.Quantity/2000) to nBulkTotal
//                            Case Break
//                        Case (MastOps.CalcBasis = "Units")
//                            Add (Trans.Quantity) to nBagTotal
//                            Case Break
//                        Case (MastOps.CalcBasis = "Gallon")
//                            Add Trans.Quantity to nGalTotal
//                            Case Break
//                    Case End
//                End
//                //
//                Constrained_Find Next
//            Loop
//            Constraint_Set 1 Delete
////            
////            Clear Trans
////            Move iEmployeeIdno to Trans.EmployeeIdno
////            Move dTransStartDate to Trans.StartDate
////            Find GE Trans by 3
////            While ((Found) and Trans.EmployeeIdno = iEmployeeIdno and Trans.StartDate >= dTransStartDate and Trans.StartDate <= dTransStopDate)
////                
////                Find GT Trans by 3
////            Loop
//            //Hours
//            Move (String(nTotalHours)+ "(h)") to sTotalHours
//            Set psFooterText of oTrans_ElapsedHours to sTotalHours
//            // Material
//            Move (String(nBulkTotal)+"(ton)") to sBulkTotal
//            Move (String(nBagTotal)+"(bags)") to sBagTotal
//            Move (String(nGalTotal)+"(gal)") to sGalTotal
//            
//            Set psFooterText of oTrans_Quantity to (If(nBulkTotal<>0,sBulkTotal,"")+;
//                                                    If(nBagTotal<>0, ("|"+sBagTotal),"") +;
//                                                    If(nGalTotal<>0, ("|"+sGalTotal),""))
//        End_Procedure
//        
//        Procedure OnComFocusChanging Variant llNewRow Variant llNewColumn Variant llNewItem Boolean  ByRef llCancel
//            Forward Send OnComFocusChanging llNewRow llNewColumn llNewItem (&llCancel)
//            // If Labor, Enable StopDate and Time, Disable Quantity columnt
//            // If Material, Disable StopDate and Time and make them the same as StartDate and Time
//            String sCostType
//            Get SelectedRowValue of oMastOps_CostType to sCostType
//            //Set pbEditable of oTrans_StopDate to (sCostType<>'Material')
//            Set pbFocusable of oTrans_StopDate to (sCostType<>'Material')
//            //Set pbEditable of oTrans_StopTime to (sCostType<>'Material')
//            Set pbFocusable of oTrans_StopTime to (sCostType<>'Material')
//            //ToDo: When sCostType is Material, change stopDate and time to match start date and time
//            //ToDo: When sCostType changes from Material/PerTime to Labor/Equipment, set qty to 0
//            Set pbEditable of oTrans_Quantity to (sCostType='Material' or sCostType='PerTime')
//            Set pbFocusable of oTrans_Quantity to (sCostType='Material' or sCostType='PerTime')
//            //
//        End_Procedure
//
//        Procedure OnSetFocus
//            Forward Send OnSetFocus
//            Send RefreshFooterTotals of oTransCJDBGrid
//        End_Procedure
//
//    End_Object

    Procedure Close_Panel
        Boolean bClosePanel
//        Move ((pbPrevOvelap(Self)=0 or pbNextOverlap(Self)=0)) to bClosePanel
//        If (not(bClosePanel)) Begin
//            Send Stop_Box "There are Transactions with overlapping times. Look for the RED start or stop time!" "Overlapping Transaction"
//        End
//        Else Begin
            Send Clear_All of oTrans_DD
            Set piOrder    of oTrans_DD to 0
            Forward Send Close_Panel
//        End
    End_Procedure

    Procedure Activate_View
        If (giUserRights GE 55) Begin
            Forward Send Activate_View
        End
        Else Begin
            Send Info_Box "You have no permission to open this view!"
        End        
    End_Procedure

    Procedure Destroy_Object
        Forward Send Destroy_Object
    End_Procedure


//    Procedure OnPostSave
//        Boolean bChanged
//        String sAttachmentCat sStartTime
//        Date dStartDate
//        Integer iEmployerIdno iMastOpsIdno iAttachmentIdno iTransIdno iJobNumber 
//        
//        #IFDEF TEMPUS
//        Move (Trim(Equipmnt.AttachmentCategory)) to sAttachmentCat
//        Move (Trim(Equipmnt.OperatedBy)) to iEmployerIdno
//        If (sAttachmentCat <> "NONE") Begin
//            Clear MastOps
//            Move sAttachmentCat to MastOps.IsAttachment
//            Find GE MastOps by Index.6
//            If ((Found) and MastOps.CostType = "Attachment") Begin
//                Move MastOps.MastOpsIdno to iMastOpsIdno
//                Move Trans.TransIdno to iTransIdno
//                
//    //        tDataSourceRow[] tAttachmentList      
//    //        Get BuildAttachmentSelectionList of oTransAttachment Equipmnt.AttachmentCategory Equipmnt.OperatedBy (&tAttachmentList) to bWorked
//    //        Get SelectAttachment of oAttachment tAttachmentList to iAttachmentIdno
//                
//                Get AttachmentSelection of Equipmnt_sl iEmployerIdno iMastOpsIdno to iAttachmentIdno
//                
//                If (iAttachmentIdno <> 0 and iTransIdno <> 0) Begin
//                    Relate Trans
//                    //Send DoCreateAttachmentTransaction iJobNumber iAttachmentIdno dStartDate sSartTime iTransIdno
//
//                    //Create new record and manipulate
//                    Reread System
//                        Increment System.LastTrans
//                        SaveRecord System
//                    Unlock
//                    Reread Trans
//                        NewRecord Trans
//                        Move System.LastTrans to Trans.TransIdno
//                        //Move iTransIdno to Trans.TransReference
//                        Move iAttachmentIdno to Trans.EquipIdno
//                        Move Trans.StartTime to Trans.StopTime
//                        Move 0 to Trans.ElapsedHours
//                        Save Trans
//                    Unlock               
//                End
//            End            
//        End
//        //
//        Send Refresh
//        
//        #ELSE
//        #ENDIF
//    End_Procedure

End_Object

