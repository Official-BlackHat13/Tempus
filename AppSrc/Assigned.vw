// C:\VDF15.0 Workspaces\Tempus\AppSrc\Assigned.vw
// Assigned-To Standards
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cGlblDbComboForm.pkg

Use cAssignedDataDictionary.dd

ACTIVATE_VIEW Activate_oAssigned FOR oAssigned
Object oAssigned Is A cGlblDbView
    Set Location to 5 5
    Set Size to 53 293
    Set Label To "Assigned-To Standards"
    Set Border_Style to Border_Thick


    Object oAssigned_DD Is A cAssignedDataDictionary
    End_Object // oAssigned_DD

    Set Main_DD To oAssigned_DD
    Set Server  To oAssigned_DD



    Object oAssignedAssignedcode Is A cGlblDbForm
        Entry_Item Assigned.Assignedcode
        Set Size to 13 95
        Set Location to 5 42
        Set peAnchors to anLeftRight
        Set Label to "Code"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 37
        Set Label_row_Offset to 0
    End_Object // oAssignedAssignedcode

    Object oAssignedDescription Is A cGlblDbForm
        Entry_Item Assigned.Description
        Set Size to 13 246
        Set Location to 20 42
        Set peAnchors to anLeftRight
        Set Label to "Description"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 37
        Set Label_row_Offset to 0
    End_Object // oAssignedDescription

    Object oAssignedStatus Is A cGlblDbComboForm
        Entry_Item Assigned.Status
        Set Size to 13 95
        Set Location to 35 42
        Set peAnchors to anLeftRight
        Set Label to "Status"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 37
        Set Label_row_Offset to 0
    End_Object // oAssignedStatus


End_Object // oAssigned
