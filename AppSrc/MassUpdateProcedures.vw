Use Windows.pkg
Use DFClient.pkg

Use OrderProcess.bp

Deferred_View Activate_oMassUpdateProcedures for ;
Object oMassUpdateProcedures is a dbView

    Set Border_Style to Border_Thick
    Set Size to 200 300
    Set Location to 2 2

    Object oInvoiceAmountGroup is a Group
        Set Size to 42 274
        Set Location to 12 15
        Set Label to 'Order.InvoiceAmount mass update'

        Object oGoButton is a Button
            Set Location to 14 215
            Set Label to 'Go'
        
            // fires when the button is clicked
            Procedure OnClick
                Integer iJobNumber
                Number nInvoiceAmount

                Get Value of oStartJobNumber  to iJobNumber
                Open Order
                Clear Order  
                Move iJobNumber to Order.JobNumber
                Find EQ Order by 1
                While (Found)
                    Get UpdateInvoiceAmountOnOrders of oOrderProcess iJobNumber to nInvoiceAmount
                    Send Info_Box ("Job#: " * String(Order.JobNumber) * " --- InvoiceAmount: " * String(nInvoiceAmount))
//                    Lock
//                        Move nInvoiceAmount to Order.InvoiceAmt
//                        Move 1 to Order.ChangedFlag
//                        SaveRecord Order
//                    Unlock 
                End
            End_Procedure
        
        End_Object

        Object oStartJobNumber is a Form
            Set Size to 13 47
            Set Location to 16 34
            Set Label to "Start"
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
        
            //OnChange is called on every changed character
        
            //Procedure OnChange
            //    String sValue
            //
            //    Get Value to sValue
            //End_Procedure
        
        End_Object

        Object oStartJobNumber is a Form
            Set Size to 13 47
            Set Location to 16 131
            Set Label to "Start"
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
        
            //OnChange is called on every changed character
        
            //Procedure OnChange
            //    String sValue
            //
            //    Get Value to sValue
            //End_Procedure
        
        End_Object
    End_Object

Cd_End_Object
