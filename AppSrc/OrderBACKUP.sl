// Order.sl
// Order Lookup List

Use DFClient.pkg
Use DFSelLst.pkg
Use Windows.pkg
Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg

Use Customer.DD
Use Location.DD
Use Order.DD
Use SalesRep.DD
Use User.DD
Use cSalesTaxGroupGlblDataDictionary.dd

Object Order_sl is a cGlblDbModalPanel

    Property Boolean pbJobNumber
    Property Boolean pbOpen
    Property Integer piJobNumber
    Property String  psWorkType
    Property Integer piSelectedWorkType 
    Property Integer piSelectedStatus

    Set Location to 5 5
    Set Size to 265 479
    Set Label To "Order Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False
    Set piSelectedWorkType to 1

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object


    Object oCustomer_DD Is A Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oLocation_DD Is A Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server To oCustomer_DD
    End_Object // oLocation_DD

    Object oOrder_DD is a Order_DataDictionary
        
    Set DDO_Server to oSalesRep_DD
    Set DDO_Server to oCustomer_DD
    Set DDO_Server to oLocation_DD
    
    Procedure OnConstrain
        Date dClosed
        Date dCanceled
//        Move 00/00/00 to dClosed
//        Move 00/00/00 to dCanceled
        //Constrain Order.JobCloseDate eq dClosed
        //Constrain Order.WorkType eq "S"
        //Constrain Order.PromiseDate eq dCanceled
//        End_Procedure
//          
//          Was Taken out bc it was not constraining right
//        Procedure OnConstrain
//        If (giUserRights LT 60) Begin
//            Constrain Order.RepIdno eq User.SalesIdno
//        End

        Case Begin
            Case (piSelectedWorkType(Self) = 0)
            Case Break
            Case (piSelectedWorkType(Self) = 1)
            Constrain Order.WorkType eq "S" //Snow Only
            Case Break
            Case (piSelectedWorkType(Self) = 2)
            Constrain Order.WorkType eq "P" // PM Only
            Case Break
            Case (piSelectedWorkType(Self) = 3)
            Constrain Order.WorkType eq "SW" // Sweeping
            Case Break
            Case (piSelectedWorkType(Self) = 4)
            Constrain Order.WorkType eq "E" // Excav Only
            Case Break
            Case (piSelectedWorkType(Self) = 5)
            Constrain Order.WorkType eq "CE" // Capital Expenditure Only
            Case Break
            Case (piSelectedWorkType(Self) = 6)
            Constrain Order.WorkType eq "SL" // Shop Labor Only
            Case Break
            Case (piSelectedWorkType(Self) = 7)
            Constrain Order.WorkType eq "CX" // Connex Box Only
            Case Break
            Case (piSelectedWorkType(Self) = 8)
            Constrain Order.WorkType eq "O" // Other Only
            Case Break
        Case End

            If (piSelectedStatus(Self)=0) Begin
            End
            If (piSelectedStatus(Self)=1) Begin
                Constrain Order.Status eq "O" //Open
            End
            If (piSelectedStatus(Self)=2) Begin
                Constrain Order.Status eq "C" //Closed
            End
            If (piSelectedStatus(Self)=3) Begin
                Constrain Order.Status eq "X" //Canceled
            End
        End_Procedure
    End_Object // oOrder_DD

    Set Main_DD To oOrder_DD
    Set Server  To oOrder_DD

    Object oSelList is a cGlblDbList
        Set Size to 159 465
        Set Location to 10 5
        Set Main_File to Order.File_Number
        Set Ordering to 1
        Set peResizeColumn to rcAll
        Set Auto_Server_State to True
        Set pbHeaderTogglesDirection to True
        Set peAnchors to anAll        

        Begin_Row
            Entry_Item Order.JobNumber
            Entry_Item Order.Organization
            Entry_Item Location.Name
            Entry_Item Order.Title
        End_Row

        Set Form_Width 0 to 48
        Set Header_Label 0 to "Job Nbr"

        Set Form_Width 1 to 154
        Set Header_Label 1 to "Organization"

        Set Form_Width 2 to 150
        Set Header_Label 2 to "Location"
        Set Form_Width 3 to 200
        Set Header_Label 3 to "Title"


        Procedure Ok
            If (pbJobNumber(Self)) Begin
                Set piJobNumber to Order.JobNumber
                Send Close_Panel
            End
            Else Begin
                Forward Send Ok
            End
        End_Procedure

    End_Object // oSelList

    Object oWorktypeRadioGroup is a RadioGroup
        Set Location to 209 5
        Set Size to 23 465
        Set Label to "Work Type"
        Set peAnchors to anBottomLeft
    
        Object oRadio1 is a Radio
            Set Label to "All"
            Set Size to 10 27
            Set Location to 9 6
        End_Object
    
        Object oRadio2 is a Radio
            Set Label to "Snow"
            Set Size to 10 42
            Set Location to 9 39
        End_Object
    
        Object oRadio3 is a Radio
            Set Label to "PM"
            Set Size to 10 28
            Set Location to 9 85
        End_Object
        
        Object oRadio4 is a Radio
            Set Label to "Sweeping"
            Set Size to 10 41
            Set Location to 9 122
        End_Object
        
        Object oRadio5 is a Radio
            Set Label to "Excavation"
            Set Size to 10 47
            Set Location to 9 175
        End_Object
        
        Object oRadio6 is a Radio
            Set Label to "Capital Exp."
            Set Size to 10 54
            Set Location to 9 237
        End_Object
        
        Object oRadio7 is a Radio
            Set Label to "Shop Labor"
            Set Size to 10 50
            Set Location to 9 297
        End_Object
        
        Object oRadio8 is a Radio
            Set Label to "Connex Box"
            Set Size to 10 49
            Set Location to 9 359
        End_Object
        
        Object oRadio9 is a Radio
            Set Label to "Other"
            Set Size to 10 41
            Set Location to 9 416
        End_Object
    
        Procedure Notify_Select_State Integer iToItem Integer iFromItem
            Forward Send Notify_Select_State iToItem iFromItem
            //for augmentation
            Set piSelectedWorkType to iToItem
            Send Rebuild_Constraints of oOrder_DD
            //Send Beginning_of_Data   of oSelList
            Send Refresh_Page of oSelList FILL_FROM_CENTER
        End_Procedure
    
        //If you set Current_Radio, you must set it AFTER the
        //radio objects have been created AND AFTER Notify_Select_State has been
        //created. i.e. Set in bottom-code of object at the end!!
        Set Current_Radio to 0
    End_Object
    
    Object oStatusRadioGroup is a RadioGroup
        Set Location to 236 5
        Set Size to 24 150
        Set Label to "Status"
        Set peAnchors to anBottomLeft
    
        Object oRadio1 is a Radio
            Set Label to "All"
            Set Size to 10 27
            Set Location to 10 6
        End_Object
    
        Object oRadio2 is a Radio
            Set Label to "Open"
            Set Size to 10 31
            Set Location to 10 33
        End_Object
    
        Object oRadio3 is a Radio
            Set Label to "Closed"
            Set Size to 10 35
            Set Location to 10 67
        End_Object
        
        Object oRadio4 is a Radio
            Set Label to "Canceled"
            Set Size to 10 41
            Set Location to 10 107
        End_Object
    
        Procedure Notify_Select_State Integer iToItem Integer iFromItem
            Forward Send Notify_Select_State iToItem iFromItem
            //for augmentation
            Set piSelectedStatus to iToItem
            Send Rebuild_Constraints of oOrder_DD
            //Send Beginning_of_Data of oSelList
            Send Refresh_Page of oSelList FILL_FROM_CENTER
        End_Procedure
    
        //If you set Current_Radio, you must set it AFTER the
        //radio objects have been created AND AFTER Notify_Select_State has been
        //created. i.e. Set in bottom-code of object at the end!!
        Set Current_Radio to 1    // 1 = Open
    End_Object

//    Object oDbGroup1 is a dbGroup
//        Set Size to 25 135
//        Set Location to 235 161
//        Set Label to 'Activity Type Filter'
//        Set peAnchors to anBottomLeft
//
//        Object oWorkTypeCombo is a dbComboForm
//            Set Size to 14 100
//            Set Entry_State to False
//            Set Allow_Blank_State to False
//            Set Location to 9 4
//            Set Combo_Data_File to 74
//            Set Code_Field to 1
//            Set Combo_Index to 1
//            Set Description_Field to 1
//            Set Label to ""
//            Set Label_Justification_Mode to JMode_Right
//            Set Label_Col_Offset to 5
//            
//            Procedure OnChange
//                Send Rebuild_Constraints of oOpers_DD
//                Send MovetoFirstRow of oSelList
//            End_Procedure
//        End_Object
//        
//        Object oButton1 is a Button
//            Set Size to 15 25
//            Set Location to 8 106
//            Set Label to 'Clear'
//        
//            // fires when the button is clicked
//            Procedure OnClick
//                //Clear Value in Filter
//                Set Value of oWorkTypeCombo to ""
//            End_Procedure
//        
//        End_Object
//    End_Object

    Object oOk_bn Is A Button
        Set Label to "&Ok"
        Set Location to 243 313
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A Button
        Set Label to "&Cancel"
        Set Location to 243 367
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure
    End_Object // oCancel_bn

    Object oSearch_bn Is A Button
        Set Label to "&Search..."
        Set Location to 243 421
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

    Function IsSelectedJobNumber String sWorkType Boolean bOpen Returns Integer
        Integer iJobNumber
        //
        Set pbJobNumber to True
        Set piJobNumber to 0
        Set pbOpen      to bOpen
        Set psWorkType  to sWorkType
        Send Rebuild_Constraints of oOrder_DD
        //
        Set Move_Value_Out_State of oSelList to False
        //
        Send Popup_Modal
        //
        Set Move_Value_Out_State of oSelList to True
        //
        Set pbJobNumber to False
        Get piJobNumber to iJobNumber
        Set pbOpen      to False
//        If (piSelectedWorkType(Self) = 1) Begin
//            Set psWorkType to "S"
//        End
//        If (piSelectedWorkType(Self) = 2) Begin
//            Set psWorkType to "P"
//        End
        Set psWorkType  to ""
        Send Rebuild_Constraints of oOrder_DD
        //
        Function_Return iJobNumber
    End_Function



End_Object

