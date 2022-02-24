Use Windows.pkg
Use DFClient.pkg
Use cTextEdit.pkg
Use cWSTransactionService.pkg
Use StdAbout.pkg
//
Use CollectTransactionsProcess.bp
Use CollectLocationNotesProcess.bp
Use CollectAreaNotesProcess.bp

Activate_View Activate_oStatusView for oStatusView
Object oStatusView is a View
    Set Border_Style to Border_Thick
    Set Size to 269 415
    Set Location to 2 2
    Set Label to "StatusView"
    Set Maximize_Icon to True
    Set Minimize_Icon to False
    Set Caption_Bar to False
    Set peAnchors to anBottomLeft

    Object oWSTransactionService is a cWSTransactionService
        //    
    End_Object
        
    Property Boolean pbProcessing
    
    Object oStatusUpdateTextBox is a cTextEdit
        Set Size to 247 408
        Set Location to 3 3
        Set peAnchors to anAll
    End_Object

    Object oManualSyncButton is a Button
        Set Size to 14 71
        Set Location to 254 5
        Set Label to 'Manual 10 Min Sync'
        Set peAnchors to anBottomLeft
    
        // fires when the button is clicked
        Procedure OnClick
            
        End_Procedure
    
    End_Object

    Object oManCloseNoteButton2 is a Button
        Set Size to 14 71
        Set Location to 254 85
        Set Label to 'Manual Close Note'
        Set peAnchors to anBottomLeft
    
        // fires when the button is clicked
        Procedure OnClick
            Send DoAutoCloseCallCenterNotes of oStatusView
        End_Procedure
    
    End_Object

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////




    Procedure Activate_About
        Send DoAbout "" "" "" "" ""
    End_Procedure

    Object oServiceTimer is a DFTimer
        Set Timer_Active_State to True
        //set Timeout            to 100 // 1/10th of a second
        Set Timeout            to 600000 // = 600 seconds = 10 minutes
        Procedure OnTimer
            Send DoNewActivityCheck
        End_Procedure
    End_Object // oServiceTimer
        
    Object oCloseLocnotesTimer is a DFTimer
        Set Timer_Active_State to True
        // 6000/1000 = 1sec
        // 60000 = 600sec = 10min
        // 3600000 = 3600 sec = 60min = 1h
        Set Timeout            to 3600000

        Procedure OnTimer
            Send DoAutoCloseCallCenterNotes
        End_Procedure
        
        Procedure Start_Timer
            Set Timer_Active_State of oCloseLocnotesTimer to True
            Send Info_Box "Close Locnotes Timer started"
        End_Procedure
        
        Procedure Stop_Timer
            Set Timer_Active_State of oCloseLocnotesTimer to False
        End_Procedure
        
    End_Object // oServiceTimer
        
    Procedure DoAutoCloseCallCenterNotes
        DateTime dtNow dtLocNoteRes
        Date dToday
        TimeSpan tsTimeDiff
        String sLocNoteResTime
        Integer iHr iMin iSec iDayDiff iHrDiff iLocnoteIdno
        Boolean bIsValid bSuccess
        //
        Move (CurrentDateTime())    to dtNow
        //
//            Send AppendTextLn of oOnScreenOutput
        Showln (String(dtNow) * " - START - DoAutoCloseCallCenterNotes")
        
        //
        Clear Locnotes
        Move "3-RESOLVED" to Locnotes.Status
        Find GE Locnotes by 7
        While ((Found) and Locnotes.Status="3-RESOLVED")
            If (Locnotes.ResolvedDate>="10/01/2018") Begin
                Move (Locnotes.ResolvedDate) to dtLocNoteRes
                Move Locnotes.ResolvedTime to sLocNoteResTime
                Get IsTimeValid (&sLocNoteResTime) (&iHr) (&iMin) to bIsValid
                Move (DateSetHour(dtLocNoteRes, iHr)) to dtLocNoteRes
                Move (DateSetMinute(dtLocNoteRes, iMin)) to dtLocNoteRes
                Move (dtNow - dtLocNoteRes) to tsTimeDiff
                Move (DateGetDay(tsTimeDiff)) to iDayDiff
                Move (DateGetHour(tsTimeDiff)) to iHrDiff
                If ((iDayDiff>=1) or (iHrDiff>=24)) Begin
                    //Trigger the DoCloseExpiredLocationsNote procedure on the remote server
                    Get wsDoCloseExpiredLocationNote of oWSTransactionService Locnotes.LocnotesId to bSuccess
                    If (bSuccess) Begin
                        Showln ("Closed Note#"*String(Locnotes.LocnotesId))
                    End
                    If (not(bSuccess)) Begin
                        Showln ("Closing of Note#"*String(Locnotes.LocnotesId))
                    End
//                        Sysdate dToday iHr iMin iSec
//                        Get IsTimeString iHr iMin iSec to sLocNoteResTime
//                        Showln ("Note#:"*String(Locnotes.LocnotesId)*" - Status:"* (Trim(Locnotes.Status))*" - TimeDifference: "* String(tsTimeDiff))
//                        Reread Locnotes
//                            Move "4-CLOSED"                         to Locnotes.Status
//                            Move "System(Auto)"                     to Locnotes.ClosedBy
//                            Move dToday                             to Locnotes.ClosedDate
//                            Move sLocNoteResTime                    to Locnotes.ClosedTime
//                            Move 1                                  to Locnotes.ChangedFlag
//                            SaveRecord Locnotes
//                        Unlock
                End
            End
            Move "3-RESOLVED" to Locnotes.Status
            Find GT Locnotes by 7
        Loop
    End_Procedure
        
    Procedure DoNewActivityCheck
        DateTime dtCurrent
        Integer  iErrorId iCount iCollected
        String sDateMonth sDateYear sServiceLocation
        String   sLabel sOutput sResult sError
        //
        If (pbProcessing(Self)) Begin
            Procedure_Return
        End
        //
        Move (CurrentDateTime()) to dtCurrent
        Move (DateGetMonth(dtCurrent)) to sDateMonth
        Move (DateGetYear(dtCurrent)) to sDateYear
        //
        Set pbProcessing   to True
        Get Label of oStatusView to sLabel
        Set Label of oStatusView to (sLabel * "-Processing")
        //
        Get psHome of (phoWorkspace(ghoApplication)) to sOutput
        If (not(Right(sOutput,1) = "\")) Begin
            Move (sOutput + "\")                     to sOutput
        End
        Move (sOutput + "Document\Log\"+sDateYear+"_"+sDateMonth+"_Remote.log")   to sOutput
        //  
        Append_Output sOutput
        Writeln "Start: " dtCurrent
        //
        Get psServiceLocation of oWSTransactionService to sServiceLocation
        Writeln ("Service Location: "*sServiceLocation)
        //
        Move ""                                                                                     to sError
        Get DoCollectAndProcessTransactions  of oCollectTransactionsProcess (&sError) (&iCollected) to iCount
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln (String(iCollected) * "transactions collected")
        Writeln (String(iCount)     * "transactions processed")
        //
        Move ""                                                                        to sError
        Get DoCollectAndProcessLocationNotes of oCollectLocationNotesProcess (&sError) to iCount
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln (String(iCount) * "location notes collected")
        //
        Move ""                                                                        to sError
        Get DoCollectAndProcessAreaNotes     of oCollectAreaNotesProcess     (&sError) to iCount
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln (String(iCount) * "area notes collected")
        //
        Move ""                                                       to sError
        Get DoUpdateMastOps  of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        Move ""                                                       to sError
        Get DoUpdateAreas    of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        Move ""                                                       to sError
        Get DoUpdateCustomer of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        // Update SalesTaxGroup
        Move ""                                                       to sError
        Get DoUpdateSalesTaxGroup  of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        Move ""                                                       to sError
        Get DoUpdateLocation of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        Move ""                                                       to sError
        Get DoUpdateOpers    of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        Move ""                                                       to sError
        Get DoUpdateOrder    of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        Move ""                                                       to sError
        Get DoUpdateEmployer of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        Move ""                                                       to sError
        Get DoUpdateEmployee of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        Move ""                                                       to sError
        Get DoUpdateEquipmnt of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        // Update LocEquip
        Move ""                                                       to sError
        Get DoUpdateLocEquip of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        // Update SalesRep
        Move ""                                                       to sError
        Get DoUpdateSalesRep  of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        // Update WorkType
        Move ""                                                       to sError
        Get DoUpdateWorkType  of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        // Update User Records
        Move ""                                                       to sError
        Get DoUpdateUser     of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        // Update WebAppUserRights Records
        Move ""                                                       to sError
        Get DoUpdateWebAppUserRights of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        // Update WebAppUser Records
        Move ""                                                       to sError
        Get DoUpdateWebAppUser of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        // Update Contact Records
        Move ""                                                       to sError
        Get DoUpdateContact     of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        Move ""                                                       to sError
        Get DoUpdateInvoice  of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        Move ""                                                       to sError
        Get DoUpdateReqtypes of oCollectTransactionsProcess (&sError) to sResult
        If (sError <> "") Begin
            Writeln sError
        End
        Writeln sResult
        //
        Move (CurrentDateTime()) to dtCurrent
        Writeln "Stop: " dtCurrent
        Close_Output
        //
        Set Label of oStatusView to sLabel
        Set pbProcessing   to False
    End_Procedure
    //
    On_Key kUser Send DoNewActivityCheck
    On_Key Key_Alt+Key_S Send DoAutoCloseCallCenterNotes

End_Object
