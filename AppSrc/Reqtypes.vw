// C:\VDF15.0 Workspaces\Tempus\AppSrc\Reqtypes.vw
// Request Types Maintenance
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use cReqtypesDataDictionary.dd

ACTIVATE_VIEW Activate_oReqtypes FOR oReqtypes
Object oReqtypes Is A cGlblDbView
    Set Location to 52 69
    Set Size to 60 249
    Set Label To "Request Types Maintenance"
    Set Border_Style to Border_Thick


    Object oReqtypes_DD Is A cReqtypesDataDictionary
    End_Object // oReqtypes_DD

    Set Main_DD To oReqtypes_DD
    Set Server  To oReqtypes_DD



    Object oReqtypesReqtypescode Is A cGlblDbForm
        Entry_Item Reqtypes.Reqtypescode
        Set Size to 13 96
        Set Location to 5 42
        Set peAnchors to anLeftRight
        Set Label to "Code"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 37
        Set Label_row_Offset to 0
    End_Object // oReqtypesReqtypescode

    Object oReqtypesDescription Is A cGlblDbForm
        Entry_Item Reqtypes.Description
        Set Size to 13 195
        Set Location to 20 42
        Set peAnchors to anLeftRight
        Set Label to "Description"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 37
        Set Label_row_Offset to 0
    End_Object // oReqtypesDescription


End_Object // oReqtypes
