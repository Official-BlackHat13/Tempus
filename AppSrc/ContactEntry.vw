Use Windows.pkg
Use DFClient.pkg
Use dfTabDlg.pkg
Use dfLine.pkg
Use DFEntry.pkg
Use cGlblDbComboForm.pkg
Use cTempusDbView.pkg
Use cGlblDbForm.pkg
Use dfTable.pkg
Use Customer.DD
Use SalesRep.DD
Use Contact.DD
Use cMaillistDataDictionary.dd
Use cListlinkDataDictionary.dd
Use cSnowrepDataDictionary.dd
Use Areas.DD
Use Location.DD
Use cQuotehdrDataDictionary.dd
Use MastOps.DD
Use cQuotedtlDataDictionary.dd
Use Order.DD
Use pminvhdr.dd
Use cJcdeptDataDictionary.dd
Use cJccntrDataDictionary.dd
Use JCOPER.DD
Use pminvdtl.dd
Use cMarketGroupGlblDataDictionary.dd
Use cMarketMemberGlblDataDictionary.dd
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use User.DD
Use cWebAppUserRightsGlblDataDictionary.dd
Use cWebAppUserDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use ContactPassword.DG
Use cDbTextEdit.pkg
Use cCrystalActiveXReportViewer.pkg
Use cCrystal.pkg
Use cDbCJGrid.pkg
Use SalesRep.sl
Use cGlblDbCheckBox.pkg
//Use dbSuggestionForm.pkg
Use Functions.pkg
Use UserInputDialog.dg

Use PropertyManagerServiceContactReport.rv
Use PropertyManagerPhoneInstructions_AndroidReport.rv
Use PropertyManagerPhoneInstructions_iPhoneReport.rv

Activate_View Activate_oContactEntry for oContactEntry
Object oContactEntry is a cTempusDbView
    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
    End_Object

    Object oWebAppUser_DD is a cWebAppUserDataDictionary
        Set DDO_Server to oWebAppUserRights_DD
    End_Object

    Object oUser_DD is a User_DataDictionary
    End_Object

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Object oMarketGroup_DD is a cMarketGroupGlblDataDictionary
    End_Object

    Object oJcdept_DD is a cJcdeptDataDictionary
    End_Object

    Object oJccntr_DD is a cJccntrDataDictionary
        Set DDO_Server to oJcdept_DD
    End_Object

    Object oJcoper_DD is a Jcoper_DataDictionary
        Set DDO_Server to oJccntr_DD
    End_Object

    Object oMastops_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oMaillist_DD is a cMaillistDataDictionary
    End_Object

    Object oSalesrep_DD is a Salesrep_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesrep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oContact_DD is a Contact_DataDictionary
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oCustomer_DD
        Set Cascade_Delete_State to True
        Set Field_Auto_Increment Field Contact.Contactidno to File_Field System.Lastcontact



        Function Validate_Delete Returns Integer
            Integer iRetval
            //
            Forward Get Validate_Delete to iRetval
            //
            If (not(iRetval)) Begin
                Attach Quotehdr
                Find ge Quotehdr.ContactIdno
                If ((Found) and Quotehdr.ContactIdno = Contact.ContactIdno) Begin
                    Send UserError "This Contact has Quotes" "Validation Error"
                    Move 1 to iRetval
                End
            End
            Function_Return iRetval
        End_Function

        Procedure Relate_Main_File
            Boolean bMustFind
            Integer iStatus
            //
            Forward Send Relate_Main_File
            //
            Get_Attribute DF_FILE_STATUS of WebAppUser.File_Number to iStatus
         
            If (iStatus = DF_FILE_INACTIVE) Begin
                Move True to bMustFind
            End
            Else If (Contact.ContactIdno <> WebAppUser.PropertyMgrIdno) Begin 
                Move True to bMustFind
            End 
        
            If bMustFind Begin // relate to SoftTable only if required
                Clear WebAppUser
                Move Contact.ContactIdno to WebAppUser.PropertyMgrIdno
                Find GE WebAppUser.PropertyMgrIdno
                If ((Found) and WebAppUser.PropertyMgrIdno = Contact.ContactIdno) Begin
                End
                Else Begin
                    Clear WebAppUser
                End
            End
        
            Get_Attribute DF_FILE_STATUS of WebAppUser.File_Number to iStatus
            If (iStatus<>DF_FILE_INACTIVE) Begin
                Send Request_Relate WebAppUser.File_Number
            End
            Else Begin
                Send Request_Clear_File WebAppUser.File_Number
                Send Request_Clear_File WebAppUserRights.File_Number
            End
        End_Procedure

    End_Object

    Object oMarketMember_DD is a cMarketMemberGlblDataDictionary
        Set DDO_Server to oMarketGroup_DD
        Set Constrain_file to Contact.File_number
        Set DDO_Server to oContact_DD
    End_Object

    Object opminvhdr_DD is a pminvhdr_DataDictionary
        Set Constrain_file to Contact.File_number
        Set DDO_Server to oContact_DD
        Set DDO_Server to oOrder_DD
    End_Object

    Object opminvdtl_DD is a pminvdtl_DataDictionary
        Set DDO_Server to oJcoper_DD
        Set Constrain_file to pminvhdr.File_number
        Set DDO_Server to opminvhdr_DD
    End_Object

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set Constrain_file to Contact.File_number
        Set DDO_Server to oContact_DD
        Set DDO_Server to oSalesrep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oQuotedtl_DD is a cQuotedtlDataDictionary
        Set DDO_Server to oMastops_DD
        Set Constrain_file to Quotehdr.File_number
        Set DDO_Server to oQuotehdr_DD
    End_Object

    Object oListlink_DD is a cListlinkDataDictionary
        Set DDO_Server to oMaillist_DD
        Set Constrain_file to Contact.File_number
        Set DDO_Server to oContact_DD
    End_Object

    Set Main_DD to oContact_DD
    Set Server to oContact_DD

    Set Border_Style to Border_Thick
    Set Size to 272 345
    Set Location to 3 4
    Set label to "Contact Entry/Edit"

    Object oContactContainer is a dbContainer3d
        Set Size to 100 338
        Set Location to 2 3

        Object oCustomer_Name is a dbForm
            Entry_Item Customer.Name
            Set Location to 9 71
            Set Size to 13 198
            Set Label to "Customer Name / #:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oCustomer_CustomerIdno is a dbForm
            Entry_Item Customer.CustomerIdno
            Set Location to 9 271
            Set Size to 13 46
        End_Object

        Object oContact_FirstName is a dbForm
            Entry_Item Contact.FirstName
            Set Location to 24 71
            Set Size to 13 86
            Set Label to "First, MI, Last / #"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oContact_MiddleInitial is a cGlblDbForm
            Entry_Item Contact.MiddleInitial
            Set Location to 24 162
            Set Size to 13 16
        End_Object

        Object oContact_LastName is a dbForm
            Entry_Item Contact.LastName
            Set Location to 24 181
            Set Size to 13 88
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to  3
        End_Object

        Object oContact_ContactIdno is a dbForm
            Entry_Item Contact.ContactIdno
            Set Location to 25 271
            Set Size to 13 46

            Procedure Prompt
                Boolean bSelected
                Handle  hoServer
                RowID   riContact riCustomer
                //
                Get Server                            to hoServer
                Move (GetRowID(Contact.File_Number )) to riContact
                Move (GetRowId(Customer.File_Number)) to riCustomer
                //
                Get IsSelectedContact of Contact_sl (&riContact) (&riCustomer) to bSelected
                //
                If  (bSelected and not(IsNullRowId(riContact))) Begin
                    Send FindByRowId of hoServer Contact.File_Number riContact
                End
            End_Procedure

            Procedure Refresh Integer notifyMode
                Boolean bHasWebAppUserRecord
                Move (WebAppUser.PropertyMgrIdno<>0) to bHasWebAppUserRecord
                Forward Send Refresh notifyMode
                Set Enabled_State of oGeneratePasswordButton to (bHasWebAppUserRecord)
                Set Enabled_State of oGernerateUserButton to (not(bHasWebAppUserRecord))
                Set Enabled_State of oWebAppUser_LoginName to (bHasWebAppUserRecord)
                Set Enabled_State of oChangePasswordButton to (bHasWebAppUserRecord)
                Set Enabled_State of oServiceContactButton to (bHasWebAppUserRecord)
                Set Enabled_State of oiPhoneInstructionsButton to (bHasWebAppUserRecord)
                Set Enabled_State of oAndroidInstructionsButton to (bHasWebAppUserRecord)
            End_Procedure
            
        End_Object

        Object oContact_Status is a cGlblDbComboForm
            Entry_Item Contact.Status
            Set Location to 41 71
            Set Size to 12 46
            Set Label to "Status:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oContact_Title is a dbForm
            Entry_Item Contact.Title
            Set Location to 41 160
            Set Size to 13 157
            Set Label to "Job Title:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oPrimSalesRep_RepIdno is a cGlblDbForm
            Entry_Item Contact.RepIdno
            Set Location to 56 71
            Set Size to 13 54
            Set Label to "Prim Sales Rep:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Prompt_Button_Mode to PB_PromptOn
            
            
            Procedure Prompt
                Integer iContactRec iRepIdno iSecSlsRep
                String sSlsRepName
                Boolean bRepSelected
                //
                Move Contact.RepIdno to iRepIdno
                Get IsSelectedSalesRep of SalesRep_sl (&iRepIdno) (&sSlsRepName) to bRepSelected
                If (bRepSelected) Begin
                    Set Field_Changed_Value of oContact_DD Field Contact.RepIdno       to iRepIdno
                    Set Value               of oPrimSalesRep_Name                      to sSlsRepName
                End
//                    Else Begin
//                        Set Field_Changed_Value of oContact_DD Field Contact.RepIdno       to iRepIdno
//                        Set Value               of oPrimSalesRep_Name                      to sSlsRepName
//                    End
            End_Procedure
                
            Procedure Refresh Integer iMode
                Integer hoDD iSlsRepIdno
                Get Main_DD to hoDD
                //
                Forward Send Refresh iMode
                //
                Move Contact.RepIdno to iSlsRepIdno
                If (iSlsRepIdno <> 0) Begin
                    Clear SalesRep
                    Move iSlsRepIdno to SalesRep.RepIdno
                    Find EQ SalesRep by Index.1
                    If (Found) Begin
                        Set Value of oPrimSalesRep_Name to (SalesRep.FirstName * SalesRep.LastName)
                    End
                    Else Begin
                        Set Value of oPrimSalesRep_Name to ""
                    End
                End
                Else Begin
                    Set Value of oPrimSalesRep_Name to ""  
                End           
            End_Procedure
            
            
        End_Object

        Object oPrimSalesRep_Name is a cGlblDbForm
            Set Location to 56 128
            Set Size to 13 189
            Set Enabled_State to False
        End_Object

        Object oSecSlsRep_RepIdno is a cGlblDbForm
            Entry_Item Contact.SnowRepIdno
            Set Location to 72 71
            Set Size to 13 54
            Set Label to "Sec Sales Rep:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Prompt_Button_Mode to PB_PromptOn
            
            Procedure Prompt
                Integer iContactRec iRepIdno iSecSlsRep
                String sSlsRepName
                Boolean bRepSelected
                //
                Move Contact.SnowRepIdno to iRepIdno

                Get IsSelectedSalesRep of Salesrep_sl (&iRepIdno) (&sSlsRepName) to bRepSelected
                If (bRepSelected) Begin
                    Set Field_Changed_Value of oContact_DD Field Contact.SnowRepIdno   to iRepIdno
                    Set Value               of oSecSlsRep_Name                         to sSlsRepName
                End
                Else Begin
                    Set Field_Changed_Value of oContact_DD Field Contact.SnowRepIdno   to iRepIdno
                    Set Value               of oSecSlsRep_Name                         to sSlsRepName
                End
            End_Procedure
            
            Procedure Refresh Integer iMode
                Integer hoDD iSlsRepIdno
                Get Main_DD to hoDD
                //
                Forward Send Refresh iMode
                //
                Move Contact.SnowRepIdno to iSlsRepIdno
                If (iSlsRepIdno <> 0) Begin
                    Clear SalesRep
                    Move iSlsRepIdno to SalesRep.RepIdno
                    Find EQ SalesRep by Index.1
                    If (Found) Begin
                        Set Value of oSecSlsRep_Name to (SalesRep.FirstName * SalesRep.LastName)
                    End
                    Else Begin
                        Set Value of oSecSlsRep_Name to ""
                    End
                End
                Else Begin
                    Set Value of oSecSlsRep_Name to ""  
                End           
            End_Procedure
            
        End_Object

        Object oSecSlsRep_Name is a cGlblDbForm
            Set Location to 72 128
            Set Size to 13 189
            Set Enabled_State to False
        End_Object
    End_Object

    Object oContactTabDialog is a dbTabDialog
        Set Size to 160 339
        Set Location to 106 3
    
        Set Rotate_Mode to RM_Rotate

        Object oInfoTabPage is a dbTabPage
            Set Label to "Address/Phones"

            Object oContact_Address1 is a dbForm
                Entry_Item Contact.Address1
                Set Location to 10 66
                Set Size to 13 182
                Set Label to "Address:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oContact_Address2 is a dbForm
                Entry_Item Contact.Address2
                Set Location to 25 66
                Set Size to 13 182
            End_Object

            Object oContact_City is a dbForm
                Entry_Item Contact.City
                Set Location to 40 66
                Set Size to 13 136
                Set Label to "City:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oContact_State is a dbForm
                Entry_Item Contact.State
                Set Location to 55 66
                Set Size to 13 24
                Set Label to "State/Zip:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oContact_Zip is a dbForm
                Entry_Item Contact.Zip
                Set Location to 55 96
                Set Size to 13 66
            End_Object

            Object oContact_Phone1 is a dbForm
                Entry_Item Contact.Phone1
                Set Location to 70 66
                Set Size to 13 62
                Set Label to "Phones:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oContact_PhoneExt1 is a cGlblDbForm
                Entry_Item Contact.PhoneExt1
                Set Location to 70 154
                Set Size to 13 42
                Set Label to "Ext:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oContact_PhoneType1 is a cGlblDbComboForm
                Entry_Item Contact.PhoneType1
                Set Location to 70 230
                Set Size to 13 52
                Set Label to "Types:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oContact_Phone2 is a dbForm
                Entry_Item Contact.Phone2
                Set Location to 85 66
                Set Size to 13 62
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oContact_PhoneExt2 is a cGlblDbForm
                Entry_Item Contact.PhoneExt2
                Set Location to 85 154
                Set Size to 13 42
            End_Object

            Object oContact_PhoneType2 is a cGlblDbComboForm
                Entry_Item Contact.PhoneType2
                Set Location to 85 230
                Set Size to 13 52
            End_Object

            Object oContact_Phone3 is a dbForm
                Entry_Item Contact.Phone3
                Set Location to 100 66
                Set Size to 13 62
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oContact_PhoneExt3 is a cGlblDbForm
                Entry_Item Contact.PhoneExt3
                Set Location to 100 154
                Set Size to 13 42
            End_Object

            Object oContact_PhoneType3 is a cGlblDbComboForm
                Entry_Item Contact.PhoneType3
                Set Location to 100 230
                Set Size to 13 52
            End_Object

            Object oContact_EmailAddress is a dbForm
                Entry_Item Contact.EmailAddress
                Set Location to 115 66
                Set Size to 13 148
                Set Label to "Email:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                
            End_Object

            Object oCloneButton is a cGlblButton
                Set Size to 14 107
                Set Location to 40 218
                Set Label to "Clone Customer Information"

                Procedure OnClick
                    Send Refind_Records     of oContact_DD
                    Set Field_Changed_Value of oContact_DD Field Contact.Address1   to Customer.Address1
                    Set Field_Changed_Value of oContact_DD Field Contact.Address2   to Customer.Address2
                    Set Field_Changed_Value of oContact_DD Field Contact.City       to Customer.City
                    Set Field_Changed_Value of oContact_DD Field Contact.State      to Customer.State
                    Set Field_Changed_Value of oContact_DD Field Contact.Zip        to Customer.Zip
                    Set Field_Changed_Value of oContact_DD Field Contact.Phone1     to Customer.Phone1
                    Set Field_Changed_Value of oContact_DD Field Contact.PhoneType1 to Customer.PhoneType1
                    Set Field_Changed_Value of oContact_DD Field Contact.Phone2     to Customer.Phone2
                    Set Field_Changed_Value of oContact_DD Field Contact.PhoneType2 to Customer.PhoneType2
                    Set Field_Changed_Value of oContact_DD Field Contact.Phone3     to Customer.Phone3
                    Set Field_Changed_Value of oContact_DD Field Contact.PhoneType3 to Customer.PhoneType3
                End_Procedure // OnClick

            End_Object

            Object oContact_FollowUpFlag is a cGlblDbCheckBox
                Entry_Item Contact.FollowUpFlag
                Set Location to 116 232
                Set Size to 10 60
                Set Label to "FollowUp"
            End_Object
        End_Object

        Object oServiceCenterTabPage is a dbTabPage
            Set Label to "Customer Portal"
            Set Enabled_State to True

            Object oWebAppUser_LoginName is a cGlblDbForm
                Entry_Item WebAppUser.LoginName
                Set Location to 38 3
                Set Size to 13 140
                Set Label to "LoginName:"
                Set Label_Justification_Mode to JMode_Top
                Set Label_Col_Offset to 0
            End_Object

            Object oWebAppUser_FullName is a cGlblDbForm
                Entry_Item WebAppUser.FullName
                Set Location to 12 3
                Set Size to 13 141
                Set Label to "FullName:"
                Set Label_Justification_Mode to JMode_Top
                Set Label_Col_Offset to 0
                Set Enabled_State to False
            End_Object

            Object oWebAppUserRights_Description is a cGlblDbForm
                Entry_Item WebAppUserRights.Description
                Set Location to 12 145
                Set Size to 13 186
                Set Label to "Description:"
                Set Label_Justification_Mode to JMode_Top
                Set Label_Col_Offset to 0
                Set Enabled_State to False
            End_Object

            Object oWebAppUser_Password is a cGlblDbForm
                Entry_Item WebAppUser.Password
                Set Enabled_State to False
                Set Location to 38 146
                Set Size to 13 183
                Set Label to "Password:"
                Set Label_Justification_Mode to JMode_Top
                Set Label_Col_Offset to 0
                Set Password_State to True
            End_Object

            Object oGernerateUserButton is a Button
                Set Size to 14 140
                Set Location to 55 3
                Set Label to 'Gernerate Username'
            
                // fires when the button is clicked
                Procedure OnClick
                    String sUserName sNewPass
                    If (Trim(WebAppUser.LoginName)="" and WebAppUser.PropertyMgrIdno=0) Begin
                        Get GeneratePropMgrUsername Contact.FirstName Contact.LastName to sUserName
                        Get GenerateRandomPassword 6 False True True True to sNewPass
                        Open WebAppUser
                        Clear WebAppUser
                        Lock
                            Move sUserName                                              to WebAppUser.LoginName
                            Move 10                                                     to WebAppUser.Rights
                            Move (Trim(Contact.FirstName) * Trim(Contact.LastName))     to WebAppUser.FullName
                            Move (Contact.ContactIdno)                                  to WebAppUser.PropertyMgrIdno
                            Move 0                                                      to WebAppUser.EmployeeIdno
                            Move 0                                                      to WebAppUser.EmployerIdno
                            Move sNewPass                                               to WebAppUser.Password
                            Move 1                                                      to WebAppUser.ChangedFlag
                            Move 1                                                      to WebAppUser.BillingAccessFlag
                            Move "A"                                                    to WebAppUser.Status
                            SaveRecord WebAppUser
                        Unlock
                        Send Request_Find of oContact_ContactIdno EQ True
                    End
                End_Procedure
            
            End_Object

            Object oChangePasswordButton is a Button
                Set Size to 14 90
                Set Location to 55 146
                Set Label to 'Change Password'
            
                // fires when the button is clicked
                Procedure OnClick
                    String sNewPass
                    Get PopupUserInput of oUserInputDialog "Change Password" "Please enter user password." "" True to sNewPass
                    Reread WebAppUser
                        //Set Value of oWebAppUser_Password to sNewPass
                        Move sNewPass to WebAppUser.Password
                        Move 1 to WebAppUser.ChangedFlag
                        SaveRecord WebAppUser
                    Unlock
                    Send Request_Find of oContact_ContactIdno EQ True
                    Send Info_Box ("The users password was changed to:"*sNewPass)
                End_Procedure
            
            End_Object

            Object oGeneratePasswordButton is a Button
                Set Size to 14 89
                Set Location to 55 238
                Set Label to 'Generate Password'
            
                // fires when the button is clicked
                Procedure OnClick
                    Integer iPropMgrIdno
                    String sNewPass
                    If (WebAppUser.PropertyMgrIdno = Contact.ContactIdno) Begin
                        Reread WebAppUser
                            Get GenerateRandomPassword 6 False True True True to sNewPass
                            Move sNewPass to WebAppUser.Password
                            Move 1 to WebAppUser.ChangedFlag
                            SaveRecord WebAppUser
                        Unlock
                        Send Info_Box ("Password has been changed to:"* sNewPass) "Password Change"
                    End
                    Send Request_Find of oContact_ContactIdno EQ True
                End_Procedure
            
            End_Object

            Object oPrintGroup is a Group
                Set Size to 58 99
                Set Location to 73 5
                Set Label to 'Print'

                Object oServiceContactButton is a Button
                    Set Size to 14 81
                    Set Location to 9 9
                    Set Label to 'Service Contact'
                
                    // fires when the button is clicked
                    Procedure OnClick
                        Send DoJumpStartReport of oPropertyManagerServiceContactReportView Contact.ContactIdno
                    End_Procedure
                
                End_Object

                Object oiPhoneInstructionsButton is a Button
                    Set Size to 14 81
                    Set Location to 23 9
                    Set Label to 'iPhone Instructions'
                    Set Enabled_State to False
                
                    // fires when the button is clicked
                    Procedure OnClick
                        Send DoJumpStartReport of oPropertyManagerPhoneInstructions_iPhoneReportView
                    End_Procedure
                
                End_Object

                Object oAndroidInstructionsButton is a Button
                    Set Size to 14 81
                    Set Location to 38 9
                    Set Label to 'Android Instructions'
                
                    // fires when the button is clicked
                    Procedure OnClick
                        Send DoJumpStartReport of oPropertyManagerPhoneInstructions_AndroidReportView
                    End_Procedure
                
                End_Object
                
                
                
            End_Object

        End_Object
    
        Procedure Request_Switch_To_Tab integer iPage integer iMode
            Boolean bChanged bBirth bDeath bStatus bNochange
            Integer hoDD
            //
            If ((iPage) and not(Current_Record(oContact_DD))) Begin
                Send Stop_Box "First select a Contact record"
                Procedure_Return
            End
            //
            If (iPage = 3) Begin
//                Send DoFillLocationGrid of oLocationsGrid
            End
            If (iPage = 4) Begin
//                Send DoFillQuoteGrid of oQuoteGrid
            End
            //
           Forward Send Request_Switch_To_Tab iPage iMode
            //
        End_Procedure

        Object oDbTabPage1 is a dbTabPage
            Set Label to 'Hobbies'

            Object oContact_Hobbies is a cDbTextEdit
                Entry_Item Contact.Hobbies
                Set Location to 20 32
                Set Size to 88 273
                Set Label to "Hobbies:"
            End_Object
        End_Object

        Object oDbTabPage2 is a dbTabPage
            Set Label to 'Misc. Notables'

            Object oContact_MiscNotes is a cDbTextEdit
                Entry_Item Contact.MiscNotes
                Set Location to 17 23
                Set Size to 82 289
                Set Label to "MiscNotes:"
            End_Object

            Object oContact_BirthMonth is a cGlblDbForm
                Entry_Item Contact.BirthMonth
                Set Location to 103 93
                Set Size to 13 18
                Set Label to "Birth Month/Date:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oContact_BirthDate is a cGlblDbForm
                Entry_Item Contact.BirthDate
                Set Location to 103 115
                Set Size to 13 18
            End_Object
        End_Object

        Object oDbTabPage3 is a dbTabPage
            Set Label to 'Marketing Groups'

            Object oDbCJGrid1 is a cDbCJGrid
                Set Server to oMarketMember_DD
                Set Size to 129 325
                Set Location to 5 5

//                Object oMarketGroup_MktGroupIdno is a cDbCJGridColumn
//                    Entry_Item MarketGroup.MktGroupIdno
//                    Set piWidth to 72
//                    Set psCaption to "Id"
//                    
//                    Procedure Prompt
//                        Integer iRecId
//                        String sDescription
//                        Get Current_Record of oMarketGroup_DD to iRecId
//                        Forward Send Prompt
//                       
////                        If (Current_Record(oMarketMember_DD) <> iRecId) Begin
//                            Set Field_Changed_Value of oMarketMember_DD Field MarketMember.GroupName    to MarketGroup.GroupName
////                        End
//                    End_Procedure
//                End_Object

                Object oMarketGroup_GroupName is a cDbCJGridColumn
                    Entry_Item MarketGroup.GroupName
                    Set piWidth to 360
                    Set psCaption to "Group Name"
                End_Object
            End_Object
            
            
        End_Object

    End_Object

    Procedure DoCreateContact Integer iCustomerIdno
        Send Activate_View
        Send Clear_All    of oContact_DD
        Move iCustomerIdno to Customer.CustomerIdno
        Send Request_Find of oContact_DD EQ Customer.File_Number 1
    End_Procedure

    Procedure DoDisplayContact Integer iRecId
        Send Activate_View
        Send Clear_All      of oContact_DD
        Send Find_By_Recnum of oContact_DD Contact.File_Number iRecId
    End_Procedure

    Procedure DoDisplaySalesReps Integer iContactIdno
        Send Activate_View
        Send Clear_All           of oContact_DD
        Set Constrain_File       of oContact_DD to 0
        Send Rebuild_Constraints of oContact_DD
        Move iContactIdno                       to Contact.ContactIdno
        Send Find                of oContact_DD EQ 2
        Set Constrain_File       of oContact_DD to Customer.File_Number
        Send Rebuild_Constraints of oContact_DD
    End_Procedure
    
    Procedure DoEditContacts Integer iRecId
        Integer hoDD
        //
        Get Server to hoDD
        If (Changed_State(hoDD)) Begin
            Send Request_Save
        End
        Send Clear_All      of hoDD
        Send Find_By_Recnum of hoDD Customer.File_Number iRecId
        Send Activate_View
    End_Procedure

End_Object

