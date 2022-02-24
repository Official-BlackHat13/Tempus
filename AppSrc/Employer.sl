// Employer.sl
// Employer Lookup List

Use DFClient.pkg
Use DFSelLst.pkg
Use Windows.pkg
Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg

Use Employer.DD

Object Employer_sl is a cGlblDbModalPanel
    Set Location to 5 2
    Set Size to 209 353
    Set Label To "Employer Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False
    
    Property Boolean pbCanceled

    Object oEmployer_DD is a Employer_DataDictionary
        Procedure OnConstrain
            //Status
            If (not(Checked_State(oActiveEmployerCheckBox(Self)))) Constrain Employer.Status ne "A"
            If (not(Checked_State(oInactiveEmployerCheckBox(Self)))) Constrain Employer.Status ne "I"
            If (not(Checked_State(oTerminatedEmployerCheckBox(Self)))) Constrain Employer.Status ne "T"
            //
        End_Procedure
    End_Object // oEmployer_DD

    Set Main_DD To oEmployer_DD
    Set Server  To oEmployer_DD

    Object oSelList is a cGlblDbList
        Set Size to 171 343
        Set Location to 10 5
        Set peAnchors to anAll
        Set Main_File to Employer.File_Number
        Set Ordering to 1
        Set peResizeColumn to rcAll
        Set Auto_Server_State to True
        Set pbHeaderTogglesDirection to True

        Begin_row
            Entry_Item Employer.EmployerIdno
            Entry_Item Employer.Name
            Entry_Item Employer.Main_contact
        End_row

        Set Form_Width 0 to 47
        Set Header_Label 0 to "Employer#"

        Set Form_Width 1 to 148
        Set Header_Label 1 to "Name"
        Set Form_Width 2 to 141
        Set Header_Label 2 to "Main contact"

    End_Object // oSelList

    Object oOk_bn Is A Button
        Set Label to "&Ok"
        Set Location to 190 190
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A Button
        Set Label to "&Cancel"
        Set Location to 190 244
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A Button
        Set Label to "&Search..."
        Set Location to 190 298
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    Object oStatusGroup is a Group
        Set Size to 22 170
        Set Location to 184 3
        Set Label to 'Status'
        Set peAnchors to anBottomLeft

        Object oActiveEmployerCheckBox is a CheckBox
            Set Size to 10 37
            Set Location to 9 9
            Set Label to 'Active'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oEmployer_DD
                Send Beginning_of_Data to oSelList
            End_Procedure
        End_Object

        Object oInactiveEmployerCheckBox is a CheckBox
            Set Size to 10 40
            Set Location to 9 61
            Set Label to 'Inactive'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oEmployer_DD
                Send Beginning_of_Data to oSelList
            End_Procedure
        
        End_Object

        Object oTerminatedEmployerCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 9 116
            Set Label to 'Terminated'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oEmployer_DD
                Send Beginning_of_Data to oSelList
            End_Procedure
        
        End_Object
    End_Object

    Function DoEmployerPrompt Returns Integer        
        Boolean bCancel
        Integer iEmployerId
        //
        Send Popup_Modal
        //        
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Move Employer.EmployerIdno to iEmployerId
        End
        If bCancel Begin
            Move 0 to iEmployerId
        End
        //
        Function_Return (iEmployerId)
    End_Function

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

End_Object

