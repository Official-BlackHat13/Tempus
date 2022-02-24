// JCOPER.vw

Use cTempusDbView.pkg
Use cGlblDbForm.pkg
Use cGlblDbCheckBox.pkg

Use cJcdeptDataDictionary.dd
Use cJccntrDataDictionary.dd
Use JCOPER.DD

Use Mastops.sl
Use Windows.pkg


Activate_View Activate_oJcoper for oJcoper
Object oJcoper is a cTempusDbView

    Property Boolean pbReadOnly

    Procedure DoRefreshView
    End_Procedure

    Set Label to "Operations"
    Set Location to 1 2
    Set Size to 253 374

    Object Jcdept_DD is a cJcdeptDataDictionary
    End_Object    // Jcdept_DD

    Object Jccntr_DD is a cJccntrDataDictionary
        Set DDO_Server to Jcdept_DD
    End_Object    // Jccntr_DD

    Object Jcoper_DD is a Jcoper_DataDictionary
        Set DDO_Server to Jccntr_DD
        Set Constrain_File to Jccntr.File_Number
    End_Object    // Jcoper_DD

    Set Main_DD to Jcoper_DD
    Set Server to Jcoper_DD

    Object Container1 is a dbContainer3d

        Property Integer pbLinker

        Set Size to 72 364
        Set Location to 5 4
        Object Jcdept_Idno is a cGlblDbForm

            //AB-StoreTopStart
            //set pbDataLoss to TRUE
            set Enabled_State to FALSE
            //AB-StoreTopEnd

            Entry_Item Jcdept.Idno
            Set Label to "Department"
            Set Size to 13 35
            Set Location to 5 45
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set Prompt_Button_Mode to pb_PromptOn
        End_Object    // Jcdept_Idno

        Object Jcdept_Name is a dbForm
            Entry_Item Jcdept.Name
            Set Label to "Description"
            Set Size to 13 130
            Set Location to 5 124
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jcdept_Name

        Object oJcdept_Nickname is a cGlblDbForm
            Entry_Item Jcdept.Nickname
            Set Label to "Abbrev."
            Set Size to 13 60
            Set Location to 5 288
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // oJcdept_Nickname

        Object Jccntr_Idno is a cGlblDbForm

            //AB-StoreTopStart
            set pbDataLoss to TRUE
            //AB-StoreTopEnd

            Entry_Item Jccntr.Idno
            Set Label to "Cost Center"
            Set Size to 13 35
            Set Location to 20 45
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jccntr_Idno

        Object Jccntr_Name is a dbForm
            Entry_Item Jccntr.Name
            Set Label to "Description"
            Set Size to 13 130
            Set Location to 20 124
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jccntr_Name

        Object oJccntr_Nickname is a cGlblDbForm
            Entry_Item Jccntr.Nickname
            Set Label to "Abbrev."
            Set Size to 13 60
            Set Location to 20 288
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // oJccntr_Nickname

        Object Jcoper_Idno is a cGlblDbForm
            Entry_Item Jcoper.Idno
            Set Label to "Operation"
            Set Size to 13 35
            Set Location to 34 45
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right

            //AB-StoreStart
            Procedure Prompt
                integer iCcno iOpcode iOpIdno
                get value    of Jcoper_Idno   to iOpIdno
                get value    of Jccntr_Idno   to iCcno
                move (iCcno *1000 +iOpidno)   to iOpcode
                set piCCno   of Jcoper_sl     to iCcno
                set piOpidno of Jcoper_sl     to iOpidno
                set piOpcode of Jcoper_sl     to iOpcode
                forward send prompt
            End_procedure
                        
            procedure PrimeList
                integer iLinkCode iSeedObj iCCNo iOpcode iOpIdno
                get piCcno   of Jcoper_sl to iCcno
                get piOpIdno of Jcoper_sl to iOpIdno
                get piOpcode of Jcoper_sl to iOpcode
                //
                if (iCcno >0 AND iOpIdno =0) begin
                    move (iCcno*1000) to Jcoper.Opcode
                    //Send Find of Jcoper_DD GE 2
                    find gt Jcoper.Opcode
                    //procedure_return
                end
                else if (iCcno >0 AND iOpcode =0) begin
                    move (iCcno*1000) to Jcoper.Opcode
                    //Send Find of Jcoper_DD GE 2
                    find gt Jcoper.Opcode
                    //procedure_return
                end
                else if (iCcno =0 and iOpcode =0) begin
                    move (-99999) to Jcoper.Opcode
                    find GT Jcoper.Opcode
                    //procedure_return
                end
                else if (iCCno <>0 and iOpIdno <>0) begin
                    move (iCCNo*1000 +iOpIdno) to Jcoper.Opcode
                    //Send Find of Jcoper_DD GE 2
                    find GE Jcoper.Opcode
                end
                if (found) send request_assign to jcoper_dd
            end_procedure
            //AB-StoreEnd
            
        End_Object    // Jcoper_Idno

        Object Jcoper_Name is a dbForm
            Entry_Item Jcoper.Name
            Set Label to "Description"
            Set Size to 13 130
            Set Location to 34 124
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jcoper_Name

        Object Jcoper_Nickname is a dbForm
            Entry_Item Jcoper.Nickname
            Set Label to "Abbrev."
            Set Size to 13 60
            Set Location to 34 288
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jcoper_Nickname

        Object oJcoper_Opcode is a cGlblDbForm
            Entry_Item Jcoper.Opcode
            Set Label to "CC/OP #"
            Set Size to 13 35
            Set Location to 50 45
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set Prompt_Button_Mode to pb_PromptOff

            //AB-StoreStart
            Set enabled_state to false
            
            //AB-StoreEnd

        End_Object    // oJcoper_Opcode

        Object oJcoper_MAST_OPS_IDNO is a cGlblDbForm
            Entry_Item Jcoper.MAST_OPS_IDNO
            Set Location to 49 125
            Set Size to 13 54
            Set Label to "MastOps"
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to JMode_Right
            Set Prompt_Button_Mode to PB_PromptOn
            
            Procedure Prompt
                Integer iOldMastOps iNewMastOps
                //
                Get Value of oJcoper_MAST_OPS_IDNO to iOldMastOps
                //
                //Send DoQuotePrompt of Mastops_sl
                Get SelectMastOps of Mastops_sl iOldMastOps to iNewMastOps
                //
                If (iNewMastOps <> iOldMastOps) Begin
                    Set Value of oMastOpsLabel to MastOps.Name
                End
            End_Procedure
            
            Procedure Refresh Integer notifyMode
                Integer iCurrentMastOps
                Forward Send Refresh notifyMode
                //
                Get Value of oJcoper_MAST_OPS_IDNO to iCurrentMastOps
                Open MastOps
                Clear MastOps
                Move iCurrentMastOps to MastOps.MastOpsIdno
                Find eq MastOps.MastOpsIdno
                Set Value of oMastOpsLabel to MastOps.Name
            End_Procedure
            
        End_Object

        Object oMastOpsLabel is a Form
            Set Size to 13 167
            Set Location to 49 182
            Set Entry_State to False
            Set Enabled_State to False
        
            //OnChange is called on every changed character
        
            //Procedure OnChange
            //    String sValue
            //
            //    Get Value to sValue
            //End_Procedure
        
        End_Object


        //AB-StoreStart
                        
        //AB-StoreEnd

    End_Object    // Container1

    Object dbOperationsTabDialog is a dbTabDialog
        Set Size to 164 364
        Set Location to 82 5
        Set Rotate_Mode to RM_Rotate
        Object TP_Parameters is a dbTabPage
            Set Label to "Parameters"
            Object oControlGroup is a dbGroup
                Set Size to 79 344
                Set Location to 5 7
                Set Label to "Costing Controls"
                Object Jcoper_Optype is a dbForm
                    Entry_Item Jcoper.Optype
                    Set Label to "Subtotal Type"
                    Set Size to 13 32
                    Set Location to 13 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Optype

                Object Jcoper_Costype is a dbForm
                    Entry_Item Jcoper.Costype
                    Set Label to "Labor Cost Type"
                    Set Size to 13 32
                    Set Location to 28 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Costype

                Object Jcoper_Standard is a dbForm
                    Entry_Item Jcoper.Standard
                    Set Label to "Standard Value"
                    Set Size to 13 40
                    Set Location to 43 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_mask item 0 to 6 2 "*,"
                    //AB-StoreEnd

                End_Object    // Jcoper_Standard

                Object Jcoper_Markup is a dbForm
                    Entry_Item Jcoper.Markup
                    Set Label to "Factor"
                    Set Size to 13 40
                    Set Location to 58 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Markup

                Object Jcoper_Std_Type is a dbForm
                    Entry_Item Jcoper.Std_type
                    Set Label to "Labor Standard Type"
                    Set Size to 13 25
                    Set Location to 13 210
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Std_Type

                Object oJcoper_Unit_Costing is a DbCheckBox //dbform
                    Set Auto_Size_State to False
                    Entry_Item Jcoper.Unit_costing
                    Set Label to "Use Unit Lbr. Costing"
                    //Set Label to "Cost Method"
                    Set Size to 10 85
                    Set Location to 30 134
                    Set AlignmentMode to taLeftJustify
                    Set Label_Col_Offset to 0
                End_Object    // oJcoper_Unit_Costing

                Object oJcoper_Std1 is a cGlblDbForm
                    Entry_Item Jcoper.Std1
                    Set Label to "Unit Rate"
                    Set Size to 13 40
                    Set Location to 28 275
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // oJcoper_Std1

                Object Jcoper_Eff_Lo is a dbForm
                    Entry_Item Jcoper.Eff_lo
                    Set Label to "Low Efficiency Range"
                    Set Size to 13 25
                    Set Location to 43 210
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Eff_Lo

                Object Jcoper_Eff_Hi is a dbForm
                    Entry_Item Jcoper.Eff_hi
                    Set Label to "High Efficiency Range"
                    Set Size to 13 25
                    Set Location to 58 210
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Eff_Hi

            End_Object    // oControlGroup

            Object dbGroup3 is a dbGroup
                Set Size to 50 344
                Set Location to 91 7
                Set Label to "Shop Floor Prompting"
                Object Jcoper_Unit_Prompt is a dbForm
                    Entry_Item Jcoper.Unit_prompt
                    Set Label to "Production Units"
                    Set Size to 13 210
                    Set Location to 12 65
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Unit_Prompt

                Object Jcoper_Prompt_Mtl_Flag is a dbCheckBox
                    Entry_Item Jcoper.Prompt_mtl_flag
                    Set Label to "Labor prompts for material?"
                    Set Size to 9 107
                    Set Location to 30 6

                    //AB-StoreStart
                                                            
                    //AB-StoreEnd

                End_Object    // Jcoper_Prompt_Mtl_Flag

                Object Jcoper_Prompt_Mtl_Op is a dbForm
                    Entry_Item Jcoper.Prompt_mtl_op
                    Set Label to "Default Material #"
                    Set Size to 13 42
                    Set Location to 28 187
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Prompt_Mtl_Op

            End_Object    // dbGroup3

        End_Object    // TP_Parameters

        Object TP_Efficiency is a dbTabPage
            Set Label to "Efficiency"
            Object dbGroup4 is a dbGroup
                Set Size to 92 344
                Set Location to 8 7
                Set Label to "                                        1st Qtr.          2nd  Qtr.         3rd Qtr.           4th Qtr.           Y.T.D.        Last Year"
                Object Jcoper_Prevyr_AvgStd is a dbForm
                    Entry_Item (prevyr_avgstd(server(current_object)))
                    Set Size to 13 42
                    Set Location to 41 296
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set numeric_mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Prevyr_AvgStd

                Object Q3_Hours is a dbForm
                    Entry_Item (jcoper.Q3_reghrs +jcoper.Q3_althrs +jcoper.Q3_splhrs)
                    Set Size to 13 42
                    Set Location to 12 164
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set numeric_mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q3_Hours

                Object Q2_Hours is a dbForm
                    Entry_Item (jcoper.Q2_reghrs +jcoper.Q2_althrs +jcoper.Q2_splhrs)
                    Set Size to 13 42
                    Set Location to 12 120
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set numeric_mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q2_Hours

                Object Prevyr_Hours is a dbForm
                    Entry_Item (jcoper.Prevyr_reghrs +jcoper.Prevyr_althrs +jcoper.Prevyr_splhrs)
                    Set Size to 13 42
                    Set Location to 12 296
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Prevyr_Hours

                Object Q4_Hours is a dbForm
                    Entry_Item (jcoper.Q4_reghrs +jcoper.Q4_althrs +jcoper.Q4_splhrs)
                    Set Size to 13 42
                    Set Location to 12 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q4_Hours

                Object YTD_Hours is a dbForm
                    Entry_Item (jcoper.Ttl_reghrs +jcoper.Ttl_althrs +jcoper.Ttl_splhrs)
                    Set Size to 13 42
                    Set Location to 12 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // YTD_Hours

                Object Q1_Hours is a dbForm
                    Entry_Item (jcoper.Q1_reghrs +jcoper.Q1_althrs +jcoper.Q1_splhrs)
                    Set Label to "Hours Reported"
                    Set Size to 13 42
                    Set Location to 12 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q1_Hours

                Object Prevyr_Units is a dbForm
                    Entry_Item (jcoper.Ttl_regunits +jcoper.Ttl_altunits +jcoper.Ttl_splunits)
                    Set Size to 13 42
                    Set Location to 26 296
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Prevyr_Units

                Object Prevyr_EffHrs is a dbForm
                    Entry_Item (jcoper.Preeff_reghrs +jcoper.Preeff_althrs +jcoper.Preeff_splhrs)
                    Set Size to 13 42
                    Set Location to 56 296
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Prevyr_EffHrs

                Object Jcoper_Prevyr_Eff is a dbForm
                    Entry_Item (prevyr_eff(server(current_object)))
                    Set Size to 13 42
                    Set Location to 71 296
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 4 0 "*%"
                    //AB-StoreEnd

                End_Object    // Jcoper_Prevyr_Eff

                Object Q1_Units is a dbForm
                    Entry_Item (jcoper.Q1_regunits +jcoper.Q1_altunits +jcoper.Q1_splunits)
                    Set Label to "Units Reported"
                    Set Size to 13 42
                    Set Location to 26 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q1_Units

                Object Q2_Units is a dbForm
                    Entry_Item (jcoper.Q2_regunits +jcoper.Q2_altunits +jcoper.Q2_splunits)
                    Set Size to 13 42
                    Set Location to 26 120
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q2_Units

                Object Q3_Units is a dbForm
                    Entry_Item (jcoper.Q3_regunits +jcoper.Q3_altunits +jcoper.Q3_splunits)
                    Set Size to 13 42
                    Set Location to 26 164
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q3_Units

                Object Q4_Units is a dbForm
                    Entry_Item (jcoper.Q4_regunits +jcoper.Q4_altunits +jcoper.Q4_splunits)
                    Set Size to 13 42
                    Set Location to 26 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q4_Units

                Object YTD_Units is a dbForm
                    Entry_Item (jcoper.Ttl_regunits +jcoper.Ttl_altunits +jcoper.Ttl_splunits)
                    Set Size to 13 42
                    Set Location to 26 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // YTD_Units

                Object Jcoper_Q1_AvgStd is a dbForm
                    Entry_Item (q1_avgstd(server(current_object)))
                    Set Label to "Average Standard"
                    Set Size to 13 42
                    Set Location to 41 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Q1_AvgStd

                Object Jcoper_Q2_AvgStd is a dbForm
                    Entry_Item (q2_avgstd(server(current_object)))
                    Set Size to 13 42
                    Set Location to 41 120
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Q2_AvgStd

                Object Jcoper_Q3_AvgStd is a dbForm
                    Entry_Item (q3_avgstd(server(current_object)))
                    Set Size to 13 42
                    Set Location to 41 164
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Q3_AvgStd

                Object Jcoper_Q4_AvgStd is a dbForm
                    Entry_Item (q4_avgstd(server(current_object)))
                    Set Size to 13 42
                    Set Location to 41 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Q4_AvgStd

                Object Jcoper_YTD_AvgStd is a dbForm
                    Entry_Item (ytd_avgstd(server(current_object)))
                    Set Size to 13 42
                    Set Location to 41 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_YTD_AvgStd

                Object Q1_Effhrs is a dbForm
                    Entry_Item (jcoper.Q1eff_reghrs +jcoper.Q1eff_althrs +jcoper.Q1eff_splhrs)
                    Set Label to "Hours in Avg. Std."
                    Set Size to 13 42
                    Set Location to 56 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q1_Effhrs

                Object Q2_Effhrs is a dbForm
                    Entry_Item (jcoper.Q2eff_reghrs +jcoper.Q2eff_althrs +jcoper.Q2eff_splhrs)
                    Set Size to 13 42
                    Set Location to 56 120
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q2_Effhrs

                Object Q3_EffHrs is a dbForm
                    Entry_Item (jcoper.Q3eff_reghrs +jcoper.Q3eff_althrs +jcoper.Q3eff_splhrs)
                    Set Size to 13 42
                    Set Location to 56 164
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q3_EffHrs

                Object Q4_EffHrs is a dbForm
                    Entry_Item (jcoper.Q4eff_reghrs +jcoper.Q4eff_althrs +jcoper.Q4eff_splhrs)
                    Set Size to 13 42
                    Set Location to 56 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q4_EffHrs

                Object YTD_EffHrs is a dbForm
                    Entry_Item (jcoper.Ttleff_reghrs +jcoper.Ttleff_althrs +jcoper.Ttleff_splhrs)
                    Set Size to 13 42
                    Set Location to 56 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    
                    //AB-StoreEnd

                End_Object    // YTD_EffHrs

                Object Jcoper_Q1_Eff is a dbForm
                    Entry_Item (q1_eff(server(current_object)))
                    Set Label to "Efficiency Score"
                    Set Size to 13 42
                    Set Location to 71 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 4 0 "*%"
                    //AB-StoreEnd

                End_Object    // Jcoper_Q1_Eff

                Object Jcoper_Q2_Eff is a dbForm
                    Entry_Item (q2_eff(server(current_object)))
                    Set Size to 13 42
                    Set Location to 71 120
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 4 0 "*%"
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Q2_Eff

                Object Jcoper_Q3_Eff is a dbForm
                    Entry_Item (q3_eff(server(current_object)))
                    Set Size to 13 42
                    Set Location to 71 164
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 4 0 "*%"
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Q3_Eff

                Object Jcoper_Q4_Eff is a dbForm
                    Entry_Item (q4_eff(server(current_object)))
                    Set Size to 13 42
                    Set Location to 71 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 4 0 "*%"
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Q4_Eff

                Object Jcoper_YTD_Eff is a dbForm
                    Entry_Item (ytd_eff(server(current_object)))
                    Set Size to 13 42
                    Set Location to 71 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 4 0 "*%"
                    //AB-StoreEnd

                End_Object    // Jcoper_YTD_Eff

            End_Object    // dbGroup4

        End_Object    // TP_Efficiency

        Object TP_Details is a dbTabPage
            Set Label to "Details"
            Object dbGroup5 is a dbGroup
                Set Size to 106 344
                Set Location to 8 7
                Set Label to "                                        1st Qtr.          2nd  Qtr.         3rd Qtr.           4th Qtr.           Y.T.D.        Last Year"
                Object Prevyr_SplHrs is a dbForm
                    Entry_Item Jcoper.Prevyr_splhrs
                    Set Size to 13 42
                    Set Location to 41 296
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Prevyr_SplHrs

                Object Prevyr_SplUnits is a dbForm
                    Entry_Item Jcoper.Prevyr_splunits
                    Set Size to 13 42
                    Set Location to 86 296
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Prevyr_SplUnits

                Object Q2_AltHrs is a dbForm
                    Entry_Item Jcoper.Q2_althrs
                    Set Size to 13 42
                    Set Location to 26 120
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q2_AltHrs

                Object Prevyr_RegHrs is a dbForm
                    Entry_Item Jcoper.Prevyr_reghrs
                    Set Size to 13 42
                    Set Location to 12 296
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Prevyr_RegHrs

                Object Prevyr_RegUnits is a dbForm
                    Entry_Item Jcoper.Prevyr_regunits
                    Set Size to 13 42
                    Set Location to 56 296
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    //AB-StoreEnd

                End_Object    // Prevyr_RegUnits

                Object Q1_AltUnits is a dbForm
                    Entry_Item Jcoper.Q1_altunits
                    Set Label to "Units Flagged Alt's"
                    Set Size to 13 42
                    Set Location to 71 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q1_AltUnits

                Object Q1_RegHrs is a dbForm
                    Entry_Item Jcoper.Q1_reghrs
                    Set Label to "Hrs. Not Flagged"
                    Set Size to 13 42
                    Set Location to 12 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q1_RegHrs

                Object Q2_RegHrs is a dbForm
                    Entry_Item Jcoper.Q2_reghrs
                    Set Size to 13 42
                    Set Location to 12 120
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q2_RegHrs

                Object Q3_RegHrs is a dbForm
                    Entry_Item Jcoper.Q3_reghrs
                    Set Size to 13 42
                    Set Location to 12 164
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q3_RegHrs

                Object Q4_RegHrs is a dbForm
                    Entry_Item Jcoper.Q4_reghrs
                    Set Size to 13 42
                    Set Location to 12 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q4_RegHrs

                Object YTD_RegHrs is a dbForm
                    Entry_Item Jcoper.Ttl_reghrs
                    Set Size to 13 42
                    Set Location to 12 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // YTD_RegHrs

                Object Q1_AltHrs is a dbForm
                    Entry_Item Jcoper.Q1_althrs
                    Set Label to "Hrs. Flagged Alt's"
                    Set Size to 13 42
                    Set Location to 26 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q1_AltHrs

                Object Prevyr_AltHrs is a dbForm
                    Entry_Item Jcoper.Prevyr_althrs
                    Set Size to 13 42
                    Set Location to 26 296
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Prevyr_AltHrs

                Object Q3_AltHrs is a dbForm
                    Entry_Item Jcoper.Q3_althrs
                    Set Size to 13 42
                    Set Location to 26 164
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q3_AltHrs

                Object Q4_AltHrs is a dbForm
                    Entry_Item Jcoper.Q4_althrs
                    Set Size to 13 42
                    Set Location to 26 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q4_AltHrs

                Object YTD_AltHrs is a dbForm
                    Entry_Item Jcoper.Ttl_althrs
                    Set Size to 13 42
                    Set Location to 26 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // YTD_AltHrs

                Object Q1_SplHrs is a dbForm
                    Entry_Item Jcoper.Q1_splhrs
                    Set Label to "Hrs. Flagged Spld."
                    Set Size to 13 42
                    Set Location to 41 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q1_SplHrs

                Object Q2_SplHrs is a dbForm
                    Entry_Item Jcoper.Q2_splhrs
                    Set Size to 13 42
                    Set Location to 41 120
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q2_SplHrs

                Object Q3_SplHrs is a dbForm
                    Entry_Item Jcoper.Q3_splhrs
                    Set Size to 13 42
                    Set Location to 41 164
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q3_SplHrs

                Object Q4_SplHrs is a dbForm
                    Entry_Item Jcoper.Q4_splhrs
                    Set Size to 13 42
                    Set Location to 41 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // Q4_SplHrs

                Object YTD_SplHrs is a dbForm
                    Entry_Item Jcoper.Ttl_splhrs
                    Set Size to 13 42
                    Set Location to 41 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 8 2 ",*"
                    //AB-StoreEnd

                End_Object    // YTD_SplHrs

                Object Q1_RegUnits is a dbForm
                    Entry_Item Jcoper.Q1_regunits
                    Set Label to "Units Not Flagged"
                    Set Size to 13 42
                    Set Location to 56 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q1_RegUnits

                Object Q2_RegUnits is a dbForm
                    Entry_Item Jcoper.Q2_regunits
                    Set Size to 13 42
                    Set Location to 56 120
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q2_RegUnits

                Object Q3_RegUnits is a dbForm
                    Entry_Item Jcoper.Q3_regunits
                    Set Size to 13 42
                    Set Location to 56 164
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q3_RegUnits

                Object Q4_RegUnits is a dbForm
                    Entry_Item Jcoper.Q4_regunits
                    Set Size to 13 42
                    Set Location to 56 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q4_RegUnits

                Object YTD_RegUnits is a dbForm
                    Entry_Item Jcoper.Ttl_regunits
                    Set Size to 13 42
                    Set Location to 56 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // YTD_RegUnits

                Object Prevyr_AltUnits is a dbForm
                    Entry_Item Jcoper.Prevyr_altunits
                    Set Size to 13 42
                    Set Location to 71 296
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Prevyr_AltUnits

                Object Q2_AltUnits is a dbForm
                    Entry_Item Jcoper.Q2_altunits
                    Set Size to 13 42
                    Set Location to 71 120
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q2_AltUnits

                Object Q3_AltUnits is a dbForm
                    Entry_Item Jcoper.Q3_altunits
                    Set Size to 13 42
                    Set Location to 71 164
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Q3_AltUnits

                Object Q4_AltUnits is a dbForm
                    Entry_Item Jcoper.Q4_altunits
                    Set Size to 13 42
                    Set Location to 71 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q4_AltUnits

                Object YTD_AltUnits is a dbForm
                    Entry_Item Jcoper.Ttl_altunits
                    Set Size to 13 42
                    Set Location to 71 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // YTD_AltUnits

                Object Q1_SplUnits is a dbForm
                    Entry_Item Jcoper.Q1_splunits
                    Set Label to "Units Flagged Spld."
                    Set Size to 13 42
                    Set Location to 86 76
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q1_SplUnits

                Object Q2_SplUnits is a dbForm
                    Entry_Item Jcoper.Q2_splunits
                    Set Size to 13 42
                    Set Location to 86 120
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q2_SplUnits

                Object Q3_SplUnits is a dbForm
                    Entry_Item Jcoper.Q3_splunits
                    Set Size to 13 42
                    Set Location to 86 164
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q3_SplUnits

                Object Q4_SplUnits is a dbForm
                    Entry_Item Jcoper.Q4_splunits
                    Set Size to 13 42
                    Set Location to 86 208
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // Q4_SplUnits

                Object YTD_SplUnits is a dbForm
                    Entry_Item Jcoper.Ttl_splunits
                    Set Size to 13 42
                    Set Location to 86 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    Set Numeric_Mask item 0 to 10 0 ",*"
                    
                    //AB-StoreEnd

                End_Object    // YTD_SplUnits

            End_Object    // dbGroup5

        End_Object    // TP_Details

    End_Object    // dbOperationsTabDialog

//    procedure AttachRecords
//        local integer hJcoperDD iCntr iOper
//        move (Jcoper_DD(self)) to hJcoperDD
//                move Jcoper.Cstctr_idno to iCntr
//        move Jcoper.Recnum to iOper
//        send Clear_All to hJcoperDD
//                move iCntr to Jccntr.Idno
//                send Request_Find to hJcoperDD EQ Jccntr.File_number 3
//        send Find_By_Recnum to hJcoperDD Jcoper.File_number iOper
//        send Activate_View
//    end_procedure
//    // right mouse button down
//    procedure Mouse_Down2
//        local integer hJcoperDD
//        move (Jcoper_DD(self)) to hJcoperDD
//        if NOT (Current_Record(hJcoperDD)) procedure_return
//        send Refind_Records to hJcoperDD
//        set Item_Shadow_State of (oViewFloatingMenu(self)) item 2 to true
//        send Popup To (oViewFloatingMenu(self))
//        set Item_Shadow_State of (oViewFloatingMenu(self)) item 2 to false
//    end_procedure
    
    on_Key Key_Alt+Key_1 Send SwitchToParametersTabPage
    on_Key Key_Alt+Key_2 Send SwitchToEfficiencyTabPage
    on_Key Key_Alt+Key_3 Send SwitchToDetailsTabPage
    //
    Procedure SwitchToParametersTabPage
        send Request_Switch_To_Tab to (dbOperationsTabDialog(self)) 0 3
    End_Procedure
    Procedure SwitchToEfficiencyTabPage
        send Request_Switch_To_Tab to (dbOperationsTabDialog(self)) 1 3
    End_Procedure
    Procedure SwitchToDetailsTabPage
        send Request_Switch_To_Tab to (dbOperationsTabDialog(self)) 2 3
    End_Procedure
    
    procedure Request_Clear
        forward send Request_Clear
        send Activate of Container1 //Beginning_Of_Panel
        send next of Container1
    end_procedure
    
    procedure Request_Clear_All
        forward send Request_Clear_All
        send Activate of Container1 //Beginning_Of_Panel
    end_procedure
    //
    // the following overridden procedure is here
    // to satisfy the Jcquot_SL
    Procedure DefaultQuoteInfo
    End_Procedure
    
//    Procedure Activating
//        boolean bReadOnly 
//        get pbReadonly of ghoApplication to bReadOnly
//        set pbReadonly to bReadOnly
//        set Read_Only_State of Jcoper_DD to bReadOnly
//        if bReadOnly Set Label to "Operations - READ ONLY"
//        Else Set Label to "Operations"
//    End_Procedure
//    
//    Procedure Request_Save
//        boolean bReadOnly
//        get pbReadOnly to bReadOnly
//        if bReadOnly Begin
//            send request_assign to Jcoper_DD
//            procedure_return
//        end
//        forward send request_save
//    End_Procedure
    
End_Object    // JCOPER
