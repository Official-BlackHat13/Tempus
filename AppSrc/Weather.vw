Use Windows.pkg
Use DFClient.pkg
Use Weather.DD
Use Areas.DD
Use cGlblDbForm.pkg
Use cDbTextEdit.pkg
Use cGlblDbView.pkg


Deferred_View Activate_oWeather for ;
Object oWeather is a cGlblDbView
    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oWeather_DD is a Weather_DataDictionary
        Set DDO_Server to oAreas_DD
    End_Object

    Set Main_DD to oWeather_DD
    Set Server to oWeather_DD

    Set Border_Style to Border_Thick
    Set Size to 181 360
    Set Location to 17 48
    Set Label to "Weather Events"

    Object oWeather_AreaNumber is a cGlblDbForm
        Entry_Item Areas.AreaNumber
        Set Location to 10 66
        Set Size to 13 42
        Set Label to "Area Number:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oWeather_EventDate is a dbForm
        Entry_Item Weather.EventDate
        Set Location to 25 66
        Set Size to 13 66
        Set Label to "Event Date:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Form_Datatype to Mask_Date_Window
        Set Prompt_Button_Mode to PB_PromptOn
        Set Prompt_Object to oMonthCalendarPrompt
    End_Object

    Object oWeather_EventTime is a dbForm
        Entry_Item Weather.EventTime
        Set Location to 40 66
        Set Size to 13 54
        Set Label to "Event Time:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Form_Datatype to Mask_Clock_Window
    End_Object

    Object oWeather_WindVelocity is a cGlblDbForm
        Entry_Item Weather.WindVelocity
        Set Location to 55 66
        Set Size to 13 30
        Set Label to "Wind Velocity:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oWeather_WindDirection is a cGlblDbComboForm
        Entry_Item Weather.WindDirection
        Set Location to 70 66
        Set Size to 13 42
        Set Label to "Wind Direction:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
        Set Combo_Sort_State to False
    End_Object

    Object oWeather_AirTemperature is a cGlblDbForm
        Entry_Item Weather.AirTemperature
        Set Location to 85 66
        Set Size to 13 30
        Set Label to "AirTemperature:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oWeather_GndTemperature is a cGlblDbForm
        Entry_Item Weather.GndTemperature
        Set Location to 100 66
        Set Size to 13 30
        Set Label to "Ground Temp:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oWeather_SnowInches is a cGlblDbForm
        Entry_Item Weather.SnowInches
        Set Location to 115 66
        Set Size to 13 30
        Set Label to "Snow Inches:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oWeather_Description is a cDbTextEdit
        Entry_Item Weather.Description
        Set Location to 130 66
        Set Size to 38 269
        Set Label to "Description:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 3
    End_Object

Cd_End_Object
