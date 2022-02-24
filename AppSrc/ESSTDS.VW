// ESSTDS.vw

Register_Object Jcoper_Var1_Dflt_Value
Register_Object Jcoper_Var2_Dflt_Value
Register_Object Jcoper_Var3_Dflt_Value
Register_Object Jcoper_Var4_Dflt_Value
Register_Object Jcoper_Var5_Dflt_Value
Register_Object Jcoper_Var6_Dflt_Value
Register_Object Jcoper_Var7_Dflt_Value
Register_Object Jcoper_Var8_Dflt_Value
Register_Object Jcoper_Var9_Dflt_Value

Use Factor.dg
use Varsigns.dg
use CalcFlag.dg
use PrntFlag.dg
use FormulaEditor.dg
Use StdsHelp.dg
Use CLCENGIN.PKG
Use JCOPERDT.DG

Use cTempusDbView.pkg
Use cGlblDbForm.pkg
Use cGlblButton.pkg
Use cGlblDbComboForm.pkg
Use cGlblLineControl.pkg
Use dbTagForm.pkg

Use cJcdeptDataDictionary.dd
Use cJccntrDataDictionary.dd
Use JCOPER.DD


Activate_View Activate_oStandards for oStandards
Object oStandards is a cTempusDbView

    Property Boolean pbReadOnly
    Property Integer piCloneOpcode

    Set pbReloadStds to True

    // the following statement must reside in the AB-Ignore section
    // immediately following the "use *.DD" statements
    // define CE_CALC_TEST
    // use ClcEngin.pkg
    enumeration_list
        define VAR_TAG   for 0
        define CON_TAG   for 1
        define TABLE_TAG for 2
    end_enumeration_list

    Set Label to "Standards & Calculations"
    Set Location to 25 188
    Set Size to 296 493

    Object Jcdept_DD is a cJcdeptDataDictionary
    End_Object    // Jcdept_DD

    Object Jccntr_DD is a cJccntrDataDictionary
        Set DDO_Server to Jcdept_DD
        Set Foreign_Field_Options DD_KeyField To DD_Clear_Field_Options DD_FindReq
    End_Object    // Jccntr_DD

    Object Jcoper_DD is a Jcoper_DataDictionary
        Set DDO_Server to Jccntr_DD
        Set pbEditStandards to True
        //Set Constrain_File to Jccntr.File_Number
        send DefineAllExtendedFields

        Procedure Request_Save
            // since I removed the constrain_file to jccntr
            // I want to make sure the user can't save an inadvertant edit to the cost center
            If (Jcoper.Recnum >0 and Jcoper.CstCtr_Idno <> Jccntr.Idno) Begin
               send Stop_Box "Operations may not be reassigned to a different cost center"
               Procedure_return
            End
            Forward Send Request_Save
        End_Procedure

        Procedure InitializeEstimatingStandard
            set Field_Changed_Value field Jcoper.Est_std to "Y"
        End_Procedure

        procedure DoIncrementEsvarsRecordValues integer iOpcode integer iVarnum
            clear Esvars
            move iOpcode to Esvars.Opcode
            move 9       to Esvars.Varnum
            find LE Esvars by Index.1
            while ((FOUND) AND Esvars.Opcode = iOpcode AND Esvars.Varnum >= iVarnum)
                reread
                add 1 to Esvars.Varnum
                saverecord Esvars
                unlock
                find LT Esvars by Index.1
            Loop
        end_procedure
        //
        Procedure DoDecrementEsvarsRecordValues Integer iOpcode Integer iVarnum
            clear Esvars
            move iOpcode to Esvars.Opcode
            move iVarnum to Esvars.Varnum
            find GE Esvars by Index.1
            // first delete if records exist for iVarnum
            while ((FOUND) AND Esvars.Opcode = iOpcode AND Esvars.Varnum = iVarnum)
                lock
                delete Esvars
                unlock
                move iOpcode to Esvars.Opcode
                move iVarnum to Esvars.Varnum
                find GE Esvars by Index.1
            loop
            // decrement the rest
            while ((FOUND) AND Esvars.Opcode = iOpcode AND Esvars.Varnum > iVarnum)
                reread
                subtract 1 from Esvars.Varnum
                saverecord Esvars
                unlock
                find GT Esvars by Index.1
            Loop
        End_Procedure

        procedure MoveRowStringValue integer iOld integer iNew
            string sRowString
            get Field_Current_Value iOld to sRowString
            set Field_Changed_Value iNew to sRowString
            set Field_Changed_Value iOld to ""
        end_procedure
        procedure MoveRowNumberValue integer iOld integer iNew
            number nRowNumber
            get Field_Current_Value iOld to nRowNumber
            set Field_Changed_Value iNew to nRowNumber
            set Field_Changed_Value iOld to 0
        end_procedure
        //
        procedure InsertTagRow integer iStart integer iTagType
            boolean bEsvars bCancel bReadOnly
            integer iCurrent iOpcode iVarnum
            string  sTag
            number  nTag
            //
            Get pbReadOnly to bReadOnly
            if bReadOnly Begin
                send request_assign to Jcoper_DD
                procedure_return
            end
            // variables & constants are processed by row, 0-8
            // variables processed differently than constants
            if      (iTagType = VAR_TAG) begin
                // we can only insert if the 9th position is vacant
                get Field_Current_Value field Jcoper.Var9_tag to sTag
                if (sTag <> "") procedure_return
                // first check for Esvars records
                get Field_Current_Value field Jcoper.Opcode to iOpcode
                move (iStart + 1)                           to iVarnum
                clear Esvars
                move iOpcode to Esvars.Opcode
                move iVarnum to Esvars.Varnum
                find GE Esvars by Index.1
                move ((FOUND) AND Esvars.Opcode = iOpcode AND Esvars.Varnum >= iVarnum) to bEsvars
                if (bEsvars) begin
                    get Confirm "Standard Variable Modifiers will be adjusted" to bCancel
                    if (bCancel) procedure_return
                end
                begin_transaction
                if (bEsvars) send DoIncrementEsvarsRecordValues iOpcode iVarnum
                // starting with row 8, process thru iRow
                move 7 to iCurrent
                while (iCurrent >= iStart)
                    send MoveRowStringValue ( 91+iCurrent) ( 91+(iCurrent+1))
                    send MoveRowStringValue (233+iCurrent) (233+(iCurrent+1))
                    send MoveRowNumberValue (100+iCurrent) (100+(iCurrent+1))
                    send MoveRowNumberValue (109+iCurrent) (109+(iCurrent+1))
                    send MoveRowStringValue (118+iCurrent) (118+(iCurrent+1))
                    decrement iCurrent
                end
                if (bEsvars) send Request_Save
                end_transaction
            end //  if (iTagType = VAR_TAG)
            else if (iTagType = CON_TAG) begin // constants
                // we can only insert if the 9th position is vacant
                get Field_Current_Value field Jcoper.Con9_desc to sTag
                if (sTag <> "") procedure_return
                // starting with row 8, process thru iRow
                move 7 to iCurrent
                while (iCurrent >= iStart)
                    send MoveRowStringValue (127+iCurrent) (127+(iCurrent+1))
                    send MoveRowNumberValue (136+iCurrent) (136+(iCurrent+1))
                    send MoveRowNumberValue (145+iCurrent) (145+(iCurrent+1))
                    send MoveRowStringValue (154+iCurrent) (154+(iCurrent+1))
                    decrement iCurrent
                end
            end // else if (iTagType = CON_TAG)
            else if (iTagType = TABLE_TAG) begin
                // we can only insert if the 10th position is vacant
                get Field_Current_Value field Jcoper.Lookup10_value to nTag
                if (nTag <> 0) procedure_return
                // starting with row 9, process thru iRow
                move 8 to iCurrent
                while (iCurrent >= iStart)
                    send MoveRowNumberValue (168+ iCurrent)    (168+( iCurrent+1   ))
                    send MoveRowNumberValue (178+(iCurrent*5)) (178+((iCurrent*5)+5))
                    send MoveRowNumberValue (179+(iCurrent*5)) (179+((iCurrent*5)+5))
                    send MoveRowNumberValue (180+(iCurrent*5)) (180+((iCurrent*5)+5))
                    send MoveRowNumberValue (181+(iCurrent*5)) (181+((iCurrent*5)+5))
                    send MoveRowNumberValue (182+(iCurrent*5)) (182+((iCurrent*5)+5))
                    decrement iCurrent
                end
            end // else if (iTagType = TABLE_TAG)
        end_procedure // InsertTagRow
        //
        procedure DeleteTagRow integer iStart integer iTagType
            boolean bEsvars bCancel bReadOnly
            integer iOpcode iVarnum
            get pbReadOnly to bReadOnly
            if bReadOnly Begin
                send request_assign to Jcoper_DD
                procedure_return
            end
            // variables processed differently than constants
            if (iTagType = VAR_TAG) begin
                // first check for Esvars records
                get Field_Current_Value field Jcoper.Opcode to iOpcode
                move (iStart + 1)                           to iVarnum
                clear Esvars
                move iOpcode to Esvars.Opcode
                move iVarnum to Esvars.Varnum
                find GE Esvars by Index.1
                move ((FOUND) AND Esvars.Opcode = iOpcode AND Esvars.Varnum >= iVarnum) to bEsvars
                if (bEsvars) begin
                    get Confirm "Standard Variable Modifiers will be adjusted" to bCancel
                    if (bCancel) procedure_return
                end
                begin_transaction
                if (bEsvars) send DoDecrementEsvarsRecordValues iOpcode iVarnum
                // starting with current row process thru row 7
                while (iStart <= 7)
                    send MoveRowStringValue ( 91+(iStart+1)) ( 91+iStart)
                    send MoveRowStringValue (233+(iStart+1)) (233+iStart)
                    send MoveRowNumberValue (100+(iStart+1)) (100+iStart)
                    send MoveRowNumberValue (109+(iStart+1)) (109+iStart)
                    send MoveRowStringValue (118+(iStart+1)) (118+iStart)
                    increment iStart
                end
                //  blank line 8
                set Field_Changed_Value field Jcoper.Var9_tag        to ""
                set Field_Changed_Value field Jcoper.Var9_tag_symbl  to ""
                set Field_Changed_Value field Jcoper.Var9_dflt_value to 0
                set Field_Changed_Value field Jcoper.Var9_link_code  to 0
                set Field_Changed_Value field Jcoper.Var9_link_symbl to ""
                if (bEsvars) send Request_Save
                end_transaction
            end // if (iTagType = VAR_TAG)
            else if (iTagType = CON_TAG) begin // constants
                // starting with current row process thru row 7
                while (iStart <= 7)
                    send MoveRowStringValue (127+(iStart+1)) (127+iStart)
                    send MoveRowNumberValue (136+(iStart+1)) (136+iStart)
                    send MoveRowNumberValue (145+(iStart+1)) (145+iStart)
                    send MoveRowStringValue (154+(iStart+1)) (154+iStart)
                    increment iStart
                end
                // blank line 8
                set Field_Changed_Value field Jcoper.Con9_desc       to ""
                set Field_Changed_Value field Jcoper.Con9_value      to 0
                set Field_Changed_Value field Jcoper.Con9_link_code  to 0
                set Field_Changed_Value field Jcoper.Con9_link_symbl to ""
            end // else if (iTagType = CON_TAG)
            else if (iTagType = TABLE_TAG) begin
                // starting with current row process thru row 8
                while (iStart <= 8)
                    send MoveRowNumberValue (168+( iStart+1   )) (168+ iStart   )
                    send MoveRowNumberValue (178+((iStart*5)+5)) (178+(iStart*5))
                    send MoveRowNumberValue (179+((iStart*5)+5)) (179+(iStart*5))
                    send MoveRowNumberValue (180+((iStart*5)+5)) (180+(iStart*5))
                    send MoveRowNumberValue (181+((iStart*5)+5)) (181+(iStart*5))
                    send MoveRowNumberValue (182+((iStart*5)+5)) (182+(iStart*5))
                    increment iStart
                end
                //  blank line 9
                set Field_Changed_Value field Jcoper.Lookup10_value to 0
                set Field_Changed_Value field Jcoper.L10b1_std      to 0
                set Field_Changed_Value field Jcoper.L10b2_std      to 0
                set Field_Changed_Value field Jcoper.L10b3_std      to 0
                set Field_Changed_Value field Jcoper.L10b4_std      to 0
                set Field_Changed_Value field Jcoper.L10b5_std      to 0
            end // else if (iTagType = TABLE_TAG)
        end_procedure // DeleteTagRow

        procedure FactorTable number nFactor
            integer iField
            number  nValue
            //
            for iField from 178 to 227
                get Field_Current_Value iField to nValue
                set Field_Changed_Value iField to (nValue * nFactor)
            loop
        end_procedure // FactorTable
    End_Object    // Jcoper_DD

    Set Main_DD to Jcoper_DD
    Set Server to Jcoper_DD

    Object oStandardContainer is a dbContainer3d
        Set Size to 42 453
        Set Location to 5 5

        Object Jccntr_Idno is a dbForm
            Entry_Item Jccntr.Idno
            Set Label to "Cost Center"
            Set Size to 13 56
            Set Location to 5 66
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set Prompt_Button_Mode to pb_PromptOn
        End_Object    // Jccntr_Idno

        Object Jccntr_Name is a dbForm
            Entry_Item Jccntr.Name
            Set Size to 13 150
            Set Location to 5 125
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
        End_Object    // Jccntr_Name

        Object Jcoper_Opcode is a cGlblDbForm

            Property Integer pbLinker False
            
            Entry_Item Jcoper.Opcode
            Set Label to "Operation Code"
            Set Size to 13 56
            Set Location to 20 66
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set pbDataLoss to True

            Procedure Refresh Integer iMode
                boolean bReadOnly
                integer hJcoperDD
                string  sEststd
                get pbReadOnly to bReadOnly
                //
                Get Server to hJcoperDD
                Get Field_Current_Value of hJcoperDD field Jcoper.Est_std to sEststd
                forward send Refresh iMode
                send EnablePrintButton    (sEststd="Y")
                send EnableCalcButton     (sEststd="Y")
                send EnableHelpTextButton (sEststd="Y" and not(bReadOnly))
                send EnableCloneButton    (Current_Record(hJcoperDD) AND sEststd="" and not(bReadOnly))
            End_Procedure
            
            procedure PrimeList
                integer iLinkCode iSeedObj iCCNo iOpcode iOpIdno iCloneOpcode
                boolean bClone
                get piCcno   of Jcoper_sl to iCcno
                get piOpIdno of Jcoper_sl to iOpIdno
                get piOpcode of Jcoper_sl to iOpcode
                //
                get pbClone of Jcoper_sl  to bClone
                if bClone Begin
                    get piCloneOpcode to iCloneOpcode
                    if (iOpcode=0) get value of (Jcoper_Opcode(self)) to iOpcode
                    if (iCloneOpcode) move iCloneOpcode to Jcoper.Opcode
                    else              move iOpcode      to Jcoper.Opcode
                    Find GE Jcoper.Opcode
                    procedure_return
                end
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
                else if (Jcoper.Recnum=0 and iOpcode<>0) begin
                    move iOpcode to Jcoper.Opcode
                    Find GE Jcoper.Opcode
                end
                if (found) send request_assign to jcoper_dd
            end_procedure

            Procedure Prompt
                integer iCcno iOpcode
                get value    of Jcoper_Opcode to iOpcode
                get value    of Jccntr_Idno   to iCcno
                set piCCno   of Jcoper_sl     to iCcno
                set piOpcode of Jcoper_sl     to iOpcode
                set piOpIdno of Jcoper_sl     to (iOpcode-(iCCno *1000))
                forward send prompt
            End_procedure
            
            //set Exit_Msg to OpcodeExit
            //Procedure OpcodeExit //Refresh integer iMode
            //    integer hJcoperDD bClear
            //    string sEststd
            //    get Server to hJcoperDD
            //    if not (Current_Record(hJcoperDD)) procedure_return
            //    get Field_Current_Value of hJcoperDD ;
            //        field Jcoper.Est_std to sEststd
            //    if sEststd eq "Y" procedure_return
            //    get Confirm ("This Operation is not an Estimating Standard." + ;
            //        "\n\nDo you want to make it an Estimating Standard?") ;
            //        to bClear
            //    if bClear send Request_Clear
            //    else send InitializeEstimatingStandard to hJcoperDD
            //End_Procedure
        End_Object    // Jcoper_Opcode

        Object Jcoper_Name is a dbForm
            Entry_Item Jcoper.Name
            Set Size to 13 150
            Set Location to 20 125
            Set Label_Col_Offset to 2
            Set Label_Justification_Mode to jMode_Right
            Set Enabled_State to False
        End_Object    // Jcoper_Name

        Object PrintButton is a cGlblButton
            Set Label to "Sh+F4 Print Standard"
            Set Size to 14 80
            Set Location to 5 280

            procedure OnClick
                send PrintStandard
            end_procedure
        End_Object    // PrintButton

        Object CalcButton is a cGlblButton
            Set Label to "Test &Calculation"
            Set Size to 14 80
            Set Location to 5 365

            register_object CalcEngine
            procedure OnClick
                send DoCalculate
            end_procedure
        End_Object    // CalcButton

        Object oHelpTextButton is a cGlblButton
            Set Label to "Maintain Help &Text"
            Set Size to 14 80
            Set Location to 20 280

            Procedure OnClick
                Send doMaintainHelp
            End_Procedure // OnClick
        End_Object    // oHelpTextButton

        Object CloneButton is a cGlblButton

            Property Integer pbLinker

            Set Label to "Clone &Standard"
            Set Size to 14 80
            Set Location to 20 365

            register_object CalcEngine
            procedure OnClick
                send DoCloneOperation
            end_procedure
        End_Object    // CloneButton

        Procedure EnablePrintButton integer bState
            set Enabled_State of (PrintButton(self)) to bState
        End_Procedure
        
        Procedure EnableCalcButton integer bState
            set Enabled_State of (CalcButton(self)) to bState
        End_Procedure
        
        Procedure EnableHelpTextButton integer bState
            set Enabled_State of (oHelpTextButton(self)) to bState
        End_Procedure
        
        Procedure DoHelpTextButton
            Send KeyAction of oHelpTextButton
        End_Procedure
        
        Procedure DoCalculate
            Integer hDD
            //
            Get Server          to hDD
            Send Refind_Records of hDD
            If (not(Jcoper.Recnum)) Begin
                Send Stop_Box "No record to calculate."
                Procedure_Return
            End
            Send DoTestEngine   of oCalcEngine
            send Refind_Records of hDD
            send Activate       of Jcoper_Opcode
        End_Procedure
        
        Procedure DoCalcButton
            send KeyAction of CalcButton
        End_Procedure
        
        Procedure EnableCloneButton integer bState
            set Enabled_State of CloneButton to bState
        End_Procedure
        
        Procedure DoMaintainHelp
            integer iCC iOpcode
            string  sCCName sOpName
            //
            move Jcoper.CstCtr_Idno to iCC
            move Jcoper.Opcode      to iOpcode
            move Jccntr.Name        to sCCName
            move Jcoper.Name        to sOpName
            send doEditStdsHelp of oStdsHelpDialog iCC iOpcode sCCName sOpName
        End_Procedure
        
        Procedure DoCloneOperation
            integer hJcoperDD iOldOp iNewOp bQuit iEsvarsRecnum
            //
            get Server to hJcoperDD
            get Field_Current_Value of hJcoperDD field Jcoper.Opcode to iNewOp
            set pbClone   of Jcoper_SL to TRUE
            set piSeedObj of Jcoper_SL to (Jcoper_Opcode(self))
            //set Move_Value_Out_State of (Jcoper_SL(self)) to false
            clear Jccntr Jcdept
            send Popup of Jcoper_SL
            //get CloneOperationStandard of (Jcoper_SL(self)) to iOldOp
            if (Jcoper.Opcode=0) move iNewOp to iOldOp
            else move Jcoper.Opcode to iOldOp
            //SEND INFO_BOX IOLDOP
            set pbClone of Jcoper_SL to FALSE
            //set Move_Value_Out_State of (Jcoper_SL(self)) to true
            // if no code selected quit
            if (iOldOp = iNewOp) procedure_return
            // if selected confirm
            get Confirm "Clone Operation?" to bQuit
            if (bQuit) procedure_return
            //
            set pbUsesSystemLog of hJcoperDD to FALSE
            //
            set Field_Changed_Value of hJcoperDD  69 to "Y"
            set Field_Changed_Value of hJcoperDD  77 to Jcoper.LOOKUP_VAR       //ASC      1   333
            set Field_Changed_Value of hJcoperDD  78 to Jcoper.BRACKET_VAR      //ASC      1   334
            set Field_Changed_Value of hJcoperDD  79 to Jcoper.PRORATE_BRACKET  //ASC      1   335
            set Field_Changed_Value of hJcoperDD  80 to Jcoper.PRORATE_LOOKUP   //ASC      1   336
            set Field_Changed_Value of hJcoperDD  81 to Jcoper.CALC_FLAGS       //ASC     26   337
            set Field_Changed_Value of hJcoperDD  82 to Jcoper.FORMULA          //ASC     54   363
            set Field_Changed_Value of hJcoperDD  83 to Jcoper.EST_FORMULA      //ASC     54   417
            set Field_Changed_Value of hJcoperDD  84 to Jcoper.EST_FORMULA_TYP  //ASC      1   471
            set Field_Changed_Value of hJcoperDD  85 to Jcoper.CALC_UNITS_DESC  //ASC     14   472
            set Field_Changed_Value of hJcoperDD  86 to Jcoper.TABLE_STD_DESC   //ASC     14   486
            set Field_Changed_Value of hJcoperDD  87 to Jcoper.LOOKUP_DESC      //ASC     14   500
            set Field_Changed_Value of hJcoperDD  88 to Jcoper.BRACKET_DESC     //ASC     14   514
            set Field_Changed_Value of hJcoperDD  89 to Jcoper.LINK_DEPTH       //NUM    2.0   528
            set Field_Changed_Value of hJcoperDD  90 to Jcoper.LINK_SYMBOL      //ASC      1   529
            set Field_Changed_Value of hJcoperDD  91 to Jcoper.VAR1_TAG         //ASC     30   530
            set Field_Changed_Value of hJcoperDD  92 to Jcoper.VAR2_TAG         //ASC     30   560
            set Field_Changed_Value of hJcoperDD  93 to Jcoper.VAR3_TAG         //ASC     30   590
            set Field_Changed_Value of hJcoperDD  94 to Jcoper.VAR4_TAG         //ASC     30   620
            set Field_Changed_Value of hJcoperDD  95 to Jcoper.VAR5_TAG         //ASC     30   650
            set Field_Changed_Value of hJcoperDD  96 to Jcoper.VAR6_TAG         //ASC     30   680
            set Field_Changed_Value of hJcoperDD  97 to Jcoper.VAR7_TAG         //ASC     30   710
            set Field_Changed_Value of hJcoperDD  98 to Jcoper.VAR8_TAG         //ASC     30   740
            set Field_Changed_Value of hJcoperDD  99 to Jcoper.VAR9_TAG         //ASC     30   770
            set Field_Changed_Value of hJcoperDD 100 to Jcoper.VAR1_DFLT_Value  //NUM    8.4   800
            set Field_Changed_Value of hJcoperDD 101 to Jcoper.VAR2_DFLT_Value  //NUM    8.4   806
            set Field_Changed_Value of hJcoperDD 102 to Jcoper.VAR3_DFLT_VALUE  //NUM    8.4   812
            set Field_Changed_Value of hJcoperDD 103 to Jcoper.VAR4_DFLT_VALUE  //NUM    8.4   818
            set Field_Changed_Value of hJcoperDD 104 to Jcoper.VAR5_DFLT_VALUE  //NUM    8.4   824
            set Field_Changed_Value of hJcoperDD 105 to Jcoper.VAR6_DFLT_VALUE  //NUM    8.4   830
            set Field_Changed_Value of hJcoperDD 106 to Jcoper.VAR7_DFLT_VALUE  //NUM    8.4   836
            set Field_Changed_Value of hJcoperDD 107 to Jcoper.VAR8_DFLT_VALUE  //NUM    8.4   842
            set Field_Changed_Value of hJcoperDD 108 to Jcoper.VAR9_DFLT_VALUE  //NUM    8.4   848
            set Field_Changed_Value of hJcoperDD 109 to Jcoper.VAR1_LINK_CODE   //NUM    8.0   854
            set Field_Changed_Value of hJcoperDD 110 to Jcoper.VAR2_LINK_CODE   //NUM    8.0   858
            set Field_Changed_Value of hJcoperDD 111 to Jcoper.VAR3_LINK_CODE   //NUM    8.0   862
            set Field_Changed_Value of hJcoperDD 112 to Jcoper.VAR4_LINK_CODE   //NUM    8.0   866
            set Field_Changed_Value of hJcoperDD 113 to Jcoper.VAR5_LINK_CODE   //NUM    8.0   870
            set Field_Changed_Value of hJcoperDD 114 to Jcoper.VAR6_LINK_CODE   //NUM    8.0   874
            set Field_Changed_Value of hJcoperDD 115 to Jcoper.VAR7_LINK_CODE   //NUM    8.0   878
            set Field_Changed_Value of hJcoperDD 116 to Jcoper.VAR8_LINK_CODE   //NUM    8.0   882
            set Field_Changed_Value of hJcoperDD 117 to Jcoper.VAR9_LINK_CODE   //NUM    8.0   886
            set Field_Changed_Value of hJcoperDD 118 to Jcoper.VAR1_LINK_SYMBL  //ASC      1   890
            set Field_Changed_Value of hJcoperDD 119 to Jcoper.VAR2_LINK_SYMBL  //ASC      1   891
            set Field_Changed_Value of hJcoperDD 120 to Jcoper.VAR3_LINK_SYMBL  //ASC      1   892
            set Field_Changed_Value of hJcoperDD 121 to Jcoper.VAR4_LINK_SYMBL  //ASC      1   893
            set Field_Changed_Value of hJcoperDD 122 to Jcoper.VAR5_LINK_SYMBL  //ASC      1   894
            set Field_Changed_Value of hJcoperDD 123 to Jcoper.VAR6_LINK_SYMBL  //ASC      1   895
            set Field_Changed_Value of hJcoperDD 124 to Jcoper.VAR7_LINK_SYMBL  //ASC      1   896
            set Field_Changed_Value of hJcoperDD 125 to Jcoper.VAR8_LINK_SYMBL  //ASC      1   897
            set Field_Changed_Value of hJcoperDD 126 to Jcoper.VAR9_LINK_SYMBL  //ASC      1   898
            set Field_Changed_Value of hJcoperDD 127 to Jcoper.CON1_DESC        //ASC     30   899
            set Field_Changed_Value of hJcoperDD 128 to Jcoper.CON2_DESC        //ASC     30   929
            set Field_Changed_Value of hJcoperDD 129 to Jcoper.CON3_DESC        //ASC     30   959
            set Field_Changed_Value of hJcoperDD 130 to Jcoper.CON4_DESC        //ASC     30   989
            set Field_Changed_Value of hJcoperDD 131 to Jcoper.CON5_DESC        //ASC     30  1019
            set Field_Changed_Value of hJcoperDD 132 to Jcoper.CON6_DESC        //ASC     30  1049
            set Field_Changed_Value of hJcoperDD 133 to Jcoper.CON7_DESC        //ASC     30  1079
            set Field_Changed_Value of hJcoperDD 134 to Jcoper.CON8_DESC        //ASC     30  1109
            set Field_Changed_Value of hJcoperDD 135 to Jcoper.CON9_DESC        //ASC     30  1139
            set Field_Changed_Value of hJcoperDD 136 to Jcoper.CON1_VALUE       //NUM    8.4  1169
            set Field_Changed_Value of hJcoperDD 137 to Jcoper.CON2_VALUE       //NUM    8.4  1175
            set Field_Changed_Value of hJcoperDD 138 to Jcoper.CON3_VALUE       //NUM    8.4  1181
            set Field_Changed_Value of hJcoperDD 139 to Jcoper.CON4_VALUE       //NUM    8.4  1187
            set Field_Changed_Value of hJcoperDD 140 to Jcoper.CON5_VALUE       //NUM    8.4  1193
            set Field_Changed_Value of hJcoperDD 141 to Jcoper.CON6_VALUE       //NUM    8.4  1199
            set Field_Changed_Value of hJcoperDD 142 to Jcoper.CON7_VALUE       //NUM    8.4  1205
            set Field_Changed_Value of hJcoperDD 143 to Jcoper.CON8_VALUE       //NUM    8.4  1211
            set Field_Changed_Value of hJcoperDD 144 to Jcoper.CON9_VALUE       //NUM    8.4  1217
            set Field_Changed_Value of hJcoperDD 145 to Jcoper.CON1_LINK_CODE   //NUM    8.0  1223
            set Field_Changed_Value of hJcoperDD 146 to Jcoper.CON2_LINK_CODE   //NUM    8.0  1227
            set Field_Changed_Value of hJcoperDD 147 to Jcoper.CON3_LINK_CODE   //NUM    8.0  1231
            set Field_Changed_Value of hJcoperDD 148 to Jcoper.CON4_LINK_CODE   //NUM    8.0  1235
            set Field_Changed_Value of hJcoperDD 149 to Jcoper.CON5_LINK_CODE   //NUM    8.0  1239
            set Field_Changed_Value of hJcoperDD 150 to Jcoper.CON6_LINK_CODE   //NUM    8.0  1243
            set Field_Changed_Value of hJcoperDD 151 to Jcoper.CON7_LINK_CODE   //NUM    8.0  1247
            set Field_Changed_Value of hJcoperDD 152 to Jcoper.CON8_LINK_CODE   //NUM    8.0  1251
            set Field_Changed_Value of hJcoperDD 153 to Jcoper.CON9_LINK_CODE   //NUM    8.0  1255
            set Field_Changed_Value of hJcoperDD 154 to Jcoper.CON1_LINK_SYMBL  //ASC      1  1259
            set Field_Changed_Value of hJcoperDD 155 to Jcoper.CON2_LINK_SYMBL  //ASC      1  1260
            set Field_Changed_Value of hJcoperDD 156 to Jcoper.CON3_LINK_SYMBL  //ASC      1  1261
            set Field_Changed_Value of hJcoperDD 157 to Jcoper.CON4_LINK_SYMBL  //ASC      1  1262
            set Field_Changed_Value of hJcoperDD 158 to Jcoper.CON5_LINK_SYMBL  //ASC      1  1263
            set Field_Changed_Value of hJcoperDD 159 to Jcoper.CON6_LINK_SYMBL  //ASC      1  1264
            set Field_Changed_Value of hJcoperDD 160 to Jcoper.CON7_LINK_SYMBL  //ASC      1  1265
            set Field_Changed_Value of hJcoperDD 161 to Jcoper.CON8_LINK_SYMBL  //ASC      1  1266
            set Field_Changed_Value of hJcoperDD 162 to Jcoper.CON9_LINK_SYMBL  //ASC      1  1267
            set Field_Changed_Value of hJcoperDD 163 to Jcoper.BRACKET1_VALUE   //NUM    8.4  1268
            set Field_Changed_Value of hJcoperDD 164 to Jcoper.BRACKET2_VALUE   //NUM    8.4  1274
            set Field_Changed_Value of hJcoperDD 165 to Jcoper.BRACKET3_VALUE   //NUM    8.4  1280
            set Field_Changed_Value of hJcoperDD 166 to Jcoper.BRACKET4_VALUE   //NUM    8.4  1286
            set Field_Changed_Value of hJcoperDD 167 to Jcoper.BRACKET5_VALUE   //NUM    8.4  1292
            set Field_Changed_Value of hJcoperDD 168 to Jcoper.LOOKUP1_VALUE    //NUM    8.4  1298
            set Field_Changed_Value of hJcoperDD 169 to Jcoper.LOOKUP2_VALUE    //NUM    8.4  1304
            set Field_Changed_Value of hJcoperDD 170 to Jcoper.LOOKUP3_VALUE    //NUM    8.4  1310
            set Field_Changed_Value of hJcoperDD 171 to Jcoper.LOOKUP4_VALUE    //NUM    8.4  1316
            set Field_Changed_Value of hJcoperDD 172 to Jcoper.LOOKUP5_VALUE    //NUM    8.4  1322
            set Field_Changed_Value of hJcoperDD 173 to Jcoper.LOOKUP6_VALUE    //NUM    8.4  1328
            set Field_Changed_Value of hJcoperDD 174 to Jcoper.LOOKUP7_VALUE    //NUM    8.4  1334
            set Field_Changed_Value of hJcoperDD 175 to Jcoper.LOOKUP8_VALUE    //NUM    8.4  1340
            set Field_Changed_Value of hJcoperDD 176 to Jcoper.LOOKUP9_VALUE    //NUM    8.4  1346
            set Field_Changed_Value of hJcoperDD 177 to Jcoper.LOOKUP10_VALUE   //NUM    8.4  1352
            set Field_Changed_Value of hJcoperDD 178 to Jcoper.L1B1_STD         //NUM    6.4  1358
            set Field_Changed_Value of hJcoperDD 179 to Jcoper.L1B2_STD         //NUM    6.4  1363
            set Field_Changed_Value of hJcoperDD 180 to Jcoper.L1B3_STD         //NUM    6.4  1368
            set Field_Changed_Value of hJcoperDD 181 to Jcoper.L1B4_STD         //NUM    6.4  1373
            set Field_Changed_Value of hJcoperDD 182 to Jcoper.L1B5_STD         //NUM    6.4  1378
            set Field_Changed_Value of hJcoperDD 183 to Jcoper.L2B1_STD         //NUM    6.4  1383
            set Field_Changed_Value of hJcoperDD 184 to Jcoper.L2B2_STD         //NUM    6.4  1388
            set Field_Changed_Value of hJcoperDD 185 to Jcoper.L2B3_STD         //NUM    6.4  1393
            set Field_Changed_Value of hJcoperDD 186 to Jcoper.L2B4_STD         //NUM    6.4  1398
            set Field_Changed_Value of hJcoperDD 187 to Jcoper.L2B5_STD         //NUM    6.4  1403
            set Field_Changed_Value of hJcoperDD 188 to Jcoper.L3B1_STD         //NUM    6.4  1408
            set Field_Changed_Value of hJcoperDD 189 to Jcoper.L3B2_STD         //NUM    6.4  1413
            set Field_Changed_Value of hJcoperDD 190 to Jcoper.L3B3_STD         //NUM    6.4  1418
            set Field_Changed_Value of hJcoperDD 191 to Jcoper.L3B4_STD         //NUM    6.4  1423
            set Field_Changed_Value of hJcoperDD 192 to Jcoper.L3B5_STD         //NUM    6.4  1428
            set Field_Changed_Value of hJcoperDD 193 to Jcoper.L4B1_STD         //NUM    6.4  1433
            set Field_Changed_Value of hJcoperDD 194 to Jcoper.L4B2_STD         //NUM    6.4  1438
            set Field_Changed_Value of hJcoperDD 195 to Jcoper.L4B3_STD         //NUM    6.4  1443
            set Field_Changed_Value of hJcoperDD 196 to Jcoper.L4B4_STD         //NUM    6.4  1448
            set Field_Changed_Value of hJcoperDD 197 to Jcoper.L4B5_STD         //NUM    6.4  1453
            set Field_Changed_Value of hJcoperDD 198 to Jcoper.L5B1_STD         //NUM    6.4  1458
            set Field_Changed_Value of hJcoperDD 199 to Jcoper.L5B2_STD         //NUM    6.4  1463
            set Field_Changed_Value of hJcoperDD 200 to Jcoper.L5B3_STD         //NUM    6.4  1468
            set Field_Changed_Value of hJcoperDD 201 to Jcoper.L5B4_STD         //NUM    6.4  1473
            set Field_Changed_Value of hJcoperDD 202 to Jcoper.L5B5_STD         //NUM    6.4  1478
            set Field_Changed_Value of hJcoperDD 203 to Jcoper.L6B1_STD         //NUM    6.4  1483
            set Field_Changed_Value of hJcoperDD 204 to Jcoper.L6B2_STD         //NUM    6.4  1488
            set Field_Changed_Value of hJcoperDD 205 to Jcoper.L6B3_STD         //NUM    6.4  1493
            set Field_Changed_Value of hJcoperDD 206 to Jcoper.L6B4_STD         //NUM    6.4  1498
            set Field_Changed_Value of hJcoperDD 207 to Jcoper.L6B5_STD         //NUM    6.4  1503
            set Field_Changed_Value of hJcoperDD 208 to Jcoper.L7B1_STD         //NUM    6.4  1508
            set Field_Changed_Value of hJcoperDD 209 to Jcoper.L7B2_STD         //NUM    6.4  1513
            set Field_Changed_Value of hJcoperDD 210 to Jcoper.L7B3_STD         //NUM    6.4  1518
            set Field_Changed_Value of hJcoperDD 211 to Jcoper.L7B4_STD         //NUM    6.4  1523
            set Field_Changed_Value of hJcoperDD 212 to Jcoper.L7B5_STD         //NUM    6.4  1528
            set Field_Changed_Value of hJcoperDD 213 to Jcoper.L8B1_STD         //NUM    6.4  1533
            set Field_Changed_Value of hJcoperDD 214 to Jcoper.L8B2_STD         //NUM    6.4  1538
            set Field_Changed_Value of hJcoperDD 215 to Jcoper.L8B3_STD         //NUM    6.4  1543
            set Field_Changed_Value of hJcoperDD 216 to Jcoper.L8B4_STD         //NUM    6.4  1548
            set Field_Changed_Value of hJcoperDD 217 to Jcoper.L8B5_STD         //NUM    6.4  1553
            set Field_Changed_Value of hJcoperDD 218 to Jcoper.L9B1_STD         //NUM    6.4  1558
            set Field_Changed_Value of hJcoperDD 219 to Jcoper.L9B2_STD         //NUM    6.4  1563
            set Field_Changed_Value of hJcoperDD 220 to Jcoper.L9B3_STD         //NUM    6.4  1568
            set Field_Changed_Value of hJcoperDD 221 to Jcoper.L9B4_STD         //NUM    6.4  1573
            set Field_Changed_Value of hJcoperDD 222 to Jcoper.L9B5_STD         //NUM    6.4  1578
            set Field_Changed_Value of hJcoperDD 223 to Jcoper.L10B1_STD        //NUM    6.4  1583
            set Field_Changed_Value of hJcoperDD 224 to Jcoper.L10B2_STD        //NUM    6.4  1588
            set Field_Changed_Value of hJcoperDD 225 to Jcoper.L10B3_STD        //NUM    6.4  1593
            set Field_Changed_Value of hJcoperDD 226 to Jcoper.L10B4_STD        //NUM    6.4  1598
            set Field_Changed_Value of hJcoperDD 227 to Jcoper.L10B5_STD        //NUM    6.4  1603
            set Field_Changed_Value of hJcoperDD 228 to Jcoper.VALUE1_PASS      //NUM    8.4  1608
            set Field_Changed_Value of hJcoperDD 229 to Jcoper.VALUE2_PASS      //NUM    8.4  1614
            set Field_Changed_Value of hJcoperDD 230 to Jcoper.VALUE3_PASS      //NUM    8.4  1620
            set Field_Changed_Value of hJcoperDD 231 to Jcoper.CALC_STD_DESC    //ASC     14  1626
            set Field_Changed_Value of hJcoperDD 232 to Jcoper.MULTI_VAL_FLAG   //ASC      1  1640
            set Field_Changed_Value of hJcoperDD 233 to Jcoper.VAR1_TAG_SYMBL   //ASC     15  1641
            set Field_Changed_Value of hJcoperDD 234 to Jcoper.VAR2_TAG_SYMBL   //ASC     15  1656
            set Field_Changed_Value of hJcoperDD 235 to Jcoper.VAR3_TAG_SYMBL   //ASC     15  1671
            set Field_Changed_Value of hJcoperDD 236 to Jcoper.VAR4_TAG_SYMBL   //ASC     15  1686
            set Field_Changed_Value of hJcoperDD 237 to Jcoper.VAR5_TAG_SYMBL   //ASC     15  1701
            set Field_Changed_Value of hJcoperDD 238 to Jcoper.VAR6_TAG_SYMBL   //ASC     15  1716
            set Field_Changed_Value of hJcoperDD 239 to Jcoper.VAR7_TAG_SYMBL   //ASC     15  1731
            set Field_Changed_Value of hJcoperDD 240 to Jcoper.VAR8_TAG_SYMBL   //ASC     15  1746
            set Field_Changed_Value of hJcoperDD 241 to Jcoper.VAR9_TAG_SYMBL   //ASC     15  1761
            set Field_Changed_Value of hJcoperDD 242 to Jcoper.PRINT_FLAGS      //ASC     26  1776
            set Field_Changed_Value of hJcoperDD 243 to Jcoper.PICKLIST_CODE    //ASC      1
            set Field_Changed_Value of hJcoperDD 244 to Jcoper.C1_TAG_SYMBL     //ASC      6  1820
            set Field_Changed_Value of hJcoperDD 245 to Jcoper.C1_LINK_CODE     //NUM    6.0  1826
            set Field_Changed_Value of hJcoperDD 246 to Jcoper.C1_LINK_SYMBL    //ASC      1  1829
            set Field_Changed_Value of hJcoperDD 247 to Jcoper.C2_TAG_SYMBL     //ASC      6  1830
            set Field_Changed_Value of hJcoperDD 248 to Jcoper.C2_LINK_CODE     //NUM    6.0  1836
            set Field_Changed_Value of hJcoperDD 249 to Jcoper.C2_LINK_SYMBL    //ASC      1  1839
            set Field_Changed_Value of hJcoperDD 250 to Jcoper.C3_TAG_SYMBL     //ASC      6  1840
            set Field_Changed_Value of hJcoperDD 251 to Jcoper.C3_LINK_CODE     //NUM    6.0  1846
            set Field_Changed_Value of hJcoperDD 252 to Jcoper.C3_LINK_SYMBL    //ASC      1  1849
            set Field_Changed_Value of hJcoperDD 253 to Jcoper.SELL_FORMULA     //ASC     54  1850
            set Field_Changed_Value of hJcoperDD 254 to Jcoper.INSTRCTN_FORM    //TEX    512  2084
            //
            send Request_Save of hJcoperDD
            //
            if (NOT(Should_Save(self))) begin // clone any extended data
                clear Esvars
                move iOldOp to Esvars.Opcode
                find GE Esvars.Opcode
                while ((FOUND) AND Esvars.Opcode = iOldOp)
                    move Esvars.Recnum to iEsvarsRecnum
                    move 0             to Esvars.Recnum
                    move iNewop        to Esvars.Opcode
                    saverecord Esvars
                    clear Esvars
                    move iEsvarsRecnum to Esvars.Recnum
                    find EQ Esvars.Recnum
                    find GT Esvars.Opcode
                loop
                clear Esvars
            end
            set pbUsesSystemLog of hJcoperDD to TRUE
            send Refind_Records of hJcoperDD
            send Display
        End_Procedure
        //
        on_key Key_Alt+Key_S send KeyAction of CloneButton

    End_Object    // oStandardContainer

    Object dbStandardsTabDialog is a dbTabDialog

        Property Integer pbLinker True
        
        procedure LinkSymbolPrompt integer iField
            integer hDD iOpcode
            get Server to hDD
            get Field_Current_Value of hDD iField to iOpcode
            if NOT iOpcode procedure_return
            send LinkSymbolPrompt ;
                to (JcoperDetailDialog(Self)) iOpcode
            send Refind_Records to hDD
        end_procedure

        Set Size to 232 483
        Set Location to 55 5
        Set Rotate_Mode to RM_Rotate
        Object TP_Formula_Variables is a dbTabPage
            Set Label to "Formula Variables"

            Object dbGroup2 is a dbGroup
                Set Size to 150 469
                Set Location to 5 5
                Set Label to "     Prompt                                                                                    Execution Modifier Signs                Default Value               Link Code    /   Symbol    "

                Object Jcoper_Var1_Tag is a dbTagForm
                    Entry_Item Jcoper.Var1_tag
                    Set Label to "1)"
                    Set Size to 13 186
                    Set Location to 10 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 0 VAR_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        //if (Value(self,0)=0) procedure_return
                        send DeleteTagRow to (Server(self)) 0 VAR_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        // no previous row
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Var2_Tag(self))
                    end_procedure // NextTagRow
                End_Object    // Jcoper_Var1_Tag

                Object Jcoper_Var1_Tag_Symbl is a dbForm
                    Entry_Item Jcoper.Var1_tag_symbl
                    Set Size to 13 96
                    Set Location to 10 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send DoModifiers
                    end_procedure
                    
                    procedure DoModifiers
                        integer hoDefault iCC iOpcode
                        string  sWasModifiers sModifiers
                        number  nWasDefault nDefault
                        //
                        move Jcoper_Var1_Dflt_Value to hoDefault
                        //
                        get Value                                              to sWasModifiers
                        get Value of hoDefault                                 to nWasDefault
                        if      (sWasModifiers CONTAINS "CC") move nWasDefault to iCC
                        else if (sWasModifiers CONTAINS "OP") move nWasDefault to iOpcode
                        //
                        get IsModifiers of odgStdModifiers 1 sWasModifiers iCC iOpcode to sModifiers
                        if (sModifiers = "CANCEL") procedure_return
                        //
                        move 0 to nDefault
                        if (sModifiers CONTAINS "CC") get piCC     of odgStdModifiers to nDefault
                        else if (sModifiers CONTAINS "OP") get piOpcode of odgStdModifiers to nDefault
                        //
                        //if (nDefault <> nWasDefault) begin
                        if (((sModifiers CONTAINS "CC") or (sModifiers CONTAINS "OP")) ;
                            and (nDefault <> nWasDefault) )begin
                                set Value              of hoDefault to nDefault
                                set Item_Changed_State of hoDefault to TRUE
                        end
                        //
                        if (sModifiers <> sWasModifiers) begin
                            set Value              to sModifiers
                            set Item_Changed_State to TRUE
                        end
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var1_Tag_Symbl

                Object Jcoper_Var1_Dflt_Value is a dbForm
                    Entry_Item Jcoper.Var1_dflt_value
                    Set Size to 13 68
                    Set Location to 10 305
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Var1_Dflt_Value

                Object Jcoper_Var1_Link_Code is a dbForm
                    Entry_Item Jcoper.Var1_link_code
                    Set Size to 13 58
                    Set Location to 10 377
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                End_Object    // Jcoper_Var1_Link_Code

                Object Jcoper_Var1_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Var1_link_symbl
                    Set Size to 13 25
                    Set Location to 10 438
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    procedure Prompt
                        send LinkSymbolPrompt 109
                    end_procedure
                End_Object    // Jcoper_Var1_Link_Symbl

                Object Jcoper_Var2_Tag is a dbTagForm
                    Entry_Item Jcoper.Var2_tag
                    Set Label to "2)"
                    Set Size to 13 186
                    Set Location to 25 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 1 VAR_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 1 VAR_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Var1_Tag(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Var3_Tag(self))
                    end_procedure // NextTagRow
                End_Object    // Jcoper_Var2_Tag

                Object Jcoper_Var2_Tag_Symbl is a dbForm
                    Entry_Item Jcoper.Var2_tag_symbl
                    Set Size to 13 96
                    Set Location to 25 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send DoModifiers
                    end_procedure
                    
                    procedure DoModifiers
                        integer hoDefault iCC iOpcode
                        string  sWasModifiers sModifiers
                        number  nWasDefault nDefault
                        //
                        move Jcoper_Var2_Dflt_Value to hoDefault
                        //
                        get Value                                              to sWasModifiers
                        get Value of hoDefault                                 to nWasDefault
                        if      (sWasModifiers CONTAINS "CC") move nWasDefault to iCC
                        else if (sWasModifiers CONTAINS "OP") move nWasDefault to iOpcode
                        //
                        get IsModifiers of odgStdModifiers 2 sWasModifiers iCC iOpcode to sModifiers
                        if (sModifiers = "CANCEL") procedure_return
                        //
                        move 0 to nDefault
                        if (sModifiers CONTAINS "CC") get piCC     of odgStdModifiers to nDefault
                        if (sModifiers CONTAINS "OP") get piOpcode of odgStdModifiers to nDefault
                        //
                        //if (nDefault <> nWasDefault) begin
                        if (((sModifiers CONTAINS "CC") or (sModifiers CONTAINS "OP")) ;
                            and (nDefault <> nWasDefault) )begin
                            set Value              of hoDefault to nDefault
                            set Item_Changed_State of hoDefault to TRUE
                        end
                        //
                        if (sModifiers <> sWasModifiers) begin
                            set Value              to sModifiers
                            set Item_Changed_State to TRUE
                        end
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var2_Tag_Symbl

                Object Jcoper_Var2_Dflt_Value is a dbForm
                    Entry_Item Jcoper.Var2_dflt_value
                    Set Size to 13 68
                    Set Location to 25 305
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Var2_Dflt_Value

                Object Jcoper_Var2_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Var2_link_code
                    Set Size to 13 58
                    Set Location to 25 377
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var2_Link_Code

                Object Jcoper_Var2_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Var2_link_symbl
                    Set Size to 13 25
                    Set Location to 25 438
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 110
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Var2_Link_Symbl

                Object Jcoper_Var3_Tag is a dbTagForm
                    Entry_Item Jcoper.Var3_tag
                    Set Label to "3)"
                    Set Size to 13 186
                    Set Location to 40 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 2 VAR_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 2 VAR_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Var2_Tag(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Var4_Tag(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Var3_Tag

                Object Jcoper_Var3_Tag_Symbl is a dbForm
                    Entry_Item Jcoper.Var3_tag_symbl
                    Set Size to 13 96
                    Set Location to 40 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send DoModifiers
                    end_procedure
                    
                    procedure DoModifiers
                        integer hoDefault iCC iOpcode
                        string  sWasModifiers sModifiers
                        number  nWasDefault nDefault
                        //
                        move Jcoper_Var3_Dflt_Value to hoDefault
                        //
                        get Value                                              to sWasModifiers
                        get Value of hoDefault                                 to nWasDefault
                        if      (sWasModifiers CONTAINS "CC") move nWasDefault to iCC
                        else if (sWasModifiers CONTAINS "OP") move nWasDefault to iOpcode
                        //
                        get IsModifiers of odgStdModifiers 3 sWasModifiers iCC iOpcode to sModifiers
                        if (sModifiers = "CANCEL") procedure_return
                        //
                        move 0 to nDefault
                        if (sModifiers CONTAINS "CC") get piCC     of odgStdModifiers to nDefault
                        if (sModifiers CONTAINS "OP") get piOpcode of odgStdModifiers to nDefault
                        //
                        //if (nDefault <> nWasDefault) begin
                        if (((sModifiers CONTAINS "CC") or (sModifiers CONTAINS "OP")) ;
                            and (nDefault <> nWasDefault) )begin
                            set Value              of hoDefault to nDefault
                            set Item_Changed_State of hoDefault to TRUE
                        end
                        //
                        if (sModifiers <> sWasModifiers) begin
                            set Value              to sModifiers
                            set Item_Changed_State to TRUE
                        end
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var3_Tag_Symbl

                Object Jcoper_Var3_Dflt_Value is a dbForm
                    Entry_Item Jcoper.Var3_dflt_value
                    Set Size to 13 68
                    Set Location to 40 305
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Var3_Dflt_Value

                Object Jcoper_Var3_Link_Code is a dbForm
                    Entry_Item Jcoper.Var3_link_code
                    Set Size to 13 58
                    Set Location to 40 377
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var3_Link_Code

                Object Jcoper_Var3_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Var3_link_symbl
                    Set Size to 13 25
                    Set Location to 40 438
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 111
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Var3_Link_Symbl

                Object Jcoper_Var4_Tag is a dbTagForm
                    Entry_Item Jcoper.Var4_tag
                    Set Label to "4)"
                    Set Size to 13 186
                    Set Location to 55 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 3 VAR_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 3 VAR_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Var3_Tag(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Var5_Tag(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Var4_Tag

                Object Jcoper_Var4_Tag_Symbl is a dbForm
                    Entry_Item Jcoper.Var4_tag_symbl
                    Set Size to 13 96
                    Set Location to 55 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send DoModifiers
                    end_procedure
                    
                    procedure DoModifiers
                        integer hoDefault iCC iOpcode
                        string  sWasModifiers sModifiers
                        number  nWasDefault nDefault
                        //
                        move Jcoper_Var4_Dflt_Value to hoDefault
                        //
                        get Value                                              to sWasModifiers
                        get Value of hoDefault                                 to nWasDefault
                        if      (sWasModifiers CONTAINS "CC") move nWasDefault to iCC
                        else if (sWasModifiers CONTAINS "OP") move nWasDefault to iOpcode
                        //
                        get IsModifiers of odgStdModifiers 4 sWasModifiers iCC iOpcode to sModifiers
                        if (sModifiers = "CANCEL") procedure_return
                        //
                        move 0 to nDefault
                        if (sModifiers CONTAINS "CC") get piCC     of odgStdModifiers to nDefault
                        if (sModifiers CONTAINS "OP") get piOpcode of odgStdModifiers to nDefault
                        //
                        //if (nDefault <> nWasDefault) begin
                        if (((sModifiers CONTAINS "CC") or (sModifiers CONTAINS "OP")) ;
                            and (nDefault <> nWasDefault) )begin
                            set Value              of hoDefault to nDefault
                            set Item_Changed_State of hoDefault to TRUE
                        end
                        //
                        if (sModifiers <> sWasModifiers) begin
                            set Value              to sModifiers
                            set Item_Changed_State to TRUE
                        end
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var4_Tag_Symbl

                Object Jcoper_Var4_Dflt_Value is a dbForm
                    Entry_Item Jcoper.Var4_dflt_value
                    Set Size to 13 68
                    Set Location to 55 305
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Var4_Dflt_Value

                Object Jcoper_Var4_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Var4_link_code
                    Set Size to 13 58
                    Set Location to 55 377
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var4_Link_Code

                Object Jcoper_Var4_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Var4_link_symbl
                    Set Size to 13 25
                    Set Location to 55 438
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 112
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Var4_Link_Symbl

                Object Jcoper_Var5_Tag is a dbTagForm
                    Entry_Item Jcoper.Var5_tag
                    Set Label to "5)"
                    Set Size to 13 186
                    Set Location to 70 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 4 VAR_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 4 VAR_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Var4_Tag(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Var6_Tag(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Var5_Tag

                Object Jcoper_Var5_Tag_Symbl is a dbForm
                    Entry_Item Jcoper.Var5_tag_symbl
                    Set Size to 13 96
                    Set Location to 70 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send DoModifiers
                    end_procedure
                    
                    procedure DoModifiers
                        integer hoDefault iCC iOpcode
                        string  sWasModifiers sModifiers
                        number  nWasDefault nDefault
                        //
                        move Jcoper_Var5_Dflt_Value to hoDefault
                        //
                        get Value                                              to sWasModifiers
                        get Value of hoDefault                                 to nWasDefault
                        if      (sWasModifiers CONTAINS "CC") move nWasDefault to iCC
                        else if (sWasModifiers CONTAINS "OP") move nWasDefault to iOpcode
                        //
                        get IsModifiers of odgStdModifiers 5 sWasModifiers iCC iOpcode to sModifiers
                        if (sModifiers = "CANCEL") procedure_return
                        //
                        move 0 to nDefault
                        if (sModifiers CONTAINS "CC") get piCC     of odgStdModifiers to nDefault
                        if (sModifiers CONTAINS "OP") get piOpcode of odgStdModifiers to nDefault
                        //
                        //if (nDefault <> nWasDefault) begin
                        if (((sModifiers CONTAINS "CC") or (sModifiers CONTAINS "OP")) ;
                            and (nDefault <> nWasDefault) )begin
                            set Value              of hoDefault to nDefault
                            set Item_Changed_State of hoDefault to TRUE
                        end
                        //
                        if (sModifiers <> sWasModifiers) begin
                            set Value              to sModifiers
                            set Item_Changed_State to TRUE
                        end
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var5_Tag_Symbl

                Object Jcoper_Var5_Dflt_Value is a dbForm
                    Entry_Item Jcoper.Var5_dflt_value
                    Set Size to 13 68
                    Set Location to 70 305
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Var5_Dflt_Value

                Object Jcoper_Var5_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Var5_link_code
                    Set Size to 13 58
                    Set Location to 70 377
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var5_Link_Code

                Object Jcoper_Var5_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Var5_link_symbl
                    Set Size to 13 25
                    Set Location to 70 438
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 113
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Var5_Link_Symbl

                Object Jcoper_Var6_Tag is a dbTagForm
                    Entry_Item Jcoper.Var6_tag
                    Set Label to "6)"
                    Set Size to 13 186
                    Set Location to 85 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 5 VAR_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 5 VAR_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Var5_Tag(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Var7_Tag(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Var6_Tag

                Object Jcoper_Var6_Tag_Symbl is a dbForm
                    Entry_Item Jcoper.Var6_tag_symbl
                    Set Size to 13 96
                    Set Location to 85 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send DoModifiers
                    end_procedure
                    
                    procedure DoModifiers
                        integer hoDefault iCC iOpcode
                        string  sWasModifiers sModifiers
                        number  nWasDefault nDefault
                        //
                        move Jcoper_Var6_Dflt_Value to hoDefault
                        //
                        get Value                                              to sWasModifiers
                        get Value of hoDefault                                 to nWasDefault
                        if      (sWasModifiers CONTAINS "CC") move nWasDefault to iCC
                        else if (sWasModifiers CONTAINS "OP") move nWasDefault to iOpcode
                        //
                        get IsModifiers of odgStdModifiers 6 sWasModifiers iCC iOpcode to sModifiers
                        if (sModifiers = "CANCEL") procedure_return
                        //
                        move 0 to nDefault
                        if (sModifiers CONTAINS "CC") get piCC     of odgStdModifiers to nDefault
                        if (sModifiers CONTAINS "OP") get piOpcode of odgStdModifiers to nDefault
                        //
                        //if (nDefault <> nWasDefault) begin
                        if (((sModifiers CONTAINS "CC") or (sModifiers CONTAINS "OP")) ;
                            and (nDefault <> nWasDefault) )begin
                            set Value              of hoDefault to nDefault
                            set Item_Changed_State of hoDefault to TRUE
                        end
                        //
                        if (sModifiers <> sWasModifiers) begin
                            set Value              to sModifiers
                            set Item_Changed_State to TRUE
                        end
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var6_Tag_Symbl

                Object Jcoper_Var6_Dflt_Value is a dbForm
                    Entry_Item Jcoper.Var6_dflt_value
                    Set Size to 13 68
                    Set Location to 85 305
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Var6_Dflt_Value

                Object Jcoper_Var6_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Var6_link_code
                    Set Size to 13 58
                    Set Location to 85 377
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var6_Link_Code

                Object Jcoper_Var6_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Var6_link_symbl
                    Set Size to 13 25
                    Set Location to 85 438
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 114
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Var6_Link_Symbl

                Object Jcoper_Var7_Tag is a dbTagForm
                    Entry_Item Jcoper.Var7_tag
                    Set Label to "7)"
                    Set Size to 13 186
                    Set Location to 100 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 6 VAR_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 6 VAR_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Var6_Tag(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Var8_Tag(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Var7_Tag

                Object Jcoper_Var7_Tag_Symbl is a dbForm
                    Entry_Item Jcoper.Var7_tag_symbl
                    Set Size to 13 96
                    Set Location to 100 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send DoModifiers
                    end_procedure
                    
                    procedure DoModifiers
                        integer hoDefault iCC iOpcode
                        string  sWasModifiers sModifiers
                        number  nWasDefault nDefault
                        //
                        move Jcoper_Var7_Dflt_Value to hoDefault
                        //
                        get Value                                              to sWasModifiers
                        get Value of hoDefault                                 to nWasDefault
                        if      (sWasModifiers CONTAINS "CC") move nWasDefault to iCC
                        else if (sWasModifiers CONTAINS "OP") move nWasDefault to iOpcode
                        //
                        get IsModifiers of odgStdModifiers 7 sWasModifiers iCC iOpcode to sModifiers
                        if (sModifiers = "CANCEL") procedure_return
                        //
                        move 0 to nDefault
                        if (sModifiers CONTAINS "CC") get piCC     of odgStdModifiers to nDefault
                        if (sModifiers CONTAINS "OP") get piOpcode of odgStdModifiers to nDefault
                        //
                        //if (nDefault <> nWasDefault) begin
                        if (((sModifiers CONTAINS "CC") or (sModifiers CONTAINS "OP")) ;
                            and (nDefault <> nWasDefault) )begin
                            set Value              of hoDefault to nDefault
                            set Item_Changed_State of hoDefault to TRUE
                        end
                        //
                        if (sModifiers <> sWasModifiers) begin
                            set Value              to sModifiers
                            set Item_Changed_State to TRUE
                        end
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var7_Tag_Symbl

                Object Jcoper_Var7_Dflt_Value is a dbForm
                    Entry_Item Jcoper.Var7_dflt_value
                    Set Size to 13 68
                    Set Location to 100 305
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Var7_Dflt_Value

                Object Jcoper_Var7_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Var7_link_code
                    Set Size to 13 58
                    Set Location to 100 377
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var7_Link_Code

                Object Jcoper_Var7_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Var7_link_symbl
                    Set Size to 13 25
                    Set Location to 100 438
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 115
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Var7_Link_Symbl

                Object Jcoper_Var8_Tag is a dbTagForm
                    Entry_Item Jcoper.Var8_tag
                    Set Label to "8)"
                    Set Size to 13 186
                    Set Location to 114 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 7 VAR_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 7 VAR_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Var7_Tag(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Var9_Tag(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Var8_Tag

                Object Jcoper_Var8_Tag_Symbl is a dbForm
                    Entry_Item Jcoper.Var8_tag_symbl
                    Set Size to 13 96
                    Set Location to 115 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send DoModifiers
                    end_procedure
                    
                    procedure DoModifiers
                        integer hoDefault iCC iOpcode
                        string  sWasModifiers sModifiers
                        number  nWasDefault nDefault
                        //
                        move Jcoper_Var8_Dflt_Value to hoDefault
                        //
                        get Value                                              to sWasModifiers
                        get Value of hoDefault                                 to nWasDefault
                        if      (sWasModifiers CONTAINS "CC") move nWasDefault to iCC
                        else if (sWasModifiers CONTAINS "OP") move nWasDefault to iOpcode
                        //
                        get IsModifiers of odgStdModifiers 8 sWasModifiers iCC iOpcode to sModifiers
                        if (sModifiers = "CANCEL") procedure_return
                        //
                        move 0 to nDefault
                        if (sModifiers CONTAINS "CC") get piCC     of odgStdModifiers to nDefault
                        if (sModifiers CONTAINS "OP") get piOpcode of odgStdModifiers to nDefault
                        //
                        //if (nDefault <> nWasDefault) begin
                        if (((sModifiers CONTAINS "CC") or (sModifiers CONTAINS "OP")) ;
                            and (nDefault <> nWasDefault) )begin
                            set Value              of hoDefault to nDefault
                            set Item_Changed_State of hoDefault to TRUE
                        end
                        //
                        if (sModifiers <> sWasModifiers) begin
                            set Value              to sModifiers
                            set Item_Changed_State to TRUE
                        end
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var8_Tag_Symbl

                Object Jcoper_Var8_Dflt_Value is a dbForm
                    Entry_Item Jcoper.Var8_dflt_value
                    Set Size to 13 68
                    Set Location to 115 305
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Var8_Dflt_Value

                Object Jcoper_Var8_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Var8_link_code
                    Set Size to 13 58
                    Set Location to 115 377
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var8_Link_Code

                Object Jcoper_Var8_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Var8_link_symbl
                    Set Size to 13 25
                    Set Location to 115 438
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 116
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Var8_Link_Symbl

                Object Jcoper_Var9_Tag is a dbTagForm
                    Entry_Item Jcoper.Var9_tag
                    Set Label to "9)"
                    Set Size to 13 186
                    Set Location to 130 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        // cannot insert here
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 8 VAR_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Var8_Tag(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        // nowhere to go
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Var9_Tag

                Object Jcoper_Var9_Tag_Symbl is a dbForm
                    Entry_Item Jcoper.Var9_tag_symbl
                    Set Size to 13 96
                    Set Location to 130 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send DoModifiers
                    end_procedure
                    
                    procedure DoModifiers
                        integer hoDefault iCC iOpcode
                        string  sWasModifiers sModifiers
                        number  nWasDefault nDefault
                        //
                        move Jcoper_Var9_Dflt_Value to hoDefault
                        //
                        get Value                                              to sWasModifiers
                        get Value of hoDefault                                 to nWasDefault
                        if      (sWasModifiers CONTAINS "CC") move nWasDefault to iCC
                        else if (sWasModifiers CONTAINS "OP") move nWasDefault to iOpcode
                        //
                        get IsModifiers of odgStdModifiers 9 sWasModifiers iCC iOpcode to sModifiers
                        if (sModifiers = "CANCEL") procedure_return
                        //
                        move 0 to nDefault
                        if (sModifiers CONTAINS "CC") get piCC     of odgStdModifiers to nDefault
                        if (sModifiers CONTAINS "OP") get piOpcode of odgStdModifiers to nDefault
                        //
                        //if (nDefault <> nWasDefault) begin
                        if (((sModifiers CONTAINS "CC") or (sModifiers CONTAINS "OP")) ;
                            and (nDefault <> nWasDefault) )begin
                            set Value              of hoDefault to nDefault
                            set Item_Changed_State of hoDefault to TRUE
                        end
                        //
                        if (sModifiers <> sWasModifiers) begin
                            set Value              to sModifiers
                            set Item_Changed_State to TRUE
                        end
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var9_Tag_Symbl

                Object Jcoper_Var9_Dflt_Value is a dbForm
                    Entry_Item Jcoper.Var9_dflt_value
                    Set Size to 13 68
                    Set Location to 130 305
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Var9_Dflt_Value

                Object Jcoper_Var9_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Var9_link_code
                    Set Size to 13 58
                    Set Location to 130 377
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Var9_Link_Code

                Object Jcoper_Var9_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Var9_link_symbl
                    Set Size to 13 25
                    Set Location to 130 438
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 117
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Var9_Link_Symbl

            End_Object    // dbGroup2

        End_Object    // TP_Formula_Variables

        Object TP_Formula_Constants is a dbTabPage
            Set Label to "Formula Constants"
            Object dbGroup4 is a dbGroup
                Set Size to 150 379
                Set Location to 5 5
                Set Label to "     Description                                                                              Defined  Value                      Link Code    /   Symbol "
                Object Jcoper_Con1_Desc is a dbTagForm
                    Entry_Item Jcoper.Con1_desc
                    Set Label to "A)"
                    Set Size to 13 186
                    Set Location to 10 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 0 CON_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 0 CON_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        // nowhere to go
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Con2_Desc(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Con1_Desc

                Object Jcoper_Con1_Value is a dbForm
                    Entry_Item Jcoper.Con1_value
                    Set Size to 13 78
                    Set Location to 10 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Con1_Value

                Object Jcoper_Con1_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Con1_link_code
                    Set Size to 13 58
                    Set Location to 10 286
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Con1_Link_Code

                Object Jcoper_Con1_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Con1_link_symbl
                    Set Size to 13 25
                    Set Location to 10 348
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 145
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Con1_Link_Symbl

                Object Jcoper_Con2_Desc is a dbTagForm
                    Entry_Item Jcoper.Con2_desc
                    Set Label to "B)"
                    Set Size to 13 186
                    Set Location to 25 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 1 CON_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 1 CON_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Con1_Desc(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Con3_Desc(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Con2_Desc

                Object Jcoper_Con2_Value is a dbForm
                    Entry_Item Jcoper.Con2_value
                    Set Size to 13 78
                    Set Location to 25 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Con2_Value

                Object Jcoper_Con2_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Con2_link_code
                    Set Size to 13 58
                    Set Location to 25 286
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Con2_Link_Code

                Object Jcoper_Con2_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Con2_link_symbl
                    Set Size to 13 25
                    Set Location to 25 348
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 146
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Con2_Link_Symbl

                Object Jcoper_Con3_Desc is a dbTagForm
                    Entry_Item Jcoper.Con3_desc
                    Set Label to "C)"
                    Set Size to 13 186
                    Set Location to 40 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 2 CON_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 2 CON_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Con2_Desc(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Con4_Desc(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Con3_Desc

                Object Jcoper_Con3_Value is a dbForm
                    Entry_Item Jcoper.Con3_value
                    Set Size to 13 78
                    Set Location to 40 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Con3_Value

                Object Jcoper_Con3_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Con3_link_code
                    Set Size to 13 58
                    Set Location to 40 286
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Con3_Link_Code

                Object Jcoper_Con3_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Con3_link_symbl
                    Set Size to 13 25
                    Set Location to 40 348
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 147
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Con3_Link_Symbl

                Object Jcoper_Con4_Desc is a dbTagForm
                    Entry_Item Jcoper.Con4_desc
                    Set Label to "D)"
                    Set Size to 13 186
                    Set Location to 55 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 3 CON_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 3 CON_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Con3_Desc(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Con5_Desc(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Con4_Desc

                Object Jcoper_Con4_Value is a dbForm
                    Entry_Item Jcoper.Con4_value
                    Set Size to 13 78
                    Set Location to 55 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Con4_Value

                Object Jcoper_Con4_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Con4_link_code
                    Set Size to 13 58
                    Set Location to 55 286
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Con4_Link_Code

                Object Jcoper_Con4_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Con4_link_symbl
                    Set Size to 13 25
                    Set Location to 55 348
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 148
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Con4_Link_Symbl

                Object Jcoper_Con5_Desc is a dbTagForm
                    Entry_Item Jcoper.Con5_desc
                    Set Label to "E)"
                    Set Size to 13 186
                    Set Location to 70 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 4 CON_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 4 CON_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Con4_Desc(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Con6_Desc(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Con5_Desc

                Object Jcoper_Con5_Value is a dbForm
                    Entry_Item Jcoper.Con5_value
                    Set Size to 13 78
                    Set Location to 70 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Con5_Value

                Object Jcoper_Con5_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Con5_link_code
                    Set Size to 13 58
                    Set Location to 70 286
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Con5_Link_Code

                Object Jcoper_Con5_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Con5_link_symbl
                    Set Size to 13 25
                    Set Location to 70 348
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 149
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Con5_Link_Symbl

                Object Jcoper_Con6_Desc is a dbTagForm
                    Entry_Item Jcoper.Con6_desc
                    Set Label to "F)"
                    Set Size to 13 186
                    Set Location to 85 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 5 CON_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 5 CON_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Con5_Desc(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Con7_Desc(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Con6_Desc

                Object Jcoper_Con6_Value is a dbForm
                    Entry_Item Jcoper.Con6_value
                    Set Size to 13 78
                    Set Location to 85 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Con6_Value

                Object Jcoper_Con6_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Con6_link_code
                    Set Size to 13 58
                    Set Location to 85 286
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Con6_Link_Code

                Object Jcoper_Con6_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Con6_link_symbl
                    Set Size to 13 25
                    Set Location to 85 348
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 150
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Con6_Link_Symbl

                Object Jcoper_Con7_Desc is a dbTagForm
                    Entry_Item Jcoper.Con7_desc
                    Set Label to "G)"
                    Set Size to 13 186
                    Set Location to 100 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 6 CON_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 6 CON_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Con6_Desc(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Con8_Desc(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Con7_Desc

                Object Jcoper_Con7_Value is a dbForm
                    Entry_Item Jcoper.Con7_value
                    Set Size to 13 78
                    Set Location to 100 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Con7_Value

                Object Jcoper_Con7_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Con7_link_code
                    Set Size to 13 58
                    Set Location to 100 286
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Con7_Link_Code

                Object Jcoper_Con7_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Con7_link_symbl
                    Set Size to 13 25
                    Set Location to 100 348
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 151
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Con7_Link_Symbl

                Object Jcoper_Con8_Desc is a dbTagForm
                    Entry_Item Jcoper.Con8_desc
                    Set Label to "H)"
                    Set Size to 13 186
                    Set Location to 114 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)="") procedure_return
                        send InsertTagRow to (Server(self)) 7 CON_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 7 CON_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Con7_Desc(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Con9_Desc(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Con8_Desc

                Object Jcoper_Con8_Value is a dbForm
                    Entry_Item Jcoper.Con8_value
                    Set Size to 13 78
                    Set Location to 115 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Con8_Value

                Object Jcoper_Con8_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Con8_link_code
                    Set Size to 13 58
                    Set Location to 115 286
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Con8_Link_Code

                Object Jcoper_Con8_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Con8_link_symbl
                    Set Size to 13 25
                    Set Location to 115 348
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 152
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Con8_Link_Symbl

                Object Jcoper_Con9_Desc is a dbTagForm
                    Entry_Item Jcoper.Con9_desc
                    Set Label to "I)"
                    Set Size to 13 186
                    Set Location to 130 15
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        // cannot insert here
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 8 CON_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Con8_Desc(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        // nowhere to go
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Con9_Desc

                Object Jcoper_Con9_Value is a dbForm
                    Entry_Item Jcoper.Con9_value
                    Set Size to 13 78
                    Set Location to 130 205
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Con9_Value

                Object Jcoper_Con9_Link_Code is a dbForm

                    //AB-StoreTopStart
                                        
                    //AB-StoreTopEnd

                    Entry_Item Jcoper.Con9_link_code
                    Set Size to 13 58
                    Set Location to 130 286
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Con9_Link_Code

                Object Jcoper_Con9_Link_Symbl is a dbForm
                    Entry_Item Jcoper.Con9_link_symbl
                    Set Size to 13 25
                    Set Location to 130 348
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send LinkSymbolPrompt 153
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_Con9_Link_Symbl

            End_Object    // dbGroup4

        End_Object    // TP_Formula_Constants

        Object TP_Table_Standards is a dbTabPage
            Set Label to "Table Standards"
            Object TableGroup is a dbGroup

                //AB-StoreTopStart
                procedure FactorTable
                    number nFactor
                    get TableFactor of (FactorDialog(self)) to nFactor
                    send FactorTable to (Server(self)) nFactor
                end_procedure
                
                on_key kCalculate send FactorTable
                //AB-StoreTopEnd

                Set Size to 208 468
                Set Location to 5 5
                Set Label to "  Table Value Description   "
                Object Jcoper_Table_Std_Desc is a dbForm
                    Entry_Item Jcoper.Table_std_desc
                    Set Size to 13 90
                    Set Location to 10 11
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Table_Std_Desc

                Object Jcoper_Bracket_Desc is a dbForm
                    Entry_Item Jcoper.Bracket_desc
                    Set Label to "Column Description"
                    Set Size to 13 90
                    Set Location to 15 240
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Bracket_Desc

                Object Jcoper_Lookup_Desc is a dbForm
                    Entry_Item Jcoper.Lookup_desc
                    Set Label to "Row Description"
                    Set Size to 13 90
                    Set Location to 40 11
                    Set Label_Col_Offset to 0
                    Set Label_Justification_Mode to jMode_Top
                End_Object    // Jcoper_Lookup_Desc

                Object Jcoper_Bracket1_Value is a dbForm
                    Entry_Item Jcoper.Bracket1_value
                    Set Label to "1"
                    Set Size to 13 66
                    Set Location to 40 108
                    Set Color to clAqua
                    Set Label_Col_Offset to -30
                    Set Label_Justification_Mode to jMode_Top
                End_Object    // Jcoper_Bracket1_Value

                Object Jcoper_Bracket2_Value is a dbForm
                    Entry_Item Jcoper.Bracket2_value
                    Set Label to "2"
                    Set Size to 13 66
                    Set Location to 40 180
                    Set Color to clAqua
                    Set Label_Col_Offset to -30
                    Set Label_Justification_Mode to jMode_Top
                End_Object    // Jcoper_Bracket2_Value

                Object Jcoper_Bracket3_Value is a dbForm
                    Entry_Item Jcoper.Bracket3_value
                    Set Label to "3"
                    Set Size to 13 66
                    Set Location to 40 252
                    Set Color to clAqua
                    Set Label_Col_Offset to -30
                    Set Label_Justification_Mode to jMode_Top
                End_Object    // Jcoper_Bracket3_Value

                Object Jcoper_Bracket4_Value is a dbForm
                    Entry_Item Jcoper.Bracket4_value
                    Set Label to "4"
                    Set Size to 13 66
                    Set Location to 40 324
                    Set Color to clAqua
                    Set Label_Col_Offset to -30
                    Set Label_Justification_Mode to jMode_Top
                End_Object    // Jcoper_Bracket4_Value

                Object Jcoper_Bracket5_Value is a dbForm
                    Entry_Item Jcoper.Bracket5_value
                    Set Label to "5"
                    Set Size to 13 66
                    Set Location to 40 396
                    Set Color to clAqua
                    Set Label_Col_Offset to -30
                    Set Label_Justification_Mode to jMode_Top
                End_Object    // Jcoper_Bracket5_Value

                Object Jcoper_Lookup1_Value is a dbTagForm
                    Entry_Item Jcoper.Lookup1_value
                    Set Label to "1)"
                    Set Size to 13 66
                    Set Location to 55 35
                    Set Color to clAqua
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)=0) procedure_return
                        send InsertTagRow to (Server(self)) 0 TABLE_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 0 TABLE_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        // nowhere to go
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Lookup2_Value(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Lookup1_Value

                Object Jcoper_L1b1_Std is a dbForm
                    Entry_Item Jcoper.L1b1_std
                    Set Size to 13 66
                    Set Location to 55 108
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L1b1_Std

                Object Jcoper_L1b2_Std is a dbForm
                    Entry_Item Jcoper.L1b2_std
                    Set Size to 13 66
                    Set Location to 55 180
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L1b2_Std

                Object Jcoper_L1b3_Std is a dbForm
                    Entry_Item Jcoper.L1b3_std
                    Set Size to 13 66
                    Set Location to 55 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L1b3_Std

                Object Jcoper_L1b4_Std is a dbForm
                    Entry_Item Jcoper.L1b4_std
                    Set Size to 13 66
                    Set Location to 55 324
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L1b4_Std

                Object Jcoper_L1b5_Std is a dbForm
                    Entry_Item Jcoper.L1b5_std
                    Set Size to 13 66
                    Set Location to 55 396
                End_Object    // Jcoper_L1b5_Std

                Object Jcoper_Lookup2_Value is a dbTagForm
                    Entry_Item Jcoper.Lookup2_value
                    Set Label to "2)"
                    Set Size to 13 66
                    Set Location to 70 35
                    Set Color to clAqua
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)=0) procedure_return
                        send InsertTagRow to (Server(self)) 1 TABLE_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 1 TABLE_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Lookup1_Value(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Lookup3_Value(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Lookup2_Value

                Object Jcoper_L2b1_Std is a dbForm
                    Entry_Item Jcoper.L2b1_std
                    Set Size to 13 66
                    Set Location to 70 108
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L2b1_Std

                Object Jcoper_L2b2_Std is a dbForm
                    Entry_Item Jcoper.L2b2_std
                    Set Size to 13 66
                    Set Location to 70 180
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L2b2_Std

                Object Jcoper_L2b3_Std is a dbForm
                    Entry_Item Jcoper.L2b3_std
                    Set Size to 13 66
                    Set Location to 70 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L2b3_Std

                Object Jcoper_L2b4_Std is a dbForm
                    Entry_Item Jcoper.L2b4_std
                    Set Size to 13 66
                    Set Location to 70 324
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L2b4_Std

                Object Jcoper_L2b5_Std is a dbForm
                    Entry_Item Jcoper.L2b5_std
                    Set Size to 13 66
                    Set Location to 70 396
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L2b5_Std

                Object Jcoper_Lookup3_Value is a dbTagForm
                    Entry_Item Jcoper.Lookup3_value
                    Set Label to "3)"
                    Set Size to 13 66
                    Set Location to 85 35
                    Set Color to clAqua
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)=0) procedure_return
                        send InsertTagRow to (Server(self)) 2 TABLE_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 2 TABLE_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Lookup2_Value(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Lookup4_Value(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Lookup3_Value

                Object Jcoper_L3b1_Std is a dbForm
                    Entry_Item Jcoper.L3b1_std
                    Set Size to 13 66
                    Set Location to 85 108
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L3b1_Std

                Object Jcoper_L3b2_Std is a dbForm
                    Entry_Item Jcoper.L3b2_std
                    Set Size to 13 66
                    Set Location to 85 180
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L3b2_Std

                Object Jcoper_L3b3_Std is a dbForm
                    Entry_Item Jcoper.L3b3_std
                    Set Size to 13 66
                    Set Location to 85 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L3b3_Std

                Object Jcoper_L3b4_Std is a dbForm
                    Entry_Item Jcoper.L3b4_std
                    Set Size to 13 66
                    Set Location to 85 324
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L3b4_Std

                Object Jcoper_L3b5_Std is a dbForm
                    Entry_Item Jcoper.L3b5_std
                    Set Size to 13 66
                    Set Location to 85 396
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L3b5_Std

                Object Jcoper_Lookup4_Value is a dbTagForm
                    Entry_Item Jcoper.Lookup4_value
                    Set Label to "4)"
                    Set Size to 13 66
                    Set Location to 100 35
                    Set Color to clAqua
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)=0) procedure_return
                        send InsertTagRow to (Server(self)) 3 TABLE_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 3 TABLE_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Lookup3_Value(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Lookup5_Value(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Lookup4_Value

                Object Jcoper_L4b1_Std is a dbForm
                    Entry_Item Jcoper.L4b1_std
                    Set Size to 13 66
                    Set Location to 100 108
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L4b1_Std

                Object Jcoper_L4b2_Std is a dbForm
                    Entry_Item Jcoper.L4b2_std
                    Set Size to 13 66
                    Set Location to 100 180
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L4b2_Std

                Object Jcoper_L4b3_Std is a dbForm
                    Entry_Item Jcoper.L4b3_std
                    Set Size to 13 66
                    Set Location to 100 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L4b3_Std

                Object Jcoper_L4b4_Std is a dbForm
                    Entry_Item Jcoper.L4b4_std
                    Set Size to 13 66
                    Set Location to 100 324
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L4b4_Std

                Object Jcoper_L4b5_Std is a dbForm
                    Entry_Item Jcoper.L4b5_std
                    Set Size to 13 66
                    Set Location to 100 396
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L4b5_Std

                Object Jcoper_Lookup5_Value is a dbTagForm
                    Entry_Item Jcoper.Lookup5_value
                    Set Label to "5)"
                    Set Size to 13 66
                    Set Location to 114 35
                    Set Color to clAqua
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)=0) procedure_return
                        send InsertTagRow to (Server(self)) 4 TABLE_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 4 TABLE_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Lookup4_Value(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Lookup6_Value(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Lookup5_Value

                Object Jcoper_L5b1_Std is a dbForm
                    Entry_Item Jcoper.L5b1_std
                    Set Size to 13 66
                    Set Location to 115 108
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L5b1_Std

                Object Jcoper_L5b2_Std is a dbForm
                    Entry_Item Jcoper.L5b2_std
                    Set Size to 13 66
                    Set Location to 115 180
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L5b2_Std

                Object Jcoper_L5b3_Std is a dbForm
                    Entry_Item Jcoper.L5b3_std
                    Set Size to 13 66
                    Set Location to 115 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L5b3_Std

                Object Jcoper_L5b4_Std is a dbForm
                    Entry_Item Jcoper.L5b4_std
                    Set Size to 13 66
                    Set Location to 115 324
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L5b4_Std

                Object Jcoper_L5b5_Std is a dbForm
                    Entry_Item Jcoper.L5b5_std
                    Set Size to 13 66
                    Set Location to 115 396
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L5b5_Std

                Object Jcoper_Lookup6_Value is a dbTagForm
                    Entry_Item Jcoper.Lookup6_value
                    Set Label to "6)"
                    Set Size to 13 66
                    Set Location to 130 35
                    Set Color to clAqua
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)=0) procedure_return
                        send InsertTagRow to (Server(self)) 5 TABLE_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 5 TABLE_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Lookup5_Value(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Lookup7_Value(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Lookup6_Value

                Object Jcoper_L6b1_Std is a dbForm
                    Entry_Item Jcoper.L6b1_std
                    Set Size to 13 66
                    Set Location to 130 108
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L6b1_Std

                Object Jcoper_L6b2_Std is a dbForm
                    Entry_Item Jcoper.L6b2_std
                    Set Size to 13 66
                    Set Location to 130 180
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L6b2_Std

                Object Jcoper_L6b3_Std is a dbForm
                    Entry_Item Jcoper.L6b3_std
                    Set Size to 13 66
                    Set Location to 130 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L6b3_Std

                Object Jcoper_L6b4_Std is a dbForm
                    Entry_Item Jcoper.L6b4_std
                    Set Size to 13 66
                    Set Location to 130 324
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L6b4_Std

                Object Jcoper_L6b5_Std is a dbForm
                    Entry_Item Jcoper.L6b5_std
                    Set Size to 13 66
                    Set Location to 130 396
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L6b5_Std

                Object Jcoper_Lookup7_Value is a dbTagForm
                    Entry_Item Jcoper.Lookup7_value
                    Set Label to "7)"
                    Set Size to 13 66
                    Set Location to 145 35
                    Set Color to clAqua
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)=0) procedure_return
                        send InsertTagRow to (Server(self)) 6 TABLE_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 6 TABLE_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Lookup6_Value(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Lookup8_Value(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Lookup7_Value

                Object Jcoper_L7b1_Std is a dbForm
                    Entry_Item Jcoper.L7b1_std
                    Set Size to 13 66
                    Set Location to 145 108
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L7b1_Std

                Object Jcoper_L7b2_Std is a dbForm
                    Entry_Item Jcoper.L7b2_std
                    Set Size to 13 66
                    Set Location to 145 180
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L7b2_Std

                Object Jcoper_L7b3_Std is a dbForm
                    Entry_Item Jcoper.L7b3_std
                    Set Size to 13 66
                    Set Location to 145 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L7b3_Std

                Object Jcoper_L7b4_Std is a dbForm
                    Entry_Item Jcoper.L7b4_std
                    Set Size to 13 66
                    Set Location to 145 324
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L7b4_Std

                Object Jcoper_L7b5_Std is a dbForm
                    Entry_Item Jcoper.L7b5_std
                    Set Size to 13 66
                    Set Location to 145 396
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L7b5_Std

                Object Jcoper_Lookup8_Value is a dbTagForm
                    Entry_Item Jcoper.Lookup8_value
                    Set Label to "8)"
                    Set Size to 13 66
                    Set Location to 160 35
                    Set Color to clAqua
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)=0) procedure_return
                        send InsertTagRow to (Server(self)) 7 TABLE_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 7 TABLE_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Lookup7_Value(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Lookup9_Value(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Lookup8_Value

                Object Jcoper_L8b1_Std is a dbForm
                    Entry_Item Jcoper.L8b1_std
                    Set Size to 13 66
                    Set Location to 160 108
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L8b1_Std

                Object Jcoper_L8b2_Std is a dbForm
                    Entry_Item Jcoper.L8b2_std
                    Set Size to 13 66
                    Set Location to 160 180
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L8b2_Std

                Object Jcoper_L8b3_Std is a dbForm
                    Entry_Item Jcoper.L8b3_std
                    Set Size to 13 66
                    Set Location to 160 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L8b3_Std

                Object Jcoper_L8b4_Std is a dbForm
                    Entry_Item Jcoper.L8b4_std
                    Set Size to 13 66
                    Set Location to 160 324
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L8b4_Std

                Object Jcoper_L8b5_Std is a dbForm
                    Entry_Item Jcoper.L8b5_std
                    Set Size to 13 66
                    Set Location to 160 396
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L8b5_Std

                Object Jcoper_Lookup9_Value is a dbTagForm
                    Entry_Item Jcoper.Lookup9_value
                    Set Label to "9)"
                    Set Size to 13 66
                    Set Location to 175 35
                    Set Color to clAqua
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)=0) procedure_return
                        send InsertTagRow to (Server(self)) 8 TABLE_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 8 TABLE_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Lookup8_Value(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        send Activate to (Jcoper_Lookup10_Value(self))
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Lookup9_Value

                Object Jcoper_L9b1_Std is a dbForm
                    Entry_Item Jcoper.L9b1_std
                    Set Size to 13 66
                    Set Location to 175 108
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L9b1_Std

                Object Jcoper_L9b2_Std is a dbForm
                    Entry_Item Jcoper.L9b2_std
                    Set Size to 13 66
                    Set Location to 175 180
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L9b2_Std

                Object Jcoper_L9b3_Std is a dbForm
                    Entry_Item Jcoper.L9b3_std
                    Set Size to 13 66
                    Set Location to 175 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L9b3_Std

                Object Jcoper_L9b4_Std is a dbForm
                    Entry_Item Jcoper.L9b4_std
                    Set Size to 13 66
                    Set Location to 175 324
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L9b4_Std

                Object Jcoper_L9b5_Std is a dbForm
                    Entry_Item Jcoper.L9b5_std
                    Set Size to 13 66
                    Set Location to 175 396
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L9b5_Std

                Object Jcoper_Lookup10_Value is a dbTagForm
                    Entry_Item Jcoper.Lookup10_value
                    Set Label to "10)"
                    Set Size to 13 66
                    Set Location to 190 35
                    Set Color to clAqua
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right

                    //AB-StoreStart
                    //
                    procedure InsertTagRow
                        if (Value(self,0)=0) procedure_return
                        send InsertTagRow to (Server(self)) 9 TABLE_TAG
                    end_procedure // InsertTagRow
                    procedure DeleteTagRow
                        send DeleteTagRow to (Server(self)) 9 TABLE_TAG
                    end_procedure // DeleteTagRow
                    procedure PreviousTagRow
                        send Activate to (Jcoper_Lookup9_Value(self))
                    end_procedure // PreviousTagRow
                    procedure NextTagRow
                        // nowhere to go
                    end_procedure // NextTagRow
                    //
                    //AB-StoreEnd

                End_Object    // Jcoper_Lookup10_Value

                Object Jcoper_L10b1_Std is a dbForm
                    Entry_Item Jcoper.L10b1_std
                    Set Size to 13 66
                    Set Location to 190 108
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L10b1_Std

                Object Jcoper_L10b2_Std is a dbForm
                    Entry_Item Jcoper.L10b2_std
                    Set Size to 13 66
                    Set Location to 190 180
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L10b2_Std

                Object Jcoper_L10b3_Std is a dbForm
                    Entry_Item Jcoper.L10b3_std
                    Set Size to 13 66
                    Set Location to 190 252
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L10b3_Std

                Object Jcoper_L10b4_Std is a dbForm
                    Entry_Item Jcoper.L10b4_std
                    Set Size to 13 66
                    Set Location to 190 324
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L10b4_Std

                Object Jcoper_L10b5_Std is a dbForm
                    Entry_Item Jcoper.L10b5_std
                    Set Size to 13 66
                    Set Location to 190 396
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_L10b5_Std

            End_Object    // TableGroup

        End_Object    // TP_Table_Standards

        Object TP_Formulas_Flags is a dbTabPage
            Set Label to "Formulas/Flags"
            Object dbGroup3 is a dbGroup
                Set Size to 134 447
                Set Location to 5 5
                Object Jcoper_Lookup_Var is a cGlblDbComboForm
                    Entry_Item Jcoper.Lookup_var
                    Set Label to "Table row is selected by variable number"
                    Set Size to 13 25
                    Set Location to 10 205
                    Set Form_Border to 0
                    Set Label_Col_Offset to 144

                    //AB-StoreStart
                    // Combo_Fill_List is called when the list needs filling
                    Procedure Combo_Fill_List
                        // Fill the combo list with Send Combo_Add_Item
                        send Combo_Add_Item "1"
                        send Combo_Add_Item "2"
                        send Combo_Add_Item "3"
                        send Combo_Add_Item "4"
                        send Combo_Add_Item "5"
                        send Combo_Add_Item "6"
                        send Combo_Add_Item "7"
                        send Combo_Add_Item "8"
                        send Combo_Add_Item "9"
                        send Combo_Add_Item "0"
                        send Combo_Add_Item "A"
                        send Combo_Add_Item "B"
                        send Combo_Add_Item "C"
                        send Combo_Add_Item "D"
                        send Combo_Add_Item "E"
                        send Combo_Add_Item "F"
                        send Combo_Add_Item "G"
                        send Combo_Add_Item "H"
                        send Combo_Add_Item "I"
                    End_Procedure  // Combo_fill_list
                    //AB-StoreEnd

                End_Object    // Jcoper_Lookup_Var

                Object Jcoper_Prorate_Lookup is a dbCheckBox
                    Entry_Item Jcoper.Prorate_lookup
                    Set Label to "Prorate calculations between rows"
                    Set Size to 10 125
                    Set Location to 12 243
                End_Object    // Jcoper_Prorate_Lookup

                Object Jcoper_Bracket_Var is a cGlblDbComboForm
                    Entry_Item Jcoper.Bracket_var
                    Set Label to "Table column is selected by variable number"
                    Set Size to 13 25
                    Set Location to 26 205
                    Set Form_Border to 0
                    Set Label_Col_Offset to 144

                    //AB-StoreStart
                    // Combo_Fill_List is called when the list needs filling
                    Procedure Combo_Fill_List
                        // Fill the combo list with Send Combo_Add_Item
                        send Combo_Add_Item "1"
                        send Combo_Add_Item "2"
                        send Combo_Add_Item "3"
                        send Combo_Add_Item "4"
                        send Combo_Add_Item "5"
                        send Combo_Add_Item "6"
                        send Combo_Add_Item "7"
                        send Combo_Add_Item "8"
                        send Combo_Add_Item "9"
                        send Combo_Add_Item "0"
                        send Combo_Add_Item "A"
                        send Combo_Add_Item "B"
                        send Combo_Add_Item "C"
                        send Combo_Add_Item "D"
                        send Combo_Add_Item "E"
                        send Combo_Add_Item "F"
                        send Combo_Add_Item "G"
                        send Combo_Add_Item "H"
                        send Combo_Add_Item "I"
                    End_Procedure  // Combo_fill_list
                    //AB-StoreEnd

                End_Object    // Jcoper_Bracket_Var

                Object Jcoper_Prorate_Bracket is a dbCheckBox
                    Entry_Item Jcoper.Prorate_bracket
                    Set Label to "Prorate calculations between columns"
                    Set Size to 10 136
                    Set Location to 27 243
                End_Object    // Jcoper_Prorate_Bracket

                Object Jcoper_Calc_Flags is a dbForm
                    Entry_Item Jcoper.Calc_flags
                    Set Label to "Calculation Flags"
                    Set Size to 13 172
                    Set Location to 55 101
                    Set Label_Col_Offset to 72
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send DoCalcFlags
                    end_procedure
                    
                    procedure DoCalcFlags
                        integer hDD
                        string  sWasCalcFlags sCalcFlags
                        //
                        get Server          to hDD
                        send Refind_Records of hDD
                        //
                        get Value                                           to sWasCalcFlags
                        //
                        get IsCalcFlags of oDialogCalcFlags sWasCalcFlags to sCalcFlags
                        if (sCalcFlags = "CANCEL") procedure_return
                        //
                        if (sCalcFlags <> sWasCalcFlags) begin
                            set Value              to sCalcFlags
                            set Item_Changed_State to TRUE
                        end
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Calc_Flags

                Object Jcoper_Picklist_Code is a dbForm
                    Entry_Item Jcoper.Picklist_code
                    Set Label to "Filter Code"
                    Set Size to 13 13
                    Set Location to 55 318
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Picklist_Code

                Object Jcoper_Print_Flags is a dbForm
                    Entry_Item Jcoper.Print_flags
                    Set Label to "Print Control Flags"
                    Set Size to 13 172
                    Set Location to 70 101
                    Set Label_Col_Offset to 72
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        send DoPrintFlags
                    end_procedure
                    
                    procedure DoPrintFlags
                        integer hDD
                        string  sWasPrintFlags sPrintFlags
                        //
                        get Server          to hDD
                        send Refind_Records of hDD
                        //
                        get Value                                           to sWasPrintFlags
                        //
                        get IsPrintFlags of oDialogPrintFlags sWasPrintFlags to sPrintFlags
                        if (sPrintFlags = "CANCEL") procedure_return
                        //
                        if (sPrintFlags <> sWasPrintFlags) begin
                            set Value              to sPrintFlags
                            set Item_Changed_State to TRUE
                        end
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Print_Flags

                Object Jcoper_Formula is a dbForm
                    Entry_Item Jcoper.Formula
                    Set Label to "Calc. Units Formula"
                    Set Size to 13 230
                    Set Location to 85 101
                    Set Label_Col_Offset to 72
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        string sWasFormula sFormula
                        integer iRetVal
                        //
                        send Refind_Records of (Server(self))
                        //
                        get Value                                                        to sWasFormula
                        get FormulaValidation of (Server(self)) 82 sWasFormula to iRetVal
                        get IsFormula of oFormulaEditor Jcoper.Opcode feCalc sWasFormula to sFormula
                        if (sFormula = sWasFormula OR sFormula = "CANCEL") procedure_return
                        //
                        set Value              to sFormula
                        set Item_Changed_State to TRUE
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Formula

                Object Jcoper_Calc_Units_Desc is a dbForm
                    Entry_Item Jcoper.Calc_units_desc
                    Set Label to "="
                    Set Size to 13 70
                    Set Location to 85 371
                    Set Label_Col_Offset to 31
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Calc_Units_Desc

                Object Jcoper_Est_Formula is a dbForm
                    Entry_Item Jcoper.Est_formula
                    Set Label to "Prod. Units Formula"
                    Set Size to 13 230
                    Set Location to 100 101
                    Set Label_Col_Offset to 72
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        string sWasFormula sFormula
                        integer iRetVal
                        //
                        send Refind_Records of (Server(self))
                        //
                        get Value                                                        to sWasFormula
                        get FormulaValidation of (Server(self)) 83 sWasFormula to iRetVal
                        get IsFormula of oFormulaEditor Jcoper.Opcode feProd sWasFormula to sFormula
                        if (sFormula = sWasFormula OR sFormula = "CANCEL") procedure_return
                        //
                        set Value              to sFormula
                        set Item_Changed_State to TRUE
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Est_Formula

                Object Jcoper_Est_Formula_Typ is a cGlblDbForm
                    Entry_Item Jcoper.Est_formula_typ
                    Set Label to "="
                    Set Size to 13 25
                    Set Location to 100 343
                    Set Label_Col_Offset to 3
                    Set Label_Justification_Mode to jMode_Right
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                                        
                    Set Exit_Msg to Est_Formula_Typ_Exit
                    Procedure Est_Formula_Typ_Exit
                        String sFormulaType
                        Get Field_Current_Value of (Jcoper_DD(self))field Jcoper.Est_Formula_Typ to sFormulaType
                        If (sFormulaType=":") ;
                           Set Field_Changed_Value of (Jcoper_DD(self))field Jcoper.Calc_Std_Desc to "HOURS"
                        If (sFormulaType="$") ;
                           Set Field_Changed_Value of (Jcoper_DD(self))field Jcoper.Calc_Std_Desc to "DOLLARS"
                    End_Procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Est_Formula_Typ

                Object Jcoper_Calc_Std_Desc is a dbForm
                    Entry_Item Jcoper.Calc_std_desc
                    Set Size to 13 70
                    Set Location to 100 371
                    Set Label_Col_Offset to 2
                    Set Label_Justification_Mode to jMode_Right
                End_Object    // Jcoper_Calc_Std_Desc

                Object Jcoper_Sell_Formula is a cGlblDbForm
                    Entry_Item Jcoper.Sell_formula
                    Set Label to "Base Sell Formula"
                    Set Size to 13 230
                    Set Location to 114 101
                    Set Label_Col_Offset to 72
                    Set Prompt_Button_Mode to pb_PromptOn

                    //AB-StoreStart
                    procedure Prompt
                        string sWasFormula sFormula
                        integer iRetVal
                        //
                        send Refind_Records of (Server(self))
                        //
                        get Value                                                        to sWasFormula
                        get FormulaValidation of (Server(self)) 253 sWasFormula to iRetVal
                        get IsFormula of oFormulaEditor Jcoper.Opcode feSell sWasFormula to sFormula
                        if (sFormula = sWasFormula OR sFormula = "CANCEL") procedure_return
                        //
                        set Value              to sFormula
                        set Item_Changed_State to TRUE
                    end_procedure
                    //AB-StoreEnd

                End_Object    // Jcoper_Sell_Formula

                Object oLineControl1 is a cGlblLineControl
                    Set Size to 2 445
                    Set Location to 45 1
                End_Object    // oLineControl1

            End_Object    // dbGroup3

            Object oFormulaExportGroup is a dbGroup
                Set Size to 59 447
                Set Location to 140 5
                Set Label to "Formula Calculation Export Parameters"
                Object Jcoper_C1_Tag_Symbl is a cGlblDbComboForm
                    Entry_Item Jcoper.C1_tag_symbl
                    Set Label to "1st value to export"
                    Set Size to 13 30
                    Set Location to 10 101
                    Set Form_Border to 0
                    Set Label_Col_Offset to 65

                    //AB-StoreStart
                    // Combo_Fill_List is called when the list needs filling
                    Procedure Combo_Fill_List
                        // Fill the combo list with Send Combo_Add_Item
                        send Combo_Add_Item "0"
                        send Combo_Add_Item "T"
                        send Combo_Add_Item "P"
                    End_Procedure  // Combo_fill_list
                    //AB-StoreEnd

                End_Object    // Jcoper_C1_Tag_Symbl

                Object Jcoper_C1_Link_Code is a dbForm
                    Entry_Item Jcoper.C1_link_code
                    Set Label to "to Link Code"
                    Set Size to 13 58
                    Set Location to 10 187
                    Set Label_Col_Offset to 45

                    //AB-StoreStart
                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                    
                    //AB-StoreEnd

                End_Object    // Jcoper_C1_Link_Code

                Object Jcoper_C1_Link_Symbl is a dbForm
                    Entry_Item Jcoper.C1_link_symbl
                    Set Label to "to Link Symbol"
                    Set Size to 13 25
                    Set Location to 10 306
                    Set Label_Col_Offset to 50
                    Set Prompt_Button_Mode to pb_PromptOn

                    Procedure Prompt
                        Send LinkSymbolPrompt 245
                    End_Procedure
                End_Object    // Jcoper_C1_Link_Symbl

                Object Jcoper_C2_Tag_Symbl is a cGlblDbComboForm
                    Entry_Item Jcoper.C2_tag_symbl
                    Set Label to "2nd value to export"
                    Set Size to 13 30
                    Set Location to 25 101
                    Set Form_Border to 0
                    Set Label_Col_Offset to 65

                    // Combo_Fill_List is called when the list needs filling
                    Procedure Combo_Fill_List
                        // Fill the combo list with Send Combo_Add_Item
                        send Combo_Add_Item "0"
                        send Combo_Add_Item "T"
                        send Combo_Add_Item "P"
                    End_Procedure  // Combo_fill_list
                End_Object    // Jcoper_C2_Tag_Symbl

                Object Jcoper_C2_Link_Code is a dbForm
                    Entry_Item Jcoper.C2_link_code
                    Set Label to "to Link Code"
                    Set Size to 13 58
                    Set Location to 25 187
                    Set Label_Col_Offset to 45

                    procedure Prompt
                        send LinkCodePrompt of Jcoper_SL (Value(self,0))
                    end_procedure
                    procedure PrimeList
                    end_procedure
                End_Object    // Jcoper_C2_Link_Code

                Object Jcoper_C2_Link_Symbl is a dbForm
                    Entry_Item Jcoper.C2_link_symbl
                    Set Label to "to Link Symbol"
                    Set Size to 13 25
                    Set Location to 25 306
                    Set Label_Col_Offset to 50
                    Set Prompt_Button_Mode to pb_PromptOn

                    Procedure Prompt
                        Send LinkSymbolPrompt 248
                    End_Procedure
                End_Object    // Jcoper_C2_Link_Symbl

                Object Jcoper_C3_Tag_Symbl is a cGlblDbComboForm
                    Entry_Item Jcoper.C3_tag_symbl
                    Set Label to "3rd value to export"
                    Set Size to 13 30
                    Set Location to 40 101
                    Set Form_Border to 0
                    Set Label_Col_Offset to 65

                    // Combo_Fill_List is called when the list needs filling
                    Procedure Combo_Fill_List
                        // Fill the combo list with Send Combo_Add_Item
                        send Combo_Add_Item "0"
                        send Combo_Add_Item "T"
                        send Combo_Add_Item "P"
                    End_Procedure  // Combo_fill_list
                End_Object    // Jcoper_C3_Tag_Symbl

                Object Jcoper_C3_Link_Code is a dbForm
                    Entry_Item Jcoper.C3_link_code
                    Set Label to "to Link Code"
                    Set Size to 13 58
                    Set Location to 40 187
                    Set Label_Col_Offset to 45

                    Procedure Prompt
                        Send LinkCodePrompt of Jcoper_SL (Value(Self,0))
                    End_Procedure
                    Procedure PrimeList
                    End_Procedure
                End_Object    // Jcoper_C3_Link_Code

                Object Jcoper_C3_Link_Symbl is a dbForm
                    Entry_Item Jcoper.C3_link_symbl
                    Set Label to "to Link Symbol"
                    Set Size to 13 25
                    Set Location to 40 306
                    Set Label_Col_Offset to 50
                    Set Prompt_Button_Mode to pb_PromptOn

                    procedure Prompt
                        send LinkSymbolPrompt 251
                    end_procedure
                End_Object    // Jcoper_C3_Link_Symbl

            End_Object    // oFormulaExportGroup

        End_Object    // TP_Formulas_Flags

        Object TP_Instruction is a dbTabPage
            Set Label to "Instruction Form"
            Object InstructionGroup is a dbGroup
                Set Size to 96 215
                Set Location to 5 5
                Object Jcoper_Instrctn_form is a dbEdit
                    Entry_Item Jcoper.Instrctn_form
                    Set Size to 80 200
                    Set Location to 10 5
                End_Object    // Jcoper_Instrctn_form

            End_Object    // InstructionGroup

        End_Object    // TP_Instruction

    End_Object    // dbStandardsTabDialog

//    procedure AttachRecords
//        integer hJcoperDD iCntr iOper
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
//        integer hJcoperDD
//        move (Jcoper_DD(self)) to hJcoperDD
//        if NOT (Current_Record(hJcoperDD)) procedure_return
//        send Refind_Records to hJcoperDD
//        set Item_Shadow_State of (oViewFloatingMenu(self)) item 3 to true
//        send Popup To (oViewFloatingMenu(self))
//        set Item_Shadow_State of (oViewFloatingMenu(self)) item 3 to false
//    end_procedure
    
    Procedure Request_Save
        Boolean bReadOnly
        Integer bCancel iSaveMsg
        //
        Get pbReadOnly to bReadOnly
        if bReadOnly Begin
            send request_assign to Jcoper_DD
            procedure_return
        end
        get Verify_Save_Msg to iSaveMsg
        set Verify_Save_Msg to GET_No_Confirmation
        get Confirm "Save Estimating Standard?" to bCancel
        if (NOT(bCancel) AND Should_Save(self)) begin
            send InitializeEstimatingStandard to (Server(self))
            forward send Request_Save
        end
        set Verify_Save_Msg to iSaveMsg
    End_Procedure
    
    Procedure Request_Delete
        Boolean bQuit
        //
        Get Confirm "Remove this Operation as an Estimating Standard?" to bQuit
        if bQuit procedure_return
        send RemoveEstimatingData to (Server(self))
        //send Request_Clear
    End_Procedure
    
    On_Key Key_Alt+Key_C Send DoCalcButton     of oStandardContainer
    On_Key Key_Alt+Key_T Send DoHelpTextButton of oStandardContainer
    
    on_Key Key_Alt+Key_1 Send SwitchToVariablesTabPage
    on_Key Key_Alt+Key_2 Send SwitchToConstantsTabPage
    on_Key Key_Alt+Key_3 Send SwitchToTableTabPage
    on_Key Key_Alt+Key_4 Send SwitchToFormulasTabPage
    on_Key Key_Alt+Key_5 Send SwitchToInstructionTabPage
    //
    Procedure SwitchToVariablesTabPage
        send Request_Switch_To_Tab to (dbStandardsTabDialog(self)) 0 3
    End_Procedure
    Procedure SwitchToConstantsTabPage
        send Request_Switch_To_Tab to (dbStandardsTabDialog(self)) 1 3
    End_Procedure
    Procedure SwitchToTableTabPage
        send Request_Switch_To_Tab to (dbStandardsTabDialog(self)) 2 3
    End_Procedure
    Procedure SwitchToFormulasTabPage
        send Request_Switch_To_Tab to (dbStandardsTabDialog(self)) 3 3
    End_Procedure
    Procedure SwitchToInstructionTabPage
        send Request_Switch_To_Tab to (dbStandardsTabDialog(self)) 4 3
    End_Procedure
    //
    procedure Beginning_Of_Panel
        send Request_Tab_Display to (dbStandardsTabDialog(self))
        forward send Beginning_Of_Panel
    end_procedure
    
    on_key kPrint_Screen send PrintStandard
    
    procedure PrintStandard
        integer hDD
        string  sStart sStop
        //
        get Server to hDD
        if (NOT(Current_Record(hDD))) procedure_return
        send Refind_Records of hDD
     // BC begin
        Move JCOPER.Opcode to sStart
        Move JCOPER.Opcode to sStop
        Send JumpStartReport of Est_Std_rpt sStart sStop TRUE ""
     // BC End
    //        chain wait "Esa070W1" export_only
    end_procedure
    
    procedure Request_Clear
        forward send Request_Clear
        send Activate of oStandardContainer //Beginning_Of_Panel
    end_procedure
    
    procedure Request_Clear_All
        forward send Request_Clear_All
        send Activate of oStandardContainer //Beginning_Of_Panel
    end_procedure

//    Procedure Activating
//        boolean bReadOnly 
//        get pbReadonly of ghoApplication to bReadOnly
//        set pbReadonly to bReadOnly
//        set Read_Only_State of Jcoper_DD to bReadOnly
//        if bReadOnly Set Label to "Standards & Calculations - READ ONLY"
//        else Set Label to "Standards & Calculations"
//    End_Procedure
    
End_Object    // oStandards
