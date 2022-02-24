// Salesrep.sl
// Salesrep Lookup List

Use DFClient.pkg
Use DFSelLst.pkg
Use Windows.pkg
Use cGlblDbModalPanel.pkg
Use cGlblDbList.pkg

Use SalesRep.DD

Object Salesrep_sl is a cGlblDbModalPanel
    
    Property Boolean pbSelected
    Property Integer piStatus
    Property Integer piIdno

    Property RowID   priContact
    Property Integer piContacIdno
    Property Boolean pbContacIdno
    
    Set Location to 6 5
    Set Size to 202 285
    Set Label to "Salesrep Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Object oSalesrep_DD is a Salesrep_DataDictionary
        Set DDO_Server to oSalesrep_DD
        
        Procedure OnConstrain
            If (piStatus(Self) = 1) Begin
                Constrain SalesRep.Status eq "A"
            End
            Else If (piStatus(Self) = 2) Begin
                Constrain SalesRep.Status eq "I"
            End
        End_Procedure
    End_Object // oSalesrep_DD

    Set Main_DD To oSalesrep_DD
    Set Server  to oSalesrep_DD
    
    Object oSelList is a cGlblDbList
        Set Size to 141 275
        Set Location to 4 6
        Set peAnchors to anAll
        Set Main_File to Salesrep.File_Number
        Set Ordering to 2
        Set peResizeColumn to rcAll
        Set pbHeaderTogglesDirection to True    
       
        Begin_row
            Entry_Item Salesrep.RepIdno
            Entry_Item Salesrep.LastName
            Entry_Item SalesRep.FirstName
            Entry_Item SalesRep.Status
        End_row

        Set Form_Width 0 to 45
        Set Header_Label 0 to "Sales Rep#"
        Set Form_Width 1 to 78
        Set Header_Label 1 to "Last Name"
        Set Form_Width 2 to 78
        Set Header_Label 2 to "First Name"
        Set Form_Width 3 to 39
        Set Header_Label 3 to "Status"
        Set Auto_Column_State to False
        Set Initial_Column to 2
        Set Auto_Index_State to False
        
    End_Object // oSelList

    Object oOk_bn Is A Button
        Set Label to "&Ok"
        Set Location to 182 122
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn Is A Button
        Set Label to "&Cancel"
        Set Location to 182 175
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn Is A Button
        Set Label to "&Search..."
        Set Location to 182 228
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn


    Object oStatusRadioGroup is a RadioGroup
        Set Location to 149 6
        Set Size to 50 70
        Set Label to "Status"
        Set peAnchors to anBottomLeft
    
        Object oRadio1 is a Radio
            Set Label to "All"
            Set Size to 10 61
            Set Location to 11 6
        End_Object
    
        Object oRadio2 is a Radio
            Set Label to "Active"
            Set Size to 10 61
            Set Location to 23 6
        End_Object
    
        Object oRadio3 is a Radio
            Set Label to "Inactive"
            Set Size to 10 61
            Set Location to 37 6
        End_Object
                
        Procedure Notify_Select_State Integer iToItem Integer iFromItem
            Forward Send Notify_Select_State iToItem iFromItem
            //for augmentation
            Set piStatus to iToItem
            Send Rebuild_Constraints of oSalesrep_DD
            Send Beginning_of_Data   of oSelList
        End_Procedure
    
        //If you set Current_Radio, you must set it AFTER the
        //radio objects have been created AND AFTER Notify_Select_State has been
        //created. i.e. Set in bottom-code of object at the end!!

         Set Current_Radio to 1  
    End_Object

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

//    Function IsSelectedSalesRep String sCostType Returns Integer
//        Send Rebuild_Constraints of oSalesrep_DD
//        Send Beginning_of_Data   of oSelList
//        Send Popup
//        Send Rebuild_Constraints of oSalesrep_DD
//        Function_Return (piIdno(Self))
//    End_Function
    
    Function IsSelectedSalesRep Integer ByRef iRepIdno RowID ByRef riContact RowID ByRef riCustomer Returns Boolean
        Boolean bSelected
        Handle  hoServer
        //
        Get Server to hoServer
        //
        Send Clear_All of hoServer
        //
        If (iRepIdno<>0) Begin
            Move iRepIdno to SalesRep.RepIdno
            Send Find of hoServer EQ 1 
        End
        If      (not(IsNullRowId(riContact))) Begin
            Send FindByRowId of hoServer SalesRep.File_Number riContact
        End
        Else If (not(IsNullRowId(riCustomer))) Begin
            Send FindByRowId of hoServer SalesRep.File_Number riCustomer
        End
        //
        Set pbSelected                       to False
        //Set Move_Value_Out_State of oSelList to False
        //
        Send Popup
        //
        //Set Move_Value_Out_State of oSelList to True
        Get pbSelected                       to bSelected
        Get priContact                       to riContact
        //
        Function_Return bSelected
    End_Function
    
End_Object // Salesrep_sl

