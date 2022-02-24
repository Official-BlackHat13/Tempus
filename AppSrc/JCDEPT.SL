// JCDEPT.SL

Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg
Use cGlblButton.pkg

Use cJcdeptDataDictionary.dd


Object JCDEPT_SL is a cGlblDbModalPanel

    set Locate_Mode to CENTER_ON_PANEL
    Set Minimize_Icon to FALSE
    Set Label to "Department List"
    Set Location to 4 5
    Set Size to 107 356
    Set piMaxSize to 344 520
    Set piMinSize to 84 195

    Object Jcdept_DD is a cJcdeptDataDictionary
    End_Object    // Jcdept_DD

    Set Main_DD to Jcdept_DD
    Set Server to Jcdept_DD

    Object oSelList is a cGlblDbList
        Set peDisabledTextColor to clGreen
        Set Main_File to Jcdept.File_Number
        Set Ordering to 1
        Set Size to 81 347
        Set Location to 1 3
        Set GridLine_Mode to Grid_Visible_Both
        Set peAnchors to anAll
        Set peResizeColumn to rcNone

        Begin_Row
            Entry_Item Jcdept.Idno
            Entry_Item Jcdept.Name
            Entry_Item Jcdept.Nickname
            Entry_Item Jcdept.Depthead
            Entry_Item Jcdept.Markup
        End_Row

        Set Form_Width    item 0 to 16
        Set Header_Label  item 0 to "ID"
        
        Set Form_Width    item 1 to 126
        Set Header_Label  item 1 to "Description"
        
        Set Form_Width    item 2 to 60
        Set Header_Label  item 2 to "Short Desc."
        
        Set Form_Width    item 3 to 107
        Set Header_Label  item 3 to "Manager"
        
        Set Form_Width    item 4 to 29
        Set Header_Label  item 4 to "Factor"
        
    End_Object    // oSelList

    Object oOK_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 86 190
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK To (oSelList(current_object))
        End_Procedure
    End_Object    // oOK_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 86 246
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel To (oSelList(current_object))
        End_Procedure
    End_Object    // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 86 300
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search To (oSelList(current_object))
        End_Procedure
    End_Object    // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

End_Object    // JCDEPT_SL
