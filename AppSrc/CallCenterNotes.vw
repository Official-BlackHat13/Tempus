// C:\Development Projects\VDF18.2 Workspaces\Tempus\AppSrc\CallCenterNotes.vw
// CallCenterNotes
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cDbTextEdit.pkg

Use Customer.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use SalesRep.DD
Use Order.DD
Use cReqtypesDataDictionary.dd
Use cLocnotesDataDictionary.dd
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg
Use dfclient.pkg

Use DamageReport_SingleReport.rv
Use Windows.pkg
Use dbSuggestionForm.pkg

ACTIVATE_VIEW Activate_oCallCenterNotes FOR oCallCenterNotes
Object oCallCenterNotes is a cGlblDbView
    Set Location to 5 5
    Set Size to 323 539
    Set Label To "CallCenterNotes"
    Set Border_Style to Border_Thick


    Object oCustomer_DD is a Customer_DataDictionary
        Procedure OnConstrain
            String sCustomer
            Forward Send OnConstrain
            //Customer
            Get Value of oCustomerFilterCombo to sCustomer
            If ((Length(sCustomer))>1) Begin
                Constrain Customer.Name eq sCustomer
            End
        End_Procedure
    End_Object 

    Object oAreas_DD is a Areas_DataDictionary
    End_Object 

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object 

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
        Set DDO_Server To oSalesTaxGroup_DD
    End_Object 

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object 

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oSalesRep_DD
    End_Object 

    Object oReqtypes_DD is a cReqtypesDataDictionary
    End_Object 

    Object oLocnotes_DD is a cLocnotesDataDictionary
        Set DDO_Server To oOrder_DD
        Set DDO_Server to oReqtypes_DD
        
        Procedure OnConstrain
            String sValue sJobNumber sStatus
            Date dStartDate dStopDate
            //ReqType
            Get Value of oReqTypeFilterCombo to sValue
            Move (Ltrim(sValue)) to sValue
            If ((Length(sValue))>1) Begin
                Constrain Locnotes.ReqtypesCode eq sValue
            End
            //StartDate
            Get Value of oStartDate to dStartDate
            Get Value of oStopDate to dStopDate
            If (dStartDate<>0 and dStopDate<>0) Begin
                Constrain Locnotes.CreatedDate Between dStartDate and dStopDate
            End
            //JobNumber
            Get Value of oJobNumberForm to sJobNumber
            If (Length(sJobNumber)>=3) Begin
                Constrain Locnotes.JobNumber contains sJobNumber
            End
            //Status
            Get Value of oStatusComboForm to sStatus
            If (Length(sStatus)>=1) Begin
                Constrain Locnotes.Status contains sStatus
            End
        End_Procedure 
    End_Object 

    Set Main_DD to oLocnotes_DD
    Set Server  To oLocnotes_DD

    Object oCallCenterNotesGrid is a cDbCJGrid
        Set Size to 284 531
        Set Location to 33 5
        Set peAnchors to anAll
        Set pbFullColumnScrolling to True
        Set pbReadOnly to True
        Set Ordering to 6
        Set pbReverseOrdering to True
        Set pbAllowColumnReorder to False
        Set pbAllowColumnRemove to False
        Set pbAllowAppendRow to False
        Set pbAllowDeleteRow to False
        Set pbAllowEdit to False
        Set pbAllowInsertRow to False
        Set pbAutoAppend to False
        Set pbEditOnTyping to False

        Object oLocnotes_LocnotesId is a cDbCJGridColumn
            Entry_Item Locnotes.LocnotesId
            Set piWidth to 43
            Set psCaption to "ID"
        End_Object

        Object oLocnotes_CreatedDate is a cDbCJGridColumn
            Entry_Item Locnotes.CreatedDate
            Set piWidth to 58
            Set psCaption to "Created On"
        End_Object

        Object oLocnotes_JobNumber is a cDbCJGridColumn
            Entry_Item Order.JobNumber
            Set piWidth to 51
            Set psCaption to "Job#"
        End_Object

        Object oCustomerLocation is a cDbCJGridColumn
            //Entry_Item Customer.Name
            Set piWidth to 155
            Set psCaption to "Customer - Location"

            Procedure OnSetCalculatedValue String  ByRef sValue
                Move (Trim(Customer.Name)*"-"*Trim(Location.Name)) to sValue
            End_Procedure
        End_Object

        Object oLocnotes_Note is a cDbCJGridColumn
            Entry_Item Locnotes.Note
            Set piWidth to 398
            Set psCaption to "Note"
            Set pbMultiLine to True
        End_Object

        Procedure Activating
            Forward Send Activating
            Send MoveToFirstRow of oCallCenterNotesGrid
        End_Procedure

        Procedure OnComRowDblClick Variant llRow Variant llItem
            Forward Send OnComRowDblClick llRow llItem
            Integer iLocNotesIdno
            Get Field_Current_Value of oLocnotes_DD Field Locnotes.LocnotesId to iLocNotesIdno
            Send DoJumpStartReport of oDamageReport_SingleReportView iLocNotesIdno
        End_Procedure

        Object oReqtypes_ReqtypesCode is a cDbCJGridColumn
            Entry_Item Reqtypes.ReqtypesCode
            Set piWidth to 117
            Set psCaption to "ReqtypesCode"
        End_Object

        Object oLocnotes_Status is a cDbCJGridColumn
            Entry_Item Locnotes.Status
            Set piWidth to 107
            Set psCaption to "Status"
            Set pbComboButton to True
        End_Object
        
    End_Object

    Object oReqTypeGroupFilter is a dbGroup
        Set Size to 25 109
        Set Location to 3 129
        Set Label to 'Request Type Filter'
        Set peAnchors to anTopLeft

        Object oReqTypeFilterCombo is a dbComboForm
            Set Size to 12 78
            Set Entry_State to False
            Set Allow_Blank_State to False
            Set Location to 9 4
            Set Combo_Data_File to 37
            Set Code_Field to 1
            Set Combo_Index to 1
            Set Description_Field to 1
            Set Label to ""
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 5
            
            Procedure OnChange
                Send Clear_All of oLocnotes_DD
                Send Rebuild_Constraints of oLocnotes_DD
                Send MoveToFirstRow of oCallCenterNotesGrid
            End_Procedure
        End_Object
        
        Object oClearButon is a Button
            Set Size to 14 25
            Set Location to 8 83
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oReqTypeFilterCombo to ""
            End_Procedure
        
        End_Object
    End_Object

    Object oDateRangeGroup is a dbGroup
        Set Size to 25 123
        Set Location to 3 4
        Set Label to 'Date Range'

        Object oStartDate is a Form
            Set Size to 13 53
            Set Location to 9 5
            Set Label to ""
            Set Label_Col_Offset to 5
            Set Label_Justification_Mode to JMode_Right
            Set Form_Datatype to Mask_Date_Window
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt

            Procedure OnChange
                Send Clear_All of oLocnotes_DD
                Send Rebuild_Constraints of oLocnotes_DD
                Send MoveToFirstRow of oCallCenterNotesGrid
            End_Procedure

            Procedure Activating
                Date dToday
                Sysdate dToday
                Set Value of oStartDate to (dToday-365)
            End_Procedure
        End_Object

        Object oStopDate is a Form
            Set Size to 13 53
            Set Location to 9 67
            Set Label to "-"
            Set Label_Col_Offset to 1
            Set Label_Justification_Mode to JMode_Right
            Set Form_Datatype to Mask_Date_Window
            Set Prompt_Button_Mode to PB_PromptOn
            Set Prompt_Object to oMonthCalendarPrompt

            Procedure Activating
                Date dToday
                Sysdate dToday
                Set Value of oStopDate to dToday
            End_Procedure

            Procedure OnChange
                Send Clear_All of oLocnotes_DD
                Send Rebuild_Constraints of oLocnotes_DD
                Send MoveToFirstRow of oCallCenterNotesGrid
            End_Procedure
        End_Object
    End_Object

    Object oCustomerFilter is a dbGroup
        Set Size to 25 110
        Set Location to 3 239
        Set Label to 'Customer Filter'
        Set peAnchors to anTopLeft

        Object oCustomerFilterCombo is a dbComboForm
            Set Size to 12 78
            Set Entry_State to False
            Set Allow_Blank_State to False
            Set Location to 9 4
            Set Combo_Data_File to 2
            Set Code_Field to 2
            Set Combo_Index to 2
            Set Description_Field to 2
            Set Label to ""
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 5
            
            Procedure OnChange
                Send Clear_All of oLocnotes_DD
                Send Rebuild_Constraints of oLocnotes_DD
                Send MoveToFirstRow of oCallCenterNotesGrid
            End_Procedure
        End_Object
        
        Object oClearButon is a Button
            Set Size to 14 25
            Set Location to 8 83
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oCustomerFilterCombo to ""
            End_Procedure
        
        End_Object
    End_Object

    Object oJobNumberFilter is a dbGroup
        Set Size to 25 116
        Set Location to 3 351
        Set Label to 'Job# Filter'
        Set peAnchors to anTopLeft

        Object oJobNumberForm is a Form
            Set Size to 12 79
            Set Location to 9 3
        
            Procedure OnChange
                Send Clear_All of oLocnotes_DD
                Send Rebuild_Constraints of oLocnotes_DD
                Send MoveToFirstRow of oCallCenterNotesGrid
            End_Procedure
        
        End_Object
        
        Object oClearButon is a Button
            Set Size to 14 25
            Set Location to 8 84
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oJobNumberForm to ""
            End_Procedure
        
        End_Object
    End_Object

    Object oStatusFilter is a Group
        Set Size to 25 116
        Set Location to 3 351
        Set Label to 'Status Filter'
        Set peAnchors to anTopLeft

        Object oStatusComboForm is a ComboForm
            Set Size to 13 75
            Set Location to 9 6
            // Combo_Fill_List is called when the list needs filling
          
            Procedure Combo_Fill_List
                // Fill the combo list with Send Combo_Add_Item
                Send Combo_Add_Item "1-OPEN"
                Send Combo_Add_Item "2-ASSIGNED"
                Send Combo_Add_Item "3-RESOLVED"
                Send Combo_Add_Item "4-CLOSED"
            End_Procedure
          
            // OnChange is called on every changed character       
            Procedure OnChange
                String sValue
                //
                Get Value to sValue // the current selected item
                //
                Send Clear_All of oLocnotes_DD
                Send Rebuild_Constraints of oLocnotes_DD
                Send MoveToFirstRow of oCallCenterNotesGrid
            End_Procedure   
            
        End_Object
        
        Object oClearButon is a Button
            Set Size to 14 25
            Set Location to 8 84
            Set Label to 'Clear'
        
            // fires when the button is clicked
            Procedure OnClick
                //Clear Value in Filter
                Set Value of oStatusComboForm to ""
            End_Procedure
        
        End_Object
    End_Object

End_Object 
