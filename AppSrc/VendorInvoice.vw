// C:\Development Projects\VDF18.2 Workspaces\Tempus\AppSrc\VendorInvoice.vw
// VendorInvoice
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use Employer.DD
Use cVendInvHdrGlblDataDictionary.dd
Use cVendInvDtlGlblDataDictionary.dd
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use dfcentry.pkg
Use Windows.pkg
Use cCJCommandBarSystem.pkg

Use VendInvoiceReport.rv
Use UnInvoicedTransactionsV2Report.rv
Use VoidVendorInvoice.bp

ACTIVATE_VIEW Activate_oVendorInvoice FOR oVendorInvoice
Object oVendorInvoice is a cGlblDbView
    Set Location to 5 5
    Set Size to 287 668
    Set Label To "VendorInvoice"
    Set Border_Style to Border_Thick
    Set Maximize_Icon to True


    Object oEmployer_DD is a Employer_DataDictionary
        Procedure OnConstrain
            String sValue
            Get Value of oEmployerCombo to sValue
            Move (Ltrim(sValue)) to sValue
            If ((Length(sValue))>1) Begin
                Send Clear of oEmployer_DD
                Constrain Employer.Name eq sValue
            End
            
        End_Procedure   
    End_Object 

    Object oVendInvHdr_DD is a cVendInvHdrGlblDataDictionary
        Set DDO_Server to oEmployer_DD

        Procedure OnConstrain
            If (not(Checked_State(oShowVoidedCheckBox(Self)))) Constrain VendInvHdr.VoidFlag ne 1
            If (not(Checked_State(oShowInQBCheckBox(Self)))) Constrain VendInvHdr.PostedFlag ne 1
        End_Procedure
        
    End_Object 

    Object oVendInvDtl_DD is a cVendInvDtlGlblDataDictionary
        Set DDO_Server To oVendInvHdr_DD
        Set Constrain_File To VendInvHdr.File_Number
    End_Object 

    Set Main_DD To oVendInvHdr_DD
    Set Server  To oVendInvHdr_DD

    Object oVendorInvoiceGrid is a cDbCJGrid
        Set Size to 252 654
        Set Location to 32 7
        Set peAnchors to anAll
        Set pbHotTracking to True
        Set piSelectedRowBackColor to clYellow
        Set piHighlightBackColor to clYellow
        Set piFocusCellRectangleColor to clNone
        Set pbShowRowFocus to True
        Set pbAllowAppendRow to False
        Set pbAllowDeleteRow to False
        Set pbAllowInsertRow to False
        Set pbSelectionEnable to True
        Set piHighlightForeColor to clBlack
        Set piSelectedRowForeColor to clBlack
        Set pbUseAlternateRowBackgroundColor to True
        Set pbStaticData to True
        Set pbHeaderReorders to True
        Set pbHeaderTogglesDirection to True
        Set Ordering to 5

        Object oVendInvHdr_VendInvHdrIdno is a cDbCJGridColumn
            Entry_Item VendInvHdr.VendInvHdrIdno
            Set piWidth to 54
            Set psCaption to "Inv#"
            Set pbEditable to False
        End_Object

        Object oVendInvHdr_CreatedDate is a cDbCJGridColumn
            Entry_Item VendInvHdr.CreatedDate
            Set piWidth to 62
            Set psCaption to "Inv. Date"
            Set pbEditable to False
        End_Object

        Object oVendInvHdr_Memo is a cDbCJGridColumn
            Entry_Item VendInvHdr.Memo
            Set piWidth to 270
            Set psCaption to "Memo"
            Set pbEditable to False
        End_Object

        Object oVendInvHdr_WeekNumber is a cDbCJGridColumn
            Entry_Item VendInvHdr.WeekNumber
            Set piWidth to 272
            Set psCaption to "WeekNumber"
            Set pbEditable to False
        End_Object

        Object oEmployer_Name is a cDbCJGridColumn
            Entry_Item Employer.Name
            Set piWidth to 167
            Set psCaption to "Employer"
            Set pbEditable to False
        End_Object

        Object oVendInvHdr_Terms is a cDbCJGridColumn
            Entry_Item VendInvHdr.Terms
            Set piWidth to 121
            Set psCaption to "Terms"
            Set pbEditable to False
        End_Object

        Object oVendInvHdr_TotalAmount is a cDbCJGridColumn
            Entry_Item VendInvHdr.TotalAmount
            Set piWidth to 98
            Set psCaption to "TotalAmount"
            Set pbEditable to False
        End_Object

        Object oVendInvHdr_PostedFlag is a cDbCJGridColumn
            Entry_Item VendInvHdr.PostedFlag
            Set pbCheckbox to True
            Set piWidth to 50
            Set psCaption to "In QB"
        End_Object

        Object oVendInvHdr_VoidFlag is a cDbCJGridColumn
            Entry_Item VendInvHdr.VoidFlag
            Set pbCheckbox to True
            Set piWidth to 50
            Set pbEditable to False
            Set psCaption to "Voided"
        End_Object
        
        Object oVendInvContextMenu is a cCJContextMenu
            Object oVoidVendInvoice is a cCJMenuItem
                Set psCaption to "VOID"
                Set psTooltip to "Void Vendor Invoice"

                Procedure OnExecute Variant vCommandBarControl
                    Forward Send OnExecute vCommandBarControl
                    Integer iVoidResponse iVendInvNumber
                    String sErrorMsg
                    Boolean bSuccess
                    Get Field_Current_Value of oVendInvHdr_DD Field VendInvHdr.VendInvHdrIdno to iVendInvNumber
                    // Confirmation Message
                    Move (YesNoCancel_Box(("Are you sure you want to VOID Vendor Invoice# " + String(iVendInvNumber) +"?"), "VOID Vendor Invoice")) to iVoidResponse
                    If (iVoidResponse = MBR_Yes) Begin
                        //Get DoVoidVendInvoice of oVoidVendInvoice iVendInvNumber sErrorMsg to bSuccess
                        Get DoVoidVendInvoice of oVoidVendorInvoice iVendInvNumber sErrorMsg to bSuccess
                        If (not(bSuccess)) Begin
                            Send Info_Box ("Vendor Invoice# " + String(iVendInvNumber) + " was not VOIDED") "Invoice Voiding - Error"
                        End
                        If (bSuccess) Begin
                            Send Info_Box ("Vendor Invoice# " + String(iVendInvNumber) + " was successfully VOIDED") "Invoice Voiding - Success"
                        End
                    End
                    If (iVoidResponse = MBR_No) Begin
                        Send Info_Box ("VOIDING Vendor Invoice process was not started")
                    End
                    If (iVoidResponse = MBR_Cancel) Begin
                        Send Info_Box ("VOIDING Vendor Invoice process was canceled")
                    End
                End_Procedure
            End_Object

            Object oPrintVendorInvoiceMenuItem is a cCJMenuItem
                Set psCaption to "Print"
                Set psTooltip to "Print Vendor Invoice"

                Procedure OnExecute Variant vCommandBarControl
                    Forward Send OnExecute vCommandBarControl
                    Integer iVendInvNumber
                    Get Field_Current_Value of oVendInvHdr_DD Field VendInvHdr.VendInvHdrIdno to iVendInvNumber
                    Send DoJumpStartReport of oVendInvoiceReportView iVendInvNumber
                End_Procedure
            End_Object
        End_Object


        Procedure OnRowRightClick Integer iRow Integer iCol
            //Forward Send OnRowRightClick iRow iCol
            //POPUP Menu
            Send Popup of oVendInvContextMenu
        End_Procedure

        Procedure OnComRowDblClick Variant llRow Variant llItem
            Forward Send OnComRowDblClick llRow llItem
            Integer iVendInvNumber
            Get Field_Current_Value of oVendInvHdr_DD Field VendInvHdr.VendInvHdrIdno to iVendInvNumber
            Send DoJumpStartReport of oVendInvoiceReportView iVendInvNumber
        End_Procedure

        Procedure Activating
            Forward Send Activating
            Send MoveToFirstRow of oVendorInvoiceGrid
        End_Procedure
    End_Object

    Object oStatusGroup is a Group
        Set Size to 25 90
        Set Location to 3 5
        Set Label to 'Show Filter'

        Object oShowVoidedCheckBox is a CheckBox
            Set Size to 10 38
            Set Location to 11 12
            Set Label to 'Voided'
            Set Checked_State to False
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                //
                Get Checked_State to bChecked
                Send Clear_All of oVendInvHdr_DD
                Send Rebuild_Constraints of oVendInvHdr_DD
                Send MoveToFirstRow of oVendorInvoiceGrid
            End_Procedure
        End_Object

        Object oShowInQBCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 11 50
            Set Label to 'In QB'
            Set Checked_State to False
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                //
                Get Checked_State to bChecked
                Send Clear_All of oVendInvHdr_DD
                Send Rebuild_Constraints of oVendInvHdr_DD
                Send MoveToFirstRow of oVendorInvoiceGrid
            End_Procedure
        
        End_Object
    End_Object

    Object oDbGroup1 is a dbGroup
        Set Size to 25 140
        Set Location to 3 103
        Set Label to 'Employer'
        Set peAnchors to anTopLeft

        Object oEmployerCombo is a dbComboForm
            Set Size to 12 100
            Set Entry_State to False
            Set Allow_Blank_State to True
            Set Location to 9 7
            Set Combo_Data_File to 4
            Set Code_Field to 2
            Set Combo_Index to 2
            Set Description_Field to 2
            Set Label to ""
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 5
            
            
            Procedure OnChange
                Send Clear_All of oVendInvHdr_DD
                Send Rebuild_Constraints of oVendInvHdr_DD
                Send MoveToFirstRow of oVendorInvoiceGrid
            End_Procedure
        End_Object
        
        Object oButton1 is a Button
            Set Size to 14 25
            Set Location to 8 109
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oEmployerCombo to ""
            End_Procedure
        
        End_Object
    End_Object

    Object oUnInvoicedReport is a Group
        Set Size to 25 270
        Set Location to 2 253
        Set Label to 'Un-Invoiced Report'

        Object oFromDate is a Form
            Set Size to 13 74
            Set Location to 9 46
            Set Label to "Between:"
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
            Set Form_Datatype to Mask_Date_Window
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt
        End_Object

        Object oToDate is a Form
            Set Size to 13 72
            Set Location to 9 133
            Set Label to "-"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Form_Datatype to Mask_Date_Window
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt
        End_Object

        Object oButton2 is a Button
            Set Location to 8 213
            Set Label to 'Run'
        
            // fires when the button is clicked
            Procedure OnClick
                Date dFromDate dToDate
                String sErrorMsg
                Boolean bSuccess
                
                Get Value of oFromDate to dFromDate
                Get Value of oToDate to dToDate
                Get ValidateDateSelection dFromDate dToDate True (&sErrorMsg) to bSuccess
                If (bSuccess) Begin
                    Send DoJumpStartReport of oUnInvoicedTransactionsV2ReportView dFromDate dToDate
                End
                Else Begin
                    Send Stop_Box sErrorMsg "Error"
                End
                
                
            End_Procedure
        
        End_Object
    End_Object


End_Object 
