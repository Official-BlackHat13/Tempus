Use Windows.pkg
Use DFClient.pkg
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use cCJCommandBarSystem.pkg
Use cWebAppUserRightsGlblDataDictionary.dd
Use cWebAppUserDataDictionary.dd
Use dfLine.pkg

Deferred_View Activate_oWebAppUser for ;
Object oWebAppUser is a dbView
    
    Property Integer piEmployerIdno
    Property String psEmployerName
    Property String psCustomer
    Property Integer piRightsIdno
    Property Boolean pbBillingAccess
    
    
    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
    End_Object

    Object oWebAppUser_DD is a cWebAppUserDataDictionary
        Set DDO_Server to oWebAppUserRights_DD
        
        Procedure OnConstrain
            Integer iEmployerIdno iRightsIdno
            Boolean bBillingAccess
            Get piEmployerIdno to iEmployerIdno
            If (iEmployerIdno<>0) Begin
                Constrain WebAppUser.EmployerIdno eq iEmployerIdno
            End
            Get pbBillingAccess to bBillingAccess
            If (bBillingAccess) Begin
                Constrain WebAppUser.BillingAccessFlag eq bBillingAccess
            End
            Get piRightsIdno to iRightsIdno
            If (iRightsIdno<>0) Begin
                Constrain WebAppUser.Rights eq iRightsIdno
            End
        End_Procedure
    End_Object

    Set Main_DD to oWebAppUser_DD
    Set Server to oWebAppUser_DD

    Set Border_Style to Border_Thick
    Set Size to 300 535
    Set Location to 2 2
    Set Label to "WebAppUser"
    Set Maximize_Icon to True
    Set piMinSize to 300 535


    Object oFilterGroup is a dbGroup
        Set Size to 44 481
        Set Location to 3 2
        Set Label to 'Filter'
        Set peAnchors to anTopLeft

        Object oEmployerCombo is a dbComboForm
            Set Size to 12 100
            Set Entry_State to False
            Set Allow_Blank_State to True
            Set Location to 20 7
            Set Combo_Data_File to 4
            Set Code_Field to 1
            Set Combo_Index to 2
            Set Description_Field to 2
            Set Label to "Employer"
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            
            
            Procedure OnChange
                String sEmployerName
                Integer iEmployerIdno
                Get Value of oEmployerCombo to sEmployerName
                //If (Length(sEmployerName)>0) Begin
                    Clear Employer
                    Move (Trim(sEmployerName)) to Employer.Name
                    Find GT Employer by 2
                    If ((Found) and (Trim(Employer.Name)) = sEmployerName) Begin
                        Move Employer.EmployerIdno to iEmployerIdno
                        Set piEmployerIdno to iEmployerIdno
                    End
                    Else Begin
                        Set piEmployerIdno to 0
                    End
                //End
                Send Clear_All of oWebAppUser_DD
                Send Rebuild_Constraints of oWebAppUser_DD
                Send MoveToFirstRow of oWebAppUserGrid
            End_Procedure
        End_Object
        
        Object oButton1 is a Button
            Set Size to 14 25
            Set Location to 19 108
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oEmployerCombo to ""
            End_Procedure
        
        End_Object
        
        Object oRightsCombo is a dbComboForm
            Set Size to 12 100
            Set Entry_State to False
            Set Allow_Blank_State to True
            Set Location to 20 142
            Set Combo_Data_File to 82
            Set Code_Field to 1
            Set Combo_Index to 2
            Set Description_Field to 2
            Set Label to "Rights"
            Set Label_Justification_Mode to JMode_Top
            Set Label_Col_Offset to 0
            
            
            Procedure OnChange
                Integer iRightsLevel
                String sRightsValue
                Get Value of oRightsCombo to sRightsValue
                Clear WebAppUserRights
                Move sRightsValue to WebAppUserRights.Description
                Find GE WebAppUserRights.Description
                If ((Found) and WebAppUserRights.Description = sRightsValue) Begin
                    
                    Set piRightsIdno to WebAppUserRights.RightLevel
                End
                Else Begin
                    Set piRightsIdno to 0
                End
                //
                Send Clear_All of oWebAppUser_DD
                Send Rebuild_Constraints of oWebAppUser_DD
                Send MoveToFirstRow of oWebAppUserGrid
            End_Procedure
        End_Object
        
        Object oCustClear is a Button
            Set Size to 14 25
            Set Location to 19 245
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oRightsCombo to ""
            End_Procedure
        
        End_Object

        Object oLineControl1 is a LineControl
            Set Size to 36 4
            Set Location to 6 137
            Set Horizontal_State to False
        End_Object

        Object oLineControl1 is a LineControl
            Set Size to 36 4
            Set Location to 6 273
            Set Horizontal_State to False
        End_Object

        Object oBillingCheckBox1 is a CheckBox
            Set Size to 10 50
            Set Location to 21 281
            Set Label to 'Billing/Invoicing Access'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Set pbBillingAccess to bChecked
                //
                Send Clear_All of oWebAppUser_DD
                Send Rebuild_Constraints of oWebAppUser_DD
                Send MoveToFirstRow of oWebAppUserGrid
            End_Procedure
        
                        
        
        End_Object
        
    End_Object


    Object oWebAppUserGrid is a cDbCJGrid
        Set Size to 243 524
        Set Location to 51 7
        Set peAnchors to anAll
        Set pbStaticData to True
        Set pbShowNonActiveInPlaceButton to True

        Object oWebAppUser_LoginName is a cDbCJGridColumn
            Entry_Item WebAppUser.LoginName
            Set piWidth to 99
            Set psCaption to "LoginName"
        End_Object

        Object oWebAppUser_Password is a cDbCJGridColumn
            Entry_Item WebAppUser.Password
            Set piWidth to 75
            Set psCaption to "Password"
        End_Object

        Object oWebAppUserRights_Description is a cDbCJGridColumn
            Entry_Item WebAppUserRights.Description
            Set piWidth to 148
            Set psCaption to "Rights"
            Set pbEditable to True
            Set pbFocusable to True
        End_Object

        Object oWebAppUser_FullName is a cDbCJGridColumn
            Entry_Item WebAppUser.FullName
            Set piWidth to 135
            Set psCaption to "FullName"
        End_Object

        Object oWebAppUser_LastLogin is a cDbCJGridColumn
            Entry_Item WebAppUser.LastLogin
            Set piWidth to 130
            Set psCaption to "LastLogin"
            Set pbEditable to False
            Set pbAllowRemove to False
            Set pbAllowDrag to False
        End_Object

        Object oWebAppUser_EmployerIdno is a cDbCJGridColumn
            Entry_Item WebAppUser.EmployerIdno
            Set piWidth to 103
            Set psCaption to "EmployerIdno"
        End_Object

        Object oCJContextMenu1 is a cCJContextMenu

            Object oEmailMenuItem is a cCJMenuItem
                Set psCaption to "Email"
                Set psTooltip to "Email"
                Set peControlType to xtpControlPopup

                Object oWebAppUserMenuItem is a cCJMenuItem
                    Set psCaption to "WebAppUser"
                    Set psTooltip to "WebAppUser"
    
                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        String sEmailAddress sContactName sSubject sEmailQuery sBody
                        Clear Employer
                        Move WebAppUser.EmployerIdno to Employer.EmployerIdno
                        Find EQ Employer by 1
                        If ((Found) and Employer.EmployerIdno = WebAppUser.EmployerIdno) Begin
                            If (Employer.Status = "A") Begin
                                Move (Trim(Employer.EmailAddress)) to sEmailAddress
                                Move (Trim(Employer.Main_contact)) to sContactName
                                Move "Interstate Companies - Billing Instructions" to sSubject
                                
                                Move ("Hello "+ sContactName +",%0D") to sBody
                                //Move (sBody + "Below you will find the link and your credentials for the Contractor Portal and attached a PDF with instructions on how to create invoices.%0D") to sBody 
                                Move (sBody + "Contractor Portal%0D") to sBody
                                Move (sBody + "Website: http://interstatepm.com/billing%0D") to sBody
                                Move (sBody + "Username: "+Trim(WebAppUser.LoginName)+"%0D") to sBody
                                Move (sBody + "Password: "+Trim(WebAppUser.Password)+"%0D") to sBody
                                Move (sBody + "Feel free to contact me if you have any questions.%0D") to sBody
                                //
                                Move ("mailto:"+sEmailAddress+"?subject="+sSubject+"&body="+sBody)        to sEmailQuery  
                                //
                                Runprogram Shell Background sEmailQuery                                  
                            End
                            Else Begin
                                // Employer Not Active
                            End
                        End
                        Else Begin
                            // Employer not Found
                        End
    
                    End_Procedure                    
    
                    Procedure OnCreate
                        Forward Send OnCreate
                        If (giUserRights <90) Begin
                            Set pbVisible of oWebAppUserMenuItem to False
                        End
                    End_Procedure
                    
                End_Object
            End_Object
            
        End_Object

        Object oWebAppUser_EmployeeIdno is a cDbCJGridColumn
            Entry_Item WebAppUser.EmployeeIdno
            Set piWidth to 86
            Set psCaption to "EmployeeIdno"
        End_Object

        Object oWebAppUser_PropertyMgrIdno is a cDbCJGridColumn
            Entry_Item WebAppUser.PropertyMgrIdno
            Set piWidth to 72
            Set psCaption to "PropertyMgrIdno"
        End_Object

        Object oWebAppUser_Status is a cDbCJGridColumn
            Entry_Item WebAppUser.Status
            Set piWidth to 78
            Set psCaption to "Status"
            Set pbComboButton to True
        End_Object

        Object oWebAppUser_BillingAccessFlag is a cDbCJGridColumn
            Entry_Item WebAppUser.BillingAccessFlag
            Set piWidth to 63
            Set psCaption to "BillingAccessFlag"
            Set pbCheckbox to True
        End_Object

        Procedure OnComRowRClick Variant llRow Variant llItem
            //Forward Send OnComRowRClick llRow llItem
            Send Popup of oCJContextMenu1
        End_Procedure

        Procedure OnRowChanged Integer iOldRow Integer iNewSelectedRow
            Forward Send OnRowChanged iOldRow iNewSelectedRow
            Send SetViewAccessRights
        End_Procedure
        
        Procedure SetViewAccessRights
            Boolean bIsCustomer bIsICEmployee bIsVendor
            //
            Move (WebAppUser.Rights=10) to bIsCustomer
            Move (WebAppUser.Rights>=20 and WebAppUser.Rights<=29) to bIsVendor
            Move (WebAppUser.Rights>=30 and WebAppUser.Rights<=100) to bIsICEmployee
            //
            Set pbEditable of oWebAppUser_PropertyMgrIdno to bIsCustomer
            Set pbFocusable of oWebAppUser_PropertyMgrIdno to bIsCustomer
            Set pbEditable of oWebAppUser_EmployerIdno to (bIsICEmployee or bIsVendor)
            Set pbFocusable of oWebAppUser_EmployerIdno to (bIsICEmployee or bIsVendor)
            Set pbEditable of oWebAppUser_EmployeeIdno to (bIsICEmployee or bIsVendor)
            Set pbFocusable of oWebAppUser_EmployeeIdno to (bIsICEmployee or bIsVendor)
        End_Procedure

        Procedure OnEntering
            Forward Send OnEntering
            Send SetViewAccessRights
        End_Procedure
        
    End_Object
    
    Procedure Activate_View
        If (giUserRights GE 90) Begin
            Forward Send Activate_View
        End
        Else Begin
            Send Info_Box "You have no permission to open this view!"
        End        
    End_Procedure

Cd_End_Object
