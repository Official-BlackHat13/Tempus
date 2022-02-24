Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Location.DD
Use Opers.DD
Use DFEntry.pkg

Deferred_View Activate_otest1 for ;
Object otest1 is a dbView
    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oLocation_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Set Main_DD to oOpers_DD
    Set Server to oOpers_DD

    Set Border_Style to Border_Thick
    Set Size to 200 300
    Set Location to 69 313

    Object oCustomer_Customer_idno is a dbForm
        Entry_Item Customer.Customer_idno
        Set Location to 25 90
        Set Size to 13 42
        Set Label to "Customer idno:"
    End_Object

    Object oLocation_Location_idno is a dbForm
        Entry_Item Location.Location_idno
        Set Location to 44 90
        Set Size to 13 42
        Set Label to "Location idno:"
    End_Object

    Object oOpers_Opers_idno is a dbForm
        Entry_Item Opers.Opers_idno
        Set Location to 62 90
        Set Size to 13 42
        Set Label to "Opers idno:"
    End_Object

Cd_End_Object
