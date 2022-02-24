/*
The dutch translations.

@private
*/
vdf.lang.translations_nl = {
    error : {
        131 : "sWebObject / vdfWebObject is verplicht",
        132 : "sMainTable / vdfMainTable is verplicht",
        133 : "Geen record gevonden",
        134 : "Verwijzing naar het Form object verplicht in {{0}}",
        135 : "Geen taal geladen!",
        
    	141 : "Onbekent control type: {{0}}",
        142 : "Onbekende library: {{0}}",
        143 : "Event listener moet een functie zijn (event: {{0}})",
        144 : "Control naam '{{0}}' bestaat al binnen het form '{{1}}'",
        145 : "Control moet een naam hebben",
        146 : "Control met de naam '{{0}}' bestaat al binnen de pagina",
        147 : "Intializatie methode niet gevonden '{{0}}'",
        151 : "Field bevat geen index",
        152 : "Onbekend veld",
        153 : "Onbekende tabel {{0}}",
        154 : "Onbekend veld {{0}} binnen tabel {{1}}",
        155 : "Onbekende data binding: {{0}}",
        
        201 : "Edit rij verplicht binnen grid",
        202 : "Header record moet eerst opgeslagen / gevonden worden",
        211 : "Display row verplicht binnen list",
        212 : "Header row verplicht binnen list",
        213 : "Onbekend veld in {{0}} rij",
        214 : "Onbekend rowtype: {{0}}",
        215 : "Onbekend autofind request: {{0}}",
        216 : "Meerdere lists (grid / lookup) op dezelfde tabel zijn niet toegestaan",
        217 : "Tab container zonder knop: {{0}}",
        218 : "Tab knop zonder container: {{0}}",
        
        301 : "Waarde moet in hoofdletters zijn",
        302 : "Waarde mag niet aangepast worden",
        303 : "Veld vereist een gevonden record",
        304 : "Waarde is geen correcte getal",
        305 : "Waarde is geen correcte datum",
        306 : "Waarde is verplicht (0 is leeg)",
        307 : "Waarde voldoet niet aan de mask",
        308 : "Waarde match niet met een van de opties",
        309 : "Waarde is langer dan de maximum toegestane lengte",
        310 : "Waarde moet lager zijn dan {{0}}",
        311 : "Waarde moet hoger zijn dan {{0}}",
        312 : "Waarde is verplicht",
        501 : "Kon geen response node vinden in de ontvangen XML",
        502 : "Kon de ontvangen XML niet parsen",
        503 : "HTTP error ontvangen (Status: {{0}}, Tekst: {{1}})",
        504 : "Soap error ontvangen (Code: {{0}}, Tekst: {{1}})",
        title : "Error {{0}}!"
    },
    
    list : {
        search_title : "Zoeken..",
        search_value : "Zoek waarde",
        search_column : "Kolom",
        search : "Zoeken",
        cancel : "Annuleren"
    },
    
    lookupdialog : {
        title : "Lookup dialoog",
        select : "Selecteren",
        cancel : "Annuleren",
        search : "Zoeken",
        lookup : "Lookup"
    },
    
    calendar : {
        today : "Vandaag is",
        wk : "Wk",
        daysShort : ["Zo", "Ma", "Di", "Wo", "Do", "Vr", "Za"],
        daysLong : ["Zondag", "Maandag", "Dinsdag", "Woensdag", "Donderdag", "Vrijdag", "Zaterdag"],
        monthsShort : ["Jan", "Feb", "Maa", "Apr", "Mei", "Jun", "Jul", "Aug", "Sep", "Okt", "Nov", "Dec"],
        monthsLong : ["Januari", "Februari", "Maart", "April", "Mei", "Juni", "Juli", "Augustus", "September", "Oktober", "November", "December"]
    },
    
    global : {
        ok : "OK",
        cancel : "Annuleren"
    }
};
vdf.register("vdf.lang.translations_nl");