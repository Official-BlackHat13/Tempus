//AB/ Project Cost Center Lookup
//AB/ Object prj is a Lookup_Project
    //AB/ Set ProjectName to "Cost Center Lookup"
    //AB/ Set ProjectFileName to "JCCNTRVN.SL"

// Project Object Structure
//   LookUp is a dbModalPanel
//     Jcdept_DD is a DataDictionary
//     Jccntr_DD is a DataDictionary
//     oJccntr_CClist is a dbList
//     oOK_bn is a cPTButton
//     oCancel_bn is a cPTButton
//     oSearch_bn is a cPTButton

// Register all objects
Register_Object Jccntr_DD
Register_Object Jcdept_DD
Register_Object LookUp
Register_Object oCancel_bn
Register_Object oJccntr_CClist
Register_Object oOK_bn
Register_Object oSearch_bn

//AB-IgnoreStart
Use dfdbmdpn.pkg
Use DataDict.pkg
Use dfSelLst.pkg
Use Windows.pkg
//AB-IgnoreEnd


//AB-IgnoreStart
Use JCDEPT.DD
Use JCCNTR.DD
//AB-IgnoreEnd


CD_Popup_Object LookUp is a dbModalPanel
    Set Label to "Cost Centers List"
    Set Location to 4 5
    // Visual DataFlex 14.0 Client Size Adjuster, modified May 23, 2008: 14:35:50
//    Set Size to 146 297
    Set Size to 130 292
    // Visual DataFlex 14.0 Client Size Adjuster, modified May 23, 2008: 14:35:50
//    Set piMaxSize to 360 525
    Set piMaxSize to 344 520
    // Visual DataFlex 14.0 Client Size Adjuster, modified May 23, 2008: 14:35:50
//    Set piMinSize to 100 200
    Set piMinSize to 84 195

    //AB-DDOStart

    Object Jcdept_DD is a Jcdept_DataDictionary
    End_Object    // Jcdept_DD

    Object Jccntr_DD is a Jccntr_DataDictionary
        Set DDO_Server to Jcdept_DD
    End_Object    // Jccntr_DD

    Set Main_DD to Jccntr_DD
    Set Server to Jccntr_DD

    //AB-DDOEnd

    Object oJccntr_CClist is a dbList
        //AB-StoreTopStart
        Set peDisabledTextColor to clGreen
        //AB-StoreTopEnd
        Set Main_File to Jccntr.File_Number
        Set Ordering to 1
        Set Size to 100 281
        Set Location to 6 6
        Set GridLine_Mode to Grid_Visible_Both
        Set peAnchors to anAll
        Set peResizeColumn to rcNone

        Begin_Row
            Entry_Item Jccntr.Idno
            Entry_Item Jccntr.Name
            Entry_Item Jccntr.Nickname
        End_Row

        Set Form_Width    item 0 to 24
        Set Header_Label  item 0 to "Idno"
        
        Set Form_Width    item 1 to 200
        Set Header_Label  item 1 to "Name"
        
        Set Form_Width    item 2 to 50
        Set Header_Label  item 2 to "Nickname"
        
    End_Object    // oJccntr_CClist

    Object oOK_bn is a cPTButton
        Set Label to "&OK"
        Set Location to 110 126
        Set peAnchors to anBottomRight

        //AB-StoreStart
        Procedure OnClick
            Send OK To oJccntr_CClist
        End_Procedure
        //AB-StoreEnd

    End_Object    // oOK_bn

    Object oCancel_bn is a cPTButton
        Set Label to "&Cancel"
        Set Location to 110 181
        Set peAnchors to anBottomRight

        //AB-StoreStart
        Procedure OnClick
            Send Cancel To oJccntr_CClist
        End_Procedure
        //AB-StoreEnd

    End_Object    // oCancel_bn

    Object oSearch_bn is a cPTButton
        Set Label to "&Search..."
        Set Location to 110 236
        Set peAnchors to anBottomRight

        //AB-StoreStart
        Procedure OnClick
            Send Search To oJccntr_CClist
        End_Procedure
        //AB-StoreEnd

    End_Object    // oSearch_bn


    //AB-StoreStart
    On_Key Key_Alt+Key_O Send KeyAction To oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction To oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction To oSearch_bn
    //AB-StoreEnd

CD_End_Object    // LookUp

//AB/ End_Object    // prj

