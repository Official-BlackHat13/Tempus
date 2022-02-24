// MastOps.sl
// MastOps Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cDivisionMgrGlblDataDictionary.dd
Use cWorkTypeGlblDataDictionary.dd
Use MastOps.DD
Use Windows.pkg

Object MastOps_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 243 536
    Set Label To "MastOps Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Property Boolean pbQuoteEntry
    Property Boolean pbCostType
    Property Boolean pbReportType
    Property String  psCostType
    Property String  psReportType
    Property Integer piIdno
    Property Integer piActivityType

    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object 

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server To oDivisionMgr_DD
    End_Object 

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
        
        Procedure OnConstrain
            // Constrain CostType depending on view
            If (pbQuoteEntry(Self)) Begin
                Constrain MastOps.ReportCategory ne "Job Cost"
            End
            Else Begin
                If (pbCostType(Self)) Begin
                    Constrain MastOps.CostType eq (psCostType(Self))
                End
                // Constrain ReportType depending on view
                If (pbReportType(Self)) Begin
                    Constrain MastOps.ReportCategory eq (psReportType(Self))
                End  
            End
            // Constrain from Filter on SL
            String sWorkType sStatus
            Get Value of oWorkTypeCombo to sWorkType
            Move (Ltrim(sWorkType)) to sWorkType
            If ((Length(sWorkType))<>0) Begin
                Constrain MastOps.ActivityType eq sWorkType
            End  
            //Status
            Move (LEFT(Value(oStatusComboForm),1)) to sStatus
            If ((Length(sStatus))<>0) Begin
                Constrain MastOps.Status eq sStatus
            End  
            // OLD STATUS CHECKBOXES
//            If (not(Checked_State(oActiveCheckBox(Self)))) Constrain MastOps.Status ne "A"
//            If (not(Checked_State(oInactiveCheckBox(Self)))) Constrain MastOps.Status ne "I"
//            If (not(Checked_State(oHiddenCheckBox(Self)))) Constrain MastOps.Status ne "H"
        End_Procedure
        
    End_Object 

    Set Main_DD To oMastOps_DD
    Set Server  To oMastOps_DD

    Object oSelList is a cDbCJGridPromptList
        Set Size to 204 526
        Set Location to 5 4
        Set peAnchors to anAll
        Set psLayoutSection to "MastOps_sl_oSelList"
        Set pbAutoServer to False
        Set pbStaticData to True
        Set Ordering to 2 // MastOps.Name

        Object oMastOps_Name is a cDbCJGridColumn
            Entry_Item MastOps.Name
            Set piWidth to 186
            Set psCaption to "Name"
        End_Object 

        Object oMastOps_MastOpsIdno is a cDbCJGridColumn
            Entry_Item MastOps.MastOpsIdno
            Set piWidth to 72
            Set psCaption to "MastOpsIdno"
            Set pbVisible to False
        End_Object

        Object oWorkType_Description is a cDbCJGridColumn
            Entry_Item WorkType.Description
            Set piWidth to 112
            Set psCaption to "Division"
        End_Object 

        Object oMastOps_Description is a cDbCJGridColumn
            Entry_Item MastOps.Description
            Set piWidth to 524
            Set psCaption to "Description"
            Set pbMultiLine to True
        End_Object 

        Object oMastOps_SellRate is a cDbCJGridColumn
            Entry_Item MastOps.SellRate
            Set piWidth to 55
            Set psCaption to "Sell Rate"
        End_Object 

        Procedure Activating
            Forward Send Activating
            Set Value of oStatusComboForm to "A - Active"
            Set Value of oWorkTypeCombo to ""
        End_Procedure


    End_Object 

    Object oStatusGroup is a Group
        Set Size to 26 133
        Set Location to 212 7
        Set Label to 'Status'
        Set peAnchors to anBottomLeft

        Object oStatusComboForm is a ComboForm
            Set Size to 12 89
            Set Location to 9 5
            Set peAnchors to anTopBottomLeft
            Set Allow_Blank_State to True
            // Combo_Fill_List is called when the list needs filling
          
            Procedure Combo_Fill_List
                // Fill the combo list with Send Combo_Add_Item
                Send Combo_Add_Item "A - Active"
                Send Combo_Add_Item "H - Hidden"
                Send Combo_Add_Item "I - Inactive"
            End_Procedure
          
            // OnChange is called on every changed character
         
            Procedure OnChange
                String sValue
                Get Value to sValue // the current selected item
                Send Rebuild_Constraints of oMastops_DD
                Send RefreshDataFromDD of oSelList ropTop
                Send Activate of oSelList
            End_Procedure
          
            // Notification that the list has dropped down
         
        //    Procedure OnDropDown
        //    End_Procedure
        
            // Notification that the list was closed
          
        //    Procedure OnCloseUp
        //    End_Procedure
        End_Object

        Object oClearButton is a Button
            Set Size to 14 31
            Set Location to 8 98
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                Set Value of oStatusComboForm to ""
            End_Procedure
        
        End_Object



//        Object oActiveCheckBox is a CheckBox
//            Set Size to 10 38
//            Set Location to 11 12
//            Set Label to 'Active'
//            Set Checked_State to True
//        
//            //Fires whenever the value of the control is changed
//            Procedure OnChange
//                Boolean bChecked
//                Get Checked_State to bChecked
//                Send Rebuild_Constraints of oMastops_DD
//                Send Beginning_of_Data to oSelList
//            End_Procedure
//        End_Object
//
//        Object oInactiveCheckBox is a CheckBox
//            Set Size to 10 50
//            Set Location to 11 49
//            Set Label to 'Inactive'
//        
//            //Fires whenever the value of the control is changed
//            Procedure OnChange
//                Boolean bChecked
//            
//                Get Checked_State to bChecked
//                Send Rebuild_Constraints of oMastops_DD
//                Send Beginning_of_Data to oSelList
//            End_Procedure
//        
//        End_Object
//        
//        Object oHiddenCheckBox is a CheckBox
//            Set Size to 10 50
//            Set Location to 11 92
//            Set Label to 'Hidden'
//        
//            //Fires whenever the value of the control is changed
//            Procedure OnChange
//                Boolean bChecked
//            
//                Get Checked_State to bChecked
//                Send Rebuild_Constraints of oMastops_DD
//                Send Beginning_of_Data to oSelList
//            End_Procedure
//        
//        End_Object
        
    End_Object


    Object oWorkTypeDbGroup is a dbGroup
        Set Size to 26 135
        Set Location to 212 146
        Set Label to 'Activity Type Filter'
        Set peAnchors to anBottomLeft

        Object oWorkTypeCombo is a dbComboForm
            Set Size to 14 100
            Set Entry_State to False
            Set Allow_Blank_State to True
            Set Location to 9 4
            Set Combo_Data_File to 74
            Set Code_Field to 1
            Set Combo_Index to 1
            Set Description_Field to 1
            Set Label to ""
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 5
            
            Procedure OnChange
                Send Rebuild_Constraints of oMastops_DD
                Send RefreshDataFromDD of oSelList ropTop
                Send Activate of oSelList
            End_Procedure
            
        End_Object
        
        Object oClearButton is a Button
            Set Size to 15 25
            Set Location to 8 106
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oWorkTypeCombo to ""
            End_Procedure
        
        End_Object
    End_Object
//
//    Procedure DoItemPrompt Integer ByRef iMastOpsIdno
//        Send Rebuild_Constraints of oMastops_DD
//        If (iMastOpsIdno<>0) Begin
//            Clear MastOps
//            Move iMastOpsIdno to MastOps.MastOpsIdno
//            Find EQ MastOps.MastOpsIdno
//        End
//        Send Popup
//        Move MastOps.MastOpsIdno to iMastOpsIdno
//        Send Rebuild_Constraints of oMastops_DD
//        
//    End_Procedure

    Function DoMastOpsPrompt Integer ByRef iMastOpsIdno Returns Boolean
        Boolean bCancel
        String[] SelectionValues
        
        // with non-invoking lists we store and restore the defaults manually
        Send OnStoreDefaults of oSelList
        //
        Set Locate_Mode to CENTER_ON_PANEL
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set piUpdateColumn of oSelList to 0
        Set psSeedValue of oSelList to iMastOpsIdno
        //
        Send Popup
        //
        Send OnRestoreDefaults of oSelList
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Get SelectedColumnValues of oSelList 1 to SelectionValues
            If (SizeOfArray(SelectionValues)) Begin
                Move SelectionValues[0] to iMastOpsIdno
                Function_Return True
            End
        End
        Function_Return False
    End_Function

    Procedure DoAddOpersPrompt
//        Set Auto_Server_State of oSelList   to False
        Set pbQuoteEntry                    to True
        Set Auto_Index_State  of oSelList   to False
        Set Ordering          of oSelList   to 2
        //Set Form_Width        of oSelList 0 to 0 // 36
        //Set Form_Width        of oSelList 1 to 0 // 36
        //Set Form_Width        of oSelList 2 to 222 // 150
        //Set peQuoteType                     to qtPavementMaintenance
        Send Rebuild_Constraints of oMastops_DD
        Send Beginning_of_Data   of oSelList
        Send Popup
        //Set peQuoteType                     to qtAll
        Send Rebuild_Constraints of oMastops_DD
        Set Auto_Index_State  of oSelList   to True
        Set pbQuoteEntry                    to False
//        Set Auto_Server_State of oSelList   to True
        Set Ordering          of oSelList   to 1
        //Set Form_Width        of oSelList 0 to 36
        //Set Form_Width        of oSelList 1 to 36
        //Set Form_Width        of oSelList 2 to 150
    End_Procedure

    Function IsSelectedJobCostOperation String sCostType String sReportType Returns Integer
//        Set Auto_Server_State of oSelList to False
        Set piIdno                        to 0
        Set pbCostType                    to True
        Set psCostType                    to sCostType
        Set pbReportType                  to True
        Set psReportType                  to sReportType
        Send Rebuild_Constraints of oMastops_DD
        Send Beginning_of_Data   of oSelList
        Send Popup
        Set pbCostType                    to False
        Set psCostType                    to ""
        Set pbReportType                  to False
        Set psReportType                  to ""
        Send Rebuild_Constraints of oMastops_DD
//        Set Auto_Server_State of oSelList to True
        Function_Return (piIdno(Self))
    End_Function
    
    Function SelectMastOps Integer iMastOpsIdno Returns Integer
        Set piIdno to iMastOpsIdno
        Send Rebuild_Constraints of oMastops_DD
        Send RefreshDataFromDD of oSelList ropTop
        Send Popup
        Send Rebuild_Constraints of oMastops_DD
        Set piIdno to MastOps.MastOpsIdno
        Function_Return (piIdno(Self))
    End_Function

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 219 373
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object 

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 219 427
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object 

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 219 481
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object 

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


End_Object // MastOps_sl
