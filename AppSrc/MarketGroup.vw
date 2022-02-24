// Z:\VDF17.0 Workspaces\Tempus\AppSrc\MarketGroup.vw
// MarketGroup
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use cMarketGroupGlblDataDictionary.dd
Use cDbCJGrid.pkg

ACTIVATE_VIEW Activate_oMarketGroup FOR oMarketGroup
Object oMarketGroup is a cGlblDbView
    Set Location to 5 5
    Set Size to 208 365
    Set Label to "Marketing Groups"
    Set Border_Style to Border_Thick


    Object oMarketGroup_DD is a cMarketGroupGlblDataDictionary
    End_Object // oMarketGroup_DD

    Set Main_DD To oMarketGroup_DD
    Set Server  To oMarketGroup_DD

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 196 355
        Set Location to 5 4
        Set pbAllowDeleteRow to False

        Object oMarketGroup_MktGroupIdno is a cDbCJGridColumn
            Entry_Item MarketGroup.MktGroupIdno
            Set piWidth to 72
            Set psCaption to "MktGroupIdno"
            Set Prompt_Button_Mode to PB_PromptOff
        End_Object

        Object oMarketGroup_GroupName is a cDbCJGridColumn
            Entry_Item MarketGroup.GroupName
            Set piWidth to 360
            Set psCaption to "GroupName"
            Set Prompt_Button_Mode to PB_PromptOff
        End_Object
    End_Object


End_Object // oMarketGroup
