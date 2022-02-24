Use Windows.pkg
Use DFClient.pkg
Use dfTable.pkg
Use cDbTextEdit.pkg
Use cTempusDbView.pkg
Use cGlblDbForm.pkg
Use cGlblDbComboForm.pkg
//Use cGlblDbGrid.pkg
Use OpersUpdateProcess.bp
Use cComDbSpellText.pkg
Use cGlblDbCheckBox.pkg
Use OperationsProcess.bp
Use MastOps.DD
Use Employer.DD
Use Equipmnt.DD
Use cWorkTypeGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use dfcentry.pkg
Use dfTabDlg.pkg
Use cDbCJGrid.pkg
Use dbSuggestionForm.pkg

Deferred_View Activate_oMastOps for ;
Object oMastOps is a cTempusDbView
    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD

        Procedure OnConstrain
//            Forward Send OnConstrain
//            // Constrain from Filter on SL
//            String sValue
//            Get Value of oWorkTypeCombo to sValue
//            Move (Ltrim(sValue)) to sValue
//            If ((Length(sValue))>1) Begin
//                Constrain MastOps.ActivityType eq sValue
//            End  
//            //Status
//            If (not(Checked_State(oActiveCheckBox(Self)))) Constrain MastOps.Status ne "A"
//            If (not(Checked_State(oInactiveCheckBox(Self)))) Constrain MastOps.Status ne "I"
//            If (not(Checked_State(oHiddenCheckBox(Self)))) Constrain MastOps.Status ne "H"
        End_Procedure
    End_Object

    Object oEquipmnt_DD is a Equipmnt_DataDictionary
        Set DDO_Server to oEmployer_DD
        Set Constrain_file to MastOps.File_number
        Set DDO_Server to oMastOps_DD
    End_Object

    Set Main_DD to oMastOps_DD
    Set Server to oMastOps_DD

    Set Border_Style to Border_Thick
    Set Size to 330 519
    Set Location to 2 4
    Set label to "Master Operation Entry/Edit"
    Set piMinSize to 243 474

    Object oDbTabDialog1 is a dbTabDialog
        Set Size to 324 513
        Set Location to 3 3
    
        Set Rotate_Mode to RM_Rotate
        Set peAnchors to anAll

        Object oDbTabPage1 is a dbTabPage
            Set Label to 'Single Item'


            Object oMastOps_Name is a DbSuggestionForm
                Entry_Item MastOps.Name
                Set Location to 8 66
                Set Size to 13 200
                Set Label_Col_Offset to 5
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopLeft
                Set Label to "Name:"
                Set pbFullText to True
                Set piStartAtChar to 2
            End_Object

            Object oMastOps_MastOpsIdno is a cGlblDbForm
                Entry_Item MastOps.MastOpsIdno
                Set Location to 8 270
                Set Size to 13 54
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopLeft
        
                Procedure Refresh Integer iMode
                    Boolean bIsAttachment
                    Forward Send Refresh iMode
                    Move (MastOps.CostType="Attachment") to bIsAttachment
                    //
                    Set Enabled_State of oAddToLocationsButton to (MastOps.Recnum)
                    Set Enabled_State of oUpdateSequenceButton to (MastOps.Recnum)
                    
                    //Set Enabled_State of oMastOps_IsAttachment to (bIsAttachment)
                    //Set Enabled_State of oMastOps_NeedsAttachment to (bIsAttachment)
                End_Procedure
            End_Object
            Object oMastOps_Status is a cGlblDbComboForm
                Entry_Item MastOps.Status
                Set Location to 14 413
                Set Size to 12 83
                Set Label to "Status:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopRight
            End_Object
            Object oWorkType_WorkTypeId is a cGlblDbForm
                Entry_Item WorkType.WorkTypeId
                Set Location to 23 66
                Set Size to 13 80
                Set Label to "WorkTypeId:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 5
                Set peAnchors to anTopLeft
            End_Object
            Object oMastOps_DisplaySequence is a cGlblDbForm
                Entry_Item MastOps.DisplaySequence
                Set Location to 23 244
                Set Size to 13 80
                Set Label to "DisplaySequence:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopLeft
            End_Object
            Object oMastOps_IsTaxable is a cGlblDbCheckBox
                Entry_Item MastOps.IsTaxable
                Set Location to 30 387
                Set Size to 10 60
                Set Label to "Is Taxable Item"
                Set peAnchors to anTopRight
            End_Object
            Object oMastOps_SellRate is a cGlblDbForm
                Entry_Item MastOps.SellRate
                Set Location to 41 413
                Set Size to 13 83
                Set Label to "Sell Rate:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopRight
            End_Object
            Object oMastOps_CostRate is a cGlblDbForm
                Entry_Item MastOps.CostRate
                Set Location to 38 244
                Set Size to 12 80
                Set Label to "Cost Rate:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopLeft
            End_Object
            Object oMastOps_QtyDivisor is a cGlblDbForm
                Entry_Item MastOps.QtyDivisor
                Set Location to 51 244
                Set Size to 13 80
                Set Label to "Qty Divisor:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                Set peAnchors to anTopLeft
            End_Object
            Object oMastOps_QtyDescription is a cGlblDbForm
                Entry_Item MastOps.QtyDescription
                Set Location to 65 244
                Set Size to 13 80
                Set Label to "Qty Description:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                Set peAnchors to anTopLeft
            End_Object
            Object oMastOps_CostType is a cGlblDbComboForm
                Entry_Item MastOps.CostType
                Set Location to 38 66
                Set Size to 12 80
                Set Label to "Cost Type:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopLeft
            End_Object
            Object oMastOps_CalcBasis is a cGlblDbComboForm
                Entry_Item MastOps.CalcBasis
                Set Location to 52 66
                Set Size to 12 80
                Set Label to "Calc Basis:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopLeft
            End_Object
            Object oMastOps_IsUniversal is a cGlblDbCheckBox
                Entry_Item MastOps.IsUniversal
                Set Location to 30 447
                Set Size to 10 60
                Set Label to "Is Universal"
                Set peAnchors to anTopRight
            End_Object
            Object oMastOps_ReportCategory is a cGlblDbComboForm
                Entry_Item MastOps.ReportCategory
                Set Location to 66 66
                Set Size to 12 80
                Set Label to "Report Category:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopLeft
            End_Object
            Object oEquipmentGrid is a DbGrid
                Set Size to 144 491
                Set Location to 158 9
                Set Wrap_State to True
                Set Child_Table_State to True
        
                Begin_Row
                    Entry_Item Equipmnt.EquipmentID
                    Entry_Item Equipmnt.Description
                    Entry_Item Employer.EmployerIdno
                    Entry_Item Employer.Name
                    Entry_Item Equipmnt.ContractorRate
                    Entry_Item Equipmnt.EquipIdno
                    Entry_Item Equipmnt.Status
                End_Row
        
                Set Main_File to Equipmnt.File_number
        
                Set Server to oEquipmnt_DD
        
                Set Form_Width 0 to 58
                Set Header_Label 0 to "EquipmentID"
        
                Set Form_Width 1 to 145
                Set Header_Label 1 to "Description"
        
                Set Form_Width 2 to 0
                Set Header_Label 2 to ""
                Set Column_Shadow_State 2 to True
        
                Set Form_Width 3 to 130
                Set Header_Label 3 to "Operator Name"
        
                Set Form_Width 4 to 64
                Set Header_Label 4 to "Contractor Rate"
                Set Column_Shadow_State 4 to True
        
                Set Form_Width 5 to 42
                Set Header_Label 5 to "Equip ID"
                Set Column_Shadow_State 5 to True
                Set Header_Justification_Mode 5 to JMode_Right
                Set Form_Width 6 to 50
                Set Header_Label 6 to "Status"
                Set Column_Combo_State 6 to True
                Set peAnchors to anAll
                Set peResizeColumn to rcSelectedColumn
                Set piResizeColumn to 1
        
                Function Child_Entering Returns Integer
                    Boolean bFail
                    //
                    Delegate Get IsValidMastOpRecord to bFail
                    //
                    Function_Return bFail // if non-zero do not enter
                End_Function // Child_Entering
        
            End_Object
            Object oMastOps_Description is a cComDbSpellText
                Entry_Item MastOps.Description
                Set Size to 46 490
                Set Location to 107 8
                Set Label to "Line Item Description:"
                Set Label_Justification_Mode to JMode_Top
                Set Label_Col_Offset to 0
                Set Auto_Clear_DEO_State to False
                Set peAnchors to anTopLeftRight
            
                Procedure OnCreate
                    Forward Send OnCreate
                    //Set the ActiveX properties here...
                    Set ComMaxLength to 2048
                End_Procedure
        
                Procedure Request_Save
                    Send Next
                End_Procedure
            
                Procedure OnComLosingFocus
                    String sText
                    //
                    If (Should_Save(Self)) Begin
                        Get ComText                                                      to sText
                        Set Field_Changed_Value of oMastops_DD Field MastOps.Description to sText
                        Delegate Send Request_Save
                    End
                End_Procedure
        
            End_Object
            Object oAddToLocationsButton is a Button
                Set Size to 14 115
                Set Location to 65 379
                Set Label to "Add Operation To All Locations"
                Set peAnchors to anTopRight
            
                Procedure OnClick
                    Send DoAddToAllLocations
                End_Procedure    
            End_Object
            Object oUpdateSequenceButton is a Button
                Set Size to 14 115
                Set Location to 81 379
                Set Label to "Update Opcode Sequences"
                Set peAnchors to anTopRight
            
                Procedure OnClick
                    Send DoUpdateOpcodeSequences
                End_Procedure
            End_Object
            Object oMastOps_IsAttachment is a cGlblDbComboForm
                Entry_Item MastOps.IsAttachment
                Set Location to 80 66
                Set Size to 12 80
                Set Label to "Is Attachment:"
                Set Label_Col_Offset to 5
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopLeft
            End_Object
            Object oMastOps_NeedsAttachment is a cGlblDbComboForm
                Entry_Item MastOps.NeedsAttachment
                Set Location to 80 244
                Set Size to 12 80
                Set Label to "Needs Attachment:"
                Set peAnchors to anTopLeft
            End_Object
        End_Object

//        Object oListTabPage is a dbTabPage
//            Set Label to 'Overview'
//
//            Object oMastOpsList is a cDbCJGrid
//                Set Size to 265 491
//                Set Location to 38 9
//                Set peAnchors to anAll
//                Set Ordering to 3
//
//                Object oMastOps_DisplaySequence1 is a cDbCJGridColumn
//                    Entry_Item MastOps.DisplaySequence
//                    Set piWidth to 86
//                    Set psCaption to "Seq."
//                End_Object
//
//                Object oMastOps_Name1 is a cDbCJGridColumn
//                    Entry_Item MastOps.Name
//                    Set piWidth to 442
//                    Set psCaption to "Name"
//                End_Object
//
//                Object oMastOps_ActivityType is a cDbCJGridColumn
//                    Entry_Item WorkType.WorkTypeId
//                    Set piWidth to 124
//                    Set psCaption to "ActivityType"
//                End_Object
//
//                Object oMastOps_Status1 is a cDbCJGridColumn
//                    Entry_Item MastOps.Status
//                    Set piWidth to 106
//                    Set psCaption to "Status"
//                    Set pbComboButton to True
//                End_Object
//
//                Object oMastOps_SellRate1 is a cDbCJGridColumn
//                    Entry_Item MastOps.SellRate
//                    Set piWidth to 101
//                    Set psCaption to "SellRate"
//                End_Object
//            End_Object
//
//            Object oStatusGroup is a Group
//                Set Size to 25 133
//                Set Location to 6 9
//                Set Label to 'Status'
//                Set peAnchors to anTopLeft
//        
//                Object oActiveCheckBox is a CheckBox
//                    Set Size to 10 38
//                    Set Location to 11 12
//                    Set Label to 'Active'
//                    Set Checked_State to True
//                
//                    //Fires whenever the value of the control is changed
//                    Procedure OnChange
//                        Boolean bChecked
//                        Get Checked_State to bChecked
//                        Send Rebuild_Constraints of oMastops_DD
//                        Send MovetoFirstRow to oMastOpsList
//                    End_Procedure
//                End_Object
//        
//                Object oInactiveCheckBox is a CheckBox
//                    Set Size to 10 50
//                    Set Location to 11 49
//                    Set Label to 'Inactive'
//                
//                    //Fires whenever the value of the control is changed
//                    Procedure OnChange
//                        Boolean bChecked
//                    
//                        Get Checked_State to bChecked
//                        Send Rebuild_Constraints of oMastops_DD
//                        Send MovetoFirstRow to oMastOpsList
//                    End_Procedure
//                
//                End_Object
//                
//                Object oHiddenCheckBox is a CheckBox
//                    Set Size to 10 50
//                    Set Location to 11 92
//                    Set Label to 'Hidden'
//                
//                    //Fires whenever the value of the control is changed
//                    Procedure OnChange
//                        Boolean bChecked
//                    
//                        Get Checked_State to bChecked
//                        Send Rebuild_Constraints of oMastops_DD
//                        Send MovetoFirstRow to oMastOpsList
//                    End_Procedure
//                
//                End_Object
//                
//            End_Object
//            Object oDbGroup1 is a dbGroup
//                Set Size to 25 135
//                Set Location to 6 153
//                Set Label to 'Activity Type Filter'
//        
//                Object oWorkTypeCombo is a dbComboForm
//                    Set Size to 14 100
//                    Set Entry_State to False
//                    Set Allow_Blank_State to False
//                    Set Location to 9 4
//                    Set Combo_Data_File to 74
//                    Set Code_Field to 1
//                    Set Combo_Index to 1
//                    Set Description_Field to 1
//                    Set Label to ""
//                    Set Label_Justification_Mode to JMode_Right
//                    Set Label_Col_Offset to 5
//                    
//                    Procedure OnChange
//                        Send Rebuild_Constraints of oMastops_DD
//                        Send MovetoFirstRow to oMastOpsList
//                    End_Procedure
//                End_Object
//                
//                Object oButton1 is a Button
//                    Set Size to 15 25
//                    Set Location to 8 106
//                    Set Label to 'Clear'
//                
//                    // fires when the button is clicked
//                    Procedure OnClick
//                        //Clear Value in Filter
//                        Set Value of oWorkTypeCombo to ""
//                    End_Procedure
//                
//                End_Object
//            End_Object
//        End_Object
    End_Object

    Procedure DoAddToAllLocations
        If (HasRecord(oMastops_DD)) Begin
            Boolean bCancel
            Integer iErrors iCreated
            //
            Get Confirm "An operation record will be created for all locations that have an Open Order.  Continue?" to bCancel
            If (bCancel) Procedure_Return
            //
            Send Refind_Records              of oMastops_DD
            Get DoAddOperationToAllLocations of oOperationsProcess MastOps.MastOpsIdno (&iErrors) to iCreated
            Send Info_Box (String(iCreated) * "records created." * String(iErrors) * "errors.")
        End
    End_Procedure

    Procedure DoUpdateOpcodeSequences
        If (HasRecord(oMastops_DD)) Begin
            Boolean bCancel
            //
            Send Request_Save
            //
            Get Confirm "Update the sequence number in all Location Operation codes?" to bCancel
            If (bCancel) Procedure_Return
            //
            Send Cursor_Wait    of Cursor_Control
            Send Refind_Records of oMastops_DD
            Clear Opers
            Move MastOps.MastOpsIdno to Opers.MastOpsIdno
            Find ge Opers.MastOpsIdno
            While ((Found) and Opers.MastOpsIdno = MastOps.MastOpsIdno)
                Reread Opers
               //If (Opers.CustomerIdno= "1325") Begin
                Move MastOps.DisplaySequence to Opers.DisplaySequence
                SaveRecord Opers
                Unlock
               // End
                Find gt Opers.MastOpsIdno
            Loop
            Send Cursor_Ready of Cursor_Control
        End
    End_Procedure

    Function IsValidMastOpRecord Returns Boolean
        Boolean bHasRecord bChanged bFail
        Handle  hoDD
        //
        Get Server            to hoDD
        Get HasRecord of hoDD to bHasRecord
        Get Should_Save       to bChanged    
        // If there is no record and no changes we have an error.
        Move (not(bHasRecord) and not(bChanged)) to bFail
        If (bFail) Begin
            Send UserError "You must First Create & Save a MastOps record" ""
        End
        Else Begin
            Send Request_Save
            Get Should_Save       to bChanged
            Get HasRecord of hoDD to bHasRecord
            Move (not(bHasRecord) or (bChanged)) to bFail
        End
        Function_Return bFail
    End_Function

    Procedure Request_Save
        Boolean bNew bCancel
        //
        Move (not(HasRecord(oMastops_DD))) to bNew
        //
        Forward Send Request_Save
        //
        If (MastOps.Recnum and bNew) Begin
            Get Confirm "Mass create Operation records for all locations?" to bCancel
            If (not(bCancel)) Begin
                Send DoMassCreateOperations of oOpersUpdateProcess MastOps.MastOpsIdno
            End
        End
    End_Procedure

Cd_End_Object

