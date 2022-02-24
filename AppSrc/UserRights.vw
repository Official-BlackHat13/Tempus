// C:\Development Projects\VDF18.2 Workspaces\Tempus\AppSrc\UserRights.vw
// UserRights
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use cUserRightsGlblDataDictionary.dd
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg

ACTIVATE_VIEW Activate_oUserRights FOR oUserRights
Object oUserRights is a cGlblDbView
    Set Location to 5 5
    Set Size to 150 312
    Set Label To "UserRights"
    Set Border_Style to Border_Thick


    Object oUserRights_DD is a cUserRightsGlblDataDictionary
    End_Object 

    Set Main_DD To oUserRights_DD
    Set Server  To oUserRights_DD

    Object oUserRightsGrid is a cDbCJGrid
        Set Size to 143 303
        Set Location to 4 5
        Set peAnchors to anAll
        Set Ordering to 1

        Object oUserRights_EditLevel is a cDbCJGridColumn
            Entry_Item UserRights.EditLevel
            Set piWidth to 99
            Set psCaption to "EditLevel"
            Set pbComboButton to True
        End_Object

        Object oUserRights_Discription is a cDbCJGridColumn
            Entry_Item UserRights.Discription
            Set piWidth to 450
            Set psCaption to "Discription"
        End_Object
    End_Object


End_Object 
