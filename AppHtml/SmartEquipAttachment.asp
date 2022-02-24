<%

if request("Request_method")="POST" Then
    iEquipIdno     = request.Form("equip_idno")
    Response.Write oTransactionEntry.call("get_SmartCreateAttachList",iEquipIdno)
end if

%>
