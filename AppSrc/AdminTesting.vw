Use Windows.pkg
Use DFClient.pkg

Deferred_View Activate_oAdminTesting for ;
Object oAdminTesting is a dbView

    Set Border_Style to Border_Thick
    Set Size to 200 300
    Set Location to 2 2

    Object oButton1 is a Button
        Set Location to 22 32
        Set Label to 'Check for UnpaidInvoices'
    
        // fires when the button is clicked
        Procedure OnClick
            Send RunInvoicePaidStatusTool of oInvoicePostingProcess
        End_Procedure
    
    End_Object

Cd_End_Object
