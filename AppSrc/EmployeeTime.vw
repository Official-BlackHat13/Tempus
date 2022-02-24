// C:\VDF14.0 Workspaces\InterstateCompanies\AppSrc\EmployeeTime.vw
// Employee Time Record Maintenance
//

Use Windows.pkg
Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cTextEdit.pkg

Use Employer.DD
Use Employee.DD
Use Empltime.DD

ACTIVATE_VIEW Activate_oEmployeeTime FOR oEmployeeTime
Object oEmployeeTime Is A cGlblDbView
    Set Location to 5 5
    Set Size to 189 391
    Set Label To "Employee Time Record Maintenance"
    Set Border_Style to Border_Thick


    Object oEmployer_DD Is A Employer_DataDictionary
    End_Object // oEmployer_DD

    Object oEmployee_DD Is A Employee_DataDictionary
        Set DDO_Server To oEmployer_DD
    End_Object // oEmployee_DD

    Object oEmpltime_DD Is A Empltime_DataDictionary
        Set DDO_Server To oEmployee_DD
        Set Constrain_File To Employee.File_Number
    End_Object // oEmpltime_DD

    Set Main_DD To oEmployee_DD
    Set Server  To oEmployee_DD



    Object oEmployeeEmployeeidno Is A cGlblDbForm
        Entry_Item Employee.Employeeidno
        Set Size to 13 54
        Set Location to 5 20
        Set peAnchors to anLeftRight
        Set Label to "ID"
        Set Label_Justification_mode to jMode_right
        Set Label_Col_Offset to 2
        Set Label_row_Offset to 0
    End_Object // oEmployeeEmployeeidno

    Object oEmployeeLastname Is A cGlblDbForm
        Entry_Item Employee.Lastname
        Set Size to 13 86
        Set Location to 5 100
        Set peAnchors to anRight
        Set Label to "Last"
        Set Label_Justification_mode to jMode_right
        Set Label_Col_Offset to 2
        Set Label_row_Offset to 0
    End_Object // oEmployeeLastname

    Object oEmployeeFirstname Is A cGlblDbForm
        Entry_Item Employee.Firstname
        Set Size to 13 86
        Set Location to 5 210
        Set peAnchors to anRight
        Set Label to "First"
        Set Label_Justification_mode to jMode_right
        Set Label_Col_Offset to 2
        Set Label_row_Offset to 0
    End_Object // oEmployeeFirstname

    Object oDetailGrid Is A DbGrid
        Set Size to 145 381
        Set Location to 35 5

        Begin_row
            Entry_Item Empltime.Startdate
            Entry_Item Empltime.Starthr
            Entry_Item Empltime.Startmn
            Entry_Item Empltime.LunchOutDate
            Entry_Item Empltime.Lunchouthr
            Entry_Item Empltime.Lunchoutmn
            Entry_Item Empltime.LunchInDate
            Entry_Item Empltime.Lunchinhr
            Entry_Item Empltime.Lunchinmn
            Entry_Item Empltime.StopDate
            Entry_Item Empltime.Stophr
            Entry_Item Empltime.Stopmn
        End_row

        Set Main_file to Empltime.File_number

        Set Form_Width 0 to 50
        Set Header_Label 0 to "Date"

        Set Form_Width 1 to 22
        Set Header_Label 1 to "Hr"
        Set Header_Justification_Mode 1 to JMode_Right

        Set Form_Width 2 to 22
        Set Header_Label 2 to "Min"
        Set Header_Justification_Mode 2 to JMode_Right

        Set Form_Width 4 to 22
        Set Header_Label 4 to "Hr"
        Set Header_Justification_Mode 4 to JMode_Right

        Set Form_Width 5 to 22
        Set Header_Label 5 to "Min"
        Set Header_Justification_Mode 5 to JMode_Right

        Set Form_Width 7 to 22
        Set Header_Label 7 to "Hr"
        Set Header_Justification_Mode 7 to JMode_Right

        Set Form_Width 8 to 22
        Set Header_Label 8 to "Min"
        Set Header_Justification_Mode 8 to JMode_Right

        Set Form_Width 10 to 22
        Set Header_Label 10 to "Hr"
        Set Header_Justification_Mode 10 to JMode_Right

        Set Form_Width 11 to 22
        Set Header_Label 11 to "Min"
        Set Header_Justification_Mode 11 to JMode_Right
        Set Form_Width 3 to 50
        Set Header_Label 3 to "Date"
        Set Form_Width 6 to 50
        Set Header_Label 6 to "Date"
        Set Form_Width 9 to 50
        Set Header_Label 9 to "Date"


        Set Server to oEmpltime_DD
        Set Ordering to 2
        Set peResizeColumn to rcAll
        Set peAnchors to anAll
        Set Wrap_State to TRUE

        // Setting child_table_state to true will
        // cause the grid to save when exiting and
        // attempt to save the header when entering.
        Set Child_Table_State to True

        // Often grids are set up, so that items can never be added out
        // of order. New items are always added to the end of the table.
        // By setting Auto_Regenerate_State to false we are telling the
        // table to never bother reordering after adding records. This is
        // a minor optimization.
        //Set Auto_Regenerate_State to False // table is always in order.

        // Child_Entering is called when entering the table. Check with the header if it
        // has a valid saved record. If not, disallow entry.
        Function Child_Entering returns Integer
            Boolean bFail
            // Check with header to see if it is saved.
            Delegate Get SaveHeader to bFail
            Function_Return bFail // if non-zero do not enter
        End_Function // Child_Entering

        // Assign insert-row key append a row
        // Create new behavior to support append a row

        On_key kAdd_Mode send Append_a_Row  // Hot Key for KAdd_Mode = Shift+F10

        // Add new record to the end of the table.
        Procedure Append_a_Row 
            Send End_Of_Data
            Send Down
        End_Procedure // Append_a_Row

        Procedure Down_Row
            Forward Send Down_Row
            //
            If (not(Current_Record(Server(Self)))) Begin
                Set Current_Item to (Base_Item(Self))
            End
        End_Procedure
    End_Object // oDetailGrid


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
    End_Function // ConfirmSaveOrder

    // Define alternate confirmation Messages
    Set Verify_Save_MSG       to GET_ConfirmSaveHeader
    Set Verify_Delete_MSG     to GET_ConfirmDeleteHeader

    Object oStartTextBox is a TextBox
        Set Size to 50 10
        Set Location to 25 15
        Set Label to "---------- Start ----------"
        Set FontWeight to 800
        Set FontSize to 12 2
        Set Transparent_State to True
        Set TextColor to clGreen
    End_Object

    Object oLunchOutTextBox is a TextBox
        Set Size to 50 10
        Set Location to 25 102
        Set Label to "------- Lunch Out -------"
        Set FontSize to 12 2
        Set FontWeight to 800
        Set Transparent_State to True
        Set TextColor to clTeal
    End_Object

    Object oLunchInTextBox is a TextBox
        Set Size to 50 10
        Set Location to 25 192
        Set Label to "-------- Lunch In --------"
        Set FontSize to 12 2
        Set FontWeight to 800
        Set Transparent_State to True
        Set TextColor to clTeal
    End_Object

    Object oTextBox1 is a TextBox
        Set Size to 50 10
        Set Location to 25 283
        Set Label to "----------- Stop -----------"
        Set FontSize to 12 2
        Set FontWeight to 800
        Set Transparent_State to True
        Set TextColor to clRed
    End_Object

    //-------------------------------------------------------------------
    //  Table entry checking - attempt to save header record
    //  before entering a table (this is called by table. Return
    //  a non-zero if the save failed (i.e., do not enter table)
    //-------------------------------------------------------------------

    Function SaveHeader Returns Boolean
        Integer iRec
        Boolean bChanged bHasRecord
        Handle  hoSrvr

        Get Server to hoSrvr                   // The Header DDO.
        Get HasRecord of hoSrvr to bHasRecord  // Is there a record?
        Get Should_Save to bChanged            // Are there any current changes?

        // If there is no record and no changes we have an error.
        If (not(bHasRecord) AND not(bChanged) ) Begin  // no rec
            Error DfErr_Operator "You must First Create & Save the Header"
            Function_Return True
        End

        // Attempt to Save the current Record
        // request_save_no_clear does a save without clearing.
        Send Request_Save_No_Clear

        // The save succeeded if there are now no changes, and we
        // have a saved record. Should_save tells us if we've got changes.
        // We must check the DDO's HasRecord property to see if
        // we have a record. If it is false, we had no save.
        Get Should_Save to bChanged  // is a save still needed
        Get HasRecord of hoSrvr to bHasRecord // is there a record after the save?
        // if no record or changes still exist, return an error code of 1
        If (not(bHasRecord) OR (bChanged)) begin
            Function_Return true
        End
    End_Function // SaveHeader



End_Object // oEmployeeTime
