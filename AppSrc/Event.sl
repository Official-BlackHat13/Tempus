// Event.sl
// Event Lookup List

Use DFClient.pkg
Use DFSelLst.pkg
Use Windows.pkg
Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg

Use Event.DD

Cd_Popup_Object Event_sl is a cGlblDbModalPanel
    Set Location to 5 5
    // Visual DataFlex 14.0 Client Size Adjuster, modified June 2, 2008: 10:49:04
//    Set Size to 159 200
    Set Size to 139 195
    Set Label To "Event Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oEvent_DD Is A Event_DataDictionary
    End_Object // oEvent_DD

    Set Main_DD To oEvent_DD
    Set Server  To oEvent_DD

    Object oSelList is a cGlblDbList
        Set Size to 105 185
        Set Location to 10 5
        Set peAnchors to anAll
        Set Main_File to Event.File_Number
        Set Ordering to 1
        Set peResizeColumn to rcAll
        Set Auto_Server_State to True
        Set pbHeaderTogglesDirection to True

        Begin_row
            Entry_Item Event.EventIdno
            Entry_Item Event.StartDate
            Entry_Item Event.StopDate
        End_row

        Set Form_Width 0 to 59
        Set Header_Label 0 to "Event Number"

        Set Form_Width 1 to 62
        Set Header_Label 1 to "Start Date"

        Set Form_Width 2 to 60
        Set Header_Label 2 to "Stop Date"

    End_Object // oSelList

    Object oOk_bn Is A Button
        Set Label to "&Ok"
        Set Location to 120 32
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A Button
        Set Label to "&Cancel"
        Set Location to 120 86
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A Button
        Set Label to "&Search..."
        Set Location to 120 140
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Event_sl

