// Order_SnowOpenNotCanceled.sl
// Order Lookup List - OrderSnowOpenNotCanceled

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

CD_Popup_Object Order_SnowOpenNotCanceled_sl is a cGlblDbModalPanel
    Set Location to 5 5
    Set Size to 134 548
    Set Label To "Order Lookup List - OrderSnowOpenNotCanceled"
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

    Set Main_DD To oOrder_DD
    Set Server  To oOrder_DD



    Object oSelList is a cDbCJGridPromptList
        Set Size to 105 538
        Set Location to 5 5
        Set peAnchors to anAll
        Set psLayoutSection to "Order_SnowOpenNotCanceled_sl_oSelList"
        Set Ordering to 1
        Set pbAutoServer to True

        Object oOrder_JobNumber is a cDbCJGridColumn
            Entry_Item Order.JobNumber
            Set piWidth to 72
            Set psCaption to "Job Nbr"
        End_Object // oOrder_JobNumber

        Object oCustomer_Name is a cDbCJGridColumn
            Entry_Item Customer.Name
            Set piWidth to 225
            Set psCaption to "Customer Name"
        End_Object // oCustomer_Name

        Object oLocation_Name is a cDbCJGridColumn
            Entry_Item Location.Name
            Set piWidth to 225
            Set psCaption to "Location Name"
        End_Object // oLocation_Name

        Object oOrder_JobOpenDate is a cDbCJGridColumn
            Entry_Item Order.JobOpenDate
            Set piWidth to 90
            Set psCaption to "JobOpenDate"
        End_Object // oOrder_JobOpenDate

        Object oOrder_JobCloseDate is a cDbCJGridColumn
            Entry_Item Order.JobCloseDate
            Set piWidth to 90
            Set psCaption to "JobCloseDate"
        End_Object // oOrder_JobCloseDate

        Object oOrder_PromiseDate is a cDbCJGridColumn
            Entry_Item Order.PromiseDate
            Set piWidth to 90
            Set psCaption to "JobCancelDate"
        End_Object // oOrder_PromiseDate


    End_Object // oSelList

    Object oOk_bn is a cGlblButton
        Set Label to "&Ok"
        Set Location to 115 385
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send OK of oSelList
        End_Procedure

    End_Object // oOk_bn

    Object oCancel_bn is a cGlblButton
        Set Label to "&Cancel"
        Set Location to 115 439
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Cancel of oSelList
        End_Procedure

    End_Object // oCancel_bn

    Object oSearch_bn is a cGlblButton
        Set Label to "&Search..."
        Set Location to 115 493
        Set peAnchors to anBottomRight

        Procedure OnClick
            Send Search of oSelList
        End_Procedure

    End_Object // oSearch_bn

    On_Key Key_Alt+Key_O Send KeyAction of oOk_bn
    On_Key Key_Alt+Key_C Send KeyAction of oCancel_bn
    On_Key Key_Alt+Key_S Send KeyAction of oSearch_bn


CD_End_Object // Order_SnowOpenNotCanceled_sl
