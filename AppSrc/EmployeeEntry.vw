Use Windows.pkg
Use DFClient.pkg
Use dfTabDlg.pkg
Use Employer.DD
Use Employee.DD
Use cInsClassGlblDataDictionary.dd
Use cWebAppUserRightsGlblDataDictionary.dd
Use DFEntry.pkg
Use dfLine.pkg
Use cGlblDbComboForm.pkg
Use cGlblDbForm.pkg
Use cTempusDbView.pkg
Use cGlblDbCheckBox.pkg
Use DFEnChk.pkg

Register_Object oEmployerEntry

Activate_View Activate_oEmployeeEntry for oEmployeeEntry

Object oEmployeeEntry is a cTempusDbView
    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
    End_Object

    Object oInsClass_DD is a cInsClassGlblDataDictionary
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oWebAppUserRights_DD
        Set DDO_Server to oInsClass_DD
        //Set ParentNullAllowed InsClass.File_Number to True
        Set DDO_Server to oEmployer_DD
        Set Constrain_File to Employer.File_Number
    End_Object

    Set Main_DD to oEmployee_DD
    Set Server to oEmployee_DD

    Set Border_Style to Border_Thick
    Set Size to 315 349
    Set Location to 14 82
    Set Label to "Employee Entry/Edit"
    Set piMinSize to 250 340
    Set piMaxSize to 315 349

    Object oEmployeeContainer is a dbContainer3d
        Set Size to 74 329
        Set Location to 4 4

        Object oEmployer_EmployerIdno is a dbForm
            Entry_Item Employer.EmployerIdno
            Set Location to 4 45
            Set Size to 13 42
            Set Label to "Employer#:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oEmployer_Name is a dbForm
            Entry_Item Employer.Name
            Set Location to 4 90
            Set Size to 13 166
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oEditEmployersButton is a Button
            Set Size to 14 55
            Set Location to 3 261
            Set Label to "Edit Employer"
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoEditEmployers
            End_Procedure
        
        End_Object

        Object oLineControl1 is a LineControl
            Set Size to 3 309
            Set Location to 20 5
        End_Object

        Object oEmployee_EmployeeIdno is a dbForm
            Entry_Item Employee.EmployeeIdno
            Set Location to 24 45
            Set Size to 13 42
            Set Label to "Employee#:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3

            Procedure Prompt
                Boolean bSelected
                Handle  hoServer
                RowID   riEmployee riEmployer
                //
                Get Server                            to hoServer
                Move (GetRowID(Employee.File_Number)) to riEmployee
                Move (GetRowId(Employer.File_Number)) to riEmployer
                //
                Get IsSelectedEmployee of Employee_sl (&riEmployee) (&riEmployer) to bSelected
                //
                If  (bSelected and not(IsNullRowId(riEmployee))) Begin
                    Send FindByRowId of hoServer Employee.File_Number riEmployee
                End
            End_Procedure
            
            
            Procedure Refresh Integer iMode
                Boolean bIsICEmployee bIsActive bIsInactive bIsTerminated bIsPending
                Boolean bHasMinSlsRights bHasMinOpsRights bHasMinAdmRights bHasMinSysAdmRights
                //
                Forward Send Refresh iMode
                //
                Move (giUserRights>=50) to bHasMinSlsRights
                Move (giUserRights>=60) to bHasMinOpsRights
                Move (giUserRights>=70) to bHasMinAdmRights
                Move (giUserRights>=90) to bHasMinSysAdmRights
                Move (Employee.Status="A") to bIsActive
                Move (Employee.Status="I") to bIsInactive
                Move (Employee.Status="T") to bIsTerminated
                Move (Employee.Status="P") to bIsPending
                Move (Employer.EmployerIdno = 101) to bIsICEmployee
                //
                Set Visible_State of oEmployee_PayRate to (not(bIsICEmployee) or (bHasMinAdmRights and bIsICEmployee))
                Set Visible_State of oEmployee_ExcludePayroll to (not(bIsICEmployee) or (bHasMinAdmRights and bIsICEmployee))
                //
                Set Enabled_State of oEmployee_Status to ((bHasMinOpsRights and (bIsActive or bIsInactive)) or (bHasMinAdmRights))
                Set Enabled_State of oWebAppUserRights_Description to (bHasMinOpsRights)
                Set Enabled_State of oEmployee_BillingAccessFlag to (bHasMinAdmRights)
                //
                Set Visible_State of oAdministrativeOptionsGroup to (giUserRights GE 80) //Only visible to Management Group
                Set Visible_State of oSpecialOptionsGroup to (giUserRights GE 60) //Only visible to Management Group
                //
                Send Rebuild_Constraints of oWebAppUserRights_DD
            End_Procedure
            
        End_Object


        Object oEmployee_CEPM_EmployeeIdno is a cGlblDbForm
            Entry_Item Employee.CEPM_EmployeeIdno
            Set Location to 24 272
            Set Size to 13 42
            Set Label to "Empl# @ CEPM:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oEmployee_FirstName is a dbForm
            Entry_Item Employee.FirstName
            Set Location to 39 45
            Set Size to 13 75
            Set Label to "First:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oEmployee_MiddleName is a cGlblDbForm
            Entry_Item Employee.MiddleName
            Set Location to 39 152
            Set Size to 13 38
            Set Label to "Middle:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object
        
        Object oEmployee_LastName is a dbForm
            Entry_Item Employee.LastName
            Set Location to 39 214
            Set Size to 13 102
            Set Label to "Last:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oEmployee_Status is a cGlblDbComboForm
            Entry_Item Employee.Status
            Set Location to 55 45
            Set Size to 12 56
            Set Label to "Status:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object
        Object oEmployee_PIN is a cGlblDbForm
            Entry_Item Employee.PIN
            Set Location to 24 152
            Set Size to 13 40
            Set Label to "PIN:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object
        
        Object oEmployee_StartDate is a dbForm
            Entry_Item Employee.StartDate
            Set Location to 54 152
            Set Size to 13 66
            Set Label to "StartDate:"
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt
        End_Object

    End_Object

    Object oEmployeeTabDialog is a dbTabDialog
        Set Size to 229 339
        Set Location to 81 4
    
        Set Rotate_Mode to RM_Rotate
        Set peAnchors to anAll

        Object oDbTabPage1 is a dbTabPage
            Set Label to "Address/Phones"

            Object oEmployee_Address is a dbForm
                Entry_Item Employee.Address1
                Set Location to 5 53
                Set Size to 13 216
                Set Label to "Address:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployee_Address2 is a dbForm
                Entry_Item Employee.Address2
                Set Location to 20 53
                Set Size to 13 216
                Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
            End_Object

            Object oEmployee_City is a dbForm
                Entry_Item Employee.City
                Set Location to 35 53
                Set Size to 13 146
                Set Label to "City:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployee_State is a dbForm
                Entry_Item Employee.State
                Set Location to 50 53
                Set Size to 13 24
                Set Label to "State/Zip:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployee_Zip is a dbForm
                Entry_Item Employee.Zip
                Set Location to 50 81
                Set Size to 13 72
            End_Object

            Object oEmployee_Phone1 is a dbForm
                Entry_Item Employee.Phone1
                Set Location to 65 53
                Set Size to 13 66
                Set Label to "Phones:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployee_PhoneType1 is a cGlblDbComboForm
                Entry_Item Employee.PhoneType1
                Set Location to 65 155
                Set Size to 13 52
                Set Label to "Types:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployee_Phone2 is a dbForm
                Entry_Item Employee.Phone2
                Set Location to 80 53
                Set Size to 13 66
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployee_PhoneType2 is a cGlblDbComboForm
                Entry_Item Employee.PhoneType2
                Set Location to 80 155
                Set Size to 13 52
            End_Object

            Object oEmployee_EmailAddress is a dbForm
                Entry_Item Employee.EmailAddress
                Set Location to 95 53
                Set Size to 13 149
                Set Label to "E Mail:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployee_ManagedBy is a cGlblDbForm
                Entry_Item Employee.ManagedBy
                Set Location to 110 54
                Set Size to 13 39
                Set Label to "Winter Mgr:"
                //Set Prompt_Object to Employee_sl
                Set Prompt_Button_Mode to PB_PromptOn
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                
                
                Procedure Prompt
                    Boolean bSelected
                    Integer iEmployeeRecId iMgrRecId iMgrIdno
                    String sFirstName sLastName
                    //
                    
                    Get Current_Record of oEmployee_DD to iEmployeeRecId
                    If (iEmployeeRecId) Begin
                        Move Employee.ManagedBy to iMgrIdno
                        Get SelectEmployee of Employee_sl (&iMgrIdno) (&sFirstname) (&sLastName) True to bSelected
                        If (bSelected) Begin
                            Set Field_Changed_Value of oEmployee_DD Field Employee.ManagedBy    to iMgrIdno
                            Set Value               of oManager_FirstName                      to sFirstName
                            Set Value               of oManager_LastName                       to sLastName
                        End
                        Else Begin
                            Set Field_Changed_Value of oEmployee_DD Field Employee.ManagedBy    to 0
                            Set Value               of oManager_FirstName                      to ""
                            Set Value               of oManager_LastName                       to ""
                        End
                    End
                End_Procedure
                
                Procedure Refresh Integer iMode
                    Integer hoDD iMgrEmployeeIdno iRecId iMainMgr
                    Get Main_DD to hoDD
                    
                    Forward Send Refresh iMode
                    //
                    Move Employee.EmployeeIdno to iRecId
                    Move Employee.ManagedBy to iMainMgr
                    //Main MGR
                    If (iMainMgr <> 0) Begin
                        Move Employee.ManagedBy to Employee.EmployeeIdno
                        Find EQ Employee by Index.1
                        If (Found) Begin
                            Set Value of oManager_FirstName to Employee.FirstName
                            Set Value of oManager_LastName to Employee.LastName  
                        End
                        Else Begin
                            Set Value of oManager_FirstName to ""
                            Set Value of oManager_LastName to ""  
                        End
                    End
                    Else Begin
                        Set Value of oManager_FirstName to ""
                        Set Value of oManager_LastName to ""  
                    End
                    //
                    Move iRecId to Employee.EmployeeIdno
                    Find eq Employee by Index.1              
                End_Procedure
                
                
            End_Object
            
            Object oManager_FirstName is a Form
                Set Size to 13 81
                Set Location to 110 97
                Set Enabled_State to False
            End_Object     
            
            Object oManager_LastName is a Form
                Set Size to 13 81
                Set Location to 110 181
                Set Enabled_State to False
            End_Object

            Object oEmployee_ManagedByAlt is a cGlblDbForm
                Entry_Item Employee.ManagedByAlt
                Set Location to 125 54
                Set Size to 13 39
                Set Label to "Summer Mgr:"
                Set Prompt_Button_Mode to PB_PromptOn
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                
                
                Procedure Prompt
                    Integer iEmployeeRecId iMgrRecId iMgrIdno
                    String sFirstName sLastName
                    Boolean bSelected
                    //
                    
                    Get Current_Record of oEmployee_DD to iEmployeeRecId
                    If (iEmployeeRecId) Begin
                        Move Employee.ManagedByAlt to iMgrIdno
                        Get SelectEmployee of Employee_sl (&iMgrIdno) (&sFirstname) (&sLastName) True to bSelected
                        If (bSelected) Begin
                            Set Field_Changed_Value of oEmployee_DD Field Employee.ManagedByAlt   to iMgrIdno
                            Set Value               of oAltManager_FirstName                      to sFirstName
                            Set Value               of oAltManager_LastName                       to sLastName
                        End
                        Else Begin
                            Set Field_Changed_Value of oEmployee_DD Field Employee.ManagedByAlt   to 0
                            Set Value               of oAltManager_FirstName                      to ""
                            Set Value               of oAltManager_LastName                       to ""
                        End
                    End
                End_Procedure
                
                Procedure Refresh Integer iMode
                    Integer hoDD iMgrEmployeeIdno iRecId iSecMgr
                    Get Main_DD to hoDD
                    
                    Forward Send Refresh iMode
                    //
                    Move Employee.EmployeeIdno to iRecId
                    Move Employee.ManagedByAlt to iSecMgr
                    //Alt MGR
                    If (iSecMgr <> 0) Begin
                        Move Employee.ManagedByAlt to Employee.EmployeeIdno
                        Find EQ Employee by Index.1
                        If (Found) Begin
                            Set Value of oAltManager_FirstName to Employee.FirstName
                            Set Value of oAltManager_LastName to Employee.LastName  
                        End
                        Else Begin
                            Set Value of oAltManager_FirstName to ""
                            Set Value of oAltManager_LastName to ""  
                        End
                    End
                    Else Begin
                        Set Value of oAltManager_FirstName to ""
                        Set Value of oAltManager_LastName to ""  
                    End 
                    //
                    Move iRecId to Employee.EmployeeIdno
                    Find eq Employee by Index.1              
                End_Procedure
                
                
            End_Object
            Object oAltManager_FirstName is a Form
                Set Size to 13 81
                Set Location to 125 97
                Set Enabled_State to False
            End_Object     
            Object oAltManager_LastName is a Form
                Set Size to 13 81
                Set Location to 125 181
                Set Enabled_State to False
            End_Object

            Object oAdministrativeOptionsGroup is a dbGroup
                Set Size to 70 190
                Set Location to 139 142
                Set Label to 'Administrative Options'
                Set peAnchors to anAll

                Object oEmployee_PayRate is a cGlblDbForm
                    Entry_Item Employee.OperatorRate
                    Set Server to oEmployee_DD
                    Set Location to 11 59
                    Set Size to 13 40
                    Set Label to "Operator Rate:"
                    Set Label_Justification_Mode to JMode_Right
                    Set Label_Col_Offset to 2
                    Set Form_Datatype to Mask_Numeric_Window
                    Set Form_Mask to "$ #,###,##0.00"
                End_Object
               
                Object oInsClass_ClassDescription is a cGlblDbForm
                    Entry_Item InsClass.ClassDescription
                    Set Entry_State to False
                    Set Label to "ClassCode:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Location to 26 59
                    Set Size to 13 124
                End_Object
                
                Object oWebAppUserRights_Description is a cGlblDbForm
                    Entry_Item WebAppUserRights.Description
                    Set Location to 41 59
                    Set Size to 13 124
                    Set Label to "WebApp Rights:"
                    Set Label_Col_Offset to 3
                    Set Label_Justification_Mode to JMode_Right
                End_Object
                
                Object oEmployee_BillingAccessFlag is a cGlblDbCheckBox
                    Entry_Item Employee.BillingAccessFlag
                    Set Location to 57 59
                    Set Size to 10 60
                    Set Label to "Billing Access"
                End_Object

                Object oEmployee_ExcludePayroll is a cGlblDbCheckBox
                    Entry_Item Employee.ExcludePayroll
                    Set Location to 12 105
                    Set Size to 10 58
                    Set Label to "Exclude from Payroll"
                End_Object


            End_Object

            Object oSpecialOptionsGroup is a dbGroup
                Set Size to 70 135
                Set Location to 139 5
                Set Label to 'Special'
                
                Object oEmployee_CallCenterFlag is a cGlblDbCheckBox
                    Entry_Item Employee.CallCenterFlag
                    Set Location to 10 9
                    Set Size to 10 60
                    Set Label to "IC Call Center"
                End_Object
                Object oEmployee_CallCenterNSIFlag is a cGlblDbCheckBox
                    Entry_Item Employee.CallCenterNSIFlag
                    Set Location to 21 9
                    Set Size to 10 58
                    Set Label to "NSI Call Center"
                End_Object
                
                Object oEmployee_GEOExclusionFlag is a cGlblDbCheckBox
                    Entry_Item Employee.GEOExclusionFlag
                    Set Location to 45 9
                    Set Size to 10 60
                    Set Label to "GEO Exclusion Flag"
                End_Object

                Object oEmployee_IsManager is a DbCheckBox
                    Entry_Item Employee.IsManager
                    Set Location to 33 9
                    Set Size to 10 73
                    Set Label to "Is Manager"
                End_Object

            End_Object


        End_Object
    
    End_Object

    Procedure DoEditEmployees Integer iRecId
        Integer hoDD
        //
        Get Server to hoDD
        If (Changed_State(hoDD)) Begin
            Send Request_Save
        End
        Send Clear_All      of hoDD
        Send Find_By_Recnum of hoDD Employee.File_Number iRecId
        Send Activate_View
    End_Procedure
    
    Procedure DoCreateNewEmployees Integer iRecId
        Integer hoDD
        //
        Get Server to hoDD
//        If (Changed_State(hoDD)) Begin
//            Send Request_Save
//        End
        Send Clear      of hoDD
        Send Find_By_Recnum of hoDD Employer.File_Number iRecId
        Send Clear of hoDD
        Send Activate_View
    End_Procedure

    Procedure DoEditEmployers
        Send DoEditEmployers of oEmployerEntry (Current_Record(oEmployer_DD))
    End_Procedure

End_Object

