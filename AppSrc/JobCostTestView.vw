Use Windows.pkg
Use DFClient.pkg
Use DFTabDlg.pkg

Activate_View Activate_oJobCostTestView for oJobCostTestView
Object oJobCostTestView is a dbView
    Set Label to "New View"
    Set Size to 185 537
    Set Location to 5 7

    Object oNewTabDialog is a dbTabDialogView
        Set Size to 169 527
        Set Location to 5 5
        Set Rotate_Mode to RM_Rotate

        Object oNewTabPage1 is a dbTabView
            Set Label to "Page 1"

Use GlobalAllEnt.pkg
Use Employer.DD
Use Employee.DD
Use Customer.DD
Use Location.DD
Use Order.DD
Use Trans.DD
Use MastOps.DD
Use Opers.DD
Use Areas.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use szcalendar.pkg
//Use cGlblDbGrid.pkg
Use cTempusDbView.pkg
Use cGlblDbForm.pkg


Activate_View Activate_oTransactionEntry for oTransactionEntry
Object oTransactionEntry is a cTempusDbView

    Property Integer piEquipIdno
    Property String  psEquipmentID

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oMastops_DD is a Mastops_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oProject_DD is a cProjectDataDictionary
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set Constrain_file to Location.File_number
        Set DDO_Server to oMastops_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oEmployer_DD
    End_Object

    Object oTrans_DD is a Trans_DataDictionary
        Property Integer piOrder
        Property Date    pdTrans

        Set Constrain_file to Employee.File_number
        Set DDO_Server to oOpers_DD
        Set DDO_Server to oOrder_DD
        Set DDO_Server to oEmployee_DD

        Procedure OnConstrain
            Constrain Trans.StartDate eq (pdTrans(Self))
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
    Set Size to 278 611
    Set Location to 5 9
    Set Label to "Cost Transactions Entry/Edit"
    Set piMinSize to 250 539
    Set piMaxSize to 650 624
    Set View_Latch_State to False

    Object oEmployeeContainer is a dbContainer3d
        Set Size to 55 590
        Set Location to 10 10
        Set peAnchors to anTopLeftRight

        Object oEmployee_EmployeeIdno is a dbForm
            Entry_Item Employee.EmployeeIdno
            Set Location to 10 51
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
        End_Object

        Object oEmployee_LastName is a dbForm
            Entry_Item Employee.LastName
            Set Location to 10 98
            Set Size to 13 120
            Set Enabled_State to False
            Set Prompt_Button_Mode to PB_PromptOff
        End_Object

        Object oTrans_StartDate is a cszDatePicker
            Set Location to 27 51
            Set Size to 13 60
            Set Label to "Start Date:"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right

            Procedure OnChange
                Date dTrans
                //
                Get Value to dTrans
                If (dTrans <> 0) Begin
                    Set pdTrans              of oTrans_DD to dTrans
                    Send Rebuild_Constraints of oTrans_DD
                    Send Beginning_of_Data   of oTransactionGrid
                End
            End_Procedure
        End_Object

        Object oEmployee_FirstName is a cGlblDbForm
            Entry_Item Employee.FirstName
            Set Location to 10 227
            Set Size to 13 89
            Set Enabled_State to False
        End_Object
    End_Object

    Object oTransactionGrid is a DbGrid
        Set Server to oTrans_DD
        Set Size to 192 590
        Set Location to 74 10
        Set Main_File to Trans.File_number
        Set Child_Table_State to True
        Set peGridLineColor to 14211288
        Set Wrap_State to True
        Set Ordering to 3
        Set peAnchors to anAll

        Begin_Row
            Entry_Item Trans.TransIdno
            Entry_Item Order.JobNumber
            Entry_Item Location.Name
            Entry_Item Trans.EquipIdno
            Entry_Item Opers.OpersIdno
            Entry_Item Opers.Name
            Entry_Item Trans.StartTime
            Entry_Item Trans.StopDate
            Entry_Item Trans.StopTime
                Entry_Item Trans.ElapsedMinutes
            Entry_Item Trans.Quantity
        
//            Entry_Item Trans.Comment
        End_Row

        Set Form_Width 0 to 1
        Set Header_Label 0 to "Idno"
        Set Column_Shadow_State 0 to True

        Set Form_Width 1 to 38
        Set Header_Label 1 to "Job#"

        Set Form_Width 2 to 88
        Set Header_Label 2 to "Location"
        Set Column_Shadow_State 2 to True

        Set Form_Width 3 to 46
        Set Header_Label 3 to "Eq/Mat ID"
        Set Header_Justification_Mode 3 to JMode_Right

        Set Form_Width 4 to 48
        Set Header_Label 4 to "Opcode"
        Set Column_Shadow_State 4 to True
        Set Header_Justification_Mode 4 to JMode_Right

        Set Form_Width 5 to 94
        Set Header_Label 5 to "Name"

        Set Form_Width 6 to 46
        Set Header_Label 6 to "StartTime"

        Set Form_Width 8 to 46
        Set Header_Label 8 to "StopTime"

        Set Form_Width 9 to 59
        Set Header_Label 9 to "ElapsedMinutes"
        Set Header_Justification_Mode 9 to JMode_Right
        Set Form_Width 7 to 60
        Set Header_Label 7 to "Stop Date"
        Set Form_Width 10 to 60
        Set Header_Label 10 to "Quantity"

        Set piResizeColumn to 5
        Set peResizeColumn to rcSelectedColumn

        Function Row_Save Returns Integer
            Integer iRetval
            Date    dStart
            //
            If (not(HasRecord(oTrans_DD))) Begin
                Get Value               of oTrans_StartDate                to dStart
                Set Field_Changed_Value of oTrans_DD Field Trans.StartDate to dStart
            End
            //
            Forward Get Row_Save to iRetval
            //
            Function_Return iRetval
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
            Boolean bMaterial
            Integer hoDD iRetval iCol iCols iToCol iBaseItem
            Integer iIsIdno iLocIdno iEquipIdno iOpersIdno
            //
            Get Server                to hoDD
            Get Base_Item             to iBaseItem
            Get Current_Col           to iCol
            Move 9                    to iCols
//            Move 10                   to iCols
            Move (mod(iToItem,iCols)) to iToCol
            //
            If (iCol = 3) Begin
                Send Refind_Records of hoDD
                Move Location.LocationIdno               to iLocIdno
                Move Opers.OpersIdno                     to iIsIdno
                Get Value item iFrItem                   to iEquipIdno
                Get IsEquipmentValid iLocIdno iEquipIdno to iOpersIdno
                If (iIsIdno <> iOpersIdno) Begin
                    Move iOpersIdno to Opers.OpersIdno
                    Send Request_Find of hoDD EQ Opers.File_Number 1
                End
            End
            //
            Forward Get msg_Item_Change iFrItem iToItem to iRetval
            //
            If (iToItem = iFrItem) Begin
                Procedure_Return
            End
            //
            If (iCol = 3) Begin
                Send Refind_Records of hoDD
                Move (Opers.CostType = "Material") to bMaterial
                If (iToCol = 6 and bMaterial) Begin
                    Move (iRetval + 2) to iRetval
                End
            End
            //
            If (iCol = 1) Begin
                Set piOrder of hoDD to (Current_Record(oOrder_DD))
            End
            //
            Procedure_Return iRetval
        End_Procedure

        Function Child_Entering Returns Integer
            Boolean bFail
            Date    dToday dStart
            //
            // Check there is an employee
            Move (not(HasRecord(oEmployee_DD))) to bFail
            If (bFail) Begin
                Send Stop_Box "No employee selected"
            End
            If (not(bFail)) Begin
                Sysdate dToday
                Get Value of oTrans_StartDate        to dStart
                Move (dStart = 0 or dStart > dToday) to bFail
                If (bFail) Begin
                    Send Stop_Box "Invalid Start Date"
                End
            End
            //
            Function_Return bFail // if non-zero do not enter
        End_Function // Child_Entering

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

    End_Object

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
        Forward Send Activate_View
    End_Procedure
    
    Procedure Entering_Scope
        Date dTrans
        //
        Forward Send Entering_Scope
        //
        Get pdTrans of oTrans_DD to dTrans
        If (dTrans = 0) Begin
            Sysdate dTrans
            Set pdTrans              of oTrans_DD to dTrans
            Send Rebuild_Constraints of oTrans_DD
            //
            Set Value of oTrans_StartDate to dTrans
        End
    End_Procedure

End_Object



///////////////////////////////////////////////////////////////////////
//            Object oTextBox2 is a Textbox
//                Set Label to "Create a DDO structure for each tab page."
//                Set Location to 8 4
//                Set Size to 10 135
//                Set TypeFace to "MS Sans Serif"
//            End_Object
//
//            Object oTextBox3 is a Textbox
//                Set Label to "Then create entry forms for each page."
//                Set Location to 22 5
//                Set Size to 10 124
//                Set TypeFace to "MS Sans Serif"
//            End_Object
//
//            Object oTextBox4 is a Textbox
//                Set Label to "Each tab page will behave as if it was a separate data entry view."
//                Set Location to 36 6
//                Set Size to 10 207
//                Set TypeFace to "MS Sans Serif"
//            End_Object

        End_Object

        Object oNewTabPage2 is a dbTabView
            Set Label to "Page 2"
        End_Object

    End_Object

End_Object

