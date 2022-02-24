// WebAppUserRights.sl
// WebAppUserRights Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cWebAppUserRightsGlblDataDictionary.dd
Use Windows.pkg

Object WebAppUserRights_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 213
    Set Label To "WebAppUserRights Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False
        
    Property Integer[] paiSelectionValues
    Property Integer piIdleCount
    
    Object oWebAppUserRights_DD is a cWebAppUserRightsGlblDataDictionary
    End_Object 

    Set Main_DD To oWebAppUserRights_DD
    Set Server  To oWebAppUserRights_DD

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

    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 203
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "WebAppUserRights_sl_oSelList"
        Set Ordering to 0
        Set pbMultipleSelection to False
        Set pbAutoServer to True
        Set pbStaticData to True

        Object oWebAppUserRights_RightLevel is a cDbCJGridColumn
            Entry_Item WebAppUserRights.RightLevel
            Set piWidth to 75
            Set psCaption to "Right Level"
        End_Object 

        Object oWebAppUserRights_Description is a cDbCJGridColumn
            Entry_Item WebAppUserRights.Description
            Set piWidth to 262
            Set psCaption to "Description"
        End_Object 

        Procedure LoadData 
            Handle hoDataSource 
            Boolean bFound
            Integer iRows
            tDataSourceRow[] TheData
        
            Get phoDataSource to hoDataSource
            
            Clear WebAppUserRights
            Find ge WebAppUserRights by Index.1
            Move (Found) to bFound
            While bFound
                // creates a datasourcerow based on current buffer data
                Get CreateDataSourceRow of hoDataSource to TheData[iRows]
                Increment iRows
                Find gt WebAppUserRights by Index.1
                Move (Found) to bFound
            Loop
            Send InitializeData TheData
            //Send MovetoFirstRow
        End_Procedure
        
        Procedure OnIdle
            Forward Send OnIdle
            Integer iIdleCount
            Get piIdleCount of WebAppUserRights_sl to iIdleCount
            If (iIdleCount<1) Begin
                Integer[] aiSelectionValues aiSelectionIndexes
                Get paiSelectionValues of WebAppUserRights_sl to aiSelectionValues
                If ((SizeOfArray(aiSelectionValues)-1)>0) Begin
                    tDataSourceRow[] tGridDataSource
                    Handle hoDataSource
                    Integer i iGrid iRowId
                    // Set Selected Rows based on submitted selection values
                    Send SetSelectedRowsAll of oSelList False
                    Get phoDataSource of oSelList to hoDataSource
                    Get DataSource of hoDataSource to tGridDataSource
                    For i from 0 to (SizeOfArray(aiSelectionValues)-1)
                        //Find and Replace Column value with row value from DataSource
                        For iGrid from 0 to (SizeOfArray(tGridDataSource)-1)
                            If (tGridDataSource[iGrid].sValue[0]=aiSelectionValues[i]) Begin
                                Move iGrid to aiSelectionIndexes[i]
                                //Send SetSelectedRow iGrid True
                            End
                        Loop
                    Loop
                    Send SetSelectedRowsAll of oSelList False
                    Send SetIndexesForSelectedRows of oSelList aiSelectionIndexes
                    //Get GetIndexesForSelectedRows of oSelList to aiSelectionIndexes
                End
                //
                Increment iIdleCount
                Set piIdleCount of WebAppUserRights_sl to iIdleCount
            End
        End_Procedure
        
    End_Object 

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 50
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object 

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 104
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object 

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 158
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object 

    Object oButton1 is a Button
        Set Size to 14 39
        Set Location to 115 4
        Set Label to 'Reset'
        Set peAnchors to anBottomRight
    
        // fires when the button is clicked
        Procedure OnClick
            Integer[] aiSelectionValues aiSelectionIndexes
            Get paiSelectionValues of WebAppUserRights_sl to aiSelectionValues
            If ((SizeOfArray(aiSelectionValues)-1)>0) Begin
                tDataSourceRow[] tGridDataSource
                Handle hoDataSource
                Integer i iGrid iRowId
                // Set Selected Rows based on submitted selection values
                Get phoDataSource of oSelList to hoDataSource
                Get DataSource of hoDataSource to tGridDataSource
                For i from 0 to (SizeOfArray(aiSelectionValues)-1)
                    //Find and Replace Column value with row value from DataSource
                    For iGrid from 0 to (SizeOfArray(tGridDataSource)-1)
                        If (tGridDataSource[iGrid].sValue[0]=aiSelectionValues[i]) Begin
                            Move iGrid to aiSelectionIndexes[i]
                            //Send SetSelectedRow iGrid True
                        End
                    Loop
                Loop
                Send SetSelectedRowsAll of oSelList False
                Send SetIndexesForSelectedRows of oSelList aiSelectionIndexes
                //Get GetIndexesForSelectedRows of oSelList to aiSelectionIndexes
            End
        End_Procedure
    
    End_Object

    Procedure Closing_View
        Forward Send Closing_View
        Set piIdleCount of WebAppUserRights_sl to 0
    End_Procedure

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn
    On_Key Key_Ctrl+Key_F Send KeyAction of oSearch_bn


End_Object // WebAppUserRights_sl
