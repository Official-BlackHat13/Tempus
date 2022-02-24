// C:\VDF16.1 Workspaces\Tempus\AppSrc\InvoiceCorrect.vw
// InvoiceCorrect
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use cDbCJGridColumn.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use MastOps.DD
Use Order.DD
Use Invhdr.DD
Use Invdtl.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDbTextEdit.pkg
Use Windows.pkg

ACTIVATE_VIEW Activate_oInvoiceCorrect FOR oInvoiceCorrect
Object oInvoiceCorrect is a cGlblDbView
    Set Location to 6 10
    Set Size to 377 588
    Set Label To "Posted Invoice Correction"
    Set Border_Style to Border_Thick

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
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

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object // oSalesRep_DD

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
    End_Object // oMastOps_DD

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oSalesRep_DD
    End_Object // oOrder_DD

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server To oOrder_DD
    End_Object // oInvhdr_DD

    Object oInvdtl_DD is a Invdtl_DataDictionary
        Set DDO_Server to oMastOps_DD
        Set DDO_Server To oInvhdr_DD
        Set Constrain_File To Invhdr.File_Number
    End_Object // oInvdtl_DD

    Set Main_DD To oInvhdr_DD
    Set Server  To oInvhdr_DD



    Object oInvhdrInvoiceIdno is a cGlblDbForm
        Entry_Item Invhdr.InvoiceIdno
        Set Size to 13 72
        Set Location to 10 107
        Set Label to "Invoice Number:"
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 3
        Set Label_row_Offset to 0
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object // oInvhdrInvoiceIdno

    Object oCustomerName is a cGlblDbForm
        Entry_Item Customer.Name
        Set Size to 13 181
        Set Location to 25 107

        Set Label to "Organization:"
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 3
        Set Label_row_Offset to 0
        Set Prompt_Button_Mode to PB_PromptOff
        Set Enabled_State to False
        Set Entry_State to False
    End_Object // oCustomerName

    Object oLocationName is a cGlblDbForm
        Entry_Item Location.Name
        Set Size to 13 181
        Set Location to 40 107
   
        Set Label to "Location:"
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 3
        Set Label_row_Offset to 0
        Set Prompt_Button_Mode to PB_PromptOff
        Set Enabled_State to False
        Set Entry_State to False

        // Last DEO will attempt to save and enable to grid and then switch to it
        Procedure Switch 
            Boolean bEnabled
            Send Request_Save
            Send EnableObjects
            Get Enabled_State of oDetailGrid to bEnabled
            If bEnabled Begin
                Forward Send Switch
            End
        End_Procedure // Switch

    End_Object // oLocationName

    Object oDetailGrid is a cDbCJGrid
        Set Size to 224 538
        Set Location to 62 31
        Set Server to oInvdtl_DD
        Set Ordering to 2
        Set psLayoutSection to "oInvoiceCorrect_oDetailGrid"
        Set pbHeaderPrompts to True
        Set pbAllowInsertRow to False

        Object oInvdtl_Sequence is a cDbCJGridColumn
            Entry_Item Invdtl.Sequence
            Set piWidth to 50
            Set psCaption to "Sequence"
        End_Object

        Object oMastOps_Name is a cDbCJGridColumn
            Entry_Item MastOps.Name
            Set piWidth to 450
            Set psCaption to "Name"
        End_Object

        Object oInvdtl_StartTime is a cDbCJGridColumn
            Entry_Item Invdtl.StartTime
            Set piWidth to 70
            Set psCaption to "StartTime"
        End_Object

        Object oInvdtl_StopTime is a cDbCJGridColumn
            Entry_Item Invdtl.StopTime
            Set piWidth to 75
            Set psCaption to "StopTime"
        End_Object

        Object oInvdtl_Quantity is a cDbCJGridColumn
            Entry_Item Invdtl.Quantity
            Set piWidth to 87
            Set psCaption to "Quantity"
        End_Object // oInvdtl_Quantity

        Object oInvdtl_Price is a cDbCJGridColumn
            Entry_Item Invdtl.Price
            Set piWidth to 104
            Set psCaption to "Price"
        End_Object // oInvdtl_Price

        Object oInvdtl_Total is a cDbCJGridColumn
            Entry_Item Invdtl.Total
            Set piWidth to 107
            Set psCaption to "Total"
        End_Object // oInvdtl_Total

    End_Object // oDetailGrid

    //-----------------------------------------------------------------------
    // Create Idle time to handle enabling / disabling of grid
    //-----------------------------------------------------------------------
    Object oIdle is a cIdleHandler
        Procedure OnIdle 
            Delegate Send OnIdle
        End_Procedure // OnIdle
    End_Object // oIdle

    Procedure OnIdle 
        Send EnableObjects
    End_Procedure // OnIdle

    Procedure EnableObjects 
        Boolean bChanged bRec
        Handle hoServer
        Get Server to hoServer
        Get Should_Save of hoServer to bChanged
        Get HasRecord of hoServer to bRec
        Set Enabled_State of oDetailGrid to (not(bChanged) and bRec)
    End_Procedure // EnableObjects

    Procedure Activating 
        Forward Send Activating
        Set pbEnabled of oIdle to True
    End_Procedure // Activating

    Procedure Deactivating 
        Set pbEnabled of oIdle to False
        Forward Send Deactivating
    End_Procedure // Deactivating

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
        Boolean bNoSave bHasRecord
        Handle  hoSrvr
        Get Server to hoSrvr
        Get HasRecord of hoSrvr to bHasRecord
        If not bHasRecord Begin
            Get Confirm "Save this NEW header?" to bNoSave
        End
        Function_Return bNoSave
    End_Function // ConfirmSaveOrder

    // Define alternate confirmation Messages
    Set Verify_Save_MSG       to GET_ConfirmSaveHeader
    Set Verify_Delete_MSG     to GET_ConfirmDeleteHeader
    // Saves in header should not clear the view
    Set Auto_Clear_Deo_State to False

    Object oInvdtl_Description is a cDbTextEdit
        Entry_Item Invdtl.Description

        Set Server to oInvdtl_DD
        Set Location to 303 32
        Set Size to 60 405
        Set Label to "Description:"
    End_Object

    Object oInvhdr_TotalAmount is a cGlblDbForm
        Entry_Item Invhdr.TotalAmount
        Set Location to 302 501
        Set Size to 13 68
        Set Label to "Total:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Enabled_State to False
        Set Entry_State to False
    End_Object

    Object oTextBox1 is a TextBox
        Set Size to 10 31
        Set Location to 11 187
        Set Label to 'Find = F9'
    End_Object
 Object oButton1 is a Button
        Set Size to 14 56
        Set Location to 343 505
        Set Label to 'Print Invoice'
        Set peAnchors to anTopRight
        //Set peAnchors to anAll
    
        // fires when the button is clicked
        Procedure OnClick
             Send DoPrintInvoice
        End_Procedure
    
    End_Object

Procedure DoPrintInvoice
        #IFDEF TEMPUS_LINK
        #ELSE
        Boolean bCancel
        Integer iInvId
        //
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno to iInvId
        Get Confirm ("Print invoice" * String(iInvId) + "?")           to bCancel
        If (not(bCancel)) Begin
            Send DoJumpStartReport of oCustomerInvoice iInvId
//            Send DoClearInvoice
        End
        #ENDIF
    End_Procedure
End_Object // oInvoiceCorrect
