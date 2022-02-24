Use Windows.pkg
Use DFClient.pkg
Use SalesRep.DD
Use cQuotaGlblDataDictionary.dd
Use cQuota_DtlGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use dfTable.pkg

Deferred_View Activate_oQuotaEntryEdit for ;
Object oQuotaEntryEdit is a dbView
    Set Size to 242 345
    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oQuota_DD is a cQuotaGlblDataDictionary
        Set DDO_Server to oSalesRep_DD
    End_Object

    Object oQuota_Dtl_DD is a cQuota_DtlGlblDataDictionary
        Set DDO_Server to oQuota_DD
        Set Constrain_File to Quota.File_Number
    End_Object

    Set Main_DD to oQuota_Dtl_DD
    Set Server to oQuota_Dtl_DD

    Set Border_Style to Border_Thick
    Set Size to 260 587
    Set Location to 2 2
    
    Object oQuota_Quota_Idno is a cGlblDbForm
        Entry_Item Quota.Quota_Idno
        Set Location to 14 72
        Set Size to 13 54
        Set Label to "Quota ID#:"
    End_Object

    Object oQuota_SalesYear is a cGlblDbForm      //////////////////cdbszDatePicker
        Entry_Item Quota.SalesYear
        Set Location to 47 72
        Set Size to 13 66
        Set Label to "Sales Year:"
    End_Object


    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 159 539
        Set Location to 70 24

        Object oQuota_Dtl_Quota_Mo_Yr is a cDbCJGridColumn
            Entry_Item Quota_Dtl.Quota_Mo_Yr
            Set piWidth to 129
            Set psCaption to "Month"
            Set pbComboButton to True
        End_Object

        Object oQuota_Dtl_Asphalt is a cDbCJGridColumn
            Entry_Item Quota_Dtl.Asphalt
            Set piWidth to 95
            Set psCaption to "Asphalt"
        End_Object

        Object oQuota_Dtl_Concrete is a cDbCJGridColumn
            Entry_Item Quota_Dtl.Concrete
            Set piWidth to 97
            Set psCaption to "Concrete"
        End_Object

        Object oQuota_Dtl_Excavation is a cDbCJGridColumn
            Entry_Item Quota_Dtl.Excavation
            Set piWidth to 97
            Set psCaption to "Excavation"
        End_Object

        Object oQuota_Dtl_Snow is a cDbCJGridColumn
            Entry_Item Quota_Dtl.Snow
            Set piWidth to 97
            Set psCaption to "Snow"
        End_Object

        Object oQuota_Dtl_Sweep is a cDbCJGridColumn
            Entry_Item Quota_Dtl.Sweep
            Set piWidth to 97
            Set psCaption to "Sweep"
        End_Object

        Object oQuota_Dtl_Marking is a cDbCJGridColumn
            Entry_Item Quota_Dtl.Marking
            Set piWidth to 98
            Set psCaption to "Marking"
        End_Object

        Object oQuota_Dtl_Other is a cDbCJGridColumn
            Entry_Item Quota_Dtl.Other
            Set piWidth to 98
            Set psCaption to "Other"
        End_Object
    End_Object

    Object oSalesRep_LastName is a cGlblDbForm
        Entry_Item SalesRep.LastName
        Set Location to 31 73
        Set Size to 13 186
        Set Label to "Account Manager:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    
Cd_End_Object
