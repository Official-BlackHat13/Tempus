Use Windows.pkg
Use DFClient.pkg
Use cGlblDbForm.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD
Use MastOps.DD
Use Employer.DD
Use Employee.DD
Use Opers.DD
Use Trans.DD
Use dfTable.pkg
Use cCJGrid.pkg
Use cCJGridColumn.pkg

Deferred_View Activate_oJobCostEntry2 for ;
Object oJobCostEntry2 is a dbView
    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oEmployer_DD
    End_Object

    Object oMastOps_DD is a Mastops_DataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oProject_DD is a cProjectDataDictionary
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oTrans_DD is a Trans_DataDictionary
        Set DDO_Server to oOpers_DD
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD
        Set DDO_Server to oEmployee_DD
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD

    Set Border_Style to Border_Thick
    Set Size to 420 674
    Set Location to -4 24
    Set Label to "Pavement Maintenance Job Costs"

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 59 643
        Set Location to 7 13

        Object oOrder_JobNumber is a cGlblDbForm
            Entry_Item Order.JobNumber
            Set Location to 11 67
            Set Size to 13 54
            Set Label to "JobNumber:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oCustomer_Name is a cGlblDbForm
            Entry_Item Customer.Name
            Set Location to 11 131
            Set Size to 13 221
            Set Label to ""
            Set Prompt_Button_Mode to PB_PromptOff
            Set Enabled_State to False
        End_Object

        Object oLocation_Name is a cGlblDbForm
            Entry_Item Location.Name
            Set Location to 28 131
            Set Size to 13 221
            Set Label to "Location:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
            Set Prompt_Button_Mode to PB_PromptOff
            Set Enabled_State to False
        End_Object

        Object oOrder_JobOpenDate is a cGlblDbForm
            Entry_Item Order.JobOpenDate
            Set Location to 11 493
            Set Size to 13 66
            Set Label to "Job Opened:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oOrder_JobCloseDate is a cGlblDbForm
            Entry_Item Order.JobCloseDate
            Set Location to 29 493
            Set Size to 13 66
            Set Label to "Job Closed:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object
    End_Object

    Object oDbGrid2 is a dbGrid
        Set Size to 320 643
        Set Location to 73 15

        Begin_Row
            Entry_Item Employee.LastName
            Entry_Item MastOps.Name
            Entry_Item Trans.StartDate
            Entry_Item Trans.StartTime
            Entry_Item Trans.StopDate
            Entry_Item Trans.StopTime
            Entry_Item Trans.Comment
            Entry_Item Trans.Quantity
        End_Row

        Set Main_File to Trans.File_Number

        Set Server to oTrans_DD

        Set Form_Width 0 to 53
        Set Header_Label 0 to "Employee"
        Set Form_Width 1 to 136
        Set Header_Label 1 to "Operation"
        Set Form_Width 2 to 53
        Set Header_Label 2 to "StartDate"
        Set Form_Width 3 to 50
        Set Header_Label 3 to "StartTime"
        Set Form_Width 4 to 49
        Set Header_Label 4 to "StopDate"
        Set Form_Width 5 to 44
        Set Header_Label 5 to "StopTime"
        Set Form_Width 6 to 199
        Set Header_Label 6 to "Comment"
        Set Form_Width 7 to 49
        Set Header_Label 7 to "Amount"
    End_Object

    

Cd_End_Object
