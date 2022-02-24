Use Windows.pkg
Use DFClient.pkg
Use cGlblDbForm.pkg
Use cDbTextEdit.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD
Use Invhdr.DD
Use cSht_HdrGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use dfLine.pkg
Use PrintSnowSheet.rv
Use szcalendar.pkg
Use PrintRyanSnowSheet.rv

Deferred_View Activate_oSnowControlEntry for ;
Object oSnowControlEntry is a dbView
    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oProject_DD is a cProjectDataDictionary
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

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server to oOrder_DD
    End_Object

    Object oSht_Hdr_DD is a cSht_HdrGlblDataDictionary
        Set DDO_Server to oInvhdr_DD
    End_Object

    Set Main_DD to oSht_Hdr_DD
    Set Server to oSht_Hdr_DD

    Set Border_Style to Border_Thick
    Set Size to 347 576
    Set Location to 1 2
    Set Auto_Clear_DEO_State to False

    Object oSht_Hdr_Sht_Hdr_ID is a cGlblDbForm
        Entry_Item Sht_Hdr.Sht_Hdr_ID
        Set Location to 21 474
        Set Size to 13 56
        Set Label to "Sht Hdr ID:"
    End_Object

    Object oCustomer_Name is a cGlblDbForm
        Entry_Item Customer.Name
        Set Location to 54 82
        Set Size to 13 205
        Set Label to "Customer:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

    Object oLocation_Name is a cGlblDbForm
        Entry_Item Location.Name
        Set Location to 70 82
        Set Size to 13 205
        Set Label to "Location:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

    Object oInvhdr_InvoiceIdno is a cGlblDbForm
        Entry_Item Invhdr.InvoiceIdno
        Set Location to 22 82
        Set Size to 13 68
        Set Label to "Tempus Invoice #:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSht_Hdr_QB_Invoice_ID is a cGlblDbForm
        Entry_Item Sht_Hdr.QB_Invoice_ID
        Set Location to 37 82
        Set Size to 13 68
        Set Label to "QB Invoice #:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 3
    End_Object

    Object oTextBox1 is a TextBox
        Set Size to 10 50
        Set Location to 23 164
        Set Label to 'Find = F9'
    End_Object

    Object oLineControl1 is a LineControl
        Set Size to 12 505
        Set Location to 95 29
    End_Object

    Object oSht_Hdr_PO_Number is a cGlblDbForm
        Entry_Item Sht_Hdr.PO_Number
        Set Location to 54 384
        Set Size to 13 143
        Set Label to "PO Number:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object
    
    Object oSht_Hdr_Bill_Rate is a dbComboForm
        Entry_Item Sht_Hdr.Bill_Rate
        Set Location to 71 384
        Set Size to 13 143
        Set Label to "Billing Rate:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        
        Procedure Combo_Fill_List
           Send Combo_Delete_Data
           Send Combo_Add_Item "Per Contract"
    
        End_Procedure
        
    End_Object

    Object oSht_Hdr_Equipment is a cDbTextEdit
        Entry_Item Sht_Hdr.Equipment
        Set Location to 136 82
        Set Size to 31 161
        Set Label to "Equipment:"
    End_Object

    Object oSht_Hdr_Personnel is a cDbTextEdit
        Entry_Item Sht_Hdr.Personnel
        Set Location to 178 82
        Set Size to 31 161
        Set Label to "Personnel:"
    End_Object

    Object oSht_Hdr_Time_In_Out is a cDbTextEdit
        Entry_Item Sht_Hdr.Time_In_Out
        Set Location to 222 82
        Set Size to 31 161
        Set Label to "Time In Out:"
    End_Object

    Object oSht_Hdr_Site_Hours is a cGlblDbForm
        Entry_Item Sht_Hdr.Site_Hours
        Set Location to 257 82
        Set Size to 13 42
        Set Label to "Site Hours:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSht_Hdr_Wind_Vel is a cGlblDbForm
        Entry_Item Sht_Hdr.Wind_Vel
        Set Location to 119 370
        Set Size to 13 57
        Set Label to "Wind Velocity:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSht_Hdr_Wind_Dir is a cGlblDbForm
        Entry_Item Sht_Hdr.Wind_Dir
        Set Location to 134 370
        Set Size to 13 58
        Set Label to "Wind Direction:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSht_Hdr_Temp is a cGlblDbForm
        Entry_Item Sht_Hdr.Temp
        Set Location to 149 370
        Set Size to 13 59
        Set Label to "Temperature:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSht_Hdr_Snowfall is a dbComboForm
        Entry_Item Sht_Hdr.Snowfall
        Set Location to 164 371
        Set Size to 13 89
        Set Label to "Amount of Snowfall:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Combo_Sort_State to False
        
        Procedure Combo_Fill_List
    Send Combo_Delete_Data
    Send Combo_Add_Item "Light"
    Send Combo_Add_Item "Moderate"
    Send Combo_Add_Item "Heavy"
    Send Combo_Add_Item "Bilzzard Conditions"
End_Procedure

        
    End_Object

    Object oSht_Hdr_Salt_Used is a dbComboForm
        Entry_Item Sht_Hdr.Salt_Used
        Set Location to 180 371
        Set Size to 13 118
        Set Label to "Salt Used:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
             Set Combo_Sort_State to False
        
        Procedure Combo_Fill_List
    Send Combo_Delete_Data
    Send Combo_Add_Item "1 Application per contract"
    End_Procedure

        
    End_Object

    Object oSht_Hdr_Comments is a cDbTextEdit
        Entry_Item Sht_Hdr.Comments
        Set Location to 206 371
        Set Size to 44 181
        Set Label to "Comments:"
    End_Object

    Object oSht_Hdr_Date is a cGlblDbForm///cszDatePicker
        Entry_Item Sht_Hdr.Date
        Set Location to 256 371
        Set Size to 13 66
        Set Label to "Submission Date:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    

    Object oSht_Hdr_Services_Dates is a cGlblDbForm
        Entry_Item Sht_Hdr.Services_Dates
        Set Location to 109 82
        Set Size to 13 178
        Set Label to "Services Dates:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oButton1 is a Button
        Set Size to 14 73
        Set Location to 307 469
        Set Label to 'Print Snow Sheet'
    
        Procedure OnClick 
            If Customer.CustomerIdno eq 1325 Begin                     
            Send DoPrintSnowSheet
            End
            If Customer.CustomerIdno eq 1227 Begin
            Send DoPrintRyanSnowSheet
            End
        End_Procedure
    
    End_Object
    
    Procedure DoPrintSnowSheet
        #IFDEF TEMPUS_LINK
        #ELSE
        Boolean bCancel
        Integer iShtId
        //
        Get Field_Current_Value of oSht_Hdr_DD Field Sht_Hdr.Sht_Hdr_ID to iShtId
        Get Confirm ("Print Snow Sheet" * String(iShtId) + "?")           to bCancel
        If (not(bCancel)) Begin
          Send DoJumpStartReport of PrintSnowSheet iShtId
        End
        #ENDIF
    End_Procedure
    
   Procedure DoPrintRyanSnowSheet
        #IFDEF TEMPUS_LINK
        #ELSE
        Boolean bCancel
        Integer iShtId
        //
        Get Field_Current_Value of oSht_Hdr_DD Field Sht_Hdr.Sht_Hdr_ID to iShtId
        Get Confirm ("Print Snow Sheet" * String(iShtId) + "?")           to bCancel
        If (not(bCancel)) Begin
          Send DoJumpStartRyan of PrintRyanSnowSheet iShtId
        End
        #ENDIF
    End_Procedure 

Cd_End_Object
