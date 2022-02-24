// Z:\VDF17.0 Workspaces\Tempus\AppSrc\SalesTax.vw
// SalesTax
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use QBDataUpdateProcess.bp

Use cSalesTaxGroupGlblDataDictionary.dd
Use dfTable.pkg
Use Windows.pkg
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg

ACTIVATE_VIEW Activate_oSalesTax FOR oSalesTax
Object oSalesTax is a cGlblDbView
    Set Location to 5 6
    Set Size to 209 450
    Set Label To "SalesTax"
    Set Border_Style to Border_Thick


    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object // oSalesTaxGroup_DD

    Set Main_DD To oSalesTaxGroup_DD
    Set Server  To oSalesTaxGroup_DD

//    Object oDbGrid1 is a dbGrid
//        Set Size to 178 439
//        Set Location to 4 6
//        Set Wrap_State to True
//        Set peAnchors to anAll
//        Set Prompt_Button_Mode to PB_PromptOff
//        
//        Begin_Row
//            Entry_Item SalesTaxGroup.SalesTaxIdno
//            Entry_Item SalesTaxGroup.Name
//            Entry_Item SalesTaxGroup.Rate
//            Entry_Item SalesTaxGroup.QBItemSalesTaxID
//        End_Row
//
//        Set Main_File to SalesTaxGroup.File_Number
//        
//        Set Column_Shadow_State 0 to True
//        Set Form_Width 0 to 26
//        Set Header_Label 0 to "Idno"
//        Set Form_Width 1 to 180
//        Set Header_Label 1 to "Name"
//        Set Form_Width 2 to 36
//        Set Header_Label 2 to "Rate"
//        Set Form_Width 3 to 180
//        Set Header_Label 3 to "QBItemSalesTaxListID"
//        Set Column_Shadow_State 3 to True
//        
//        
//        // Assign insert-row key append a row
//        // Create new behavior to support append a row
//        On_Key kAdd_Mode Send Append_a_Row  // Hot Key for KAdd_Mode = Shift+F10
//
//        // Add new record to the end of the table.
//        Procedure Append_a_Row 
//            Send End_Of_Data
//            Send Down
//        End_Procedure // Append_a_Row
//        
//    End_Object

    Object oUpdateSalesTaxRate is a Button
        Set Location to 187 385
        Set Label to 'Update'
        Set peAnchors to anBottomRight
    
        // fires when the button is clicked
        Procedure OnClick
            Boolean bSuccess
            //Write Update Procedure to update each line item and add new line items
            Send DoUpdateSalesTax of oQBDataUpdateProcess
            Send MoveToFirstRow of oSalesTaxDbCJGrid
        End_Procedure
    
    End_Object

    Object oSalesTaxDbCJGrid is a cDbCJGrid
        Set Size to 181 442
        Set Ordering to 2
        Set Location to 4 4
        Set peAnchors to anAll
        Set pbHeaderReorders to True
        Set pbHeaderTogglesDirection to True
        Set pbStaticData to True

        Object oSalesTaxGroup_Name is a cDbCJGridColumn
            Entry_Item SalesTaxGroup.Name
            Set piWidth to 313
            Set psCaption to "Group Name"
        End_Object

        Object oSalesTaxGroup_Rate is a cDbCJGridColumn
            Entry_Item SalesTaxGroup.Rate
            Set piWidth to 63
            Set psCaption to "Rate"
            Set pbEditable to False
        End_Object

        Object oSalesTaxGroup_QBItemSalesTaxID is a cDbCJGridColumn
            Entry_Item SalesTaxGroup.QBItemSalesTaxID
            Set piWidth to 275
            Set psCaption to "QBItemSalesTaxID"
            Set pbEditable to False
        End_Object

        Procedure OnBeginningOfPanel Integer hoPanel
            Forward Send OnBeginningOfPanel hoPanel
            Send MoveToFirstRow of oSalesTaxDbCJGrid
        End_Procedure

    End_Object


End_Object // oSalesTax
