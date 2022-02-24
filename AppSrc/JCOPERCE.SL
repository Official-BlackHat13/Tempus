USE DFAllEnt.pkg

Use cJcdeptDataDictionary.dd
Use cJccntrDataDictionary.dd
Use Jcoper.dd

Object Jcoperce_SL is a dbModalPanel

    property string psOptype public ""

    Object Jccntr_DD is a cJccntrDataDictionary
    End_Object // Jccntr_DD

    Object Jcoper_DD is a Jcoper_DataDictionary
        set DDO_Server to (Jccntr_DD(self))
        set Constrain_File to Jccntr.File_number
        //
        function MeetsConstraints returns integer
            string sOptype
            if "D" in Jcoper.Calc_flags function_return FALSE
            get psOptype to sOptype
            //
            if (sOptype = "") function_return TRUE
            //
            else if (sOptype = "L") begin
                if "L" in Jcoper.Optype      function_return TRUE
                else if "H" in Jcoper.Optype function_return TRUE
                else                         function_return FALSE
            end
            //
            else if (sOptype = "M") begin
                if "M" in Jcoper.Optype function_return TRUE
                else                    function_return FALSE
            end
            //
            else if (sOptype = "P") begin
                if "P" in Jcoper.Optype function_return TRUE
                else                    function_return FALSE
            end
            //
            else begin
                if (Jcoper.Picklist_code = sOptype) function_return TRUE
                else                                function_return FALSE
            end
        end_function // MeetsConstraints
        //
        begin_constraints
        //    if (Current_Record(Jccntr_DD(self))) ;
        //        constrain Jcoper relates to Jccntr
            constrain Jcoper.Est_std eq "Y"
            constrain Jcoper as (MeetsConstraints(self))
        end_constraints
        //
    End_Object // Jcoper_DD

    set Locate_Mode to CENTER_ON_PANEL

    Set Minimize_Icon to FALSE
    set Sysmenu_Icon  to FALSE
    Set Label to "Select Operation"
    // Visual DataFlex 14.0 Client Size Adjuster, modified May 23, 2008: 14:35:50
//    Set Size to 149 238
    Set Size to 189 233
    Set Location to 4 5


    Object oSelList is a dbList

        //AB-StoreTopStart
        Set peDisabledTextColor to clGreen
        on_key kExit_application send None
        //AB-StoreTopEnd

        set Server to (Jcoper_DD(self))
        set Move_Value_Out_State to false
        Set peDisabledTextColor to clGreen

        //Set Main_File to Jcoper.File_Number
        Set Ordering to 3
        set Auto_Index_State to false
        Set Size to 161 224
        Set Location to 4 4

        Begin_Row
            Entry_Item Jcoper.Opcode
            Entry_Item Jccntr.Nickname
            Entry_Item Jcoper.Name
        End_Row

        Set Form_Width    item 0 to 0
        Set Header_Label  item 0 to "CC/OP#"

        Set Form_Width    item 1 to 0
        Set Header_Label  item 1 to "Cost Center"

        Set Form_Width    item 2 to 220
        Set Header_Label  item 2 to "Description"
        Set Header_Justification_Mode 2 to JMode_Center
        Set Form_Justification_Mode 2 to Form_DisplayCenter
        Set Resize_Column_State to False
        Set peAnchors to anAll

                procedure OK
                        send Close_Panel
                end_procedure

                procedure Cancel
                        clear Jcoper
                        send Close_Panel
                end_procedure

    End_Object    // oSelList

    Object oOK_bn is a Button
        Set Label to "&Ok"
        Set Size to 14 50
        Set Location to 171 124
        Set peAnchors to anBottomRight

        //AB-StoreStart
        Procedure OnClick
            Send OK To (oSelList(self))
        End_Procedure
        //AB-StoreEnd

    End_Object    // oOK_bn

    Object oCancel_bn is a Button
        Set Label to "&Cancel"
        Set Size to 14 50
        Set Location to 171 178
        Set peAnchors to anBottomRight

        //AB-StoreStart
        Procedure OnClick
            Send Cancel To (oSelList(self))
        End_Procedure
        //AB-StoreEnd

    End_Object    // oCancel_bn

    procedure SelectOpcode string sOptype integer iCC integer iOpcode string sListTitle
        local integer hJcoperDD iRec
        move (Jcoper_DD(self)) to hJcoperDD
        set psOptype to sOptype
        //SHOWLN ""
        //SHOWLN "SELECT OPCODE"
        //SHOWLN ICC
        //SHOWLN IOPCODE
        send Clear_All to hJcoperDD
        move iCC to Jccntr.Idno
        send Request_Find to hJcoperDD EQ Jccntr.File_number 3
        if iOpcode begin
            move iOpcode to Jcoper.Opcode
            send Find to hJcoperDD EQ 2
            move (Current_Record(hJcoperDD)) to iRec
            //SHOWLN IREC
        end
        send Rebuild_Constraints to hJcoperDD
        //if (iOpcode AND iRec) begin
        //    SHOWLN "READY"
        //    send Find_By_Recnum to hJcoperDD Jcoper.File_number iRec
        //    send Refresh_Page to (oSelList(self)) FILL_FROM_CENTER
        //end
        if (sListTitle<>"") set label to sListTitle
        else set label to "Select Operation"
        send Popup
    end_procedure

        procedure Activating
        integer iRet
                forward get MSG_Activating to iRet
                if iRet function_return iRet
        set Locate_Mode to NO_LOCATE
        end_procedure

    On_Key Key_Alt+Key_O Send KeyAction To (oOk_bn(self))
    On_Key Key_Alt+Key_C Send KeyAction To (oCancel_bn(self))

End_Object    // Jcoperce_SL

