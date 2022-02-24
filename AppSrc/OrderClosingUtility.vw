Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use Order.DD
Use szcalendar.pkg

Deferred_View Activate_oOrderClosingUtility for ;
Object oOrderClosingUtility is a dbView

    Property String psWorkType "S"

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oProject_DD is a cProjectDataDictionary
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
        Set Ordering to 7

        Procedure OnConstrain
            Constrain Order.WorkType     eq (psWorkType(Self))
            Constrain Order.JobCloseDate eq 0
        End_Procedure
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD

    Set Border_Style to Border_Thick
    Set Size to 113 304
    Set Location to 22 47

    Object oInstructionTextBox is a TextBox
        Set Auto_Size_State to False
        Set Size to 10 230
        Set Location to 15 15
        Set Label to "Select the Work Type and Closing date and press the Process button"
        Set FontWeight to 800
        Set TextColor to clRed
    End_Object

    Object oWorkTypeComboForm is a ComboForm
        Set Size to 13 94
        Set Location to 35 15
        Set Combo_Sort_State to False
    
        //Combo_Fill_List is called when the list needs filling    
        Procedure Combo_Fill_List
            Send Combo_Add_Item "Snow Removal"
            Send Combo_Add_Item "Pavement Maintenance"
            Send Combo_Add_Item "Other"
        End_Procedure
    
        //OnChange is called on every changed character    
        Procedure OnChange
            String sValue
            //
            Get Value to sValue
            If      (sValue = "Snow Removal") Begin
                Set psWorkType to "S"
            End
            Else If (sValue = "Pavement Maintenance") Begin
                Set psWorkType to "P"
            End
            Else If (sValue = "Other") Begin
                Set psWorkType to "O"
            End
            Send Rebuild_Constraints of oOrder_DD
        End_Procedure
    
        //Notification that the list has dropped down
    
        //Procedure OnDropDown
        //End_Procedure
    
        //Notification that the list was closed
    
        //Procedure OnCloseUp
        //End_Procedure
    
    End_Object

    Object oCloseDatePicker is a cszDatePicker
        Set Size to 13 66
        Set Location to 55 15
    End_Object

    Object oProcessButton is a Button
        Set Location to 86 127
        Set Label to "Process"
    
        Procedure OnClick
            Send DoProcess
        End_Procedure    
    End_Object

    Procedure DoProcess
        Boolean bCancel
        Integer hoDD
        String  sType
        Date    dClose
        //
        Get Value of oWorkTypeComboForm to sType
        Get Value of oCloseDatePicker   to dClose
        Get Confirm ("Open" * sType * "orders will be closed as of" * String(dClose)) to bCancel
        If (not(bCancel)) Begin
            Get Server to hoDD
            Send Find of hoDD FIRST_RECORD 7
            While (Found)
                Set Field_Changed_Value of hoDD Field Order.JobCloseDate to dClose
                Send Request_Save       of hoDD
                Send Find               of hoDD GT 7
            Loop
        End
    End_Procedure

Cd_End_Object
