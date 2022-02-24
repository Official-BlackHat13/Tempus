Use Windows.pkg
Use DFClient.pkg
Use dfTable.pkg
Use MastOps.DD
Use Employer.DD
Use Equipmnt.DD
Use cDbTextEdit.pkg
Use cTempusDbView.pkg
Use cGlblDbForm.pkg
Use cGlblDbComboForm.pkg
Use cGlblDbGrid.pkg
Use OpersUpdateProcess.bp

Deferred_View Activate_oMastOps for ;
Object oMastOps is a cTempusDbView
    
    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oMastops_DD is a Mastops_DataDictionary
    End_Object

    Object oEquipmnt_DD is a Equipmnt_DataDictionary
        Set DDO_Server to oEmployer_DD
        Set Constrain_file to MastOps.File_number
        Set DDO_Server to oMastops_DD
    End_Object

    Set Main_DD to oMastops_DD
    Set Server to oMastops_DD

    Set Border_Style to Border_Thick
    Set Size to 228 490
    Set Location to 13 25
    Set label to "Master Operation Entry/Edit"
    Set piMinSize to 228 490

    Object oMastOps_MastOpsIdno is a cGlblDbForm
        Entry_Item MastOps.MastOpsIdno
        Set Location to 10 66
        Set Size to 13 54
        Set Label to "ID:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oMastOps_DisplaySequence is a cGlblDbForm
        Entry_Item MastOps.DisplaySequence
        Set Location to 10 224
        Set Size to 13 42
        Set Label to "DisplaySequence:"
    End_Object

    Object oMastOps_Name is a cGlblDbForm
        Entry_Item MastOps.Name
        Set Location to 25 66
        Set Size to 13 200
        Set Label to "Name:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oMastOps_SellRate is a cGlblDbForm
        Entry_Item MastOps.SellRate
        Set Location to 40 66
        Set Size to 13 54
        Set Label to "Sell Rate:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oMastOps_CostRate is a cGlblDbForm
        Entry_Item MastOps.CostRate
        Set Location to 55 66
        Set Size to 13 54
        Set Label to "Cost Rate:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oMastOps_QtyDivisor is a cGlblDbForm
        Entry_Item MastOps.QtyDivisor
        Set Location to 70 66
        Set Size to 13 54
        Set Label to "Qty Divisor:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 3
    End_Object

    Object oMastOps_QtyDescription is a cGlblDbForm
        Entry_Item MastOps.QtyDescription
        Set Location to 85 66
        Set Size to 13 54
        Set Label to "Qty Description:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 3
    End_Object

    Object oMastOps_CostType is a cGlblDbComboForm
        Entry_Item MastOps.CostType
        Set Location to 100 66
        Set Size to 13 80
        Set Label to "Cost Type:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oMastOps_CalcBasis is a cGlblDbComboForm
        Entry_Item MastOps.CalcBasis
        Set Location to 115 66
        Set Size to 13 80
        Set Label to "Calc Basis:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oMastOps_ActivityType is a cGlblDbComboForm
        Entry_Item MastOps.ActivityType
        Set Location to 130 66
        Set Size to 13 80
        Set Label to "Activity Type:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oMastOps_Description is a cDbTextEdit
        Entry_Item MastOps.Description
        Set Location to 100 200
        Set Size to 43 281
        Set Label to "Line Item Description:"

        Procedure Next
            If (Should_Save(Self)) Begin
                Send Request_Save
            End
            Forward Send Next
        End_Procedure

    End_Object

    Object oEquipmentGrid is a cGlblDbGrid
        Set Size to 65 471
        Set Location to 155 10
        Set Wrap_State to True
        Set Child_Table_State to True

        Begin_Row
            Entry_Item Equipmnt.EquipmentID
            Entry_Item Equipmnt.Description
            Entry_Item Employer.EmployerIdno
            Entry_Item Employer.Name
            Entry_Item Equipmnt.ContractorRate
            Entry_Item Equipmnt.EquipIdno
        End_Row

        Set Main_File to Equipmnt.File_number

        Set Server to oEquipmnt_DD

        Set Form_Width 0 to 70
        Set Header_Label 0 to "EquipmentID"

        Set Form_Width 1 to 140
        Set Header_Label 1 to "Description"

        Set Form_Width 2 to 0
        Set Header_Label 2 to ""
        Set Column_Shadow_State 2 to True

        Set Form_Width 3 to 140
        Set Header_Label 3 to "Operator Name"

        Set Form_Width 4 to 64
        Set Header_Label 4 to "Contractor Rate"

        Set Form_Width 5 to 48
        Set Header_Label 5 to "Equip ID"
        Set Column_Shadow_State 5 to True
        Set peAnchors to anAll
        Set peResizeColumn to rcSelectedColumn
        Set piResizeColumn to 1
    End_Object

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

