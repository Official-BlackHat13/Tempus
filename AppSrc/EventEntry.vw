Use Windows.pkg
Use DFClient.pkg
Use Event.DD
Use DFEntry.pkg
Use dfLine.pkg
Use szcalendar.pkg
Use cGlblDbView.pkg
Use InvoiceCreationProcess.bp


Deferred_View Activate_oEventEntry for ;
Object oEventEntry is a cGlblDbView

    Object oEvent_DD is a Event_DataDictionary
    End_Object

    Set Main_DD to oEvent_DD
    Set Server to oEvent_DD

    Set Border_Style to Border_Thick
    Set Size to 101 336
    Set Location to 15 19
    Set Label to "Event Entry/Edit"

    Object oEvent_EventIdno is a dbForm
        Entry_Item Event.EventIdno
        Set Location to 21 74
        Set Size to 13 42
        Set Label to "Event Number:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 8
        Set FontWeight to 600
        Set Entry_State to False

        Procedure Refresh Integer iMode
            Forward Send Refresh iMode
            //
            Set Enabled_State of oUpdateButton to (HasRecord(oEvent_DD))
        End_Procedure
    End_Object
    
    Object oEvent_Planner is a dbForm
        Entry_Item Event.Planner
        Set Location to 21 160
        Set Size to 13 33
        Set Label to "Planner:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 2
    End_Object
    
    Object oEvent_EnteredDate is a dbForm
        Entry_Item Event.EnteredDate
        Set Location to 21 230
        Set Size to 13 54
        Set Label to "Entered:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 2
        Set TextColor to clBlack
    End_Object

    Object oEvent_StartDate is a cdbszDatePicker
        Entry_Item Event.StartDate
        Set Location to 50 84
        Set Size to 13 60
        Set Label to "Start Date:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 2
    End_Object

    Object oEvent_StopDate is a cdbszDatePicker
        Entry_Item Event.StopDate
        Set Location to 50 194
        Set Size to 13 60
        Set Label to "End Date:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 2
    End_Object

    Object oEventLineControl is a LineControl
        Set Size to 7 316
        Set Location to 42 7
    End_Object

    Object oUpdateButton is a Button
        Set Size to 14 57
        Set Location to 79 268
        Set Label to "Update Orders"
    
        Procedure OnClick
            Send DoUpdateOrders
        End_Procedure
    
    End_Object

    Procedure DoUpdateOrders
        Boolean bCancel
        //
        If (Should_Save(Self)) Begin
            Send Request_Save
        End
        Get Confirm "This Event will be added to all orders.  Continue?" to bCancel
        If (bCancel) Begin
            Procedure_Return
        End
        //
        Clear Order
        Find GE Order.Recnum
        While (Found)
            Reread
            Move Event.StartDate to Order.EventOpenDate
            Move Event.StopDate  to Order.EventCloseDate
            Move Event.EventIdno to Order.EventIdno
            SaveRecord Order
            Unlock
            Find GT Order.Recnum
        Loop
    End_Procedure

    Procedure Request_Save
        Boolean bState
        Integer iRecId
        Date    dStop
        //
        Get Field_Changed_State of oEvent_DD Field Event.StopDate to bState
        Get Field_Current_Value of oEvent_DD Field Event.StopDate to dStop
        //
        Forward Send Request_Save
        If (Changed_State(oEvent_DD)) Begin
            Procedure_Return
        End
        //
        If (bState and dStop <> 0) Begin
            Send Info_Box "Invoices for all open transactions will be created"
            //
            Get DoCreateInvoices of oInvoiceCreationProcess Event.Recnum to iRecId
        End
    End_Procedure

Cd_End_Object

