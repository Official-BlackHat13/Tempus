// C:\Development Projects\VDF18.2 Workspaces\Tempus\AppSrc\WebAppUserRightsEntry.vw
// WebAppUserRightsEntry
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use cWebAppUserRightsGlblDataDictionary.dd
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg

ACTIVATE_VIEW Activate_oWebAppUserRightsEntry FOR oWebAppUserRightsEntry
Object oWebAppUserRightsEntry is a cGlblDbView
    Set Location to 5 5
    Set Size to 193 354
    Set Label To "WebAppUserRightsEntry"
    Set Border_Style to Border_Thick


    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
    End_Object 

    Set Main_DD To oWebAppUserRights_DD
    Set Server  To oWebAppUserRights_DD

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 186 346
        Set Location to 3 4
        Set peAnchors to anAll
        Set Ordering to 1

        Object oWebAppUserRights_RightLevel is a cDbCJGridColumn
            Entry_Item WebAppUserRights.RightLevel
            Set piWidth to 79
            Set psCaption to "Right Level"
        End_Object

        Object oWebAppUserRights_Description is a cDbCJGridColumn
            Entry_Item WebAppUserRights.Description
            Set piWidth to 526
            Set psCaption to "Description"
        End_Object
    End_Object


End_Object 
