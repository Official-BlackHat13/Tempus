// Z:\VDF17.0 Workspaces\Tempus\AppSrc\CreditMemo.vw
// CreditMemo
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use cDbCJGridColumn.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use Invhdr.DD
Use cCreditHdrGlblDataDictionary.dd
Use cCreditDtlGlblDataDictionary.dd
Use MastOps.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use Windows.pkg
Use dfallent.pkg
Use dfEnChk.pkg

Activate_View Activate_oCreditMemo for oCreditMemo
Object oCreditMemo is a cGlblDbView
    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
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
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server to oOrder_DD
    End_Object

    Object oCreditHdr_DD is a cCreditHdrGlblDataDictionary
        Set DDO_Server to oInvhdr_DD
    End_Object

    Object oCreditDtl_DD is a cCreditDtlGlblDataDictionary
        Set DDO_Server to oMastOps_DD
        Set Constrain_file to CreditHdr.File_number
        Set DDO_Server to oCreditHdr_DD
    End_Object

    Set Main_DD to oCreditHdr_DD
    Set Server to oCreditHdr_DD

    Set Location to 5 5
    Set Size to 240 465
    Set Label To "CreditMemo"
    Set Border_Style to Border_Thick
    
//    Object oCreditHdrCreditDate is a cGlblDbForm
//        Entry_Item CreditHdr.CreditDate
//        Set Size to 13 66
//        Set Location to 37 45
//        Set peAnchors to anLeftRight
//        Set Label to "CreditDate"
//        Set Label_Justification_mode to jMode_right
//        Set Label_Col_Offset to 2
//        Set Label_row_Offset to 0
//    End_Object // oCreditHdrCreditDate

    //-----------------------------------------------------------------------
    // Create custom confirmation messages for save and delete
    // We must create the new functions and assign verify messages
    // to them.
    //-----------------------------------------------------------------------

    Function ConfirmDeleteHeader Returns Boolean
        Boolean bFail
        Get Confirm "Delete Entire Header and all detail?" to bFail
        Function_Return bFail
    End_Function // ConfirmDeleteHeader

    // Only confirm on the saving of new records
    Function ConfirmSaveHeader Returns Boolean
        Boolean bFail bHasRecord bHasChanged
        Handle  hoSrvr
        Get Server to hoSrvr
        Get Changed_State of hoSrvr to bHasChanged
        Get HasRecord of hoSrvr to bHasRecord
        If ((bHasRecord) and (bHasChanged)) Begin
            Send Request_Save of hoSrvr
        End
        If not bHasRecord Begin
            Get Confirm "Save this NEW Credit Memo?" to bFail
            If not (bFail) Begin
                Send Request_Save of hoSrvr
            End
        End
        Function_Return bFail
    End_Function // ConfirmSaveHeader

    // Define alternate confirmation Messages
    Set Verify_Save_MSG       to (RefFunc(ConfirmSaveHeader))
    Set Verify_Delete_MSG     to (RefFunc(ConfirmDeleteHeader))
    
    
    Object oCreditHdr_CreditSubTotal is a cGlblDbForm
        Entry_Item CreditHdr.CreditSubTotal
        Set Location to 191 401
        Set Size to 13 54
        Set Label to "Sub Total"
        Set Form_Datatype to Mask_Numeric_Window
        Set Form_Mask to "$ #,###,##0.00"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
        Set Enabled_State to False
        Set peAnchors to anBottomRight
    End_Object

    Object oCreditHdr_CreditTaxTotal is a cGlblDbForm
        Entry_Item CreditHdr.CreditTaxTotal
        Set Location to 206 401
        Set Size to 13 54
        Set Label to "Sales Tax"
        Set Form_Datatype to Mask_Numeric_Window
        Set Form_Mask to "$ #,###,##0.00"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
        Set Enabled_State to False
        Set peAnchors to anBottomRight
    End_Object
    
    Object oCreditHdr_CreditTotal is a cGlblDbForm
        Entry_Item CreditHdr.CreditTotal
        Set Location to 222 401
        Set Size to 13 54
        Set Label to "Total"
        Set Form_Datatype to Mask_Numeric_Window
        Set Form_Mask to "$ #,###,##0.00"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
        Set Label_FontWeight to fw_Bold
        Set Enabled_State to False
        Set peAnchors to anBottomRight
    End_Object

    Object oDbGroup1 is a dbGroup
        Set Server to oCreditHdr_DD
        Set Size to 54 455
        Set Location to 4 4
        Set Label to ''

        Object oInvhdrInvoiceIdno is a cGlblDbForm
            Entry_Item Invhdr.InvoiceIdno
            Set Size to 13 66
            Set Location to 6 44
            Set peAnchors to anLeft
            Set Label to "Invoice#"
            Set Label_Justification_mode to jMode_right
            Set Label_Col_Offset to 2
            Set Label_row_Offset to 0
            
            Procedure Next
                Send Request_Superfind EQ
                Forward Send Next
            End_Procedure
        End_Object // oInvhdrInvoiceIdno

        Object oCreditHdr_CreditIdno is a cGlblDbForm
            Entry_Item CreditHdr.CreditIdno
            Set Location to 6 161
            Set Size to 13 54
            Set Label to "CreditIdno"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set peAnchors to anTopRight
    
            
            Procedure Refresh Integer notifyMode
                Boolean bSynced bCreditExists bQBInvExists
                
                Move (CreditHdr.PostedFlag) to bSynced
                Move (CreditHdr.CreditIdno>0) to bCreditExists 
                Move (Invhdr.QBInvoiceNumber) to bQBInvExists
                
                Forward Send Refresh notifyMode
    
                Set Enabled_State of oSyncButton to (not(bSynced) and bCreditExists and bQBInvExists)
                
                Set Enabled_State of oInvhdrInvoiceIdno to (not(bSynced) and (not(bCreditExists)))
                Set Enabled_State of oInvhdrQBInvoiceNumber to (not(bSynced) and (not(bCreditExists)))
                Set Enabled_State of oCreditHdr_CreditDate to (not(bSynced))
                Set Enabled_State of oDetailGrid to (not(bSynced))
            End_Procedure
            
            Procedure Next
                Send Request_Superfind EQ
                Forward Send Next
            End_Procedure
            
        End_Object
        Object oCustomerName is a cGlblDbForm
            Entry_Item Customer.Name
            Set Size to 13 287
            Set Location to 21 161
            Set peAnchors to anTopRight
            Set Label to "Customer"
            Set Label_Justification_mode to jMode_right
            Set Label_Col_Offset to 2
            Set Label_row_Offset to 0
            Set Enabled_State to False
        End_Object // oCustomerName
        Object oLocationName is a cGlblDbForm
            Entry_Item Location.Name
            Set Size to 13 287
            Set Location to 36 161
            Set peAnchors to anTopRight
            Set Label to "Location"
            Set Label_Justification_mode to jMode_right
            Set Label_Col_Offset to 2
            Set Label_row_Offset to 0
            Set Enabled_State to False
        End_Object // oLocationName
        Object oInvhdrQBInvoiceNumber is a cGlblDbForm
            Entry_Item Invhdr.QBInvoiceNumber
            Set Size to 13 66
            Set Location to 21 44
            Set peAnchors to anLeft
            Set Label to "QB Invoice#"
            Set Label_Justification_mode to jMode_right
            Set Label_Col_Offset to 2
            Set Label_row_Offset to 0
            
            Procedure Next
                Send Request_Superfind EQ
                Forward Send Next
            End_Procedure
            
        End_Object // oInvhdrQBInvoiceNumber
        Object oSyncButton is a Button
            Set Size to 13 50
            Set Location to 5 398
            Set Label to 'Sync to QB'
            Set peAnchors to anTopRight
        
            // fires when the button is clicked
            Procedure OnClick
                Integer iCreditIdno iQBCreditIdno
                Boolean bOk
                String sError
                Date dSyncDate
                Get Field_Current_Value of oCreditHdr_DD Field CreditHdr.CreditIdno to iCreditIdno
                
                Get SyncCreditMemo of oInvoicePostingProcess iCreditIdno (&iQBCreditIdno) (&dSyncDate) (&sError) to bOk
                If (bOk) Begin
                    Reread CreditHdr
                        Move iQBCreditIdno to CreditHdr.QBCreditNumber
                        Move dSyncDate to CreditHdr.CreditPostingDate
                        Move gsUserFullName to CreditHdr.CreatedBy
                        Move "1" to CreditHdr.PostedFlag
                        SaveRecord CreditHdr
                    Unlock
                End
                Else If (not(bOk) and sError<>"") Begin
                    Send Info_Box (sError)
                End
                
            End_Procedure
        
        End_Object
        Object oCreditHdr_QBCreditNumber is a cGlblDbForm
            Entry_Item CreditHdr.QBCreditNumber
            Set Location to 6 340
            Set Size to 13 54
            Set Label to "QBCreditNumber:"
            Set Enabled_State to False
            Set peAnchors to anTopRight
        End_Object
        
        Object oCreditHdr_CreditDate is a dbForm
            Entry_Item CreditHdr.CreditDate
            Set Location to 36 44
            Set Size to 13 66
            Set Label to "CreditDate:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set peAnchors to anLeft
            Set Form_Datatype to Mask_Date_Window
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt
            
            // Saves in header should not clear the view
            Set Auto_Clear_Deo_State to False
        End_Object
    End_Object

    Object oDbGroup2 is a dbGroup
        Set Server to oCreditDtl_DD
        Set Size to 126 455
        Set Location to 62 5
        Set Label to ''

        Object oDetailGrid is a cDbCJGrid
            Set Server to oCreditDtl_DD
            Set Size to 117 446
            Set Location to 7 4
            Set Ordering to 2
            Set peAnchors to anAll
            Set pbAllowInsertRow to False
            
            Object oCreditDtl_Sequence is a cDbCJGridColumn
                Entry_Item CreditDtl.Sequence
                Set piWidth to 33
                Set psCaption to "Seq."
            End_Object
    
            Object oMastOps_Name is a cDbCJGridColumn
                Entry_Item MastOps.Name
                Set piWidth to 194
                Set psCaption to "Name"
                Set Prompt_Button_Mode to PB_PromptOn
                
                Procedure Prompt
                        Integer iCol iRecId
                        String sDescription
                        Get Current_Record of oMastops_DD to iRecId
                        Forward Send Prompt
                       
                        If (Current_Record(oMastops_DD) <> iRecId) Begin
                            Set Field_Changed_Value of oCreditDtl_DD Field CreditDtl.Price          to MastOps.SellRate
                            Move MastOps.Description                                               to sDescription
                            If (sDescription contains "Credit") Begin
                                Move (sDescription * "on Invoice" * String(Invhdr.QBInvoiceNumber)) to sDescription
                            End
                            Set Field_Changed_Value of oCreditDtl_DD Field CreditDtl.Description    to sDescription
                        End
                End_Procedure
                
            End_Object
    
            Object oCreditDtl_Description is a cDbCJGridColumn
                Entry_Item CreditDtl.Description
                Set piWidth to 238
                Set psCaption to "Description"
            End_Object
    
            Object oCreditDtl_Quantity is a cDbCJGridColumn
                Entry_Item CreditDtl.Quantity
                Set piWidth to 52
                Set psCaption to "Quantity"
            End_Object // oCreditDtl_Quantity
    
            Object oCreditDtl_Price is a cDbCJGridColumn
                Entry_Item CreditDtl.Price
                Set piWidth to 59
                Set psCaption to "Rate"
            End_Object // oCreditDtl_Price
    
            Object oCreditDtl_TaxAmount is a cDbCJGridColumn
                Entry_Item CreditDtl.TaxAmount
                Set piWidth to 111
                Set psCaption to "Sales Tax"
                Set pbEditable to False
            End_Object // oCreditDtl_TaxAmount
    
            Object oCreditDtl_Total is a cDbCJGridColumn
                Entry_Item CreditDtl.Total
                Set piWidth to 93
                Set psCaption to "Total"
                Set pbEditable to False
            End_Object // oCreditDtl_Total
            
            Procedure Activating
                Forward Send Activating
                Send Beginning_of_Panel of oDetailGrid
            End_Procedure
            
            Procedure OnEntering
                Boolean bOk
                Forward Send OnEntering
                Get ConfirmSaveHeader to bOk
            End_Procedure
        End_Object // oDetailGrid
    End_Object

End_Object // oCreditMemo
