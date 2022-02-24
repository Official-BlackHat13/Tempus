Use Windows.pkg
Use DFClient.pkg
Use Employer.DD
Use Employee.DD
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD
Use MastOps.DD
Use Opers.DD
Use Trans.DD
Use cDbCJGrid.pkg
Use cGlblDbForm.pkg

Deferred_View Activate_oSubPerTimeEntry for ;
Object oSubPerTimeEntry is a dbView
    Object oMastOps_DD is a Mastops_DataDictionary
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
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oEmployer_DD
        Set Constrain_File to Employer.File_Number
    End_Object

    Object oTrans_DD is a Trans_DataDictionary
        Set DDO_Server to oOpers_DD
        Set DDO_Server to oOrder_DD
        Set DDO_Server to oEmployee_DD
    End_Object

    Set Main_DD to oTrans_DD
    Set Server to oTrans_DD

    Set Border_Style to Border_Thick
    Set Size to 200 533
    Set Location to 74 183
    
    Object oEmployer_EmployerIdno is a cGlblDbForm
        Entry_Item Employer.EmployerIdno
        Set Location to 33 96
        Set Size to 13 54
        Set Label to "Employer#/Name:"
    End_Object

    Object oEmployer_Name is a cGlblDbForm
        Entry_Item Employer.Name
        Set Location to 32 157
        Set Size to 13 189
        
    End_Object

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 100 420
        Set Location to 68 61

        Object oTrans_EmployeeIdno is a cDbCJGridColumn
            Entry_Item Employee.EmployeeIdno
            Set piWidth to 30
            Set psCaption to "EmployeeIdno"
        End_Object

        Object oEmployee_LastName is a cDbCJGridColumn
            Entry_Item Employee.LastName
            Set piWidth to 50
            Set psCaption to "Last Name"
        End_Object
        
        Object oTrans_StartDate is a cDbCJGridColumn
            Entry_Item Trans.StartDate
            Set piWidth to 30
            Set psCaption to "Start Date"
        End_Object

        Object oTrans_Quantity is a cDbCJGridColumn
            Entry_Item Trans.Quantity
            Set piWidth to 70
            Set psCaption to "Quantity"
        End_Object

        Object oTrans_Comment is a cDbCJGridColumn
            Entry_Item Trans.Comment
            Set piWidth to 100
            Set psCaption to "Comment"
        End_Object
    End_Object

    Object oTrans_JobNumber is a cGlblDbForm
        Entry_Item Order.JobNumber
        Set Location to 17 96
        Set Size to 13 54
        Set Label to "JobNumber:"
    End_Object

    

Cd_End_Object
