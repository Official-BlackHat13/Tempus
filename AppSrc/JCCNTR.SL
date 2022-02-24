// JCCNTR.SL

Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg
Use cGlblForm.pkg
Use cGlblButton.pkg

Use cJcdeptDataDictionary.dd
Use cJccntrDataDictionary.dd


Object Jccntr_SL is a cGlblDbModalPanel

    Property Integer pbClone
    Property String  psNickname
    Property String  psCCPickListCode
    
    Set Locate_Mode to CENTER_ON_PANEL
    Set Minimize_Icon to FALSE
    Set Label to "Cost Centers List"
    Set Location to 4 5
    Set Size to 132 456
    Set piMaxSize to 344 520
    Set piMinSize to 84 195

    Object Jcdept_DD is a cJcdeptDataDictionary
    End_Object    // Jcdept_DD

    Object Jccntr_DD is a cJccntrDataDictionary
        Set DDO_Server to Jcdept_DD

        function MeetsConstraints returns integer
            string sCCPickListCode
            get psCCPickListCode to sCCPickListCode
            if (sCCPickListCode = "")                   function_return TRUE
            if (Jccntr.Picklist_code = sCCPickListCode) function_return TRUE
            else                                        function_return FALSE
        end_function // MeetsConstraints

        Procedure OnConstrain
            Constrain Jccntr as (MeetsConstraints(Self))
        End_Procedure

    End_Object    // Jccntr_DD

    Set Main_DD to Jccntr_DD
    Set Server to Jccntr_DD

    Object oSelList is a cGlblDbList

        Set Main_File to Jccntr.File_Number
        Set Ordering to 1
        Set Size to 101 446
        Set Location to 5 5
        Set GridLine_Mode to Grid_Visible_Both
        Set peAnchors to anAll
        Set peResizeColumn to rcNone
        Set peDisabledTextColor to clGreen

        Begin_Row
            Entry_Item Jcdept.Idno
            Entry_Item Jcdept.Nickname
            Entry_Item Jccntr.Idno
            Entry_Item Jccntr.Name
            Entry_Item Jccntr.Nickname
            Entry_Item Jccntr.Fullrate
            Entry_Item Jccntr.Directrate
            Entry_Item Jccntr.Markup
            Entry_Item Jccntr.Bnoshopfloor
            Entry_Item Jccntr.Picklist_code
        End_Row

        Set Form_Width    item 0 to 32
        Set Header_Label  item 0 to "Dept #"
        
        Set Form_Width    item 1 to 51
        Set Header_Label  item 1 to "Dept. Desc."
        
        Set Form_Width    item 2 to 28
        Set Header_Label  item 2 to "C.C.#"
        
        Set Form_Width    item 3 to 131
        Set Header_Label  item 3 to "Description"
        
        Set Form_Width    item 4 to 52
        Set Header_Label  item 4 to "Short Desc."
        
        Set Form_Width    item 5 to 35
        Set Header_Label  item 5 to " Full $"
        
        Set Form_Width    item 6 to 35
        Set Header_Label  item 6 to "Direct $"
        
        Set Form_Width    item 7 to 29
        Set Header_Label  item 7 to "Factor"
        
        Set Form_Width    item 8 to 22
        Set Header_Label  item 8 to "xSF"
        Set Column_Checkbox_State  item 8 to True
        
        Set Form_Width    item 9 to 25
        Set Header_Label  item 9 to "Filter"
        
        Procedure Move_Value_Out
            if (pbClone(self)) procedure_return
            forward send Move_Value_Out
        End_Procedure
        
        procedure Seed_List
            if (Jcdept.Recnum > 0 AND Jccntr.Recnum = 0) begin
                move Jcdept.Idno to Jccntr.Dept_idno
                move -999 to Jccntr.Idno
                find ge Jccntr by Index.1
                procedure_return
            end
            forward send Seed_List
        end_procedure
        
        procedure Ok
            if (NOT(Move_Value_Out_State(self))) begin
                set psNickname to Jccntr.Nickname
                send Close_Panel
            end
            else forward send Ok
        end_procedure

    End_Object    // oSelList

    Object oCodeFilterString is a cGlblForm
        Set Label to "Filter Code"
        Set Size to 13 17
        Set Location to 111 92
        Set peAnchors to anBottomLeft
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to jMode_Right
        Set Capslock_State to True

        Procedure OnSetFocus
            set value to (psCCPickListCode(self))
        End_Procedure
            
        Procedure OnChange
            String sFilterValue
            Get value to sFilterValue
            set psCCPickListCode to sFilterValue
            send SelectCC sFilterValue "" True
        End_Procedure  // OnChange

    End_Object    // oCodeFilterString

    Object oOK_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 111 291
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK To (oSelList(self))
        End_Procedure

    End_Object    // oOK_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 111 346
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel To (oSelList(self))
        End_Procedure

    End_Object    // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 111 401
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search To (oSelList(self))
        End_Procedure

    End_Object    // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction To (oOk_bn(self))
    On_Key Key_Alt+Key_C Send KeyAction To (oCancel_bn(self))
    On_Key Key_Alt+Key_S Send KeyAction To (oSearch_bn(self))
    
    function IsSelectedNickname returns string
        integer hoSelList
        //
        move oSelList to hoSelList
        set Move_Value_Out_State of hoSelList to FALSE
        //
        clear Jccntr
        //
        set psNickname to ""
        send Popup
        //
        set Move_Value_Out_State of hoSelList to TRUE
        function_return (psNickname(self))
    end_function
    
    procedure SelectCC string sCCPicklistCode 
        local integer hJccntrDD iRec
        move (Jccntr_DD(self)) to hJccntrDD
        //the following two lines keeps the displayed filter in synch with the filter the list was invoked with
        //and depending how the list was invoked, i.e. either by the user choosing to add a new item 
        //or by a variable prompt in an executing std. calling the pick list.
        if (sCCPickListCode = "") get value of oCodeFilterString to sCCPickListCode
        set psCCPickListCode to sCCPicklistCode
        send Rebuild_Constraints to hJccntrDD
        send Refresh_Page of oSelList FILL_FROM_CENTER
        send Popup_Modal
    end_procedure

End_Object    // Jccntr_SL
