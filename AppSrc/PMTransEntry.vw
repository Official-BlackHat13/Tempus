Use Windows.pkg
Use DFClient.pkg
Use DFTabDlg.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD
Use cGlblDbForm.pkg
Use cGlblDataDictionary.pkg
Use DFAllEnt.pkg


Activate_View Activate_oPMTransEntry for oPMTransEntry
Object oPMTransEntry is a dbView
    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oProject_DD is a cProjectDataDictionary
        Set DDO_Server to oLocation_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD

    Set Label to "New View"
    Set Size to 262 600
    Set Location to 6 25

    Object oNewTabDialog is a dbTabDialogView
        Set Size to 236 580
        Set Location to 10 17
        Set Rotate_Mode to RM_Rotate

        Object oNewTabPage1 is a dbTabView
            Object oSalesRep_DD is a Salesrep_DataDictionary
            End_Object

            Object oAreas_DD is a Areas_DataDictionary
            End_Object

            Object oCustomer_DD is a Customer_DataDictionary
            End_Object

            Object oLocation_DD is a Location_DataDictionary
                Set DDO_Server to oAreas_DD
                Set DDO_Server to oCustomer_DD
            End_Object

            Object oProject_DD is a cProjectDataDictionary
                Set DDO_Server to oLocation_DD
            End_Object

            Object oOrder_DD is a Order_DataDictionary
                Set DDO_Server to oSalesRep_DD
                Set DDO_Server to oProject_DD
                Set DDO_Server to oLocation_DD
            End_Object

            Set Main_DD to oOrder_DD
            Set Server to oOrder_DD

            Set Label to "Labor Transactions"


        End_Object

        Object oNewTabPage2 is a dbTabView
            Set Label to "Contractor & Material Costs"
        End_Object
        
         Object oNewTabPage3 is a dbTabView
            Set Label to "AI Report"
       End_Object

    End_Object

    Object oDbContainer3d2 is a dbContainer3d
        Set Size to 100 100
        Set Location to 59 -134
    End_Object

End_Object

