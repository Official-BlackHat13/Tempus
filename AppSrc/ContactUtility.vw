Use Windows.pkg
Use DFClient.pkg

Use Contact.sl

Open Customer
Open Contact
Open Location
Open Quotehdr
Open Project
Open Order
Open Listlink

Deferred_View Activate_oContactUtility for ;
Object oContactUtility is a dbView

//    Property String psSource
//    Property String psTarget

    Set Border_Style to Border_Thick
    Set Size to 100 360
    Set Location to 9 11
    Set Label to "Contact Utility"

    Object oSourceForm is a Form
        Set Size to 13 50
        Set Location to 20 66
        Set Label to "Source:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOn
        Set Prompt_Object to Contact_sl

//        Procedure Prompt
//            Forward Send Prompt
//            //
//            Set psSource to (trim(Customer.Name))
//        End_Procedure
    End_Object

    Object oSourceTextBox is a TextBox
        Set Size to 50 10
        Set Location to 22 130
        Set Label to "This is the Contact that will be deleted"
    End_Object

    Object oTargetForm is a Form
        Set Size to 13 50
        Set Location to 45 66
        Set Label to "Target:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOn
        Set Prompt_Object to Contact_sl

//        Procedure Prompt
//            Forward Send Prompt
//            //
//            Set psTarget to (trim(Customer.Name))
//        End_Procedure
    End_Object

    Object oTargetTextBox is a TextBox
        Set Size to 50 10
        Set Location to 47 130
        Set Label to "Source records will be combined with this Contact"
    End_Object

    Object oCombineButton is a Button
        Set Location to 70 66
        Set Label to "Combine"
    
        Procedure OnClick
            Boolean bCancel
            Integer iSource iSourceCust iTarget iTargetCust
            String  sSource sTarget
            //
            Get Value of oSourceForm to iSource
            Clear Contact
            Move iSource to Contact.ContactIdno
            Find eq Contact.ContactIdno
            If (not(Found)) Begin
                Send Stop_Box "Invalid Contact ID"
                Procedure_Return
            End
            Move Contact.CustomerIdno     to iSourceCust
            Move (Trim(Contact.LastName)) to sSource
            //
            Get Value of oTargetForm to iTarget
            Clear Contact
            Move iTarget to Contact.ContactIdno
            Find eq Contact.ContactIdno
            If (not(Found)) Begin
                Send Stop_Box "Invalid Contact ID"
                Procedure_Return
            End
            Move Contact.CustomerIdno     to iTargetCust
            Move (Trim(Contact.LastName)) to sTarget
            //
            If (iSourceCust <> iTargetCust) Begin
                Send Stop_Box "The source and target contacts do not belong to the same customer"
                Procedure_Return
            End
            //
            Get Confirm ("Combine" * String(iSource) * sSource * "with" * String(iTarget) * sTarget + "?") to bCancel
            If (bCancel) Procedure_Return
            //
            Send DoCombineContactRecords iSource iTarget
            //
            Set Value of oSourceForm to ""
            Set Value of oTargetForm to ""
            //
            Send Close_Panel
        End_Procedure
    End_Object

    Procedure DoCombineContactRecords Integer iSource Integer iTarget
        Clear Listlink
        Move iSource to Listlink.ContactIdno
        Find ge Listlink.ContactIdno
        While ((Found) and Listlink.ContactIdno = iSource)
            Reread Listlink
            Move iTarget to Listlink.ContactIdno
            SaveRecord Listlink
            Unlock
            Clear Listlink
            Move iSource to Listlink.ContactIdno
            Find ge Listlink.ContactIdno
        Loop
        // Location contacts
        Clear Location
        Move iSource to Location.ContactIdno
        Find ge Location.ContactIdno
        While ((Found) and Location.ContactIdno = iSource)
            Reread Location
            Move iTarget to Location.ContactIdno
            SaveRecord Location
            Unlock
            Clear Location
            Move iSource to Location.ContactIdno
            Find ge Location.ContactIdno
        Loop
        // Location property managers
        Clear Location
        Move iSource to Location.PropmgrIdno
        Find ge Location.PropmgrIdno
        While ((Found) and Location.PropmgrIdno = iSource)
            Reread Location
            Move iTarget to Location.PropmgrIdno
            SaveRecord Location
            Unlock
            Clear Location
            Move iSource to Location.PropmgrIdno
            Find ge Location.PropmgrIdno
        Loop
        //quotehdr
        Clear Quotehdr
        Move iSource to Quotehdr.ContactIdno
        Find ge Quotehdr.ContactIdno
        While ((Found) and Quotehdr.ContactIdno = iSource)
            Reread
            Move iTarget to Quotehdr.ContactIdno
            SaveRecord Quotehdr
            Unlock
            Clear Quotehdr
            Move iSource to Quotehdr.ContactIdno
            Find ge Quotehdr.ContactIdno
        Loop
//        //
//        Clear Opers
//        Move iSource to Opers.LocationIdno
//        Find ge Opers.LocationIdno
//        While ((Found) and Opers.LocationIdno = iSource)
//            Reread
//            Delete Opers
//            Unlock
//            Clear Opers
//            Move iSource to Opers.LocationIdno
//            Find ge Opers.LocationIdno
//        Loop
//        //
//        Clear Order
//        Move iSource to Order.LocationIdno
//        Find ge Order.LocationIdno
//        While ((Found) and Order.LocationIdno = iSource)
//            Reread
//            Move iTarget to Order.LocationIdno
//            SaveRecord Order
//            Unlock
//            //
//            Clear Trans
//            Move Order.JobNumber to Trans.JobNumber
//            Find ge Trans.JobNumber
//            While ((Found) and Trans.JobNumber = Order.JobNumber)
//                Reread
//                Move iTarget to Trans.LocationIdno
//                SaveRecord Trans
//                Unlock
//                Find gt Trans.JobNumber
//            Loop
//            //
//            Clear Invhdr
//            Move Order.JobNumber to Invhdr.JobNumber
//            Find ge Invhdr.JobNumber
//            While ((Found) and Invhdr.JobNumber = Order.JobNumber)
//                Reread
//                Move iTarget to Invhdr.LocationIdno
//                SaveRecord Invhdr
//                Unlock
//                Find gt Invhdr.JobNumber
//            Loop
//            //
//            Clear Order
//            Move iSource to Order.LocationIdno
//            Find ge Order.LocationIdno
//        Loop
        //
        Clear Contact
        Move iSource to Contact.ContactIdno
        Find eq Contact.ContactIdno
        If (Found) Begin
            Reread Contact
            Delete Contact
            Unlock
        End
    End_Procedure

Cd_End_Object
