// C:\VDF14.0 Workspaces\InterstateCompanies\AppSrc\User.vw
// Website User Maintenance
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cGlblDbComboForm.pkg
Use User.DG
Use Windows.pkg
Use dfLine.pkg
Use User.DD
Use cUserRightsGlblDataDictionary.dd

ACTIVATE_VIEW Activate_oUser FOR oUser
Object oUser Is A cGlblDbView
    Object oUserRights_DD is a cUserRightsGlblDataDictionary
    End_Object

    Object oUser_DD is a User_DataDictionary
        Set DDO_Server to oUserRights_DD
    End_Object

    Set Main_DD to oUser_DD
    Set Server to oUser_DD

    Set Location to 6 9
    Set Size to 150 329
    Set Label to "User Maintenance"
    Set Border_Style to Border_Thick

//    Object oUserUserid Is A cGlblDbForm
//        Entry_Item User.Userid
//        Set Size to 13 50
//        Set Location to 5 39
//     //   Set peAnchors to anLeftRight
//        Set Label to "User ID"
//        Set Label_Justification_mode to JMode_Right
//        Set Label_Col_Offset to 5
//        Set Label_row_Offset to 0
//
//        Procedure Refresh Integer iMode
//            Set Enabled_State of oPasswordButton to (User.Recnum)
//            //
//            Forward Send Refresh iMode
//        End_Procedure
//    End_Object // oUserUserid

    Object oUserLoginname Is A cGlblDbForm
        Entry_Item User.Loginname
        Set Size to 13 101
        Set Location to 20 51
      //  Set peAnchors to anLeftRight
        Set Label to "Login name"
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 5
        Set Label_row_Offset to 0
        Set Prompt_Button_Mode to PB_PromptOn
        
        Procedure Refresh Integer iMode
            Set Enabled_State of oPasswordButton to (User.Recnum)
            //
            Forward Send Refresh iMode
        End_Procedure
        
    End_Object // oUserLoginname

    Object oUserFirstname Is A cGlblDbForm
        Entry_Item User.Firstname
        Set Size to 13 100
        Set Location to 37 51
        //Set peAnchors to anLeftRight
        Set Label to "First Name"
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 5
        Set Label_row_Offset to 0
    End_Object // oUserFirstname

    Object oUserLastname Is A cGlblDbForm
        Entry_Item User.Lastname
        Set Size to 13 109
        Set Location to 37 203
       // Set peAnchors to anLeftRight
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 39
        Set Label_row_Offset to 0
        Set Label to "Lastname"
    End_Object // oUserLastname

    Object oUserState Is A cGlblDbComboForm
        Entry_Item User.State
        Set Size to 12 53
        Set Location to 54 51
       // Set peAnchors to anLeftRight
        Set Label to "Status"
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 5
        Set Label_row_Offset to 0
    End_Object // oUserState

    Object oUserEditrights Is A cGlblDbComboForm
        Entry_Item User.Editrights
        Set Size to 12 53
        Set Location to 77 95
        //Set peAnchors to anLeftRight
        Set Label to "Edit rights:"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 39
        Set Label_row_Offset to 0
    End_Object // oUserEditrights

    Object oPasswordButton is a Button
        Set Size to 14 106
        Set Location to 54 203
        Set Label to "&Change Password"

        Procedure OnClick
            Send DoChangePassword
        End_Procedure
    End_Object

//    Object oUser_SalesIdno is a cGlblDbForm
//        Entry_Item SalesRep.RepIdno
//        Set Location to 133 53
//        Set Size to 13 53
//        Set Label to "Sales ID"
//        Set Label_Col_Offset to 5
//        Set Label_Justification_Mode to JMode_Right
//    End_Object
//
//    Object oSalesRepName is a cGlblDbForm
//        Entry_Item SalesRep.FirstName
//        Set Location to 133 110
//        Set Size to 13 106
//        Set Label to ""
//        Set Label_Col_Offset to 5
//        Set Label_Justification_Mode to JMode_Right
//    End_Object
//
//    Object oUser_SalesIdno is a cGlblDbForm
//        Entry_Item SalesRep.LastName
//        Set Location to 133 218
//        Set Size to 13 95
//        Set Label to ""
//        Set Label_Col_Offset to 5
//        Set Label_Justification_Mode to JMode_Right
//    End_Object

    Object oLineControl1 is a LineControl
        Set Size to 6 307
        Set Location to 73 7
    End_Object

    Object oUserAccount is a TextBox
        Set Size to 10 44
        Set Location to 7 9
        Set Label to "User Account"
        Set FontWeight to fw_Bold
    End_Object

    Procedure DoChangePassword
        Send Request_Save
        If (Should_Save(Self)) Procedure_Return
        //
        Send DoChangePassword of oUserPasswordDialog (Current_Record(Server(Self)))
        Send Activate         of oUserFirstname
    End_Procedure

    Object oRights is a TextBox
        Set Size to 10 21
        Set Location to 79 9
        Set Label to "Rights"
        Set FontWeight to fw_Bold
    End_Object

    Object oAccessIDs is a TextBox
        Set Size to 10 30
        Set Location to 100 9
        Set Label to 'Accounts'
        Set FontWeight to fw_Bold
    End_Object

    Object oLineControl1 is a LineControl
        Set Size to 1 307
        Set Location to 93 6
    End_Object

//    Object oComboForm1 is a dbComboForm
//        Set Size to 12 131
//        Set Location to 77 180
//        Entry_Item User.EditLevel
//        Set Combo_Sort_State to False
//        Set Entry_State to False
//        Set Label to "Group:"
//        Set Label_Col_Offset to 5
//        Set Label_Justification_Mode to JMode_Right
//                
//        //Combo_Fill_List is called when the list needs filling
//    
////        Procedure Combo_Fill_List
////            // Fill the combo list with Send Combo_Add_Item
////            Send Combo_Add_Item "Not specified (0)" "0"
//////            Send Combo_Add_Item "10 - " "10"            
//////            Send Combo_Add_Item "20 - " "20"            
//////            Send Combo_Add_Item "30 - " "30"
//////            Send Combo_Add_Item "40 - " "40"
////            Send Combo_Add_Item "Sales (50)" "50"
////            Send Combo_Add_Item "Operations (60)" "60"
////            Send Combo_Add_Item "Operations - Temp Changes (65)" "65"
////            Send Combo_Add_Item "Administration (70)" "70"
////            Send Combo_Add_Item "Management (80)" "80"            
////            Send Combo_Add_Item "SystemAdmin (90)" "90"
////            
////        End_Procedure
//    
//        //OnChange is called on every changed character
//    
//        //Procedure OnChange
//        //    String sValue
//        //
//        //    Get Value To sValue // the current selected item
//        //End_Procedure
//    
//        //Notification that the list has dropped down
//    
//        //Procedure OnDropDown
//        //End_Procedure
//    
//        //Notification that the list was closed
//    
//        //Procedure OnCloseUp
//        //End_Procedure
//    
//    End_Object

    Object oSalesRep_RepIdno is a cGlblDbForm
        Entry_Item User.SalesIdno
        Set Location to 97 95
        Set Size to 13 54
        Set Label to "SalesRep :"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 5
        Set Prompt_Button_Mode to PB_PromptOn
        
        Procedure Prompt
            Integer iRepIdno
            String sRepName
            Boolean bSuccess
            Move User.SalesIdno to iRepIdno
            Get IsSelectedSalesRep of SalesRep_sl (&iRepIdno) (sRepName) to bSuccess
            If (bSuccess) Begin
                Move iRepIdno to User.SalesIdno
                Send Request_Save of oUser_DD
            End
            
        End_Procedure

        Procedure Refresh Integer notifyMode
            Forward Send Refresh notifyMode
            If (User.SalesIdno <>0) Begin
                Move User.SalesIdno to SalesRep.RepIdno
                Find EQ SalesRep by 1
                If (Found) Begin
                    Set Value of oSalesRep_FirstName to SalesRep.FirstName
                    Set Value of oSalesRep_LastName to SalesRep.LastName
                End
            End
            Else Begin
                Set Value of oSalesRep_FirstName to ""
                Set Value of oSalesRep_LastName to ""
            End
        End_Procedure

    End_Object
    
    Object oSalesRep_FirstName is a cGlblDbForm
        Set Location to 96 152
        Set Size to 13 81
        Set Label to ""
        Set Enabled_State to False
    End_Object
    
    Object oSalesRep_LastName is a cGlblDbForm
        Set Location to 97 235
        Set Size to 13 76
        Set Label to ""
        Set Enabled_State to False
    End_Object

    Object oEmployee_EmployeeIdno is a cGlblDbForm
        Entry_Item User.EmployeeIdno
        Set Location to 113 95
        Set Size to 13 54
        Set Label to "Employee:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOn
        
        Procedure Prompt
            Integer iEmployeeIdno
            String sEmplFirstName sEmplLastName
            Boolean bSuccess
            Move User.EmployeeIdno to iEmployeeIdno
            Get SelectEmployee of Employee_sl (&iEmployeeIdno) (&sEmplFirstName) (&sEmplLastName) False to bSuccess
            If (bSuccess) Begin
                Move iEmployeeIdno to User.EmployeeIdno
                Send Request_Save of oUser_DD
            End
        End_Procedure

        Procedure Refresh Integer notifyMode
            Forward Send Refresh notifyMode
            If (User.EmployeeIdno <>0) Begin
                Move User.EmployeeIdno to Employee.EmployeeIdno
                Find EQ Employee by 1
                If (Found) Begin
                    Set Value of oEmployee_FirstName to Employee.FirstName
                    Set Value of oEmployee_LastName to Employee.LastName
                End
            End
            Else Begin
                Set Value of oEmployee_FirstName to ""
                Set Value of oEmployee_LastName to ""
            End
        End_Procedure
    End_Object

    Object oEmployee_FirstName is a cGlblDbForm
        Set Location to 113 152
        Set Size to 13 81
        Set Enabled_State to False
    End_Object

    Object oEmployee_LastName is a cGlblDbForm
        Set Location to 113 235
        Set Size to 13 76
        Set Enabled_State to False
    End_Object

    Object oContact_ContactIdno is a cGlblDbForm
        Entry_Item User.CustContactId
        Set Location to 129 95
        Set Size to 13 54
        Set Label to "Contact:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOn
        
        Procedure Prompt
            Integer iContactIdno
            String sContactFirstName sContactLastName
            Boolean bSuccess
            Move User.CustContactId to iContactIdno
            Get SelectContact of Contact_sl (&iContactIdno) to bSuccess
            If (bSuccess) Begin
                Move iContactIdno to User.CustContactId
                Send Request_Save of oUser_DD
            End
            

        End_Procedure

        Procedure Refresh Integer notifyMode
            Forward Send Refresh notifyMode
            If (User.CustContactId <>0) Begin
                Move User.CustContactId to Contact.ContactIdno
                Find EQ Contact by 2
                If (Found) Begin
                    Set Value of oContact_FirstName to Contact.FirstName
                    Set Value of oContact_LastName to Contact.LastName
                End
            End
            Else Begin
                Set Value of oContact_FirstName to ""
                Set Value of oContact_LastName to ""
            End
        End_Procedure
    End_Object

    Object oContact_FirstName is a cGlblDbForm
        Set Location to 129 152
        Set Size to 13 81
        Set Enabled_State to False
    End_Object

    Object oContact_LastName is a cGlblDbForm
        Set Location to 128 235
        Set Size to 13 76
        Set Enabled_State to False
    End_Object

    Object oUserRights_Discription is a cGlblDbForm
        Entry_Item UserRights.Discription
        Set Location to 77 190
        Set Size to 13 122
        Set Label to "Edit Level:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
    End_Object

    On_Key Key_Alt+Key_C Send KeyAction of oPasswordButton

End_Object // oUser
