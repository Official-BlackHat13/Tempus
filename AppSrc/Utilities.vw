Use Windows.pkg
Use DFClient.pkg
Use File_Dlg.pkg
Use cTextEdit.pkg
Use Functions.pkg
Use UserInputDialog.dg
Use UserSelectionDialog.dg
Use FreeMultiSelectionDialog.dg
Use EmailSend.dg
Use OpersProcess.bp
Use InvoicePostingProcess.bp
Use Mastops.sl
Use EmployerTasks.bp
Use MarketMemberProcess.bp
Use TransactionJobCostMove.bp
Use TransactionUpdate.bp
Use GeoLocationUpdate.bp
Use cCJGrid.pkg
Use cCJGridColumn.pkg
Use cCharTranslate.pkg
Use cSeqFileHelper.pkg
Use cScrollingContainer.pkg
Use cSplitterContainer.pkg
Use cProgressBar.pkg
Use cHttpTransfer.pkg
Use cJsonHttpTransfer.pkg
Use cJsonPath.pkg

Activate_View Activate_oUtilities for oUtilities
Object oUtilities is a dbView

    Property Integer piEquipIdno
    Property String  psEquipmentID
    
    Property Integer piSelectedGroupItem1
    Property Boolean pbEmployer
    Property Boolean pbEquipment
    Property Boolean pbEmployee
    
    Property String[]   psSelectedItems

    Set Border_Style to Border_Thick
    Set Size to 385 719
    Set Location to 1 2
    Set Maximize_Icon to True

    Object oSplitterContainer1 is a cSplitterContainer
        Set piSplitterLocation to 320
        Object oSplitterContainerChild1 is a cSplitterContainerChild
            Object oEmployerTab is a TabDialog
                Set Size to 377 315
                Set Location to 16 2
                Set MultiLine_State to True
                Set peAnchors to anAll
        
                Object oTransToolsTabPage is a TabPage
                    Set Label to "Trans Tools"
        
                    Object oScrollingContainer1 is a cScrollingContainer
                        Object oScrollingClientArea1 is a cScrollingClientArea
                            Object oUpdateRateOnTrans is a Group
                                Set Size to 344 300
                                Set Location to 4 4
                                Set Label to "Please Select carefully"
                                Set peAnchors to anTopLeftRight

                                Object oGroup7 is a Group
                                    Set Size to 31 284
                                    Set Location to 47 8
                                    Set Label to 'When (Required):'
                                    Set peAnchors to anTopLeftRight
                
                                    Object oStartDate is a Form
                                        Set Size to 13 65
                                        Set Location to 10 44
                                        Set Label to "Start Date:"
                                        Set Label_Col_Offset to 5
                                        Set Label_Justification_Mode to JMode_Right
                                        Set Form_Datatype to Mask_Date_Window
                                        Set Prompt_Button_Mode to PB_PromptOn
                                        Set Prompt_Object to oMonthCalendarPrompt
                                    End_Object
                                    
                                    Object oStopDate is a Form
                                        Set Size to 13 65
                                        Set Location to 10 153
                                        Set Label to "Stop Date:"
                                        Set Label_Col_Offset to 5
                                        Set Label_Justification_Mode to JMode_Right
                                        Set Form_Datatype to Mask_Date_Window
                                        Set Prompt_Button_Mode to PB_PromptOn
                                        Set Prompt_Object to oMonthCalendarPrompt
                                    End_Object
                                End_Object
                
                                Object oTransactionRateGroup is a RadioGroup
                                    Set Location to 109 8
                                    Set Enabled_State to False
                                    Set Size to 56 284
                                    Set Label to 'Transaction Rates for:'
                                    Set peAnchors to anTopLeftRight
                                
                                    Object oRadio1 is a Radio
                                        Set Label to "Employer Idno:"
                                        Set Size to 10 61
                                        Set Location to 11 7
                                    End_Object
                                
                                    Object oRadio2 is a Radio
                                        Set Label to "Equipment Idno:"
                                        Set Size to 10 61
                                        Set Location to 26 7
                                    End_Object
                                
                                    Object oRadio3 is a Radio
                                        Set Label to "Employee Idno:"
                                        Set Size to 10 61
                                        Set Location to 41 7
                                    End_Object
                                    
                                    Procedure Notify_Select_State Integer iToItem Integer iFromItem
                                        Forward Send Notify_Select_State iToItem iFromItem
                                        //for augmentation
                                        Set piSelectedGroupItem1 to iToItem
                                        // Reset all fields
                                        If (iFromItem <> iToItem) Begin
                                            Set Value of oEmployerForm to ""
                                            Set Value of oEmployeeForm to ""
                                            Set Value of oEquipmentForm to ""
                                            //
                                            Set pbEmployer to (piSelectedGroupItem1(Self)=0)
                                            Set pbEquipment to (piSelectedGroupItem1(Self)=1)
                                            Set pbEmployee to (piSelectedGroupItem1(Self)=2)
                                            // Level1
                                            Set Enabled_State of oEmployerForm to (pbEmployer(Self))
                                            Set Enabled_State of oEquipmentForm to (pbEquipment(Self))
                                            Set Enabled_State of oEmployeeForm to (pbEmployee(Self))
                                            // Level2
                                            
                                            // Level4 Button   
                                        End
                                        
                                        
                                        //Send AdjustView //Transactions Tab
                                    End_Procedure
                                                                   
                                    
                                    Object oEmployerForm is a Form
                                        Set Size to 13 50
                                        Set Location to 9 82
                                        Set Prompt_Button_Mode to PB_PromptOn
                                        
                                        
                                        Procedure Prompt
                                            Integer iEmployerId
                                            Get DoEmployerPrompt of Employer_sl to iEmployerId
                                            Set Value of oEmployerForm to iEmployerId 
                                        End_Procedure
                
                                        Procedure Prompt_Callback Integer hPrompt
                                            Forward Send Prompt_Callback hPrompt
                                        End_Procedure
                                    
                                        //OnChange is called on every changed character
                                    
                                        //Procedure OnChange
                                        //    String sValue
                                        //
                                        //    Get Value to sValue
                                        //End_Procedure
                                    
                                    End_Object
                
                                    Object oEquipmentForm is a Form
                                        Set Size to 13 50
                                        Set Location to 24 82
                                        
                                        Procedure Prompt
                                            Integer iEquipId
                                            Get DoEquipPrompt of Equipmnt_sl to iEquipId
                                            Set Value of oEquipmentForm to iEquipId 
                                        End_Procedure
                                        //OnChange is called on every changed character
                                    
                                        //Procedure OnChange
                                        //    String sValue
                                        //
                                        //    Get Value to sValue
                                        //End_Procedure
                                    
                                    End_Object
                
                                    Object oEmployeeForm is a Form
                                        Set Size to 13 50
                                        Set Location to 39 82
                                    
                                        //OnChange is called on every changed character
                                    
                                        //Procedure OnChange
                                        //    String sValue
                                        //
                                        //    Get Value to sValue
                                        //End_Procedure
                                    
                                    End_Object
                                
                                    //If you set Current_Radio, you must set it AFTER the
                                    //radio objects have been created AND AFTER Notify_Select_State has been
                                    //created. i.e. Set in bottom-code of object at the end!!
                                
                                    Set Current_Radio to 0

                                    Object oUpdateTransRates is a Button
                                        Set Size to 40 40
                                        Set Location to 11 239
                                        Set Label to 'Go'
                                        Set peAnchors to anTopRight
                                    
                                        // fires when the button is clicked
                                        Procedure OnClick
                                            Handle hoDD
                                            Integer iFoundCount iChangeCount iDays iLabRate iEquipIdno iContRate iRentRate iOpRate 
                                            String sEmployer sEquipment sEmployee sAttachDesc
                                            Boolean bSuccess bLaborRate bContractorRate bRentalRate bOperatorRate bPreviewChecked
                                            Number nAttachRate nTimeSpan
                                            Date    dStartDate dStopDate dToday
                                            DateTime dtStart dtStop
                                            TimeSpan tsTime
                                            //
                                            tStats tUpdateStats
                                            //
                                            Sysdate dToday
                                            Move (CurrentDateTime()) to dtStart
                                            //
                                            Get Value of oStartDate  to dStartDate
                                            Get Value of oStopDate   to dStopDate
                                            
                                            Get Checked_State of oPreviewCheckBox to bPreviewChecked
                                            Get Value of oEmployerForm to sEmployer
                                            Get Value of oEquipmentForm to sEquipment
                                            Get Value of oEmployeeForm to sEmployee
                                            //
                                            Send Delete_Data of oOnScreenOutput
                                            //
                                            If (dStartDate <> 0 and dStopDate <> 0) Begin                    // Checking if date range is entered
                                                Move (dStopDate - dStartDate) to iDays
                                                Increment               iDays
                                                If (iDays >= 1) Begin
                                                    Send AppendTextLn of oOnScreenOutput ("Updating Rate in Transactions between " + String(dStartDate) + " and " + String(dStopDate))
                                                    // Find Transaction within Date Range
                                                    Get UpdateTransRates of oTransactionUpdate sEmployer sEmployee sEquipment dStartDate dStopDate (&tUpdateStats) to bSuccess
                                                    If (bSuccess) Begin
                                                        Send AppendTextLn of oOnScreenOutput ("Successfull processed - "*String(tUpdateStats.iTransChangedCount))
                                                    End
                                                    Else Begin
                                                        Send AppendTextLn of oOnScreenOutput ("There have been some errors - Errors:"*String(tUpdateStats.iErrCount)*" | Successfull:"*String(tUpdateStats.iTransChangedCount))
                                                    End
                                                    
                    
                                                End
                                                Else Begin
                                                    Send Stop_Box "Start Date must be on or before Stop Date"
                                                End
                                            End
                                            Else Begin
                                                Send Stop_Box "No date range entered"
                                            End
                                            
                                        End_Procedure
                                    
                                    End_Object
                                
                                End_Object
                
                                Object oSelectionGroup is a Group
                                    Set Location to 79 8
                                    Set Size to 26 284
                                    Set Label to 'What?'
                                    Set peAnchors to anTopLeftRight

                                    Object oComboForm2 is a ComboForm
                                        Set Size to 12 273
                                        Set Location to 9 6
                                        // Combo_Fill_List is called when the list needs filling
                                      
                                        Procedure Combo_Fill_List
                                            // Fill the combo list with Send Combo_Add_Item
                                            Send Combo_Add_Item "1. Transaction Rate"
                                            Send Combo_Add_Item "2. Elapsed Minutes --> Elapsed Hours"
                                            Send Combo_Add_Item "3. Transactions From Job to Job"
                                            Send Combo_Add_Item "4. Vendor Transaction Invoice Flag"
                                        End_Procedure
                                      
                                        // OnChange is called on every changed character
                                     
                                        Procedure OnChange
                                            String sValue
                                        
                                            Get Value to sValue // the current selected item
                                            Set Enabled_State of oTransactionRateGroup to (sValue = "1. Transaction Rate")
                                            Set Enabled_State of oElapsedHoursGroup to (sValue = "2. Elapsed Minutes --> Elapsed Hours")
                                            Set Enabled_State of oFromJobToJobGroup to (sValue = "3. Transactions From Job to Job")
                                            Set Enabled_State of oVendorTransInvoiceFlagGroup to (sValue = "4. Vendor Transaction Invoice Flag")
                                        End_Procedure
                                      
                                        // Notification that the list has dropped down
                                     
                                    //    Procedure OnDropDown
                                    //    End_Procedure
                                    
                                        // Notification that the list was closed
                                      
                                    //    Procedure OnCloseUp
                                    //    End_Procedure
                                    End_Object
                                
                                
                                End_Object

                                Object oElapsedHoursGroup is a Group
                                    Set Size to 27 284
                                    Set Location to 172 8
                                    Set Enabled_State to False
                                    Set Label to 'Elapsed Minutes --> Elapsed Hours'
                                    Set peAnchors to anTopLeftRight

                                    Object oTextBox1 is a TextBox
                                        Set Size to 10 210
                                        Set Location to 11 9
                                        Set Label to 'Fill in ElapsedHours from ElapsedMinutes/60.00'
                                    End_Object
                    
                                    Object oButton3 is a Button
                                        Set Size to 15 40
                                        Set Location to 7 238
                                        Set Label to "Go"
                                        Set peAnchors to anTopRight
                                        
                                        // fires when the button is clicked
                                        Procedure OnClick
                                            Date dStartDate dStopDate
                                            Boolean bPreviewChecked bDetailed
                                            Integer iFound iChanged
                                            //
                                            Get Value of oStartDate to dStartDate
                                            Get Value of oStopDate to dStopDate
                                            Get Checked_State of oPreviewCheckBox to bPreviewChecked
                                            Get Checked_State of oDetailedOutputCheckBox to bDetailed
                                            //
                                            Send Delete_Data of oOnScreenOutput
                                            Send AppendTextLn of oOnScreenOutput ("-----------------------RESULTS-----------------------")
                                            If (bPreviewChecked) Send AppendTextLn of oOnScreenOutput ("-------------------PREVIEW ONLY--------------------")
                                            Send AppendTextLn of oOnScreenOutput ("Parameters: StartDate:"+String(dStartDate) +" | StopDate: " * String(dStopDate))
                                            //
                                            Open Trans
                                            Clear Trans
                                            Move dStartDate to Trans.StartDate
                                            Find GE Trans by Index.6
                                            While ((Found) and Trans.StartDate >= dStartDate and Trans.StartDate <= dStopDate)
                                                If (bDetailed) Send AppendTextLn of oOnScreenOutput (" - Found Transaction#"*String(Trans.TransIdno)*" | StartDate:"*String(Trans.StartDate)*"| StopDate:"*String(Trans.StopDate)* "| Elapsed Minutes:"*String(Trans.ElapsedMinutes))
                                                Increment iFound
                                                Reread Trans
                                                    Move (Trans.ElapsedMinutes/60.00) to Trans.ElapsedHours
                                                    If (not(bPreviewChecked)) Begin
                                                        SaveRecord Trans
                                                        Increment iChanged
                                                        If (bDetailed) Send AppendTextLn of oOnScreenOutput ("- Trans.ElapsedHours:"*String(Trans.ElapsedHours))
                                                    End
                                                Unlock
                                                Find GT Trans by Index.6
                                            Loop
                                            Send AppendTextLn of oOnScreenOutput ("------------------------FINISHED-----------------------")
                                            Send AppendTextLn of oOnScreenOutput ("-------------------------STATS-------------------------")
                                            Send AppendTextLn of oOnScreenOutput ("Transactions Found:"*String(iFound)*" | Changed:"*String(iChanged))
                                            Send AppendTextLn of oOnScreenOutput ("-----------------------COMPLETED-----------------------")
                                        End_Procedure
                                    
                                    End_Object
                                End_Object

                                Object oFromJobToJobGroup is a Group
                                    Set Size to 32 284
                                    Set Location to 203 8
                                    Set Enabled_State to False
                                    Set Label to 'Transactions From Job to Job'
                                    Set peAnchors to anTopLeftRight
                                        
                                    Object oFromJobNumberForm is a Form
                                        Set Size to 13 65
                                        Set Location to 11 48
                                        Set Label to "From Job#:"
                                        Set Label_Justification_Mode to JMode_Right
                                        Set Label_Col_Offset to 5
                                    
                                        // OnChange is called on every changed character
                                    //    Procedure OnChange
                                    //        String sValue
                                    //    
                                    //        Get Value to sValue
                                    //    End_Procedure
                                    
                                    End_Object
                    
                                    Object oToJobNumberForm is a Form
                                        Set Size to 13 65
                                        Set Location to 11 153
                                        Set Label to "To Job#:"
                                        Set Label_Col_Offset to 5
                                        Set Label_Justification_Mode to JMode_Right
                                    
                                        // OnChange is called on every changed character
                                    //    Procedure OnChange
                                    //        String sValue
                                    //    
                                    //        Get Value to sValue
                                    //    End_Procedure
                                    
                                    End_Object
                    
                                    Object oGoButton is a Button
                                        Set Size to 15 40
                                        Set Location to 10 237
                                        Set Label to "Go"
                                        Set peAnchors to anTopRight
                                    
                                        // fires when the button is clicked
                                        Procedure OnClick
                                            Integer iFromJobNumber iToJobNumber
                                            Date dStartDate dStopDate
                                            Boolean bSuccess
                                            //
                                            Get Value of oFromJobNumberForm to iFromJobNumber
                                            Get Value of oToJobNumberForm to iToJobNumber
                                            Get Value of oStartDate to dStartDate
                                            Get Value of oStopDate to dStopDate
                                            //
                                            Get MoveTransactionsToJob of oTransactionJobCostMove iFromJobNumber iToJobNumber dStartDate dStopDate to bSuccess
                                            
                                        End_Procedure
                                    
                                    End_Object
                                End_Object

                                Object oVendorTransInvoiceFlagGroup is a Group
                                    Set Size to 87 284
                                    Set Location to 239 8
                                    Set Enabled_State to False
                                    Set Label to 'Vendor Trans Invoice Flagging'
                    
                                    Object oVendorCJGrid is a cCJGrid
                                        Set Size to 59 201
                                        Set Location to 10 5
                                        Set pbAllowEdit to False
                                        Set pbAllowInsertRow to False
                                        Set pbAutoAppend to False
                                        Set pbEditOnTyping to False
                                        Set pbSelectionEnable to True
                                        Set pbMultipleSelection to True
                    
                                        Object oVendorNumberCJGridColumn1 is a cCJGridColumn
                                            Set piWidth to 39
                                            Set psCaption to "Idno"
                                        End_Object
                    
                    
                    
                                        Object oVendorCJGridColumn is a cCJGridColumn
                                            Set piWidth to 266
                                            Set psCaption to "Vendor"
                                        End_Object
                    
                                        Object oStatusCJGridColumn is a cCJGridColumn
                                            Set piWidth to 46
                                            Set psCaption to "Status"
                                        End_Object
                                        
                                        Procedure LoadData 
                                            Handle hoDataSource
                                            tDataSourceRow[] TheData
                                            Boolean bFound
                                            Integer iRows iNum iName iStatus
                                            
                                            Get phoDataSource to hoDataSource
                                            
                                            // Get the datasource indexes of the various columns
                                            Get piColumnId of oVendorNumberCJGridColumn1 to iNum
                                            Get piColumnId of oVendorCJGridColumn to iName
                                            Get piColumnId of oStatusCJGridColumn to iStatus
                                            
                                            Boolean bChecked
                                            Get Checked_State of oActiveCheckBox to bChecked
                                            // Load all data into the datasource array
                                            Open Employer
                                            Clear Employer
                                            Constraint_Set 1
                                            If (bChecked) Begin
                                                Constrain Employer.Status eq "A"
                                            End
                                            Constrain Employer.EmployerIdno ne 101
                                            Constrained_Find First Employer by 2
                                            While (Found)
                                                
                                                Move Employer.EmployerIdno to TheData[iRows].sValue[iNum] 
                                                Move Employer.Name to TheData[iRows].sValue[iName] 
                                                Move Employer.Status  to TheData[iRows].sValue[iStatus] 
                                                //
                                                Move (Found) to bFound
                                                Increment iRows
                                                Constrained_Find Next
                                            Loop
                                            Constraint_Set 1 Delete
                                            
                                            // Initialize Grid with new data
                                            Send InitializeData TheData
                                            Send MovetoFirstRow
                                        End_Procedure
                                        
                                        Procedure ProcessSelectionItems
                                            Integer[] SelRows
                                            Integer i iSels iRow
                                            String sName
                                            String[] sItemSelection
                                            Handle hoDataSource
                                            tDataSourceRow[] MyData
                                        
                                            Get GetIndexesForSelectedRows to SelRows
                                            Get phoDataSource to hoDataSource
                                            Get DataSource of hoDataSource to MyData
                                            Move (SizeOfArray(SelRows)) to iSels
                                            For i from 0 to (iSels-1)
                                                Move SelRows[i] to iRow
                                                Move MyData[iRow].sValue[0] to sName
                                                Move sName to sItemSelection[i]
                                                //Showln (String(iRow) * ' - ' * sName)
                                            Loop
                                            Set psSelectedItems to sItemSelection
                                        End_Procedure
                    
                                        Procedure Activating
                                            Forward Send Activating
                                            Send LoadData
                                        End_Procedure
                        
                                    End_Object
                    
                                    Object oActiveCheckBox is a CheckBox
                                        Set Size to 10 50
                                        Set Location to 11 212
                                        Set Label to 'Active Only'
                                        Set Checked_State to True
                                    
                                    // Fires whenever the value of the control is changed
                                        Procedure OnChange
                                            Boolean bChecked
                                            Get Checked_State to bChecked
                                            Send LoadData of oVendorCJGrid
                                        End_Procedure
                                    
                                    End_Object
                    
                                    Object oButton5 is a Button
                                        Set Size to 14 56
                                        Set Location to 55 207
                                        Set Label to 'Flag Invoiced'
                                    
                                        // fires when the button is clicked
                                        Procedure OnClick
                                            Date dStartDate dStopDate
                                            DateTime dtCurrent
                                            Boolean bPreviewOnly
                                            String sOutput
                                            String[] sSelectedItems
                                            Integer iSizeOfArray iRows
                                            //
                                            Send Delete_Data of oOnScreenOutput
                                            //
                                            Get Checked_State of oPreviewCheckBox to bPreviewOnly
                                            Get Value of oStartDate to dStartDate
                                            Get Value of oStopDate to dStopDate
                                            // Process Grid Selected Data
                                            Send ProcessSelectionItems of oVendorCJGrid
                                            Get psSelectedItems to sSelectedItems
                                            Move (SizeOfArray(sSelectedItems)) to iSizeOfArray
                                            If (iSizeOfArray >= 1) Begin
                                                // Prepare Log file
                                                Move (CurrentDateTime()) to dtCurrent
                                                Get psHome of (phoWorkspace(ghoApplication)) to sOutput
                                                If (not(Right(sOutput,1) = "\")) Begin
                                                    Move (sOutput + "\") to sOutput
                                                End
                                                Move (sOutput + "Document\Log\VendorTransInvFlag.log")   to sOutput
                                                //  
                                                Append_Output sOutput
                                                Writeln "Started: "dtCurrent
                                                Send AppendTextLn of oOnScreenOutput ("Started"*String(dtCurrent))
                                                //
                                                Move 0 to iRows
                                                For iRows from 0 to (iSizeOfArray-1)
                                                    Writeln ("Vendor:"+ String(sSelectedItems[iRows]))
                                                    Send AppendTextLn of oOnScreenOutput ("Vendor:"+ String(sSelectedItems[iRows]))
                                                    //Showln ("Out:"*String(iRows)*'-'*sSelectedItems[iRows]*'- StartDate:'*String(dStartDate)*'- StopDate:'*String(dStopDate))
                                                    Open Trans
                                                    Clear Trans
                                                    Constraint_Set 1
                                                    Constrain Trans.StartDate Between dStartDate and dStopDate
                                                    Constrain Trans.EmployerIdno eq sSelectedItems[iRows]
                                                    Constrain Trans.VendInvoicedFlag eq 0
                                                    Constrained_Find First Trans by 6
                                                    While ((Found) and (Trans.StartDate>=dStartDate) and (Trans.StartDate <= dStopDate) and (Trans.EmployerIdno=sSelectedItems[iRows]) and (Trans.VendInvoicedFlag=0))
                                                        //
                                                        Writeln ('Found Trans:'*String(Trans.TransIdno)*'- EmployeeIdno:'*String(Trans.EmployeeIdno)*'- Job#:'*String(Trans.JobNumber)*'- Equip#:'*String(Trans.EquipIdno)*'- StarDate:'*String(Trans.StartDate)*'- StartTime:'*String(Trans.StartTime)*'- VendInvFlag:'*String(Trans.VendInvoicedFlag)*'- VendInvIdno:'*String(Trans.VendInvHdrIdno))
                                                        Send AppendTextLn of oOnScreenOutput ('Found Trans:'*String(Trans.TransIdno)*'- EmployeeIdno:'*String(Trans.EmployeeIdno)*'- Job#:'*String(Trans.JobNumber)*'- Equip#:'*String(Trans.EquipIdno)*'- StarDate:'*String(Trans.StartDate)*'- StartTime:'*String(Trans.StartTime)*'- VendInvFlag:'*String(Trans.VendInvoicedFlag)*'- VendInvIdno:'*String(Trans.VendInvHdrIdno))
                                                        If (not(bPreviewOnly)) Begin
                                                            Move 1 to Trans.VendInvoicedFlag
                                                            SaveRecord Trans
                                                            Writeln ('Changed Trans:'*String(Trans.TransIdno)*'- EmployeeIdno:'*String(Trans.EmployeeIdno)*'- Job#:'*String(Trans.JobNumber)*'- Equip#:'*String(Trans.EquipIdno)*'- StarDate:'*String(Trans.StartDate)*'- StartTime:'*String(Trans.StartTime)*'- VendInvFlag:'*String(Trans.VendInvoicedFlag)*'- VendInvIdno:'*String(Trans.VendInvHdrIdno))
                                                            Send AppendTextLn of oOnScreenOutput ('Changed Trans:'*String(Trans.TransIdno)*'- EmployeeIdno:'*String(Trans.EmployeeIdno)*'- Job#:'*String(Trans.JobNumber)*'- Equip#:'*String(Trans.EquipIdno)*'- StarDate:'*String(Trans.StartDate)*'- StartTime:'*String(Trans.StartTime)*'- VendInvFlag:'*String(Trans.VendInvoicedFlag)*'- VendInvIdno:'*String(Trans.VendInvHdrIdno))
                                                        End
                                                        Constrained_Find Next
                                                    Loop
                                                    Constraint_Set 1 Delete
                                                Loop
                                                Writeln "Completed"
                                                Send AppendTextLn of oOnScreenOutput ("Completed")
                                                Close_Output
                                            End
                                        End_Procedure
                                    
                                    End_Object
                    
                                End_Object

                                Object oGroup3 is a Group
                                    Set Size to 30 283
                                    Set Location to 12 9
                                    Set Label to 'Options'

                                    Object oPreviewCheckBox is a CheckBox
                                        Set Size to 10 50
                                        Set Location to 12 9
                                        Set Label to 'Preview Only'
                                        Set Checked_State to True
                                    
                                        // Fires whenever the value of the control is changed
                                    //    Procedure OnChange
                                    //        Boolean bChecked
                                    //    
                                    //        Get Checked_State to bChecked
                                    //    End_Procedure
                                    
                                    End_Object
                                    Object oDetailedOutputCheckBox is a CheckBox
                                        Set Size to 10 50
                                        Set Location to 12 69
                                        Set Label to 'Detailed Output'
                                        Set Checked_State to True
                                    
                                        // Fires whenever the value of the control is changed
                                    //    Procedure OnChange
                                    //        Boolean bChecked
                                    //    
                                    //        Get Checked_State to bChecked
                                    //    End_Procedure
                                    
                                    End_Object
                                    
                                End_Object
                                
                                
                            End_Object
                        End_Object
                    End_Object
        
        //            Object oHttpTransfer1 is a cHttpTransfer
        //                Procedure OnDataReceived String sContentType String sData
        //                    // You can abort file transfer here with 'Send CancelTransfer'
        //                End_Procedure
        //            End_Object
        
                End_Object
        
        
                Object oTransTools2TabPage is a TabPage
                    Set Label to 'Trans Tools 2'
        
                    Object oGroup14 is a Group
                        Set Size to 100 260
                        Set Location to 5 9
                        Set Label to 'Trans Mass Update - EquipOwner'
        
                        Object oStartDateForm is a Form
                            Set Size to 13 59
                            Set Location to 18 14
                            Set Label to "Start Date:"
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        
                            // OnChange is called on every changed character
                        //    Procedure OnChange
                        //        String sValue
                        //    
                        //        Get Value to sValue
                        //    End_Procedure
                        
                        End_Object
        
                        Object oStopDateForm is a Form
                            Set Size to 13 54
                            Set Location to 18 82
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        
                            // OnChange is called on every changed character
                        //    Procedure OnChange
                        //        String sValue
                        //    
                        //        Get Value to sValue
                        //    End_Procedure
                        
                        End_Object
        
                        Object oPreviewCheckBox1 is a CheckBox
                            Set Size to 10 50
                            Set Location to 19 154
                            Set Label to 'Preview Only'
                            Set Checked_State to True
                        
                            // Fires whenever the value of the control is changed
                        //    Procedure OnChange
                        //        Boolean bChecked
                        //    
                        //        Get Checked_State to bChecked
                        //    End_Procedure
                        
                        End_Object
        
                        Object oButton10 is a Button
                            Set Size to 14 229
                            Set Location to 66 16
                            Set Label to 'Start'
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                // MAINTENANCE TOOL - This tool can be run to update the transaction record with historic data, without triggering the DD Update procedure
                                Date dStartDate dStopDate
                                Integer iTransFoundCount iTransChangeCount iTransSavedCount
                                Boolean bPreview
                                //
                                Get Value of oStartDateForm to dStartDate
                                Get Value of oStopDateForm to dStopDate
                                Get Checked_State of oPreviewCheckBox1 to bPreview
                                //
                                Send Delete_Data of oOnScreenOutput
                                Send AppendTextLn of oOnScreenOutput ("Start")
                                // Step 1 - Find first Transaction in Date Range
                                Constraint_Set 1 
                                Constrain Trans.StartDate ge dStartDate
                                Constrain Trans.StartDate le dStopDate
                                Constrained_Find FIRST Trans by 6
                                While (Found)
                                    Increment iTransFoundCount
                                    Send AppendTextLn of oOnScreenOutput ("Updating Trans.EquipOwner and Trans.AttachEquipOwner in Transactions between " + String(dStartDate) + " and " + String(dStopDate))
                                    // Step 2 - use Trans.EquipIdno to find Equipment record of Equipment used for the Transaction
                                    Clear Equipmnt
                                    If (Trans.AttachEquipIdno<>0) Begin
                                        Move Trans.AttachEquipIdno to Equipmnt.EquipIdno
                                        Find EQ Equipmnt.EquipIdno
                                        If ((Found) and Trans.AttachEquipIdno = Equipmnt.EquipIdno) Begin
                                            Send AppendTextLn of oOnScreenOutput ("Found Attach#"*String(Trans.AttachEquipIdno)*" | OwnedBy:"* String(Equipmnt.OperatedBy))
                                            Move Equipmnt.OperatedBy to Trans.AttachEquipOwner
                                        End
                                    End
                                    Clear Equipmnt
                                    Move Trans.EquipIdno to Equipmnt.EquipIdno
                                    Find EQ Equipmnt.EquipIdno
                                    If ((Found) and Trans.EquipIdno = Equipmnt.EquipIdno) Begin
                                        // Step 3 - update new field Trans.EquipOwner from Equipmnt.OperatedBy 
                                        Send AppendTextLn of oOnScreenOutput ("Found Equip#"*String(Trans.EquipIdno)*" | OwnedBy:"* String(Equipmnt.OperatedBy))
                                        Increment iTransChangeCount
                                        Move Equipmnt.OperatedBy to Trans.EquipOwner
                                        If (not(bPreview)) Begin
                                            SaveRecord Trans
                                            Increment iTransSavedCount
                                            Send AppendTextLn of oOnScreenOutput ("SAVED")
                                        End
                                    End
                                    Constrained_Find Next
                                Loop
                                Constraint_Set 1 Delete
                                Send AppendTextLn of oOnScreenOutput ("STATS: Found"*String(iTransFoundCount)*" | Changed:"*String(iTransChangeCount)*" | Saved:"*String(iTransSavedCount))
                                
                            End_Procedure
                        
                        End_Object
                        
                        
                        
                    End_Object
        
                End_Object
        
                Object oTabPage2 is a TabPage
                    Set Label to 'Order Tools'
        
                    Object oUpdateOrderStatus is a Group
                        Set Size to 34 267
                        Set Location to 4 4
                        Set Label to 'Reset Order ProjectID >= 1007 to 0'
                
                        Object oUpdateOrderStatus is a Button
                            Set Size to 14 84
                            Set Location to 14 94
                            Set Label to 'Go'
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Send Delete_Data of oOnScreenOutput
                                Integer iOrderCounter iOpenCounter iClosedCounter iCanceledCounter
                                 
                                
                                
                                Constraint_Set 1
                                Constrain Order.ProjectId gt 1007
                                Constrained_Find First Order by 1
                                While (Found)
                                    If (Order.ProjectId>0) Begin
                                        Send AppendTextLn of oOnScreenOutput ("Job#"* String(Order.JobNumber))
                                        Move 0 to Order.ProjectId
                                        Increment iOrderCounter
                                        SaveRecord Order    
                                    End
                                    Constrained_Find Next
                                Loop
                                Constraint_Set 1 Delete
                                
                                Send AppendTextLn of oOnScreenOutput ("Total:" * String(iOrderCounter))
                            End_Procedure
        
                        End_Object
          
                    End_Object
        
                    Object oGroup1 is a Group
                        Set Size to 72 266
                        Set Location to 41 4
                        Set Label to 'Mass Close Orders'
        
                        Object oSzStartDatePicker is a Form
                            Set Size to 13 92
                            Set Location to 17 53
                            Set Label to "Begin Date"
                            Set Label_Col_Offset to 5
                            Set Label_Justification_Mode to JMode_Right
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        End_Object
                        
                        Object oSzStopDatePicker is a Form
                            Set Size to 13 92
                            Set Location to 33 53
                            Set Label to "End Date"
                            Set Label_Justification_Mode to JMode_Right
                            Set Label_Col_Offset to 5
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        End_Object
        
                        Object oComboForm1 is a ComboForm
                            Set Size to 12 92
                            Set Location to 49 53
                            Set Allow_Blank_State to False
                            Set Entry_State to False
                        
                            //Combo_Fill_List is called when the list needs filling
                        
                            Procedure Combo_Fill_List
                                // Fill the combo list with Send Combo_Add_Item
                                Send Combo_Add_Item "Snow Removal - S"
                                Send Combo_Add_Item "Pavement Maint. - P"
                                Send Combo_Add_Item "Sweeping - SW"
                                Send Combo_Add_Item "Excavation - E"
                                Send Combo_Add_Item "Other - O"
                                Send Combo_Add_Item "Capital Expenditure - CE"
                                Send Combo_Add_Item "Shop Labor - SL"
                                Send Combo_Add_Item "Connex Box - CX"
                            End_Procedure
                        
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
        
                        Object oButton1 is a Button
                            Set Location to 31 181
                            Set Label to 'Close'
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Send Delete_Data of oOnScreenOutput
                                Date dStart dStop dToday
                                Integer iFound iChanged eResponse iSet
                                Boolean bPreviewChecked
                                String sOrderType
                                                       
                                Move 0 to dStart
                                Move 0 to dStop
                                Move "" to sOrderType
                                Move 0 to iFound
                                Move 0 to iChanged
                                Increment iSet
                                Sysdate dToday
                                
                                Get Value of oSzStartDatePicker to dStart
                                Get Value of oSzStopDatePicker to dStop
                                Get Value of oComboForm1 to sOrderType
                                Get Checked_State of oPreviewCheckBox to bPreviewChecked
                                Move (Right(sOrderType, 2)) to sOrderType
                                Move (Trim(sOrderType)) to sOrderType
                                Send AppendTextLn of oOnScreenOutput "START"
                                Send AppendTextLn of oOnScreenOutput ("Looking for Orders opened between" * String(dStart) * " and " * String(dStop) * " of the WorkType " * sOrderType)
                                
                                Open Order
                                Clear Order
                                Constraint_Set 1
                                Constrain Order.Status eq "O"
                                Constrained_Find First Order by 1
                                While (Found)
                                    If (Order.JobOpenDate >= dStart and Order.JobOpenDate <= dStop and Order.WorkType = sOrderType) Begin
                                        Increment iFound
                                        Send AppendTextLn of oOnScreenOutput ("#"*String(iFound)*" - Job#:"*String(Order.JobNumber)*"- Order.WorkType"*Order.WorkType*"- Title: "*Order.Title*"- Status:"*Order.Status)
                                    End
                                    Constrained_Find Next
                                Loop
                                Send AppendTextLn of oOnScreenOutput "COMPLETE" 
                                Send AppendTextLn of oOnScreenOutput ("Found: " * String(iFound) * " - Changed: " * String(iChanged))
                                If (iFound >=1) Begin
                                    Get YesNo_Box ("Would you like to close "*String(iFound)*" Jobs of the type"*sOrderType*"?") "Close found Orders?" MB_DEFBUTTON1 to eResponse
                                    If (eResponse = MBR_Yes) Begin
                                        Constraint_Set 1
                                        Constrained_Find First Order by 1
                                        While (Found)
                                            If (Order.JobOpenDate => dStart and Order.JobOpenDate <= dStop and Order.WorkType = sOrderType) Begin
                                                If (not(bPreviewChecked)) Begin
                                                    Reread Order
                                                        Move "C"                    to Order.Status
                                                        Move dToday                 to Order.JobCloseDate
                                                        Move "1"                    to Order.ChangedFlag
                                                        Move "1"                    to Order.LockedFlag
                                                        SaveRecord Order
                                                    Unlock
                                                End
                                                
                                                Increment iChanged
                                                Send AppendTextLn of oOnScreenOutput ("Job#:"*String(Order.JobNumber)*"- Order.WorkType"*Order.WorkType*"- Title: "*Order.Title*"- Status:"*Order.Status)
                                            End
                                            Constrained_Find Next
                                        Loop
                                        Send AppendTextLn of oOnScreenOutput ("DONE - Changed:"*String(iChanged)*"/"*String(iFound))
                                        Constraint_Set 1 Delete 
                                    End
                                 
                                End
                                Else Begin
                                    Send Info_Box ("No open order found")
                                End
                                Constraint_Set 1 Delete 
                            End_Procedure
                        End_Object
        
                        Object oPreviewCheckBox is a CheckBox
                            Set Size to 10 50
                            Set Location to 18 181
                            Set Label to "Preview Only"
                            Set Checked_State to True
                        
                            //Fires whenever the value of the control is changed
                            //Procedure OnChange
                            //    Boolean bChecked
                            //
                            //    Get Checked_State To bChecked
                            //End_Procedure
                        
                        End_Object
                    End_Object
        
                    Object oGroup2 is a Group
                        Set Size to 40 265
                        Set Location to 116 4
                        Set Label to 'Update OrderDtl required flag on all Order records'
                        
                        //Qualifying OrderDtl Lineitems: 
                        //  - Has Man Hours & $ Amount
                        //  - Subcontractor Only
        
                        Object oButton2 is a Button
                            Set Size to 14 84
                            Set Location to 14 35
                            Set Label to 'Go'
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Integer iOrderCount iCurrRec iOrderDtl iOrderDtlRequired iOrderDtlCompleted
                                Send Delete_Data of oOnScreenOutput
                                Send AppendTextLn of oOnScreenOutput "START"
                                // Count total records
                                Clear Order
                                Find GE Order by 1
                                While (Found)
                                    Increment iOrderCount
                                    Find GT Order by 1
                                Loop
                                Send AppendTextLn of oOnScreenOutput ("Processing "+String(iOrderCount)+" Records.")
                                // Progress bar parameters
                                Set piMinimum of oUtilityProgressBar to 0
                                Set piMaximum of oUtilityProgressBar to iOrderCount
                                // Open Orders only
                                Clear Order
                                //Move 'O' to Order.Status
                                Find GE Order by 1
                                While ((Found))
                                    // Update Progress Bar
                                    Increment iCurrRec
                                    Set piPosition of oUtilityProgressBar to iCurrRec
                                    // Reset counter variables for each Order
                                    Move 0 to iOrderDtl
                                    Move 0 to iOrderDtlRequired
                                    Move 0 to iOrderDtlCompleted
                                    Send AppendTextLn of oOnScreenOutput ("Job#: "+String(Order.JobNumber)+" | "+ Trim(Order.Title))
                                    Clear OrderDtl
                                    Move Order.JobNumber to OrderDtl.JobNumber
                                    Find GE OrderDtl by 2
                                    While ((Found) and OrderDtl.JobNumber = Order.JobNumber)
                                        Increment iOrderDtl
                                        Move (OrderDtl.TotalManHours>0 or OrderDtl.Amount>0 or OrderDtl.SubOnlyFlag) to OrderDtl.CompletedReqFlag
                                        Move (if(Order.Status='C' and OrderDtl.CompletedReqFlag,True,False)) to OrderDtl.CompletedFlag
                                        SaveRecord OrderDtl
                                        Add (OrderDtl.CompletedReqFlag) to iOrderDtlRequired
                                        Add (OrderDtl.CompletedFlag) to iOrderDtlCompleted
                                        Find GT OrderDtl by 2
                                    Loop
                                    // Order.JobNumber should be the same as at the beginning of the loop.
                                    Send AppendTextLn of oOnScreenOutput ("Job#: "+String(Order.JobNumber)+" | ADD")
                                    Send AppendTextLn of oOnScreenOutput ("OrderDetail Line Items: "+String(iOrderDtl)+" | Required Items: "+ String(iOrderDtlRequired)+" | Completed: "+String(iOrderDtlCompleted))
                                    // Add gathered stats to current Order record
                                    If (iOrderDtlRequired>0 or iOrderDtlCompleted>0) Begin
                                        Move iOrderDtl to Order.LineItemCount
                                        Move iOrderDtlRequired to Order.LineItemReqCount
                                        Move (If(Order.Status='C',iOrderDtlRequired,iOrderDtlCompleted)) to Order.LineItemCompCount
                                        SaveRecord Order
                                        Send AppendTextLn of oOnScreenOutput ("Updated Job# "+String(Order.JobNumber))
                                    End
                                    
                                    // Go to next record
                                    Find GT Order by 1
                                Loop
                                Clear Order OrderDtl
                                Send AppendTextLn of oOnScreenOutput  ("COMPLETED")
                            End_Procedure
                        
                        End_Object
                    End_Object
        
                    Object oGroup4 is a Group
                        Set Size to 47 263
                        Set Location to 158 5
                        Set Label to 'Invoice Data Range Builder'
        
                        Object oSzStartDatePicker is a Form
                            Set Size to 13 92
                            Set Location to 10 53
                            Set Label to "Begin Date"
                            Set Label_Col_Offset to 5
                            Set Label_Justification_Mode to JMode_Right
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        End_Object
                        
                        Object oSzStopDatePicker is a Form
                            Set Size to 13 92
                            Set Location to 26 53
                            Set Label to "End Date"
                            Set Label_Justification_Mode to JMode_Right
                            Set Label_Col_Offset to 5
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        End_Object
                        
                        Object oButton1 is a Button
                            Set Location to 17 167
                            Set Label to 'Update'
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Send Delete_Data of oOnScreenOutput
                                Date dStart dStop dToday
                                Integer iFound iChanged eResponse iSet
                                String sOrderType
                                                       
                                Move 0 to dStart
                                Move 0 to dStop
                                Move 0 to iFound
                                Move 0 to iChanged
                                Increment iSet
                                Sysdate dToday
                                
                                Get psValue of oSzStartDatePicker to dStart
                                Get psValue of oSzStopDatePicker to dStop
                                Send AppendTextLn of oOnScreenOutput "START"
                                Send AppendTextLn of oOnScreenOutput ("Looking for Orders opened between" * String(dStart) * " and " * String(dStop) * " of the WorkType " * sOrderType)
                                
                                Open Order
                                Clear Order
                                Constraint_Set 1
                                Constrain Order.WorkType ne "S"
                                Constrain Order.Status eq "C"
                                Constrained_Find First Order by 1
                                While (Found)
                                    If (Order.JobOpenDate >= dStart and Order.JobOpenDate <= dStop and Order.WorkType = sOrderType) Begin
                                        Increment iFound
                                        Send AppendTextLn of oOnScreenOutput ("#"*String(iFound)*" - Job#:"*String(Order.JobNumber)*"- Order.WorkType"*Order.WorkType*"- Title: "*Order.Title*"- Status:"*Order.Status)
                                    End
                                    Constrained_Find Next
                                Loop
                                Send AppendTextLn of oOnScreenOutput "COMPLETE" 
                                Send AppendTextLn of oOnScreenOutput ("Found: " * String(iFound) * " - Changed: " * String(iChanged))
                                If (iFound >=1) Begin
                                    Get YesNo_Box ("Would you like to close "*String(iFound)*" Jobs of the type"*sOrderType*"?") "Close found Orders?" MB_DEFBUTTON1 to eResponse
                                    If (eResponse = MBR_Yes) Begin
                                        Constraint_Set 1
                                        Constrained_Find First Order by 1
                                        While (Found)
                                            If (Order.JobOpenDate => dStart and Order.JobOpenDate <= dStop and Order.WorkType = sOrderType) Begin
                                                Reread Order
                                                    Move "C"                    to Order.Status
                                                    Move dToday                 to Order.JobCloseDate
                                                    Move "1"                    to Order.ChangedFlag
                                                    SaveRecord Order
                                                Unlock
                                                Increment iChanged
                                                Send AppendTextLn of oOnScreenOutput ("Job#:"*String(Order.JobNumber)*"- Order.WorkType"*Order.WorkType*"- Title: "*Order.Title*"- Status:"*Order.Status)
                                            End
                                            Constrained_Find Next
                                        Loop
                                        Send AppendTextLn of oOnScreenOutput ("DONE - Changed:"*String(iChanged)*"/"*String(iFound))
                                    End
                                    Else Procedure_Return                            
                                End
                                Else Send Info_Box ("No open order found")
                            End_Procedure
                        End_Object
                    End_Object
        
                    Object oGroup10 is a Group
                        Set Size to 39 264
                        Set Location to 210 4
                        Set Label to "Mass Order Cost Update"
        
                        Object oSzOpenDatePicker is a Form
                            Set Size to 13 62
                            Set Location to 16 64
                            Set Label to "Opened between"
                            Set Label_Col_Offset to 2
                            Set Label_Justification_Mode to JMode_Right
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        End_Object
                        
                        Object oSzOpenToDatePicker is a Form
                            Set Size to 13 62
                            Set Location to 16 141
                            Set Label to "-"
                            Set Label_Justification_Mode to JMode_Right
                            Set Label_Col_Offset to 5
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        End_Object
                        
                        Object oButton7 is a Button
                            Set Location to 21 208
                            Set Label to "Go"
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Integer iFoundOrderCount iJobNumber iFoundTransCount iFoundInvCount iFoundJobcostCount
                                Boolean bPreviewChecked bCancel
                                Number nTransCost nLaborMinutes nInvTotal nJobCostTotal
                                Date dOrderOpenDateStart dOrderOpenDateStop
                                //
                                Send Delete_Data of oOnScreenOutput
                                Send AppendTextLn of oOnScreenOutput ("Start")
                                //
                                Get Checked_State of oPreviewCheckBox to bPreviewChecked
                                If (not(bPreviewChecked)) Begin
                                    Get Confirm ("Are you sure you want to apply the changes to the data?") to bCancel
                                    If (bCancel) Begin // Reset Checked status
                                        Set Checked_State of oPreviewCheckBox to True
                                        Move True to bPreviewChecked
                                    End
                                End
                                If (bPreviewChecked) Send AppendTextLn of oOnScreenOutput ("Preview Mode")
                                Else Send AppendTextLn of oOnScreenOutput ("Changes Mode")
                                Get Value of oSzOpenDatePicker to dOrderOpenDateStart
                                Get Value of oSzOpenToDatePicker to dOrderOpenDateStop
                                // Orders
                                Constraint_Set 1
                                Constrain Order.JobOpenDate Between dOrderOpenDateStart and dOrderOpenDateStop
                                Constrain Order as (Order.WorkType ne "S" and Order.WorkType ne "SL")
                                Constrained_Find First Order by 1
                                While (Found)
                                    Send AppendTextLn of oOnScreenOutput ("Found Job#:" * String(Order.JobNumber) * " LaborMin: "*String(Order.LaborMinutes) * " TransCost: $" * String(Order.LaborCost) * "JobCost: $" *String(Order.JobCostTotal) * "InvoiceAmt: $" * String(Order.InvoiceAmt)* "opened on" * String(Order.JobOpenDate))
                                    Increment iFoundOrderCount
                                    Move Order.JobNumber to iJobNumber
                                    Move 0 to iFoundTransCount
                                    Move 0 to iFoundInvCount
                                    Move 0 to iFoundJobcostCount
                                    Move 0 to nTransCost
                                    Move 0 to nLaborMinutes
                                    Move 0 to nInvTotal
                                    Move 0 to nJobCostTotal
                                    // Transactions
                                    Constraint_Set 2
                                    Constrain Trans.JobNumber eq iJobNumber
                                    Constrained_Find First Trans by 2
                                    While (Found)
                                        Increment iFoundTransCount
                                        Add (Trans.ElapsedMinutes) to nLaborMinutes
                                        Add (Trans.CurrentContractorRate*Trans.ElapsedMinutes/60.00) to nTransCost
                                        Constrained_Find Next // Transaction
                                    Loop
                                    Constraint_Set 2 Delete
                                    Send AppendTextLn of oOnScreenOutput (" --->"*String(iFoundTransCount)*"Transactions - "*String(nLaborMinutes)*"Labor minutes - $"*String(nTransCost))
                                    // JobCost
                                    Constraint_Set 3
                                    Constrain Jobcosts.JobNumber eq iJobNumber
                                    Constrain Jobcosts.ExcludeFlag eq 0
                                    Constrained_Find First Jobcosts by 2
                                    While (Found)
                                        Increment iFoundJobcostCount
                                        Add (Jobcosts.TotalCost) to nJobCostTotal
                                        Constrained_Find Next // JobCost
                                    Loop
                                    Constraint_Set 3 Delete
                                    Send AppendTextLn of oOnScreenOutput (" --->"* String(iFoundJobcostCount) * "JobCostEntries - $"*String(nJobCostTotal))
                                    // Invoices
                                    Constraint_Set 4
                                    Constrain Invhdr.JobNumber eq iJobNumber
                                    Constrain Invhdr.VoidFlag eq 0
                                    Constrained_Find First Invhdr by 2
                                    While (Found)
                                        Increment iFoundInvCount
                                        Add (Invhdr.TotalAmount) to nInvTotal
                                        Constrained_Find Next // Invoice
                                    Loop
                                    Constraint_Set 4 Delete
                                    Send AppendTextLn of oOnScreenOutput (" --->"* String(iFoundInvCount) * " Invoices - $"*String(nInvTotal))
                                    // Update all records on the order if not in preview mode
                                    If (not(bPreviewChecked)) Begin
                                        Move nLaborMinutes      to Order.LaborMinutes
                                        Move nTransCost         to Order.LaborCost
                                        Move nJobCostTotal      to Order.JobCostTotal
                                        Move nInvTotal          to Order.InvoiceAmt
                                        SaveRecord Order
                                    End
                                    Constrained_Find Next // Find Next Order
                                Loop
                                Constraint_Set 1 Delete
                                Send AppendTextLn of oOnScreenOutput ("Finished - Found:" *String(iFoundOrderCount)* "Orders")
                            End_Procedure
                        
                        End_Object
        
                        Object oPreviewCheckBox is a CheckBox
                            Set Size to 10 50
                            Set Location to 9 208
                            Set Label to "Preview Only"
                            Set Checked_State to True
                        
                            //Fires whenever the value of the control is changed
                            //Procedure OnChange
                            //    Boolean bChecked
                            //
                            //    Get Checked_State To bChecked
                            //End_Procedure
                        
                        End_Object
        
        
                    End_Object
        
                    Object oGroup10 is a Group
                        Set Size to 39 264
                        Set Location to 251 5
                        Set Label to "Mass Order EstHours Update"
        
                        Object oSzOpenDatePicker is a Form
                            Set Size to 13 62
                            Set Location to 16 64
                            Set Label to "Opened between"
                            Set Label_Col_Offset to 2
                            Set Label_Justification_Mode to JMode_Right
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        End_Object
                        
                        Object oSzOpenToDatePicker is a Form
                            Set Size to 13 62
                            Set Location to 16 141
                            Set Label to "-"
                            Set Label_Justification_Mode to JMode_Right
                            Set Label_Col_Offset to 5
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        End_Object
                        
                        Object oButton7 is a Button
                            Set Location to 21 208
                            Set Label to "Go"
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Integer iFoundOrderCount iJobNumber iFoundDetailCount
                                Number nEstHoursTtl
                                Boolean bPreviewChecked bCancel
                                Date dOrderOpenDateStart dOrderOpenDateStop
                                //
                                Send Delete_Data of oOnScreenOutput
                                Send AppendTextLn of oOnScreenOutput ("Start")
                                //
                                Get Checked_State of oPreviewCheckBox to bPreviewChecked
                                If (not(bPreviewChecked)) Begin
                                    Get Confirm ("Are you sure you want to apply the changes to the data?") to bCancel
                                    If (bCancel) Begin // Reset Checked status
                                        Set Checked_State of oPreviewCheckBox to True
                                        Move True to bPreviewChecked
                                    End
                                End
                                If (bPreviewChecked) Send AppendTextLn of oOnScreenOutput ("Preview Mode")
                                Else Send AppendTextLn of oOnScreenOutput ("Changes Mode")
                                Get Value of oSzOpenDatePicker to dOrderOpenDateStart
                                Get Value of oSzOpenToDatePicker to dOrderOpenDateStop
                                // Orders
                                Constraint_Set 1
                                Constrain Order.JobOpenDate Between dOrderOpenDateStart and dOrderOpenDateStop
                                Constrain Order as (Order.WorkType ne "S" and Order.WorkType ne "SL")
                                Constrained_Find First Order by 1
                                While (Found)
                                    Send AppendTextLn of oOnScreenOutput ("Found Job#:" * String(Order.JobNumber) * " - opened on" * String(Order.JobOpenDate)* " - EstHoursTotal:" * String(Order.EstHoursTotal))
                                    Increment iFoundOrderCount
                                    Move Order.JobNumber to iJobNumber
                                    Move 0 to iFoundDetailCount
                                    Move 0 to nEstHoursTtl
                                    // Transactions
                                    Constraint_Set 2
                                    Constrain OrderDtl.JobNumber eq iJobNumber
                                    Constrained_Find First OrderDtl by 2
                                    While (Found)
                                        Increment iFoundDetailCount
                                        Send AppendTextLn of oOnScreenOutput (" -> " * String(OrderDtl.TotalManHours))
                                        Add OrderDtl.TotalManHours to nEstHoursTtl
                                        Constrained_Find Next // OrderDetail
                                    Loop
                                    Constraint_Set 2 Delete
                                    Send AppendTextLn of oOnScreenOutput (" ---> "*String(iFoundDetailCount))
                                    If (not(bPreviewChecked)) Begin
                                        Move nEstHoursTtl       to Order.EstHoursTotal
                                        SaveRecord Order
                                    End
                                    Constrained_Find Next // Find Next Order
                                Loop
                                Constraint_Set 1 Delete
                                Send AppendTextLn of oOnScreenOutput ("Finished - Found:" *String(iFoundOrderCount)* "Orders")
                            End_Procedure
                        
                        End_Object
        
                        Object oPreviewCheckBox is a CheckBox
                            Set Size to 10 50
                            Set Location to 9 208
                            Set Label to "Preview Only"
                            Set Checked_State to True
                        
                            //Fires whenever the value of the control is changed
                            //Procedure OnChange
                            //    Boolean bChecked
                            //
                            //    Get Checked_State To bChecked
                            //End_Procedure
                        
                        End_Object
        
        
                    End_Object
        
                    Object oMoveOrderGroup is a Group
                        Set Size to 50 263
                        Set Location to 292 6
                        Set Label to 'Move Order, Estimate, Quote & JobCosts'
        
                        Object oJobNumberForm is a Form
                            Set Size to 13 43
                            Set Location to 19 6
                            Set Label to "Job#"
                            Set Label_Justification_Mode to JMode_Top
                            Set Label_Col_Offset to 0
                        
                            // OnChange is called on every changed character
                        //    Procedure OnChange
                        //        String sValue
                        //    
                        //        Get Value to sValue
                        //    End_Procedure
                        
                        End_Object
                    End_Object
          
                End_Object
        
                Object oTabPage3 is a TabPage
                    Set Label to 'Quote Tools'
                    
        
                    Object oGroup1 is a Group
                        Set Size to 35 166
                        Set Location to 4 3
                        Set Label to 'Quote Mass Subtotal Update'
        
                        Object oQuoteSubTotalUpdateButton is a Button
                            Set Size to 14 153
                            Set Location to 11 6
                            Set Label to 'Go !'
                                           
                            // fires when the button is clicked
                            Procedure OnClick
                                Integer iQuoteHdrIdno iQuoteCounter iRunCounter
                                Integer[] iQuoteArray
                                Number nSubTotal nTaxTotal nTotalAmount
                                Boolean bError
                                Send Delete_Data of oOnScreenOutput
                                Clear DF_ALL
                                Move 8000 to Quotedtl.QuotehdrID
                                Find GE Quotedtl by Index.2
                                While (Found)
                                    Relate Quotedtl
                                    Move Quotedtl.QuotehdrID to iQuoteHdrIdno
                                    If (MastOps.IsTaxable = 1) Begin
                                        Move Quotedtl.QuotehdrID to iQuoteHdrIdno
                                        Send AppendTextLn of oOnScreenOutput ("Quote# with Taxable Item:" * String(iQuoteHdrIdno))
                                        Increment iQuoteCounter
                                        Clear QuoteHdr
                                        Move iQuoteHdrIdno to Quotehdr.QuotehdrID
                                        Find EQ QuoteHdr by Index.1
                                        If ((Found) and Quotehdr.QuotehdrID = iQuoteHdrIdno) Begin
                                            Clear Quotedtl
                                            Move 0 to nSubTotal
                                            Move 0 to nTaxTotal
                                            Move 0 to nTotalAmount                   
                                            Send AppendTextLn of oOnScreenOutput ("Quote#:" * String(Quotehdr.QuotehdrID))
                                            //Update all QuoteDtl Records
                                            Move iQuoteHdrIdno to Quotedtl.QuotehdrID
                                            Find GE Quotedtl by Index.2
                                            While ((Found) and Quotedtl.QuotehdrID = iQuoteHdrIdno)
                                                Add Quotedtl.Amount to nSubTotal
                                                Add Quotedtl.TaxAmount to nTaxTotal
                                                Find GT Quotedtl by Index.2
                                            Loop
                                            Move iQuoteHdrIdno to Quotehdr.QuotehdrID
                                            Find EQ Quotehdr by Index.1
                                            If ((Found) and Quotehdr.QuotehdrID = iQuoteHdrIdno) Begin
                                                Reread Quotehdr
                                                    Move (nSubTotal+nTaxTotal) to nTotalAmount
                                                    Move nSubTotal to Quotehdr.SubTotal
                                                    Move nTaxTotal to Quotehdr.TaxTotal
                                                    Move nTotalAmount to Quotehdr.Amount
                                                    If (Quotehdr.Probability = 0) Begin
                                                        Move 20 to Quotehdr.Probability
                                                    End
                                                    If (Quotehdr.CloseDate = 0) Begin
                                                        Move (Quotehdr.QuoteDate+90) to Quotehdr.CloseDate
                                                    End
                                                    Save Quotehdr
                                                Unlock
                                            End
                                        End
                                    End
                                    //Move iQuoteHdrIdno to Quotedtl.QuotehdrID
                                    Find GT Quotedtl by Index.2
                                Loop
                                    
                            End_Procedure
                        
                        End_Object
        
                    End_Object
                    
                End_Object
        
                Object oTabPage4 is a TabPage
                    Set Label to 'Invoice Tools'
        
                    Object oInvoiceDateRangeUpdate is a Group
                        Set Size to 83 161
                        Set Location to 5 6
                        Set Label to 'Update Invoice Date Range'
        
                        Object oBeginDate is a Form
                            Set Size to 13 96
                            Set Location to 12 36
                            Set Label to "From:"
                            Set Label_Col_Offset to 5
                            Set Label_Justification_Mode to JMode_Right
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        End_Object
                        
                        Object oStopDate is a Form
                            Set Size to 13 96
                            Set Location to 27 36
                            Set Label to "To:"
                            Set Label_Col_Offset to 5
                            Set Label_Justification_Mode to JMode_Right
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        End_Object
                    End_Object
                End_Object
        
                Object oTabPage5 is a TabPage
                    Set Label to 'Equip Tools'
                    
                    Object oGroup5 is a Group
                        Set Size to 52 227
                        Set Location to 4 5
                        Set Label to 'Update Equipment - MastOps Relation'
                        
                        Object oEquipMastOpsFrom is a Form
                            Set Size to 13 73
                            Set Location to 14 98
                            Set Label to "Move Equip from MastOps:"
                            Set Label_Col_Offset to 5
                            Set Label_Justification_Mode to JMode_Right
                                                
                        End_Object
                    
                        Object oEquipMastOpsTo is a Form
                            Set Size to 13 73
                            Set Location to 30 98
                            Set Label to "to MastOps:"
                            Set Label_Col_Offset to 5
                            Set Label_Justification_Mode to JMode_Right                
                        End_Object
                        
                        
                        Object oStartButton is a Button
                            Set Size to 14 34
                            Set Location to 21 183
                            Set Label to 'START'
                            
                            
                            Procedure OnClick
                                Integer iCounter iMastOpsFrom iMastOpsTo eResponse
                                String sFromMastOpsName sToMastOpsName    
                                //Clear Output Grid
                                Send Delete_Data of oOnScreenOutput
                                //Get Entry Values
                                Get Value of oEquipMastOpsFrom to iMastOpsFrom
                                Get Value of oEquipMastOpsTo to iMastOpsTo
                                
                                Open MastOps
                                Clear MastOps
                                Move iMastOpsFrom to MastOps.MastOpsIdno
                                Find EQ MastOps by Index.1
                                If ((Found) and MastOps.MastOpsIdno = iMastOpsFrom) Begin
                                    Move MastOps.Name to sFromMastOpsName
                                    //
                                    Clear MastOps
                                    Move iMastOpsTo to MastOps.MastOpsIdno
                                    Find EQ MastOps by Index.1
                                    If ((Found) and MastOps.MastOpsIdno = iMastOpsTo) Begin
                                        Move MastOps.Name to sToMastOpsName
                                        /////////////////
                                        Get YesNo_Box ("Would like to continue moving all Equipment from MastOps: "*String(iMastOpsFrom)* sFromMastOpsName* " to" * String(iMastOpsTo)* sToMastOpsName* "?") "Move all Equipment?" MB_DEFBUTTON1 to eResponse
                                        If (eResponse = MBR_Yes) Begin
                                            Send AppendTextLn of oOnScreenOutput ("Updating Equipment relationship from " *String(iMastOpsFrom)* sFromMastOpsName* " to" * String(iMastOpsTo)* sToMastOpsName)
                                            Clear Equipmnt
                                            Move iMastOpsFrom to Equipmnt.MastOpsIdno
                                            Find ge Equipmnt.MastOpsIdno
                                            
                                            While ((Found)and Equipmnt.MastOpsIdno = iMastOpsFrom)
                                                Reread Equipmnt
                                                    Move iMastOpsTo to Equipmnt.MastOpsIdno
                                                    Move 1 to Equipmnt.ChangedFlag
                                                    SaveRecord Equipmnt
                                                Unlock
                                                Increment iCounter
                                                //
                                                Send AppendTextLn of oOnScreenOutput ("Moved Equipment#"*String(Equipmnt.EquipIdno)*Equipmnt.Description)
                                                //
                                                Move iMastOpsFrom to Equipmnt.MastOpsIdno         
                                                Find gt Equipmnt.MastOpsIdno
                                                
                                            Loop
                                            Send AppendTextLn of oOnScreenOutput ("Total:"*String(iCounter)*"records changed.")  
                                        End
                                        Else Procedure_Return
                                        
                                    End
                                    Else Begin
                                        Send Stop_Box ("Entered MastOps: " +String(iMastOpsTo) + " does not exist") "Error"
                                        Procedure_Return
                                    End
                                    
                                    
                                End
                                Else Begin
                                    Send Stop_Box ("Entered MastOps: " +String(iMastOpsFrom) + " does not exist") "Error"
                                    Procedure_Return
                                End
        
                            End_Procedure
                            
                        End_Object
                    End_Object
        
                    
                End_Object
        
                Object oTabPage6 is a TabPage
                    Set Label to 'Opers Tools'
        
                    Object oUpdateAllOpersGroup is a Group
                        Set Size to 84 245
                        Set Location to 5 5
                        Set Label to 'Update all Opers with MastOps defaults'
                
                        Object oUpdateButton is a Button
                            Set Size to 14 80
                            Set Location to 40 119
                            Set Label to 'Update'
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Boolean bStatus bPricing bDescription bName 
                                Move False to bStatus
                                Move False to bPricing
                                Move False to bDescription
                                Move False to bName
                                Integer iMastOpsIdno iAlternateMastOps iOpersUpdated
                                String sCurrentMastOpsStatus
                                
                                Get Checked_State of oStatusCheckBox to bStatus
                                Get Checked_State of oPricingCheckBox to bPricing
                                Get Checked_State of oDescriptionCheckBox to bDescription
                                Get Checked_State of oNameCheckBox to bName
                                
                                Get Value of oMastOpsIdno to iMastOpsIdno
                                If (iMastOpsIdno <> 0) Begin
                                    
                                    
                                End
                                Else Send Info_Box "Please select a valid MastOps before continuing." "Select MastOps"
                                
                                Move MastOps.Status to sCurrentMastOpsStatus
                                
                                If ((bStatus) or (bPricing) or (bDescription) or (bName)) Begin
                                    If ((bStatus) and sCurrentMastOpsStatus = "I") Begin
                                        // All Operations and Equipment should be re-assigned to a new MastOps
                                    End
                                    Get UpdateRelatedOpers of oOpersProcess iMastOpsIdno bStatus bPricing bDescription bName to iOpersUpdated
                                    Send Info_Box ("Updated" * (String(iOpersUpdated)) * "Opers records")
                                End
                                Else Begin
                                    Send Info_Box "You must select at lease one option to update"
                                End
                                
                
                            End_Procedure
                        
                        End_Object
                
                        Object oStatusCheckBox is a CheckBox
                            Set Size to 10 50
                            Set Location to 32 13
                            Set Label to 'Status'
                        
                            //Fires whenever the value of the control is changed
                            Procedure OnChange
                                Boolean bChecked
                            
                                Get Checked_State to bChecked
                            End_Procedure
                        
                        End_Object
                
                        Object oPricingCheckBox is a CheckBox
                            Set Size to 10 50
                            Set Location to 45 13
                            Set Label to 'Pricing'
                        
                            //Fires whenever the value of the control is changed
                            Procedure OnChange
                                Boolean bChecked
                            
                                Get Checked_State to bChecked
                            End_Procedure
                        
                        End_Object
                
                        Object oDescriptionCheckBox is a CheckBox
                            Set Size to 10 50
                            Set Location to 58 13
                            Set Label to 'Description'
                        
                            //Fires whenever the value of the control is changed
                            Procedure OnChange
                                Boolean bChecked
                            
                                Get Checked_State to bChecked
                            End_Procedure
                        
                        End_Object
        
                        Object oNameCheckBox is a CheckBox
                            Set Size to 10 50
                            Set Location to 71 13
                            Set Label to 'Name'
                        
                            //Fires whenever the value of the control is changed
                            Procedure OnChange
                                Boolean bChecked
                            
                                Get Checked_State to bChecked
                            End_Procedure
                        
                        End_Object
        
                        Object oMastOpsIdno is a Form
                            Set Size to 13 42
                            Set Location to 12 13
                            Set Prompt_Button_Mode to PB_PromptOn
                            
                            
                            Procedure Prompt
                                Integer iMastOps
                                Get Value of oMastOpsIdno to iMastOps
                                Get SelectMastOps of Mastops_sl iMastOps to iMastOps
                                Set Value of oMastOpsIdno to iMastOps
                            End_Procedure
                        
                            //OnChange is called on every changed character
                        
                            //Procedure OnChange
                            //    String sValue
                            //
                            //    Get Value to sValue
                            //End_Procedure
                        
                        End_Object
        
                        Object oMastOpsName is a Form
                            Set Enabled_State to False
                            Set Size to 13 174
                            Set Location to 12 58
                        
                            //OnChange is called on every changed character
                        
                            //Procedure OnChange
                            //    String sValue
                            //
                            //    Get Value to sValue
                            //End_Procedure
                        
                        End_Object
                          
                    End_Object
                End_Object
        
        
                Object oTabPage7 is a TabPage
                    Set Label to 'Location Tools'
        
                    Object oGroup8 is a Group
                        Set Size to 42 265
                        Set Location to 4 5
                        Set Label to 'Add Universal MastOps'
        
                        Object oLocationIdno is a Form
                            Set Size to 13 46
                            Set Location to 17 53
                            Set Label to "LocationIdno:"
                            Set Label_Col_Offset to 5
                            Set Label_Justification_Mode to JMode_Right
                        
                            //OnChange is called on every changed character
                        
                            //Procedure OnChange
                            //    String sValue
                            //
                            //    Get Value to sValue
                            //End_Procedure
                        
                        End_Object
        
                        Object oButton4 is a Button
                            Set Location to 16 113
                            Set Label to 'Go'
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Integer iLocIdno iCreated iErrors
                                Get Value of oLocationIdno to iLocIdno
                                Open Location
                                Clear Location
                                Move iLocIdno to Location.LocationIdno
                                Find EQ Location by Index.1
                                If ((Found) and iLocIdno = Location.LocationIdno) Begin
                                    Send Delete_Data of oOnScreenOutput
                                    Send AppendTextLn of oOnScreenOutput "Starting"
                                    Send AppendTextLn of oOnScreenOutput ("Adding all Universal MastOps to "* Location.Name * "("+String(Location.LocationIdno)+")")
                                    Get DoAddUniversalMastOpsToLocation of oOperationsProcess Location.LocationIdno "P" (&iErrors) to iCreated
                                    If (iErrors > 1) Begin
                                        Send AppendTextLn of oOnScreenOutput (String(iCreated) * "Operations created." * String(iErrors) * "errors.")
                                    End                            
                                End
                                Else Begin
                                    Send AppendTextLn of oOnScreenOutput ("Location not found!") "Location not found!"
                                End
                                Send AppendTextLn of oOnScreenOutput ("Completed - Created" + String(iCreated))
                            End_Procedure
                        
                        End_Object
                    End_Object
                    
                    
                    
                End_Object
        
                Object oTabPage8 is a TabPage
                    Set Label to 'QuickBooks Tools'
        
                    Object oGroup9 is a Group
                        Set Size to 55 250
                        Set Location to 7 14
                        Set Label to 'Paid Status and Date update'
        
                        Object oStartDate is a Form
                            Set Size to 13 100
                            Set Location to 16 59
                            Set Label to "Start Date"
                            Set Label_Col_Offset to 5
                            Set Label_Justification_Mode to JMode_Right
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        End_Object
        
                        Object oStopDate is a Form
                            Set Size to 13 100
                            Set Location to 33 59
                            Set Label to "Stop Date"
                            Set Label_Col_Offset to 5
                            Set Label_Justification_Mode to JMode_Right
                            Set Form_Datatype to Mask_Date_Window
                            Set Prompt_Button_Mode to PB_PromptOn
                            Set Prompt_Object to oMonthCalendarPrompt
                        End_Object
        
                        Object oButton6 is a Button
                            Set Location to 23 178
                            Set Label to "Start"
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Date dStart dStop
                                Integer iFoundCount iChangeCount
                                Boolean bSuccess
                                //
                                Get Value of oStartDate to dStart
                                Get Value of oStopDate to dStop
                                If (dStart = 0 or dStop = 0) Begin
                                    Send Info_Box ("Please enter Valid Date Range") "Date Range Error"
                                End
                                Else Begin
                                    Get QBInvPaidStatusManualDateRange of oInvoicePostingProcess dStart dStop (&iFoundCount) (&iChangeCount) to bSuccess
                                    If (bSuccess) Begin
                                        
                                    End                            
                                End
                            End_Procedure
                        
                        End_Object
                    End_Object
                End_Object
        
                Object oTabPage9 is a TabPage
                    Set Label to "Employer Tools"
        
                    Object oWebAppUserGroup is a Group
                        Set Size to 42 265
                        Set Location to 4 5
                        Set Label to 'WebAppUser Mass Creation'
        
                        Object oButton8 is a Button
                            Set Size to 14 95
                            Set Location to 18 25
                            Set Label to 'Create WebAppUsers'
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Integer iEmployerIdno
                                Boolean bPreviewChecked
                                //
                                Get Checked_State of oPreviewCheckBox to bPreviewChecked
                                //
                                Send Delete_Data of oOnScreenOutput
                                Send AppendTextLn of oOnScreenOutput "START"
                                //
                                Open Employer
                                Clear Employer
                                Find GE Employer by 1
                                While (Found)
                                    If (Employer.Status="A") Begin
                                        // EMPLOYER FOUND
                                        Send AppendTextLn of oOnScreenOutput ("Active Employer Found"*String(Employer.EmployerIdno)* Trim(Employer.Name)) 
                                        Move Employer.EmployerIdno to iEmployerIdno
                                        Open Employee
                                        Clear Employee
                                        Move iEmployerIdno to Employee.EmployerIdno
                                        Find GE Employee by 8
                                        While ((Found) and Employee.EmployerIdno = iEmployerIdno)
                                            If (Employee.Status = "A") Begin
                                                //Update Changes to Employee Name, PIN etc. to the WebAppUser table
                                                Clear WebAppUser
                                                Move Employee.EmployeeIdno to WebAppUser.LoginName
                                                Find EQ WebAppUser by 1
                                                If ((Found) and Employee.EmployeeIdno = WebAppUser.LoginName) Begin
                                                    // UPDATE RECORD
                                                    Reread WebAppUser
                                                        Send AppendTextLn of oOnScreenOutput ("--> UPDATED: Employee#"*String(Employee.EmployeeIdno)* Trim(Employee.FirstName*Employee.LastName))
                                                        Move (Trim(Employee.FirstName)*Trim(Employee.LastName)) to WebAppUser.FullName
                                                        Move Employee.PIN to WebAppUser.Password
                                                        Move Employee.EmployeeIdno to WebAppUser.EmployeeIdno
                                                        Move Employee.Status to WebAppUser.Status
                                                        Move 1 to WebAppUser.ChangedFlag
                                                        If (not(bPreviewChecked)) Begin
                                                            SaveRecord WebAppUser
                                                        End
                                                    Unlock
                                                End
                                                Else Begin //Does not exists yet, therefor create
                                                    //CREATE NEW
                                                    Clear WebAppUser
                                                    Lock
                                                        Send AppendTextLn of oOnScreenOutput ("--> CREATING: Employee#"*String(Employee.EmployeeIdno)* Trim(Employee.FirstName*Employee.LastName))
                                                        Move Employee.EmployeeIdno to WebAppUser.LoginName
                                                        Move Employer.EmployerIdno to WebAppUser.EmployerIdno
                                                        Move (Trim(Employee.FirstName)*Trim(Employee.LastName)) to WebAppUser.FullName
                                                        Move Employee.PIN to WebAppUser.Password
                                                        Move Employee.EmployeeIdno to WebAppUser.EmployeeIdno
                                                        Move Employee.Status to WebAppUser.Status
                                                        Move 1 to WebAppUser.ChangedFlag
                                                        If (not(bPreviewChecked)) Begin 
                                                            SaveRecord WebAppUser
                                                        End
                                                    Unlock
                                                End
                                            End
                                            Find GT Employee by 8
                                        Loop
                                    End
                                    Find GT Employer by 1
                                Loop
                                Send AppendTextLn of oOnScreenOutput "Finished"
                            End_Procedure
                        End_Object
                        
                        Object oPreviewCheckBox is a CheckBox
                            Set Size to 10 50
                            Set Location to 20 150
                            Set Label to 'Preview Only'
                            Set Checked_State to True
                        
                            // Fires whenever the value of the control is changed
                        //    Procedure OnChange
                        //        Boolean bChecked
                        //    
                        //        Get Checked_State to bChecked
                        //    End_Procedure
                        
                        End_Object
                    End_Object
        
                    Object oEmployerStatusGroup is a Group
                        Set Size to 44 263
                        Set Location to 50 5
                        Set Label to 'Employer Status Mass Update'
        
                        Object oEmployerStatusButton is a Button
                            Set Size to 14 95
                            Set Location to 18 25
                            Set Label to 'Update Employer Status'
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Integer iEmployerIdno
                                Boolean bPreviewChecked
                                //
                                Get Checked_State of oPreviewStatusCheckBox to bPreviewChecked
                                //
                                Send Delete_Data of oOnScreenOutput
                                Send AppendTextLn of oOnScreenOutput "START"
                                //
                                Open Employer
                                Clear Employer
                                Find GE Employer by 1
                                While (Found)
                                    If (Employer.Status <> "A") Begin
                                        Move Employer.EmployerIdno to iEmployerIdno
                                        Send ChangeEmployerStatus of oEmployerTasks iEmployerIdno "I" True bPreviewChecked
                                        
        //                                // EMPLOYER FOUND
        //                                Send AppendTextLn of oOnScreenOutput ("Inactive Employer Found"*String(Employer.EmployerIdno)* Trim(Employer.Name)) 
        //                                // EMPLOYEE
        //                                Open Employee
        //                                Clear Employee
        //                                Move iEmployerIdno to Employee.EmployerIdno
        //                                Find GE Employee by 8
        //                                While ((Found) and Employee.EmployerIdno = iEmployerIdno)
        //                                    Send AppendTextLn of oOnScreenOutput ("-->Employee#"*String(Employee.EmployeeIdno)* Trim(Employee.FirstName*Employee.LastName))
        //                                    // Deactivate the Employee
        //                                    Reread Employee
        //                                        Move "I" to Employee.Status
        //                                        Move 1 to Employee.ChangedFlag
        //                                        If (not(bPreviewChecked)) Begin
        //                                            SaveRecord Employee
        //                                        End
        //                                    Unlock
        //                                    Find GT Employee by 8
        //                                Loop
        //                                // EQUIPMENT
        //                                Open Equipmnt
        //                                Clear Equipmnt
        //                                Move iEmployerIdno to Equipmnt.OperatedBy
        //                                Find GE Equipmnt by 4
        //                                While ((Found) and Equipmnt.OperatedBy = iEmployerIdno)
        //                                    Send AppendTextLn of oOnScreenOutput ("-->Equipmnet#"*String(Equipmnt.EquipIdno)* Trim(Equipmnt.Description))
        //                                    // Deactivate the Employee
        //                                    Reread Equipmnt
        //                                        Move "I" to Equipmnt.Status
        //                                        Move 1 to Equipmnt.ChangedFlag
        //                                        If (not(bPreviewChecked)) Begin
        //                                            SaveRecord Equipmnt
        //                                        End
        //                                    Unlock
        //                                    Find GT Equipmnt by 4
        //                                Loop
        
                                    End
                                    Find GT Employer by 1
                                Loop
                                Send AppendTextLn of oOnScreenOutput "Finished"
                            End_Procedure
                        
                        End_Object
                        Object oPreviewStatusCheckBox is a CheckBox
                            Set Size to 10 50
                            Set Location to 20 150
                            Set Label to 'Preview Only'
                            Set Checked_State to True
                        
                            // Fires whenever the value of the control is changed
                        //    Procedure OnChange
                        //        Boolean bChecked
                        //    
                        //        Get Checked_State to bChecked
                        //    End_Procedure
                        
                        End_Object
                        
                        
                    End_Object
                    
                    
                    
                    
                End_Object
        
                Object oTabPage10 is a TabPage
                    Set Label to 'User Tools'
        
                    Object oGroup11 is a Group
                        Set Size to 44 261
                        Set Location to 8 9
                        Set Label to 'Mass Update Passwords'
        
                        Object oPasswordGernatorButton is a Button
                            Set Location to 20 17
                            Set Label to "Generate"
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                String sNewPass
                                Integer iUserCount iUserPropMgr iUserChangeCount
                                Boolean bPreviewChecked
                                //
                                Get Checked_State of oPreviewCheckBox to bPreviewChecked
                                //
                                Send Delete_Data of oOnScreenOutput
                                Send AppendTextLn of oOnScreenOutput ("STARTING")
                                Send AppendTextLn of oOnScreenOutput ("Starting Mass Password Auto Generate Process")
                                If (bPreviewChecked) Begin
                                    Send AppendTextLn of oOnScreenOutput ("PREVIEW ONLY - No Changes are saved")
                                End
                                Clear User
                                Find GE User by 1
                                While ((Found))
                                    Increment iUserCount
                                    If (User.CustContactId <> 0) Begin
                                        Increment iUserPropMgr
                                        //Get GenerateRandomPassword 8 False True True True to sNewPass
                                        Get GenerateRandomPassword 16 True True True True to sNewPass
                                        Send AppendTextLn of oOnScreenOutput ("Updating User:"* Trim(User.FirstName*User.LastName))
                                        Send AppendTextLn of oOnScreenOutput ("Old Password:"* User.Password * "--> New Password:" * sNewPass)
                                        If (not(bPreviewChecked)) Begin
                                            Reread User
                                            Move sNewPass to User.Password
                                            Move 1 to User.ChangedFlag
                                            SaveRecord User
                                            Increment iUserChangeCount
                                            Unlock
                                        End
                                    End
                                    Find GT User by 1
                                Loop
                                Send AppendTextLn of oOnScreenOutput ("Stopping Mass Password Auto Generate Process")
                                Send AppendTextLn of oOnScreenOutput (" - Total User Count:"*String(iUserCount))
                                Send AppendTextLn of oOnScreenOutput (" - Property Mgr Count:"*String(iUserPropMgr))
                                Send AppendTextLn of oOnScreenOutput (" - Changed User Count:"*String(iUserChangeCount))
                                Send AppendTextLn of oOnScreenOutput ("COMPLETED")
                            End_Procedure
        
                        
                        End_Object
                        
                        Object oPreviewCheckBox is a CheckBox
                            Set Size to 10 50
                            Set Location to 22 96
                            Set Label to "Preview Only"
                            Set Checked_State to True
                        
                            //Fires whenever the value of the control is changed
                            //Procedure OnChange
                            //    Boolean bChecked
                            //
                            //    Get Checked_State To bChecked
                            //End_Procedure
                        
                        End_Object
                        
                    End_Object
        
                    Object oWebAppUserGroup is a Group
                        Set Size to 42 265
                        Set Location to 54 6
                        Set Label to 'WebAppUser Mass Creation - Property Managers'
        
                        Object oButton8 is a Button
                            Set Size to 14 141
                            Set Location to 18 5
                            Set Label to 'Create WebAppUsers for Property Managers'
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Integer iCustContactIdno iPropertyMgrIdno
                                Boolean bPreviewChecked
                                //
                                Get Checked_State of oPreviewCheckBox to bPreviewChecked
                                //
                                Send Delete_Data of oOnScreenOutput
                                Send AppendTextLn of oOnScreenOutput "START"
                                //
                                
                                Open Order
                                Clear Order
                                Move "O" to Order.Status
                                Move "S" to Order.WorkType
                                Find GE Order by 12
                                While ((Found) and Order.Status = "O")
                                    If (Order.WorkType = "S") Begin
                                        Relate Order
                                        Send AppendTextLn of oOnScreenOutput ("Found Job# "*String(Order.JobNumber)* Order.Title)
                                        If (Location.PropmgrIdno <> 0) Begin
                                            Move Location.PropmgrIdno to iPropertyMgrIdno
                                            // Check WebAppUser Table first!
                                            Clear WebAppUser
                                            Move iPropertyMgrIdno to WebAppUser.PropertyMgrIdno
                                            Find GE WebAppUser.PropertyMgrIdno
                                            If ((Found) and WebAppUser.PropertyMgrIdno = iPropertyMgrIdno) Begin
                                                //We dont have to do anything, because he already has a WebAppUser account setup.
                                                Send AppendTextLn of oOnScreenOutput ("--> WebAppUser Already Exsists for Property Manager#"*String(iPropertyMgrIdno)* Trim(WebAppUser.FullName))
                                            End
                                            Else Begin
                                                // Prefer exsisting User Account to gernerate new WebAppUser account.
                                                Open User
                                                Clear User
                                                Move iPropertyMgrIdno to User.CustContactId
                                                Find GE User by 5
                                                If ((Found) and User.CustContactId = iPropertyMgrIdno) Begin
                                                    //User account was found and will be used to generate new WebAppUser account with same credentials
                                                    Clear WebAppUser
                                                    Lock
                                                        Send AppendTextLn of oOnScreenOutput ("CREATING FROM USER TABLE: Property Manager#"*String(iPropertyMgrIdno)*" - Name:"* Trim(User.FirstName*User.LastName)*" - User Name:"*Trim(User.LoginName))
                                                        Move User.LoginName to WebAppUser.LoginName
                                                        Move User.CustContactId to WebAppUser.PropertyMgrIdno
                                                        Move (Trim(User.FirstName)*Trim(User.LastName)) to WebAppUser.FullName
                                                        Move User.Password to WebAppUser.Password
                                                        Move 0 to WebAppUser.EmployeeIdno
                                                        Move "A" to WebAppUser.Status
                                                        Move 1 to WebAppUser.BillingAccessFlag
                                                        Move 1 to WebAppUser.ChangedFlag
                                                        If (not(bPreviewChecked)) Begin 
                                                            SaveRecord WebAppUser
                                                        End
                                                    Unlock
                                                End
                                                Else Begin
                                                    //If the old User account does not exsist, use the Contact table to gernerate new WebApp User account with new credentials
                                                    Clear Contact
                                                    Move iPropertyMgrIdno to Contact.ContactIdno
                                                    Find GE Contact.ContactIdno
                                                    If ((Found) and Contact.ContactIdno = iPropertyMgrIdno) Begin
                                                        Clear WebAppUser
                                                        Lock
                                                            Send AppendTextLn of oOnScreenOutput ("CREATING FROM CONTACT TABLE: Property Manager#"*String(iPropertyMgrIdno)* Trim(Contact.FirstName*Contact.LastName))
                                                            String sUserName sNewPass
                                                            Get GeneratePropMgrUsername Contact.FirstName Contact.LastName to sUserName
                                                            Move sUserName to WebAppUser.LoginName
                                                            Move Contact.ContactIdno to WebAppUser.PropertyMgrIdno
                                                            Move (Trim(Contact.FirstName)*Trim(Contact.LastName)) to WebAppUser.FullName
                                                            Get GenerateRandomPassword 6 False True True True to sNewPass
                                                            Move sNewPass to WebAppUser.Password
                                                            Move 0 to WebAppUser.EmployeeIdno
                                                            Move Contact.Status to WebAppUser.Status
                                                            Move 1 to WebAppUser.BillingAccessFlag
                                                            Move 1 to WebAppUser.ChangedFlag
                                                            If (not(bPreviewChecked)) Begin 
                                                                SaveRecord WebAppUser
                                                            End
                                                        Unlock
                                                    End
                                                End
                                            End
                                        End
                                    End
                                    Find GT Order by 12
                                Loop
                                Send AppendTextLn of oOnScreenOutput "Finished"
                            End_Procedure
                        End_Object
                        
                        Object oPreviewCheckBox is a CheckBox
                            Set Size to 10 50
                            Set Location to 20 150
                            Set Label to 'Preview Only'
                            Set Checked_State to True
                        
                            // Fires whenever the value of the control is changed
                        //    Procedure OnChange
                        //        Boolean bChecked
                        //    
                        //        Get Checked_State to bChecked
                        //    End_Procedure
                        
                        End_Object
                    End_Object
                    
                    
                End_Object
        
                Object oTabPage11 is a TabPage
                    Set Label to 'Contact Tools'
        
                    Object oGroup12 is a Group
                        Set Size to 50 271
                        Set Location to 0 0
                        Set Label to 'Merge Contact Groups'
        
                        Object oMergeFromForm is a Form
                            Set Size to 13 100
                            Set Location to 20 8
                            Set Label to "From:"
                            Set Label_Col_Offset to 0
                            Set Label_FontWeight to fw_Bold
                            Set Label_Justification_Mode to JMode_Top
                        
                            // OnChange is called on every changed character
                        //    Procedure OnChange
                        //        String sValue
                        //    
                        //        Get Value to sValue
                        //    End_Procedure
                        
                        End_Object
        
                        Object oMergeToForm is a Form
                            Set Size to 13 100
                            Set Location to 20 162
                            Set Label to "To:"
                            Set Label_Col_Offset to 0
                            Set Label_FontWeight to fw_Bold
                            Set Label_Justification_Mode to JMode_Top
                        
                            // OnChange is called on every changed character
                        //    Procedure OnChange
                        //        String sValue
                        //    
                        //        Get Value to sValue
                        //    End_Procedure
                        
                        End_Object
                        
                        Object oPreviewCheckBox is a CheckBox
                            Set Size to 10 50
                            Set Location to 36 9
                            Set Label to "Preview Only"
                            Set Checked_State to True
                        
                            //Fires whenever the value of the control is changed
                            //Procedure OnChange
                            //    Boolean bChecked
                            //
                            //    Get Checked_State To bChecked
                            //End_Procedure
                        
                        End_Object
        
                        Object oMergeToButton is a Button
                            Set Location to 19 110
                            Set Label to 'Merge'
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Integer iMergeFromListNumber iMergeToListNumber iCurrentContact eResponse
                                String sMergeToGroupName
                                Boolean bPreviewChecked
                                
                                Get Value of oMergeFromForm to iMergeFromListNumber
                                Get Value of oMergeToForm to iMergeToListNumber
                                Get Checked_State of oPreviewCheckBox to bPreviewChecked
                                
                                Clear MarketGroup
                                Move iMergeToListNumber to MarketGroup.MktGroupIdno
                                Find EQ MarketGroup by 1
                                If ((Found) and MarketGroup.MktGroupIdno = iMergeToListNumber) Begin
                                    Move MarketGroup.GroupName to sMergeToGroupName
                                    //
                                    Send Delete_Data of oOnScreenOutput
                                    Send AppendTextLn of oOnScreenOutput ("STARTING")
                                    Send AppendTextLn of oOnScreenOutput ("Starting MarketMember Merging Process")
                                    Clear MarketMember
                                    Move iMergeFromListNumber to MarketMember.MktGroupIdno
                                    Find GE MarketMember by 3
                                    While ((Found) and MarketMember.MktGroupIdno = iMergeFromListNumber)
                                        Relate MarketMember
                                        Move MarketMember.ContactIdno to iCurrentContact
                                        Send AppendTextLn of oOnScreenOutput ("Found:" * MarketMember.GroupName)
                                        If (not(bPreviewChecked)) Begin
                                            Reread MarketMember
                                                Move iMergeToListNumber to MarketMember.MktGroupIdno
                                                Move sMergeToGroupName to MarketMember.GroupName
                                                SaveRecord MarketMember
                                                If (err) Begin
                                                    Send AppendTextLn of oOnScreenOutput (" --->>> ERROR with Record:"* String(MarketMember.ContactIdno) *"-"* Contact.FirstName * Contact.LastName)
                                                    // Delete Record
                                                    Move iMergeFromListNumber to MarketMember.MktGroupIdno
                                                    Move iCurrentContact to MarketMember.ContactIdno
                                                    Find EQ MarketMember by 3
                                                    If ((Found) and MarketMember.ContactIdno = iCurrentContact and MarketMember.MktGroupIdno = iMergeFromListNumber) Begin
                                                        Send AppendTextLn of oOnScreenOutput (" --->>> DELETING Record:"* MarketGroup.GroupName*" - Member:" * String(MarketMember.ContactIdno) *"-"* Contact.FirstName * Contact.LastName)
                                                        Delete MarketMember
                                                    End
                                                    Move False to Err
                                                End
                                                Else Begin
                                                    Send AppendTextLn of oOnScreenOutput (" --->>>  Changed to:"* sMergeToGroupName)
                                                End
                                            Unlock
                                            
                                        End
                                        Clear MarketMember
                                        Move iMergeFromListNumber to MarketMember.MktGroupIdno
                                        Move iCurrentContact to MarketMember.ContactIdno
                                        Find GT MarketMember by 3
                                    Loop
                                    Send AppendTextLn of oOnScreenOutput "FINISHED"
                                End
                                Else Begin
                                    Send Info_Box "Target Group not found" "Error"
                                End
                                
                            End_Procedure
                        
                        End_Object
        
                        
                        
                        
                    End_Object
                    
                    
                End_Object
        
                Object oTabPage12 is a TabPage
                    Set Label to 'Base64Test'
        
                    Object oCharTranslate is a cCharTranslate
                    End_Object
        
                    Object oSeqFileHelper1 is a cSeqFileHelper
                    End_Object
        
                    Object oButton9 is a Button
                        Set Size to 14 170
                        Set Location to 20 47
                        Set Label to 'Encode / Decode'
                    
                        // fires when the button is clicked
                        Procedure OnClick
                            Integer iLocIdno iFileCount iLoopCount iArraySize
                            Integer iEncodeBinSize
                            UChar[] ucEncodeString
                            String sHomePath sSourcePath sTargetPath
                            String[] sFileName
                            //
                            Move 4430 to iLocIdno
                            Open Location
                            Move iLocIdno to Location.LocationIdno
                            Find EQ Location.LocationIdno
                            If ((Found) and Location.LocationIdno = iLocIdno) Begin
                                If (Length(Trim(Location.Image1))>=1) Begin
                                    Increment iFileCount
                                    Move (Trim(Location.Image1)) to sFileName[iFileCount]
                                End
                                 If (Length(Trim(Location.Image2))>=1) Begin
                                    Increment iFileCount
                                    Move (Trim(Location.Image2)) to sFileName[iFileCount]
                                End                       
                                If (Length(Trim(Location.Image3))>=1) Begin
                                    Increment iFileCount
                                    Move (Trim(Location.Image3)) to sFileName[iFileCount]
                                End
                                If (Length(Trim(Location.Image4))>=1) Begin
                                    Increment iFileCount
                                    Move (Trim(Location.Image4)) to sFileName[iFileCount]
                                End
                                If (Length(Trim(Location.Image5))>=1) Begin
                                    Increment iFileCount
                                    Move (Trim(Location.Image5)) to sFileName[iFileCount]
                                End
                            End
                            Get psHome of (phoWorkspace(ghoApplication)) to sHomePath
                            Move (sHomePath+"Bitmaps\Snowbooks\") to sSourcePath
                            Move (sHomePath+"Bitmaps\Snowbooks\Decoded\") to sTargetPath
                            //
                            Send Delete_Data of oOnScreenOutput
                            Send AppendTextLn of oOnScreenOutput ("Started")
                            Send AppendTextLn of oOnScreenOutput ("SourcePath:"*sSourcePath)
                            Move (SizeOfArray(sFileName)-1) to iArraySize
                            If (iArraySize<=0) Begin
                                Send AppendTextLn of oOnScreenOutput ("No Pictures attached to this Location")
                                Procedure_Return
                            End
                            For iLoopCount from 1 to iArraySize
                                //Send AppendTextLn of oOnScreenOutput ("FileName"*sFileName[iLoopCount])
                                Send AppendTextLn of oOnScreenOutput ("ENCODE: Source File:"*(sSourcePath+sFileName[iLoopCount]))
                                Send Base64EncodeFile sSourcePath (&sFileName[iLoopCount]) (&iEncodeBinSize) (&ucEncodeString)
                                //
                                Send Base64DecodeFile sTargetPath sFileName[iLoopCount] iEncodeBinSize ucEncodeString
                            Loop
                        End_Procedure
                    
                    End_Object

                    Object oEmailDialogButton is a Button
                        Set Size to 14 224
                        Set Location to 100 49
                        Set Label to 'EmailDialogButton'
                    
                        // fires when the button is clicked
                        Procedure OnClick
                            Boolean bSuccess
                            tEmail eMessage
                            //BEN: Remove after testing filling the Array by triggering object
                            //FROM
                            Move "no-reply@interstatepm.com" to eMessage.sFromEmail
                            //TO
                            Move "Benjamin Bungarten" to eMessage.stToEmail[0].sFriendlyName
                            Move "ben@interstatepm.com" to eMessage.stToEmail[0].sEmailAddress
                            Move "Ben Personal" to eMessage.stToEmail[1].sFriendlyName
                            Move "ben@bungartenweb.com" to eMessage.stToEmail[1].sEmailAddress
                            //CC
                            Move "Ben Personal 2" to eMessage.stCCEmail[0].sFriendlyName
                            Move "b00ngarten@gmail.com" to eMessage.stCCEmail[0].sEmailAddress
                            // ReplyTo:
                            Move "Kristin Larson" to eMessage.stReplyTo[0].sFriendlyName
                            Move "kristin@interstatepm.com" to eMessage.stReplyTo[0].sEmailAddress
                            //Move "Jeff Towers" to eMessage.stReplyTo[1].sFriendlyName
                            //Move "jeff@interstatepm.com" to eMessage.stReplyTo[1].sEmailAddress
                            //ATTACHMENTS
                            Move "D:\Development Projects\VDF19.1 Workspaces\Tempus\Reports\Cache\SubcontractorAgreements\Chilo Exteriors-Contractor#378.pdf" to eMessage.sAttachmentFilePath[0]
                            Move "D:\Development Projects\VDF19.1 Workspaces\Tempus\Reports\Cache\SubcontractorAgreements\Chilo Exteriors-Contractor#378.pdf" to eMessage.sAttachmentFilePath[1]
                            Move "D:\Development Projects\VDF19.1 Workspaces\Tempus\Reports\Cache\SubcontractorAgreements\Chilo Exteriors-Contractor#378.pdf" to eMessage.sAttachmentFilePath[2]
                            //SUBJECT
                            Move "Test Message" to eMessage.sSubject
                            //BODY
                            Move "This is the email body" to eMessage.sBody
                            //
                            Get OpenEmailMessage of (oEmailSend(Self)) eMessage to bSuccess
                            
                        End_Procedure
                    
                    End_Object
                    
                    Procedure Base64EncodeFile String sSourcePath String ByRef sFileName Integer ByRef iEncodeBinSize UChar[] ByRef ucEncodeString
                        Address aEncodeBuffer iArgSize
                        String sEncodeString
                        //UChar[] ucEncodeString
                        // ENCODE
                        Get ReadBinFileToBuffer of oSeqFileHelper1 (sSourcePath+sFileName) (&iEncodeBinSize) to aEncodeBuffer
                        //
                        Get_Argument_Size to iArgSize
                        Set_Argument_Size (iEncodeBinSize*2) // set String Size to to filesize + 1kb to ensure propper file transfer
                        Send AppendTextLn of oOnScreenOutput ("Set ArgSize from:"*String(iArgSize)*" to:"*String(iEncodeBinSize*2))
                        Send AppendTextLn of oOnScreenOutput ("Size:"*String(iEncodeBinSize)+'b |'*String(iEncodeBinSize/1024)+'kb')
                        //
                        //Get Base64EncodeToVariantStr of oCharTranslate aEncodeBuffer iEncodeBinSize to vEncodeString
                        //Send AppendTextLn of oOnScreenOutput ('--------------------------------Start of Variant----------------------------')
                        //Send AppendTextLn of oOnScreenOutput (vEncodeString)
                        //Send AppendTextLn of oOnScreenOutput ('---------------------------------End of Variant-----------------------------')
                        Move (StringToUCharArray(Base64EncodeToStr(oCharTranslate, aEncodeBuffer, iEncodeBinSize))) to ucEncodeString
                        //
                        
                        //Get Base64EncodeToStr of oCharTranslate aEncodeBuffer iEncodeBinSize to sEncodeString
                        //Move (StringToUCharArray(Base64EncodeToStr(oCharTranslate,aEncodeBuffer,iEncodeBinSize))) to ucEncodeString
                        //Variant vtest
                        //Move (UCharArrayToString(ucEncodeString)) to vtest
                        //Send AppendTextLn of oOnScreenOutput ('--------------------------------Start of String----------------------------')
                        //Send AppendTextLn of oOnScreenOutput (vtest)
                        //Send AppendTextLn of oOnScreenOutput ('---------------------------------End of String-----------------------------')
                        Set_Argument_Size iArgSize // reset String size back to default 64kb or 65536b
                    End_Procedure
                    
                    Procedure Base64DecodeFile String sDecodePathOfFile String sFileName Integer iEncodeBinSize UChar[] ucEncodeString
                        String sTargetPathFile sEncodeString 
                        Address aDecodeBuffer
                        Integer iDecodeBinSize iVoid
                        // DECODE
                        //Variant vtest
                        //Move (UCharArrayToString(ucEncodeString)) to vtest
                        Set_Argument_Size (iEncodeBinSize*2)
                        Move (UCharArrayToString(ucEncodeString)) to sEncodeString
                        Get Base64DecodeFromStr of oCharTranslate sEncodeString (&iDecodeBinSize) to aDecodeBuffer
                        If (iEncodeBinSize <> iDecodeBinSize) Begin
                            //Send Info_Box "Test Failed"
                            Send AppendTextLn of oOnScreenOutput "Decoding failed - mismatching file size!"
                        End
                        Else Begin
                            Move (sDecodePathOfFile+Trim(sFileName)) to sTargetPathFile
                            Send WriteBinFileFromBuffer of oSeqFileHelper1 sTargetPathFile aDecodeBuffer iDecodeBinSize
                        End
                        Move (Free(aDecodeBuffer)) to iVoid
                        
                        
        //                String sFile sLine
        //                Date dNow dFileDate
        //                DateTime dtNow dtFileModTime
        //                TimeSpan tsTimeDiff
        //                Integer iFileHour iFileMinute iFileSecond iFileCount
        //                // PREP
        //                Move (CurrentDateTime()) to dtNow
        //                Send AppendTextLn of oOnScreenOutput ("Started"*String(dtNow))
        //                
        //                Send AppendTextLn of oOnScreenOutput ("LocIdno:"*String(iLocIdno))
        //                //
        //                // Get the values. 
        //                
        //                // Reads and lists all contend of folder submitted
        //                Send AppendTextLn of oOnScreenOutput ("All files in folder:")
        //                Direct_Input ("dir: " + sSourcePath)
        //                Repeat
        //                    Readln sLine
        //                    Increment iFileCount
        //                    If (iFileCount>2 and Length(sLine)>=1) Begin
        //                        Move (sSourcePath+sLine) to sFile
        //                        Get_File_Mod_Time sFile to dFileDate iFileHour iFileMinute iFileSecond
        //                        Send AppendTextLn of oOnScreenOutput (sFile*'-'*String(dFileDate)*'- Time:'*String(iFileHour)+':'+String(iFileMinute)+':'+String(iFileSecond))
        //                        Move (dFileDate) to dtFileModTime
        //                        Move (DateAddHour(dtFileModTime,iFileHour)) to dtFileModTime
        //                        Move (DateAddMinute(dtFileModTime,iFileMinute)) to dtFileModTime
        //                        Move (DateAddSecond(dtFileModTime,iFileSecond)) to dtFileModTime
        //                        Move (dtNow - dtFileModTime) to tsTimeDiff
        //                        Send AppendTextLn of oOnScreenOutput ('dtNow:'*String(dtNow)*'- dtFileModTime:'*String(dtFileModTime)*' - TimeDiff:'*String(tsTimeDiff))
        //                    End
        //                Until (SeqEof)
        //                Send AppendTextLn of oOnScreenOutput "Completed"
        //                //
        //                // Reads and lists files from folder submitted
        //                Send AppendTextLn of oOnScreenOutput ("Files for LocIdno:"*String(iLocIdno))
        //                Integer iLoopCount
        //                Boolean bFileExists
        //                For iLoopCount from 1 to 5
        //                    Move (sSourcePath+String(iLocIdno)+"_"+String(iLoopCount)+".*") to sFile
        //                    Send AppendTextLn of oOnScreenOutput ("File:"*sFile)
        //                    //Check if file exsists for each loop
        //                    File_Exist sFile bFileExists
        //                    If (bFileExists) Begin
        //                        //ENCODE FILE HERE
        //                        Send AppendTextLn of oOnScreenOutput ("File to Encode:"*String(iLocIdno)+"_"+String(iLoopCount)+".*")
        //                    End
        //                    
        //                Loop
        
        
                    End_Procedure  
                    
        //            Function Base64DecodeFile String sDecodePath
        //                Address aEncodeBuffer aDecodeBuffer
        //                Variant vVariant
        //                Integer iEncodeBinSize iDecodeBinSize iVoid iLocIdno
        //                // ENCODE
        //                Get ReadBinFileToBuffer of oSeqFileHelper1 sFilePath (&iEncodeBinSize) to aEncodeBuffer
        //                Get Base64EncodeToVariantStr of oCharTranslate aEncodeBuffer iEncodeBinSize to vVariant
        //                // DECODE
        //                
        //                Get Base64DecodeFromVariantStr of oCharTranslate vVariant (&iDecodeBinSize) to aDecodeBuffer
        //                If (iEncodeBinSize <> iDecodeBinSize) Begin
        //                    //Send Info_Box "Test Failed"
        //                    Send AppendTextLn of oOnScreenOutput "Decoding failed - mismatching file size!"
        //                End
        //                Else Begin
        //                    Move ("F:\InterstateCompanies\Bitmaps\Snowbooks\DecodeTest.jpg") to sDecodePathOfFile
        //                    Send WriteBinFileFromBuffer of oSeqFileHelper1 sDecodePathOfFile aDecodeBuffer iDecodeBinSize
        //                End
        //                //
        //                Move (Free(aDecodeBuffer)) to iVoid            
        //            End_Function
                    
                End_Object

                Object oGeocodingAPITabPage is a TabPage
                    Set Label to 'Geolocation'

                    Object oMapboxGroup is a Group
                        Set Size to 41 299
                        Set Location to 4 4
                        Set Label to 'Mapbox API'
                        
                        //Docs: https://docs.mapbox.com/api/search/geocoding/
                        //TempusGeocodingAPI Token: pk.eyJ1IjoiYjAwbmdhcnRlbiIsImEiOiJja3B6azRqcHEwMXMzMnBvdTEyczJ0ZjJ0In0.AURnQqeSanOcoKOw5cx6fw
                        //Typical API Address request: https://api.mapbox.com/geocoding/v5/mapbox.places/20920%20Forest%20Rd%20N%2C%20Forest%20Lake%2C%20MN%2055025.json?access_token=pk.eyJ1Ijoic2VhcmNoLW1hY2hpbmUtdXNlci0xIiwiYSI6ImNrN2Y1Nmp4YjB3aG4zZ253YnJoY21kbzkifQ.JM5ZeqwEEm-Tonrk5wOOMw&cachebuster=1623853108755&autocomplete=true
                        //Construct API Address: https://api.mapbox.com/geocoding/v5/mapbox.places/<Address>.json?access_token=<API-Token>&cachebuster=1623853108755&autocomplete=true

//                        Object oJsonPath is a cJsonPath
//                        End_Object
//
//                        Struct tProperties
//                          String accuracy
//                        End_Struct
//                        
//                        Struct tGeometry
//                          String type
//                          Number[] coordinates
//                        End_Struct
//                        
//                        Struct tContext
//                          String id
//                          String text
//                          String wikidata
//                          String short_code
//                        End_Struct
//                        
//                        Struct tFeature
//                           String id
//                           String type
//                           String[] place_type
//                           Number relevance
//                           tProperties properties
//                           String text
//                           String place_name
//                           Number[] center
//                           tGeometry geometry
//                           String Address
//                           tContext[] context
//                        End_Struct
//                        
//                        Struct tData
//                          String type
//                          String[] query
//                          tFeature[] features
//                          String attribution
//                        End_Struct
                        

                        Object oGetButton is a Button
                            Set Size to 14 112
                            Set Location to 17 8
                            Set Label to "GET GEO Locations of >>"
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Integer i iMaxRecords iLocCount iNoAddress iHasGEOLocInfo iLocRequired iCurrRec eResponse
                                Integer[] iaEmptyLoc iaUpdateLoc iaHasNoAddress
                                String sAddress sAPIToken sOutput sDateMonth sDateYear
                                Boolean bSuccess
                                DateTime dtCurrent
                                //
                                
                                //
                                Send Delete_Data of oOnScreenOutput
                                Send AppendTextLn of oOnScreenOutput ("Started Mapbox API Request")
                                //
                                Move (CurrentDateTime()) to dtCurrent
                                Move (DateGetMonth(dtCurrent)) to sDateMonth
                                Move (DateGetYear(dtCurrent)) to sDateYear
                                Get psHome of (phoWorkspace(ghoApplication)) to sOutput
                                If (not(Right(sOutput,1) = "\")) Begin
                                    Move (sOutput + "\")                     to sOutput
                                End
                                Move (sOutput + "Document\Log\"+sDateYear+"_"+sDateMonth+"_GeolocationUpdate.log")   to sOutput
                                Append_Output sOutput
                                Writeln ('#|Customer Idno|Customer Name|Location Idno|Location Name|Note')
                                // Count All locations
                                Get Value of oNoOffRecrodsForm to iMaxRecords
                                Clear Location
                                Find GE Location by 1
                                While (Found and iLocRequired<iMaxRecords)
                                    Increment iLocCount
                                    If (Location.Status='A' and Length(Trim(Location.Address1))>0) Begin
                                        If (Location.Longitude=0 or Location.Latitude=0) Begin
                                            Move Location.LocationIdno to iaEmptyLoc[iLocRequired]
                                            Increment iLocRequired
                                        End
                                        Else Begin
                                            Move Location.LocationIdno to iaUpdateLoc[iHasGEOLocInfo]
                                            Increment iHasGEOLocInfo
                                        End
                                    End
                                    Else Begin
                                        Move Location.LocationIdno to iaHasNoAddress[iNoAddress]
                                        Increment iNoAddress
                                    End
                                    Find GT Location by 1
                                Loop
                                //
                                tDataSourceRow[] TheData
                                String[] sSelectedItems
                                Integer iRows iSelCount iTotalRecCount
                               
                                If (SizeOfArray(iaEmptyLoc)>0) Begin
                                    Move ('Attempt to fill all '*String(SizeOfArray(iaEmptyLoc))*' empty location records without GEOLocation info?') to TheData[iRows].sValue[0]
                                    Move 'NEW' to TheData[iRows].sValue[1] //Identifyer value
                                    Move True to TheData[iRows].sValue[2] //Default to checked
                                    Move True to TheData[iRows].vTag //Flagged as required
                                    Increment iRows
                                End
                                If (SizeOfArray(iaUpdateLoc)>0) Begin
                                    Move ('Overwrite/Update all '*String(SizeOfArray(iaUpdateLoc))*' locations already containing GEOLocation info?') to TheData[iRows].sValue[0]
                                    Move 'UPDATE' to TheData[iRows].sValue[1] //Identifyer value
                                    Move False to TheData[iRows].sValue[2]
                                    Move False to TheData[iRows].vTag //Flagged as NOT required
                                    Increment iRows
                                End
                                Get PopupMultiSelectDialog of oFreeMultiSelectionDialog 'GEOLocation update' 'Please select the desired update method(s) below!' TheData (&sSelectedItems) to bSuccess
                                If (not(bSuccess)) Procedure_Return
                                For iSelCount from 0 to (SizeOfArray(sSelectedItems)-1)
                                    If (sSelectedItems[iSelCount]='NEW') Add (SizeOfArray(iaEmptyLoc)) to iTotalRecCount
                                    If (sSelectedItems[iSelCount]='UPDATE') Add (SizeOfArray(iaUpdateLoc)) to iTotalRecCount
                                Loop
                                
                                // If UPDATE selected then
                                
                                Move (YesNoCancel_Box(('Please confirm the you like to update:'*String(iTotalRecCount)*'records.'))) to eResponse
                                If (eResponse=MBR_Yes) Begin
                                    Integer iCurrTotalRec iUpdRecCount
                                    String sLogMsg
                                    // Progress bar parameters
                                    Set piMinimum of oUtilityProgressBar to 0
                                    Set piMaximum of oUtilityProgressBar to iTotalRecCount
                                    
                                    For iSelCount from 0 to (SizeOfArray(sSelectedItems)-1)                                 
                                        // If NEW selected then
                                        If (sSelectedItems[iSelCount]='NEW') Begin
                                            Send AppendTextLn of oOnScreenOutput 'NEW'
                                            For iCurrRec from 0 to (SizeOfArray(iaEmptyLoc)-1)
                                                Get UpdatedGeoLocationDetails of oGeoLocationUpdate (iaEmptyLoc[iCurrRec]) (&sLogMsg) to bSuccess
                                                Send AppendTextLn of oOnScreenOutput (String(sSelectedItems[iSelCount])*'|'*String(iCurrTotalRec)+'/'+String(iTotalRecCount)*'|'*sLogMsg)
                                                Writeln (String(sSelectedItems[iSelCount])*'|'*String(iCurrTotalRec)+'/'+String(iTotalRecCount)*'|'*sLogMsg)
                                                Increment iCurrTotalRec
                                                Set piPosition of oUtilityProgressBar to iCurrTotalRec
                                            Loop
                                        End
                                        If (sSelectedItems[iSelCount]='UPDATE') Begin
                                            Send AppendTextLn of oOnScreenOutput 'UPDATE'
                                            For iCurrRec from 0 to (SizeOfArray(iaUpdateLoc)-1)
                                                Get UpdatedGeoLocationDetails of oGeoLocationUpdate (iaUpdateLoc[iCurrRec]) (&sLogMsg) to bSuccess
                                                Send AppendTextLn of oOnScreenOutput (String(sSelectedItems[iSelCount])*'|'*String(iCurrTotalRec)+'/'+String(iTotalRecCount)*'|'*sLogMsg)
                                                Writeln (String(sSelectedItems[iSelCount])*'|'*String(iCurrTotalRec)+'/'+String(iTotalRecCount)*'|'*sLogMsg)
                                                Increment iCurrTotalRec
                                                Set piPosition of oUtilityProgressBar to iCurrTotalRec
                                            Loop
                                        End
                                    Loop
                                    
//                                    Clear Location
//                                    Find GE Location by 1
//                                    While ((Found))
//                                        If (Location.Status='A' and Length(Trim(Location.Address1))>0) Begin
//                                            If (Location.Latitude=0 or Location.Longitude=0 ) Begin
//                                                Relate Location
//                                                Increment iLocRequired
//                                                // Update Progress Bar
//                                                Increment iCurrRec
//                                                
//                                                // Make the API request using the randomly selected location address
//                                                Send AppendTextLn of oOnScreenOutput ('LocationIdno:'*String(Location.LocationIdno)*'|'*Trim(Location.Name))
//                                                Move (Trim(Location.Address1)*Trim(Location.City)*Trim(Location.State)*Trim(Left(Location.Zip,5))) to sAddress
//                                                Send AppendTextLn of oOnScreenOutput ('Address:'* sAddress)
//                                                Move (Replaces(' ',sAddress,'%20')) to sAddress
//                                                Send AppendTextLn of oOnScreenOutput ('Address for URL:'* sAddress)
//                                                // Execute HTTPGetJson
//                                                Handle hoJson hoResp
//                                                Boolean bOk bMatchFound
//                                                UChar[] ucaResp
//                                                String sResponse
//                                                String sName sLat sLon sRelev sbbox1_lat sbbox1_lon sbbox2_lat sbbox2_lon
//                                                Integer iStatus iMem iType iFeatureCount iNoMatchCount iSingleMatchCount iMultiMatchCount
//                                                tData myData
//                                                //
//                                                Send AppendTextLn of oOnScreenOutput ('Execute HTTPGetJson #'*String(iCurrRec))
//                                                // Create and Prept
//                                                Get Create (RefClass(cJsonHttpTransfer))  to hoJson // Created
//                                                Set piRemotePort of hoJson to rpHttpSSL //https
//                                                Set peTransferFlags of hoJson to ifSecure
//                                                Set pbShowErrorDialog of hoJson to True
//                                                Set psContentTypeExpected of hoJson to "application/vnd.geo+json" // allow any content type
//                                                
//                                                // Execute
//                                                //
//                                                Get AddHeader of hoJson "Content-Type" "application/vnd.geo+json" to bOk
//                                                Get HttpGetJson of hoJson ('api.mapbox.com') ('/geocoding/v5/mapbox.places/'+sAddress+'.json?access_token='+sAPIToken) (&bOk) to hoResp //'&cachebuster=1623853108755&autocomplete=true'
//                                                // After Json received
//                                                If (bOk) Begin
//                                                    Get Stringify of hoResp to sResponse
//                                                    Send AppendTextLn of oOnScreenOutput (sResponse)
//                                                    // Extract GPS Coordinates
//                                                    Set pbRequireAllMembers of hoResp to False
//                                                    Get JsonToDataType of hoResp to myData
//                                                    // How accurate is the record?
//                                                    // This API returns a relevance value grading how accurate the found address is.
//                                                    // Forward geocodes: Returned features are ordered by relevance.
//                                                    Move (SizeOfArray(myData.features)) to iFeatureCount
//                                                    For i from 0 to (iFeatureCount-1 and not(iSingleMatchCount) and not(iNoMatchCount))
//                                                        Case Begin
//                                                            Case (myData.features[i].relevance >= 0.75) // A value greater than 85% match is considered acceptable - Ideally we want to use 100% accuracy.
//                                                                Increment iSingleMatchCount
//                                                                Send AppendTextLn of oOnScreenOutput ('Greater than 85% Match for first record: Cust#'*String(Location.CustomerIdno)*'| Loc#'*String(Location.LocationIdno)*'|'*Trim(Location.Name))
//                                                                Move myData.features[i].geometry.coordinates[0] to sLon
//                                                                Move myData.features[i].geometry.coordinates[1] to sLat
//                                                                Move myData.features[i].relevance to sRelev
//                                                                Reread Location
//                                                                    Move sLat to Location.Latitude
//                                                                    Move sLon to Location.Longitude
//                                                                    Move sRelev to Location.GeoRelevance
//                                                                    Move 0.25 to Location.GeoFenceRadius //default Radius, can be changed any time
//                                                                    SaveRecord Location
//                                                                Unlock
//                                                                Send AppendTextLn of oOnScreenOutput ('GPS Lat:'*sLat*'| Lon: '*sLon* ' | Relevance:' *sRelev)
//                                                                Move True to bMatchFound
//                                                                Case Break
//                                                            Case Else // Everything below 75% cant be considered usable due to inaccurate and incomplete address information - a manual input is required here.
//                                                                Increment iNoMatchCount
//                                                                Send AppendTextLn of oOnScreenOutput ('NO MATCH - REVIEW AND UPDATE ADDRESS FOR:'*String(Location.LocationIdno)*'|'*Trim(Location.Name))
//                                                                Writeln (String(Customer.CustomerIdno)*'|'*Trim(Customer.Name)*'|'*String(Location.LocationIdno)*'|'*Trim(Location.Name)*'| NO MATCH - REVIEW AND UPDATE ADDRESS')
//                                                                Case Break
//                                                        Case End
//                                                    Loop
//                                                End
//                                                Else Begin
//                                                    String sErrorMsg
//                                                    Get TransferErrorDescription of hoJson to sErrorMsg
//                                                    Send AppendTextLn of oOnScreenOutput ('ERROR:'*sErrorMsg)
//                                                End
//                                                Send Destroy of hoJson
//                                                Send AppendTextLn of oOnScreenOutput ('------------------------------------------------------------------------------------------')
//                                                //Increment i
//                                                
//                                            End
//                                            
//                                        End // Doesn't have a location Address to verify
//                                        Else Begin
//                                            Increment iNoAddress
//                                            Writeln (String(Customer.CustomerIdno)*'|'*Trim(Customer.Name)*'|'*String(Location.LocationIdno)*'|'*Trim(Location.Name)*'| NO MATCH - Review and update address for:')
//                                        End
//                                        Find GT Location by 1
//                                    Loop
//                                    Send AppendTextLn of oOnScreenOutput ('Location updated process Completed SUCCESS - Perfect Match :'*String(iSingleMatchCount))
//                                    Send AppendTextLn of oOnScreenOutput ('FAILED - NO Matches (85% or less):'*String(iNoMatchCount)*' - NO Address:'*String(iNoAddress))
//                                    Send Info_Box ('Location updated process Completed \n\n SUCCESS \n - Perfect Match :'*String(iSingleMatchCount)*'\n\n Failed \n - NO Matches (85% or less):'*String(iNoMatchCount)*'\n - NO Address:'*String(iNoAddress)) 'Location Update Process'
                                    //
                                    Move (CurrentDateTime()) to dtCurrent
                                    Writeln "Stop: " dtCurrent
                                    Close_Output
                                End
                            End_Procedure
                        
                        End_Object

                        Object oNoOffRecrodsForm is a Form
                            Set Size to 13 60
                            Set Location to 18 122
                            Set Label to "Records"
                            Set Label_Col_Offset to -90
                            Set Label_Justification_Mode to JMode_Right
                            Set Value to "1000"
                        
                            // OnChange is called on every changed character
                        //    Procedure OnChange
                        //        String sValue
                        //    
                        //        Get Value to sValue
                        //    End_Procedure
                        
                        End_Object


//                        Object oGetButton is a Button
//                            Set Size to 14 112
//                            Set Location to 17 19
//                            Set Label to 'GET 3 Random Locations'
//                        
//                            // fires when the button is clicked
//                            Procedure OnClick
//                                Integer i iRandomLocIdno iRetVal
//                                String sAddress sAPIToken
//                                //
//                                Move 'pk.eyJ1IjoiYjAwbmdhcnRlbiIsImEiOiJja3B6azRqcHEwMXMzMnBvdTEyczJ0ZjJ0In0.AURnQqeSanOcoKOw5cx6fw' to sAPIToken
//                                //
//                                Send Delete_Data of oOnScreenOutput
//                                Send AppendTextLn of oOnScreenOutput ("Started Mapbox API Request")
//                                //
//                                
////                                Boolean bExists
////                                Boolean bOK
////                                Handle hoObj
////                                String sPath sFile sFileName
////                                UChar[] stream
////                                String sJSON
////                                tData myData
////                                
////                                Get psDataPath of (phoWorkspace(ghoApplication)) to sPath
////                                Move "Benjamin.txt" to sFile
////                                Move (sPath+"\"+sFile) to sFileName
////                                File_Exist sFileName bExists
////                                If (bExists) Begin
////                                    Direct_Input sFileName
////                                    Read_Block stream -1
////                                    Close_Input
////                                    Move (UCharArrayToString(stream)) to sJSON
////                                    Get Create (RefClass(cJsonObject)) to hoObj
////                                    If (hoObj) Begin
////                                      Get ParseString of hoObj sJSON to bOK  
////                                      If (bOK) Begin
////                                        Set pbRequireAllMembers of hoObj to False
////                                        Get JsonToDataType of hoObj to myData
////                                        Move myData.features[0].geometry.coordinates[0] to sLat
////                                        Move myData.features[0].geometry.coordinates[1] to sLon
////                                      End
////                                    End
////                                End
//                                  
//                                While (i<3)
//                                    //Look for a new random record
//                                    Clear Location
//                                    Move (Random(10000)) to iRandomLocIdno
//                                    Move iRandomLocIdno to Location.LocationIdno
//                                    Find EQ Location.LocationIdno
//                                    If ((Found) and iRandomLocIdno = Location.LocationIdno) Begin
//                                        // Make the API request using the randomly selected location address
//                                        Send AppendTextLn of oOnScreenOutput ('LocationIdno:'*String(Location.LocationIdno)*'|'*Trim(Location.Name))
//                                        Move (Trim(Location.Address1)*Trim(Location.City)*Trim(Location.State)*Trim(Left(Location.Zip,5))) to sAddress
//                                        Send AppendTextLn of oOnScreenOutput ('Address:'* sAddress)
//                                        Move (Replaces(' ',sAddress,'%20')) to sAddress
//                                        Send AppendTextLn of oOnScreenOutput ('Address URL:'* sAddress)
//                                        // Execute HTTP Get request with modified address and API Token
//                                        //Send AppendTextLn of oOnScreenOutput ('Execute HTTPGetRequest #'*String(i))
//                                        //Get HTTPGetRequest of oHttpTransfer1 ('/geocoding/v5/mapbox.places/'+sAddress+'.json?access_token='+sAPIToken+'&cachebuster=1623853108755&autocomplete=true') to iRetVal
//                                        //
//                                        // Execute HTTPGetJson
//                                        Handle hoJson hoResp hoMember hoType hoQuery hoFeatures hoGeometry
//                                        Boolean bOk
//                                        UChar[] ucaResp
//                                        String sResponse
//                                        String sName sLat sLon
//                                        Integer iStatus iMem iType
//                                        tData myData
//                                        //
//                                        Send AppendTextLn of oOnScreenOutput ('Execute HTTPGetJson #'*String(i))
//                                        Get HttpGetJson of oJsonHttpTransfer1 ('api.mapbox.com') ('/geocoding/v5/mapbox.places/'+sAddress+'.json?access_token='+sAPIToken+'&cachebuster=1623853108755&autocomplete=true') (&bOk) to hoJson
//                                        // After Json received
//                                        If (bOk) Begin
//                                            Get pucaData of oJsonHttpTransfer1 to ucaResp
//                                            If (SizeOfArray(ucaResp)) Begin
//                                                Get Create (RefClass(cJsonObject))  to hoResp // Created
//                                                //Set peWhiteSpace of hoResp          to jpWhitespace_Pretty
//                                                //Set pbEscapeForwardSlash of hoResp  to False
//                                                Get ParseUtf8 of hoResp ucaResp     to bOK
//                                                If (bOK) Begin
//                                                    Get Stringify of hoResp to sResponse
//                                                    Send AppendTextLn of oOnScreenOutput (sResponse)
//                                                    // Extract GPS Coordinates
//                                                    Set pbRequireAllMembers of hoResp to False
//                                                    Get JsonToDataType of hoResp to myData
//                                                    Move myData.features[0].geometry.coordinates[0] to sLat
//                                                    Move myData.features[0].geometry.coordinates[1] to sLon
//                                                End
//                                            End
//                                            Send Destroy of hoResp
//                                        End
//                                        Increment i
//                                        //
//                                    End
//                                Loop
//                            End_Procedure
//                        
//                        End_Object

 
                        
                        
                        
                        
                    End_Object

                    Object oKMLExportGroup is a Group
                        Set Size to 57 300
                        Set Location to 47 4
                        Set Label to 'GEOLocation Export KML'

                        Object oExportButton is a Button
                            Set Location to 23 225
                            Set Label to 'Export'
                        
                            // fires when the button is clicked
                            Procedure OnClick
                                Boolean bSuccess
                                Get ExportGeoLocationKML to bSuccess
                            End_Procedure
                        
                        End_Object

                        Object oDegComboForm is a ComboForm
                            Set Size to 13 100
                            Set Location to 22 16
                            Set Allow_Blank_State to False
                            // Combo_Fill_List is called when the list needs filling
                          
                            Procedure Combo_Fill_List
                                // Fill the combo list with Send Combo_Add_Item
                                Send Combo_Add_Item "1 deg | 360 dots (Fine)"
                                //Send Combo_Add_Item "2 deg | 180 dots"
                                Send Combo_Add_Item "4 deg | 90 dots (Medium)"
                                Send Combo_Add_Item "8 deg | 45 dots (Coarse)"
                                //Send Combo_Add_Item "10 deg | 36 dots"
                            End_Procedure
                          
                            // OnChange is called on every changed character
                         
                        //    Procedure OnChange
                        //        String sValue
                        //    
                        //        Get Value to sValue // the current selected item
                        //    End_Procedure
                          
                            // Notification that the list has dropped down
                         
                        //    Procedure OnDropDown
                        //    End_Procedure
                        
                            // Notification that the list was closed
                          
                        //    Procedure OnCloseUp
                        //    End_Procedure
                        End_Object
                        
                        Define C__PI      for 3.14159265358979
                        Define C__EarthMi for 3958.8728
                        Define C__EarthKm for 6371
                        
                        Function aTan2 Global Decimal x Decimal y Returns Decimal
                            Decimal dz
                            If (y=0) Begin
                                Move (If(x=0,0,If(x>0,Atan(y/x),C__PI+Atan(y/x))) ) to dz
                                
                            End
                            Else Begin
                                Move (Atan((Sqrt((x*x)+(y*y)) - x)/y)*2) to dz
                            End
                            Function_Return dz
                        End_Function
                        
                        Function deg2rad Number nDeg Returns Decimal
                            Function_Return (nDeg*(C__PI/180.00))
                        End_Function
                        
                        Function rad2deg Number nRad Returns Decimal
                            Function_Return (nRad*(180.00/C__PI))
                        End_Function
                        
                        Function CalcNextCoordinate Decimal dLocLat Decimal dLocLon Number nRadius Decimal dBearingDeg Decimal ByRef dNextLat Decimal ByRef dNextLon Returns Boolean
                            Decimal dX dY
                            //convert deg to rad
                            Move (deg2rad(Self,dLocLat)) to dLocLat
                            Move (deg2rad(Self,dLocLon)) to dLocLon
                            Move (deg2rad(Self,dBearingDeg)) to dBearingDeg
                            //dNextLat
                            Move (asin((Sin(dLocLat) * Cos(nRadius/C__EarthMi)) + (Cos(dLocLat) * Sin(nRadius/C__EarthMi) * Cos(dBearingDeg)))) to dNextLat
                            //dNextLon
                            Move (Sin(dBearingDeg) * Sin(nRadius/C__EarthMi) * Cos(dLocLat)) to dX
                            Move (Cos(nRadius/C__EarthMi) - (Sin(dLocLat) * Sin(dNextLat))) to dY
                            Move (dloclon + ATAN2(dY,dX)) to dNextLon
                            
                            Move (rad2deg(Self,dNextLat)) to dNextLat // convert rad to deg
                            Move (rad2deg(Self,dNextLon)) to dNextLon // convert rad to deg
                            Function_Return True
                        End_Function
                        
                        Function ExportGeoLocationKML Returns Boolean
                            String sDeg sNextLat sNextLon
                            Integer iDotCount iCurrDotDeg i360deg
                            Number nDeg
                            Boolean bNewCordOK
                            //
                            Send Delete_Data of oOnScreenOutput
                            Send AppendTextLn of oOnScreenOutput ("Started Export Geolocation KML")
                            //
                            Move 360 to i360deg
                            Get Value of oDegComboForm to sDeg
                            Move (Left(sDeg,1)) to nDeg
                            Send AppendTextLn of oOnScreenOutput ("Selected:"*sDeg * ' | Deg:' + String(nDeg))
                            
                            While (iCurrDotDeg<=(i360deg))
                                Increment iDotCount
                                Send AppendTextLn of oOnScreenOutput (String(iDotCount)+'.'*"Current Dot:"*String(iCurrDotDeg))
                                //
                                Get CalcNextCoordinate '45.25278829374101' '-92.98676195567347' '0.5' (iCurrDotDeg+nDeg) (&sNextLat) (&sNextLon) to bNewCordOK
                                //
                                Send AppendTextLn of oOnScreenOutput ("Next Lat:"*sNextLat*' | Next Lon: '*sNextLon)
                                //
                                Move (iCurrDotDeg+nDeg) to iCurrDotDeg
                            Loop
                            
                            //
                            Send AppendTextLn of oOnScreenOutput ("Completed Export Geolocation KML")
                            Function_Return True
                        End_Function
                        
                        
                    End_Object

//                    Object oNominatimAPIGroup is a Group
//                        Set Size to 41 299
//                        Set Location to 46 4
//                        Set Label to 'Nominatim API'
//                        
//                        //Docs: https://nominatim.org/release-docs/develop/api/Overview/
//                        //Construct API Address: https://nominatim.openstreetmap.org/search?q=<Address>&format=geojson
//                        //Typical API Address request: https://nominatim.openstreetmap.org/search?q=20920%20Forest%20Rd%20N%2C%20Forest%20Lake%2C%20MN%2055025&format=geojson
//
//                        Struct tProperties
//                          Number place_id
//                          String osm_type
//                          Number osm_id
//                          String display_name
//                          Number place_rank
//                          String category
//                          String type
//                          Number importance
//                        End_Struct
//                        
//                        Struct tGeometry
//                          String type
//                          Number[] coordinates
//                        End_Struct
//                        
//                        Struct tFeature
//                           String type
//                           tProperties properties
//                           Number[] bbox
//                           tGeometry geometry
//                        End_Struct
//                        
//                        Struct tData
//                          String type
//                          String licence
//                          tFeature[] features
//                        End_Struct
//
//                        Object oGetButton is a Button
//                            Set Size to 14 112
//                            Set Location to 17 19
//                            Set Label to 'GET 3 Random Locations'
//                        
//                            // fires when the button is clicked
//                            Procedure OnClick
//                                Integer i iLocCount iLocRequired iCurrRec eResponse
//                                String sAddress
//                                //
//                                Send Delete_Data of oOnScreenOutput
//                                Send AppendTextLn of oOnScreenOutput ("Started Nominatim API Request")
//                                // Count All locations
//                                Clear Location
//                                Find GE Location by 1
//                                While (Found)
//                                    Increment iLocCount
//                                    If (Location.Longitude=0 or Location.Latitude=0) Begin
//                                        Increment iLocRequired
//                                    End
//                                    Find GT Location by 1
//                                Loop
//                                //
//                                Move (YesNoCancel_Box(('Add GPS Information to '*String(iLocRequired)*'/'*String(iLocCount)*'required records?'),'Location record updates',MBR_Yes)) to eResponse
//                                
//                                If (eResponse=MBR_Yes) Begin
//                                    // Progress bar parameters
//                                    Set piMinimum of oUtilityProgressBar to 0
//                                    Set piMaximum of oUtilityProgressBar to iLocRequired
//                                    //Look for a new random record
//                                    Clear Location
//                                    Find GE Location by 1
//                                    While ((Found) and iCurrRec<=99)
//                                        // Update Progress Bar
//                                        Increment iCurrRec
//                                        Set piPosition of oUtilityProgressBar to iCurrRec
//                                        // Make the API request using the randomly selected location address
//                                        Send AppendTextLn of oOnScreenOutput ('LocationIdno:'*String(Location.LocationIdno)*'|'*Trim(Location.Name))
//                                        Move (Trim(Location.Address1)*Trim(Location.City)*Trim(Location.State)*Trim(Left(Location.Zip,5))) to sAddress
//                                        Send AppendTextLn of oOnScreenOutput ('Address:'* sAddress)
//                                        Move (Replaces(' ',sAddress,'%20')) to sAddress
//                                        Send AppendTextLn of oOnScreenOutput ('Address URL:'* sAddress)
//                                        // Execute HTTPGetJson
//                                        Handle hoJson hoResp
//                                        Boolean bOk
//                                        UChar[] ucaResp
//                                        String sResponse
//                                        String sName sLat sLon
//                                        Integer iStatus iMem iType iFeatureCount iNoMatchCount iSingleMatchCount iMultiMatchCount
//                                        tData myData
//                                        //
//                                        Send AppendTextLn of oOnScreenOutput ('Execute HTTPGetJson #'*String(i))
//                                        // Create and Prept
//                                        Get Create (RefClass(cJsonHttpTransfer))  to hoJson // Created
//                                        Set piRemotePort of hoJson to rpHttpSSL //https
//                                        Set peTransferFlags of hoJson to ifSecure
//                                        Set pbShowErrorDialog of hoJson to False
//                                        // Execute
//                                        Get HttpGetJson of hoJson ('nominatim.openstreetmap.org') ('/search?q='+sAddress+'&format=geojson') (&bOk) to hoResp
//                                        // After Json received
//                                        If (bOk) Begin
//                                            Get Stringify of hoResp to sResponse
//                                            //Send AppendTextLn of oOnScreenOutput (sResponse)
//                                            // Extract GPS Coordinates
//                                            Set pbRequireAllMembers of hoResp to False
//                                            Get JsonToDataType of hoResp to myData
//                                            // Single or multiple records returned?
//                                            Move (SizeOfArray(myData.features)) to iFeatureCount
//                                            Case Begin
//                                                Case (iFeatureCount=0)
//                                                    Increment iNoMatchCount
//                                                    Send AppendTextLn of oOnScreenOutput ('NO MATCHING RECORD FOUND FOR:'*String(Location.LocationIdno)*'|'*Trim(Location.Name))
//                                                    Case Break
//                                                Case (iFeatureCount=1)
//                                                    Increment iSingleMatchCount
//                                                    Move myData.features[0].geometry.coordinates[0] to sLat
//                                                    Move myData.features[0].geometry.coordinates[1] to sLon
//                                                    Send AppendTextLn of oOnScreenOutput ('GPS Lat:'*sLat*'| Lon'*sLon)
//                                                    Case Break
//                                                Case Else
//                                                    Increment iMultiMatchCount
//                                                    For i from 0 to (iMultiMatchCount-1)
//                                                        Send AppendTextLn of oOnScreenOutput ('- Address#'*String(i)*'|'*Trim(myData.features[1].properties.display_name))
//                                                    Loop
//                                                    //Let user select which record to use
//                                                    //Send Popup of oFreeMultiSelectionDialog 
//                                                    Case Break 
//                                            Case End
//                                        End
//                                        Send Destroy of hoJson
//                                        Send AppendTextLn of oOnScreenOutput ('------------------------------------------------------------------------------------------')
//                                        Increment i
//                                        //
//                                        Find GT Location by 1
//                                    Loop
//                                    Send Info_Box ("Location updated process Completed /n/n/n -No Matches:"*String(iNoMatchCount)*'/n/n - Single Match:'*String(iSingleMatchCount)*'/n/n - Multiple Matches:'*String(iMultiMatchCount)) 'Location Update Process'
//                                End
//                            End_Procedure
//                        
//                        End_Object
//
//                    End_Object 
                    
                End_Object
        
        
        //        Object oTabPage9 is a TabPage
        //            Set Label to 'Employee Tools'
        //
        //            Object oGroup11 is a Group
        //                Set Size to 100 100
        //                Set Location to 4 5
        //                Set Label to 'Create WebAppUser Account'
        //
        //                Object oButton8 is a Button
        //                    Set Location to 0 0
        //                    Set Label to 'oButton8'
        //                
        //                    // fires when the button is clicked
        //                    Procedure OnClick
        //                        
        //                    End_Procedure
        //                    
        //                    Procedure DoMassCreateWebAppUserForEmployees
        //                        
        //                        //
        //                        Constraint_Set 1
        //                        Constrain Employee.Status eq "A"
        //                        Constrained_Find FIRST Employee by 1
        //                        While ((Found) and Employee.Status = "A")
        //                            Relate Employee
        //                            If (Employer.Status = "A") Begin
        //                                Open WebAppUser
        //                                Clear WebAppUser
        //                                Move (Trim(Employee.FirstName)*Trim(Employee.LastName)) to WebAppUser.FullName
        //                                Move (Employee.EmployeeIdno)
        //                            End
        //                            Else Begin
        //                                //Ignore due to Inactive Employer
        //                            End
        //                        Loop
        //                        Constraint_Set 1 Delete
        //                    End_Procedure
        //                
        //                End_Object
        //                
        //                
        //            End_Object
        //        End_Object
        
            End_Object
        End_Object

        Object oSplitterContainerChild2 is a cSplitterContainerChild
            Object oOnScreenOutput is a cTextEdit
                Set Size to 346 386
                Set Location to 12 5
                Set Read_Only_State to True
                Set Label to "Output"
                Set peAnchors to anAll
            End_Object

            Object oUtilityProgressBar is a cProgressBar
                Set Size to 14 383
                Set Location to 362 6
                Set piMinimum to 0
                Set piMaximum to 100
                Set peAnchors to anBottomLeftRight
            End_Object
        End_Object
    End_Object

    // Matching Functions
    
//    Function MatchExternalEmployee Integer iExtEmployeeIdno String sEmployeeName Returns Integer
//        Integer iIntEmployeeIdno
//        Clear Employee
//        
//        Move iExtEmployeeIdno to Employee.CEPM_EmployeeIdno
//        Find GE Employee.CEPM_EmployeeIdno
//        If ((Found) and Employee.CEPM_EmployeeIdno = iExtEmployeeIdno) Begin
//            Move Employee.EmployeeIdno to iIntEmployeeIdno
//            Function_Return iIntEmployeeIdno
//        End
//        Else Begin
//            Send Info_Box (sEmployeeName * "(" * String(iExtEmployeeIdno) * ") not linked yet! \n \n  Please select a CEPM Employee") "Link CEPM Employee"
//            Get EmployeeSelection of Employee_sl 180 to iIntEmployeeIdno           
//            Function_Return iIntEmployeeIdno
//        End
//    End_Function
//    
//    Function MatchExternalJobNumber Integer iExtJobNumber String sLocationName Returns Integer
//        Integer iIntJobNumber       
//        Clear Order
//        Move iExtJobNumber to Order.CEPM_JobNumber
//        Find ge Order.CEPM_JobNumber
//        If ((Found) and Order.CEPM_JobNumber = iExtJobNumber) Begin
//            Move Order.JobNumber to iIntJobNumber
//            Function_Return iIntJobNumber 
//        End
//        Else Begin
//            Send Info_Box (sLocationName * "(" * String(iExtJobNumber)  * ") not linked yet! \n \n Please select a matching Job") "Link Job"
//            Get IsSelectedJobNumber of Order_sl "" True to iIntJobNumber
//            Function_Return iIntJobNumber
//        End
//    End_Function
//    
//    Function MatchExternalEquipment Integer iExtEquipmentIdno String sEquipDescription Returns Integer
//        Integer iIntEquipmentIdno
//        Boolean bOk
//        String sEquipIdno
//        
//        Clear Equipmnt
//        Move iExtEquipmentIdno to Equipmnt.CEPM_EquipIdno
//        Find GE Equipmnt.CEPM_EquipIdno
//        If ((Found) and Equipmnt.CEPM_EquipIdno = iExtEquipmentIdno) Begin
//            Move Equipmnt.EquipIdno to iIntEquipmentIdno
//            Function_Return iIntEquipmentIdno
//        End
//        Else Begin
//            Send Info_Box (sEquipDescription * "(" * String(iExtEquipmentIdno) * ") not linked yet! \n \n Please select a CEPM Equipment") "Link CEPM Equipment"
//            Get EquipmentSelection of Equipmnt_sl 180 "0" (&sEquipIdno) to bOk
//            Move sEquipIdno to iIntEquipmentIdno
//            Function_Return iIntEquipmentIdno
//        End
//    End_Function   
//
//    // Validation Functions
//    Function IsEmployeeValid Integer iEmployeeIdno Integer iPIN Returns Boolean
//        Clear Employee
//        
//        Integer iEmployerIdno
//        
//        Move iEmployeeIdno to Employee.EmployeeIdno
//        Find eq Employee.EmployeeIdno
//        If ((Found) and Employee.Status = "A") Begin
//            Move Employee.EmployerIdno to iEmployerIdno
//            Clear Employer
//            Move iEmployerIdno to Employer.EmployerIdno
//            Find eq Employer.EmployerIdno
//            Function_Return ((Found) and Employer.Status = "A")
//        End
//    End_Function
//    
//    Function IsJobValid Integer iJobNumber Returns Integer
//        Clear Order
//        Move iJobNumber to Order.JobNumber
//        Find eq Order.JobNumber
//        If ((Found) and Order.JobCloseDate = 0) Begin
//            Function_Return Order.LocationIdno
//        End
//    End_Function
//
//    Function IsEquipmentValid Integer iLocationIdno Integer iEquipIdno Returns Integer
//        Clear Equipmnt MastOps Opers
//        Move iEquipIdno to Equipmnt.EquipIdno
//        Find eq Equipmnt.EquipIdno
//        If (Found) Begin
//            Relate Equipmnt
//            If (MastOps.Recnum <> 0) Begin
//                Move iLocationIdno       to Opers.LocationIdno
//                Move MastOps.MastOpsIdno to Opers.MastOpsIdno
//                Find eq Opers by Index.4
//                If (Found) Begin
//                    Set piEquipIdno   to Equipmnt.EquipIdno
//                    Set psEquipmentID to Equipmnt.EquipmentID
//                    Function_Return Opers.OpersIdno
//                End
//            End
//        End
//    End_Function
//
//    Function IsMaterialValid Integer iLocationIdno Integer iMaterialIdno Returns Integer
//        Clear Equipmnt MastOps Opers
//        Move iMaterialIdno to Equipmnt.EquipIdno
//        Find eq Equipmnt.EquipIdno
//        If (Found) Begin
//            Relate Equipmnt
//            If (MastOps.Recnum <> 0 and MastOps.CostType = "Material") Begin
//                Move iLocationIdno       to Opers.LocationIdno
//                Move MastOps.MastOpsIdno to Opers.MastOpsIdno
//                Find eq Opers by Index.4
//                If (Found) Begin
//                    Set piEquipIdno   to Equipmnt.EquipIdno
//                    Set psEquipmentID to Equipmnt.EquipmentID
//                    Function_Return Opers.OpersIdno
//                End
//            End
//        End
//    End_Function
//    
//    Function ImportTransaction Integer iExtTransIdno Integer iExtEmployeeIdno String sEmplName Integer iExtJobNumber String sLocName Integer iExtEquipIdno String sEquipDesc Date dStartDate String sStartTime Date dStopDate String sStopTime Number nQty Returns Boolean
//        Boolean bFail bOk bEmplValid
//        Integer iEmployeeIdno iJobNumber iEquipIdno
//        Integer iLocationIdno iOpersIdno hoDD iStartPos iStopPos
//        String sStartHr sStartMin sStopHr sStopMin sTime sSeed sEquipIdno
//        Date    dToday
//        
//        // Check for previous import based on CEPMs Transidno
//        // If allready imported disgard this transaction and go to the next (ERROR MESSAGE or NOTIFICATION ??? )
//        Clear Trans
//        Move iExtTransIdno to Trans.CEPM_TransIdno
//        Find GE Trans by Index.12
//        If ((Found) and Trans.CEPM_TransIdno = iExtTransIdno) Begin
//            Send AppendTextLn of oOnScreenOutput ("This Transaction was previously imported:" * String(iExtTransIdno))
//        End
//        Else Begin
//            
//            Move 2373 to iEmployeeIdno //Jen Erik, CEPM Employee in LIVE
//            Move 0 to iJobNumber
//            Move 0 to iEquipIdno
//            Move 0 to iLocationIdno
//            
//                         
//            While (iEmployeeIdno = 0 and (not(bEmplValid)))
//                // Matching process not needed due to Jen Erik employee
//                // Get MatchExternalEmployee iExtEmployeeIdno sEmplName to iEmployeeIdno
//                If (iEmployeeIdno <> 0) Begin
//                    Get IsEmployeeValid iEmployeeIdno 0 to bEmplValid
//                    If (not(bEmplValid)) Begin
//                        Get IsSelectedManager of Employee_sl 0 to iEmployeeIdno
//                    End
//                    Else Begin
//                        Reread Employee
//                            Move iExtEmployeeIdno to Employee.CEPM_EmployeeIdno
//                            SaveRecord Employee
//                        Unlock
//                    End
//                    
//                End
//            Loop  
//    
//            While (iJobNumber = 0 and iLocationIdno = 0) 
//                Get MatchExternalJobNumber iExtJobNumber sLocName to iJobNumber
//                If (iJobNumber <> 0) Begin
//                    Get IsJobValid iJobNumber to iLocationIdno
//                    If (iLocationIdno=0) Begin
//                        Get IsSelectedJobNumber of Order_sl 0 to iJobNumber
//                    End
//                    Else Begin
//                        Reread Order
//                            Move iExtJobNumber to Order.CEPM_JobNumber
//                            SaveRecord Order
//                        Unlock
//                    End
//                End
//            Loop
//    
//            While (iEquipIdno = 0 and iOpersIdno = 0)
//                Get MatchExternalEquipment iExtEquipIdno sEquipDesc to iEquipIdno
//                If (iEquipIdno <> 0) Begin
//                    Get IsEquipmentValid iLocationIdno iEquipIdno to iOpersIdno
//                    If (iOpersIdno=0) Begin
//                        Send Info_Box "Equipment not valid - select someting else"
//                        Get EquipmentSelection of Equipmnt_sl 180 sSeed (&sEquipIdno) to bOk
//                        If (bOk) Begin
//                            Move sEquipIdno to iEquipIdno
//                        End
//                    End
//                    Else Begin
//                        Reread Equipmnt
//                            Move iExtEquipIdno to Equipmnt.CEPM_EquipIdno
//                            SaveRecord Equipmnt
//                        Unlock
//                    End
//                End
//            Loop     
//    
//            //SplitTime
//            Move (Pos(":", sStartTime)) to iStartPos
//            Move (Pos(":", sStopTime)) to iStopPos
//            Move (Left(sStartTime,iStartPos-1)) to sStartHr
//            Move (Right(sStartTime,iStartPos)) to sStartMin
//            Move (Left(sStopTime,iStopPos-1)) to sStopHr
//            Move (Right(sStopTime,iStopPos)) to sStopMin
//            //
//            Get Main_DD                            to hoDD
//            Send Clear of hoDD
//            // create new transaction
//            Move iEmployeeIdno                                      to Employee.EmployeeIdno
//            Send Request_Find       of hoDD EQ Employee.File_Number    1
//            If (not(Found)) Begin
//                Send Info_Box "Employee not found"
//                Function_Return
//            End
//            Move iJobNumber                                         to Order.JobNumber
//            Send Request_Find       of hoDD EQ Order.File_Number       1
//            If (not(Found)) Begin
//                Send Info_Box "Order not found"
//                Function_Return
//            End
//            //
//            Move iOpersIdno                                         to Opers.OpersIdno
//            Send Request_Find       of hoDD EQ Opers.File_Number       1
//            If (not(Found)) Begin
//                Send Info_Box "Operation not found"
//                Function_Return
//            End
//            //
//            // TimeSplit in iStartHr,iStartMin
//            //
//            Set Field_Changed_Value of hoDD Field Trans.CEPM_TransIdno  to iExtTransIdno
//            Set Field_Changed_Value of hoDD Field Trans.StartTime       to sStartTime
//            Set Field_Changed_Value of hoDD Field Trans.StartDate       to dStartDate
//            Set Field_Changed_Value of hoDD Field Trans.StartHr         to sStartHr
//            Set Field_Changed_Value of hoDD Field Trans.StartMin        to sStartMin
//            Set Field_Changed_Value of hoDD Field Trans.StopDate        to dStopDate
//            Set Field_Changed_Value of hoDD Field Trans.StopTime        to sStopTime
//            Set Field_Changed_Value of hoDD Field Trans.StopHr          to sStopHr
//            Set Field_Changed_Value of hoDD Field Trans.StopMin         to sStopMin
//            Set Field_Changed_Value of hoDD Field Trans.Quantity        to nQty
//            Get Request_Validate    of hoDD                             to bFail
//            If (not(bFail)) Begin
//                //Showln "Request_Save"
//                Send Request_Save   of hoDD
//            End
//            Else Begin
//                Send Info_Box "Validation error creating"
//            End
//            Function_Return (Current_Record(hoDD) <> 0)            
//        End
//        
//    End_Function

End_Object
