// Z:\VDF17.0 Workspaces\Tempus\AppSrc\TimeCard.vw
// TimeCard
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg

Use Employer.DD
Use Employee.DD
Use Customer.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use SalesRep.DD
Use cWorkTypeGlblDataDictionary.dd
Use MastOps.DD
Use Opers.DD
Use Order.DD
Use Trans.DD
Use cWebAppUserRightsGlblDataDictionary.dd
Use cCJGrid.pkg
Use cDbCJGrid.pkg
Use Windows.pkg

ACTIVATE_VIEW Activate_oTimeCard FOR oTimeCard
Object oTimeCard is a cGlblDbView
    Set Size to 291 530
    Set Label To "TimeCard"
    Set Border_Style to Border_Thick

    Property Integer piEmplIdnoCard

    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
    End_Object

    Object oEmployer_DD is a Employer_DataDictionary
    End_Object // oEmployer_DD

    Object oEmployee_DD is a Employee_DataDictionary
        Set DDO_Server to oWebAppUserRights_DD
        Set DDO_Server To oEmployer_DD
    End_Object // oEmployee_DD

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD is a Areas_DataDictionary
    End_Object // oAreas_DD

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object // oSalesTaxGroup_DD

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
        Set DDO_Server To oSalesTaxGroup_DD
    End_Object // oLocation_DD

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object // oSalesRep_DD

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
    End_Object // oWorkType_DD

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server To oWorkType_DD
    End_Object // oMastOps_DD

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oMastOps_DD
    End_Object // oOpers_DD

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oSalesRep_DD
    End_Object // oOrder_DD

    Object oTrans_DD is a Trans_DataDictionary
        Set DDO_Server To oOrder_DD
        Set DDO_Server To oEmployee_DD
        Set DDO_Server to oOpers_DD

        Procedure OnConstrain
            Date dToday dSixtyDays
            Sysdate dToday
            Move (dToday-60.00) to dSixtyDays
            Forward Send OnConstrain
            If (piEmplIdnoCard(Self)<>0) Begin
                Constrain Trans.EmployeeIdno eq (piEmplIdnoCard(Self))
                Constrain Trans.StartDate Between dSixtyDays and dToday
            End
        End_Procedure
        
    End_Object // oTrans_DD

    Set Main_DD To oTrans_DD
    Set Server  To oTrans_DD
    Set Minimize_Icon to False
    Set Caption_Bar to False

    Procedure ReloadView Integer iEmplIdno
        Set View_Mode to Viewmode_Zoom
        //
        Set piEmplIdnoCard to iEmplIdno
        Send Rebuild_Constraints of oTrans_DD
        Send MovetoFirstRow of oTransDBGrid
        //
        
    End_Procedure

    Object oTransDBGrid is a cDbCJGrid
        Set Size to 255 519
        Set Location to 27 3
        Set Ordering to 6
        Set pbReverseOrdering to True
        Set pbEditOnTyping to False
        Set pbAllowAppendRow to False
        Set pbAllowColumnRemove to False
        Set pbAllowColumnReorder to False
        Set pbAllowDeleteRow to False
        Set pbAllowEdit to False
        Set pbAllowInsertRow to False
        Set pbAutoAppend to False
        Set pbAutoSave to False
        Set pbAutoRegenerate to False
        Set pbReadOnly to True
        Set peAnchors to anAll

        Object oTrans_StartTime is a cDbCJGridColumn
            Entry_Item Trans.StartTime
            Set piWidth to 95
            Set psCaption to "StartTime"
        End_Object

        Object oTrans_StartDate is a cDbCJGridColumn
            Entry_Item Trans.StartDate
            Set piWidth to 95
            Set psCaption to "StartDate"
        End_Object

        Object oTrans_StopTime is a cDbCJGridColumn
            Entry_Item Trans.StopTime
            Set piWidth to 95
            Set psCaption to "StopTime"
        End_Object

        Object oTrans_StopDate is a cDbCJGridColumn
            Entry_Item Trans.StopDate
            Set piWidth to 95
            Set psCaption to "StopDate"
        End_Object

        Object oTrans_JobNumber is a cDbCJGridColumn
            Entry_Item Order.JobNumber
            Set piWidth to 95
            Set psCaption to "JobNumber"
        End_Object

        Object oTrans_EquipIdno is a cDbCJGridColumn
            Entry_Item Trans.EquipIdno
            Set piWidth to 89
            Set psCaption to "EquipIdno"
        End_Object

        Object oLocation_Name is a cDbCJGridColumn
            Set piWidth to 344
            Set psCaption to "Name"

            Procedure OnSetCalculatedValue String  ByRef sValue
                Move (Location.Name*' - '*Order.Title) to sValue
            End_Procedure
        End_Object
    End_Object

    Object oEmployee_FirstName is a cGlblDbForm
        Entry_Item Employee.FirstName
        Set Location to 6 31
        Set Size to 13 132
        Set Label to "Name:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 5
        Set Enabled_State to False
    End_Object

    Object oEmployee_LastName is a cGlblDbForm
        Entry_Item Employee.LastName
        Set Location to 6 164
        Set Size to 13 147
        Set Enabled_State to False
    End_Object

    Object oCloseButton is a Button
        Set Size to 14 27
        Set Location to 4 493
        Set Label to "X"
        Set Color to clRed
        //Set piTextColor to clWhite
        //Set pbDropDownButton to False
        //Set piTextHotColor to clBlack
        Set peAnchors to anTopRight
    
        // fires when the button is clicked
        Procedure OnClick
            Send Deactivate of oTimeCard
        End_Procedure
    
    End_Object

    Procedure Activating
        Forward Send Activating
    End_Procedure

End_Object // oTimeCard
