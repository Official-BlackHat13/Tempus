// Crystal.sl
// Crystal Report Lookup List

Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg
Use cGlblButton.pkg

Use Crystal.DD

CD_Popup_Object Crystal_sl is a cGlblDbModalPanel
    Set Location to 11 17
    Set Size to 134 281
    Set Label To "Crystal Report Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oCrystal_DD Is A Crystal_DataDictionary
    End_Object // oCrystal_DD

    Set Main_DD To oCrystal_DD
    Set Server  To oCrystal_DD



    Object oSelList Is A cGlblDbList
        Set Size to 105 271
        Set Location to 5 5
        Set peAnchors to anAll
        Set Main_File to Crystal.File_Number
        Set Ordering to 1
        Set peResizeColumn to rcAll
        Set Auto_Server_State to True
        Set pbHeaderTogglesDirection to True

        Begin_row
            Entry_Item Crystal.Description
        End_row

        Set Form_Width 0 to 259
        Set Header_Label 0 to "Description"

    End_Object // oSelList

    Object oOk_bn Is A cGlblButton
        Set Label to "&Ok"
        Set Location to 115 112
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 166
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A cGlblButton
        Set Label to "&Search..."
        Set Location to 115 220
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Crystal_sl
