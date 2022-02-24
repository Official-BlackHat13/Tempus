// Propmgr.sl
// Propmgr Lookup List

Use DFClient.pkg
Use DFSelLst.pkg
Use Windows.pkg
Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg

Use Customer.DD
Use cPropmgrDataDictionary.dd
Use SalesRep.DD
Use cSnowrepDataDictionary.dd
Use Contact.DD

Object Propmgr_sl is a cGlblDbModalPanel

    Property Boolean pbRecId
    Property Integer piRecId

    Set Location to 14 70
    Set Size to 139 378
    Set Label to "Property Manager Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oSalesrep_DD is a Salesrep_DataDictionary
    End_Object

    Object oCustomer_DD Is A Customer_DataDictionary
    End_Object // oCustomer_DD
    
    Object oContact_DD is a Contact_DataDictionary
    End_Object

    Object oPropmgr_DD is a cPropmgrDataDictionary
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesrep_DD
        Set DDO_Server to oCustomer_DD
        Set DDO_Server to oContact_DD

        Procedure OnConstrain
            Constrain Propmgr.Status eq "A"
        End_Procedure
    End_Object // oPropmgr_DD

    Set Main_DD To oPropmgr_DD
    Set Server  to oPropmgr_DD

    Object oSelList is a cGlblDbList
        Set Size to 105 368
        Set Location to 10 5
        Set peAnchors to anAll
        Set Main_File to Propmgr.File_Number
        Set Ordering to 1
        Set peResizeColumn to rcAll
        Set pbHeaderTogglesDirection to True

        Begin_row
            Entry_Item Propmgr.ContactIdno
            Entry_Item Propmgr.LastName
            Entry_Item Propmgr.FirstName
            Entry_Item Customer.Name
        End_row

        Set Form_Width 0 to 39
        Set Header_Label 0 to "Contact#"

        Set Form_Width 1 to 70
        Set Header_Label 1 to "Last Name"

        Set Form_Width 3 to 180
        Set Header_Label 3 to "Organization"
        Set Form_Width 2 to 70
        Set Header_Label 2 to "First Name"

        Procedure Ok
            If (pbRecId(Self)) Begin
                Set piRecId to Propmgr.Recnum
                Send Close_Panel
            End
            Else Begin
                Forward Send Ok
            End
        End_Procedure

    End_Object // oSelList

    Object oOk_bn Is A Button
        Set Label to "&Ok"
        Set Location to 120 215
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A Button
        Set Label to "&Cancel"
        Set Location to 120 269
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A Button
        Set Label to "&Search..."
        Set Location to 120 323
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    Object oCreateContact is a Button
        Set Size to 14 68
        Set Location to 120 24
        Set Label to 'Create Contact'
    
          Procedure OnClick 
             Send DoCreateContact
          End_Procedure
     End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

    Function IsSelectedPropertyManager Integer iRecId Returns Integer
        Integer hoDD
        //
        Set pbRecId to True
        Set piRecId to 0
        Get Server  to hoDD
        Send Clear_All      of hoDD
        Send Find_By_Recnum of hoDD Customer.File_Number iRecId
        Send Popup_Modal
        Set pbRecId to False
        Function_Return (piRecId(Self))
    End_Function

End_Object

