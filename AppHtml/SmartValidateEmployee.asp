<%

if request("Request_method")="POST" Then
    iEmployeeIdno = request.Form("enteredid")
    iPIN          = request.Form("pin")
    sCallerId     = request.Form("phone")
    Response.Write oTransactionEntry.call("get_SmartValidateEmployee",iEmployeeIdno,iPIN,sCallerId)
end if

%>
