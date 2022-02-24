Use Windows.pkg
Use DFClient.pkg
Use DFTabDlg.pkg

Activate_View Activate_oPMTransEdit for oPMTransEdit
Object oPMTransEdit is a dbView
    Set Label to "New View"
    Set Size to 300 600
    Set Location to 5 7

    Object oNewTabDialog is a dbTabDialogView
        Set Size to 290 590
        Set Location to 5 5
        Set Rotate_Mode to RM_Rotate

        Object oNewTabPage1 is a dbTabView
            Set Label to "Labor Transactions"

       Object oNewTabPage2 is a dbTabView
        Set Size to 290 590
        Set Location to 5 5
        Set Rotate_Mode to RM_Rotate
        Set Label to "OutSide & Materal Cost"
        End_Object

    End_Object

    End_Object
End_Object

