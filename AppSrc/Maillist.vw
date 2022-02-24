// C:\VDF14.1 Workspaces\Tempus\AppSrc\Maillist.vw
// Mailing List Maintenance
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use cMaillistDataDictionary.dd
Use cGlblDbCheckBox.pkg
Use Windows.pkg

ACTIVATE_VIEW Activate_oMaillist FOR oMaillist
Object oMaillist Is A cGlblDbView
    Set Location to 5 5
    Set Size to 67 308
    Set Label To "Mailing List Maintenance"
    Set Border_Style to Border_Thick
    Set piMinSize to 67 308


    Object oMaillist_DD Is A cMaillistDataDictionary
    End_Object // oMaillist_DD

    Set Main_DD To oMaillist_DD
    Set Server  To oMaillist_DD



    Object oMaillistListcode Is A cGlblDbForm
        Entry_Item Maillist.Listcode
        Set Size to 13 96
        Set Location to 10 42
        Set peAnchors to anLeftRight
        Set Label to "Listcode"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 37
        Set Label_row_Offset to 0
    End_Object // oMaillistListcode

    Object oMaillistDescription Is A cGlblDbForm
        Entry_Item Maillist.Description
        Set Size to 13 246
        Set Location to 25 42
        Set peAnchors to anLeftRight
        Set Label to "Description"
        Set Label_Justification_mode to jMode_Left
        Set Label_Col_Offset to 37
        Set Label_row_Offset to 0
    End_Object // oMaillistDescription

    Object oMaillist_AutoCreateFlag is a cGlblDbCheckBox
        Entry_Item Maillist.AutoCreateFlag
        Set Location to 42 42
        Set Size to 10 60
        Set Label to "AutoCreateFlag"
    End_Object

    Object oMailMergeButton is a Button
        Set Size to 14 159
        Set Location to 43 129
        Set Label to "Generate Mail Merged Letter to all Contacts"
    
        Procedure OnClick
            Send DoMailMerge
        End_Procedure
    End_Object

    Procedure DoMailMerge
        If (HasRecord(oMaillist_DD)) Begin
            Send DoAllContactsOnMailingList of WordDocumentsProcess (Trim(Maillist.ListCode))
        End
    End_Procedure

End_Object // oMaillist
