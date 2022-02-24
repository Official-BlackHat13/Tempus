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
//Use cGlblDbGrid.pkg
Use cTempusDbView.pkg
Use cGlblDbForm.pkg

Use Equipmnt.sl

Use TransAttachment.bp
Use TransactionCopyProcess.bp
Use Attachment.sl
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use Windows.pkg
Use TransactionsByEmployeeReport.rv


Activate_View Activate_oTransactionEntry for oTransactionEntry
Object oTransactionEntry is a cTempusDbView

    Property Integer piEmployeeIdno
    Property Integer piEquipIdno
    Property String  psEquipmentID
    Property Integer piOrder
    Property Date    pdStartTrans
    Property Date    pdStopTrans
    Property Number  pnHoursTotal

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
            String  sEquipmentID
            //
            Forward Send Creating
            //
            Get piEquipIdno   to iEquipIdno
            Get psEquipmentID to sEquipmentID
            Move iEquipIdno   to Trans.EquipIdno
            Move sEquipmentID to Trans.EquipmentID
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
    End_Object

    Set Main_DD to oEmployee_DD
    Set Server to oEmployee_DD

    Set Border_Style to Border_Thick
    Set Size to 250 650
    Set Location to 3 5
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
                Boolean bEmployeeSelected bHasStartDate bHasStopDate bICEmployer bHasSysAdminRights bIsZach
                Date dStartDate dStopDate
                Move (Employee.EmployeeIdno<>0) to bEmployeeSelected
                Get Value of oTrans_StartDate to dStartDate
                Get Value of oTrans_StopDate to dStopDate
                Move (dStartDate<>0) to bHasStartDate
                Move (dStopDate<>0) to bHasStopDate
                Move (Employee.EmployerIdno = 101) to bICEmployer
                Move (giUserRights>=90) to bHasSysAdminRights
                Move (gsUsername="zach.larson") to bIsZach
                Set Visible_State of oCopyToButton to (bHasSysAdminRights or bIsZach)
//                Set pbVisible of oTrans_Comment to (bHasSysAdminRights)
                Set Enabled_State of oCopyToButton to ((bHasSysAdminRights or bIsZach))
                Set Enabled_State of oPrintTransButton to (bEmployeeSelected and bHasStartDate)
                Set piEmployeeIdno to Employee.EmployeeIdno
            End_Procedure

            Procedure OnExitObject
                Forward Send OnExitObject
//                Send MoveToFirstRow of oTransCJDBGrid
//                Send RefreshFooterTotals of oTransCJDBGrid
            End_Procedure

            
        End_Object

        Object oEmployee_LastName is a dbForm
            Entry_Item Employee.LastName
            Set Location to 5 87
            Set Size to 13 120
            Set Enabled_State to False
            Set Prompt_Button_Mode to PB_PromptOff
        End_Object

        Object oTrans_StartDate is a Form
            Set Location to 22 40
            Set Size to 13 60
            Set Label to "Start Date:"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
            Set Form_Datatype to Mask_Date_Window
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt

//            Procedure OnExitObject
//                Forward Send OnExitObject
//                Date dStartTrans 
//                Integer iDateDifference iEmployeeIdno 
//                
//                Get Value to dStartTrans
//                Set pdStartTrans              of oTrans_DD to dStartTrans
//                Send Rebuild_Constraints of oTrans_DD
//                If (piEmployeeIdno(Self)<>0 and dStartTrans<>"0") Begin
//                    Send MoveToFirstRow of oTransCJDBGrid
//                    Send RefreshFooterTotals of oTransCJDBGrid
//                End
//            End_Procedure

            Procedure OnChange
                Forward Send OnChange
                //
                Date dStartTrans 
                Integer iDateDifference iEmployeeIdno 
                
                Get Value to dStartTrans
                Set pdStartTrans              of oTrans_DD to dStartTrans
                Send Rebuild_Constraints of oTrans_DD
                If (piEmployeeIdno(Self)<>0 and dStartTrans<>"0") Begin
//                    Send MoveToFirstRow of oTransCJDBGrid
//                    Send RefreshFooterTotals of oTransCJDBGrid
                    Send Beginning_of_Data of oTransactionGrid
                End
                
            End_Procedure

        End_Object

        Object oTrans_StopDate is a Form
            Set Location to 22 111
            Set Size to 13 60
            Set Label to "-"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
            Set Form_Datatype to Mask_Date_Window
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt

            Procedure OnChange
                Forward Send OnChange
                Date dStopTrans
                //
                Get Value to dStopTrans
                Set pdStopTrans              of oTrans_DD to dStopTrans
                Send Rebuild_Constraints of oTrans_DD
                If (piEmployeeIdno(Self)<>0 and dStopTrans<>"0") Begin
//                    Send MoveToFirstRow of oTransCJDBGrid
//                    Send RefreshFooterTotals of oTransCJDBGrid
                    Send Beginning_of_Data of oTransactionGrid
                End
            End_Procedure
        End_Object

        Object oEmployee_FirstName is a cGlblDbForm
            Entry_Item Employee.FirstName
            Set Location to 5 216
            Set Size to 13 89
            Set Enabled_State to False
        End_Object

        Object oEmployer_Name is a cGlblDbForm
            Entry_Item Employer.Name
            Set Location to 5 309
            Set Size to 13 122
            Set Enabled_State to False
            Set Prompt_Button_Mode to PB_PromptOff
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
                Get Value of oTrans_StartDate to dStartDate
                Get Value of oTrans_StopDate to dStopDate
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
                Get Value of oTrans_StartDate to dStartDate
                Get Value of oTrans_StopDate to dStopDate
                If (dStopDate = "") Begin
                    Move dStartDate to dStopDate
                End
                If (iEmplIdno <> 0 and dStartDate <> "" and dStartDate <> "") Begin
                    Send DoJumpStartReport of oTransactionsByEmployeeReportView iEmplIdno dStartDate dStopDate
                End
            End_Procedure
        
        End_Object
    End_Object

    Object oTransactionGrid is a DbGrid
        Set Server to oTrans_DD
        Set Size to 191 639
        Set Location to 51 6
        Set Main_File to Trans.File_number
        Set Child_Table_State to True
        Set peGridLineColor to 14211288
        Set Wrap_State to True
        Set Ordering to 3
        Set peAnchors to anAll


//        // Changes the color of all items in the current row to RGB color 'iColor'
//        // This should be sent from Entry_Display as shown later...
//        Procedure Change_Row_Text_Color Integer iColor
//            Integer iBase iItem iItems
//         
//            Get Base_Item to iBase               // first item of current row
//            Get Item_Limit  to iItems              // items per row
//            Move (iBase+iItems-1) to iItems     // last item in the current row
//         
//            For iItem from iBase to iItems         // set all items in row to color 
//                Set ItemTextColor iItem to iColor
//                Set Item_Shadow_State iItem to (iColor = clRed)
//            Loop
//        End_Procedure // Change_Row_Color
//         
//        // Augmented in order to get the row, and possibly cell, highlighted
//        // with a specific color depending on its file-buffer values
//        Procedure Entry_Display Integer iFile Integer iType
//            Integer iColor iItem
//         
//            // set current row color based on value of extended price
//            If (Trans.VendInvoicedFlag <> 0) Begin
//                Move clRed to iColor
//            End
//            Else Begin
//                Move clBlack to iColor
//            End
//            Send Change_Row_Text_Color iColor
//            
////            // Set single cell (column 5) based on contents of qty_ordered
////            If OrderDtl.Qty_Ordered ge 10 Begin
////                Get Base_Item to iItem // first item of the current row
////                Set ItemColor (iItem+4) to clPurple // Fifth column
////            End    
//         
//            Forward Send Entry_Display iFile iType
//        End_Procedure // Entry_Display

        //Ben -Inserted on 06/18/2012 - Conversion to Dec.Hours

        Function MinInHours Returns Number
            Number nNumber
            Move Trans.ElapsedMinutes to nNumber
            Calc (nNumber/60.00) to nNumber
            Function_Return nNumber
        End_Function
        
        Function EquipmentName Integer iEquipIdno Returns String
            String sEquipName
            Boolean bChanged
            Get Changed_State of oTrans_DD to bChanged
            If (bChanged) Get Field_Current_Value of oTrans_DD Field Trans.EquipIdno to iEquipIdno 
            //
            Open Equipmnt
            Clear Equipmnt
            Move iEquipIdno to Equipmnt.EquipIdno
            Find EQ Equipmnt by Index.1
            If (Found) Begin
                Move (Trim(Equipmnt.Description)) to sEquipName
            End
            Else Begin
                Move (Trim(Opers.Name)) to sEquipName
            End
            Function_Return sEquipName
        End_Function
        
        Function AttachmentName Integer iAttachEquipIdno Returns String
            String sAttchName
            Boolean bChanged
            Get Changed_State of oTrans_DD to bChanged
            If (bChanged) Get Field_Current_Value of oTrans_DD Field Trans.AttachEquipIdno to iAttachEquipIdno 
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
        
        Begin_Row
            Entry_Item Trans.TransIdno
            Entry_Item Order.JobNumber
            Entry_Item Location.Name
            Entry_Item Trans.EquipIdno
            //Entry_Item Opers.OpersIdno
            Entry_Item (EquipmentName(Self,Trans.EquipIdno))
            Entry_Item (AttachmentName(Self,Trans.AttachEquipIdno))
            Entry_Item Trans.StartDate
            Entry_Item Trans.StartTime
            Entry_Item Trans.StopDate
            Entry_Item Trans.StopTime
            Entry_Item Trans.ElapsedHours
            //Entry_Item (MinInHours(Self))
            Entry_Item Trans.Quantity
        End_Row
        
        Set Header_Label 0 to "Idno"
        Set Column_Shadow_State 0 to True
        Set Form_Width 0 to 1

        Set Form_Width 1 to 40
        Set Header_Label 1 to "Job#"
        Set Form_Button_Value 1 to "..."
        Set Form_Button 1 to Form_Button_Prompt

        Set Form_Width 2 to 100
        Set Header_Label 2 to "Location"
        Set Column_Shadow_State 2 to True

        Set Form_Width 3 to 40
        Set Header_Label 3 to "Eq/Mat ID"
        Set Header_Justification_Mode 3 to JMode_Right
        Set Column_Button 3 to Form_Button_Prompt
        Set Form_Button_Value 3 to "..."

        Set Form_Width 4 to 100
        Set Header_Label 4 to "Equipment"
        Set Form_Button_Value 4 to "..."
        Set Form_Button 4 to Form_Button_Prompt

        Set Form_Width 7 to 40
        Set Header_Label 7 to "Start Time"
        
        Set Form_Width 8 to 50
        Set Header_Label 8 to "Stop Date"
        

        Set Form_Width 9 to 40
        Set Header_Label 9 to "Stop Time"
             
        Set Form_Width 10 to 40
        Set Header_Label 10 to "Hours"
        Set Header_Justification_Mode 10 to JMode_Right
        Set Column_Shadow_State 10 to True
        Set Form_Datatype 10 to Mask_Numeric_Window
        Set Form_Mask 10 to "#0.00"
        Set Form_Justification_Mode 10 to Form_DisplayRight
        
        Set Form_Width 11 to 40
        Set Header_Label 11 to "Quantity"
        Set Header_Justification_Mode 11 to JMode_Right
        Set Header_Label 5 to "Attachment"
        Set Form_Width 5 to 100
        Set Form_Width 6 to 50
        Set Header_Label 6 to "StartDate"
        Set Highlight_Row_State to False
        

        Function Row_Save Returns Integer
            Integer iRetval
            Date    dStart dToday
            Sysdate dToday
            //
            If (not(HasRecord(oTrans_DD))) Begin
                Get Field_Current_Value of oTrans_DD Field Trans.StartDate to dStart
                If (dStart = "") Begin
                    Get Value               of oTrans_StartDate                to dStart
                    Set Field_Changed_Value of oTrans_DD Field Trans.StartDate to dStart 
                End
            End
            //
//            Get Field_Current_Value of oTrans_DD Field Trans.StartDate to dStart
//            If (dToday - dStart > 14) Begin
//                If (giUserRights >= 70 or giUserRights = 65) Begin
//                    // Opers Temp, Administrative and higher are permitted to make changes
//                    Forward Get Row_Save to iRetval
//                End
//                Else Begin
//                    Send Stop_Box "You can not add or edit a Transaction that is older than 14 days."
//                    Function_Return 1 //Validation failed   
//                End
//            End
            //
            Forward Get Row_Save to iRetval
            //
            Function_Return iRetval
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
        
        Procedure Item_Change Integer iFrItem Integer iToItem Returns Integer
            Boolean bIsEquipmnt bIsMaterial bAttachment bAttachReq bHasChanged bOk 
            Boolean bEquipHasChanged bOpersHasChanged bJobHasChanged bLocHasChanged
            Integer hoDD iRetval iCol iCols iToCol iBaseItem
            Integer iIsIdno iLocIdno iJobNumber iEquipIdno iOpersIdno iMastOpsIdno iEmployerIdno 
            Integer iAttachmentIdno iAttachOpersIdno iAttachMastOps
            String[][] sAttachArray
            String sAttachmentCat sErrorMsg
            //
            Get Server                to hoDD
            Get Base_Item             to iBaseItem
            Get Current_Col           to iCol
            Move 9                    to iCols
            //Move 10                   to iCols
            Move (mod(iToItem,iCols)) to iToCol
            //
           
            
            //
//            If (iCol = 1) Begin
//                //Get Value item iFrItem  to 
//                Get Field_Changed_State of hoDD Field Trans.JobNumber to bJobHasChanged
//                Get Field_Changed_State of hoDD Field Trans.LocationIdno to bLocHasChanged
//                If (bJobHasChanged) Begin
//                    
//                End
//            End
            
            
            If (iCol = 3) Begin
                Send Refind_Records of hoDD
                Move Trans.EmployerIdno                  to iEmployerIdno
                Move Trans.MastOpsIdno                   to iMastOpsIdno
                Move Trans.JobNumber                     to iJobNumber
                Move Location.LocationIdno               to iLocIdno
                Move Opers.OpersIdno                     to iIsIdno 
                Get Value item iFrItem                   to iEquipIdno
                Move iEquipIdno to Equipmnt.EquipIdno
                Find EQ Equipmnt by Index.1
                If (Found) Begin
                    Get IsEquipmentValid iLocIdno iEquipIdno to iOpersIdno
                    If (iIsIdno <> iOpersIdno) Begin
                        Move iOpersIdno to Opers.OpersIdno
                        Send Request_Find of hoDD EQ Opers.File_Number 1
                        // Sign for Operation might have changed
                    End
                    If (iOpersIdno<>0) Begin
                                                
                        //Obviously Equipment was changed
                        Get Field_Changed_State of hoDD Field Trans.EquipIdno to bEquipHasChanged
                        Get Field_Changed_State of hoDD Field Trans.OpersIdno to bOpersHasChanged
                        If (bEquipHasChanged) Begin
                            Move iEquipIdno to Equipmnt.EquipIdno
                            Find EQ Equipmnt by Index.1
                            If ((Found) and Equipmnt.EquipIdno = iEquipIdno) Begin
                                Move (MastOps.NeedsAttachment <> "NONE") to bAttachReq 
                                Move Equipmnt.OperatedBy to iEmployerIdno
                                If (bEquipHasChanged and bAttachReq) Begin
                                    
                                    //Move (Trim(Equipmnt.AttachmentCategory)) to sAttachmentCat
                                    Move MastOps.NeedsAttachment to sAttachmentCat
//                                    Get BuildAttachmentSelectionList of oTransAttachment sAttachmentCat iEmployerIdno (&sAttachArray) to bOk
//                                    If (bOk) Begin
//                                        Get AttachSelection of oAttachment sAttachArray to iAttachmentIdno
//                                        Move iAttachmentIdno to iAttachmentIdno
//                                    End
                                    Clear MastOps
                                    Move sAttachmentCat to MastOps.IsAttachment
                                    Find GE MastOps by Index.6
                                    If ((Found) and MastOps.CostType = "Attachment") Begin
                                        Get AttachmentSelection of Equipmnt_sl iEmployerIdno sAttachmentCat to iAttachmentIdno
                                        Get isAttachmentValid iLocIdno iAttachmentIdno (&iAttachOpersIdno) (&iAttachMastOps) (&sErrorMsg) to bOk
                                        If (bOk) Begin                                            
                                            Set Field_Changed_Value of hoDD Field Trans.AttachEquipIdno to iAttachmentIdno
                                            Set Field_Changed_Value of hoDD Field Trans.AttachOpersIdno to iAttachOpersIdno
                                            Set Field_Changed_Value of hoDD Field Trans.AttachMastOpsIdno to iAttachMastOps
                                        End
                                        If (not(bOk)) Begin
                                            If (sErrorMsg <> "") Begin
                                                Send Info_Box (sErrorMsg) "Attachment Error"
                                            End
                                            Set Field_Changed_Value of hoDD Field Trans.AttachEquipIdno to 0
                                            Set Field_Changed_Value of hoDD Field Trans.AttachOpersIdno to 0
                                            Set Field_Changed_Value of hoDD Field Trans.AttachMastOpsIdno to 0
                                        End
                                    End
                                End
                                Else Begin
                                    Set Field_Changed_Value of hoDD Field Trans.AttachEquipIdno to 0
                                    Set Field_Changed_Value of hoDD Field Trans.AttachOpersIdno to 0
                                    Set Field_Changed_Value of hoDD Field Trans.AttachMastOpsIdno to 0
                                End
                            End    
                        End
                        ///////////////////////////////////////////
                    End
                End

            End
            //
            Forward Get msg_Item_Change iFrItem iToItem to iRetval
            //
            If (iToItem = iFrItem) Begin
                Procedure_Return
            End
            //
            //Adjust the jump to the correct column
            If (iCol = 3) Begin
                Send Refind_Records of hoDD
                Move (MastOps.CostType = "Material") to bIsMaterial 
                Move (MastOps.CostType = "Equipment") to bIsEquipmnt
                
//                If (iToCol = 6 and bIsMaterial) Begin
//                    Move (iRetval + 3) to iRetval
//                End                
            End
            //
            If (iCol = 1) Begin
                Set piOrder of hoDD to (Current_Record(oOrder_DD))
            End
            //
            Procedure_Return iRetval
        End_Procedure

        Function Child_Exiting Integer toObj# Returns Integer
            Boolean bState
            //
            Get Changed_State of oTrans_DD to bState
            If (Should_Save(Self) and not(bState)) Begin
                Send Request_Clear
            End
//            Integer iCol
//            //
//            Get Current_Col to iCol
        End_Function

        // Assign insert-row key append a row
        // Create new behavior to support append a row
        On_Key kAdd_Mode Send Append_a_Row  // Hot Key for KAdd_Mode = Shift+F10

        // Add new record to the end of the table.
        Procedure Append_a_Row 
            Send End_Of_Data
            Send Down
        End_Procedure // Append_a_Row

        Procedure Close_Panel
            Boolean bState
            //
//            Get Changed_State of oTrans_DD to bState
//            If (Should_Save(Self) and not(bState)) Begin
//                Send Request_Clear
//            End
            Send Clear_All of oTrans_DD
            Set piOrder    of oTrans_DD to 0
            //
            Forward Send Close_Panel
        End_Procedure

//        Function Child_Entering Returns Integer
//            //
//            Function_Return bFail // if non-zero do not enter
//        End_Function // Child_Entering

        Function Child_Entering Returns Integer
            Integer iRetVal
            Forward Get Child_Entering to iRetVal
            

            Boolean bFail
            Date    dToday dStart
            //
            // Check there is an employee
            Move (not(HasRecord(oEmployee_DD))) to bFail
            If (bFail) Begin
                Send Stop_Box "No employee selected"
                Function_Return 1
            End
            If (not(bFail)) Begin
                Sysdate dToday
                Get Value of oTrans_StartDate        to dStart
                Move (dStart = 0 or dStart > dToday) to bFail
                If (bFail) Begin
                    Send Stop_Box "Invalid Start Date"
                    Function_Return 1
                End
                Else Begin
                    Integer iDateDifference
                    Move (dToday - dStart) to iDateDifference
                    If (iDateDifference > 14) Begin
//                        If (giUserRights >= 70 or giUserRights = 65) Begin
//                            // Administrative and higher are permitted to make these changes but are suggested to refrain
                            Send Info_Box "Making changes to Transactions that are older than 14 days will affect invoicing and job costing."
                            Function_Return 0
//                        End
//                        Send Stop_Box "You have no permission to make changes to transactions that are older than 14 days. Please contact Debbie Johnson."
//                        Function_Return 1
                    End
                    Function_Return 0
                End
            End            
            Function_Return iRetVal
        End_Function
        
        Procedure Prompt
            Integer iCol iEquipIdno iEmployerIdno
            Boolean bSuccess
            Get Current_Col           to iCol
            If (iCol = 1) Begin
                Forward Send Prompt
            End
            If (iCol = 3) Begin
                Get Value to iEquipIdno
                Move Employer.EmployerIdno to iEmployerIdno
                Get DoEquipPromptwEmployer of Equipmnt_sl (&iEquipIdno) iEmployerIdno to bSuccess
                If (bSuccess) Begin
                    Set Field_Changed_Value of oTrans_DD Field Trans.EquipIdno to iEquipIdno
                End
                
            End
        End_Procedure

    End_Object

//    Object oTransCJDBGrid is a cDbCJGrid
//        Set Server to oTrans_DD
//        Set Size to 196 635
//        Set Location to 49 8
//        Set pbShowRowFocus to True
//        Set pbUseFocusCellRectangle to False
//        Set pbShowFooter to True
//        Set piSelectedRowBackColor to clLtGray
//        Set piHighlightBackColor to clLtGray
//        Set piHighlightForeColor to clLtGray
//        Set piSelectedRowForeColor to clLtGray
//        Set peAnchors to anAll
//        Set pbEditOnClick to True
//        Set pbEditOnKeyNavigation to True
//
//        Object oTrans_JobNumber is a cDbCJGridColumn
//            Entry_Item Order.JobNumber
//            Set piWidth to 45
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
//            Set piWidth to 179
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
//        Object oTrans_EquipIdno is a cDbCJGridColumn
//            Entry_Item Trans.EquipIdno
//            Set piWidth to 81
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
//            Set piWidth to 142
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
//            Procedure OnSetCalculatedValue String  ByRef sValue
//                Forward Send OnSetCalculatedValue (&sValue)
//                
//                Boolean bChanged bAttachReq bOk
//                Integer iEquipIdno iEmployerIdno iAttachmentIdno
//                String sAttachmentCat sError
//                Move Trans.EquipIdno to iEquipIdno
//                Get Changed_State of oTrans_DD to bChanged
//                If (bChanged) Begin
//                    Get Field_Current_Value of oTrans_DD Field Trans.EquipIdno to iEquipIdno
//                End
//                //
//                Open Equipmnt
//                Clear Equipmnt
//                Move iEquipIdno to Equipmnt.EquipIdno
//                Find EQ Equipmnt by Index.1
//                If ((Found) and iEquipIdno = Equipmnt.EquipIdno) Begin
//                    Move (Trim(Equipmnt.Description)) to sValue
//                End             
//            End_Procedure
//        End_Object
//
//        Object oAttachment_Description is a cDbCJGridColumn
//            Set piWidth to 154
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
//            Procedure OnSetCalculatedValue String  ByRef sValue
//                Forward Send OnSetCalculatedValue (&sValue)
//                Integer iAttachEquipIdno
//                Boolean bChanged
//                Move Trans.AttachEquipIdno to iAttachEquipIdno
//                Get Changed_State of oTrans_DD to bChanged
//                If (bChanged) Get Field_Current_Value of oTrans_DD Field Trans.AttachEquipIdno to iAttachEquipIdno
//                //
//                Open Equipmnt
//                Clear Equipmnt
//                Move iAttachEquipIdno to Equipmnt.EquipIdno
//                Find EQ Equipmnt by Index.1
//                If (Found) Begin
//                    Move (Trim(Equipmnt.Description)) to sValue
//                End           
//            End_Procedure
//        End_Object
//
//        Object oTrans_StartDate is a cDbCJGridColumn
//            Entry_Item Trans.StartDate
//            Set piWidth to 58
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
//            Set piWidth to 65
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
//            Set piWidth to 90
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
//            Set piWidth to 68
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
//            Set piWidth to 69
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
//            Set piWidth to 59
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
//        Procedure OnRowChanged Integer iOldRow Integer iNewSelectedRow
//            //Forward Send OnRowChanged iOldRow iNewSelectedRow
//            Send RefreshFooterTotals of oTransCJDBGrid
//        End_Procedure
//        
//
//
//    End_Object

    Procedure Close_Panel
        Boolean bState bCancel
        //
        Send Clear_All of oTrans_DD
        Set piOrder    of oTrans_DD to 0
        //
//        Get Changed_State of oTrans_DD to bState
//        If (Should_Save(Self) and not(bState)) Begin
//            Send Request_Clear of oTransactionGrid
//        End
        //
        Forward Send Close_Panel
    End_Procedure

    Procedure Activate_View
        If (giUserRights GE 55) Begin
            Forward Send Activate_View
        End
        Else Begin
            Send Info_Box "You have no permission to open this view!"
        End        
    End_Procedure
    
    Procedure Entering_Scope
        Date dStartTrans dStopTrans
        //
        Forward Send Entering_Scope
        //
        Get pdStartTrans of oTrans_DD to dStartTrans
        Get pdStopTrans of oTrans_DD to dStopTrans
        If (dStartTrans = 0) Begin
            Sysdate dStartTrans
            Set pdStartTrans              of oTrans_DD to dStartTrans
            Set pdStopTrans                 of oTrans_DD to dStopTrans
            Send Rebuild_Constraints of oTrans_DD
            //
            Set Value of oTrans_StartDate to dStartTrans
            Set Value of oTrans_StopDate to dStopTrans
        End
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

