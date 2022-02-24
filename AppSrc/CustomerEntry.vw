// C:\Visual DataFlex Projects\InterstateCompanies\AppSrc\CustomerEntry.vw
// CustomerEntry
//

Use DFClient.pkg
Use DFEntry.pkg
Use dfTabDlg.pkg
Use cGlblDbComboForm.pkg
Use cGlblDbForm.pkg
Use cDbTextEdit.pkg
Use Windows.pkg
Use cTempusDbView.pkg
Use CustomerTasks.bp
Use Customer.DD


Register_Object oLocationEntry
Register_Object oContactEntry
Register_Object oCustomerEntry
Register_Object oSnowbook

Activate_View Activate_oCustomerEntry for oCustomerEntry
Object oCustomerEntry is a cTempusDbView
    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Set Main_DD to oCustomer_DD
    Set Server to oCustomer_DD

    Set Location to 8 13
    Set Size to 265 373
    Set Label to "Organization Entry/Edit"
    Set Border_Style to Border_Thick

    Object oCustomerContainer is a dbContainer3d
            Set Size to 51 355
            Set Location to 10 10
        
       Object oCustomerCustomerIdno is a dbForm
            Entry_Item Customer.CustomerIdno
            Set Size to 13 47
            Set Location to 10 61
            Set peAnchors to anLeftRight
            Set Label to "ID#/Name:"
            Set Label_Justification_mode to JMode_Right
            Set Label_Col_Offset to 3
            Set Label_row_Offset to 0

//            Procedure Prompt_Callback Integer hPrompt
//                Set Auto_Server_State of hPrompt to False
//            End_Procedure
        End_Object // oCustomerCustomer_Idno
    
        Object oCustomerName is a dbForm
            Entry_Item Customer.Name
            Set Size to 13 205
            Set Location to 10 112
            Set peAnchors to anLeftRight
            Set Label_Justification_mode to jMode_right
            Set Label_Col_Offset to 3
            Set Label_row_Offset to 0

//            Procedure Prompt_Callback Integer hPrompt
//                Set Auto_Server_State of hPrompt to False
//            End_Procedure
        End_Object // oCustomerName 

        Object oCustomer_BusinessType is a cGlblDbComboForm
            Entry_Item Customer.BusinessType
            Set Location to 26 61
            Set Size to 13 65
            Set Label to "BusinessType:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oCustomer_WebAddress is a cGlblDbForm
            Entry_Item Customer.WebAddress
            Set Location to 26 166
            Set Size to 13 149
            Set Label to "Web Site:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object
       
    End_Object

    Object oCustomerTabDialog is a dbTabDialog
        Set Size to 193 355
        Set Location to 66 10
    
        Set Rotate_Mode to RM_Rotate

        Object oDbTabPage1 is a dbTabPage
            Set Label to "Address/Phones"

            Object oCustomerAddress1 is a dbForm
                Entry_Item Customer.Address1
                Set Size to 13 187
                Set Location to 10 66
                Set peAnchors to anLeftRight
                Set Label to "Address:"
                Set Label_Justification_mode to jMode_right
                Set Label_Col_Offset to 3
                Set Label_row_Offset to 0
            End_Object // oCustomerAddress_1
            
            
            Object oCustomerAddress2 is a dbForm
                Entry_Item Customer.Address2
                Set Size to 13 186
                Set Location to 25 66
                Set peAnchors to anLeftRight
                Set Label_Justification_mode to jMode_right
                Set Label_Col_Offset to 3
                Set Label_row_Offset to 0
            End_Object // oCustomerAddress_2
        
            Object oCustomerCity is a dbForm
                Entry_Item Customer.City
                Set Size to 13 146
                Set Location to 40 66
                Set peAnchors to anLeftRight
                Set Label to "City:"
                Set Label_Justification_mode to jMode_right
                Set Label_Col_Offset to 3
                Set Label_row_Offset to 0
            End_Object // oCustomerCity
             
             Object oCustomerState is a dbForm
                Entry_Item Customer.State
                Set Size to 13 20
                Set Location to 55 66
                Set peAnchors to anLeftRight
                Set Label to "State/Zip:"
                Set Label_Justification_mode to JMode_Right
                Set Label_Col_Offset to 3
                Set Label_row_Offset to 0
            End_Object // oCustomerState
        
            Object oCustomerZip is a dbForm
                Entry_Item Customer.Zip
                Set Size to 13 66
                Set Location to 55 92
                Set peAnchors to anLeftRight
                Set Label_Justification_mode to jMode_right
                Set Label_Col_Offset to 3
                Set Label_row_Offset to 0
                Set Form_Mask to "#####-####"
            End_Object // oCustomerZip
        
            Object oCustomerPhone1 is a dbForm
                Entry_Item Customer.Phone1
                Set Size to 13 66
                Set Location to 71 66
                Set peAnchors to anLeftRight
                Set Label to "Phones:"
                Set Label_Justification_mode to jMode_right
                Set Label_Col_Offset to 3
                Set Label_row_Offset to 0
            End_Object // oCustomerPhone_1

            Object oCustomer_PhoneExt1 is a cGlblDbForm
                Entry_Item Customer.PhoneExt1
                Set Location to 70 164
                Set Size to 13 42
                Set Label to "Ext:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oCustomer_PhoneType1 is a cGlblDbComboForm
                Entry_Item Customer.PhoneType1
                Set Location to 70 246
                Set Size to 13 52
                Set Label to "Types:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object
        
            Object oCustomerPhone2 is a dbForm
                Entry_Item Customer.Phone2
                Set Size to 13 66
                Set Location to 86 66
                Set peAnchors to anLeftRight
                Set Label_Justification_mode to jMode_right
                Set Label_Col_Offset to 3
                Set Label_row_Offset to 0
            End_Object // oCustomerPhone_2

            Object oCustomer_PhoneExt2 is a cGlblDbForm
                Entry_Item Customer.PhoneExt2
                Set Location to 86 164
                Set Size to 13 42
            End_Object

            Object oCustomer_PhoneType2 is a cGlblDbComboForm
                Entry_Item Customer.PhoneType2
                Set Location to 85 246
                Set Size to 13 52
            End_Object
        
            Object oCustomerPhone3 is a dbForm
                Entry_Item Customer.Phone3
                Set Size to 13 66
                Set Location to 101 66
                Set peAnchors to anLeftRight
                Set Label_Justification_mode to jMode_right
                Set Label_Col_Offset to 3
                Set Label_row_Offset to 0
            End_Object // oCustomerPhone_3

            Object oCustomer_PhoneExt3 is a cGlblDbForm
                Entry_Item Customer.PhoneExt3
                Set Location to 101 164
                Set Size to 13 42
            End_Object

            Object oCustomer_PhoneType3 is a cGlblDbComboForm
                Entry_Item Customer.PhoneType3
                Set Location to 100 246
                Set Size to 13 52
            End_Object

            Object oCustomer_Status is a cGlblDbComboForm
                Entry_Item Customer.Status
                Set Location to 115 66
                Set Size to 13 71
                Set Label to "Status:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right

                Procedure Combo_Item_Changed
                    Integer eResponse iCustIdno
                    String sCustName sCurStatus sNewStatus
                    Get Field_Current_Value of oCustomer_DD Field Customer.CustomerIdno to iCustIdno
                    Get Field_Current_Value of oCustomer_DD Field Customer.Name to sCustName
                    Get Field_Current_Value of oCustomer_DD Field Customer.Status to sCurStatus
                    Move (YesNo_Box("This will change the status of"*sCustName*", all Locations and Contacts to"*sCurStatus*"?", "Customer Status Change", MB_DEFBUTTON2)) to eResponse
                    If (eResponse = MBR_Yes) Begin
                        Send DoChangeCustomerStatus of oCustomerTasks iCustIdno sCurStatus True False
                    End
                End_Procedure
            End_Object

            Object oEditLocationsButton is a Button
                Set Size to 14 70
                Set Location to 115 229
                Set Label to "Edit Locations"
            
                Procedure OnClick
                    Send DoEditLocations
                End_Procedure
            End_Object

            Object oButton1 is a Button
                Set Size to 14 70
                Set Location to 115 152
                Set Label to "Edit Contacts"
                Set peAnchors to anTopRight
            
                // fires when the button is clicked
                
                    Procedure OnClick
                        Send DoEditContacts of oContactEntry (Current_Record(oCustomer_DD))                                          
                End_Procedure
            
            End_Object

            Object oCustomer_Terms is a cGlblDbComboForm
                Entry_Item Customer.Terms
                Set Location to 132 66
                Set Size to 12 234
                Set Label to "Terms:"
                Set Label_Col_Offset to 5
                Set Label_Justification_Mode to JMode_Right
            End_Object


            Object oCustomer_PORequired1 is a cGlblDbCheckBox
                Entry_Item Customer.PORequired
                Set Location to 150 67
                Set Size to 13 18
                Set Label to "PO Required"
            End_Object
        
        End_Object

        Object oContactTabPage is a dbTabPage
            Set Label to "Accounting Contact"

            Object oCustomer_ContactName is a cGlblDbForm
                Entry_Item Customer.ContactName
                Set Location to 10 66
                Set Size to 13 226
                Set Label to "Name:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oCustomer_ContactPhn1 is a cGlblDbForm
                Entry_Item Customer.ContactPhn1
                Set Location to 25 66
                Set Size to 13 62
                Set Label to "Phones:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oCustomer_ContactPhnExt1 is a cGlblDbForm
                Set Location to 25 157
                Entry_Item Customer.ContactPhnExt1
                Set Size to 13 42
                Set Label to "Ext:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oCustomer_ContactPhnType1 is a cGlblDbComboForm
                Entry_Item Customer.ContactPhnType1
                Set Location to 25 240
                Set Size to 13 52
                Set Label to "Types:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oCustomer_ContactPhn2 is a cGlblDbForm
                Entry_Item Customer.ContactPhn2
                Set Location to 40 66
                Set Size to 13 62
            End_Object

            Object oCustomer_ContactPhnExt2 is a cGlblDbForm
                Entry_Item Customer.ContactPhnExt2
                Set Location to 40 157
                Set Size to 13 42
            End_Object

            Object oCustomer_ContactPhnType2 is a cGlblDbComboForm
                Entry_Item Customer.ContactPhnType2
                Set Location to 40 240
                Set Size to 13 52
            End_Object

            Object oCustomer_ContactEmail is a cGlblDbForm
                Entry_Item Customer.ContactEmail
                Set Location to 55 66
                Set Size to 13 226
                Set Label to "Email:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oCustomer_ContactComment is a cDbTextEdit
                Entry_Item Customer.ContactComment
                Set Location to 70 66
                Set Size to 45 226
                Set Label to "Comment:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3

                Procedure Next
                    Send Request_Save
                    Forward Send Next
                End_Procedure
            End_Object

        End_Object
    
    End_Object

    Procedure DoCreateCustomer
        Send Clear_All    of oCustomer_DD
        Send Activate_View
    End_Procedure

    Procedure DoEditCustomers Integer iRecId
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

    Procedure DoEditCustomerID Integer iId
        Integer hoDD
        //
        Get Server to hoDD
        If (Changed_State(hoDD)) Begin
            Send Request_Save
        End
        Send Clear_All of hoDD
        Move iId to Customer.CustomerIdno
        Send Find      of hoDD eq 1
//        Send Popup_Modal
        Send Activate_View
    End_Procedure

    Procedure DoEditLocations
        Send DoEditLocations of oLocationEntry (Current_Record(oCustomer_DD))
    End_Procedure

    Procedure Request_Delete
    End_Procedure

    Procedure DoDeleteCustomer
        Forward Send Request_Delete
    End_Procedure
        
    //
    //On_Key kUser Send DoDeleteCustomer
 
End_Object // oCustomerEntry

