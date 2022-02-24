Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD
//Use Invhdr.DD
Use cSnoSheetGlblDataDictionary.dd
Use cSShtDtlGlblDataDictionary.dd
Use cGlblDbForm.pkg

Deferred_View Activate_oSnowSheetEntry for ;
Object oSnowSheetEntry is a dbView
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

//    Object oInvhdr_DD is a Invhdr_DataDictionary
//        Set DDO_Server to oOrder_DD
//    End_Object

    Object oSnoSheet_DD is a cSnoSheetGlblDataDictionary
        Set DDO_Server to oInvhdr_DD
    End_Object

    Object oSShtDtl_DD is a cSShtDtlGlblDataDictionary
        Set Constrain_file to SnoSheet.File_number
        Set DDO_Server to oSnoSheet_DD
    End_Object

    Set Main_DD to oSnoSheet_DD
    Set Server to oSnoSheet_DD

    Set Border_Style to Border_Thick
    Set Size to 261 651
    Set Location to 32 73

    Object oOrder_JobNumber is a cGlblDbForm
        Entry_Item Order.JobNumber
        Set Location to 16 78
        Set Size to 13 54
        Set Label to "JobNumber:"
    End_Object

    Object oCustomer_Name is a cGlblDbForm
        Entry_Item Customer.Name
        Set Location to 17 137
        Set Size to 13 230
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

    Object oLocation_Name is a cGlblDbForm
        Entry_Item Location.Name
        Set Location to 34 136
        Set Size to 13 230
        Set Prompt_Button_Mode to PB_PromptOff
    End_Object

    Object oSnoSheet_SnoSheetIdno is a cGlblDbForm
        Entry_Item SnoSheet.SnoSheetIdno
        Set Location to 64 78
        Set Size to 13 54
        Set Label to "SnoSheetIdno:"
    End_Object

    Object oSnoSheet_Date is a cGlblDbForm
        Entry_Item SnoSheet.Date
        Set Location to 66 448
        Set Size to 13 66
        Set Label to "Date:"
    End_Object

    Object oSnoSheet_WindVel is a cGlblDbForm
        Entry_Item SnoSheet.WindVel
        Set Location to 81 448
        Set Size to 13 66
        Set Label to "WindVel:"
    End_Object

    Object oSnoSheet_WindDir is a cGlblDbForm
        Entry_Item SnoSheet.WindDir
        Set Location to 96 448
        Set Size to 13 66
        Set Label to "WindDir:"
    End_Object

    Object oSnoSheet_Temp is a cGlblDbForm
        Entry_Item SnoSheet.Temp
        Set Location to 111 448
        Set Size to 13 96
        Set Label to "Temp:"
    End_Object

    Object oSnoSheet_SnowAmt is a cGlblDbForm
        Entry_Item SnoSheet.SnowAmt
        Set Location to 126 448
        Set Size to 13 186
        Set Label to "SnowAmt:"
    End_Object

Cd_End_Object
