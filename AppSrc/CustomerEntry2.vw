Use Windows.pkg
Use DFClient.pkg
Use Areas.DD
Use Customer.DD
Use Location.DD
Use cGlblDbForm.pkg

Deferred_View Activate_oCustomerEntry2 for ;
Object oCustomerEntry2 is a dbView
    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set Constrain_file to Areas.File_number
        Set Constrain_File to Customer.File_Number
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Set Main_DD to oAreas_DD
    Set Server to oAreas_DD

    Set Border_Style to Border_Thick
    Set Size to 200 451
    Set Location to 2 2

    Object oCustomer_CustomerIdno is a cGlblDbForm
        Entry_Item Customer.CustomerIdno

        Set Server to oLocation_DD
        Set Location to 17 62
        Set Size to 13 54
        Set Label to "CustomerIdno:"
    End_Object

    Object oCustomer_Name is a cGlblDbForm
        Entry_Item Customer.Name

        Set Server to oLocation_DD
        Set Location to 36 62
        Set Size to 13 366
        Set Label to "Name:"
    End_Object

    Object oLocation_LocationIdno is a cGlblDbForm
        Entry_Item Location.LocationIdno

        Set Server to oLocation_DD
        Set Location to 86 64
        Set Size to 13 54
        Set Label to "LocationIdno:"
    End_Object

    Object oLocation_Name is a cGlblDbForm
        Entry_Item Location.Name

        Set Server to oLocation_DD
        Set Location to 112 64
        Set Size to 13 246
        Set Label to "Name:"
    End_Object

Cd_End_Object
