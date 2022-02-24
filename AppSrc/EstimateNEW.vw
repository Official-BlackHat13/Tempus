// Z:\VDF17.0 Workspaces\Tempus\AppSrc\Estimate.vw
// Estimate
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

Use EstimateWizard.dg
Use CompItem.dg

Use OrderProcess.bp
Use OperationsProcess.bp
Use PMInvoiceFromQuote.bp
Use QuoteEstimateSync.bp

ACTIVATE_VIEW Activate_oEstimate FOR oEstimate
Object oEstimate is a cGlblDbView
    Set Location to 5 5
    Set Size to 192 390
    Set Label To "Estimate"
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

      Object oCustomerName is a cGlblDbForm
        Entry_Item Customer.Name
        Set Size to 14 135
        Set Location to 5 48
        Set peAnchors to anLeftRight
        Set Label to "Customer"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 43
        Set Label_row_Offset to 0
    End_Object // oCustomerName

    Object oContactFirstName is a cGlblDbForm
        Entry_Item Contact.FirstName
        Set Size to 13 57
        Set Location to 21 48
        Set peAnchors to anLeftRight
        Set Label to "Contact"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 43
        Set Label_row_Offset to 0
        
        Procedure Prompt
            Boolean bSelected
            Handle  hoServer
            RowID   riContact riCustomer
            //
            Get Server                            to hoServer
            Move (GetRowID(Contact.File_Number )) to riContact
            Move (GetRowId(Customer.File_Number)) to riCustomer
            //
            Get IsSelectedContact of Contact_sl (&riContact) (&riCustomer) to bSelected
            //
            If  (bSelected and not(IsNullRowId(riContact))) Begin
                Send FindByRowId of hoServer Contact.File_Number riContact
            End
        End_Procedure
        
    End_Object // oContactFirstName

    Object oContactLastName is a cGlblDbForm
        Entry_Item Contact.LastName
        Set Size to 13 57
        Set Location to 21 127
        Set peAnchors to anLeftRight
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 0
        Set Label_row_Offset to 0
        
        Procedure Prompt
            Boolean bSelected
            Handle  hoServer
            RowID   riContact riCustomer
            //
            Get Server                            to hoServer
            Move (GetRowID(Contact.File_Number )) to riContact
            Move (GetRowId(Customer.File_Number)) to riCustomer
            //
            Get IsSelectedContact of Contact_sl (&riContact) (&riCustomer) to bSelected
            //
            If  (bSelected and not(IsNullRowId(riContact))) Begin
                Send FindByRowId of hoServer Contact.File_Number riContact
            End
        End_Procedure
    End_Object // oContactLastName

    Object oContactEmailAddress is a cGlblDbForm
        Entry_Item Contact.EmailAddress
        Set Size to 13 103
        Set Location to 36 81
        Set peAnchors to anLeftRight
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 0
        Set Label_row_Offset to 0
        Set Enabled_State to False
        Set Entry_State to False
    End_Object // oContactEmailAddress

    Object oLocationName is a cGlblDbForm
        Entry_Item Location.Name
        Set Size to 13 135
        Set Location to 51 48
        Set peAnchors to anLeftRight
        Set Label to "Location"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 43
        Set Label_row_Offset to 0
    End_Object // oLocationName

    Object oSalesRepFirstName is a cGlblDbForm
        Entry_Item SalesRep.FirstName
        Set Size to 13 57
        Set Location to 66 48
        Set peAnchors to anLeftRight
        Set Label to "Sales Rep"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 43
        Set Label_row_Offset to 0
    End_Object // oSalesRepFirstName

    Object oSalesRepLastName is a cGlblDbForm
        Entry_Item SalesRep.LastName
        Set Size to 13 57
        Set Location to 66 127
        Set peAnchors to anLeftRight
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 0
        Set Label_row_Offset to 0
    End_Object // oSalesRepLastName

    Object oDetailGrid is a cDbCJGrid
        Set Size to 23 168
        Set Location to 68 213
        Set Server to oEscomp_DD
        Set Ordering to 2
        Set peAnchors to anTopLeftRight
        Set psLayoutSection to "oEstimate_oDetailGrid"
        Set pbAllowInsertRow to False
        Set pbHeaderPrompts to True

        Object oEscomp_ESTIMATE_ID is a cDbCJGridColumn
            Entry_Item Eshead.ESTIMATE_ID
            Set piWidth to 70
            Set psCaption to "ESTIMATE ID"
        End_Object

        Object oEscomp_CREATION_DATE is a cDbCJGridColumn
            Entry_Item Escomp.CREATION_DATE
            Set piWidth to 106
            Set psCaption to "CREATION DATE"
        End_Object // oEscomp_CREATION_DATE

        Object oEscomp_ITEM_COUNT is a cDbCJGridColumn
            Entry_Item Escomp.ITEM_COUNT
            Set piWidth to 92
            Set psCaption to "ITEM COUNT"
        End_Object // oEscomp_ITEM_COUNT

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

    Object oEshead_ESTIMATE_ID is a cGlblDbForm
        Entry_Item Eshead.ESTIMATE_ID
        Set Location to 5 256
        Set Size to 14 54
        Set Label to "ESTIMATE ID:"
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oESITEMGrid is a cDbCJGrid
        Set Server to oEsitem_DD
        Set Size to 84 376
        Set Location to 99 6
        Set pbAllowDeleteRow to False
        Set pbAllowAppendRow to False
        Set pbAllowInsertRow to False
        Set pbAutoAppend to False
        Set TextColor to clBlack
        Set piShadeSortColor to clBlack

        Object oJcoper_NAME is a cDbCJGridColumn
            Entry_Item Jcoper.NAME
            Set piWidth to 171
            Set psCaption to "Name"
            Set piDisabledTextColor to clBlack
        End_Object

        Object oEsitem_PROD_UNITS1 is a cDbCJGridColumn
            Entry_Item Esitem.PROD_UNITS1
            Set piWidth to 93
            Set psCaption to "Price"
            Set piDisabledTextColor to clBlack
        End_Object

        Object oEsitem_INSTRUCTION is a cDbCJGridColumn
            Entry_Item Esitem.INSTRUCTION
            Set piWidth to 394
            Set psCaption to "Description"
        End_Object
    End_Object

    Object oSpecificationsButton is a Button
        Set Size to 14 70
        Set Location to 5 313
        Set Label to "Enter/Edit Estimate"
       // Set peAnchors to anTopRight
    
        Procedure OnClick
//            Integer iRecId
//            Move Eshead.Recnum to iRecId
//            Send Clear_All of oEshead_DD
//            Send Find_By_Recnum of Eshead_DD iRecId
            Send DoCalcEngine
            Send RefreshDataFromExternal of oESITEMGrid 0
        End_Procedure
        
    End_Object

    Object oEshead_TITLE is a cGlblDbForm
        Entry_Item Eshead.TITLE
        Set Location to 81 48
        Set Size to 13 155
        Set Label to "Title"
        Set Label_Col_Offset to 43
    End_Object

    Object oEshead_CREATION_DATE is a cGlblDbForm
        Entry_Item Eshead.CREATION_DATE
        Set Location to 21 257
        Set Size to 13 53
        Set Label to "Created:"
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oEshead_QuoteReference is a cGlblDbForm
        Entry_Item Eshead.QuoteReference
        Set Location to 36 256
        Set Size to 13 54
        Set Label to "Quote:"
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to JMode_Right
        Set Enabled_State to False
    End_Object

    Object oQuoteEstimateSyncButton is a Button
        Set Size to 13 70
        Set Location to 36 313
        Set Label to "Creat/Sync Quote"
    
        // fires when the button is clicked
        Procedure OnClick
            Integer iQuoteIdno iEsheadId
            Get Field_Current_Value of oEshead_DD Field Eshead.ESTIMATE_ID to iEsheadId
            Get Field_Current_Value of oEshead_DD Field Eshead.QuoteReference to iQuoteIdno
            If (iEsheadId = 0) Begin
                Send Stop_Box "No Estimate Selected"
            End
            Else Begin
                Get DoCreateQuoteFromEstimate of oQuoteEstimateSync iEsheadId iQuoteIdno to iQuoteIdno
                Reread Eshead
                    Move iQuoteIdno to Eshead.QuoteReference
                    SaveRecord Eshead
                Unlock                
            End
        End_Procedure
    
    End_Object
    
    Procedure Activating
        If (giEstimateIdno) Begin
            Send Request_Clear_All
            //Showln ( "ACTIVATING - giEstimateIdno" + (String(giEstimateIdno)))
            Move giEstimateIdno to Eshead.ESTIMATE_ID
            Send Find of oEshead_DD EQ 1
        End
        Send Refind_Records of oEshead_DD
        Forward Send Activating
    End_Procedure

    Procedure Closing_View
        Forward Send Closing_View
        Send Exit_Application
    End_Procedure

    Procedure DoCalcEngine
        Integer iEsheadRecId iEscompRecId iStatus
        Boolean bHasEscompRec bError
        //
        Get Current_Record of oEshead_DD to iEsheadRecId
        //
        If (not(iEsheadRecId)) Begin
            Send Info_Box "No Estimate selected or created"
            Procedure_Return
        End
        //
        Clear Eshead Escomp
        //
        Get HasRecord of oEscomp_DD to bHasEscompRec
        If (not(bHasEscompRec)) Begin
            //
            Set Field_Changed_Value of oEscomp_DD Field Escomp.ESTIMATE_ID      to Eshead.ESTIMATE_ID
            Set Field_Changed_Value of oEscomp_DD Field Escomp.DESCRIPTION      to Eshead.TITLE
            Set Field_Changed_Value of oEscomp_DD Field Escomp.CREATION_DATE    to Eshead.CREATION_DATE
            Set Field_Changed_Value of oEscomp_DD Field Escomp.QTY1             to 1
            Set Field_Changed_Value of oEscomp_DD Field Escomp.QTY2             to 2
            Set Field_Changed_Value of oEscomp_DD Field Escomp.QTY3             to 3
            Get Request_Validate of oEscomp_DD                                  to bError
            If (not(bError)) Begin
                Send Request_Save of oEscomp_DD
            End
        End
        //
        Get Field_Current_Value of oEscomp_DD Field Escomp.Recnum           to iEscompRecId
        Send DoSpecifications of oComponentItemDialog iEscompRecId False True //1st boolean = bLocked, 2nd = bTrigger
        
//            //
//            Get_Attribute DF_FILE_STATUS of Escomp.File_Number to iStatus
//            If (iStatus = DF_FILE_ACTIVE) Begin
//                
//                //Send Find_By_Recnum   of hoDD Quotehdr.File_Number iEsheadRecId
//            End
    End_Procedure
        
    Procedure DoMaintenanceCalculate
        Integer hEsheadDD
        String  sEstimateId
        Boolean bReadOnly bCanceled
        //        Get pbReadOnly to bReadOnly
        //        If bReadOnly Procedure_Return
        If (Quotehdr.JobNumber <> 0) Procedure_Return
         //
        //        Move Eshead_DD to hEsheadDD
        //        If (not(Current_Record(hEsheadDD))) Procedure_Return
        //        Send Activate of EstimateContainer
        Move Quotehdr.QuotehdrID to sEstimateId
        //        Get Field_Current_Value of hEsheadDD Field Eshead.Estimate_id to sEstimateId
        Send Info_Box ("Maintenance recalc for Estimate" * sEstimateId)
        Send DoZeroEstimateTotals of ZeroEstimateTotalsProcess sEstimateId
        Set pbNoBackout  of oCalcEngine to True
        Set pbNoPreview  of ghoApplication to True //suppresses preview links message box in calc engine process
        //        Send DoCalculate of EstimateContainer
        //Get DoCalcEngine of oCalcEngine CE_BATCH bComponent bDebug to bCanceled
        Get DoCalcEngine of oCalcEngine CE_BATCH False False to bCanceled
        //
        Send Request_Assign of oQuotehdr_DD
        Set pbNoBackout  of oCalcEngine to False
        Set pbNoPreview  of ghoApplication to False 
    End_Procedure
    
    Procedure DoReloadStandards
        Send DoLoadStandards of oCalcEngine
    End_Procedure

End_Object // oEstimate
