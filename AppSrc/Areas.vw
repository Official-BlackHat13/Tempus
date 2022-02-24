// C:\VDF14.0 Workspaces\InterstateCompanies\AppSrc\Areas.vw
// Area Standards
//

Use cTempusDbView.pkg
Use cGlblDbForm.pkg
Use Employee.sl
Use CalendarWeeks.sl

Use Areas.DD
Use cCalendarWeeksDataDictionary.dd
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use cDbCJGridPromptList.pkg
Use cCJCommandBarSystem.pkg

Use AreaSnowbooksPrintReport.rv

ACTIVATE_VIEW Activate_oAreas FOR oAreas
Object oAreas is a cTempusDbView
    Set Location to 34 41
    Set Size to 201 615
    Set Label To "Area Standards"
    Set Border_Style to Border_Thick

    Object oCalendarWeeks_DD is a cCalendarWeeksDataDictionary
    End_Object


    Object oAreas_DD Is A Areas_DataDictionary
    End_Object // oAreas_DD

    Set Main_DD To oAreas_DD
    Set Server  To oAreas_DD



//    Object oAreasAreanumber Is A cGlblDbForm
//        Entry_Item Areas.Areanumber
//        Set Size to 13 249
//        Set Location to 5 45
//        Set peAnchors to anLeftRight
//        Set Label to "Number"
//        Set Label_Justification_mode to jMode_Left
//        Set Label_Col_Offset to 40
//        Set Label_row_Offset to 0
//    End_Object // oAreasAreanumber
//
//    Object oAreasName Is A cGlblDbForm
//        Entry_Item Areas.Name
//        Set Size to 13 407
//        Set Location to 20 45
//        Set peAnchors to anLeftRight
//        Set Label to "Name"
//        Set Label_Justification_mode to jMode_Left
//        Set Label_Col_Offset to 40
//        Set Label_row_Offset to 0
//    End_Object // oAreasName
//
//    Object oAreas_EmployeeIdno is a cGlblDbForm
//        Entry_Item Areas.EmployeeIdno
//        Set Location to 35 45
//        Set Size to 13 66
//        Set Label to "Manager"
//        Set Label_Col_Offset to 40
//        Set Prompt_Button_Mode to PB_PromptOn
//
//        Procedure Prompt
//            Integer iAreaMgrIdno
//            Boolean bSelected
//            String sFirstname sLastName
//            //
//            Get Field_Current_Value of oAreas_DD Field Areas.EmployeeIdno to iAreaMgrIdno
//            Get SelectEmployee of Employee_sl (&iAreaMgrIdno) (&sFirstname) (&sLastName) True to bSelected
//            If (bSelected) Begin
//                Set Field_Changed_Value of oAreas_DD Field Areas.EmployeeIdno to iAreaMgrIdno
//                Set Field_Changed_Value of oAreas_DD Field Areas.Manager      to (Trim(sFirstname) * Trim(sLastName))
//            End
//            Else Begin
//                //No changes made
//            End
//        End_Procedure
//        
//        Procedure Refresh Integer iMode
//            Forward Send Refresh iMode
//            //
//            Clear Employee
//            If (Areas.AreaNumber<>0 and Areas.EmployeeIdno =0) Begin
//                Move "" to Areas.Manager
//            End
//            If (Areas.EmployeeIdno <> 0) Begin
//                Move Areas.EmployeeIdno to Employee.EmployeeIdno
//                Find eq Employee.EmployeeIdno
//            End
//        End_Procedure
//    End_Object
//
//    Object oAreasManager is a cGlblDbForm
//        Entry_Item Areas.Manager
//        Set Size to 13 337
//        Set Location to 35 115
//        Set peAnchors to anLeftRight
//        Set Label_Justification_mode to jMode_Left
//        Set Label_Col_Offset to 40
//        Set Label_row_Offset to 0
//        Set Enabled_State to False
//    End_Object // oAreasManager

    Object oAreaGrid is a cDbCJGrid
        Set Size to 193 607
        Set Location to 5 3
        Set peAnchors to anAll

        Object oAreas_Name is a cDbCJGridColumn
            Entry_Item Areas.Name
            Set piWidth to 434
            Set psCaption to "Name"
        End_Object

        Object oAreas_AreaNumber is a cDbCJGridColumn
            Entry_Item Areas.AreaNumber
            Set piWidth to 33
            Set psCaption to "AreaNumber"
        End_Object

        Object oAreas_EmployeeIdno is a cDbCJGridColumn
            Entry_Item Areas.EmployeeIdno
            Set piWidth to 88
            Set psCaption to "EmployeeIdno"
            Set Prompt_Button_Mode to PB_PromptOn
            
            Procedure Prompt
                Integer iAreaMgrIdno
                Boolean bSelected
                String sFirstname sLastName
                //
                Get Field_Current_Value of oAreas_DD Field Areas.EmployeeIdno to iAreaMgrIdno
                Get SelectEmployee of Employee_sl (&iAreaMgrIdno) (&sFirstname) (&sLastName) True to bSelected
                If (bSelected) Begin
                    Set Field_Changed_Value of oAreas_DD Field Areas.EmployeeIdno to iAreaMgrIdno
                    Set Field_Changed_Value of oAreas_DD Field Areas.Manager      to (Trim(sFirstname) * Trim(sLastName))
                End
                Else Begin
                    //No changes made
                End
            End_Procedure            
        End_Object


        Object oAreas_Manager is a cDbCJGridColumn
            Entry_Item Areas.Manager
            Set piWidth to 356
            Set psCaption to "Manager"
            Set pbEditable to False
        End_Object

        Object oAreas_ReviewedToDate is a cDbCJGridColumn
            Entry_Item Areas.ReviewedToDate
            Set piWidth to 151
            Set psCaption to "ReviewedToDate"
            Set Prompt_Button_Mode to PB_PromptOn

            Procedure Prompt
                Date dReviewToDate 
                Boolean bSelected
                String sCalendarWeek sLastName
                //
                Get Field_Current_Value of oAreas_DD Field Areas.ReviewedToDate to dReviewToDate
                //
                Get SelectCalendarWeek of CalendarWeeks_sl (&sCalendarWeek) (&dReviewToDate) to bSelected
                If (bSelected) Begin
                    Set Field_Changed_Value of oAreas_DD Field Areas.ReviewedToDate to dReviewToDate
                End
                Else Begin
                    //No changes made
                End
            End_Procedure              
        End_Object

        Object oAreaContextMenu is a cCJContextMenu
            
            Object oPrintSnowbooksMenuItem is a cCJMenuItem
                Set psCaption to "Print Snowbooks"
                Set psTooltip to "Print Snowbooks"

                Procedure OnExecute Variant vCommandBarControl
                    Forward Send OnExecute vCommandBarControl
                    Integer iAreaNumber
                    Get Field_Current_Value of oAreas_DD Field Areas.AreaNumber to iAreaNumber
                    Send DoJumpStartReport of oAreaSnowbooksPrintReportView iAreaNumber
                End_Procedure
            End_Object
        End_Object

        Procedure OnComRowRClick Variant llRow Variant llItem
            Send Popup of oAreaContextMenu
        End_Procedure
    End_Object

    Procedure Activating
        Forward Send Activating
        
        Boolean bHasMinAdminRights
        Move (giUserRights>=70) to bHasMinAdminRights
        Set pbAllowEdit of oAreaGrid to (bHasMinAdminRights)
        
    End_Procedure


End_Object // oAreas
