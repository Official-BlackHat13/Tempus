// Z:\Tempus\AppSrc\RequestTypeEntry.vw
// RequestTypeEntry
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use cReqtypesDataDictionary.dd

ACTIVATE_VIEW Activate_oRequestTypeEntry FOR oRequestTypeEntry
Object oRequestTypeEntry is a cGlblDbView
    Set Location to 5 5
    Set Size to 38 421
    Set Label To "RequestTypeEntry"
    Set Border_Style to Border_Thick


    Object oReqtypes_DD is a cReqtypesDataDictionary
    End_Object // oReqtypes_DD

    Set Main_DD To oReqtypes_DD
    Set Server  To oReqtypes_DD



    Object oReqtypesReqtypesCode is a cGlblDbForm
        Entry_Item Reqtypes.ReqtypesCode
        Set Size to 13 96
        Set Location to 5 50
        Set peAnchors to anLeftRight
        Set Label to "ReqtypesCode"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 45
        Set Label_row_Offset to 0
    End_Object // oReqtypesReqtypesCode

    Object oReqtypesDescription is a cGlblDbForm
        Entry_Item Reqtypes.Description
        Set Size to 13 366
        Set Location to 20 50
        Set peAnchors to anLeftRight
        Set Label to "Description"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 45
        Set Label_row_Offset to 0
    End_Object // oReqtypesDescription


End_Object // oRequestTypeEntry
