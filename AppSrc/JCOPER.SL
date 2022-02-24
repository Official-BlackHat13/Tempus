// Jcoper.SL

Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg
Use cGlblButton.pkg

Use cJcdeptDataDictionary.dd
Use cJccntrDataDictionary.dd
Use JCOPER.DD


Object Jcoper_SL is a cGlblDbModalPanel

    Property Integer piLinkCode
    Property Integer pbLinker
    Property Integer pbClone
    Property Integer piSeedObj
    Property Integer piCCno
    Property Integer piOpidno
    Property Integer piOpcode
    Property String  psCCPickListCode ''
    
    set Locate_Mode to CENTER_ON_PANEL
    
    procedure Activating
        Integer iRet iObj
        //
        Get Focus to iObj
        forward get MSG_Activating to iRet
        if iRet procedure_return
        Set pbLinker to (pbLinker(iObj))
        //Set Value of oCodeFilterString to 'A' // Tom, thought he wanted to ...
    end_procedure

    Set Minimize_Icon to FALSE
    Set Label to "Operation Standards List"
    Set Location to 4 5
    Set Size to 130 488
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
        //
        Procedure OnConstrain
            constrain Jccntr as (MeetsConstraints(Jccntr_DD))
        End_Procedure

    End_Object    // Jccntr_DD

    Object Jcoper_DD is a Jcoper_DataDictionary
        Set DDO_Server to Jccntr_DD

        function MeetsConstraints returns integer
            boolean bClone
            get pbClone to bClone
            if (not(bClone)) Function_Return True
            else Function_Return (Jcoper.Est_Std="Y")
        end_function // MeetsConstraints
        //
        Procedure OnConstrain
            constrain Jcoper as (MeetsConstraints(Jcoper_DD))
        End_Procedure
    End_Object    // Jcoper_DD

    Set Main_DD to Jcoper_DD
    Set Server to Jcoper_DD

    Object oSelList is a cGlblDbList
        Set Initial_Row to fill_from_center
        Set Init_From_Top_State to False
        register_procedure PrimeList
        set Load_Buffer_msg to msg_PrimeList
        Set peDisabledTextColor to clGreen
        set Auto_Export_State to FALSE
        
        procedure Activating
            Integer iRet
            //
            Forward Get MSG_Activating to iRet
            if iRet procedure_return
            set Export_Item_State to (pbLinker(self))
        end_procedure

        Set Main_File to Jcoper.File_Number
        Set Ordering to 3
        Set Size to 101 478
        Set Location to 4 4
        Set GridLine_Mode to Grid_Visible_Both
        Set peAnchors to anAll
        Set peResizeColumn to rcNone

        Begin_Row
            Entry_Item Jcoper.Opcode
            Entry_Item Jccntr.Nickname
            Entry_Item Jcoper.Name
            Entry_Item Jcoper.Nickname
            Entry_Item Jcoper.Optype
            Entry_Item Jcoper.Costype
            Entry_Item Jcoper.Std_type
            Entry_Item Jcoper.Standard
            Entry_Item Jcoper.Markup
            Entry_Item Jcoper.Est_std
            Entry_Item Jcoper.Picklist_code
        End_Row

        Set Form_Width    item 0 to 36
        Set Header_Label  item 0 to "CC/OP#"
        
        Set Form_Width    item 1 to 50
        Set Header_Label  item 1 to "Cost Center"
        
        Set Form_Width    item 2 to 122
        Set Header_Label  item 2 to "Description"
        
        Set Form_Width    item 3 to 54
        Set Header_Label  item 3 to "Short Desc."
        
        Set Form_Width    item 4 to 31
        Set Header_Label  item 4 to "Sub Ttl"
        
        Set Form_Width    item 5 to 37
        Set Header_Label  item 5 to "Cst Type"
        
        Set Form_Width    item 6 to 38
        Set Header_Label  item 6 to "Std Type"
        
        Set Form_Width    item 7 to 38
        Set Header_Label  item 7 to "Standard"
        
        Set Form_Width    item 8 to 29
        Set Header_Label  item 8 to "Factor"
        
        Set Form_Width    item 9 to 14
        Set Header_Label  item 9 to "$"
        
        Set Form_Width    item 10 to 24
        Set Header_Label  item 10 to "Filter"
        

        // all this stuff is to make the higlight bar retain context with the view
        // and work correctly as the prompt object for Jcoper.Idno in Jcoper.vw
        // when that column does not appear in the list
        
        procedure Seed_List
            integer iLinkCode iSeedObj iCCNo iOpcode iOpIdno
            get piCcno   to iCcno
            get piOpIdno to iOpIdno
            get piOpcode to iOpcode
            //
            // we'd still like the list to retain its current record context when cloning
            if (pbClone(self)) Begin //procedure_return
                get piSeedObj to iSeedObj
                set invoking_object_id to iSeedObj
            end
            if (pbLinker(self)) begin
                get piLinkCode to iLinkCode
                clear Jcoper
                if iLinkCode begin
                    move iLinkCode to Jcoper.Opcode
                    find ge Jcoper.Opcode
                end
                procedure_return
            end
//            if (iCcno >0 AND iOpIdno =0) begin
//                move (iCcno*1000) to Jcoper.Opcode
//                Send Find of Jcoper_DD GE 2
//                //find gt Jcoper.Opcode
//                //procedure_return
//            end
//            else if (iCcno >0 AND iOpcode =0) begin
//                move (iCcno*1000) to Jcoper.Opcode
//                Send Find of Jcoper_DD GE 2
//                //find gt Jcoper.Opcode
//                //procedure_return
//            end
//            else if (iCcno =0 and iOpcode =0) begin
//                move (-99999) to Jcoper.Opcode
//                find GT Jcoper.Opcode
//                procedure_return
//            end
//            else if (iCCno <>0 and iOpIdno <>0) begin
//                move (iCCNo*1000 +iOpIdno) to Jcoper.Opcode
//                Send Find of Jcoper_DD GE 2
//                //find GE Jcoper.Opcode
//                //send request_assign to jcoper_dd
//            end
            forward send Seed_List
        end_procedure
        
        procedure Move_Value_Out
            if (pbClone(self)) procedure_return
            forward send Move_Value_Out
        end_procedure
        
    End_Object    // oSelList

    Object oCodeFilterString is a cGlblForm
        Set Label to "CC Filter Code"
        Set Size to 13 17
        Set Location to 109 54
        Set peAnchors to anBottomLeft
        Set Label_Col_Offset to 2
        Set Label_Justification_Mode to jMode_Right

        set capslock_state to true
        Procedure OnSetFocus
            Set value to (psCCPickListCode(Self))
        End_Procedure
            
        Procedure OnChange
            String sFilterValue
            Get value to sFilterValue
            set psCCPickListCode to sFilterValue
            send SelectCC sFilterValue "" True
        End_Procedure  // OnChange
    End_Object    // oCodeFilterString

    Object oDetails_bn is a cGlblButton
        Set Label to "&Estimating Standard Details"
        Set Size to 14 100
        Set Location to 109 90
        Set peAnchors to anBottomLeft

        Procedure OnClick
            Send DoDisplayDetails
        End_Procedure
    End_Object    // oDetails_bn

    Object oOK_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 109 325
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure
    End_Object    // oOK_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 109 379
        Set peAnchors to anBottomRight

        Procedure OnClick
            Clear Jcoper
            Send Cancel of oSelList
        End_Procedure
    End_Object    // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 109 433
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure
    End_Object    // oSearch_bn


    On_Key Key_Alt+Key_E Send KeyAction of oDetails_bn
    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn
    
    register_object JcoperDetailDialog
    Procedure DoDisplayDetails
        send DoDisplayDetails of JcoperDetailDialog Jcoper.Recnum
    End_Procedure
    
    procedure LinkCodePrompt integer iLinkCode
        set piLinkCode to iLinkCode
        send Popup
    end_procedure
    
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
    //function CloneOperationStandard returns integer
    //    set pbClone to true
    //    set Move_Value_Out_State of (oSelList(self)) to false
    //    send Popup
    //    set Move_Value_Out_State of (oSelList(self)) to true
    //    set pbClone to false
    //    function_return Jcoper.Opcode
    //end_function
    //AB-StoreEnd

End_Object    // Jcoper_SL
