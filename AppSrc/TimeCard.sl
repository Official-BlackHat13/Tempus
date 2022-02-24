Use Windows.pkg
Use DFClient.pkg
Use cDbCJGridPromptList.pkg

Object oTimeCard is a dbModalPanel
    Set Size to 133 292
    Set Location     to 4 5
    Set Border_Style to Border_Thick

    Object oSelList is a cDbCJGridPromptList
        Set peAnchors to anAll
        Set Size      to 105 280
        Set Location  to 6 6
    End_Object

    Object oOK_bn is a Button
        Set Label     to "&OK"
        Set Location  to 115 128
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Ok of oSelList
        End_Procedure

    End_Object

    Object oCancel_bn is a Button
        Set Label     to "&Cancel"
        Set Location  to 115 182
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object

    Object oSearch_bn is a Button
        Set Label     to "&Search..."
        Set Location  to 115 236
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

End_Object

