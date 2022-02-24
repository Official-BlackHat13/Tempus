<%  
    Option Explicit

    Response.CacheControl = "No-cache"
    
    Dim sSessionKey, iError, bEditRights
    
    '   Find session key and validate session
    iError = 1
    sSessionKey = Request.Cookies("vdfSessionKey")
    
    If (sSessionKey <> Empty and sSessionKey <> "") Then
        iError = oSessionManager.call("get_ValidateSession", sSessionKey)
    End If
    
    '   Create new session if needed
    If (iError > 0) Then
        sSessionKey = oSessionManager.call("get_CreateSession", Request.ServerVariables("REMOTE_ADDR"))
        Response.Cookies("vdfSessionKey") = sSessionKey
    End If



    bEditRights = oSessionManager.call("get_HasRights", sSessionKey, "save", "", "")
    If (Not(bEditRights)) Then
        bEditRights = oSessionManager.call("get_HasRights", sSessionKey, "delete", "", "")
    End If    

%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01//EN" "http://www.w3.org/TR/html4/strict.dtd">