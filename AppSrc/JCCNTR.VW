// JCCNTR.vw

Use cTempusDbView.pkg
Use cGlblDbForm.pkg
Use cGlblButton.pkg
Use cGlblDbCheckBox.pkg

Use cJcdeptDataDictionary.dd
Use cJccntrDataDictionary.dd


Activate_View Activate_oCostCenters for oCostCenters
Object oCostCenters is a cTempusDbView

    Property Boolean pbReadOnly False
            
    Set Label to "Cost Centers"
    Set Location to 9 9
    Set Size to 249 370

    Object Jcdept_DD is a cJcdeptDataDictionary
    End_Object    // Jcdept_DD

    Object Jccntr_DD is a cJccntrDataDictionary
        Set DDO_Server to Jcdept_DD
    End_Object    // Jccntr_DD

    Set Main_DD to Jccntr_DD
    Set Server to Jccntr_DD

    Object Container1 is a dbContainer3d
        Set Size to 71 361
        Set Location to 5 5
        Object Jccntr_Idno is a cGlblDbForm
            Entry_Item Jccntr.Idno
            Set Label to "C.C. I.D. #"
            Set Size to 13 38
            Set Location to 5 45
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set pbDataLoss to True

            Procedure Refresh Integer iMode
                Local Integer hJccntrDD //iOpcount
                Get Server to hJccntrDD
            //    Get Field_Current_Value of hJccntrDD ;
            //        field Jccntr.Count to iOpcount
                forward send Refresh iMode
                send EnableCloneButton (Current_Record(hJccntrDD))
            End_Procedure
        End_Object    // Jccntr_Idno

        Object Jccntr_Name is a cGlblDbForm
            Entry_Item Jccntr.Name
            Set Label to "Description"
            Set Size to 13 130
            Set Location to 5 131
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jccntr_Name

        Object Jccntr_Nickname is a cGlblDbForm
            Entry_Item Jccntr.Nickname
            Set Label to "Short Name"
            Set Size to 13 60
            Set Location to 20 131
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jccntr_Nickname

        Object oJccntr_Picklist_Code is a cGlblDbForm
            Entry_Item Jccntr.Picklist_code
            Set Label to "Filter Code"
            Set Size to 13 16
            Set Location to 20 245
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // oJccntr_Picklist_Code

        Object Jcdept_Idno is a cGlblDbForm
            Entry_Item Jcdept.Idno
            Set Label to "Dep't #"
            Set Size to 13 29
            Set Location to 35 45
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set pbDataLoss to True
        End_Object    // Jcdept_Idno

        Object Jcdept_Name is a cGlblDbForm
            Entry_Item Jcdept.Name
            Set Label to "Description"
            Set Size to 13 130
            Set Location to 35 131
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jcdept_Name

        Object Jccntr_Count is a cGlblDbForm
            Entry_Item Jccntr.Count
            Set Label to "Assigned Ops."
            Set Size to 13 25
            Set Location to 50 131
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jccntr_Count

        Object CloneButton is a cGlblButton
            Set Label to "&Clone Operations"
            Set Size to 14 70
            Set Location to 50 283

            Procedure OnClick
                send CloneOperations
            End_Procedure
        End_Object    // CloneButton

        on_key Key_Alt+Key_C  send KeyAction of CloneButton
        
        Procedure EnableCloneButton integer bState
            set Enabled_State of (CloneButton(self)) to bState
        End_Procedure
        
        register_object CloneOperations
        register_procedure DoCloneOperations
        Procedure CloneOperations
            Boolean bReadOnly
            Integer hJccntrDD iOldCC iNewCC bQuit
            //
            Get pbReadOnly to bReadOnly
            if bReadOnly Procedure_Return
            //
            Get Server to hJccntrDD
            get Field_Current_Value of hJccntrDD field Jccntr.Idno to iNewCC
            set pbClone of Jccntr_SL to TRUE
            clear Jcdept
            send Popup of Jccntr_SL
            move Jccntr.Idno to iOldCC
            set pbClone of Jccntr_SL to FALSE
            // if no selection, quit
            if iOldCC eq iNewCC procedure_return
            // else, confirm
            get Confirm ("Clone Operations from CC."*string(iOldCC)*"to CC."*string(iNewCC)+"?") to bQuit
            if bQuit procedure_return
            send DoCloneOperations of CloneOperations iOldCC iNewCC
            send Refind_Records to hJccntrDD
            send Display
        End_Procedure

    End_Object    // Container1

    Object dbCostCenterTabDialog is a dbTabDialog
        Set Size to 164 361
        Set Location to 81 5
        Set Rotate_Mode to RM_Ring
        Object TP_Rates_and_Capacities is a dbTabPage
            Set Label to "Rates and Capacities"
            Object oCostGroup is a dbGroup
                Set Size to 80 345
                Set Location to 5 6
                Object Jccntr_Fullrate is a cGlblDbForm
                    Entry_Item Jccntr.Fullrate
                    Set Label to "Full $/Hour"
                    Set Size to 13 42
                    Set Location to 10 60
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Currency_mask item 0 to 6 2
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Fullrate

                Object Jccntr_Directrate is a cGlblDbForm
                    Entry_Item Jccntr.Directrate
                    Set Label to "Direct $/Hour"
                    Set Size to 13 42
                    Set Location to 26 60
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Currency_mask item 0 to 6 2
                    //AB-StoreEnd

                End_Object    // Jccntr_Directrate

                Object Jccntr_Sell_Rate is a cGlblDbForm
                    Entry_Item Jccntr.Sell_rate
                    Set Label to "Sell $/Hour"
                    Set Size to 13 42
                    Set Location to 41 60
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Currency_mask item 0 to 6 2
                    //AB-StoreEnd

                End_Object    // Jccntr_Sell_Rate

                Object Jccntr_Markup is a cGlblDbForm
                    Entry_Item Jccntr.Markup
                    Set Label to "Factor"
                    Set Size to 13 42
                    Set Location to 56 60
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Markup

                Object Jccntr_Weekdays is a cGlblDbForm
                    Entry_Item Jccntr.Weekdays
                    Set Label to "Days per week"
                    Set Size to 13 30
                    Set Location to 10 173
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Weekdays

                Object Jccntr_Shifts is a cGlblDbForm
                    Entry_Item Jccntr.Shifts
                    Set Label to "Shifts per day"
                    Set Size to 13 30
                    Set Location to 26 173
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Shifts

                Object Jccntr_Shifthrs is a cGlblDbForm
                    Entry_Item Jccntr.Shifthrs
                    Set Label to "Hours per shift"
                    Set Size to 13 30
                    Set Location to 41 173
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Shifthrs

                Object Jccntr_Shiftunits is a cGlblDbForm
                    Entry_Item Jccntr.Shiftunits
                    Set Label to "Resource units"
                    Set Size to 13 30
                    Set Location to 56 173
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Shiftunits

                Object Jccntr_Utilgoal is a cGlblDbForm
                    Entry_Item Jccntr.Utilgoal
                    Set Label to "Budgeted Utilization"
                    Set Size to 13 42
                    Set Location to 10 288
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Utilgoal

                Object Jccntr_Effgoal is a cGlblDbForm
                    Entry_Item Jccntr.Effgoal
                    Set Label to "Efficiency Standard"
                    Set Size to 13 42
                    Set Location to 26 288
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Effgoal

                Object Jccntr_Jobskej_Maxhrs is a cGlblDbForm
                    Entry_Item Jccntr.Jobskej_maxhrs
                    Set Label to "Max. Job Schedule Hrs."
                    Set Size to 13 42
                    Set Location to 41 288
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Jobskej_Maxhrs

                Object Jccntr_Startup_Time is a cGlblDbForm
                    Entry_Item Jccntr.Startup_time
                    Set Label to "Startup Time"
                    Set Size to 13 42
                    Set Location to 56 288
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Startup_Time

            End_Object    // oCostGroup

            Object oJccntr_Bnoshopfloor is a cGlblDbCheckBox
                Entry_Item Jccntr.Bnoshopfloor
                Set Label to "Suppress display on shop floor"
                Set Size to 10 112
                Set Location to 92 7
            End_Object    // oJccntr_Bnoshopfloor

        End_Object    // TP_Rates_and_Capacities

        Object TP_Shop_Load is a dbTabPage
            Set Label to "Shop Load"
            Object dbGroup2 is a dbGroup
                Set Size to 69 124
                Set Location to 19 35
                Set Label to "Backlog"
                Object Jccntr_Backlog_Days is a cGlblDbForm
                    Entry_Item Jccntr.Backlog_days
                    Set Label to "Days"
                    Set Size to 13 42
                    Set Location to 15 49
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Backlog_Days

                Object Jccntr_Backlog_Hrs is a cGlblDbForm
                    Entry_Item Jccntr.Backlog_hrs
                    Set Label to "Hours"
                    Set Size to 13 42
                    Set Location to 30 49
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Backlog_Hrs

                Object Jccntr_Backlog_Jobs is a cGlblDbForm
                    Entry_Item Jccntr.Backlog_jobs
                    Set Label to "Orders"
                    Set Size to 13 42
                    Set Location to 45 49
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Backlog_Jobs

            End_Object    // dbGroup2

            Object dbGroup3 is a dbGroup
                Set Size to 69 124
                Set Location to 19 195
                Set Label to "Current"
                Object Jccntr_Current_Days is a cGlblDbForm
                    Entry_Item Jccntr.Current_days
                    Set Label to "Days"
                    Set Size to 13 42
                    Set Location to 15 51
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Current_Days

                Object Jccntr_Current_Hrs is a cGlblDbForm
                    Entry_Item Jccntr.Current_hrs
                    Set Label to "Hours"
                    Set Size to 13 42
                    Set Location to 30 51
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Current_Hrs

                Object Jccntr_Current_Jobs is a cGlblDbForm
                    Entry_Item Jccntr.Current_jobs
                    Set Label to "Orders"
                    Set Size to 13 42
                    Set Location to 45 51
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jccntr_Current_Jobs

            End_Object    // dbGroup3

        End_Object    // TP_Shop_Load

        Object TP_Utilization is a dbTabPage
            Set Label to "Utilization"
            Object dbGroup4 is a dbGroup
                Set Size to 137 347
                Set Location to 8 4
                Set Label to "                                      1st Qtr.           2nd Qtr.          3rd Qtr.           4th Qtr.            Y.T.D.         Last Year "
                Object Jccntr_Q1_Avlhrs is a cGlblDbForm
                    Entry_Item (jccntrq1_avlhrs(server(current_object)))
                    Set Label to "Available Hrs."
                    Set Size to 13 42
                    Set Location to 12 73
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q1_Avlhrs

                Object Jccntr_Q1_Chghrs is a cGlblDbForm
                    Entry_Item Jccntr.Q1_chghrs
                    Set Label to "Chargeable Hrs."
                    Set Size to 13 42
                    Set Location to 26 73
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q1_Chghrs

                Object Jccntr_Q1_Nchrs is a cGlblDbForm
                    Entry_Item Jccntr.Q1_nchrs
                    Set Label to "Burden Hrs."
                    Set Size to 13 42
                    Set Location to 42 73
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q1_Nchrs

                Object Jccntr_Q1_Althrs is a cGlblDbForm
                    Entry_Item Jccntr.Q1_althrs
                    Set Label to "Alteration Hrs."
                    Set Size to 13 42
                    Set Location to 57 73
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q1_Althrs

                Object Jccntr_Q1_Splhrs is a cGlblDbForm
                    Entry_Item Jccntr.Q1_splhrs
                    Set Label to "Spoilage Hrs."
                    Set Size to 13 42
                    Set Location to 72 73
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q1_Splhrs

                Object Jccntr_Q2_Avlhrs is a cGlblDbForm
                    Entry_Item (jccntrq2_avlhrs(server(current_object)))
                    Set Size to 13 42
                    Set Location to 12 118
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q2_Avlhrs

                Object Jccntr_Q2_Chghrs is a cGlblDbForm
                    Entry_Item Jccntr.Q2_chghrs
                    Set Size to 13 42
                    Set Location to 27 118
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q2_Chghrs

                Object Jccntr_Q2_Nchrs is a cGlblDbForm
                    Entry_Item Jccntr.Q2_nchrs
                    Set Size to 13 42
                    Set Location to 42 118
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q2_Nchrs

                Object Jccntr_Q2_Althrs is a cGlblDbForm
                    Entry_Item Jccntr.Q2_althrs
                    Set Size to 13 42
                    Set Location to 57 118
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q2_Althrs

                Object Jccntr_Q2_Splhrs is a cGlblDbForm
                    Entry_Item Jccntr.Q2_splhrs
                    Set Size to 13 42
                    Set Location to 72 118
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q2_Splhrs

                Object Jccntr_Q3_Avlhrs is a cGlblDbForm
                    Entry_Item (jccntrq3_avlhrs(server(current_object)))
                    Set Size to 13 42
                    Set Location to 12 163
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q3_Avlhrs

                Object Jccntr_Q3_Chghrs is a cGlblDbForm
                    Entry_Item Jccntr.Q3_chghrs
                    Set Size to 13 42
                    Set Location to 27 163
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q3_Chghrs

                Object Jccntr_Q3_Nchrs is a cGlblDbForm
                    Entry_Item Jccntr.Q3_nchrs
                    Set Size to 13 42
                    Set Location to 42 163
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q3_Nchrs

                Object Jccntr_Q3_Althrs is a cGlblDbForm
                    Entry_Item Jccntr.Q3_althrs
                    Set Size to 13 42
                    Set Location to 57 163
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q3_Althrs

                Object Jccntr_Q3_Splhrs is a cGlblDbForm
                    Entry_Item Jccntr.Q3_splhrs
                    Set Size to 13 42
                    Set Location to 72 163
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q3_Splhrs

                Object Jccntr_Q4_Avlhrs is a cGlblDbForm
                    Entry_Item (jccntrq4_avlhrs(server(current_object)))
                    Set Size to 13 42
                    Set Location to 12 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q4_Avlhrs

                Object Jccntr_Q4_Chghrs is a cGlblDbForm
                    Entry_Item Jccntr.Q4_chghrs
                    Set Size to 13 42
                    Set Location to 27 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q4_Chghrs

                Object Jccntr_Q4_Nchrs is a cGlblDbForm
                    Entry_Item Jccntr.Q4_nchrs
                    Set Size to 13 42
                    Set Location to 42 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q4_Nchrs

                Object Jccntr_Q4_Althrs is a cGlblDbForm
                    Entry_Item Jccntr.Q4_althrs
                    Set Size to 13 42
                    Set Location to 57 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q4_Althrs

                Object Jccntr_Q4_Splhrs is a cGlblDbForm
                    Entry_Item Jccntr.Q4_splhrs
                    Set Size to 13 42
                    Set Location to 72 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Q4_Splhrs

                Object Jccntr_Prevyr_Avlhrs is a cGlblDbForm
                    Entry_Item Jccntr.Prevyr_avlhrs
                    Set Size to 13 42
                    Set Location to 12 298
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Prevyr_Avlhrs

                Object Jccntr_Prevyr_Chghrs is a cGlblDbForm
                    Entry_Item Jccntr.Prevyr_chghrs
                    Set Size to 13 42
                    Set Location to 27 298
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Prevyr_Chghrs

                Object Jccntr_Prevyr_Nchrs is a cGlblDbForm
                    Entry_Item Jccntr.Prevyr_nchrs
                    Set Size to 13 42
                    Set Location to 42 298
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Prevyr_Nchrs

                Object Jccntr_Prevyr_Althrs is a cGlblDbForm
                    Entry_Item Jccntr.Prevyr_althrs
                    Set Size to 13 42
                    Set Location to 57 298
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Prevyr_Althrs

                Object Jccntr_Prevyr_Splhrs is a cGlblDbForm
                    Entry_Item Jccntr.Prevyr_splhrs
                    Set Size to 13 42
                    Set Location to 72 298
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_Prevyr_Splhrs

                Object Jccntr_YTD_ChgHrs is a cGlblDbForm
                    Entry_Item (jccntr.Q1_chghrs +jccntr.Q2_chghrs +jccntr.Q3_chghrs +jccntr.Q4_chghrs)
                    Set Size to 13 42
                    Set Location to 27 253
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Jccntr_YTD_ChgHrs

                Object Jccntr_YTD_AvlHrs is a cGlblDbForm
                    Entry_Item (jccntrytd_avlhrs(server(current_object)))
                    Set Size to 13 42
                    Set Location to 12 253
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_YTD_AvlHrs

                Object Jccntr_YTD_NCHrs is a cGlblDbForm
                    Entry_Item (jccntr.Q1_nchrs +jccntr.Q2_nchrs +jccntr.Q3_nchrs +jccntr.Q4_nchrs)
                    Set Size to 13 42
                    Set Location to 42 253
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                    
                    
                    
                    //AB-StoreEnd

                End_Object    // Jccntr_YTD_NCHrs

                Object Jccntr_YTD_AltHrs is a cGlblDbForm
                    Entry_Item (jccntr.Q1_althrs +jccntr.Q2_althrs +jccntr.Q3_althrs +jccntr.Q4_althrs)
                    Set Size to 13 42
                    Set Location to 57 253
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                End_Object    // Jccntr_YTD_AltHrs

                Object Jccntr_YTD_SplHrs is a cGlblDbForm
                    Entry_Item (jccntr.Q1_splhrs +jccntr.Q2_splhrs +jccntr.Q3_splhrs +jccntr.Q4_splhrs)
                    Set Size to 13 42
                    Set Location to 72 253
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Numeric_Mask Item 0 to 8 2 ",*"
                End_Object    // Jccntr_YTD_SplHrs

                Object Jccntr_Q1_Act_Util is a cGlblDbForm
                    Entry_Item (jccntrq1_act_util(server(current_object)))
                    Set Label to "Actual Utilization"
                    Set Size to 13 42
                    Set Location to 87 73
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 4 0 "*%"
                End_Object    // Jccntr_Q1_Act_Util

                Object Jccntr_Q2_Act_Util is a cGlblDbForm
                    Entry_Item (jccntrq2_act_util(server(current_object)))
                    Set Size to 13 42
                    Set Location to 87 118
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 4 0  "*%"
                End_Object    // Jccntr_Q2_Act_Util

                Object Jccntr_Q3_Act_Util is a cGlblDbForm
                    Entry_Item (jccntrq3_act_util(server(current_object)))
                    Set Size to 13 42
                    Set Location to 87 163
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 4 0 "*%"
                End_Object    // Jccntr_Q3_Act_Util

                Object Jccntr_Q4_Nchrs is a cGlblDbForm
                    Entry_Item (jccntrq4_act_util(server(current_object)))
                    Set Size to 13 42
                    Set Location to 87 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 4 0 "*%"
                End_Object    // Jccntr_Q4_Nchrs

                Object Jccntr_YTD_Act_Util is a cGlblDbForm
                    Entry_Item (jccntrytd_act_util(server(current_object)))
                    Set Size to 13 42
                    Set Location to 87 253
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 4 0 "*%"
                End_Object    // Jccntr_YTD_Act_Util

                Object Jccntr_Prevyr_Act_Util is a cGlblDbForm
                    Entry_Item (jccntrprevyr_act_util(server(current_object)))
                    Set Size to 13 42
                    Set Location to 87 298
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 4 0 "*%"
                End_Object    // Jccntr_Prevyr_Act_Util

                Object Jccntr_Prevyr_Adj_Util is a cGlblDbForm
                    Entry_Item (jccntrprevyr_adj_util(server(current_object)))
                    Set Size to 13 42
                    Set Location to 102 298
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 4 0 "*%"
                End_Object    // Jccntr_Prevyr_Adj_Util

                Object Jccntr_YTD_Adj_Util is a cGlblDbForm
                    Entry_Item (jccntrytd_adj_util(server(current_object)))
                    Set Size to 13 42
                    Set Location to 102 253
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 4 0 "*%"
                End_Object    // Jccntr_YTD_Adj_Util

                Object Jccntr_Q4_Adj_Util is a cGlblDbForm
                    Entry_Item (jccntrq4_adj_util(server(current_object)))
                    Set Size to 13 42
                    Set Location to 102 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 4 0 "*%"
                End_Object    // Jccntr_Q4_Adj_Util

                Object Jccntr_Q3_Adj_Util is a cGlblDbForm
                    Entry_Item (jccntrq3_adj_util(server(current_object)))
                    Set Size to 13 42
                    Set Location to 102 163
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 4 0 "*%"
                End_Object    // Jccntr_Q3_Adj_Util

                Object Jccntr_Q2_Adj_Util is a cGlblDbForm
                    Entry_Item (jccntrq2_adj_util(server(current_object)))
                    Set Size to 13 42
                    Set Location to 102 118
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 4 0 "*%"
                End_Object    // Jccntr_Q2_Adj_Util

                Object Jccntr_Q1_Adj_Util is a cGlblDbForm
                    Entry_Item (jccntrq1_adj_util(server(current_object)))
                    Set Label to "Adjusted Utilization"
                    Set Size to 13 42
                    Set Location to 102 73
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 4 0 "*%"
                End_Object    // Jccntr_Q1_Adj_Util

                Object Jccntr_Q1_Lost_Hrs is a cGlblDbForm
                    Entry_Item (jccntrq1_lost_hrs(server(current_object)))
                    Set Label to "Unused Hours"
                    Set Size to 13 42
                    Set Location to 117 73
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 8 2 ",*"
                End_Object    // Jccntr_Q1_Lost_Hrs

                Object Jccntr_Q2_Lost_Hrs is a cGlblDbForm
                    Entry_Item (jccntrq2_lost_hrs(server(current_object)))
                    Set Size to 13 42
                    Set Location to 117 118
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 8 2 ",*"
                End_Object    // Jccntr_Q2_Lost_Hrs

                Object Jccntr_Q3_Lost_Hrs is a cGlblDbForm
                    Entry_Item (jccntrq3_lost_hrs(server(current_object)))
                    Set Size to 13 42
                    Set Location to 117 163
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 8 2 ",*"
                End_Object    // Jccntr_Q3_Lost_Hrs

                Object Jccntr_Q4_Lost_Hrs is a cGlblDbForm
                    Entry_Item (jccntrq4_lost_hrs(server(current_object)))
                    Set Size to 13 42
                    Set Location to 117 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 8 2 ",*"
                End_Object    // Jccntr_Q4_Lost_Hrs

                Object Jccntr_YTD_Lost_Hrs is a cGlblDbForm
                    Entry_Item (jccntr_ytd_lost_hrs(server(current_object)))
                    Set Size to 13 42
                    Set Location to 117 253
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 8 2 ",*"
                End_Object    // Jccntr_YTD_Lost_Hrs

                Object Jccntr_Prevyr_Lost_Hrs is a cGlblDbForm
                    Entry_Item (jccntr_prevyr_lost_hrs(server(current_object)))
                    Set Size to 13 42
                    Set Location to 117 298
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set numeric_mask item 0 to 8 2 ",*"
                End_Object    // Jccntr_Prevyr_Lost_Hrs

            End_Object    // dbGroup4

        End_Object    // TP_Utilization

    End_Object    // dbCostCenterTabDialog

//    procedure AttachRecords
//        local integer hJccntrDD iDept iCntr
//        move (Jccntr_DD(self)) to hJccntrDD
//        move Jccntr.Dept_idno to iDept
//        move Jccntr.Recnum to iCntr
//        send Clear_All to hJccntrDD
//        move iDept to Jcdept.Idno
//        send Request_Find to hJccntrDD EQ Jcdept.File_number 1
//        send Find_By_Recnum to hJccntrDD Jccntr.File_number iCntr
//        send Activate_View
//    end_procedure
//    // right mouse button down
//    register_object oViewFloatingMenu
//    procedure Mouse_Down2
//        local integer hJccntrDD
//        move (Jccntr_DD(self)) to hJccntrDD
//        if NOT (Current_Record(hJccntrDD)) procedure_return
//        send Refind_Records to hJccntrDD
//        set Item_Shadow_State of oViewFloatingMenu item 1 to true
//        send Popup To (oViewFloatingMenu(self))
//        set Item_Shadow_State of oViewFloatingMenu item 1 to false
//    end_procedure
    
    on_Key Key_Alt+Key_1 Send SwitchToRatesTabPage
    on_Key Key_Alt+Key_2 Send SwitchToShopTabPage
    on_Key Key_Alt+Key_3 Send SwitchToUtilizationTabPage
    //
    Procedure SwitchToRatesTabPage
        send Request_Switch_To_Tab to (dbCostCenterTabDialog(self)) 0 3
    End_Procedure
    Procedure SwitchToShopTabPage
        send Request_Switch_To_Tab to (dbCostCenterTabDialog(self)) 1 3
    End_Procedure
    Procedure SwitchToUtilizationTabPage
        send Request_Switch_To_Tab to (dbCostCenterTabDialog(self)) 2 3
    End_Procedure
    
    Procedure Request_Clear
        Forward Send Request_Clear
        Send Activate of Container1 //Beginning_Of_Panel
        //send next of Container1
    End_Procedure
    
//    Procedure Activating
//        boolean bReadOnly 
//        get pbReadonly of ghoApplication to bReadOnly
//        set pbReadonly to bReadOnly
//        set Read_Only_State of Jccntr_DD to bReadOnly
//        set Enabled_State of CloneButton to bReadOnly
//        if bReadOnly Set Label to "Cost Centers - READ ONLY"
//        Else Set Label to "Cost Centers"
//    End_Procedure
    
//    Procedure Request_Save
//        boolean bReadOnly
//        get pbReadOnly to bReadOnly
//        if bReadOnly Begin
//            send request_assign to Jccntr_DD
//            procedure_return
//        end
//        forward send request_save
//    End_Procedure

End_Object    // oCostCenters
