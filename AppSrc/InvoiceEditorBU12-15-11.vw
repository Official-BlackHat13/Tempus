#IFDEF ShellExecuteA
#ELSE
External_Function ShellExecuteA "ShellExecuteA" shell32.dll ;
    Handle hWnd         ;
    String lpOperation  ;
    String lpFile       ;
    String lpParameters ;
    String lpDirectory  ;
    DWord iShowCmd      ;
    Returns Handle
#ENDIF

Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Location.DD
Use Event.DD
Use Invhdr.DD
Use Invdtl.DD
Use MastOps.DD
Use Opers.DD
Use Areas.DD
Use Order.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use cGlblDbForm.pkg
Use cGlblDbList.pkg
//Use cGlblDbGrid.pkg
Use cGlblDbContainer3d.pkg
Use cTempusDbView.pkg
Use cDbTextEdit.pkg
Use szcalendar.pkg
Use InvoiceCreationProcess.bp
//Use CollectTransactionsProcess.bp
//Use CollectLocationNotesProcess.bp
//Use CollectAreaNotesProcess.bp
Use cGlblGrid.pkg
Use cComDbSpellText.pkg

Register_Object oCustomerInvoice
Register_Object oWSTransactionService

Deferred_View Activate_oInvoiceEditor for ;
Object oInvoiceEditor is a cTempusDbView

    Property String psActivityType "Snow Removal"

    Function DataLossConfirmation Returns Integer
        Integer bCancel
        //
        If (not(Changed_State(oInvhdr_DD))) Begin
            Function_Return
        End
        Else Begin
            Get Confirm "Abandon Invoice Header Changes?" to bCancel
            Function_Return bCancel
        End
    End_Function

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oMastops_DD is a Mastops_DataDictionary
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
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD

        Procedure OnConstrain
            String sType
            //
            Get psActivityType to sType
            If (sType <> "") Begin
                Move (Left(sType,1))     to sType
                Constrain Order.WorkType eq sType
            End
        End_Procedure
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set Constrain_file to Location.File_number
        Set DDO_Server to oMastops_DD
        Set DDO_Server to oLocation_DD

        Procedure OnConstrain
            Forward Send OnConstrain
            //
            If (psActivityType(Self) <> "") Begin
                Constrain Opers.ActivityType eq (psActivityType(Self))
            End
        End_Procedure
    End_Object

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server to oOrder_DD
        Set Cascade_Delete_State to False
        Set No_Delete_State to True
        Set Ordering to 8

        Procedure OnConstrain
            Constrain Invhdr.EditFlag eq 0
            Constrain Invhdr.VoidFlag eq 0
//            Constrain Invhdr.PrintFlag eq 0
//            Constrain Invhdr.PostFlag  eq 0
        End_Procedure
    End_Object

    Object oInvdtl_DD is a Invdtl_DataDictionary
        Set DDO_Server to oOpers_DD
        Set Constrain_file to Invhdr.File_number
        Set DDO_Server to oInvhdr_DD
        Send DefineAllExtendedFields
    End_Object

    Set Main_DD to oInvhdr_DD
    Set Server to oInvhdr_DD

    Set Border_Style to Border_Thick
    Set Size to 329 545
    Set Location to 4 3
    Set Label to "Invoice Editor"
    Set Verify_Data_Loss_Msg to get_DataLossConfirmation
    Set Verify_Exit_msg to get_DataLossConfirmation
    Set piMinSize to 329 545

//    Object oAreaForm is a Form
//        Set Size to 13 60
//        Set Location to 10 60
//        Set Prompt_Button_Mode to PB_PromptOn
//        Set Label to "Area:"
//        Set Label_Col_Offset to 3
//        Set Label_Justification_Mode to JMode_Right
//        Set Prompt_Object to Areas_SL
//        Set Form_Datatype to 0
//    End_Object

    Object oBeginDate is a cszDatePicker
        Set Location to 25 60
        Set Size to 13 60
        Set Label to "Begin Date:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oEndDate is a cszDatePicker
        Set Location to 40 60
        Set Size to 13 60
        Set Label to "End Date:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

//    Object oCreateButton is a Button
//        Set Size to 14 60
//        Set Location to 55 60
//        Set Label to "Create"
//    
//        Procedure OnClick
//            Boolean bCancel
//            Integer iAreaNumber iRetval iDays
//            Date    dBegin dEnd
//            //
//            Get Value of oAreaForm  to iAreaNumber
//            Get Value of oBeginDate to dBegin
//            Get Value of oEndDate   to dEnd
//            //
//            If (dBegin <> 0) Begin
//                Move (dEnd - dBegin) to iDays
//                Increment               iDays
//                If (iDays > System.MaxCreateInv) Begin
//                    Send Stop_Box "Maximum days exceeded"
//                    Procedure_Return
//                End
//                //
//                Get Confirm ("Create invoices for" * String(dBegin) * "thru" * String(dEnd) + "?") to bCancel
//                If (not(bCancel)) Begin
//                    Get DoCreateInvoices   of oInvoiceCreationProcess iAreaNumber dBegin dEnd to iRetval
//                    Send Beginning_Of_Data of oHeaderList
//                End
//            End
//            Else Begin
//                Send Stop_Box "No begin date entered"
//            End
//            Send Activate of oHeaderList
//        End_Procedure
//    End_Object

    Object oInvoiceOneJobButton is a Button
        Set Size to 14 60
        Set Location to 58 60
        Set Label to "Invoice 1 Job"
    
        Procedure OnClick
            Boolean bCancel
            Integer iJobNumber iRecId iDays
            String  sWorkType
            Date    dBegin dEnd
            //
            Get Value of oBeginDate  to dBegin
            Get Value of oEndDate    to dEnd
            //
            Get psActivityType       to sWorkType
            Move (Left(sWorkType,1)) to sWorkType
            //
            If (dBegin <> 0) Begin
                Move (dEnd - dBegin) to iDays
                Increment               iDays
                If (iDays > System.MaxCreateInv) Begin
//                    Send Stop_Box "Maximum days exceeded"
                    Get Confirm ("You are invoicing for" * String(iDays) * "days." * "Continue?") to bCancel
                    If (bCancel) Procedure_Return
                End
                //
                Get IsSelectedJobNumber of Order_sl sWorkType True to iJobNumber
                If (not(iJobNumber)) Begin
                    Send Stop_Box "No job selected"
                    Procedure_Return
                End
                //
                Get Confirm ("Create invoice for job" * String(iJobNumber) * String(dBegin) * "thru" * String(dEnd) + "?") to bCancel
                If (not(bCancel)) Begin
                    Get DoCreateInvoiceForJobAndDates of oInvoiceCreationProcess iJobNumber dBegin dEnd to iRecId
                    If (iRecId) Begin
                        Send Find_By_Recnum of oInvhdr_DD Invhdr.File_Number iRecId
                        Send Find           of oInvdtl_DD FIRST_RECORD 2
                        Send End_of_Data    of oHeaderList
                    End
                End
            End
            Else Begin
                Send Stop_Box "No begin date entered"
            End
            Send Activate of oHeaderList
        End_Procedure
    End_Object

//    Object oTypeComboForm is a ComboForm
//        Set Size to 13 76
//        Set Location to 89 60
//        Set Label to "Type Filter:"
//        Set Label_Col_Offset to 3
//        Set Label_Justification_Mode to JMode_Right
//        Set Combo_Sort_State to False
//        Set Allow_Blank_State to True
//    
//        //Combo_Fill_List is called when the list needs filling
//    
//        Procedure Combo_Fill_List
//            // Fill the combo list with Send Combo_Add_Item
//            Send Combo_Add_Item "Snow Removal"
//            Send Combo_Add_Item "Pavement Mnt."
//            Send Combo_Add_Item "Other"
//        End_Procedure
//    
//        Procedure OnChange
//            String sValue
//            //
//            Get Value          to sValue
//            Set psActivityType to sValue
//            //
//            Send Rebuild_Constraints of oOpers_DD
//            Send Rebuild_Constraints of oOrder_DD
//            Send Rebuild_Constraints of oInvhdr_DD
//            Send Rebuild_Constraints of oInvdtl_DD
//            Send End_of_Data         of oHeaderList
//        End_Procedure
//    
//        //Notification that the list has dropped down
//        //Procedure OnDropDown
//        //End_Procedure
//    
//        //Notification that the list was closed
//        //Procedure OnCloseUp
//        //End_Procedure
//    
//    End_Object

    Object oHeaderList is a cGlblDbList
        Set Size to 75 362
        Set Location to 10 175
        Set Move_Value_Out_State to False

        Begin_Row
            Entry_Item Invhdr.InvoiceIdno
            Entry_Item Invhdr.InvoiceDate
            Entry_Item Location.Name
            Entry_Item Invhdr.TotalAmount
        End_Row

        Set Main_File to Invhdr.File_number

        Set Form_Width 0 to 40
        Set Header_Label 0 to "Invoice#"
        Set Header_Justification_Mode 0 to JMode_Right
        Set Form_Width 2 to 207
        Set Header_Label 2 to "Name"
        Set Form_Width 3 to 50
        Set Header_Label 3 to "Total"
        Set Header_Justification_Mode 3 to JMode_Right
        Set Form_Width 1 to 54
        Set Header_Label 1 to "Date"
        Set peAnchors to anTopLeftRight
        Set peResizeColumn to rcSelectedColumn
        Set piResizeColumn to 1
        Set Auto_Index_State to False
        Set pbUseServerOrdering to True

        Procedure Refresh Integer iMode
            Forward Send Refresh iMode
            //
            Send Delete_Data of oCallCenterGrid
        End_Procedure
    End_Object

    Object oClearButton is a Button
        Set Size to 14 100
        Set Location to 89 177
        Set Label to "Clear Invoice to Print"
    
        Procedure OnClick
            Send DoClearInvoice
        End_Procedure
    End_Object

    Object oVoidButton is a Button
        Set Location to 89 284
        Set Label to "Void Invoice"
    
        Procedure OnClick
            Send DoVoidInvoice
        End_Procedure
    End_Object

    Object oPrintButton is a Button
        Set Location to 89 343
        Set Label to "Print"
    
        Procedure OnClick
            Send DoPrintInvoice
        End_Procedure
    End_Object

    Object oCreateHeaderButton is a Button
        Set Size to 14 100
        Set Location to 89 400
        Set Label to "Create Invoice Header"
    
        Procedure OnClick
            Send DoCreateInvoiceHeader
        End_Procedure
    End_Object

    Object oDetailContainer is a cGlblDbContainer3d
        Set Server to oInvdtl_DD
        Set Size to 131 528
        Set Location to 110 10
        Set Border_Style to Border_None
        Set peAnchors to anAll

        Object oDetailGrid is a DbGrid

//            Procedure Item_Change Integer iFrItem Integer iToItem Returns Integer
//                Boolean bMaterial
//                Integer hoDD iRetval iCol iCols iToCol iBaseItem
//                //
//                Get Server                to hoDD
//                Get Base_Item             to iBaseItem
//                Get Current_Col           to iCol
//                Move 10                   to iCols
//                Move (mod(iToItem,iCols)) to iToCol
//                //
//                Forward Get msg_Item_Change iFrItem iToItem to iRetval
//                //
//                If (iToItem = iFrItem) Begin
//                    Procedure_Return
//                End
//                //
//                If (iCol = 3) Begin
//                    Send Refind_Records of hoDD
//                    Move (Opers.CostType <> "Labor") to bMaterial
//                    If (iToCol = 6 and bMaterial) Begin
//                        Move (iRetval + 2) to iRetval
//                    End
//                End
//                //
//                If (iCol = 1) Begin
//                    Set piOrder of hoDD to (Current_Record(oOrder_DD))
//                End
//                //
//                Procedure_Return iRetval
//            End_Procedure

            Function Child_Entering Returns Integer
                Integer iRetval iRecId
                // Check with header to see if it is saved.
                Delegate Get IsSavedHeader to iRetval
                //
                If (iRetval = 0) Begin
                    Get Current_Record  of oInvdtl_DD to iRecId
                    Send Find_By_Recnum of oInvdtl_DD Invdtl.File_Number iRecId
                End
                //
                Function_Return iRetval // if non-zero do not enter
            End_Function  // Child_Entering

            Procedure Prompt
                Integer iCol iRecId
                //
                Get Current_Col                 to iCol
                Get Current_Record of oOpers_DD to iRecId
                //
                Forward Send Prompt
                //
                If (Current_Record(oOpers_DD) <> iRecId) Begin
                    Set Field_Changed_Value of oInvdtl_DD Field Invdtl.Price to Opers.SellRate
//                    If (iRecId = 0) Begin
                        Set Field_Changed_Value of oInvdtl_DD Field Invdtl.Description to Opers.Description
//                    End
                End
            End_Procedure

            Procedure Request_Clear
                If (Changed_State(oInvdtl_DD)) Begin
                    Forward Send Request_Clear
                End
                Else Begin
                    Send Add_New_Row 0
                End
            End_Procedure

            Function DataLossConfirmation Returns Integer
                Integer bCancel
                //
                If (not(Changed_State(oInvhdr_DD))) Begin
                    Function_Return
                End
                Else Begin
                    Get Confirm "Abandon Invoice Detail Changes?" to bCancel
                    Function_Return bCancel
                End
            End_Function

            Set Size to 87 527
            Set Wrap_State to True
            Set Child_Table_State to True
            Set Verify_Data_Loss_Msg to get_DataLossConfirmation
            Set Verify_Exit_msg to get_DataLossConfirmation
            Set peAnchors to anAll
            Set peResizeColumn to rcAll
            Set Ordering to 2
    
            Begin_Row
                Entry_Item Invdtl.Sequence
                Entry_Item Invdtl.StartDate
                Entry_Item Opers.OpersIdno
                Entry_Item Opers.Name
                Entry_Item Invdtl.StartTime
                Entry_Item Invdtl.StopTime
                Entry_Item Invdtl.Quantity
                Entry_Item Invdtl.Price
                Entry_Item Invdtl.Total
            End_Row
    
            Set Main_File to Invdtl.File_number
    
            Set Form_Width 0 to 28
            Set Header_Label 0 to "Seq"
            Set Header_Justification_Mode 0 to JMode_Right

            Set Form_Width 1 to 46
            Set Header_Label 1 to "Date"

            Set Form_Width 2 to 50
            Set Header_Label 2 to "Opcode"

            Set Form_Width 3 to 158
            Set Header_Label 3 to "Description"

            Set Form_Width 4 to 46
            Set Header_Label 4 to "StartTime"

            Set Form_Width 5 to 46
            Set Header_Label 5 to "StopTime"

            Set Form_Width 6 to 48
            Set Header_Label 6 to "Hrs/Qty"
            Set Header_Justification_Mode 6 to JMode_Right

            Set Form_Width 7 to 46
            Set Header_Label 7 to "Rate"
            Set Header_Justification_Mode 7 to JMode_Right

            Set Form_Width 8 to 50
            Set Header_Label 8 to "Total"
            Set Header_Justification_Mode 8 to JMode_Right
            Set Color to clWhite
            Set peDisabledColor to clWhite
            Set peDisabledTextColor to clBlack
            Set TextColor to clBlack

        End_Object

        Object oInvdtl_Description is a cComDbSpellText //cDbTextEdit

            Property Boolean pbText
            Property Boolean pbChangedText
            Property Integer piRecId
            Property String  psText

            Entry_Item Invdtl.Description
            Set Location to 94 45
            Set Size to 36 257
            Set Label to "Description:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
            Set peAnchors to anBottomLeftRight

            Procedure OnCreate
                Forward Send OnCreate
                // ToDo: Set the ActiveX properties here...
                Set ComDebugOption to OLEDebug_Actions
                Set ComMaxLength   to 2048
            End_Procedure
        
            Procedure Request_Save
                Send Next
            End_Procedure

            Procedure Next
                Set pbText to False
                Send Activate of oDetailGrid
            End_Procedure
    
            Procedure OnComChange
                String sText
                //
                If (pbText(Self)) Begin
                    Set pbChangedText                                                  to True
                    Get ComText                                                        to sText
//                    Set Field_Changed_Value of oQuotedtl_DD Field Quotedtl.Description to sText
//                    Send Request_Save       of oQuotedtl_DD
                    Set psText                                                         to sText
                End
            End_Procedure

            Procedure OnComGainedFocus
                Set pbText  to True
                Set piRecId to (Current_Record(oInvdtl_DD))
            End_Procedure

            Procedure OnComDebugEvent String llDebugInfo
                Showln llDebugInfo
            End_Procedure

            Procedure Exiting Integer iObj Returns Integer
                Boolean bChanged
                Integer iRetval iRecId
                String  sText
                //
                Forward Get msg_Exiting iObj to iRetval
                If (iRetval) Begin
                    Procedure_Return iRetval
                End
                //
                Get pbChangedText to bChanged
                If (bChanged) Begin
                    Send ChangeAllFileModes DF_FILEMODE_READONLY
                    Set_Attribute DF_FILE_MODE of Invdtl.File_Number to DF_FILEMODE_DEFAULT
                    Get piRecId                                      to iRecId
                    If (Invdtl.Recnum <> iRecId) Begin
                        Clear Invdtl
                        Move iRecId to Invdtl.Recnum
                        Find eq Invdtl.Recnum
                    End
                    Get psText to sText
                    Reread
                    Move sText to Invdtl.Description
                    SaveRecord Invdtl
                    Unlock
                    Send ChangeAllFileModes DF_FILEMODE_DEFAULT
                    Set pbChangedText                                  to False
                End
                //
                Procedure_Return iRetval
            End_Procedure
    
//            Procedure OnComLosingFocus
//                Boolean bChanged
//                Integer iRetval
//                String  sText
//                //
//                Get pbChangedText to bChanged
//                If (bChanged) Begin
//                    Get psText                                                         to sText
//                    Set Field_Changed_Value of oQuotedtl_DD Field Quotedtl.Description to sText
//                    Send Request_Save       of oQuotedtl_DD
//                    Set pbChangedText                                                  to False
//                End
//            End_Procedure
    
//            Procedure Next
//                Send Request_Save
//                Send Activate of oDetailGrid
//            End_Procedure
        End_Object

//        Object oCollectButton is a Button
//            Set Size to 14 160
//            Set Location to 94 307
//            Set Label to "Collect && Process Auto-Attendant Transactions"
//            Set peAnchors to anBottomRight
//        
//            Procedure OnClick
//                Integer iCount
//                //
//                Get DoCollectAndProcessTransactions of oCollectTransactionsProcess to iCount
//            End_Procedure
//        End_Object

//        Object oLocationNoteButton is a Button
//            Set Size to 14 160
//            Set Location to 109 307
//            Set Label to "Collect && Process Area && Location Notes"
//            Set peAnchors to anBottomRight
//        
//            Procedure OnClick
//                Integer iCount
//                //
//                Get DoCollectAndProcessLocationNotes of oCollectLocationNotesProcess to iCount
//                Get DoCollectAndProcessAreaNotes     of oCollectAreaNotesProcess     to iCount
//            End_Procedure
//        
//        End_Object

    End_Object

    Object oCallCenterTextBox is a TextBox
        Set Size to 10 85
        Set Location to 255 10
        Set Label to "Recent Call Center Activity"
        Set TextColor to clRed
        Set peAnchors to anBottomLeftRight
    End_Object

    Object oCallCenterGrid is a cGlblGrid

        Property tWStLocnotes[] ptNotes
        Property Boolean pbFilled

        Set Location to 267 10
        Set Size to 57 423
    
        Set Line_Width to 6 0
    
        Set Form_Width 0 to 50
        Set Header_Label 0 to "Date"
    
        Set Form_Width    item 1 to 28
        Set Header_Label 1 to "Time"
    
        Set Form_Width    item 2 to 86
        Set Header_Label 2 to "By"

        Set Header_Label 3 to "Status"
        Set Form_Width 3 to 60

        Set Header_Label 4 to "Request Description"
        Set Form_Width 4 to 100

        Set Header_Label 5 to "Assigned To"
        Set Form_Width 5 to 90

        Set peAnchors to anBottomLeftRight
        Set peResizeColumn to rcSelectedColumn
        Set piResizeColumn to 4
        Set CurrentCellColor to clYellow
        Set CurrentCellTextColor to clBlack
        Set CurrentRowColor to clYellow
        Set CurrentRowTextColor to clBlack
        Set Highlight_Row_State to True
    
        Procedure AddReadOnlyItem String sValue //Boolean bNumber
            Integer iItem
            //
            Move (Item_Count(Self))                       to iItem
            Send Add_Item msg_None                           sValue
//            If (bNumber) Begin
//                Set Form_Datatype item iItem              to MASK_NUMERIC_WINDOW
//            End
            Set Entry_State item ((Item_Count(Self)) - 1) to False
        End_Procedure

        Procedure DoFillGrid tWStLocnotes[] tNotes
            Integer iItems iItem iUserId iL
            String  sUser sStatus sTime
            //
            Set ptNotes                to tNotes
            Set pbFilled               to False
            Set Dynamic_Update_State   to False
            Send Delete_Data
            Set Select_Mode            to Multi_Select
            //
            Move (SizeOfArray(tNotes)) to iItems
            Decrement iItems
            For iItem from 0 to iItems
                Move tNotes[iItem].iCreatedBy to iUserId
                Clear User
                Move iUserId to User.UserId
                Find eq User.UserId
                Move (trim(User.FirstName) * Trim(User.LastName)) to sUser
                //
                Move tNotes[iItem].sCreatedTime to sTime
                Move (Left(sTime,5))            to sTime
                //
                Move tNotes[iItem].sStatus   to sStatus
                Move (Length(sStatus))       to iL
                Move (Mid(sStatus,(iL-2),3)) to sStatus
                //
                Send AddReadOnlyItem tNotes[iItem].dCreatedDate
                Send AddReadOnlyItem sTime
                Send AddReadOnlyItem sUser
                Send AddReadOnlyItem sStatus
                Send AddReadOnlyItem tNotes[iItem].sReqtypesCode
                Send AddReadOnlyItem tNotes[iItem].sAssignedTo
            Loop
            //
            Set Select_Mode          to No_Select
            Set Dynamic_Update_State to True
            Set pbFilled             to True
            Set Current_Item         to 0
        End_Procedure  // DoFillGrid
    
        Procedure DoDisplayCurrent
            tWStLocnotes[] tNotes
            Integer iCur iItem
            String  sRowId sPage sWorkspaceWSFile
            Handle  hoWorkspace hoIniFile hWnd hInstance
            //
            Get ptNotes               to tNotes
            Get Current_Item          to iCur
            Move (iCur / 6)           to iItem
            Move tNotes[iItem].sRowId to sRowId
            //
            Move (phoWorkSpace(ghoApplication))                                to hoWorkspace
            Get psWorkspaceWSFile of hoWorkspace                               to sWorkspaceWSFile 
            Get Create U_cIniFile                                              to hoIniFile
            Set psFilename        of hoIniFile                                 to sWorkspaceWSFile 
            Get ReadString        of hoIniFile "WebServices" "WebsiteRoot" " " to sPage
            Move (sPage + "/CallCenterUpdateItem.asp?RowId=" + sRowId)         to sPage
//            Move ("http://208.79.212.77/IRTest/CallCenterUpdateItem.asp?RowId=" + sRowId) to sPage
            //WebsiteRoot=http://208.79.212.77/IRTest
            Move (ShellExecuteA (hWnd, "open", (trim(sPage)), '', '', 1))      to hInstance
        End_Procedure  // DoDisplayCurrent
    End_Object

    Object oRetrieveButton is a Button
        Set Size to 14 90
        Set Location to 280 445
        Set Label to "Retrieve Recent Activity"
        Set peAnchors to anBottomRight
    
        Procedure OnClick
            tWStLocnotes[] tNotes
            Integer iJobNumber iItems
            Date    dNoteDate
            //
            Send Cursor_Wait        of Cursor_Control
            Get Field_Current_Value of oInvhdr_DD Field Invhdr.JobNumber                 to iJobNumber
            Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceDate               to dNoteDate
            Move (dNoteDate - 1)                                                         to dNoteDate
            Get wsGetSelectedLocationNotes of oWSTransactionService iJobNumber dNoteDate to tNotes
            Move (SizeOfArray(tNotes))                                                   to iItems
            If (iItems) Begin
                Send DoFillGrid of oCallCenterGrid tNotes
            End
            Send Cursor_Ready of Cursor_Control
        End_Procedure
    End_Object

    Object oViewButton is a Button
        Set Size to 14 90
        Set Location to 295 445
        Set Label to "View Selected Item"
        Set peAnchors to anBottomRight
    
        Procedure OnClick
            // http://208.79.212.77/IRTest/CallCenterUpdateItem.asp?RowId=1a000000
            Send DoDisplayCurrent of oCallCenterGrid
        End_Procedure
    End_Object

    Function IsSavedHeader Returns Integer
        Integer iRecId
        //
        Get Current_Record of oInvhdr_DD to iRecId
        //
        If (iRecId = 0) Begin
            Send Stop_Box "No Invoice selected"
            Function_Return 1
        End
    End_Function

    Procedure DoClearInvoice
        Boolean bCancel
        Integer iInvId
        //
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno to iInvId
        Get Confirm ("Clear invoice number" * String(iInvId) + "?")    to bCancel
        If (not(bCancel)) Begin
            Set Field_Changed_Value of oInvhdr_DD Field Invhdr.EditFlag to 1
            Send Request_Save       of oInvhdr_DD
            Send Refresh_Page       of oHeaderList FILL_FROM_CENTER
        End
    End_Procedure

    Procedure DoVoidInvoice
        Boolean bCancel
        Integer iInvId
        //
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno to iInvId
        Get Confirm ("Void invoice number" * String(iInvId) + "?")     to bCancel
        If (not(bCancel)) Begin
            // free the Trans records to be invoiced later
//            Clear Invdtl
//            Move iInvId to Invdtl.InvoiceIdno
//            Find ge Invdtl.InvoiceIdno
//            While ((Found) and Invdtl.InvoiceIdno = iInvId)
//                Clear Trans
//                Move Invdtl.TransIdno to Trans.TransIdno
//                Find eq Trans.TransIdno
//                If (Found) Begin
//                    Reread Trans
//                    Move 0 to Trans.InvoicedFlag
//                    Move 0 to Trans.InvoiceDate
//                    SaveRecord Trans
//                    Unlock
//                End
//                Find gt Invdtl.InvoiceIdno
//            Loop
            //
            Set Field_Changed_Value of oInvhdr_DD Field Invhdr.EditFlag to 1
            Set Field_Changed_Value of oInvhdr_DD Field Invhdr.VoidFlag to 1
            Send Request_Save       of oInvhdr_DD
            Send Refresh_Page       of oHeaderList FILL_FROM_CENTER
        End
    End_Procedure

    Procedure DoPrintInvoice
        #IFDEF TEMPUS_LINK
        #ELSE
        Boolean bCancel
        Integer iInvId
        //
        Get Field_Current_Value of oInvhdr_DD Field Invhdr.InvoiceIdno to iInvId
        Get Confirm ("Print invoice" * String(iInvId) + "?")           to bCancel
        If (not(bCancel)) Begin
            Send DoJumpStartReport of oCustomerInvoice iInvId
            Send DoClearInvoice
        End
        #ENDIF
    End_Procedure

    Procedure Request_Delete
    End_Procedure

    Procedure DoCreateInvoiceHeader
        Boolean bCancel
        Integer iJobNumber hoDD
        String  sWorkType
        Date    dToday
        //
        Get psActivityType       to sWorkType
        Move (Left(sWorkType,1)) to sWorkType
        //
        Get IsSelectedJobNumber of Order_sl sWorkType True to iJobNumber
        If (iJobNumber <> 0) Begin
            Get Confirm ("Create Invoice Header for job number" * String(iJobNumber) + "?") to bCancel
            If (not(bCancel)) Begin
                Get Value of oBeginDate to dToday
                If (dToday = 0) Begin
                    Sysdate dToday
                End
                Move oInvhdr_DD to hoDD
                Send Clear        of hoDD
                Move iJobNumber to Order.JobNumber
                Send Request_Find of hoDD EQ Order.File_Number 1
                If (Found) Begin
                    Set Field_Changed_Value of hoDD Field Invhdr.InvoiceDate to dToday
                    Get Request_Validate    of hoDD                          to bCancel
                    If (not(bCancel)) Begin
                        Send Request_Save   of hoDD
                        Send Refresh_Page   of oHeaderList FILL_FROM_CENTER
                    End
                End
            End
        End
    End_Procedure

//    Procedure DoUpdateRemoteDataFiles
//        String sResult
//        //
//        Get DoUpdateMastOps  of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateAreas    of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateCustomer of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateLocation of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateOpers    of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateOrder    of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateInvoice  of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateEmployer of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateEmployee of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateEquipmnt of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateUser     of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//        Get DoUpdateReqtypes of oCollectTransactionsProcess to sResult
//        Send Info_Box sResult
//    End_Procedure
//    //
//    On_Key Key_Alt+Key_F12 Send DoUpdateRemoteDataFiles

Cd_End_Object
