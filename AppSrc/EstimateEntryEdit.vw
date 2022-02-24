// Z:\VDF17.0 Workspaces\Tempus\AppSrc\EstimateEntryEdit.vw
// EstimateEntryEdit
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use cDbCJGridColumn.pkg

Use Customer.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use SalesRep.DD
Use Contact.DD
Use cJcdeptDataDictionary.dd
Use cJccntrDataDictionary.dd
Use JCOPER.DD
Use Eshead.DD
Use Escomp.DD
Use Esitem.DD

ACTIVATE_VIEW Activate_oEstimateEntryEdit FOR oEstimateEntryEdit
Object oEstimateEntryEdit is a cGlblDbView
    Set Location to 5 5
    Set Size to 159 417
    Set Label To "EstimateEntryEdit"
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
    End_Object // oSalesRep_DD

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server To oCustomer_DD
    End_Object // oContact_DD

    Object oJcdept_DD is a cJcdeptDataDictionary
    End_Object // oJcdept_DD

    Object oJccntr_DD is a cJccntrDataDictionary
        Set DDO_Server To oJcdept_DD
    End_Object // oJccntr_DD

    Object oJcoper_DD is a Jcoper_DataDictionary
        Set DDO_Server To oJccntr_DD
    End_Object // oJcoper_DD

    Object oEshead_DD is a Eshead_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oContact_DD
        Set DDO_Server To oSalesRep_DD
    End_Object // oEshead_DD

    Object oEscomp_DD is a Escomp_DataDictionary
        Set DDO_Server To oEshead_DD
        // this lets you save a new parent DD from within child DD
        Set Allow_Foreign_New_Save_State to True
    End_Object // oEscomp_DD

    Object oEsitem_DD is a Esitem_DataDictionary
        Set DDO_Server To oEscomp_DD
        Set DDO_Server To oJcoper_DD
        Set Constrain_File To Escomp.File_Number
    End_Object // oEsitem_DD

    Set Main_DD To oEscomp_DD
    Set Server  To oEscomp_DD



    Object oEsheadESTIMATE_ID is a cGlblDbForm
        Entry_Item Eshead.ESTIMATE_ID
        Set Size to 13 54
        Set Location to 5 46
        Set peAnchors to anLeftRight
        Set Label to "ESTIMATE ID"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 41
        Set Label_row_Offset to 0
    End_Object // oEsheadESTIMATE_ID

    Object oEsheadTITLE is a cGlblDbForm
        Entry_Item Eshead.TITLE
        Set Size to 13 306
        Set Location to 20 46
        Set peAnchors to anLeftRight
        Set Label to "TITLE"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 41
        Set Label_row_Offset to 0
    End_Object // oEsheadTITLE

    Object oCustomerName is a cGlblDbForm
        Entry_Item Customer.Name
        Set Size to 13 366
        Set Location to 35 46
        Set peAnchors to anLeftRight
        Set Label to "Name"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 41
        Set Label_row_Offset to 0
    End_Object // oCustomerName

    Object oLocationName is a cGlblDbForm
        Entry_Item Location.Name
        Set Size to 13 246
        Set Location to 50 46
        Set peAnchors to anLeftRight
        Set Label to "Name"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 41
        Set Label_row_Offset to 0
    End_Object // oLocationName

    Object oSalesRepLastName is a cGlblDbForm
        Entry_Item SalesRep.LastName
        Set Size to 13 186
        Set Location to 65 46
        Set peAnchors to anLeftRight
        Set Label to "LastName"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 41
        Set Label_row_Offset to 0
    End_Object // oSalesRepLastName

    Object oDetailGrid is a cDbCJGrid
        Set Size to 66 388
        Set Location to 88 5
        Set Server to oEsitem_DD
        Set Ordering to 4
        Set peAnchors to anAll
        Set psLayoutSection to "oEstimateEntryEdit_oDetailGrid"
        Set pbAllowInsertRow to False
        Set pbHeaderPrompts to True

        Object oJcoper_NAME is a cDbCJGridColumn
            Entry_Item Jcoper.NAME
            Set piWidth to 262
            Set psCaption to "NAME"
        End_Object // oJcoper_NAME

        Object oEsitem_INSTRUCTION is a cDbCJGridColumn
            Entry_Item Esitem.INSTRUCTION
            Set piWidth to 262
            Set psCaption to "INSTRUCTION"
        End_Object // oEsitem_INSTRUCTION

        Object oEsitem_PROD_UNITS1 is a cDbCJGridColumn
            Entry_Item Esitem.PROD_UNITS1
            Set piWidth to 136
            Set psCaption to "PROD UNITS1"
        End_Object // oEsitem_PROD_UNITS1

    End_Object // oDetailGrid

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
    End_Function // ConfirmSaveHeader

    // Define alternate confirmation Messages
    Set Verify_Save_MSG       to (RefFunc(ConfirmSaveHeader))
    Set Verify_Delete_MSG     to (RefFunc(ConfirmDeleteHeader))
    // Saves in header should not clear the view
    Set Auto_Clear_Deo_State to False


End_Object // oEstimateEntryEdit
