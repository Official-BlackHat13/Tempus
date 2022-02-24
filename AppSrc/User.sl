// User.sl
// User Lookup List

Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg
Use cGlblButton.pkg

Use User.DD

CD_Popup_Object User_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 368
    Set Label To "User Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oUser_DD Is A User_DataDictionary
    End_Object // oUser_DD

    Set Main_DD To oUser_DD
    Set Server  To oUser_DD



    Object oSelList Is A cGlblDbList
        Set Size to 105 358
        Set Location to 5 5
        Set peAnchors to anAll
        Set Main_File to User.File_Number
        Set Ordering to 3
        Set peResizeColumn to rcAll
        Set Auto_Server_State to True
        Set pbHeaderTogglesDirection to True

        Begin_Row
            Entry_Item User.LoginName
            Entry_Item User.Lastname
            Entry_Item User.Firstname
        End_row

        Set Form_Width 0 to 50
        Set Header_Label 0 to "Login"

        Set Form_Width 1 to 150
        Set Header_Label 1 to "Last name"

        Set Form_Width 2 to 150
        Set Header_Label 2 to "First name"

    End_Object // oSelList

    Object oOk_bn Is A cGlblButton
        Set Label to "&Ok"
        Set Location to 115 205
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 259
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A cGlblButton
        Set Label to "&Search..."
        Set Location to 115 313
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // User_sl
