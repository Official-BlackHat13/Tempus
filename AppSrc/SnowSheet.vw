Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD
Use Invhdr.DD
Use cSnoSheetGlblDataDictionary.dd

Use Opers.DD
Use Invdtl.DD
Use cSShtDtlGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use szcalendar.pkg
Use cDbTextEdit.pkg
Use cDbCJGridPromptList.pkg
Use SnowSheet.rv
Use dfTable.pkg

Deferred_View Activate_oSnowSheet for ;
Object oSnowSheet is a dbView
//    Object oMastOps_DD is a Mastops_DataDictionary
//    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oProject_DD is a cProjectDataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

//    Object oOpers_DD is a Opers_DataDictionary
//        Set DDO_Server to oMastOps_DD
//        Set DDO_Server to oLocation_DD
//    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server to oOrder_DD
    End_Object

    Object oInvdtl_DD is a Invdtl_DataDictionary
        Set DDO_Server to oOpers_DD
        Set Constrain_file to Invhdr.File_number
        Set DDO_Server to oInvhdr_DD
    End_Object


    Object oSnoSheet_DD is a cSnoSheetGlblDataDictionary
        Set Constrain_file to Invhdr.File_number
        Set DDO_Server to oInvhdr_DD
    End_Object

    Object oSShtDtl_DD is a cSShtDtlGlblDataDictionary
        Set Constrain_file to SnoSheet.File_number
        Set DDO_Server to oSnoSheet_DD
    End_Object

    Set Main_DD to oInvhdr_DD
    Set Server to oInvhdr_DD

    Set Border_Style to Border_Thick
    Set Size to 369 568
    Set Location to 16 40

    Object oInvhdr_InvoiceIdno is a cGlblDbForm
        Entry_Item Invhdr.InvoiceIdno
        Set Location to 29 61
        Set Size to 13 54
        Set Label to "InvoiceIdno:"
        Set Label_Col_Offset to 6
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oCustomer_Name is a cGlblDbForm
        Entry_Item Customer.Name
        Set Location to 28 136
        Set Size to 13 223
        Set Prompt_Button_Mode to PB_PromptOff
        Set Enabled_State to False
        Set Entry_State to False
    End_Object

    Object oLocation_Name is a cGlblDbForm
        Entry_Item Location.Name
        Set Location to 46 136
        Set Size to 13 223
        Set Prompt_Button_Mode to PB_PromptOff
        Set Enabled_State to False
        Set Entry_State to False
    End_Object

    Object oSnoSheet_Comment is a cDbTextEdit
        Entry_Item SnoSheet.Comment

        Set Server to oSnoSheet_DD
        Set Location to 97 135
        Set Size to 60 226
        Set Label to "Comment:"
    End_Object

    Object oButton1 is a Button
        Set Size to 14 78
        Set Location to 345 467
        Set Label to 'Print Snow Sheet'
    
        // fires when the button is clicked
        Procedure OnClick
            
            Send DoPrintSnowSheet
            
        End_Procedure
    
    End_Object

    Object oSnoSheet_Date is a cdbszDatePicker
        Entry_Item SnoSheet.Date

        Set Server to oSnoSheet_DD
        Set Location to 97 413
        Set Size to 13 66
        Set Label to "Date:"
        Set Label_Col_Offset to 6
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSnoSheet_WindVel is a cGlblDbForm
        Entry_Item SnoSheet.WindVel

        Set Server to oSnoSheet_DD
        Set Location to 112 413
        Set Size to 13 66
        Set Label to "WindVel:"
        Set Label_Col_Offset to 6
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSnoSheet_WindDir is a cGlblDbForm
        Entry_Item SnoSheet.WindDir

        Set Server to oSnoSheet_DD
        Set Location to 127 413
        Set Size to 13 66
        Set Label to "WindDir:"
        Set Label_Col_Offset to 6
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSnoSheet_Temp is a cGlblDbForm
        Entry_Item SnoSheet.Temp

        Set Server to oSnoSheet_DD
        Set Location to 142 413
        Set Size to 13 66
        Set Label to "Temp:"
        Set Label_Col_Offset to 6
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSnoSheet_SnowAmt is a cGlblDbForm
        Entry_Item SnoSheet.SnowAmt

        Set Server to oSnoSheet_DD
        Set Location to 157 413
        Set Size to 13 66
        Set Label to "SnowAmt:"
        Set Label_Col_Offset to 6
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSnoSheet_SnoSheetIdno is a cGlblDbForm
        Entry_Item SnoSheet.SnoSheetIdno

        Set Server to oSnoSheet_DD
        Set Location to 98 63
        Set Size to 13 54
        Set Label to "SnoSheetIdno:"
        Set Label_Col_Offset to 6
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oDbCJGrid1 is a cDbCJGrid
        Set Server to oSShtDtl_DD
        Set Size to 100 337
        Set Location to 188 81

        Object oSShtDtl_Description is a cDbCJGridColumn
            Entry_Item SShtDtl.Description
            Set piWidth to 505
            Set psCaption to "Description"
        End_Object

        Object oSShtDtl_CrewNames is a cDbCJGridColumn
            Entry_Item SShtDtl.CrewNames
            Set piWidth to 540
            Set psCaption to "CrewNames"
        End_Object
    End_Object
    
    
    Procedure DoPrintSnowSheet   
        Boolean bCancel
        Integer iRefId
        //
        Get Field_Current_Value of oInvHdr_DD Field InvHdr.InvoiceIdno to iRefId
        Get Confirm ("Print Snow Sheet" * String(iRefId) + "?")       to bCancel
        If (not(bCancel)) Begin
            Send DoJumpStartReport of SnowSheet iRefId
                          End       
    End_Procedure
    

Cd_End_Object
