Use Windows.pkg
Use DFClient.pkg
Use dfTabDlg.pkg
Use cDbSplitterContainer.pkg

Deferred_View Activate_oOverview for ;
Object oOverview is a dbView

    Set Border_Style to Border_Thick
    Set Size to 600 900
    Set Location to 2 21

    Object oDbTabDialog1 is a dbTabDialog
        Set Size to 471 676
        Set Location to 47 192
            Set Rotate_Mode to RM_Rotate

        Object oDbTabPage3 is a dbTabPage
            Set Label to 'HOME'
        End_Object

        Object oDbTabPage2 is a dbTabPage
            Set Label to 'CONTACTS'
        End_Object

        Object oDbTabPage1 is a dbTabPage
            Set Label to 'ACCOUNTS'
        End_Object

        Object oDbTabPage4 is a dbTabPage
            Set Label to 'PROPOSALS'
        End_Object

        Object oDbTabPage5 is a dbTabPage
            Set Label to 'ORDERS'
        End_Object

        Object oDbTabPage6 is a dbTabPage
            Set Label to 'BILLING'
        End_Object
    End_Object

Cd_End_Object
