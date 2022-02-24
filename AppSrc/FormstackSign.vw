Use Windows.pkg
Use DFClient.pkg
Use cTextEdit.pkg
Use FormstackSignAPI.pkg

Deferred_View Activate_oFormstackSign for ;
Object oFormstackSign is a View

    Property String psLastResponse
    Property String psAccesToken

    Set Border_Style to Border_Thick
    Set Size to 268 494
    Set Location to 2 2
    Set Label to "FormstackSign"

    Object oAuthButton is a Button
        Set Size to 14 58
        Set Location to 6 8
        Set Label to 'Authorization'
    
        // fires when the button is clicked
        Procedure OnClick
            String sResponse sAccesToken
            Integer iStatus
            Boolean bOk bSuccess
            Handle hoJson hoDetails
            //
            Get ClientCredentialsAuthorization (&sAccesToken) (&sResponse) (&iStatus) to bSuccess
            Set Value of oHttpOutput to sResponse
            Set Value of oRespStatus to (String(iStatus))
            If (bSuccess) Begin
                Set psAccesToken to sAccesToken
            End
            
//            
//            If not ((iStatus >= 200) and (iStatus < 300)) Begin
//                Send Info_Box ("Http status:" * String(iStatus)) "Error"
//            End
//            Else Begin
//                
//                // Parse JSON to psAccessToken
//                Get Create (RefClass(cJsonObject)) to hoJson 
//                Get ParseString of hoJson sResponse to bOk
//                If bOk Begin
//                    Get MemberValue of hoJson "access_token" to sAccesToken
//                End
//            End
        End_Procedure
    
    End_Object
    
    Object oMyDocButton is a Button
        Set Size to 14 58
        Set Location to 5 387
        Set Label to 'MyDocuments'
    
        // fires when the button is clicked
        Procedure OnClick
            String sResponse
            Integer iStatus
            Send GetDocuments (psAccesToken(Self)) (&sResponse) (&iStatus)
            If not ((iStatus >= 200) and (iStatus < 300)) Begin
                Send Info_Box ("Http status:" * String(iStatus)) "Error"
                Send AppendTextLn of oHttpOutput sResponse
            End
            Else Begin
                Set Value of oHttpOutput to sResponse
            End
        End_Procedure
    
    End_Object

    Object oRespStatus is a Form
        Set Size to 12 35
        Set Location to 251 452
        Set Label to "Response Status:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 5
        Set Form_Datatype to 0
        Set peAnchors to anBottomRight
        Set Enabled_State to False
        Set psToolTip to "The HTTP status of the response"
    End_Object

    Object oHttpOutput is a cTextEdit
        Set Size to 205 482
        Set Location to 40 6
        Set peAnchors to anAll
    End_Object

    Object oTemplatesButton is a Button
        Set Size to 14 58
        Set Location to 6 129
        Set Label to 'Templates'
    
        // fires when the button is clicked
        Procedure OnClick
            String sResponse
            Integer iStatus
            Send GetTemplates (psAccesToken(Self)) (&sResponse) (&iStatus)
            If not ((iStatus >= 200) and (iStatus < 300)) Begin
                Send Info_Box ("Http status:" * String(iStatus)) "Error"
                Send AppendTextLn of oHttpOutput sResponse
            End
            Else Begin
                Set Value of oHttpOutput to sResponse
            End
        End_Procedure
    
    End_Object

    Object oCreateDocumentButton is a Button
        Set Size to 14 67
        Set Location to 6 189
        Set Label to 'Create Document'
    
        // fires when the button is clicked
        Procedure OnClick
            String sResponse
            Integer iStatus
            
            Send CreateDocument "" "" (&sResponse) (&iStatus)
            If not ((iStatus >= 200) and (iStatus < 300)) Begin
                Send Info_Box ("Http status:" * String(iStatus)) "Error"
                Send AppendTextLn of oHttpOutput sResponse
            End
            Else Begin
                Set Value of oHttpOutput to sResponse
            End
        End_Procedure
    
    End_Object

    Object oUploadFileButton is a Button
        Set Size to 14 67
        Set Location to 6 259
        Set Label to 'Upload File'
    
        // fires when the button is clicked
        Procedure OnClick
            String sResponse sPDFFileName
            Boolean bPDFOk bUplOk 
            Integer iStatus
            //
            Get DoExportReportAsPDF of oSubcontractorAgreementReportView 356 False (&sPDFFileName) to bPDFOk
            If (bPDFOk) Begin
                Get UploadFile (psAccesToken(Self)) sPDFFileName (&sResponse) to bUplOk
            End
            
        End_Procedure
    
    End_Object

Cd_End_Object
