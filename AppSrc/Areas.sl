// Areas.sl
// Areas Lookup List

Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg
Use cGlblButton.pkg

Use Areas.DD

CD_Popup_Object Areas_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 269
    Set Label To "Areas Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oAreas_DD Is A Areas_DataDictionary
    End_Object // oAreas_DD

    Set Main_DD To oAreas_DD
    Set Server  To oAreas_DD



    Object oSelList Is A cGlblDbList
        Set Size to 105 259
        Set Location to 5 5
        Set peAnchors to anAll
        Set Main_File to Areas.File_Number
        Set Ordering to 1
        Set peResizeColumn to rcAll
        Set Auto_Server_State to True
        Set pbHeaderTogglesDirection to True

        Begin_row
            Entry_Item Areas.Areanumber
            Entry_Item Areas.Name
            Entry_Item Areas.Manager
        End_row

        Set Form_Width 0 to 48
        Set Header_Label 0 to "Area"

        Set Form_Width 1 to 119
        Set Header_Label 1 to "Name"
        
        Set Form_Width 2 to 90
        Set Header_Label 1 to "Area Manager"

    End_Object // oSelList

    Object oOk_bn Is A cGlblButton
        Set Label to "&Ok"
        Set Location to 115 106
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 160
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A cGlblButton
        Set Label to "&Search..."
        Set Location to 115 214
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Areas_sl
