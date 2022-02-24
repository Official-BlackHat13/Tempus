// D:\Development Projects\VDF19.1 Workspaces\Tempus\AppSrc\APForm.vw
// APForm
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use cDbCJGridColumn.pkg

Use Customer.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use cLocationAPFormGlblDataDictionary.dd
Use dfclient.pkg
Use cCJCommandBarSystem.pkg
Use Windows.pkg
Use cTextEdit.pkg
Use cDbScrollingContainer.pkg
Use dbSuggestionForm.pkg
Use cToolTipController.pkg
Use cDbTextEdit.pkg
Use cGlblDbComboForm.pkg
Use cGlblDbCheckBox.pkg
Use SalesTaxGroup.sl
Use APFormReport.rv

Activate_View Activate_oAPForm for oAPForm


Object oAPForm is a cGlblDbView
    Set Location to 63 34
    Set Size to 420 512
    Set Label to "AP Form"
    Set Border_Style to Border_Thick
    Set Maximize_Icon to True
    Set piMinSize to 0 512

    Property Boolean pbCancel True

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object 

    Object oAreas_DD is a Areas_DataDictionary
    End_Object 

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object 

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oCustomer_DD
        Set DDO_Server To oAreas_DD
        Set DDO_Server To oSalesTaxGroup_DD
        // this lets you save/prevents you from saving a new parent DD from within child DD
        Set Allow_Foreign_New_Save_State to False
    End_Object 

    Object oLocationAPForm_DD is a cLocationAPFormGlblDataDictionary
        Set DDO_Server To oLocation_DD
    End_Object 

    Set Main_DD to oLocationAPForm_DD
    Set Server to oLocationAPForm_DD

    //-----------------------------------------------------------------------
    // Create custom confirmation messages for save and delete
    // We must create the new functions and assign verify messages
    // to them.
    //-----------------------------------------------------------------------

    Function ConfirmDeleteHeader Returns Boolean
        Boolean bFail
        Get Confirm "Delete Entire Header and all detail?" to bFail
        Function_Return bFail
    End_Function 

    // Only confirm on the saving of new records
    Function ConfirmSaveHeader Returns Boolean
        Boolean bNoSave bHasRecord
        Handle  hoSrvr
        Get Server to hoSrvr
        Get HasRecord of hoSrvr to bHasRecord
        If not bHasRecord Begin
            Get Confirm "Save this NEW header?" to bNoSave
        End
        Function_Return bNoSave
    End_Function 

    // Define alternate confirmation Messages
    Set Verify_Save_MSG       to (RefFunc(ConfirmSaveHeader))
    Set Verify_Delete_MSG     to (RefFunc(ConfirmDeleteHeader))
    // Saves in header should not clear the view
    Set Auto_Clear_Deo_State to False

    Object oDbScrollingContainer1 is a cDbScrollingContainer
        
        Object oDbScrollingClientArea1 is a cDbScrollingClientArea
                        
            Object oLocationAPForm_LocationAPIdno is a cGlblDbForm
                Entry_Item LocationAPForm.LocationAPIdno
                Set Server to oLocationAPForm_DD
                Set Location to 5 7
                Set Size to 13 58
                Set Label_Col_Offset to 0
                Set Label_Justification_Mode to JMode_Right

                Procedure Refresh Integer notifyMode
                    Forward Send Refresh notifyMode
                    Boolean bHasRecord
                    //
                    Get HasRecord of oLocationAPForm_DD to bHasRecord
                    Set Enabled_State of oLockStateButton to bHasRecord
                    Set Enabled_State of oPrintButton to bHasRecord
                    Set Enabled_State of oLocation_Name to (not(bHasRecord))
                    //
                    //Update status of all required fields
                End_Procedure
            End_Object
    
            Object oLocation_Name is a DbSuggestionForm
                Entry_Item Location.Name
                Set Location to 5 68
                Set Size to 13 346
                Set Label to ""
                Set piStartAtChar to 1
                Set peAnchors to anTopLeftRight
            End_Object

            Object oLocationAPForm_ChangedDate is a cGlblDbForm
                Entry_Item LocationAPForm.ChangedDate
                Set Location to 5 419
                Set Size to 13 67
                Set Label to ""
                Set Enabled_State to False
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set peAnchors to anTopRight
            End_Object

            Object oLockStateButton is a Button
                Set Size to 15 17
                Set Location to 4 488
                Set Label to 'LockUnlock'
                Set Bitmap to "locked.bmp"
                Set peAnchors to anTopRight
            
                // fires when the button is clicked
                Procedure OnClick
                    Boolean bHasMainRecord bFail
                    Handle hoDD
                    //
                    Move oLocationAPForm_DD to hoDD
                    //
                    Get HasRecord of hoDD to bHasMainRecord
                    If (bHasMainRecord) Begin
                        Set Enabled_State of oDetailDbGroup to (not(Enabled_State(oDetailDbGroup)))
                        Set Bitmap of oLockStateButton to (If(Enabled_State(oDetailDbGroup)=True,"unlocked.bmp","locked.bmp"))
                    End
                End_Procedure
            
            End_Object

            Object oBusinessInfoDbGroup is a dbGroup
                Set Size to 101 500
                Set Location to 20 5
                Set Label to 'Business Information'
                Set Enabled_State to False
                Set peAnchors to anTopLeftRight
                
                Object oLocationInfoDbGroup is a dbGroup
                    Set Size to 85 244
                    Set Location to 11 5
                    Set Label to 'Service Location'
                    Set peAnchors to anTopLeftRight
                    Set Enabled_State to False

                    Object oLocation_Name1 is a cGlblDbForm
                        Entry_Item Location.Name
                        Set Location to 11 40
                        Set Size to 13 168
                        Set Label to "Name:"
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                    End_Object

                    Object oLocation_Address1 is a cGlblDbForm
                        Entry_Item Location.Address1
                        Set Location to 25 40
                        Set Size to 13 168
                        Set Label to "Address:"
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                    End_Object

                    Object oLocation_Address2 is a cGlblDbForm
                        Entry_Item Location.Address2
                        Set Location to 39 40
                        Set Size to 13 168
                        Set Label to ""
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                    End_Object

                    Object oLocation_City is a cGlblDbForm
                        Entry_Item Location.City
                        Set Location to 53 40
                        Set Size to 13 168
                        Set Label to "City:"
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                    End_Object

                    Object oLocation_State is a cGlblDbForm
                        Entry_Item Location.State
                        Set Location to 67 40
                        Set Size to 13 24
                        Set Label to "State/Zip:"
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                    End_Object

                    Object oLocation_Zip is a cGlblDbForm
                        Entry_Item Location.Zip
                        Set Location to 67 65
                        Set Size to 13 66
                        Set Label to ""
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                    End_Object
                    
                End_Object

                Object oCustomerDbGroup is a dbGroup
                    Set Size to 85 242
                    Set Location to 11 253
                    Set Label to "Customer Information"
                    Set peAnchors to anTopRight
                    Set piMinSize to 85 89
                    Set Enabled_State to False
            
                    Object oCustomer_Name is a cGlblDbForm
                        Entry_Item Customer.Name
                        Set Location to 10 41
                        Set Size to 13 168
                        Set Label to "Name:"
                        Set Label_Justification_Mode to JMode_Right
                        Set Label_Col_Offset to 3
                        Set peAnchors to anTopLeftRight
                    End_Object
            
                    Object oCustomer_Address1 is a cGlblDbForm
                        Entry_Item Customer.Address1
                        Set Location to 25 41
                        Set Size to 13 168
                        Set Label to "Address:"
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                        Set peAnchors to anTopLeftRight
                        Set piMinSize to 13 14
                    End_Object
            
                    Object oCustomer_Address2 is a cGlblDbForm
                        Entry_Item Customer.Address2
                        Set Location to 39 41
                        Set Size to 13 168
                        Set Label_Justification_Mode to JMode_Top
                        Set Label_Col_Offset to 0
                        Set peAnchors to anTopLeftRight
                        Set piMinSize to 13 14
                    End_Object
            
                    Object oCustomer_City is a cGlblDbForm
                        Entry_Item Customer.City
                        Set Location to 53 41
                        Set Size to 13 168
                        Set Label to "City:"
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                        Set peAnchors to anTopLeftRight
                        Set piMinSize to 13 13
                    End_Object
            
                    Object oCustomer_State is a cGlblDbForm
                        Entry_Item Customer.State
                        Set Location to 67 41
                        Set Size to 13 24
                        Set Label to "State/Zip:"
                        Set Label_Justification_Mode to JMode_Right
                        Set Label_Col_Offset to 3
                        Set peAnchors to anTopLeftRight
                        Set piMinSize to 13 1
                    End_Object
            
                    Object oCustomer_Zip is a cGlblDbForm
                        Entry_Item Customer.Zip
                        Set Location to 67 66
                        Set Size to 13 66
                        Set Label_Justification_Mode to JMode_Top
                        Set Label_Col_Offset to 0
                        Set peAnchors to anTopRight
                        Set piMinSize to 13 66
                    End_Object
                    
                    
                End_Object
                
            End_Object

//            Object oSaveConfirmButton is a Button
//                Set Size to 14 71
//                Set Location to 403 278
//                Set Label to 'Save / Confirm'
//                Set peAnchors to anBottomRight
//            
//                // fires when the button is clicked
//                Procedure OnClick
//                    
//                End_Procedure
//            
//            End_Object
//
//            Object oCancelButton is a Button
//                Set Location to 403 224
//                Set Label to 'Cancel'
//                Set peAnchors to anBottomRight
//            
//                // fires when the button is clicked
//                Procedure OnClick
//                    
//                End_Procedure
//            
//            End_Object

            Object oDetailDbGroup is a dbGroup
                Set Size to 245 500
                Set Location to 120 5
                Set peAnchors to anAll
                Set Enabled_State to False
                
                Object oBillingInfoDbGroup is a dbGroup
                    Set Size to 103 244
                    Set Location to 7 5
                    Set Label to "Billing Information"
                    Set peAnchors to anTopLeftRight
                    
                    Procedure CheckReqBillingFields Integer[] ByRef iLabelColor
                        Broadcast Recursive Send CheckRequiredFields (&iLabelColor)
                    End_Procedure
                    
                    Object oLocationAPForm_BillingName is a cGlblDbForm
                        Entry_Item LocationAPForm.BillingName
                        Set Location to 14 49
                        Set Size to 13 170
                        Set Label to "Name:"
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                        Set Label_TextColor to clBlack

                        Procedure OnChange
                            Forward Send OnChange
                            If (Length(Trim(Value(Self)))=0) Set Label_TextColor to clRed
                            Else Set Label_TextColor to clBlack 
                        End_Procedure
                        
                        
                    End_Object
            
                    Object oLocationAPForm_BillingAddress1 is a cGlblDbForm
                        Entry_Item LocationAPForm.BillingAddress1
                        Set Server to oLocationAPForm_DD
                        Set Location to 28 49
                        Set Size to 13 170
                        Set Label to "Address:"
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                        Set Label_TextColor to clBlack

                        Procedure OnChange
                            Forward Send OnChange
                            If (Length(Trim(Value(Self)))=0) Set Label_TextColor to clRed
                            Else Set Label_TextColor to clBlack 
                        End_Procedure
                    End_Object
            
                    Object oLocationAPForm_BillingAddress2 is a cGlblDbForm
                        Entry_Item LocationAPForm.BillingAddress2
            
                        Set Server to oLocationAPForm_DD
                        Set Location to 42 49
                        Set Size to 13 170
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                    End_Object
            
                    Object oLocationAPForm_BillingCity is a cGlblDbForm
                        Entry_Item LocationAPForm.BillingCity
            
                        Set Server to oLocationAPForm_DD
                        Set Location to 56 49
                        Set Size to 13 170
                        Set Label to "City:"
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                        Set Label_TextColor to clBlack

                        Procedure OnChange
                            Forward Send OnChange
                            If (Length(Trim(Value(Self)))=0) Set Label_TextColor to clRed
                            Else Set Label_TextColor to clBlack 
                        End_Procedure
                    End_Object
            
                    Object oLocationAPForm_BillingState is a cGlblDbForm
                        Entry_Item LocationAPForm.BillingState
            
                        Set Server to oLocationAPForm_DD
                        Set Location to 70 49
                        Set Size to 13 30
                        Set Label to "State"
                        Set Label_Col_Offset to 20
                        Set Label_Justification_Mode to JMode_Right
                        Set Label_TextColor to clBlack

                        Procedure OnChange
                            Forward Send OnChange
                            If (Length(Trim(Value(Self)))=0) Set Label_TextColor to clRed
                            Else Set Label_TextColor to clBlack 
                        End_Procedure
                    End_Object
            
                    Object oLocationAPForm_BillingZip is a cGlblDbForm
                        Entry_Item LocationAPForm.BillingZip
            
                        Set Server to oLocationAPForm_DD
                        Set Location to 70 80
                        Set Size to 13 66
                        Set Label to "/Zip:"
                        Set Label_Col_Offset to 35
                        Set Label_Justification_Mode to JMode_Right
                        Set Label_TextColor to clBlack

                        Procedure OnChange
                            Forward Send OnChange
                            If (Length(Trim(Value(Self)))=0) Set Label_TextColor to clRed
                            Else Set Label_TextColor to clBlack 
                        End_Procedure
                    End_Object
            
                    Object oCopyFromCustomerButton is a Button
                        Set Size to 14 171
                        Set Location to 85 48
                        Set Label to 'Copy from ...'
                    
                        // fires when the button is clicked
                        Procedure OnClick
                            Send Popup of oBillingCJContextMenu
                        End_Procedure
                    
                    End_Object
    
                    Object oBillingCJContextMenu is a cCJContextMenu
                        Object oCustomerMenuItem is a cCJMenuItem
                            Set psCaption to "Customer"
                            Set psTooltip to "Customer"
    
                            Procedure OnExecute Variant vCommandBarControl
                                Forward Send OnExecute vCommandBarControl
                                // Copy From Customer Address
                                Send Refind_Records     of oLocationAPForm_DD
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingName       to Customer.Name
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingAddress1   to Customer.Address1
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingAddress2   to Customer.Address2
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingCity       to Customer.City
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingState      to Customer.State
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingZip        to Customer.Zip
                            End_Procedure
                        End_Object
    
                        Object oLocationMenuItem is a cCJMenuItem
                            Set psCaption to "Location"
                            Set psTooltip to "Location"
    
                            Procedure OnExecute Variant vCommandBarControl
                                Forward Send OnExecute vCommandBarControl
                                // Copy From Location Address
                                Send Refind_Records     of oLocationAPForm_DD
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingName       to Location.Name
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingAddress1   to Location.Address1
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingAddress2   to Location.Address2
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingCity       to Location.City
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingState      to Location.State
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingZip        to Location.Zip
                            End_Procedure
                        End_Object
    
                        Object oAlternateMenuItem is a cCJMenuItem
                            Set psCaption to "Alternate"
                            Set psTooltip to "Alternate"
    
                            Procedure OnExecute Variant vCommandBarControl
                                Forward Send OnExecute vCommandBarControl
                                // Copy From Alternate Address
                                Send Refind_Records     of oLocationAPForm_DD
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingName       to Location.BillingName
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingAddress1   to Location.BillingAddress1
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingAddress2   to Location.BillingAddress2
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingCity       to Location.BillingCity
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingState      to Location.BillingState
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BillingZip        to Location.BillingZip
                            End_Procedure
                        End_Object
                    End_Object

                    Procedure OnEnterArea Handle hoFrom
                        Forward Send OnEnterArea hoFrom
                    End_Procedure

                End_Object
                
                Object oAPContactInfoDbGroup is a dbGroup
                    Set Size to 103 242
                    Set Location to 6 253
                    Set Label to "Accounts Payable Contact Information"
                    Set peAnchors to anTopRight
                    
                    Procedure CheckReqContactFields Integer[] ByRef iLabelColor
                        Broadcast Recursive Send CheckRequiredFields (&iLabelColor)
                    End_Procedure
                                
                    Object oLocationAPForm_BCFullName is a cGlblDbForm
                        Entry_Item LocationAPForm.BCFullName
            
                        Set Server to oLocationAPForm_DD
                        Set Location to 18 3
                        Set Size to 13 116
                        Set Label to "Name:"
                        Set Label_Col_Offset to 0
                        Set Label_Justification_Mode to JMode_Top
                        Set Label_TextColor to clBlack

                        Procedure OnChange
                            Forward Send OnChange
                            If (Length(Trim(Value(Self)))=0) Set Label_TextColor to clRed
                            Else Set Label_TextColor to clBlack 
                        End_Procedure
                    End_Object
            
                    Object oLocationAPForm_BCEmail is a cGlblDbForm
                        Entry_Item LocationAPForm.BCEmail
                        Set Server to oLocationAPForm_DD
                        Set Location to 18 122
                        Set Size to 13 116
                        Set Label to "Email:"
                        Set Label_Col_Offset to 0
                        Set Label_Justification_Mode to JMode_Top
                        Set Label_TextColor to clBlack

                        Procedure OnChange
                            Forward Send OnChange
                            If (Length(Trim(Value(Self)))=0) Set Label_TextColor to clRed
                            Else Set Label_TextColor to clBlack 
                        End_Procedure
                    End_Object

                    Object oLocationAPForm_BCCellPhone is a cGlblDbForm
                        Entry_Item LocationAPForm.BCCellPhone
                        Set Server to oLocationAPForm_DD
                        Set Location to 42 4
                        Set Size to 13 73
                        Set Label to "Cell:"
                        Set Label_Col_Offset to 0
                        Set Label_Justification_Mode to JMode_Top
                    End_Object
    
                    Object oLocationAPForm_BCOfficePhone is a cGlblDbForm
                        Entry_Item LocationAPForm.BCOfficePhone
            
                        Set Server to oLocationAPForm_DD
                        Set Location to 42 79
                        Set Size to 13 74
                        Set Label to "Office:"
                        Set Label_Col_Offset to 0
                        Set Label_Justification_Mode to JMode_Top
                        Set Label_TextColor to clBlack
                    End_Object
            
                    Object oLocationAPForm_BCOtherPhone is a cGlblDbForm
                        Entry_Item LocationAPForm.BCOtherPhone
                        Set Server to oLocationAPForm_DD
                        Set Location to 42 155
                        Set Size to 13 83
                        Set Label to "Other:"
                        Set Label_Col_Offset to 0
                        Set Label_Justification_Mode to JMode_Top
                    End_Object
            
                    Object oCopyFromContactButton is a Button
                        Set Size to 14 75
                        Set Location to 58 4
                        Set Label to 'Copy from Contact'
                    
                        // fires when the button is clicked
                        Procedure OnClick
                            Integer iContactIdno
                            Boolean bSuccess
                            Get SelectContact of Contact_sl Customer.CustomerIdno (&iContactIdno) to bSuccess
                            If (bSuccess) Begin
                                Send Refind_Records     of oLocationAPForm_DD
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BCFullName           to (Trim(Contact.FirstName) + " " + Trim(Contact.LastName))
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BCEmail              to (Contact.EmailAddress)
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BCOfficePhone        to (If(Contact.PhoneType1="M",Trim(Contact.Phone1),If(Contact.PhoneType2="M",Trim(Contact.Phone2),If(Contact.PhoneType3="M",Trim(Contact.Phone3),''))))
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BCCellPhone          to (If(Contact.PhoneType1="C",Trim(Contact.Phone1),If(Contact.PhoneType2="C",Trim(Contact.Phone2),If(Contact.PhoneType3="C",Trim(Contact.Phone3),''))))
                                Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.BCOtherPhone         to (If(Contact.PhoneType1="O",Trim(Contact.Phone1),If(Contact.PhoneType2="O",Trim(Contact.Phone2),If(Contact.PhoneType3="O",Trim(Contact.Phone3),''))))
                            End
                        End_Procedure
                    
                    End_Object

                    Object oLocationAPForm_BCAltFullName is a cGlblDbForm
                        Entry_Item LocationAPForm.BCAltFullName
            
                        Set Server to oLocationAPForm_DD
                        Set Location to 85 3
                        Set Size to 13 116
                        Set Label to "Name (Alternate):"
                        Set Label_Col_Offset to 0
                        Set Label_Justification_Mode to JMode_Top
                        Set Label_TextColor to clBlack
                    End_Object
                    
                    Object oLocationAPForm_BCAltEmail is a cGlblDbForm
                        Entry_Item LocationAPForm.BCAltEmail
                        Set Server to oLocationAPForm_DD
                        Set Location to 85 122
                        Set Size to 13 116
                        Set Label to "Email (Alternate):"
                        Set Label_Col_Offset to 0
                        Set Label_Justification_Mode to JMode_Top
                        Set Label_TextColor to clBlack
                    End_Object

                End_Object
                
                Object oSubmitInvoiceDbGroup is a dbGroup
                    Set Size to 132 244
                    Set Location to 109 5
                    Set Label to "Submit Invoice via:"
                    Set peAnchors to anTopLeftRight
    
                    Object oLocationAPForm_SendMailFlag is a cGlblDbCheckBox
                        Entry_Item LocationAPForm.SendMailFlag
                        Set Location to 13 22
                        Set Size to 10 60
                        Set Label to "Send Mail"
                    End_Object
    
                    Object oLocationAPForm_SendEmailFlag is a cGlblDbCheckBox
                        Entry_Item LocationAPForm.SendEmailFlag
                        Set Location to 13 91
                        Set Size to 10 60
                        Set Label to "Send Email"
                    End_Object
    
                    Object oLocationAPForm_ThirdPartyFlag is a cGlblDbCheckBox
                        Entry_Item LocationAPForm.ThirdPartyFlag
                        Set Location to 13 162
                        Set Size to 10 60
                        Set Label to "3rd Party / External"

                        Procedure OnChange
                            Forward Send OnChange
                            Set Enabled_State of oThirdPartyBillingGroup to (Checked_State(Self))
                        End_Procedure
                    End_Object

                    Object oThirdPartyBillingGroup is a dbGroup
                        Set Size to 100 236
                        Set Location to 29 5
                        Set Label to '3rd Party Billing'
                        Set Enabled_State to False
                        
                        Procedure CheckReqThirdPartyFields Integer[] ByRef iLabelColor
                            Broadcast Recursive Send CheckRequiredFields (&iLabelColor)
                        End_Procedure
                        
                        Object oLocationAPForm_ThirdPartyServiceName is a cGlblDbForm
                            Entry_Item LocationAPForm.ThirdPartyServiceName
                            Set Location to 11 60
                            Set Size to 13 170
                            Set Label to "Service Name:"
                            Set Label_TextColor to clBlack
                            Set Label_Col_Offset to 3
                            Set Label_Justification_Mode to JMode_Right
                            
                            Procedure OnChange
                                Forward Send OnChange
                                If (Length(Trim(Value(Self)))=0) Set Label_TextColor to clRed
                                Else Set Label_TextColor to clBlack 
                            End_Procedure
                        End_Object
    
                        Object oLocationAPForm_ThirdPartyInstructions is a cDbTextEdit
                            Entry_Item LocationAPForm.ThirdPartyInstructions
                            Set Location to 26 60
                            Set Size to 26 170
                            Set Label to "Instructions:"
                            Set Label_TextColor to clBlack
                            Set Label_Col_Offset to 3
                            Set Label_Justification_Mode to JMode_Right
                            
                            Procedure OnChange
                                Forward Send OnChange
                                If (Length(Trim(Value(Self)))=0) Set Label_TextColor to clRed
                                Else Set Label_TextColor to clBlack 
                            End_Procedure
                        End_Object
    
                        Object oLocationAPForm_ThirdPartyContactName is a cGlblDbForm
                            Entry_Item LocationAPForm.ThirdPartyContactName
                            Set Location to 53 60
                            Set Size to 13 170
                            Set Label to "Contact Name:"
                            Set Label_Col_Offset to 3
                            Set Label_Justification_Mode to JMode_Right
                        End_Object
    
                        Object oLocationAPForm_ThirdPartyContactEmail is a cGlblDbForm
                            Entry_Item LocationAPForm.ThirdPartyContactEmail
                            Set Location to 68 60
                            Set Size to 13 170
                            Set Label to "Email:"
                            Set Label_Col_Offset to 3
                            Set Label_Justification_Mode to JMode_Right
                        End_Object
    
                        Object oLocationAPForm_ThirdPartyPhone is a cGlblDbForm
                            Entry_Item LocationAPForm.ThirdPartyPhone
                            Set Location to 82 60
                            Set Size to 13 170
                            Set Label to "Phone:"
                            Set Label_Col_Offset to 3
                            Set Label_Justification_Mode to JMode_Right
                        End_Object
                    End_Object
                End_Object
                
                Object oAdditionalBillingInfoDbGroup is a dbGroup
                    Set Size to 132 242
                    Set Location to 109 254
                    Set Label to 'Additional Billing Information'
                    Set peAnchors to anTopRight

                    Procedure CheckReqAdditionalFields Integer[] ByRef iLabelColor
                        Broadcast Recursive Send CheckRequiredFields (&iLabelColor)
                    End_Procedure
                    

                    Object oLocationAPForm_BillingTerms is a cGlblDbComboForm
                        Entry_Item LocationAPForm.BillingTerms
                        Set Location to 12 50
                        Set Size to 12 188
                        Set Label to "Terms:"
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                        Set Allow_Blank_State to True
                        Set Entry_State to False
                            
                        Procedure OnChange
                            Forward Send OnChange
                            If (Length(Trim(Value(Self)))=0 or (Trim(Value(Self))="<Undefined>")) Set Label_TextColor to clRed
                            Else Set Label_TextColor to clBlack 
                        End_Procedure
                    End_Object

                    Object oSalesTaxGroup_Name is a cGlblDbForm
                        Entry_Item SalesTaxGroup.Name
                        Set Location to 27 50
                        Set Size to 13 141
                        Set Label to "Sales Tax:"
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                        Set Prompt_Button_Mode to PB_PromptOn
                            
                        Procedure OnChange
                            Forward Send OnChange
                            If (Length(Trim(Value(Self)))=0 or (Trim(Value(Self))="NOT YET SELECTED")) Set Label_TextColor to clRed
                            Else Set Label_TextColor to clBlack 
                        End_Procedure
                    End_Object

                    Object oSalesTaxGroup_Rate is a cGlblDbForm
                        Entry_Item SalesTaxGroup.Rate
                        Set Enabled_State to False
                        Set Location to 27 195
                        Set Size to 13 42
                        Set Label_Col_Offset to 3
                        Set Label_Justification_Mode to JMode_Right
                    End_Object
    
                    Object oLocationAPForm_AddtlInfoText is a cDbTextEdit
                        Entry_Item LocationAPForm.AddtlInfoText
                        Set Size to 35 230
                        Set Location to 44 8
                        //Set Status_Help to "Work Order, GI String, PID Number, PO Number, Summary of Services, Snow Sheets"
                        Set psToolTip to ("- Work Order, GI String, PID Number"+(Character(13)+Character(10))+"- Summary of Services, Snow Sheets"+(Character(13)+Character(10))+"- Client Billing Terms")          
                    End_Object
    
                    Object oExampleTextEdit is a cTextEdit
                        Set Size to 35 230
                        Set Location to 92 8
                        Set Value to ("- Work Order, GI String, PID Number"+(Character(13)+Character(10))+"- Summary of Services, Snow Sheets"+(Character(13)+Character(10))+"- Client Billing Terms")
                        Set Enabled_State to False
                        Set Label to "Examples:"
                    End_Object
                    
                End_Object              
            End_Object

            Object oSaveAndClose_btn is a Button
                Set Size to 14 62
                Set Label    to "&Save and Close"
                Set Location to 403 387
                Set peAnchors to anBottomRight
        
                Procedure OnClick
                    // Manually look for required fields and test if they have been filled out
                    Boolean bSuccess bFail bBillingReq bAPContactReq bThirdPartyReq bAdditionalReq
                    Integer[] iBillingLabelColor iAPContactLabelColor iThirdPartyBillingLabelColor iAddlLabelColor
                    Integer iFieldCount iBillingRed iAPContactRed iThirdPartyRed iAddlRed
                    Send CheckReqBillingFields of oBillingInfoDbGroup (&iBillingLabelColor)
                    For iFieldCount from 0 to (SizeOfArray(iBillingLabelColor)-1)
                        If (iBillingLabelColor[iFieldCount]=clRed) Begin
                            Increment iBillingRed
                        End
                    Loop
                    Send CheckReqContactFields of oAPContactInfoDbGroup (&iAPContactLabelColor)
                    For iFieldCount from 0 to (SizeOfArray(iAPContactLabelColor)-1)
                        If (iAPContactLabelColor[iFieldCount]=clRed) Begin
                            Increment iAPContactRed
                        End
                    Loop
                    Send CheckReqThirdPartyFields of oThirdPartyBillingGroup (&iThirdPartyBillingLabelColor)
                    For iFieldCount from 0 to (SizeOfArray(iThirdPartyBillingLabelColor)-1)
                        If (iThirdPartyBillingLabelColor[iFieldCount]=clRed) Begin
                            Increment iThirdPartyRed
                        End
                    Loop
                    Send CheckReqAdditionalFields of oAdditionalBillingInfoDbGroup (&iAddlLabelColor)
                    For iFieldCount from 0 to (SizeOfArray(iAddlLabelColor)-1)
                        If (iAddlLabelColor[iFieldCount]=clRed) Begin
                            Increment iAddlRed
                        End
                    Loop
                    //
                    If (Changed_State(oLocationAPForm_DD)) Begin
                        Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.ChangedDate to (CurrentDateTime())
                    End
                    Move (iBillingRed>=1) to bBillingReq
                    Move (iAPContactRed>=1) to bAPContactReq
                    Move (iThirdPartyRed>=1 and (Checked_State(oLocationAPForm_ThirdPartyFlag))) to bThirdPartyReq
                    Move (iAddlRed>=1) to bAdditionalReq
                    
                    If (bBillingReq or bAPContactReq or bThirdPartyReq or bAdditionalReq) Begin
                        Send Stop_Box ("Required fields missing from:"+If(bBillingReq,'\n - Billing Address','')+If(bAPContactReq,'\n - AP Contact','')+If(bThirdPartyReq,'\n - 3rd Party Billing','')+If(bAdditionalReq,'\n - Additional Billing','')) "Required Information missing!"
                        Procedure_Return
                    End
                    Else Begin
                        Get Request_Validate of oLocationAPForm_DD to bFail
                        If (not(bFail)) Begin
                            Send Request_Save
                            Set pbCancel to False
                            Send Close_Panel
                        End
                    End
                    //
                End_Procedure
        
            End_Object

            Object oSave_btn is a Button
                Set Size to 14 62
                Set Label    to "&Save"
                Set Location to 403 317
                Set peAnchors to anBottomRight
        
                Procedure OnClick
                    Boolean bFail
                    If (Changed_State(oLocationAPForm_DD)) Begin
                        Set Field_Changed_Value of oLocationAPForm_DD Field LocationAPForm.ChangedDate to (CurrentDateTime())
                    End
                    Get Request_Validate of oLocationAPForm_DD to bFail
                    If (not(bFail)) Begin
                        Send Request_Save
                    End
                End_Procedure
        
            End_Object

            Object oCancel_btn is a Button
                Set Size to 14 50
                Set Label    to "&Cancel"
                Set Location to 403 452
                Set peAnchors to anBottomRight
        
                Procedure OnClick
                   Set pbCancel to True
                   Send Close_Panel
                End_Procedure
        
            End_Object

            Object oPrintButton is a Button
                Set Size to 14 41
                Set Location to 403 5
                Set psImage to "ActionPrint.ico"
                Set Label to 'Print'
                Set peAnchors to anBottomLeft
            
                // fires when the button is clicked
                Procedure OnClick
                    Send DoJumpStartReport of oAPFormReportView LocationAPForm.LocationAPIdno True
                End_Procedure
            
            End_Object
        End_Object
    End_Object

    Procedure Activating
        Forward Send Activating
        Set Enabled_State of oDetailDbGroup to False
        Set pbCancel to True
    End_Procedure
    
    Procedure ValidateSaveView Boolean bCloseView
    End_Function
    
    Function PromptAPForm Integer iAPFormIdno Returns Boolean
        Integer eResponse
        Boolean bFail bCancel
        Handle hoDD
        //
        Set Enabled_State of oLocationAPForm_LocationAPIdno to False
        Set Enabled_State of oLocation_Name to False
        //
        Send Clear of oLocationAPForm_DD
        Move iAPFormIdno to LocationAPForm.LocationAPIdno
        Send Request_Find of oLocationAPForm_DD EQ LocationAPForm.File_Number 1
        If ((Found) and LocationAPForm.LocationAPIdno = iAPFormIdno) Begin
            Send Refind_Records of oLocationAPForm_DD
        End
        Else Begin
            //NEW Record?
            Move (YesNoCancel_Box("Looks like this Location requires a new AP Form. Create now?","New AP Form")) to eResponse
            If (eResponse = MBR_Cancel or eResponse = MBR_No) Begin
                Function_Return False
            End
            If (eResponse = MBR_Yes) Begin
                //Create new LocAPForm record
                Move oLocationAPForm_DD to hoDD
                Send Clear_All of hoDD
                Move iAPFormIdno to Location.LocationIdno
                Send Request_Find of hoDD EQ Location.File_Number 1
                Set Field_Changed_Value of hoDD Field LocationAPForm.BillingTerms to Customer.Terms
                //
                Get Request_Validate of hoDD to bFail
                If (bFail) Begin
                    Function_Return
                End
                Send Request_Save of hoDD
            End
        End
        Send Popup_Modal
        //Evaluate SAVE, SAVE and CLOSE and CANCEL button and set return value based on button clicked.
        Set Enabled_State of oLocationAPForm_LocationAPIdno to True
        Set Enabled_State of oLocation_Name to True
        Get pbCancel to bCancel
        Function_Return (not(bCancel))
    End_Function
End_Object 
