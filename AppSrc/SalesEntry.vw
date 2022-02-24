Use Windows.pkg
Use DFClient.pkg
Use dfTabDlg.pkg
Use SalesRep.DD
Use DFEntry.pkg
Use Salesrep.DD
Use cGlblDbComboForm.pkg
Use cGlblDbForm.pkg
Use cTempusDbView.pkg
Use cDbTextEdit.pkg
Use dfEnChk.pkg
Use dfcentry.pkg

Activate_View Activate_oSalesEntry for oSalesEntry
Object oSalesEntry is a cTempusDbView

    Object oSalesrep_DD is a Salesrep_DataDictionary
        Set Field_Auto_Increment Field Salesrep.Repidno to File_Field System.Lastsalesrep
    End_Object

    Set Main_DD to oSalesrep_DD
    Set Server to oSalesrep_DD

    Set Border_Style to Border_Thick
    Set Size to 236 337
    Set Location to 9 38
    Set Label to "Sales Representative Entry/Edit"

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 47 320
        Set Location to 10 10

        Object oSalesRep_RepIdno is a dbForm
            Entry_Item SalesRep.RepIdno
            Set Location to 8 46
            Set Size to 13 42
            Set Label to "ID#:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oSalesRep_LastName is a dbForm
            Entry_Item SalesRep.LastName
            Set Location to 23 46
            Set Size to 13 106
            Set Label to "Last Name:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object

        Object oSalesRep_FirstName is a dbForm
            Entry_Item SalesRep.FirstName
            Set Location to 22 198
            Set Size to 13 107
            Set Label to "First Name:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object
    End_Object

    Object oDbTabDialog1 is a dbTabDialog
        Set Size to 162 320
        Set Location to 65 10
    
        Set Rotate_Mode to RM_Rotate

        Object oDbTabPage1 is a dbTabPage
            Set Label to "Address/Phones"

            Object oSalesRep_Address1 is a dbForm
                Entry_Item SalesRep.Address1
                Set Location to 10 66
                Set Size to 13 216
                Set Label to "Address:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oSalesRep_Address2 is a dbForm
                Entry_Item SalesRep.Address2
                Set Location to 25 66
                Set Size to 13 216
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oSalesRep_City is a dbForm
                Entry_Item SalesRep.City
                Set Location to 40 66
                Set Size to 13 186
                Set Label to "City:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oSalesRep_State is a dbForm
                Entry_Item SalesRep.State
                Set Location to 55 66
                Set Size to 13 24
                Set Label to "State/Zip:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oSalesRep_Zip is a dbForm
                Entry_Item SalesRep.Zip
                Set Location to 55 94
                Set Size to 13 66
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oSalesRep_Phone1 is a dbForm
                Entry_Item SalesRep.Phone1
                Set Location to 70 66
                Set Size to 13 60
                Set Label to "Phones:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oSalesRep_PhoneType1 is a cGlblDbComboForm
                Entry_Item SalesRep.PhoneType1
                Set Location to 70 160
                Set Size to 13 52
                Set Label to "Types:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oSalesRep_Phone2 is a dbForm
                Entry_Item SalesRep.Phone2
                Set Location to 85 66
                Set Size to 13 60
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oSalesRep_PhoneType2 is a cGlblDbComboForm
                Entry_Item SalesRep.PhoneType2
                Set Location to 85 160
                Set Size to 13 52
            End_Object

            Object oSalesRep_Phone3 is a cGlblDbForm
                Entry_Item SalesRep.Phone3
                Set Location to 100 66
                Set Size to 13 60
            End_Object

            Object oSalesRep_PhoneType3 is a cGlblDbComboForm
                Entry_Item SalesRep.PhoneType3
                Set Location to 100 160
                Set Size to 13 52
            End_Object

            Object oSalesRep_EmailAddress is a dbForm
                Entry_Item SalesRep.EmailAddress
                Set Location to 115 66
                Set Size to 13 186
                Set Label to "Email:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

            Object oDbStatusComboForm is a cGlblDbComboForm
                Entry_Item SalesRep.Status
                Set Size to 13 60
                Set Location to 131 66
                Set Label to "Status:"
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object
        End_Object
        
         Object oDbTabPage2 is a dbTabPage
            Set Label to "QuickBooks Info"
            
            Object oDbForm1 is a dbForm
                Entry_Item SalesRep.Initials
                Set Label to "Initials:"
                Set Size to 13 45
                Set Location to 14 51
                Set Label_Justification_Mode to JMode_Right
                Set Label_Col_Offset to 3
            End_Object

             Object oSalesRep_InvMessage1 is a cDbTextEdit
                 Entry_Item SalesRep.InvMessage
                 Set Location to 41 51
                 Set Size to 60 249
                 Set Label to "InvMessage:"
                 Set Label_Justification_Mode to JMode_Right
                 Set Label_Col_Offset to 3
             End_Object

             Object oSalesComissionFlag is a dbCheckbox
                Entry_Item SalesRep.ComissionFlag
                 Set Size to 10 50
                 Set Location to 15 118
                 Set Label to 'Sales Comission'
             End_Object
            
         End_Object
    
    End_Object

End_Object

