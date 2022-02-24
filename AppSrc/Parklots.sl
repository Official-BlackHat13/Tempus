// Parklots.sl
// Parking Lots Lookup List

Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use cParklotsDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd

CD_Popup_Object Parklots_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 266
    Set Label To "Parking Lots Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
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

    Object oParklots_DD Is A cParklotsDataDictionary
        Set DDO_Server To oLocation_DD
    End_Object // oParklots_DD

    Set Main_DD To oParklots_DD
    Set Server  To oParklots_DD



    Object oSelList Is A cGlblDbList
        Set Size to 105 256
        Set Location to 5 5
        Set peAnchors to anAll
        Set Main_File to Parklots.File_Number
        Set Ordering to 1
        Set peResizeColumn to rcAll
        Set Auto_Server_State to True
        Set pbHeaderTogglesDirection to True

        Begin_row
            Entry_Item Parklots.Parkinglotid
            Entry_Item Parklots.Description
            Entry_Item Parklots.Sqfttotal
        End_row

        Set Form_Width 0 to 48
        Set Header_Label 0 to "ID"

        Set Form_Width 1 to 150
        Set Header_Label 1 to "Description"

        Set Form_Width 2 to 48
        Set Header_Label 2 to "Total Sq Ft"

    End_Object // oSelList

    Object oOk_bn Is A cGlblButton
        Set Label to "&Ok"
        Set Location to 115 103
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 157
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A cGlblButton
        Set Label to "&Search..."
        Set Location to 115 211
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Parklots_sl
