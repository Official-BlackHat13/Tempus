Use Windows.pkg
Use DFClient.pkg
Use dfTabDlg.pkg
Use dfLine.pkg
Use Customer.DD
Use Location.DD
Use Areas.DD
Use Contact.DD
Use Order.DD
Use cLocnotesDataDictionary.dd
Use cParklotsDataDictionary.dd
Use cLotaccesDataDictionary.dd
Use SalesRep.DD
Use cQuotehdrDataDictionary.dd
Use MastOps.DD
Use cQuotedtlDataDictionary.dd
Use Invhdr.DD
Use Opers.DD
Use Invdtl.DD
Use Employer.DD
Use Employee.DD
Use Trans.DD
Use cSnowrepDataDictionary.dd
Use cProjectDataDictionary.dd
Use cReqtypesDataDictionary.dd
Use cJobcostsDataDictionary.dd
Use cLocequipDataDictionary.dd
Use DFEntry.pkg
Use cTempusDbView.pkg
Use cGlblDbComboForm.pkg
Use cGlblButton.pkg
Use cGlblDbForm.pkg
Use cDbTextEdit.pkg
Use cGlblDbCheckBox.pkg
Use cSzTime.pkg
Use dfSelLst.pkg
//Use ParkingLot.dg
Use Propmgr.sl
Use cDbCJGrid.pkg


Register_Object oCustomerEntry
Register_Object oContactEntry

Activate_View Activate_oSnowbook for oSnowbook
Object oSnowbook is a cTempusDbView
    Object oReqtypes_DD is a cReqtypesDataDictionary
    End_Object

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oEmployer_DD
    End_Object

    Object oMastops_DD is a Mastops_DataDictionary
    End_Object

    Object oSalesrep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
        Procedure OnConstrain
            Constrain Customer.Status eq "A"
        End_Procedure
    End_Object

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesrep_DD
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
        Set Constrain_File to Customer.File_Number

//        Procedure Relate_Main_File
//            Boolean bMustFind
//            Integer iStatus
//        
//            Get_Attribute DF_FILE_STATUS of Location.File_Number to iStatus
//         
//            Forward Send Relate_Main_File
//        
//            If (iStatus = DF_FILE_INACTIVE) Begin
//                Move True to bMustFind
//            End
//            Else If (Location.PropmgrIdno <> Propmgr.ContactIdno) Begin 
//                Move True to bMustFind
//            End 
//        
//            If (bMustFind) Begin
//                Clear Propmgr
//                Move Location.PropmgrIdno to Propmgr.ContactIdno
//                Find eq Propmgr.ContactIdno
//            End
//        
//            Get_Attribute DF_FILE_STATUS of Propmgr.File_Number to iStatus
//            If (iStatus <> DF_FILE_INACTIVE) Begin
////                Send Request_Assign of oPropmgr_DD Propmgr.File_Number
////                Send Request_Relate Propmgr.File_Number
//            End
//            Else Begin
//                Clear Propmgr
////                Send Request_Clear_File Propmgr.File_Number
//            End
//        End_Procedure  // Relate_Main_File

        Function Validate_Delete Returns Integer
            Integer iRetval
            //
            Forward Get Validate_Delete to iRetval
            //
            If (not(iRetval)) Begin
                Attach Order
                Find ge Order.LocationIdno
                If ((Found) and Order.LocationIdno = Location.LocationIdno) Begin
                    Send UserError "This Location has Orders" "Validation Error"
                    Move 1 to iRetval
                End
                //
                Attach Quotehdr
                Find ge Quotehdr.LocationIdno
                If ((Found) and Quotehdr.LocationIdno = Location.LocationIdno) Begin
                    Send UserError "This Location has Quotes" "Validation Error"
                    Move 1 to iRetval
                End
            End
            Function_Return iRetval
        End_Function
    End_Object

    Object oLocequip_DD is a cLocequipDataDictionary
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD
    End_Object

    Object oProject_DD is a cProjectDataDictionary
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oMastops_DD
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD
        Set Cascade_Delete_State to True
    End_Object

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set DDO_Server to oContact_DD
        Set DDO_Server to oSalesrep_DD
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD
    End_Object

    Object oQuotedtl_DD is a cQuotedtlDataDictionary
        Set DDO_Server to oMastops_DD
        Set Constrain_file to Quotehdr.File_number
        Set DDO_Server to oQuotehdr_DD
    End_Object

    Object oParklots_DD is a cParklotsDataDictionary
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD
    End_Object

    Object oLotacces_DD is a cLotaccesDataDictionary
        Set Constrain_file to Parklots.File_number
        Set DDO_Server to oParklots_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesrep_DD
        Set DDO_Server to oProject_DD
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD
        Set Cascade_Delete_State to True
    End_Object

    Object oJobcosts_DD is a cJobcostsDataDictionary
        Set DDO_Server to oMastops_DD
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD
    End_Object

    Object oTrans_DD is a Trans_DataDictionary
        Set DDO_Server to oOpers_DD
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD
        Set DDO_Server to oEmployee_DD
        Set Cascade_Delete_State to True
    End_Object

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD
        Set Cascade_Delete_State to True
    End_Object

    Object oInvdtl_DD is a Invdtl_DataDictionary
        Set DDO_Server to oOpers_DD
        Set Constrain_file to Invhdr.File_number
        Set DDO_Server to oInvhdr_DD
        Set Cascade_Delete_State to True
    End_Object

    Object oLocnotes_DD is a cLocnotesDataDictionary
        Set DDO_Server to oReqtypes_DD
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD
    End_Object

    Set Main_DD to oLocation_DD
    Set Server to oLocation_DD

    Set Border_Style to Border_Thick
    Set Size to 395 475
    Set Location to 6 196
    Set Label to "Snowbook"
    Set piMinSize to 395 475

    Object oLocationsContainer is a dbContainer3d
        Set Size to 110 455
        Set Location to 10 10

        Object oLineControl1 is a LineControl
            Set Size to 5 327
            Set Location to 31 8
        End_Object

        Object oCustomer_CustomerIdno is a dbForm
            Entry_Item Customer.CustomerIdno
            Set Location to 10 74
            Set Size to 13 42
            Set Label to "Customer#/Name:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oCustomer_Name is a dbForm
            Entry_Item Customer.Name
            Set Location to 10 120
            Set Size to 13 204
        End_Object

        Object oLocation_LocationIdno is a cGlblDbForm
            Entry_Item Location.LocationIdno
            Set Location to 40 74
            Set Size to 13 42
            Set Label to "ID/Nbr/Name:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right

            Procedure Prompt_Callback Integer hPrompt
                Set Auto_Server_State of hPrompt to True
            End_Procedure
        End_Object

        Object oLocation_LocationNbr is a dbForm
            Entry_Item Location.LocationNbr
            Set Location to 40 120
            Set Size to 13 42

            Procedure Prompt_Callback Integer hPrompt
                Set Auto_Server_State of hPrompt to True
            End_Procedure
        End_Object

        Object oLocation_Name is a dbForm
            Entry_Item Location.Name
            Set Location to 40 168
            Set Size to 13 156
        End_Object

        Object oLocation_EstimatedHours is a dbForm
            Entry_Item Location.EstimatedHours
            Set Location to 55 74
            Set Size to 13 42
            Set Label to "Estimated Hours:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oLocation_Area is a cGlblDbForm
            Entry_Item Areas.AreaNumber
            Set Location to 55 168
            Set Size to 13 42
            Set Label to "Area:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oLocation_Status is a cGlblDbComboForm
            Entry_Item Location.Status
            Set Location to 55 258
            Set Size to 13 66
            Set Label to "Status:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oPropmgr_ContactIdno is a cGlblDbForm
            Entry_Item Location.PropmgrIdno
            Set Location to 70 74
            Set Size to 13 54
            Set Label to "Property Mgr:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Prompt_Button_Mode to PB_PromptOn

            Procedure Prompt
                Integer iOrgRecId iMgrRecId
                //
                Get Current_Record of oCustomer_DD to iOrgRecId
                If (iOrgRecId) Begin
                    Get IsSelectedPropertyManager of Propmgr_sl iOrgRecId to iMgrRecId
                    If (iMgrRecId) Begin
                        Set Field_Changed_Value of oLocation_DD Field Location.PropmgrIdno to Propmgr.ContactIdno
                        Set Value               of oPropmgr_LastName                       to Propmgr.LastName
                        Set Value               of oPropmgr_FirstName                      to Propmgr.FirstName
                    End
                    Else Begin
                        Set Field_Changed_Value of oLocation_DD Field Location.PropmgrIdno to 0
                        Set Value               of oPropmgr_LastName                       to ""
                        Set Value               of oPropmgr_FirstName                      to ""
                    End
                End
            End_Procedure

            Procedure Refresh Integer iMode
                Forward Send Refresh iMode
                //
                Clear Propmgr
                If (Location.PropmgrIdno <> 0) Begin
                    Move Location.PropmgrIdno to Propmgr.ContactIdno
                    Find eq Propmgr.ContactIdno
                End
                Set Value of oPropmgr_LastName  to Propmgr.LastName
                Set Value of oPropmgr_FirstName to Propmgr.FirstName
            End_Procedure
        End_Object

        Object oPropmgr_LastName is a cGlblForm
//            Entry_Item Propmgr.LastName
//            Set Server to oPropmgr_DD
            Set Location to 70 132
            Set Size to 13 78
            Set Enabled_State to False
        End_Object

        Object oPropmgr_FirstName is a cGlblForm
//            Entry_Item Propmgr.FirstName
//            Set Server to oPropmgr_DD
            Set Location to 70 214
            Set Size to 13 60
            Set Enabled_State to False
        End_Object
    End_Object

    Object oEditCustomerButton is a Button
        Set Size to 14 70
        Set Location to 269 281
        Set Label to "Edit Customers"
    
        Procedure OnClick
            Send DoEditCustomers
        End_Procedure    
    End_Object

    Object oLocation_BillingAddress is a cGlblDbComboForm
        Entry_Item Location.BillingAddress
        Set Location to 269 88
        Set Size to 13 66
        Set Label to "Billing Address:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Allow_Blank_State to True
        Set Combo_Sort_State to False
    End_Object

    Procedure DoCreateLocation Integer iCustomerIdno
        Send Clear_All    of oLocation_DD
        Move iCustomerIdno to Customer.CustomerIdno
        Send Request_Find of oLocation_DD EQ Customer.File_Number 1
        Send Activate_View
    End_Procedure

    Procedure DoDisplayLocation Integer iRecId
        Integer hoDD
        //
        Get Server to hoDD
        If (Changed_State(hoDD)) Begin
            Send Request_Save
        End
        Send Clear_All      of hoDD
        Send Find_By_Recnum of hoDD Location.File_Number iRecId
        Send Activate_View
    End_Procedure

    Procedure DoEditLocations Integer iRecId
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

    Procedure DoEditCustomers
        Send DoEditCustomers of oCustomerEntry (Current_Record(oCustomer_DD))
    End_Procedure

    Procedure DoCreateContact
        Boolean bFail
        Integer hoServer hoDD iLength iPos
        String  sName sFirst sLast
        //
        If (Should_Save(Self)) Begin
            Send Request_Save
        End
        //
        Get Server to hoServer
        If (HasRecord(hoServer)) Begin
            Move oContact_DD                                           to hoDD
            Send Refind_Records     of hoServer
            Send Clear              of hoDD
            Move (trim(Location.ContactName))                          to sName
            Move (Length(sName))                                       to iLength
            Move (Pos(" ",sName))                                      to iPos
            Move (Left(sName, (iPos - 1)))                             to sFirst
            Move (Mid(sName,(iLength - iPos),(iPos + 1)))              to sLast
            Set Field_Changed_Value of hoDD Field Contact.FirstName    to sFirst
            Set Field_Changed_Value of hoDD Field Contact.LastName     to sLast
            Set Field_Changed_Value of hoDD Field Contact.Address1     to Location.Address1
            Set Field_Changed_Value of hoDD Field Contact.Address2     to Location.Address2
            Set Field_Changed_Value of hoDD Field Contact.City         to Location.City
            Set Field_Changed_Value of hoDD Field Contact.State        to Location.State
            Set Field_Changed_Value of hoDD Field Contact.Zip          to Location.Zip
            Set Field_Changed_Value of hoDD Field Contact.Phone1       to Location.ContactPhone1
            Set Field_Changed_Value of hoDD Field Contact.PhoneType1   to Location.ContactPhnType1
            Set Field_Changed_Value of hoDD Field Contact.PhoneExt1    to Location.ContactPhnExt1
            Set Field_Changed_Value of hoDD Field Contact.Phone2       to Location.ContactPhone2
            Set Field_Changed_Value of hoDD Field Contact.PhoneType2   to Location.ContactPhnType2
            Set Field_Changed_Value of hoDD Field Contact.PhoneExt2    to Location.ContactPhnExt2
            Set Field_Changed_Value of hoDD Field Contact.EmailAddress to Location.ContactEmail
            Set Field_Changed_Value of hoDD Field Contact.Status       to "A"
            Get Request_Validate    of hoDD                            to bFail
            If (not(bFail)) Begin
                Send Request_Save   of hoDD
            End
            If (Contact.Recnum <> 0) Begin
                Send DoDisplayContact of oContactEntry Contact.Recnum
            End
        End
    End_Procedure

    Procedure Request_Delete
    End_Procedure

    Procedure DoDeleteLocation
        Forward Send Request_Delete
    End_Procedure

    Object oDbTabDialog1 is a dbTabDialog
        Set Size to 255 455
        Set Location to 129 10
    
        Set Rotate_Mode to RM_Rotate
 
        Object oDbTabPage1 is a dbTabPage
            Set Label to "Basic Information"
 
            Object oSnowBook_Header is a cDbTextEdit
                Entry_Item Location.Header
                Set Location to 18 62
                Set Size to 60 333
                Set Label to "Scope of Work:"
            End_Object
 
            Object oSnowBook_OpenUp is a cDbTextEdit
                Entry_Item Location.OpenUp
                Set Location to 92 64
                Set Size to 60 329
                Set Label to "OpenUp:"
            End_Object
 
            Object oSnowBook_FullPlow is a cDbTextEdit
                Entry_Item Location.FullPlow
                Set Location to 165 63
                Set Size to 60 330
                Set Label to "FullPlow:"
            End_Object
        End_Object
 
        Object oDbTabPage2 is a dbTabPage
            Set Label to "Specifications"
 
            Object oDbContainer3d3 is a dbContainer3d
                Set Size to 203 424
                Set Location to 12 14
 
                Object oSnowBook_BuildingType is a cGlblDbComboForm
                    Entry_Item Location.BuildingType
                    Set Location to 12 66
                    Set Size to 13 126
                    Set Label to "Building Type:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                End_Object
 
                Object oSnowBook_MajTenant is a dbForm
                    Entry_Item Location.MajTenant
                    Set Location to 12 264
                    Set Size to 13 126
                    Set Label to "Major Tenant:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object
 
                Object oSnowBook_PlowTrigger is a dbForm
                    Entry_Item Location.PlowTrigger
                    Set Location to 30 66
                    Set Size to 13 126
                    Set Label to "PlowTrigger:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object
 
                Object oSnowBook_ParkSqFeet is a dbForm
                    Entry_Item Location.ParkSqFeet
                    Set Location to 30 264
                    Set Size to 13 42
                    Set Label to "Park Sq. Feet:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object
 
                Object oSnowBook_SWTrigger is a dbForm
                    Entry_Item Location.SWTrigger
                    Set Location to 47 66
                    Set Size to 13 126
                    Set Label to " Walk Trigger:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object
 
                Object oSnowBook_SWSqFeet is a dbForm
                    Entry_Item Location.SWSqFeet
                    Set Location to 47 264
                    Set Size to 13 42
                    Set Label to "Walk Sq. Feet:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object
 
                Object oSnowBook_Parking_Stalls is a dbForm
                    Entry_Item Location.Parking_Stalls
                    Set Location to 64 264
                    Set Size to 13 42
                    Set Label to "Parking Stalls:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object
 
                Object oSnowBook_Hauling is a cGlblDbComboForm
                    Entry_Item Location.Hauling
                    Set Location to 65 66
                    Set Size to 13 126
                    Set Label to "Hauling:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                End_Object
 
                Object oSnowBook_Melting is a cGlblDbComboForm
                    Entry_Item Location.Melting
                    Set Location to 82 66
                    Set Size to 13 126
                    Set Label to "Melting:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                   
                End_Object
 
                Object oSnowBook_Awnings is a cGlblDbComboForm
                    Entry_Item Location.Awnings
                    Set Location to 99 66
                    Set Size to 13 126
                    Set Label to "Awnings:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                End_Object
 
                Object oSnowBook_SpcEquipment is a cGlblDbComboForm
                    Entry_Item Location.SpcEquipment
                    Set Location to 115 67
                    Set Size to 13 126
                    Set Label to "Special Equip:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                End_Object

                Object oLocation_CityWalks is a cGlblDbComboForm
                    Entry_Item Location.CityWalks
                    Set Location to 132 67
                    Set Size to 13 126
                    Set Label to "CityWalks:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                End_Object

                Object oLocation_DeIcing is a cGlblDbComboForm
                    Entry_Item Location.DeIcing
                    Set Location to 148 67
                    Set Size to 13 126
                    Set Label to "DeIcing:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                End_Object
            End_Object
        End_Object
 
        Object oDbTabPage3 is a dbTabPage
            Set Label to "Site Equipment"

            Object oDbCJGrid1 is a cDbCJGrid
                Set Server to oLocequip_DD
                Set Size to 202 300
                Set Location to 19 56

                Object oLocequip_Quantity is a cDbCJGridColumn
                    Entry_Item Locequip.Quantity
                    Set piWidth to 85
                    Set psCaption to "Quantity"
                End_Object

                Object oLocequip_Description is a cDbCJGridColumn
                    Entry_Item Locequip.Description
                    Set piWidth to 365
                    Set psCaption to "Description"
                End_Object
            End_Object
        End_Object
 
        Object oDbTabPage4 is a dbTabPage
            Set Label to "Special Instructions"
 
            Object oSnowBook_Special is a cDbTextEdit
                Entry_Item Location.Special
                Set Location to 30 62
                Set Size to 95 323
                Set Label to "Special:"
            End_Object
        End_Object

        Object oDbTabPage5 is a dbTabPage
            Set Label to 'Site Images'

            Object oLocation_Image_1 is a cGlblDbForm
                Entry_Item Location.Image_1
                Set Location to 28 84
                Set Size to 13 96
                Set Label to "Directional Map:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oLocation_Image_2 is a cGlblDbForm
                Entry_Item Location.Image_2
                Set Location to 43 84
                Set Size to 13 96
                Set Label to "Arial View 1:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oLocation_Image_3 is a cGlblDbForm
                Entry_Item Location.Image_3
                Set Location to 58 84
                Set Size to 13 96
                Set Label to "Image 3:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oLocation_Image_4 is a cGlblDbForm
                Entry_Item Location.Image_4
                Set Location to 73 84
                Set Size to 13 96
                Set Label to "Image 4:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oLocation_Image_5 is a cGlblDbForm
                Entry_Item Location.Image_5
                Set Location to 88 84
                Set Size to 13 96
                Set Label to "Image 5:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object
        End_Object
    
    End_Object
    //
    On_Key kUser Send DoDeleteLocation

    Procedure DoEditSnowbook RowID riLocation
        Integer hoDD
        //
        Get Server to hoDD
        Send Clear_All   of hoDD
        Send FindByRowId of hoDD Location.File_Number riLocation
        Send Activate_View
    End_Procedure
    
        
    Procedure DoEditSnowbook_2 Integer iCustomerIdno
        Send Clear_All    of oLocation_DD
        Move iCustomerIdno to Customer.CustomerIdno
        Send Request_Find of oLocation_DD EQ Customer.File_Number 1
        Send Activate_View
    End_Procedure
 
    Procedure DoDisplayLocation Integer iRecId
        Integer hoDD
        //
        Get Server to hoDD
        If (Changed_State(hoDD)) Begin
            Send Request_Save
        End
        Send Clear_All      of hoDD
        Send Find_By_Recnum of hoDD Location.File_Number iRecId
        Send Activate_View
    End_Procedure

End_Object
