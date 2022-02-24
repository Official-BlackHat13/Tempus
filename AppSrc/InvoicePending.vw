Use Windows.pkg
Use DFClient.pkg
Use dfSelLst.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD

Deferred_View Activate_oInvoicePending for ;
Object oInvoicePending is a dbView
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
           Constrain Order.WorkType eq "P"
           Constrain Order.OpsCostOK gt "01/01/1900"
           Constrain Order.JobCloseDate lt "01/01/1900"
        End_Procedure
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD

    Set Border_Style to Border_Thick
    Set Size to 340 517
    Set Location to 2 2

    Object oDbList1 is a cGlblDbList
        Set Size to 100 443
        Set Location to 35 33
   
        Begin_Row
            Entry_Item Order.JobNumber
            Entry_Item Customer.Name
            Entry_Item Location.Name
        End_Row

        Set Main_File to Order.File_Number

        Set Form_Width 0 to 48
        Set Header_Label 0 to "JobNumber"
        Set Form_Width 1 to 155
        Set Header_Label 1 to "Customer"
        Set Form_Width 2 to 240
        Set Header_Label 2 to "Location"
    End_Object

Cd_End_Object
