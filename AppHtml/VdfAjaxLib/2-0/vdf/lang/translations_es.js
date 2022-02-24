/*
The spanish translations.

@private
*/
vdf.lang.translations_es = {
    error : {
        131 : "sWebObject / vdfWebObject deben ser configurados",
        132 : "sMainTable / vdfMainTable deben ser configurados",
        133 : "Registro no encontrado",
        134 : "Referencia al objeto form requerida en {{0}}",
        135 : "Ningun idioma ha sido cargado!",
        
    	141 : "Tipo de control desconocido: {{0}}",
        142 : "Biblioteca inválida: {{0}}",
        143 : "El Listener debe ser una función (evento: {{0}})",
        144 : "El nombre del control '{{0}}' ya existe dentro del form '{{1}}'",
        145 : "El control debe tener un nombre",
        146 : "Un control de nombre '{{0}}' ya existe dentro de la página",
        147 : "No fué posible encontrar el método de inicialización '{{0}}'",
        148 : "Control definido para prototype({{0}}) que no se encuentra disponible",
        151 : "Campo no indexado para búsquedas",
        152 : "Campo desconocido",
        153 : "Tabla desconocida {{0}}",
        154 : "Campo desconocido {{0}} en la tabla {{1}}",
        155 : "Data Binding desconocido: {{0}}",
        
        201 : "Linea Edit requerida para la grid",
        202 : "La tabla del encabezado debe ser grabada/ posicionada primeiro",
        211 : "Linea Display requerida para la lista",
        212 : "Linea Header requerida para la lista",
        213 : "Campo desconocido en {{0}} linea",
        214 : "Tipo de linea desconocido: {{0}}",
        215 : "Requisición autofind desconocida: {{0}}",
        216 : "No son permitidas múltiplas listas (grid / lookup) en una única tabla",
        217 : "Tab container sin un botón: {{0}}",
        218 : "Botón tab sin un container: {{0}}",
        
        301 : "El valor debe estar en caja alta",
        302 : "El valor no debe ser alterado",
        303 : "El Campo requiere búsqueda",
        304 : "El valor no es un número válido",
        305 : "El valor no es una fecha válida",
        306 : "Valor requerido (0 no es válido)",
        307 : "El valor no se encaja en la máscara",
        308 : "El valor no satisface a una de las opciones",
        309 : "El valor es mayor que el tamaño máximo permitido",
        310 : "El valor debe ser menor que {{0}}",
        311 : "El valor debe ser mayor que {{0}}",
        312 : "Valor requerido",
        501 : "No fué posible encontrar el nudo de respuesta en XML de respuesta",
        502 : "No fué posible analisar (parse) el XML de respuesta",
        503 : "Ocurrió un error HTTP (Status: {{0}}, Texto: {{1}})",
        504 : "El servidor há devuelto un error soap (Código: {{0}}, Texto: {{1}})",
        title : "Error {{0}}!"
    },
    
    list : {
        search_title : "Búsqueda..",
        search_value : "Búsqueda valor",
        search_column : "Columna",
        search : "Búsqueda",
        cancel : "Cancelar"
    },
    
    lookupdialog : {
        title : "Lista",
        select : "Seleccionar",
        cancel : "Cancelar",
        search : "Búsqueda",
        lookup : "Lookup"
    },
    
    calendar : {
        today : "Hoy es",
        wk : "S",
        daysShort : ["Dom", "Lun", "Mar", "Mie", "Jue", "Vie", "Sab"],
        daysLong : ["Domingo", "Lunes", "Martes", "Miércoles", "Jueves", "Viernes", "Sábado"],
        monthsShort : ["Ene", "Feb", "Mar", "Abr", "May", "Jun", "Jul", "Ago", "Sep", "Oct", "Nov", "Dic"],
        monthsLong : ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubro", "Noviembre", "Diciembre"]
    },
    
    global : {
        ok : "OK",
        cancel : "Cancelar"
    }
};
vdf.register("vdf.lang.translations_es");