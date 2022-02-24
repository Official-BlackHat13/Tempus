<%

if request("Request_method")="POST" Then
    iEmployeeIdno = request.Form("enteredid")
    iPIN          = request.Form("pin")
    sCallerId     = request.Form("phone")
    sSuccess      = "5666"
    sFailure      = "5687"
    Response.Write oTransactionEntry.call("get_ValidateEmployee",iEmployeeIdno,iPIN,sCallerId,sSuccess,sFailure)
end if

%>
