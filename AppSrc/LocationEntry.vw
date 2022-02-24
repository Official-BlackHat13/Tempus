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
Use GeoLocationUpdate.bp
//Use cSzTime.pkg
Use dfSelLst.pkg
//Use ParkingLot.dg
Use Propmgr.sl
Use LocationPricing.rv
Use cLinkLabel.pkg
Use cIeFrame.pkg
Use dbSuggestionForm.pkg
Use Customer.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use dbTrckBr.pkg


Register_Object oCustomerEntry
Register_Object oContactEntry
Register_Object oAPForm

Activate_View Activate_oLocationEntry for oLocationEntry
Object oLocationEntry is a cTempusDbView
    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
        
        
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

    Set Main_DD to oLocation_DD
    Set Server to oLocation_DD

    Set Border_Style to Border_Thick
    Set Size to 315 350
    Set Location to 7 5
    Set Label to "Location Entry/Edit"
    Set piMinSize to 315 350
    Set Maximize_Icon to True

    Object oLocationsContainer is a dbContainer3d
        Set Size to 94 344
        Set Location to 2 2
        Set peAnchors to anTopLeftRight

        Object oLineControl1 is a LineControl
            Set Size to 5 327
            Set Location to 20 8
            Set peAnchors to anTopLeftRight
        End_Object

        
        Object oCustomer_Name is a DbSuggestionForm
            Entry_Item Customer.Name
            Set pbFullText to True
            Set Location to 4 65
            Set Size to 13 221
            Set Label to "Customer:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
            Set peAnchors to anTopLeftRight
        End_Object

        Object oCustomer_CustomerIdno is a dbForm
            Entry_Item Customer.CustomerIdno
            Set Location to 4 290
            Set Size to 13 42
            Set peAnchors to anTopRight

            Procedure Refresh Integer iMode
                Forward Send Refresh iMode
                //
                Set Enabled_State of oCopyFromCustomerButton to (Current_Record(oCustomer_DD))
            End_Procedure
        End_Object

        Object oLocation_Name is a DbSuggestionForm
            Entry_Item Location.Name
            Set pbFullText to True
            Set Label to "Name/ID:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set peAnchors to anTopLeftRight
            
            Procedure Prompt_Callback Integer hPrompt
                Set Auto_Server_State of hPrompt to True
            End_Procedure
            
            Set Location to 24 65
            Set Size to 13 221

//            Procedure OnChange
//                Boolean bCancel
//                Get CancelNavigation to bCancel
//                If (not(bCancel)) Forward Send OnChange
//            End_Procedure
        End_Object

        Object oLocation_LocationIdno is a cGlblDbForm
            Entry_Item Location.LocationIdno
            Set Location to 24 290
            Set Size to 13 42
            Set peAnchors to anTopRight
            
            Procedure Prompt_Callback Integer hPrompt
                Set Auto_Server_State of hPrompt to True
            End_Procedure

            Procedure Refresh Integer notifyMode
                Forward Send Refresh notifyMode
                //
                Boolean bGeoFence1Manual bIsMinOps
                //
                Get Checked_State of oLocation_Geo1ManualFlag to bGeoFence1Manual
                Move (giUserRights>=60) to bIsMinOps
                //
                Set Enabled_State of oLocation_Latitude to bGeoFence1Manual
                Set Enabled_State of oLocation_Longitude to bGeoFence1Manual
                Set Enabled_State of oLocation_GeoFenceRadius to bGeoFence1Manual
                Set Enabled_State of oUpdateButton to (not(bGeoFence1Manual))
                //
                Set Enabled_State of oGeoFence2DbGroup to bIsMinOps
                
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
            Set Location to 40 65
            Set Size to 13 90
            Set Label to "Area:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object
        
        Object oAreas_Manager is a cGlblDbForm
            Entry_Item Areas.Manager
            Set Location to 40 158
            Set Size to 13 81
            Set Enabled_State to False
            Set Prompt_Button_Mode to PB_PromptOff
            Set peAnchors to anTopLeftRight
        End_Object

        Object oLocation_Status is a cGlblDbComboForm
            Entry_Item Location.Status
            Set Location to 40 268
            Set Size to 12 63
            Set Label to "Status:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set peAnchors to anTopRight
        End_Object

        Object oPropmgr_ContactIdno is a cGlblDbForm
            Entry_Item Location.PropmgrIdno
            Set Location to 55 65
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
            Set Location to 55 125
            Set Size to 13 85
            Set Enabled_State to False
        End_Object

        Object oPropmgr_FirstName is a cGlblForm
//            Entry_Item Propmgr.FirstName
//            Set Server to oPropmgr_DD
            Set Location to 55 213
            Set Size to 13 70
            Set Enabled_State to False
            Set peAnchors to anTopLeftRight
        End_Object

        Object oSalesRepsButton is a Button
            Set Size to 13 46
            Set Location to 55 286
            Set Label to "Sales Reps"
            Set Skip_State to True
            Set peAnchors to anTopRight
        
            Procedure OnClick
                Integer iContactIdno
                //
                Get Field_Current_Value of oLocation_DD Field Location.PropmgrIdno to iContactIdno
                Send DoDisplaySalesReps of oContactEntry iContactIdno
            End_Procedure
        End_Object

        Object oLocation_DocumentFolder is a cGlblDbForm
            Entry_Item Location.DocumentFolder
            Set Location to 70 65
            Set Size to 14 218
            Set Label to "Document Folder:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Entry_State to False
            Set Enabled_State to False
            Set peAnchors to anTopLeftRight

            Procedure Refresh Integer notifyMode
                Forward Send Refresh notifyMode
                Set Enabled_State of oOpenButton to (Length(Trim(Location.DocumentFolder))>0)
            End_Procedure
        End_Object

        Object oOpenButton is a Button
            Set Size to 14 46
            Set Location to 70 286
            Set Label to 'Open'
            Set peAnchors to anTopRight
        
            // fires when the button is clicked
            Procedure OnClick
                
            End_Procedure
        
        End_Object


    End_Object

    Object oLocationTabDialog is a dbTabDialog
        Set Size to 214 345
        Set Location to 99 2
    
        Set Rotate_Mode to RM_Rotate
        Set peAnchors to anAll

        Object oAddressTabPage is a dbTabPage
            Set Label to "Address/Phones"

            Object oLocation_Address1 is a dbForm
                Entry_Item Location.Address1
                Set Location to 8 38
                Set Size to 13 142
                Set Label to "Address:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                Set Prompt_Button_Mode to PB_PromptOff
                Set peAnchors to anTopLeftRight
            End_Object

            Object oLocation_Address2 is a dbForm
                Entry_Item Location.Address2
                Set Location to 23 38
                Set Size to 13 141
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                Set peAnchors to anTopLeftRight
            End_Object

            Object oLocation_City is a dbForm
                Entry_Item Location.City
                Set Location to 39 38
                Set Size to 13 90
                Set Label to "City:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                Set peAnchors to anTopLeftRight
            End_Object

            Object oLocation_State is a dbForm
                Entry_Item Location.State
                Set Location to 54 38
                Set Size to 13 20
                Set Label to "State/Zip:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oLocation_Zip is a dbForm
                Entry_Item Location.Zip
                Set Location to 54 62
                Set Size to 13 66
                Set Label to ""
                Set peAnchors to anTopLeftRight
                //Set Form_Mask to "#####-####"
            End_Object

            Object oLocation_Phone1 is a dbForm
                Entry_Item Location.Phone1
                Set Location to 8 186
                Set Size to 13 62
                Set Label to "Phones:"
                Set Label_Justification_Mode to JMode_Top
                Set Label_Col_Offset to 0
                Set peAnchors to anTopRight
            End_Object

            Object oLocation_PhoneExt11 is a cGlblDbForm
                Entry_Item Location.PhoneExt1
                Set Location to 8 249
                Set Size to 13 34
                Set Label to "Ext:"
                Set Label_Justification_Mode to JMode_Top
                Set Label_Col_Offset to 0
                Set peAnchors to anTopRight
            End_Object

            Object oLocation_PhoneType1 is a cGlblDbComboForm
                Entry_Item Location.PhoneType1
                Set Location to 8 284
                Set Size to 13 52
                Set Label to "Types:"
                Set Label_Justification_Mode to JMode_Top
                Set Label_Col_Offset to 0
                Set peAnchors to anTopRight
            End_Object

            Object oLocation_Phone2 is a dbForm
                Entry_Item Location.Phone2
                Set Location to 23 186
                Set Size to 13 62
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                Set peAnchors to anTopRight
            End_Object

            Object oLocation_PhoneExt21 is a cGlblDbForm
                Entry_Item Location.PhoneExt2
                Set Location to 23 249
                Set Size to 13 34
                Set peAnchors to anTopRight
            End_Object

            Object oLocation_PhoneType2 is a cGlblDbComboForm
                Entry_Item Location.PhoneType2
                Set Location to 23 284
                Set Size to 13 52
                Set peAnchors to anTopRight
            End_Object

            Object oLocation_Phone3 is a dbForm
                Entry_Item Location.Phone3
                Set Location to 38 186
                Set Size to 13 62
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                Set peAnchors to anTopRight
            End_Object

            Object oLocation_PhoneExt3 is a cGlblDbForm
                Entry_Item Location.PhoneExt3
                Set Location to 38 249
                Set Size to 13 34
                Set peAnchors to anTopRight
            End_Object

            Object oLocation_PhoneType3 is a cGlblDbComboForm
                Entry_Item Location.PhoneType3
                Set Location to 38 284
                Set Size to 13 52
                Set peAnchors to anTopRight
            End_Object

//            Object oLocation_StartTime is a cSzdbTimeForm
//                Entry_Item Location.StartTime
//                Set Location to 100 191
//                Set Size to 13 90
//                Set Label to "Open Time:"
//                Set piTimeDisplayMode to SZTIME_DISPLAY_AMPM
//                Set pbDisplaySeconds to False
//                Set Label_Col_Offset to 3
//                Set Label_Justification_Mode to JMode_Right
//            End_Object
//
//            Object oLocation_StopTime is a cSzdbTimeForm
//                Entry_Item Location.StopTime
//                Set Location to 85 290
//                Set Size to 13 44
//                Set Label to "Close Time:"
//                Set piTimeDisplayMode to SZTIME_DISPLAY_AMPM
//                Set pbDisplaySeconds to False
//                Set Label_Col_Offset to 3
//                Set Label_Justification_Mode to JMode_Right
//            End_Object
//
//            Object oLocation_InvoiceLocation is a cGlblDbCheckBox
//                Entry_Item Location.InvoiceLocation
//                Set Location to 102 258
//                Set Size to 10 60
//                Set Label to "Invoice Location"
//            End_Object

            Object oCopyFromCustomerButton is a Button
                Set Size to 14 50
                Set Location to 38 130
                Set Label to 'Copy from ...'
                Set peAnchors to anTopRight
            
                // fires when the button is clicked
                Procedure OnClick
                    Send Popup of oCopyFromCJContextMenu
                End_Procedure
            
            End_Object
    
            Object oCopyFromCJContextMenu is a cCJContextMenu
                Object oCustomerMenuItem is a cCJMenuItem
                    Set psCaption to "Customer"
                    Set psTooltip to "Customer"

                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        // Copy From Customer Address
                        Send Refind_Records     of oLocation_DD
                        Set Field_Changed_Value of oLocation_DD Field Location.Address1   to Customer.Address1
                        Set Field_Changed_Value of oLocation_DD Field Location.Address2   to Customer.Address2
                        Set Field_Changed_Value of oLocation_DD Field Location.City       to Customer.City
                        Set Field_Changed_Value of oLocation_DD Field Location.State      to Customer.State
                        Set Field_Changed_Value of oLocation_DD Field Location.Zip        to Customer.Zip
                        Set Field_Changed_Value of oLocation_DD Field Location.Phone1     to Customer.Phone1
                        Set Field_Changed_Value of oLocation_DD Field Location.PhoneType1 to Customer.PhoneType1
                        Set Field_Changed_Value of oLocation_DD Field Location.Phone2     to Customer.Phone2
                        Set Field_Changed_Value of oLocation_DD Field Location.PhoneType2 to Customer.PhoneType2
                        Set Field_Changed_Value of oLocation_DD Field Location.Phone3     to Customer.Phone3
                        Set Field_Changed_Value of oLocation_DD Field Location.PhoneType3 to Customer.PhoneType3
                    End_Procedure
                End_Object

            End_Object

//            Object oCloneButton is a cGlblButton
//                Set Size to 14 107
//                Set Location to 38 133
//                Set Label to "Copy"
//
//                Procedure OnClick
//                    Send Refind_Records     of oLocation_DD
//                    Set Field_Changed_Value of oLocation_DD Field Location.Address1   to Customer.Address1
//                    Set Field_Changed_Value of oLocation_DD Field Location.Address2   to Customer.Address2
//                    Set Field_Changed_Value of oLocation_DD Field Location.City       to Customer.City
//                    Set Field_Changed_Value of oLocation_DD Field Location.State      to Customer.State
//                    Set Field_Changed_Value of oLocation_DD Field Location.Zip        to Customer.Zip
//                    Set Field_Changed_Value of oLocation_DD Field Location.Phone1     to Customer.Phone1
//                    Set Field_Changed_Value of oLocation_DD Field Location.PhoneType1 to Customer.PhoneType1
//                    Set Field_Changed_Value of oLocation_DD Field Location.Phone2     to Customer.Phone2
//                    Set Field_Changed_Value of oLocation_DD Field Location.PhoneType2 to Customer.PhoneType2
//                    Set Field_Changed_Value of oLocation_DD Field Location.Phone3     to Customer.Phone3
//                    Set Field_Changed_Value of oLocation_DD Field Location.PhoneType3 to Customer.PhoneType3
//                End_Procedure // OnClick
//
//            End_Object

            Object oLinkLabel1 is a cLinkLabel
                Set Size to 8 65
                Set Location to 57 137
                Set Label to '<A ID="LinkId" HREF="https://tools.usps.com/go/ZipLookupAction_input">Lookup 9-Diget Zip</a>'
                Set peAnchors to anTopRight
            End_Object
            
            //http://salestax.avalara.com/locations?a=20920%20Forest%20Rd%20N,%20Forest%20Lake,%20MN,%2055025-5028
            
            Object oAvaleraLinkLabel is a cLinkLabel
                Set Size to 8 82
                Set Location to 57 209
                Set Label to 'or    <A ID="LinkId" HREF="http://salestax.avalara.com/">Rate By Address</a>'
                Set peAnchors to anTopRight
                
                Procedure Mouse_Click Integer iWindowNumber Integer iPosition
                    String sAddress1 sAddress2 sCity sState sZip
                    Forward Send Mouse_Click iWindowNumber iPosition

                    Move (Replaces(" ",(trim(Location.Address1)),"+"))           to sAddress1    //20920+Forest+Rd+N
                    Move (Replaces(" ",(trim(Location.Address2)),"+"))           to sAddress2    //
                    Move (Replaces(" ",(trim(Location.City)),"+"))               to sCity        //Forest+Lake
                    Move (Replaces(" ",(trim(Location.State)),"+"))              to sState       //MN
                    Move (Replaces(" ",(trim(Location.Zip)),"+"))                to sZip         //55025
                    
                    Set Label of oLinkLabel1 to ('<a ID="LinkId" HREF="http://salestax.avalara.com/locations?a='+sAddress1+',%20'+sCity+',%20'+sState+',%20'+sZip+'">Get 9-Didget Zip</a>')
                End_Procedure

                
            End_Object

//            Object oGoogleMapsBrowser is a cComWebBrowser
//                
//                Set Size to 77 142
//                Set Location to 4 194
//                Set peAnchors to anTopLeftRight
//
//                Procedure OnCreate
//                    Forward Send OnCreate
//                    //Integer iValue
//                    //Get Size of oGoogleMapsTab to iValue 
//                    //Set Size to ((Hi(iValue) -10)) (Low(iValue) -10) 
//                    // First initialize the browser. that shows a nicer window
//                    Send ComNavigate "about:blank" 0 0 0 0
//
//                    // Send a message to paint the map for the current record if any
//                    Send RefreshMap
//                End_Procedure
//
//                //
//                //  Refreshes the map to display the current address in the buffer.
//                //
//                Procedure RefreshMap
//                    Handle hoWorkspace
//                    Boolean bIsCreated bHasRecord bEnabled
//                    String sAddress sAddress1 sAddress2 sCity sState sZip sLat sLon sRadius sRelevance
//                    String sUrl sAppHtml sSearchValue
//
//                    Get IsComObjectCreated to bIsCreated
//                    If (bIsCreated) Begin
//                        Move "about:blank" to sUrl
//
//                        //  Record in the buffer?
//                        Get HasRecord of oLocation_DD to bHasRecord
//                        If (bHasRecord) Begin
//                            //  Get the location of the AppHtml folder
//                            Get phoWorkspace of oApplication to hoWorkspace
//                            Get psAppHtmlPath of hoWorkspace to sAppHtml
//
//                            Get Field_Current_Value of oLocation_DD Field Location.Address1 to sAddress1
//                            Get Field_Current_Value of oLocation_DD Field Location.Address2 to sAddress2
//                            Get Field_Current_Value of oLocation_DD Field Location.City to sCity
//                            Get Field_Current_Value of oLocation_DD Field Location.State to sState
//                            Get Field_Current_Value of oLocation_DD Field Location.Zip  to sZip
//                            Get Field_Current_Value of oLocation_DD Field Location.Latitude to sLat
//                            Get Field_Current_Value of oLocation_DD Field Location.Longitude to sLon
//                            Get Field_Current_Value of oLocation_DD Field Location.GeoFenceRadius to sRadius
//                            Get Field_Current_Value of oLocation_DD Field Location.GeoRelevance to sRelevance
//                            //
//                            Move (Trim(Trim(sAddress1)*Trim(sAddress2))*Trim(sCity)*Trim(sState)*Trim(Left(sZip,5))) to sAddress
//                            Move (Replaces(' ',sAddress,'%20')) to sAddress
//                            //  Generate the URL using the contacts address
////                            // MAPBOX --------------------------------------------------------------------------------------------------------------
////                            Move (SFormat ("file://%1/mapbox_gl_js.html", sAppHtml)) to sUrl
////                            // MAPBOX --------------------------------------------------------------------------------------------------------------
//                            //Move (SFormat ("file://%1/GoogleSingleContactMapv3.html?search=%2", sAppHtml, sSearchValue)) to sUrl
//                            //file://%1/mapbox_gl_js.html
//                            // GOOGLE MAPS TARGED URL: ---------------------------------------------------------------------------------------------
//                            //https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2808.7570860178516!2d-92.98916888425573!3d45.25270465555147!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x52b2dd5d6fa4ba89%3A0xaec60a9bc6ae4b3f!2s20920%20Forest%20Rd%20N%2C%20Forest%20Lake%2C%20MN%2055025!5e0!3m2!1sen!2sus!4v1625578756782!5m2!1sen!2sus
//                            //Move ('https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d2808.7570860178516!2d'+(Trim(sLat))+'!3d'+(Trim(sLon))+'!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x52b2dd5d6fa4ba89%3A0xaec60a9bc6ae4b3f!2s'+sAddress+'!5e0!3m2!1sen!2sus!4v1625578756782!5m2!1sen!2sus') to sUrl
//                            Move (SFormat ("file://%1/maps.google.com.html?lat=%2&lon=%3&address=%4", sAppHtml, sLat, sLon, sAddress)) to sUrl
//                            // GOOGLE MAPS ---------------------------------------------------------------------------------------------------------
//                        End
//                        //  Navigate to the generated URL
//                        // Showln sUrl
//                        Send ComNavigate sUrl 0 0 0 0
//                    End
//                End_Procedure
//            End_Object // Browser

            Object oAPFormButton is a Button
                Set Size to 14 79
                Set Location to 140 38
                Set Label to "Create/Edit AP Form"
                Set peAnchors to anBottomLeft
            
                // fires when the button is clicked
                Procedure OnClick
                    Boolean bSuccess
                    Get PromptAPForm of oAPForm Location.LocationIdno to bSuccess
                End_Procedure
            End_Object
            Object oPriceListButton is a Button
                Set Size to 14 64
                Set Location to 140 121
                Set Label to "Price List"
                Set peAnchors to anBottomLeft
            
                // fires when the button is clicked
                Procedure OnClick
                    Send Activate_oOperationsEntry
                End_Procedure
            End_Object
            Object oEditCustomerButton is a Button
                Set Size to 14 67
                Set Location to 140 193
                Set Label to "Edit Customers"
                Set peAnchors to anBottomLeft
            
                Procedure OnClick
                    Send DoEditCustomers
                End_Procedure    
            End_Object
            Object oSnowBookButton is a Button
                Set Size to 14 67
                Set Location to 140 268
                Set Label to "Edit Snow Book"
                Set peAnchors to anBottomLeft
            
                // fires when the button is clicked
                Procedure OnClick
                    Boolean bShouldSave
                    //
                    Get Should_Save of oSnowbook to bShouldSave
                    If (bShouldSave) Begin
                        Send Stop_Box "There are unsaved changes in the Snow Book view"
                        Procedure_Return
                    End
                    Send DoEditSnowbook
                End_Procedure
            End_Object
            Object oSalesTaxGroup_Name is a cGlblDbForm
                Entry_Item SalesTaxGroup.Name
                Set Location to 160 38
                Set Size to 13 166
                Set Label to "Sales Tax:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
                Set peAnchors to anBottomLeftRight
            End_Object
            Object oSalesTaxGroup_Rate is a cGlblDbForm
                Entry_Item SalesTaxGroup.Rate
                Set Location to 160 208
                Set Size to 13 65
                Set peAnchors to anBottomRight
            End_Object
            Object oLinkLabel2 is a cLinkLabel
                Set Size to 8 49
                Set Location to 163 278
                Set Label to '<A ID="LinkId" HREF="http://www.revenue.state.mn.us/businesses/sut/Pages/SalesTaxCalculator.aspx">Tax Calculator</A>'
                Set peAnchors to anBottomRight
            End_Object
            Object oLocation_BillingAddress is a cGlblDbComboForm
                Entry_Item Location.BillingAddress
                Set Location to 179 38
                Set Size to 12 296
                Set Label to "Billing:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set Allow_Blank_State to True
                Set Combo_Sort_State to False
                Set Enabled_State to False
                Set peAnchors to anBottomLeftRight
            End_Object

            Object oLineControl2 is a LineControl
                Set Size to 2 324
                Set Location to 72 9
            End_Object

            Object oLineControl2 is a LineControl
                Set Size to 2 324
                Set Location to 136 9
                Set peAnchors to anBottomLeftRight
            End_Object

            Object oGeoFence1DbGroup is a dbGroup
                Set Size to 58 164
                Set Location to 74 6
                Set Label to 'Primary GeoFence (Sales)'

                Object oLocation_Latitude is a cGlblDbForm
                    Entry_Item Location.Latitude
                    Set Location to 18 10
                    Set Size to 13 44
                    Set Label to "Latitude:"
                    Set Label_Col_Offset to 0
                    Set Label_Justification_Mode to JMode_Top
                    Set Label_FontUnderLine to True
                    
                    Procedure OnChange
                        Forward Send OnChange
                        If (Value(Self)=0.00) Set Label_TextColor to clRed
                        Else Set Label_TextColor to clBlack 
                    End_Procedure
                    
                End_Object
                Object oLocation_Longitude is a cGlblDbForm
                    Entry_Item Location.Longitude
                    Set Location to 18 56
                    Set Size to 13 44
                    Set Label to "Longitude:"
                    Set Label_Col_Offset to 0
                    Set Label_Justification_Mode to JMode_Top
                    Set Label_FontUnderLine to True
                    
                    Procedure OnChange
                        Forward Send OnChange
                        If (Value(Self)=0.00) Set Label_TextColor to clRed
                        Else Set Label_TextColor to clBlack 
                    End_Procedure
                End_Object
                Object oShowOnMapButton is a Button
                    Set Size to 14 34
                    Set Location to 18 105
                    Set Label to 'Show'
                
                    // fires when the button is clicked
                    Procedure OnClick
                        String sLink
                        Move ('https://www.google.com/maps?z=6&t=m&q=loc:'+ (Trim(Location.Latitude)) +'+'+ (Trim(Location.Longitude))) to sLink
                        Runprogram Shell Background sLink
                    End_Procedure
                
                End_Object
                Object oLocation_GeoFenceRadius is a cGlblDbForm
                    Entry_Item Location.GeoFenceRadius
                    Set Location to 42 10
                    Set Size to 13 44
                    Set Label to "GeoFence Radius:"
                    Set Label_Col_Offset to 0
                    Set Label_Justification_Mode to JMode_Top
                    Set Label_FontUnderLine to True
                    
                    Procedure OnChange
                        Forward Send OnChange
                        If (Value(Self)=0.00) Set Label_TextColor to clRed
                        Else Set Label_TextColor to clBlack 
                    End_Procedure
                End_Object
                Object oUpdateButton is a Button
                    Set Size to 14 42
                    Set Location to 42 57
                    Set Label to 'Update'
                
                    // fires when the button is clicked
                    Procedure OnClick
                        String sLogMsg
                        Boolean bSuccess bErr
                        Integer eResponse
                        //
                        Move (YesNo_Box('Are you sure you like to update the GEO Location info for this site?','Update GEO Location info?',MBR_Yes)) to eResponse
                        If (eResponse=MBR_Yes) Begin
                            Get Request_Validate of oLocation_DD to bErr
                            If (bErr) Begin
                                Procedure_Return
                            End
                            Send Request_Save of oLocation_DD
                            Get UpdatedGeoLocationDetails of oGeoLocationUpdate (Location.LocationIdno) (&sLogMsg) to bSuccess
                            If (bSuccess) Begin
                                Send Info_Box (sLogMsg) "Location Updated"
                                Send Activate of oLocation_Name
                                Send Request_Superfind of oLocation_Name EQ
                            End
                            Else Send Stop_Box (sLogMsg) "Error updating"
                        End
                    End_Procedure
                
                End_Object
                Object oLocation_Geo1ManualFlag is a cGlblDbCheckBox
                    Entry_Item Location.Geo1ManualFlag
                    Set Location to 44 104
                    Set Size to 10 60
                    Set Label to "Manual"
    
                    Procedure OnChange
                        Forward Send OnChange
                        Boolean bErr
                        If (Changed_State(oLocation_DD)) Begin
                            Get Request_Validate of oLocation_DD to bErr
                            If (not(bErr)) Begin
                                Send Request_Save of oLocation_DD
                                Move (Err) to bErr
                            End
                        End
                    End_Procedure
                End_Object
            End_Object

            Object oGeoFence2DbGroup is a dbGroup
                Set Size to 58 163
                Set Location to 74 172
                Set Label to 'Secondary GeoFence (Ops)'

                Object oLocation_Latitude2 is a cGlblDbForm
                    Entry_Item Location.Latitude2
                    Set Location to 18 8
                    Set Size to 13 53
                    Set Label to "Latitude2:"
                    Set Label_Col_Offset to 0
                    Set Label_Justification_Mode to JMode_Top
                    Set Label_FontUnderLine to True
                End_Object

                Object oLocation_Longitude2 is a cGlblDbForm
                    Entry_Item Location.Longitude2
                    Set Location to 18 65
                    Set Size to 13 53
                    Set Label to "Longitude2:"
                    Set Label_Col_Offset to 0
                    Set Label_Justification_Mode to JMode_Top
                    Set Label_FontUnderLine to True
                End_Object

                Object oLocation_GeoFenceRadius2 is a cGlblDbForm
                    Entry_Item Location.GeoFenceRadius2
                    Set Location to 42 8
                    Set Size to 13 53
                    Set Label to "GeoFenceRadius2:"
                    Set Label_Col_Offset to 0
                    Set Label_Justification_Mode to JMode_Top
                    Set Label_FontUnderLine to True
                End_Object

                Object oShowSecOnMapButton is a Button
                    Set Size to 14 34
                    Set Location to 17 125
                    Set Label to 'Show'
                
                    // fires when the button is clicked
                    Procedure OnClick
                        String sLink
                        Move ('https://www.google.com/maps?z=6&t=m&q=loc:'+ (Trim(Location.Latitude2)) +'+'+ (Trim(Location.Longitude2))) to sLink
                        Runprogram Shell Background sLink
                    End_Procedure
                
                End_Object
            End_Object

        End_Object
        
//        Object oGoogleMapsTab is a dbTabPage
//            Set Label to "Google Maps"
//
//            Object oGoogleMapsBrowser is a cComWebBrowser
//                
//                Set Size to 134 334
//                Set Location to 4 3
//                Set peAnchors to anAll
//
//                Procedure OnCreate
//                    Forward Send OnCreate
//                    Integer iValue
//                    Get Size of oGoogleMapsTab to iValue 
//                    Set Size to ((Hi(iValue) -10)) (Low(iValue) -10) 
//                    // First initialize the browser. that shows a nicer window
//                    Send ComNavigate "about:blank" 0 0 0 0
//
//                    // Send a message to paint the map for the current record if any
//                    Send RefreshMap
//                End_Procedure
//
//                //
//                //  Refreshes the map to display the current address in the buffer.
//                //
//                Procedure RefreshMap
//                    Handle hoWorkspace
//                    Boolean bIsCreated bHasRecord bEnabled
//                    String sAddress1 sAddress2 sCity sState sCountry
//                    String sUrl sAppHtml sSearchValue
//
//                    Get IsComObjectCreated to bIsCreated
//                    If (bIsCreated) Begin
//                        Move "about:blank" to sUrl
//
//                        //  Record in the buffer?
//                        Get HasRecord of oLocation_DD to bHasRecord
//                        If (bHasRecord) Begin
//                            //  Get the location of the AppHtml folder
//                            Get phoWorkspace of oApplication to hoWorkspace
//                            Get psAppHtmlPath of hoWorkspace to sAppHtml
//
//                            Get Field_Current_Value of oLocation_DD  Field Location.Address1 to sAddress1
//                            Get Field_Current_Value of oLocation_DD  Field Location.Address2 to sAddress2
//                            Get Field_Current_Value of oLocation_DD Field  Location.City to sCity
//                            Get Field_Current_Value of oLocation_DD Field  Location.State to sState
//                            Get Field_Current_Value of oLocation_DD Field  Location.Zip  to sCountry
//
//                            Move (SFormat ("%1, %3, %4, %5, %2", Trim (sAddress1), Trim (sAddress2), Trim (sCity), Trim (sState), Trim (sCountry))) to sSearchValue
//                          
//                            //  Generate the URL using the contacts address
//                            //file://%1/mapbox_gl_js.html
//                            Move (SFormat ("file://%1/maps.google.com.html", sAppHtml)) to sUrl
//                            //Move ("https://www.interstatepm.com") to sUrl
//                        End
//                        //  Navigate to the generated URL
//                        // Showln sUrl
//                        Send ComNavigate sUrl 0 0 0 0
//                    End
//                End_Procedure
//            End_Object // Browser
//      End_Object// TabPage
        
        
       Object oContactTabPage is a dbTabPage
            Set Label to "Location Contact"

           Object oLocation_ContactName is a dbForm
               Entry_Item Location.ContactName
               Set Location to 10 46
               Set Size to 13 226
               Set Label to "Name:"
               Set Label_Justification_Mode to JMode_Right
               Set Label_Col_Offset to 3
           End_Object

           Object oLocation_ContactPhone1 is a dbForm
               Entry_Item Location.ContactPhone1
               Set Location to 25 46
               Set Size to 13 62
               Set Label to "Phones:"
               Set Label_Justification_Mode to JMode_Right
               Set Label_Col_Offset to 3
           End_Object

           Object oLocation_PhoneExt1 is a cGlblDbForm
               Entry_Item Location.PhoneExt1
               Set Location to 25 137
               Set Size to 13 42
               Set Label to "Ext:"
               Set Label_Col_Offset to 3
               Set Label_Justification_Mode to JMode_Right
           End_Object

           Object oLocation_ContactPhnType1 is a cGlblDbComboForm
               Entry_Item Location.ContactPhnType1
               Set Location to 25 220
               Set Size to 13 52
               Set Label to "Types:"
               Set Label_Col_Offset to 3
               Set Label_Justification_Mode to JMode_Right
           End_Object

           Object oLocation_ContactPhone2 is a dbForm
               Entry_Item Location.ContactPhone2
               Set Location to 40 46
               Set Size to 13 62
               Set Label_Justification_Mode to JMode_Right
               Set Label_Col_Offset to 3
           End_Object

           Object oLocation_PhoneExt2 is a cGlblDbForm
               Entry_Item Location.PhoneExt2
               Set Location to 40 137
               Set Size to 13 42
           End_Object

           Object oLocation_ContactPhnType2 is a cGlblDbComboForm
               Entry_Item Location.ContactPhnType2
               Set Location to 40 220
               Set Size to 13 52
           End_Object

           Object oLocation_ContactEmail is a cGlblDbForm
               Entry_Item Location.ContactEmail
               Set Location to 55 46
               Set Size to 13 226
               Set Label to "Email:"
               Set Label_Col_Offset to 3
               Set Label_Justification_Mode to JMode_Right
           End_Object

           Object oLocation_ContactComment is a cDbTextEdit
               Entry_Item Location.ContactComment
               Set Location to 70 46
               Set Size to 42 226
               Set Label to "Comment:"
               Set Label_Col_Offset to 3
               Set Label_Justification_Mode to JMode_Right
           End_Object

           Object oCreateContactButton is a Button
               Set Size to 14 63
               Set Location to 10 276
               Set Label to "Create Contact"
           
               Procedure OnClick
                   Send DoCreateContact
               End_Procedure           
           End_Object
       End_Object

        Object oAlternateBillingAddressTabPage is a dbTabPage
            Set Label to "Alternate Billing Address"

            Object oLocation_BillingName is a cGlblDbForm
                Entry_Item Location.BillingName
                Set Location to 13 66
                Set Size to 13 216
                Set Label to "Customer:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oLocation_BillingAttn is a cGlblDbForm
                Entry_Item Location.BillingAttn
                Set Location to 28 66
                Set Size to 13 216
                Set Label to "Attention:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oLocation_BillingAddress1 is a cGlblDbForm
                Entry_Item Location.BillingAddress1
                Set Location to 43 66
                Set Size to 13 216
                Set Label to "Address:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oLocation_BillingAddress2 is a cGlblDbForm
                Entry_Item Location.BillingAddress2
                Set Location to 58 66
                Set Size to 13 216
            End_Object

            Object oLocation_BillingCity is a cGlblDbForm
                Entry_Item Location.BillingCity
                Set Location to 73 66
                Set Size to 13 156
                Set Label to "City:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oLocation_BillingState is a cGlblDbForm
                Entry_Item Location.BillingState
                Set Location to 88 66
                Set Size to 13 20
                Set Label to "State/Zip:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oLocation_BillingZip is a cGlblDbForm
                Entry_Item Location.BillingZip
                Set Location to 88 90
                Set Size to 13 66
                //Set Form_Mask to "#####-####"
            End_Object
        End_Object

//        Object oParkingLotTabPage is a dbTabPage
//            Set Label to "Maping"
//
//            Object oParkingLotList is a dbList
//                Set Size to 54 332
//                Set Location to 5 4
//                Set Move_Value_Out_State to False
//
//                Begin_Row
//                    Entry_Item Parklots.ParkingLotId
//                    Entry_Item Parklots.Description
//                    Entry_Item Parklots.SqFtTotal
//                End_Row
//
//                Set Main_File to Parklots.File_number
//
//                Set Server to oParklots_DD
//
//                Set Form_Width 0 to 1
//                Set Form_Width 1 to 270
//                Set Header_Label 1 to "Description"
//                Set Form_Width 2 to 48
//                Set Header_Label 2 to "SqFt Total"
//                Set Header_Justification_Mode 2 to JMode_Right
//            End_Object
//
//            Object oAddButton is a Button
//                Set Location to 96 5
//                Set Label to "Add"
//            
//                Procedure OnClick
//                    Send DoAddParkingLot
//                End_Procedure            
//            End_Object
//
//            Object oEditButton is a Button
//                Set Location to 96 60
//                Set Label to "Edit"
//            
//                Procedure OnClick
//                    Send DoEditParkingLot
//                End_Procedure            
//            End_Object
//
//            Procedure DoAddParkingLot
//                Integer hoDD iRecId
//                //
//                Move oParklots_DD   to hoDD
//                Send Refind_Records of hoDD
//                Get DoAddParkingLot of oParkingLot Location.Recnum to iRecId
//                If (iRecId) Begin
//                    Send Find_By_Recnum of hoDD Parklots.File_Number iRecId
//                    Send Refresh_Page   of oParkingLotList FILL_FROM_CENTER
//                End
//                Send Activate of oParkingLotList
//            End_Procedure
//        
//            Procedure DoEditParkingLot
//                Integer hoDD iRecId
//                //
//                Move oParklots_DD   to hoDD
//                If (Current_Record(hoDD)) Begin
//                    Get Current_Record    of hoDD     to iRecId
//                    Send DoEditParkingLot of oParkingLot iRecId
//                    Send Find_By_Recnum   of hoDD Parklots.File_Number iRecId
//                    Send Refresh_Page     of oParkingLotList FILL_FROM_CENTER
//                End
//            End_Procedure
//        End_Object
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
    
    Procedure DoEditSnowbook
        Send DoEditSnowbook of oSnowBook (CurrentRowId(oLocation_DD))
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
    
    Procedure DoPrintOperations   
        Boolean bCancel
        Integer iRefId
        //
        Get Field_Current_Value of oLocation_DD Field Location.LocationIdno to iRefId
        Get Confirm ("Print Operations List" * String(iRefId) + "?")       to bCancel
        If (not(bCancel)) Begin
            Send DoJumpStartReport of LocationPricing iRefId
        End       
    End_Procedure

    Procedure CheckReqFields Integer[] ByRef iLabelColor
        Broadcast Recursive Send CheckRequiredFields (&iLabelColor)
    End_Procedure

    Function CancelNavigation Returns Boolean
        Boolean bCancel
        Integer iFieldCount iRedCount
        Integer[] iLabelColor
        Send CheckReqFields of oLocationEntry (&iLabelColor)
        For iFieldCount from 0 to (SizeOfArray(iLabelColor)-1)
            If (iLabelColor[iFieldCount]=clRed) Begin
                Increment iRedCount
            End
        Loop
        //Move ((HasRecord(oLocation_DD)) and (Location.Latitude=0 or Location.Longitude=0 or Location.GeoFenceRadius=0)) to bCancel
        If (iRedCount and (HasRecord(oLocation_DD) or Changed_State(oLocation_DD))) Begin
            Send Info_Box ("There are "+String(iRedCount)+" required Fields not filled out.") "Missing Fields"
            Function_Return True
        End
        Function_Return False
    End_Function

    Set Verify_Exit_Msg to (RefFunc(CancelNavigation))

//
//    Procedure DoDeleteLocation
//        Forward Send Request_Delete
//    End_Procedure
//    //
//    On_Key kUser Send DoDeleteLocation
 
End_Object
