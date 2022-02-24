// CalendarWeeks.sl
// CalendarWeeks Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cCalendarWeeksDataDictionary.dd

Object CalendarWeeks_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 212
    Set Label To "CalendarWeeks Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oCalendarWeeks_DD is a cCalendarWeeksDataDictionary
    End_Object 

    Set Main_DD To oCalendarWeeks_DD
    Set Server  To oCalendarWeeks_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 202
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "CalendarWeeks_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oCalendarWeeks_YearWeek is a cDbCJGridColumn
            Entry_Item CalendarWeeks.YearWeek
            Set piWidth to 73
            Set psCaption to "YearWeek"
        End_Object 

        Object oCalendarWeeks_WeekDates is a cDbCJGridColumn
            Entry_Item CalendarWeeks.WeekDates
            Set piWidth to 262
            Set psCaption to "WeekDates"
        End_Object 


    End_Object 

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 49
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object 

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 103
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object 

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 157
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object 

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

    Function SelectCalendarWeek String ByRef sCalendarWeek Date ByRef dLastDayInWeek Returns Boolean
        Boolean bCancel
        String[] SelectionValues
        //
        Send OnStoreDefaults of oSelList
        //
        Set Locate_Mode to CENTER_ON_PANEL
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set piUpdateColumn of oSelList to 0
        Set psSeedValue of oSelList to sCalendarWeek
        //
        Send Rebuild_Constraints of oCalendarWeeks_DD
        //
        Send Popup_Modal
        //
        Send OnRestoreDefaults of oSelList
        //
        
        Send Rebuild_Constraints of oCalendarWeeks_DD        
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Get SelectedColumnValues of oSelList 0 to SelectionValues
            If (SizeOfArray(SelectionValues)) Begin
                Move SelectionValues[0] to sCalendarWeek
                Move CalendarWeeks.last_day_in_week to dLastDayInWeek
                Function_Return True
            End
        End
        Function_Return False
    End_Function

End_Object // CalendarWeeks_sl
