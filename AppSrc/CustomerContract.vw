// D:\Development Projects\VDF19.1 Workspaces\Tempus\AppSrc\CustomerContract.vw
// CustomerContract
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use Customer.DD
Use cCustomerContractsGlblDataDictionary.dd
Use cDbCJGrid.pkg
Use Windows.pkg
Use cdbCJGridColumn.pkg

Use ContractDetails.dg

ACTIVATE_VIEW Activate_oCustomerContract FOR oCustomerContract
Object oCustomerContract is a cGlblDbView
    Set Location to 5 5
    Set Size to 294 601
    Set Label To "CustomerContract"
    Set Border_Style to Border_Thick


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object 

    Object oCustomerContracts_DD is a cCustomerContractsGlblDataDictionary
        Set DDO_Server To oCustomer_DD
    End_Object 

    Set Main_DD To oCustomerContracts_DD
    Set Server  To oCustomerContracts_DD

    Object oCustomerContractDbCJGrid is a cDbCJGrid
        Set Size to 279 584
        Set Location to 7 10
        Set peAnchors to anAll
        Set pbAllowEdit to False
        Set pbEditOnTyping to False
        Set pbReadOnly to True

        Object oCustomerContracts_ContractIdno is a cDbCJGridColumn
            Entry_Item CustomerContracts.ContractIdno
            Set piWidth to 99
            Set psCaption to "ContractIdno"
        End_Object

        Object oCustomerContracts_DisplayName is a cDbCJGridColumn
            Entry_Item CustomerContracts.DisplayName
            Set piWidth to 230
            Set psCaption to "Display Name"
        End_Object

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 249
            Set psCaption to "Customer"
        End_Object

        Object oCustomerContracts_FileName is a cDbCJGridColumn
            Entry_Item CustomerContracts.FileName
            Set piWidth to 200
            Set psCaption to "File Name"
            Set pbVisible to False
            
        End_Object

        Object oCustomerContracts_StartDate is a cDbCJGridColumn
            Entry_Item CustomerContracts.StartDate
            Set piWidth to 105
            Set psCaption to "Start Date"
        End_Object

        Object oCustomerContracts_ExpiryDate is a cDbCJGridColumn
            Entry_Item CustomerContracts.ExpiryDate
            Set piWidth to 95
            Set psCaption to "Expiry Date"
        End_Object

        Object oCustomerContracts_TempFlag is a cDbCJGridColumn
            Entry_Item CustomerContracts.TempFlag
            Set piWidth to 85
            Set psCaption to "Temporary"
        End_Object

        Object oCustomerContracts_AssignedCount is a cDbCJGridColumn
            Entry_Item CustomerContracts.AssignedCount
            Set piWidth to 111
            Set psCaption to "Assigned"
        End_Object
    End_Object


    Function CreateRecord Integer iCustIdno String sFileName String sNewFileName Integer ByRef iContractIdno Returns Boolean
        Boolean bFail bIsTemp bSuccess
        Date dContractStartDate dContractExpiryDate
        Handle hoDD
        //
        Get EnterContractDetails of oContractDetails (&dContractStartDate) (&dContractExpiryDate) (&bIsTemp) to bSuccess
        If (not(bSuccess)) Function_Return False //without complete contract details processing is discontinued
        //
        Move oCustomerContracts_DD to hoDD
        Send Clear of hoDD
        // Find Customer
        Move iCustIdno to Customer.CustomerIdno
        Send Request_Find of hoDD EQ Customer.File_Number 1
        // Contract Details
        //Set Field_Changed_Value of hoDD Field CustomerContracts.CustomerIdno    to iCustIdno
        Set Field_Changed_Value of hoDD Field CustomerContracts.DisplayName     to sFileName
        Set Field_Changed_Value of hoDD Field CustomerContracts.FileName        to sNewFileName
        Set Field_Changed_Value of hoDD Field CustomerContracts.StartDate       to dContractStartDate
        Set Field_Changed_Value of hoDD Field CustomerContracts.ExpiryDate      to dContractExpiryDate
        Set Field_Changed_Value of hoDD Field CustomerContracts.TempFlag        to bIsTemp
        Set Field_Changed_Value of hoDD Field CustomerContracts.AssignedCount   to 1
        //
        Get Request_Validate of hoDD                                            to bFail
        If (not(bFail)) Begin
            Send Request_Save of hoDD
        End
        Else Begin
            Send Stop_Box "Processing stopped at Customer Contract Validation" "Processing Error"
            Procedure_Return
        End
        Get Field_Current_Value of hoDD Field CustomerContracts.ContractIdno to iContractIdno
        Function_Return (not(bFail))
    End_Function
    
    Function AssignRecordUpdate Integer iContractIdno Returns Boolean
        Handle hoDD
        Boolean bFail
        //
        Move oCustomerContracts_DD to hoDD
        Send Clear of hoDD
        Move iContractIdno to CustomerContracts.ContractIdno
        Send Request_Find of hoDD EQ CustomerContracts.File_Number 1
        If ((Found) and CustomerContracts.ContractIdno = iContractIdno) Begin
            Integer iContractAssignCount
            Get Field_Current_Value of hoDD Field CustomerContracts.AssignedCount to iContractAssignCount
            Increment iContractAssignCount
            Set Field_Current_Value of hoDD Field CustomerContracts.AssignedCount to iContractAssignCount
            Get Request_Validate of hoDD to bFail
            If (not(bFail)) Begin
                Send Request_Save of hoDD
            End
            Else Begin
                Send Stop_Box "Could not validate CustomerContract record." "Processing Error"
                Function_Return (bFail)
            End
        End
        Function_Return (not(bFail))
    End_Function
    
    Function DeleteRecord Returns Boolean
    End_Function


End_Object 
