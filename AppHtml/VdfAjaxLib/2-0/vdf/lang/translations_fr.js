/*
The french translations.

@private
*/
vdf.lang.translations_fr = {
    error : {
        131 : "sWebObject / le vdfWebObject doit être paramétré",
        132 : "sMainTable / la vdfMainTable doit être paramétrée",
        133 : "Aucun enregistrement trouvé",
        134 : "Référence à un objet de type form requise dans {{0}}",
        135 : "Aucun langage indiqué!",
        
        141 : "Type de contrôle inconnu : {{0}}",
        142 : "Librairie non valide : {{0}}",
        143 : "L'auditeur devrait être une fonction (évènement : {{0}})",
        144 : "Ce nom de contrôle '{{0}}' existe déjà dans cette forme '{{1}}'",
        145 : "Un contrôle devrait avoir un nom",
        146 : "Un contrôle portant ce nom '{{0}}' existe déjà dans cette page",
        147 : "Méthode d'initialisation non trouvée'{{0}}'",
        151 : "Champ non indexé",
        152 : "Champ inconnu",
        153 : "Table inconnue {{0}}",
        154 : "Champ inconnu {{0}} dans la table {{1}}",
        155 : "Liaison de données inconnue : {{0}}",
        
        201 : "L'édition des lignes est requise dans une grille",
        202 : "L'enregistrement de la table d'entète doit être préalablement sauvé ou trouvé",
        211 : "L'affichage des lignes est requis pour les listes",
        212 : "La ligne d'entète est requise pour les listes",
        213 : "Champ inconnu dans la ligne {{0}}",
        214 : "Type de ligne inconnu : {{0}}",
        215 : "Recherche automatique inconnue : {{0}}",
        216 : "Les listes multiples (grid / lookup) sur une simple table ne sont pas autorisées",
        217 : "Conteneur de tabulation sans bouton : {{0}}",
        218 : "Bouton de tabulation sans conteneur : {{0}}",
        
        301 : "La valeur doit être entrée en majuscules",
        302 : "La valeur ne peut pas être modifiée",
        303 : "Le champ requiert une recherche",
        304 : "La valeur n'est pas un nombre valide",
        305 : "La valeur n'est pas une date valide",
        306 : "Une valeur est requise (0 n'est pas valide)",
        307 : "La valeur ne respecte pas le masque de saisie",
        308 : "La valeur ne correspond pas à l'une des options",
        309 : "La valeur est plus longue que le maximum autorisé",
        310 : "La valeur doit être inférieure à {{0}}",
        311 : "La valeur doit être supérieure à {{0}}",
        312 : "La valeur est requise",
        501 : "Il n'y a pas de noeud de réponse correspondante dans la réponse XML",
        502 : "On ne peut parcourir la réponse XML",
        503 : "Erreur HTTP survenue (Statut : {{0}}, Texte : {{1}})",
        504 : "Le serveur retourne une erreur soap (Code : {{0}}, Texte: {{1}})",
        title : "Erreur {{0}} survenue!"
    },
    
    list : {
        search_title : "Rechercher..",
        search_value : "Rechercher la valeur",
        search_column : "Colonne",
        search : "Recherche",
        cancel : "Abandon"
    },
    
    lookupdialog : {
        title : " Dialogue lookup",
        select : "Sélectionner",
        cancel : "Abandon",
        search : "Recherche",
        lookup : "Lookup"
    },
    
    calendar : {
        today : "Nous sommes le",
        wk : "Sem",
        daysShort : ["Dim", "Lun", "Mar", "Mer", "Jeu", "Ven", "Sam"],
        daysLong : ["Dimanche", "Lundi", "Mardi", "Mercredi", "Jeudi", "Vendredi", "Samedi"],
        monthsShort : ["Jan", "Fév", "Mar", "Avr", "Mai", "Jun", "Jul", "Aoû", "Sep", "Oct", "Nov", "Dec"],
        monthsLong : ["Janvier", "Février", "Mars", "Avril", "Mai", "Juin", "Juillet", "Août", "Septembre", "Octobre", "Novembre", "Décembre"]
    },
    
    global : {
        ok : "OK",
        cancel : "Abandon"
    }
};
vdf.register("vdf.lang.translations_fr");
