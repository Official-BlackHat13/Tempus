Use Windows.pkg
Use DFClient.pkg
Use Areas.DD
Use Weather.DD
Use cDbCJGrid.pkg
Use cDbTextEdit.pkg
Use cGlblDbForm.pkg

Deferred_View Activate_oSnowControlSheet for ;
Object oSnowControlSheet is a dbView
    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oWeather_DD is a Weather_DataDictionary
        Set DDO_Server to oAreas_DD
    End_Object

    Set Main_DD to oWeather_DD
    Set Server to oWeather_DD

    Set Border_Style to Border_Thick
    Set Size to 277 467
    Set Location to 28 160
    Set Label to "Snow Controll Sheet - Weather"
    Set peAnchors to anBottomRight

    Object oWeatherGrid is a cDbCJGrid
        Set Size to 235 448
        Set Location to 6 10
        Set Ordering to 2
        Set peAnchors to anAll
        Set pbReverseOrdering to True
        Set pbStaticData to True

        Object oWeather_EventDate is a cDbCJGridColumn
            Entry_Item Weather.EventDate
            Set piWidth to 123
            Set psCaption to "EventDate"
        End_Object

        Object oWeather_WindVelocity is a cDbCJGridColumn
            Entry_Item Weather.WindVelocity
            Set piWidth to 147
            Set psCaption to "WindVelocity"
        End_Object

        Object oWeather_WindDirection is a cDbCJGridColumn
            Entry_Item Weather.WindDirection
            Set piWidth to 222
            Set psCaption to "WindDirection"
            Set pbComboButton to True
        End_Object

        Object oWeather_AirTemperature is a cDbCJGridColumn
            Entry_Item Weather.AirTemperature
            Set piWidth to 148
            Set psCaption to "AirTemperature"
        End_Object

        Object oWeather_SnowInches is a cDbCJGridColumn
            Entry_Item Weather.SnowInches
            Set piWidth to 144
            
            Set psCaption to "SnowInches"
        End_Object

        Procedure Activating
            Forward Send Activating
            Send MoveToFirstRow of oWeatherGrid
        End_Procedure
    End_Object

    Object oAddButton is a Button
        Set Size to 14 77
        Set Location to 255 381
        Set Label to 'Add'
        Set peAnchors to anBottomRight
    
        // fires when the button is clicked
        Procedure OnClick
            Boolean bMoveError
            Get MoveToColumnObject of oWeatherGrid (oWeather_EventDate) to bMoveError
            Send MovetoLastRow of oWeatherGrid
            Send MoveDownRow of oWeatherGrid
        End_Procedure
    
    End_Object

//    Object oWeather_EventDate1 is a cGlblDbForm
//        Entry_Item Weather.EventDate
//        Set Location to 15 14
//        Set Size to 13 66
//        Set Label to "EventDate:"
//        Set Label_Justification_Mode to JMode_Top
//        Set Label_Col_Offset to -2
//    End_Object
//
//    Object oWeather_WindVelocity1 is a cGlblDbForm
//        Entry_Item Weather.WindVelocity
//        Set Location to 15 84
//        Set Size to 13 71
//        Set Label to "WindVelocity:"
//        Set Label_Justification_Mode to JMode_Top
//        Set Label_Col_Offset to -2
//    End_Object
//
//    Object oWeather_WindDirection is a cGlblDbForm
//        Entry_Item Weather.WindDirection
//        Set Location to 15 160
//        Set Size to 13 71
//        Set Label to "Wind Direction:"
//        Set Label_Justification_Mode to JMode_Top
//        Set Label_Col_Offset to -2
//    End_Object
//    
//    Object oWeather_AirTemperature1 is a cGlblDbForm
//        Entry_Item Weather.AirTemperature
//        Set Location to 15 235
//        Set Size to 13 67
//        Set Label to "AirTemperature:"
//        Set Label_Justification_Mode to JMode_Top
//        Set Label_Col_Offset to -2
//    End_Object
//
//    Object oWeather_SnowInches1 is a cGlblDbForm
//        Entry_Item Weather.SnowInches
//        Set Location to 15 307
//        Set Size to 13 66
//        Set Label to "SnowInches:"
//        Set Label_Justification_Mode to JMode_Top
//        Set Label_Col_Offset to -2
//    End_Object

Cd_End_Object
