Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use cSnowrepDataDictionary.dd
Use Contact.DD
Use cQuotehdrDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use dfcentry.pkg

Deferred_View Activate_oQuoteUpdate for ;
Object oQuoteUpdate is a dbView
    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oContact_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Set Main_DD to oQuotehdr_DD
    Set Server to oQuotehdr_DD

    Set Border_Style to Border_Thick
    Set Label to "Quote Status Update"
    Set Size to 114 300
    Set Location to 19 286

    Object oQuotehdr_QuoteDate is a cGlblDbForm
        Entry_Item Quotehdr.QuoteDate
        Set Location to 7 96
        Set Size to 13 66
        Set Label to "Set Quote status before : "
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 5
    End_Object

    Object oButton1 is a Button
        Set Location to 5 245
        Set Label to 'Go'
    
        // fires when the button is clicked
        Procedure OnClick
            Boolean bCancel bOk
            Date dQuoteDate
            Integer iCount
            //String sStatus
            //
            Get Field_Current_Value of oQuoteHdr_DD Field QuoteHdr.QuoteDate to dQuoteDate
            //
            Clear Quotehdr
            Move dQuoteDate to Quotehdr.QuoteDate
            Find lt Quotehdr.QuoteDate
           
            While ((Found) and Quotehdr.QuoteDate < dQuoteDate)
                If (Quotehdr.Status = "P" and Quotehdr.JobNumber = 0) Begin
                    Increment iCount
                End
              
                Find lt Quotehdr.QuoteDate
            Loop
            
            If (iCount <> "0")Begin
            Get Confirm ("There are " + String(iCount) + " records before " +String(dQuoteDate) +". \n \n Flag them Lost?") to bCancel
            If bCancel Procedure_Return                
            End
            Else Begin
                Send Info_Box ("There are no Records before "+String(dQuoteDate)+" to be changed!")
            End

            Clear Quotehdr
            Move dQuoteDate to Quotehdr.QuoteDate
            Find lt Quotehdr.QuoteDate
            
            While ((Found) and Quotehdr.QuoteDate < dQuoteDate)
                If (Quotehdr.Status = "P" and Quotehdr.JobNumber = 0) Begin
                    Reread QuoteHdr
                    Move "L" to QuoteHdr.Status
                    SaveRecord Quotehdr
                    Unlock 
                End

                Find lt Quotehdr.QuoteDate
            Loop
            Send Info_Box (String(iCount) + " records have been flaged Lost!")
        End_Procedure      
    End_Object

    Object oQuotehdr_Status is a cGlblDbForm
        Entry_Item Quotehdr.Status
        Set Location to 9 182
        Set Size to 13 15
        Set Label to "Status:"
    End_Object

    Object oDbComboForm1 is a dbComboForm
        Entry_Item Quotehdr.Status
        Set Size to 13 100
        Set Location to 33 175
        Set Label to " to "
    End_Object

    

Cd_End_Object

