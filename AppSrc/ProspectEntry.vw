Use Windows.pkg
Use DFClient.pkg
Use cGlblDbForm.pkg
Use cProspectGlblDataDictionary.dd
Use SalesRep.DD

Deferred_View Activate_oProspectEntry for ;
Object oProspectEntry is a dbView
    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oProspect_DD is a cProspectGlblDataDictionary
    End_Object

    Set Main_DD to oProspect_DD
    Set Server to oProspect_DD

    Set Border_Style to Border_Thick
    Set Size to 254 426
    Set Location to 38 61

    Object oProspect_Prospect_Idno is a cGlblDbForm
        Entry_Item Prospect.Prospect_Idno
        Set Location to 27 99
        Set Size to 13 54
        Set Label to "Prospect Idno:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oProspect_CompanyName is a cGlblDbForm
        Entry_Item Prospect.CompanyName
        Set Location to 46 99
        Set Size to 13 243
        Set Label to "CompanyName:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oProspect_ProspectName is a cGlblDbForm
        Entry_Item Prospect.ProspectName
        Set Location to 64 99
        Set Size to 13 186
        Set Label to "ProspectName:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oProspect_Address1 is a cGlblDbForm
        Entry_Item Prospect.Address1
        Set Location to 82 99
        Set Size to 13 186
        Set Label to "Address1:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oProspect_Address2 is a cGlblDbForm
        Entry_Item Prospect.Address2
        Set Location to 101 99
        Set Size to 13 186
        Set Label to "Address2:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oProspect_City is a cGlblDbForm
        Entry_Item Prospect.City
        Set Location to 119 99
        Set Size to 13 97
        Set Label to "City/State/Zip:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oProspect_State is a cGlblDbForm
        Entry_Item Prospect.State
        Set Location to 119 205
        Set Size to 13 24
        //Set Label to "State:"
    End_Object

    Object oProspect_Zip is a cGlblDbForm
        Entry_Item Prospect.Zip
        Set Location to 119 235
        Set Size to 13 51
       //Set Label to "Zip:"
    End_Object

    Object oProspect_OfficePhone is a cGlblDbForm
        Entry_Item Prospect.OfficePhone
        Set Location to 137 99
        Set Size to 13 78
        Set Label to "Office Phone:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oProspect_MobilePhone is a cGlblDbForm
        Entry_Item Prospect.MobilePhone
        Set Location to 155 99
        Set Size to 13 78
        Set Label to "Mobile Phone:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oProspect_Email is a cGlblDbForm
        Entry_Item Prospect.Email
        Set Location to 172 99
        Set Size to 13 245
        Set Label to "Email:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSalesRep_RepIdno is a cGlblDbForm
        Entry_Item SalesRep.RepIdno
        Set Location to 26 223
        Set Size to 13 54
        Set Label to "RepIdno:"
    End_Object

    

Cd_End_Object
