// D:\Development Projects\VDF19.1 Workspaces\Tempus\AppSrc\DivisionMgr.vw
// DivisionMgr
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use cDivisionMgrGlblDataDictionary.dd
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use cCJCommandBarSystem.pkg

Use Employee.sl

ACTIVATE_VIEW Activate_oDivisionMgr FOR oDivisionMgr
Object oDivisionMgr is a cGlblDbView
    Set Location to 5 6
    Set Size to 335 598
    Set Label To "DivisionMgr"
    Set Border_Style to Border_Thick


    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object 

    Set Main_DD To oDivisionMgr_DD
    Set Server  To oDivisionMgr_DD

    Object oDivisionMgrDbCJGrid is a cDbCJGrid
        Set Size to 327 588
        Set Location to 5 7
        Set peAnchors to anAll
        Set pbAllowEdit to False

        Object oDivisionMgr_DivMgrIdno is a cDbCJGridColumn
            Entry_Item DivisionMgr.DivMgrIdno
            Set piWidth to 78
            Set psCaption to "Employee #"
            Set pbEditable to False
        End_Object

        Object oDivisionMgr_FirstName is a cDbCJGridColumn
            Entry_Item DivisionMgr.FirstName
            Set piWidth to 216
            Set psCaption to "FirstName"
        End_Object

        Object oDivisionMgr_LastName is a cDbCJGridColumn
            Entry_Item DivisionMgr.LastName
            Set piWidth to 217
            Set psCaption to "LastName"
        End_Object

        Object oDivisionMgr_Email is a cDbCJGridColumn
            Entry_Item DivisionMgr.Email
            Set piWidth to 217
            Set psCaption to "Email"
        End_Object

        Object oDivisionMgr_CellPhone is a cDbCJGridColumn
            Entry_Item DivisionMgr.CellPhone
            Set piWidth to 199
            Set psCaption to "CellPhone"
        End_Object

        Object oDivisionMgr_Status is a cDbCJGridColumn
            Entry_Item DivisionMgr.Status
            Set piWidth to 22
            Set psCaption to "Status"
        End_Object

        Object oDivisionMgrCJContextMenu is a cCJContextMenu
            
            Object oCreateUpdateMenuItem is a cCJMenuItem
                Set psCaption to "Create/Update"
                Set psTooltip to "Create/Update"

                Procedure OnExecute Variant vCommandBarControl
                    //Forward Send OnExecute vCommandBarControl
                    
                    Boolean bSuccess bFail
                    Integer iEmployeeIdno iEmployerIdno
                    //
                    Get Field_Current_Value of oDivisionMgr_DD Field DivisionMgr.DivMgrIdno to iEmployeeIdno
                    Move 101 to iEmployerIdno // Always Interstate Only
                    Get DoEmplPromptwEmployer of Employee_sl (&iEmployeeIdno) iEmployerIdno to bSuccess
                    If (bSuccess) Begin
                        //Check if record exsists
                        Send Clear_All of oDivisionMgr_DD
                        Move iEmployeeIdno to DivisionMgr.DivMgrIdno
                        Send Request_Find of oDivisionMgr_DD EQ DivisionMgr.File_Number 1
                        If ((Found) and DivisionMgr.DivMgrIdno = iEmployeeIdno) Begin
                            Send Refind_Records of oDivisionMgr_DD
                        End
                        Else Begin
                            // New record required
                            Send Clear_All of oDivisionMgr_DD
                        End
                        Clear Employee
                        Move iEmployeeIdno to Employee.EmployeeIdno
                        Find GE Employee.EmployeeIdno
                        If ((Found) and Employee.EmployeeIdno = iEmployeeIdno and Employee.EmployerIdno = iEmployerIdno) Begin
                            Set Field_Changed_Value of oDivisionMgr_DD Field DivisionMgr.DivMgrIdno to Employee.EmployeeIdno
                            Set Field_Changed_Value of oDivisionMgr_DD Field DivisionMgr.FirstName to Employee.FirstName
                            Set Field_Changed_Value of oDivisionMgr_DD Field DivisionMgr.LastName to Employee.LastName
                            Set Field_Changed_Value of oDivisionMgr_DD Field DivisionMgr.Email to Employee.EmailAddress
                            Set Field_Changed_Value of oDivisionMgr_DD Field DivisionMgr.CellPhone to (If(Employee.PhoneType1="C",Employee.Phone1,Employee.Phone2))
                            Set Field_Changed_Value of oDivisionMgr_DD Field DivisionMgr.Status to Employee.Status
                            Get Request_Validate of oDivisionMgr_DD to bFail
                            If (not(bFail)) Begin
                                Send Request_Save of oDivisionMgr_DD
                                Send RefreshDataFromDD of oDivisionMgrDbCJGrid ropTop
                                Send MoveToFirstRow of oDivisionMgrDbCJGrid
                            End
                        End
                    End
                End_Procedure
                
                
            End_Object

            Object oDeleteMenuItem is a cCJMenuItem
                Set psCaption to "Delete"
                Set psTooltip to "Delete"
            End_Object
        End_Object

        Procedure OnComRowRClick Variant llRow Variant llItem
            //Forward Send OnComRowRClick llRow llItem
            Send Popup of oDivisionMgrCJContextMenu
        End_Procedure
    End_Object


End_Object 
