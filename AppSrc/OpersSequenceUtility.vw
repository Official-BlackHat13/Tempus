Use Windows.pkg
Use DFClient.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use MastOps.DD
Use Opers.DD
Use cWorkTypeGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd
Use cDivisionMgrGlblDataDictionary.dd
Use dfTable.pkg

Deferred_View Activate_oOpersSequenceUtility for ;
Object oOpersSequenceUtility is a dbView
    Object oDivisionMgr_DD is a cDivisionMgrGlblDataDictionary
    End_Object

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oWorkType_DD is a cWorkTypeGlblDataDictionary
        Set DDO_Server to oDivisionMgr_DD
    End_Object

    Object oMastOps_DD is a Mastops_DataDictionary
        Set DDO_Server to oWorkType_DD
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOpers_DD is a Opers_DataDictionary
        Set DDO_Server to oMastOps_DD
        Set DDO_Server to oLocation_DD        
    End_Object

    Set Main_DD to oOpers_DD
    Set Server to oOpers_DD

    Set Border_Style to Border_Thick
    Set Size to 351 347
    Set Location to 2 219

    Object oButton1 is a Button
        Set Size to 14 104
        Set Location to 337 121
        Set Label to 'RUN'
        

        
    
        // fires when the button is clicked
        Procedure OnClick
            Boolean bCancel
            Integer iOpersCount            
            Move 0 to iOpersCount
            Open Opers
            Constraint_Set 1
            Constrain Opers.DisplaySequence eq 0
            Constrained_Find First Opers by 7
            
            Get Confirm ("Are you sure you want to resequence?") to bCancel
                If (bCancel) Begin
                    Procedure_Return
                End
            
            While (Found)
                Increment iOpersCount
                Reread Opers
                Move "99" to Opers.DisplaySequence
                SaveRecord Opers
                Unlock
                Constrained_Find First Opers by 7
            Loop
            
            Send Info_Box ("Successfully resequenced" * String(iOpersCount) * "Opers.")
        End_Procedure
    
    End_Object

    Object oTextBox1 is a TextBox
        Set Size to 10 260
        Set Location to 320 48
        Set Label to 'This Utility finds any Operation with a sequence number = 0 and changes it to 99'
      
        Procedure testDateGetDayofWeek

    DateTime dtVar

 

    //Get the current local date and time

    Move (CurrentDateTime()) to dtVar

    Showln "The day of week of " dtvar " is: " (DateGetDayOfWeek(dtVar))

End_Procedure

    End_Object

    Object oDbGrid1 is a dbGrid
        Set Size to 300 200
        Set Location to 12 30

        Begin_Row
            Entry_Item Opers.OpersIdno
            Entry_Item Opers.DisplaySequence
        End_Row

        Set Main_File to Opers.File_Number

        Set Form_Width 0 to 48
        Set Header_Label 0 to "OpersIdno"
        Set Form_Width 1 to 68
        Set Header_Label 1 to "DisplaySequence"
    End_Object

    Object oTextBox2 is a TextBox
        Set Size to 10 50
        Set Location to 30 257
        Set Label to 'oTextBox2'
    End_Object

Cd_End_Object
