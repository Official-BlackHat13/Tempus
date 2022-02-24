// Customer.sl
// Customer Lookup List

Use DFClient.pkg
Use DFSelLst.pkg
Use Windows.pkg
Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg

Use Customer.DD

Object Customer_sl is a cGlblDbModalPanel

    Property Integer piStatus
    Property Boolean pbCustIdno
    Property Integer piCustIdno
    Property Boolean pbOpen

    Set Location to 5 5
    Set Size to 138 361
    Set Label To "Customer Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Object oCustomer_DD Is A Customer_DataDictionary
//        Procedure OnConstrain
//            Integer iStatus
//            //
//            Get piStatus to iStatus
//            //
//            If      (iStatus = 1) Begin
//                Constrain Customer.Status eq "A"
//            End
//            Else If (iStatus = 2) Begin
//                Constrain Customer.Status eq "I"
//            End
//        End_Procedure
    End_Object // oCustomer_DD

    Set Main_DD To oCustomer_DD
    Set Server  To oCustomer_DD

    Object oSelList is a cGlblDbList
        Set Size to 96 351
        Set Location to 10 5
        Set peAnchors to anAll
        Set Main_File to Customer.File_Number
        Set Ordering to 1
        Set peResizeColumn to rcAll
        Set Auto_Server_State to True
        Set pbHeaderTogglesDirection to True

        Begin_row
            Entry_Item Customer.CustomerIdno
            Entry_Item Customer.Name
            Entry_Item Customer.City
            Entry_Item Customer.Zip
        End_row

        Set Form_Width 0 to 46
        Set Header_Label 0 to "Customer#"

        Set Form_Width 1 to 147
        Set Header_Label 1 to "Name"
        Set Form_Width 2 to 88
        Set Header_Label 2 to "City"
        Set Form_Width 3 to 60
        Set Header_Label 3 to "Zip"

        Procedure OK
            If (pbCustIdno(Self)) Begin
                Set piCustIdno to Customer.CustomerIdno
                Send Close_Panel
            End
    //        Else If (pbQuoteLocRecId(Self)) Begin
    ////                Boolean bSelect
    ////                Move (Location.ContactIdno = 0 or Location.ContactIdno = piContactIdno(Self)) to bSelect
    ////                If (not(bSelect)) Begin
    ////                    Procedure_Return
    ////                End
    //            Set piQuoteLocRecId to Location.Recnum
    //            Send Close_Panel
    //        End
            Else Begin
                Forward Send OK
            End
        End_Procedure
        
    End_Object // oSelList

//   Object oStatusRadioGroup is a RadioGroup
//       Set Location to 106 5
//        Set Size to 25 125
//    
//       Object oAllRadio is a Radio
//            Set Label to "All"
//            Set Size to 10 23
//            Set Location to 10 5
//        End_Object
//    
//        Object oActiveRadio is a Radio
//            Set Label to "Active"
//            Set Size to 10 32
//            Set Location to 10 35
//        End_Object
////    
//        Object oInactiveRadio is a Radio
//           Set Label to "Inactive"
//            Set Size to 10 42
//            Set Location to 10 75
//        End_Object
//    
//        Procedure Notify_Select_State Integer iToItem Integer iFromItem
//            Forward Send Notify_Select_State iToItem iFromItem
//            //
//            Set piStatus to iToItem
//            Send Rebuild_Constraints of oCustomer_DD
//            Send Beginning_of_Data   of oSelList
//            Send Activate            of oSelList
//        End_Procedure
    
        //If you set Current_Radio, you must set it AFTER the
        //radio objects have been created AND AFTER Notify_Select_State has been
        //created. i.e. Set in bottom-code of object at the end!!
       // Set Current_Radio to 1
   // End_Object

    Function IsSelectedCustomer Integer iCustIdno Returns Integer
        Integer iMode
        //
        Get Locate_Mode to iMode
        Set Locate_Mode to CENTER_ON_PANEL
        //
        Set pbCustIdno to True
        Set piCustIdno to iCustIdno
        If (iCustIdno<>0) Begin
            Send Clear of oCustomer_DD
            Move iCustIdno to Customer.CustomerIdno
            Send Request_Find of oCustomer_DD EQ Customer.File_Number 1
        End
        
        //
        Set Constrain_File       of oCustomer_DD to 0
        Send Rebuild_Constraints of oCustomer_DD
        //
        Set Move_Value_Out_State of oSelList to False
        Send Beginning_of_Data   of oSelList
        //
        Send Popup_Modal
        //
        Set Move_Value_Out_State of oSelList to True
        //
        //Set Constrain_File       of oLocation_DD to Customer.File_Number
        //Send Rebuild_Constraints of oLocation_DD
        //
        Set pbCustIdno     to False
        Set Locate_Mode to iMode
        Function_Return (piCustIdno(Self))
    End_Function

    Object oOk_bn Is A Button
        Set Label to "&Ok"
        Set Location to 113 183
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A Button
        Set Label to "&Cancel"
        Set Location to 113 237
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A Button
        Set Label to "&Search..."
        Set Location to 113 291
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

//    Procedure Add_Focus Handle hoParent Returns Integer
//        Boolean bState
//        Integer iRetval
//        //
//        Forward Get msg_Add_Focus hoParent to iRetval
//        //
//        Get Auto_Server_State of oSelList          to bState
//        Move (not(bState))                         to bState
//        Set Visible_State     of oStatusRadioGroup to bState
//        Set Enabled_State     of oStatusRadioGroup to bState
//        //
//        Procedure_Return iRetval
//    End_Procedure
End_Object
