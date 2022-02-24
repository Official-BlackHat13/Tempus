// SalesRep.sl
// SalesRep Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use SalesRep.DD

Object SalesRep_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 185 285
    Set Label To "SalesRep Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Property Boolean pbCanceled
    Property Boolean pbSelected
    Property Integer piSelected
    Property Integer piStatus
    Property Integer piIdno

    Property RowID   priContact
    Property Integer piContacIdno
    Property Boolean pbContacIdno

    Object oSalesRep_DD is a Salesrep_DataDictionary
        Set DDO_Server to oSalesrep_DD
        
        Procedure OnConstrain
            //Status
            If (not(Checked_State(oActiveSlsRepCheckBox(Self)))) Constrain SalesRep.Status ne "A"
            If (not(Checked_State(oInactiveSlsRepCheckBox(Self)))) Constrain SalesRep.Status ne "I"
        End_Procedure
    End_Object // oSalesRep_DD

    Set Main_DD To oSalesRep_DD
    Set Server  To oSalesRep_DD

    Object oSelList is a cDbCJGridPromptList
        Set Size to 145 275
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "SalesRep_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oSalesRep_RepIdno is a cDbCJGridColumn
            Entry_Item SalesRep.RepIdno
            Set piWidth to 80
            Set psCaption to "RepIdno"
        End_Object // oSalesRep_RepIdno

        Object oSalesRep_LastName is a cDbCJGridColumn
            Entry_Item SalesRep.LastName
            Set piWidth to 171
            Set psCaption to "Last Name"
        End_Object // oSalesRep_LastName

        Object oSalesRep_FirstName is a cDbCJGridColumn
            Entry_Item SalesRep.FirstName
            Set piWidth to 169
            Set psCaption to "First Name"
        End_Object // oSalesRep_FirstName

        Object oSalesRep_Status is a cDbCJGridColumn
            Entry_Item SalesRep.Status
            Set piWidth to 61
            Set psCaption to "Status"
            Set pbComboButton to True
        End_Object


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 166 122
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 166 176
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 166 230
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn



    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

    Function IsSelectedSalesRep Integer ByRef iRepIdno String ByRef sRepName Returns Boolean
        Boolean bCancel
        
        Set peUpdateMode of oSelList to umPromptValue
        Send OnStoreDefaults of oSelList      
        //
        If (iRepIdno<>0) Begin
            Set piSelected to iRepIdno
            Set pbSelected to True
            Send Clear of oSalesRep_DD
            Move iRepIdno to SalesRep.RepIdno
            Send Request_Find of oSalesRep_DD EQ SalesRep.File_Number 1
            Move (SalesRep.FirstName * SalesRep.LastName) to sRepName
        End
        //
        Set pbCanceled                       to False
        //
        Send Popup
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Move SalesRep.RepIdno to iRepIdno
            Move (SalesRep.FirstName * SalesRep.LastName) to sRepName
            Set pbSelected to True
            Function_Return (pbSelected(Self))
        End
        If bCancel Begin
            Set pbSelected to False
            Function_Return (pbSelected(Self))
        End
        //
        
    End_Function


    Object oStatusGroup is a Group
        Set Size to 25 93
        Set Location to 157 5
        Set Label to 'Status'
        Set peAnchors to anBottomLeft

        Object oActiveSlsRepCheckBox is a CheckBox
            Set Size to 10 38
            Set Location to 11 12
            Set Label to 'Active'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oSalesRep_DD
                Send MovetoFirstRow of oSelList
            End_Procedure
        End_Object

        Object oInactiveSlsRepCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 11 49
            Set Label to 'Inactive'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oSalesRep_DD
                Send MovetoFirstRow of oSelList
            End_Procedure
        
        End_Object
    End_Object
End_Object // SalesRep_sl
