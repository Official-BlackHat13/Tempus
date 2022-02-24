// Z:\VDF17.0 Workspaces\Tempus\AppSrc\InvoiceReview.vw
// InvoiceReview
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use Customer.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use dfSelLst.pkg
Use cDbCJGrid.pkg
Use cCJCommandBarSystem.pkg
Use cdbCJGridColumn.pkg

ACTIVATE_VIEW Activate_oInvoiceReview FOR oInvoiceReview
Object oInvoiceReview is a cGlblDbView
    Set Location to 5 4
    Set Size to 300 570
    Set Label To "InvoiceReview"
    Set Border_Style to Border_Thick


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD is a Areas_DataDictionary
    End_Object // oAreas_DD

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object // oSalesTaxGroup_DD

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
        Set DDO_Server To oSalesTaxGroup_DD
    End_Object // oLocation_DD

    Object oSalesRep_DD is a Salesrep_DataDictionary
        Procedure OnConstrain
            // Constrain from Sales Rep Filter on view
            String sSalesRepValue
            Get Value of oSalesRepCombo to sSalesRepValue
            Move (Ltrim(sSalesRepValue)) to sSalesRepValue
            If ((Length(sSalesRepValue))>0) Begin
                Constrain SalesRep.LastName eq sSalesRepValue
            End 
        End_Procedure
    End_Object // oSalesRep_DD

    Object oOrder_DD is a Order_DataDictionary
        Set Read_Only_State to True
        Set DDO_Server To oLocation_DD
        Set DDO_Server to oSalesRep_DD  
              
        Procedure OnConstrain
            Constrain Order.OpsCostOK_Flag eq 1
            Constrain Order.WriteOffFlag eq 0
            Constrain Order.SalesInvoiceOK_Flag eq 0 // BEN - Uncommend after Testing for full restrictions
            Constrain Order.Status eq "C"  
            If (giUserRights LT "60") Begin
                Constrain Order.RepIdno eq giSalesRepId
            End
        End_Procedure
    End_Object // oOrder_DD

    Set Main_DD To oOrder_DD
    Set Server  To oOrder_DD

    Object oInvoiceReviewGrid is a cDbCJGrid
        Set Size to 266 561
        Set Location to 2 3
        Set peAnchors to anAll
        //Set Ordering to 1
        //Set pbReverseOrdering to True
        Set pbPromptListBehavior to True
        Set pbReadOnly to True
        Set pbStaticData to True
        Set pbSelectionEnable to True
        //Set piHighlightBackColor to clOrange
        Set pbUseAlternateRowBackgroundColor to True
        Set pbHeaderReorders to True
        Set pbHeaderSelectsColumn to True
        Set pbHeaderTogglesDirection to True
        Set Scope_State to True
        Set pbShowFooter to True
        Set pbFocusSubItems to False

        Object oOrder_JobNumber is a cDbCJGridColumn
            Entry_Item Order.JobNumber
            Set piWidth to 48
            Set psCaption to "Job#"
            Set pbDrawFooterDivider to False
        End_Object

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 84
            Set psCaption to "Customer"
            Set pbDrawFooterDivider to False
        End_Object

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 143
            Set psCaption to "Location"
            Set pbDrawFooterDivider to False
        End_Object

        Object oOrder_Title is a cDbCJGridColumn
            Entry_Item Order.Title
            Set piWidth to 275
            Set psCaption to "Title"
            Set pbDrawFooterDivider to False
        End_Object

        Object oOrder_BillingType is a cDbCJGridColumn
            Entry_Item Order.BillingType
            Set piWidth to 65
            Set psCaption to "Billing"
            Set pbComboButton to True
            Set pbDrawFooterDivider to False
        End_Object

        Object oOrder_OpsCostOK is a cDbCJGridColumn
            Entry_Item Order.OpsCostOK
            Set piWidth to 82
            Set psCaption to "Cost OK"
            Set pbDrawFooterDivider to False
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iDaysOld
                Date dToday dOpsCostOK
                Sysdate dToday
                Get RowValue of oOrder_OpsCostOK iRow to dOpsCostOK
                Move (dToday-dOpsCostOK) to iDaysOld
                Case Begin
                    Case (iDaysOld < 5)
                        Set ComForeColor of hoGridItemMetrics to clGreen
                        Case Break
                    Case (iDaysOld >= 5 and iDaysOld <=14)
                        Set ComForeColor of hoGridItemMetrics to clOrange
                        Case Break
                    Case Else
                        Set ComForeColor of hoGridItemMetrics to clRed
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            
        End_Object

        Object oSalesRep_LastName is a cDbCJGridColumn
            Entry_Item SalesRep.LastName
            Set piWidth to 89
            Set psCaption to "Sales Rep"
            Set pbDrawFooterDivider to False
        End_Object

        Object oOrder_ReturnMemo is a cDbCJGridColumn
            Entry_Item Order.ReturnMemo
            Set piWidth to 104
            Set psCaption to "ReturnMemo"
            Set psFooterText to "Total Invoices:"
            Set pbDrawFooterDivider to False

            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                String sReturnMemo
                Get RowValue of oOrder_ReturnMemo iRow to sReturnMemo
                If (Length(sReturnMemo) <> 0) Begin
                    Set ComForeColor of hoGridItemMetrics to clRed
                End
                Else Set ComForeColor of hoGridItemMetrics to clDefault
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
        End_Object

        Object oOrder_OrderTotalAmount is a cDbCJGridColumn
            Entry_Item Order.OrderTotalAmount
            Set piWidth to 91
            Set psCaption to "Total"
            Set pbDrawFooterDivider to False
        End_Object

        Object oCJContextMenu1 is a cCJContextMenu
            Object oViewMenuItem is a cCJMenuItem
                Set psCaption to "Refresh View"
                Set psTooltip to "Refresh View"

                Procedure OnExecute Variant vCommandBarControl
                    Forward Send OnExecute vCommandBarControl
                    Send RefreshGrid
                End_Procedure
            End_Object

//            Object oWriteOffMenuItem is a cCJMenuItem
//                Set psCaption to "Write-Off"
//                Set psTooltip to "Write-Off"
//
//                Procedure OnExecute Variant vCommandBarControl
//                    Forward Send OnExecute vCommandBarControl
//                    Send Cursor_Wait to Cursor_Control
//                    Send UpdateCurrentValue of oOrder_WriteOffFlag True
//                    Send Request_Save of oOrder_DD
//                    Send Cursor_Ready to Cursor_Control  
//                    Send RefreshGrid
//                    
//                End_Procedure
//            End_Object
//            
//            Procedure OnCreate
//                Forward Send OnCreate
//                //
//                Set pbVisible of oWriteOffMenuItem to (giUserRights >=70) // Only visible for Admin and higher
//            End_Procedure
            
        End_Object

        Object oOrder_WriteOffFlag is a cDbCJGridColumn
            Entry_Item Order.WriteOffFlag
            Set pbCheckbox to True
            Set piWidth to 18
            Set psCaption to "WriteOffFlag"
            Set pbVisible to False
        End_Object

        Procedure OnComRowDblClick Variant llRow Variant llItem
            Forward Send OnComRowDblClick llRow llItem
            //
            If (HasRecord(oOrder_DD)) Begin
                Send DoViewOrder of oOrderEntry Order.Recnum
            End
        End_Procedure
                
        Procedure RefreshGrid
            Handle hoDataSource
            tDataSourceRow[] TheData
            Integer iRows i
            Number nTotalAmount
            //
            Send Initialize_StatusPanel of ghoStatusPanel "Refreshing Data" "Grid Refresh" "Loading..."
            Send Start_StatusPanel of ghoStatusPanel
            //
            Get phoDataSource to hoDataSource
            //
            Send Rebuild_Constraints of oOrder_DD
            Send MovetoFirstRow of oInvoiceReviewGrid
            Send Reset of hoDataSource
            //
            Get DataSource of hoDataSource to TheData
            Move (SizeOfArray(TheData)) to iRows
            For i from 0 to (iRows-1)
                Move (nTotalAmount + TheData[i].sValue[8]) to nTotalAmount
            Loop
            //Total
            Set psFooterText of oOrder_OrderTotalAmount to (String(FormatCurrency(nTotalAmount,2)))
            Send Stop_StatusPanel of ghoStatusPanel
        End_Procedure

        Procedure OnComMouseDown Short llButton Short llShift Integer llx Integer lly
            If (llButton=2) Send Popup of oCJContextMenu1
            Else Forward Send OnComMouseDown llButton llShift llx lly
        End_Procedure

        Procedure Search
            Handle hoCol
            Get SelectedColumnObject to hoCol 
            Send RequestColumnSearch hoCol 0 0
        End_Procedure
        
        Procedure Entering_Scope Returns Integer
            Integer iRetVal
            Forward Get msg_Entering_Scope to iRetVal
            If (not(iRetVal)) Begin
                Send RefreshDataFromSelectedRow
            End
            Procedure_Return iRetVal
        End_Procedure

        Procedure OnCreateGridControl
            Forward Send OnCreateGridControl
            Set Ordering to 15 //Index 1 - Order.JobNumber
            //Set pbReverseOrdering to True //Latest on top
            Set piSortColumn to 5 // JobNumber
        End_Procedure
        

    End_Object

    Object oViewOrderButton is a Button
        Set Size to 14 80
        Set Location to 278 412
        Set Label to "View Order"
        Set peAnchors to anBottomRight
                    
        Procedure OnClick
            Boolean bHasOrderRecord
            Get HasRecord of oOrder_DD to bHasOrderRecord
            If (bHasOrderRecord) Begin
                Send DoViewOrder of oOrderEntry Order.Recnum
            End
        End_Procedure
    End_Object
    
    Object oPrintJobCostButton is a Button
       Set Size to 14 64
       Set Location to 278 497
       Set Label to "Cost Sheet"
        Set peAnchors to anBottomRight
   
       Procedure OnClick
           Integer iJobNumber
           //
           Get Field_Current_Value of oOrder_DD Field Order.JobNumber to iJobNumber
           If (iJobNumber <> 0) Begin
               Send DoJumpStartReport of PrintCostSheet iJobNumber
           End
       End_Procedure
   End_Object

    Object oSalesRepFilterDbGroup is a dbGroup
        Set Size to 25 135
        Set Location to 270 265
        Set Label to 'SalesRep Filter'
        Set peAnchors to anBottomRight
    
        Object oSalesRepCombo is a ComboForm
           Set Size to 14 100
           Set Allow_Blank_State to True
           Set Location to 9 4
           Set Label to ""
           Set Label_Justification_Mode to JMode_Right
           Set Label_Col_Offset to 5
    
            Procedure OnChange
                Send RefreshGrid of oInvoiceReviewGrid
            End_Procedure
    
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
           End_Object
       
       Object oClearButton is a Button
           Set Size to 15 25
           Set Location to 8 106
           Set Label to 'Clear'
       
           // fires when the button is clicked
           Procedure OnClick
               //Clear Value in Filter
               Set Value of oSalesRepCombo to ""
           End_Procedure
       
       End_Object
    End_Object

//    Procedure OnSetFocus
//        Forward Send OnSetFocus
//        Send RefreshDataFromDD of oInvoiceReviewGrid ropTop
//    End_Procedure


//    Object oSalesOkButton is a Button
//        Set Size to 14 70
//        Set Location to 277 357
//        Set Label to 'Sales OK to Invoice'
//        //Set Delegation_Mode to No_Delegate_Or_Error
//        Set FontWeight to 600
//        Set peAnchors to anBottomRight
// 
//        Procedure OnClick
//            Send TriggerInvoice of oOrderEntry
//            Send MovetoFirstRow of oInvoiceReviewGrid
//        End_Procedure
// 
//    End_Object
    
End_Object // oInvoiceReview
