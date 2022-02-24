// D:\Development Projects\VDF18.2 Workspaces\Tempus\AppSrc\OpenOrders.vw
// OpenOrders
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use Customer.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use cWorkTypeGlblDataDictionary.dd
Use MastOps.DD
Use cOrderDtlGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use Windows.pkg
Use dbParentCombo.pkg
Use dbSuggestionForm.pkg
Use dfSpnEnt.pkg

ACTIVATE_VIEW Activate_oOpenOrders FOR oOpenOrders
Object oOpenOrders is a cGlblDbView
    Set Location to 4 5
    Set Size to 341 725
    Set Label To "OpenOrders"
    Set Border_Style to Border_Thick
    
    Property String psWorkType
    Property String psWorkType2
    Property String psStatus
    Property String psSeason
    Property String psCustomer
    Property String psLocation
    Property String psSalesRep

    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
    End_Object


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object 

    Object oAreas_DD is a Areas_DataDictionary
    End_Object 

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object 

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
        Set DDO_Server To oSalesTaxGroup_DD
    End_Object 

    Object oSalesRep_DD is a Salesrep_DataDictionary

        Procedure OnConstrain
            Forward Send OnConstrain
            If (Length(psSalesRep(Self))>0) Begin
                Constrain SalesRep.LastName eq (psSalesRep(Self))
            End
            
        End_Procedure

    End_Object 

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server to oSalesRep_DD

        Function WorkTypesContainsBoth Returns Boolean
                Function_Return (Order.Division contains ('['+(psWorkType(Self))+']') or Order.Division contains ('['+(psWorkType2(Self))+']'))
        End_Function

        Procedure OnConstrain
            If (Length(psStatus(Self))>0) Begin
                Constrain Order.Status eq (psStatus(Self))
            End
            Else Constrain Order.Status eq 'O'
            //
            If ((psSeason(Self)='Winter')) Constrain Order.WorkType eq 'S'
            Else Constrain Order.WorkType ne 'S'
            //
            Case Begin
                Case (Length(psWorkType(Self))>0 and Length(psWorkType2(Self))>0)
                    Constrain Order as (WorkTypesContainsBoth(Self))
                    Case Break
                Case (Length(psWorkType(Self))>0)
                    Constrain Order.Division contains ('['+(psWorkType(Self))+']')
                    Case Break
                Case (Length(psWorkType2(Self))>0)
                    Constrain Order.Division contains ('['+(psWorkType2(Self))+']')
                    Case Break
                Case Else
                    Case Break
            Case End
            
        End_Procedure
    End_Object 

    Object oOrderDtl_DD is a cOrderDtlGlblDataDictionary
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oOrder_DD
        Set Constrain_file to Order.File_number
        
    End_Object

    Set Main_DD to oOrder_DD
    Set Server  To oOrder_DD
    Set Maximize_Icon to True

    Object oFilterGroup is a dbGroup
        Set Size to 34 713
        Set Location to 2 4
        Set Label to ''
        Set peAnchors to anTopLeftRight
        
        Object oWorkTypeComboForm is a dbComboForm
            Set Size to 12 100
            Set Entry_State to False
            Set Allow_Blank_State to True
            Set Location to 16 5
            Set Combo_Data_File to 74
            Set Code_Field to 3
            Set Combo_Index to 1
            Set Description_Field to 1
            Set Code_Display_Mode to CB_Code_Display_Both
            Set Label to 'WorkType'
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            
            Procedure OnChange
                Set psWorkType to (Trim(Left((Value(oWorkTypeComboForm)),2)))
                Send Rebuild_Constraints of oOrder_DD
                Send RefreshDataFromDD of oOrderDbCJGrid ropTop 
                //Send MoveToFirstRow of oOrderDbCJGrid
            End_Procedure
            
        End_Object

        Object oWT1Clear is a Button
            Set Size to 14 25
            Set Location to 15 105
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oWorkTypeComboForm to ""
            End_Procedure
        
        End_Object

        Object oWorkType2ComboForm is a dbComboForm
            Set Size to 12 100
            Set Entry_State to False
            Set Allow_Blank_State to True
            Set Location to 16 137
            Set Combo_Data_File to 74
            Set Code_Field to 3
            Set Combo_Index to 1
            Set Description_Field to 1
            Set Code_Display_Mode to CB_Code_Display_Both
            Set Label to 'WorkType 2'
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            
            Procedure OnChange
                Set psWorkType2 to (Trim(Left((Value(oWorkType2ComboForm)),2)))
                Send Rebuild_Constraints of oOrder_DD
                Send RefreshDataFromDD of oOrderDbCJGrid ropTop 
                //Send MoveToFirstRow of oOrderDbCJGrid
            End_Procedure
            
        End_Object

        Object oWT2Clear is a Button
            Set Size to 14 25
            Set Location to 15 237
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oWorkType2ComboForm to ""
            End_Procedure
        
        End_Object

        Object oSalesRepComboForm is a ComboForm
            Set Size to 12 77
            Set Location to 16 267
            Set Allow_Blank_State to True
            Set Label to 'Sales Rep'
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            
            Procedure Combo_Fill_List
               Forward Send Combo_Fill_List
               
                Constraint_Set 1
                Constrained_Find First SalesRep by 2
                While (Found)
                    If (SalesRep.Status="A") Begin
                        Send Combo_Add_Item (Trim(SalesRep.LastName))
                    End
                    Constrained_Find Next
                Loop
                Constraint_Set 1 Delete 
               
            End_Procedure
            
            Procedure OnChange
                Set psSalesRep to (Trim(Value(oSalesRepComboForm)))
                Send Rebuild_Constraints of oOrder_DD
                Send RefreshDataFromDD of oOrderDbCJGrid ropTop 
            End_Procedure
    
        End_Object
        
        Object oSalesClear is a Button
            Set Size to 14 25
            Set Location to 15 344
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oSalesRepComboForm to ""
            End_Procedure
        
        End_Object

        Object oStatusComboForm is a ComboForm
            Set Size to 12 77
            Set Entry_State to False
            Set Allow_Blank_State to False
            Set Location to 16 378
            Set Label to 'Status'
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            Set Combo_Sort_State to False
            
            Procedure OnChange
                Set psStatus to (Trim(Left((Value(oStatusComboForm)),1)))
                Send Rebuild_Constraints of oOrder_DD
                Send RefreshDataFromDD of oOrderDbCJGrid ropTop 
                //Send MoveToFirstRow of oOrderDbCJGrid
            End_Procedure

            Procedure Combo_Fill_List
                Forward Send Combo_Fill_List
                Send Combo_Add_Item 'O - Open'
                Send Combo_Add_Item 'X - Canceled'
                Send Combo_Add_Item 'C - Closed'
            End_Procedure            
        End_Object

        Object oStatusClear is a Button
            Set Size to 14 25
            Set Location to 15 455
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oStatusComboForm to ""
            End_Procedure
        
        End_Object
        
        Object oSeasonComboForm is a ComboForm
            Set Size to 12 77
            Set Entry_State to False
            Set Allow_Blank_State to False
            Set Location to 16 486
            Set Label to 'Season'
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            Set Combo_Sort_State to False
            
            Procedure OnChange
                Set psSeason to (Trim(Value(oSeasonComboForm)))
                Send Rebuild_Constraints of oOrder_DD
                Send RefreshDataFromDD of oOrderDbCJGrid ropTop 
                //Send MoveToFirstRow of oOrderDbCJGrid
            End_Procedure

            Procedure Combo_Fill_List
                Forward Send Combo_Fill_List
                Send Combo_Add_Item 'Summer'
                Send Combo_Add_Item 'Winter'
            End_Procedure            
        End_Object
        
        Object oSeasonClear is a Button
            Set Size to 14 25
            Set Location to 15 564
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oSeasonComboForm to ""
            End_Procedure
        
        End_Object

//        Object oCustomerSuggestionForm is a DbSuggestionForm
//            //Entry_Item Customer.Name
//            Set Label to 'Customer'
//            Set Label_Justification_Mode to JMode_Top
//            Set Label_Col_Offset to 0
//            Set peSuggestionMode to smCustom
//            Set pbFullText to True
//            Set piStartAtChar to 1
//            Set Size to 13 100
//            Set Location to 15 609
//            
//            Property String[] psCustomerName
//
//            Procedure OnEnterObject Handle hoFrom
//                Forward Send OnEnterObject hoFrom
//                Handle hoDateSource
//                Integer i
//                String[] sCust
//                tDataSourceRow[] TheData
//                Get phoDataSource of oOrderDbCJGrid to hoDateSource
//                Get DataSource of hoDateSource to TheData
//                For i from 0 to (SizeOfArray(TheData)-1)
//                    Move (TheData[i].sValue[(piColumnId(oCustomer_Name))]) to sCust[i]
//                Loop
//                Set psCustomerName to (SortArray(sCust,Desktop,RefFunc(DFSTRICMP)))
//            End_Procedure
//
//            Procedure OnFindSuggestions String sSearch tSuggestion[]  ByRef aSuggestions
//                Forward Send OnFindSuggestions sSearch (&aSuggestions)
//                String[] sIDs
//                Integer i iLen iIds iCount
//                Move (Lowercase(sSearch)) to sSearch
//                Move (Length(sSearch)) to iLen
//                Get psCustomerName to sIds
//                Move (SizeOfArray(sIds)-1) to iIds
//                For i from 0 to iIds
//                    If (Lowercase(sIds[i]) contains sSearch) Begin
//                        Move sIds[i] to aSuggestions[iCount].sRowId
//                        Move sIds[i] to aSuggestions[iCount].aValues[0]
//                        Increment iCount
//                    End
//                Loop
//
//            End_Procedure
//
//
//            
//        End_Object
        
    End_Object

    Object oOrderDbCJGrid is a cDbCJGrid
        Set Size to 295 712
        Set Location to 38 6
        Set peAnchors to anAll
        //Set Ordering to 1
        //Set pbReverseOrdering to True
        Set pbPromptListBehavior to True
        Set pbStaticData to True
        Set pbAllowAppendRow to False
        Set pbAllowColumnRemove to False
        Set pbAllowDeleteRow to False
        Set pbAllowEdit to False
        Set pbAllowInsertRow to False
        Set pbAutoSave to False
        Set pbSelectionEnable to True
        //Set piHighlightBackColor to clOrange
        Set pbUseAlternateRowBackgroundColor to True
        Set pbHeaderReorders to True
        Set pbHeaderSelectsColumn to True
        Set pbHeaderTogglesDirection to True
        Set Scope_State to True

        Object oOrder_JobNumber is a cDbCJGridColumn
            Entry_Item Order.JobNumber
            Set piWidth to 82
            Set psCaption to "JobNumber"
            Set pbEditable to False
        End_Object

        Object oOrder_JobOpenDate is a cDbCJGridColumn
            Entry_Item Order.JobOpenDate
            Set piWidth to 101
            Set psCaption to "JobOpenDate"
            Set pbEditable to False
        End_Object

        Object oOrder_LineItemCompCount is a cDbCJGridColumn
            Send CreateNumericMask 3 0
            Set piWidth to 76
            Set psCaption to "Completed"
            Set psMask to '#0,%'
            
            
            Procedure OnSetCalculatedValue String ByRef sValue
                Move (Order.LineItemCompCount/Order.LineItemReqCount*100) to sValue
            End_Procedure

            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                
                Case Begin
                    Case (sValue = '100')
                        Set ComForeColor of hoGridItemMetrics to clGreen
                        Case Break
                    Case (sValue = '0')
                        Set ComForeColor of hoGridItemMetrics to clBlack
                        Case Break
                    Case Else
                        Set ComForeColor of hoGridItemMetrics to clOrange
                Case End
                
            End_Procedure

        End_Object

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 127
            Set psCaption to "Customer"
        End_Object

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 127
            Set psCaption to "Location"
        End_Object

        Object oOrder_Title is a cDbCJGridColumn
            Entry_Item Order.Title
            Set piWidth to 225
            Set psCaption to "Title"
            Set pbEditable to False
        End_Object

        Object oOrder_OrderTotalAmount is a cDbCJGridColumn
            Entry_Item Order.OrderTotalAmount
            Set piWidth to 73
            Set psCaption to "Amount"
        End_Object

        Object oSalesRep is a cDbCJGridColumn
            //Entry_Item SalesRep.LastName
            Set piWidth to 135
            Set psCaption to "SalesRep"
            Set pbEditable to False

            Procedure OnSetCalculatedValue String  ByRef sValue
                Forward Send OnSetCalculatedValue (&sValue)
                Move (Trim(SalesRep.FirstName)*Trim(SalesRep.LastName)) to sValue
            End_Procedure
            
        End_Object

        Object oOrder_Division is a cDbCJGridColumn
            Entry_Item Order.Division
            Set piWidth to 184
            Set psCaption to "Division"
            Set pbEditable to False
        End_Object

        Object oOrder_Status is a cDbCJGridColumn
            Entry_Item Order.Status
            Set piWidth to 57
            Set psCaption to "Status"
            Set pbEditable to False
            Set pbComboButton to True
        End_Object

        Procedure Activating
            Forward Send Activating
            Send MoveToFirstRow of oOrderDbCJGrid
        End_Procedure
        
        Procedure OnComRowDblClick Variant llRow Variant llItem
            Forward Send OnComRowDblClick llRow llItem
            Send Activate_oOrderEntry
        End_Procedure

        Procedure Search
            Handle hoCol
            Get SelectedColumnObject to hoCol 
            Send RequestColumnSearch hoCol 0 0
        End_Procedure
        
        Procedure GridRefresh
            //Send RefreshDataFromSelectedRow
            Send Initialize_StatusPanel of ghoStatusPanel "Refreshing Data" "Grid Refresh" "Loading..."
            Send Start_StatusPanel of ghoStatusPanel
            Send RefreshDataFromDD of oOrderDbCJGrid ropTop
            Send MoveToFirstRow of oOrderDbCJGrid
            Send Stop_StatusPanel of ghoStatusPanel
        End_Procedure

        Procedure Entering_Scope Returns Integer
            Integer iRetVal
            Forward Get msg_Entering_Scope to iRetVal
            
            Send RefreshDataFromSelectedRow
            Procedure_Return iRetVal
        End_Procedure

        Procedure OnCreateGridControl
            Forward Send OnCreateGridControl
            Set Ordering to 1 //Index 1 - Order.JobNumber
            Set pbReverseOrdering to True //Latest on top
            Set piSortColumn to 0 // JobNumber
        End_Procedure
        
        

        On_Key Key_Ctrl+Key_F Send Search of oOrderDbCJGrid
        On_Key Key_F5 Send GridRefresh of oOrderDbCJGrid
        
    End_Object

End_Object 
