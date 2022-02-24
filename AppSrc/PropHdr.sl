// PropHdr.sl
// PropHdr Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use cSnowrepDataDictionary.dd
Use cPropHdrGlblDataDictionary.dd
Use cSalesTaxGroupGlblDataDictionary.dd

CD_Popup_Object PropHdr_sl is a cGlblDbModalPanel
    Set Location to 32 23
    Set Size to 134 523
    Set Label To "PropHdr Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False

    Object oSalesTaxGroup_DD is a cSalesTaxGroupGlblDataDictionary
    End_Object


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD is a Areas_DataDictionary
    End_Object // oAreas_DD

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oSalesTaxGroup_DD
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
    End_Object // oLocation_DD

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object // oSalesRep_DD

    Object oSnowrep_DD is a cSnowrepDataDictionary
    End_Object // oSnowrep_DD

    Object oPropHdr_DD is a cPropHdrGlblDataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oSalesRep_DD
        Set DDO_Server To oLocation_DD
    End_Object // oPropHdr_DD

    Set Main_DD To oPropHdr_DD
    Set Server  To oPropHdr_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 513
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "PropHdr_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oSalesRep_LastName is a cDbCJGridColumn
            Entry_Item SalesRep.LastName
            Set piWidth to 93
            Set psCaption to "Sales Rep."
        End_Object

        Object oPropHdr_PropHdr_Idno is a cDbCJGridColumn
            Entry_Item PropHdr.PropHdr_Idno
            Set piWidth to 70
            Set psCaption to "Propsal #"
        End_Object // oPropHdr_PropHdr_Idno

        Object oPropHdr_ICust_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 201
            Set psCaption to "Customer"
        End_Object // oPropHdr_ICust_Name

        Object oPropHdr_IAdjacent_Site is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 201
            Set psCaption to "Adjacent Site Name"
        End_Object // oPropHdr_IAdjacent_Site

        Object oPropHdr_PropSite_Name is a cDbCJGridColumn
            Entry_Item PropHdr.PropSite_Name
            Set piWidth to 204
            Set psCaption to "Proposed Site Name"
        End_Object // oPropHdr_PropSite_Name


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 361
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 414
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 468
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // PropHdr_sl
