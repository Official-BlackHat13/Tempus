Use Windows.pkg
Use DFClient.pkg
Use cDbCJGridPromptList.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD
Use dfSelLst.pkg
Use cGlblDbForm.pkg
Use dfTable.pkg

Deferred_View Activate_oOrdersOpen2 for ;
Object oOrdersOpen2 is a dbView
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
        Procedure OnConstrain
            Constrain Order.JobCloseDate le "01/01/1900"
            Constrain Order.WorkType eq "P"
            Constrain Order.MonthlyBilling eq "0"
            Constrain Order.PromiseDate le "01/01/1900"
            Constrain Order.JobOpenDate ge "01/01/2013"
        End_Procedure
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD

    Set Border_Style to Border_Thick
    Set Size to 331 706
    Set Location to 19 101

    Object oDbGrid1 is a dbGrid
        Set Size to 150 385
        Set Location to 17 17
        Set Ordering to 9    
        Begin_Row
            Entry_Item Order.JobNumber
            Entry_Item Order.JobOpenDate
            Entry_Item Customer.Name
            Entry_Item Location.Name
            Entry_Item Order.EventCloseDate
        End_Row

        Set Main_File to Order.File_Number

        Set Form_Width 0 to 30
        Set Header_Label 0 to "Job #"
        Set Form_Width 1 to 50
        Set Header_Label 1 to "Opened"
        Set Form_Width 2 to 120
        Set Header_Label 2 to "Customer"
        Set Form_Width 3 to 120
        Set Header_Label 3 to "Location"    
        Set Form_Width 4 to 50
        Set Header_Label 4 to "Scheduled"
           Set Initial_Row to Fill_From_Bottom
    End_Object

    

    

Cd_End_Object
