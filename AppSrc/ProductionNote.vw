Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD
Use cProdNoteGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use cDbTextEdit.pkg

Deferred_View Activate_oProductionNote for ;
Object oProductionNote is a dbView
    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oProject_DD is a cProjectDataDictionary
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

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oProdNote_DD is a cProdNoteGlblDataDictionary
        Set Constrain_File to Order.File_Number
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oOrder_DD
    End_Object

    Set Main_DD to oProdNote_DD
    Set Server to oProdNote_DD

    Set Border_Style to Border_Thick
    Set Label to "Production Notes"
    Set Size to 189 401
    Set Location to 15 52

    Object oProdNoteContainer is a dbContainer3d
        Set Size to 170 381
        Set Location to 8 10
        
        Object oProdNote_JobNumber is a cGlblDbForm
            Entry_Item Order.JobNumber
            Set Location to 9 51
            Set Size to 13 54
            Set Label to "Job Number:"
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
        End_Object
    
        Object oProdNote_Note is a cDbTextEdit
            Entry_Item ProdNote.Note
            Set Location to 80 51
            Set Size to 77 314
            Set Label to "Note:"
        End_Object
    
        Object oCustomer_Name is a cGlblDbForm
            Entry_Item Customer.Name
            Set Location to 9 111
            Set Size to 13 253
            Set Prompt_Button_Mode to PB_PromptOff
            
        End_Object
    
        Object oLocation_Name is a cGlblDbForm
            Entry_Item Location.Name
            Set Location to 26 111
            Set Size to 13 252
            Set Label to "Loaction:"
            Set Prompt_Button_Mode to PB_PromptOff
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
        End_Object
    
        Object oProdNote_ProdNoteIdno is a cGlblDbForm
            Entry_Item ProdNote.ProdNoteIdno
            Set Location to 47 50
            Set Size to 13 54
            Set Label to "Note ID#:"
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
        End_Object
    
        Object oProdNote_CreatedDate is a cGlblDbForm
            Entry_Item ProdNote.CreatedDate
            Set Location to 47 162
            Set Size to 13 66
            Set Label to "CreatedDate:"
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
        End_Object
    
        Object oProdNote_CreatedBy is a cGlblDbForm
            Entry_Item ProdNote.CreatedBy
            Set Location to 47 280
            Set Size to 13 80
            Set Label to "CreatedBy:"
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
        End_Object

    End_Object //ProdNoteContainer
      
Cd_End_Object
