// C:\Tempus_Workspaces\Tempus\AppSrc\PM_Invoice_Entry.vw
// PM_Invoice_Entry
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cGlblDbTabDialog.pkg
Use cGlblDbTabPage.pkg
Use cDbCJGrid.pkg
Use cDbCJGridColumn.pkg
Use szcalendar.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use cProjectDataDictionary.dd
Use Order.DD
Use pminvhdr.dd
Use cJcdeptDataDictionary.dd
Use cJccntrDataDictionary.dd
Use JCOPER.DD
Use pminvdtl.dd
Use cSnowrepDataDictionary.dd
Use Contact.DD

// Activate_oPM_Invoice_Entry for oPM_Invoice_Entry
Object oPM_Invoice_Entry is a cGlblDbView
    Set Location to 6 5
    Set Size to 275 647
    Set Label to "PM Invoice Entry"
    Set Border_Style to Border_Thick
    Set View_Latch_State to True

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD is a Areas_DataDictionary
    End_Object // oAreas_DD

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
    End_Object // oLocation_DD

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object // oSalesRep_DD

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oProject_DD is a cProjectDataDictionary
        Set DDO_Server To oLocation_DD
    End_Object // oProject_DD

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oProject_DD
        Set DDO_Server To oSalesRep_DD
    End_Object // oOrder_DD

    Object opminvhdr_DD is a pminvhdr_DataDictionary
        Set DDO_Server to oContact_DD
        Set DDO_Server To oOrder_DD
    End_Object // opminvhdr_DD

    Object oJcdept_DD is a cJcdeptDataDictionary
    End_Object // oJcdept_DD

    Object oJccntr_DD is a cJccntrDataDictionary
        Set DDO_Server To oJcdept_DD
    End_Object // oJccntr_DD

    Object oJcoper_DD is a Jcoper_DataDictionary
        Set DDO_Server To oJccntr_DD
    End_Object // oJcoper_DD

    Object opminvdtl_DD is a pminvdtl_DataDictionary
        Set DDO_Server To opminvhdr_DD
        Set DDO_Server To oJcoper_DD
        Set Constrain_File To pminvhdr.File_Number
        Send DefineAllExtendedFields
    End_Object // opminvdtl_DD

    Set Main_DD To opminvhdr_DD
    Set Server  To opminvhdr_DD



    Object opminvhdrInvoiceNumber is a cGlblDbForm
        Entry_Item pminvhdr.InvoiceNumber
        Set Size to 13 54
        Set Location to 10 51
        Set Label to "Invoice #:"
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 3
        Set Label_row_Offset to 0
    End_Object // opminvhdrInvoiceNumber

    Object opminvhdrQuoteHdrID is a cGlblDbForm
        Entry_Item pminvhdr.QuoteHdrID
        Set Size to 13 54
        Set Location to 10 224
        Set Label to "Quote #:"
        Set Label_Justification_mode to jMode_Right
        Set Label_Col_Offset to 3
        Set Label_row_Offset to 0
        Set Enabled_State to False
    End_Object // opminvhdrQuoteHdrID

    Object oOrderJobNumber is a cGlblDbForm
        Entry_Item Order.JobNumber
        Set Size to 13 54
        Set Location to 30 51
        Set Label to "Job #:"
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 3
        Set Label_row_Offset to 0
        Procedure Refresh Integer iMode
           Integer hDD iCurrent
           Get Server to hDD
           Get Current_Record of hDD to iCurrent
           Set Enabled_State to (iCurrent = 0)
           Forward Send Refresh iMode
           If (iCurrent and Focus(Self) = Self) Send Next
        End_Procedure
    End_Object // oOrderJobNumber

    Object oCustomerName is a cGlblDbForm
        Entry_Item Customer.Name
        Set Size to 13 170
        Set Location to 30 108
        Set Label to ""
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 2
        Set Label_row_Offset to 0
        Set Enabled_State to False
    End_Object // oCustomerName

    Object opminvhdrInvoiceDate is a cdbszDatePicker
        Entry_Item pminvhdr.InvoiceDate
        Set Size to 12 70
        Set Location to 30 332
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 3
        Set Label_row_Offset to 0
        Set Label to "Invoice Date:"
    End_Object // opminvhdrInvoiceDate

    Object opminvhdrLocationIdno is a cGlblDbForm
        Entry_Item pminvhdr.LocationIdno
        Set Size to 13 54
        Set Location to 45 51
        Set Label to "Location:"
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 3
        Set Label_row_Offset to 0
        Set Enabled_State to False
    End_Object // opminvhdrLocationIdno

    Object oLocationName is a cGlblDbForm
        Entry_Item Location.Name
        Set Size to 13 170
        Set Location to 45 108
        Set Label to ""
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 2
        Set Label_row_Offset to 0
        Set Enabled_State to False
    End_Object // oLocationName

    Object opminvhdrAmount is a cGlblDbForm
        Entry_Item pminvhdr.Amount
        Set Size to 13 70
        Set Location to 45 332
        Set Label to "Amount:"
        Set Label_Justification_mode to jMode_Right
        Set Label_Col_Offset to 3
        Set Label_row_Offset to 0
    End_Object // opminvhdrAmount

    Object opContactIdno is a cGlblDbForm
        Entry_Item Contact.ContactIdno
        Set Size to 13 54
        Set Location to 60 50
        Set Label to "Contact #:"
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 3
        Set Label_row_Offset to 0
        Set Enabled_State to False
    End_Object // opminvhdrContactIdno

    Object oContact_LastName is a cGlblDbForm
        Entry_Item Contact.LastName
        Set Location to 60 108
        Set Size to 13 170
        Set Enabled_State to False
    End_Object

    Object opminvhdrSlsRepIdno is a cGlblDbForm
        Entry_Item pminvhdr.SlsRepIdno
        Set Size to 13 54
        Set Location to 75 50
        Set Label to "Sales Rep.:"
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 3
        Set Label_row_Offset to 0
        Set Enabled_State to False
    End_Object // opminvhdrSlsRepIdno

    Object oSalesRepLastName is a cGlblDbForm
        Entry_Item SalesRep.LastName
        Set Size to 13 170
        Set Location to 75 108
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 34
        Set Label_row_Offset to 0
        Set Enabled_State to False
    End_Object // oSalesRepLastName

    Object opminvhdr_PO is a cGlblDbForm
        Entry_Item pminvhdr.PO
        Set Location to 90 108
        Set Size to 13 170
        Set Label to "P.O. "
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oDetailGrid is a cDbCJGrid
        Set Size to 136 635
        Set Location to 115 7
        Set Server to opminvdtl_DD
        Set Ordering to 1
        Set peAnchors to anAll
        Set psLayoutSection to "oPM_Invoice_Entry_oDetailGrid"
        Set pbAllowInsertRow to False
        Set pbHeaderPrompts to True
        Property Boolean pbLinker True

        Set pbAllowColumnRemove to False
        Set pbAllowColumnReorder to False
        Set pbAutoSave to False

//        Object opminvdtl_LineNo is a cDbCJGridColumn
//            Entry_Item pminvdtl.LineNo
//            Set piWidth to 53
//            Set psCaption to "Line #"
//        End_Object // opminvdtl_LineNo

        Object oJcoper_OPCODE is a cDbCJGridColumn
//            Property Boolean pbLinker True
            Entry_Item Jcoper.OPCODE
            Set piWidth to 74
            Set psCaption to "Opcode"
        End_Object // oJcoper_OPCODE

        Object oJccntr_NickName is a cDbCJGridColumn
            Entry_Item Jccntr.NICKNAME
            Set piWidth to 106
            Set psCaption to "CC.Desc."
        End_Object // oJcoper_OPCODE

        Object oJcoper_NickName is a cDbCJGridColumn
            Entry_Item Jcoper.NICKNAME
            Set piWidth to 106
            Set psCaption to "Op.Desc."
        End_Object // oJcoper_OPCODE

//        Object opminvdtl_EstAmt1 is a cDbCJGridColumn
//            Entry_Item pminvdtl.EstAmt1
//            Set piWidth to 79
//            Set psCaption to "Amount"
//        End_Object // opminvdtl_EstAmt1

        Object opminvdtl_Instruction is a cDbCJGridColumn
            Entry_Item pminvdtl.Instruction
            Set piWidth to 534
            Set psCaption to "Description"
        End_Object // opminvdtl_Instruction

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

    Object oPrintInvoice is a Button
        Set Size to 14 66
        Set Location to 256 576
        Set Label to "PRINT INVOICE"
        Set peAnchors to anBottomRight
    
        // fires when the button is clicked
        Procedure OnClick
            
        End_Procedure
    
    End_Object


End_Object // oPM_Invoice_Entry
