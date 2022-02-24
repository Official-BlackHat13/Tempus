// WebAppUserRights.sl
// WebAppUserRights Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cWebAppUserRightsGlblDataDictionary.dd

CD_Popup_Object WebAppUserRights_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 224
    Set Label To "WebAppUserRights Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
    End_Object 

    Set Main_DD To oWebAppUserRights_DD
    Set Server  To oWebAppUserRights_DD

    Property Integer[] paiSelectionValues
    Property Integer piIdleCount

    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 214
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "WebAppUserRights_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oWebAppUserRights_Description is a cDbCJGridColumn
            Entry_Item WebAppUserRights.Description
            Set piWidth to 276
            Set psCaption to "Description"
        End_Object 

        Object oWebAppUserRights_RightLevel is a cDbCJGridColumn
            Entry_Item WebAppUserRights.RightLevel
            Set piWidth to 80
            Set psCaption to "Right Level"
        End_Object 


    End_Object 

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 61
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object 

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 115
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object 

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 169
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object 

    // This would be added to the prompt list's panel object.
    Function GetWebAppUserRights String sSeed String ByRef sRights Returns Boolean
        Boolean bCancel
        String[] SelectionValues
        
         // with non-invoking lists we store and restore the defaults manually
        Send OnStoreDefaults of oSelList
        
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set piUpdateColumn of oSelList to 0 //Rights Value
        Set psSeedValue of oSelList to sSeed
    
        Send Popup
        
        Send OnRestoreDefaults of oSelList
        
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Get SelectedColumnValues of oSelList 1 to SelectionValues
            If (SizeOfArray(SelectionValues)) Begin
                Move SelectionValues[0] to sRights
                Function_Return False
            End
        End
        Function_Return True
    End_Function

    Function GetMultipleWebAppUserRights Boolean bAllowMultiSelect String[] ByRef asSelectionValues Returns Boolean
        Boolean bCancel
        Integer i
        Integer[] aiSelectionValues
        // with non-invoking lists we store and restore the defaults manually
        Send OnStoreDefaults of oSelList
        //
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set pbStaticData of oSelList to True
        Set piUpdateColumn of oSelList to 0 //Rights Value    
        Set pbMultipleSelection of oSelList to bAllowMultiSelect
        //Set pbInitialSelectionEnable of oSelList to True
        // Set Selected Rows based on submitted selection values
        For i from 0 to (SizeOfArray(asSelectionValues)-1)
            Move asSelectionValues[i] to aiSelectionValues[i]
        Loop
        Set paiSelectionValues of WebAppUserRights_sl to aiSelectionValues
        //Send SetIndexesForSelectedRows of oSelList aiSelectionValues
        Send Popup
        
        Send OnRestoreDefaults of oSelList
        
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Get SelectedColumnValues of oSelList 0 to asSelectionValues
            If (SizeOfArray(asSelectionValues)) Begin
                Function_Return False   
            End
        End
        Function_Return True
    End_Function
    
    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // WebAppUserRights_sl
