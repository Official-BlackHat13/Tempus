Use Windows.pkg
Use DFClient.pkg
Use for_all.pkg

Use MastOps.DD

Deferred_View Activate_oEquipmentUtility for ;
Object oEquipmentUtility is a dbView

    Set Border_Style to Border_Thick
    Set Size to 200 447
    Set Location to 2 2
    Set Label to "Equipment Utility"

    Object oInstructionTextBox is a TextBox
        Set Size to 10 413
        Set Location to 10 10
        Set Label to "Enter the old Master Operation ID in the first form and the new Master Operation ID in the second form and click the Process button"
    End_Object

    Object oForm1 is a Form
        Set Size to 13 50
        Set Location to 30 80
        Set Prompt_Button_Mode to PB_PromptOn
        Set Prompt_Object to MastOps_sl
        Set Label to "Original ID"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Form_Datatype to 0
    End_Object

    Object oForm2 is a Form
        Set Size to 13 50
        Set Location to 50 80
        Set Prompt_Button_Mode to PB_PromptOn
        Set Prompt_Object to MastOps_sl
        Set Label to "New ID"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Form_Datatype to 0
    End_Object

    Object oProcessButton is a Button
        Set Location to 75 80
        Set Label to "Process"
    
        Procedure OnClick
            Boolean bCancel
            Integer iOld iNew iCount
            //
            Get Value of oForm1 to iOld
            Get Value of oForm2 to iNew
            //
            Get Confirm ("Replace MastOps ID" * String(iOld) * "with MastOps ID" * String(iNew)) to bCancel
            If bCancel Procedure_Return
            //
            For_All Equipmnt by 3 as queue
                Constrain Equipmnt.MastOpsIdno eq iOld
                do
                    Reread Equipmnt
                    Move iNew to Equipmnt.MastOpsIdno
                    Move 1    to Equipmnt.ChangedFlag
                    SaveRecord Equipmnt
                    Unlock
                    Increment iCount
            End_For_All
            //
            Send Info_Box (String(iCount) * "changes")
        End_Procedure
    End_Object

Cd_End_Object
