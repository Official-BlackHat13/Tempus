// D:\Development Projects\VDF19.1 Workspaces\Tempus\AppSrc\CustomerContracts.vw
// CustomerContracts
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use cDbCJGridColumn.pkg

Use Customer.DD
Use cCustomerContractsGlblDataDictionary.dd
Use dbSuggestionForm.pkg

ACTIVATE_VIEW Activate_oCustomerContracts FOR oCustomerContracts
Object oCustomerContracts is a cGlblDbView
    Set Location to 5 5
    Set Size to 99 571
    Set Label To "CustomerContracts"
    Set Border_Style to Border_Thick


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object 

    Object oCustomerContracts_DD is a cCustomerContractsGlblDataDictionary
        Set pbUseDDRelates to True
        Set DDO_Server to oCustomer_DD
        Set Field_Related_FileField Field CustomerContracts.CustomerIdno to File_Field Customer.CustomerIdno
        Set Constrain_File to Customer.File_Number
    End_Object 

    Set Main_DD To oCustomer_DD
    Set Server  To oCustomer_DD


    Object oCustomerName is a DbSuggestionForm
        Entry_Item Customer.Name
        Set Size to 13 250
        Set Location to 5 38
        Set peAnchors to anTopLeftRight
        Set Label to "Customer"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 33
        Set Label_row_Offset to 0
        Set pbFullText to True
        Set piStartAtChar to 2
    End_Object 

    Object oDetailGrid is a cDbCJGrid
        Set Size to 66 561
        Set Location to 28 5
        Set Server to oCustomerContracts_DD
        Set Ordering to 6
        Set peAnchors to anAll
        Set psLayoutSection to "oCustomerContracts_oDetailGrid"
        Set pbAllowInsertRow to False
        Set pbHeaderPrompts to True
        Set pbAllowEdit to False

        Object oCustomerContracts_ContractIdno is a cDbCJGridColumn
            Entry_Item CustomerContracts.ContractIdno
            Set piWidth to 80
            Set psCaption to "Contract#"
        End_Object 

        Object oCustomerContracts_DisplayName is a cDbCJGridColumn
            Entry_Item CustomerContracts.DisplayName
            Set piWidth to 250
            Set psCaption to "Display Name"
        End_Object 

        Object oCustomerContracts_FileName is a cDbCJGridColumn
            Entry_Item CustomerContracts.FileName
            Set piWidth to 250
            Set psCaption to "FileName"
        End_Object 

        Object oCustomerContracts_StartDate is a cDbCJGridColumn
            Entry_Item CustomerContracts.StartDate
            Set piWidth to 100
            Set psCaption to "Start Date"
        End_Object 

        Object oCustomerContracts_ExpiryDate is a cDbCJGridColumn
            Entry_Item CustomerContracts.ExpiryDate
            Set piWidth to 100
            Set psCaption to "Expiry Date"
        End_Object 

        Object oCustomerContracts_TempFlag is a cDbCJGridColumn
            Entry_Item CustomerContracts.TempFlag
            Set piWidth to 73
            Set psCaption to "Temporary"
        End_Object 

        Object oCustomerContracts_AssignedCount is a cDbCJGridColumn
            Entry_Item CustomerContracts.AssignedCount
            Set piWidth to 65
            Set psCaption to "Assigned"
        End_Object 

    End_Object 

    //-----------------------------------------------------------------------
    // Create custom confirmation messages for save and delete
    // We must create the new functions and assign verify messages
    // to them.
    //-----------------------------------------------------------------------

    Function ConfirmDeleteHeader Returns Boolean
        Boolean bFail
        Get Confirm "Delete Entire Header and all detail?" to bFail
        Function_Return bFail
    End_Function 

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
    End_Function 

    // Define alternate confirmation Messages
    Set Verify_Save_MSG       to (RefFunc(ConfirmSaveHeader))
    Set Verify_Delete_MSG     to (RefFunc(ConfirmDeleteHeader))
    // Saves in header should not clear the view
    Set Auto_Clear_Deo_State to False



End_Object 
