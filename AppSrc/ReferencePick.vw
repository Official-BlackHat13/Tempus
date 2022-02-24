Use Windows.pkg
Use DFClient.pkg
Use cReferencGlblDataDictionary.dd
Use cDbCJGrid.pkg
Use cCJGrid.pkg

Deferred_View Activate_oReferencePick for ;
Object oReferencePick is a dbView
    Object oReferenc_DD is a cReferencGlblDataDictionary
    End_Object

    Set Main_DD to oReferenc_DD
    Set Server to oReferenc_DD

    Set Border_Style to Border_Thick
    Set Label to "Reference Entry/Edit"
    Set Size to 347 721
    Set Location to 14 52

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 298 637
        Set Location to 23 43

        
        Object oReferenc_Company is a cDbCJGridColumn
            Entry_Item Referenc.Company
            Set piWidth to 335
            Set psCaption to "Company"
        End_Object

        Object oReferenc_Name is a cDbCJGridColumn
            Entry_Item Referenc.Name
            Set piWidth to 193
            Set psCaption to "Name"
        End_Object

        Object oReferenc_Phone is a cDbCJGridColumn
            Entry_Item Referenc.Phone
            Set piWidth to 89
            Set psCaption to "Phone"
        End_Object

        Object oReferenc_Email is a cDbCJGridColumn
            Entry_Item Referenc.Email
            Set piWidth to 338
            Set psCaption to "Email"
        End_Object
    End_Object

Cd_End_Object
