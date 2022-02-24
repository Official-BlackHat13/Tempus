// MarketGroup.sl
// MarketGroup Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cMarketGroupGlblDataDictionary.dd

Object MarketGroup_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 218
    Set Label To "MarketGroup Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False
    
    Property Boolean pbSelected
    Property Integer piSelected


    Object oMarketGroup_DD is a cMarketGroupGlblDataDictionary
    End_Object // oMarketGroup_DD

    Set Main_DD To oMarketGroup_DD
    Set Server  To oMarketGroup_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 208
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "MarketGroup_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oMarketGroup_GroupName is a cDbCJGridColumn
            Entry_Item MarketGroup.GroupName
            Set piWidth to 262
            Set psCaption to "Group Name"
        End_Object // oMarketGroup_GroupName


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 55
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 109
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
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


    Function SelectedClassCode Integer iClassCode String ByRef sClassDescription Returns Integer
        Set pbSelected to True
        Set piSelected to iClassCode
        //
        If (iClassCode <> 0) Begin
            Send Clear of oMarketGroup_DD
            Move iClassCode to MarketGroup.MktGroupIdno
            Send Find of oMarketGroup_DD EQ 1
        End
        
        Set Move_Value_Out_State of oSelList to False
        //
        Send Popup_Modal
        //
        Set Move_Value_Out_State of oSelList to True
        
        Set pbSelected to False
        Function_Return (piSelected(Self))
    End_Function


End_Object // MarketGroup_sl
