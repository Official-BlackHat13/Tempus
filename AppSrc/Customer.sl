// Customer.sl
// Customer Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD

Object Customer_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 162 290
    Set Label To "Customer Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Property Boolean pbCanceled
    Property Boolean pbSelected
    Property Integer piSelected
    Property Boolean pbCustIdno
    Property Integer piCustIdno

    Object oCustomer_DD is a Customer_DataDictionary
        Procedure OnConstrain
            //Status
            If (not(Checked_State(oActiveCustCheckBox(Self)))) Constrain Customer.Status ne "A"
            If (not(Checked_State(oInactiveCustCheckBox(Self)))) Constrain Customer.Status ne "I"
        End_Procedure
    End_Object // oCustomer_DD

    Set Main_DD To oCustomer_DD
    Set Server  To oCustomer_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 126 280
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Customer_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oCustomer_CustomerIdno is a cDbCJGridColumn
            Entry_Item Customer.CustomerIdno
            Set piWidth to 57
            Set psCaption to "Cust #"
        End_Object // oCustomer_CustomerIdno

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 214
            Set psCaption to "Name"
        End_Object // oCustomer_Name

        Object oCustomer_City is a cDbCJGridColumn
            Entry_Item Customer.City
            Set piWidth to 153
            Set psCaption to "City"
        End_Object // oCustomer_City

        Object oCustomer_Zip is a cDbCJGridColumn
            Entry_Item Customer.Zip
            Set piWidth to 66
            Set psCaption to "Zip"
        End_Object // oCustomer_Zip


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 141 127
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 141 181
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 141 235
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


//    Function IsSelectedCustomer Integer iCustIdno Returns Integer
//        Integer iMode
//        //
//        Get Locate_Mode to iMode
//        Set Locate_Mode to CENTER_ON_PANEL
//        //
//        Set pbCustIdno to True
//        Set piCustIdno to iCustIdno
//
//        
//        //
//        Set Constrain_File       of oCustomer_DD to 0
//        Send Rebuild_Constraints of oCustomer_DD
//        //
//        Set Move_Value_Out_State of oSelList to False
//        Send Beginning_of_Data   of oSelList
//        //
//        Send Popup_Modal
//        //
//        Set Move_Value_Out_State of oSelList to True
//        //
//        //Set Constrain_File       of oLocation_DD to Customer.File_Number
//        //Send Rebuild_Constraints of oLocation_DD
//        //
//        Set pbCustIdno     to False
//        Set Locate_Mode to iMode
//        Function_Return (piCustIdno(Self))
//    End_Function
    
    Function IsSelectedCustomer Integer ByRef iCustIdno Returns Boolean
        Boolean bCancel
        String[] SelectionValues

        // with non-invoking lists we store and restore the defaults manually
        Send OnStoreDefaults of oSelList
        //
        Set Locate_Mode to CENTER_ON_PANEL
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set piUpdateColumn of oSelList to 0
        Set psSeedValue of oSelList to iCustIdno
        //
        Send Popup
        //
        Send OnRestoreDefaults of oSelList
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Get SelectedColumnValues of oSelList 0 to SelectionValues
            If (SizeOfArray(SelectionValues)) Begin
                Move SelectionValues[0] to iCustIdno
                Function_Return True
            End
        End
        Function_Return False
    End_Function

    Object oStatusGroup is a Group
        Set Size to 25 93
        Set Location to 134 6
        Set Label to 'Status'
        Set peAnchors to anBottomLeft

        Object oActiveCustCheckBox is a CheckBox
            Set Size to 10 38
            Set Location to 11 12
            Set Label to 'Active'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oCustomer_DD
                Send MovetoFirstRow of oSelList
            End_Procedure
        End_Object

        Object oInactiveCustCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 11 49
            Set Label to 'Inactive'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oCustomer_DD
                Send MovetoFirstRow of oSelList
            End_Procedure
        
        End_Object
    End_Object

    Procedure Prompt_Callback Handle hoPrompt
        Forward Send Prompt_Callback hoPrompt
    End_Procedure


End_Object // Customer_sl
