// Contact2.sl
// Contact Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use SalesRep.DD
Use cSnowrepDataDictionary.dd
Use Contact.DD

CD_Popup_Object Contact2_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 370
    Set Label To "Contact Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object // oSalesRep_DD

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object // oSnowrep_DD

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oSalesRep_DD
        Set DDO_Server To oSnowrep_DD
    End_Object // oContact_DD

    Set Main_DD To oContact_DD
    Set Server  To oContact_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 360
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Contact2_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oContact_ContactIdno is a cDbCJGridColumn
            Entry_Item Contact.ContactIdno
            Set piWidth to 75
            Set psCaption to "ContactIdno"
        End_Object // oContact_ContactIdno

        Object oContact_FirstName is a cDbCJGridColumn
            Entry_Item Contact.FirstName
            Set piWidth to 225
            Set psCaption to "FirstName"
        End_Object // oContact_FirstName

        Object oContact_LastName is a cDbCJGridColumn
            Entry_Item Contact.LastName
            Set piWidth to 225
            Set psCaption to "LastName"
        End_Object // oContact_LastName


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 207
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 261
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 315
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Contact2_sl
