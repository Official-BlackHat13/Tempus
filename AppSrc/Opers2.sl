// Opers2.sl
// Opers Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use MastOps.DD
Use Opers.DD

CD_Popup_Object Opers2_sl is a cGlblDbModalPanel
    Set Location to 73 133
    Set Size to 134 427
    Set Label To "Opers2 Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD is a Areas_DataDictionary
    End_Object // oAreas_DD

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
    End_Object // oLocation_DD

    Object oMastOps_DD is a Mastops_DataDictionary
    End_Object // oMastOps_DD

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oLocation_DD
        Set DDO_Server to oMastOps_DD
        Set Constrain_File to Location.File_Number
        Procedure OnConstrain
            Constrain Opers.ActivityType eq "Snow Removal"   
        End_Procedure   
        
    End_Object // oOpers_DD

    Set Main_DD To oOpers_DD
    Set Server  To oOpers_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 417
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Opers2_sl_oSelList"
        Set Ordering to 5
        Set pbAutoServer to False

        Object oOpers_DisplaySequence is a cDbCJGridColumn
            Entry_Item Opers.DisplaySequence
            Set piWidth to 98
            Set psCaption to "Sequence"
        End_Object // oOpers_DisplaySequence

        Object oMastOps_MastOpsIdno is a cDbCJGridColumn
            Entry_Item MastOps.MastOpsIdno
            Set piWidth to 102
            Set psCaption to "MastOp"
        End_Object

        Object oOpers_Name is a cDbCJGridColumn
            Entry_Item Opers.Name
            Set piWidth to 425
            Set psCaption to "Description"
        End_Object

        Object oOpers_ActivityType is a cDbCJGridColumn
            Entry_Item Opers.ActivityType
            Set piWidth to 207
            Set psCaption to "ActivityType"
            Set pbComboButton to True
        End_Object


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 264
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 318
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 372
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Opers2_sl
