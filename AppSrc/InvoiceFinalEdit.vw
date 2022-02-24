Use Windows.pkg
Use DFClient.pkg
Use cDbCJGrid.pkg
Use cGlblDbForm.pkg
Use dfSelLst.pkg
Use dfTable.pkg
Use cDbCJGridPromptList.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use Invhdr.DD
Use MastOps.DD
Use Opers.DD
Use Invdtl.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use cDbTextEdit.pkg
//Use Mastops.sl

Deferred_View Activate_oInvoiceFinalEdit for ;
Object oInvoiceFinalEdit is a dbView
    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Object oMastOps_DD is a Mastops_DataDictionary
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
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set Constrain_file to Location.File_number
        Set DDO_Server to oMastops_DD
        Set DDO_Server to oLocation_DD      
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server to oOrder_DD
        Set Cascade_Delete_State to False
        Set No_Delete_State to True
        Set Ordering to 9
        Procedure OnConstrain
            Constrain Invhdr.QBInvoiceNumber ne 0
            Constrain Invhdr.QBPaidFlag ne 1
        End_Procedure
    End_Object

    Object oInvdtl_DD is a Invdtl_DataDictionary
        Set DDO_Server to oOpers_DD
        Set Constrain_file to Invhdr.File_number
        Set DDO_Server to oInvhdr_DD
        Send DefineAllExtendedFields
    End_Object

    Set Main_DD to oInvhdr_DD
    Set Server to oInvhdr_DD

    Set Border_Style to Border_Thick
    Set Label to "Invoice Editor - After QB transfer"
    Set Size to 382 615
    Set Location to 22 41
    Set piMinSize to 226 615

    Object oDbCJGrid1 is a cDbCJGrid
        Set Server to oInvdtl_DD
        Set Size to 222 607
        Set Location to 65 5
        Set pbReadOnly to False

        Object oInvdtl_Sequence is a cDbCJGridColumn
            Entry_Item Invdtl.Sequence
            Set piWidth to 98
            Set psCaption to "Sequence"
        End_Object

        Object oOpers_OpersIdno is a cDbCJGridColumn
            Entry_Item Opers.OpersIdno
            Set piWidth to 131
            Set psCaption to "Opers ID"
            Set pbVisible to False
        End_Object

        Object oOpers_Name is a cDbCJGridColumn
            Entry_Item Opers.Name
            Set piWidth to 467
            Set psCaption to "Operation"

            Procedure OnSelectedRowDataChanged String sOldValue String sValue
                Forward Send OnSelectedRowDataChanged sOldValue sValue
                //
                Set Field_Changed_Value of oInvdtl_DD Field Invdtl.Price to Opers.SellRate
                Send UpdateCurrentValue of oInvdtl_Price Opers.SellRate
                Set Field_Changed_Value of oInvdtl_DD Field Invdtl.Description to Opers.Description
                Set Value of oInvdtl_Description to Opers.Description
            End_Procedure
        End_Object

        Object oInvdtl_StartTime is a cDbCJGridColumn
            Entry_Item Invdtl.StartTime
            Set piWidth to 72
            Set psCaption to "Start Time"
        End_Object

        Object oInvdtl_StopTime is a cDbCJGridColumn
            Entry_Item Invdtl.StopTime
            Set piWidth to 72
            Set psCaption to "Stop Time"
        End_Object

        Object oInvdtl_Quantity is a cDbCJGridColumn
            Entry_Item Invdtl.Quantity
            Set piWidth to 73
            Set psCaption to "Quantity"
        End_Object

        Object oInvdtl_Price is a cDbCJGridColumn
            Entry_Item Invdtl.Price
            Set piWidth to 75
            Set psCaption to "Price"
        End_Object

        Object oInvdtl_Total is a cDbCJGridColumn
            Entry_Item Invdtl.Total
            Set piWidth to 74
            Set psCaption to "Total"
        End_Object
    End_Object
    
        Object oDbContainer3d1 is a dbContainer3d
        Set Size to 59 607
        Set Location to 3 4

        Object oInvhdr_InvoiceIdno is a cGlblDbForm
            Entry_Item Invhdr.InvoiceIdno
            Set Location to 5 221
            Set Size to 13 54
            Set Label to "Tempus Invoice Number:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oInvhdr_JobNumber is a cGlblDbForm
            Entry_Item Order.JobNumber
            Set Location to 21 518
            Set Size to 13 66
            Set Label to "Job Number:"
            Set Prompt_Button_Mode to PB_PromptOff
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Enabled_State to False
        End_Object

        Object oCustomer_Name is a cGlblDbForm
            Entry_Item Customer.Name

            Set Server to oInvdtl_DD
            Set Location to 21 80
            Set Size to 13 142
            Set Label to "Customer:"
            Set Prompt_Button_Mode to PB_PromptOff
            Set Entry_State to False
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
            Set Enabled_State to False
        End_Object

        Object oLocation_Name is a cGlblDbForm
            Entry_Item Location.Name

            Set Server to oInvdtl_DD
            Set Location to 20 259
            Set Size to 13 141
            Set Label to "Location:"
            Set Prompt_Button_Mode to PB_PromptOff
            Set Entry_State to False
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Enabled_State to False
        End_Object

        Object oOrder_PO_Number is a cGlblDbForm
            Entry_Item Order.PO_Number
            Set Location to 37 81
            Set Size to 13 319
            Set Label to "PO Number:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oInvhdr_InvoiceDate is a cGlblDbForm
            Entry_Item Invhdr.InvoiceDate
            Set Location to 6 518
            Set Size to 13 66
            Set Label to "Invoice Date:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

            Object oInvhdr_QBInvoiceNumber is a cGlblDbForm
                Entry_Item Invhdr.QBInvoiceNumber
                Set Location to 6 80
                Set Size to 13 54
                Set Label to "QuickBooks Invoice #:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oButton1 is a Button
                Set Size to 14 66
                Set Location to 37 518
                Set Label to 'Print Invoice'
                Set peAnchors to anTopRight
                //Set peAnchors to anAll
            
                // fires when the button is clicked
                Procedure OnClick
                     Send DoPrintInvoice
                End_Procedure
            
            End_Object
    End_Object

    Object oInvdtl_Description is a cDbTextEdit
        Entry_Item Invdtl.Description

        Set Server to oInvdtl_DD
        Set Location to 301 5
        Set Size to 75 494
        Set Label to "Description:"
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

    Procedure Request_Delete
    End_Procedure

    Object oInvhdr_SubTotal is a cGlblDbForm
        Entry_Item Invhdr.SubTotal
        Set Server to oInvhdr_DD
        Set Location to 299 540
        Set Size to 13 69
        Set Label to "SubTotal:"
        Set Enabled_State to False
        Set peAnchors to anBottomRight
        Set TextColor to clBlack
        Set Form_Datatype to Mask_Numeric_Window
        Set Form_Mask to "$ #,###,##0.00"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 5
    End_Object
    Object oInvhdr_TaxTotal is a cGlblDbForm
        Entry_Item Invhdr.TaxTotal
        Set Server to oInvhdr_DD
        Set Location to 315 540
        Set Size to 13 69
        Set Label to "Sales Tax:"
        Set Label_Col_Offset to 5
        Set Enabled_State to False
        Set peAnchors to anBottomRight
        Set TextColor to clBlack
        Set Form_Datatype to Mask_Numeric_Window
        Set Form_Mask to "$ #,###,##0.00"
        Set Label_Justification_Mode to JMode_Right
    End_Object
    Object oInvhdr_TotalAmount is a cGlblDbForm
        Entry_Item Invhdr.TotalAmount
        Set Server to oInvhdr_DD
        Set Location to 330 540
        Set Size to 13 69
        Set Label to "Total:"
        Set Label_Col_Offset to 5
        Set Enabled_State to False
        Set peAnchors to anBottomRight
        Set TextColor to clBlack
        Set Form_Datatype to Mask_Numeric_Window
        Set Form_Mask to "$ #,###,##0.00"
        Set Label_Justification_Mode to JMode_Right
    End_Object
    Object oInvhdr_TotalCost is a cGlblDbForm
        Entry_Item Invhdr.TotalCost
        Set Server to oInvhdr_DD
        Set Location to 345 539
        Set Size to 13 69
        Set Label to "Cost:"
        Set Label_Col_Offset to 5
        Set peAnchors to anBottomRight
        Set TextColor to clBlack
        Set Enabled_State to False
        Set Form_Datatype to Mask_Numeric_Window
        Set Form_Mask to "$ #,###,##0.00"
        Set Label_Justification_Mode to JMode_Right
    End_Object
    Object oCurrentProfit is a cGlblDbForm
        Entry_Item (1-(Invhdr.TotalCost/Invhdr.TotalAmount)*100)
        Set Size to 13 69
        Set Location to 360 540
        Set Label to "Profit:"
        Set peAnchors to anBottomRight
        Set Label_Col_Offset to 5
        Set TextColor to clBlack
        Set Enabled_State to False
        Set Form_Datatype to Mask_Numeric_Window
        Set Label_Justification_Mode to JMode_Right
        Set Form_Mask to "#,###,##0.00 %"
        Set Form_Mask of oCurrentProfit to "#0.00 %"
    End_Object

    

Cd_End_Object
