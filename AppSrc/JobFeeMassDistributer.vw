Use Windows.pkg
Use DFClient.pkg
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use cWorkTypeGlblDataDictionary.dd
Use MastOps.DD
Use cGlobalJobCostGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use cDbCJGridPromptList.pkg
Use cCJGridColumnButton.pkg
Use JobCostMassDistribution.bp

Struct tJobDetails
    Integer iJobNumber
    Integer iLocIdno
    Number nLocSQFT
End_Struct

Struct tSelectedItems
    Integer iJobCostIdno
    String sDescription
    Number nCostRate
    Integer iMastOpsIdno
End_Struct

Deferred_View Activate_oJobFeeMassDistributer for ;
Object oJobFeeMassDistributer is a dbView
    
    Property Boolean pbItemsSelected
    Property Boolean pbOrderDetailsSet
    Property Boolean pbPrecalcDone
    Property Boolean pbGoTime
    Property Number pnTotalSqft

    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object
    
    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
    End_Object

    Object oGlobalJobCost_DD is a cGlobalJobCostGlblDataDictionary
        Set DDO_Server to oMastOps_DD
    End_Object

    Set Main_DD to oGlobalJobCost_DD
    Set Server to oGlobalJobCost_DD

    Set Border_Style to Border_Thick
    Set Size to 290 576
    Set Location to 1 2
    Set Label to "JobFeeMassDistributer"

    Object oItemSelectionGroup is a dbGroup
        Set Size to 218 551
        Set Location to 7 7
        Set Label to 'Step 1: Select items to distribute'

        Object oDBSelectionGrid is a cDbCJGrid
            Set Size to 201 538
            Set Location to 12 7
            Set pbMultipleSelection to True
            Set pbMultiSelectionMode to True
            Set pbSelectionEnable to True
            Set pbStaticData to True

            Object oGlobalJobCost_CostIdno is a cDbCJGridColumn
                Entry_Item GlobalJobCost.CostIdno
                Set piWidth to 61
                Set psCaption to "CostIdno"
            End_Object
    
            Object oGlobalJobCost_Description is a cDbCJGridColumn
                Entry_Item GlobalJobCost.Description
                Set piWidth to 265
                Set psCaption to "Description"
            End_Object

            Object oMastOps_Name is a cDbCJGridColumn
                Entry_Item MastOps.Name
                Set piWidth to 366
                Set psCaption to "Name"
            End_Object
    
            Object oGlobalJobCost_Status is a cDbCJGridColumn
                Entry_Item GlobalJobCost.Status
                Set piWidth to 109
                Set psCaption to "Status"
            End_Object

            Object oGlobalJobCost_Rate is a cDbCJGridColumn
                Entry_Item GlobalJobCost.Rate
                Set piWidth to 77
                Set psCaption to "Rate"
            End_Object

            Object oMastOps_MastOpsIdno is a cDbCJGridColumn
                Entry_Item MastOps.MastOpsIdno
                Set piWidth to 32
                Set psCaption to "MastOpsIdno"
            End_Object
            
            
            Function ProcessSelectionItems tSelectedItems[] ByRef SelectedItems Returns Boolean
                Integer[] SelRows
                Integer i iSels iRow
                String sName sCostIdno
                Handle hoDataSource
                tDataSourceRow[] MyData
            
                Get GetIndexesForSelectedRows to SelRows
                Get phoDataSource to hoDataSource
                Get DataSource of hoDataSource to MyData
                Move (SizeOfArray(SelRows)) to iSels
                For i from 0 to (iSels-1)
                    Move SelRows[i] to iRow
                    Move MyData[iRow].sValue[0] to SelectedItems[iRow].iJobCostIdno
                    Move MyData[iRow].sValue[1] to SelectedItems[iRow].sDescription
                    Move MyData[iRow].sValue[4] to SelectedItems[iRow].nCostRate
                    Move MyData[iRow].sValue[5] to SelectedItems[iRow].iMastOpsIdno
                    Showln (String(SelectedItems[iRow].iJobCostIdno) * SelectedItems[iRow].sDescription * String(SelectedItems[iRow].iMastOpsIdno)* String(SelectedItems[iRow].nCostRate))
                Loop
                Function_Return True
            End_Function
            
        End_Object

    End_Object

    Object oOrderTypeGroup is a dbGroup
        Set Size to 54 158
        Set Location to 229 7
        Set Label to 'Step 2: Set details & filters'

        Object oSzCostDatePicker is a Form
            Set Size to 13 92
            Set Location to 12 53
            Set Label to "Cost Date"
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
            Set Form_Datatype to Mask_Date_Window
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt

            Procedure Activating
                Date dToday
                Sysdate dToday
                Forward Send Activating
                Set Value of oSzCostDatePicker to dToday
                //Set psValue of oSzCostDatePicker to dToday
            End_Procedure
        End_Object
                
        Object oComboForm1 is a ComboForm
            Set Size to 12 92
            Set Location to 31 53
            Set Allow_Blank_State to False
            Set Entry_State to False
            Set Label to "Type"
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
        
            //Combo_Fill_List is called when the list needs filling
        
            Procedure Combo_Fill_List
                // Fill the combo list with Send Combo_Add_Item
                Send Combo_Add_Item "Snow Removal - S"
                Send Combo_Add_Item "Pavement Maint. - P"
                Send Combo_Add_Item "Sweeping - SW"
                Send Combo_Add_Item "Excavation - E"
                Send Combo_Add_Item "Other - O"
                Send Combo_Add_Item "Capital Expenditure - CE"
                Send Combo_Add_Item "Shop Labor - SL"
                Send Combo_Add_Item "Connex Box - CX"
            End_Procedure
        
            //OnChange is called on every changed character
        
            //Procedure OnChange
            //    String sValue
            //
            //    Get Value To sValue // the current selected item
            //End_Procedure
        
            //Notification that the list has dropped down
        
            //Procedure OnDropDown
            //End_Procedure
        
            //Notification that the list was closed
        
            //Procedure OnCloseUp
            //End_Procedure
        
        End_Object
    End_Object

    Object oGroup1 is a Group
        Set Size to 55 119
        Set Location to 229 173
        Set Label to 'Step 3: Create or Remove'

        Object oCreateRecordsButton is a Button
            Set Size to 14 91
            Set Location to 11 8
            Set Label to 'Create Records'
        
            // fires when the button is clicked
            Procedure OnClick
                tSelectedItems[] SelectedItems
                tJobDetails[] JobDetails
                Number nSqftTotal
                Boolean bSuccess
                //
                Get ProcessSelectionItems of oDBSelectionGrid (&SelectedItems) to bSuccess
                If (bSuccess) Begin
                    Get GatherOrderInformation (&JobDetails) (&nSqftTotal) to bSuccess
                    If (bSuccess) Begin
                        Date dCostDate
                        Get Value of oSzCostDatePicker to dCostDate
                        Get DoCreateCostRecords SelectedItems JobDetails nSqftTotal dCostDate to bSuccess
                    End
                End
            End_Procedure
        
        End_Object

        Object oRemoveRecordsButton is a Button
            Set Size to 14 91
            Set Location to 31 8
            Set Label to 'Remove Records'
        
            // fires when the button is clicked
            Procedure OnClick
                tSelectedItems[] SelectedItems
                tJobDetails[] JobDetails
                Boolean bSuccess
                Number nSqftTotal
                //
                Get ProcessSelectionItems of oDBSelectionGrid (&SelectedItems) to bSuccess
                If (bSuccess) Begin
                    Get GatherOrderInformation (&JobDetails) (&nSqftTotal) to bSuccess
                    If (bSuccess) Begin
                        Date dCostDate
                        Get Value of oSzCostDatePicker to dCostDate
                        Get DoRemoveCostRecords SelectedItems JobDetails dCostDate to bSuccess
                    End
                End
            End_Procedure
        
        End_Object
    End_Object

    //Step1
    Function GatherOrderInformation tJobDetails[] ByRef JobDetails Number ByRef nSqftTotal Returns Boolean
        Boolean bSuccess
        Integer iJobCounter iTotalJobCount iItemCounter iTotalItemCount eResponse iFound
        Number nSqft
        String sOrderType sErrMsg
        //
        Get Value of oComboForm1 to sOrderType
        Move (Right(sOrderType, 2)) to sOrderType
        Move (Trim(sOrderType)) to sOrderType
        //
        Clear Order
        Constraint_Set 1
        Constrain Order.Status eq "O"
        Constrained_Find First Order by 1
        While (Found)
            If (Order.WorkType = sOrderType) Begin
                Move Order.JobNumber to JobDetails[iFound].iJobNumber
                Move Location.LocationIdno to JobDetails[iFound].iLocIdno
                Move (Location.ParkSqFeet+Location.SWSqFeet) to JobDetails[iFound].nLocSQFT
                //
                Showln ("#"*String(iFound)*" - Job#:"*String(Order.JobNumber)*"- Order.WorkType"*Order.WorkType*"- Title: "*Order.Title*"- Status:"*Order.Status)
                Showln ("LocationSQFT:"*String(JobDetails[iFound].nLocSQFT))
                Add (JobDetails[iFound].nLocSQFT) to nSqftTotal
                //
                Increment iFound
            End
            Constrained_Find Next
        Loop
        Showln "COLLECTION COMPLETED" 
        Showln ("Found: " * String(iFound)*"Orders")
        Showln ("TotalSqft:"*String(nSqftTotal))        
        Function_Return True
    End_Function
    
    //Step2
    Function DoCreateCostRecords tSelectedItems[] SelectedItems tJobDetails[] JobDetails Number nSqftTotal Date dCostDate Returns Boolean
        Integer iJobCounter iTotalJobCount iTotalItemCount iItemCounter eResponse
        String sErrMsg
        Boolean bSuccess
        // Prompt for continuation
        Move (YesNo_Box("Add cost to these locations?", "Mass Create Job Cost Entries?", MB_DEFBUTTON2)) to eResponse
        If (eResponse = MBR_Yes) Begin
            Move (SizeOfArray(JobDetails)) to iTotalJobCount
            For iJobCounter from 0 to (iTotalJobCount-1)
                Showln ("Job#"*String(JobDetails[iJobCounter].iJobNumber))
                Move (SizeOfArray(SelectedItems)) to iTotalItemCount
                For iItemCounter from 0 to (iTotalItemCount-1)
                    If (SelectedItems[iItemCounter].iJobCostIdno<>0) Begin
                        Showln ("  - Items:"*String(SelectedItems[iItemCounter].iJobCostIdno)*"-"*String(SelectedItems[iItemCounter].iMastOpsIdno)*"-"*SelectedItems[iItemCounter].sDescription)
                        Get DoMassDistributeJobCost of oJobCostMassDistribution ;
                            JobDetails[iJobCounter].iJobNumber SelectedItems[iItemCounter].iMastOpsIdno;
                            JobDetails[iJobCounter].nLocSQFT nSqftTotal ;
                            SelectedItems[iItemCounter].nCostRate dCostDate (&sErrMsg) to bSuccess
                    End
                Loop
            Loop
            
        End
    End_Function

    //Step2
    Function DoRemoveCostRecords tSelectedItems[] SelectedItems tJobDetails[] JobDetails Date dCostDate Returns Boolean
        Integer iJobCounter iTotalJobCount iTotalItemCount iItemCounter eResponse
        String sErrMsg
        Boolean bSuccess
        // Prompt for continuation
        Move (YesNo_Box("Remove cost from these locations?", "Mass Remove Job Cost Entries?", MB_DEFBUTTON2)) to eResponse
        If (eResponse = MBR_Yes) Begin
            Move (SizeOfArray(JobDetails)) to iTotalJobCount
            For iJobCounter from 0 to (iTotalJobCount-1)
                Showln ("Job#"*String(JobDetails[iJobCounter].iJobNumber))
                Move (SizeOfArray(SelectedItems)) to iTotalItemCount
                For iItemCounter from 0 to (iTotalItemCount-1)
                    If (SelectedItems[iItemCounter].iJobCostIdno<>0) Begin
                        Showln ("  - Items:"*String(SelectedItems[iItemCounter].iJobCostIdno)*"-"*String(SelectedItems[iItemCounter].iMastOpsIdno)*"-"*SelectedItems[iItemCounter].sDescription)
                        Get DoMassRemoveJobCost of oJobCostMassDistribution ;
                            JobDetails[iJobCounter].iJobNumber SelectedItems[iItemCounter].iMastOpsIdno ;
                            dCostDate (&sErrMsg) to bSuccess
                    End
                Loop
                
            Loop
            
        End
    End_Function    
    
Cd_End_Object
