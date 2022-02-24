Use Windows.pkg
Use DFClient.pkg
Use MastOps.DD
Use Employer.DD
Use Equipmnt.DD
Use cWorkTypeGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use dfcentry.pkg
Use cProgressBar.pkg

Deferred_View Activate_oEquipmentStatusUtility for ;
Object oEquipmentStatusUtility is a dbView
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
    Set Size to 98 330
    Set Location to 30 311
    Set Label to "Equipment Status Update"

    Object oEmployer_EmployerIdno is a cGlblDbForm
        Entry_Item Employer.EmployerIdno
        Set Location to 15 81
        Set Size to 13 54
        Set Label to "EmployerIdno:"
    End_Object

    Object oEmployer_Name is a cGlblDbForm
        Entry_Item Employer.Name
        Set Location to 30 81
        Set Size to 13 150
        Set Label to "Name:"
    End_Object

    Object oButton1 is a Button
        Set Location to 50 81
        Set Label to 'Update'
    
        // fires when the button is clicked
        Procedure OnClick
            Boolean bComplete
            Integer iEmployer_Idno
            Get Field_Current_Value of oEmployer_DD Field Employer.EmployerIdno to iEmployer_Idno
            
            Clear Equipmnt
            Move iEmployer_Idno to Equipmnt.OperatedBy
            Find ge Equipmnt.OperatedBy
            While ((Found) and Equipmnt.OperatedBy = iEmployer_Idno and Employer.Status = "I")
                Reread Equipmnt
                Move "I" to Equipmnt.Status
                SaveRecord Equipmnt
                Unlock
                Find gt Equipmnt.OperatedBy
               //Send DoAdvanceBy of oProgressBar1 5 
            Loop 
            
        End_Procedure
    
    End_Object

    Object oDbComboForm1 is a dbComboForm
        Entry_Item Employer.Status
        Set Size to 13 60
        Set Location to 30 243
    End_Object

//    Object oProgressBar1 is a cProgressBar
//        Set Size to 14 161
//        Set Location to 50 141
//        Set piMinimum to 0
//        Set piMaximum to 100
//        Set pbSmooth to True
//    End_Object

Cd_End_Object
