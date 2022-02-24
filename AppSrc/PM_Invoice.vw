Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use cSnowrepDataDictionary.dd
Use Contact.DD
Use cQuotehdrDataDictionary.dd
Use MastOps.DD
Use cQuotedtlDataDictionary.dd
Use cGlblDbForm.pkg

Deferred_View Activate_oPM_Invoice for ;
Object oPM_Invoice is a dbView
    Object oMastOps_DD is a Mastops_DataDictionary
    End_Object

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesRep_DD
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oContact_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oQuotedtl_DD is a cQuotedtlDataDictionary
        Set DDO_Server to oMastOps_DD
        Set Constrain_file to Quotehdr.File_number
        Set DDO_Server to oQuotehdr_DD
    End_Object

    Set Main_DD to oQuotehdr_DD
    Set Server to oQuotehdr_DD

    Set Border_Style to Border_Thick
    Set Size to 369 620
    Set Location to 26 77

    Object oQuotehdr_QuotehdrID is a cGlblDbForm
        Entry_Item Quotehdr.QuotehdrID
        Set Location to 31 82
        Set Size to 13 54
        Set Label to "QuotehdrID:"
    End_Object

    Object oCustomer_CustomerIdno is a cGlblDbForm
        Entry_Item Customer.CustomerIdno

        Set Server to oContact_DD
        Set Location to 47 82
        Set Size to 13 54
        Set Label to "CustomerIdno:"
    End_Object

    Object oCustomer_Name is a cGlblDbForm
        Entry_Item Customer.Name

        Set Server to oContact_DD
        Set Location to 46 250
        Set Size to 13 366
        Set Label to "Name:"
    End_Object

    Object oLocation_LocationIdno is a cGlblDbForm
        Entry_Item Location.LocationIdno

        Set Server to oLocation_DD
        Set Location to 64 82
        Set Size to 13 54
        Set Label to "LocationIdno:"
    End_Object

Cd_End_Object
