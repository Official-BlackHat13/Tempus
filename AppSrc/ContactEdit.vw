Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use SalesRep.DD
Use cSnowrepDataDictionary.dd
Use Contact.DD
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use dfEnChk.pkg
Use cDbCJGridPromptList.pkg

Deferred_View Activate_oContactEdit for ;
Object oContactEdit is a dbView
    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oContact_DD is a Contact_DataDictionary
        Set Constrain_File to SalesRep.File_Number
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Set Main_DD to oContact_DD
    Set Server to oContact_DD

    Set Border_Style to Border_Thick
    Set Size to 428 679
    Set Location to 1 110

    Object oContact_RepIdno is a cGlblDbForm
        Entry_Item SalesRep.RepIdno
        Set Location to 11 71
        Set Size to 13 54
        Set Label to "RepIdno:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 370 615
        Set Location to 36 26
        Set Ordering to 1

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 226
            Set psCaption to "Customer"
        End_Object
//        Set pbAutoServer to True
    
        Object oContact_LastName is a cDbCJGridColumn
            Entry_Item Contact.LastName
            Set piWidth to 118
            Set psCaption to "Last Name"
        End_Object

        Object oContact_FirstName is a cDbCJGridColumn
            Entry_Item Contact.FirstName
            Set piWidth to 119
            Set psCaption to "First Name"
        End_Object

        Object oContact_Phone1 is a cDbCJGridColumn
            Entry_Item Contact.Phone1
            Set piWidth to 101
            Set psCaption to "Phone"
        End_Object

        Object oContact_EmailAddress is a cDbCJGridColumn
            Entry_Item Contact.EmailAddress
            Set piWidth to 242
            Set psCaption to "EmailAddress"
        End_Object

        Object oContact_Status is a cDbCJGridColumn
            Entry_Item Contact.Status
            Set piWidth to 77
            Set psCaption to "Status"
            Set pbComboButton to True
        End_Object

       
    End_Object

    

Cd_End_Object
