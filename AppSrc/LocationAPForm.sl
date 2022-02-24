// LocationAPForm.sl
// LocationAPForm Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use cLocationAPFormGlblDataDictionary.dd

CD_Popup_Object LocationAPForm_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 381
    Set Label To "LocationAPForm Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object 

    Object oAreas_DD is a Areas_DataDictionary
    End_Object 

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object 

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
        Set DDO_Server To oSalesTaxGroup_DD
    End_Object 

    Object oLocationAPForm_DD is a cLocationAPFormGlblDataDictionary
        Set DDO_Server To oLocation_DD
    End_Object 

    Set Main_DD To oLocationAPForm_DD
    Set Server  To oLocationAPForm_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 371
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "LocationAPForm_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oLocationAPForm_LocationAPIdno is a cDbCJGridColumn
            Entry_Item LocationAPForm.LocationAPIdno
            Set piWidth to 53
            Set psCaption to "ID"
        End_Object 

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 265
            Set psCaption to "Location"
        End_Object 

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 300
            Set psCaption to "Customer"
        End_Object 


    End_Object 

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 218
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object 

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 272
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object 

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 326
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object 

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // LocationAPForm_sl
