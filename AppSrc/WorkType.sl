// WorkType.sl
// WorkType Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cWorkTypeGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd

CD_Popup_Object WorkType_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 170
    Set Label To "WorkType Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object


    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object // oWorkType_DD

    Set Main_DD To oWorkType_DD
    Set Server  To oWorkType_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 160
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "WorkType_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oWorkType_Description is a cDbCJGridColumn
            Entry_Item WorkType.Description
            Set piWidth to 262
            Set psCaption to "Description"
        End_Object // oWorkType_Description


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 7
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 61
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 115
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // WorkType_sl
