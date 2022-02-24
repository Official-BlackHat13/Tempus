Use Windows.pkg
Use DFClient.pkg
Use dfLine.pkg
Use dfTable.pkg
Use DFEntry.pkg
Use cDbTextEdit.pkg
Use Customer.DD
Use Location.DD
Use MastOps.DD
Use Opers.DD
Use Areas.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use cTempusDbView.pkg
Use cGlblDbForm.pkg

Use OpersProcess.bp
Use OperationsProcess.bp
Use dfallent.pkg
Use dbSuggestionForm.pkg


Deferred_View Activate_oOperationsEntry for ;
Object oOperationsEntry is a cTempusDbView
        
    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oMastops_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
        Send DefineAllExtendedFields
        
        Procedure OnConstrain
            String sValue
            Get Value of oWorkTypeCombo to sValue
            Move (Ltrim(sValue)) to sValue
            If ((Length(sValue))>1) Begin
                Constrain MastOps.ActivityType eq sValue
            End
            
        End_Procedure       
        
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Send DefineAllExtendedFields
        Set Constrain_file to Location.File_number
        Set DDO_Server to oMastops_DD
        Set DDO_Server to oLocation_DD
        
        Procedure OnConstrain
            //Status
            If (not(Checked_State(oActiveCheckBox(Self)))) Constrain Opers.Status ne "A"
            If (not(Checked_State(oInactiveCheckBox(Self)))) Constrain Opers.Status ne "I"
            If (not(Checked_State(oHiddenCheckBox(Self)))) Constrain Opers.Status ne "H"
//            //ActivityType
//            If (not(Checked_State(oSnowRemovalCheckBox(Self)))) Constrain Opers.ActivityType ne "Snow Removal"
//            If (not(Checked_State(oPavementCheckBox(Self)))) Constrain Opers.ActivityType ne "Pavement Mnt."
//            If (not(Checked_State(oConcreteCheckBox(Self)))) Constrain Opers.ActivityType ne "Concrete"
//            If (not(Checked_State(oSweepingCheckBox(Self)))) Constrain Opers.ActivityType ne "Sweeping"
//            If (not(Checked_State(oExcavatingCheckBox(Self)))) Constrain Opers.ActivityType ne "Excavation"
//            If (not(Checked_State(oOtherCheckBox(Self)))) Constrain Opers.ActivityType ne "Other"
        End_Procedure
        
    End_Object

    Set Main_DD to oLocation_DD
    Set Server to oLocation_DD

    Set Border_Style to Border_Thick
    Set Size to 278 591
    Set Location to 4 4
    Set Label to "Operations Entry/Edit"
    Set piMinSize to 250 530
    Set Maximize_Icon to True

    Object oLocationContainer is a dbContainer3d
        Set Size to 45 581
        Set Location to 3 5
        Set peAnchors to anTopLeftRight

        Object oCustomer_Name is a DbSuggestionForm
            Entry_Item Customer.Name
            Set Location to 3 64
            Set Size to 13 349
            Set Label to "Customer Name:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
            Set peAnchors to anTopLeftRight
            Set piStartAtChar to 1
            Set pbFullText to True
            Set piMaxResults to 10
        End_Object

        Object oCustomer_CustomerIdno is a dbForm
            Entry_Item Customer.CustomerIdno
            Set Location to 3 420
            Set Size to 13 42
            Set peAnchors to anTopRight
        End_Object

        Object oLineControl1 is a LineControl
            Set Size to 1 451
            Set Location to 20 10
            Set peAnchors to anTopLeftRight
        End_Object

        Object oLocation_Name is a DbSuggestionForm
            Entry_Item Location.Name
            Set Location to 25 64
            Set Size to 13 349
            Set Label to "Location Name:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
            Set peAnchors to anTopLeftRight
            Set piStartAtChar to 1
            Set pbFullText to True
            Set piMaxResults to 10

            Procedure Prompt_Callback Integer hPrompt
                Set Auto_Server_State of hPrompt to True
            End_Procedure
            
            Procedure Refresh Integer notifyMode
                Boolean bHasLocRec
                Get HasRecord of oLocation_DD to bHasLocRec
                Forward Send Refresh notifyMode
                //
                Set Enabled_State of oAddButton to (bHasLocRec)
                Set Enabled_State of oPrintButton to (bHasLocRec)
//                Set Enabled_State of oCloneButton to (bHasLocRec)
                Set Enabled_State of oCopyButton to (bHasLocRec)
                Set Enabled_State of oOperationsGrid to (bHasLocRec)
                Boolean bHasSlsRights bHasOpsRights bHasOpsSpecialRights bHasAdmRights bHasSysAdmRights
                //
                // RIGHTS
                Move (giUserRights>=50 and giUserRights <=59) to bHasSlsRights
                Move (giUserRights>=60 and giUserRights <=64) to bHasOpsRights
                Move (giUserRights>=65) to bHasOpsSpecialRights
                Move (giUserRights>=70 and giUserRights <=79) to bHasAdmRights
                Move (giUserRights>=90) to bHasSysAdmRights
                //
                Set Column_Shadow_State of oOperationsGrid 4 to (bHasOpsRights) 
                Set Read_Only_State of oOpers_Description to (bHasOpsRights)
            End_Procedure
        End_Object

        Object oLocation_LocationIdno is a dbForm
            Entry_Item Location.LocationIdno
            Set Location to 25 420
            Set Size to 13 42
            Set peAnchors to anTopRight

            Procedure Prompt_Callback Integer hPrompt
                Set Auto_Server_State of hPrompt to True
            End_Procedure
            
            
        End_Object

        Object oDbGroup2 is a dbGroup
            Set Size to 31 100
            Set Location to 4 470
            Set Label to 'Populate from other Location'
            Set peAnchors to anTopRight

//            Object oCloneButton is a Button
//                Set Size to 14 57
//                Set Location to 10 9
//                Set Label to "Clone"
//                Set peAnchors to anTopRight
//        
//                Procedure OnClick
//                    Send DoCloneOperations of oOperationsEntry
//                End_Procedure
//        
//            End_Object

            Object oCopyButton is a Button
                Set Size to 14 83
                Set Location to 11 7
                Set Label to 'Copy Records'
                Set peAnchors to anTopRight

                Procedure OnClick
                    Forward Send OnClick
                    Integer iCopyFromLocIdno iCopyToLocIdno
                    Integer eResponse
                    String sErrMsg
                    Boolean bSuccess bOverwrite
                    //
                    If (not(HasRecord(oLocation_DD))) Begin
                        Send UserError ("No Location record selected.") "Error"
                        Procedure_Return
                    End
                    //
                    Get Field_Current_Value of oLocation_DD Field Location.LocationIdno to iCopyToLocIdno
                    //2.    Select CopyFrom LocationRecord
                    Get IsSelectedLocation of Location_sl 0  to iCopyFromLocIdno
                    If (iCopyFromLocIdno = 0) Begin
                        Send UserError "You have not selected a Location - please try again." "Error"
                        Procedure_Return
                    End
                    //
                    Move (YesNoCancel_Box("Overwrite Existing records?")) to eResponse
                    If (eResponse=MBR_Yes) Move True to bOverwrite
                    If (eResponse=MBR_No) Move False to bOverwrite
                    If (eResponse=MBR_Cancel) Procedure_Return
                    //
                    Get CopyOpersRecords of oOpersProcess iCopyFromLocIdno iCopyToLocIdno bOverwrite (&sErrMsg) to bSuccess
                    If (not(bSuccess)) Begin
                        Send UserError sErrMsg "Error"
                    End
                    // Reload view
                    If bSuccess Begin
                        Send Info_Box sErrMsg "Copying completed"
                    End
                    //Send Request_Clear_All of oOperationsGrid
                    Send Beginning_of_Data of oOperationsGrid
                End_Procedure
                
                
            End_Object
            
//            Object oCopyOLDButton is a Button
//                Set Size to 14 57
//                Set Location to 10 71
//                Set Label to 'Copy'
//                Set peAnchors to anTopRight
//            
//                // fires when the button is clicked
//                Procedure OnClick
//                    Integer iCopyFromLocIdno iCopyToLocIdno
//                    Boolean bCancel
//                            
//                    If (not(HasRecord(oLocation_DD))) Begin
//                        Procedure_Return
//                    End
//                    Else Begin
//                        Get Field_Current_Value of oLocation_DD Field Location.LocationIdno to iCopyToLocIdno
//                    End
//                    //            
//                    Get IsSelectedLocation of Location_sl 0  to iCopyFromLocIdno
//                    //
//                    If (iCopyFromLocIdno = 0) Begin
//                        Send Stop_Box "You have not selected a Location - please try again."
//                        Procedure_Return
//                    End
//                    If (iCopyToLocIdno = iCopyFromLocIdno) Begin
//                        Send Stop_Box "You have selected the same Location, please select a different Location."
//                        Procedure_Return
//                    End
//                    //
//                    Get Confirm ("Copy operations from" * String(iCopyFromLocIdno) * "and overwrite to" * String(iCopyToLocIdno) * "?") to bCancel
//                    If (bCancel) Begin
//                        Procedure_Return
//                    End
//                    
//                    Send DoCopyPriceAndDescriptionFromSource of oOperationsEntry iCopyFromLocIdno iCopyToLocIdno
//                    //Get DoCopyPriceAndDescriptionFromSource of oOperationsProcess to iReturnCounter
//                    Send Beginning_of_Data of oOperationsGrid
//                    Send Beginning_of_Panel
//    
//                End_Procedure
//            
//            End_Object
        End_Object
    

    
        
        Function IsExistingOperation Integer iLocationIdno Integer iMastOpsIdno Returns Boolean
            Open Opers
            Clear Opers
            Move iLocationIdno to Opers.LocationIdno
            Find GE Opers.LocationIdno
            While (Found)
                Move iMastOpsIdno to Opers.MastOpsIdno
                Find GE Opers.MastOpsIdno
                If ((Found) and Opers.LocationIdno eq iLocationIdno) Begin
                    Showln "MastOps Exsists"
                    Function_Return True
                End
                Else Begin
                    Showln "MastOps - Does NOT Exsist"
                    Function_Return False           
                End
                Find GT Opers.LocationIdno
            Loop
        End_Function

    End_Object
    
    Object oStatusGroup is a Group
        Set Size to 24 133
        Set Location to 51 5
        Set Label to 'Status'
        Set peAnchors to anTopLeft

        Object oActiveCheckBox is a CheckBox
            Set Size to 10 38
            Set Location to 11 12
            Set Label to 'Active'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOperationsGrid FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOperationsGrid
            End_Procedure
        End_Object

        Object oInactiveCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 11 49
            Set Label to 'Inactive'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
                Send Refresh of oOperationsGrid FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOperationsGrid
            End_Procedure
        
        End_Object
        
        Object oHiddenCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 11 92
            Set Label to 'Hidden'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
                Send Refresh of oOperationsGrid FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOperationsGrid
            End_Procedure
        
        End_Object
        
    End_Object
    
//    Object oActivityTypeGroup is a Group
//        Set Size to 25 474
//        Set Location to 60 101
//        Set Label to 'ActivityType'
//
//        Object oSnowRemovalCheckBox is a CheckBox
//            Set Size to 10 38
//            Set Location to 11 12
//            Set Label to 'Snow Removal'
//            Set Checked_State to True
//        
//            //Fires whenever the value of the control is changed
//            Procedure OnChange
//                Boolean bChecked
//                Get Checked_State to bChecked
//                Send Refresh of oOperationsGrid FILL_FROM_BOTTOM
//                Send Beginning_of_Data of oOperationsGrid
//            End_Procedure
//        End_Object
//
//        Object oPavementCheckBox is a CheckBox
//            Set Size to 10 38
//            Set Location to 11 85
//            Set Label to 'Pavement'
//            Set Checked_State to True
//        
//            //Fires whenever the value of the control is changed
//            Procedure OnChange
//                Boolean bChecked
//            
//                Get Checked_State to bChecked
//                Send Refresh of oOperationsGrid FILL_FROM_BOTTOM
//                Send Beginning_of_Data of oOperationsGrid
//            End_Procedure
//        
//        End_Object
//
//        Object oConcreteCheckBox is a CheckBox
//            Set Size to 10 50
//            Set Location to 11 145
//            Set Label to 'Concrete'
//            Set Checked_State to True
//        
//            //Fires whenever the value of the control is changed
//            Procedure OnChange
//                Boolean bChecked
//            
//                Get Checked_State to bChecked
//                Send Refresh of oOperationsGrid FILL_FROM_BOTTOM
//                Send Beginning_of_Data of oOperationsGrid
//            End_Procedure
//        
//        End_Object
//
//        Object oSweepingCheckBox is a CheckBox
//            Set Size to 10 38
//            Set Location to 11 205
//            Set Label to 'Sweeping'
//            Set Checked_State to True
//        
//            //Fires whenever the value of the control is changed
//            Procedure OnChange
//                Boolean bChecked
//                Get Checked_State to bChecked
//                Send Refresh of oOperationsGrid FILL_FROM_BOTTOM
//                Send Beginning_of_Data of oOperationsGrid
//            End_Procedure
//        End_Object
//        
//        Object oExcavatingCheckBox is a CheckBox
//            Set Size to 10 38
//            Set Location to 11 262
//            Set Label to 'Excavating'
//            Set Checked_State to True
//        
//            //Fires whenever the value of the control is changed
//            Procedure OnChange
//                Boolean bChecked
//            
//                Get Checked_State to bChecked
//                Send Refresh of oOperationsGrid FILL_FROM_BOTTOM
//                Send Beginning_of_Data of oOperationsGrid
//            End_Procedure
//        
//        End_Object
//        
//        Object oOtherCheckBox is a CheckBox
//            Set Size to 10 38
//            Set Location to 11 316
//            Set Label to 'Other'
//            Set Checked_State to True
//        
//            //Fires whenever the value of the control is changed
//            Procedure OnChange
//                Boolean bChecked
//            
//                Get Checked_State to bChecked
//                Send Refresh of oOperationsGrid FILL_FROM_BOTTOM
//                Send Beginning_of_Data of oOperationsGrid
//            End_Procedure
//        
//        End_Object
//    End_Object

    
    Object oOperationsGrid is a dbGrid
        Set Server to oOpers_DD
        Set Size to 149 581
        Set Location to 79 5
        Set Ordering to 5
        Set No_Delete_State to True
        
        Set Main_File to Opers.File_number

        Begin_Row
            Entry_Item Location.LocationIdno
            Entry_Item MastOps.MastOpsIdno
            Entry_Item Opers.DisplaySequence
            Entry_Item MastOps.Name
            Entry_Item Opers.SellRate
            Entry_Item MastOps.CostType
            Entry_Item MastOps.ActivityType
            Entry_Item Opers.Status
            Entry_Item Opers.ExcludeCostFlag
            Entry_Item Opers.MonthlyItemFlag
            Entry_Item MastOps.NeedsAttachment
        End_Row

        Set Form_Width 0 to 1
        Set Column_Shadow_State item 0 to True
        Set Header_Label 1 to "Oper#"
        Set Form_Width 1 to 30
        Set Column_Shadow_State 1 to True
        Set Header_Justification_Mode 2 to JMode_Right
        Set Header_Label 3 to "Item Name"
        Set Column_Shadow_State 3 to False
        Set Form_Width 3 to 176
        Set Form_Width 4 to 42
        Set Header_Label 4 to "Sell rate"
        Set Form_Width 5 to 44
        Set Header_Label 5 to "Cost type"
        Set Column_Combo_State 5 to True
        Set Form_Width 6 to 64
        Set Header_Label 6 to "Activity type"
        Set Column_Combo_State 6 to True
        Set Form_Width 2 to 30
        Set Header_Label 2 to "Seq"
        Set Form_Width 7 to 43
        Set Header_Label 7 to "Status"
        Set Column_Combo_State 7 to True
        Set Form_Width 8 to 33
        Set Header_Label 8 to "No Cost"
        Set Column_Checkbox_State 8 to True
        Set Column_Shadow_State 8 to (giUserRights<=69)
        Set Form_Width 9 to 40
        Set Header_Label 9 to "Monthly"
        Set Column_Checkbox_State 9 to True
        //Set Column_Shadow_State 9 to (giUserRights<60)
        Set Form_Width 10 to 77
        Set Header_Label 10 to "NeedsAttachment"
        Set Column_Combo_State 10 to True
        Set Column_Shadow_State 10 to True
        Set peAnchors to anAll
        Set pbHeaderTogglesDirection to True
        Set pbUseServerOrdering to True
        Set Allow_Insert_Add_State to False
        Set Prompt_Button_Mode to PB_PromptOff
        
        Procedure AddNewOpersItem
            Send Activate of oOperationsGrid
            Send Move_to_Column of oOperationsGrid 3
            Send End_of_Data of oOperationsGrid
            Send Down of oOperationsGrid
            //Send Add_New_Row 0
            Send Prompt
        End_Procedure
        
        Procedure Prompt
            Integer iCol
            String  sDescription
            //
            Get Current_Col of oOperationsGrid to iCol
            //
            If (iCol = 1 or iCol = 3) Begin
                Send Popup of Mastops_sl
            End
            Else Begin
                Forward Send Prompt
            End
            //
            If ((iCol = 1 or iCol=3) and HasRecord(oMastops_DD) and not(HasRecord(oOpers_DD))) Begin
                Set Field_Changed_Value of oOpers_DD Field Opers.Name            to MastOps.Name
                Set Field_Changed_Value of oOpers_DD Field Opers.SellRate        to MastOps.SellRate
                Set Field_Changed_Value of oOpers_DD Field Opers.CostRate        to MastOps.CostRate
                Set Field_Changed_Value of oOpers_DD Field Opers.CostType        to MastOps.CostType
                Set Field_Changed_Value of oOpers_DD Field Opers.CalcBasis       to MastOps.CalcBasis
                Set Field_Changed_Value of oOpers_DD Field Opers.ActivityType    to MastOps.ActivityType
                Set Field_Changed_Value of oOpers_DD Field Opers.Description     to MastOps.Description
                Set Field_Changed_Value of oOpers_DD Field Opers.DisplaySequence to MastOps.DisplaySequence
                Get Field_Current_Value of oOpers_DD Field Opers.Description     to sDescription
                Set Value               of oOpers_Description                    to sDescription
            End
//            If (iCol = 3 and HasRecord(oMastops_DD) and not(HasRecord(oOpers_DD))) Begin
//                Set Field_Changed_Value of oOpers_DD Field Opers.Name            to MastOps.Name
//                Set Field_Changed_Value of oOpers_DD Field Opers.SellRate        to MastOps.SellRate
//                Set Field_Changed_Value of oOpers_DD Field Opers.CostRate        to MastOps.CostRate
//                Set Field_Changed_Value of oOpers_DD Field Opers.CostType        to MastOps.CostType
//                Set Field_Changed_Value of oOpers_DD Field Opers.CalcBasis       to MastOps.CalcBasis
//                Set Field_Changed_Value of oOpers_DD Field Opers.ActivityType    to MastOps.ActivityType
//                Set Field_Changed_Value of oOpers_DD Field Opers.Description     to MastOps.Description
//                Set Field_Changed_Value of oOpers_DD Field Opers.DisplaySequence to MastOps.DisplaySequence
//                Get Field_Current_Value of oOpers_DD Field Opers.Description     to sDescription
//                Set Value               of oOpers_Description                    to sDescription
//            End
        End_Procedure

        Procedure Prompt_Callback Handle hoPrompt
            Forward Send Prompt_Callback hoPrompt
        End_Procedure

        Procedure Next
            Forward Send Next
        End_Procedure
        
        Procedure Refresh Integer notifyMode
            Forward Send Refresh notifyMode
            
            Send Rebuild_Constraints of oOpers_DD
        End_Procedure

        Function Child_Entering Returns Integer
            Integer iRetVal
            Forward Get Child_Entering to iRetVal
            
            Boolean bCustFail bLocFail
            Move (not(HasRecord(oCustomer_DD)) ) to bCustFail
            If (bCustFail) Begin
                Send Stop_Box "No Customer selected"
                Function_Return 1
            End
            Move (not(HasRecord(oLocation_DD)) ) to bLocFail
            If (bLocFail) Begin
                Send Stop_Box "No Customer and Location selected"
            End      
            
            Function_Return iRetVal
        End_Function


        
    End_Object

    Object oOpers_Description is a cDbTextEdit
        Entry_Item Opers.Description
        Set Server to oOpers_DD
        Set Location to 240 5
        Set Size to 31 581
        Set Label to "Description:"
        Set peAnchors to anBottomLeftRight

        Procedure Next
            If (Should_Save(Self)) Begin
                Send Request_Save
            End
            Send Activate    of oOperationsGrid
            Send Down_Row    of oOperationsGrid
            Set Current_Item of oOperationsGrid to (Base_Item(oOperationsGrid))
        End_Procedure
    End_Object

    Object oDbGroup1 is a dbGroup
        Set Size to 25 140
        Set Location to 51 143
        Set Label to 'Activity Type Filter'
        Set peAnchors to anTopLeft

        Object oWorkTypeCombo is a dbComboForm
            Set Size to 12 100
            Set Entry_State to False
            Set Allow_Blank_State to False
            Set Location to 9 7
            Set Combo_Data_File to 74
            Set Code_Field to 1
            Set Combo_Index to 1
            Set Description_Field to 1
            Set Label to ""
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 5
            
            Procedure OnChange
                Send Rebuild_Constraints of oMastops_DD
                Send Refresh of oOperationsGrid FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOperationsGrid
                Send Activate of oOperationsGrid
            End_Procedure
        End_Object
        
        Object oButton1 is a Button
            Set Size to 14 25
            Set Location to 8 109
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oWorkTypeCombo to ""
            End_Procedure
        
        End_Object
    End_Object

        Procedure DoCloneOperations
            Boolean bCancel bFail bIsExistingOpers
            Integer hoDD iCloneToLocId iCloneFromLocId iRecId iMastOpsIdno iOverwrite
            
            Number nTemp
            String sTemp
            
            //
            If (not(HasRecord(oLocation_DD))) Begin
                Procedure_Return
            End
            //
            Get Current_Record     of oLocation_DD to iCloneToLocId
            Get IsSelectedLocation of Location_sl 0  to iCloneFromLocId
            If (iCloneFromLocId = 0) Begin
                Send Stop_Box "You have not selected a Location - please try again."
                Procedure_Return
            End
            If (iCloneFromLocId = iCloneToLocId) Begin
                Send Stop_Box "You have selected the same Location, please select a different Location."
                Procedure_Return
            End
            //
            Get Confirm "Clone operations?" to bCancel
            If (bCancel) Begin
                Procedure_Return
            End
            //
            Move oOpers_DD to hoDD
            Send Refind_Records of hoDD
            Send Clear          of hoDD
            //
            Move iCloneFromLocId to Opers.LocationIdno
            Find GE Opers by Index.4
            While ((Found) and Opers.LocationIdno = iCloneFromLocId)
                              
                Move Opers.Recnum                                           to iRecId
                Move Opers.MastOpsIdno                                      to MastOps.MastOpsIdno
                Send Request_Find       of hoDD EQ MastOps.File_Number 1
                Set Field_Changed_Value of hoDD Field Opers.Name            to Opers.Name
                Set Field_Changed_Value of hoDD Field Opers.SellRate        to Opers.SellRate
                Set Field_Changed_Value of hoDD Field Opers.CostRate        to Opers.CostRate
                Set Field_Changed_Value of hoDD Field Opers.CostType        to Opers.CostType
                Set Field_Changed_Value of hoDD Field Opers.CalcBasis       to Opers.CalcBasis
                Set Field_Changed_Value of hoDD Field Opers.ActivityType    to Opers.ActivityType
                Set Field_Changed_Value of hoDD Field Opers.Description     to Opers.Description
                Set Field_Changed_Value of hoDD Field Opers.Display         to Opers.Display
                Set Field_Changed_Value of hoDD Field Opers.DisplaySequence to Opers.DisplaySequence
                
                Get Request_Validate    of hoDD                                to bFail
                
                Get Field_Current_Value of hoDD Opers.Name to sTemp
                Get Field_Current_Value of hoDD Opers.SellRate to nTemp
                
                
                If bFail Begin
                    Get YesNo_Box ("Operation"*Opers.Name*"already exists - would you like to overwrite description and pricing for this item?") to iOverwrite
//                    If (iOverwrite = MBR_YES) Begin
//                        Showln ("Here it would go and find the Opers record" * Opers.MastOpsIdno* "-" * Opers.Name * " from" * iCloneFromLocId * "and write it to" * iCloneToLocId ) 
//                    End                      
                End
                If not bFail Begin
                    Send Refind_Records of hoDD
                    Send Request_Save   of hoDD
                    Send Clear          of hoDD
                End
                
                //
                Move iRecId to Opers.Recnum
                Find EQ Opers.Recnum
                Find GT Opers by Index.4
            Loop
            Send Beginning_of_Data of oOperationsGrid
            Send Beginning_of_Panel
        End_Procedure



        Procedure DoCopyPriceAndDescriptionFromSource Integer iCopyFromLocIdno Integer iCopyToLocIdno
            Boolean bCancel bFail bIsExistingOpers
            Integer iMastOpsIdno iOverwrite iRecId
            //          
            Number nTempSellRate nTempCostRate nTempDisplay nTempDisplaySequence
            String sTempName sTempCostType sTempCalcBasis sTempActivityType sTempDescription 
            String sTempStatus
            //
            Clear Opers
            Move iCopyFromLocIdno to Opers.LocationIdno
            Find GE Opers by Index.4
            While ((Found) and Opers.LocationIdno = iCopyFromLocIdno) 
                Move Opers.Recnum to iRecId
                Move Opers.MastOpsIdno to iMastOpsIdno    
                Showln ("LocationID:" * String(Opers.LocationIdno) * "MastOps:" * String(Opers.MastOpsIdno))
                //
                Move Opers.Name to sTempName
                Move Opers.SellRate to nTempSellRate
                Move Opers.CostRate to nTempCostRate
                Move Opers.CalcBasis to sTempCalcBasis
                Move Opers.ActivityType to sTempActivityType
                Move Opers.Description to sTempDescription
                Move Opers.Status to sTempStatus
                Move Opers.Display to nTempDisplay
                Move Opers.DisplaySequence to nTempDisplaySequence
                
                Clear Opers
                Move iCopyToLocIdno to Opers.LocationIdno
                Move iMastOpsIdno to Opers.MastOpsIdno
                Find EQ Opers by Index.4
                If ((Found) and Opers.LocationIdno = iCopyToLocIdno and Opers.MastOpsIdno = iMastOpsIdno) Begin
                    Reread Opers
                    //Relate Opers
                        Move sTempName to Opers.Name
                        Move nTempSellRate to Opers.SellRate
                        Move nTempCostRate to Opers.CostRate
                        Move sTempCalcBasis to Opers.CalcBasis
                        Move sTempDescription to Opers.Description
                        Move sTempStatus to Opers.Status
                        Move nTempDisplay to Opers.Display
                        Move nTempDisplaySequence to Opers.DisplaySequence
                        Move 1 to Opers.ChangedFlag
                        SaveRecord Opers  
                    Unlock
                End
                If (not(Found)) Begin
                    Showln ("LocationID:" * String(Opers.LocationIdno) * "MastOps:" * String(Opers.MastOpsIdno) * "was not found, please add this one manually")
                    //Send Info_Box ("MastOps" * String(Opers.MastOpsIdno) * " - " * Opers.Name * "was not found and needs to be added manually")
                End
                // 
                Send Find_By_Recnum of oOpers_DD Opers.File_Number iRecId
                //
                Move iCopyFromLocIdno to Opers.LocationIdno
                //Move iMastOpsIdno to Opers.MastOpsIdno
                Find GT Opers by Index.4
            Loop
        End_Procedure

        Object oPrintButton is a Button
            Set Size to 14 38
            Set Location to 58 544
            Set Label to "Print"
            Set peAnchors to anTopRight
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoPrintOperations
            End_Procedure
        End_Object

        Object oAddButton is a Button
            Set Size to 14 38
            Set Location to 58 503
            Set Label to 'Add'
            Set peAnchors to anTopRight
        
            // fires when the button is clicked
            Procedure OnClick
                Send AddNewOpersItem of oOperationsGrid
            End_Procedure
        
        End_Object


    Procedure DoPrintOperations   
        Boolean bCancel
        Integer iRefId
        //
        Get Field_Current_Value of oLocation_DD Field Location.LocationIdno to iRefId
        Get Confirm ("Print Operations List" * String(iRefId) + "?")       to bCancel
        If (not(bCancel)) Begin
            Send DoJumpStartReport of LocationPricing iRefId
        End       
    End_Procedure
   
//    Procedure DoProcessOpersUpdate
//        Boolean bCancel
//        //
//        If (Should_Save(Self)) Begin
//            Send Stop_Box "Please save your changes and try again"
//            Procedure_Return
//        End
//        //
//        Get Confirm "Update Opers Description & Display Sequence to MastOps values?" to bCancel
//        If bCancel Procedure_Return
//        //
//        Send Request_Clear_All
//        Send DoProcess of oOpersProcess
//    End_Procedure
    //
    //On_Key Key_Alt+Key_F1 Send DoProcessOpersUpdate

Cd_End_Object
