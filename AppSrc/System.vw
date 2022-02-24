Use Windows.pkg
Use DFClient.pkg
Use System.DD
Use cWorkTypeGlblDataDictionary.dd
Use Employer.DD
Use Employee.DD
Use dfTabDlg.pkg
Use cGlblDbForm.pkg
Use cTempusDbView.pkg
Use dfcentry.pkg
Use cDbCJGrid.pkg
Use cCJGrid.pkg
Use cdbCJGridColumn.pkg

Deferred_View Activate_oSystem for ;
Object oSystem is a cTempusDbView

    Object oSystem_DD is a System_DataDictionary
    End_Object

    Set Main_DD to oSystem_DD
    Set Server to oSystem_DD

    Set Border_Style to Border_Thick
    Set Size to 292 435
    Set Location to 3 10
    Set Label to "System Configuration"

    Object oSystemTabDialog is a dbTabDialog
        Set Size to 263 425
        Set Location to 5 5
    
        Set Rotate_Mode to RM_Rotate

        Object oCompanyTabPage is a dbTabPage
            Set Label to "Company Information"

            Object oSystem_CompanyName is a cGlblDbForm
                Entry_Item System.CompanyName
                Set Location to 10 66
                Set Size to 13 306
                Set Label to "Company Name"
            End_Object

            Object oSystem_Address1 is a cGlblDbForm
                Entry_Item System.Address1
                Set Location to 25 66
                Set Size to 13 306
                Set Label to "Address"
            End_Object

            Object oSystem_Address2 is a cGlblDbForm
                Entry_Item System.Address2
                Set Location to 40 66
                Set Size to 13 306
            End_Object

            Object oSystem_City is a cGlblDbForm
                Entry_Item System.City
                Set Location to 55 66
                Set Size to 13 216
                Set Label to "City"
            End_Object

            Object oSystem_State is a cGlblDbForm
                Entry_Item System.State
                Set Location to 70 66
                Set Size to 13 24
                Set Label to "State"
            End_Object

            Object oSystem_Zip is a cGlblDbForm
                Entry_Item System.Zip
                Set Location to 85 66
                Set Size to 13 66
                Set Label to "Zip"
            End_Object

            Object oSystem_CustomerInvoice is a cGlblDbForm
                Entry_Item System.CustomerInvoice
                Set Location to 100 66
                Set Size to 13 246
                Set Label to "Customer Invoice"
            End_Object
        End_Object

        Object oDatabaseTabPage is a dbTabPage
            Set Label to "Data Table ID's"
            Set Enabled_State of oDatabaseTabPage to 0

            Object oSystem_LastJob is a cGlblDbForm
                Entry_Item System.LastJob
                Set Location to 10 66
                Set Size to 13 54
                Set Label to "Last Job:"
            End_Object

            Object oSystem_LastEvent is a cGlblDbForm
                Entry_Item System.LastEvent
                Set Location to 25 66
                Set Size to 13 54
                Set Label to "Last Event:"
            End_Object

            Object oSystem_LastEstimate is a cGlblDbForm
                Entry_Item System.LastEstimate
                Set Location to 40 66
                Set Size to 13 54
                Set Label to "Last Estimate:"
            End_Object

            Object oSystem_LastEmployer is a cGlblDbForm
                Entry_Item System.LastEmployer
                Set Location to 55 66
                Set Size to 13 54
                Set Label to "Last Employer:"
            End_Object

            Object oSystem_LastEmployee is a cGlblDbForm
                Entry_Item System.LastEmployee
                Set Location to 70 66
                Set Size to 13 54
                Set Label to "Last Employee:"
            End_Object

            Object oSystem_LastCustomer is a cGlblDbForm
                Entry_Item System.LastCustomer
                Set Location to 85 66
                Set Size to 13 54
                Set Label to "Last Customer:"
            End_Object

            Object oSystem_LastLocation is a cGlblDbForm
                Entry_Item System.LastLocation
                Set Location to 100 66
                Set Size to 13 54
                Set Label to "Last Location:"
            End_Object

            Object oSystem_LastOpers is a cGlblDbForm
                Entry_Item System.LastOpers
                Set Location to 115 66
                Set Size to 13 54
                Set Label to "Last Operation:"
            End_Object

            Object oSystem_LastContact is a cGlblDbForm
                Entry_Item System.LastContact
                Set Location to 130 66
                Set Size to 13 54
                Set Label to "Last Contact:"
            End_Object

            Object oSystem_LastTrans is a cGlblDbForm
                Entry_Item System.LastTrans
                Set Location to 10 250
                Set Size to 13 54
                Set Label to "Last Trans:"
            End_Object

            Object oSystem_LastMastOps is a cGlblDbForm
                Entry_Item System.LastMastOps
                Set Location to 25 250
                Set Size to 13 54
                Set Label to "Last Master Ops:"
            End_Object

            Object oSystem_LastEstimateDtl is a cGlblDbForm
                Entry_Item System.LastEstimateDtl
                Set Location to 40 250
                Set Size to 13 54
                Set Label to "Last Est Detail:"
            End_Object

            Object oSystem_LastSalesRep is a cGlblDbForm
                Entry_Item System.LastSalesRep
                Set Location to 55 250
                Set Size to 13 54
                Set Label to "Last Sales Rep:"
            End_Object

            Object oSystem_LastInvoiceHdr is a cGlblDbForm
                Entry_Item System.LastInvoiceHdr
                Set Location to 70 250
                Set Size to 13 54
                Set Label to "Last Invoice Hdr:"
            End_Object

            Object oSystem_LastInvoiceDtl is a cGlblDbForm
                Entry_Item System.LastInvoiceDtl
                Set Location to 85 250
                Set Size to 13 54
                Set Label to "Last Invoice Dtl:"
            End_Object

            Object oSystem_LastEquipmnt is a cGlblDbForm
                Entry_Item System.LastEquipmnt
                Set Location to 100 250
                Set Size to 13 54
                Set Label to "Last Equipment:"
            End_Object

            Object oSystem_LastWeather is a cGlblDbForm
                Entry_Item System.LastWeather
                Set Location to 115 250
                Set Size to 13 54
                Set Label to "Last Weather:"
            End_Object

            Object oSystem_LastWeblog is a cGlblDbForm
                Entry_Item System.LastWeblog
                Set Location to 130 250
                Set Size to 13 54
                Set Label to "Last Weblog:"
            End_Object

            Object oSystem_Labor_Rate is a cGlblDbForm
                Entry_Item System.Labor_Rate
                Set Location to 146 66
                Set Size to 13 54
                Set Label to "Labor Rate:"
            End_Object

//            Object oSystem_ProjectId is a cGlblDbForm
//                Entry_Item System.ProjectId
//                Set Location to 146 250
//                Set Size to 13 54
//                Set Label to "Division #:"
//            End_Object

//            Object oSystem_SnowShtID is a cGlblDbForm
//                Entry_Item System.SnowShtID
//                Set Location to 147 66
//                Set Size to 13 54
//                Set Label to "SnowShtID:"
//            End_Object
//
//            Object oSystem_SnowShtHdr is a cGlblDbForm
//                Entry_Item System.SnowShtHdr
//                Set Location to 162 66
//                Set Size to 13 54
//                Set Label to "SnowShtHdr:"
//            End_Object
//
//            Object oSystem_SnowShtDtl is a cGlblDbForm
//                Entry_Item System.SnowShtDtl
//                Set Location to 177 66
//                Set Size to 13 54
//                Set Label to "SnowShtDtl:"
//            End_Object
        End_Object
    
    End_Object

    Object oButton1 is a Button
        Set Location to 273 5
        Set Label to 'Unlock to Edit'
        Boolean bUnlocked
        Integer iUnlocked
        // fires when the button is clicked
        Procedure OnClick
            Get Enabled_State of oDatabaseTabPage to bUnlocked
                
            If (bUnlocked = 0)Begin
                Set Enabled_State of oDatabaseTabPage to (not(bUnlocked))
            End
        End_Procedure
    
    End_Object

Cd_End_Object
