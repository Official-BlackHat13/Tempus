Use Windows.pkg
Use DFClient.pkg
Use Customer.sl
Open Customer
Open Contact
Open Location
Open Quotehdr
Open Opers
Open Project
Open Order
Open Trans
Open Invhdr
Deferred_View Activate_oCustomerUtility for ;
Object oCustomerUtility is a dbView

//    Property String psSource
//    Property String psTarget

    Set Border_Style to Border_Thick
    Set Size to 100 360
    Set Location to 9 11
    Set Label to "Organization Utility"

    Object oSourceForm is a Form
        Set Size to 13 50
        Set Location to 20 66
        Set Label to "Source:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOn
        Set Prompt_Object to Customer_SL

//        Procedure Prompt
//            Forward Send Prompt
//            //
//            Set psSource to (trim(Customer.Name))
//        End_Procedure
    End_Object

    Object oSourceTextBox is a TextBox
        Set Size to 50 10
        Set Location to 22 130
        Set Label to "This is the Organization that will be deleted"
    End_Object

    Object oTargetForm is a Form
        Set Size to 13 50
        Set Location to 45 66
        Set Label to "Target:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOn
        Set Prompt_Object to Customer_SL

//        Procedure Prompt
//            Forward Send Prompt
//            //
//            Set psTarget to (trim(Customer.Name))
//        End_Procedure
    End_Object

    Object oTargetTextBox is a TextBox
        Set Size to 50 10
        Set Location to 47 130
        Set Label to "Source records will be combined with this Organization"
    End_Object

    Object oCombineButton is a Button
        Set Location to 70 66
        Set Label to "Combine"
    
        Procedure OnClick
            Boolean bCancel
            Integer iSource iTarget
            String  sSource sTarget
            //
            Get Value of oSourceForm to iSource
            Clear Customer
            Move iSource to Customer.CustomerIdno
            Find eq Customer.CustomerIdno
            Move (Trim(Customer.Name)) to sSource
//            Get psSource             to sSource
            Get Value of oTargetForm to iTarget
            Clear Customer
            Move iTarget to Customer.CustomerIdno
            Find eq Customer.CustomerIdno
            Move (Trim(Customer.Name)) to sTarget
//            Get psTarget             to sTarget
            //
            Get Confirm ("Combine" * String(iSource) * sSource * "with" * String(iTarget) * sTarget + "?") to bCancel
            If (bCancel) Procedure_Return
            //
            Send DoCombineCustomerRecords iSource iTarget
            //
            Set Value of oSourceForm to ""
            Set Value of oTargetForm to ""
            //
            Send Close_Panel
        End_Procedure
    End_Object

    Procedure DoCombineCustomerRecords Integer iCustomerSource Integer iCustomerTarget
        //
        Clear Contact
        Move iCustomerSource to Contact.CustomerIdno
        Find ge Contact.CustomerIdno
        While ((Found) and Contact.CustomerIdno = iCustomerSource)
            Reread
            Move iCustomerTarget to Contact.CustomerIdno
            SaveRecord Contact
            Unlock
            Clear Contact
            Move iCustomerSource to Contact.CustomerIdno
            Find ge Contact.CustomerIdno
        Loop
        //
        Clear Location
        Move iCustomerSource to Location.CustomerIdno
        Find ge Location.CustomerIdno
        While ((Found) and Location.CustomerIdno = iCustomerSource)
            Clear Quotehdr
            Move Location.LocationIdno to Quotehdr.LocationIdno
            Find ge Quotehdr.LocationIdno
            While ((Found) and Quotehdr.LocationIdno = Location.LocationIdno)
                Reread
                Move iCustomerTarget to Quotehdr.CustomerIdno
                SaveRecord Quotehdr
                Unlock
                Find gt Quotehdr.LocationIdno
            Loop
            //
//            Clear Project
//            Move Location.LocationIdno to Project.LocationIdno
//            Find ge Project.LocationIdno
//            While ((Found) and Project.LocationIdno = Location.LocationIdno)
//                Reread
//                Move iCustomerTarget to Project.CustomerIdno
//                SaveRecord Project
//                Unlock
//                Find gt Project.LocationIdno
//            Loop
            //
            Clear Opers
            Move Location.LocationIdno to Opers.LocationIdno
            Find ge Opers.LocationIdno
            While ((Found) and Opers.LocationIdno = Location.LocationIdno)
                Reread
                Move iCustomerTarget to Opers.CustomerIdno
                SaveRecord Opers
                Unlock
                Find gt Opers.LocationIdno
            Loop
            //
            Clear Order
            Move Location.LocationIdno to Order.LocationIdno
            Find ge Order.LocationIdno
            While ((Found) and Order.LocationIdno = Location.LocationIdno)
                Reread
                Move iCustomerTarget to Order.CustomerIdno
                SaveRecord Order
                Unlock
                //
                Clear Trans
                Move Order.JobNumber to Trans.JobNumber
                Find ge Trans.JobNumber
                While ((Found) and Trans.JobNumber = Order.JobNumber)
                    Reread
                    Move iCustomerTarget to Trans.CustomerIdno
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
                    Move iCustomerTarget to Invhdr.CustomerIdno
                    SaveRecord Invhdr
                    Unlock
                    Find gt Invhdr.JobNumber
                Loop
                //
                Find gt Order.LocationIdno
            Loop
            //
            Reread
            Move iCustomerTarget to Location.CustomerIdno
            SaveRecord Location
            Unlock
            //
            Clear Location
            Move iCustomerSource to Location.CustomerIdno
            Find ge Location.CustomerIdno
        Loop
        Clear Customer
        Move iCustomerSource to Customer.CustomerIdno
        Find eq Customer.CustomerIdno
        If (Found) Begin
            Reread
            Delete Customer
            Unlock
        End
    End_Procedure

Cd_End_Object
