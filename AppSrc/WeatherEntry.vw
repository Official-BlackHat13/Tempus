// D:\Development Projects\VDF19.1 Workspaces\Tempus\AppSrc\WeatherEntry.vw
// WeatherEntry
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use cDbCJGridColumn.pkg

Use Areas.DD
Use Weather.DD
Use Windows.pkg

Use WeatherAddEdit.dg

ACTIVATE_VIEW Activate_oWeatherEntry FOR oWeatherEntry

Object oWeatherEntry is a cGlblDbView
    Set Location to 4 7
    Set Size to 209 583
    Set Label To "WeatherEntry"
    Set Border_Style to Border_Thick


    Object oAreas_DD is a Areas_DataDictionary
        // this lets you save a new parent DD from within child DD
        Set Allow_Foreign_New_Save_State to False
                
        Procedure OnConstrain
            String sValue
            Get Value of oAreaCombo to sValue
            //
            Move (Ltrim(sValue)) to sValue
            If ((Length(sValue))>1) Begin
                Constrain Areas.Name eq sValue
            End
        End_Procedure  
    End_Object 

    Object oWeather_DD is a Weather_DataDictionary
        Set DDO_Server To oAreas_DD
    End_Object 

    Set Main_DD to oWeather_DD
    Set Server to oWeather_DD

    Object oAreaCombo is a dbComboForm
        Set Size to 12 217
        Set Entry_State to False
        Set Allow_Blank_State to True
        Set Location to 5 28
        Set Combo_Data_File to 19
        Set Code_Field to 2
        Set Combo_Index to 2
        Set Description_Field to 2
        Set Label to "Area"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 5
        
        Procedure OnChange
            Send Request_Clear of oWeather_DD
            Send Rebuild_Constraints of oWeather_DD
            Send RefreshDataFromDD of oWeatherDetailGrid ropTop
            Send MoveToFirstRow of oWeatherDetailGrid
        End_Procedure
        
    End_Object
    
    Object oClearButon is a Button
        Set Size to 14 33
        Set Location to 4 247
        Set Label to 'Clear'
    
        // fires when the button is clicked
        Procedure OnClick
            //Clear Value in Filter
            Set Value of oAreaCombo to ""
            Send OnChange of oAreaCombo
        End_Procedure
    
    End_Object
        
//    Object oAreasManager is a cGlblDbForm
//        Entry_Item Areas.Manager
//        Set Size to 13 212
//        Set Location to 5 283
//        Set peAnchors to anTopLeftRight
//        Set Label_Justification_mode to JMode_Right
//        Set Label_row_Offset to 0
//        Set Enabled_State to False
//        Set Label_Col_Offset to 5
//    End_Object 

    //-----------------------------------------------------------------------
    // Create custom confirmation messages for save and delete
    // We must create the new functions and assign verify messages
    // to them.
    //-----------------------------------------------------------------------

    Function ConfirmDeleteHeader Returns Boolean
        Boolean bFail
        Get Confirm "Delete Entire Header and all detail?" to bFail
        Function_Return bFail
    End_Function 

    // Only confirm on the saving of new records
    Function ConfirmSaveHeader Returns Boolean
        Boolean bNoSave bHasRecord
        Handle  hoSrvr
        Get Server to hoSrvr
        Get HasRecord of hoSrvr to bHasRecord
        If not bHasRecord Begin
            Get Confirm "Save this NEW header?" to bNoSave
        End
        Function_Return bNoSave
    End_Function 

    // Define alternate confirmation Messages
    Set Verify_Save_MSG       to (RefFunc(ConfirmSaveHeader))
    Set Verify_Delete_MSG     to (RefFunc(ConfirmDeleteHeader))
    // Saves in header should not clear the view
    Set Auto_Clear_Deo_State to False

    Object oNewButton is a Button
        Set Size to 14 34
        Set Location to 4 501
        Set Label to 'New'
        Set peAnchors to anTopRight
    
        // fires when the button is clicked
        Procedure OnClick
//            DateTime dtNow
//            Send MoveToLastRow of oWeatherDetailGrid
//            Send MoveDownRow of oWeatherDetailGrid
//            Send MoveToFirstEnterableColumn of oWeatherDetailGrid
//            Send Popup of oWeatherAddEdit
            Boolean bSuccess
            String sArea
            Get Value of oAreaCombo to sArea
            Get PopupWeatherInput of oWeatherAddEdit 0 sArea "New" to bSuccess
            If (bSuccess) Begin
                Send RefreshDataFromDD of oWeatherDetailGrid ropTop
                Send MoveToFirstRow of oWeatherDetailGrid
            End
        End_Procedure

    
    End_Object

    Object oEditButton is a Button
        Set Size to 14 34
        Set Location to 4 542
        Set Label to 'Edit'
        Set peAnchors to anTopRight
    
        // fires when the button is clicked
        Procedure OnClick
            Boolean bSuccess
            Get PopupWeatherInput of oWeatherAddEdit Weather.WeatherId "" "Edit" to bSuccess
            If (bSuccess) Begin
                Send RefreshDataFromDD of oWeatherDetailGrid ropTop
            End
        End_Procedure
    
    End_Object

    Object oWeatherDetailGrid is a cDbCJGrid
        Set Size to 184 570
        Set Location to 21 6
        Set pbStaticData to True
        Set Ordering to 2
        Set pbReverseOrdering to True
        Set peAnchors to anAll

        Object oWeather_EventDate is a cDbCJGridColumn
            Entry_Item Weather.EventDate
            Set piWidth to 82
            Set psCaption to "Date"
            Set pbEditable to False
        End_Object

        Object oWeather_EventTime is a cDbCJGridColumn
            Entry_Item Weather.EventTime
            Set piWidth to 83
            Set psCaption to "Time"
            Set pbEditable to False
        End_Object

        Object oAreas_Name is a cDbCJGridColumn
            Entry_Item Areas.Name
            Set piWidth to 164
            Set psCaption to "Area"
        End_Object

        Object oAreas_Manager is a cDbCJGridColumn
            Entry_Item Areas.Manager
            Set piWidth to 140
            Set psCaption to "Manager"
        End_Object

        Object oWeather_WindVelocity is a cDbCJGridColumn
            Entry_Item Weather.WindVelocity
            Set piWidth to 70
            Set psCaption to "Wind Velocity"
        End_Object

        Object oWeather_WindDirection is a cDbCJGridColumn
            Entry_Item Weather.WindDirection
            Set piWidth to 65
            Set psCaption to "Wind Direction"
            Set pbComboButton to True
        End_Object

        Object oWeather_AirTemperature is a cDbCJGridColumn
            Entry_Item Weather.AirTemperature
            Set piWidth to 52
            Set psCaption to "Air Temp."
        End_Object

        Object oWeather_GndTemperature is a cDbCJGridColumn
            Entry_Item Weather.GndTemperature
            Set piWidth to 54
            Set psCaption to "Ground Temp."
        End_Object

        Object oWeather_SnowInches is a cDbCJGridColumn
            Entry_Item Weather.SnowInches
            Set piWidth to 91
            Set psCaption to "Snow Inches"
        End_Object

        Object oWeather_Description is a cDbCJGridColumn
            Entry_Item Weather.Description
            Set piWidth to 215
            Set psCaption to "Description"
        End_Object

        Procedure Activating
            Forward Send Activating
            Send MoveToFirstRow of oWeatherDetailGrid
        End_Procedure

    End_Object

End_Object 
