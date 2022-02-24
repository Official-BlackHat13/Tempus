Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Location.DD
Use Event.DD
Use Invhdr.DD
Use Invdtl.DD
Use MastOps.DD
Use Opers.DD
Use cGlblDbForm.pkg
Use cGlblDbList.pkg
//Use cGlblDbGrid.pkg
Use cGlblDbContainer3d.pkg
Use cDbTextEdit.pkg
Use szcalendar.pkg


Deferred_View Activate_oInvoiceEditor for ;
Object oInvoiceEditor is a dbView

    Object oMastops_DD is a Mastops_DataDictionary
    End_Object

    Object oEvent_DD is a Event_DataDictionary
//        Procedure OnNewCurrentRecord RowID riOldRowId RowID riNewRowId
//            Forward Send OnNewCurrentRecord riOldRowId riNewRowId
//            //
//            If (Operation_Mode = Mode_Finding and not(IsSameRowId(riOldRowId,riNewRowId))) Begin
//                Send Beginning_of_Data of oHeaderList
//            End
//        End_Procedure
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oMastops_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oInvhdr_DD is a Invhdr_DataDictionary
        Set DDO_Server to oEvent_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oInvdtl_DD is a Invdtl_DataDictionary
        Set DDO_Server to oOpers_DD
        Set Constrain_file to Invhdr.File_number
        Set DDO_Server to oInvhdr_DD
    End_Object

    Set Main_DD to oInvhdr_DD
    Set Server to oInvhdr_DD

    Set Border_Style to Border_Thick
    Set Size to 213 537
    Set Location to 1 2

    Object oEvent_EventIdno is a cGlblDbForm
        Entry_Item Event.EventIdno
        Set Location to 10 60
        Set Size to 13 48
        Set Label to "Event ID:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oEvent_StartDate is a cdbszDatePicker
        Entry_Item Event.StartDate
        Set Location to 25 60
        Set Size to 13 60
        Set Label to "Start Date:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oEvent_StopDate is a cdbszDatePicker
        Entry_Item Event.StopDate
        Set Location to 40 60
        Set Size to 13 60
        Set Label to "Stop Date:"
        Set Label_Col_Offset to 3
        Set Label_Justification_Mode to JMode_Right
    End_Object

    Object oHeaderList is a cGlblDbList
        Set Size to 62 349
        Set Location to 10 175

        Begin_Row
            Entry_Item Invhdr.InvoiceIdno
            Entry_Item Location.Name
            Entry_Item Invhdr.TotalAmount
        End_Row

        Set Server to oInvdtl_DD

        Set Main_File to Invdtl.File_number

        Set Form_Width 0 to 40
        Set Header_Label 0 to "Invoice#"
        Set Header_Justification_Mode 0 to JMode_Right
        Set Form_Width 1 to 252
        Set Header_Label 1 to "Name"
        Set Form_Width 2 to 48
        Set Header_Label 2 to "Total"
        Set Header_Justification_Mode 2 to JMode_Right
        Set Move_Value_Out_State to False
    End_Object

    Object oDetailContainer is a cGlblDbContainer3d
        Set Server to oInvdtl_DD
        Set Size to 128 515
        Set Location to 78 10
        Set Border_Style to Border_None

        Object oDetailGrid is a DbGrid
            Set Size to 87 514
    
            Begin_Row
                Entry_Item Invdtl.Quantity
                Entry_Item Opers.Name
                Entry_Item Invdtl.Comment
                Entry_Item Invdtl.StartTime
                Entry_Item Invdtl.StopTime
                Entry_Item Invdtl.Price
                Entry_Item Invdtl.Total
            End_Row
    
            Set Main_File to Invdtl.File_number
    
            Set Server to oInvdtl_DD
    
            Set Form_Width 0 to 30
            Set Header_Label 0 to "Qty"
            Set Header_Justification_Mode 0 to JMode_Right
            Set Form_Width 1 to 130
            Set Header_Label 1 to "Name"
            Set Form_Width 3 to 50
            Set Header_Label 3 to "Start Time"
            Set Form_Width 4 to 50
            Set Header_Label 4 to "Stop Time"
            Set Form_Width 5 to 48
            Set Header_Label 5 to "Price"
            Set Header_Justification_Mode 5 to JMode_Right
            Set Form_Width 6 to 48
            Set Header_Label 6 to "Total"
            Set Form_Width 2 to 150
            Set Header_Label 2 to "Comment"
            Set Header_Justification_Mode 6 to JMode_Right
        End_Object

        Object oInvdtl_Description is a cDbTextEdit
            Entry_Item Invdtl.Description
            Set Location to 94 49
            Set Size to 30 262
            Set Label to "Description:"
            Set Label_Justification_Mode to JMode_Right
            Set Label_Col_Offset to 3
        End_Object
    End_Object

Cd_End_Object
