// Quota.sl
// Quota Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use SalesRep.DD
Use cQuotaGlblDataDictionary.dd

CD_Popup_Object Quota_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 182
    Set Label To "Quota Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object // oSalesRep_DD

    Object oQuota_DD is a cQuotaGlblDataDictionary
        Set DDO_Server To oSalesRep_DD
    End_Object // oQuota_DD

    Set Main_DD To oQuota_DD
    Set Server  To oQuota_DD


//
//    Object oSelList is a cDbCJGridPromptList
//        Set Size to 105 172
//        Set Location to 5 5
//        Set peAnchors to anAll
//        Set psLayoutSection to "Quota_sl_oSelList"
//        Set Ordering to 1
//        Set pbAutoServer to True
//
//        Object oQuota_Quota_Idno is a cDbCJGridColumn
//            Entry_Item Quota.Quota_Idno
//            Set piWidth to 72
//            Set psCaption to "Quota Idno"
//        End_Object // oQuota_Quota_Idno
//
//        Object oQuota_SalesYear is a cDbCJGridColumn
//            Entry_Item Quota.SalesYear
//            Set piWidth to 90
//            Set psCaption to "SalesYear"
//        End_Object // oQuota_SalesYear
//
//        Object oSalesRep_RepIdno is a cDbCJGridColumn
//            Entry_Item SalesRep.RepIdno
//            Set piWidth to 81
//            Set psCaption to "SalesRepIdno"
//        End_Object // oSalesRep_RepIdno
//
//
//    End_Object // oSelList
//
//    Object oOk_bn is a cGlblButton
//        Set Label to "&Ok"
//        Set Location to 115 19
//        Set peAnchors to anBottomRight
//
//        Procedure OnClick
//            Send OK of oSelList
//        End_Procedure
//
//    End_Object // oOk_bn
//
//    Object oCancel_bn is a cGlblButton
//        Set Label to "&Cancel"
//        Set Location to 115 73
//        Set peAnchors to anBottomRight
//
//        Procedure OnClick
//            Send Cancel of oSelList
//        End_Procedure
//
//    End_Object // oCancel_bn
//
//    Object oSearch_bn is a cGlblButton
//        Set Label to "&Search..."
//        Set Location to 115 127
//        Set peAnchors to anBottomRight
//
//        Procedure OnClick
//            Send Search of oSelList
//        End_Procedure
//
//    End_Object // oSearch_bn
//
//    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
//    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
//    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn
//

CD_End_Object // Quota_sl
