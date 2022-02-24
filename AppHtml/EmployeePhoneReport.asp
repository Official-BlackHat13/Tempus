<%

if request("Request_method")="POST" Then
    iEmployeeIdno = request.Form("enteredid")
    sCallerId     = request.Form("phone")
    sSuccess      = "5888"
    sFailure      = "5777"
    Response.Write oTransactionEntry.call("get_CreateEmployeePhoneReport",iEmployeeIdno,sCallerId,sSuccess,sFailure)
end if

%>
