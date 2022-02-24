// Location2.sl
// Location Lookup List-2

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD

CD_Popup_Object Location2_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 221
    Set Label To "Location Lookup List-2"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD is a Areas_DataDictionary
    End_Object // oAreas_DD

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
    End_Object // oLocation_DD

    Set Main_DD To oLocation_DD
    Set Server  To oLocation_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 211
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Location2_sl_oSelList"
        Set Ordering to 2
        Set pbAutoServer to True

        Object oLocation_LocationIdno is a cDbCJGridColumn
            Entry_Item Location.LocationIdno
            Set piWidth to 76
            Set psCaption to "LocationIdno"
        End_Object // oLocation_LocationIdno

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 225
            Set psCaption to "Name"
        End_Object // oLocation_Name


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 58
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 112
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 166
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Location2_sl
