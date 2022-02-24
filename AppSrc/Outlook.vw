Use Windows.pkgUse DFClient.pkg
Use msoutl.pkg


Deferred_View Activate_oOutlook for ;
Object oOutlook is a dbView
    
    Set Border_Style to Border_Thick
    Set Size to 200 300
    Set Location to 2 2
    Set Label to "Outlook"
    Object oOutlook is a cComApplication
    End_Object
    
    Object o_A_envoyer is a cComMailItem
    End_Object
    
    Object oRecipients is a cComRecipients
    End_Object
    
    Object oAttachments is a cComAttachments
    End_Object


    Object oCB_stop is a CheckBox
        Set Size to 10 50
        Set Location to 43 97
        Set Label to "Stop before sending"
    End_Object
    
    Object oButton1 is a Button
        Set Location to 72 92
        Set Label to 'oButton1'
    
        // fires when the button is clicked
        Procedure OnClick
            Variant v_A_envoyer v_recipients v_email v_result v_attachments
            Handle h_outlook h_A_envoyer h_recipients h_attachments
            Boolean b_IsComObjectCreated b_arret
            
            Move oOutlook to h_outlook
            Move o_A_envoyer to h_A_envoyer
            Move oRecipients to h_recipients
            Move oAttachments to h_attachments
            Get Checked_State of oCB_stop to b_arret
            
            Get IsComObjectCreated of h_outlook to b_IsComObjectCreated
            If (not(b_IsComObjectCreated)) Begin
                Send CreateComObject of h_outlook
                Get IsComObjectCreated of h_outlook to b_IsComObjectCreated
                If (not(b_IsComObjectCreated)) Begin
                    Send Stop_Box "MS outlook object non created"
                    Procedure_Return
                End
            End
            Get ComCreateItem of h_outlook OLEolMailItem to v_A_envoyer
            Set pvComObject of h_A_envoyer to v_A_envoyer
            Set ComSubject of h_A_envoyer to "Hello world"
            Get ComRecipients of h_A_envoyer to v_recipients    
            Set pvComObject of h_recipients to v_recipients
            Get ComAdd of h_recipients "abcd@efgh.be" to v_result
            Set ComHTMLBody  of h_A_envoyer to "Here is the body"
            Get ComAttachments of h_A_envoyer to v_attachments
            Set pvComObject of h_attachments to v_attachments
            Get ComAdd of h_attachments  "c:\photos\00_20920.014.jpg" Nothing Nothing Nothing to v_result
            If (b_arret) Send ComDisplay of h_A_envoyer True
            Else Begin
                Send ComDisplay of h_A_envoyer False
                Send ComSend to h_A_envoyer
            End
            Set pvComObject   of h_attachments     to (NullComObject())
            Set pvComObject   of h_recipients    to (NullComObject())
            Set pvComObject   of h_A_envoyer      to (NullComObject())
            Set pvComObject   of h_outlook      to (NullComObject())
        End_Procedure    
    End_Object
Cd_End_Object