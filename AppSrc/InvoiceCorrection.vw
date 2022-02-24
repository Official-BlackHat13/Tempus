// \\ipm-107\C$\VDF16.1 Workspaces\Tempus\AppSrc\InvoiceCorrection.vw
// InvoiceCorrection
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
Use Opers.DD
Use cProjectDataDictionary.dd
Use Order.DD
Use Invhdr.DD
Use Invdtl.DD

ACTIVATE_VIEW Activate_oInvoiceCorrection FOR oInvoiceCorrection
Object oInvoiceCorrection is a cGlblDbView
    Set Location to 5 5
    Set Size to 129 543
    Set Label To "InvoiceCorrection"
    Set Border_Style to Border_Thick


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

    Object oMastOps_DD is a Mastops_DataDictionary
    End_Object // oMastOps_DD

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oMastOps_DD
    End_Object // oOpers_DD

    Object oProject_DD is a cProjectDataDictionary
    End_Object // oProject_DD

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oProject_DD
        Set DDO_Server To oSalesRep_DD
    End_Object // oOrder_DD

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server To oOrder_DD
    End_Object // oInvhdr_DD

    Object oInvdtl_DD is a Invdtl_DataDictionary
        Set DDO_Server To oInvhdr_DD
        Set DDO_Server To oOpers_DD
        Set Constrain_File To Invhdr.File_Number
    End_Object // oInvdtl_DD

    Set Main_DD To oInvhdr_DD
    Set Server  To oInvhdr_DD



    Object oInvhdrInvoiceIdno is a cGlblDbForm
        Entry_Item Invhdr.InvoiceIdno
        Set Size to 13 54
        Set Location to 5 46
        Set peAnchors to anLeftRight
        Set Label to "InvoiceIdno"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 41
        Set Label_row_Offset to 0
    End_Object // oInvhdrInvoiceIdno

    Object oCustomerName is a cGlblDbForm
        Entry_Item Customer.Name
        Set Size to 13 366
        Set Location to 20 46
        Set peAnchors to anLeftRight
        Set Label to "Organization"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 41
        Set Label_row_Offset to 0
    End_Object // oCustomerName

    Object oLocationName is a cGlblDbForm
        Entry_Item Location.Name
        Set Size to 13 246
        Set Location to 35 46
        Set peAnchors to anLeftRight
        Set Label to "Location"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 41
        Set Label_row_Offset to 0

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
        Set Size to 66 533
        Set Location to 58 5
        Set Server to oInvdtl_DD
        Set Ordering to 2
        Set peAnchors to anAll
        Set psLayoutSection to "oInvoiceCorrection_oDetailGrid"
        Set pbAllowInsertRow to False
        Set pbHeaderPrompts to True

        Object oInvdtl_Sequence is a cDbCJGridColumn
            Entry_Item Invdtl.Sequence
            Set piWidth to 64
            Set psCaption to "Sequence"
        End_Object // oInvdtl_Sequence

        Object oOpers_OpersIdno is a cDbCJGridColumn
            Entry_Item Opers.OpersIdno
            Set piWidth to 72
            Set psCaption to "OpersIdno"
        End_Object // oOpers_OpersIdno

        Object oInvdtl_Description is a cDbCJGridColumn
            Entry_Item Invdtl.Description
            Set piWidth to 225
            Set psCaption to "Description"
        End_Object // oInvdtl_Description

        Object oInvdtl_StartTime is a cDbCJGridColumn
            Entry_Item Invdtl.StartTime
            Set piWidth to 90
            Set psCaption to "StartTime"
        End_Object // oInvdtl_StartTime

        Object oInvdtl_StopTime is a cDbCJGridColumn
            Entry_Item Invdtl.StopTime
            Set piWidth to 90
            Set psCaption to "StopTime"
        End_Object // oInvdtl_StopTime

        Object oInvdtl_Quantity is a cDbCJGridColumn
            Entry_Item Invdtl.Quantity
            Set piWidth to 81
            Set psCaption to "Quantity"
        End_Object // oInvdtl_Quantity

        Object oInvdtl_Price is a cDbCJGridColumn
            Entry_Item Invdtl.Price
            Set piWidth to 81
            Set psCaption to "Price"
        End_Object // oInvdtl_Price

        Object oInvdtl_Total is a cDbCJGridColumn
            Entry_Item Invdtl.Total
            Set piWidth to 81
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


End_Object // oInvoiceCorrection
