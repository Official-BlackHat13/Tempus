Use Windows.pkg
Use DFClient.pkg
Use Crystal.DD
Use cDbCJGrid.pkg
Use cdbCJGridColumn.pkg

Deferred_View Activate_oReportSelection for ;
Object oReportSelection is a dbView
    Object oCrystal_DD is a Crystal_DataDictionary
    End_Object

    Set Main_DD to oCrystal_DD
    Set Server to oCrystal_DD

    Set Border_Style to Border_Thick
    Set Size to 200 300
    Set Location to 2 2
    Set Label to "ReportSelection"

    Object oDbCJGrid1 is a cDbCJGrid
        Set Size to 176 293
        Set Location to 3 4

        Object oCrystal_Description is a cDbCJGridColumn
            Entry_Item Crystal.Description
            Set piWidth to 232
            Set psCaption to "Description"
        End_Object

        Object oCrystal_FileName is a cDbCJGridColumn
            Entry_Item Crystal.FileName
            Set piWidth to 280
            Set psCaption to "FileName"
        End_Object
    End_Object

Cd_End_Object
