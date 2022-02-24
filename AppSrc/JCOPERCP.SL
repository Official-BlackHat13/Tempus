//AB/ Project Alternate Trigger Standards
//AB/ Object prj is a Lookup_Project
    //AB/ Set ProjectName to "Alternate Trigger Standards"
    //AB/ Set ProjectFileName to "Jcopercp.SL"
    //AB/ Set GenerateFileName to "NONAME3"

// Project Object Structure
//   oJcopercp_sl is a dbModalPanel
//     Jcdept_DD is a DataDictionary
//     Jccntr_DD is a DataDictionary
//     Jcoper_DD is a DataDictionary
//     oSelList is a dbList
//     oOK_bn is a Button
//     oCancel_bn is a Button
//     oSearch_bn is a cPTButton

// Register all objects
Register_Object Jccntr_DD
Register_Object Jcdept_DD
Register_Object Jcoper_DD
Register_Object oCancel_bn
Register_Object oJcopercp_sl
Register_Object oOK_bn
Register_Object oSearch_bn
Register_Object oSelList

//AB-IgnoreStart
Use dfdbmdpn.pkg
Use DataDict.pkg
Use dfSelLst.pkg
Use Windows.pkg
//AB-IgnoreEnd


//AB-IgnoreStart
Use JCDEPT.DD
Use JCCNTR.DD
Use JCOPER.DD
//AB-IgnoreEnd


Object oJcopercp_sl is a dbModalPanel
    Set Label to "Alternate Trigger Standards"
    Set Location to 4 5
    // Visual DataFlex 14.0 Client Size Adjuster, modified May 23, 2008: 14:35:46
//    Set Size to 149 238
    Set Size to 133 233
    // Visual DataFlex 14.0 Client Size Adjuster, modified May 23, 2008: 14:35:46
//    Set piMaxSize to 360 525
    Set piMaxSize to 344 520
    // Visual DataFlex 14.0 Client Size Adjuster, modified May 23, 2008: 14:35:46
//    Set piMinSize to 100 200
    Set piMinSize to 84 195

    //AB-DDOStart

    Object Jcdept_DD is a Jcdept_DataDictionary
    End_Object    // Jcdept_DD

    Object Jccntr_DD is a Jccntr_DataDictionary
        Set DDO_Server to Jcdept_DD
    End_Object    // Jccntr_DD

    Object Jcoper_DD is a Jcoper_DataDictionary
        Set DDO_Server to Jccntr_DD

        //AB-StoreStart
        //
        function MeetsConstraints returns integer
            string sOptype
            if "T" in Jcoper.Calc_flags function_return TRUE
            else function_return FALSE
        end_function // MeetsConstraints
        //
        
        begin_constraints
            constrain Jcoper.Est_std eq "Y"
            constrain Jcoper as (MeetsConstraints(self))
        end_constraints
        //
        //AB-StoreEnd

    End_Object    // Jcoper_DD

    Set Main_DD to Jcoper_DD
    Set Server to Jcoper_DD

    //AB-DDOEnd

    Object oSelList is a dbList
        //AB-StoreTopStart
        Set peDisabledTextColor to clGreen
        //AB-StoreTopEnd
        Set Main_File to Jcoper.File_Number
        Set Size to 101 224
        Set Location to 4 4
        Set GridLine_Mode to Grid_Visible_Both
        Set peAnchors to anAll
        Set peResizeColumn to rcNone

        Begin_Row
            Entry_Item Jcoper.Opcode
            Entry_Item Jccntr.Nickname
            Entry_Item Jcoper.Name
        End_Row

        Set Form_Width    item 0 to 37
        Set Header_Label  item 0 to "CC/OP#"
        
        Set Form_Width    item 1 to 51
        Set Header_Label  item 1 to "Cost Center"
        
        Set Form_Width    item 2 to 126
        Set Header_Label  item 2 to "Description"
        
    End_Object    // oSelList

    Object oOK_bn is a Button
        Set Label to "&OK"
        Set Location to 111 124
        Set peAnchors to anBottomRight

        //AB-StoreStart
        Procedure OnClick
            Send OK To oSelList
        End_Procedure
        //AB-StoreEnd

    End_Object    // oOK_bn

    Object oCancel_bn is a Button
        Set Label to "&Cancel"
        Set Location to 111 178
        Set peAnchors to anBottomRight

        //AB-StoreStart
        Procedure OnClick
            Send Cancel To oSelList
        End_Procedure
        //AB-StoreEnd

    End_Object    // oCancel_bn

    Object oSearch_bn is a cPTButton
        Set Label to "&Search..."
        Set Location to 115 236

        //AB-StoreStart
        Procedure OnClick
            Send Search To oSelList
        End_Procedure
        //AB-StoreEnd

    End_Object    // oSearch_bn


    //AB-StoreStart
    On_Key Key_Alt+Key_O Send KeyAction To oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction To oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction To oSearch_bn
    //AB-StoreEnd

End_Object    // oJcopercp_sl

//AB/ End_Object    // prj

