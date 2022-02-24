Use Windows.pkg
Use DFClient.pkg
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use dfSelLst.pkg
Use dfTabDlg.pkg
Use dfLine.pkg
Use szcalendar.pkg
Use dfTable.pkg
Use cCJGrid.pkg
Use POInpusModalDialog.dg
Use cProgressBar.pkg
Use cCJGridColumn.pkg
Use Customer.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD


Activate_View Activate_oInvoiceReview for oInvoiceReview
Object oInvoiceReview is a dbView
    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oProject_DD is a cProjectDataDictionary
    End_Object

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
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
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
        
        Procedure OnConstrain
            Constrain Order.Status eq "C"  
            Constrain Order.SalesInvoiceOK lt "01/01/1900" // BEN - Uncommend after Testing for full restrictions
            Constrain Order.OpsCostOK gt "01/01/1900"
            If (giUserRights LT "60") Begin
                Constrain Order.RepIdno eq giSalesRepId
            End
        End_Procedure
        
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD
    
    Set Border_Style to Border_Thick
    Set Size to 333 568
    Set Location to 7 1
    Set Label to "Invoice Review"
    
    Object oInvoiceReviewList is a cGlblDbList
        Set Main_File to Order.File_Number          
        Set Size to 308 553
        Set Location to 3 6
        Set Ordering to 10
        Set CurrentRowColor to clLtGray
        Set CurrentCellColor to clLtGray
        Set peAnchors to anAll
        Set Read_Only_State to True
        Set GridLine_Mode to Grid_Visible_Horz
        Set Auto_Index_State to False
        Set Auto_Fill_State to True
                
        Begin_Row      
            Entry_Item Order.JobNumber
            Entry_Item Customer.Name
            Entry_Item Location.Name
            Entry_Item Order.JobOpenDate
            Entry_Item Order.OpsCostOK
            Entry_Item SalesRep.LastName
            Entry_Item Order.ReturnMemo
        End_Row  
        

        Set Form_Width 0 to 28
        Set Header_Label 0 to "Job"
        Set Form_Width 1 to 123
        Set Header_Label 1 to "Customer"
        Set Form_Width 2 to 112
        Set Header_Label 2 to "Location"
        Set Form_Width 3 to 60
        Set Header_Label 3 to "Job Opened"
        Set Form_Width 4 to 60
        Set Header_Label 4 to "Cost Completed"
        Set Form_Width 5 to 71
        Set Header_Label 5 to "Sales Rep"
        Set Form_Width 6 to 100
        Set Header_Label 6 to "ReturnMemo"


        
        Procedure Change_Row_Color Integer iColor
            Integer iBase iItem iItems
         
            Get Base_Item to iBase               // first item of current row
            Get Item_Limit to iItems              // items per row
            Move (iBase+iItems-1) to iItems     // last item in the current row
         
            For iItem from iBase to iItems         // set all items in row to color 
                Set ItemColor iItem to iColor
            Loop
            Procedure_Return
        End_Procedure // Change_Row_Color
        
        Procedure Entry_Display Integer iFile Integer iType
            Integer iColor iItem iDateSum
            Date dToday dDateSum
            Boolean bReturned
            Sysdate dToday
            If (Order.OpsCostOK>0) Begin
                Move (dToday-Order.OpsCostOK) to iDateSum
            End
            Move (Order.ReturnFlag>0) to bReturned
            
            Case Begin
                Case (iDateSum <=3)
                    Move 13172178 to iColor // Green
                    Case Break
                Case (iDateSum >3 and iDateSum <=10)
                    Move 13106938 to iColor // Yellow
                    Case Break
                Case Else
                    Move 8157695 to iColor //Red 
            Case End

            Send Change_Row_Color iColor
            If (bReturned) Begin
                Get Base_Item to iItem // first item of the current row
                Set ItemColor (iItem+6) to clRed // Fifth column
            End                   
            Forward Send Entry_Display iFile iType
        End_Procedure        

        Procedure Mouse_Click Integer iWindowNumber Integer iPosition
            Boolean bHasOrderRecord
            Get HasRecord of oOrder_DD to bHasOrderRecord
            If (bHasOrderRecord) Begin
                Send DoViewOrder of oOrderEntry Order.Recnum
            End
        End_Procedure
        
    End_Object

//    Object oDbTabDialog1 is a dbTabDialog
//        Set Size to 129 550
//        Set Location to 190 7
//    
//        //Set Rotate_Mode to RM_Rotate
//        Set peAnchors to anTopLeftRight
//
//        Object oDbTabPage1 is a dbTabPage
//            Set Label to 'Labor Detail'
//
//            Object oLaborDetail is a cGlblDbGrid
//                Set Size to 97 528
//                Set Location to 11 9
//                //Set Move_Value_Out_State to False
//                Set Read_Only_State to True
//                Set Enabled_State to False
//                Set peAnchors to anAll
//         
//                                 
//                Function MinInHours Returns Number
//                    Number nNumber
//                    Move Trans.ElapsedMinutes to nNumber
//                    Calc (nNumber/60.00) to nNumber
//                    Function_Return nNumber
//                End_Function
//                
//                Begin_Row
//                    Entry_Item MastOps.Name
//                    Entry_Item Employee.LastName
//                    Entry_Item Trans.StartDate
//                    Entry_Item (MinInHours(Self))
//                End_Row
//                
//                Set Main_File to Trans.File_Number
//                Set Server to oTrans_DD       
//                
//                Set Header_Label 0 to "Operation"
//                Set Form_Width 0 to 198
//                
//                Set Header_Label 1 to "Lastname"
//                Set Form_Width 1 to 95
//                
//                Set Header_Label 2 to "StartDate"
//                Set Form_Width 2 to 60
//                
//                Set Header_Label 3 to "Hours"
//                Set Form_Width 3 to 72
//                Set Form_Datatype 3 to Mask_Numeric_Window
//                Set Form_Mask 3 to "#0.00"
//            End_Object
//        End_Object
//
//        Object oDbTabPage2 is a dbTabPage
//            Set Label to 'Job Cost Detail'
//           
//            Object oDbGrid1 is a cGlblDbGrid
//                Set Size to 97 528
//                Set Location to 11 9
//                //Set Move_Value_Out_State to False
//                Set Read_Only_State to True
//                Set Enabled_State to False
//                Set peAnchors to anAll
//                
//                Begin_Row
//                    Entry_Item MastOps.Name
//                    Entry_Item Jobcosts.WorkDate
//                    Entry_Item Jobcosts.Quantity
//                    Entry_Item Jobcosts.UnitCost
//                    Entry_Item Jobcosts.TotalCost
//                    Entry_Item Jobcosts.Notes
//                End_Row
//
//                Set Main_File to Jobcosts.File_Number
//
//                Set Server to oJobcosts_DD
//
//                Set Form_Width 0 to 109
//                Set Header_Label 0 to "Name"
//                Set Form_Width 1 to 60
//                Set Header_Label 1 to "WorkDate"
//                Set Form_Width 2 to 60
//                Set Header_Label 2 to "Quantity"
//                Set Form_Width 3 to 60
//                Set Header_Label 3 to "UnitCost"
//                Set Form_Width 4 to 60
//                Set Header_Label 4 to "TotalCost"
//                Set Form_Width 5 to 223
//                Set Header_Label 5 to "Notes"
//            End_Object
//        End_Object
//    
//    End_Object
//       
//        Function CalculateSalesCommision Returns Number
//            Number nCommission
//            If (SalesRep.ComissionFlag = 1) Move (Quotehdr.SubTotal * .045) to nCommission
//            Function_Return nCommission
//        End_Function
//        
//        Function CalculateNetProfit Returns Number
//            Number nProfit
//            If (Quotehdr.SubTotal and SalesRep.ComissionFlag = 1) Begin
//                Move (1-((Order.JobCostTotal + (Order.LaborMinutes/60.00*System.Labor_Rate) + (Order.TravelMinutes/60.00*System.Labor_Rate) + Order.SalesComm) / Quotehdr.SubTotal)*100) to nProfit
//            End
//            Else If (Quotehdr.SubTotal and SalesRep.ComissionFlag = 0) Begin
//                Move (1-((Order.JobCostTotal + (Order.LaborMinutes/60.00*System.Labor_Rate) + (Order.TravelMinutes/60.00*System.Labor_Rate)) / Quotehdr.SubTotal)*100) to nProfit
//            End
//            Function_Return nProfit
//        End_Function
//
//        Function CalcJobCostTotal Returns Number
//            Number nTotalJobCost            
//
//            If (SalesRep.ComissionFlag = 1 ) Begin
//               Move (Order.JobCostTotal + (Order.LaborMinutes/60.00*System.Labor_Rate) + (Order.TravelMinutes/60.00*System.Labor_Rate) + (Quotehdr.SubTotal * .045)) to nTotalJobCost
//            End
//            Else If (SalesRep.ComissionFlag = 0 ) Begin
//                Move (Order.JobCostTotal + (Order.LaborMinutes/60.00*System.Labor_Rate) + (Order.TravelMinutes/60.00*System.Labor_Rate)) to nTotalJobCost
//            End
//                
//            Function_Return nTotalJobCost
//        End_Function    
//
//        Function GetSubTotal Returns Number 
//            Function_Return Quotehdr.SubTotal
//        End_Function
//
//        Function GetTaxTotal Returns Number 
//            Function_Return Quotehdr.TaxTotal
//        End_Function
//
//        Function GetTotal Returns Number
//            Function_Return Quotehdr.Amount
//        End_Function
//        
//        Object oOrder_LaborCost is a cGlblDbForm
//            Entry_Item ((Order.LaborMinutes + Order.TravelMinutes)/60.00*System.Labor_Rate)
//            Set Location to 7 633
//            Set Size to 13 66
//            Set Label to "Labor Cost:"
//            Set Label_Col_Offset to 3
//            Set Label_Justification_Mode to JMode_Right
//            Set Enabled_State to False
//            Set peAnchors to anTopRight
//            Set Form_Datatype to Mask_Numeric_Window
//            Set Form_Mask to "$ #,###,##0.00"
//        End_Object
//        
//        Object oOrder_SuppliesCost is a cGlblDbForm
//            Entry_Item Order.SuppliesCost
//            Set Location to 26 633
//            Set Size to 13 66
//            Set Label to "Supplies Cost:"
//            Set Enabled_State to False
//             Set Label_Col_Offset to 3
//             Set Label_Justification_Mode to JMode_Right
//            Set peAnchors to anTopRight
//            Set Form_Datatype to Mask_Numeric_Window
//            Set Form_Mask to "$ #,###,##0.00"
//        End_Object
//        
//        Object oOrder_EquipmentCost is a cGlblDbForm
//            Entry_Item Order.EquipmentCost
//            Set Location to 46 633
//            Set Size to 13 66
//            Set Label to "Equipment Cost:"
//            Set Enabled_State to False
//            Set Label_Col_Offset to 3
//            Set Label_Justification_Mode to JMode_Right
//            Set peAnchors to anTopRight
//            Set Form_Datatype to Mask_Numeric_Window
//            Set Form_Mask to "$ #,###,##0.00"
//        End_Object
//        
//        Object oOrder_OutsideSvcsCost is a cGlblDbForm
//            Entry_Item Order.OutsideSvcsCost
//            Set Location to 65 633
//            Set Size to 13 66
//            Set Label to "OS Services Cost:"
//            Set Enabled_State to False
//            Set Label_Col_Offset to 3
//            Set Label_Justification_Mode to JMode_Right
//            Set peAnchors to anTopRight
//            Set Form_Datatype to Mask_Numeric_Window
//            Set Form_Mask to "$ #,###,##0.00"
//        End_Object
//        Object oOrder_SalesComm is a cGlblDbForm
//            //Entry_Item (Order.QuoteAmount * .045)
//            Entry_Item (CalculateSalesCommision(Self))
//            Set Location to 85 633
//            Set Size to 13 66
//            Set Label to "Sales Commission:"
//            Set Enabled_State to False
//            Set Label_Col_Offset to 3
//            Set Label_Justification_Mode to JMode_Right
//            Set peAnchors to anTopRight
//            Set Form_Justification_Mode to Form_DisplayRight
//            Set Form_Datatype to Mask_Numeric_Window
//            Set Form_Mask to "$ #,###,##0.00"
//        End_Object
//        
//        Object oLineControl1 is a LineControl
//            Set Size to 2 693
//            Set Location to 106 5
//            Set Line_Thickness to 5
//            Set peAnchors to anTopLeftRight
//        End_Object
//        
//        Object oOrder_JobCostTotal is a cGlblDbForm
//            Entry_Item (CalcJobCostTotal(Self))
//            Set Location to 113 633
//            Set Size to 13 66
//            Set Label to "Job Cost Total:"
//            Set Enabled_State to False
//            Set Label_FontWeight to 600
//            Set Label_Col_Offset to 3
//            Set Label_Justification_Mode to JMode_Right
//            Set peAnchors to anTopRight
//            Set Form_Justification_Mode to Form_DisplayRight
//            Set Form_Datatype to Mask_Numeric_Window
//            Set Form_Mask to "$ #,###,##0.00"
//        End_Object
//
//        Object oQuote_SubTotal is a cGlblDbForm
//            Entry_Item (GetSubTotal(Self))
//            Set Location to 137 633
//            Set Size to 13 66
//            Set Label to "Sub Total:"
//            Set Label_Col_Offset to 3
//            Set Enabled_State to False
//            Set Label_FontWeight to 600
//            Set Label_Justification_Mode to JMode_Right
//            Set peAnchors to anTopRight
//            Set Form_Datatype to Mask_Numeric_Window
//            Set Form_Mask to "$ #,###,##0.00"
//        End_Object
//
//        Object oQuote_TaxTotal is a cGlblDbForm
//            Entry_Item (GetTaxTotal(Self))
//            Set Location to 153 633
//            Set Size to 13 66
//            Set Label to "Sales Tax:"
//            Set Label_Col_Offset to 3
//            Set Enabled_State to False
//            Set Label_FontWeight to 600
//            Set Label_Justification_Mode to JMode_Right
//            Set peAnchors to anTopRight
//            Set Form_Datatype to Mask_Numeric_Window
//            Set Form_Mask to "$ #,###,##0.00"
//        End_Object
//        
//        Object oQuote_QuoteAmount is a cGlblDbForm
//            Entry_Item (GetTotal(Self))
//            Set Location to 173 633
//            Set Size to 13 66
//            Set Label to "Invoice Total:"
//            Set Label_Col_Offset to 3
//            Set Enabled_State to False
//            Set Label_FontWeight to 600
//            Set Label_Justification_Mode to JMode_Right
//            Set peAnchors to anTopRight
//            Set Form_Datatype to Mask_Numeric_Window
//            Set Form_Mask to "$ #,###,##0.00"
//        End_Object
        
//        Object oOrder_NetProfit is a cGlblDbForm
//            Entry_Item (CalculateNetProfit(Self))
//            Set Location to 113 234
//            Set Size to 13 56
//            Set Label to "Profit: "
//            Set Label_Col_Offset to 3
//            Set Label_Justification_Mode to JMode_Right
//            Set Label_FontWeight to 600
//            Set TextColor to clBlack
//            Set Entry_State to False
//            Set FontWeight to 600
//            Set Form_Datatype to Mask_Currency_Window
//            Set Form_Datatype of oOrder_NetProfit to Mask_Numeric_Window
//            Set Form_Mask of oOrder_NetProfit to "#,###,##0.00 %"
//        End_Object

        Object oSalesOkButton is a Button
            Set Size to 14 70
            Set Location to 316 481
            Set Label to 'Sales OK to Invoice'
            //Set Delegation_Mode to No_Delegate_Or_Error
            Set FontWeight to 600
            Set peAnchors to anBottomRight
    
            Procedure OnClick
                Send TriggerInvoice of oOrderEntry
                Send Refresh_Page of oInvoiceReviewList FILL_FROM_BOTTOM
            End_Procedure
    
        End_Object
        
        Object oViewQuoteButton is a Button
            Set Size to 14 80
            Set Location to 316 322
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

 

//    Object oCJGrid1 is a cdbCJGrid
//        Set Server to oProdNote_DD
//        Set Size to 55 553
//        Set Location to 257 12
//        Set pbGrayIfDisable to False
//        Set pbAllowAppendRow to False
//        Set pbAllowColumnRemove to False
//        Set pbAllowColumnReorder to False
//        Set pbAllowDeleteRow to False
//        Set pbAllowEdit to False
//        Set pbAllowInsertRow to False
//        Set pbAutoAppend to False
//
//        Object oProdNote_JobNumber is a cDbCJGridColumn
//            Entry_Item Order.JobNumber
//            Set piWidth to 71
//            Set psCaption to "JobNumber"
//            Set Prompt_Button_Mode to PB_PromptOff
//        End_Object
//
//        Object oProdNote_CreatedDate is a cDbCJGridColumn
//            Entry_Item ProdNote.CreatedDate
//            Set piWidth to 113
//            Set psCaption to "CreatedDate"
//        End_Object
//
//        Object oProdNote_CreatedBy is a cDbCJGridColumn
//            Entry_Item ProdNote.CreatedBy
//            Set piWidth to 212
//            Set psCaption to "CreatedBy"
//        End_Object
//
//        Object oProdNote_Note is a cDbCJGridColumn
//            Entry_Item ProdNote.Note
//            Set piWidth to 571
//            Set psCaption to "Note"
//            Set Prompt_Button_Mode to PB_PromptOff
//        End_Object
//    End_Object

//    Object oOrder_TravelCost is a cGlblDbForm
//        Entry_Item (Order.TravelMinutes/60.00*System.Labor_Rate)
//        Set Location to 28 529
//        Set Size to 13 66
//        Set Label to "Travel Cost:"
//        Set Label_Col_Offset to 3
//        Set Label_Justification_Mode to JMode_Right
//        Set Enabled_State to False
//        Set peAnchors to anTopRight
//    End_Object
    


//    Register_Object oQuoteEntry
    //
 
//    Procedure DoViewQuote
//        Send Refind_Records of oOrder_DD
//        Send DoViewQuote of oQuoteEntry Order.QuoteReference
//    End_Procedure

    Object oPrintJobCostButton is a Button
       Set Size to 14 64
       Set Location to 316 408
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
    
End_Object
//Cd_End_Object
