// Contact.sl
// Contact Lookup List

Use DFClient.pkg
Use DFSelLst.pkg
Use Windows.pkg
Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg

Use Customer.DD
Use Contact.DD
Use SalesRep.DD
Use cSnowrepDataDictionary.dd

Object Contact_sl is a cGlblDbModalPanel

    Property Boolean pbSelected
    Property Integer piStatus
    Property RowID   priContact
    Property Integer piContacIdno
    Property Boolean pbContacIdno

    Set Location to 5 5
    Set Size to 180 378
    Set Label To "Contact Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object

    Object oSalesrep_DD is a Salesrep_DataDictionary
    End_Object


    Object oCustomer_DD Is A Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oContact_DD Is A Contact_DataDictionary
        Set Constrain_file to Customer.File_number
        Set DDO_Server to oSnowrep_DD
        Set DDO_Server to oSalesrep_DD
        Set DDO_Server to oCustomer_DD

        Procedure OnConstrain
            If      (piStatus(Self) = 1) Begin
                Constrain Contact.Status eq "A"
            End
            Else If (piStatus(Self) = 2) Begin
                Constrain Contact.Status eq "I"
            End
        End_Procedure
    End_Object // oContact_DD

    Set Main_DD To oContact_DD
    Set Server  To oContact_DD

    Object oSelList is a cGlblDbList
        Set Size to 104 368
        Set Location to 10 5
        Set peAnchors to anAll
        Set Main_File to Contact.File_Number
        Set Ordering to 1
        Set peResizeColumn to rcAll
        Set pbHeaderTogglesDirection to True

        Begin_row
            Entry_Item Customer.CustomerIdno
            Entry_Item Contact.ContactIdno
            Entry_Item Contact.LastName
            Entry_Item Contact.FirstName
            Entry_Item Customer.Name
        End_row

        Set Column_Shadow_State 0 to True

        Set Form_Width 1 to 39
        Set Header_Label 1 to "Contact#"
        Set Form_Width 2 to 70
        Set Header_Label 2 to "Last Name"
        Set Form_Width 4 to 180
        Set Header_Label 4 to "Organization"
        Set Form_Width 3 to 70
        Set Header_Label 3 to "First Name"
        Set Form_Width 0 to 1
        Set Header_Label 0 to "CustomerIdno"
        Set Auto_Column_State to False
        Set Initial_Column to 1
        Set Auto_Index_State to False

        Procedure Ok
            RowID riContact
            //
            If (pbContacIdno(Self)) Begin
                Set piContacIdno to Contact.ContactIdno
                Send Close_Panel
            End
            //
            If (Move_Value_Out_State(Self)) Begin
                Forward Send Ok
            End
            Else Begin
                Get CurrentRowId of oContact_DD to riContact
                Set priContact                  to riContact
                Set pbSelected                  to True
                Send Close_Panel
            End

        End_Procedure

    End_Object // oSelList

    Object oOk_bn Is A Button
        Set Label to "&Ok"
        Set Location to 162 215
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A Button
        Set Label to "&Cancel"
        Set Location to 162 269
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A Button
        Set Label to "&Search..."
        Set Location to 162 323
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    Object oStatusRadioGroup is a RadioGroup
        Set Location to 120 5
        Set Size to 54 77
        Set Label to "Status"
        Set peAnchors to anBottomLeft
    
        Object oRadio1 is a Radio
            Set Label to "All"
            Set Size to 10 61
            Set Location to 10 5
        End_Object
    
        Object oRadio2 is a Radio
            Set Label to "Active"
            Set Size to 10 61
            Set Location to 25 5
        End_Object
    
        Object oRadio3 is a Radio
            Set Label to "Inactive"
            Set Size to 10 61
            Set Location to 40 5
        End_Object
    
        Procedure Notify_Select_State Integer iToItem Integer iFromItem
            Forward Send Notify_Select_State iToItem iFromItem
            //for augmentation
            Set piStatus to iToItem
            Send Rebuild_Constraints of oContact_DD
            Send Beginning_of_Data   of oSelList
        End_Procedure
    
        //If you set Current_Radio, you must set it AFTER the
        //radio objects have been created AND AFTER Notify_Select_State has been
        //created. i.e. Set in bottom-code of object at the end!!
        Set Current_Radio to 1    
    End_Object

    Function IsSelectedContact RowID ByRef riContact RowID ByRef riCustomer Returns Boolean
        Boolean bSelected
        Handle  hoServer
        //
        Get Server to hoServer
        //
        Send Clear_All of hoServer
        //
        If      (not(IsNullRowId(riContact))) Begin
            Send FindByRowId of hoServer Contact.File_Number riContact
        End
        Else If (not(IsNullRowId(riCustomer))) Begin
            Send FindByRowId of hoServer Customer.File_Number riCustomer
        End
        //
        Set pbSelected                       to False
        Set Move_Value_Out_State of oSelList to False
        //
        Send Popup
        //
        Set Move_Value_Out_State of oSelList to True
        Get pbSelected                       to bSelected
        Get priContact                       to riContact
        //
        Function_Return bSelected
    End_Procedure

    Function IsSelectedContact2 Returns Integer
        Integer iContact iMode
        //
        Get Locate_Mode to iMode
        Set Locate_Mode to CENTER_ON_PANEL
        //
        Set pbContacIdno to True
        Set piContacIdno to 0
        //
        Set Constrain_File of oContact_DD to Customer.File_Number
        Send Rebuild_Constraints of oContact_DD
        //
        Set Move_Value_Out_State of oSelList to False
        Send Beginning_of_Data   of oSelList
        //
        Send Popup_Modal
        //
        Set Move_Value_Out_State of oSelList to True
        //
        //Set Constrain_File       of oContact_DD to Customer.File_Number
        //Send Rebuild_Constraints of oContact_DD
        //
        Set pbContacIdno    to False
        Set Locate_Mode to iMode
        Function_Return (piContacIdno(Self))
    End_Function

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

End_Object

