// CO_Head.sl
// CO_Head Lookup List

Use cGlblDbModalPanel.pkg
Use cDbCJGridPromptList.pkg
Use cDbCJGridColumn.pkg
Use cGlblButton.pkg

Use Customer.DD
Use Areas.DD
Use Location.DD
Use SalesRep.DD
Use cProjectDataDictionary.dd
Use Order.DD
Use cCO_HeadGlblDataDictionary.dd

CD_Popup_Object CO_Head_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 417
    Set Label To "CO_Head Lookup List"
    Set Border_Style to Border_Thick
    Set Minimize_Icon to False


    Object oCustomer_DD is a Customer_DataDictionary
    End_Object // oCustomer_DD

    Object oAreas_DD is a Areas_DataDictionary
    End_Object // oAreas_DD

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server To oCustomer_DD
        Set DDO_Server To oAreas_DD
    End_Object // oLocation_DD

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object // oSalesRep_DD

    Object oProject_DD is a cProjectDataDictionary
    End_Object // oProject_DD

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server To oLocation_DD
        Set DDO_Server To oProject_DD
        Set DDO_Server To oSalesRep_DD
    End_Object // oOrder_DD

    Object oCO_Head_DD is a cCO_HeadGlblDataDictionary
        Set DDO_Server To oOrder_DD
    End_Object // oCO_Head_DD

    Set Main_DD To oCO_Head_DD
    Set Server  To oCO_Head_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 407
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "CO_Head_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oCO_Head_CO_Head_ID is a cDbCJGridColumn
            Entry_Item CO_Head.CO_Head_ID
            Set piWidth to 73
            Set psCaption to "Change ID"
        End_Object // oCO_Head_CO_Head_ID

        Object oOrder_JobNumber is a cDbCJGridColumn
            Entry_Item Order.JobNumber
            Set piWidth to 72
            Set psCaption to "Job Number"
        End_Object // oOrder_JobNumber

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 225
            Set psCaption to "Customer"
        End_Object // oCustomer_Name

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 225
            Set psCaption to "Location"
        End_Object // oLocation_Name


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 254
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 308
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 362
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // CO_Head_sl
