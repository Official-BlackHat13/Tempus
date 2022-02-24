Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD
Use cSnowrepDataDictionary.dd
Use Contact.DD
Use cQuotehdrDataDictionary.dd
Use MastOps.DD
Use cQuotedtlDataDictionary.dd
Use cCO_HeadGlblDataDictionary.dd
Use cCO_DTLGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg

Deferred_View Activate_oChangeOrder for ;
Object oChangeOrder is a dbView
    Object oMastOps_DD is a Mastops_DataDictionary
    End_Object

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oProject_DD is a cProjectDataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oContact_DD is a Contact_DataDictionary
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oQuotehdr_DD is a cQuotehdrDataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oContact_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oQuotedtl_DD is a cQuotedtlDataDictionary
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oQuotehdr_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oCO_Head_DD is a cCO_HeadGlblDataDictionary
        Set Constrain_file to Order.File_number
        Set DDO_Server to oOrder_DD
    End_Object

    Object oCO_DTL_DD is a cCO_DTLGlblDataDictionary
         Send DefineAllExtendedFields
        Set Constrain_file to CO_Head.File_number
        Set DDO_Server to oCO_Head_DD
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD

    Set Border_Style to Border_Thick
    Set Size to 303 444
    Set Location to 1 158
    Set Label to "Change Order Entry/Edit"

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 73 405
        Set Location to 13 19

        Object oOrder_JobNumber is a cGlblDbForm
            Entry_Item Order.JobNumber
            Set Location to 14 98
            Set Size to 13 54
            Set Label to "Job Number:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oCustomer_Name is a cGlblDbForm
            Entry_Item Customer.Name
            Set Location to 14 156
            Set Size to 13 200
            Set Prompt_Button_Mode to PB_PromptOff

        End_Object

        Object oLocation_Name is a cGlblDbForm
            Entry_Item Location.Name
            Set Location to 31 156
            Set Size to 13 200
            Set Prompt_Button_Mode to PB_PromptOff
        End_Object

        Object oCO_Head_CO_Head_ID is a cGlblDbForm
            Entry_Item CO_Head.CO_Head_ID

            Set Server to oCO_Head_DD
            Set Location to 46 97
            Set Size to 13 54
            Set Label to "CHANGE ORDER ID:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object
    End_Object

    Object oDbCJGrid1 is a cDbCJGrid
        Set Server to oCO_DTL_DD
        Set Size to 182 399
        Set Location to 98 23

        Object oCO_DTL_Issued is a cDbCJGridColumn
            Entry_Item CO_DTL.Issued
            Set piWidth to 68
            Set psCaption to "Issued"
        End_Object

        Object oCO_DTL_Initials is a cDbCJGridColumn
            Entry_Item CO_DTL.Initials
            Set piWidth to 42
            Set psCaption to "Initials"
        End_Object

        Object oCO_DTL_Instructions is a cDbCJGridColumn
            Entry_Item CO_DTL.Instructions
            Set piWidth to 389
            Set psCaption to "Instructions"
        End_Object

        Object oCO_DTL_Estimated_Value is a cDbCJGridColumn
            Entry_Item CO_DTL.Estimated_Value
            Set piWidth to 99
            Set psCaption to "Estimated Value"
        End_Object
    End_Object

Cd_End_Object
