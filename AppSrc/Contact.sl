// Contact.sl
// Contact Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Contact.DD

Object Contact_sl is a cGlblDbModalPanel
    
    Property Boolean pbSelected
    Property Boolean pbCanceled
    Property Integer piStatus
    Property RowID   priContact
    Property Integer piContacIdno
    Property Boolean pbContacIdno
    Property Integer piCustIdno
    
    Set Location to 5 5
    Set Size to 134 306
    Set Label To "Contact Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object 

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server to oCustomer_DD
        
        Procedure OnConstrain
            If (piCustIdno(Self)<>0) Begin
                Constrain Contact.CustomerIdno eq (piCustIdno(Self))
            End            
            //Status
            If (not(Checked_State(oStatusActiveCheckBox(Self)))) Constrain Contact.Status ne "A"
            If (not(Checked_State(oStatusInactiveCheckBox(Self)))) Constrain Contact.Status ne "I"
        End_Procedure
    End_Object 

    Set Main_DD To oContact_DD
    Set Server  To oContact_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 99 296
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Contact_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oContact_ContactIdno is a cDbCJGridColumn
            Entry_Item Contact.ContactIdno
            Set piWidth to 73
            Set psCaption to "ContactIdno"

            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                //Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                String sStatus
                Get RowValue of oContact_Status iRow to sStatus
                If (sStatus="I") Begin
                    Set ComForeColor of hoGridItemMetrics to clRed
                End 
            End_Procedure
        End_Object 

        Object oContact_LastName is a cDbCJGridColumn
            Entry_Item Contact.LastName
            Set piWidth to 146
            Set psCaption to "Last Name"

            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                //Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                String sStatus
                Get RowValue of oContact_Status iRow to sStatus
                If (sStatus="I") Begin
                    Set ComForeColor of hoGridItemMetrics to clRed
                End 
            End_Procedure
        End_Object 

        Object oContact_FirstName is a cDbCJGridColumn
            Entry_Item Contact.FirstName
            Set piWidth to 148
            Set psCaption to "First Name"

            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                //Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                String sStatus
                Get RowValue of oContact_Status iRow to sStatus
                If (sStatus="I") Begin
                    Set ComForeColor of hoGridItemMetrics to clRed
                End 
            End_Procedure
        End_Object 

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 151
            Set psCaption to "Customer"

            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                //Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                String sStatus
                Get RowValue of oContact_Status iRow to sStatus
                If (sStatus="I") Begin
                    Set ComForeColor of hoGridItemMetrics to clRed
                End 
            End_Procedure
        End_Object 

        Object oContact_Status is a cDbCJGridColumn
            Entry_Item Contact.Status
            Set piWidth to 36
            Set psCaption to "Status"
            Set pbComboButton to True
            Set pbVisible to False

            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                //Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
                String sStatus
                Get RowValue of oContact_Status iRow to sStatus
                If (sStatus="I") Begin
                    Set ComForeColor of hoGridItemMetrics to clRed
                End 
            End_Procedure
        End_Object


    End_Object 

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 143
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object 

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 197
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object 

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 251
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object 

    Object oStatusGroup is a Group
        Set Size to 25 93
        Set Location to 105 5
        Set Label to 'Status'

        Object oStatusActiveCheckBox is a CheckBox
            Set Size to 10 38
            Set Location to 11 12
            Set Label to 'Active'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oContact_DD
                Send MovetoFirstRow of oSelList
            End_Procedure
        End_Object

        Object oStatusInactiveCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 11 49
            Set Label to 'Inactive'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oContact_DD
                Send MovetoFirstRow of oSelList
            End_Procedure
        
        End_Object
    End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

    Function IsSelectedContact RowID ByRef riContact RowID ByRef riCustomer Returns Boolean
        Boolean bSelected
        Handle  hoServer
        //
        Get Server to hoServer
        //
        Send Clear_All of hoServer
        //
        If      (not(IsNullRowId(riContact))) Begin
            Send FindByRowId of hoServer Contact.File_Number riContact
        End
        Else If (not(IsNullRowId(riCustomer))) Begin
            Send FindByRowId of hoServer Customer.File_Number riCustomer
        End
        //
        Set pbSelected                       to False
        //Set Move_Value_Out_State of oSelList to False
        //
        Send Popup
        //
        //Set Move_Value_Out_State of oSelList to True
        Get pbSelected                       to bSelected
        Get priContact                       to riContact
        //
        Function_Return bSelected
    End_Function

    Function SelectContact Integer iCustomerIdno Integer ByRef iContactIdno Returns Boolean
        Integer iMode
        Boolean bCancel
        //
        // with non-invoking lists we store and restore the defaults manually
        Send OnStoreDefaults of oSelList
        //
        Set Locate_Mode to CENTER_ON_PANEL
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set piUpdateColumn of oSelList to 0
        // Build constraints if needed
        If (iCustomerIdno<>0) Begin
            Set piCustIdno to iCustomerIdno
            Send Rebuild_Constraints of oContact_DD            
        End
        // Move to value already selected
        If (iContactIdno<>0) Begin
            Set psSeedValue of oSelList to iContactIdno
        End
        //
        Send Popup_Modal
        //
        Send OnRestoreDefaults of oSelList
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Set pbSelected to True
            Move Contact.ContactIdno to iContactIdno
        End
        Else Begin
            Set pbSelected to False
        End
        
        Function_Return (pbSelected(Self))
    End_Function

End_Object // Contact_sl
