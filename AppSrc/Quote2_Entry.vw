// C:\VDF16.1 Workspaces\Tempus\AppSrc\Quote2_Entry.vw
// Quote2_Entry
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use cDbCJGridColumn.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use cSnowrepDataDictionary.dd
Use Contact.DD
Use MastOps.DD
Use cQuotehdrDataDictionary.dd
Use cQuotedtlDataDictionary.dd

ACTIVATE_VIEW Activate_oQuote2_Entry FOR oQuote2_Entry
Object oQuote2_Entry is a cGlblDbView
    Set Location to 5 5
    Set Size to 144 444
    Set Label To "Quote2_Entry"
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

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object // oSnowrep_DD

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oSalesRep_DD
        Set DDO_Server To oSnowrep_DD
    End_Object // oContact_DD

    Object oMastOps_DD is a Mastops_DataDictionary
    End_Object // oMastOps_DD

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oSalesRep_DD
        Set DDO_Server To oContact_DD
    End_Object // oQuotehdr_DD

    Object oQuotedtl_DD is a cQuotedtlDataDictionary
        Set DDO_Server To oQuotehdr_DD
        Set DDO_Server To oMastOps_DD
        Set Constrain_File To Quotehdr.File_Number
    End_Object // oQuotedtl_DD

    Set Main_DD To oQuotehdr_DD
    Set Server  To oQuotehdr_DD



    Object oQuotehdrQuotehdrID is a cGlblDbForm
        Entry_Item Quotehdr.QuotehdrID
        Set Size to 13 54
        Set Location to 5 50
        Set peAnchors to anLeftRight
        Set Label to "QuotehdrID"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 45
        Set Label_row_Offset to 0
    End_Object // oQuotehdrQuotehdrID

    Object oQuotehdrCustomerIdno is a cGlblDbForm
        Entry_Item Quotehdr.CustomerIdno
        Set Size to 13 54
        Set Location to 20 50
        Set peAnchors to anLeftRight
        Set Label to "CustomerIdno"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 45
        Set Label_row_Offset to 0
    End_Object // oQuotehdrCustomerIdno

    Object oLocationLocationIdno is a cGlblDbForm
        Entry_Item Location.LocationIdno
        Set Size to 13 54
        Set Location to 35 50
        Set peAnchors to anLeftRight
        Set Label to "LocationIdno"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 45
        Set Label_row_Offset to 0
    End_Object // oLocationLocationIdno

    Object oContactContactIdno is a cGlblDbForm
        Entry_Item Contact.ContactIdno
        Set Size to 13 54
        Set Location to 50 50
        Set peAnchors to anLeftRight
        Set Label to "ContactIdno"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 45
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

    End_Object // oContactContactIdno

    Object oDetailGrid is a cDbCJGrid
        Set Size to 66 434
        Set Location to 73 5
        Set Server to oQuotedtl_DD
        Set Ordering to 2
        Set peAnchors to anAll
        Set psLayoutSection to "oQuote2_Entry_oDetailGrid"
        Set pbAllowInsertRow to False
        Set pbHeaderPrompts to True

        Object oMastOps_MastOpsIdno is a cDbCJGridColumn
            Entry_Item MastOps.MastOpsIdno
            Set piWidth to 78
            Set psCaption to "MastOpsIdno"
        End_Object // oMastOps_MastOpsIdno

        Object oQuotedtl_Quantity is a cDbCJGridColumn
            Entry_Item Quotedtl.Quantity
            Set piWidth to 117
            Set psCaption to "Quantity"
        End_Object // oQuotedtl_Quantity

        Object oQuotedtl_Price is a cDbCJGridColumn
            Entry_Item Quotedtl.Price
            Set piWidth to 99
            Set psCaption to "Price"
        End_Object // oQuotedtl_Price

        Object oQuotedtl_Amount is a cDbCJGridColumn
            Entry_Item Quotedtl.Amount
            Set piWidth to 117
            Set psCaption to "Amount"
        End_Object // oQuotedtl_Amount

        Object oQuotedtl_Description is a cDbCJGridColumn
            Entry_Item Quotedtl.Description
            Set piWidth to 225
            Set psCaption to "Description"
        End_Object // oQuotedtl_Description

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


End_Object // oQuote2_Entry
