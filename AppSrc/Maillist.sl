// Maillist.sl
// Mailing List Lookup List

Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg
Use cGlblButton.pkg

Use cMaillistDataDictionary.dd

CD_Popup_Object Maillist_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 260
    Set Label To "Mailing List Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oMaillist_DD Is A cMaillistDataDictionary
    End_Object // oMaillist_DD

    Set Main_DD To oMaillist_DD
    Set Server  To oMaillist_DD



    Object oSelList Is A cGlblDbList
        Set Size to 105 250
        Set Location to 5 5
        Set peAnchors to anAll
        Set Main_File to Maillist.File_Number
        Set Ordering to 1
        Set peResizeColumn to rcAll
        Set Auto_Server_State to True
        Set pbHeaderTogglesDirection to True

        Begin_row
            Entry_Item Maillist.Listcode
            Entry_Item Maillist.Description
        End_row

        Set Form_Width 0 to 90
        Set Header_Label 0 to "Listcode"

        Set Form_Width 1 to 150
        Set Header_Label 1 to "Description"

    End_Object // oSelList

    Object oOk_bn Is A cGlblButton
        Set Label to "&Ok"
        Set Location to 115 97
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 151
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A cGlblButton
        Set Label to "&Search..."
        Set Location to 115 205
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Maillist_sl
