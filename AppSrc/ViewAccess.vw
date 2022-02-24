// D:\Development Projects\VDF19.1 Workspaces\Tempus\AppSrc\WebAppViewAccess.vw
// WebAppViewAccess
//
Use WebAppUserRights.sl

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use cViewAccessDataDictionary.dd
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg

Activate_View Activate_oViewAccess for oViewAccess
Object oViewAccess is a cGlblDbView
    Set Location to 5 5
    Set Size to 232 562
    Set Label to "ViewAccess"
    Set Border_Style to Border_Thick

    Property String psAppFilter

    Object oViewAccess_DD is a cViewAccessDataDictionary

        Procedure OnConstrain
            Forward Send OnConstrain
            String sAppFilter
            Get psAppFilter of oViewAccess to sAppFilter
            If (Length(sAppFilter)>0) Begin
                Constrain ViewAccess.Application eq sAppFilter
            End
        End_Procedure

    End_Object 

    Set Main_DD to oViewAccess_DD
    Set Server  to oViewAccess_DD

    Object oFilterGroup is a dbGroup
        Set Size to 30 553
        Set Location to 3 2
        Set Label to 'Filter'
        Set peAnchors to anTopLeftRight

        Object oAppFilterCombo is a ComboForm
            Set Size to 12 100
            Set Entry_State to True
            Set Allow_Blank_State to True
            Set Location to 12 26
            Set Label to "Application"
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            
            
            Procedure OnChange
                String sAppFilter
                Get Value of oAppFilterCombo to sAppFilter
                Set psAppFilter to sAppFilter
                //
                Send Clear_All of oViewAccess_DD
                Send Rebuild_Constraints of oViewAccess_DD
                Send MoveToFirstRow of oViewAccessDBCJGrid
            End_Procedure

            Procedure Combo_Fill_List
                Forward Send Combo_Fill_List
                Send Combo_Add_Item "Tempus" "Tempus - Windows Application"
                Send Combo_Add_Item "Tempus Field" "Tempus Field - Time Tracking Web Application"
                Send Combo_Add_Item "Tempus Mobile" "Contractor Billing - Web Application"
                Send Combo_Add_Item "My Properties" "Customer Portal - Web Application"
            End_Procedure
        End_Object
        
        Object oCustClear is a Button
            Set Size to 14 25
            Set Location to 11 129
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oAppFilterCombo to ""
            End_Procedure
        
        End_Object
    
    
    End_Object

    Object oViewAccessDBCJGrid is a cDbCJGrid
        Set Size to 189 549
        Set Ordering to 3
        Set peAnchors to anAll

        Object oViewAccess_Sequence is a cDbCJGridColumn
            Entry_Item ViewAccess.Sequence
            Set piWidth to 58
            Set psCaption to "Seq."
        End_Object

        Object oViewAccess_Application is a cDbCJGridColumn
            Entry_Item ViewAccess.Application
            Set piWidth to 271
            Set psCaption to "Application"
            Set pbComboButton to True
        End_Object

        Object oViewAccess_ViewName is a cDbCJGridColumn
            Entry_Item ViewAccess.ViewName
            Set piWidth to 271
            Set psCaption to "ViewName"
        End_Object
        Set Location to 37 5

        Object oViewAccess_Full is a cDbCJGridColumn
            Entry_Item ViewAccess.Full
            Set piWidth to 173
            Set psCaption to "Full"
            Set Prompt_Button_Mode to PB_PromptOn

            Procedure Prompt
                String[] asSelectedRights
                Boolean bCancel
                Integer i
                String sRights
                //
                Move (StrSplitToArray(Trim(ViewAccess.Full),",")) to asSelectedRights
                Get GetMultipleWebAppUserRights of WebAppUserRights_sl True (&asSelectedRights) to bCancel
                If (not(bCancel)) Begin
                    For i from 0 to (SizeOfArray(asSelectedRights)-1)
                        Move (Append(sRights,(asSelectedRights[i]+If(i<(SizeOfArray(asSelectedRights)-1),",","")))) to sRights
                    Loop
                    Set Value of oViewAccess_Full to sRights
                End
            End_Procedure

//            Set Prompt_Object to WebAppUserRights_sl

//            Procedure Prompt_Callback Handle hoPrompt
//                String[] asSelectionValues
//                Integer i
//                Integer[] aiSelectionValues
//                Boolean bCancel
//                //
//                Set peUpdateMode of hoPrompt to umPromptNonInvoking
//                Set pbStaticData of hoPrompt to True
//                Set pbInitialSelectionEnable of hoPrompt to True
//                Set pbMultipleSelection of hoPrompt to True
//                Set piUpdateColumn of hoPrompt to 0 //Rights Value    
//                
//                Move (StrSplitToArray(Trim(ViewAccess.Full),",")) to asSelectionValues
//                For i from 0 to (SizeOfArray(asSelectionValues)-1)
//                    Move asSelectionValues[i] to aiSelectionValues[i]
//                Loop
//                Send SetIndexesForSelectedRows of hoPrompt aiSelectionValues
//
//                Forward Send Prompt_Callback hoPrompt
//        
//                Get pbCanceled of hoPrompt to bCancel
//                If not bCancel Begin
//                    Get SelectedColumnValues of hoPrompt 0 to asSelectionValues
//                    If (SizeOfArray(asSelectionValues)) Begin
//                        For i from 0 to (SizeOfArray(asSelectionValues)-1)
//                                                 
//                        Loop
//                    End
//                End
//            End_Procedure
        End_Object

        Object oViewAccess_Modify is a cDbCJGridColumn
            Entry_Item ViewAccess.Modify
            Set piWidth to 176
            Set psCaption to "Modify"
        End_Object

        Object oViewAccess_ReadOnly is a cDbCJGridColumn
            Entry_Item ViewAccess.ReadOnly
            Set piWidth to 188
            Set psCaption to "ReadOnly"
        End_Object
    End_Object


End_Object 
