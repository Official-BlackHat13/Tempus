Use Windows.pkg
Use DFClient.pkg
Use cDbCJGrid.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use MastOps.DD
Use Opers.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd

Deferred_View Activate_oMastOpsSeq for ;
Object oMastOpsSeq is a dbView
    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
        Procedure OnConstrain
            Constrain MastOps.ActivityType eq "Pavement Mnt."
        End_Procedure
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set Constrain_file to MastOps.File_number
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Set Main_DD to oMastOps_DD
    Set Server to oMastOps_DD

    Set Border_Style to Border_Thick
    Set Size to 324 559
    Set Location to 30 229

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 175 443
        Set Location to 28 60

        Object oMastOps_MastOpsIdno is a cDbCJGridColumn
            Entry_Item MastOps.MastOpsIdno
            Set piWidth to 80
            Set psCaption to "MastOpsIdno"
        End_Object

        Object oMastOps_Name is a cDbCJGridColumn
            Procedure HeaderReorder Integer iCol
             Send HeaderReorder iCol
            End_Procedure  



            Entry_Item MastOps.Name
            Set piWidth to 314
            Set psCaption to "Name"
        End_Object

        Object oMastOps_ActivityType is a cDbCJGridColumn
            Entry_Item MastOps.ActivityType
            Set piWidth to 161
            Set psCaption to "ActivityType"
            Set pbComboButton to True
        End_Object

        Object oMastOps_DisplaySequence is a cDbCJGridColumn
            Entry_Item MastOps.DisplaySequence
            Set piWidth to 109
            Set psCaption to "DisplaySequence"
        End_Object
    End_Object

Cd_End_Object
