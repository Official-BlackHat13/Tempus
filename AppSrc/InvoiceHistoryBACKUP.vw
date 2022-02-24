Use Windows.pkg
Use DFClient.pkg
Use cTempusDbView.pkg

Use ReturnMemoModalDialog.dg
Use UserInputDialog.dg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use Order.DD
Use Invhdr.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDbCJGrid.pkg

Register_Object oCustomerInvoice

Deferred_View Activate_oInvoiceHistory for ;
Object oInvoiceHistory is a cTempusDbView

    Property Integer piLocId

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
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

        Procedure OnConstrain
            If (piLocId(Self)) Begin
                Constrain Location.LocationIdno eq (piLocId(Self))
            End
        End_Procedure
    End_Object

    Object oProject_DD is a cProjectDataDictionary
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server to oOrder_DD
        Set Cascade_Delete_State to False
        Set No_Delete_State to True

        Procedure OnConstrain
            Constrain Invhdr.EditFlag eq 1
            Constrain Invhdr.PostFlag eq 0
            Constrain Invhdr.VoidFlag eq 0
        End_Procedure
    End_Object

    Set Main_DD to oInvhdr_DD
    Set Server to oInvhdr_DD

    Set Border_Style to Border_Thick
    Set Size to 270 660
    Set Location to 7 5
    Set Label to "Invoice History"
    Set piMinSize to 270 660
    Set piMaxSize to 270 660
    
    
//    Object oDbCJGrid1 is a cDbCJGrid
//        Set Size to 243 680
//        Set Location to 6 11
//        Set peAnchors to anAll
//        Set piSelectedRowBackColor to clLtGray
//        Set piHighlightBackColor to clLtGray
//        Set piHighlightForeColor to clGray
//        Set piSelectedRowForeColor to clGray
//
//        Object oInvhdr_InvoiceIdno is a cDbCJGridColumn
//            Entry_Item Invhdr.InvoiceIdno
//            Set piWidth to 62
//            Set psCaption to "Invoice#"
//            Set pbEditable to False
//        End_Object
//
//        Object oInvhdr_InvoiceDate is a cDbCJGridColumn
//            Entry_Item Invhdr.InvoiceDate
//            Set piWidth to 77
//            Set psCaption to "Date"
//            Set pbEditable to False
//        End_Object
//
//        Object oOrder_JobNumber is a cDbCJGridColumn
//            Entry_Item Order.JobNumber
//            Set piWidth to 62
//            Set psCaption to "Job#"
//            Set pbEditable to False
//        End_Object
//
//        Object oCustomer_Name is a cDbCJGridColumn
//            Entry_Item Customer.Name
//            Set piWidth to 233
//            Set psCaption to "Customer"
//            Set pbEditable to False
//        End_Object
//
//        Object oLocation_Name is a cDbCJGridColumn
//            Entry_Item Location.Name
//            Set piWidth to 265
//            Set psCaption to "Location"
//            Set pbEditable to False
//        End_Object
//
//        Object oLocation_LocationIdno is a cDbCJGridColumn
//            Entry_Item Location.LocationIdno
//            Set piWidth to 71
//            Set psCaption to "Loc Idno"
//            Set pbEditable to False
//        End_Object
//
//        Object oInvhdr_TotalAmount is a cDbCJGridColumn
//            Entry_Item Invhdr.TotalAmount
//            Set piWidth to 125
//            Set psCaption to "Total"
//            Set pbEditable to False
//        End_Object
//
//        Object oInvhdr_PrintCount is a cDbCJGridColumn
//            Entry_Item Invhdr.PrintCount
//            Set piWidth to 87
//            Set psCaption to "Print Count"
//            Set pbEditable to False
//        End_Object
//
//        Object oInvhdr_PrintFlag is a cDbCJGridColumn
//            Entry_Item Invhdr.PrintFlag
//            Set piWidth to 65
//            Set psCaption to "Print"
//            Set pbCheckbox to True
//            Set pbEditable to False
//        End_Object
//
//        Object oInvhdr_PostFlag is a cDbCJGridColumn
//            Entry_Item Invhdr.PostFlag
//            Set piWidth to 61
//            Set psCaption to "Post"
//            Set pbCheckbox to True
//        End_Object
//    End_Object

    Object oHeaderList is a cGlblDbList
        Set Size to 240 640
        Set Location to 6 10
        Set peResizeColumn to rcSelectedColumn
        Set piResizeColumn to 2

        Begin_Row
            Entry_Item Invhdr.InvoiceIdno
            Entry_Item Invhdr.InvoiceDate
            Entry_Item Order.JobNumber
            Entry_Item Order.WorkType
            Entry_Item Customer.Name
            Entry_Item Location.Name
            Entry_Item Location.LocationIdno
            Entry_Item Invhdr.TotalAmount
            Entry_Item Invhdr.PrintCount
            Entry_Item Invhdr.PrintFlag
            Entry_Item Invhdr.PostReady
            //Entry_Item Invhdr.VoidFlag
        End_Row

        Set Main_File to Invhdr.File_number

        Set Form_Width 0 to 46
        Set Header_Label 0 to "Invoice#"
        Set Header_Justification_Mode 0 to JMode_Right
        //Set Column_Shadow_State 0 to True

        Set Form_Width 1 to 50
        Set Header_Label 1 to "Date"
        //Set Column_Shadow_State 1 to True
        
        Set Form_Width 2 to 33
        Set Header_Label 2 to "Job #"
        Set Header_Justification_Mode 2 to JMode_Right
        //Set Column_Shadow_State 2 to True
        
        Set Form_Width 3 to 27
        Set Header_Label 3 to "Type"
        //Set Column_Shadow_State 3 to True
        
        Set Form_Width 4 to 120
        Set Header_Label 4 to "Customer Name"
        //Set Column_Shadow_State 4 to True
        
        Set Form_Width 5 to 117
        Set Header_Label 5 to "Location Name"
        //Set Column_Shadow_State 5 to True
        
        Set Form_Width 6 to 45
        Set Header_Label 6 to "LocationIdno"
        Set Header_Justification_Mode 6 to JMode_Right
        //Set Column_Shadow_State 6 to True
        Set Form_Justification_Mode 6 to Form_DisplayRight

        Set Form_Width 7 to 50
        Set Header_Label 7 to "Total"
        Set Header_Justification_Mode 7 to JMode_Right
        //Set Column_Shadow_State 7 to True

        Set Form_Width 8 to 50
        Set Header_Label 8 to "Print Count"
        Set Header_Justification_Mode 8 to JMode_Right
        //Set Column_Shadow_State 8 to True

        Set Form_Width 9 to 50
        Set Header_Label 9 to "Printed"
        Set Column_Checkbox_State 9 to True
        //Set Column_Shadow_State 9 to True

        Set Form_Width 10 to 50
        Set Header_Label 10 to "To Post"
        //Set Column_Shadow_State 10 to True
        Set Column_Checkbox_State 10 to True        
        
//        Set Form_Width 10 to 50
//        Set Header_Label 10 to "VOID"
//        Set Form_Button_Value 10 to "VOID"
//        Set Form_Button 10 to Form_Button_Prompt
//        Set Column_Shadow_State 10 to False
//        Set Column_Button 10 to Form_Button_Prompt
//        Set Form_Justification_Mode 10 to Form_DisplayCenter
                
        Set Ordering to 8
        //Set Auto_Column_State to False
        Set Auto_Index_State to False
        Set CurrentRowColor to clLtGray
        Set CurrentCellColor to clLtGray
        Set Seed_List_State to False


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
            Integer iColor iItem
            
            Case Begin
                Case (Order.WorkType="P")
                    Move 13106938 to iColor // Yellow
                    Case Break
                Case (Order.WorkType="E")
                    Move 15638571 to iColor // Orange
                    Case Break
                Case (Order.WorkType="S")
                    Move clWhite to iColor //White
                    Case Break
                Case Else
                    Move clWhite to iColor 
            Case End

            Send Change_Row_Color iColor
            Forward Send Entry_Display iFile iType
        End_Procedure 

//        Set Form_Width 7 to 36
//        Set Header_Label 7 to "Void"
//        Set Column_Checkbox_State 7 to True
//        Set Header_Justification_Mode 7 to JMode_Center

    End_Object

    Object oEditorReturnButton is a Button
        Set Size to 14 70
        Set Location to 251 10
        Set Label to "Return To Editor"
    
        Procedure OnClick
            Send DoReturnToEditor
        End_Procedure
    End_Object

    Object oPrintButton is a Button
        Set Location to 251 105
        Set Label to "Print"
    
        Procedure OnClick
            Send DoPrintInvoice
        End_Procedure
    End_Object

    Object oToPostButton is a Button
        Set Size to 14 37
        Set Location to 251 193
        Set Label to "Post"
    
        Procedure OnClick
            Send DoClearToPost
        End_Procedure
        
        Procedure Refresh Integer iMode
            Forward Send Refresh iMode
        End_Procedure
        
    End_Object
    
    Object oUnPostButton is a Button
        Set Size to 14 37
        Set Location to 251 230
        Set Label to "Un-Post"
    
        Procedure OnClick
            Send DoUnPost
        End_Procedure
        
        Procedure Refresh Integer iMode
            Forward Send Refresh iMode
        End_Procedure
        
    End_Object

    Object oFilterButton is a Button
        Set Location to 251 532
        Set Label to "Location Filter"

        Procedure OnClick
            Integer iLocId
            //
            Get IsSelectedLocation of Location_sl 0 to iLocId
            Set piLocId                           to iLocId
            //
            Send Rebuild_Constraints of oLocation_DD
            Send Rebuild_Constraints of oOrder_DD
            Send Rebuild_Constraints of oInvhdr_DD
            Send Beginning_of_Data   of oHeaderList
            Send Activate            of oHeaderList
        End_Procedure
    End_Object

    Object oClearButton is a Button
        Set Location to 251 587
        Set Label to "Clear Filter"
    
        Procedure OnClick
            Set piLocId to 0
            //
            Send Rebuild_Constraints of oLocation_DD
            Send Rebuild_Constraints of oOrder_DD
            Send Rebuild_Constraints of oInvhdr_DD
            Send Beginning_of_Data   of oHeaderList
            Send Activate            of oHeaderList
        End_Procedure
    End_Object

    Object oQBPaidStatusUpdate is a Button
        Set Size to 14 82
        Set Location to 251 308
        Set Label to 'Paid Status Update'
    
        // fires when the button is clicked
        Procedure OnClick
            Boolean bCancel bDone
            Integer iFoundCounter iStatusChangedCounter
            // Find all Unpaid Invoices
            Get Confirm ("Would you like to run the QB Invoice Paid status update tool now?")           to bCancel
            If (not(bCancel)) Begin
                Get QuickBooksInvoicePaidStatus of oInvoicePostingProcess (&iFoundCounter) (&iStatusChangedCounter) to bDone
                If (bDone) Begin
                    Send Info_Box ("Found:"*String(iFoundCounter)*"- changed:"*String(iStatusChangedCounter))  
                End
            End
        End_Procedure
    
    End_Object

    Procedure DoReturnToEditor
        Boolean bCancel
        Integer iInvId iJobNumber
        String sInvEditor sReturnMemo
        Date dToday
        Sysdate dToday
        
       
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno          to iInvId
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvEditorFlag        to sInvEditor
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.JobNumber            to iJobNumber
        
        If (sInvEditor="IR") Begin
            //Send Popup of oReturnMemoModalDialog
            Get Confirm ("PM - Invoice Return \n \n Do you want to Return invoice number" * String(iInvId) * "to the Invoice Review?") to bCancel
             If (not(bCancel)) Begin
                Get PopupUserInput of oUserInputDialog "Return Memo" "Please Enter the Return Memo:" to sReturnMemo
                Set Field_Changed_Value of oOrder_DD Field Order.ReturnMemo         to sReturnMemo
                Set Field_Changed_Value of oOrder_DD Field Order.SalesInvoiceOK     to 0
                Set Field_Changed_Value of oOrder_DD Field Order.ReturnFlag         to 1
                Set Field_Changed_Value of oOrder_DD Field Order.LastReturnDate     to dToday
                Send Request_Save       of oOrder_DD
                
                
                Set Field_Changed_Value of oInvhdr_DD Field Invhdr.ChangedFlag      to 1
                Set Field_Changed_Value of oInvhdr_DD Field Invhdr.VoidFlag         to 1
                Set Field_Changed_Value of oInvhdr_DD Field Invhdr.PostReady        to 0
                Send Request_Save       of oInvhdr_DD
                Send Refresh_Page       of oHeaderList FILL_FROM_CENTER
             End
        End
        Else If (sInvEditor="IE") Begin
            Get Confirm ("Return invoice number" * String(iInvId) * "to editor?") to bCancel
            If (not(bCancel)) Begin
                Set Field_Changed_Value of oInvhdr_DD Field Invhdr.EditFlag  to 0
                Set Field_Changed_Value of oInvhdr_DD Field Invhdr.VoidFlag  to 0
                Set Field_Changed_Value of oInvhdr_DD Field Invhdr.PostReady to 0
                Send Request_Save       of oInvhdr_DD
                Send Refresh_Page       of oHeaderList FILL_FROM_CENTER
            End
        End
        Else Begin
            Send Info_Box "The Invoice was not returned. Please contact IT" "Invoice Return - Error"
        End

            
    End_Procedure

    Procedure DoPrintInvoice
        Boolean bCancel
        Integer iInvId
        //
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno to iInvId
        Get Confirm ("Print invoice" * String(iInvId) + "?")           to bCancel
        If (not(bCancel)) Begin
            Send DoJumpStartReport of oCustomerInvoice iInvId
        End
    End_Procedure

    Procedure DoClearToPost
        Boolean bCancel
        Integer iInvId
        //
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno                       to iInvId
        Get Confirm ("Do you want to prepare invoice: " * String(iInvId) * "for posting to Quickbooks?") to bCancel
        If (not(bCancel)) Begin
            Set Field_Changed_Value of oInvhdr_DD Field Invhdr.PostReady to 1
            Send Request_Save       of oInvhdr_DD
            Send Refresh_Page       of oHeaderList FILL_FROM_CENTER
        End
    End_Procedure

    Procedure DoUnPost
        Boolean bCancel
        Integer iInvId
        //
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno                       to iInvId
        Get Confirm ("Do you want to remove invoice: " * String(iInvId) * "from posting to Quickbooks?") to bCancel
        If (not(bCancel)) Begin
            Set Field_Changed_Value of oInvhdr_DD Field Invhdr.PostReady to 0
            Send Request_Save       of oInvhdr_DD
            Send Refresh_Page       of oHeaderList FILL_FROM_CENTER
        End
    End_Procedure

    Procedure Request_Delete
    End_Procedure

    Procedure DoRemoteInvoiceUpdate
        String sResult
        //
        Get DoUpdateInvoice  of oCollectTransactionsProcess to sResult
        Send Info_Box sResult
    End_Procedure
    //
    On_Key Key_Alt+Key_F1 Send DoRemoteInvoiceUpdate

Cd_End_Object
