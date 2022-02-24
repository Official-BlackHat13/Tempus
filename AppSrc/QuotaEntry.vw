Use Windows.pkg
Use DFClient.pkg
Use SalesRep.DD
Use cQuotaGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use dfLine.pkg
Use PrintSalesQuota.rv
 

Deferred_View Activate_oQuotaEntry for ;
Object oQuotaEntry is a dbView
    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oQuota_DD is a cQuotaGlblDataDictionary
        Set DDO_Server to oSalesRep_DD
    End_Object

    Set Main_DD to oQuota_DD
    Set Server to oQuota_DD

    Set Border_Style to Border_Thick
    Set Size to 240 685
    Set Location to 32 37
    Set Label to "Sales Quota Entry"
    Set Auto_Clear_DEO_State to False

    Object oSalesRep_RepIdno is a cGlblDbForm
        Entry_Item SalesRep.RepIdno
        Set Location to 27 215
        Set Size to 13 54
        Set Label to "Rep#/Name:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oSalesRep_LastName is a cGlblDbForm
        Entry_Item SalesRep.LastName
        Set Location to 27 276
        Set Size to 13 100
        Set Prompt_Button_Mode to PB_PromptOff
        //Set Label to "LastName:"
    End_Object

    Object oQuota_Quota_Idno is a cGlblDbForm
        Entry_Item Quota.Quota_Idno
        Set Location to 26 89
        Set Size to 13 68
        Set Label to "Quota Idno:"
    End_Object

    Object oQuota_SalesYear is a cGlblDbForm
        Entry_Item Quota.SalesYear
        Set Location to 49 89
        Set Size to 13 67
        Set Label to "SalesYear:"
    End_Object

    Object oQuota_Asphalt_Q1 is a cGlblDbForm
        Entry_Item Quota.Asphalt_Q1
        Set Location to 94 60
        Set Size to 13 54
        Set Label to "Asphalt Q1:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Asphalt_Q2 is a cGlblDbForm
        Entry_Item Quota.Asphalt_Q2
        Set Location to 109 60
        Set Size to 13 54
        Set Label to "Asphalt Q2:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Asphalt_Q3 is a cGlblDbForm
        Entry_Item Quota.Asphalt_Q3
        Set Location to 124 60
        Set Size to 13 54
        Set Label to "Asphalt Q3:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
     End_Object   
        
     Object oQuota_Asphalt_Q4 is a cGlblDbForm
        Entry_Item Quota.Asphalt_Q4
        Set Location to 140 60
        Set Size to 13 54
        Set Label to "Asphalt Q4:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object
   
    Object oQuota_Concrete_Q1 is a cGlblDbForm
        Entry_Item Quota.Concrete_Q1
        Set Location to 94 172
        Set Size to 13 54
        Set Label to "Concrete Q1:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Concrete_Q2 is a cGlblDbForm
        Entry_Item Quota.Concrete_Q2
        Set Location to 109 172
        Set Size to 13 54
        Set Label to "Concrete Q2:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Concrete_Q3 is a cGlblDbForm
        Entry_Item Quota.Concrete_Q3
        Set Location to 124 172
        Set Size to 13 54
        Set Label to "Concrete Q3:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Concrete_Q4 is a cGlblDbForm
        Entry_Item Quota.Concrete_Q4
        Set Location to 140 172
        Set Size to 13 54
        Set Label to "Concrete Q4:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Excavation_Q1 is a cGlblDbForm
        Entry_Item Quota.Excavation_Q1
        Set Location to 94 291
        Set Size to 13 54
        Set Label to "Excavation Q1:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Excavation_Q2 is a cGlblDbForm
        Entry_Item Quota.Excavation_Q2
        Set Location to 109 291
        Set Size to 13 54
        Set Label to "Excavation Q2:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Excavation_Q3 is a cGlblDbForm
        Entry_Item Quota.Excavation_Q3
        Set Location to 124 291
        Set Size to 13 54
        Set Label to "Excavation Q3:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Excavation_Q4 is a cGlblDbForm
        Entry_Item Quota.Excavation_Q4
        Set Location to 139 291
        Set Size to 13 54
        Set Label to "Excavation Q4:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Snow_Q1 is a cGlblDbForm
        Entry_Item Quota.Snow_Q1
        Set Location to 94 392
        Set Size to 13 54
        Set Label to "Snow Q1:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Snow_Q2 is a cGlblDbForm
        Entry_Item Quota.Snow_Q2
        Set Location to 108 392
        Set Size to 13 54
        Set Label to "Snow Q2:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Snow_Q3 is a cGlblDbForm
        Entry_Item Quota.Snow_Q3
        Set Location to 123 393
        Set Size to 13 54
        Set Label to "Snow Q3:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Snow_Q4 is a cGlblDbForm
        Entry_Item Quota.Snow_Q4
        Set Location to 139 393
        Set Size to 13 54
        Set Label to "Snow Q4:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Sweep_Q1 is a cGlblDbForm
        Entry_Item Quota.Sweep_Q1
        Set Location to 92 499
        Set Size to 13 54
        Set Label to "Sweep Q1:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Sweep_Q2 is a cGlblDbForm
        Entry_Item Quota.Sweep_Q2
        Set Location to 107 499
        Set Size to 13 54
        Set Label to "Sweep Q2:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Sweep_Q3 is a cGlblDbForm
        Entry_Item Quota.Sweep_Q3
        Set Location to 123 499
        Set Size to 13 54
        Set Label to "Sweep Q3:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Sweep_Q4 is a cGlblDbForm
        Entry_Item Quota.Sweep_Q4
        Set Location to 138 499
        Set Size to 13 54
        Set Label to "Sweep Q4:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object
    
    Object oQuota_Marking_Q1 is a cGlblDbForm
        Entry_Item Quota.Marking_Q1
        Set Location to 91 607
        Set Size to 13 54
        Set Label to "Marking Q1:"
           Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Marking_Q2 is a cGlblDbForm
        Entry_Item Quota.Marking_Q2
        Set Location to 106 607
        Set Size to 13 54
        Set Label to "Marking Q2:"
           Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Marking_Q3 is a cGlblDbForm
        Entry_Item Quota.Marking_Q3
        Set Location to 121 607
        Set Size to 13 54
        Set Label to "Marking Q3:"
           Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Marking_Q4 is a cGlblDbForm
        Entry_Item Quota.Marking_Q4
        Set Location to 136 607
        Set Size to 13 54
        Set Label to "Marking Q4:"
           Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
    End_Object


    Object oLineControl1 is a LineControl
        Set Size to 8 645
        Set Location to 79 17
    End_Object

    Object oLineControl2 is a LineControl
        Set Size to 2 605
        Set Location to 160 60
    End_Object

    Object oQuota_Asphalt_Year is a cGlblDbForm
        Entry_Item Quota.Asphalt_Year
        Set Location to 165 60
        Set Size to 13 54
        Set Label to "Asphalt Year:"
           Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Concrete_Year is a cGlblDbForm
        Entry_Item Quota.Concrete_Year
        Set Location to 166 172
        Set Size to 13 54
        Set Label to "Concrete Year:"
           Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Excavation_Year is a cGlblDbForm
        Entry_Item Quota.Excavation_Year
        Set Location to 166 291
        Set Size to 13 54
        Set Label to "Excavation Year:"
           Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Snow_Year is a cGlblDbForm
        Entry_Item Quota.Snow_Year
        Set Location to 166 393
        Set Size to 13 54
        Set Label to "Snow Year:"
           Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Sweep__Year is a cGlblDbForm
        Entry_Item Quota.Sweep__Year
        Set Location to 164 499
        Set Size to 13 54
        Set Label to "Sweep  Year:"
           Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
    End_Object

    
    Object oQuota_Other_Year is a cGlblDbForm
        Entry_Item Quota.Other_Year
        Set Location to 166 607
        Set Size to 13 54
        Set Label to "Marking Year:"
           Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oQuota_Sls_Rep_Year is a cGlblDbForm
        Entry_Item Quota.Sls_Rep_Year
        Set Location to 198 608
        Set Size to 13 54
        Set Label to "Sales Rep Total Year:"
         Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        
    End_Object

    Object oLineControl3 is a LineControl
        Set Size to 2 209
        Set Location to 200 56
    End_Object

    Object oTextBox1 is a TextBox
        Set Size to 10 50
        Set Location to 188 58
        Set Label to 'Print Options'
        Set FontWeight to 600
    End_Object

    Object oButton1 is a Button
        Set Size to 14 56
        Set Location to 208 58
        Set Label to 'Print Record'
    
  
        Procedure OnClick
            Integer iSpec
            
            Get Field_Current_Value of oQuota_DD Field Quota.Quota_Idno to iSpec
            Send DoJumpStartReport of PrintSalesQuota iSpec
            
        End_Procedure
    
    End_Object

Cd_End_Object
