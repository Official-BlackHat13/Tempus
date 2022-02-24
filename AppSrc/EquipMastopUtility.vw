Use Windows.pkg
Use DFClient.pkg
Use MastOps.DD
Use Employer.DD
Use Equipmnt.DD
Use cWorkTypeGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use dfTable.pkg
Use cProgressBar.pkg

Deferred_View Activate_oEquipMastopUtility for ;
Object oEquipMastopUtility is a dbView
    
    Integer giMopFind
    Integer giMopReplace

    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object
    
    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
    End_Object

    Object oEquipmnt_DD is a Equipmnt_DataDictionary
        Set DDO_Server to oEmployer_DD
        Set DDO_Server to oMastOps_DD
      End_Object

    Set Main_DD to oEquipmnt_DD
    Set Server to oEquipmnt_DD

    Set Border_Style to Border_Thick
    Set Size to 158 337
    Set Location to 33 131
    Set Label to "Equipment/MastOp Relation Utility"

    

   

Cd_End_Object
