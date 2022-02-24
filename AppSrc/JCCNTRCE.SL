USE DFAllEnt.pkg

Use cJcdeptDataDictionary.dd
Use cJccntrDataDictionary.dd


Object JccntrCE_SL is a dbModalPanel

    Property String  psCCPickListCode  Public ""
    Property Boolean pbConstrainToDept False
    Property Boolean pbAllowFilter     False

    Object Jcdept_DD is a cJcdeptDataDictionary
    End_Object    // Jcdept_DD

    Object Jccntr_DD is a cJccntrDataDictionary
        Set DDO_Server to (Jcdept_DD(Current_Object))
        //
        function MeetsConstraints returns integer
            string sCCPickListCode
            get psCCPickListCode to sCCPickListCode
            if (sCCPickListCode = "")                   function_return TRUE
            if (Jccntr.Picklist_code = sCCPickListCode) function_return TRUE
            else                                        function_return FALSE
        end_function // MeetsConstraints
        //
        begin_constraints
            if (Current_Record(Jcdept_DD) and (not(pbAllowFilter(self)))) ;
                constrain Jccntr relates to Jcdept
            constrain Jccntr.Std_count NE 0
            constrain Jccntr as (MeetsConstraints(self))
        end_constraints
    End_Object    // Jccntr_DD

    set Locate_Mode to CENTER_ON_PANEL

    Set Minimize_Icon to FALSE
    set Sysmenu_Icon to false
    Set Label to "Select Cost Center"
    // Visual DataFlex 14.0 Client Size Adjuster, modified May 23, 2008: 14:36:01
//    Set Size to 149 269 //186
    Set Size to 110 264
    Set Location to 4 5

    Object oSelList is a dbList

        //AB-StoreTopStart
        Set peDisabledTextColor to clGreen
        //AB-StoreTopEnd
                on_key kEnter send OK
        on_key kExit_application send None
        Set peDisabledTextColor to clGreen

        set Server to (Jccntr_DD(Current_Object))
        Set Main_File to Jccntr.File_Number
        Set Ordering to 1
        Set Initial_Column to 2
        //set Auto_Index_State to false
        Set Size to 82 253
        Set Location to 5 5

                set Move_Value_Out_State to false

        Begin_Row
            Entry_Item Jcdept.Idno
            Entry_Item Jcdept.Nickname
            Entry_Item Jccntr.Idno
            Entry_Item Jccntr.Name
        End_Row

        Set Form_Width    item 0 to 0
        Set Header_Label  item 0 to "Dept #"

        Set Form_Width    item 1 to 0
        Set Header_Label  item 1 to "Dept. Desc."

        Set Form_Width    item 2 to 0
        Set Header_Label  item 2 to "CC#"

        Set Form_Width    item 3 to 250
        Set Header_Label  item 3 to "Description"
        Set Header_Justification_Mode 3 to JMode_Center
        Set Form_Justification_Mode 3 to Form_DisplayCenter
        Set Resize_Column_State 3 to False
        Set peAnchors to anAll

                procedure OK
                        send Close_Panel
                end_procedure

                procedure Cancel
                        clear Jccntr
                        send Close_Panel
                end_procedure

    End_Object    // oSelList

    Object oOK_bn is a cGlblButton
        Set Label to "&Ok"
        Set Size to 14 50
        Set Location to 92 155
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK To (oSelList(current_object))
        End_Procedure

    End_Object // oOK_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Size to 14 50
        Set Location to 92 209
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel To (oSelList(current_object))
        End_Procedure

    End_Object // oCancel_bn

//    Object oSearch_bn is a Button
//        Set Label to "&Search..."
//        Set Size to 14 50
//        Set Location to 115 117

//        //AB-StoreStart
//        Procedure OnClick
//            Send Search To (oSelList(current_object))
//        End_Procedure
        //AB-StoreEnd

//    End_Object    // oSearch_bn

    Object oCodeFilterGroup is a cGlblGroup
        Set Size to 23 84
        Set Location to 87 5
        Set peAnchors to anBottomLeft

        Object oCodeFilterString is a cGlblForm
            Set Label to "Filter list by code:"
            Set Size to 13 14
            Set Location to 7 65

            //AB-StoreStart
            set capslock_state to true
            Procedure OnSetFocus
                set value to (psCCPickListCode(self))
            End_Procedure
            
            Procedure OnChange
                String sFilterValue
                Get value to sFilterValue
                set psCCPickListCode to sFilterValue
                send SelectCC sFilterValue "" True
            End_Procedure  // OnChange
            //AB-StoreEnd

        End_Object    // oCodeFilterString

    End_Object    // oCodeFilterGroup

    //AB-StoreStart
    On_Key Key_Alt+Key_O Send KeyAction To (oOk_bn(current_object))
    On_Key Key_Alt+Key_C Send KeyAction To (oCancel_bn(current_object))
//    On_Key Key_Alt+Key_S Send KeyAction To (oSearch_bn(current_object))

    procedure SelectCC string sCCPicklistCode string sListTitle boolean bAllowFilter
        local integer hJccntrDD iRec
        move (Jccntr_DD(self)) to hJccntrDD
        set pbAllowFilter to bAllowFilter
        //the following two lines keeps the displayed filter in synch with the filter the list was invoked with
        //and depending how the list was invoked, i.e. either by the user choosing to add a new item 
        //or by a variable prompt in an executing std. calling the pick list.
        set enabled_state of (oCodeFilterString(oCodeFilterGroup(self))) to bAllowFilter
        if (sCCPickListCode = "") get value of (oCodeFilterString(oCodeFilterGroup(self))) to sCCPickListCode
        set psCCPickListCode to sCCPicklistCode
        send Rebuild_Constraints to hJccntrDD
        if (sListTitle<>"") set label to sListTitle
        else set Label to "Select Cost Center"
        send Refresh_Page of oSelList FILL_FROM_CENTER
        send Popup_Modal
    end_procedure

        procedure Activating
        integer iRet
                forward get MSG_Activating to iRet
                if iRet function_return iRet
        set Locate_Mode to NO_LOCATE
        //set pbConstrainToDept to (Current_Record(Jcdept_DD)) 
        Set Value of oCodeFilterString to 'A'
    End_Procedure
    //AB-StoreEnd

End_Object    // JCCNTR_SL

//AB/ End_Object    // prj

