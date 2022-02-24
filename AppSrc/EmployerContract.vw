// Z:\VDF17.0 Workspaces\Tempus\AppSrc\EmployerContract.vw
// EmployerContract
//

Use cGlblDbView.pkg
Use cGlblDbForm.pkg
Use cDbCJGrid.pkg
Use Windows.pkg
Use mailto.pkg

Use SubcontractorContract.rv //ToDo: Retire
Use SubcontractorAgreementReport.rv
Use cCJCommandBarSystem.pkg
Use EmployerTasks.bp

Use Vendor_BillingInstructionsReport.rv
Use Vendor_TempusFieldInstructionsReport.rv

Use WebAppUserRights.sl
Use Employer.DD

Activate_View Activate_oEmployerContract for oEmployerContract

Object oEmployerContract is a cGlblDbView
    
    Object oEmployer_DD is a Employer_DataDictionary
        Procedure OnConstrain
            Constrain Employer.EmployerIdno ne 101
            //Status
            If (not(Checked_State(oActiveEmployerCheckBox(Self)))) Constrain Employer.Status ne "A"
            If (not(Checked_State(oInactiveEmployerCheckBox(Self)))) Constrain Employer.Status ne "I"
            If (not(Checked_State(oTerminatedEmployerCheckBox(Self)))) Constrain Employer.Status ne "T"
            //
        End_Procedure
    End_Object

    Set Main_DD to oEmployer_DD
    Set Server to oEmployer_DD

    Set Location to 1 1
    Set Size to 373 724
    Set Label To "EmployerContract"
    Set Border_Style to Border_Thick
    Set piMinSize to 300 500
    Set Maximize_Icon to True



    Object oEmployerGrid is a cDbCJGrid
        Set Size to 339 714
        Set Location to 31 6
        Set pbAllowEdit to True
        Set peAnchors to anAll
        Set Ordering to 2
        Set piSortColumn to 0
        Set pbAllowColumnRemove to False
        Set pbAllowColumnReorder to False
        Set pbAllowDeleteRow to False
        Set pbEditOnClick to True
        Set pbAllowInsertRow to False
        Set piHighlightBackColor to clLtGray
        Set pbSelectionEnable to True
        Set pbHeaderReorders to True
        Set pbHeaderTogglesDirection to True
        Set pbStaticData to True
        
        Boolean bGLInsOk bWorkCompOk bAutoInsOk bTrucking
        Date dGLInsExp dAutoInsExp dWorkCompExp
               

        Object oEmployer_Name is a cDbCJGridColumn
            Entry_Item Employer.Name
            Set piWidth to 160
            Set psCaption to "Name"
            Set pbEditable to False
            Set pbAllowRemove to False
            Set pbAllowDrag to False
            Set piMaximumWidth to 160
            Set piMinimumWidth to 160

            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue                       
                Variant vFont
                Handle hoFont
                Get RowValue of oEmployer_TruckingOnlyFlag iRow to bTrucking
                If (bTrucking) Begin
                    Get Create (RefClass(cComStdFont)) to hoFont
                    Get ComFont of hoGridItemMetrics to vFont
                    Set pvComObject of hoFont to vFont
                    Set ComBold of hoFont to True
                    Send Destroy of hoFont
                End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
                        
        End_Object

        Object oEmployer_Main_contact is a cDbCJGridColumn
            Entry_Item Employer.Main_contact
            Set piWidth to 130
            Set psCaption to "Main Contact"
            Set piMinimumWidth to 130
            Set piMaximumWidth to 130
        End_Object

        Object oEmployer_Phone1 is a cDbCJGridColumn
            Entry_Item Employer.Phone1
            Set piWidth to 100
            Set psCaption to "Phone"
            Set piMaximumWidth to 100
            Set piMinimumWidth to 100
        End_Object

        Object oEmployer_EmailAddress is a cDbCJGridColumn
            Entry_Item Employer.EmailAddress
            Set piWidth to 130
            Set psCaption to "EmailAddress"
            Set piMinimumWidth to 130
        End_Object

        Object oEmployer_Notes is a cDbCJGridColumn
            Entry_Item Employer.Notes
            Set piWidth to 180
            Set psCaption to "Notes"
            Set pbMultiLine to True
            Set piMinimumWidth to 180
        End_Object

        Object oEmployer_ManagedBy is a cDbCJGridColumn
            Set piWidth to 72
            Set psCaption to "ManagedBy"
            Set Shadow_State to True
            Set pbEditable to False
            Set piDisabledTextColor to clNone

            Procedure OnSetCalculatedValue String  ByRef sValue
                Forward Send OnSetCalculatedValue (&sValue)
                Move Employer.ManagedBy to Employee.EmployeeIdno
                Find EQ Employee by Index.1
                If ((Found) and Employer.ManagedBy = Employee.EmployeeIdno) Begin
                   Move (Trim(Employee.FirstName) + ' ' + Trim(Employee.LastName)) to sValue
                End
                Else Move "-" to sValue
                
            End_Procedure
        End_Object

        Object oEmployer_LastTimeNotifyed is a cDbCJGridColumn
            Entry_Item Employer.LastTimeNotifyed
            Set piWidth to 100
            Set psCaption to "Notified"
            Set piMaximumWidth to 100
            Set piMinimumWidth to 100
            Set pbResizable to False
        End_Object

        Object oEmployer_W9Flag is a cDbCJGridColumn
            Entry_Item Employer.W9Flag
            Set piWidth to 60
            Set psCaption to "W9"
            Set pbCheckbox to True
            Set peHeaderAlignment to xtpAlignmentCenter
            Set peTextAlignment to xtpAlignmentCenter
        End_Object

        Object oEmployer_GLInsExpDate is a cDbCJGridColumn
            Entry_Item Employer.GLInsExpDate
            Set piWidth to 100
            Set psCaption to "General Liability"
            Set peDataType to Mask_Date_Window
            Set pbAllowDrag to False
            Set pbAllowRemove to False
            Set piMinimumWidth to 100
            Set piMaximumWidth to 100
            Set pbResizable to False

            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iExpiresIn
                Date dToday
                Sysdate dToday
                Get RowValue of oEmployer_GLInsExpDate iRow to dGLInsExp
                Move (dGLInsExp-dToday) to iExpiresIn
                Case Begin
                    Case (iExpiresIn > 14)
                        Set ComForeColor of hoGridItemMetrics to clGreen
                        Case Break
                    Case (iExpiresIn <= 14 and iExpiresIn >=0)
                        Set ComForeColor of hoGridItemMetrics to clOrange
                        Case Break
                    Case Else //(iExpiresIn < 0)
                        Set ComForeColor of hoGridItemMetrics to clRed
                Case End
                                
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure

            Procedure OnSelectedRowDataChanged String sOldValue String sValue            
                Forward Send OnSelectedRowDataChanged sOldValue sValue
                Send Request_Save
            End_Procedure

        End_Object

        Object oEmployer_AutoInsExpDate is a cDbCJGridColumn
            Entry_Item Employer.AutoInsExpDate
            Set piWidth to 100
            Set psCaption to "Auto Insurance"
            Set peDataType to Mask_Date_Window
            Set pbAllowRemove to False
            Set pbAllowDrag to False
            Set piMinimumWidth to 100
            Set piMaximumWidth to 100
            Set pbResizable to False
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iExpiresIn
                Date dToday
                Sysdate dToday
                Get RowValue of oEmployer_AutoInsExpDate iRow to dAutoInsExp
                Move (dAutoInsExp-dToday) to iExpiresIn
                Case Begin
                    Case (iExpiresIn > 14)
                        Set ComForeColor of hoGridItemMetrics to clGreen
                        Case Break
                    Case (iExpiresIn <= 14 and iExpiresIn >=0)
                        Set ComForeColor of hoGridItemMetrics to clOrange
                        Case Break
                    Case Else //(iExpiresIn < 0)
                        Set ComForeColor of hoGridItemMetrics to clRed
                Case End
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            
            Procedure OnSelectedRowDataChanged String sOldValue String sValue
                Forward Send OnSelectedRowDataChanged sOldValue sValue
                Send Request_Save
            End_Procedure
        End_Object

        Object oEmployer_WorkCompInsDate is a cDbCJGridColumn
            Entry_Item Employer.WorkCompInsDate
            Set piWidth to 100
            Set psCaption to "Workers Comp."
            Set peDataType to Mask_Date_Window
            Set pbAllowDrag to False
            Set pbAllowRemove to False
            Set piMaximumWidth to 100
            Set piMinimumWidth to 100
            Set pbResizable to False
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Integer iExpiresIn
                Date dToday
                Sysdate dToday
                Get RowValue of oEmployer_WorkCompInsDate iRow to dWorkCompExp
                Move (dWorkCompExp-dToday) to iExpiresIn
                Case Begin
                    Case (iExpiresIn > 14)
                        Set ComForeColor of hoGridItemMetrics to clGreen
                        Case Break
                    Case (iExpiresIn <= 14 and iExpiresIn >=0)
                        Set ComForeColor of hoGridItemMetrics to clOrange
                        Case Break
                    Case Else //(iExpiresIn < 0)
                        Set ComForeColor of hoGridItemMetrics to clRed
                Case End
                
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            
            Procedure OnSelectedRowDataChanged String sOldValue String sValue
                Forward Send OnSelectedRowDataChanged sOldValue sValue
                Send Request_Save
            End_Procedure
        End_Object

        Object oEmployer_ContractSignedDate is a cDbCJGridColumn
            Entry_Item Employer.ContractSignedFlag
            Set piWidth to 60
            Set psCaption to "Contract"
            Set peDataType to Mask_Date_Window
            Set pbAllowRemove to False
            Set pbAllowDrag to False
            Set piMinimumWidth to 100
            Set piMaximumWidth to 100
            Set pbResizable to False
            Set pbCheckbox to True
            
            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                Case Begin
                    Case (sValue='1')
                        Set ComForeColor of hoGridItemMetrics to clGreen
                        Case Break
                    Case Else
                        Set ComForeColor of hoGridItemMetrics to clRed
                Case End
                
                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure
            
            Procedure OnSelectedRowDataChanged String sOldValue String sValue
                Forward Send OnSelectedRowDataChanged sOldValue sValue
                Send Request_Save
            End_Procedure

//            Function OnValidating Returns Boolean
//                Boolean bRetVal
//                Forward Get OnValidating to bRetVal
//                //
//                Date dToday
//                Sysdate dToday
//                Move Employer.GLInsExpDate to dGLInsExp
//                Move (dGLInsExp>=dToday) to bGLInsOk
//                Move Employer.AutoInsExpDate to dAutoInsExp
//                Move (dAutoInsExp>=dToday) to bAutoInsOk
//                Move Employer.WorkCompInsDate to dWorkCompExp
//                Move (dWorkCompExp>=dToday) to bWorkCompOk
//    
//                //Set pbEditable of oEmployer_ContractSignedDate to (bGLInsOk and bAutoInsOk and bWorkCompOk)
//                If (not(bGLInsOk and bAutoInsOk and bWorkCompOk)) Begin
//                    Move True to bRetVal
//                    Send Info_Box "Contract can not be signed until all insurances are dated correctly" "Warning"
//                End
//
//                Function_Return bRetVal
//            End_Function


        End_Object

        Object oEmployer_BillingInstrFlag is a cDbCJGridColumn
            // Used to be called VerificationFlag before being used for TempusField and Billing instructions
            Entry_Item Employer.VerificationFlag
            Set piWidth to 60
            Set psCaption to "Billing Instr."
            Set pbCheckbox to True
            Set pbVisible to True
            Set pbEditable to False
        End_Object

        Object oEmployer_Status is a cDbCJGridColumn
            Entry_Item Employer.Status
            Set piWidth to 100
            Set psCaption to "Status"
            Set pbComboButton to True
            Set pbAllowRemove to False
            Set pbAllowDrag to False
            Set piMaximumWidth to 100
            Set piMinimumWidth to 100
            Set pbResizable to False

            Procedure OnSetDisplayMetrics Handle hoGridItemMetrics Integer iRow String  ByRef sValue
                String sStatus
                
                Get RowValue of oEmployer_Status iRow to sStatus
                If (sStatus = "A") Begin
                    Set ComForeColor of hoGridItemMetrics to clGreen
                End
                If (sStatus = "I" or sStatus = "T") Begin
                    Set ComForeColor of hoGridItemMetrics to clRed
                End

                Forward Send OnSetDisplayMetrics hoGridItemMetrics iRow (&sValue)
            End_Procedure

            Procedure OnEndEdit String sOldValue String sNewValue
                Forward Send OnEndEdit sOldValue sNewValue
                Send Request_Save
            End_Procedure

        End_Object

        Object oCJContextMenu is a cCJContextMenu
            Object oEditEmployerMenuItem is a cCJMenuItem
                Set psCaption to "Edit Employer"
                Set psTooltip to "Edit Employer"

                Procedure OnExecute Variant vCommandBarControl
                    Forward Send OnExecute vCommandBarControl
                    Send DoEditEmployers of oEmployerEntry (Current_Record(oEmployer_DD))
                End_Procedure
            End_Object

            Object oEmailEmployerMenuItem is a cCJMenuItem
                Set psCaption to "Email Employer"
                Set psTooltip to "Email Employer"
                Set peControlType to xtpControlPopup

//                Object oBLANKMenuItem is a cCJMenuItem
//                    Set psCaption to "BLANK"
//                    Set psTooltip to "BLANK"
//                    
//                    Procedure OnExecute Variant vCommandBarControl
//                        Forward Send OnExecute vCommandBarControl
//                        String sEmailAddress sEmailQuery
//                        Move Employer.EmailAddress to sEmailAddress
//                        Move ("mailto:" + sEmailAddress +"?subject=")        to sEmailQuery  
//                        
//                        Runprogram Shell Background sEmailQuery
//                    End_Procedure
//                End_Object
                
                Object oLastYearsInfoMenuItem is a cCJMenuItem
                    Set psCaption to "Last Years Info"
                    Set psTooltip to "Last Years Info"

                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        Integer iEmployerIdno
                        String[] sFilePath 
                        String[] sFileName 
                        String sEmplrName sHTMLMsg
                        Boolean bSuccess
                        //
                        Move Employer.EmployerIdno to iEmployerIdno
                        Move (Trim(Employer.Name)) to sEmplrName
                        If (iEmployerIdno<>0) Begin
                            Send DoExportReport of oEquipmentListReportView Employer.EmployerIdno "A" (&sFilePath[0]) (&sFileName[0]) False
                            Send DoExportReport of oEmployeeListReportView Employer.EmployerIdno "A" (&sFilePath[1]) (&sFileName[1]) False
                            //
                            tEmail eMessage
                            //FROM
                            Move "no-reply@interstatepm.com" to eMessage.sFromEmail
                            //TO
                            Move (Trim(Employer.Main_contact)) to eMessage.stToEmail[0].sFriendlyName
                            Move (Trim(Employer.EmailAddress)) to eMessage.stToEmail[0].sEmailAddress
                            //Move "Ben Bungarten" to eMessage.stToEmail[0].sFriendlyName
                            //Move "ben@interstatepm.com" to eMessage.stToEmail[0].sEmailAddress
                            //BCC
                            Move "Kristin Larson" to eMessage.stBCCEmail[0].sFriendlyName
                            Move "kristin@interstatepm.com" to eMessage.stBCCEmail[0].sEmailAddress
                            Move "Jeff Towers" to eMessage.stBCCEmail[1].sFriendlyName
                            Move "jeff@interstatepm.com" to eMessage.stBCCEmail[1].sEmailAddress
                            // ReplyTo:
                            Move "Kristin Larson" to eMessage.stReplyTo[0].sFriendlyName
                            Move "kristin@interstatepm.com" to eMessage.stReplyTo[0].sEmailAddress
                            //Move "Jeff Towers" to eMessage.stReplyTo[1].sFriendlyName
                            //Move "jeff@interstatepm.com" to eMessage.stReplyTo[1].sEmailAddress
                            //ATTACHMENTS
                            Move (sFilePath[0]+sFileName[0]) to eMessage.sAttachmentFilePath[0] //Equipment
                            Move (sFilePath[1]+sFileName[1]) to eMessage.sAttachmentFilePath[1] //Employees
                            Move (sFilePath[0]+'W9.pdf') to eMessage.sAttachmentFilePath[2] //W9 Form
                            //SUBJECT
                            Move "Interstate Companies - Current Info" to eMessage.sSubject
                            //BODY
                            Append sHTMLMsg ("Hello,"+Character(10)+Character(10))
                            Append sHTMLMsg ("Attached is your last year's information, please review the attachment. If there are changes please cross of what is incorrect and add the new information."+Character(10)+Character(10))
                            Append sHTMLMsg ("Please note insurance must be current, please send your COI's over to Kristin@interstatepm.com."+Character(10)+Character(10))
                            Append sHTMLMsg ("If your Vehicle is not listed under the Certificate of Insurance please provide her with a copy of your Auto Policy."+Character(10))
                            Append sHTMLMsg ("We have attached a W-9 to this email, we are asking each Subcontractor fill one out. This way we can make sure the information we have for you on file  is correct and up to date."+Character(10)+Character(10))
                            Append sHTMLMsg ("After receiving all requested documents we will update your information and proceed with sending you over the Subcontractor Agreement."+Character(10)+Character(10))
                            Append sHTMLMsg ("Please contact Jeff Towers if you have any questions at 651-319-6087."+Character(10)+Character(10))
                            Append sHTMLMsg ("Thank you.")
                            Move sHTMLMsg to eMessage.sBody
                            //
                            Get OpenEmailMessage of (oEmailSend(Self)) eMessage to bSuccess
                            
                        End
                    End_Procedure

                    
//                    Procedure OnExecute Variant vCommandBarControl
//                        Forward Send OnExecute vCommandBarControl
//                        String sEmailAddress sEmailQuery sBody
//                        Move Employer.EmailAddress to sEmailAddress
//                        
//                        Move ("Hello,%0D%0A") to sBody
//                        Append sBody ("Attached is last year's information, please review. If there are changes, cross off any information that is incorrect and write in new information.%0D%0A")
//                        Append sBody ("Please note insurance must be current, please send us your current policies.%0D%0A")
//                        Append sBody ("After updating, we will send over the new Subcontractor Agreement.%0D%0A")
//                        Append sBody ("Please contact Jeff Towers if you have any questions at 651-319-6087.%0D%0A%0D%0A")
//                        Append sBody ("Thank you.%0D%0A%0D%0A")
//                        Move ("mailto:" + sEmailAddress +"?subject=Contract Info&body="+sBody)        to sEmailQuery  
//                        Runprogram Shell Background sEmailQuery
//                    End_Procedure
                    
                End_Object

                Object oLastYearsInfoMenuItem is a cCJMenuItem
                    Set psCaption to "Last Years Info (Outlook)"
                    Set psTooltip to "Last Years Info (Outlook)"

                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        Integer iEmployerIdno
                        String[] sFilePath 
                        String[] sFileName 
                        String sEmplrName sHTMLMsg
                        Boolean bSuccess
                        //
                        Move Employer.EmployerIdno to iEmployerIdno
                        Move (Trim(Employer.Name)) to sEmplrName
                        If (iEmployerIdno<>0) Begin
                            Send DoExportReport of oEquipmentListReportView Employer.EmployerIdno "A" (&sFilePath[0]) (&sFileName[0]) False
                            Send DoExportReport of oEmployeeListReportView Employer.EmployerIdno "A" (&sFilePath[1]) (&sFileName[1]) False
                            //
                            tEmail eMessage
                            //FROM
                            Move "no-reply@interstatepm.com" to eMessage.sFromEmail
                            //TO
                            Move (Trim(Employer.Main_contact)) to eMessage.stToEmail[0].sFriendlyName
                            Move (Trim(Employer.EmailAddress)) to eMessage.stToEmail[0].sEmailAddress
                            //Move "Ben Bungarten" to eMessage.stToEmail[0].sFriendlyName
                            //Move "ben@interstatepm.com" to eMessage.stToEmail[0].sEmailAddress
                            //BCC
                            Move "Kristin Larson" to eMessage.stBCCEmail[0].sFriendlyName
                            Move "kristin@interstatepm.com" to eMessage.stBCCEmail[0].sEmailAddress
                            Move "Jeff Towers" to eMessage.stBCCEmail[1].sFriendlyName
                            Move "jeff@interstatepm.com" to eMessage.stBCCEmail[1].sEmailAddress
                            // ReplyTo:
                            Move "Kristin Larson" to eMessage.stReplyTo[0].sFriendlyName
                            Move "kristin@interstatepm.com" to eMessage.stReplyTo[0].sEmailAddress
                            //Move "Jeff Towers" to eMessage.stReplyTo[1].sFriendlyName
                            //Move "jeff@interstatepm.com" to eMessage.stReplyTo[1].sEmailAddress
                            //ATTACHMENTS
                            Move (sFilePath[0]+sFileName[0]) to eMessage.sAttachmentFilePath[0] //Equipment
                            Move (sFilePath[1]+sFileName[1]) to eMessage.sAttachmentFilePath[1] //Employees
                            Move (sFilePath[0]+'W9.pdf') to eMessage.sAttachmentFilePath[2] //W9 Form
                            //SUBJECT
                            Move "Interstate Companies - Current Info" to eMessage.sSubject
                            //BODY
                            Append sHTMLMsg ("<p>Hello,<br><br>")
                            Append sHTMLMsg ("Attached is your last year's information, please review the attachment. If there are changes please cross of what is incorrect and add the new information.<br><br>")
                            Append sHTMLMsg ("Please note insurance must be current, please send your COI's over to <a href='mailto:kristin@interstatepm.com'>Kristin@interstatepm.com</a>.<br><br>")
                            Append sHTMLMsg ("If your Vehicle is not listed under the Certificate of Insurance please provide her with a copy of your Auto Policy.<br>")
                            Append sHTMLMsg ("We have attached a W-9 to this email, we are asking each Subcontractor fill one out. This way we can make sure the information we have for you on file  is correct and up to date.<br><br>")
                            Append sHTMLMsg ("After receiving all requested documents we will update your information and proceed with sending you over the Subcontractor Agreement.<br><br>")
                            Append sHTMLMsg ("Please contact Jeff Towers if you have any questions at 651-319-6087.<br><br>")
                            Append sHTMLMsg ("Thank you.")
                            Move (sHTMLMsg) to eMessage.sBody
                            //
                            //Get OpenEmailMessage of (oEmailSend(Self)) eMessage to bSuccess
                            Get BuildOutlookEmailObject of oCustomEmailNotification eMessage to bSuccess
                            
                        End
                    End_Procedure

                    
//                    Procedure OnExecute Variant vCommandBarControl
//                        Forward Send OnExecute vCommandBarControl
//                        String sEmailAddress sEmailQuery sBody
//                        Move Employer.EmailAddress to sEmailAddress
//                        
//                        Move ("Hello,%0D%0A") to sBody
//                        Append sBody ("Attached is last year's information, please review. If there are changes, cross off any information that is incorrect and write in new information.%0D%0A")
//                        Append sBody ("Please note insurance must be current, please send us your current policies.%0D%0A")
//                        Append sBody ("After updating, we will send over the new Subcontractor Agreement.%0D%0A")
//                        Append sBody ("Please contact Jeff Towers if you have any questions at 651-319-6087.%0D%0A%0D%0A")
//                        Append sBody ("Thank you.%0D%0A%0D%0A")
//                        Move ("mailto:" + sEmailAddress +"?subject=Contract Info&body="+sBody)        to sEmailQuery  
//                        Runprogram Shell Background sEmailQuery
//                    End_Procedure
                    
                End_Object


//                Object oContractMenuItem is a cCJMenuItem
//                    Set psCaption to "Contract"
//                    Set psTooltip to "Contract"
//
//                    Procedure OnExecute Variant vCommandBarControl
//                        Forward Send OnExecute vCommandBarControl
//                        Integer iEmployerIdno
//                        String sPath sFileName sEmplrName sHTMLMsg
//                        Boolean bSuccess
//                        //
//                        Move Employer.EmployerIdno to iEmployerIdno
//                        Move (Trim(Employer.Name)) to sEmplrName
//                        If (iEmployerIdno<>0) Begin
//                            Get psHome of (phoWorkspace(ghoApplication)) to sPath
//                            Move (sPath+"Reports\Cache\SubcontractorAgreements\"+sEmplrName+"-Contractor#"+(String(iEmployerIdno))+".pdf") to sFileName
//                            Send DoExportReport of oSubcontractorAgreementReportView iEmployerIdno sFileName False
//                            //
//                            tEmail eMessage
//                            //FROM
//                            Move "no-reply@interstatepm.com" to eMessage.sFromEmail
//                            //TO
//                            Move (Trim(Employer.Main_contact)) to eMessage.stToEmail[0].sFriendlyName
//                            Move (Trim(Employer.EmailAddress)) to eMessage.stToEmail[0].sEmailAddress
//                            //Move "Ben Bungarten" to eMessage.stToEmail[0].sFriendlyName
//                            //Move "ben@interstatepm.com" to eMessage.stToEmail[0].sEmailAddress
//                            //BCC
//                            Move "Kristin Larson" to eMessage.stBCCEmail[0].sFriendlyName
//                            Move "kristin@interstatepm.com" to eMessage.stBCCEmail[0].sEmailAddress
//                            Move "Jeff Towers" to eMessage.stBCCEmail[1].sFriendlyName
//                            Move "jeff@interstatepm.com" to eMessage.stBCCEmail[1].sEmailAddress
//                            // ReplyTo:
//                            Move "Kristin Larson" to eMessage.stReplyTo[0].sFriendlyName
//                            Move "kristin@interstatepm.com" to eMessage.stReplyTo[0].sEmailAddress
//                            //Move "Jeff Towers" to eMessage.stReplyTo[1].sFriendlyName
//                            //Move "jeff@interstatepm.com" to eMessage.stReplyTo[1].sEmailAddress
//                            //ATTACHMENTS
//                            Move sFileName to eMessage.sAttachmentFilePath[0]
//                            //SUBJECT
//                            Move "Interstate Companies - Contractor Agreement" to eMessage.sSubject
//                            //BODY
//                            Append sHTMLMsg ("Hi"*sEmplrName+Character(10))
//                            Append sHTMLMsg ("Attached is your Subcontractor Agreement for this season."+Character(10))
//                            Append sHTMLMsg ("Please review, initial the bottom of all pages, sign and Date where indicated and return to me."+Character(10))
//                            Append sHTMLMsg ("I will then Send you back a fully executed copy for your files."+Character(10))
//                            Append sHTMLMsg ("Please feel free to contact me If you have any questions."+Character(10))
//                            Append sHTMLMsg ("Thank you very much.")
//                            Move sHTMLMsg to eMessage.sBody
//                            //
//                            Get OpenEmailMessage of (oEmailSend(Self)) eMessage to bSuccess
//                            
//                        End
//                    End_Procedure
//                    
////                    Procedure OnExecute Variant vCommandBarControl
////                        Forward Send OnExecute vCommandBarControl
////                        String sEmailAddress sEmailQuery sBody
////                        
////                        Move ("Hello:%0D%0A") to sBody
////                        Append sBody ("Attached is your Subcontractor Agreement for this season.%0D%0A")
////                        Append sBody ("Please review, initial the bottom of all pages, sign and Date where indicated and return to me.%0D%0A")
////                        Append sBody ("I will then Send you back a fully executed copy for your files.%0D%0A")
////                        Append sBody ("Please feel free to contact me If you have any questions.%0D%0A")
////                        Append sBody ("Thank you very much.%0D%0A%0D%0A")
////                        Move Employer.EmailAddress to sEmailAddress
////                        Move ("mailto:" + sEmailAddress +"?subject=Contract&body="+sBody) to sEmailQuery  
////                        
////                        Runprogram Shell Background sEmailQuery
////                    End_Procedure
//                    
//                End_Object

                Object oInsuranceMenuItem is a cCJMenuItem
                    Set psCaption to "Insurance"
                    Set psTooltip to "Insurance"
                    
                    Procedure OnExecute Variant vCommandBarControl
                        Forward Send OnExecute vCommandBarControl
                        String sEmailAddress sSubject sEmailQuery sBody
                        Move (Trim(Employer.EmailAddress)) to sEmailAddress
                        Move "Insurance Information" to sSubject
                        
                        Move ("Hello: %0D") to sBody
                        Move (sBody + "You are notified because some or all of your current insurance will expire shortly.%0D") to sBody
                        Move (sBody + "Attached is a sample of Interstate's Insurance requirements that you can forward to your agent so they can send over a current COI.%0D") to sBody
                        Move (sBody + "NOTE:We are no longer Interstate Pavement Maintenance, please update any records to reflect our new name of Interstate Removal, LLC.%0D") to sBody
                        Move (sBody + "Feel free to contact me if you have any questions.%0D") to sBody
                        Move (sBody + "Thank you very much.") to sBody
                        //
                        Move ("mailto:"+sEmailAddress+"?subject="+sSubject+"&body="+sBody)        to sEmailQuery  
                        //

                        Runprogram Shell Background sEmailQuery
                    End_Procedure
                End_Object
            End_Object
            
            Object oPrintContractMenuItem is a cCJMenuItem
                Set psCaption to "Print Contract"
                Set psTooltip to "Print Contract"

                Procedure OnExecute Variant vCommandBarControl
                    Forward Send OnExecute vCommandBarControl
                    Integer iEmployerIdno
                    String sPath sEmplrName sFileName
                    Move Employer.EmployerIdno to iEmployerIdno
                    Move (Trim(Employer.Name)) to sEmplrName
                    If (iEmployerIdno<>0) Begin
                        //Send DoJumpStartReport of SubcontractorContract iEmployerIdno
                        Get psHome of (phoWorkspace(ghoApplication)) to sPath
                        Move (sPath+"Reports\Cache\SubcontractorAgreements\"+sEmplrName+"-Contractor#"+(String(iEmployerIdno))+".pdf") to sFileName
                        Send DoExportReport of oSubcontractorAgreementReportView iEmployerIdno sFileName True
                    End
                    Else Begin
                        Send Info_Box ("No Employer Selected") "Please Select an Employer"
                    End
                End_Procedure
            End_Object

//            Object oCreateWebAppUsersMenuItem is a cCJMenuItem
//                Set psCaption to "Create WebApp Users"
//                Set psTooltip to "Create WebApp Users"
//                
//                Procedure OnExecute Variant vCommandBarControl
//                    Forward Send OnExecute vCommandBarControl
//                    Integer iEmployerIdno
//                    Move Employer.EmployerIdno to iEmployerIdno
//                    If (iEmployerIdno<>0) Begin
//                        Send 
//                    End
//                    Else Begin
//                        Send Info_Box ("No Employer Selected") "Please Select an Employer"
//                    End
//                End_Procedure
//            End_Object
            
            Procedure OnPopupInit Variant vCommandBarControl Handle hoCommandBarControls
                Boolean bCanPrint bHasMinSysAdminRights
                Get canPrintContract to bCanPrint
                Move (giUserRights>=90) to bHasMinSysAdminRights
                //
                Forward Send OnPopupInit vCommandBarControl hoCommandBarControls
                //
                Set pbEnabled of oPrintContractMenuItem to True //bCanPrint
                Set pbVisible of oSystemAdminMenuItem to bHasMinSysAdminRights
                Set pbEnabled of oSystemAdminMenuItem to bHasMinSysAdminRights
            End_Procedure
            
            Function canPrintContract Returns Boolean
                Date dToday
                Sysdate dToday
                Function_Return ((Employer.GLInsExpDate>=dToday) and (Employer.AutoInsExpDate>=dToday) and (Employer.WorkCompInsDate>=dToday))
            End_Function

            Object oSystemAdminMenuItem is a cCJMenuItem
                Set psCaption to "System Admin"
                Set psTooltip to "System Admin"
                Set peControlType to xtpControlPopup

                Object oUpdateMenuItem is a cCJMenuItem
                    Set psCaption to "Update"
                    Set psTooltip to "Update"
                    Set peControlType to xtpControlPopup

                    Object oEmployeeWebAppUserRightsMenuItem is a cCJMenuItem
                        Set psCaption to "Set Employee/WebAppUser Rights"
                        Set psTooltip to "Set Employee/WebAppUser Rights"
                        
                        Property String psRights
                        Property String psEmployer

                        Procedure OnExecute Variant vCommandBarControl
                            Forward Send OnExecute vCommandBarControl
                            String sWebAppUserRightsLevel sEmployerIdno
                            Boolean bCancel
                            
                            Get Field_Current_Value of oEmployer_DD Field Employer.EmployerIdno to sEmployerIdno
                            Get GetWebAppUserRights of WebAppUserRights_sl "" (&sWebAppUserRightsLevel) to bCancel
                            If (not(bCancel) and sEmployerIdno<>'0' and sWebAppUserRightsLevel<>'0') Begin
                                Send UpdateEmployeeWebAppRights sEmployerIdno sWebAppUserRightsLevel
                            End
                            
                        End_Procedure
                        
                        Procedure UpdateEmployeeWebAppRights Integer iEmployer Integer iRights
                            Boolean bFail
                            Integer iLastEmployee iFoundCount iChangeCount iFailCount
                            Send Clear of oEmployee_DD
                            Move iEmployer to Employee.EmployerIdno
                            Send Find of oEmployee_DD GE 8
                            While ((Found) and Employee.EmployerIdno = iEmployer)
                                Increment iFoundCount
                                Get Field_Current_Value of oEmployee_DD Field Employee.EmployeeIdno to iLastEmployee
                                Set Field_Changed_Value of oEmployee_DD Field Employee.WebAppUserRights to iRights
                                Get Request_Validate of oEmployee_DD to bFail
                                If (not(bFail)) Begin
                                    Send Request_Save of oEmployee_DD
                                    If (not(Err)) Increment iChangeCount
                                End
                                Else Begin
                                    Increment iFailCount
                                End
                                Send Clear of oEmployee_DD
                                Move iEmployer to Employee.EmployerIdno
                                Move iLastEmployee to Employee.EmployeeIdno
                                Send Find of oEmployee_DD GT 8
                            Loop
                            Send Info_Box ("Completed: Employer#"*String(iEmployer)+" | Found:"*String(iFoundCount)+" | Changed:"+String(iChangeCount)+" | Failed:"+String(iFailCount))
                            
                        End_Procedure
                        
                    End_Object
                End_Object

                Object oInstructionsMenuItem is a cCJMenuItem
                    Set psCaption to "Instructions"
                    Set psTooltip to "Instructions"
                    Set peControlType to xtpControlPopup
                    
                    Object oPortalInstMenuItem is a cCJMenuItem
                        Set psCaption to "Contractor Portal"
                        Set psTooltip to "Contractor Portal"

                        Procedure OnExecute Variant vCommandBarControl
                            Forward Send OnExecute vCommandBarControl
                            String sEmployerIdno sExportFileName
                            Boolean bSuccess
                            Get Field_Current_Value of oEmployer_DD Field Employer.EmployerIdno to sEmployerIdno
                            Get DoExportReport of oVendor_BillingInstructionsReportView sEmployerIdno (&sExportFileName) True to bSuccess
                            If (not(bSuccess)) Begin
                                Send Stop_Box "Unable to create the file." "Error"
                            End
                        End_Procedure
                    End_Object
  
                    Object oFieldAppInstMenuItem is a cCJMenuItem
                        Set psCaption to "Tempus Field"
                        Set psTooltip to "Tempus Field"

                        Procedure OnExecute Variant vCommandBarControl
                            Forward Send OnExecute vCommandBarControl
                            String sEmployerIdno sExportFileName
                            Boolean bSuccess
                            Get Field_Current_Value of oEmployer_DD Field Employer.EmployerIdno to sEmployerIdno
                            //Send DoJumpStartReport of oVendor_TempusFieldInstructionsReportView sEmployerIdno True
                            Get DoExportReport of oVendor_TempusFieldInstructionsReportView sEmployerIdno (&sExportFileName) True to bSuccess
                            If (not(bSuccess)) Begin
                                Send Stop_Box "Unable to create the file." "Error"
                            End
                        End_Procedure
                    End_Object
                    
                    
                    
                End_Object
                
                Object oEmailMenuItem is a cCJMenuItem
                    Set psCaption to "Email"
                    Set psTooltip to "Email"
                    Set peControlType to xtpControlPopup
                    
                    Object oEmailInstructionsMenuItem is a cCJMenuItem
                        Set psCaption to "Contractor Portal + Tempus Field"
                        Set psTooltip to "Contractor Portal + Tempus Field"

                        Procedure OnExecute Variant vCommandBarControl
                            Integer iEmployerIdno
                            String sFileName sEmplrName sEmplrEmail sHTMLMsg
                            Boolean bSuccess
                            //
                            Move Employer.EmployerIdno to iEmployerIdno
                            Move (Trim(Employer.Name)) to sEmplrName
                            Move (Trim(Employer.EmailAddress)) to sEmplrEmail
                            If (iEmployerIdno<>0) Begin
                                tEmail eMessage
                                // Create and Prep both files
                                //ATTACHMENTS
                                Get DoExportReport of oVendor_BillingInstructionsReportView iEmployerIdno (&eMessage.sAttachmentFilePath[0]) False to bSuccess
                                Get DoExportReport of oVendor_TempusFieldInstructionsReportView iEmployerIdno (&eMessage.sAttachmentFilePath[1]) False to bSuccess
                                //
                                //FROM
                                Move "no-reply@interstatepm.com" to eMessage.sFromEmail
                                //TO
                                Move (Trim(Employer.Main_contact)) to eMessage.stToEmail[0].sFriendlyName
                                Move (Trim(Employer.EmailAddress)) to eMessage.stToEmail[0].sEmailAddress
                                //BCC
                                Move "Jeff Towers" to eMessage.stBCCEmail[0].sFriendlyName
                                Move "jeff@interstatepm.com" to eMessage.stBCCEmail[0].sEmailAddress
                                Move "Benjamin Bungarten" to eMessage.stBCCEmail[1].sFriendlyName
                                Move "ben@interstatepm.com" to eMessage.stBCCEmail[1].sEmailAddress
                                // ReplyTo:
                                Move "Ben Bungarten" to eMessage.stReplyTo[0].sFriendlyName
                                Move "ben@interstatepm.com" to eMessage.stReplyTo[0].sEmailAddress
                                //Move "Jeff Towers" to eMessage.stReplyTo[1].sFriendlyName
                                //Move "jeff@interstatepm.com" to eMessage.stReplyTo[1].sEmailAddress
                                //SUBJECT
                                Move "Interstate Companies - Billing Portal and Time Tracking" to eMessage.sSubject
                                //BODY
                                Append sHTMLMsg ("Hello"*(Trim(Employer.Main_contact))+","+Character(10)+Character(10))
                                Append sHTMLMsg ("Welcome to Interstate Companies."+Character(10)+Character(10))
                                Append sHTMLMsg ("Please review the two attached PDF files to become familiar with the usage of Tempus Field our Time Tracking App and the Contractor Billing Portal used to submit your invoices to Interstate Companies."+Character(10))
                                Append sHTMLMsg (">>>Beware the files contain personalized login information and credentials. Please do not share with anyone outside of your organization.<<<"+Character(10)+Character(10))
                                Append sHTMLMsg (" - Tempus Field: https://interstatepm.com/apps | Time Tracking Mobile App"+Character(10))
                                Append sHTMLMsg (" - Tempus Billing: https://interstatepm.com/billing | Billing Portal"+Character(10)+Character(10))
                                Append sHTMLMsg ("Please feel free to contact me if you have any questions."+Character(10)+Character(10))
                                Append sHTMLMsg ("Kind regards,"+Character(10))
                                Append sHTMLMsg ("Ben Bungarten"+Character(10))
                                Append sHTMLMsg ("651-361-8622 | ben@interstatepm.com ")
                                Move sHTMLMsg to eMessage.sBody
                                //
                                Get OpenEmailMessage of (oEmailSend(Self)) eMessage to bSuccess
                            End
                        End_Procedure
                        
                        

                        
//                        Procedure OnExecute Variant vCommandBarControl
//                            Forward Send OnExecute vCommandBarControl
//                            //
//                            String sMainContact sEmailAddress sBody sEmailQuerry  
//                            Move Employer.EmailAddress to sEmailAddress
//                            Move (Trim(Employer.Main_contact)) to sMainContact
//                            
//                            Move ("Hi "+sMainContact+",%0D%0A"+;
//                            "Welcome to Interstate Companies.%0D%0A"+;
//                            "%0D%0A"+;
//                            "Please find attached two PDF files with instructions on how to access and use the Contractor Portal and Tempus Field App.%0D%0A"+;
//                            ">>>The file also contains your credentials to access the Contractor Portal<<<%0D%0A"+;
//                            "%0D%0A"+;
//                            "Please feel free to contact me if you have any questions.%0D%0A%0D%0A"+;
//                            "%0D%0A") to sBody
//                            Move ("mailto:"+sEmailAddress+"&cc=jeff@interstatepm.com?subject=Interstate%20Companies%20-%20Contractor%20Portal%20Info&body="+sBody) to sEmailQuerry 
//                            Runprogram Shell Background sEmailQuerry
//                        End_Procedure
                        
                    End_Object
                    
                    
                    
                End_Object
                
            End_Object
            
        End_Object

        Object oEmployer_TruckingOnlyFlag is a cDbCJGridColumn
            Entry_Item Employer.TruckingOnlyFlag
            Set psCaption to "TruckingOnlyFlag"
            Set pbVisible to False
        End_Object

//        Procedure OnComFocusChanging Variant llNewRow Variant llNewColumn Variant llNewItem Boolean  ByRef llCancel            
//            Forward Send OnComFocusChanging llNewRow llNewColumn llNewItem (&llCancel)
//            Date dToday
//            Sysdate dToday
//            Move Employer.GLInsExpDate to dGLInsExp
//            Move (dGLInsExp>=dToday) to bGLInsOk
//            Move Employer.AutoInsExpDate to dAutoInsExp
//            Move (dAutoInsExp>=dToday) to bAutoInsOk
//            Move Employer.WorkCompInsDate to dWorkCompExp
//            Move (dWorkCompExp>=dToday) to bWorkCompOk
//
//            Set pbEditable of oEmployer_ContractSignedDate to (bGLInsOk and bAutoInsOk and bWorkCompOk)
//        End_Procedure

        Function CountEmployerStatus Integer ByRef iActive Integer ByRef iInactive Integer ByRef iTerminated Returns Boolean
            Boolean bSuccess
            Move 0 to iActive
            Move 0 to iInactive
            Move 0 to iTerminated
            
            Constraint_Set 1
            Constrained_Find First Employer by 1
            While (Found)
                Case Begin
                    Case (Employer.Status = "A")
                        Increment iActive
                        Case Break
                    Case (Employer.Status = "I")
                        Increment iInactive
                        Case Break
                    Case (Employer.Status = "T")
                        Increment iTerminated
                        Case Break
                Case End
                Constrained_Find Next
            Loop
            Move True to bSuccess
            Constraint_Set 1 Delete 
            Function_Return bSuccess
        End_Function

        Procedure Activating
            Forward Send Activating
            Integer iActive iInactive iTerminated
            Boolean bSuccess bHasSysAdmin bHasAdmin
            //
            Move (giUserRights>=70) to bHasAdmin
            Move (giUserRights>=90) to bHasSysAdmin
            //
            Set pbEditable of oEmployer_ManagedBy to bHasAdmin
            Set pbEditable of oEmployer_LastTimeNotifyed to bHasAdmin
            Set pbEditable of oEmployer_W9Flag to bHasAdmin
            Set pbEditable of oEmployer_GLInsExpDate to bHasAdmin
            Set pbEditable of oEmployer_AutoInsExpDate to bHasAdmin
            Set pbEditable of oEmployer_WorkCompInsDate to bHasAdmin
            Set pbEditable of oEmployer_ContractSignedDate to bHasAdmin
            //
            Set pbEditable of oEmployer_BillingInstrFlag to bHasSysAdmin
            //
            Get CountEmployerStatus (&iActive) (&iInactive) (&iTerminated) to bSuccess
            If (bSuccess) Begin
                Set Label of oActiveEmployerCheckBox to ('Active ('+String(iActive) +')')
                Set Label of oInactiveEmployerCheckBox to ('Inactive ('+String(iInactive) +')')
                Set Label of oTerminatedEmployerCheckBox to ('Terminated ('+String(iTerminated) +')')
            End
            Send MovetoFirstRow of oEmployerGrid
        End_Procedure

        Procedure OnComRowRClick Variant llRow Variant llItem
            //Forward Send OnComRowRClick llRow llItem
            Send Popup of oCJContextMenu
        End_Procedure

        Procedure OnComRowDblClick Variant llRow Variant llItem
            Forward Send OnComRowDblClick llRow llItem
            Send DoEditEmployers of oEmployerEntry (Current_Record(oEmployer_DD))
        End_Procedure

//        Procedure Activating
//            Boolean bGLInsOk bAutoInsOk
//            Date dToday
//            Sysdate dToday            
//            Move (Employer.GLInsExpDate >= dToday) to bGLInsOk
//            Move (Employer.AutoInsExpDate >= dToday) to bAutoInsOk
//            If (not(bGLInsOk) or not(bAutoInsOk)) Begin
//                
//            End
//            
//            Forward Send Activating
//        End_Procedure

    End_Object
        
    Procedure Activate_View
        If (giUserRights GE 60) Begin
            Forward Send Activate_View
            If (giUserRights GE 70) Begin
                Set pbAllowEdit of oEmployerGrid to True
            End
            Else Begin
                Set pbAllowEdit of oEmployerGrid to False
            End
        End
        Else Begin
            Send Info_Box "You have no permission to open this view!"
        End        
    End_Procedure

    Object oStatusGroup is a Group
        Set Size to 25 182
        Set Location to 3 5
        Set Label to 'Status'

        Object oActiveEmployerCheckBox is a CheckBox
            Set Size to 10 37
            Set Location to 11 9
            Set Label to 'Active'
            Set Checked_State to True
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oEmployer_DD
                Send MovetoFirstRow of oEmployerGrid
            End_Procedure
        End_Object

        Object oInactiveEmployerCheckBox is a CheckBox
            Set Size to 10 40
            Set Location to 11 61
            Set Label to 'Inactive'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oEmployer_DD
                Send MovetoFirstRow of oEmployerGrid
            End_Procedure
        
        End_Object

        Object oTerminatedEmployerCheckBox is a CheckBox
            Set Size to 10 50
            Set Location to 11 116
            Set Label to 'Terminated'
        
            //Fires whenever the value of the control is changed
            Procedure OnChange
                Boolean bChecked
            
                Get Checked_State to bChecked
                Send Rebuild_Constraints of oEmployer_DD
                Send MovetoFirstRow of oEmployerGrid
            End_Procedure
        
        End_Object
    End_Object
    
End_Object
