Use Windows.pkg
Use DFClient.pkg

Use Location.sl
Use Employer.DD
Use Employee.DD
Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use MastOps.DD
Use Opers.DD
Use Trans.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd

Open Customer
Open Contact
Open Location
Open Quotehdr
Open Opers
Open Project
Open Order
Open Trans
Open Invhdr
Open pminvhdr
Open System

Deferred_View Activate_oLocationUtility for ;
Object oLocationUtility is a dbView
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

    Object oSalesRep_DD is a Salesrep_DataDictionary
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

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oEmployer_DD
    End_Object

    Object oTrans_DD is a Trans_DataDictionary
        Set DDO_Server to oOpers_DD
        Set DDO_Server to oOrder_DD
        Set DDO_Server to oEmployee_DD
    End_Object

    Set Main_DD to oTrans_DD
    Set Server to oTrans_DD

//    Property String psSource
//    Property String psTarget

    Set Border_Style to Border_Thick
    Set Size to 100 360
    Set Location to 66 230
    Set Label to "Location Utility"

    Object oSourceForm is a Form
        Set Size to 13 50
        Set Location to 20 66
        Set Label to "Source:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOn
        Set Prompt_Object to Location_sl

//        Procedure Prompt
//            Forward Send Prompt
//            //
//            Set psSource to (trim(Customer.Name))
//        End_Procedure
    End_Object

    Object oSourceTextBox is a TextBox
        Set Size to 50 10
        Set Location to 22 130
        Set Label to "This is the Location that will be deleted"
    End_Object

    Object oTargetForm is a Form
        Set Size to 13 50
        Set Location to 45 66
        Set Label to "Target:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Prompt_Button_Mode to PB_PromptOn
        Set Prompt_Object to Location_sl

//        Procedure Prompt
//            Forward Send Prompt
//            //
//            Set psTarget to (trim(Customer.Name))
//        End_Procedure
    End_Object

    Object oTargetTextBox is a TextBox
        Set Size to 50 10
        Set Location to 47 130
        Set Label to "Source records will be combined with this Location"
    End_Object

    Object oCombineButton is a Button
        Set Location to 70 66
        Set Label to "Combine"
    
        Procedure OnClick
            Boolean bCancel
            Integer iSource iSourceCust iTarget iTargetCust
            String  sSource sTarget
            //
            Get Value of oSourceForm to iSource
            Clear Location
            Move iSource to Location.LocationIdno
            Find eq Location.LocationIdno
            If (not(Found)) Begin
                Send Stop_Box "Invalid Location"
                Procedure_Return
            End
            Move Location.CustomerIdno to iSourceCust
            Move (Trim(Location.Name)) to sSource
            //
            Get Value of oTargetForm to iTarget
            Clear Location
            Move iTarget to Location.LocationIdno
            Find eq Location.LocationIdno
            If (not(Found)) Begin
                Send Stop_Box "Invalid Location"
                Procedure_Return
            End
            Move Location.CustomerIdno to iTargetCust
            Move (Trim(Location.Name)) to sTarget
            //
            If (iSourceCust <> iTargetCust) Begin
                Send Stop_Box "The source and target locations do not belong to the same customer"
                Procedure_Return
            End
            //
            Get Confirm ("Combine" * String(iSource) * sSource * "with" * String(iTarget) * sTarget + "?") to bCancel
            If (bCancel) Procedure_Return
            //
            Send DoCombineLocationRecords iSource iTarget
            //
            Set Value of oSourceForm to ""
            Set Value of oTargetForm to ""
            //
            Send Close_Panel
        End_Procedure
    End_Object

    Procedure DoCombineLocationRecords Integer iSource Integer iTarget
        
        Integer iSourceOpers iTargetOpers iTempOpers iTempCust iTempMastOps 
        String sTempName sTempSellRate sTempCostRate sTempCostType sTempCalcBasis sTempActivityType sTempDescription sTempStatus sTempDisplaSequence
        Boolean bFail
        
        //Move all Quotes
        Clear Quotehdr
        Move iSource to Quotehdr.LocationIdno
        Find ge Quotehdr.LocationIdno
        While ((Found) and Quotehdr.LocationIdno = iSource)
            Reread
            Move iTarget to Quotehdr.LocationIdno
            SaveRecord Quotehdr
            Unlock
            Clear Quotehdr
            Move iSource to Quotehdr.LocationIdno
            Find ge Quotehdr.LocationIdno
        Loop
        // Find current Opers at Source
        Clear Opers
        Move iSource to Opers.LocationIdno
        Find ge Opers.LocationIdno
        While ((Found) and Opers.LocationIdno = iSource)
//            Move Opers.MastOpsIdno          to iTempMastOps
//            Move Opers.CustomerIdno         to iTempCust
            Move Opers.OpersIdno            to iSourceOpers
//            Move Opers.Name                 to sTempName
//            Move Opers.SellRate             to sTempSellRate
//            Move Opers.CostRate             to sTempCostRate
//            Move Opers.CostType             to sTempCostType
//            Move Opers.CalcBasis            to sTempCalcBasis
//            Move Opers.ActivityType         to sTempActivityType
//            Move Opers.Description          to sTempDescription
//            Move Opers.Status               to sTempStatus
//            Move Opers.DisplaySequence      to sTempDisplaSequence
//            Clear Opers
//            // Find existing Opers at Target
//            Move iTempMastOps to Opers.MastOpsIdno
//            Move iTarget to Opers.LocationIdno
//            Find eq Opers by Index.3
//            If ((Found) and Opers.MastOpsIdno = iTempMastOps and Opers.LocationIdno = iTarget) Begin
//                // Trigger Move Transaction Procedure
//                Move Opers.OpersIdno to iTargetOpers
//                //Showln ("Opers Record"* (String(Opers.OpersIdno))* "-" * Opers.Name * "already exists - Relocate all Transactions w"* (String(Opers.OpersIdno)))
//                //Showln ("iSourceOpers:"* String(iSourceOpers) * "-" * "iTargetOpers:" * String(iTargetOpers))
//                //Send RelocateTransactions iSourceOpers iSource iTargetOpers iTarget
//            End
//            Else Begin
//                //Showln ("Opers Record"*(String(iTargetOpers))* "-" * Opers.Name * "NOT Found - Create New Opers Record")
//                Reread System
//                    Increment System.LastOpers
//                    Save System
//                    Move System.LastOpers to iTargetOpers
//                Unlock
//                Clear MastOps
//                Move iTempMastOps to MastOps.MastOpsIdno
//                Find GE MastOps by Index.1
//                If ((Found) and MastOps.MastOpsIdno = iTempMastOps) Begin
//                    Clear Opers
//                    Lock                  
//                        Move iTargetOpers               to Opers.OpersIdno
//                        Move iTempCust                  to Opers.CustomerIdno
//                        Move iTarget                    to Opers.LocationIdno 
//                        Move sTempName                  to Opers.Name
//                        Move sTempSellRate              to Opers.SellRate
//                        Move sTempCostRate              to Opers.CostRate
//                        Move sTempCostType              to Opers.CostType
//                        Move sTempCalcBasis             to Opers.CalcBasis
//                        Move sTempActivityType          to Opers.ActivityType
//                        Move sTempDescription           to Opers.Description
//                        Move 0                          to Opers.Display
//                        Move sTempStatus                to Opers.Status
//                        Move sTempDisplaSequence        to Opers.DisplaySequence
//                        Move 1                          to Opers.ChangedFlag
//                        Save Opers
//                    Unlock
//                End
////                Send RelocateTransactions iSourceOpers iSource iTargetOpers iTarget
//            End
            // Set old opers record to inactive
            Clear Opers
            Move iSourceOpers to Opers.OpersIdno
            Find eq Opers.OpersIdno
            If ((Found) and Opers.LocationIdno = iSource) Begin
                Reread Opers
                Move "I" to Opers.Status
                Move 1 to Opers.ChangedFlag
                SaveRecord Opers
                Unlock
                           
            End
            Find GT Opers by Index.2
        Loop
        //
        Clear Order
        Move iSource to Order.LocationIdno
        Find ge Order.LocationIdno
        While ((Found) and Order.LocationIdno = iSource)
            Reread
            Move iTarget to Order.LocationIdno
            SaveRecord Order
            Unlock
            // Trans
            //
            Clear Invhdr
            Move Order.JobNumber to Invhdr.JobNumber
            Find ge Invhdr.JobNumber
            While ((Found) and Invhdr.JobNumber = Order.JobNumber)
                Reread
                Move iTarget to Invhdr.LocationIdno
                SaveRecord Invhdr
                Unlock
                Find gt Invhdr.JobNumber
            Loop
            //
            Clear PMInvhdr
            Move Order.JobNumber to PMInvhdr.JobNumber
            Find ge PMInvhdr.JobNumber
            While ((Found) and PMInvhdr.JobNumber = Order.JobNumber)
                Reread
                Move iTarget to Invhdr.LocationIdno
                SaveRecord PMInvhdr
                Unlock
                Find gt PMInvhdr.JobNumber
            Loop
            //
            Clear Order
            Move iSource to Order.LocationIdno
            Find ge Order.LocationIdno
        Loop
        //
        Clear Location
        Move iSource to Location.LocationIdno
        Find eq Location.LocationIdno
        If (Found) Begin
            Reread Location
            Delete Location
            Unlock
        End
    End_Procedure

//    Procedure RelocateTransactions Integer iSourceOpers Integer iOldLocation Integer iTargetOpers Integer iNewLocation
//            Integer iRunCounter
//            Clear Trans
//            Move iSourceOpers to Trans.OpersIdno
//            Find GE Trans by Index.4
//            While ((Found) and Trans.OpersIdno = iSourceOpers and Trans.LocationIdno = iOldLocation)
//                Reread Trans
//                    Move iNewLocation to Trans.LocationIdno
//                    Move iTargetOpers to Trans.OpersIdno
//                    SaveRecord Trans
//                Unlock
//                Clear Trans
//                Move iSourceOpers to Trans.OpersIdno
//                Find GT Trans by Index.4
//                Increment iRunCounter
//            Loop
//            //Showln ("Changed" *(String(iRunCounter)) * "Transactions")
//    End_Procedure

Cd_End_Object
