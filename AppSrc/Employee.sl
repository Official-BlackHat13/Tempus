// Employee.sl
// Employee Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Employer.DD
Use Employee.DD
Use cWebAppUserRightsGlblDataDictionary.dd

Object Employee_sl is a cGlblDbModalPanel
    
    Property Boolean pbSelected
    Property Boolean pbManager
    Property Boolean pbCanceled
    Property Integer piSelected
    Property Integer piStatus
    Property RowID   priEmployee
    Property Integer piEmployerId
    
    Set Location to 5 5
    Set Size to 147 374
    Set Label To "Employee Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
    End_Object


    Object oEmployer_DD is a Employer_DataDictionary
    End_Object 

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oWebAppUserRights_DD
        Set DDO_Server to oEmployer_DD

        Procedure OnConstrain
            Forward Send OnConstrain
            //Manager
            If (pbManager(Self)) Begin
                Constrain Employee.IsManager eq 1
            End
            If (piEmployerId(Self)<>0) Begin
                Integer iEmployerIdno
                Get piEmployerId to iEmployerIdno
                Constrain Employee.EmployerIdno eq iEmployerIdno
            End
            //Status
            If (not(Checked_State(oStatusActiveCheckBox(Self)))) Constrain Employee.Status ne "A"
            If (not(Checked_State(oStatusInactiveCheckBox(Self)))) Constrain Employee.Status ne "I"
        End_Procedure

                    
    End_Object 

    Set Main_DD To oEmployee_DD
    Set Server  To oEmployee_DD

    Object oSelList is a cDbCJGridPromptList
        Set Size to 110 364
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Employee_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oEmployee_EmployeeIdno is a cDbCJGridColumn
            Entry_Item Employee.EmployeeIdno
            Set piWidth to 52
            Set psCaption to "Employee#"
        End_Object 

        Object oEmployee_LastName is a cDbCJGridColumn
            Entry_Item Employee.LastName
            Set piWidth to 165
            Set psCaption to "Last Name"
        End_Object 

        Object oEmployee_FirstName is a cDbCJGridColumn
            Entry_Item Employee.FirstName
            Set piWidth to 166
            Set psCaption to "First Name"
        End_Object 

        Object oEmployer_Name is a cDbCJGridColumn
            Entry_Item Employer.Name
            Set piWidth to 166
            Set psCaption to "Company"
        End_Object 

        Object oWebAppUserRights_Description is a cDbCJGridColumn
            Entry_Item WebAppUserRights.Description
            Set piWidth to 205
            Set psCaption to "Description"
        End_Object


    End_Object 

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 125 211
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object 

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 125 265
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object 

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 125 319
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object 

    Object oStatusGroup is a Group
        Set Size to 25 93
        Set Location to 117 5
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
                Send Rebuild_Constraints of oEmployee_DD
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
                Send Rebuild_Constraints of oEmployee_DD
                Send MovetoFirstRow of oSelList
            End_Procedure
        
        End_Object
    End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

    //IsSelectedManager
    Function SelectEmployee Integer ByRef iMgrEmployeeIdno String ByRef sFirstName String ByRef sLastName Boolean bManager Returns Boolean
        Boolean bCancel
        String[] SelectionValues
        //
        Send OnStoreDefaults of oSelList
        //
        Set Locate_Mode to CENTER_ON_PANEL
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set piUpdateColumn of oSelList to 0
        Set psSeedValue of oSelList to iMgrEmployeeIdno
        If (bManager) Begin
            Set Label of Employee_sl to "Manager Lookup List"
            Set pbManager to bManager 
        End
        Send Rebuild_Constraints of oEmployee_DD
        //
        Send Popup_Modal
        //
        Send OnRestoreDefaults of oSelList
        //
        If (bManager) Begin
            Set Label of Employee_sl to "Employee Lookup List"
            Set pbManager to False    
        End
        
        Send Rebuild_Constraints of oEmployee_DD        
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Get SelectedColumnValues of oSelList 0 to SelectionValues
            If (SizeOfArray(SelectionValues)) Begin
                Move SelectionValues[0] to iMgrEmployeeIdno
                Move Employee.FirstName to sFirstName
                Move Employee.LastName to sLastName
                Function_Return True
            End
        End
        Function_Return False
    End_Function


    Function DoEmplPromptwEmployer Integer ByRef iEmployeeIdno Integer iEmployerIdno Returns Boolean
        Boolean bCancel
        String[] SelectionValues
        
        // with non-invoking lists we store and restore the defaults manually
        Send OnStoreDefaults of oSelList
        //
        Set Locate_Mode to CENTER_ON_PANEL
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set piUpdateColumn of oSelList to 0
        Set psSeedValue of oSelList to iEmployeeIdno
        
        If (iEmployerIdno<>0) Begin
            Set piEmployerId to iEmployerIdno  
            Send Rebuild_Constraints of oEmployee_DD
        End
        //
        Send Popup
        //
        Send OnRestoreDefaults of oSelList
        //
        If (iEmployerIdno<>0) Begin
            Set piEmployerId to 0  
            Send Rebuild_Constraints of oEmployee_DD
        End
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Get SelectedColumnValues of oSelList 0 to SelectionValues
            If (SizeOfArray(SelectionValues)) Begin
                Move SelectionValues[0] to iEmployeeIdno
                Function_Return True
            End
        End
        Function_Return False
    End_Function

//    Function SelectEmployee Integer ByRef iEmployeeIdno String ByRef sFirstName String ByRef sLastName Returns Boolean
//        Boolean bCancel
//        //
//        Set peUpdateMode of oSelList to umPromptValue
//        Send OnStoreDefaults of oSelList
//        //
//        If (iEmployeeIdno <> 0) Begin
//            Set pbSelected to True
//            Set piSelected to iEmployeeIdno
//            Send Clear of oEmployee_DD
//            Move iEmployeeIdno to Employee.EmployeeIdno
//            Send Find of oEmployee_DD EQ 1
//        End
//        //
//        Send Popup_Modal
//        //
//        Get pbCanceled of oSelList to bCancel
//        If not bCancel Begin
//            Set pbSelected to True
//            Move Employee.EmployeeIdno to iEmployeeIdno
//            Move Employee.FirstName to sFirstName
//            Move Employee.LastName to sLastName
//        End
//        Else Begin
//            Set pbSelected to False
//        End
//        
//        Function_Return (pbSelected(Self))
//    End_Function

    Function IsSelectedEmployee RowID ByRef riEmployee RowID ByRef riEmployer Returns Boolean
        Boolean bSelected
        Handle  hoServer
        //
        Get Server to hoServer
//        //
//        Send Clear_All of hoServer
        If (IsNullRowID(riEmployer)) Begin
            Set Constrain_File of hoServer to 0
        End
        Else Begin
            Set Constrain_File of hoServer to Employer.File_Number
        End
        Send Rebuild_Constraints of hoServer
        //
        If      (not(IsNullRowId(riEmployee))) Begin
            Send FindByRowId of hoServer Employee.File_Number riEmployee
        End
        Else If (not(IsNullRowId(riEmployer))) Begin
            Send FindByRowId of hoServer Employer.File_Number riEmployer
        End
        //
        Set pbSelected                       to False
        //Set Move_Value_Out_State of oSelList to False
        //
        Send Popup
        //
        //Set Move_Value_Out_State of oSelList to True
        Get pbSelected                       to bSelected
        Get priEmployee                      to riEmployee
        //
        Function_Return bSelected
    End_Function

End_Object // Employee_sl
