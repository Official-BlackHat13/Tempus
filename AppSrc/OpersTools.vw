// Z:\VDF17.0 Workspaces\Tempus - CEPM\AppSrc\OpersTools.vw
// OpersTools
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use MastOps.DD
Use Opers.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use Windows.pkg

Use OpersProcess.bp
Use cTextEdit.pkg

ACTIVATE_VIEW Activate_oOpersTools FOR oOpersTools
Object oOpersTools is a cGlblDbView
    Set Location to 34 144
    Set Size to 114 231
    Set Label to "Opers Tools"
    Set Border_Style to Border_Thick

    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD is a Areas_DataDictionary
    End_Object // oAreas_DD

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
    End_Object // oLocation_DD

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
    End_Object // oMastOps_DD

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oMastOps_DD
    End_Object // oOpers_DD

    Set Main_DD To oOpers_DD
    Set Server  To oOpers_DD



    Object oMastOpsIdno is a cGlblDbForm
        Entry_Item MastOps.MastOpsIdno
        Set Size to 13 32
        Set Location to 6 59
        Set peAnchors to anLeftRight
        Set Label to "MastOpsIdno"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 45
        Set Label_row_Offset to 0
        
        Procedure Refresh Integer notifyMode
            Boolean bHasMastOpsSelected
            Move (MastOps.MastOpsIdno>0) to bHasMastOpsSelected
            
            Forward Send Refresh notifyMode
            
            Set Enabled_State of oUpdateAllOpersGroup to bHasMastOpsSelected          
            
        End_Procedure
        
    End_Object // oMastOpsMastOpsIdno

    Object oMastOps_Name is a cGlblDbForm
        Entry_Item MastOps.Name
        Set Enabled_State to False
        Set Location to 6 94
        Set Size to 13 129
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

    Object oUpdateAllOpersGroup is a Group
        Set Size to 75 100
        Set Location to 28 11
        Set Label to 'Update all Opers'

        Object oUpdateButton is a Button
            Set Size to 14 80
            Set Location to 12 7
            Set Label to 'Update'
        
            // fires when the button is clicked
            Procedure OnClick
                Boolean bStatus, bPricing, bDescription
                Move False to bStatus
                Move False to bPricing
                Move False to bDescription
                Integer iMastOpsIdno iAlternateMastOps iOpersUpdated
                String sCurrentMastOpsStatus
                
                Get Checked_State of oStatusCheckBox to bStatus
                Get Checked_State of oPricingCheckBox to bPricing
                Get Checked_State of oDescriptionCheckBox to bDescription
                
                Get Value of oMastOpsIdno to iMastOpsIdno
                Move MastOps.Status to sCurrentMastOpsStatus
                
                If ((bStatus) or (bPricing) or (bDescription)) Begin
                    If ((bStatus) and sCurrentMastOpsStatus = "I") Begin
                        // All Operations and Equipment should be re-assigned to a new MastOps
                    End
                    Get UpdateRelatedOpers of oOpersProcess iMastOpsIdno bStatus bPricing bDescription to iOpersUpdated
                    Send Info_Box ("Updated" * (String(iOpersUpdated)) * "Opers records")
                    If (bStatus) Begin
                        
                    End
                End
                Else Begin
                    Send Info_Box "You must select at lease one option to update"
                End
                

            End_Procedure
        
        End_Object

        Object oStatusCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 32 13
            Set Label to 'Status'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
            End_Procedure
        
        End_Object

        Object oPricingCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 45 13
            Set Label to 'Pricing'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
            End_Procedure
        
        End_Object

        Object oDescriptionCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 58 13
            Set Label to 'Description'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
            End_Procedure
        
        End_Object
        
        
        
        
        
    End_Object

//    Object oUpdateAllOpersGroup is a Group
//        Set Size to 75 103
//        Set Location to 28 114
//        Set Label to 'Adjust pricing for Sidewalk'
//
//        Object oTextEdit1 is a cTextEdit
//            Set Size to 42 90
//            Set Location to 12 6
//            Set Value of oTextEdit1 to "Clicking the Adjust button below will universaly adjust the sidewalk pricing."
//        End_Object
//       
//
//        Object oUpdateButton is a Button
//            Set Size to 14 80
//            Set Location to 57 9
//            Set Label to 'Adjust'
//        
//            // fires when the button is clicked
//            Procedure OnClick
//                Integer iFail iChangeCounter iTempLoc iMastOpsIdno iOpersIdno
//                String sTempText
//                Number nTempRate
//                
//                Get Confirm ("Do you want to continue?") to iFail
//                If (not(iFail)) Begin
//                    // Find Opers
//                    Clear Opers
//                    Move "125" to Opers.MastOpsIdno
//                    Find ge Opers by Index.3
//                    While ((Found) and Opers.MastOpsIdno = "125")
//                        Move Opers.OpersIdno to iOpersIdno
//                        Move Opers.LocationIdno to iTempLoc
//                        Move Opers.SellRate to nTempRate
//                        Move "126" to iMastOpsIdno
//                        
//                        For iMastOpsIdno from 126 to 127
//                            Clear Opers
//                            Move iTempLoc to Opers.LocationIdno
//                            Move iMastOpsIdno to Opers.MastOpsIdno 
//                            Find EQ Opers by Index.4
//                            If ((Found) and Opers.MastOpsIdno = iMastOpsIdno and Opers.LocationIdno = iTempLoc) Begin
//                                Lock
////                                If (Opers.SellRate <= "79.99") Begin
////                                    Add nTempRate to Opers.SellRate
////                                End
//
//                                Move (Remove(Opers.Description, 1, 17)) to sTempText
//                                Move sTempText to Opers.Description    
//                                Move "1" to Opers.ChangedFlag
//                                SaveRecord Opers                     
//                                Unlock
//                                Increment iChangeCounter
//
//                            End
//                        Loop
//                    //Find next Opers with MastOps 125
//                    Move iOpersIdno to Opers.OpersIdno
//                    Move "125" to Opers.MastOpsIdno
//                    Find GT Opers by Index.3                       
//                    Loop
//                End
//                If (iChangeCounter) Begin
//                    Send Info_Box ("Updated " + String(iChangeCounter) + " Operations records")
//                End
//            End_Procedure
//        
//        End_Object       
//        
//    End_Object


End_Object // oOpersTools
