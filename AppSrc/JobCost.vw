Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use Order.DD
Use cJobcostsDataDictionary.dd
Use SalesRep.DD
Use MastOps.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use cDbTextEdit.pkg
Use dfTabDlg.pkg
Use dfSelLst.pkg
Use cGlblDbView.pkg
Use cGlblDbList.pkg
//Use EquipmentCost.dg
//Use LaborCost.dg
//Use SuppliesCost.dg
//Use SubcontractorCost.dg
Use cGlblDbCheckBox.pkg
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use cDbCJGridColumnSuggestion.pkg

//Deferred_View Activate_oJobCost for ;
    
    Activate_View Activate_oJobCost for oJobCost
    Object oJobCost is a cGlblDbView
        Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
        End_Object

//    Property String psCostType "EQUIPMENT"

        Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
        End_Object

        Object oWorkType_DD is a cWorkTypeGlblDataDictionary
            Set DDO_Server to oDivisionMgr_DD
        End_Object

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oJobcosts_DD is a cJobcostsDataDictionary
        Set DDO_Server to oMastOps_DD
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD

//        Procedure OnConstrain
//            String sCostType
//            //
//            Forward Send OnConstrain
//            //
//            Get psCostType to sCostType
//            Constrain Jobcosts.CostType eq sCostType
//        End_Procedure

        Function IsCostDescription Returns String
            String sCostType
            //
//            Get psCostType to sCostType
            //
//            If (sCostType <> "CONTRACTOR") Begin
                Clear MastOps
                Move Jobcosts.MastOpsIdno to MastOps.MastOpsIdno
                Find eq MastOps.MastOpsIdno
                Function_Return (Trim(MastOps.Name))
//            End
//            Else Begin
//                Clear Employer
//                Move Jobcosts.MastOpsIdno to Employer.EmployerIdno
//                Find eq Employer.EmployerIdno
//                Function_Return (Trim(Employer.Name))
//            End
        End_Function
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD

    Set Border_Style to Border_Thick
    Set Size to 338 389
    Set Location to 2 1
    Set Label to "Job Costs"
        Set Maximize_Icon to True
        Set piMinSize to 340 390
    
//Global_Variable Integer iKey



//    Object oJobCostTabDialog is a dbTabDialog
//        Set Size to 168 433
//        Set Location to 150 5
//    
//        Set Rotate_Mode to RM_Rotate
//
//        Procedure Request_Switch_To_Tab Integer iTab Integer iMode
//            Forward Send Request_Switch_To_Tab iTab iMode
//            //
//            If      (iTab = 0) Begin
//                Set psCostType to "EQUIPMENT"
//            End
//            Else If (iTab = 1) Begin
//                Set psCostType to "SUPPLIES"
//            End
//            Else If (iTab = 2) Begin
//                Set psCostType to "CONTRACTOR"
//            End
//            Else If (iTab = 3) Begin
//                Set psCostType to "LABOR"
//            End       
//            
//            Send Rebuild_Constraints of oJobcosts_DD
//            If      (iTab = 0) Begin
//                Send Beginning_of_Data of oEquipmentList
//            End
//            Else If (iTab = 1) Begin
//                Send Beginning_of_Data of oSuppliesList
//            End
//            Else If (iTab = 2) Begin
//                Send Beginning_of_Data of oSubcontractorList
//            End
//            Else If (iTab = 3) Begin
//                Send Beginning_of_Data of oLaborList
//            End            
//        End_Procedure
//
//        Object oEquipmentTabPage is a dbTabPage
//            Set Label to "Equipment"
//
//            Object oEquipmentList is a cGlblDbList
//                Set Size to 119 419
//                Set Location to 6 5
//
//                Begin_Row
//                    Entry_Item Order.JobNumber
//                    Entry_Item Jobcosts.WorkDate
//                    Entry_Item (IsCostDescription(oJobcosts_DD))
//                    Entry_Item Jobcosts.Notes
//                    Entry_Item Jobcosts.Quantity
//                    Entry_Item Jobcosts.UnitCost
//                    Entry_Item Jobcosts.TotalCost
//                End_Row
//
//                Set Main_File to Jobcosts.File_number
//
//                Set Server to oJobcosts_DD
//                Set Form_Width 0 to 1
//                Set Header_Label 0 to "JobNumber"
//                Set Form_Width 2 to 120
//                Set Header_Label 2 to "Description"
//                Set Column_CapsLock_State 2 to True
//                Set Form_Width 3 to 80
//                Set Header_Label 3 to "Notes"
//                Set Header_Justification_Mode 3 to JMode_Left
//                Set Form_Width 4 to 54
//                Set Header_Label 4 to "Quantity"
//                Set Header_Justification_Mode 4 to JMode_Right
//                Set Form_Width 5 to 54
//                Set Header_Label 5 to "Unit Cost"
//                Set Header_Justification_Mode 5 to JMode_Right
//                Set Form_Width 6 to 54
//                Set Header_Label 6 to "Total Cost"
//                Set Header_Justification_Mode 6 to JMode_Right
//                Set Form_Width 1 to 54
//                Set Header_Label 1 to "Date"
//                Set Move_Value_Out_State to False
//            End_Object
//
//            Object oAddEquipmentButton is a Button
//                Set Location to 132 5
//                Set Label to "Add"
//
//                Procedure OnClick
//                    Send DoAdd
//                End_Procedure
//            End_Object
//
//            Object oEditEquipmentButton is a Button
//                Set Location to 132 60
//                Set Label to "Edit"
//
//                Procedure OnClick
//                    Send DoEdit
//                End_Procedure
//            End_Object
//
//            Object oDeleteEquipmentButton is a Button
//                Set Location to 132 115
//                Set Label to "Delete"
//
//                Procedure OnClick
//                    Boolean bCancel
//                    Integer hoDD
//                    //
//                    Move oJobcosts_DD to hoDD
//                    //
//                    If (HasRecord(hoDD)) Begin
//                        Get Confirm "Delete this item?" to bCancel
//                        If bCancel Procedure_Return
//                        //
//                        Send Request_Delete of hoDD
//                        //
//                        Send Refresh_Page of oEquipmentList FILL_FROM_CENTER
//                        Send FindByRowId  of oOrder_DD Order.File_Number (CurrentRowId(oOrder_DD))
//                    End
//                End_Procedure
//            End_Object
//
//            
//
//            
//        
//            Procedure DoAdd
//                RowID riJobNo riJobcosts
//                //
//                If (HasRecord(oOrder_DD)) Begin
//                    Get CurrentRowId   of oOrder_DD              to riJobNo
//                    Get DoAddEquipment of oEquipmentCost riJobNo to riJobcosts
//                    If (not(IsNullRowID(riJobcosts))) Begin
//                        Send FindByRowId  of oJobcosts_DD Order.File_Number    riJobNo
//                        Send FindByRowId  of oJobcosts_DD Jobcosts.File_Number riJobcosts
//                        Send Refresh_Page of oEquipmentList FILL_FROM_CENTER
//                    End
//                End
//                //
//                Send Activate of oEquipmentList
//            End_Procedure
//        
//            Procedure DoEdit
//                RowID riJobno riJobcosts
//                //
//                If (HasRecord(oJobcosts_DD)) Begin
//                    Get CurrentRowId    of oOrder_DD                 to riJobno
//                    Get CurrentRowId    of oJobcosts_DD              to riJobcosts
//                    Get DoEditEquipment of oEquipmentCost riJobcosts to riJobcosts
//                    If (not(IsNullRowID(riJobcosts))) Begin
//                        Send FindByRowId  of oJobcosts_DD Order.File_Number    riJobNo
//                        Send FindByRowId  of oJobcosts_DD Jobcosts.File_Number riJobcosts
//                        Send Refresh_Page of oEquipmentList FILL_FROM_CENTER
//                    End
//                End
//                //
//                Send Activate of oEquipmentList
//            End_Procedure
//
//        End_Object
//
//        Object oSuppliesTabPage is a dbTabPage
//            Set Label to "Supplies"
//
//            Object oSuppliesList is a cGlblDbList
//                Set Size to 119 417
//                Set Location to 6 5
//
//                Begin_Row
//                    Entry_Item Order.JobNumber
//                    Entry_Item Jobcosts.WorkDate
//                    Entry_Item (IsCostDescription(oJobcosts_DD))
//                    Entry_Item Jobcosts.Notes
//                    Entry_Item Jobcosts.Quantity
//                    Entry_Item Jobcosts.UnitCost
//                    Entry_Item Jobcosts.TotalCost
//                End_Row
//
//                Set Main_File to Jobcosts.File_number
//
//                Set Server to oJobcosts_DD
//
//                Set Form_Width 0 to 1
//                Set Header_Label 0 to "JobNumber"
//                Set Form_Width 2 to 120
//                Set Header_Label 2 to "Description"
//                Set Column_CapsLock_State 2 to True
//                Set Form_Width 3 to 80
//                Set Header_Label 3 to "Notes"
//                Set Header_Justification_Mode 3 to JMode_Left
//                Set Form_Width 4 to 54
//                Set Header_Label 4 to "Quantity"
//                Set Header_Justification_Mode 4 to JMode_Right
//                Set Form_Width 5 to 54
//                Set Header_Label 5 to "Unit Cost"
//                Set Header_Justification_Mode 5 to JMode_Right
//                Set Form_Width 6 to 54
//                Set Header_Label 6 to "Total Cost"
//                Set Header_Justification_Mode 6 to JMode_Right
//                Set Form_Width 1 to 54
//                Set Header_Label 1 to "Date"
//                Set Move_Value_Out_State to False
//            End_Object
//
//            Object oAddSuppliesButton is a Button
//                Set Location to 132 5
//                Set Label to "Add"
//
//                Procedure OnClick
//                    Send DoAdd
//                End_Procedure
//            End_Object
//
//            Object oEditSuppliesButton is a Button
//                Set Location to 132 60
//                Set Label to "Edit"
//
//                Procedure OnClick
//                    Send DoEdit
//                End_Procedure
//            End_Object
//
//            Object oDeleteSuppliesButton is a Button
//                Set Location to 132 115
//                Set Label to "Delete"
//
//                Procedure OnClick
//                    Boolean bCancel
//                    Integer hoDD
//                    //
//                    Move oJobcosts_DD to hoDD
//                    //
//                    If (HasRecord(hoDD)) Begin
//                        Get Confirm "Delete this item?" to bCancel
//                        If bCancel Procedure_Return
//                        //
//                        Send Request_Delete of hoDD
//                        //
//                        Send Refresh_Page of oSuppliesList FILL_FROM_CENTER
//                        Send FindByRowId  of oOrder_DD Order.File_Number (CurrentRowId(oOrder_DD))
//                    End
//                End_Procedure
//            End_Object
//
//            Procedure DoAdd
//                RowID riJobNo riJobcosts
//                //
//                If (HasRecord(oOrder_DD)) Begin
//                    Get CurrentRowId  of oOrder_DD             to riJobNo
//                    Get DoAddSupplies of oSuppliesCost riJobNo to riJobcosts
//                    If (not(IsNullRowID(riJobcosts))) Begin
//                        Send FindByRowId  of oJobcosts_DD Order.File_Number    riJobNo
//                        Send FindByRowId  of oJobcosts_DD Jobcosts.File_Number riJobcosts
//                        Send Refresh_Page of oSuppliesList FILL_FROM_CENTER
//                    End
//                End
//                //
//                Send Activate of oSuppliesList
//            End_Procedure
//        
//            Procedure DoEdit
//                RowID riJobno riJobcosts
//                //
//                If (HasRecord(oJobcosts_DD)) Begin
//                    Get CurrentRowId   of oOrder_DD                to riJobno
//                    Get CurrentRowId   of oJobcosts_DD             to riJobcosts
//                    Get DoEditSupplies of oSuppliesCost riJobcosts to riJobcosts
//                    If (not(IsNullRowID(riJobcosts))) Begin
//                        Send FindByRowId  of oJobcosts_DD Order.File_Number    riJobNo
//                        Send FindByRowId  of oJobcosts_DD Jobcosts.File_Number riJobcosts
//                        Send Refresh_Page of oSuppliesList FILL_FROM_CENTER
//                    End
//                End
//                //
//                Send Activate of oSuppliesList
//            End_Procedure
//
//        End_Object
//
//        Object oSubcontractorTabPage is a dbTabPage
//            Set Label to "Subcontractors"
//
//            Object oSubcontractorList is a cGlblDbList
//                Set Size to 119 418
//                Set Location to 6 5
//
//                Begin_Row
//                    Entry_Item Order.JobNumber
//                    Entry_Item Jobcosts.WorkDate
//                    Entry_Item (IsCostDescription(oJobcosts_DD))
//                    Entry_Item Jobcosts.Notes
//                    Entry_Item Jobcosts.Quantity
//                    Entry_Item Jobcosts.UnitCost
//                    Entry_Item Jobcosts.TotalCost
//                End_Row
//
//                Set Main_File to Jobcosts.File_number
//
//                Set Server to oJobcosts_DD
//                Set Form_Width 0 to 1
//                Set Header_Label 0 to "JobNumber"
//                Set Form_Width 2 to 120
//                Set Header_Label 2 to "Description"
//                Set Column_CapsLock_State 2 to True
//                Set Form_Width 3 to 80
//                Set Header_Label 3 to "Notes"
//                Set Header_Justification_Mode 3 to JMode_Left
//                Set Form_Width 4 to 54
//                Set Header_Label 4 to "Quantity"
//                Set Header_Justification_Mode 4 to JMode_Right
//                Set Form_Width 5 to 54
//                Set Header_Label 5 to "Unit Cost"
//                Set Header_Justification_Mode 5 to JMode_Right
//                Set Form_Width 6 to 54
//                Set Header_Label 6 to "Total Cost"
//                Set Header_Justification_Mode 6 to JMode_Right
//                Set Form_Width 1 to 54
//                Set Header_Label 1 to "Date"
//                Set Move_Value_Out_State to False
//            End_Object
//
//            Object oAddSubcontractorButton is a Button
//                Set Location to 132 5
//                Set Label to "Add"
//
//                Procedure OnClick
//                    Send DoAdd
//                End_Procedure
//            End_Object
//
//            Object oEditSubcontractorButton is a Button
//                Set Location to 132 60
//                Set Label to "Edit"
//
//                Procedure OnClick
//                    Send DoEdit
//                End_Procedure
//            End_Object
//
//            Object oDeleteSubcontractorButton is a Button
//                Set Location to 132 115
//                Set Label to "Delete"
//
//                Procedure OnClick
//                    Boolean bCancel
//                    Integer hoDD
//                    //
//                    Move oJobcosts_DD to hoDD
//                    //
//                    If (HasRecord(hoDD)) Begin
//                        Get Confirm "Delete this item?" to bCancel
//                        If bCancel Procedure_Return
//                        //
//                        Send Request_Delete of hoDD
//                        //
//                        Send Refresh_Page of oSubcontractorList FILL_FROM_CENTER
//                        Send FindByRowId  of oOrder_DD Order.File_Number (CurrentRowId(oOrder_DD))
//                    End
//                End_Procedure
//            End_Object
//
//            Procedure DoAdd
//                RowID riJobNo riJobcosts
//                //
//                If (HasRecord(oOrder_DD)) Begin
//                    Get CurrentRowId       of oOrder_DD                  to riJobNo
//                    Get DoAddSubcontractor of oSubcontractorCost riJobNo to riJobcosts
//                    If (not(IsNullRowID(riJobcosts))) Begin
//                        Send FindByRowId  of oJobcosts_DD Order.File_Number    riJobNo
//                        Send FindByRowId  of oJobcosts_DD Jobcosts.File_Number riJobcosts
//                        Send Refresh_Page of oSubcontractorList FILL_FROM_CENTER
//                    End
//                End
//                //
//                Send Activate of oSubcontractorList
//            End_Procedure
//        
//            Procedure DoEdit
//                RowID riJobno riJobcosts
//                //
//                If (HasRecord(oJobcosts_DD)) Begin
//                    Get CurrentRowId        of oOrder_DD                     to riJobno
//                    Get CurrentRowId        of oJobcosts_DD                  to riJobcosts
//                    Get DoEditSubcontractor of oSubcontractorCost riJobcosts to riJobcosts
//                    If (not(IsNullRowID(riJobcosts))) Begin
//                        Send FindByRowId  of oJobcosts_DD Order.File_Number    riJobNo
//                        Send FindByRowId  of oJobcosts_DD Jobcosts.File_Number riJobcosts
//                        Send Refresh_Page of oSubcontractorList FILL_FROM_CENTER
//                    End
//                End
//                //
//                Send Activate of oSubcontractorList
//            End_Procedure
//
//        End_Object
//        
//        Object oLaborTabPage is a dbTabPage
//            Set Label to "Labor"
//
//            Object oLaborList is a cGlblDbList
//                Set Size to 119 371
//                Set Location to 6 5
//
//                Begin_Row
//                    Entry_Item Order.JobNumber
//                    Entry_Item Jobcosts.WorkDate
//                    Entry_Item (IsCostDescription(oJobcosts_DD))
//                    Entry_Item Jobcosts.Quantity
//                    Entry_Item Jobcosts.UnitCost
//                    Entry_Item Jobcosts.TotalCost
//                End_Row
//
//                Set Main_File to Jobcosts.File_number
//
//                Set Server to oJobcosts_DD
//
//                Set Form_Width 0 to 1
//                Set Header_Label 0 to "JobNumber"
//                Set Form_Width 2 to 146
//                Set Header_Label 2 to "Description"
//                Set Column_CapsLock_State 2 to True
//                Set Form_Width 3 to 54
//                Set Header_Label 3 to "Quantity"
//                Set Header_Justification_Mode 3 to JMode_Right
//                Set Form_Width 4 to 54
//                Set Header_Label 4 to "Unit Cost"
//                Set Header_Justification_Mode 4 to JMode_Right
//                Set Form_Width 5 to 54
//                Set Header_Label 5 to "Total Cost"
//                Set Header_Justification_Mode 5 to JMode_Right
//                Set Form_Width 1 to 54
//                Set Header_Label 1 to "Date"
//                Set Move_Value_Out_State to False
//            End_Object
//
//            Object oAddLaborButton is a Button
//                Set Location to 132 5
//                Set Label to "Add"
//
//                Procedure OnClick
//                    Send DoAdd
//                End_Procedure
//            End_Object
//
//            Object oEditLaborButton is a Button
//                Set Location to 132 60
//                Set Label to "Edit"
//
//                Procedure OnClick
//                    Send DoEdit
//                End_Procedure
//            End_Object
//
//            Object oDeleteLaborButton is a Button
//                Set Location to 132 115
//                Set Label to "Delete"
//
//                Procedure OnClick
//                    Boolean bCancel
//                    Integer hoDD
//                    //
//                    Move oJobcosts_DD to hoDD
//                    //
//                    If (HasRecord(hoDD)) Begin
//                        Get Confirm "Delete this item?" to bCancel
//                        If bCancel Procedure_Return
//                        //
//                        Send Request_Delete of hoDD
//                        //
//                        Send Refresh_Page of oLaborList FILL_FROM_CENTER
//                        Send FindByRowId  of oOrder_DD Order.File_Number (CurrentRowId(oOrder_DD))
//                    End
//                End_Procedure
//            End_Object
//
//            Procedure DoAdd
//                RowID riJobNo riJobcosts
//                //
//                If (HasRecord(oOrder_DD)) Begin
//                    Get CurrentRowId  of oOrder_DD             to riJobNo
//                    Get DoAddLabor of oLaborCost riJobNo to riJobcosts
//                    If (not(IsNullRowID(riJobcosts))) Begin
//                        Send FindByRowId  of oJobcosts_DD Order.File_Number    riJobNo
//                        Send FindByRowId  of oJobcosts_DD Jobcosts.File_Number riJobcosts
//                        Send Refresh_Page of oLaborList FILL_FROM_CENTER
//                    End
//                End
//                //
//                Send Activate of oLaborList
//            End_Procedure
//        
//            Procedure DoEdit
//                RowID riJobno riJobcosts
//                //
//                If (HasRecord(oJobcosts_DD)) Begin
//                    Get CurrentRowId   of oOrder_DD                to riJobno
//                    Get CurrentRowId   of oJobcosts_DD             to riJobcosts
//                    Get DoEditLabor of oLaborCost riJobcosts to riJobcosts
//                    If (not(IsNullRowID(riJobcosts))) Begin
//                        Send FindByRowId  of oJobcosts_DD Order.File_Number    riJobNo
//                        Send FindByRowId  of oJobcosts_DD Jobcosts.File_Number riJobcosts
//                        Send Refresh_Page of oLaborList FILL_FROM_CENTER
//                    End
//                End
//                //
//                Send Activate of oLaborList
//            End_Procedure
//
//        End_Object
//    End_Object
    
    Procedure Activate_View
        If (giUserRights GE 60) Begin
            Forward Send Activate_View
        End
        Else Begin
            Send Info_Box "You are lacking permission to open this view!"
        End
    End_Procedure
    
    Procedure DoViewJobCost Integer iRecId
        //Send Request_Clear_All
        If (iRecId) Begin
            
            Send Request_Clear_All
            Send Find_By_Recnum of oOrder_DD Order.File_Number iRecId
        End
        Send Activate_View  

    End_Procedure

    Object oOrderContainer is a dbContainer3d
        Set Size to 118 377
        Set Location to 7 5
        Set peAnchors to anTopLeftRight

        Object oLocation_Name is a cGlblDbForm
            Entry_Item Location.Name
            Set Location to 19 85
            Set Size to 13 282
            Set Label to "Property:"
            Set Prompt_Button_Mode to PB_PromptOff
            Set Enabled_State to False
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set peAnchors to anTopLeftRight
        End_Object

        Object oOrder_Description is a cDbTextEdit
            Entry_Item Order.Description
            Set Location to 34 85
            Set Size to 47 282
            Set Label to "Work Description:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set peAnchors to anTopLeftRight
        End_Object

        Object oOrder_MilesToWorksite is a cGlblDbForm
            Entry_Item Order.MilesToWorksite
            Set Location to 98 85
            Set Size to 13 30
            Set Label to "Miles To Job:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

//        Object oOrder_WorkScheduled is a cGlblDbForm
//            Entry_Item Order.WorkScheduled
//            Set Location to 100 85
//            Set Size to 13 66
//            Set Label to "Scheduled Date:"
//            Set Label_Col_Offset to 3
//            Set Label_Justification_Mode to JMode_Right
//        End_Object
//
//        Object oOrder_WorkStarted is a cGlblDbForm
//            Entry_Item Order.WorkStarted
//            Set Location to 115 85
//            Set Size to 13 66
//            Set Label to "Work Date:"
//            Set Label_Col_Offset to 3
//            Set Label_Justification_Mode to JMode_Right
//        End_Object

        Object oOrder_CostStatus is a cGlblDbCheckBox
            Entry_Item Order.CostStatus
            Set Location to 99 218
            Set Size to 10 60
            Set Label to "Cost Not Complete"
        End_Object

        Object oOrder_PO_Number is a cGlblDbForm
            Entry_Item Order.PO_Number
            Set Location to 83 85
            Set Size to 13 282
            Set Label to "PO Number:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Enabled_State to False
            Set Entry_State to False
            Set peAnchors to anTopLeftRight
        End_Object

        Object oOrder_JobNumber is a cGlblDbForm
            Entry_Item Order.JobNumber
            Set Location to 3 85
            Set Size to 13 49
            Set Label to "Job Number:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
    
            Procedure Refresh Integer notifyMode
                Forward Send Refresh notifyMode
                Boolean bHasRecord bHasFullRights
                //
                Move (HasRecord(oOrder_DD)) to bHasRecord
                Move (giUserRights>=60) to bHasFullRights
                // 
                Set Enabled_State of oJobCostDbCJGrid to (bHasRecord and bHasFullRights)
                Set Enabled_State of oOrder_Description to (bHasRecord and bHasFullRights)
                Set Enabled_State of oOrder_PO_Number to (bHasRecord and bHasFullRights)
                Set Enabled_State of oOrder_MilesToWorksite to (bHasRecord and bHasFullRights)
            End_Procedure
    
        End_Object
        Object oOrder_Title is a cGlblDbForm
            Entry_Item Order.Title
            Set Location to 3 137
            Set Size to 13 230
            Set Enabled_State to False
            Set Entry_State to False
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
            Set peAnchors to anTopLeftRight
        End_Object

      
    End_Object

    Object oJobCostDbCJGrid is a cDbCJGrid
        Set Server to oJobcosts_DD
        Set Size to 183 377
        Set Location to 132 6
        Set peAnchors to anAll

        Object oJobcosts_JobcostsId is a cDbCJGridColumn
            Entry_Item Jobcosts.JobcostsId
            Set piWidth to 65
            Set psCaption to "JobcostsId"
            Set pbVisible to False
        End_Object

        Object oJobcosts_WorkDate is a cDbCJGridColumn
            Entry_Item Jobcosts.WorkDate
            Set piWidth to 72
            Set psCaption to "WorkDate"
        End_Object

        Object oMastOps_Name is a cDbCJGridColumnSuggestion
            Entry_Item MastOps.Name
            Set piWidth to 197
            Set psCaption to "Name"
            Set pbFullText to True
            Set piFindIndex to 2
            Set piStartAtChar to 1
            Set peSuggestionMode to smCustom

            Procedure OnSelectSuggestion String sSearch tSuggestion Suggestion
                //Forward Send OnSelectSuggestion sSearch Suggestion
                Clear MastOps
                Move Suggestion.sRowId to MastOps.MastOpsIdno
                Send Request_Find of oMastOps_DD EQ MastOps.File_Number 1
                Send UpdateCurrentValue of oJobcosts_Notes MastOps.Description
                Send UpdateCurrentValue of oJobcosts_UnitCost MastOps.CostRate
                Send Next
                //Send UpdateCurrentValue of oMastOps_Name Suggestion.aValues[0]
                //Send UpdateCurrentValue of oJobcosts_Notes Suggestion.aValues[1]
            End_Procedure

            Procedure OnFindSuggestions String sSearch tSuggestion[]  ByRef aSuggestions
                //Forward Send OnFindSuggestions sSearch (&aSuggestions)
                Integer i
                Move (SizeOfArray(aSuggestions)) to i
                Clear MastOps
                Repeat
                    Find gt MastOps by 2  // Name MastOps.Name
                    If (Found) Begin
                        If (MastOps.Name contains sSearch or lowercase(MastOps.Name) contains Lowercase(sSearch)) Begin
                            // add both customer number and name to the list of suggestions that are shown to the user
                            Move (Trim(MastOps.MastOpsIdno)) to aSuggestions[i].sRowId
                            Move (trim(MastOps.Name)) to aSuggestions[i].aValues[0]
                            Move (trim(MastOps.Description)) to aSuggestions[i].aValues[1]
                            Increment i
                            If (i >= piMaxResults(Self)) Move False to Found  // stop at piMaxResults
                        End
                    End
                Until not (Found)
            End_Procedure
            
        End_Object

        Object oJobcosts_Notes is a cDbCJGridColumn
            Entry_Item Jobcosts.Notes
            Set piWidth to 200
            Set psCaption to "Notes"
        End_Object

        Object oJobcosts_Quantity is a cDbCJGridColumn
            Entry_Item Jobcosts.Quantity
            Set piWidth to 37
            Set psCaption to "Qty"
        End_Object

        Object oJobcosts_UnitCost is a cDbCJGridColumn
            Entry_Item Jobcosts.UnitCost
            Set piWidth to 73
            Set psCaption to "UnitCost"
        End_Object

        Object oJobcosts_TotalCost is a cDbCJGridColumn
            Entry_Item Jobcosts.TotalCost
            Set piWidth to 49
            Set psCaption to "TotalCost"
        End_Object
    End_Object

    Object oOrder_JobCostTotal is a cGlblDbForm
        Entry_Item Order.JobCostTotal
        Set Location to 319 327
        Set Size to 13 54
        Set Label to "Job Cost Total:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set peAnchors to anBottomRight
    End_Object

End_Object
