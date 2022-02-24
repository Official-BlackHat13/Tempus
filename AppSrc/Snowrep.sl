// Snowrep.sl
// Snowrep Lookup List

Use DFClient.pkg
Use DFSelLst.pkg
Use Windows.pkg
Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg

Use cSnowrepDataDictionary.dd

Cd_Popup_Object Snowrep_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 139 217
    Set Label To "Salesrep Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object // oSnowrep_DD

    Set Main_DD To oSnowrep_DD
    Set Server  to oSnowrep_DD

    Object oSelList is a cGlblDbList
        Set Size to 105 207
        Set Location to 10 5
        Set peAnchors to anAll
        Set Main_File to Snowrep.File_Number
        Set Ordering to 1
        Set peResizeColumn to rcAll
        Set Auto_Server_State to True
        Set pbHeaderTogglesDirection to True

        Begin_row
            Entry_Item Snowrep.RepIdno
            Entry_Item Snowrep.LastName
        End_row

        Set Form_Width 0 to 51
        Set Header_Label 0 to "Sales Rep#"

        Set Form_Width 1 to 150
        Set Header_Label 1 to "Last Name"

    End_Object // oSelList

    Object oOk_bn Is A Button
        Set Label to "&Ok"
        Set Location to 120 54
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A Button
        Set Label to "&Cancel"
        Set Location to 120 108
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A Button
        Set Label to "&Search..."
        Set Location to 120 162
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


Cd_End_Object // Snowrep_sl

