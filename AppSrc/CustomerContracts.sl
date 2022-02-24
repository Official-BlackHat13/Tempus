// CustomerContracts.sl
// CustomerContracts Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg
Use cCustomerContractsGlblDataDictionary.dd
Use Customer.DD

Object CustomerContracts_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 487
    Set Label To "CustomerContracts Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Property Integer piCustomerIdno
    Property Date pdJobOpenDate
    Property Boolean pbSelected

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oCustomerContracts_DD is a cCustomerContractsGlblDataDictionary
        Set pbUseDDRelates to True
        Set DDO_Server to oCustomer_DD
        Set Field_Related_FileField Field CustomerContracts.CustomerIdno to File_Field Customer.CustomerIdno

        Procedure OnConstrain
            Forward Send OnConstrain
            If (piCustomerIdno(Self)<>0) Begin
                Constrain CustomerContracts.CustomerIdno eq (piCustomerIdno(Self))
            End
            //Constrain CustomerContracts as (CustomerContracts.StartDate ge (pdJobOpenDate(Self)) and CustomerContracts.ExpiryDate le (pdJobOpenDate(Self)))
        End_Procedure
    End_Object 

    Set Main_DD To oCustomerContracts_DD
    Set Server  To oCustomerContracts_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 477
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "CustomerContracts_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oCustomerContracts_ContractIdno is a cDbCJGridColumn
            Entry_Item CustomerContracts.ContractIdno
            Set piWidth to 72
            Set psCaption to "Contract#"
        End_Object

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 199
            Set psCaption to "Customer"
        End_Object 

        Object oCustomerContracts_DisplayName is a cDbCJGridColumn
            Entry_Item CustomerContracts.DisplayName
            Set piWidth to 281
            Set psCaption to "Contract"
        End_Object 

        Object oCustomerContracts_StartDate is a cDbCJGridColumn
            Entry_Item CustomerContracts.StartDate
            Set piWidth to 112
            Set psCaption to "Start Date"
        End_Object 

        Object oCustomerContracts_ExpiryDate is a cDbCJGridColumn
            Entry_Item CustomerContracts.ExpiryDate
            Set piWidth to 113
            Set psCaption to "Expiry Date"
        End_Object 

        Object oCustomerContracts_TempFlag is a cDbCJGridColumn
            Entry_Item CustomerContracts.TempFlag
            Set piWidth to 90
            Set psCaption to "Temporary?"
        End_Object 

        Object oCustomerContracts_AssignedCount is a cDbCJGridColumn
            Entry_Item CustomerContracts.AssignedCount
            Set piWidth to 36
            Set psCaption to "AssignedCount"
        End_Object


    End_Object 

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 324
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object 

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 378
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object 

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 432
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object 

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

    Function SelectExistingContract Integer iCustomerIdno Date dJobOpenDate Integer ByRef iContractIdno String ByRef sDisplayName String ByRef sFileName Returns Boolean
        Boolean bCancel
        // with non-invoking lists we store and restore the defaults manually
        Send OnStoreDefaults of oSelList
        //
        Set Locate_Mode to CENTER_ON_PANEL
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set piUpdateColumn of oSelList to 0
        //
        If (iCustomerIdno<>0) Begin
            Set piCustomerIdno to iCustomerIdno
            Set pdJobOpenDate to dJobOpenDate
            Send Rebuild_Constraints of oCustomerContracts_DD
        End
        If (iContractIdno<>0) Begin
            Set psSeedValue of oSelList to iContractIdno
        End
        Send Popup_Modal
        //
        Send OnRestoreDefaults of oSelList
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Set pbSelected to True
            Move CustomerContracts.ContractIdno to iContractIdno
            Move (Trim(CustomerContracts.DisplayName)) to sDisplayName
            Move (Trim(CustomerContracts.FileName)) to sFileName
        End
        Else Begin
            Set pbSelected to False
        End
        
        Function_Return (pbSelected(Self))
    End_Function

End_Object // CustomerContracts_sl
