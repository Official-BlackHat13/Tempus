// C:\VDF14.0 Workspaces\InterstateCompanies\AppSrc\Crystal.vw
// Crystal Reports
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use Crystal.DD

ACTIVATE_VIEW Activate_oCrystal FOR oCrystal
Object oCrystal Is A cGlblDbView
    Set Location to 17 31
    Set Size to 75 310
    Set Label To "Crystal Reports"
    Set Border_Style to Border_Thick
    Set piMinSize to 75 310


    Object oCrystal_DD Is A Crystal_DataDictionary
    End_Object // oCrystal_DD

    Set Main_DD To oCrystal_DD
    Set Server  To oCrystal_DD



    Object oCrystalDescription Is A cGlblDbForm
        Entry_Item Crystal.Description
        Set Size to 13 200
        Set Location to 10 60
        Set peAnchors to anLeftRight
        Set Label to "Description"
        Set Label_Justification_mode to JMode_Right
        Set Label_Col_Offset to 2
        Set Label_row_Offset to 0
    End_Object // oCrystalDescription

    Object oCrystalReportname Is A cGlblDbForm
        Entry_Item Crystal.FileName
        Set Size to 13 200
        Set Location to 30 60
        Set peAnchors to anLeftRight
        Set Label to "File Name"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 41
        Set Label_row_Offset to 0

        Procedure Next
            Send Request_Save
            Forward Send Next
        End_Procedure
    End_Object // oCrystalReportname


End_Object // oCrystal
