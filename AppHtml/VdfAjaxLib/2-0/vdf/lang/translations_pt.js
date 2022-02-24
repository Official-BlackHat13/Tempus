/*
The portuguese translations.

@private
*/
vdf.lang.translations_pt = {
    error : {
        131 : "sWebObject / vdfWebObject devem ser configurados",
        132 : "sMainTable / vdfMainTable devem ser configurados",
        133 : "Registro não encontrado",
        134 : "Referência ao objeto form requerida em {{0}}",
        135 : "Nenhum idioma carregado!",
        
    	141 : "Tipo de controle desconhecido: {{0}}",
        142 : "Biblioteca inválida: {{0}}",
        143 : "O Listener deve ser uma função (evento: {{0}})",
        144 : "O nome de controle '{{0}}' já existe dentro do form '{{1}}'",
        145 : "O controle deve ter um nome",
        146 : "Um controle de nome '{{0}}' já existe dentro da página",
        147 : "Não foi possível encontrar o método de inicialização '{{0}}'",
        148 : "Controle definido para prototype({{0}}) que não está disponível",
        151 : "Campo não indexado para pesquisas",
        152 : "Campo desconhecido",
        153 : "Tabela desconhecida {{0}}",
        154 : "Campo desconhecido {{0}} na tabela {{1}}",
        155 : "Data Binding desconhecido: {{0}}",
        
        201 : "Linha Edit requerida para a grid",
        202 : "A tabela de cabeçalho deve ser salva / posicionada primeiro",
        211 : "Linha Display requerida para a lista",
        212 : "Linha Header requerida para a lista",
        213 : "Campo desconhecido na {{0}} linha",
        214 : "Tipo de linha desconhecido: {{0}}",
        215 : "Requisição autofind desconhecida: {{0}}",
        216 : "Não são permitidas múltiplas listas (grid / lookup) em uma única tabela",
        217 : "Tab container sem um botão: {{0}}",
        218 : "Botão tab sem um container: {{0}}",
        
        301 : "O valor deve estar em caixa alta",
        302 : "O valor não deve ser alterado",
        303 : "O Campo requer pesquisa",
        304 : "O valor não é um número válido",
        305 : "O valor não é uma data válida",
        306 : "Valor requerido (0 não é válido)",
        307 : "O valor não se encaixa à máscara",
        308 : "O valor não satisfaz uma das opções",
        309 : "O valor é maior que o tamanho máximo permitido",
        310 : "O valor deve ser menor que {{0}}",
        311 : "O valor deve ser maior que {{0}}",
        312 : "Valor requerido",
        501 : "Não foi possível encontrar o nó de resposta no XML de resposta",
        502 : "Não foi possível analisar (parse) o XML de resposta",
        503 : "Ocorreu um erro HTTP (Status: {{0}}, Texto: {{1}})",
        504 : "O servidor retornou um erro soap (Código: {{0}}, Texto: {{1}})",
        title : "Erro {{0}}!"
    },
    
    list : {
        search_title : "Pesquisar..",
        search_value : "Pesquisa valor",
        search_column : "Coluna",
        search : "Pesquisar",
        cancel : "Cancelar"
    },
    
    lookupdialog : {
        title : "Listagem",
        select : "Selecionar",
        cancel : "Cancelar",
        search : "Pesquisar",
        lookup : "Lookup"
    },
    
    calendar : {
        today : "Hoje é",
        wk : "S",
        daysShort : ["Dom", "Seg", "Ter", "Qua", "Qui", "Sex", "Sab"],
        daysLong : ["Domingo", "Segunda", "Terça", "Quarta", "Quinta", "Sexta", "Sábado"],
        monthsShort : ["Jan", "Fev", "Mar", "Abr", "Mai", "Jun", "Jul", "Ago", "Set", "Out", "Nov", "Dez"],
        monthsLong : ["Janeiro", "Fevereiro", "Março", "Abril", "Maio", "Junho", "Julho", "Agosto", "Setembro", "Outubro", "Novembro", "Dezembro"]
    },
    
    global : {
        ok : "OK",
        cancel : "Cancelar"
    }
};
vdf.register("vdf.lang.translations_pt");