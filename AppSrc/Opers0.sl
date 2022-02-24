// Opers.sl
// Operations Lookup List

Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Location.DD
Use MastOps.DD
Use Opers.DD

CD_Popup_Object Opers_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 242
    Set Label To "Operations Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oCustomer_DD Is A Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oLocation_DD Is A Location_DataDictionary
        Set DDO_Server To oCustomer_DD
    End_Object // oLocation_DD

    Object oMastops_DD Is A Mastops_DataDictionary
    End_Object // oMastops_DD

    Object oOpers_DD is a Opers_DataDictionary
        Set Constrain_file to Location.File_number
        Set DDO_Server to oCustomer_DD
        Set DDO_Server to oLocation_DD
        Set DDO_Server to oMastops_DD
    End_Object // oOpers_DD

    Set Main_DD To oOpers_DD
    Set Server  to oOpers_DD
    


    Object oSelList Is A cGlblDbList
        Set Size to 105 233
        Set Location to 4 5
        Set peAnchors to anBottomLeft
        Set Main_File to Opers.File_Number
        Set Ordering to 5
        Set peResizeColumn to rcAll
        //Set Auto_Server_State to True
        Set pbHeaderTogglesDirection to True
    
        Begin_row
            Entry_Item MastOps.DisplaySequence
            Entry_Item Opers.Opersidno
            Entry_Item Opers.Name
        End_row

        Set Header_Justification_Mode 0 to JMode_Right

        Set Form_Width 1 to 48
        Set Header_Label 1 to "Opers Idno"

        Set Form_Width 2 to 142
        Set Header_Label 2 to "Name"
        Set Form_Width 0 to 32
        Set Header_Label 0 to "Seq"
        Set Auto_Column_State to False

    End_Object // oSelList

    Object oOk_bn Is A cGlblButton
        Set Label to "&Ok"
        Set Location to 115 55
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 109
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A cGlblButton
        Set Label to "&Search..."
        Set Location to 115 163
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Opers_sl
