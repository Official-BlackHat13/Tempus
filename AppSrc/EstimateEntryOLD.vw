Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Contact.DD
Use cQuotehdrDataDictionary.dd
Use MastOps.DD
Use cQuotedtlDataDictionary.dd
Use cSnowrepDataDictionary.dd
Use cTempusDbView.pkg
Use cGlblDbForm.pkg

Use EstimateWizard.dg
Use dfTable.pkg
Use cDbTextEdit.pkg
Use cComDbSpellText.pkg
Use cGlblDbComboForm.pkg
Use OrderProcess.bp
Use OperationsProcess.bp
Use CompItem.dg

#IFDEF qtAll
#ELSE
Enum_List
    Define qtAll
    Define qtPavementMaintenance
    Define qtSnowRemoval
End_Enum_List
#ENDIF

Activate_View Activate_oEstimateEntry for oEstimateEntry
Object oEstimateEntry is a cTempusDbView

    Property Integer peQuoteType qtPavementMaintenance

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oMastops_DD is a Mastops_DataDictionary
        Procedure OnConstrain
            If (peQuoteType(Self) = qtPavementMaintenance) Begin
                Constrain MastOps.ActivityType eq "Pavement Mnt."
                Constrain MastOps.Status       eq "A"
            End
        End_Procedure
    End_Object

    Object oSalesrep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesrep_DD
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set DDO_Server to oContact_DD
        Set DDO_Server to oSalesrep_DD
        Set DDO_Server to oLocation_DD
        Set Add_System_File to Order.File_Number DD_LOCK_ON_ALL
        
        Procedure Save_Main_File
            Forward Send Save_Main_File
            //
            If (Quotehdr.JobNumber <> 0) Begin
                Clear Order
                Move Quotehdr.JobNumber to Order.JobNumber
                Find eq Order.JobNumber
                If (Found) Begin
                    Move Quotehdr.Amount to Order.QuoteAmount
                    SaveRecord order
                End
            End
        End_Procedure
    End_Object

    Object oQuotedtl_DD is a cQuotedtlDataDictionary
        Set DDO_Server to oMastops_DD
        Set DDO_Server to oQuotehdr_DD
        Set Constrain_file to Quotehdr.File_number
        Send DefineAllExtendedFields
    End_Object

    Set Main_DD to oQuotehdr_DD
    Set Server to oQuotehdr_DD

    Set Border_Style to Border_Thick
    Set Size to 135 470
    Set Location to 8 8
    Set Label to "Quote Entry"
    Set piMinSize to 135 470
    Set pbAutoActivate to True
    Set piMaxSize to 135 470

    Object oQuotehdr_QuotehdrID is a cGlblDbForm
        Entry_Item Quotehdr.QuotehdrID
        Set Location to 10 51
        Set Size to 13 54
        Set Label to "Quote ID:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right

        Procedure Refresh Integer iMode
            Forward Send Refresh iMode
            //
            Set Enabled_State of oQuoteWizardButton to (Quotehdr.Recnum = 0)
            Set Enabled_State of oCloneButton       to (Quotehdr.Recnum > 0)
            Set Enabled_State of oCreateOrderButton to (Quotehdr.Recnum > 0 and Quotehdr.JobNumber = 0)
            Set Enabled_State of oQuotehdr_Status   to (Quotehdr.Status <> "W" and Quotehdr.Status <> "R")
            Set Enabled_State of oViewOrderButton   to (Quotehdr.JobNumber <> 0)
        End_Procedure
    End_Object

    Object oQuotehdr_QuoteDate is a cdbszDatePicker // cGlblDbForm
        Entry_Item Quotehdr.QuoteDate
        Set Location to 10 224
        Set Size to 13 60
        Set Label to "Quote Date:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oCustomer_CustomerIdno is a cGlblDbForm
        Entry_Item Customer.CustomerIdno
        Set Location to 25 51
        Set Size to 13 54
        Set Label to "Customer:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oCustomer_Name is a cGlblDbForm
        Entry_Item Customer.Name
        Set Location to 25 109
        Set Size to 13 175
        Set Enabled_State to False
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

    Object oContact_ContactIdno is a cGlblDbForm
        Entry_Item Contact.ContactIdno
        Set Location to 40 51
        Set Size to 13 54
        Set Label to "Contact:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right

        Procedure Prompt_Callback Integer hPrompt
            Set Auto_Server_State of hPrompt to True
        End_Procedure
    End_Object

    Object oContact_LastName is a cGlblDbForm
        Entry_Item Contact.LastName
        Set Location to 40 109
        Set Size to 13 90
        Set Prompt_Button_Mode to PB_PromptOff
        Set Enabled_State to False
    End_Object

    Object oContact_FirstName is a cGlblDbForm
        Entry_Item Contact.FirstName

        Set Server to oContact_DD
        Set Location to 40 203
        Set Size to 13 80
        Set Enabled_State to False
    End_Object

    Object oLocation_LocationIdno is a cGlblDbForm
        Entry_Item Location.LocationIdno
        Set Server to oLocation_DD
        Set Location to 55 51
        Set Size to 13 54
        Set Label to "Location:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right

        Procedure Prompt_Callback Integer hPrompt
            Set Auto_Server_State of hPrompt to True
        End_Procedure
    End_Object

    Object oLocation_Name is a cGlblDbForm
        Entry_Item Location.Name
        Set Server to oLocation_DD
        Set Location to 55 109
        Set Size to 13 175
        Set Prompt_Button_Mode to PB_PromptOff
        Set Enabled_State to False
    End_Object

    Object oSalesRep_RepIdno is a cGlblDbForm
        Entry_Item SalesRep.RepIdno
        Set Location to 70 51
        Set Size to 13 54
        Set Label to "Sales Rep:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSalesRep_LastName is a cGlblDbForm
        Entry_Item SalesRep.LastName
        Set Location to 70 109
        Set Size to 13 90
        Set Prompt_Button_Mode to PB_PromptOff
        Set Enabled_State to False
    End_Object

    Object oSalesRep_FirstName is a cGlblDbForm
        Entry_Item SalesRep.FirstName
        Set Location to 70 203
        Set Size to 13 80
        Set Enabled_State to False
    End_Object

    Object oQuotehdr_JobNumber is a cGlblDbForm
        Entry_Item Quotehdr.JobNumber
        Set Location to 40 403
        Set Size to 13 60
        Set Label to "Job Number:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuotehdr_OrderDate is a cGlblDbForm
        Entry_Item Quotehdr.OrderDate
        Set Location to 55 403
        Set Size to 13 60
        Set Label to "Order Date:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuotehdr_Status is a cGlblDbComboForm
        Entry_Item Quotehdr.Status
        Set Location to 70 403
        Set Size to 13 60
        Set Label to "Status:"
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to JMode_Right
        Set Combo_Sort_State to False
    End_Object

    Object oQuoteWizardButton is a Button
        Set Size to 14 80
        Set Location to 5 380
        Set Label to "Quote Wizard"
        Set peAnchors to anTopRight
    
        Procedure OnClick
            Send DoQuoteWizard
        End_Procedure
    End_Object

    Object oSpecificationsButton is a Button
        Set Size to 14 80
        Set Location to 20 380
        Set Label to "Specifications"
        Set peAnchors to anTopRight
    
        Procedure OnClick
            Send DoCalcEngine
        End_Procedure
    End_Object

    Object oQuotehdr_QuoteLostMemo is a cGlblDbForm
        Entry_Item Quotehdr.QuoteLostMemo
        Set Location to 85 51
        Set Size to 13 233
        Set Label to "Memo:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set peAnchors to anBottomLeft
    End_Object

    Object oQuotehdr_WorkType is a cGlblDbComboForm
        Entry_Item Quotehdr.WorkType
        Set Location to 100 51
        Set Size to 13 96
        Set Label to "Work Type:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 3
        Set peAnchors to anBottomLeft
    End_Object

    Object oQuotehdr_Amount is a cGlblDbForm
        Entry_Item Quotehdr.Amount
        Set Location to 85 403
        Set Size to 13 60
        Set Label to "Total:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set peAnchors to anBottomRight
    End_Object

    Object oPrintButton is a Button
        Set Size to 14 54
        Set Location to 108 403
        Set Label to "Print Quote"
        Set peAnchors to anBottomRight
    
        Procedure OnClick
            Integer iQuote
            //
            Get Field_Current_Value of oQuotehdr_DD Field Quotehdr.QuotehdrID to iQuote
            If (iQuote <> 0) Begin
//                Send DoJumpStartReport of oPrintQuotes iQuote
            End
        End_Procedure
    End_Object

    Object oCloneButton is a Button
        Set Size to 14 54
        Set Location to 108 306
        Set Label to "Clone Quote"
        Set peAnchors to anBottomRight
    
        Procedure OnClick
            Send DoCloneQuote
        End_Procedure    
    End_Object

    Object oCreateOrderButton is a Button
        Set Size to 14 54
        Set Location to 108 226
        Set Label to "Create Order"
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send DoCreateOrder
        End_Procedure    
    End_Object

    Object oViewOrderButton is a Button
        Set Location to 108 170
        Set Label to "View Order"
        Set peAnchors to anBottomRight
    
        Procedure OnClick
            Send DoViewOrder
        End_Procedure    
    End_Object

    Register_Object oOrderEntry
    //
    Procedure DoViewOrder
        Integer iRecId
        //
        Send Refind_Records of oQuotehdr_DD
        Clear Order
        Move Quotehdr.JobNumber to Order.JobNumber
        Find eq Order.JobNumber
        If (Found) Begin
            Send DoViewOrder of oOrderEntry Order.Recnum
        End
    End_Procedure

    Function IsSavedHeader Returns Integer
        Integer iRecId
        //
        Get Current_Record of oQuotehdr_DD to iRecId
        //
        If (iRecId = 0) Begin
            Send Stop_Box "No Quote created/selected"
            Function_Return 1
        End
    End_Function

    Procedure DoQuoteWizard
        Integer iRecId
        //
        Get DoEstimateWizard of oEstimateWizardPanel to iRecId
        //
        If (iRecId) Begin
            Send Find_By_Recnum of oQuotehdr_DD Quotehdr.File_Number iRecId
            Send Activate       of oSpecificationsButton
        End
        Else Begin
            Send Activate of oQuotehdr_QuotehdrID
        End
    End_Procedure

    Procedure Request_Delete
        //
    End_Procedure

    Procedure DoDeleteEstimate
        Boolean bCancel
        //
        If (not(HasRecord(oQuotehdr_DD))) Begin
            Procedure_Return
        End
        //
        Get Confirm "Delete Estimate?" to bCancel
        If bCancel Procedure_Return
        //
        Clear Eshead Escomp Esitem //Quotedtl
        Move Quotehdr.QuotehdrID to Eshead.ESTIMATE_ID
        Find eq Eshead.ESTIMATE_ID
        If (Found) Begin
            Move Eshead.ESTIMATE_ID to Escomp.ESTIMATE_ID
            Find ge Escomp.ESTIMATE_ID
            If ((Found) and Escomp.ESTIMATE_ID = Eshead.ESTIMATE_ID) Begin
                Move Escomp.ESTIMATE_ID  to Esitem.ESTIMATE_ID
                Move Escomp.COMPONENT_ID to Esitem.COMPONENT_ID
                Move -9999999            to Esitem.OPCODE
                Find ge Esitem by Index.2
                While ((Found) and Esitem.ESTIMATE_ID = Escomp.ESTIMATE_ID and Esitem.COMPONENT_ID = Escomp.COMPONENT_ID)
                    Reread Esitem
                    Delete Esitem
                    Unlock
                    Clear Esitem
                    Move Escomp.ESTIMATE_ID  to Esitem.ESTIMATE_ID
                    Move Escomp.COMPONENT_ID to Esitem.COMPONENT_ID
                    Move -9999999            to Esitem.OPCODE
                    Find ge Esitem by Index.2
                Loop
            End
            Reread Escomp Eshead
            Delete Escomp
            Delete Eshead
            Unlock
        End
    End_Procedure
    //
    On_Key Key_Alt+Key_F2 Send DoDeleteEstimate

    Procedure DoCalcEngine
        Integer hoDD iRecId iStatus
        //
        Get Server                 to hoDD
        Get Current_Record of hoDD to iRecId
        //
        If (not(iRecId)) Procedure_Return
        //
        Clear Eshead Escomp
        //
        Move Quotehdr.QuotehdrID to Eshead.ESTIMATE_ID
        Find eq Eshead.ESTIMATE_ID
        If (not(Found)) Begin
            Reread System
            Move ("Quote number" * String(Quotehdr.QuotehdrID)) to Eshead.TITLE
            Move 1                                              to Eshead.COMP_COUNT
            Move Quotehdr.QuoteDate                             to Eshead.CREATION_DATE
            Move "Y"                                            to Eshead.LOCKED
            Move 1                                              to Eshead.QTY1
            Move 2                                              to Eshead.QTY2
            Move 3                                              to Eshead.QTY3
            SaveRecord Eshead
            //
            Add 1 to System.EscompId
            SaveRecord System
            //
            Move Eshead.ESTIMATE_ID to Escomp.ESTIMATE_ID
            Move Eshead.TITLE       to Escomp.DESCRIPTION
            Move System.EscompId    to Escomp.COMPONENT_ID
            Move Quotehdr.QuoteDate to Escomp.CREATION_DATE
            Move 1                  to Escomp.QTY1
            Move 2                  to Escomp.QTY2
            Move 3                  to Escomp.QTY3
            SaveRecord Escomp
            Unlock
        End
        Else Begin
            Move Eshead.ESTIMATE_ID to Escomp.ESTIMATE_ID
            Find ge Escomp.ESTIMATE_ID
        End
        //
        Get_Attribute DF_FILE_STATUS of Escomp.File_Number to iStatus
        If (iStatus = DF_FILE_ACTIVE and Escomp.ESTIMATE_ID = Quotehdr.QuotehdrID) Begin
            Send DoSpecifications of oComponentItemDialog Escomp.Recnum False True
            Send Find_By_Recnum   of hoDD Quotehdr.File_Number iRecId
        End
    End_Procedure

    Procedure DoViewQuote Integer iQuotehdrIdno
        Send Request_Clear_All
        If (iQuotehdrIdno) Begin
            Move iQuotehdrIdno to Quotehdr.QuotehdrID
            Send Find of oQuotehdr_DD EQ 1
        End
        Send Activate_View
    End_Procedure

    Procedure DoCloneQuote
        Boolean bCancel
        Integer iQuoteHdrId iHdrRecId iDtlRecId
        Date    dToday
        //
        Get Confirm "Clone Quote?" to bCancel
        If (not(bCancel)) Begin
            Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.Status to "R"
            Send Request_Save       of oQuotehdr_DD
            Move Quotehdr.QuotehdrID                                      to iQuoteHdrId
            //
            Send ChangeAllFileModes DF_FILEMODE_READONLY
            Set_Attribute DF_FILE_MODE of System.File_Number   to DF_FILEMODE_DEFAULT
            Set_Attribute DF_FILE_MODE of Quotehdr.File_Number to DF_FILEMODE_DEFAULT
            Set_Attribute DF_FILE_MODE of Quotedtl.File_Number to DF_FILEMODE_DEFAULT
            //
            Sysdate dToday
            Reread
            Add 1 to System.QuoteHdrId
            SaveRecord System
            //
            Move 0                 to Quotehdr.Recnum
            Move System.QuoteHdrId to Quotehdr.QuotehdrID
            Move dToday            to Quotehdr.QuoteDate
            Move 0                 to Quotehdr.ExpirationDate
            Move 0                 to Quotehdr.JobNumber
            Move 0                 to Quotehdr.OrderDate
            Move "P"               to Quotehdr.Status
            Move iQuoteHdrId       to Quotehdr.CloneReference
            SaveRecord Quotehdr
            Unlock
            Move Quotehdr.Recnum   to iHdrRecId
            //
            If (iHdrRecId <> 0) Begin
                Clear Quotedtl
                Move iQuoteHdrId to Quotedtl.QuotehdrID
                Find ge Quotedtl.QuotehdrID
                While ((Found) and Quotedtl.QuotehdrID = iQuoteHdrId)
                    Move Quotedtl.Recnum   to iDtlRecId
                    Reread
                    Add 1                  to System.QuoteDtlId
                    SaveRecord System
                    //
                    Move 0                 to Quotedtl.Recnum
                    Move System.QuoteDtlId to Quotedtl.QuotedtlID
                    Move System.QuotehdrID to Quotedtl.QuotehdrID
                    SaveRecord Quotedtl
                    Unlock
                    //
                    Clear Quotedtl
                    Move iDtlRecId to Quotedtl.Recnum
                    Find eq Quotedtl.Recnum
                    Find gt Quotedtl.QuotehdrID
                Loop
                Send Clear_All      of oQuotehdr_DD
                Send Find_By_Recnum of oQuotehdr_DD Quotehdr.File_Number iHdrRecId
            End
            Send ChangeAllFileModes DF_FILEMODE_DEFAULT
        End
        Send Activate of oQuotehdr_QuotehdrID
    End_Procedure

    Procedure DoCreateOrder
        Integer iRecId iErrors iCreated
        //
        Send Refind_Records of oQuotehdr_DD
        Get DoCreateOrderFromQuote of oOrderProcess Quotehdr.Recnum to iRecId
        If (iRecId) Begin
            If (Order.Recnum <> iRecId) Begin
                Clear Order
                Move iRecId to Order.Recnum
                Find eq Order.Recnum
            End
            Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.JobNumber to Order.JobNumber
            Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.OrderDate to Order.JobOpenDate
            Set Field_Changed_Value of oQuotehdr_DD Field Quotehdr.Status    to "W"
            Send Request_Save       of oQuotehdr_DD
            //
            Get DoAddUniversalMastOpsToLocation of oOperationsProcess Location.LocationIdno Quotehdr.WorkType (&iErrors) to iCreated
            If (iErrors > 1) Begin
                Send Info_Box (String(iCreated) * "Operations created." * String(iErrors) * "errors.")
            End
        End
        Send Activate of oQuotehdr_QuotehdrID
    End_Procedure

    Procedure DoReloadStandards
        Send DoLoadStandards of oCalcEngine
    End_Procedure
    //
    On_Key Key_Alt+Key_F12 Send DoReloadStandards

End_Object
