<!-- #include File="VdfAjaxLib/2-3/pagetop.inc.asp" -->

<%
    Dim bUserLoggedIn, sUserId, sLoginName, bValidSession, bIsContact, sContactID
    
    '   Get session & login info
    bUserLoggedIn = True
    sUserId = ""
    sLoginName = ""
    bEditRights = True
	bIsContact = False
	sContactID = ""
    
    bValidSession = (oSessionManager.call("get_FindSessionInfo", sSessionKey) <> 0)
    If (bValidSession) Then
        bUserLoggedIn = (oSessionManager.DDValue("User.UserId") <> "0")
        sUserId = oSessionManager.DDValue("User.UserId")
        sLoginName = oSessionManager.DDValue("User.LoginName")
        If (bUserLoggedIn) Then
            bEditRights = (oSessionManager.DDValue("User.EditRights") = "Y")
		End If
		bIsContact = (oSessionManager.DDValue("User.CustContactId") <> "0")
		sContactID = oSessionManager.DDValue("User.CustContactId")
    Else
        bUserLoggedIn = False
        sUserId = ""
        sLoginName = ""
        bEditRights = False
        bIsContact = False
        sContactID = ""
    End If
        
%>