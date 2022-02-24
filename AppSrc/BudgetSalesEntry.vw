Use Windows.pkg
Use DFClient.pkg
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use cCJGrid.pkg
Use cBudgetHdrGlblDataDictionary.dd
Use SalesRep.DD
Use coBudgetSalesGlblDataDictionary.dd

Deferred_View Activate_oBudgetSalesEntry for ;
Object oBudgetSalesEntry is a dbView
    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oBudgetHdr_DD is a cBudgetHdrGlblDataDictionary
    End_Object

    Object oQuota_DD is a coBudgetSalesGlblDataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oBudgetHdr_DD
        Set Constrain_File to BudgetHdr.File_Number
    End_Object

    Set Main_DD to oQuota_DD
    Set Server to oQuota_DD

    Set Border_Style to Border_Thick
    Set Label to "Sales Budget Entry/Edit"
    Set Size to 258 744
    Set Location to 39 34

    Object oBudgetHdr_Budget_Hdr_Idno is a cGlblDbForm
        Entry_Item BudgetHdr.Budget_Hdr_Idno
        Set Location to 13 99
        Set Size to 13 67
        Set Label to "Budget ID#:"
    End_Object

    Object oBudgetHdr_Budget_Yr is a cGlblDbForm
        Entry_Item BudgetHdr.Budget_Yr
        Set Location to 27 99
        Set Size to 13 66
        Set Label to "Budget Year:"
    End_Object

    Object oBudgetHdr_Budget_Mo is a cGlblDbForm
        Entry_Item BudgetHdr.Budget_Mo
        Set Location to 43 99
        Set Size to 13 66
        Set Label to "Budget Month:"
//        Set Ordering to False
    End_Object

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 105 673
        Set Location to 71 38

        Object oSalesRep_RepIdno is a cDbCJGridColumn
            Entry_Item SalesRep.RepIdno
            Set piWidth to 112
            Set psCaption to "Sales Rep ID#"
        End_Object

        Object ooBudgetSales_Snow_Amt is a cDbCJGridColumn
            Entry_Item oBudgetSales.Snow_Amt
            Set piWidth to 112
            Set psCaption to "Snow Removal"
        End_Object

        Object ooBudgetSales_Melt_Amt is a cDbCJGridColumn
            Entry_Item oBudgetSales.Melt_Amt
            Set piWidth to 112
            Set psCaption to "Snow Melting"
        End_Object

        Object ooBudgetSales_Pave_Amt is a cDbCJGridColumn
            Entry_Item oBudgetSales.Pave_Amt
            Set piWidth to 112
            Set psCaption to "Pavement Mnt."
        End_Object

        Object ooBudgetSales_Concrete_Amt is a cDbCJGridColumn
            Entry_Item oBudgetSales.Concrete_Amt
            Set piWidth to 112
            Set psCaption to "Concrete"
        End_Object

        Object ooBudgetSales_Excavation_Amt is a cDbCJGridColumn
            Entry_Item oBudgetSales.Excavation_Amt
            Set piWidth to 112
            Set psCaption to "Excavation"
        End_Object

        Object ooBudgetSales_Sweep_Amp is a cDbCJGridColumn
            Entry_Item oBudgetSales.Sweep_Amp
            Set piWidth to 112
            Set psCaption to "Sweeping"
        End_Object

        Object ooBudgetSales_Mark_Amt is a cDbCJGridColumn
            Entry_Item oBudgetSales.Mark_Amt
            Set piWidth to 112
            Set psCaption to "Marking"
        End_Object

        Object ooBudgetSales_Other_Amt is a cDbCJGridColumn
            Entry_Item oBudgetSales.Other_Amt
            Set piWidth to 113
            Set psCaption to "Other"
        End_Object
    End_Object

    Object oBudgetHdr_Snow_TTL is a cGlblDbForm
        Entry_Item BudgetHdr.Snow_TTL
        Set Location to 188 115
        Set Size to 13 68
        //Set Label to "Snow TTL:"
    End_Object

    Object oBudgetHdr_Melt_TTL is a cGlblDbForm
        Entry_Item BudgetHdr.Melt_TTL
        Set Location to 188 193
        Set Size to 13 66
       // Set Label to "Melt TTL:"
    End_Object

    Object oBudgetHdr_Pave_TTL is a cGlblDbForm
        Entry_Item BudgetHdr.Pave_TTL
        Set Location to 188 266
        Set Size to 13 69
       // Set Label to "Pave TTL:"
    End_Object

    Object oBudgetHdr_Concrete_TTL is a cGlblDbForm
        Entry_Item BudgetHdr.Concrete_TTL
        Set Location to 188 342
        Set Size to 13 67
       // Set Label to "Concrete TTL:"
    End_Object

    Object oBudgetHdr_Excavation_TTL is a cGlblDbForm
        Entry_Item BudgetHdr.Excavation_TTL
        Set Location to 188 417
        Set Size to 13 66
     //   Set Label to "Excavation TTL:"
    End_Object

    Object oBudgetHdr_Sweep_TTL is a cGlblDbForm
        Entry_Item BudgetHdr.Sweep_TTL
        Set Location to 188 491
        Set Size to 13 66
       // Set Label to "Sweep TTL:"
    End_Object

    Object oBudgetHdr_Mark_TTL is a cGlblDbForm
        Entry_Item BudgetHdr.Mark_TTL
        Set Location to 188 566
        Set Size to 13 67
        //Set Label to "Mark TTL:"
    End_Object

    Object oBudgetHdr_Other_TTL is a cGlblDbForm
        Entry_Item BudgetHdr.Other_TTL
        Set Location to 188 639
        Set Size to 13 69
       // Set Label to "Other TTL:"
    End_Object

    Object oBudgetHdr_Grand_TTL is a cGlblDbForm
        Entry_Item BudgetHdr.Grand_TTL
        Set Location to 212 638
        Set Size to 13 68
        Set Label to "Month Grand Total:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
    End_Object

Cd_End_Object
