Use Windows.pkg
Use DFClient.pkg
Use cTextEdit.pkg
Use cHttpTransfer.pkg
Use cJsonObject.pkg
Use WinUuid.pkg
  
Deferred_View Activate_oRESTTest for ;
Object oRESTTest is a dbView
    Set Border_Style to Border_Thick
    Set Size to 373 350
    Set Location to 2 2
    Set Label to "REST Tester"
  
    // This is the HTTP object which we will use to make all our calls.
    // It is augmented to store received data in a UChar array property so does
    // *not* suffer from string length limitations (see: Set_Argument_Size).
    //
    // You should always send Reset of this object as the first thing you do
    // making a call.
    Object oHttp is a cHttpTransfer
        Property UChar[] pucaData
        Property String  psContentType
      
        Procedure OnDataReceived String sContentType String sData
            UChar[] ucaData
              
            Get pucaData                                            to ucaData
            Move (AppendArray(ucaData, StringToUCharArray(sData)))  to ucaData
            Set pucaData                                            to ucaData
            Set psContentType                                       to sContentType
        End_Procedure
          
        Procedure Reset
            UChar[] empty
              
            Set pucaData        to empty
            Set psContentType   to ""
            Set peTransferFlags to 0
            Set psAcceptTypes   to "*"
            Send ClearHeaders
        End_Procedure
      
    End_Object
  
    // The MakeCall procedure is what does all the work - everything else is 
    // just set up:
    Procedure MakeCall
        String  sPath sVerb sAuth sToken sUUID
        Address pReq pCreds
        Integer iSize iOK iStatus
        UChar[] ucaReq ucaResp
        Handle  hoReq hoResp
        Boolean bOK bSecure bUUID bOnlyJSON
          
        Send Reset          of oHttp  // Important!
          
        Set Value of oReceivedJSON      to ""  // Make sure to clear out any
        Set Value of oRespStatus        to ""  // old results from these
          
        Set psRemoteHost    of oHttp    to (Value(oHost))
        Set piRemotePort    of oHttp    to (Value(oPort))
  
        Get Value of oAuthType          to sAuth
        Get Value of oPath              to sPath
        Get Value of oVerb              to sVerb
        Get Checked_State of oSecure    to bSecure
        Get Checked_State of oUseUUID   to bUUID
        Get Checked_State of oOnlyJSON  to bOnlyJSON
          
        If bSecure Begin
            Set peTransferFlags of oHttp to ifSecure
        End
          
        // Usually not used
        If bUUID Begin
            Move (RandomHexUUID())                                      to sUUID
            Get AddHeader of oHttp "client-request-id" sUUID            to iOK
            Get AddHeader of oHttp "return-client-request-id" "true"    to iOK
        End
          
        // Usually not used
        If bOnlyJSON Begin
            Set psAcceptTypes of oHttp  to "application/json"
        End
          
        If (sAuth = "Basic") Begin
            Move (Value(oCreds) + ":" + Value(oPassword)) to sToken
            Move (Base64Encode(AddressOf(sToken), Length(sToken))) to pCreds
            Move pCreds to sToken
            Move (Free(pCreds)) to bOK
            Get AddHeader of oHttp "Authorization" ("Basic" * sToken) to bOK
        End
        Else If (sAuth = "Bearer") Begin
            Get Value of oCreds to sToken
            Get AddHeader of oHttp "Authorization" ("Bearer" * sToken) to iOK
        End
          
        // If we are doing a POST, PUT or PATCH, we need to assemble the JSON
        // we are going to send with the request
        If ((sVerb = "GET") or (sVerb = "DELETE")) Begin
            Move 0 to pReq
            Move 0 to iSize
        End
        Else Begin
              
            If (Value(oSendJSON) = "") Begin
                Send Info_Box ("For" * sVerb * "you must enter valid JSON to send") "Error"
                Procedure_Return
            End
              
            Get Create (RefClass(cJsonObject)) to hoReq          // Created
            Get ParseString of hoReq (Value(oSendJSON)) to bOK
              
            If not bOK Begin
                Send Info_Box ("Invalid input JSON:" * psParseError(hoReq)) "Error"
                Send Destroy of hoReq                            // Destroy before
                Procedure_Return                                 // exiting
            End
              
            Get StringifyUtf8 of hoReq  to ucaReq
            Send Destroy of hoReq                                // or Destroy here
              
            Move (AddressOf(ucaReq))    to pReq
            Move (SizeOfArray(ucaReq))  to iSize
            Get AddHeader of oHttp "Content-Type" "application/json" to iOK
        End
          
        Get HttpVerbAddrRequest of oHttp sPath pReq iSize False sVerb to iOK
          
        If iOK Begin
            Get ResponseStatusCode of oHttp to iStatus
            Set Value of oRespStatus to iStatus
            Get pucaData of oHttp to ucaResp
             
            // Do we have some response?
            If (SizeOfArray(ucaResp)) Begin
                Get Create (RefClass(cJsonObject))  to hoResp // Created
                Set peWhiteSpace of hoResp          to jpWhitespace_Pretty
                Set pbEscapeForwardSlash of hoResp  to False
                Get ParseUtf8 of hoResp ucaResp     to bOK
                 
                If bOK ;
                    Set Value of oReceivedJSON      to (Stringify(hoResp))
                Else ;
                    Send Info_Box ("Invalid JSON received," * psParseError(hoResp)) "Error"               
                 
                Send Destroy of hoResp                       // Destroyed
            End
             
            If not ((iStatus >= 200) and (iStatus < 300)) ;
                Send Info_Box ("Http status:" * String(iStatus)) "Error"
        End
        Else Begin
            Send Info_Box "HTTP request failed" "Error"
        End
          
    End_Procedure
      
    // By default the view is set up to call 
    // http://jsonplaceholder.typicode.com/posts on port 80 (insecure), which is
    // a dummy RESTful service offering a range of calls you can make.
    // See: http://jsonplaceholder.typicode.com for the list. Calls to it don't 
    // actually change anything, but will provide realistic responses.
    //
    // It works both with HTTP and HTTPS (secure).
    //
    // Useful for testing only.
    //
    // Change the various values to call the service of your choice.
  
    Object oHost is a Form
        Set Size to 12 293
        Set Location to 4 55
        Set Label to "Host:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 5
        Set peAnchors to anTopLeftRight
        Set Value to "jsonplaceholder.typicode.com"
        Set psToolTip to "The host name or IP address of the server to call"
    End_Object
  
    Object oPort is a Form
        Set Size to 12 22
        Set Location to 18 55
        Set Label to "Port:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 5
        Set Value to "80"
        Set Form_Datatype to 0
        Set psToolTip to "The port to use: usually 80 for insecure, 443 for secure"
    End_Object
  
    // Most "real" services will require a secure (HTTPS) connection
    Object oSecure is a CheckBox
        Set Size to 10 50
        Set Location to 20 104
        Set Label to "Secure"
        Set psToolTip to "Use secure HTTP (HTTPS)"
          
        Procedure OnChange
            Boolean bChecked
          
            Get Checked_State to bChecked
              
            Set Value of oPort to (If(bChecked, rpHttpSSL, rpHttp))
        End_Procedure
      
    End_Object
  
    // Some services may require a request UUID (generally leave it unchecked)
    Object oUseUUID is a CheckBox
        Set Size to 10 50
        Set Location to 20 150
        Set Label to "Use request UUID"
        Set psToolTip to "Add a UUID to the request Headers"
    End_Object
  
    // If the service reqires this, you can check this box to ensure that the
    // the HTTP object will only accep JSON (gererally leave it unchecked)
    Object oOnlyJSON is a CheckBox
        Set Size to 10 50
        Set Location to 20 235
        Set Label to "Only accept JSON"
        Set psToolTip to "Only accept JSON responses"
    End_Object
  
    // The path on the server to call.
    //
    // The default jsonplaceholder service has "posts", "todos", "comments",
    // "albums", "photos" and "users".
    //
    // For the various options, see: http://jsonplaceholder.typicode.com/.
    Object oPath is a Form
        Set Size to 12 293
        Set Location to 33 55
        Set Label to "Path:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 5
        Set peAnchors to anTopLeftRight
        Set Value to "posts"
        Set psToolTip to "The path on the server to call"
    End_Object
  
    Object oVerb is a ComboForm
        Set Size to 12 49
        Set Location to 48 55
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
        Set Combo_Sort_State to False
        Set Allow_Blank_State to False
        Set Value to "GET"
        Set Label to "Verb:"
        Set psToolTip to "The HTTP verb to make the call with"
        
        Procedure Combo_Fill_List
            Send Combo_Add_Item "GET"
            Send Combo_Add_Item "POST"
            Send Combo_Add_Item "PUT"
            Send Combo_Add_Item "PATCH"
            Send Combo_Add_Item "DELETE"
        End_Procedure
        
        Procedure OnChange
            String sValue
          
            Get Value to sValue
            Set Enabled_State of oSendJSON to ((sValue <> "GET") and (sValue <> "DELETE"))
        End_Procedure
        
    End_Object
  
    // This controls what kind of authentication the call will use. That can be
    // "None", "Basic" (username and password) or "Bearer" (a "Bearer" token
    // will be passed in the "Authentication" HTTP header). It dynamically
    // manipulates the oCreds and oPassword objects depending on what type of
    // authentication you are using.
    Object oAuthType is a ComboForm
        Set Size to 12 42
        Set Location to 48 189
        Set Label to "Authentication Type:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
        Set Combo_Sort_State to False
        Set Allow_Blank_State to False
        Set Value to "None"
        Set psToolTip to "The authentication type to use for the call"
        
       Procedure Combo_Fill_List
            Send Combo_Add_Item "None"
            Send Combo_Add_Item "Basic"
            Send Combo_Add_Item "Bearer"
        End_Procedure
        
        Procedure OnChange
            String sValue
          
            Get Value to sValue
              
            If (sValue = "Basic") Begin
                Set Label of oCreds to "User Name:"
                Set Enabled_State of oCreds to True
                Set Visible_State of oCreds to True
                Set Enabled_State of oPassword to True
                Set Visible_State of oPassword to True
                Set psToolTip of oCreds to "The username to make the call with"
            End
            Else If (sValue = "Bearer") Begin
                Set Label of oCreds to "Token:"
                Set Enabled_State of oCreds to True
                Set Visible_State of oCreds to True
                Set Enabled_State of oPassword to False
                Set Visible_State of oPassword to False
                Set psToolTip of oCreds to 'The "bearer token" to make the call with'
            End
            Else Begin
                Set Label of oCreds to "User Name:"
                Set Enabled_State of oCreds to False
                Set Visible_State of oCreds to False
                Set Enabled_State of oPassword to False
                Set Visible_State of oPassword to False
            End
              
        End_Procedure
        
    End_Object
      
    // Used both for username (if using Basic Auth) and the bearer token (if
    // using Bearer Auth).
    Object oCreds is a Form
        Set Size to 12 158
        Set Location to 63 189
        Set Label to "User name:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
        Set Visible_State to False
        Set Enabled_State to False
        Set peAnchors to anTopLeftRight
        Set psToolTip to "The username to make the call with"
    End_Object
  
    // The password if using basic auth.
    Object oPassword is a Form
        Set Size to 12 158
        Set Location to 78 189
        Set Label to "Password:"
        Set Label_Col_Offset to 5
        Set Label_Justification_Mode to JMode_Right
        Set Password_State to True
        Set Visible_State to False
        Set Enabled_State to False
        Set peAnchors to anTopLeftRight
        Set psToolTip to "The password to make the call with"
    End_Object
  
    // You enter the JSON to make your call (POST,PUT and PATCH only) with here.
    Object oSendJSON is a cTextEdit
        Set Size to 106 340
        Set Location to 98 7
        Set Label to "JSON to send:"
        Set peAnchors to anTopLeftRight
        Set Enabled_State to False
        Set psToolTip to "JSON to pass with the call (POST, PUT amd PATCH only)"
    End_Object
  
    // Clicking this is what sends your call.
    Object oSendBtn is a Button
        Set Location to 211 7
        Set Label to 'Send'
        Set psToolTip to "Send the call"
  
        Procedure OnClick
            Send MakeCall
        End_Procedure
      
    End_Object
  
    // The HTTP response status code (if you get a response) will be displayed
    // here.
    Object oRespStatus is a Form
        Set Size to 12 26
        Set Location to 212 320
        Set Label to "Response Status:"
        Set Label_Justification_Mode to JMode_Right
        Set Label_Col_Offset to 5
        Set Form_Datatype to 0
        Set peAnchors to anTopRight
        Set Enabled_State to False
        Set psToolTip to "The HTTP status of the response"
    End_Object
  
    // The JSON response to your call will be displayed here.
    Object oReceivedJSON is a cTextEdit
        Set Size to 128 340
        Set Location to 240 7
        Set Label to "Received JSON:"
        Set peAnchors to anAll
        Set Read_Only_State to True
        Set psToolTip to "The data returned by the call"
    End_Object
  
Cd_End_Object