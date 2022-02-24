// C:\VDF16.1 Workspaces\Tempus\AppSrc\TransactionUtility.vw
// Transaction Utility
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use Windows.pkg
Use dfLine.pkg
Use dfTable.pkg
Use dfSelLst.pkg
Use Employer.DD
Use Employee.DD
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use MastOps.DD
Use Opers.DD
Use Trans.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use cWebAppUserRightsGlblDataDictionary.dd
Use cSplitButton.pkg

Activate_View Activate_oTransactionUtility for oTransactionUtility
Object oTransactionUtility is a cGlblDbView
    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
    End_Object

    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
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

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oWebAppUserRights_DD
        Set DDO_Server to oEmployer_DD
    End_Object

    Object oTrans_DD is a Trans_DataDictionary
        Set DDO_Server to oOpers_DD
        Set DDO_Server to oOrder_DD
        Set DDO_Server to oEmployee_DD
    End_Object

    Set Main_DD to oTrans_DD
    Set Server to oTrans_DD

    Set Location to 4 5
    Set Size to 113 359
    Set Label To "Transaction Utility"
    Set Border_Style to Border_Thick

    Procedure Activate_View
        If (giUserRights GE 70) Begin
            Set Visible_State of oDaylightSavingsAdjustmentGroup to (giUserRights GE 90)
            Forward Send Activate_View  
        End
        Else Begin
            Send Info_Box "You have no permission to open this view!"
        End        
    End_Procedure

    Object oPayrollSundaySplitGroup is a Group
        Set Size to 28 350
        Set Location to 5 5
        Set Label to 'Payroll Split'

        Object oPayRollTimeSplit is a TextBox
            Set Size to 10 85
            Set Location to 11 8
            Set Label to 'PayRoll Time Split (Sat/Sun)'
        End_Object
        
        Object oSaturday is a Form
            Set Size to 13 100
            Set Location to 9 161
            Set Label to "Select Saturday:"
            Set Label_Col_Offset to 55
            Set Form_Datatype to Mask_Date_Window
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt
        End_Object
        
        Object oListSplitButton is a Button
            Set Size to 14 73
            Set Location to 8 274
            Set Label to 'ListSplit'
        
            // fires when the button is clicked
            Procedure OnClick
                Date dSaturday dSunday
                Integer iTransCount iChangedTransCount iTempTransIdno hoDD
                String sTempStartTime sTempStopTime sCutOffTime sCuttOffHr sCuttOffMin sStartUpTime sStartUpHr sStartUpMin          
                Boolean bOk bCancel bError
    
                Get Value of oSaturday to dSaturday
                Move (DateGetDayOfWeek(dSaturday)=7) to bOk
                If (bOk) Begin
                    Move 0              to iTransCount
                    Move (dSaturday+1)  to dSunday
                    // Time split according to Megan is: cutoff Saturday 23:59 openup Sunday 00:00
                    Move "23:59"        to sCutOffTime
                    Move "23"           to sCuttOffHr
                    Move "59"           to sCuttOffMin
                    
                    Move "00:00"        to sStartUpTime
                    Move "00"           to sStartUpHr
                    Move "00"           to sStartUpMin
                    //
                    Clear Trans
                    Constraint_Set 1
                    Constrain Trans.StartDate Between (dSaturday-6) and dSaturday
                    Constrain Trans.StopDate gt dSaturday
                    Constrain Trans.EmployerIdno eq "101"
                    Constrained_Find First Trans by 6
                    While ((Found) and Trans.StartDate >= (dSaturday-6) and Trans.StartDate <= dSaturday and Trans.StopDate > dSaturday)                      
                        Increment iTransCount 
                        Constrained_Find Next
                    Loop
                    If (iTransCount = 0) Send Info_Box "Could not find a record for this day"
                    Else Begin
                        Get Confirm ("Would you like to continue and split the" * (String(iTransCount))* "found Transactions") to bCancel
                        If (not(bCancel)) Begin
                            Constrained_Find First Trans by 6
                            While ((Found) and Trans.StartDate >= (dSaturday-6) and Trans.StartDate <= dSaturday and Trans.StopDate > dSaturday)
                                Move Trans.TransIdno to iTempTransIdno                   
                                Reread System
                                    Increment System.LastTrans
                                    SaveRecord System
                                Unlock
                                Lock
                                    //Create new record and manipulate
                                    NewRecord Trans   
                                    Move System.LastTrans   to Trans.TransIdno
                                    Move dSunday            to Trans.StartDate
                                    Move sStartUpTime       to Trans.StartTime
                                    Move sStartUpHr         to Trans.StartHr
                                    Move sStartUpMin        to Trans.StartMin
                                    // update and Save the record
                                    Send Update of oTrans_DD
                                    SaveRecord Trans
                                Unlock
                                // Find the old transaction and edit the information in there
                                Clear Trans
                                Move iTempTransIdno to Trans.TransIdno
                                Find EQ Trans.TransIdno
                                If ((Found) and Trans.TransIdno = iTempTransIdno) Begin
                                    // Manipulate the old record
                                    Reread Trans
                                    Move dSaturday          to Trans.StopDate
                                    Move sCutOffTime        to Trans.StopTime
                                    Move sCuttOffHr         to Trans.StopHr
                                    Move sCuttOffMin        to Trans.StopMin
                                    // update and save the record
                                    Send Update of oTrans_DD
                                    SaveRecord Trans
                                    Unlock
                                End  
                                Increment iChangedTransCount
                                // Find Next Record after everything is saved.
                                Constrained_Find Next
                            Loop
                            Constraint_Set 1 Delete
                            Send Info_Box ("Successfully split" * (String(iChangedTransCount)) * " Transactions") "Transaction Splitter" 
                        End
                        Else If (bCancel) Send Info_Box "Procedure canceled - no records were changed."
                    End
                    Constraint_Set 1 Delete
                End
                Else Send Info_Box "You did not select a Saturday"           
            End_Procedure
        
        End_Object
    End_Object

    Object oDaylightSavingsAdjustmentGroup is a Group
        Set Size to 43 350
        Set Location to 37 5
        Set Label to 'Daylight Savings Adjustment'
        

        Object oTextBox1 is a TextBox
            Set Size to 10 103
            Set Location to 13 8
            Set Label to 'Adjust ALL Labor Transactions on:'
        End_Object

        Object oTransDatePicker is a Form
            Set Size to 13 100
            Set Location to 11 115
            Set Form_Datatype to Mask_Date_Window
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt
        End_Object

        Object oTextBox2 is a TextBox
            Set Size to 10 100
            Set Location to 26 8
            Set Label to 'for DaylightSavings change from'
        End_Object

        Object oDSTComboForm is a ComboForm
            Set Size to 12 100
            Set Location to 26 115
            // Combo_Fill_List is called when the list needs filling
          
            Procedure Combo_Fill_List
                // Fill the combo list with Send Combo_Add_Item
                Send Combo_Add_Item "Summer --> Winter (+1h)"
                Send Combo_Add_Item "Winter --> Summer (-1h)"
            End_Procedure
          
        End_Object

        Object oGoButton is a Button
            Set Size to 29 70
            Set Location to 9 275
            Set Label to 'Go'
        
            // fires when the button is clicked
            Procedure OnClick
                Boolean bIsSunday
                String sDSTAdjustment sCutOffTime sCuttOffHr sCuttOffMin sStartUpTime sStartUpHr sStartUpMin
                Integer iTransCount iTempTransIdno
                Date dSunday
                Get Value of oTransDatePicker to dSunday
                Get Value of oDSTComboForm to sDSTAdjustment
                //
                Move (DateGetDayOfWeek(dSunday)=1) to bIsSunday
                If (bIsSunday) Begin
                    Showln ("Selected Sunday"*String(dSunday))
                    Showln ("Selected DST Adjustment is: "* sDSTAdjustment)
                    
                    //Cutoff for DST
                    Move "02:00"        to sCutOffTime
                    Move "02"           to sCuttOffHr
                    Move "00"           to sCuttOffMin
                    //Startup for DST
                    Move "03:00"        to sStartUpTime
                    Move "03"           to sStartUpHr
                    Move "00"           to sStartUpMin
                    
                    // Transaction Started Before Sunday 02:00 and Stopped after Sunday 03:00
                    Clear Trans
                    Constraint_Set 1
                    Constrain Trans.StartDate Between (dSunday-6) and dSunday
                    Constrain Trans.StopDate Between dSunday and (dSunday+6)
                    //Constrain Trans.EmployerIdno eq "101"
                    Constrained_Find First Trans by 6
                    While ((Found) and ((Trans.StartDate>=(dSunday-6) and Trans.StartDate<=dSunday) and (Trans.StopDate>=dSunday and Trans.StopDate<=(dSunday+6))))
                        //ToDo: Check if Material or Labor Transaction
                        Case Begin
                            Case ((((Trans.StartDate=dSunday) and (Trans.StartTime < '02:00')) or ((Trans.StartDate>(dSunday-6)) and (Trans.StartDate<dSunday)));
                                and ;
                                (((Trans.StopDate = dSunday) and (Trans.StopTime > '03:00')) or ((Trans.StopDate > dSunday) and (Trans.StopDate < (dSunday+6))))) 
                                
                                //Regular, full spanning transaction, can be from live, could have been entered manually
                                Showln "Regular, full spanning transaction, can be from live, could have been entered manually"
                                Showln "EASY TO ADJUST:"
                                Showln "Step 1: Capture original Stop Time in 3 variables"
                                Showln "Step 2: Create a new transaction with Start Time of 03:00 using captured original StopTime"
                                Showln "Step 3: Re-Find original transactions and change Stop Time of current Transaction to 02:00"
                                //
                                Increment iTransCount
                                Showln ("Empl#:"*String(Trans.EmployeeIdno)*"- Trans#"*String(iTransCount)*"- Start"*String(Trans.StartDate)*String(Trans.StartTime)*"-"*String(Trans.StopDate)*String(Trans.StopTime)*"- ElapsedHours:"*String(Trans.ElapsedHours))
                                //Remember this transaction
                                Move Trans.TransIdno to iTempTransIdno  
                                Reread System
                                    Increment System.LastTrans
                                    SaveRecord System
                                Unlock
                                //Create new record and adjust start time
                                Lock
                                    NewRecord Trans   
                                    Move System.LastTrans   to Trans.TransIdno
                                    Move dSunday            to Trans.StartDate
                                    Move sStartUpTime       to Trans.StartTime
                                    Move sStartUpHr         to Trans.StartHr
                                    Move sStartUpMin        to Trans.StartMin
                                    // update and Save the record
                                    Send Update of oTrans_DD
                                    SaveRecord Trans
                                Unlock
                                Showln ("--> NEW Empl#:"*String(Trans.EmployeeIdno)*"- Trans#"*String(iTransCount)*"- Start"*String(Trans.StartDate)*String(Trans.StartTime)*"-"*String(Trans.StopDate)*String(Trans.StopTime)*"- ElapsedHours:"*String(Trans.ElapsedHours))
                                // Find the old transaction and edit the information in there
                                Clear Trans
                                Move iTempTransIdno to Trans.TransIdno
                                Find EQ Trans.TransIdno
                                If ((Found) and Trans.TransIdno = iTempTransIdno) Begin
                                    // Manipulate the old record
                                    Reread Trans
                                        Move dSunday            to Trans.StopDate
                                        Move sCutOffTime        to Trans.StopTime
                                        Move sCuttOffHr         to Trans.StopHr
                                        Move sCuttOffMin        to Trans.StopMin
                                        // update and save the record
                                        Send Update of oTrans_DD
                                        SaveRecord Trans
                                    Unlock
                                    Showln ("--> OLD Empl#:"*String(Trans.EmployeeIdno)*"- Trans#"*String(iTransCount)*"- Start"*String(Trans.StartDate)*String(Trans.StartTime)*"-"*String(Trans.StopDate)*String(Trans.StopTime)*"- ElapsedHours:"*String(Trans.ElapsedHours))
                                End
                                
                                Case Break
//                                Case (Trans.StartTime > "02:00" and Trans.StartTime < "03:00" and Trans.StopTime > "03:00")
//                                    //ToDo: Verify if manual transaction
//                                    Showln "Can only be a Manual Transaction or correction"
//                                    Showln "Step 1: Start Time needs to be changed to 03:00"
//                                    Case Break
//                                Case (Trans.StartTime < "02:00" and Trans.StopTime > "02:00" and Trans.StopTime < "03:00")
//                                    //ToDo: Verify if manual transaction
//                                    Showln "Can only be a Manual Transaction or correction"
//                                    Showln "Step 1: Stop Time needs to be changed to 02:00"
//                                    Case Break
//                                Case (Trans.StartTime > "02:00" and Trans.StartTime < "03:00" and Trans.StopTime > "02:00" and Trans.StopTime < "03:00")
//                                    //ToDo: Verify if manual transaction
//                                    Showln "Can only be a Manual Transaction or correction"
//                                    Showln "Step 1: This should require a manual adjustment as this transaction should have not happened at all."
//                                    Case Break
                            Case Else
                                Showln "This condition is currently outside the parameters for using an automated procedure!"
                        Case End
                        Constrained_Find Next
                    Loop
                    Constraint_Set 1 Delete

                End
                Else Begin
                    Send Info_Box "You did not select a Saturday" 
                End
                
            End_Procedure
        
        End_Object
    End_Object

End_Object // oTransactionUtility
