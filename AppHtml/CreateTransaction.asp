<%

if request("Request_method")="POST" Then
    iIdno     = request.Form("p_t")
    iType     = request.Form("transtype")
    sLoc1     = request.Form("locid1")
    sEquipId  = request.Form("equipmentid")
    sLoc2     = request.Form("locid2")
    sMatId    = request.Form("materialid")
    sQty      = request.Form("materialqty")
    sCallerId = request.Form("phone")
	sGPS_Lat  = request.Form("gps_lat")
	sGPS_Long = request.Form("gps_long")
    sSuccess  = "5688"
    sFailure  = "5689"
    Response.Write oTransactionEntry.call("get_CreateTransaction",iIdno,iType,sLoc1,sEquipId,sLoc2,sMatId,sQty,sCallerId,sGPS_Lat,sGPS_Long,sSuccess,sFailure)
end if

%>
