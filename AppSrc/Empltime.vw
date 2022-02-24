#IFNDEF ptStartShift
Enum_List // punch type
    Define ptStartShift
    Define ptLunchOut
    Define ptLunchIn
    Define ptStopShift
End_Enum_List
#ENDIF

Use Windows.pkg
Use DFClient.pkg
Use cTempusDbView.pkg
Use cTextEdit.pkg
Use cszDropDownButton.pkg
Use TransactionProcess.bp

Use Employer.DD
Use Employee.DD
Use Empltime.DD

//
///TimeCardHeader
//                           Lunch
//   Date        Start    Out     In     Stop
//---------------------------------------------
///TimeCardBody
// __/__/____    _____   _____   _____   _____
///*

Activate_View Activate_oEmpltime for oEmpltime
Object oEmpltime is a cTempusDbView

    Property Boolean pbActive
    Property Integer pePunchType ptStartShift
    Property String  psFilename

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oEmployer_DD
    End_Object

    Object oEmpltime_DD is a Empltime_DataDictionary
        Set Constrain_file to Employee.File_number
        Set DDO_Server to oEmployee_DD

        Procedure Update
            Forward Send Update
            //
            If (pePunchType(Self) = ptStartShift) Begin
                Move Empltime.EmpltimeId to Employee.ActiveEmpltime
            End
            If (pePunchType(Self) = ptStopShift) Begin
                Move 0                   to Employee.ActiveEmpltime
            End
        End_Procedure   // Update

        Function Request_Validate Returns Boolean
            Boolean bFail
            Integer ePunchType
            //
            Get pePunchType to ePunchType
            //
            If (not(bFail)) Begin
                Forward Get Request_Validate to bFail
            End
            //
            Function_Return bFail
        End_Function   // Request_Validate
 
    End_Object

    Set Main_DD to oEmpltime_DD
    Set Server to oEmpltime_DD

    Set Border_Style to Border_Thick
    Set Size to 287 536
    Set Location to 12 12
    Set piMinSize to 287 536
    Set View_Latch_State to False
//    Set View_Mode to Viewmode_Zoom
    Set Maximize_Icon to True
    Set Label to "Employee Time Clock"
    Set Caption_Bar to False

    Object oReportEdit is a cTextEdit
        Set psTypeface to "Courier"
        Set Fontsize to 14 8
        Set Size to 213 245
        Set Location to 5 5
        Set peAnchors to anAll
        Set TextColor to clBlack
        Set Color to clWhite
        Set pbBold to True

        Procedure DoPrintTimeCard
//            Integer iRecId iEmployeeIdno iSize
//            String  sTempPath sFilename sStart sLunchOut sLunchIn sStop
//            Date    dDate
//            //
//            Set Read_Only_State          to False
//            Set Dynamic_Update_State     to False
//            //
//            Send Delete_Data
//            //
//            Get_Environment "TEMP"       to sTempPath
//            Get IsLongPathName sTempPath to sTempPath
//            If (right(sTempPath,1) <> "\") Begin
//                Move (sTempPath + "\")   to sTempPath            
//            End
//            Move "Timecard.TXT"          to sFilename
//            Move (sTempPath + sFilename) to sFilename
//            Set psFilename               to sFilename
//            //
//            Direct_Output sFilename
//            // Write the Header
//            Output TimeCardHeader
//            Move Employee.EmployeeIdno   to iEmployeeIdno
//            If (iEmployeeIdno = 0) Begin
//                Procedure_Return
//            End
//            Sysdate                         dDate
//            Move (dDate + 1)             to dDate
//            Move Empltime.Recnum         to iRecId
//            Clear Empltime
//            Move iEmployeeIdno           to Empltime.EmployeeId
//            Move dDate                   to Empltime.StartDate
//            Find ge Empltime.EmployeeId
//            While ((Found) and Empltime.EmployeeId = iEmployeeIdno)
//                Get IsFormattedTime Empltime.StartHr    Empltime.StartMn    to sStart
//                Get IsFormattedTime Empltime.LunchOutHr Empltime.LunchOutMn to sLunchOut
//                Get IsFormattedTime Empltime.LunchInHr  Empltime.LunchInMn  to sLunchIn
//                Get IsFormattedTime Empltime.StopHr     Empltime.StopMn     to sStop
//                //
//                autopage TimeCardBody
//                Print Empltime.StartDate
//                Print sStart
//                Print sLunchOut
//                Print sLunchIn
//                Print sStop
//                Output TimeCardBody
//                //
//                Find gt Empltime.EmployeeId
//            Loop
//            //
//            Set_Channel_Position 1   to -1
//            Get_Channel_Position 1   to iSize
//            Close_Output
//            Set piMaxChars           to iSize
//            Send Read sFilename
//            Send Beginning_of_Data
//            Set Dynamic_Update_State to True
//            Set Read_Only_State      to True
//            //
//            If (iRecId <> 0) Begin
//                Clear Empltime
//                Move iRecId to Empltime.Recnum
//                Find eq Empltime.Recnum
//            End
        End_Procedure
    End_Object

    Object oKeypadGroup is a Container3d
        Set Size to 262 166
        Set Location to 5 296
        Set Color to 16744448
        Set peAnchors to anTopRight

        Object oNameForm is a Form
            Set Size to 26 115
            Set Location to 10 5
            Set Color to clWhite
            Set TextColor to clBlack
            Set FontSize to 16 4
            Set FontWeight to 800
            Set Form_Justification_Mode to Form_DisplayCenter
        End_Object

        Object o1Button is a cszDropDownButton
            Set Size to 30 35
            Set Location to 50 5
            Set Label to "1"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoIncrementDisplay 1
            End_Procedure
        End_Object

        Object o2Button is a cszDropDownButton
            Set Size to 30 35
            Set Location to 50 58
            Set Label to "2"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoIncrementDisplay 2
            End_Procedure
        End_Object

        Object o3Button is a cszDropDownButton
            Set Size to 30 35
            Set Location to 50 111
            Set Label to "3"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoIncrementDisplay 3
            End_Procedure
        End_Object

        Object o4Button is a cszDropDownButton
            Set Size to 30 35
            Set Location to 92 5
            Set Label to "4"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoIncrementDisplay 4
            End_Procedure
        End_Object

        Object o5Button is a cszDropDownButton
            Set Size to 30 35
            Set Location to 92 58
            Set Label to "5"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoIncrementDisplay 5
            End_Procedure
        End_Object

        Object o6Button is a cszDropDownButton
            Set Size to 30 35
            Set Location to 92 111
            Set Label to "6"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoIncrementDisplay 6
            End_Procedure
        End_Object

        Object o7Button is a cszDropDownButton
            Set Size to 30 35
            Set Location to 134 5
            Set Label to "7"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoIncrementDisplay 7
            End_Procedure
        End_Object

        Object o8Button is a cszDropDownButton
            Set Size to 30 35
            Set Location to 134 58
            Set Label to "8"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoIncrementDisplay 8
            End_Procedure
        End_Object

        Object o9Button is a cszDropDownButton
            Set Size to 30 35
            Set Location to 134 111
            Set Label to "9"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoIncrementDisplay 9
            End_Procedure
        End_Object

        Object oClearAllButton is a cszDropDownButton
            Set Size to 30 35
            Set Location to 175 5
            Set Label to "Clear All"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoClearDisplay
            End_Procedure
        End_Object

        Object o0Button is a cszDropDownButton
            Set Size to 30 35
            Set Location to 175 58
            Set Label to "0"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoIncrementDisplay 0
            End_Procedure
        End_Object

        Object oClearButton is a cszDropDownButton
            Set Size to 30 35
            Set Location to 175 111
            Set Label to "Clear"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoDecrementDisplay
            End_Procedure
        End_Object

        Object oEnterButton is a cszDropDownButton
            Set Size to 30 35
            Set Location to 216 111
            Set Label to "Enter"
            Set Color to clWhite
            Set piTextColor to clBlack
            Set FontWeight to 800
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoProcessDisplay
            End_Procedure
        End_Object

        Procedure DoIncrementDisplay Integer iNumber
            Integer hoDD iEmployeeIdno iEmpltimeId
            String  sNumber
            Date    dToday
            //
            If (not(HasRecord(oEmployee_DD))) Begin
//                Set pbActive                     to False
//                Get Server                       to hoDD
                Get Value         of oNameForm   to sNumber
                Move (sNumber + String(iNumber)) to sNumber
//                Move (Integer(sNumber))          to iEmployeeIdno
//                Send Clear_All    of hoDD
//                Move iEmployeeIdno               to Employee.EmployeeIdno
//                Send Request_Find of hoDD EQ Employee.File_Number 1
//                If (Found) Begin
//                    Set pbActive                 to (Employee.Status = "A")
//                    Move Employee.ActiveEmpltime to iEmpltimeId
//                    If (iEmpltimeId) Begin
//                        Sysdate dToday
//                        Move iEmpltimeId         to Empltime.EmpltimeId
//                        Send Find of hoDD EQ 1
//                    End
//                    Set Value of oNameForm       to (Trim(Employee.FirstName) * Trim(Employee.LastName))
//                End
//                Else Begin
                    Set Value of oNameForm       to sNumber
//                End
            End
        End_Procedure

        Procedure DoDecrementDisplay
            Integer iLength
            String  sNumber
            //
            If (HasRecord(oEmployee_DD)) Begin
                Send DoClearDisplay
            End
            Else Begin
                Get Value of oNameForm to sNumber
                If (sNumber <> "") Begin
                    Move (Length(sNumber)) to iLength
                    If (iLength = 1) Begin
                        Move "" to sNumber
                    End
                    Else Begin
                        Decrement iLength
                        Move (Left(sNumber,(iLength))) to sNumber
                    End
                    Set Value of oNameForm to sNumber
                End
            End
        End_Procedure

        Procedure DoProcessDisplay
            Integer hoDD iEmployeeIdno iEmpltimeId
            String  sNumber
            Date    dToday
            //
            If (not(HasRecord(oEmployee_DD))) Begin
                Set pbActive                     to False
                Get Server                       to hoDD
                Get Value         of oNameForm   to sNumber
//                Move (sNumber + String(iNumber)) to sNumber
                Move (Integer(sNumber))          to iEmployeeIdno
                Send Clear_All    of hoDD
                Move iEmployeeIdno               to Employee.EmployeeIdno
                Send Request_Find of hoDD EQ Employee.File_Number 1
                If (Found) Begin
                    Set pbActive                 to (Employee.Status = "A")
                    Move Employee.ActiveEmpltime to iEmpltimeId
                    If (iEmpltimeId) Begin
                        Sysdate dToday
                        Move iEmpltimeId         to Empltime.EmpltimeId
                        Send Find of hoDD EQ 1
                    End
                    Set Value of oNameForm       to (Trim(Employee.FirstName) * Trim(Employee.LastName))
                End
                Else Begin
                    Set Value of oNameForm       to sNumber
                End
            End
        End_Procedure
    End_Object

    Object oTimeButtonContainer is a Container3d
        Set Size to 271 71
        Set Location to 0 466
        Set Border_Style to Border_None
        Set peAnchors to anTopBottomRight

        Object oStartButton is a cszDropDownButton
            Set Size to 34 42
            Set Location to 5 5
            Set Label to "Start"
            Set Color to clGreen
            Set piTextColor to clBlack
            Set FontWeight to 1200
            Set FontSize to 16 4
            Set pbDropDownButton to False
            Set piTextHotColor to clRed

            Procedure OnClick
                Send DoTimePunch ptStartShift
            End_Procedure
        End_Object
    
        Object oLunchOutButton is a cszDropDownButton
            Set Size to 34 42
            Set Location to 54 5
            Set Label to "Lunch Out"
            Set Color to clYellow
            Set piTextColor to clBlack
            Set FontWeight to 1200
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoTimePunch ptLunchOut
            End_Procedure
        End_Object
    
        Object oLunchInButton is a cszDropDownButton
            Set Size to 34 42
            Set Location to 102 5
            Set Label to "Lunch In"
            Set Color to clYellow
            Set piTextColor to clBlack
            Set FontWeight to 1200
            Set FontSize to 16 4
            Set pbDropDownButton to False

            Procedure OnClick
                Send DoTimePunch ptLunchIn
            End_Procedure
        End_Object
    
        Object oStopButton is a cszDropDownButton
            Set Size to 34 42
            Set Location to 152 5
            Set Label to "End Day"
            Set Color to clRed
            Set piTextColor to clBlack
            Set FontWeight to 1200
            Set FontSize to 16 4
            Set pbDropDownButton to False
            Set piTextHotColor to clBlack

            Procedure OnClick
                Send DoTimePunch ptStopShift
            End_Procedure
        End_Object

        Object oTimeCardButton is a cszDropDownButton
            Set Size to 34 42
            Set Location to 202 5
            Set Label to "Time Card"
            Set Color to clBlue
            Set piTextColor to clBlack
            Set FontWeight to 1200
            Set FontSize to 16 4
            Set pbDropDownButton to False
            Set piTextHotColor to clBlack

            Procedure OnClick
                Send DoTimeCard
            End_Procedure
        End_Object

    End_Object

    Object oExitButton is a Button
        Set Size to 10 10
        Set Location to 275 5
        Set FlatState to True
        Set peAnchors to anBottomLeft
    
        Procedure OnClick
            Send Exit_Application
        End_Procedure
    End_Object

    Function IsFormattedTime Integer iHr Integer iMn Returns String
        String sHr sMn sTime
        //
        Move iHr to sHr
        If (Length(sHr) <> 2) Begin
            Move ("0" + sHr) to sHr
        End
        Move iMn to sMn
        If (Length(sMn) <> 2) Begin
            Move ("0" + sMn) to sMn
        End
        Move (sHr + ":" + sMn) to sTime
        Function_Return sTime
    End_Function

    Procedure DoClearDisplay
        Set Value        of oNameForm to ""
        Send Clear_All   of oEmpltime_DD
        Send Delete_Data of oReportEdit
    End_Procedure

    Procedure DoTimePunch Integer ePunchType
        Boolean bValidPunch bFail bSuccess
        Integer hoDD iHr iMn iDateField iHrField iMnField
        Integer iTransIdno iJobnumber iEmployeeId iOpersIdno
        Date    dToday
        //
        If (not(HasRecord(oEmployee_DD))) Begin
            Procedure_Return
        End
        //
        If (not(pbActive(Self))) Begin
            Send Stop_Box "Inactive Employee, not allowed."
            Procedure_Return
        End
        //
        Get Server to hoDD
        //
        If      (ePunchType = ptStartShift) Begin
            If (HasRecord(hoDD)) Begin
                Send Stop_Box "You have already started your shift"
                Procedure_Return
            End
            Move 3 to iDateField
            Move 4 to iHrField
            Move 5 to iMnField
            //
            Move Employee.ActiveTrans  to iTransIdno
            Move System.PR_JobNumber   to iJobnumber
            Move Employee.EmployeeIdno to iEmployeeId
            Move System.PR_Active_Oper to iOpersIdno
        End
        Else If (ePunchType = ptLunchOut) Begin
            Move (HasRecord(hoDD)) to bValidPunch
            If (bValidPunch) Begin
                Send Refind_Records of hoDD
                Move (                             ;
                    Empltime.StartDate    <> 0 and ;
                    Empltime.LunchOutDate  = 0 and ;
                    Empltime.LunchInDate   = 0 and ;
                    Empltime.StopDate      = 0     ) to bValidPunch
            End
            If (not(bValidPunch)) Begin
                Send Stop_Box "You have not clocked in"
                Procedure_Return
            End
            Move 6 to iDateField
            Move 7 to iHrField
            Move 8 to iMnField
            //
            Move Employee.ActiveTrans  to iTransIdno
            Move System.PR_JobNumber   to iJobnumber
            Move Employee.EmployeeIdno to iEmployeeId
            Move System.PR_Break_Oper  to iOpersIdno
        End
        Else If (ePunchType = ptLunchIn) Begin
            Move (HasRecord(hoDD)) to bValidPunch
            If (bValidPunch) Begin
                Send Refind_Records of hoDD
                Move (                             ;
                    Empltime.StartDate    <> 0 and ;
                    Empltime.LunchOutDate <> 0 and ;
                    Empltime.LunchInDate   = 0 and ;
                    Empltime.StopDate      = 0     ) to bValidPunch
            End
            If (not(bValidPunch)) Begin
                Send Stop_Box "Not clocked in or not clocked out for lunch"
                Procedure_Return
            End
            Move  9 to iDateField
            Move 10 to iHrField
            Move 11 to iMnField
            //
            Move Employee.ActiveTrans  to iTransIdno
            Move System.PR_JobNumber   to iJobnumber
            Move Employee.EmployeeIdno to iEmployeeId
            Move System.PR_Active_Oper to iOpersIdno
        End
        Else If (ePunchType = ptStopShift) Begin
            Move (HasRecord(hoDD)) to bValidPunch
            If (bValidPunch) Begin
                Send Refind_Records of hoDD
                Move ((                            ;
                    Empltime.StartDate    <> 0 and ;
                    Empltime.LunchOutDate <> 0 and ;
                    Empltime.LunchInDate  <> 0 and ;
                    Empltime.StopDate      = 0) or ;
                    (                              ;
                    Empltime.StartDate    <> 0 and ;
                    Empltime.LunchOutDate  = 0 and ;
                    Empltime.LunchInDate   = 0 and ;
                    Empltime.StopDate      = 0)    ) to bValidPunch
            End
            If (not(bValidPunch)) Begin
                Send Stop_Box "Not Clocked In for the day or not Clocked In from lunch"
                Procedure_Return
            End
            Move 12 to iDateField
            Move 13 to iHrField
            Move 14 to iMnField
            //
            Move Employee.ActiveTrans  to iTransIdno
        End
        //
        Set pePunchType to ePunchType
        Sysdate dToday iHr iMn
        Set Field_Changed_Value of hoDD iDateField to dToday
        Set Field_Changed_Value of hoDD iHrField   to iHr
        Set Field_Changed_Value of hoDD iMnField   to iMn
        Get Request_Validate    of hoDD            to bFail
        If (not(bFail)) Begin
            Send Request_Save   of hoDD
            //
            Get DoProcessTransaction of oTransactionProcess iTransIdno iJobnumber iEmployeeId iOpersIdno to bSuccess
            //
            Send DoClearDisplay
        End
    End_Procedure

    Procedure DoTimeCard
        Boolean bExists
        String  sFilename
        //
        If (not(HasRecord(oEmployee_DD))) Begin
            Procedure_Return
        End
        //
        Send DoPrintTimeCard of oReportEdit
        //
        Get psFilename to sFilename
        File_Exist sFilename bExists
        If (bExists) Begin
            EraseFile sFilename
        End
    End_Procedure

End_Object
