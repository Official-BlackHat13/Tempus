Use Windows.pkg
Use DFClient.pkg
Use cReferencGlblDataDictionary.dd
Use cGlblDbForm.pkg

Deferred_View Activate_oReferenceEntry for ;
Object oReferenceEntry is a dbView
    Object oReferenc_DD is a cReferencGlblDataDictionary
    End_Object

    Set Main_DD to oReferenc_DD
    Set Server to oReferenc_DD

    Set Border_Style to Border_Thick
    Set Label to "Reference Entry/Edit"
    Set Size to 157 414
    Set Location to 20 24

    Object oReferenc_ReferenceIdno is a cGlblDbForm
        Entry_Item Referenc.ReferenceIdno
        Set Location to 17 75
        Set Size to 13 54
        Set Label to "ReferenceIdno:"
    End_Object

    Object oReferenc_Company is a cGlblDbForm
        Entry_Item Referenc.Company
        Set Location to 36 75
        Set Size to 13 186
        Set Label to "Company:"
    End_Object

    Object oReferenc_Name is a cGlblDbForm
        Entry_Item Referenc.Name
        Set Location to 55 75
        Set Size to 13 186
        Set Label to "Name:"
    End_Object

    Object oReferenc_Title is a cGlblDbForm
        Entry_Item Referenc.Title
        Set Location to 76 75
        Set Size to 13 306
        Set Label to "Title:"
    End_Object

    Object oReferenc_Phone is a cGlblDbForm
        Entry_Item Referenc.Phone
        Set Location to 96 75
        Set Size to 13 66
        Set Label to "Phone:"
    End_Object

    Object oReferenc_Email is a cGlblDbForm
        Entry_Item Referenc.Email
        Set Location to 117 75
        Set Size to 13 306
        Set Label to "Email:"
    End_Object

Cd_End_Object
