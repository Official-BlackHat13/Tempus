// Project.sl
// Project Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use cProjectDataDictionary.dd

Object Project_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 278
    Set Label To "Project Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Property Integer piSelected
    Property Integer piCustIdno
    Property Integer piRepIdno
    Property Boolean pbSelected
    Property Boolean pbHasCust
    Property Boolean pbHasRep
    Property Boolean pbCanceled

    Object oProject_DD is a cProjectDataDictionary
    End_Object // oProject_DD

    Set Main_DD To oProject_DD
    Set Server  To oProject_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 268
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Project_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oProject_ProjectId is a cDbCJGridColumn
            Entry_Item Project.ProjectId
            Set piWidth to 84
            Set psCaption to "ProjectId"
        End_Object // oProject_ProjectId

        Object oProject_Description is a cDbCJGridColumn
            Entry_Item Project.Description
            Set piWidth to 262
            Set psCaption to "Description"
        End_Object // oProject_Description

        Object oProject_CreatedDate is a cDbCJGridColumn
            Entry_Item Project.CreatedDate
            Set piWidth to 105
            Set psCaption to "CreatedDate"
        End_Object // oProject_CreatedDate


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 115
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 169
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 223
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn

    Function DoProjectPrompt Integer ByRef iProjectIdno Integer iCustomerIdno Integer iSalesRepIdno Returns Boolean
        Boolean bCancel
        String[] SelectionValues

        // with non-invoking lists we store and restore the defaults manually
        Send OnStoreDefaults of oSelList
        //
        Set Locate_Mode to CENTER_ON_PANEL
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set piUpdateColumn of oSelList to 0 //Project#
        Set psSeedValue of oSelList to iProjectIdno
        //
        Send Popup
        //
        Send OnRestoreDefaults of oSelList
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Get SelectedColumnValues of oSelList 0 to SelectionValues
            If (SizeOfArray(SelectionValues)) Begin
                Move SelectionValues[0] to iProjectIdno
                Function_Return True
            End
        End
        Function_Return False
    End_Function

End_Object // Project_sl
