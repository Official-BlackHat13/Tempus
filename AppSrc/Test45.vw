Use Windows.pkg
Use DFClient.pkg

Deferred_View Activate_oTest45 for ;
Object oTest45 is a dbView

    Set Border_Style to Border_Thick
    Set Size to 200 300
    Set Location to 2 2

    Object oComboForm1 is a ComboForm
        Set Size to 13 100
        Set Location to 57 142
    
        //Combo_Fill_List is called when the list needs filling
    
        //Procedure Combo_Fill_List
        //    // Fill the combo list with Send Combo_Add_Item
        //    Send Combo_Add_Item "{item Value 1}"
        //    Send Combo_Add_Item "{item Value 2}"
        //End_Procedure
    
        //OnChange is called on every changed character
    
        //Procedure OnChange
        //    String sValue
        //
        //    Get Value To sValue // the current selected item
        //End_Procedure
    
        //Notification that the list has dropped down
    
        //Procedure OnDropDown
        //End_Procedure
    
        //Notification that the list was closed
    
        //Procedure OnCloseUp
        //End_Procedure
    
    End_Object

Cd_End_Object
