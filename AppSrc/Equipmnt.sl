// Equipmnt.sl
// Equipmnt Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Employer.DD
Use MastOps.DD
Use Equipmnt.DD
Use Customer.DD
Use Areas.DD
Use Location.DD
Use Opers.DD
Use cWorkTypeGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd

Object Equipmnt_sl is a cGlblDbModalPanel
    
    Property Boolean pbCanceled
    Property Boolean pbSelected
    Property Integer piSelected
    Property Boolean pbEquipId
    Property Integer piEquipId
    Property Integer piEmployerIdno
    Property String psAttachCat
    
    
    Set Location to 5 5
    Set Size to 189 290
    Set Label To "Equipmnt Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object


    Object oEmployer_DD is a Employer_DataDictionary
    End_Object // oEmployer_DD

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
        
        Procedure OnConstrain
            If (psAttachCat(Self) <> "") Begin
                Constrain MastOps.IsAttachment eq (psAttachCat(Self))
            End
        End_Procedure
        
    End_Object // oMastOps_DD

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Object oEquipmnt_DD is a Equipmnt_DataDictionary
        Set DDO_Server To oMastOps_DD
        Set DDO_Server to oEmployer_DD
        
        Procedure OnConstrain
            If (piEmployerIdno(Self) >0) Begin
                Constrain Equipmnt.OperatedBy eq (piEmployerIdno(Self))
            End
            //Status
            If (not(Checked_State(oActiveEquipmentCheckBox(Self)))) Constrain Equipmnt.Status ne "A"
            If (not(Checked_State(oInactiveEquipmentCheckBox(Self)))) Constrain Equipmnt.Status ne "I"
            //            
        End_Procedure
        
    End_Object // oEquipmnt_DD

    Set Main_DD To oEquipmnt_DD
    Set Server  To oEquipmnt_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 153 280
        Set Location to 4 6
        Set peAnchors to anAll
        //Set psLayoutSection to "Equipmnt_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True
        Set peRequestFindMode to rfmFindAll

        Object oEquipmnt_EquipIdno is a cDbCJGridColumn
            Entry_Item Equipmnt.EquipIdno
            Set piWidth to 72
            Set psCaption to "EquipIdno"
        End_Object

        Object oEquipmnt_Description is a cDbCJGridColumn
            Entry_Item Equipmnt.Description
            Set piWidth to 212
            Set psCaption to "Description"
        End_Object // oEquipmnt_Description

        Object oEmployer_Name is a cDbCJGridColumn
            Entry_Item Employer.Name
            Set piWidth to 278
            Set psCaption to "Owner/Employer"
        End_Object // oEmployer_Name


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 170 127
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 170 181
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 170 235
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure
    End_Object // oSearch_bn

    Function DoEquipPromptwEmployer Integer ByRef iEquipIdno Integer iEmployerIdno Returns Boolean
        Boolean bCancel
        String[] SelectionValues
        
        // with non-invoking lists we store and restore the defaults manually
        Send OnStoreDefaults of oSelList
        //
        Set Locate_Mode to CENTER_ON_PANEL
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set piUpdateColumn of oSelList to 0
        Set psSeedValue of oSelList to iEquipIdno
        
        If (iEmployerIdno<>0) Begin
            Set piEmployerIdno to iEmployerIdno  
            Send Rebuild_Constraints of oEquipmnt_DD
        End
        //
        Send Popup
        //
        Send OnRestoreDefaults of oSelList
        //
        If (iEmployerIdno<>0) Begin
            Set piEmployerIdno to 0
            Send Rebuild_Constraints of oEquipmnt_DD
        End
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Get SelectedColumnValues of oSelList 0 to SelectionValues
            If (SizeOfArray(SelectionValues)) Begin
                Move SelectionValues[0] to iEquipIdno
                Function_Return True
            End
        End
        Function_Return False
    End_Function
    
    Function DoAttachPromptwEmployer Integer ByRef iAttachIdno Integer iEmployerIdno String sAttachCat Returns Boolean
        Boolean bCancel
        String[] SelectionValues
        
        // with non-invoking lists we store and restore the defaults manually
        Send OnStoreDefaults of oSelList
        //
        Set Locate_Mode to CENTER_ON_PANEL
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Set piUpdateColumn of oSelList to 0
        Set psSeedValue of oSelList to iAttachIdno
        
        If (iEmployerIdno<>0) Begin
            Set piEmployerIdno to iEmployerIdno
        End
        If (sAttachCat<>"") Begin
            Set psAttachCat to sAttachCat
        End
        //
        Send Rebuild_Constraints of oEquipmnt_DD
        //
        Send Popup
        //
        Send OnRestoreDefaults of oSelList
        //
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Get SelectedColumnValues of oSelList 0 to SelectionValues
            If (SizeOfArray(SelectionValues)) Begin
                Move SelectionValues[0] to iAttachIdno
                Function_Return True
            End
        End
        Function_Return False
    End_Function
    
    Function DoEquipPrompt Returns Integer  
        
        Set peUpdateMode of oSelList to umPromptNonInvoking
        Send OnStoreDefaults of oSelList
        
        Boolean bCancel
        Integer iEquipIdno
        //
        Send Popup_Modal
        //        
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Move Equipmnt.EquipIdno to iEquipIdno
        End
        If bCancel Begin
            Move 0 to iEquipIdno
        End
        //
        Function_Return (iEquipIdno)
    End_Function
    
    Function AttachmentSelection Integer iEmployerIdno String sAttachCat Returns Integer        
        Integer iAttachmentIdno
        String sEquipIdno
        Boolean bCancel
        Send OnStoreDefaults of oSelList
        Set peUpdateMode of oSelList to umPromptNonInvoking
//        // Adjust view size and sellist size
//        Set Size of Equipmnt_sl to 160 350
//        Set Size of oSelList to 150 300
//        // Hide unused columns
//        Set piWidth of oEquipmnt_Description to 100
//        Set piWidth of oEquipmnt_EquipIdno to 0
//        Set piWidth of oEmployer_Name to 100
//        Set piWidth of oEquipmnt_ContractorRate to 100
//        Set piWidth of oMastOps_Name to 0
        
        
        Set piEmployerIdno to iEmployerIdno
        Set psAttachCat to sAttachCat
        Send Rebuild_Constraints of oEquipmnt_DD
        Send Popup
        Get pbCanceled of oSelList to bCancel
        If not bCancel Begin
            Move Equipmnt.EquipIdno to sEquipIdno
        End
        Else Move "0" to sEquipIdno
        Send OnRestoreDefaults of oSelList
        Set psAttachCat to ""
        Set piEmployerIdno to 0
        Function_Return (sEquipIdno)
    End_Function

    Object oStatusGroup is a Group
        Set Size to 25 93
        Set Location to 159 7
        Set Label to 'Status'

        Object oActiveEquipmentCheckBox is a CheckBox
            Set Size to 10 38
            Set Location to 11 12
            Set Label to 'Active'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oEquipmnt_DD
                Send MovetoFirstRow of oSelList
            End_Procedure
        End_Object

        Object oInactiveEquipmentCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 11 49
            Set Label to 'Inactive'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oEquipmnt_DD
                Send MovetoFirstRow of oSelList
            End_Procedure
        
        End_Object
    End_Object

End_Object // Equipmnt_sl
