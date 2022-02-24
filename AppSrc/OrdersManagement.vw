Use Windows.pkg
Use DFClient.pkg
Use cCJGroupedGrid.pkg
Use Customer.DD
Use Areas.DD
Use Location.DD
Use cProjectDataDictionary.dd
Use SalesRep.DD
Use Order.DD
Use cDbCJGrid.pkg
Use cCJStandardCommandBarSystem.pkg
Use cCJCommandBarSystem.pkg
Use szcalendar.pkg
Use cCJGridColumn.pkg
Use cCJGridPromptList.pkg

Deferred_View Activate_oOrdersManagement for ;
Object oOrdersManagement is a dbView

    Object oSalesRep_DD is a Salesrep_DataDictionary
    End_Object

    Object oProject_DD is a cProjectDataDictionary
    End_Object

    Object oAreas_DD is a Areas_DataDictionary
    End_Object

    Object oCustomer_DD is a Customer_DataDictionary
    End_Object

    Object oLocation_DD is a Location_DataDictionary
        Set DDO_Server to oAreas_DD
        Set DDO_Server to oCustomer_DD
    End_Object

    Object oOrder_DD is a Order_DataDictionary
        Set DDO_Server to oSalesRep_DD
        Set DDO_Server to oProject_DD
        Set DDO_Server to oLocation_DD
        
//        Procedure OnConstrain
//
//        End_Procedure
    End_Object

    Set Main_DD to oOrder_DD
    Set Server to oOrder_DD

    Set Border_Style to Border_Thick
    Set Size to 355 613
    Set Location to 2 2

    Object oCJGrid1 is a cCJGroupedGrid
        Set Size to 63 598
        Set Location to 289 6

        Object oJobNumberColumn is a cCJGridColumn
            Set piWidth to 223
            Set psCaption to "Job #"
        End_Object
        
        Object oJobOpenedColumn is a cCJGridColumn
            Set piWidth to 223
            Set psCaption to "Job Opened"
            Set phoGroupColumn to Self
        End_Object


        Object oJobTitleColumn is a cCJGridColumn
            Set piWidth to 223
            Set psCaption to "Job Title"
        End_Object

        Object oCustomerNameColumn is a cCJGridColumn
            Set piWidth to 193
            Set psCaption to "Customer Name"
        End_Object

        Object oLocationNameColumn is a cCJGridColumn
            Set piWidth to 184
            Set psCaption to "Location Name"
        End_Object
        
        Procedure LoadData 
            Handle hoDataSource
            tDataSourceRow[] TheData
            Boolean bFound
            Integer iRows iTitle iCust iLoc iJobNo iQuoteIdno iJobOpened
            
            Get phoDataSource to hoDataSource
            
            // Get the datasource indexes of the various columns
            Get piColumnId of oJobNumberColumn          to iJobNo
            Get piColumnId of oJobOpenedColumn          to iJobOpened
            Get piColumnId of oJobTitleColumn           to iTitle
            Get piColumnId of oCustomerNameColumn       to iCust
            Get piColumnId of oLocationNameColumn       to iLoc

            // Load all data into the datasource array
            Clear Order
            
            Constraint_Set 1
            Constrain Order.JobOpenDate gt 0
            Constrain Order.JobCloseDate eq 0
            Constrain Order.PromiseDate eq 0
            Constrain Order.WorkType eq "P"
            Constrained_Find First Order by 1
            While (Found)
                Relate Order
                Move Order.JobNumber                    to TheData[iRows].sValue[iJobNo]
                Move Order.JobOpenDate                  to TheData[iRows].sValue[iJobOpened] 
                Move (Trim(Order.Title))                to TheData[iRows].sValue[iTitle]
                Move (Trim(Customer.Name))              to TheData[iRows].sValue[iCust] 
                Move (Trim(Location.Name))              to TheData[iRows].sValue[iLoc] 
                Constrained_Find Next
                Increment iRows
            Loop
            
            // Initialize Grid with new data
            Send InitializeData TheData
            Send MovetoFirstRow
        End_Procedure
        
        Procedure Activating
            Forward Send Activating
            Send LoadData
        End_Procedure
                
    End_Object

//    Object oSigCJCalendar_Control_v21 is a cSigCJCalendar_Control_v2
//        Set Size to 283 529
//        Set Location to 2 2
//        Set peAnchors to anAll
//        Set pbEnableDB_Link to True
//        Set pbDB_Link_OnClick to False
//        Set pbEnableCustomIcons to True
//        Set pbEnableCustomProperties to True
//    
//        //#Include Calendar_v2\cSigCJCalendar_Standard_Tables.pkg
//    
//        Procedure OnCreate_DataProvider
//            //Do Nothing - we will use the auto created default
//        End_Procedure
//        
//        Procedure OnLoadIcons
//            Send Load_Icon 10 "Con_All_16.ico" 
//            Send Load_Icon 11 "Con_Act_16.ico" 
//            Send Load_Icon 12 "Con_Ter_16.ico" 
//            Send Load_Icon 22 "Gear_16.ico" 
//            Send Load_Icon 23 "Grid_16.ico" 
//            Send Load_Icon 24 "Grids_16.ico" 
//        End_Procedure
//    
//        Procedure OnCreate_Categories
//            tdSigCjCal_Category     tCategory
//            
//            Move 1          to tCategory.iID
//            Move "Holiday"  to tCategory.sName
//            Move clRed      to tCategory.iBorderColor
//            Move clAqua     to tCategory.iColor_1
//            Move clAqua     to tCategory.iColor_2
//            Move 0.75       to tCategory.nGradient
//            Send Create_Category tCategory
//    
//            Move 2                  to tCategory.iID
//            Move "Internal Meeting" to tCategory.sName
//            Move clLime             to tCategory.iBorderColor
//            Move clYellow           to tCategory.iColor_1
//            Move clYellow           to tCategory.iColor_2
//            Move 0.75               to tCategory.nGradient
//            Send Create_Category  tCategory
//    
//            Move 3                to tCategory.iID
//            Move "Client Meeting" to tCategory.sName
//            Move clBlue           to tCategory.iBorderColor
//            Move clGreen          to tCategory.iColor_1
//            Move clGreen          to tCategory.iColor_2
//            Move 0.75             to tCategory.nGradient
//            Send Create_Category  tCategory
//        End_Procedure
//    End_Object
//    
//    
//    
//    

Cd_End_Object
