// Z:\VDF17.0 Workspaces\Tempus\AppSrc\InsuranceClassification.vw
// InsuranceClassification
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use cInsClassGlblDataDictionary.dd
Use cDbCJGrid.pkg

ACTIVATE_VIEW Activate_oInsuranceClassification FOR oInsuranceClassification
Object oInsuranceClassification is a cGlblDbView
    Set Location to 5 5
    Set Size to 229 358
    Set Label To "InsuranceClassification"
    Set Border_Style to Border_Thick


    Object oInsClass_DD is a cInsClassGlblDataDictionary
    End_Object // oInsClass_DD

    Set Main_DD To oInsClass_DD
    Set Server  To oInsClass_DD

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 214 343
        Set Location to 6 7

        Object oInsClass_ClassCode is a cDbCJGridColumn
            Entry_Item InsClass.ClassCode
            Set piWidth to 72
            Set psCaption to "Code"
        End_Object

        Object oInsClass_ClassDescription is a cDbCJGridColumn
            Entry_Item InsClass.ClassDescription
            Set piWidth to 450
            Set psCaption to "Classification"
        End_Object
    End_Object


End_Object // oInsuranceClassification
