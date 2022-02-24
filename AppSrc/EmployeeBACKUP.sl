// Employee.sl
// Employee Lookup List

Use DFClient.pkg
Use DFSelLst.pkg
Use Windows.pkg
Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg

Use Employer.DD
Use Employee.DD

Object Employee_sl is a cGlblDbModalPanel

    Property Boolean pbSelected
    Property Boolean pbCanceled
    Property Integer piSelected
    Property Integer piStatus
    Property RowID   priEmployee
    Property Integer piEmployerId

    Set Location to 5 5
    Set Size to 180 293
    Set Label To "Employee Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Object oEmployer_DD is a Employer_DataDictionary      
    End_Object // oEmployer_DD

    Object oEmployee_DD Is A Employee_DataDictionary
        Set DDO_Server to oEmployer_DD
        Set Constrain_File to Employer.File_Number

        Procedure OnConstrain
            If (piEmployerId(Self) >0) Begin
                Constrain Employee.EmployerIdno eq (piEmployerId(Self))
            End                       
            If      (piStatus(Self) = 1) Begin
                Constrain Employee.Status eq "A"
            End
            Else If (piStatus(Self) = 2) Begin
                Constrain Employee.Status eq "I"
            End
        End_Procedure
    End_Object // oEmployee_DD

    Set Main_DD To oEmployee_DD
    Set Server  To oEmployee_DD

    Object oSelList is a cGlblDbList
        Set Size to 113 280
        Set Location to 5 5
        Set peAnchors to anAll
        Set Main_File to Employee.File_Number
        Set Ordering to 1
        Set peResizeColumn to rcAll
        Set pbHeaderTogglesDirection to True

        Begin_row
            Entry_Item Employee.EmployeeIdno
            Entry_Item Employee.Lastname
            Entry_Item Employee.FirstName
            Entry_Item Employer.Name
        End_row

        Set Form_Width 0 to 51
        Set Header_Label 0 to "Employee#"

        Set Form_Width 1 to 80
        Set Header_Label 1 to "Last Name"
        Set Form_Width 2 to 70
        Set Header_Label 2 to "FirstName"
        Set Form_Width 3 to 70
        Set Header_Label 3 to "Company"

//        Procedure Ok
//            If (pbSelected(Self)) Begin
//                Set piSelected to Employee.EmployeeIdno
//                Send Close_Panel
//            End
//            Else Begin
//                Forward Send Ok
//            End
//        End_Procedure

        Procedure Ok
            RowID riEmployee
            //
            If (Move_Value_Out_State(Self)) Begin
                Forward Send Ok
            End
            Else Begin
                Get CurrentRowId of oEmployee_DD to riEmployee
                Set piSelected                   to Employee.EmployeeIdno
                Set priEmployee                  to riEmployee
                Set pbSelected                   to True
                Send Close_Panel
            End
        End_Procedure

    End_Object // oSelList

    Object oStatusRadioGroup is a RadioGroup
        Set Location to 120 5
        Set Size to 54 77
        Set Label to "Status"
        Set peAnchors to anBottomLeft
    
        Object oRadio1 is a Radio
            Set Label to "All"
            Set Size to 10 61
            Set Location to 10 5
        End_Object
    
        Object oRadio2 is a Radio
            Set Label to "Active"
            Set Size to 10 61
            Set Location to 25 5
        End_Object
    
        Object oRadio3 is a Radio
            Set Label to "Inactive"
            Set Size to 10 61
            Set Location to 40 5
        End_Object
    
        Procedure Notify_Select_State Integer iToItem Integer iFromItem
            Forward Send Notify_Select_State iToItem iFromItem
            //for augmentation
            Set piStatus to iToItem
            Send Rebuild_Constraints of oEmployee_DD
            Send Beginning_of_Data   of oSelList
        End_Procedure
    
        //If you set Current_Radio, you must set it AFTER the
        //radio objects have been created AND AFTER Notify_Select_State has been
        //created. i.e. Set in bottom-code of object at the end!!
        Set Current_Radio to 1    
    End_Object

    Object oOk_bn Is A Button
        Set Label to "&Ok"
        Set Location to 159 124
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A Button
        Set Label to "&Cancel"
        Set Location to 159 178
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A Button
        Set Label to "&Search..."
        Set Location to 159 232
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


    Function IsSelectedManager Integer iID Integer ByRef iEmployeeIdno String ByRef sFirstName String ByRef sLastName Returns Integer
        Set pbSelected to True
        Set piSelected to iID
        Boolean bCancel
        //
        Set Constrain_File       of oEmployee_DD to 0
        Constrain Employee.IsManager eq 1
        Send Rebuild_Constraints of oEmployee_DD
        If (iID <> 0) Begin
            Send Clear of oEmployee_DD
            Move iID to Employee.EmployeeIdno
            Send Find  of oEmployee_DD EQ 1
        End
        //
        Set Move_Value_Out_State of oSelList to False
        //
        Send Popup_Modal
        //
        Set Move_Value_Out_State of oSelList to True
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Move Employee.EmployeeIdno to iEmployeeIdno
            Move Employee.FirstName to sFirstName
            Move Employee.LastName to sLastName
        End
        //
        Set Constrain_File       of oEmployee_DD to Employer.File_Number
        Send Rebuild_Constraints of oEmployee_DD
        //
        Set pbSelected to False
        
        Function_Return (piSelected(Self))
    End_Function


    Function SelectEmployee Integer ByRef iEmployeeIdno String ByRef sFirstName String ByRef sLastName Returns Boolean
        Boolean bCancel
        //
        If (iEmployeeIdno <> 0) Begin
            Set pbSelected to True
            Set piSelected to iEmployeeIdno
            Send Clear of oEmployee_DD
            Move iEmployeeIdno to Employee.EmployeeIdno
            Send Find of oEmployee_DD EQ 1
        End
        //
        //Set Move_Value_Out_State of oSelList to False
        //
        Send Popup_Modal
        //
        //Set Move_Value_Out_State of oSelList to True
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Set pbSelected to True
            Move Employee.EmployeeIdno to iEmployeeIdno
            Move Employee.FirstName to sFirstName
            Move Employee.LastName to sLastName
        End
        Else Begin
            Set pbSelected to False
        End
        
        Function_Return (pbSelected(Self))
    End_Function

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
        Set Move_Value_Out_State of oSelList to False
        //
        Send Popup
        //
        Set Move_Value_Out_State of oSelList to True
        Get pbSelected                       to bSelected
        Get priEmployee                      to riEmployee
        //
        Function_Return bSelected
    End_Function

End_Object
