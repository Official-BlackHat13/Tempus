Use Windows.pkg
Use DFClient.pkg
Use dfTabDlg.pkg
Use Employer.DD
Use MastOps.DD
Use Equipmnt.DD
Use Employee.DD
Use Areas.DD
Use cWorkTypeGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use cWebAppUserRightsGlblDataDictionary.dd
Use DFEntry.pkg
Use cGlblDbComboForm.pkg
Use cGlblDbForm.pkg
Use cTempusDbView.pkg
Use cDbCJGrid.pkg
Use dfallent.pkg
Use dfTable.pkg
Use dfSelLst.pkg
Use dfcentry.pkg
Use dfEnChk.pkg
Use cCJGrid.pkg
Use cdbCJGridColumn.pkg
Use EmployerTasks.bp
Use dbSuggestionForm.pkg
Use cGlblDbCheckBox.pkg
Use EmployeeListReport.rv
Use EquipmentListReport.rv

Register_Object oEmployeeEntry
Register_Object PrintEmployees
Register_Object PrintEquipment

Activate_View Activate_oEmployerEntry for oEmployerEntry
Object oEmployerEntry is a cTempusDbView
    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
    End_Object

//    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
//    End_Object
    
    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oMastops_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oWebAppUserRights_DD
//        Set pbUseDDRelates to True
//        Set DDO_Server to oWebAppUserRights_DD
//        Set Field_Related_FileField Field Employee.WebAppUserRights to File_Field WebAppUserRights.RightLevel
        Set Constrain_file to Employer.File_number
        Set DDO_Server to oEmployer_DD
        
        Procedure OnConstrain
            String sEmplStatus
            Get Value of oEmplStatusComboForm to sEmplStatus
            Move (Left(Trim(sEmplStatus),1)) to sEmplStatus
            If (Trim(sEmplStatus)<>"") Constrain Employee.Status eq sEmplStatus
            //
        End_Procedure
    End_Object

    Object oEquipmnt_DD is a Equipmnt_DataDictionary
        Set Constrain_file to Employer.File_number
        Set DDO_Server to oEmployer_DD
        Set DDO_Server to oMastops_DD
        
        Procedure OnConstrain
            //Status
            String sEquipStatus
            Get Value of oEquipStatusComboForm to sEquipStatus
            Move (Left(Trim(sEquipStatus),1)) to sEquipStatus
            If (Length(sEquipStatus)>0) Begin
                Constrain Equipmnt.Status eq sEquipStatus
            End
            //
        End_Procedure        
        
    End_Object

    Set Main_DD to oEmployer_DD
    Set Server to oEmployer_DD

    Set Border_Style to Border_Thick
    Set Size to 220 462
    Set Location to 4 4
    Set Label to "Employer Entry/Edit"
    Set piMinSize to 220 453
    Set Maximize_Icon to True
    
    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 28 453
        Set Location to 2 5
        Set peAnchors to anTopLeftRight

        Object oEmployer_Name is a DbSuggestionForm //dbForm
            Entry_Item Employer.Name
            Set piStartAtChar to 1
            Set pbFullText to True
            Set Location to 9 3
            Set Size to 13 147
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            Set Label to "Name"
            Set peAnchors to anTopLeftRight
        End_Object

        Object oEmployer_EmployerIdno is a dbForm
            Entry_Item Employer.EmployerIdno
            Set Location to 9 157
            Set Size to 13 42
            Set Label to "Employer#"
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            Set peAnchors to anTopRight

            Procedure Refresh Integer notifyMode
                Boolean bIsInterstate bIsActive bIsInactive bIsTerminated
                Boolean bHasMinSlsRights bHasMinOpsRights bHasMinAdmRights bHasMinMgmtRights bHasMinSysAdmRights
                Forward Send Refresh notifyMode
                //
                Move (giUserRights GE 50) to bHasMinSlsRights
                Move (giUserRights GE 60) to bHasMinOpsRights
                Move (giUserRights GE 70) to bHasMinAdmRights
                Move (giUserRights GE 80) to bHasMinMgmtRights
                Move (giUserRights GE 90) to bHasMinSysAdmRights
                Move (Employer.EmployerIdno=101) to bIsInterstate
                Move (Employer.Status="A") to bIsActive
                Move (Employer.Status="I") to bIsInactive
                Move (Employer.Status="T") to bIsTerminated
                //
                Set Enabled_State of oEmployer_Status to (bHasMinAdmRights and not(bIsInterstate))
                Set Enabled_State of oEmployer_Terms to (bHasMinAdmRights)
                Set Enabled_State of oEmployerTabDialog to (bIsActive)
                Set Enabled_State of oOpsSettingsDbGroup to (bHasMinMgmtRights)
                
            End_Procedure
        End_Object

        Object oManagedByAdreaManager is a cGlblDbForm
            Entry_Item Employer.ManagedBy
            Set Label to "Managed By"
            Set Size to 13 33
            Set Location to 9 282

            Set Label_Justification_Mode to JMode_Top
            Set Prompt_Button_Mode to PB_PromptOn
            Set Label_Col_Offset to 0
            Set peAnchors to anTopRight
            
            Procedure Prompt
                Integer iManagerIdno
                String sFirstName sLastName
                Boolean bSelected
                //
                Get Field_Current_Value of oEmployer_DD Field Employer.ManagedBy to iManagerIdno
                Get SelectEmployee of Employee_sl (&iManagerIdno) (&sFirstName) (&sLastName) True to bSelected
                If (bSelected) Begin
                    Set Field_Changed_Value of oEmployer_DD Field Employer.ManagedBy    to iManagerIdno
                    Set Value               of oManager_FirstName                      to sFirstName
                    Set Value               of oManager_LastName                       to sLastName
                End
                Else Begin
                    // No change reqired
                End
            End_Procedure
            
            Procedure Refresh Integer iMode
                Forward Send Refresh iMode
                //
                Clear Employee
                If (Employer.ManagedBy <> 0) Begin
                    Move Employer.ManagedBy to Employee.EmployeeIdno
                    Find eq Employee.EmployeeIdno
                End
                Set Value of oManager_FirstName to Employee.FirstName
                Set Value of oManager_LastName to Employee.LastName
            End_Procedure
            
        End_Object

        Object oManager_FirstName is a cGlblDbForm
            Set Location to 9 318
            Set Size to 13 58
            Set Enabled_State to False
            Set peAnchors to anTopRight
        End_Object

        Object oManager_LastName is a cGlblDbForm
            Set Location to 9 382
            Set Size to 13 63
            Set Prompt_Button_Mode to PB_PromptOff
            Set Enabled_State to False
            Set peAnchors to anTopRight
        End_Object

        Object oEmployer_Status is a cGlblDbComboForm
            Entry_Item Employer.Status
            Set Location to 9 211
            Set Size to 13 62
            Set Label to "Status:"
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            Set peAnchors to anTopRight
            
            
            Procedure Combo_Item_Changed
                Integer eResponse iEmplrIdno
                String sEmplrName sCurStatus
                Boolean bFail
                //
                Get Field_Current_Value of oEmployer_DD Field Employer.EmployerIdno to iEmplrIdno
                Get Field_Current_Value of oEmployer_DD Field Employer.Name to sEmplrName
                Get Field_Current_Value of oEmployer_DD Field Employer.Status to sCurStatus
                //
                Move (YesNo_Box("This will change the status of"*sEmplrName*", all Employees and Equipment to"*sCurStatus*"?", "Customer Status Change", MB_DEFBUTTON2)) to eResponse
                If (eResponse = MBR_Yes) Begin
                    Get Request_Validate of oEmployer_DD to bFail
                    If (not(bFail)) Begin
                        Send Request_Save of oEmployer_DD
                        If (sCurStatus = "T") Begin
                            Move "I" to sCurStatus
                        End
                        Send ChangeEmployerStatus of oEmployerTasks iEmplrIdno sCurStatus True False
                        Send Request_Clear_All
                        Move iEmplrIdno to Employer.EmployerIdno
                        Send Find of oEmployer_DD EQ 1
                    End 
                End
            End_Procedure
            
        End_Object
        
        

    End_Object


    Object oEmployerTabDialog is a dbTabDialog
        Set Size to 181 454
        Set Location to 36 4
    
        Set Rotate_Mode to RM_Rotate
        Set peAnchors to anAll

        Object oAddressTabPage is a dbTabPage
            Set Label to "Address/Phones"

            Object oEmployer_Main_contact is a dbForm
                Entry_Item Employer.Main_contact
                Set Location to 10 66
                Set Size to 13 185
                Set Label to "Main Contact:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployer_Address1 is a dbForm
                Entry_Item Employer.Address1
                Set Location to 25 66
                Set Size to 13 185
                Set Label to "Address:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployer_Address2 is a dbForm
                Entry_Item Employer.Address2
                Set Location to 40 66
                Set Size to 13 185
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployer_City is a dbForm
                Entry_Item Employer.City
                Set Location to 55 66
                Set Size to 13 120
                Set Label to "City:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployer_State is a dbForm
                Entry_Item Employer.State
                Set Location to 70 66
                Set Size to 13 20
                Set Label to "State/Zip:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployer_Zip is a dbForm
                Entry_Item Employer.Zip
                Set Location to 70 90
                Set Size to 13 66
                Set Label to ""
            End_Object

            Object oEmployer_Phone1 is a dbForm
                Entry_Item Employer.Phone1
                Set Location to 85 66
                Set Size to 13 62
                Set Label to "Phones:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oEmployer_PhoneType1 is a cGlblDbComboForm
                Entry_Item Employer.PhoneType1
                Set Location to 85 158
                Set Size to 13 52
                Set Label to "Types:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oEmployer_Phone2 is a dbForm
                Entry_Item Employer.Phone2
                Set Location to 100 66
                Set Size to 13 62
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                
            End_Object

            Object oEmployer_PhoneType2 is a cGlblDbComboForm
                Entry_Item Employer.PhoneType2
                Set Location to 100 158
                Set Size to 13 52
            End_Object

            Object oEmployer_Phone3 is a cGlblDbForm
                Entry_Item Employer.Phone3
                Set Location to 115 66
                Set Size to 13 62
            End_Object

            Object oEmployer_PhoneType3 is a cGlblDbComboForm
                Entry_Item Employer.PhoneType3
                Set Location to 115 158
                Set Size to 13 52
            End_Object

            Object oEmployer_EmailAddress is a dbForm
                Entry_Item Employer.EmailAddress
                Set Location to 130 66
                Set Size to 13 145
                Set Label to "Email:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oBillingDBGroup is a dbGroup
                Set Size to 63 179
                Set Location to 5 260
                Set Label to "Billing Settings"

                Object oEmployer_Terms is a cGlblDbComboForm
                    Entry_Item Employer.Terms
                    Set Location to 13 34
                    Set Size to 12 134
                    Set Label to "Terms:"
                    Set Label_Col_Offset to 3
                    Set Label_Justification_Mode to JMode_Right
                End_Object

                Object oDbCheckbox1 is a dbCheckbox
                    Set Size to 10 50
                    Set Location to 32 35
                    Entry_Item Employer.TruckingOnlyFlag
                    Set Label to "Trucking Only"
                End_Object
            End_Object

            Object oOpsSettingsDbGroup is a dbGroup
                Set Size to 71 181
                Set Location to 73 260
                Set Label to "Ops Settings"

                Object oEmployer_GEOExclusionFlag is a cGlblDbCheckBox
                    Entry_Item Employer.GEOExclusionFlag
                    Set Location to 19 30
                    Set Size to 11 123
                    Set Label to "GEO Exclusion (Company Default)"
                End_Object
            End_Object

        End_Object

        Object oEquipmentTabPage is a dbTabPage
            Set Label to "Equipment"
            
            Object oStatusGroup is a Group
                Set Size to 25 140
                Set Location to 3 6
                Set Label to 'Status'

                Object oEquipStatusComboForm is a ComboForm
                    Set Size to 14 100
                    Set Location to 8 6
                    Set Allow_Blank_State to False
                    Set Entry_State to False
                    // Combo_Fill_List is called when the list needs filling
                  
                    Procedure Combo_Fill_List
                        // Fill the combo list with Send Combo_Add_Item
                        Send Combo_Add_Item "Active"
                        Send Combo_Add_Item "Inactive"
                        Send Combo_Add_Item "Terminated"
                    End_Procedure
                  
                    // OnChange is called on every changed character
                 
                    Procedure OnChange
                        Send Rebuild_Constraints of oEquipmnt_DD
                        Send MoveToFirstRow of oEquipmentGrid
                    End_Procedure
                  
                    // Notification that the list has dropped down
                 
                //    Procedure OnDropDown
                //    End_Procedure
                
                    // Notification that the list was closed
                  
                //    Procedure OnCloseUp
                //    End_Procedure
                End_Object
                
                Object oClearEmployeeStatusButton is a Button
                    Set Size to 14 25
                    Set Location to 8 110
                    Set Label to 'Clear'
                
                    // fires when the button is clicked
                    Procedure OnClick
                        //Clear Value in Filter
                        Set Value of oEquipStatusComboForm to ""
                        Send Rebuild_Constraints of oEquipmnt_DD
                        Send MoveToFirstRow of oEquipmentGrid
                    End_Procedure
                
                End_Object
                
            End_Object
            
            Object oEquipmentGrid is a cDbCJGrid
                Set Server to oEquipmnt_DD
                Set Size to 130 436
                Set Location to 31 9
                Set Ordering to -1
                Set peAnchors to anAll
                Set peVerticalGridStyle to xtpGridSmallDots
                Set piSelectedRowBackColor to clLtGray
                Set pbAllowDeleteRow to False
                Set pbHeaderReorders to True
                Set pbUseAlternateRowBackgroundColor to True
                Set pbAllowColumnRemove to False
                Set pbAllowColumnReorder to False
                Set pbAutoAppend to False
                Set pbHeaderTogglesDirection to True
                Set pbHotTracking to True
                Set pbStaticData to True

                Object oEquipmnt_EquipmentID is a cDbCJGridColumn
                    Entry_Item Equipmnt.EquipmentID
                    Set piWidth to 68
                    Set psCaption to "EquipmentID"
                End_Object

                Object oEquipmnt_Description is a cDbCJGridColumn
                    Entry_Item Equipmnt.Description
                    Set piWidth to 173
                    Set psCaption to "Description"
                End_Object

                Object oMastOps_MastOpsIdno is a cDbCJGridColumn
                    Entry_Item MastOps.MastOpsIdno
                    Set piWidth to 57
                    Set psCaption to "MastOpsIdno"
                End_Object

                Object oMastOps_Name is a cDbCJGridColumn
                    Entry_Item MastOps.Name
                    Set piWidth to 179
                    Set psCaption to "Name"
                End_Object

                Object oEquipmnt_EquipIdno is a cDbCJGridColumn
                    Entry_Item Equipmnt.EquipIdno
                    Set piWidth to 72
                    Set psCaption to "Equip #"
                    Set pbEditable to False
                End_Object

                Object oEquipmnt_ContractorRate is a cDbCJGridColumn
                    Entry_Item Equipmnt.ContractorRate
                    Set pbEditable to False
                    Set piWidth to 66
                    Set psCaption to "Rate"
                End_Object

                Object oEquipmnt_RentalRate is a cDbCJGridColumn
                    Entry_Item Equipmnt.RentalRate
                    Set piWidth to 72
                    Set psCaption to "RentalRate"
                    Set pbEditable to False
                End_Object

                Object oEquipmnt_Status is a cDbCJGridColumn
                    Entry_Item Equipmnt.Status
                    Set piWidth to 67
                    Set psCaption to "Status"
                    Set pbComboButton to True
                End_Object

                Object oEquipmnt_Hr_Mat_MinFlag is a cDbCJGridColumn
                    Entry_Item Equipmnt.Hr_Mat_MinFlag
                    Set piWidth to 82
                    Set psCaption to "Hr/Mat Min."
                    Set pbCheckbox to True
                End_Object

                Object oEquipmnt_CEPM_EquipIdno is a cDbCJGridColumn
                    Entry_Item Equipmnt.CEPM_EquipIdno
                    Set piWidth to 89
                    Set psCaption to "Equip# @ CEPM"
                End_Object

                Procedure Search
                    Handle hoCol
                    Get SelectedColumnObject to hoCol 
                    Send RequestColumnSearch hoCol 0 0
                End_Procedure

                Procedure Activating
                    Forward Send Activating
                    Set Value of oEquipStatusComboForm to "Active"
                    Send MoveToFirstRow of oEquipmentGrid
                End_Procedure

                Procedure OnComFocusChanging Variant llNewRow Variant llNewColumn Variant llNewItem Boolean  ByRef llCancel
                    Forward Send OnComFocusChanging llNewRow llNewColumn llNewItem (&llCancel)
                    If (Employer.EmployerIdno = "101") Begin
                        //Only Management Employees have the right to change Interstates Equipment rates used for costing
                        If (giUserRights GE 80) Begin
                            Set pbEditable of oEquipmnt_ContractorRate to True
                            Set pbEditable of oEquipmnt_RentalRate to True
                        End
                        Else Begin
                            Set pbEditable of oEquipmnt_ContractorRate to False
                            Set pbEditable of oEquipmnt_RentalRate to False
                        End
                    End
                    Else Begin
                        If (giUserRights GE 70) Begin
                            Set pbEditable of oEquipmnt_ContractorRate to True
                            Set pbEditable of oEquipmnt_RentalRate to True
                        End
                        Else Begin
                            Set pbEditable of oEquipmnt_ContractorRate to False
                            Set pbEditable of oEquipmnt_RentalRate to False
                        End
                    End
                  
                End_Procedure

                On_Key Key_Ctrl+Key_F Send Search of oEquipmentGrid

            End_Object

            Object oPrintEmployees is a Button
                Set Size to 14 31
                Set Location to 10 413
                Set Label to "Print"
                Set peAnchors to anTopRight
            
                Procedure OnClick
                    //Send DoPrintEquipment
                    String sFilePath sFileName
                    Send DoExportReport of oEquipmentListReportView Employer.EmployerIdno (Left(Trim(Value(oEquipStatusComboForm)),1)) (&sFilePath) (&sFileName) True
                End_Procedure
            End_Object
        End_Object

        Object oEmployeesTabPage is a dbTabPage
            Set Label to 'Employees'

            Object oStatusGroup is a Group
                Set Size to 25 140
                Set Location to 3 5
                Set Label to 'Status'

                Object oEmplStatusComboForm is a ComboForm
                    Set Size to 14 100
                    Set Location to 8 6
                    Set Allow_Blank_State to True
                    Set Entry_State to True
                    // Combo_Fill_List is called when the list needs filling
                  
                    Procedure Combo_Fill_List
                        // Fill the combo list with Send Combo_Add_Item
                        Send Combo_Add_Item "Active"
                        Send Combo_Add_Item "Paperwork Missing"
                        Send Combo_Add_Item "Inactive"
                        Send Combo_Add_Item "Terminated"
                    End_Procedure
                  
                    // OnChange is called on every changed character
                 
                    Procedure OnChange
                        Send Rebuild_Constraints of oEmployee_DD
                        Send RefreshDataFromDD of oEmployeeGrid ropTop
                    End_Procedure
                  
                    // Notification that the list has dropped down
                 
                //    Procedure OnDropDown
                //    End_Procedure
                
                    // Notification that the list was closed
                  
                    Procedure OnCloseUp
                        Send Rebuild_Constraints of oEmployee_DD
                        Send MoveToFirstRow of oEmployeeGrid
                    End_Procedure
                End_Object
                
                Object oClearEmployeeStatusButton is a Button
                    Set Size to 14 25
                    Set Location to 8 110
                    Set Label to 'Clear'
                
                    // fires when the button is clicked
                    Procedure OnClick
                        //Clear Value in Filter
                        Set Value of oEmplStatusComboForm to ""
                        //Send RebuildAllConstraints of oEmployee_DD
                        Send Rebuild_Constraints of oEmployee_DD
                        Send MoveToFirstRow of oEmployeeGrid
                    End_Procedure
                
                End_Object
            End_Object

//            Object oEmployeeGrid is a dbList
//                Set Size to 245 557
//                Set Location to 30 5
//
//                Begin_Row
//                    Entry_Item Employee.FirstName
//                    Entry_Item Employee.LastName
//                    Entry_Item Employee.EmployeeIdno
//                    Entry_Item Employee.PIN
//                    Entry_Item Employee.Status
//                    Entry_Item Employee.CallCenterFlag
//                    Entry_Item Employee.OperatorRate
//                End_Row
//
//                Set Main_File to Employee.File_Number
//
//                Set Server to oEmployee_DD
//
//                Set Form_Width 0 to 118
//                Set Header_Label 0 to "First Name"
//                
//                Set Form_Width 1 to 138
//                Set Header_Label 1 to "Last Name"
//                
//                Set Form_Width 2 to 60
//                Set Header_Label 2 to "Empl #"
//                
//                Set Form_Width 3 to 60
//                Set Header_Label 3 to "PIN"
//                
//                Set Form_Width 4 to 36
//                Set Header_Label 4 to "Status"
//                Set Column_Combo_State 4 to True
//                
//                Set Column_Checkbox_State 5 to True
//                Set Form_Width 5 to 55
//                Set Header_Label 5 to "Call Center"
//                
//                Set Form_Width 6 to 54
//                Set Header_Label 6 to "Operator Rate"
//                
//
//                Set pbHeaderTogglesDirection to True
//                Set pbUseServerOrdering to True
//                Set Read_Only_State to True
//                Set Auto_Index_State to True
//                Set Auto_Shadow_State to False
//                
//                
//                Procedure Refresh Integer notifyMode
//                    Forward Send Refresh notifyMode
//                    Send Rebuild_Constraints of oEmployee_DD
//                End_Procedure
//                
//                Procedure Activating
//                    Forward Send Activating
//                    Send Beginning_of_Data of oEmployeeGrid
//                End_Procedure
//
//                Procedure Mouse_Click Integer iWindowNumber Integer iPosition
//                    Send DoEditEmployees of oEmployeeEntry (Current_Record(oEmployee_DD))
//                End_Procedure
//                
//            End_Object

            Object oEditEmployeeButton is a Button
                Set Size to 14 31
                Set Location to 10 344
                Set Label to "Edit"
                Set peAnchors to anTopRight
            
                Procedure OnClick
                    Send DoEditEmployees of oEmployeeEntry (Current_Record(oEmployee_DD))
                End_Procedure
            
            End_Object

            Object oNewEmployeeButton is a Button
                Set Size to 14 31
                Set Location to 10 378
                Set Label to "New"
                Set peAnchors to anTopRight
            
                Procedure OnClick
                    Send DoCreateNewEmployees of oEmployeeEntry (Current_Record(oEmployer_DD))
                End_Procedure
            
            End_Object

            Object oPrintEmployees is a Button
                Set Size to 14 31
                Set Location to 10 413
                Set Label to "Print"
                Set peAnchors to anTopRight
            
                Procedure OnClick
                    //Send DoPrintEmployees
                    String sFilePath sFileName
                    Send DoExportReport of oEmployeeListReportView Employer.EmployerIdno (Left(Trim(Value(oEmplStatusComboForm)),1)) (&sFilePath) (&sFileName) True
                End_Procedure
            
            End_Object

            Object oEmployeeGrid is a cDbCJGrid
                Set Server to oEmployee_DD
                Set Size to 130 439
                Set Location to 33 6
                Set peAnchors to anAll
                Set pbStaticData to True
                Set peVerticalGridStyle to xtpGridSmallDots
                Set piSelectedRowBackColor to clLtGray
                Set pbHeaderReorders to True
                Set pbUseAlternateRowBackgroundColor to True
                Set pbHeaderTogglesDirection to True
                Set pbSelectionEnable to True
                Set pbPromptListBehavior to True
                Set pbShowRowFocus to True
                Set pbMultipleSelection to True
                Set pbReadOnly to True
                Set Ordering to 5
                Set piSortColumn to 0
                Set pbHeaderSelectsColumn to True

                Object oEmployee_FirstName is a cDbCJGridColumn
                    Entry_Item Employee.FirstName
                    Set piWidth to 104
                    Set psCaption to "First Name"
                    Set pbEditable to False
                End_Object

                Object oEmployee_LastName is a cDbCJGridColumn
                    Entry_Item Employee.LastName
                    Set piWidth to 110
                    Set psCaption to "LastName"
                    Set pbEditable to False
                End_Object

                Object oEmployee_EmployeeIdno is a cDbCJGridColumn
                    Entry_Item Employee.EmployeeIdno
                    Set piWidth to 79
                    Set psCaption to "Employee#"
                    Set pbEditable to False
                End_Object

                Object oEmployee_PIN is a cDbCJGridColumn
                    Entry_Item Employee.PIN
                    Set piWidth to 72
                    Set psCaption to "PIN"
                    Set pbEditable to False
                End_Object

                Object oEmployee_Status is a cDbCJGridColumn
                    Entry_Item Employee.Status
                    Set piWidth to 61
                    Set psCaption to "Status"
                    Set pbComboButton to True
                    Set pbEditable to False
                End_Object

                Object oEmployee_IsSeasonal is a cDbCJGridColumn
                    Entry_Item Employee.IsSeasonal
                    Set pbEditable to True
                    Set pbCheckbox to True
                    Set piWidth to 49
                    Set psCaption to "Seasonal"
                End_Object

                Object oEmployee_CallCenterFlag is a cDbCJGridColumn
                    Entry_Item Employee.CallCenterFlag
                    Set pbCheckbox to True
                    Set peTextAlignment to xtpAlignCenter
                    Set piWidth to 55
                    Set psCaption to "Call Center"
                    Set pbEditable to False
                End_Object

                Object oEmployee_OperatorRate is a cDbCJGridColumn
                    Entry_Item Employee.OperatorRate
                    Set piWidth to 68
                    Set psCaption to "Operator Rate"
                    Set pbEditable to False
                End_Object

                Object oWebAppUserRights_Description is a cDbCJGridColumn
                    Entry_Item WebAppUserRights.Description
                    Set piWidth to 112
                    Set psCaption to "WebApp Rights"
                    Set pbEditable to False
                End_Object

                Object oEmployee_BillingAccessFlag is a cDbCJGridColumn
                    Entry_Item Employee.BillingAccessFlag
                    Set pbCheckbox to True
                    Set pbEditable to False
                    Set piWidth to 22
                    Set psCaption to "Billing"
                End_Object

                Procedure OnComRowDblClick Variant llRow Variant llItem
                    Forward Send OnComRowDblClick llRow llItem
                    Send DoEditEmployees of oEmployeeEntry (Current_Record(oEmployee_DD))
                End_Procedure

                Procedure Search
                    Handle hoCol
                    Get SelectedColumnObject to hoCol 
                    Send RequestColumnSearch hoCol 0 0
                End_Procedure

                Procedure Activating
                    Forward Send Activating
                    Set Value of oEmplStatusComboForm to "Active"
                    Send RefreshDataFromDD of oEmployeeGrid ropTop
                End_Procedure

//
//                Procedure Key Integer iKeyValue Returns Integer
//                    Integer iRetVal
//                    //>+65 and <=90 or >=97 & <=122
//                    If ((iKeyValue >= 65 and iKeyValue <=90) or (iKeyValue>=97 and iKeyValue <=122)) Begin
//                        Send Search
//                    End
//                    Forward Get msg_Key iKeyValue to iRetVal
//                    Procedure_Return iRetVal
//                End_Procedure

                On_Key Key_Ctrl+Key_F Send Search of oEmployeeGrid

            End_Object
            
        End_Object
    
    End_Object

    Procedure DoPrintEmployees
        Boolean bCancel bActive bInactive
        String sEmployerName
        //
        Get Field_Current_Value of oEmployer_DD Field Employer.Name to sEmployerName
        Get Checked_State of oStatusActiveCheckBox to bActive
        Get Checked_State of oStatusInactiveCheckBox to bInactive
        Send DoJumpStartReport of PrintEmployees sEmployerName bActive bInactive
    End_Procedure

    Procedure DoPrintEquipment
        Boolean bCancel bActive bInactive
        String sEmployerName
        //
        Get Field_Current_Value of oEmployer_DD Field Employer.Name to sEmployerName
        Get Checked_State of oActiveEquipmentCheckBox to bActive
        Get Checked_State of oInactiveEquipmentCheckBox to bInactive
        Get Confirm ("Print List for " * sEmployerName + "?")           to bCancel
        If (not(bCancel)) Begin
            Send DoJumpStartReport of PrintEquipment sEmployerName bActive bInactive
            
        End
    End_Procedure

    Procedure DoEditEmployers Integer iRecId
        Integer hoDD
        //
        Get Server to hoDD
        If (Changed_State(hoDD)) Begin
            Send Request_Save
        End
        Send Clear_All      of hoDD
        Send Find_By_Recnum of hoDD Employer.File_Number iRecId
        Send Activate_View
    End_Procedure

    
End_Object
