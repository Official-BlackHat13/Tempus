// Quotehdr.sl
// Quote Lookup List

Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Contact.DD
Use cQuotehdrDataDictionary.dd
Use cSnowrepDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use Windows.pkg
Use cDbTextEdit.pkg
Use cGlblDbForm.pkg

Object Quotehdr_sl is a cGlblDbModalPanel

    Property Boolean pbPendingOnly True
    Property Boolean pbRecId
    Property Integer piRecId

    Set Location to 5 4
    Set Size to 175 635
    Set Label To "Quote Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False
    Set piMinSize to 175 635
    Set piMaxSize to 775 635

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oCustomer_DD Is A Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD Is A Areas_DataDictionary
    End_Object // oAreas_DD

    Object oLocation_DD Is A Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
    End_Object // oLocation_DD

    Object oSalesrep_DD Is A Salesrep_DataDictionary
    End_Object // oSalesrep_DD

    Object oContact_DD Is A Contact_DataDictionary
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server To oCustomer_DD
    End_Object // oContact_DD

    Object oQuotehdr_DD Is A cQuotehdrDataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oSalesrep_DD
        Set DDO_Server To oContact_DD
//        Set Ordering to 6

//Ben: I commented out the OnConstrain Procedure to show all quotes, including the ones with Job#
//        Procedure OnConstrain
//            If (pbPendingOnly(Self)) Begin
//                Constrain Quotehdr.JobNumber eq 0
//            End
//        End_Procedure

    End_Object // oQuotehdr_DD

    Set Main_DD To oQuotehdr_DD
    Set Server  To oQuotehdr_DD

    Object oSelList Is A cGlblDbList
        Set Size to 127 624
        Set Location to 5 6
        Set peAnchors to anAll
        Set Main_File to Quotehdr.File_Number
        Set peResizeColumn to rcAll
        Set pbHeaderTogglesDirection to True

        Begin_row
            Entry_Item Quotehdr.Quotehdrid
            Entry_Item Quotehdr.CustomerIdno
            Entry_Item Quotehdr.Organization
            Entry_Item Quotehdr.LocationName
            Entry_Item Quotehdr.JobNumber
            Entry_Item Quotehdr.QuoteDate
            Entry_Item Quotehdr.Amount
            Entry_Item Quotehdr.QuoteLostMemo
        End_row

        Set Form_Width 0 to 42
        Set Header_Label 0 to "Quote ID"

        Set Form_Width 2 to 136
        Set Header_Label 2 to "Customer"

        Set Form_Width 3 to 134
        Set Header_Label 3 to "Location"
        Set Form_Width 4 to 40
        Set Header_Label 4 to "Job No."
        Set Form_Width 1 to 38
        Set Header_Label 1 to "Cust ID"
        Set Form_Width 5 to 52
        Set Header_Label 5 to "Quote Date"
        Set Form_Width 6 to 50
        Set Header_Label 6 to "Amount"
        Set Header_Justification_Mode 6 to JMode_Right
        Set Form_Width 7 to 122
        Set Header_Label 7 to "Memo"
        
      

        Procedure Ok
            If (pbRecId(Self)) Begin
                Set piRecId to Quotehdr.Recnum
                Send Close_Panel
            End
            Else Begin
                Forward Send Ok
            End
        End_Procedure
    End_Object // oSelList

//Ben: I have commented this out to hide the CheckBox "Not Converted to Orders Only"
//    Object oPendingCheckBox is a CheckBox
//        Set Size to 10 50
//        Set Location to 158 15
//        Set Label to "Not Converted to Orders Only"
//        Set peAnchors to anBottomLeft
//    
//        Procedure OnChange
//            Boolean bChecked
//            Integer hoDD iIndex
//            //
//            Get Server        to hoDD
//            Get Checked_State to bChecked
////            If (bChecked) Begin
////                Move 6 to iIndex
////            End
////            Else Begin
////                Move 1 to iIndex
////            End
//            Set pbPendingOnly                to bChecked
////            Set Ordering             of hoDD to iIndex
//            Send Rebuild_Constraints of hoDD
//            Send Beginning_of_Data   of oSelList
//            Send Refresh_Page        of oSelList FILL_FROM_TOP
//            Send Activate            of oSelList
//        End_Procedure
//    End_Object

    Object oOk_bn Is A cGlblButton
        Set Label to "&Ok"
        Set Location to 156 462
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure
    End_Object // oOk_bn

    Object oCancel_bn Is A cGlblButton
        Set Label to "&Cancel"
        Set Location to 156 516
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure
    End_Object // oCancel_bn

    Object oSearch_bn Is A cGlblButton
        Set Label to "&Search..."
        Set Location to 156 570
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    Object oQuotehdr_QuoteLostMemo is a cGlblDbForm
        Entry_Item Quotehdr.QuoteLostMemo
        Set Location to 136 83
        Set Size to 13 359
        Set Label to "Memo:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set peAnchors to anBottomLeft
        Set Enabled_State to False
    End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

    Function IsSelectedQuote Integer iRecId Returns Integer
        Set pbRecId                          to True
        Set piRecId                          to 0
        Set Move_Value_Out_State of oSelList to False
        Send Popup_Modal
        Set Move_Value_Out_State of oSelList to True
        Set pbRecId                          to False
        Function_Return (piRecId(Self))
    End_Function

End_Object
