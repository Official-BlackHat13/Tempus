// C:\Development Projects\VDF18.2 Workspaces\Tempus\AppSrc\Terms.vw
// Terms
//

Use cGlblDbView.pkg
Use cGlblDbComboForm.pkg

Use cTermsGlblDataDictionary.dd
Use cDbCJGrid.pkg
Use Windows.pkg
Use cdbCJGridColumn.pkg

Use QBDataUpdateProcess.bp

ACTIVATE_VIEW Activate_oTerms FOR oTerms
Object oTerms is a cGlblDbView
    Set Location to 5 5
    Set Size to 268 536
    Set Label To "Terms"
    Set Border_Style to Border_Thick


    Object oTerms_DD is a cTermsGlblDataDictionary
    End_Object 

    Set Main_DD To oTerms_DD
    Set Server  To oTerms_DD

    Object oTermsDbCJGrid is a cDbCJGrid
        Set Size to 241 519
        Set Location to 4 6
        Set peAnchors to anAll

        Object oTerms_Terms is a cDbCJGridColumn
            Entry_Item Terms.Terms
            Set piWidth to 363
            Set psCaption to "Terms"
        End_Object

        Object oTerms_QBTermsRefListId is a cDbCJGridColumn
            Entry_Item Terms.QBTermsRefListId
            Set piWidth to 271
            Set psCaption to "QBTermsRefListId"
        End_Object

        Object oTerms_DueDays is a cDbCJGridColumn
            Entry_Item Terms.DueDays
            Set piWidth to 64
            Set psCaption to "DueDays"
        End_Object

        Object oTerms_DiscountDay is a cDbCJGridColumn
            Entry_Item Terms.DiscountDay
            Set piWidth to 65
            Set psCaption to "DiscountDay"
        End_Object

        Object oTerms_DiscountPercent is a cDbCJGridColumn
            Entry_Item Terms.DiscountPercent
            Set piWidth to 104
            Set psCaption to "DiscountPercent"
        End_Object

        Object oTerms_Status is a cDbCJGridColumn
            Entry_Item Terms.Status
            Set piWidth to 41
            Set psCaption to "Status"
        End_Object
    End_Object

    Object oSyncQB is a Button
        Set Size to 14 82
        Set Location to 249 443
        Set Label to 'Sync from QB'
        Set peAnchors to anBottomRight
    
        // fires when the button is clicked
        Procedure OnClick
            Send DoUpdateTerms of oQBDataUpdateProcess
            Send MoveToFirstRow of oTermsDbCJGrid
        End_Procedure
    
    End_Object


End_Object 
