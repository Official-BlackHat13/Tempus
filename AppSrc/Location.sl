// Location.sl
// Location Lookup List

Use DFClient.pkg
Use DFSelLst.pkg
Use Windows.pkg
Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg

Use Customer.DD
Use Location.DD
Use cSalesTaxGroupGlblDataDictionary.dd

Object Location_sl is a cGlblDbModalPanel

    Property Boolean pbLocId
    Property Integer piLocId
    //
    Property Boolean pbQuoteLocRecId
    Property Integer piQuoteLocRecId
    Property Integer piContactIdno

    Set Location to 10 3
    Set Size to 139 499
    Set Label To "Location Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oCustomer_DD Is A Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
          Set DDO_Server to oCustomer_DD

//        Procedure OnConstrain
//            If (pbQuoteLocRecId(Self)) Begin
//                Integer iContactIdno
//                //
//                Get piContactIdno to iContactIdno
//                Constrain Location as (Location.ContactIdno = 0 or Location.ContactIdno = iContactIdno)
//            End
//        End_Procedure
    End_Object // oLocation_DD

    Set Main_DD To oLocation_DD
    Set Server  To oLocation_DD

    Object oSelList is a cGlblDbList
        Set Size to 105 490
        Set Location to 5 5
        Set peAnchors to anAll
        Set Main_File to Location.File_Number
        //Set Ordering to 5
        Set peResizeColumn to rcAll
        Set Auto_Server_State to True
        Set pbHeaderTogglesDirection to True

        Begin_row

            Entry_Item Location.LocationIdno
            Entry_Item Location.LocationNbr
            Entry_Item Location.Name
            Entry_Item Location.Address1
            Entry_Item Customer.Name
        End_row

        Set Form_Width 0 to 36
        Set Header_Label 0 to "ID"
        Set Header_Justification_Mode 0 to JMode_Right

        Set Form_Width 1 to 24
        Set Header_Label 1 to "Nbr"
        Set Column_Shadow_State 1 to True

        Set Form_Width 2 to 140
        Set Header_Label 2 to "Location Name"
        Set Form_Width 3 to 140
        Set Header_Label 3 to "Location Address"
        Set Form_Width 4 to 140
        Set Header_Label 4 to "Organization Name"

        Set Auto_Index_State to True
        Set pbUseServerOrdering to True

        Procedure OK
            If (pbLocId(Self)) Begin
                Set piLocId to Location.LocationIdno
                Send Close_Panel
            End
            Else If (pbQuoteLocRecId(Self)) Begin
                Set piQuoteLocRecId to Location.Recnum
                Send Close_Panel
            End
            Else Begin
                Forward Send OK
            End
        End_Procedure
    End_Object // oSelList

    Object oOk_bn Is A Button
        Set Label to "&Ok"
        Set Location to 119 332
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure
    End_Object // oOk_bn

    Object oCancel_bn Is A Button
        Set Label to "&Cancel"
        Set Location to 119 386
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure
    End_Object // oCancel_bn

    Object oSearch_bn Is A Button
        Set Label to "&Search..."
        Set Location to 119 440
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure
    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

    Function IsSelectedLocation Integer iCustomerIdno Returns Integer
        Integer iLocId iMode
        //
        Get Locate_Mode to iMode
        Set Locate_Mode to CENTER_ON_PANEL
        //
        Set pbLocId to True
        Set piLocId to 0
        //
        If (iCustomerIdno>0) Begin
            Set Constrain_File of oLocation_DD to Customer.File_Number
        End
        Else Set Constrain_File       of oLocation_DD to 0
        //
        Send Rebuild_Constraints of oLocation_DD
        //
        Set Move_Value_Out_State of oSelList to False
        Send Beginning_of_Data   of oSelList
        //
        Send Popup_Modal
        //
        Set Move_Value_Out_State of oSelList to True
        //
        Set Constrain_File       of oLocation_DD to Customer.File_Number
        Send Rebuild_Constraints of oLocation_DD
        //
        Set pbLocId     to False
        Set Locate_Mode to iMode
        Function_Return (piLocId(Self))
    End_Function

    Function IsQuoteLocation Integer iCustomerRecId Integer iContactIdno Returns Integer
        Integer hoDD iRecId iMode
        //
        Get Locate_Mode to iMode
        Set Locate_Mode to CENTER_ON_PANEL
        //
        Get Server          to hoDD
        Send Clear_All           of hoDD
        Send Find_By_Recnum      of hoDD Customer.File_Number iCustomerRecId
        Set pbQuoteLocRecId to True
        Set piQuoteLocRecId to 0
        Set piContactIdno   to iContactIdno
//        Send Rebuild_Constraints of hoDD
        //
        Set Move_Value_Out_State of oSelList to False
        Send Beginning_of_Data   of oSelList
        //
        Send Popup
        //
        Set Move_Value_Out_State of oSelList to True
        //
        Set pbQuoteLocRecId to False
//        Send Rebuild_Constraints of hoDD
        //
        Get piQuoteLocRecId to iRecId
        Set Locate_Mode     to iMode
        Function_Return iRecId
    End_Function

End_Object
