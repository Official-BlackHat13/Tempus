Use Windows.pkg
Use DFClient.pkg
Use dfTabDlg.pkg
Use dfLine.pkg
Use DFEntry.pkg
Use cTempusDbView.pkg
Use cGlblDbComboForm.pkg
Use cGlblButton.pkg
Use cGlblDbForm.pkg
Use cDbTextEdit.pkg
Use cGlblDbCheckBox.pkg
Use dfSelLst.pkg
//Use ParkingLot.dg
Use Propmgr.sl
Use cDbCJGrid.pkg
Use dfBitmap.pkg
Use dbBitmap.pkg
Use cAnimation.pkg
Use File_dlg.pkg
Use VdfBase.pkg
Use dfAllEnt.pkg
Use File_Dlg.pkg
Use Functions.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cLocequipDataDictionary.dd
Use Employer.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use SnowbooksLocationReport.rv
Use SnowbooksLocationOrderReport.rv


Register_Object oCustomerEntry
Register_Object oContactEntry

Activate_View Activate_oSnowbook for oSnowbook
Object oSnowbook is a cTempusDbView
    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
        Set Constrain_File to Customer.File_Number
        Set Cascade_Delete_State to True
    End_Object

    Object oLocequip_DD is a cLocequipDataDictionary
        Set DDO_Server to oEmployer_DD
        Set Constrain_file to Location.File_number
        Set DDO_Server to oLocation_DD

        Procedure OnConstrain
            Forward Send OnConstrain
            Constrain Locequip.DeleteFlag eq 0
        End_Procedure
    End_Object

    Set Main_DD to oLocation_DD
    Set Server to oLocation_DD

    Set Border_Style to Border_Thick
    Set Size to 340 363
    Set Location to 2 2
    Set Label to "Snowbook"
    Set piMinSize to 340 350
    Set piMaxSize to 340 363

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
    //
    
    Procedure DoEditSnowbook RowID riLocation
        Integer hoDD
        //
        Get Server to hoDD
        Send Clear_All   of hoDD
        Send FindByRowId of hoDD Location.File_Number riLocation
        Send Activate_View
    End_Procedure

    Object oLocationsContainer is a dbContainer3d
        Set Size to 77 357
        Set Location to 3 3
        Set peAnchors to anTopLeftRight
        
        Object oLineControl1 is a LineControl
            Set Size to 5 346
            Set Location to 20 3
        End_Object
        
        Object oCustomer_Name is a dbForm
            Entry_Item Customer.Name
            Set Location to 4 50
            Set Size to 13 249
            Set Label to "Customer:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oCustomer_CustomerIdno is a dbForm
            Entry_Item Customer.CustomerIdno
            Set Location to 4 303
            Set Size to 13 42
        End_Object

        Object oLocation_Name is a dbForm
            Entry_Item Location.Name
            Set Label to "Name/ID:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Location to 24 50
            Set Size to 13 249
                       
            Procedure Prompt_Callback Integer hPrompt
                Integer iCustomerNumber
                Get Value of oCustomer_CustomerIdno to iCustomerNumber
                If (iCustomerNumber) Begin
                    Set Auto_Server_State of hPrompt to True
                End
            End_Procedure
            
            Procedure Refresh Integer iMode
                Handle hoDD
                Boolean bHasLocationRecord bAntBulkUsageManual bAntBagUsageManual
                
                Forward Send Refresh iMode
                //
                Move (Location.LocationIdno>0) to bHasLocationRecord
                Move (Location.BulkManualFlag=1) to bAntBulkUsageManual
                Move (Location.BagManualFlag=1) to bAntBagUsageManual
                //
                Set Enabled_State of oBulkLockStateButton to (bHasLocationRecord)
                Set Enabled_State of oBagLockStateButton to (bHasLocationRecord)
                //
                If (bAntBulkUsageManual) Begin
                    Set Bitmap of oBulkLockStateButton to "unlocked.bmp"
                End
                    
                Else Begin
                    Set Bitmap of oBulkLockStateButton to "locked.bmp" 
                End
                    
                If (bAntBagUsageManual) Begin
                    Set Bitmap of oBagLockStateButton to "unlocked.bmp"
                End
                Else Begin
                    Set Bitmap of oBagLockStateButton to "locked.bmp"
                End
                //
                Set Enabled_State of oLocation_AntBulkUsage to (bHasLocationRecord and bAntBulkUsageManual)
                Set Enabled_State of oLocation_AntBagUsage to (bHasLocationRecord and bAntBagUsageManual)                    
                //
                Set Enabled_State of oSelectDirectionalButton to (bHasLocationRecord)
                Set Enabled_State of oSelectArialButton to (bHasLocationRecord)
                Set Enabled_State of oSelectImage3Button to (bHasLocationRecord)
                Set Enabled_State of oSelectImage4Button to (bHasLocationRecord)
                Set Enabled_State of oSelectImage5Button to (bHasLocationRecord)
                Set Enabled_State of oDirectionClearButton to (bHasLocationRecord)
                Set Enabled_State of oAirialClearButton to (bHasLocationRecord)
                Set Enabled_State of oImage3ClearButton to (bHasLocationRecord)
                Set Enabled_State of oImage4ClearButton to (bHasLocationRecord)
                Set Enabled_State of oImage5ClearButton to (bHasLocationRecord)

            End_Procedure

        End_Object

        Object oLocation_LocationIdno is a cGlblDbForm
            Entry_Item Location.LocationIdno
            Set Location to 24 303
            Set Size to 13 42
            
            Procedure Prompt_Callback Integer hPrompt
                Set Auto_Server_State of hPrompt to True
            End_Procedure
           
        End_Object

//        Object oLocation_Area is a cGlblDbForm
//            Entry_Item Areas.AreaNumber
//            Set Location to 55 168
//            Set Size to 13 42
//            Set Label to "Area:"
//            Set Label_Col_Offset to 3
//            Set Label_Justification_Mode to JMode_Right
//        End_Object
        
        Object oLocation_Area_Name is a cGlblDbForm
            Entry_Item Areas.Name
            Set Location to 40 51
            Set Size to 13 90
            Set Label to "Area:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object
        
        Object oAreas_Manager is a cGlblDbForm
            Entry_Item Areas.Manager
            Set Location to 40 144
            Set Size to 13 81
            Set Enabled_State to False
            Set Prompt_Button_Mode to PB_PromptOff
        End_Object

        Object oLocation_Status is a cGlblDbComboForm
            Entry_Item Location.Status
            Set Location to 39 254
            Set Size to 12 45
            Set Label to "Status:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oPropmgr_ContactIdno is a cGlblDbForm
            Entry_Item Location.PropmgrIdno
            Set Location to 55 51
            Set Size to 13 58
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
            Set Location to 55 113
            Set Size to 13 91
            Set Enabled_State to False
        End_Object

        Object oPropmgr_FirstName is a cGlblForm
//            Entry_Item Propmgr.FirstName
//            Set Server to oPropmgr_DD
            Set Location to 55 211
            Set Size to 13 86
            Set Enabled_State to False
        End_Object

        Object oPrintButton is a Button
            Set Size to 28 41
            Set Location to 40 303
            Set Label to ''
            Set psImage to "print.bmp"
            Set piImageSize to 48
            Set peImageAlign to Button_ImageList_Align_Center

            Procedure OnClick
                Integer iLocIdno iJobNumber
                Move Location.LocationIdno to iLocIdno
                //Find Snow Order for Job#
                Clear Order
                Move iLocIdno to Order.LocationIdno
                Find GE Order.LocationIdno
                While ((Found) and Order.LocationIdno = iLocIdno)
                    If (Order.Status = 'O' and Order.WorkType='S' and Order.InvoiceOnly<>1) Begin
                        Move Order.JobNumber to iJobNumber
                    End
                    Find GT Order.LocationIdno
                Loop
                If (iJobNumber<>0) Begin
                    Send DoJumpStartReport of oSnowbooksLocationOrderReportView iJobNumber
                End
                Else Begin
                    Send Info_Box "Could not find a Snow JobNumber for this Location yet" "No Snow Job Open"
                    Send DoJumpStartReport of oSnowbooksLocationReportView iLocIdno
                End
            End_Procedure
        End_Object


    End_Object

    Object oDbTabDialog1 is a dbTabDialog
        Set Size to 255 355
        Set Location to 83 4
    
        Set Rotate_Mode to RM_Rotate
        Set peAnchors to anBottomLeftRight
 
        Object oDbTabPage1 is a dbTabPage
            Set Label to "Basic Information"
 
            Object oSnowBook_Header is a cDbTextEdit
                Entry_Item Location.Header
                Set Location to 16 9
                Set Size to 60 331
                Set Label to "Scope of Work:"
                Set peAnchors to anTopLeftRight
           
            End_Object
 
            Object oSnowBook_OpenUp is a cDbTextEdit
                Entry_Item Location.OpenUp
                Set Location to 91 9
                Set Size to 60 331
                Set Label to "OpenUp:"
                Set peAnchors to anTopLeftRight
            End_Object
 
            Object oSnowBook_FullPlow is a cDbTextEdit
                Entry_Item Location.FullPlow
                Set Location to 164 9
                Set Size to 60 331
                Set Label to "FullPlow:"
                Set peAnchors to anBottomLeftRight
            End_Object
        End_Object
 
        Object oDbTabPage2 is a dbTabPage
            Set Label to "Specifications"
 
            Object oDbContainer3d3 is a dbContainer3d
                Set Size to 224 339
                Set Location to 3 3
                Set peAnchors to anAll
 
                Object oSnowBook_BuildingType is a cGlblDbComboForm
                    Entry_Item Location.BuildingType
                    Set Location to 4 54
                    Set Size to 12 88
                    Set Label to "Building Type:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                    Set peAnchors to anAll
                End_Object
 
                Object oSnowBook_MajTenant is a dbForm
                    Entry_Item Location.MajTenant
                    Set Location to 4 197
                    Set Size to 13 113
                    Set Label to "Major Tenant:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object
 
                Object oSnowBook_PlowTrigger is a dbForm
                    Entry_Item Location.PlowTrigger
                    Set Location to 18 54
                    Set Size to 13 88
                    Set Label to "PlowTrigger:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set peAnchors to anAll
                End_Object

                Object oSnowBook_SWTrigger is a dbForm
                    Entry_Item Location.SWTrigger
                    Set Location to 34 54
                    Set Size to 13 75
                    Set Label to " Walk Trigger:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object
 
                Object oSnowBook_ParkSqFeet is a dbForm
                    Entry_Item Location.ParkSqFeet
                    Set Location to 19 197
                    Set Size to 13 54
                    Set Label to "Park Sq. Feet:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right

                    Procedure OnChange
                        Number nParkSqft nBulkUsage
                        Boolean bChanged
                        Forward Send OnChange
                        Get Field_Changed_State of oLocation_DD Field Location.ParkSqFeet to bChanged
                        If (bChanged) Begin
                            If (Location.BulkManualFlag = 0) Begin
                                Get Field_Current_Value of oLocation_DD Field Location.ParkSqFeet to nParkSqft
                                Move (Round(nParkSqft/28.84)) to nBulkUsage
                                Set Field_Changed_Value of oLocation_DD Field Location.AntBulkUsage to nBulkUsage
                            End                            
                        End
                    End_Procedure

                End_Object

                Object oLocation_AntBulkUsage is a cGlblDbForm
                    Entry_Item Location.AntBulkUsage
                    Set Location to 34 197
                    Set Size to 13 54
                    Set Label to "Bulk usage:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object
 
                Object oSnowBook_SWSqFeet is a dbForm
                    Entry_Item Location.SWSqFeet
                    Set Location to 49 197
                    Set Size to 13 54
                    Set Label to "Walk Sq. Feet:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right

                    Procedure OnChange
                        Boolean bChanged
                        Number nBagUsage nSWSqFeet
                        Forward Send OnChange
                        Get Field_Changed_State of oLocation_DD Field Location.SWSqFeet to bChanged
                        If (bChanged) Begin
                            If (Location.BagManualFlag = 0) Begin
                                Get Field_Current_Value of oLocation_DD Field Location.SWSqFeet to nSWSqFeet
                                Move (nSWSqFeet/3600.00) to nBagUsage
                                Get RoundValue nBagUsage "+" to nBagUsage
                                Set Field_Changed_Value of oLocation_DD Field Location.AntBagUsage to nBagUsage
                            End
                        End
                    End_Procedure

                End_Object

                Object oLocation_AntBagUsage is a cGlblDbForm
                    Entry_Item Location.AntBagUsage
                    Set Location to 64 197
                    Set Size to 13 54
                    Set Label to "Bag usage:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object
 
                Object oSnowBook_Parking_Stalls is a dbForm
                    Entry_Item Location.Parking_Stalls
                    Set Location to 79 197
                    Set Size to 13 54
                    Set Label to "Parking Stalls:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object
 
                Object oSnowBook_Hauling is a cGlblDbComboForm
                    Entry_Item Location.Hauling
                    Set Location to 49 54
                    Set Size to 12 75
                    Set Label to "Hauling:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                End_Object
 
                Object oSnowBook_Melting is a cGlblDbComboForm
                    Entry_Item Location.Melting
                    Set Location to 64 54
                    Set Size to 12 75
                    Set Label to "Melting:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                   
                End_Object
 
                Object oSnowBook_Awnings is a cGlblDbComboForm
                    Entry_Item Location.Awnings
                    Set Location to 78 54
                    Set Size to 12 75
                    Set Label to "Awnings:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                End_Object
 
                Object oSnowBook_SpcEquipment is a cGlblDbComboForm
                    Entry_Item Location.SpcEquipment
                    Set Location to 92 54
                    Set Size to 12 75
                    Set Label to "Special Equip:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                End_Object

                Object oLocation_CityWalks is a cGlblDbComboForm
                    Entry_Item Location.CityWalks
                    Set Location to 107 54
                    Set Size to 12 75
                    Set Label to "CityWalks:"
                     Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                End_Object

                Object oLocation_DeIcing is a cGlblDbComboForm
                    Entry_Item Location.DeIcing
                    Set Location to 122 54
                    Set Size to 12 75
                    Set Label to "DeIcing:"
                     Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                    Set Entry_State to False
                End_Object

                Object oBulkLockStateButton is a Button
                    Set Size to 15 17
                    Set Location to 34 266
                    Set Label to 'oButton2'
                    Set Bitmap to "unlocked.bmp"
                    Set peAnchors to anTopRight
                
                    // fires when the button is clicked
                    Procedure OnClick
                        Boolean bBulkLockStatus bHasRecord bShouldSave
                        //
                        Get Field_Current_Value of oLocation_DD Field Location.BulkManualFlag to bBulkLockStatus
                        Set Field_Changed_Value of oLocation_DD Field Location.BulkManualFlag to (not(bBulkLockStatus))                
                        Get HasRecord of oLocation_DD to bHasRecord
                        Get Should_Save of oLocation_DD to bShouldSave
                        If (bHasRecord and bShouldSave) Begin
                            Send Request_Save of oLocation_DD
                        End
                    End_Procedure
                
                End_Object

                Object oBagLockStateButton is a Button
                    Set Size to 15 17
                    Set Location to 64 266
                    Set Label to 'oButton2'
                    Set Bitmap to "unlocked.bmp"
                    Set peAnchors to anTopRight
                
                    // fires when the button is clicked
                    Procedure OnClick
                        Boolean bBagLockStatus bHasRecord bShouldSave
                        //
                        Get Field_Current_Value of oLocation_DD Field Location.BagManualFlag to bBagLockStatus
                        Set Field_Changed_Value of oLocation_DD Field Location.BagManualFlag to (not(bBagLockStatus))                
                        Get HasRecord of oLocation_DD to bHasRecord
                        Get Should_Save of oLocation_DD to bShouldSave
                        If (bHasRecord and bShouldSave) Begin
                            Send Request_Save of oLocation_DD
                        End
                    End_Procedure
                
                End_Object

                Object oLocation_PreTreatWalk is a cGlblDbComboForm
                    Entry_Item Location.PreTreatWalk
                    Set Location to 94 197
                    Set Size to 12 54
                    Set Label to "PreTreatWalk:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object

                Object oLocation_PreTreatWalkSqft is a cGlblDbForm
                    Entry_Item Location.PreTreatWalkSqft
                    Set Location to 109 197
                    Set Size to 13 54
                    Set Label to "PreTreatWalkSqft:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object

                Object oLocation_PreTreatLot is a cGlblDbComboForm
                    Entry_Item Location.PreTreatLot
                    Set Location to 124 197
                    Set Size to 12 54
                    Set Label to "PreTreatLot:"
                    Set Label_Col_Offset to 5
                    Set Label_Justification_Mode to JMode_Right
                End_Object

                Object oLocation_PreTreatLotSqft is a cGlblDbForm
                    Entry_Item Location.PreTreatLotSqft
                    Set Location to 139 197
                    Set Size to 13 54
                    Set Label to "PreTreatLotSqft:"
                    Set Label_Justification_Mode to JMode_Right
                    Set Label_Col_Offset to 5
                End_Object
            End_Object
        End_Object
 
        Object oDbTabPage3 is a dbTabPage
            Set Label to "Site Equipment"

            Object oDbCJGrid1 is a cDbCJGrid
                Set Server to oLocequip_DD
                Set Size to 228 323
                Set Location to 4 6

                Object oEmployer_Name is a cDbCJGridColumn
                    Entry_Item Employer.Name
                    Set piWidth to 190
                    Set psCaption to "Name"
                End_Object

                Object oLocequip_Description is a cDbCJGridColumn
                    Entry_Item Locequip.Description
                    Set piWidth to 313
                    Set psCaption to "Description"
                End_Object
                
                Object oLocequip_Quantity is a cDbCJGridColumn
                    Entry_Item Locequip.Quantity
                    Set piWidth to 62
                    Set psCaption to "Quantity"
                End_Object

            End_Object
            
        End_Object
 
 
        Object oDbTabPage4 is a dbTabPage
            Set Label to "Special Instructions"
 
            Object oSnowBook_Special is a cDbTextEdit
                Entry_Item Location.Special
                Set Location to 16 8
                Set Size to 215 320
                Set Label to "Special:"
            End_Object
        End_Object

        Object oDbTabPage5 is a dbTabPage
            Set Label to 'Site Images'

            Object oLocation_Image1 is a cDbTextEdit
                Entry_Item Location.Image1
                Set Location to 38 95
                Set Size to 15 60
                Set Label to "Directional Map"
                Set Read_Only_State to True
            End_Object

            Object oLocation_Image2 is a cDbTextEdit
                Entry_Item Location.Image2
                Set Location to 68 94
                Set Size to 15 60
                Set Label to "Arial View"
                Set Read_Only_State to True
            End_Object

            Object oLocation_Image3 is a cDbTextEdit
                Entry_Item Location.Image3
                Set Read_Only_State to True
                Set Location to 99 94
                Set Size to 15 60
                Set Label to "Image3:"
            End_Object

            Object oLocation_Image4 is a cDbTextEdit
                Entry_Item Location.Image4
                Set Read_Only_State to True
                Set Location to 131 94
                Set Size to 15 60
                Set Label to "Image4:"
            End_Object

            Object oLocation_Image5 is a cDbTextEdit
                Entry_Item Location.Image5
                Set Read_Only_State to True
                Set Location to 162 94
                Set Size to 15 60
                Set Label to "Image5:"
            End_Object
                        
            Object oOpenDialog1 is a OpenDialog
                Set Filter_String to 'Image (JPG/JPEG)|*.jpg;*.jpeg|Image File (PNG)|*.png|All Images|*.jpg;*.jpeg;*.png'
                Set Initial_Folder to 'C:\'
                Set Filter_Index to 3
                Set MultiSelect_State to False
                
                //Show_Dialog is a predefined function in the OpenDialog class.
                //Call the OpenDialog via:
            
                //get Show_Dialog to iIntegerVariable
            
                //DoCallOpenDialog is NOT a predefined method in the OpenDialog class,
                //DoCallOpenDialog is just a code sample.
                //You can call DoCallOpenDialog from another object, such as a button.
            
                //Procedure DoCallOpenDialog
                //    Boolean bOk
                //
                //    Get Show_Dialog To bOk
                //    If (bOk) Begin
                //        
                //    End
                //End_Procedure

            End_Object
 
            Object oSelectDirectionalButton is a Button
                Set Size to 14 35
                Set Location to 38 157
                Set Label    to 'Browse...'
                
                Procedure OnClick
                    Boolean bOpen bReadOnly bHasLocationRecord
                    String sFileTitle sTargetAddress sTargetFilename sRandom sFileExt sTarget
                    Integer iDotPos
                    String[] sSelectedFiles
                    //
                    Move (Location.LocationIdno>0) to bHasLocationRecord
                    //
                    If (bHasLocationRecord) Begin
                        Get Show_Dialog of oOpenDialog1 to bOpen
                        If bOpen Begin
                            Get TickReadOnly_State of oOpenDialog1 to bReadOnly
                            
                            Get Selected_Files of oOpenDialog1 to sSelectedFiles
                            If (bReadOnly) Append sSelectedFiles[0] ' (Read-Only)'
                            //Showln sSelectedFiles[0]
                            Get File_Title of oOpenDialog1 to sFileTitle
                            //Showln ("FileTitel: " + sFileTitle)
                            Get psHome of (phoWorkspace(ghoApplication)) to sTargetAddress
                            Move (sTargetAddress+"Bitmaps\Snowbooks\") to sTargetAddress
                            //Move "\\Web\images\" to sTargetAddress
                            //Showln ("Target Address: " + sTargetAddress)
                            Move ((Length(sFileTitle)) - (RightPos(".", sFileTitle))) to iDotPos
                            //Showln ("Dot position:" + String(iDotPos))
                            Move (Right(sFileTitle, (iDotPos+1))) to sFileExt
                            //Showln ("Target Extension: " + sFileExt)
                            Get GenerateRandomPassword 4 False True True True to sRandom
                            //Showln ("Random: " + sRandom)
                            Move (String(Location.LocationIdno)+"_1_"+sRandom+sFileExt) to sTargetFilename
                            //Showln ("Target Filename: " + sTargetFilename)
                            Move (Append(sTargetAddress, sTargetFilename)) to sTarget
                            //Showln ("Target:" + sTarget)
                            CopyFile sSelectedFiles[0] to sTarget
                            //
                            Set Value of oLocation_Image1 to sTargetFilename
                        End
                        Else Send Info_Box "Picture Upload was canceled"
                    End // bHasLocationRecord
                End_Procedure // OnClick
            End_Object
            
            Object oSelectArialButton is a Button
                Set Size to 14 35
                Set Location to 68 157
                Set Label    to 'Browse...'
                
                Procedure OnClick
                    Boolean bOpen bReadOnly bHasLocationRecord
                    String sFileTitle sTargetAddress sTargetFilename sRandom sFileExt sTarget
                    Integer iDotPos
                    String[] sSelectedFiles
                    //
                    Move (Location.LocationIdno>0) to bHasLocationRecord
                    //
                    If (bHasLocationRecord) Begin
                        Get Show_Dialog of oOpenDialog1 to bOpen
                        If bOpen Begin
                            Get TickReadOnly_State of oOpenDialog1 to bReadOnly
                            
                            Get Selected_Files of oOpenDialog1 to sSelectedFiles
                            If (bReadOnly) Append sSelectedFiles[0] ' (Read-Only)'
                            //Showln sSelectedFiles[0]
                            Get File_Title of oOpenDialog1 to sFileTitle
                            //Showln ("FileTitel: " + sFileTitle)
                            //Move "\\web\images\" to sTargetAddress
                            Get psHome of (phoWorkspace(ghoApplication)) to sTargetAddress
                            Move (sTargetAddress+"Bitmaps\Snowbooks\") to sTargetAddress
                            //Showln ("Target Address: " + sTargetAddress)
                            Move ((Length(sFileTitle)) - (RightPos(".", sFileTitle))) to iDotPos
                            //Showln ("Dot position:" + String(iDotPos))
                            Move (Right(sFileTitle, (iDotPos+1))) to sFileExt
                            //Showln ("Target Extension: " + sFileExt)
                            Get GenerateRandomPassword 4 False True True True to sRandom
                            //Showln ("Random: " + sRandom)
                            Move (String(Location.LocationIdno)+"_2_"+sRandom+sFileExt) to sTargetFilename
                            //Showln ("Target Filename: " + sTargetFilename)
                            Move (Append(sTargetAddress, sTargetFilename)) to sTarget
                            //Showln ("Target:" + sTarget)
                            CopyFile sSelectedFiles[0] to sTarget
                            //
                            Set Value of oLocation_Image2 to sTargetFilename
                        End
                        Else Send Info_Box "Picture Upload was canceled"
                    End // bHasLocationRecord
                End_Procedure // OnClick
            End_Object
            
            Object oSelectImage3Button is a Button
                Set Size to 14 35
                Set Location to 99 157
                Set Label    to 'Browse...'
                
                Procedure OnClick
                    Boolean bOpen bReadOnly bHasLocationRecord
                    String sFileTitle sTargetAddress sTargetFilename sRandom sFileExt sTarget
                    Integer iDotPos
                    String[] sSelectedFiles
                    //
                    Move (Location.LocationIdno>0) to bHasLocationRecord
                    //
                    If (bHasLocationRecord) Begin
                        Get Show_Dialog of oOpenDialog1 to bOpen
                        If bOpen Begin
                            Get TickReadOnly_State of oOpenDialog1 to bReadOnly
                            
                            Get Selected_Files of oOpenDialog1 to sSelectedFiles
                            If (bReadOnly) Append sSelectedFiles[0] ' (Read-Only)'
                            //Showln sSelectedFiles[0]
                            Get File_Title of oOpenDialog1 to sFileTitle
                            //Showln ("FileTitel: " + sFileTitle)
                            //Move "\\web\images\" to sTargetAddress
                            Get psHome of (phoWorkspace(ghoApplication)) to sTargetAddress
                            Move (sTargetAddress+"Bitmaps\Snowbooks\") to sTargetAddress
                            //Showln ("Target Address: " + sTargetAddress)
                            Move ((Length(sFileTitle)) - (RightPos(".", sFileTitle))) to iDotPos
                            //Showln ("Dot position:" + String(iDotPos))
                            Move (Right(sFileTitle, (iDotPos+1))) to sFileExt
                            //Showln ("Target Extension: " + sFileExt)
                            Get GenerateRandomPassword 4 False True True True to sRandom
                            //Showln ("Random: " + sRandom)
                            Move (String(Location.LocationIdno)+"_3_"+sRandom+sFileExt) to sTargetFilename
                            //Showln ("Target Filename: " + sTargetFilename)
                            Move (Append(sTargetAddress, sTargetFilename)) to sTarget
                            //Showln ("Target:" + sTarget)
                            CopyFile sSelectedFiles[0] to sTarget
                            //
                            Set Value of oLocation_Image3 to sTargetFilename
                        End
                        Else Send Info_Box "Picture Upload was canceled"
                    End // bHasLocationRecord
                End_Procedure // OnClick
            End_Object
                        
            Object oSelectImage4Button is a Button
                Set Size to 14 35
                Set Location to 131 156
                Set Label    to 'Browse...'
                
                Procedure OnClick
                    Boolean bOpen bReadOnly bHasLocationRecord
                    String sFileTitle sTargetAddress sTargetFilename sRandom sFileExt sTarget
                    Integer iDotPos
                    String[] sSelectedFiles
                    //
                    Move (Location.LocationIdno>0) to bHasLocationRecord
                    //
                    If (bHasLocationRecord) Begin
                        Get Show_Dialog of oOpenDialog1 to bOpen
                        If bOpen Begin
                            Get TickReadOnly_State of oOpenDialog1 to bReadOnly
                            
                            Get Selected_Files of oOpenDialog1 to sSelectedFiles
                            If (bReadOnly) Append sSelectedFiles[0] ' (Read-Only)'
                            //Showln sSelectedFiles[0]
                            Get File_Title of oOpenDialog1 to sFileTitle
                            //Showln ("FileTitel: " + sFileTitle)
                            //Move "\\web\images\" to sTargetAddress
                            Get psHome of (phoWorkspace(ghoApplication)) to sTargetAddress
                            Move (sTargetAddress+"Bitmaps\Snowbooks\") to sTargetAddress
                            //Showln ("Target Address: " + sTargetAddress)
                            Move ((Length(sFileTitle)) - (RightPos(".", sFileTitle))) to iDotPos
                            //Showln ("Dot position:" + String(iDotPos))
                            Move (Right(sFileTitle, (iDotPos+1))) to sFileExt
                            //Showln ("Target Extension: " + sFileExt)
                            Get GenerateRandomPassword 4 False True True True to sRandom
                            //Showln ("Random: " + sRandom)
                            Move (String(Location.LocationIdno)+"_4_"+sRandom+sFileExt) to sTargetFilename
                            //Showln ("Target Filename: " + sTargetFilename)
                            Move (Append(sTargetAddress, sTargetFilename)) to sTarget
                            //Showln ("Target:" + sTarget)
                            CopyFile sSelectedFiles[0] to sTarget
                            //
                            Set Value of oLocation_Image4 to sTargetFilename
                        End
                        Else Send Info_Box "Picture Upload was canceled"
                    End // bHasLocationRecord
                End_Procedure // OnClick
            End_Object            
            
            Object oSelectImage5Button is a Button
                Set Size to 14 35
                Set Location to 162 156
                Set Label    to 'Browse...'

                Procedure OnClick
                    Boolean bOpen bReadOnly bHasLocationRecord
                    String sFileTitle sTargetAddress sTargetFilename sRandom sFileExt sTarget
                    Integer iDotPos
                    String[] sSelectedFiles
                    //
                    Move (Location.LocationIdno>0) to bHasLocationRecord
                    //
                    If (bHasLocationRecord) Begin
                        Get Show_Dialog of oOpenDialog1 to bOpen
                        If bOpen Begin
                            Get TickReadOnly_State of oOpenDialog1 to bReadOnly
                            
                            Get Selected_Files of oOpenDialog1 to sSelectedFiles
                            If (bReadOnly) Append sSelectedFiles[0] ' (Read-Only)'
                            //Showln sSelectedFiles[0]
                            Get File_Title of oOpenDialog1 to sFileTitle
                            //Showln ("FileTitel: " + sFileTitle)
                            //Move "\\web\images\" to sTargetAddress
                            Get psHome of (phoWorkspace(ghoApplication)) to sTargetAddress
                            Move (sTargetAddress+"Bitmaps\Snowbooks\") to sTargetAddress
                            //Showln ("Target Address: " + sTargetAddress)
                            Move ((Length(sFileTitle)) - (RightPos(".", sFileTitle))) to iDotPos
                            //Showln ("Dot position:" + String(iDotPos))
                            Move (Right(sFileTitle, (iDotPos+1))) to sFileExt
                            //Showln ("Target Extension: " + sFileExt)
                            Get GenerateRandomPassword 4 False True True True to sRandom
                            //Showln ("Random: " + sRandom)
                            Move (String(Location.LocationIdno)+"_5_"+sRandom+sFileExt) to sTargetFilename
                            //Showln ("Target Filename: " + sTargetFilename)
                            Move (Append(sTargetAddress, sTargetFilename)) to sTarget
                            //Showln ("Target:" + sTarget)
                            CopyFile sSelectedFiles[0] to sTarget
                            //
                            Set Value of oLocation_Image5 to sTargetFilename
                        End
                        Else Send Info_Box "Picture Upload was canceled"
                    End // bHasLocationRecord
                End_Procedure // OnClick
            End_Object   

            Object oDirectionClearButton is a Button
                Set Size to 14 25
                Set Location to 38 194
                Set Label to 'Clear'
            
                // fires when the button is clicked
                Procedure OnClick
                    Set Value of oLocation_Image1 to ""
                End_Procedure
            
            End_Object

            Object oAirialClearButton is a Button
                Set Size to 14 25
                Set Location to 68 194
                Set Label to 'Clear'
            
                // fires when the button is clicked
                Procedure OnClick
                    Set Value of oLocation_Image2 to ""
                End_Procedure
            
            End_Object

            Object oImage3ClearButton is a Button
                Set Size to 14 25
                Set Location to 99 194
                Set Label to 'Clear'
            
                // fires when the button is clicked
                Procedure OnClick
                    Set Value of oLocation_Image3 to ""
                End_Procedure
            
            End_Object

            Object oImage4ClearButton is a Button
                Set Size to 14 25
                Set Location to 131 194
                Set Label to 'Clear'
            
                // fires when the button is clicked
                Procedure OnClick
                    Set Value of oLocation_Image4 to ""
                End_Procedure
            
            End_Object

            Object oImage5ClearButton is a Button
                Set Size to 14 25
                Set Location to 162 194
                Set Label to 'Clear'
            
                // fires when the button is clicked
                Procedure OnClick
                    Set Value of oLocation_Image5 to ""
                End_Procedure
            
            End_Object
            
        End_Object
    
    End_Object
    
    //On_Key kUser Send DoDeleteLocation
 
End_Object
