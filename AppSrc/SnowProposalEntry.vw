Use Windows.pkg
Use DFClient.pkg
Use cGlblDbForm.pkg
Use dfTabDlg.pkg
Use cDbCJGrid.pkg
Use SnowPerTime.rv
Use SnowSeasonal.rv
Use dfLine.pkg
Use SnowTM.rv
Use SnowSpec.rv
Use SnowPerTimeNoWalks.rv
Use SnowSeasonalNoWalks.rv
Use SnowTMNoWalks.rv
Use SnowProposalCover.rv
Use Customer.DD
Use SalesRep.DD
Use Areas.DD
Use cSalesTaxGroupGlblDataDictionary.dd
Use Location.DD
Use cPropHdrGlblDataDictionary.dd
Use cPropDtlGlblDataDictionary.dd

Deferred_View Activate_oSnowProposalEntry for ;
Object oSnowProposalEntry is a dbView
    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oprophdr_DD is a cPropHdrGlblDataDictionary
        Set DDO_Server to oLocation_DD
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object opropdtl_DD is a cPropDtlGlblDataDictionary
        Set Constrain_file to prophdr.File_number
        Set DDO_Server to oprophdr_DD
    End_Object

    Set Main_DD to oprophdr_DD
    Set Server to oprophdr_DD

    Set Border_Style to Border_Thick
    Set Size to 362 381
    Set Location to 25 191
    Set Auto_Clear_DEO_State to False

    Object oDbContainer3d1 is a dbContainer3d
        Set Size to 107 349
        Set Location to 12 15

        Object oPropHdr_PropHdr_Idno is a cGlblDbForm
            Entry_Item PropHdr.PropHdr_Idno
            Set Location to 11 113
            Set Size to 13 54
            Set Label to "Proposal#:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Entry_State to False
        End_Object

        Object oSalesRep_LastName is a cGlblDbForm
            Entry_Item SalesRep.LastName
            Set Location to 11 215
            Set Size to 13 81
            Set Label to "Sales Rep:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            Set Entry_State to False
        End_Object

        Object oCustomer_Name is a cGlblDbForm
            Entry_Item Customer.Name
            Set Server to oLocation_DD
            Set Location to 29 113
            Set Size to 13 183
            Set Label to "Customer:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oPropHdr_AltCust_Name is a cGlblDbForm
            Entry_Item PropHdr.AltCust_Name
            Set Location to 46 113
            Set Size to 13 182
            Set Label to "Alternate Customer Name:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            
        End_Object

        Object oPropHdr_NameOnCover is a cGlblDbForm
            Entry_Item PropHdr.NameOnCover
            Set Location to 63 113
            Set Size to 13 182
            Set Label to "Contact Name on Cover:"
             Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object

        Object oPropHdr_PropCont_Name1 is a cGlblDbForm
            Entry_Item PropHdr.PropCont_Name
            Set Location to 79 113
            Set Size to 13 182
            Set Label to "Letter Salutation Name:"
            Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
        End_Object
    End_Object

    Object oDbTabDialog1 is a dbTabDialog
        Set Size to 154 349
        Set Location to 127 15
    
        Set Rotate_Mode to RM_Rotate

        Object oDbTabPage1 is a dbTabPage
            Set Label to 'Proposal/Contract'

            Object oLocation_Name is a cGlblDbForm
                Entry_Item Location.Name
                
                Procedure Prompt_Callback Integer hPrompt
                    Set Auto_Server_State of hPrompt to True
                End_Procedure

                Set Server to oLocation_DD
                Set Location to 12 99
                Set Size to 13 199
                Set Label to "Location:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
                Set Entry_State to False
                Set Auto_Clear_DEO_State to False
            End_Object

            Object oPropHdr_AltLocatio_Name is a cGlblDbForm
                Entry_Item PropHdr.AltLocatio_Name
                Set Location to 28 99
                Set Size to 13 199
                Set Label to "Alternate Location Name:"
                Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object

           
            Object oLocation_Address1 is a cGlblDbForm
                Entry_Item Location.Address1

                Set Server to oLocation_DD
                Set Location to 44 99
                Set Size to 13 199
                Set Label to "Street Address:"
                Set Prompt_Button_Mode to PB_PromptOff
            End_Object

            Object oLocation_City is a cGlblDbForm
                Entry_Item Location.City

                Set Server to oLocation_DD
                Set Location to 61 99
                Set Size to 13 95
                Set Label to "City/State/Zip:"
                Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oLocation_State is a cGlblDbForm
                Entry_Item Location.State

                Set Server to oLocation_DD
                Set Location to 61 199
                Set Size to 13 24
                //Set Label to "State:"
            End_Object

            Object oLocation_Zip is a cGlblDbForm
                Entry_Item Location.Zip

                Set Server to oLocation_DD
                Set Location to 61 229
                Set Size to 13 66
                //Set Label to "Zip:"
            End_Object
     
      Object oPropHdr_Walk_Trigger is a cGlblDbForm
                Entry_Item PropHdr.Walk_Trigger
                Set Location to 78 99
                Set Size to 13 42
                Set Label to "Walk Trigger:"
                 Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oPropHdr_Plow_Trigger is a cGlblDbForm
                Entry_Item PropHdr.Plow_Trigger
                Set Location to 78 198
                Set Size to 13 42
                Set Label to "Plow Trigger:"
                 Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object

     
        End_Object
        
        
        
        Object oDbTabPage3 is a dbTabPage
            Set Label to 'Per-Time Detail'

            Object oDbCJGrid1 is a cDbCJGrid
                Set Server to oPropDtl_DD
                Set Size to 100 312
                Set Location to 10 16

                Object oPropDtl_SnowDepth is a cDbCJGridColumn
                    Entry_Item PropDtl.SnowDepth
                    Set piWidth to 105
                    Set psCaption to "Snow Depth"
                    Set peTextAlignment to xtpAlignmentCenter
                End_Object

                Object oPropDtl_PlowPrice is a cDbCJGridColumn
                    Entry_Item PropDtl.PlowPrice
                    Set piWidth to 71
                    Set psCaption to "Plow Price"
                    Set peTextAlignment to xtpAlignmentCenter
                End_Object

                Object oPropDtl_ShovelPrice is a cDbCJGridColumn
                    Entry_Item PropDtl.ShovelPrice
                    Set piWidth to 88
                    Set psCaption to "Shovel Price"
                    Set peTextAlignment to xtpAlignmentCenter
                End_Object

                Object oPropDtl_DeicePrice is a cDbCJGridColumn
                    Entry_Item PropDtl.DeicePrice
                    Set piWidth to 101
                    Set psCaption to "Salt App. Price"
                    Set peTextAlignment to xtpAlignmentCenter
                End_Object

                Object oPropDtl_SideWalkDeice is a cDbCJGridColumn
                    Entry_Item PropDtl.SideWalkDeice
                    Set piWidth to 103
                    Set psCaption to "Sidewalk Deice"
                    Set peTextAlignment to xtpAlignmentCenter
                End_Object
            End_Object

            Object oPropHdr_PerTimePriceValid is a cGlblDbForm
                Entry_Item PropHdr.PerTimePriceValid
                Set Location to 118 76
                Set Size to 13 250
                Set Label to "Pricing Valid For:"
                           Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
                
            End_Object
        End_Object

        Object oDbTabPage2 is a dbTabPage
            Set Label to 'Seasonal Detail'

            Object oPropHdr_PriceValid is a cGlblDbForm
                Entry_Item PropHdr.PriceValid
                Set Location to 15 82
                Set Size to 13 250
                Set Label to "Pricing Valid For:"
                Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oPropHdr_SeasonalPayment is a cGlblDbForm
                Entry_Item PropHdr.SeasonalPayment
                Set Location to 33 82
                Set Size to 13 66
                Set Label to "Monthly Payment:"
                Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oPropHdr_SeasonFirstPay is a cdbszDatePicker
                Entry_Item PropHdr.SeasonFirstPay
                Set Location to 51 82
                Set Size to 13 66
                Set Label to "First Payment Due:"
                     Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object
        End_Object
        
        Object oDbTabPage4 is a dbTabPage
            Set Label to 'T/M Details'

            Object oPropHdr_TMPriceValid is a cGlblDbForm
                Entry_Item PropHdr.TMPriceValid
                Set Location to 19 73
                Set Size to 13 250
                Set Label to "Pricing Valid For:"
                  Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
                
            End_Object
        End_Object

        Object oDbTabPage3 is a dbTabPage
            Set Label to 'Unsolicited Details'

            Object oPropHdr_ProspectCoName is a cGlblDbForm
                Entry_Item PropHdr.ProspectCoName
                Set Location to 9 86
                Set Size to 13 200
                Set Label to "Company Name:"
                 Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object
            
            Object oPropHdr_PropCont_Name is a cGlblDbForm
                Entry_Item PropHdr.PropCont_Name
                Set Location to 25 86
                Set Size to 13 200
                Set Label to "Salutation Name:"
                Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object
            
            Object oPropHdr_PropSite_Name is a cGlblDbForm
                Entry_Item PropHdr.PropSite_Name
                Set Location to 40 86
                Set Size to 13 200
                Set Label to "Prospect Site:"
                Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object
          
             Object oPropHdr_ProspectSqFt is a cGlblDbForm
                Entry_Item PropHdr.ProspectSqFt
                Set Location to 55 86
                Set Size to 13 54
                Set Label to "Site Sq. Feet:"
                Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oPropHdr_ProspectAdd1 is a cGlblDbForm
                Entry_Item PropHdr.ProspectAdd1
                Set Location to 70 86
                Set Size to 13 200
                Set Label to "Street Address:"
                 Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oPropHdr_ProspectAdd2 is a cGlblDbForm
                Entry_Item PropHdr.ProspectAdd2
                Set Location to 85 86
                Set Size to 13 200
                Set Label to "Suite/Floor:"
                 Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oPropHdr_ProspectCity is a cGlblDbForm
                Entry_Item PropHdr.ProspectCity
                Set Location to 102 86
                Set Size to 13 100
                Set Label to "City/St/Zip:"
                 Set Label_Col_Offset to 3
            Set Label_Justification_Mode to JMode_Right
            End_Object

            Object oPropHdr_ProspectState is a cGlblDbForm
                Entry_Item PropHdr.ProspectState
                Set Location to 102 191
                Set Size to 13 24
          
            End_Object

            Object oPropHdr_ProspectZip is a cGlblDbForm
                Entry_Item PropHdr.ProspectZip
                Set Location to 102 220
                Set Size to 13 66
           
            End_Object


            Object oPropHdr_ProspectPhone is a cGlblDbForm
                Entry_Item PropHdr.ProspectPhone
                Set Location to 118 86
                Set Size to 13 78
                Set Label to "Prospect Phone:"
                Set Label_Col_Offset to 3
                Set Label_Justification_Mode to JMode_Right
            End_Object

            
        End_Object

    End_Object

    Object oButton1 is a Button
        Set Size to 14 75
        Set Location to 302 15
        Set Label to 'Per Time Contract'
    
        Procedure OnClick
            Integer iSpec
            Number nNoWalkway
            
            Get Field_Current_Value of oPropHdr_DD Field PropHdr.PropHdr_Idno to iSpec
            Get Field_Current_Value of oPropHdr_DD Field PropHdr.Walk_Trigger to nNoWalkway
            
            If (iSpec <>0 and nNoWalkway >0.00) Begin
                Send DoJumpStartReport of SnowPerTime iSpec
            End
            Else Begin
                Send DoJumpStartReport of SnowPerTimeNoWalks iSpec
            End
         
        End_Procedure
    
    End_Object

    Object oTextBox1 is a TextBox
        Set Size to 10 43
        Set Location to 284 22
        Set Label to 'Print Options'
        Set FontWeight to fw_Bold
    End_Object

    Object oLineControl1 is a LineControl
        Set Size to 2 282
        Set Location to 290 79
    End_Object

    Object oButton2 is a Button
        Set Size to 14 70
        Set Location to 302 94
        Set Label to 'Seasonal Contract'
    
        // fires when the button is clicked
        Procedure OnClick
            Integer iSpec
            Number nNoWalkway
           
            Get Field_Current_Value of oPropHdr_DD Field PropHdr.PropHdr_Idno to iSpec
            Get Field_Current_Value of oPropHdr_DD Field PropHdr.Walk_Trigger to nNoWalkway
          
            If (iSpec <>0 and nNoWalkway > 0.00) Begin
                Send DoJumpStartReport of SnowSeasonal iSpec
            End
            
            Else Begin
                Send DoJumpStartReport of SnowSeasonalNoWalks iSpec
            End
            
        End_Procedure
    
    End_Object

    Object oButton3 is a Button
        Set Size to 14 57
        Set Location to 302 169
        Set Label to 'T/M Contract'
    
        // fires when the button is clicked
        Procedure OnClick
            Integer iSpec
            Number nNoWalkway
            
            Get Field_Current_Value of oPropHdr_DD Field PropHdr.PropHdr_Idno to iSpec
            Get Field_Current_Value of oPropHdr_DD Field PropHdr.Walk_Trigger to nNoWalkway
            If (iSpec <> 0 and nNoWalkway > 0.00 ) Begin
                Send DoJumpStartReport of SnowTM iSpec
            End
            
            Else Begin
                Send DoJumpStartReport of SnowTMNoWalks iSpec
            End
            
        End_Procedure
    
    End_Object

    Object oButton4 is a Button
        Set Size to 14 80
        Set Location to 302 230
        Set Label to 'Unsolicited Proposal'
    
        // fires when the button is clicked
        Procedure OnClick
            Integer iSpec
            
            Get Field_Current_Value of oPropHdr_DD Field PropHdr.PropHdr_Idno to iSpec
            If (iSpec <> 0) Begin
                Send DoJumpStartReport of SnowSpec iSpec
            End
                       
        End_Procedure
    
    End_Object

    Object oButton5 is a Button
        Set Location to 302 315
        Set Label to 'Cover'
    
        // fires when the button is clicked
        Procedure OnClick
          Integer iSpec
            
            Get Field_Current_Value of oPropHdr_DD Field PropHdr.PropHdr_Idno to iSpec
            If (iSpec <> 0) Begin
                Send DoJumpStartReport of SnowProposalCover iSpec
            End  
        End_Procedure
    
    End_Object

Cd_End_Object
