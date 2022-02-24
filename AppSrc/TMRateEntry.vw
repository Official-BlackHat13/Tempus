Use Windows.pkg
Use DFClient.pkg
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use cTMList_HdrGlblDataDictionary.dd
Use cPropTMGlblDataDictionary.dd

Deferred_View Activate_oTMRateEntry for ;
Object oTMRateEntry is a dbView
    Object oTMList_Hdr_DD is a cTMList_HdrGlblDataDictionary
    End_Object

    Object oPropTM_DD is a cPropTMGlblDataDictionary
        Set DDO_Server to oTMList_Hdr_DD
        Set Constrain_File to TMList_Hdr.TMList_Idno
    End_Object

    Set Main_DD to oPropTM_DD
    Set Server to oPropTM_DD

    Set Border_Style to Border_Thick
    Set Size to 291 512
    Set Location to 78 153

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 36 462
        Set Location to 11 26

        Object oTMList_Hdr_TMList_Idno is a cGlblDbForm
            Entry_Item TMList_Hdr.TMList_Idno
            Set Location to 12 68
            Set Size to 13 54
            Set Label to "List#/Title:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oTMList_Hdr_Description is a cGlblDbForm
            Entry_Item TMList_Hdr.Description
            Set Location to 12 142
            Set Size to 13 191
        End_Object
    End_Object

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 216 459
        Set Location to 60 26

        Object oPropTM_Catagory is a cDbCJGridColumn
            Entry_Item PropTM.Catagory
            Set piWidth to 104
            Set psCaption to "Catagory"
        End_Object

        Object oPropTM_ServiceDesc is a cDbCJGridColumn
            Entry_Item PropTM.ServiceDesc
            Set piWidth to 446
            Set psCaption to "Service Description"
        End_Object

        Object oPropTM_ServicePrice is a cDbCJGridColumn
            Entry_Item PropTM.ServicePrice
            Set piWidth to 138
            Set psCaption to "Service Price"
        End_Object
    End_Object

    

 

Cd_End_Object
