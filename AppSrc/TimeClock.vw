#IFNDEF ptStartActive
Enum_List // punch type
    Define ptStartActive
    Define ptStartBreak
    Define ptStopShift
End_Enum_List
#ENDIF

Use Windows.pkg
Use DFClient.pkg
Use cTempusDbView.pkg
Use cTextEdit.pkg
//Use cszDropDownButton.pkg
Use TransactionProcess.bp
Use cWSTransactionService.pkg
Use Dates.nui
Use dfLine.pkg

Use Employer.DD
Use Employee.DD
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use Equipmnt.DD
Use cWebAppUserRightsGlblDataDictionary.dd

//Use TimeCard.rv
Use TimeCard.vw
Use LoadingPopup.dg
Use Rgb_Custom.pkg
Use cWSSystemLinkAPI.pkg

Activate_View Activate_oTimeClock for oTimeClock
Object oTimeClock is a dbView
    Property Integer piActiveEntry
    
    Integer iActiveEntry iEmployeeIdno iJobNumber iEquipNumber iOpersIdno
    Boolean bEmplOk bJobOk bEquipOk

    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
    End_Object

    Object oEquipmnt_DD is a Equipmnt_DataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Move 1 to iActiveEntry
        
    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oWebAppUserRights_DD
        Set DDO_Server to oEmployer_DD
    End_Object

    Set Main_DD to oEmployee_DD
    Set Server to oEmployee_DD
    Set Size to 279 478
    Set View_Mode to Viewmode_Zoom
    Set Auto_Top_View_State to True
    Set View_Latch_State to False
    Set Maximize_Icon to True
    Set Sysmenu_Icon to False
    Set pbSizeToClientArea to False

    Procedure UpdateEmployee 
        String sErrorMsg
        Integer iAltEmployeeIdno
        Get Value of oEmployeeNumberForm to iEmployeeIdno
        Get IsEmployeeValid of oEmployee_DD iEmployeeIdno (&iAltEmployeeIdno) (&sErrorMsg) to bEmplOk
        If (bEmplOk) Begin
            Set Value of oEmployeeNameForm to (Trim(Employee.FirstName) * Trim(Employee.LastName))
        End
        Else Begin
            Set Value of oEmployeeNameForm to ""
        End
        // Refresh
        Send Refresh_Status of oStatusForm
    End_Procedure
    
    Procedure UpdateJob
        String sErrorMsg
        Integer iLocIdno iAltJobNumber
        Boolean bOk 
        Get Value of oJobNumberForm to iJobNumber
        Get IsJobValid of oOrder_DD iJobNumber (&iLocIdno) (&iAltJobNumber) (&sErrorMsg) to bJobOk
        If (bJobOk) Begin
            Move iLocIdno to Location.LocationIdno
            Find EQ Location by 1
            Set Value of oJobNameForm to (Trim(Location.Name) * " - " * Trim(Order.Title))
        End
        Else Begin
            Set Value of oJobNameForm to ""
        End
        // Refresh
        Send Refresh_Status of oStatusForm
    End_Procedure
    
    Procedure UpdateEquipment
        String sValue sErrorMsg
        Integer iAltEmplNumber
        Get Value of oEquipNumberForm to iEquipNumber
        Get IsEquipmentValid of oEquipmnt_DD Location.LocationIdno iEquipNumber (&iOpersIdno) (&iAltEmplNumber) (&sErrorMsg) to bEquipOk
        If (bEquipOk) Begin
            Set Value of oEquipNameForm to (Trim(Equipmnt.Description))
        End
        Else Begin
            Set Value of oEquipNameForm to ""
        End                 
        // Refresh
        Send Refresh_Status of oStatusForm           
    End_Procedure

    Procedure DoIncrementCurrentDisplay Integer iNumber
        Integer hoDD iEmpltimeId
        String  sNumber
        Date    dToday
        //
        If (iActiveEntry = 1) Begin
            Get Value of oEmployeeNumberForm        to sNumber
            Move (sNumber + String(iNumber))        to sNumber
            Set Value of oEmployeeNumberForm        to sNumber
            Send UpdateEmployee     
        End
        Else If (iActiveEntry = 2) Begin
            Get Value of oJobNumberForm             to sNumber
            Move (sNumber + String(iNumber))        to sNumber
            Set Value of oJobNumberForm             to sNumber
            Send UpdateJob
        End
        Else If (iActiveEntry = 3) Begin
            Get Value of oEquipNumberForm           to sNumber
            Move (sNumber + String(iNumber))        to sNumber
            Set Value of oEquipNumberForm           to sNumber
            Send UpdateEquipment
        End
        //Else Send Info_Box "No object selected" "Select Empl#, Job# or Equip#"
    End_Procedure

    Procedure DoDecrementDisplay
        Integer iLength
        String  sNumber
        //
        //
        If (iActiveEntry = 1) Begin //Employee Number
            Get Value of oEmployeeNumberForm to sNumber
            Move (Length(sNumber)) to iLength
            If (iLength = 1) Begin
                Move "" to sNumber
            End
            Else Begin
                Decrement iLength
                Move (Left(sNumber,(iLength))) to sNumber
            End
            Set Value of oEmployeeNumberForm        to sNumber    
            Send UpdateEmployee        
        End
        Else If (iActiveEntry = 2) Begin // Job Number
            Get Value of oJobNumberForm to sNumber
            Move (Length(sNumber)) to iLength
            If (iLength = 1) Begin
                Move "" to sNumber
            End
            Else Begin
                Decrement iLength
                Move (Left(sNumber,(iLength))) to sNumber
            End
            Set Value of oJobNumberForm             to sNumber
            Send UpdateJob              
        End
        Else If (iActiveEntry = 3) Begin // Equipment Number
            Get Value of oEquipNumberForm to sNumber
            Move (Length(sNumber)) to iLength
            If (iLength = 1) Begin
                Move "" to sNumber
            End
            Else Begin
                Decrement iLength
                Move (Left(sNumber,(iLength))) to sNumber
            End
            Set Value of oEquipNumberForm             to sNumber   
            Send UpdateEquipment             
        End                                       
    End_Procedure
    
    Procedure StartTransaction String sEmplIdno String sTransType String sLoc1 String sEquipIdno
        Boolean bOk
        String sCallerId
        Number nGPSLatOffice nGPSLongOffice
        //
        Move "6517650765" to sCallerId
        Move 45.252730 to nGPSLatOffice
        Move -92.986679 to nGPSLongOffice
        //
        String sHost sPath sData
        Integer iSoF
        
        Move "tempus.interstatepm.com" to sHost // Live
        //Move "192.168.50.149" to sHost // Development
        Move "ISC/SmartCreateTransaction.asp?" to sPath
        Move ("p_t="+sEmplIdno+"&transtype="+sTransType+"&locid1="+sLoc1+"&equipmentid="+sEquipIdno+"&locid2=0&materialid=0&materialqty=0&phone="+sCallerId+"&gps_lat="+String(nGPSLatOffice)+"&gps_long="+String(nGPSLongOffice)+"&attach_idno=0") to sData
        
        Set psRemoteHost of oHttpPostRequest to sHost
        Get AddHeader of oHttpPostRequest "Content-Type" "application/x-www-form-urlencoded" to bOk
        Get HttpPostRequest of oHttpPostRequest sPath sData 0 to iSoF 
    End_Procedure
        
    Procedure DoClearDisplay
        // Reset All Fields
        Set Value        of oEmployeeNameForm to ""
        Set Value        of oEmployeeNumberForm to ""
        Set Value        of oJobNameForm to ""
        Set Value        of oJobNumberForm to ""
        Set Value        of oEquipNameForm to ""
        Set Value        of oEquipNumberForm to ""
        // Clear All Data From DDs
        Send Clear_All   of oEmployee_DD oOrder_DD oEquipmnt_DD
        // Reset all Variables
        Move 0 to iActiveEntry
        Move 0 to iEmployeeIdno
        Move 0 to iJobNumber
        Move 0 to iEquipNumber
        Move 0 to iOpersIdno
        //
        Send UpdateEmployee
        Send UpdateJob
        Send UpdateEquipment
        //
        Send Entering of oEmployeeNumberForm
    End_Procedure

    Procedure XMLParser String sXMLData String ByRef sID String ByRef sP_T String ByRef sStatus String ByRef sMSG
        Handle hoXML hoRoot hoList hoParams
        Integer iItems i bOK

        Get Create (RefClass(cXMLDOMDocument)) to hoXML
        
        Get LoadXML of hoXML sXMLData to bOK
        //Set psDocumentName of hoXML to 
        //       Set pbAsync of hoXML to False
        //       Set pbValidateOnParse of hoXML to True
        //       Get LoadXMLDocument of hoXML to bOK
        
        If not bOK Begin
        Send BasicParseErrorReport of hoXml
            Procedure_Return
        End
        //Showln 'loaded'
        Get DocumentElement of hoXML to hoRoot
        Get FindNodeList of hoRoot "parameters" to hoList
        Get NodeListLength of hoList to iItems
        Decrement iItems
        For i from 0 to iItems
            Get CollectionNode of hoList i to hoParams
            // Save Parameters to Variable
            Get ChildNodeValue of hoParams "id" to sID
            Get ChildNodeValue of hoParams "p_t" to sP_T
            Get ChildNodeValue of hoParams "status" to sStatus
            Get ChildNodeValue of hoParams "msg" to sMSG
            //Showln ("ID:"+sID * "p_t:"+sP_T * "status:"+sStatus * "Message:"+sMSG)
            Send Destroy of hoParams
        Loop
        Send Destroy of hoList
        Send Destroy of hoRoot
        Send Destroy of hoXML
    End_Procedure

    Object oWSSystemLinkAPI is a cWSSystemLinkAPI
    
        //
        // Interface:
        //
        // Function wsCreateTimeTransaction String llsEmployeeNumber String llsJobNumber String llsEquipNumber String llsPhone String llsGPSLat String llsGPSLong String llsAttachIdno String BYREF llsErrorMsg Returns Boolean
        // Function wsCreateMaterialTransaction String llsEmployeeNumber String llsJobNumber String llsEquipNumber String llsMatQty String llsPhone String llsGPSLat String llsGPSLong String BYREF llsErrorMsg Returns Boolean
        // Function wsEndShiftTransaction String llsEmployeeIdno String llsPhone String llsGPSLat String llsGPSLong String BYREF llsErrorMsg Returns Boolean
        //
    
    
        // phoSoapClientHelper
        //     Setting this property will pop up a view that provides information
        //     about the Soap (xml) data transfer. This can be useful in debugging.
        //     If you use this you must make sure you USE the test view at the top
        //     of your program/view by adding:   Use WebClientHelper.vw // oClientWSHelper
        //Set phoSoapClientHelper to oClientWSHelper
    
    End_Object

//    Object oWSTransactionService1 is a cWSTransactionService
//    
//        //
//        // Interface:
//        //
//        // Function wsCreateTimeTransaction String llsEmployeeNumber String llsJobNumber String llsEquipNumber String llsPhone String llsGPSLat String llsGPSLong String llsAttachIdno String BYREF llsErrorMsg Returns Boolean
//        // Function wsCreateMaterialTransaction String llsEmployeeNumber String llsJobNumber String llsEquipNumber String llsMatQty String llsPhone String llsGPSLat String llsGPSLong String BYREF llsErrorMsg Returns Boolean
//        // Function wsEndShiftTransaction String llsEmployeeIdno String llsPhone String llsGPSLat String llsGPSLong String BYREF llsErrorMsg Returns Boolean
//        // Function wsDoCreateIdleTransaction Integer lliEmployeeIdno Integer lliJobNumber Integer lliOpersIdno Returns Boolean
//        // Function wsDoEndShift Integer lliEmployeeIdno Returns Boolean
//        // Function wsGetNewTransactions Returns tWStNewTransaction[]
//        // Function wsUpdateCollectedTransactions tWStCollectedTransaction[] lltTransactions Returns Integer
//        // Function wsUpdateEmployeeRecords Returns tWStEmployee[]
//        // Function wsGetNewLocationNotes Returns tWStLocnotes[]
//        // Function wsUpdateCollectedLocationNotes tWStLocnotes[] lltNotes Returns Integer
//        // Function wsDoCloseExpiredLocationNote Integer lliLocnoteIdno Returns Boolean
//        // Function wsGetSelectedLocationNotes Integer lliJobNumber Date lldNoteDate Date lldNoteStopDate Returns tWStLocnotes[]
//        // Function wsGetNewAreaNotes Returns tWStAreanote[]
//        // Function wsUpdateCollectedAreaNotes tWStAreanote[] lltNotes Returns Integer
//        // Function wsUpdateMastOps tWStMastOps[] lltMastOpsUpdate Returns tWStMastOps[]
//        // Function wsUpdateLocNotes tWStLocnotes[] lltLocNotesUpdate Returns tWStLocnotes[]
//        // Function wsUpdateAreas tWStAreas[] lltAreasUpdate Returns tWStAreas[]
//        // Function wsUpdateCustomer tWStCustomer[] lltCustomerUpdate Returns tWStCustomer[]
//        // Function wsUpdateTerms tWStTerms[] lltTermsUpdate Returns tWStTerms[]
//        // Function wsUpdateSalesTaxGroup tWStSalesTaxGroup[] lltSalesTaxGroupUpdate Returns tWStSalesTaxGroup[]
//        // Function wsUpdateLocation tWStLocation[] lltLocationUpdate Returns tWStLocation[]
//        // Function wsUpdateOpers tWStOpers[] lltOpersUpdate Returns tWStOpers[]
//        // Function wsUpdateOrder tWStOrder[] lltOrderUpdate Returns tWStOrder[]
//        // Function wsUpdateInvhdr tWStInvhdr[] lltInvhdrUpdate Returns tWStInvhdr[]
//        // Function wsUpdateEmployer tWStEmployer[] lltEmployerUpdate Returns tWStEmployer[]
//        // Function wsUpdateEmployee tWStEmployee[] lltEmployeeUpdate Returns tWStEmployee[]
//        // Function wsUpdateEquipmnt tWStEquipmnt[] lltEquipmntUpdate Returns tWStEquipmnt[]
//        // Function wsUpdateLocEquip tWStLocEquip[] lltLocEquipUpdate Returns tWStLocEquip[]
//        // Function wsUpdateSalesRep tWStSalesRep[] lltSalesRepUpdate Returns tWStSalesRep[]
//        // Function wsUpdateWorkType tWStWorkType[] lltWorkTypeUpdate Returns tWStWorkType[]
//        // Function wsUpdateUser tWStUser[] lltUserUpdate Returns tWStUser[]
//        // Function wsUpdateWebAppUserRights tWStWebAppUserRights[] lltWebAppUserRightsUpdate Returns tWStWebAppUserRights[]
//        // Function wsUpdateWebAppUser tWStWebAppUser[] lltWebAppUserUpdate Returns tWStWebAppUser[]
//        // Function wsUpdateContact tWStContact[] lltContactUpdate Returns tWStContact[]
//        // Function wsUpdateReqtypes tWStReqtypes[] lltUpdate Returns tWStReqtypes[]
//        // Function wsGetOpenTransactions Returns tWStNewTransaction[]
//        // Function wsLogEvent Integer lliEventType String lllpszEvent Returns tWSLogEventResponse
//        //
//    
//    
//        // phoSoapClientHelper
//        //     Setting this property will pop up a view that provides information
//        //     about the Soap (xml) data transfer. This can be useful in debugging.
//        //     If you use this you must make sure you USE the test view at the top
//        //     of your program/view by adding:   Use WebClientHelper.vw // oClientWSHelper
//        //Set phoSoapClientHelper to oClientWSHelper
//    
//    End_Object

    
    
    Object oHttpPostRequest is a cHttpTransfer
        Procedure OnDataReceived String sContentType String sData
            // You can abort file transfer here with 'Send CancelTransfer'
            String sID sP_T sStatus sMSG
            //Showln sData
            Send XMLParser sData (&sID) (&sP_T) (&sStatus) (&sMSG)
            If (sID = "1") Begin //Transaction Successfull
                //Send Info_Box sMSG
                Send DoClearDisplay
            End
            Else If (sID = "0") Begin // Transaction Failed
                Send Stop_Box sMSG "Transaction Failed"
            End
        End_Procedure
    End_Object
    
        
//        Object oBackButton is a Button
//            Set Size to 30 62
//            Set Location to 165 348
//            Set Label to "<< Back"
//        
//            // fires when the button is clicked
//            Procedure OnClick
//                Case Begin
//                    Case (iActiveEntry=1)
//                        
//                        Case Break
//                    Case (iActiveEntry=2)
//                        Set Value of oJobNumberForm to ""
//                        Send Activate of oEmployeeNumberForm
//                        Case Break
//                    Case (iActiveEntry=3)
//                        Set Value of oEquipNumberForm to ""
//                        Send Activate of oJobNumberForm
//                        Case Break
//                Case End
//            End_Procedure
//        
//        End_Object


    Object oGroup1 is a Group
        Set Size to 181 305
        Set Location to 41 5
        Set Label to ''
        Set peAnchors to anAll

        Object oStatusForm is a Form
            Set Size to 13 176
            Set Location to 10 11
            Set Enabled_State to False
            Set FontPointHeight to 16
            Set Form_Justification_Mode to Form_DisplayCenter
            Set peAnchors to anTopLeftRight
            
            Procedure Refresh_Status                
                Integer iStartColor iEndColor iTimeCardColor iNextColor
                // Start Button
                Set Enabled_State of oStartActiveButton to (bEmplOk and bJobOk and bEquipOk)
                If (bEmplOk and bJobOk and bEquipOk) Move clGreen to iStartColor
                Else Move clLtGray to iStartColor
                Set Color of oStartActiveButton to iStartColor
                // End Button
                Set Enabled_State of oEndButton to (bEmplOk and not(bJobOk) and not(bEquipOk))
                If (bEmplOk and not(bJobOk) and not(bEquipOk)) Move clRed to iEndColor
                Else Move clLtGray to iEndColor
                Set Color of oEndButton to iEndColor
                // TimeCard Button
                Set Enabled_State of oTimeCardButton to (bEmplOk and not(bJobOk) and not(bEquipOk))
                If (bEmplOk and not(bJobOk) and not(bEquipOk)) Move clBlue to iTimeCardColor //Blue
                Else Move clLtGray to iTimeCardColor
                Set Color of oTimeCardButton to iTimeCardColor
                // Quickbuttons
                Set Enabled_State of oGenLab to (bEmplOk and bJobOk)
                Set Enabled_State of oStaging to (bEmplOk and bJobOk)
                Set Enabled_State of oPayrollLab to (bEmplOk and bJobOk)
                Set Enabled_State of oBreak to (bEmplOk and bJobOk)
    
                Case Begin
                    Case (iActiveEntry=1)
                        Set Label_TextColor of oEmployeeNumberForm to clBlack
                        Set Label_TextColor of oJobNumberForm to clLtGray
                        Set Label_TextColor of oEquipNumberForm to clLtGray
                        //
                        Set Value of oStatusForm to "Enter Employee ID"
                        Set Enabled_State of oNextButton to bEmplOk
                        If (bEmplOk) Move clOrange to iNextColor
                        Else Move clLtGray to iNextColor
                        Case Break
                    Case (iActiveEntry=2)
                        Set Label_TextColor of oEmployeeNumberForm to clLtGray
                        Set Label_TextColor of oJobNumberForm to clBlack
                        Set Label_TextColor of oEquipNumberForm to clLtGray
                        //
                        Set Value of oStatusForm to "Enter Job #"
                        //
                        Set Enabled_State of oNextButton to bJobOk
                        If (bJobOk) Move clOrange to iNextColor
                        Else Move clLtGray to iNextColor
                        Case Break
                    Case (iActiveEntry=3)
                        Set Label_TextColor of oEmployeeNumberForm to clLtGray
                        Set Label_TextColor of oJobNumberForm to clLtGray
                        Set Label_TextColor of oEquipNumberForm to clBlack
                        //
                        Set Value of oStatusForm to "Enter Equipment #"
    
                        Set Enabled_State of oNextButton to False
                        Move clLtGray to iNextColor
                        Case Break
                Case End
                Set Color of oNextButton to iNextColor
                
            End_Procedure
        End_Object

        Object oEmployeeNumberForm is a Form
            Set Size to 15 35
            Set Location to 59 11
            Set Label to "Empl #:"
            Set Label_Col_Offset to 0
            Set Label_Justification_Mode to JMode_Top
            Set Label_FontWeight to fw_Bold
            Set Label_FontPointHeight to 16
            Set Label_TextColor to clLtGray
            Set FontPointHeight to 14
            Set Form_Justification_Mode to Form_DisplayCenter
            Set pbCenterToolTip to True
            Set Entry_State to False
            Set peAnchors to anTopLeft

            Procedure Entering Returns Integer
                Integer iRetVal
                Forward Get msg_Entering to iRetVal
                Move 1 to iActiveEntry
                Send Refresh_Status of oStatusForm                
                Procedure_Return iRetVal
            End_Procedure
            
        End_Object
        
        Object oEmployeeNameForm is a Form
            Set Size to 15 151
            Set Location to 59 71
            Set FontPointHeight to 14
            Set Enabled_State to False
            Set Entry_State to False
            Set peAnchors to anTopLeftRight
        
            //OnChange is called on every changed character
        
            //Procedure OnChange
            //    String sValue
            //
            //    Get Value to sValue
            //End_Procedure
        
        End_Object

        Object oJobNumberForm is a Form
            Set Size to 15 35
            Set Location to 101 11
            Set Label to "Job #:"
            Set Label_Col_Offset to 0
            Set Label_Justification_Mode to JMode_Top
            Set Label_FontWeight to fw_Bold
            Set Label_FontPointHeight to 16
            Set Label_TextColor to clLtGray
            Set FontPointHeight to 14
            Set Form_Justification_Mode to Form_DisplayCenter
            Set pbCenterToolTip to True
            Set Entry_State to False
   

            Procedure Entering Returns Integer
                Integer iRetVal
                Forward Get msg_Entering to iRetVal
                Move 2 to iActiveEntry
                Send Refresh_Status of oStatusForm
                Procedure_Return iRetVal
            End_Procedure
            
        End_Object

        Object oJobNameForm is a Form
            Set Size to 15 150
            Set Location to 101 71
            Set FontPointHeight to 14
            Set Enabled_State to False
            Set Entry_State to False
            Set peAnchors to anTopLeftRight
        
            //OnChange is called on every changed character
        
            //Procedure OnChange
            //    String sValue
            //
            //    Get Value to sValue
            //End_Procedure
        
        End_Object
        Object oEquipNumberForm is a Form
            Set Size to 15 35
            Set Location to 143 11
            Set Label to "Equip #:"
            Set Label_Col_Offset to 0
            Set Label_Justification_Mode to JMode_Top
            Set Label_FontWeight to fw_Bold
            Set Label_FontPointHeight to 16
            Set Label_TextColor to clLtGray
            Set FontPointHeight to 14
            Set Form_Justification_Mode to Form_DisplayCenter
            Set pbCenterToolTip to True
            Set Entry_State to False

            Procedure Entering Returns Integer
                Integer iRetVal
                Forward Get msg_Entering to iRetVal
                Move 3 to iActiveEntry
                Send Refresh_Status of oStatusForm
                Procedure_Return iRetVal
            End_Procedure
            
        End_Object

        Object oEquipNameForm is a Form
            Set Size to 15 150
            Set Location to 143 71
            Set FontPointHeight to 14
            Set Enabled_State to False
            Set Entry_State to False
            Set peAnchors to anTopLeftRight
        
            //OnChange is called on every changed character
        
            //Procedure OnChange
            //    String sValue
            //
            //    Get Value to sValue
            //End_Procedure
        
        End_Object

        Object oLineControl1 is a LineControl
            Set Size to 5 291
            Set Location to 40 9
            Set peAnchors to anTopLeftRight
        End_Object
    End_Object
    
//    Object oExitButton is a Button
//        Set Size to 10 10
//        Set Location to 1 521
//        Set FlatState to False
//        Set peAnchors to anTopRight
//        Set Label to "X"
//        Set pbVisible to False
//    
//    End_Object   

    Object oBitmapContainer1 is a BitmapContainer
        Set Size to 39 46
        Set Location to 2 37
        Set Bitmap to "logo.bmp"
        Set Enabled_State to False
        Set Bitmap_Style to Bitmap_Stretch
        Set piMaxSize to 39 73
        Set piMinSize to 39 46

        Procedure Mouse_Click Integer iWindowNumber Integer iPosition
            Forward Send Mouse_Click iWindowNumber iPosition
            Set View_Mode of oTimeClock to Viewmode_Zoom
            Integer eResponse
            If (bEmplOk and iEmployeeIdno = 890) Begin
                Move (YesNo_Box("Are you sure you want to close the Time Clock?", "", MB_DEFBUTTON2)) to eResponse
                If (eResponse = MBR_YES) Begin
                    Send Exit_Application
                End                
            End
        End_Procedure
    End_Object
  
    Object oContainer3d1 is a Container3d
        Set Size to 256 157
        Set Location to 1 318
        Set Color to clWhite
        Set peAnchors to anTopBottomRight
        
        Object oButton1 is a Button
            Set Size to 40 47
            Set Location to 2 5
            Set Label to '1'
            Set FontWeight to fw_Bold
            Set peAnchors to anTopLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoIncrementCurrentDisplay 1
            End_Procedure
        
        End_Object
        
        Object oButton2 is a Button
            Set Size to 40 47
            Set Location to 2 53
            Set Label to '2'
            Set FontWeight to fw_Bold
            Set peAnchors to anTopLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoIncrementCurrentDisplay 2
            End_Procedure
        End_Object
        
        Object oButton3 is a Button
            Set Size to 40 47
            Set Location to 2 101
            Set Label to '3'
            Set FontWeight to fw_Bold
            Set peAnchors to anTopLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoIncrementCurrentDisplay 3
            End_Procedure
        End_Object
        
        Object oButton4 is a Button
            Set Size to 40 47
            Set Location to 43 5
            Set Label to '4'
            Set FontWeight to fw_Bold
            Set peAnchors to anTopLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoIncrementCurrentDisplay 4
            End_Procedure
        End_Object
        
        Object oButton5 is a Button
            Set Size to 40 47
            Set Location to 43 53
            Set Label to '5'
            Set FontWeight to fw_Bold
            Set peAnchors to anTopLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoIncrementCurrentDisplay 5
            End_Procedure
        End_Object
        
        Object oButton6 is a Button
            Set Size to 40 47
            Set Location to 43 101
            Set Label to '6'
            Set FontWeight to fw_Bold
            Set peAnchors to anTopLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoIncrementCurrentDisplay 6
            End_Procedure
        End_Object
        
        Object oButton7 is a Button
            Set Size to 40 47
            Set Location to 84 5
            Set Label to '7'
            Set FontWeight to fw_Bold
            Set peAnchors to anTopLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoIncrementCurrentDisplay 7
            End_Procedure
        End_Object
        
        Object oButton8 is a Button
            Set Size to 40 47
            Set Location to 84 53
            Set Label to '8'
            Set FontWeight to fw_Bold
            Set peAnchors to anTopLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoIncrementCurrentDisplay 8                
            End_Procedure
        
        End_Object
        
        Object oButton9 is a Button
            Set Size to 40 47
            Set Location to 84 101
            Set Label to '9'
            Set FontWeight to fw_Bold
            Set peAnchors to anTopLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoIncrementCurrentDisplay 9
            End_Procedure
        
        End_Object
        
        Object oButtonClearAll is a Button
            Set Size to 40 47
            Set Location to 125 5
            Set Label to 'ClearAll'
            Set FontWeight to fw_Bold
            Set peAnchors to anTopLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoClearDisplay
            End_Procedure
        
        End_Object
        
        Object oButton0 is a Button
            Set Size to 40 47
            Set Location to 125 53
            Set Label to '0'
            Set FontWeight to fw_Bold
            Set peAnchors to anTopLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoIncrementCurrentDisplay 0
            End_Procedure
        
        End_Object
        
        Object oButtonClear is a Button
            Set Size to 40 47
            Set Location to 125 101
            Set Label to 'Clear'
            Set FontWeight to fw_Bold
            Set peAnchors to anTopLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Send DoDecrementDisplay
            End_Procedure
        
        End_Object

        Object oTimeCardButton is a Button
            Set Size to 40 70
            Set Location to 166 5
            Set Label to "Time Card"
            Set Color to clLtGray
            Set psImage to "ActionPageLayout.ico"
            Set piImageSize to 45
            Set MultiLineState to True
            Set peImageAlign to Button_ImageList_Align_Top
            Set piImageMarginTop to 5
            Set piImageMarginLeft to 0
            Set FontWeight to fw_Bold
            //Set piTextColor to clWhite
            //Set pbDropDownButton to False
            //Set piTextHotColor to clBlack
            //Set MultiLineState to True
        
            // fires when the button is clicked
            Procedure OnClick
                //Send JumpStartReport of oTimeCard iEmployeeIdno
                Send Popup of oLoadingPopup 
                Send Activate_oTimeCard
                Send ReloadView of oTimeCard iEmployeeIdno
            End_Procedure
        
        End_Object

        Object oNextButton is a Button
            Set Size to 40 70
            Set Location to 166 78
            Set Color to clLtGray
            Set psImage to "ActionNextView.ico"
            Set piImageSize to 40
            Set peImageAlign to Button_ImageList_Align_Top
            Set Label to "Next"
            Set piImageMarginLeft to 0
            Set piImageMarginTop to 10
            Set FontWeight to fw_Bold
            Set peAnchors to anTopRight
            //Set piTextColor to clBlack
            //Set pbDropDownButton to False
            //Set piTextHotColor to clBlack
        
            // fires when the button is clicked
            Procedure OnClick
                Send Refresh_Status of oStatusForm
                Case Begin
                    Case (iActiveEntry=1)
                    Send Entering of oJobNumberForm
                    Case Break
                    Case (iActiveEntry=2)
                    Send Entering of oEquipNumberForm
                    Case Break
                    Case (iActiveEntry=3)
                    Case Break
                Case End
            End_Procedure
        
        End_Object
        
        Object oStartActiveButton is a Button
            Set Size to 40 70
            Set Location to 209 5
            Set Label to "Start"
            Set Color to clLtGray
            Set psImage to "timer_start.ico"
            Set peImageAlign to Button_ImageList_Align_Top
            Set piImageSize to 48
            Set piImageMarginLeft to 0
            Set piImageMarginTop to 5
            Set FontWeight to fw_Bold
            //Set piTextColor to clBlack
            //Set pbDropDownButton to False

            // fires when the button is clicked
            Procedure OnClick
                String sCallerId sErrorMsg
                Number nGPSLatOffice nGPSLongOffice
                Boolean bSuccess
                Move "6517650765" to sCallerId
                Move 45.252730 to nGPSLatOffice
                Move -92.986679 to nGPSLongOffice
                //Send StartTransaction iEmployeeIdno 1 iJobNumber iEquipNumber //OLD(Retired) way using ISC/SmartCreateTransaction.asp
                // NEW way - using the Tempus Field App
                Get wsCreateTimeTransaction of oWSSystemLinkAPI iEmployeeIdno iJobNumber iEquipNumber sCallerId nGPSLatOffice nGPSLongOffice 0 (&sErrorMsg) to bSuccess
                If (bSuccess) Begin
                    Send Info_Box sErrorMsg "Success"
                    Send DoClearDisplay
                End
                Else Begin
                    Send Stop_Box sErrorMsg "Error"
                End
            End_Procedure
        End_Object
    
        Object oEndButton is a Button
            Set Size to 40 70
            Set Location to 209 78
            Set Label to "End"
            Set Color to clLtGray
            Set psImage to "timer_end.ico"
            Set piImageSize to 48
            Set peImageAlign to Button_ImageList_Align_Top
            Set piImageMarginLeft to 0
            Set piImageMarginTop to 5
            Set FontWeight to fw_Bold
            Set peAnchors to anTopRight
            //Set piTextColor to clBlack
            //Set pbDropDownButton to False
            //Set piTextHotColor to clBlack

            // fires when the button is clicked
            Procedure OnClick
                Integer eResponse
                Get YesNo_Box "Do you want to end your Shift?" "End Shift" MB_DEFBUTTON1 to eResponse
                If (eResponse = MBR_Yes) Begin
                    String sCallerId sErrorMsg
                    Number nGPSLatOffice nGPSLongOffice
                    Boolean bSuccess
                    Move "6517650765" to sCallerId
                    Move 45.252730 to nGPSLatOffice
                    Move -92.986679 to nGPSLongOffice
                    //Send StartTransaction iEmployeeIdno 3 "" "" //OLD(Retired) was using
                    Get wsEndShiftTransaction of oWSSystemLinkAPI iEmployeeIdno sCallerId nGPSLatOffice nGPSLongOffice (&sErrorMsg) to bSuccess
                    If (bSuccess) Begin
                        Send Info_Box sErrorMsg "Success"
                        Send DoClearDisplay
                    End
                    Else Begin
                        Send Stop_Box sErrorMsg "Error"
                    End
                End
            End_Procedure
        
        End_Object
    
    End_Object

    Object oGroup2 is a Group
        Set Size to 35 306
        Set Location to 217 4
        Set Label to ''
        Set peAnchors to anAll
        
        Object oPayrollLab is a Button
            Set Size to 25 60
            Set Location to 7 4
            Set Label to 'Active (99)'
            Set FontPointHeight to 10
            Set FontWeight to fw_Bold
            Set peAnchors to anBottomLeft
        
            // fires when the button is clicked
            Procedure OnClick
//                Set Value of oJobNumberForm to "333"
//                Send UpdateJob
                Set Value of oEquipNumberForm to "99"
                Send UpdateEquipment
                Send Entering of oEquipNumberForm
            End_Procedure
        
        End_Object

        Object oStaging is a Button
            Set Size to 25 60
            Set Location to 7 146
            Set Label to 'Staging (98)'
            Set FontPointHeight to 10
            Set FontWeight to fw_Bold
            Set peAnchors to anBottomLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Set Value of oEquipNumberForm to "98"
                Send UpdateEquipment
                Send Entering of oEquipNumberForm
            End_Procedure
        
        End_Object

        Object oGenLab is a Button
            Set Size to 25 60
            Set Location to 7 216
            Set Label to 'Gen. Labor (1114)'
            Set FontPointHeight to 10
            Set FontWeight to fw_Bold
            Set peAnchors to anBottomLeft
        
            // fires when the button is clicked
            Procedure OnClick
                Set Value of oEquipNumberForm to "1114"
                Send UpdateEquipment
                Send Entering of oEquipNumberForm
            End_Procedure
        End_Object

        Object oBreak is a Button
            Set Size to 25 60
            Set Location to 7 75
            Set Label to 'Break (97)'
            Set FontPointHeight to 10
            Set FontWeight to fw_Bold
            Set peAnchors to anBottomLeft
        
            // fires when the button is clicked
            Procedure OnClick
//                Set Value of oJobNumberForm to "333"
//                Send UpdateJob
                Set Value of oEquipNumberForm to "97"
                Send UpdateEquipment
                Send Entering of oEquipNumberForm
            End_Procedure
        
        End_Object
    End_Object

    Object oTextBox1 is a TextBox
        Set Auto_Size_State to False
        Set Size to 10 84
        Set Location to 11 98
        Set Label to 'Tempus - Time Clock'
        Set FontPointHeight to 20
        Set Justification_Mode to JMode_Center
    End_Object

    Procedure OnBeginningOfPanel Integer hoPanel
        Forward Send OnBeginningOfPanel hoPanel
        //Set View_Mode to Viewmode_Zoom
        Send Entering of oEmployeeNumberForm
    End_Procedure

    Procedure Activating
        Forward Send Activating
        //Set View_Mode to ViewMode_Zoom
    End_Procedure
            
End_Object
