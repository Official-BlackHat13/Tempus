Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use cSnowrepDataDictionary.dd
Use Contact.DD
Use cQuotehdrDataDictionary.dd
Use cProdNoteGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cCJGridPromptList.pkg
Use dfSelLst.pkg
Use cDbCJGrid.pkg
Use cDbCJGridPromptList.pkg
Use cGlblDbForm.pkg
Use PrintJobSheet.rv
Use OrderInvoicePreviewReport.rv
Use dfTable.pkg

Activate_View Activate_oOrdersOpen for oOrdersOpen
//Deferred_View Activate_oOrdersOpen for ;

Object oOrdersOpen is a dbView
    Set Border_Style to Border_Thick
    Set Size to 293 646
    Set Location to 2 5
    Set Label to "Open Orders"

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object
    
    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Procedure OnConstrain
            Constrain Order.Status eq "O"
//            Constrain Order.JobOpenDate ge "01/01/2014"
//            Constrain Order.JobCloseDate le "01/01/1900"
//            Constrain Order.PromiseDate le "01/01/1900"
            // Worktype
            If (not(Checked_State(oSnowCheckBox(Self)))) Constrain Order.WorkType ne "S"
            If (not(Checked_State(oPMCheckBox(Self)))) Constrain Order.WorkType ne "P"
            If (not(Checked_State(oSweepingCheckBox(Self)))) Constrain Order.WorkType ne "SW"
            If (not(Checked_State(oExcavationCheckBox(Self)))) Constrain Order.WorkType ne "E"
            If (not(Checked_State(oCapitalCheckBox(Self)))) Constrain Order.WorkType ne "CE"
            If (not(Checked_State(oShopLaborCheckBox(Self)))) Constrain Order.WorkType ne "SL"
            If (not(Checked_State(oConnexBoxCheckBox(Self)))) Constrain Order.WorkType ne "CX"
            If (not(Checked_State(oOtherCheckBox(Self)))) Constrain Order.WorkType ne "O"
            // BillingType
            If (not(Checked_State(oStandardCheckBox(Self)))) Constrain Order.BillingType ne "S"
            If (not(Checked_State(oTNMCheckBox(Self)))) Constrain Order.BillingType ne "T"
            If (not(Checked_State(oMonthlyCheckBox(Self)))) Constrain Order.BillingType ne "M"
            If (not(Checked_State(oNoChargeCheckBox(Self)))) Constrain Order.BillingType ne "N"
        End_Procedure
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oProdNote_DD is a cProdNoteGlblDataDictionary
        Set DDO_Server to oSalesRep_DD
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD

    Property Integer piSelectedWorkType

//    Object oRefreshMyListTime is a DFTimer
//        //Set Timer_Active_State of oRefreshMyListTime to True
//        //Set Timer_Object to oOpenPMJobList
//        Set Timeout            to 10000 // 60000 = 60 seconds, 1 minutes
//        Procedure OnTimer
//            Forward Send Refresh of oOpenJobList
//            
//        End_Procedure
//    End_Object // oServiceTimer

    
    Object oOpenJobList is a cGlblDbList
        Set Size to 236 634
        Set Location to 36 5
        Set Main_File to Order.File_Number
        Set Move_Value_Out_State to False
        
        Begin_Row
            Entry_Item Order.JobNumber
            Entry_Item Order.JobOpenDate
            Entry_Item Customer.Name
            Entry_Item Location.Name
            Entry_Item Order.WorkType
            Entry_Item Order.Title
            Entry_Item Order.OrderTotalAmount
        End_Row

        Set Form_Width 0 to 35
        Set Header_Label 0 to "Job #"
        Set Form_Width 1 to 57
        Set Header_Label 1 to "JobOpenDate"
        Set Form_Width 2 to 138
        Set Header_Label 2 to "Opened On"
        Set Form_Width 3 to 140
        Set Header_Label 3 to "Location"
        Set Form_Width 5 to 151
        Set Header_Label 5 to "Title"
        Set Form_Width 4 to 40
        Set Header_Label 4 to "WorkType"
        Set Column_Combo_State 6 to True
        Set Form_Width 6 to 72
        Set Header_Label 6 to "Amount"
        
        Set GridLine_Mode to Grid_Visible_Horz
        Set Seed_List_State to True
        Set Move_Value_Out_State to False
        Set Auto_Index_State to False
        Set Initial_Row to FILL_FROM_BOTTOM
        Set peAnchors to anAll
        Set peGridLineColor to clBtnShadow
        Set pbHeaderTogglesDirection to True
        Set Ordering to 9
        Set pbUseServerOrdering to True
        Set Read_Only_State to True
        
        Procedure Refresh Integer eMode
            Handle hoServer
            Boolean bHasRecord
        
            Get Server to hoServer              // get the ddo
            Get HasRecord of hoServer to bHasRecord // get record in ddo
            Forward Send Refresh eMode          // do normal refresh
            Send Rebuild_Constraints of oOrder_DD
            
        End_Procedure
        
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
            If (Order.Status = "O") Begin
                Move (dToday-Order.JobOpenDate) to iDateSum
            End

            Case Begin
                Case (iDateSum <= 5) // Opened within the last 5 days
                    Move clGreen to iColor // Green 
                Case Break
                Case (iDateSum >= 6 and iDateSum <=8) // Opened within the last 8 days
                    Move 13106938 to iColor // Yellow
                Case Break    
                Case Else                // Everythin open longer than 9 days
                    Move clWhite to iColor //White
            Case End

            Send Change_Row_Color iColor
                If (bReturned) Begin
                    Get Base_Item to iItem // first item of the current row
                    Set ItemColor (iItem) to clRed // Fifth column
                End 
            Forward Send Entry_Display iFile iType
        End_Procedure
        
    End_Object

    Object oViewOrderButton is a Button
        Set Size to 14 63
        Set Location to 275 339
        Set Label to 'View Order'
        Set peAnchors to anBottomRight
    
        // fires when the button is clicked
        Procedure OnClick
            Send DoViewOrder
        End_Procedure
    End_Object

    Object oBillingTypeGroup is a Group
        Set Size to 26 260
        Set Location to 4 381
        Set Label to 'Billing Type'
        Set peAnchors to anTopRight
        
        Object oStandardCheckBox is a CheckBox
            Set Size to 10 29
            Set Location to 11 6
            Set Label to 'Standard'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOpenJobList FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOpenJobList
            End_Procedure
        End_Object
        
        Object oMonthlyCheckBox is a CheckBox
            Set Size to 10 29
            Set Location to 11 141
            Set Label to 'Monthly'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOpenJobList FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOpenJobList
            End_Procedure
        End_Object
        
        Object oNoChargeCheckBox is a CheckBox
            Set Size to 10 29
            Set Location to 11 200
            Set Label to 'No Charge'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOpenJobList FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOpenJobList
            End_Procedure
        End_Object
        
        Object oTNMCheckBox is a CheckBox
            Set Size to 10 29
            Set Location to 11 59
            Set Label to 'Time and Material'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOpenJobList FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOpenJobList
            End_Procedure
        End_Object
        
        
    End_Object
    
    Procedure DoViewQuote
        Send Refind_Records of oOrder_DD
        Send DoViewQuote of oQuoteEntry Order.QuoteReference
    End_Procedure
    
    Procedure DoViewOrder
        Send Refind_Records of oOrder_DD
        Send DoViewOrder of oOrderEntry Order.Recnum
    End_Procedure

    Object oWorkTypeGroup is a Group
        Set Size to 26 375
        Set Location to 4 3
        Set Label to 'Work Type'
        Set peAnchors to anTopLeftRight
        
        Object oSnowCheckBox is a CheckBox
            Set Size to 10 29
            Set Location to 11 8
            Set Label to 'Snow'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOpenJobList FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOpenJobList
            End_Procedure
        End_Object

        Object oPMCheckBox is a CheckBox
            Set Size to 10 23
            Set Location to 11 40
            Set Label to 'PM'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOpenJobList FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOpenJobList
            End_Procedure
        
        End_Object

        Object oSweepingCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 11 67
            Set Label to 'Sweeping'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOpenJobList FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOpenJobList
            End_Procedure
        
        End_Object

        Object oExcavationCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 11 114
            Set Label to 'Excavation'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOpenJobList FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOpenJobList
            End_Procedure
        
        End_Object

        Object oCapitalCheckBox is a CheckBox
            Set Size to 10 71
            Set Location to 11 163
            Set Label to 'Capital Expenditure'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOpenJobList FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOpenJobList
            End_Procedure
        
        End_Object

        Object oShopLaborCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 11 238
            Set Label to 'Shop Labor'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOpenJobList FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOpenJobList
            End_Procedure
        
        End_Object

        Object oOtherCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 11 342
            Set Label to 'Other'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOpenJobList FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOpenJobList
            End_Procedure
        
        End_Object 

        Object oConnexBoxCheckBox is a CheckBox
            Set Size to 10 49
            Set Location to 11 290
            Set Label to 'Connex Box'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Refresh of oOpenJobList FILL_FROM_BOTTOM
                Send Beginning_of_Data of oOpenJobList
            End_Procedure
        
        End_Object
        
    End_Object

    Object oPrintJobSheetButton is a Button
       Set Size to 14 62
       Set Location to 275 434
       Set Label to "Job Sheet"        
        Set peAnchors to anBottomRight
       //Set Bitmap to "doc.bmp/3d"
   
       Procedure OnClick
           Integer iJobNumber
           String sFilePath sFileName
           //
           Get Field_Current_Value of oOrder_DD Field Order.JobNumber to iJobNumber
           If (iJobNumber <> 0) Begin
               Send DoJumpStartReport of oJobSheetReportView iJobNumber (&sFilePath) (&sFileName) True
           End
       End_Procedure
   End_Object
    Object oPrintJobCostButton is a Button
       Set Size to 14 64
       Set Location to 275 500
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
   Object oPrintInvoicePrevButton is a Button
       Set Size to 14 69
       Set Location to 275 568
       Set Label to 'Invoice Preview'
       Set peAnchors to anBottomRight
   
       // fires when the button is clicked
       Procedure OnClick
           Integer iJobNumber
           String sFilePath sFileName
           Get Field_Current_Value of oOrder_DD Field Order.JobNumber to iJobNumber
           If (iJobNumber <> 0) Begin
               Send DoJumpStartReport of oOrderInvoicePreviewReportView iJobNumber (&sFilePath) (&sFileName) True
           End
       End_Procedure
   
   End_Object
    
End_Object
