// Z:\VDF17.0 Workspaces\Tempus\AppSrc\Project.vw
// Project
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use Windows.pkg
Use cDbCJGrid.pkg
Use cProjectDataDictionary.dd

Activate_View Activate_oProject for oProject
Object oProject is a cGlblDbView
    Object oProject_DD is a cProjectDataDictionary
    End_Object

    Set Main_DD to oProject_DD
    Set Server to oProject_DD

    Set Location to 5 4
    Set Size to 59 448
    Set Label To "Project"
    Set Border_Style to Border_Thick



    Object oProjectDescription is a cGlblDbForm
        Entry_Item Project.Description
        Set Size to 13 223
        Set Location to 5 123
        Set peAnchors to anTopLeftRight
        Set Label to "Description"
        Set Label_Justification_mode to jMode_right
        Set Label_Col_Offset to 2
        Set Label_row_Offset to 0

        Procedure Refresh Integer notifyMode
            Forward Send Refresh notifyMode
            Boolean bLockedState
            Integer iCustIdno iSalesRepIdno
            // check on locked State
            Move Project.LockedFlag to bLockedState
            If (bLockedState) Begin
                Set Bitmap of oLockStateButton to "locked.bmp"
            End
            Else Begin
                Set Bitmap of oLockStateButton to "unlocked.bmp"
            End
            Set Enabled_State of oProjectDescription to (not(bLockedState))
            Set Enabled_State of oProject_CustomerIdno to (not(bLockedState))
            Set Enabled_State of oProjectRepIdno to (not(bLockedState))
            // update names on Customer and SalesRep
            Move Project.CustomerIdno to iCustIdno
            Move Project.RepIdno to iSalesRepIdno
            Clear Customer
            Move iCustIdno to Customer.CustomerIdno
            Find EQ Customer.CustomerIdno
            If (Found) Set Value of oCustomerNameForm to Customer.Name
            Clear SalesRep
            Move iSalesRepIdno to SalesRep.RepIdno
            Find EQ SalesRep.RepIdno
            If (Found) Set Value of oSalesRepForm to (SalesRep.FirstName * SalesRep.LastName)
        End_Procedure
    End_Object // oProjectDescription

    Object oProjectCreatedDate is a cGlblDbForm
        Entry_Item Project.CreatedDate
        Set Size to 13 66
        Set Location to 5 377
        Set peAnchors to anRight
        Set Label to "Created"
        Set Label_Justification_mode to jMode_right
        Set Label_Col_Offset to 2
        Set Label_row_Offset to 0
        Set Enabled_State to False
        Set Entry_State to False
    End_Object // oProjectCreatedDate

    Object oLockStateButton is a Button
        Set Size to 15 17
        Set Location to 25 398
        Set Label to ''
        Set Bitmap to "unlocked.bmp"
        Set peAnchors to anTopRight
    
        // fires when the button is clicked
        Procedure OnClick
            Boolean bProjectLockStatus bHasRecord bShouldSave
            //
            Get Field_Current_Value of oProject_DD Field Project.LockedFlag to bProjectLockStatus
            Set Field_Changed_Value of oProject_DD Field Project.LockedFlag to (not(bProjectLockStatus))                
            Get HasRecord of oProject_DD to bHasRecord
            Get Should_Save of oProject_DD to bShouldSave
            If (bHasRecord and bShouldSave) Begin
                Send Request_Save of oProject_DD
            End
        End_Procedure
    
    End_Object

    Object oProject_CustomerIdno is a cGlblDbForm
        Entry_Item Project.CustomerIdno
        Set Location to 20 41
        Set Size to 13 41
        Set Label to "Customer"
        Set Prompt_Button_Mode to PB_PromptOn
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
        
        Procedure Prompt
            Integer iCustIdno
            Boolean bSucces
            Get Field_Current_Value of oProject_DD Field Project.CustomerIdno to iCustIdno
            //Move Project.CustomerIdno to iCustIdno
            Get IsSelectedCustomer of Customer_sl (&iCustIdno) to bSucces
            If (bSucces) Begin
                Move iCustIdno to Project.CustomerIdno
                Set Field_Changed_Value of oProject_DD Field Project.CustomerIdno to iCustIdno   
                Send Request_Save of oProject_DD 
            End
        End_Procedure
    End_Object

    Object oProjectRepIdno is a cGlblDbForm
        Entry_Item Project.RepIdno
        Set Size to 13 41
        Set Location to 35 41
        Set Label to "Sales Rep"
        Set Label_Justification_mode to jMode_right
        Set Label_Col_Offset to 5
        Set Label_row_Offset to 0
        Set Prompt_Button_Mode to PB_PromptOn
        
        Procedure Prompt
            Integer iRepIdno
            String sRepName
            Boolean bSuccess
            Get Field_Current_Value of oProject_DD Field Project.RepIdno to iRepIdno
            Get IsSelectedSalesRep of SalesRep_sl (&iRepIdno) (&sRepName) to bSuccess
            If (bSuccess) Begin
                Set Field_Changed_Value of oProject_DD Field Project.RepIdno to iRepIdno
                Send Request_Save of oProject_DD
            End
        End_Procedure
    End_Object // oProjectRepIdno

    Object oCustomerNameForm is a Form
        Set Size to 13 262
        Set Location to 20 85
        Set peAnchors to anTopLeftRight
        Set Enabled_State to False
        Set Entry_State to False
    
        //OnChange is called on every changed character
    
        //Procedure OnChange
        //    String sValue
        //
        //    Get Value to sValue
        //End_Procedure
    
    End_Object

    Object oSalesRepForm is a Form
        Set Size to 13 262
        Set Location to 35 85
        Set peAnchors to anTopLeftRight
        Set Entry_State to False
        Set Enabled_State to False
    
        //OnChange is called on every changed character
    
        //Procedure OnChange
        //    String sValue
        //
        //    Get Value to sValue
        //End_Procedure
    
    End_Object

    Object oProject_ProjectId is a cGlblDbForm
        Entry_Item Project.ProjectId
        Set Location to 5 41
        Set Size to 13 41
        Set Label to "ProjectId:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
    End_Object


End_Object // oProject
