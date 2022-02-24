// EsitemEd.SL

// Register all objects
Register_Object AddButton
Register_Object CloseButton
Register_Object DeleteButton
Register_Object DetailsButton
Register_Object EditButton
Register_Object Escomp_DD
Register_Object Eshead_DD
Register_Object Esitem_DD
Register_Object EsitemAllComponents
Register_Object FilterRadioGroup
Register_Object ItemEdit
Register_Object ItemList
Register_Object Jccntr_DD
Register_Object Jcdept_DD
Register_Object Jcoper_DD
Register_Object RadioAll
Register_Object RadioLabor
Register_Object RadioMaterial
Register_Object RadioPaper
Register_Object RadioPurchases
Register_Object RadioSubtotal1
Register_Object RadioSubtotal2
Register_Object RadioSubtotal3
Register_Object RadioSubtotal4

Use cGlblRadioGroup.pkg
Use cGlblRadio.pkg
Use cGlblButton.pkg

Use CLCENGIN.PKG
Use cJcdeptDataDictionary.dd
Use cJccntrDataDictionary.dd
Use JCOPER.DD
Use ESHEAD.DD
Use ESCOMP.DD
Use ESITEM.DD


Object EsitemAllComponents is a dbModalPanel

    Property Boolean pbCalcFlagMode True
    Property Integer piFilterSetting
    Property String  psEstimateId
    
    procedure DoSetCalcEngineDebugMode
        integer bDebug
        get pbDebug of ghoApplication to bDebug
        set pbDebug of ghoApplication to (NOT(bDebug))
    end_procedure
    
    procedure DoSetListDebugMode
        boolean bCalcFlagMode
        integer hDD
        //
        move Esitem_DD           to hDD
        get pbCalcFlagMode       to bCalcFlagMode
        set pbCalcFlagMode       to (NOT(bCalcFlagMode))
        send Rebuild_Constraints of hDD
        send Beginning_Of_Data   of ItemList
    end_procedure
    
    on_key kUser2         send DoSetCalcEngineDebugMode
    on_key Key_Alt+Key_F3 send DoSetListDebugMode
    //
    set Locate_Mode to CENTER_ON_PANEL
    Set Minimize_Icon to FALSE
    Set Label to "Estimate Component Items"
    Set Location to 4 5
    Set Size to 210 520
    Set piMaxSize to 344 570
    Set piMinSize to 109 270

    Object Jcdept_DD is a cJcdeptDataDictionary
    End_Object    // Jcdept_DD

    Object Jccntr_DD is a cJccntrDataDictionary
        Set DDO_Server to Jcdept_DD
    End_Object    // Jccntr_DD

    Object Jcoper_DD is a Jcoper_DataDictionary
        Set DDO_Server to Jccntr_DD

        Procedure OnConstrain
            integer iFilterSetting
            //
            get piFilterSetting to iFilterSetting
            //
            if      (iFilterSetting = 1) ;
                constrain Jcoper AS (Jcoper.Optype CONTAINS "L")
            else if (iFilterSetting = 2) ;
                constrain Jcoper AS (Jcoper.Optype CONTAINS "M")
            else if (iFilterSetting = 3) ;
                constrain Jcoper AS (Jcoper.Optype CONTAINS "P" AND Jcoper.Optype <> "PP")
            else if (iFilterSetting = 4) ;
                constrain Jcoper AS (Jcoper.Optype = "PP")
            else if (iFilterSetting = 5) ;
                constrain Jcoper AS (Jcoper.Optype CONTAINS "1")
            else if (iFilterSetting = 6) ;
                constrain Jcoper AS (Jcoper.Optype CONTAINS "2")
            else if (iFilterSetting = 7) ;
                constrain Jcoper AS (Jcoper.Optype CONTAINS "3")
            else if (iFilterSetting = 8) ;
                constrain Jcoper AS (Jcoper.Optype CONTAINS "4")
            //
        end_procedure
    End_Object    // Jcoper_DD

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD is a Areas_DataDictionary
    End_Object // oAreas_DD
    
    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object // oSalesRep_DD

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server to oCustomer_DD
    End_Object // oContact_DD

    Object Eshead_DD is a Eshead_DataDictionary
        Set DDO_Server to oLocation_DD
        Set DDO_Server to oContact_DD
        Set DDO_Server to oSalesRep_DD
        // this lets you save a new parent DD from within child DD
        //Set Allow_Foreign_New_Save_State to True
    End_Object    // Eshead_DD

    Object Escomp_DD is a Escomp_DataDictionary
        Set DDO_Server to Eshead_DD
    End_Object    // Escomp_DD

    Object Esitem_DD is a Esitem_DataDictionary
        Set DDO_Server to Escomp_DD
        Set DDO_Server to Jcoper_DD

        //AB-StoreStart
        Set Field_Options field Esitem.Calc_Units1 to DD_Clear_Field_Options DD_NoEnter
        Set Field_Options field Esitem.Prod_Units1 to DD_Clear_Field_Options DD_NoEnter
        Set Field_Options Field Esitem.Est_$1      to DD_Clear_Field_Options DD_NoEnter
        Set Field_Options field Esitem.Sell_1      to DD_Clear_Field_Options DD_NoEnter
        
        
        procedure OnConstrain
            constrain Esitem.Estimate_id               EQ (psEstimateId(self))
            if (pbCalcFlagMode(self)) constrain Esitem AS (pos('Z',Jcoper.Calc_Flags)=0)
        end_procedure
        
        //AB-StoreEnd

    End_Object    // Esitem_DD

    Set Main_DD to Esitem_DD
    Set Server to Esitem_DD

    Object ItemList is a dbList

        //AB-StoreTopStart
        property boolean pbEstimateDollarState TRUE
        property boolean pbDisableSearch       FALSE
        
        function Col_Index integer iColumn returns integer
            integer iIndex
            if iColumn eq 0 move 3 to iIndex
            else move 1 to iIndex
            function_return iIndex
        end_function
        
        on_key kInsert           send doAdd
        on_key kDelete_character send doDelete
        Set peDisabledTextColor to clGreen
        //AB-StoreTopEnd

        Set Main_File to Esitem.File_Number
        Set Ordering to 4
        Set Size to 140 512
        Set Location to 5 5
        Set GridLine_Mode to Grid_Visible_Both
        Set peDisabledColor to clWindow
        Set peAnchors to anAll
        Set peResizeColumn to rcNone
        Set Move_Value_Out_State to FALSE

        Begin_Row
            Entry_Item Jcoper.Opcode
            Entry_Item Esitem.Component_id
            Entry_Item (editstatus(self))
            Entry_Item Jccntr.Nickname
            Entry_Item Jcoper.Name
            Entry_Item Esitem.Calc_units1
            Entry_Item Jcoper.Calc_units_desc
            Entry_Item Esitem.Prod_units1
            Entry_Item Jcoper.Calc_std_desc
            Entry_Item Esitem.Est_$1
            Entry_Item Esitem.Sell_1
        End_Row

        Set Form_Width    item 0 to 34
        Set Header_Label  item 0 to "Opcode"
        
        Set Form_Width    item 1 to 23
        Set Header_Label  item 1 to "Cmp"
        
        Set Form_Width    item 2 to 13
        Set Header_Label  item 2 to "E"
        
        Set Form_Width    item 3 to 55
        Set Header_Label  item 3 to "Cost Center"
        
        Set Form_Width    item 4 to 112
        Set Header_Label  item 4 to "Name"
        
        Set Form_Width    item 5 to 50
        Set Header_Label  item 5 to "Calc. Units"
        
        Set Form_Width    item 6 to 60
        Set Header_Label  item 6 to "Description"
        
        Set Form_Width    item 7 to 50
        Set Header_Label  item 7 to "Prod. Units"
        
        Set Form_Width    item 8 to 60
        Set Header_Label  item 8 to "Description"
        
        Set Form_Width    item 9 to 48
        Set Header_Label  item 9 to "Cost Dollars"
        
        Set Form_Width    item 10 to 48
        Set Header_Label  item 10 to "Sell Dollars"
        

        //AB-StoreStart
        Set Header_Justification_Mode item 5  to jMode_right
        Set Header_Justification_Mode item 7  to jMode_right
        Set Header_Justification_Mode item 9 to jMode_right
        Set Header_Justification_Mode item 10 to jMode_right
        Set Numeric_Mask item 5  to 8 2
        Set Numeric_Mask item 7  to 8 2
        
        Procedure Stop_Searching
            Set Auto_Index_State to False
            Set pbDisableSearch to True
        End_Procedure
        Procedure Restore_Searching
            Set Auto_Index_State to True
            Set pbDisableSearch  to False
        End_Procedure
        set column_entry_msg item 5 to msg_Stop_Searching
        set column_exit_msg  item 5 to msg_Restore_Searching
        set column_entry_msg item 7 to msg_Stop_Searching
        set column_exit_msg  item 7 to msg_Restore_Searching
        set column_entry_msg item 9 to msg_Stop_Searching
        set column_exit_msg  item 9 to msg_Restore_Searching
        set column_entry_msg item 10 to msg_Stop_Searching
        set column_exit_msg  item 10 to msg_Restore_Searching
        
        Procedure Request_Search integer KeyVal
            integer iNoSearch
            Get pbDisableSearch to iNoSearch
            if (iNoSearch) Procedure_Return
            Forward Send Request_Search KeyVal
        End_Procedure
        
        // These 3 commented out blocks were attempts to
        // make finding by opcode across multiple components work
        // it just can't be done without looping through all compoents
        // which is what the user currently has to do manually -- very very easily
        // so it just ain't worth messing with.
        // nevertheless the only procesure that held out promise here was the "item_find" one
        // except that the augmentation of it doens't get called :-(
        
        //Procedure Request_Lookup integer Item#
        //    set file_field_index of Esitem_DD File_field Esitem.Opcode to 4
        //    Forward Send Request_Lookup Item#
        //    set file_field_index of Esitem_DD File_field Esitem.Opcode to 1
        //End_Procedure
        
        //        Procedure Request_Find Integer iMode Boolean bUpdate
        //            integer iOldOrdering iCurrent_Col
        //            Get Current_col to iCurrent_Col
        //            If (iCurrent_Col = 0) Begin
        //                Get ordering to iOldOrdering
        //                Set ordering to 4
        //                Set ordering of (server(Self)) to 4
        //            end
        //            forward send request_find iMode bUpdate
        //            set ordering to iOldOrdering
        //            Set ordering of (server(Self)) to iOldOrdering
        //        end_procedure
        
        //procedure Item_Find integer eFindMode ;
        //                      integer iFile integer iField ;
        //                      integer bDoEntryUpdate integer bShowFindErr integer bDeferred
        //          integer iEstnum iEsitemRecnum
        //          move Esitem.Recnum to iEsitemRecnum
        //          move Eshead.Estnum to iEstnum
        //          move "" to Esitem.Component_Id
        //          move Jcoper.Opcode to Esitem.Opcode
        //          Find GE Esitem by Index.3
        //          While (number(Esitem.Estimate_Id) = iEstnum)
        //               if (Esitem.Opcode >= Jcoper.Opcode) break
        //               find GE Esitem by Index.3
        //          Loop
        //          If (number(Esitem.Estimate_Id) <> iEstnum) begin
        //            clear Esitem
        //            move iEstnum to Esitem.Estimate_id
        //            move Jcoper.Opcode to Esitem.Opcode
        //            Find LE Esitem by Index.3
        //            While (number(Esitem.Estimate_Id) = iEstnum)
        //                if (Esitem.Opcode <= Jcoper.Opcode) break
        //                find LE Esitem by Index.3
        //            Loop
        //          end
        //          If (number(Esitem.Estimate_Id) <> iEstnum) begin
        //             clear esitem
        //             move iEsitemRecnum to Esitem.Recnum
        //             find EQ Esitem.Recnum
        //          End
        //          send request_assign of Esitem_dd
        //          Forward Send Item_Find eFindMode iFile iField bDoEntryUpdate bShowFinderr bDeferred
        //end_procedure
        
        //procedure Entry_Display integer i1 integer i2
        //    local integer iBase
        //    forward send Entry_Display i1 i2
        //    get Base_Item to iBase
        //    set ItemTextColor item (iBase+5)  to clBlack
        //    set ItemTextColor item (iBase+7)  to clBlack
        //    set ItemTextColor item (iBase+9)  to clBlack
        //    set ItemTextColor item (iBase+10) to clBlack
        //end_procedure
        
        
        function EditStatus returns string
            string sStatus sCalcFlags
            move "*" to sStatus
            move Jcoper.Calc_flags to sCalcFlags
            if "D" in sCalcFlags if not "O" in sCalcFlags move "" to sStatus
            if Esitem.Instruction ne "" append sStatus "T"
            function_return sStatus
        end_function
        
        procedure Ok
            send KeyAction to (DetailsButton(self))
        end_procedure
        
        procedure DoToggleDollarState
            boolean bEstimateDollarState
            //
            get pbEstimateDollarState        to bEstimateDollarState
            move (NOT(bEstimateDollarState)) to bEstimateDollarState
            set pbEstimateDollarState        to bEstimateDollarState
            //
            if (bEstimateDollarState) begin
                set Form_Width item 9  to 48
                set Form_Width item 10 to 0
            end
            else begin
                set Form_Width item 9  to 0
                set Form_Width item 10 to 48
            end
            send Refresh_Page FILL_FROM_CENTER
        end_procedure
        //AB-StoreEnd

    End_Object    // ItemList

    Object ItemEdit is a dbEdit

        //AB-StoreTopStart
        set Shadow_State to TRUE
        //AB-StoreTopEnd

        Entry_Item Esitem.Instruction
        Set Size to 54 234
        Set Location to 151 5
        Set peAnchors to anBottomLeftRight

        //AB-StoreStart
                
        //AB-StoreEnd

    End_Object    // ItemEdit

    Object FilterRadioGroup is a cGlblRadioGroup
        Set Size to 39 272
        Set Location to 148 245
        Set peAnchors to anBottomRight
        Set Label to "Show only items for Subtotal:"
        Object RadioAll is a Radio
            Set Label to "&Show all"
            Set Size to 10 43
            Set Location to 10 5

            //AB-StoreStart
            Procedure OnSetFocus
                Send Activate of ItemList
            End_Procedure
            //AB-StoreEnd

        End_Object    // RadioAll

        Object RadioLabor is a Radio
            Set Label to "L Subtotal"
            Set Size to 10 49
            Set Location to 10 49

            //AB-StoreStart
            set label to ("&L" * (lowercase(Jcpars.L_Subttl_Name)))
            Procedure OnSetFocus
                Send Activate of ItemList
            End_Procedure
            //AB-StoreEnd

        End_Object    // RadioLabor

        Object RadioMaterial is a Radio
            Set Label to "M Subtotal"
            Set Size to 10 51
            Set Location to 10 102

            //AB-StoreStart
            set label to ("&M" * (lowercase(Jcpars.M_Subttl_Name)))
            Procedure OnSetFocus
                Send Activate of ItemList
            End_Procedure
            //AB-StoreEnd

        End_Object    // RadioMaterial

        Object RadioPurchases is a cGlblRadio
            Set Label to "P Subtotal"
            Set Size to 10 49
            Set Location to 10 155

            //AB-StoreStart
            set label to ("&P" * (lowercase(Jcpars.P_Subttl_Name)))
            Procedure OnSetFocus
                Send Activate of ItemList
            End_Procedure
            //AB-StoreEnd

        End_Object    // RadioPurchases

        Object RadioPaper is a cGlblRadio
            Set Label to "PP Subtotal"
            Set Size to 10 54
            Set Location to 10 213

            //AB-StoreStart
            set label to ("&R" * (lowercase(Jcpars.PP_Subttl_Name)))
            Procedure OnSetFocus
                Send Activate of ItemList
            End_Procedure
            //AB-StoreEnd

        End_Object    // RadioPaper

        Object RadioSubtotal1 is a cGlblRadio
            Set Label to "Subtotal 1"
            Set Size to 10 49
            Set Location to 23 49

            //AB-StoreStart
            set label to ("&1" * (lowercase(Jcpars.Subttl1_Name)))
            Procedure OnSetFocus
                Send Activate of ItemList
            End_Procedure
            //AB-StoreEnd

        End_Object    // RadioSubtotal1

        Object RadioSubtotal2 is a cGlblRadio
            Set Label to "Subtotal 2"
            Set Size to 10 49
            Set Location to 23 102

            //AB-StoreStart
            set label to ("&2" * (lowercase(Jcpars.Subttl2_Name)))
            Procedure OnSetFocus
                Send Activate of ItemList
            End_Procedure
            //AB-StoreEnd

        End_Object    // RadioSubtotal2

        Object RadioSubtotal3 is a cGlblRadio
            Set Label to "Subtotal 3"
            Set Size to 10 49
            Set Location to 23 155

            //AB-StoreStart
            set label to ("&3" * (lowercase(Jcpars.Subttl3_Name)))
            Procedure OnSetFocus
                Send Activate of ItemList
            End_Procedure
            //AB-StoreEnd

        End_Object    // RadioSubtotal3

        Object RadioSubtotal4 is a cGlblRadio
            Set Label to "Subtotal 4"
            Set Size to 10 49
            Set Location to 23 213

            //AB-StoreStart
            set label to ("&4" * (lowercase(Jcpars.Subttl4_Name)))
            Procedure OnSetFocus
                Send Activate of ItemList
            End_Procedure
            //AB-StoreEnd

        End_Object    // RadioSubtotal4


        //AB-StoreStart
        Procedure Notify_Select_State integer iToItem integer iFromItem
            //for augmentation
            send doFilterItems iToItem
            //send activate of ItemList
        End_Procedure
        
        
        // If you set Current_radio you must set this after the
        // radio objects have been created AND after Notify_select_State has been
        // created. i.e. Set in bottom-code at end!!
        //Set Current_Radio to 0
        //AB-StoreEnd

    End_Object    // FilterRadioGroup

    Object AddButton is a cGlblButton

        //AB-StoreTopStart
        on_key kCancel send Request_Cancel
        //AB-StoreTopEnd

        Set Label to "&Add"
        Set Size to 14 32
        Set Location to 191 245
        Set peAnchors to anBottomRight

        //AB-StoreStart
        procedure OnClick
            send DoAdd
        end_procedure
        //AB-StoreEnd

    End_Object    // AddButton

    Object EditButton is a cGlblButton

        //AB-StoreTopStart
        on_key kCancel send Request_Cancel
        //AB-StoreTopEnd

        Set Label to "&Edit"
        Set Size to 14 32
        Set Location to 191 281
        Set peAnchors to anBottomRight

        //AB-StoreStart
        procedure OnClick
            send DoEdit
        end_procedure
        //AB-StoreEnd

    End_Object    // EditButton

    Object DetailsButton is a cGlblButton

        //AB-StoreTopStart
        on_key kCancel send Request_Cancel
        //AB-StoreTopEnd

        Set Label to "De&tails"
        Set Size to 14 32
        Set Location to 191 317
        Set peAnchors to anBottomRight

        //AB-StoreStart
        Procedure OnClick
            Send DoDetails
        End_Procedure
        //AB-StoreEnd

    End_Object    // DetailsButton

    Object DeleteButton is a cGlblButton

        //AB-StoreTopStart
        on_key kCancel send Request_Cancel
        //AB-StoreTopEnd

        Set Label to "&Delete"
        Set Size to 14 32
        Set Location to 191 353
        Set peAnchors to anBottomRight

        //AB-StoreStart
        procedure OnClick
            send DoDelete
        end_procedure
        //AB-StoreEnd

    End_Object    // DeleteButton

    Object CloseButton is a cGlblButton

        //AB-StoreTopStart
        on_key kCancel send Request_Cancel
        //AB-StoreTopEnd

        Set Label to "&Close"
        Set Size to 14 32
        Set Location to 191 389
        Set peAnchors to anBottomRight

        //AB-StoreStart
        Procedure OnClick
            Send Close_Panel
        End_Procedure
        //AB-StoreEnd

    End_Object    // CloseButton


    //AB-StoreStart
    Procedure EnableAdd    boolean bState
        set Enabled_State of AddButton to bState
    End_Procedure
    Procedure EnableEdit   boolean bState
        set Enabled_State of EditButton to bState
    End_Procedure
    Procedure EnableDelete boolean bState
        set Enabled_State of DeleteButton to bState
    End_Procedure
    Procedure EnableButtons boolean bState
        set Enabled_State of AddButton    to bState
        set Enabled_State of EditButton   to bState
        set Enabled_State of DeleteButton to bState
    End_Procedure
    
    procedure DoAdd
        integer hEsitemDD iNewOpcode iCalcMode bDebug
        string  sEstimateId sComponentId
        //
        move Esitem_DD to hEsitemDD
        send Refind_Records to hEsitemDD
        //
        get psEstimateId to sEstimateId
//*dw*
//        get AddItemSelection of (Escomp_SL(self)) to sComponentId
    //        SEND INFO_BOX sComponentId
        //
    //        send EnableEdit false
    //        send EnableDelete false
        //
        move CE_ADD to iCalcMode
        //
        get pbDebug of ghoApplication to bDebug
        //
        begin
            get DoCalcEngine of oCalcEngine ;
                iCalcMode ;
                DFFALSE   ;
                bDebug    ;
                to iNewOpcode
            if iNewOpcode begin
                clear Esitem
                move sEstimateId  to Esitem.Estimate_id
                move sComponentId to Esitem.Component_id
                move iNewOpcode   to Esitem.Opcode
                send Find of hEsitemDD EQ 1
            end
            move CE_ADD_AGAIN to iCalcMode
            if (iNewOpcode) break BEGIN
        end
    //        send EnableButtons true
    //        if Escomp.Needs_calced eq "Y" send EnableCalculate true
        //if NOT (Current_Record
        send Refresh_Page of ItemList FILL_FROM_CENTER
        set pbDebug of ghoApplication to FALSE
        send Activate of ItemList
        //
    end_procedure // DoAdd
    
    procedure DoEdit
        integer iItemRec
        get Current_Record of (Esitem_DD(self)) to iItemRec
        send EditItemDirect of oVariablesDialog iItemRec
        //send EditItemDirect to (EsitemDt(self)) iItemRec
        send Refresh_Page to (ItemList(self)) FILL_FROM_CENTER
    end_procedure
    
    procedure DoDetails
        integer iItemRec
        get Current_Record of (Esitem_DD(self)) to iItemRec
        send DoItemDetails of oItemDialog iItemRec FALSE
        //send SetDdoStructure to (Esitem(self)) iItemRec
        //send Popup_Modal to (Esitem(self))
    end_procedure
    
    procedure DoDelete
        integer hEsitemDD iRet iOpcode //iItemCount
        string  sEstimateId sComponentId sOperation
        // get the ID of the server
        move (Esitem_DD(self)) to hEsitemDD
        //
        move Esitem.Estimate_id to sEstimateId
        move Esitem.Component_id to sComponentId
        move Esitem.Opcode to iOpcode
        move "Delete Operation " to sOperation
        append sOperation iOpcode " from component " sComponentId "?"
        get YesNo_Box sOperation "Confirm" to iRet
        if (iRet = MBR_No) procedure_return
        send Request_Delete
        move sEstimateId to Esitem.Estimate_id
        move sComponentId to Esitem.Component_id
        move iOpcode to Esitem.Opcode
        send Find to hEsitemDD GE 4
        send Refresh_Page to (ItemList(self)) FILL_FROM_CENTER
        send Activate     to (ItemList(self))
    end_procedure
    
    procedure DoAllCompItems string sEstimateId
        set pbCalcFlagMode  to TRUE
        set psEstimateId    to sEstimateId
        set piFilterSetting to 0
        send Rebuild_Constraints of (Server(self))
    end_procedure
    
    procedure DoFilterItems integer iFilterSetting
        integer hDD hList
        //
        move ItemList  to hList
        get Server     to hDD
        send Clear_All of hDD
        //
        set piFilterSetting      to iFilterSetting
        send Rebuild_Constraints of Jcoper_DD
        send Rebuild_Constraints of hDD
        send Beginning_Of_Data   of hList
        send Refresh_Page        of hList FILL_FROM_TOP
        send Activate            of hList
    end_procedure
    
    Procedure doSetCurrent_Radio0
        set current_radio of FilterRadioGroup to 0
    End_Procedure
    Procedure doSetCurrent_Radio1
        set current_radio of FilterRadioGroup to 1
    End_Procedure
    Procedure doSetCurrent_Radio2
        set current_radio of FilterRadioGroup to 2
    End_Procedure
    Procedure doSetCurrent_Radio3
        set current_radio of FilterRadioGroup to 3
    End_Procedure
    Procedure doSetCurrent_Radio4
        set current_radio of FilterRadioGroup to 4
    End_Procedure
    Procedure doSetCurrent_Radio5
        set current_radio of FilterRadioGroup to 5
    End_Procedure
    Procedure doSetCurrent_Radio6
        set current_radio of FilterRadioGroup to 6
    End_Procedure
    Procedure doSetCurrent_Radio7
        set current_radio of FilterRadioGroup to 7
    End_Procedure
    Procedure doSetCurrent_Radio8
        set current_radio of FilterRadioGroup to 8
    End_Procedure
    
    on_key Key_Alt+Key_A   send KeyAction           of AddButton
    on_key Key_Alt+Key_E   send KeyAction           of EditButton
    on_key Key_Alt+Key_T   send KeyAction           of DetailsButton
    on_key Key_Alt+Key_D   send KeyAction           of DeleteButton
    on_key Key_Alt+Key_C   send KeyAction           of CloseButton
    on_key Key_Alt+Key_F12 send DoToggleDollarState of ItemList
    //
    on_key Key_Alt+Key_S   send doSetCurrent_Radio0
    on_key Key_Alt+Key_L   send doSetCurrent_Radio1
    on_key Key_Alt+Key_M   send doSetCurrent_Radio2
    on_key Key_Alt+Key_P   send doSetCurrent_Radio3
    on_key Key_Alt+Key_R   send doSetCurrent_Radio4
    on_key Key_Alt+Key_1   send doSetCurrent_Radio5
    on_key Key_Alt+Key_2   send doSetCurrent_Radio6
    on_key Key_Alt+Key_3   send doSetCurrent_Radio7
    on_key Key_Alt+Key_4   send doSetCurrent_Radio8
    
    Procedure Popup_Modal boolean bReadOnly // set labels commands in objects bottom code is NOT executing!!!
        set value of RadioLabor     to (lowercase(Jcpars.L_Subttl_Name))
        set value of RadioMaterial  to (lowercase(Jcpars.M_Subttl_Name))
        set value of RadioPurchases to (lowercase(Jcpars.P_Subttl_Name))
        set value of RadioPaper     to (lowercase(Jcpars.PP_Subttl_Name))
        set value of RadioSubtotal1 to (lowercase(Jcpars.Subttl1_Name))
        set value of RadioSubtotal2 to (lowercase(Jcpars.Subttl2_Name))
        set value of RadioSubtotal3 to (lowercase(Jcpars.Subttl3_Name))
        set value of RadioSubtotal4 to (lowercase(Jcpars.Subttl4_Name))
        send enablebuttons (not(bReadOnly))
        forward send popup_modal
    End_Procedure
    //AB-StoreEnd

End_Object    // EsitemAllComponents

//AB/ End_Object    // prj

