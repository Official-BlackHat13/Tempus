Use Windows.pkg
Use DFClient.pkg
Use cRef_HdrGlblDataDictionary.dd
Use cReferencGlblDataDictionary.dd
Use cRef_DtlGlblDataDictionary.dd
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use dfcentry.pkg
Use ListReferences.rv



Deferred_View Activate_oReferenceLists for ;
Object oReferenceLists is a dbView
    Object oReferenc_DD is a cReferencGlblDataDictionary
    End_Object

//Object oCrystalListReferences is a ReportView
//End_Object

    Object oRef_Hdr_DD is a cRef_HdrGlblDataDictionary
    End_Object

    Object oRef_Dtl_DD is a cRef_DtlGlblDataDictionary
        Set DDO_Server to oReferenc_DD
        Set Constrain_file to Ref_Hdr.File_number
        Set DDO_Server to oRef_Hdr_DD
    End_Object

    Set Main_DD to oRef_Hdr_DD
    Set Server to oRef_Hdr_DD

    Set Border_Style to Border_Thick
    Set Size to 287 715
    Set Location to 14 49
    Set Auto_Clear_DEO_State to False

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 51 587
        Set Location to 14 21

        Object oRef_Hdr_Ref_Hdr_Idno is a cGlblDbForm
            Entry_Item Ref_Hdr.Ref_Hdr_Idno
            Set Location to 16 36
            Set Size to 13 65
            Set Label to "Reference Number:"
            Set Label_Col_Offset to 0
            Set Label_Justification_Mode to JMode_Top
            Set Entry_State to False
        End_Object

        Object oRef_Hdr_Description is a cGlblDbForm
            Entry_Item Ref_Hdr.Description
            Set Location to 16 124
            Set Size to 13 306
            Set Label to "Customer/Location Description"
            Set Label_Col_Offset to 0
            Set Label_Justification_Mode to JMode_Top
        End_Object

        Object oDbComboForm1 is a dbComboForm
            Entry_Item Ref_Hdr.SalesRep
            Set Size to 13 100
            Set Location to 17 452
            Set Label to "Sales Rep"
            Set Label_Col_Offset to 0
            Set Label_Justification_Mode to JMode_Top
           
            
    Procedure Combo_Fill_List
      Send Combo_Add_Item "Dave Earls"
      Send Combo_Add_Item "Scott Lewis"
      Send Combo_Add_Item "Andy Marchant"
      Send Combo_Add_Item "OJ Rinehart"
    End_Procedure
            
        End_Object
    End_Object

    Object oDbCJGrid1 is a cDbCJGrid
        Set Server to oRef_Dtl_DD
        Set Size to 169 665
        Set Location to 82 24

        Object oReferenc_ReferenceIdno is a cDbCJGridColumn
            Entry_Item Referenc.ReferenceIdno
            Set piWidth to 64
            Set psCaption to "Reference"
            Set Prompt_Button_Mode to PB_PromptOn
            
             Procedure Prompt
               Integer iCol iRecId

               Get Current_Record of oReferenc_DD to iRecId
                Forward Send Prompt
                             
                    Set Field_Changed_Value of oRef_Dtl_DD Field Ref_Dtl.Company to Referenc.Company
                    Set Field_Changed_Value of oRef_Dtl_DD Field Ref_Dtl.Name    to Referenc.Name                   
                    Set Field_Changed_Value of oRef_Dtl_DD Field Ref_Dtl.Phone   to Referenc.Phone                 
                    Set Field_Changed_Value of oRef_Dtl_DD Field Ref_Dtl.Email   to Referenc.Email 
            
             End_Procedure

        End_Object

        Object oRef_Dtl_Company is a cDbCJGridColumn
            Entry_Item Ref_Dtl.Company
            Set piWidth to 227
            Set psCaption to "Company"
        End_Object

        Object oRef_Dtl_Name is a cDbCJGridColumn
            Entry_Item Ref_Dtl.Name
            Set piWidth to 228
            Set psCaption to "Name"
        End_Object

        Object oRef_Dtl_Phone is a cDbCJGridColumn
            Entry_Item Ref_Dtl.Phone
            Set piWidth to 107
            Set psCaption to "Phone"
        End_Object

        Object oRef_Dtl_Email is a cDbCJGridColumn
            Entry_Item Ref_Dtl.Email
            Set piWidth to 312
            Set psCaption to "Email"
        End_Object

        Object oRef_Dtl_HighLight is a cDbCJGridColumn
            Entry_Item Ref_Dtl.HighLight
            Set piWidth to 59
            Set psCaption to "Highlight"
            Set pbCheckbox to True
        End_Object
    End_Object

    Object oButton1 is a Button
        Set Location to 49 641
        Set Label to 'Print List'
        Set psToolTip to "Print List"
    
        Procedure OnClick
          Send DoPrintReference
        End_Procedure
    
    End_Object

    Object oButton2 is a Button
        Set Location to 15 641
        Set Label to 'Clone List'
    
        // fires when the button is clicked
     Procedure OnClick
         Send DoCloneRef_List   
        End_Procedure
//    
    End_Object

    Procedure DoPrintReference   
        Boolean bCancel
        Integer iRefId
        //
        Get Field_Current_Value of oRef_Hdr_DD Field Ref_Hdr.Ref_Hdr_Idno to iRefId
        Get Confirm ("Print Reference List" * String(iRefId) + "?")       to bCancel
        If (not(bCancel)) Begin
            Send DoJumpStartReport of ListReferences iRefId
                          End       
    End_Procedure

    Procedure DoCloneRef_List
        Boolean bCancel
        Integer iRef_Hdr_Idno iRef_Dtl_Idno iHdrRecId iDtlRecId 
        
        Get Confirm "Clone Reference List" to bCancel
            If (not(bCancel)) Begin
                Move Ref_Hdr.Ref_Hdr_Idno to iRef_Hdr_Idno
                
                Send ChangeAllFileModes DF_FILEMODE_READONLY
                Set_Attribute DF_FILE_MODE of System.File_Number  to DF_FILEMODE_DEFAULT
                Set_Attribute DF_FILE_MODE of Ref_Hdr.File_Number to DF_FILEMODE_DEFAULT
                Set_Attribute DF_FILE_MODE of Ref_Dtl.File_Number to DF_FILEMODE_DEFAULT
                
                Reread
                Add 1 to System.CrewId
                SaveRecord System
                
                Move 0 to Ref_Hdr.Recnum
                Move System.CrewId to Ref_Hdr.Ref_Hdr_Idno
                SaveRecord Ref_Hdr
                Unlock 
                
                Reread
                Add 1 to System.CrewMemberId
                SaveRecord System
                Unlock
                
          Move Ref_Hdr.Recnum to iHdrRecId
           
           If (iHdrRecId <> 0) Begin
            Clear Ref_Dtl
            Move iRef_Hdr_Idno to Ref_Dtl.Ref_Hdr_Idno
            Find ge Ref_Dtl.Ref_Hdr_Idno
            While ((Found) and Ref_Dtl.Ref_Hdr_Idno=iRef_Hdr_Idno)
            
            Move Ref_Dtl.Recnum to iDtlRecId
           
                   
            Move 0 to Ref_Dtl.Recnum
            Move System.CrewMemberId to Ref_Dtl.Ref_Dtl_idno
            Move System.CrewId to Ref_Dtl.Ref_Hdr_Idno
            SaveRecord Ref_Dtl
            Unlock
            
            Clear Ref_Dtl
            Move iDtlRecId to Ref_Dtl.Recnum
            Find eq Ref_Dtl.Recnum
            Find gt Ref_Dtl.Ref_Hdr_Idno
            
            Loop
            Send Clear_All of oRef_Hdr_DD
            Send Find_By_Recnum of oRef_hdr_DD Ref_Hdr.File_Number iHdrRecId
            End
            
           Send ChangeAllFileModes DF_FILEMODE_DEFAULT
           End
              
    
    End_Procedure

    Procedure Request_Delete
    End_Procedure

  

Cd_End_Object
