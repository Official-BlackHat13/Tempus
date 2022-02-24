<!-- field value debugging for the AJAX Library, include by passing ?debugbuffer=true -->
<style type="text/css">
#debugBuffer{
    position: fixed;
    z-index: 999;
    top: 5%;
    right: 20px;
    width: 350px;
    border: 1px solid #A5BCFF;
    padding: 5px;
    opacity: 0.7;
    alpha(opacity=70);
    background-color: #FFFFFF;
    padding-top: 25px;
}
#debugBuffer.visible{
    bottom: 5%;
}
/* IE7 workarround because overflow:auto doesn't work with top & bottom sizing */
body.vdf-ie7 #debugBuffer.visible{
    height: 80%;
}
#debugToggle{
    background-color: #47A6FF;
    color: #FFFFFF;
    font-weight: bold;
    text-decoration: underline;
    cursor: pointer;
    padding: 3px;
    margin-top: -20px;
}

#bufferwindow{
    height: 100%;
    overflow: auto;
}

.debugTable td{
    border-left: 1px solid #A5BCFF;
    padding: 2px 5px 2px 5px;
}

.debugTable .formHeader {
    font-weight: bold;
    font-size: 14px;
    
    border-left: none;
}

.debugTable .ddHeader {
    font-weight: bold;
    font-size: 12px;
    padding-left: 15px;
    border-left: none;
}

.debugTable .ddFieldName {
    padding-left: 30px;
    border-left: none;
}

.debugTable .userFieldName {
    padding-left: 15px;
    border-left: none;
}
</style>

<script type="text/javascript">
    /*
    After the DOM is initialized we execute the method containing the debugbuffer functionality. By 
    wrapping it in a single method it has no footprint so no conflicts will occur. It generates its 
    own HTML and when activated it will set a timeout that shows the buffer values per form.
    */
    vdf.sys.dom.ready(function(){
        var eMainDiv, eContentDiv, bDebugEnabled = false;
        
        //  Create elements
        eMainDiv = document.createElement("div");
        eMainDiv.id = "debugBuffer";
        eMainDiv.innerHTML = '<div id="debugToggle">Show</div><div id="bufferwindow" style="display: none;">asdas</div>';
        document.body.appendChild(eMainDiv);
        
        eContentDiv = document.getElementById('bufferwindow');
        
        //  Update the displayed table
        function displayBufferValues(){
            var eTable, eDiv, sName, oForm, eRow, eCell, sDD, oDD, sField, iDeo;
            eTable = document.createElement("table");
            eTable.className = "debugTable";
            eTable.cellPadding = 0;
            eTable.cellSpacing = 0;
            
            //  Loop through VDF controls search for form objects
            for(sName in vdf.oControls){
                if(typeof(vdf.oControls[sName]) === "object" && vdf.oControls[sName].bIsForm){
                    oForm = vdf.oControls[sName];
                    
                    //  Generate form header
                    eRow = eTable.insertRow(eTable.rows.length);
                    eCell = eRow.insertCell(0);
                    vdf.sys.dom.setElementText(eCell, oForm.sName);
                    eCell.className = "formHeader";
                    eCell.colSpan = 3;
                    
                    
                    for(sField in oForm.oUserDataFields){
                        if(oForm.oUserDataFields.hasOwnProperty(sField)){
                            displayUserDataField(eTable, oForm.oUserDataFields[sField]);
                        }
                        
                    }
                    
                    if(vdf.sys.ref.getType(oForm) === "FormBase" || vdf.sys.ref.getType(oForm) === "FormMeta"){
                        for(iDeo = 0; iDeo < oForm.aDEOs.length; iDeo++){
                            displayUserDataField(eTable, oForm.aDEOs[iDeo]);
                        }
                    }else{
                    
                        //  Loop through DDs
                        for(sDD in oForm.oDDs){
                            if(typeof(oForm.oDDs[sDD]) === "object" && oForm.oDDs[sDD].bIsDD){
                                oDD = oForm.oDDs[sDD];
                                
                                //  Generate DD header
                                eRow = eTable.insertRow(eTable.rows.length);
                                eCell = eRow.insertCell(0);
                                eCell.colSpan = 3;
                                vdf.sys.dom.setElementText(eCell, oDD.sName);
                                eCell.className = "ddHeader";
                                
                                //  Loop through fields
                                displayBufferField(eTable, oDD.tStatus, oDD);
                                for(sField in oDD.oBuffer){
                                    if(typeof(oDD.oBuffer[sField]) === "object" && oDD.oBuffer[sField].__isField){
                                        displayBufferField(eTable, oDD.oBuffer[sField], oDD);
                                    }
                                }
                            }
                        }
                    }
                }
            }
            eContentDiv.innerHTML = "";
            eContentDiv.appendChild(eTable);
            
            //  Set timeout for the next update
            if(bDebugEnabled){
                setTimeout(displayBufferValues, 1500);
            }
        }
        
        //  Generate single row
        function displayBufferField(eTable, tField, oDD){
            var eRow, eCell, bDisplayChanged = false, iDeo;
            
            
            //  Determine display changed
            for(iDeo = 0; iDeo < oDD.aDEO.length; iDeo++){
                if(oDD.aDEO[iDeo].sDataBindingType === "D"){
                    if(oDD.aDEO[iDeo].sDataBinding === tField.sBinding){
                        bDisplayChanged = oDD.aDEO[iDeo].isChanged() || bDisplayChanged;
                    }
                }
            }
            
            eRow = eTable.insertRow(eTable.rows.length);
            eCell = eRow.insertCell(0);
            
            vdf.sys.dom.setElementText(eCell, (tField.sBinding.indexOf(".") > 0 ? tField.sBinding.substr(tField.sBinding.indexOf(".") + 1) : tField.sBinding));
            eCell.className = "ddFieldName";
            
            eCell = eRow.insertCell(1);
            vdf.sys.dom.setElementText(eCell, (tField.bChanged ? "true" : "false"));
            
            eCell = eRow.insertCell(2);
            vdf.sys.dom.setElementText(eCell, (bDisplayChanged ? "true" : "false"));
            
            eCell = eRow.insertCell(3);
            vdf.sys.dom.setElementText(eCell, tField.sValue);
        }
        
        //  Generat row for user data field
        function displayUserDataField(eTable, oField){
            var eRow, eCell;
        
            eRow = eTable.insertRow(eTable.rows.length);
            eCell = eRow.insertCell(0);
            
            vdf.sys.dom.setElementText(eCell, oField.sDataBinding);
            eCell.className = "userFieldName";
            
            eCell = eRow.insertCell(1);
            vdf.sys.dom.setElementText(eCell, " ");
            
            eCell = eRow.insertCell(2);
            vdf.sys.dom.setElementText(eCell, oField.isChanged());
            
            eCell = eRow.insertCell(3);
            vdf.sys.dom.setElementText(eCell, oField.getValue());
        }
        
        //  Toggle on or of
        function toggleDebugWindow(){
            if(bDebugEnabled){
                eMainDiv.className = "";
                eContentDiv.style.display = "none";
                bDebugEnabled = false;
                vdf.sys.dom.setElementText(document.getElementById("debugToggle"), "Show");
            }else{
                eMainDiv.className = "visible";
                eContentDiv.style.display = "";
                bDebugEnabled = true;
                vdf.sys.dom.setElementText(document.getElementById("debugToggle"), "Hide");
                displayBufferValues();
            }
        }
        
        vdf.events.addDomListener("click", document.getElementById('debugToggle'), toggleDebugWindow);
    });




    
</script>


