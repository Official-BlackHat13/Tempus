// Z:\VDF17.0 Workspaces\Tempus\AppSrc\WorkType.vw
// WorkType
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cTextEdit.pkg
Use Windows.pkg
Use cDbCJGrid.pkg
Use dfSelLst.pkg
Use dfTable.pkg

Use Employee.sl
Use dfTabDlg.pkg
Use cCJGrid.pkg
Use cDivisionMgrGlblDataDictionary.dd
Use cWorkTypeGlblDataDictionary.dd
Use cdbCJGridColumn.pkg

Activate_View Activate_oWorkTypeDivisions for oWorkTypeDivisions
Object oWorkTypeDivisions is a cGlblDbView
   
    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Set Main_DD to oWorkType_DD
    Set Server to oWorkType_DD

    Set Location to 5 4
    Set Size to 185 560
    Set Label to "Work Type / Divisions"
    Set Border_Style to Border_Thick
    Set piMaxSize to 185 560
    Set piMinSize to 185 560

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 179 555
        Set Location to 4 3

        Object oWorkType_WorkTypeId is a cDbCJGridColumn
            Entry_Item WorkType.WorkTypeId
            Set piWidth to 73
            Set psCaption to "Idno"
        End_Object

        Object oWorkType_Description is a cDbCJGridColumn
            Entry_Item WorkType.Description
            Set piWidth to 286
            Set psCaption to "Description"
        End_Object

        Object oWorkType_ShortCut is a cDbCJGridColumn
            Entry_Item WorkType.ShortCut
            Set piWidth to 19
            Set psCaption to "ShortCut"
        End_Object

        Object oWorkType_Sequence is a cDbCJGridColumn
            Entry_Item WorkType.Sequence
            Set piWidth to 51
            Set psCaption to "Seq."
        End_Object

        Object oDivisionMgr_DivMgrIdno is a cDbCJGridColumn
            Entry_Item DivisionMgr.DivMgrIdno
            Set piWidth to 72
            Set psCaption to "Mgr Idno"
        End_Object

        Object oWorkType_ManagedBy is a cDbCJGridColumn
            Set piWidth to 103
            Set psCaption to "ManagedBy"
            Set pbEditable to False

            Procedure OnSetCalculatedValue String  ByRef sValue
                Forward Send OnSetCalculatedValue (&sValue)
                Move (Trim(DivisionMgr.FirstName)*Trim(DivisionMgr.LastName)) to sValue
            End_Procedure
        End_Object

        Object oWorkType_QBItemRefID is a cDbCJGridColumn
            Entry_Item WorkType.QBItemRefID
            Set piWidth to 288
            Set psCaption to "QBItemRefID"
        End_Object

        Object oWorkType_ChangedFlag is a cDbCJGridColumn
            Entry_Item WorkType.ChangedFlag
            Set piWidth to 25
            Set psCaption to "ChangedFlag"
        End_Object

        Object oWorkType_HourlyCost is a cDbCJGridColumn
            Entry_Item WorkType.HourlyCost
            Set piWidth to 80
            Set psCaption to "HourlyCost"
        End_Object
    End_Object

End_Object
