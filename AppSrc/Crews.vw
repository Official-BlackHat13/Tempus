Use Windows.pkg
Use DFClient.pkg
Use cCrewsDataDictionary.dd
Use cCrmemberDataDictionary.dd
Use Employer.DD
Use Employee.DD
Use dfTable.pkg
Use szcalendar.pkg
Use CloneCrewDialog.dg


Deferred_View Activate_oCrews for ;
Object oCrews is a dbView

    Object oEmployer_DD is a Employer_DataDictionary
        Set Auto_Fill_State to True
        Procedure OnConstrain
            Constrain Employer.EmployerIdno eq System.EmployerId
        End_Procedure
    End_Object

    Object oEmployee_DD is a Employee_DataDictionary
        Set Constrain_file to Employer.File_number
        Set DDO_Server to oEmployer_DD
    End_Object

    Object oCrews_DD is a cCrewsDataDictionary
    End_Object

    Object oCrmember_DD is a cCrmemberDataDictionary
        Set DDO_Server to oEmployee_DD
        Set DDO_Server to oCrews_DD
        Set Constrain_file to Crews.File_number

        Function IsEmployeeName Returns String
            String sName
            //
            Move (Trim(Employee.FirstName))              to sName
            If (Employee.MiddleName <> "") Begin
                Move (sName * Trim(Employee.MiddleName)) to sName
            End
            Move (sName * Trim(Employee.LastName))       to sName
            If (Employee.Suffix <> "") Begin
                Move (sName * Trim(Employee.Suffix))     to sName
            End
            Function_Return sName
        End_Function
    End_Object

    Set Main_DD to oCrews_DD
    Set Server to oCrews_DD

    Set Border_Style to Border_Thick
    Set Size to 236 511
    Set Location to 2 2
    Set piMinSize to 236 511
    Set Label to "Crew Maintenance"

    Object oCrewsGrid is a DbGrid
        Set Size to 222 268
        Set Location to 10 10

        Begin_Row
            Entry_Item Crews.CrewDate
            Entry_Item Crews.CrewChiefId
            Entry_Item Crews.Description
            Entry_Item Crews.CrewCount
        End_Row

        Set Main_File to Crews.File_number

        Set Form_Width 0 to 54
        Set Header_Label 0 to "Date"
        Set Form_Width 1 to 40
        Set Header_Label 1 to "Chief ID"
        Set Form_Width 2 to 136
        Set Header_Label 2 to "Description"
        Set Form_Width 3 to 30
        Set Header_Label 3 to "Count"
        Set Wrap_State to True
        Set peAnchors to anAll
        Set CurrentRowColor to clAqua
        Set CurrentCellColor to clAqua
    End_Object

    Object oCrewMembersGrid is a DbGrid
        Set Size to 134 216
        Set Location to 10 287

        Begin_Row
            Entry_Item Crews.CrewId
            Entry_Item Employee.EmployeeIdno
            Entry_Item (IsEmployeeName(oCrmember_DD))
            Entry_Item Crmember.CrewChiefFlag
        End_Row

        Set Main_File to Crmember.File_number

        Set Server to oCrmember_DD

        Set Form_Width 0 to 1
        Set Column_Shadow_State 0 to True
        Set Form_Width 1 to 46
        Set Header_Label 1 to "Empl ID"
        Set Form_Width 3 to 30
        Set Header_Label 3 to "Chief"
        Set Form_Width 2 to 130
        Set Header_Label 2 to "Name"
        Set Column_Checkbox_State 3 to True
        Set Wrap_State to True
        Set peAnchors to anAll
        Set CurrentRowColor to clAqua
        Set CurrentCellColor to clAqua
    End_Object

    Object oCrewCalendar is a cszCalendar
        Set Size to 75 90
        Set Location to 153 413
        Set peAnchors to anBottomRight
    End_Object

    Object oCloneCrewButton is a Button
        Set Location to 160 290
        Set Label to "Clone Crew"
    
        Procedure OnClick
            Send DoCloneOneCrew
        End_Procedure
    End_Object

    Object oCloneAllButton is a Button
        Set Size to 14 70
        Set Location to 180 290
        Set Label to "Clone All Crews"

        Procedure OnClick
            Send DoCloneAllCrews
        End_Procedure
    End_Object

    Function DoCloneCrew Integer iCrewId Date dCrewDate Returns Integer
        Integer iCrewsRecId iRecId
        //
        Send ChangeAllFileModes DF_FILEMODE_READONLY
        Set_Attribute DF_FILE_MODE of System.File_Number   to DF_FILEMODE_DEFAULT
        Set_Attribute DF_FILE_MODE of Crews.File_Number    to DF_FILEMODE_DEFAULT
        Set_Attribute DF_FILE_MODE of Crmember.File_Number to DF_FILEMODE_DEFAULT
        //
        Reread
        Add 1              to System.CrewId
        SaveRecord System
        Move 0             to Crews.Recnum
        Move System.CrewId to Crews.CrewId
        Move dCrewDate     to Crews.CrewDate
        SaveRecord Crews
        Unlock
        Move Crews.Recnum  to iCrewsRecId
        Clear Crmember
        Move iCrewId       to Crmember.CrewId
        Find ge Crmember.CrewId
        While ((Found) and Crmember.CrewId = iCrewId)
            Reread
            Add 1                    to System.CrewMemberId
            SaveRecord System
            Move Crmember.Recnum     to iRecId
            Move 0                   to Crmember.Recnum
            Move System.CrewMemberId to Crmember.CrewMemberId
            Move System.CrewId       to Crmember.CrewId
            Move dCrewDate           to Crmember.CrewDate
            SaveRecord Crmember
            Unlock
            Clear Crmember
            Move iRecId              to Crmember.Recnum
            Find eq Crmember.Recnum
            Find gt Crmember.CrewId
        Loop
        Send ChangeAllFileModes DF_FILEMODE_DEFAULT
        Function_Return iCrewsRecId
    End_Function

    Procedure DoCloneOneCrew
        Boolean bCancel
        Integer hoDD iCrewId iCrewsRecId
        String  sCloneFrom
        Date    dValue
        //
        Move oCrews_DD to hoDD
        If (not(HasRecord(hoDD))) Begin
            Procedure_Return
        End
        //
        Move Crews.CrewId                                          to iCrewId
        Move (String(Crews.CrewDate) * Trim(Crews.Description))    to sCloneFrom
        //
        Get IsClonedToDate of oCloneCrewDialog sCloneFrom          to dValue
        //
        Get Confirm ("Clone" * sCloneFrom * "to" * String(dValue)) to bCancel
        If (bCancel) Procedure_Return
        //
        Get DoCloneCrew iCrewId dValue to iCrewsRecId
        //
        Send Find_By_Recnum of hoDD Crews.File_Number iCrewsRecId
        Send Activate       of oCrewsGrid
    End_Procedure

    Procedure DoCloneAllCrews
        Boolean bCancel
        Integer hoDD iRecId iCrewsRecId
        String  sCloneFrom
        Date    dCrewDate dValue
        //
        Move oCrews_DD to hoDD
        If (not(HasRecord(hoDD))) Begin
            Procedure_Return
        End
        //
        Move Crews.CrewDate           to dCrewDate
        Move (String(Crews.CrewDate)) to sCloneFrom
        //
        Get IsClonedToDate of oCloneCrewDialog sCloneFrom          to dValue
        //
        Get Confirm ("Clone" * sCloneFrom * "to" * String(dValue)) to bCancel
        If (bCancel) Procedure_Return
        //
        Clear Crews
        Move dCrewDate to Crews.CrewDate
        Find ge Crews.CrewDate
        While ((Found) and Crews.CrewDate = dCrewDate)
            Move Crews.Recnum to iRecId
            Get DoCloneCrew Crews.CrewId dValue to iCrewsRecId
            Clear Crews
            Move iRecId to Crews.Recnum
            Find eq Crews.Recnum
            Find gt Crews.CrewDate
        Loop
        //
        Send Find_By_Recnum of hoDD Crews.File_Number iCrewsRecId
        Send Activate       of oCrewsGrid
    End_Procedure

Cd_End_Object
