Use Windows.pkg
Use DFClient.pkg
Use cDbCJGrid.pkg
Use System.DD
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD
Use cSht_HdrGlblDataDictionary.dd
Use cSht_DtlGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use cDbTextEdit.pkg

Deferred_View Activate_oTestCombo for ;
Object oTestCombo is a dbView
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

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oSht_Hdr_DD is a cSht_HdrGlblDataDictionary
        Set DDO_Server to oOrder_DD
    End_Object

    Object oSShtDtl_DD is a cSht_DtlGlblDataDictionary
        Set Constrain_file to Sht_Hdr.File_number
        Set DDO_Server to oSht_Hdr_DD
    End_Object

    Set Main_DD to oSht_Hdr_DD
    Set Server to oSht_Hdr_DD

    Set Border_Style to Border_Thick
    Set Size to 273 605
    Set Location to 41 152

    Object oOrder_JobNumber is a cGlblDbForm
        Entry_Item Order.JobNumber
        Set Location to 29 60
        Set Size to 13 54
        Set Label to "JobNumber:"
        Set Label_Col_Offset to 6
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oCustomer_Name is a cGlblDbForm
        Entry_Item Customer.Name
        Set Location to 29 121
        Set Size to 13 150
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

    Object oLocation_Name is a cGlblDbForm
        Entry_Item Location.Name
        Set Location to 48 121
        Set Size to 13 150
        Set Prompt_Button_Mode to PB_PromptOff
       
    End_Object

    Object oSht_Hdr_Wind_Vel is a cGlblDbForm
        Entry_Item Sht_Hdr.Wind_Vel
        Set Location to 28 338
        Set Size to 13 166
        Set Label to "Wind Vel:"
    End_Object

    Object oSht_Hdr_Wind_Dir is a cGlblDbForm
        Entry_Item Sht_Hdr.Wind_Dir
        Set Location to 43 338
        Set Size to 13 166
        Set Label to "Wind Dir:"
    End_Object

    Object oSht_Hdr_Temp is a cGlblDbForm
        Entry_Item Sht_Hdr.Temp
        Set Location to 58 338
        Set Size to 13 166
        Set Label to "Temp:"
    End_Object

    Object oSht_Hdr_Snowfall is a cGlblDbForm
        Entry_Item Sht_Hdr.Snowfall
        Set Location to 74 338
        Set Size to 13 186
        Set Label to "Snowfall:"
    End_Object

    Object oSht_Hdr_Salt_Used is a cGlblDbForm
        Entry_Item Sht_Hdr.Salt_Used
        Set Location to 88 338
        Set Size to 13 186
        Set Label to "Salt Used:"
    End_Object

    Object oSht_Hdr_Site_Hours is a cGlblDbForm
        Entry_Item Sht_Hdr.Site_Hours
        Set Location to 209 219
        Set Size to 13 42
        Set Label to "Site Hours:"
    End_Object

    Object oSht_Hdr_Note is a cDbTextEdit
        Entry_Item Sht_Hdr.Note
        Set Location to 128 338
        Set Size to 60 120
        Set Label to "Note:"
    End_Object

    Object oSht_Hdr_Sheet_Hdr_idno is a cGlblDbForm
        Entry_Item Sht_Hdr.Sheet_Hdr_idno
        Set Location to 96 80
        Set Size to 13 54
        Set Label to "Sheet Hdr idno:"
    End_Object

    Object oSht_Dtl_Equip is a cGlblDbForm
        Entry_Item Sht_Dtl.Equip

        Set Server to oSShtDtl_DD
        Set Location to 161 64
        Set Size to 13 186
        Set Label to "Equip:"
    End_Object

Cd_End_Object
