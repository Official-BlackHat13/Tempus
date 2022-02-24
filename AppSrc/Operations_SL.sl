// Operations_SL.sl
// Opers Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use MastOps.DD
Use Opers.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use cGlblDbForm.pkg

Object Operations_SL is a cGlblDbModalPanel
    
    Set Location to CENTER_ON_PANEL
    Set Size to 327 694
    Set Label To "Opers Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False
    Set Locate_Mode to Center_On_Parent

    Property Boolean pbSelected
    Property Integer piSelected
    Property String[] psaSelected
    Property Integer piLocIdno
    Property Integer piOpsIdno
    Property Integer piMastOps
    Property String  psActivityType
    Property String  psCostType
    Property String  psAttachCat
    Property String  psStatus

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
        
        Procedure OnConstrain
            If (psCostType(Self)) Begin
                Constrain MastOps.CostType eq (psCostType(Self))
            End
            If (psAttachCat(Self)) Begin
                Constrain MastOps.IsAttachment eq (psAttachCat(Self))
            End
            // Constrain from Filter on SL
            String sWTValue
            Get Value of oWorkTypeCombo to sWTValue
            Move (Ltrim(sWTValue)) to sWTValue
            If ((Length(sWTValue))>1) Begin
                Constrain MastOps.ActivityType eq sWTValue
            End   
        End_Procedure
        
    End_Object // oMastOps_DD

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oLocation_DD
        Set DDO_Server to oMastOps_DD

        Procedure OnConstrain
            Forward Send OnConstrain
            // Constrain Selection List
            If (piLocIdno(Self)) Begin
                Constrain Opers.LocationIdno eq (piLocIdno(Self))
            End
            
 
            //Status
            If (not(Checked_State(oActiveCheckBox(Self)))) Constrain Opers.Status ne "A"
            If (not(Checked_State(oInactiveCheckBox(Self)))) Constrain Opers.Status ne "I"
            If (not(Checked_State(oHiddenCheckBox(Self)))) Constrain Opers.Status ne "H"
        End_Procedure
    End_Object // oOpers_DD

    Set Main_DD to oOpers_DD
    Set Server  To oOpers_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 282 684
        Set Location to 15 5
        Set peAnchors to anAll
        //Set psLayoutSection to "Operations_SL_oSelList"
        Set pbAutoServer to True
        Set pbStaticData to True
        Set pbGrayIfDisable to False
        Set pbEditOnTyping to False
        Set Ordering to 5
        Set pbAllowColumnReorder to False
        Set pbAllowColumnRemove to False
        Set pbAutoOrdering to False
        Set pbMultipleSelection to False
                
        Object oOpers_DisplaySequence is a cDbCJGridColumn
            Entry_Item Opers.DisplaySequence
            Set piWidth to 83
            Set psCaption to "Seq."
            Set peHeaderAlignment to xtpAlignmentLeft
        End_Object

        Object oOpers_OpersIdno is a cDbCJGridColumn
            Entry_Item Opers.OpersIdno
            Set piWidth to 72
            Set psCaption to "OpersIdno"
            Set pbVisible to False
        End_Object // oOpers_OpersIdno     
        
        Object oMastOps_Name is a cDbCJGridColumn
            Entry_Item MastOps.Name
            Set piWidth to 362
            Set psCaption to "Name"
            Set piDisabledTextColor to clDefault
        End_Object

        Object oOpers_Description is a cDbCJGridColumn
            Entry_Item Opers.Description
            Set piWidth to 567
            Set psCaption to "Description"
        End_Object

        Object oOpers_SellRate is a cDbCJGridColumn
            Entry_Item Opers.SellRate
            Set piWidth to 64
            Set psCaption to "SellRate"
        End_Object

        Object oMastOps_NeedsAttachment is a cDbCJGridColumn
            Entry_Item MastOps.NeedsAttachment
            Set piWidth to 121
            Set psCaption to "Will prompt for:"
            Set pbComboButton to True
        End_Object

        Procedure ProcessSelectionItems
            Integer[] SelRows
            Integer i iSels iRow iOperIdno
            String[] sItemSelection
            Handle hoDataSource
            tDataSourceRow[] MyData
        
            Get GetIndexesForSelectedRows to SelRows
            Get phoDataSource to hoDataSource
            Get DataSource of hoDataSource to MyData
            Move (SizeOfArray(SelRows)) to iSels
            For i from 0 to (iSels-1)
                Move SelRows[i] to iRow
                Move MyData[iRow].sValue[1] to iOperIdno //
                Move iOperIdno to sItemSelection[i]
            Loop
            //
            Set psaSelected to sItemSelection
        End_Procedure

        Procedure OnComRowDblClick Variant llRow Variant llItem
            Send KeyAction of oOk_bn
        End_Procedure

    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Size to 14 31
        Set Label to "&Ok"
        Set Location to 308 582
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send ProcessSelectionItems of oSelList
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Size to 14 31
        Set Label to "&Cancel"
        Set Location to 308 618
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Size to 14 31
        Set Label to "&Search..."
        Set Location to 308 656
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    Object oDbGroup1 is a dbGroup
        Set Size to 25 135
        Set Location to 300 146
        Set Label to 'Activity Type Filter'
        Set peAnchors to anBottomLeft

        Object oWorkTypeCombo is a dbComboForm
            Set Size to 12 100
            Set Entry_State to False
            Set Allow_Blank_State to False
            Set Location to 9 4
            Set Combo_Data_File to 74
            Set Code_Field to 1
            Set Combo_Index to 1
            Set Description_Field to 1
            Set Label to ""
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 5
            
            Procedure OnChange
                Send Rebuild_Constraints of oOpers_DD
                Send MovetoFirstRow of oSelList
            End_Procedure
        End_Object
        
        Object oButton1 is a Button
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

    Object oStatusGroup is a Group
        Set Size to 24 133
        Set Location to 300 3
        Set Label to 'Status'
        Set peAnchors to anBottomLeft

        Object oActiveCheckBox is a CheckBox
            Set Size to 10 38
            Set Location to 11 12
            Set Label to 'Active'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oOpers_DD
                Send MovetoFirstRow of oSelList
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
                Send Rebuild_Constraints of oOpers_DD
                Send MovetoFirstRow of oSelList
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
                Send Rebuild_Constraints of oOpers_DD
                Send MovetoFirstRow of oSelList
            End_Procedure
        
        End_Object
        
    End_Object

    Object oLocation_Name is a cGlblDbForm
        Entry_Item Location.Name
        Set Location to 1 5
        Set Size to 13 684
        Set Enabled_State to False
        Set Entry_State to False
        Set peAnchors to anTopLeftRight
        Set Label_FontWeight to fw_Bold
        Set FontWeight to fw_Bold
        Set FontUnderline to True
    End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn
   
    Function DoInvoicePrompt Integer iOpersIdno Integer iLocIdno String sCostType Integer iMastOps Returns Integer        
        Boolean bCancel
        //
        Send OnStoreDefaults of oSelList
        Set Locate_Mode to CENTER_ON_PANEL
        Set peUpdateMode of oSelList to umPromptNonInvoking
        //
        Set piLocIdno to iLocIdno
        Set psCostType to sCostType
        Set piMastOps to iMastOps
        //
        If (iOpersIdno<>0) Begin
            Set pbSelected to True
            Set piSelected to iOpersIdno
//            Set piUpdateColumn of oSelList to 1
//            Set psSeedValue of oSelList to iOpersIdno
//            Send Clear of oOpers_DD
//            Move iOpersIdno to Opers.OpersIdno
//            Send Request_Find EQ Opers.File_Number 1
        End
        //
        Send Rebuild_Constraints of oOpers_DD
        //
        Send Popup_Modal
        //   
        Send OnRestoreDefaults of oSelList
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            If (iOpersIdno <> Opers.OpersIdno) Begin
                Move Opers.OpersIdno to iOpersIdno
                Send Request_Find EQ Opers.File_Number 1   
                Set piSelected to iOpersIdno             
            End
        End
        //
        
        Set piLocIdno to 0
        Set psCostType to ""
        Set piMastOps to 0
        //
        Send Rebuild_Constraints of oOpers_DD
        Function_Return (piSelected(Self))
    End_Function


    Function DoInvoicePromptFlex Integer iLocIdno Boolean bMulti String sCostType Integer iMastOps Returns String[]
        String[] saSelectedItems        
        Boolean bCancel
        //
        Send OnStoreDefaults of oSelList
        //
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set pbMultipleSelection of oSelList to (bMulti)
        Set pbStaticData of oSelList to True
        //
        Set Locate_Mode of oSelList to CENTER_ON_PANEL
        //
        Set piLocIdno to iLocIdno
        Set psCostType to sCostType
        Set piMastOps to iMastOps
        //Seed
//        If (iOpersIdno<>0) Begin
//            Set pbSelected to True
//            Set piSelected to iOpersIdno
////            Set piUpdateColumn of oSelList to 1
////            Set psSeedValue of oSelList to iOpersIdno
////            Send Clear of oOpers_DD
////            Move iOpersIdno to Opers.OpersIdno
////            Send Request_Find EQ Opers.File_Number 1
//        End
        //
        Send Rebuild_Constraints of oOpers_DD
        //
        Send Popup_Modal
        //   
        Send OnRestoreDefaults of oSelList
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            //Click on OK button sends ProcessSelectionItems
            Get psaSelected to saSelectedItems
        End
        //
        
        Set piLocIdno to 0
        Set psCostType to ""
        Set piMastOps to 0
        //
        Send Rebuild_Constraints of oOpers_DD
        Function_Return (saSelectedItems)
    End_Function


//    Function IsSelectedJobCostOperation String sCostType String sReportType Returns Integer
////        Set Auto_Server_State of oSelList to False
//        Set piIdno                        to 0
//        Set pbCostType                    to True
//        Set psCostType                    to sCostType
//        Set pbReportType                  to True
//        Set psReportType                  to sReportType
//        Send Rebuild_Constraints of oMastops_DD
//        Send Beginning_of_Data   of oSelList
//        Send Popup
//        Set pbCostType                    to False
//        Set psCostType                    to ""
//        Set pbReportType                  to False
//        Set psReportType                  to ""
//        Send Rebuild_Constraints of oMastops_DD
////        Set Auto_Server_State of oSelList to True
//        Function_Return (piIdno(Self))
//    End_Function

    Function DoInvoiceAttachPrompt Integer iOpersIdno Integer iLocIdno String sCostType String sAttachCat;
        String ByRef sAttachOpersName String ByRef sAttachOpersDesc Integer ByRef iAttachMastOpsIdno Number ByRef nAttachSellRate ;
        Returns Integer        
        Boolean bCancel
        //
        Send OnStoreDefaults of oSelList
        Set peUpdateMode of oSelList to umPromptNonInvoking
        //
        Set piLocIdno to iLocIdno
        Set psCostType to sCostType
        Set psAttachCat to sAttachCat
        //
        Send Rebuild_Constraints of oOpers_DD
        //
        Send Popup_Modal
        //  
        Send OnRestoreDefaults of oSelList
        //      
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Move Opers.OpersIdno to iOpersIdno
            Move MastOps.Name to sAttachOpersName
            Move Opers.Description to sAttachOpersDesc
            Move Opers.MastOpsIdno to iAttachMastOpsIdno
            Move Opers.SellRate to nAttachSellRate
        End
        Else Begin 
            Move 0 to iOpersIdno
            Move "" to sAttachOpersName
            Move "" to sAttachOpersDesc
            Move 0 to iAttachMastOpsIdno
            Move 0 to nAttachSellRate
        End
        //
        Set piSelected to iOpersIdno
        Set piLocIdno to 0
        Set psCostType to ""
        Set psAttachCat to ""
        //
        Send Rebuild_Constraints of oOpers_DD
        Function_Return (piSelected(Self))
    End_Function

End_Object // Operations_SL
