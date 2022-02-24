Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use MastOps.DD
Use Opers.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd

Deferred_View Activate_oOpersMastOpUtility for ;
Object oOpersMastOpUtility is a dbView
    
    Global_Variable Integer giFindOperMastOp
    Global_Variable Integer giReplaceOperMastOP

    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object
    
    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
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
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Set Main_DD to oOpers_DD
    Set Server to oOpers_DD

    Set Border_Style to Border_Thick
    Set Size to 196 354
    Set Location to 36 266
    Set Label to "Operation/MastOp Relation Utility"

    Object oForm1 is a Form
        Set Size to 13 100
        Set Location to 38 127
        Set Label to "Find MastOp Idno:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
    
        Procedure OnKillFocus
            Get Value to giFindOperMastOp
        End_Procedure
    
    End_Object

    Object oForm2 is a Form
        Set Size to 13 100
        Set Location to 57 127
        Set Label to "Replace with MastOp Idno:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
    
        Procedure OnKillFocus
            Get Value to giReplaceOperMastOP
        End_Procedure  
    
    End_Object

    Object oButton1 is a Button
        Set Location to 127 59
        Set Label to 'START'
           
        Procedure OnClick
            
            Clear Opers
            Move giFindOperMastOp to Opers.MastOpsIdno
            Find ge Opers.MastOpsIdno
            
            While ((Found) and Opers.MastOpsIdno = giFindOperMastOp)
                Reread Opers
                Move giReplaceOperMastOP to Opers.MastOpsIdno
                SaveRecord Opers
                Unlock
                Move giFindOperMastOp to Opers.MastOpsIdno
                Find gt Opers.MastOpsIdno
            Loop
            
        End_Procedure
    
    End_Object

Cd_End_Object
