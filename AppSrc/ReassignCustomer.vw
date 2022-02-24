Use Windows.pkg
Use DFClient.pkg
Use for_all.pkg

Use Customer.sl

Open Location
Open Customer
Open Contact
Open Quotehdr
Open Order
Open Trans
Open Invhdr
Open PMInvHdr

Deferred_View Activate_oReassignCustomer for ;
Object oReassignCustomer is a dbView


    Set Border_Style to Border_Thick
    Set Size to 100 171
    Set Location to 8 9
    Set Label to "Reassign Customer Data Utility"

    Object oOldCustomerForm is a Form
        Set Size to 13 50
        Set Location to 20 66
        Set Label to "From Customer:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOn
        Set Prompt_Object to Customer_sl
    End_Object

    Object oNewCustomerForm is a Form
        Set Size to 13 50
        Set Location to 45 66
        Set Label to "To Customer:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOn
        Set Prompt_Object to Customer_sl
    End_Object

    Object oReassignButton is a Button
        Set Size to 14 95
        Set Location to 70 21
        Set Label to "Reassign Customer Data"
    
        Procedure OnClick
            Boolean bCancel
            Integer iOldCust iNewCust
            String  sOldCust sNewCust
            //
            Get Value of oOldCustomerForm to iOldCust
            Clear Customer
            Move iOldCust to Customer.CustomerIdno
            Find eq customer.CustomerIdno
            If (not(Found)) Begin
                Send Stop_Box "Invalid Customer"
                Procedure_Return
            End
            Move (Trim(Customer.Name)) to sOldCust
            //
            Get Value of oNewCustomerForm to iNewCust
            Clear Customer
            Move iNewCust to Customer.CustomerIdno
            Find eq Customer.CustomerIdno
            If (not(Found)) Begin
                Send Stop_Box "Invalid Customer"
                Procedure_Return
            End
            Move (Trim(Customer.Name)) to sNewCust
            //
            If (iOldCust = iNewCust) Begin
                Send Stop_Box "Can't reassign data to same customer!" "Lack of attention Error"
                Procedure_Return
            End
            Get Confirm ("Reassign data belonging to" * String(iOldCust) * sOldCust * "to" * String(iNewCust) * sNewCust + "?") to bCancel
            If (bCancel) Procedure_Return
            //
            Send DoReassignCustomerData iOldCust iNewCust
            Send Close_Panel
        End_Procedure
    End_Object

    Procedure DoReassignCustomerData Integer iOldCust Integer iNewCust
          //
        /////////////////
        Begin_Transaction
        /////////////////
            //
            For_All Location by 2 as que
                Constrain Location.CustomerIdno eq iOldCust
                do
                Move iNewCust to Location.CustomerIdno
                SaveRecord Location
            End_For_All
            //
            For_All Contact by 1 as que
                Constrain Contact.CustomerIdno eq iOldCust
                do
                Move iNewCust to Contact.CustomerIdno
                SaveRecord Contact
            End_For_All
            //
            For_All Quotehdr  by 7 as que
                Constrain Quotehdr.CustomerIdno eq iOldCust
                do
                Move iNewCust to Quotehdr.CustomerIdno
                SaveRecord Quotehdr
            End_For_All
            //
            For_All Order by 3 as que
                Constrain Order.CustomerIdno eq iOldCust
                do
                Move iNewCust to Order.CustomerIdno
                SaveRecord Order
                //
                Clear Trans
                Move Order.JobNumber to Trans.JobNumber
                Find ge Trans.JobNumber
                While ((Found) and Trans.JobNumber = Order.JobNumber)
                    Reread
                    Move iNewCust to Trans.CustomerIdno
                    SaveRecord Trans
                    Unlock
                    Find gt Trans.JobNumber
                Loop
                //
                Clear Invhdr
                Move Order.JobNumber to Invhdr.JobNumber
                Find ge Invhdr.JobNumber
                While ((Found) and Invhdr.JobNumber = Order.JobNumber)
                    Reread
                    Move iNewCust to Invhdr.CustomerIdno
                    SaveRecord Invhdr
                    Unlock
                    Find gt Invhdr.JobNumber
                Loop
                //
                Clear pminvhdr
                Move Order.JobNumber to pminvhdr.JobNumber
                Find ge pminvhdr.JobNumber
                While ((Found) and PMInvhdr.JobNumber = Order.JobNumber)
                    Reread
                    Move iNewCust to PMInvhdr.CustomerIdno
                    SaveRecord PMInvhdr
                    Unlock
                    Find gt PMInvhdr.JobNumber
                Loop
                //
            End_For_All
            //
        ///////////////
        End_Transaction
        ///////////////

    End_Procedure

Cd_End_Object
