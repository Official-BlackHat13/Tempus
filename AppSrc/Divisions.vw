Use Windows.pkg
Use DFClient.pkg
Use cProjectDataDictionary.dd
Use cGlblDbForm.pkg

Deferred_View Activate_oDivisions for ;
Object oDivisions is a dbView
    Object oProject_DD is a cProjectDataDictionary
    End_Object

    Set Main_DD to oProject_DD
    Set Server to oProject_DD

    Set Border_Style to Border_Thick
    Set Label to "Division Entry/Edit"
    Set Size to 100 247
    Set Location to 2 2

    Object oProject_ProjectId is a cGlblDbForm
        Entry_Item Project.ProjectId
        Set Location to 22 66
        Set Size to 13 54
        Set Label to "Division #:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oProject_Description is a cGlblDbForm
        Entry_Item Project.Description
        Set Location to 42 66
        Set Size to 13 138
        Set Label to "Name:"
         Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

Cd_End_Object
