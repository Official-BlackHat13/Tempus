Use Windows.pkg
Use DFClient.pkg
Use cReportControlGrid.pkg
Use cTempusDbView.pkg


Deferred_View Activate_oOpenTransactionReport for ;
Object oOpenTransactionReport is a cTempusDbView

    Property Handle phoReportControl

    Set Border_Style to Border_Thick
    Set Size to 247 536
    Set Location to 2 2
    Set Label to "Open Labor Transactions"

    Object oOpenTransactionGrid is a cReportControlGrid
        Delegate Set phoReportControl to Self

        Set Size to 210 525
        Set Location to 6 6
        Set peAnchors to anAll
        Set Border_Style to OLExtpBorderFrame
        Set piCustomDraw to OLExtpCustomBeforeDrawRow
        Set Color to 13303806
        Set TextColor to clNavy
        Set pbEditOnClick to False
        Set pbAllowColumnRemove to True
        Set piReportGridStyle to OLExtpGridSmallDots
        Set pbDrawGridForEmptySpace to False
        Set pbAutoColumnSizing to True
        Set pbSelectTextOnEdit to False
        Set pbDeleteAllowed to False
        Set pbUseColumnJustificationModeForHeader to True

        Procedure OnCreate
            Forward Send OnCreate // Don't forget to forward send!
            Send DoAddIcons 
            Send DoAddColumns
            Send DoFillGrid
        End_Procedure // OnCreate
                               
        Procedure DoAddIcons
        End_Procedure // DoAddIcons

        Procedure DoAddColumns
            Integer iRetval iCount
            Variant vConstraintsCollection                       
            Handle  hoColumn hoItemEditOptions hoConstraints
            //
            Get AddColumn "Area"                                    to hoColumn 
                Set HeaderWidth                       item hoColumn to 20
                Set HeaderToolTip                     item hoColumn to "Sort by Area"
            Get AddColumn "Location"                                to hoColumn
                Set HeaderWidth                       item hoColumn to 80
                Set HeaderToolTip                     item hoColumn to "Sort by Location"
                Set ColumnJustificationMode           item hoColumn to OLExtpAlignmentWordBreak
            Get AddColumn "Employee Name"                           to hoColumn
                Set HeaderWidth                       item hoColumn to 80
                Set ColumnJustificationMode           item hoColumn to OLExtpAlignmentWordBreak
            Get AddColumn "Operation"                               to hoColumn
                Set HeaderWidth                       item hoColumn to 80
                Set ColumnJustificationMode           item hoColumn to OLExtpAlignmentWordBreak
            Get AddColumn "Start Date"                              to hoColumn 
                Set HeaderWidth                       item hoColumn to 30
            Get AddColumn "Start Time"                              to hoColumn 
                Set HeaderWidth                       item hoColumn to 30
        End_Procedure // DoAddColumns

        Procedure DoFillGrid
            tWStNewTransaction[] tOpen
            //
            Integer iItem iItems iArea
            String  sLocation sEmployee sOperation sStartDate sStartTime
            Handle  hoItem
            //
            Send Cursor_Wait of Cursor_Control                            
            //
            Get wsGetOpenTransactions of oWSTransactionService to tOpen
            Move (SizeOfArray(tOpen))                          to iItems
            //
            If (iItems > 0) Begin
                Decrement iItems
                For iItem from 0 to iItems
                    Clear Order Location Employee Opers
                    //
                    Move tOpen[iItem].iArea         to iArea
                    //
                    Move tOpen[iItem].iJobNumber    to Order.JobNumber
                    Find eq Order.JobNumber
                    Relate Order
                    Move (Trim(Location.Name))      to sLocation
                    //
                    Move tOpen[iItem].iEmployeeIdno to Employee.EmployeeIdno
                    Find eq Employee.EmployeeIdno
                    Move (Trim(Employee.FirstName) * Trim(Employee.LastName)) to sEmployee
                    //
                    Move tOpen[iItem].iOpersIdno to Opers.OpersIdno
                    Find eq Opers.OpersIdno
                    Move (Trim(Opers.Description)) to sOperation
                    //
                    Move tOpen[iItem].dStartDate to sStartDate
                    Move tOpen[iItem].sStartTime to sStartTime
                    //
                    Get AddItem iArea              to hoItem
                    Get AddItem sLocation          to hoItem
                    Get AddItem sEmployee          to hoItem
                    Get AddItem sOperation         to hoItem
                    Get AddItem sStartDate         to hoItem
                    Get AddItem sStartTime         to hoItem
                Loop
            End
            Send Populate
            Send Cursor_Ready of Cursor_Control
        End_Procedure

    End_Object

    Object oRefreshButton is a Button
        Set Location to 228 454
        Set Label to "Refresh"
        Set peAnchors to anBottomRight
    
        Procedure OnClick
            Integer iCols
            Handle  hoReportGrid
            //
            Get phoReportControl            to hoReportGrid
            Send DeleteData of hoReportGrid
            Get Col_Count   of hoReportGrid to iCols
            If (iCols = 0) Begin 
                Send DoAddColumns of hoReportGrid
            End
            Send DoFillGrid of hoReportGrid             
        End_Procedure
    End_Object

Cd_End_Object
