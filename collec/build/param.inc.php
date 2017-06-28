<?php
/** Fichier cree le 4 mai 07 par quinton
 * Renommez le fichier en param.inc.php
 * ajustez les parametres a votre implementation
 * conservez une sauvegarde de ces parametres pour ne pas les perdre 
 * lors de la mise en place d'une nouvelle version
 * tous les parametres presents dans param.default.inc.php peuvent etre utilises
 */
 /*
  * Affichage des erreurs et des messages
  */
$APPLI_modeDeveloppement = false;
$_ERROR_display = 0;
$ERROR_level = E_ERROR ;
$OBJETBDD_debugmode = 1;

/*
 * code de l'application dans la gestion des droits
 */
$GACL_aco = "zaalpes";
/*
 * Code de l'application - impression sur les etiquettes
 */
$APPLI_code = 'zaalpes';
/*
 * Mode d'identification
 * BDD : uniquement a partir des comptes internes
 * LDAP : uniquement a partir des comptes de l'annuaires LDAP
 * LDAP-BDD : essai avec le compte LDAP, sinon avec le compte interne
 * CAS : identification auprès d'un serveur CAS
 */
$ident_type = "BDD";
 /*
  * Adresse du serveur CAS
  */
// $CAS_address = "http://localhost/CAS";
/*
 * Parametres concernant la base de donnees
 */
$BDD_login = "collec";
$BDD_passwd = "collec";
$BDD_dsn = "pgsql:host=postgiscollec;dbname=collec;sslmode=require";
$BDD_schema = "zaalpes,gacl,public";

/*
 * Rights management, logins and logs records database
 */
$GACL_dblogin = "collec";
$GACL_dbpasswd = "collec";
$GACL_aco = "zaalpes";
$GACL_dsn = "pgsql:host=postgiscollec;dbname=collec;sslmode=require";
$GACL_schema = "gacl";

/*
 * Lien vers le site d'assistance
 */
$APPLI_mail = "https://site.assistance.com";
/*
 * Configuration LDAP
 */
$LDAP ["address" ] = "localhost";
/*
 * pour une identification en LDAPS :
 * port = 636
 * tls = true;
 */
$LDAP ["port" ] = 389;
$LDAP [ "tls"] = false;
/*
 * chemin d'accès a l'identification
 */
$LDAP [ "basedn"] = "ou=people,ou=example,o=societe,c=fr";
$LDAP [ "user_attrib" ] = "uid";

/*
 * Recherche des groupes dans l'annuaire LDAP
 * Decommenter la premiere ligne pour activer la fonction
 */
 //$LDAP [ "groupSupport" ] = true;
$LDAP [ "groupAttrib" ] = "supannentiteaffectation";
$LDAP [ "commonNameAttrib" ] = "displayname";
$LDAP [ "mailAttrib" ] = "mail";
$LDAP [ 'attributgroupname' ] = "cn";
$LDAP [ 'attributloginname' ] = "memberuid";
$LDAP [ 'basedngroup' ] = 'ou=group,ou=example,o=societe,c=fr';

/*
 * Chemin d'acces au fichier param.ini
 * Consultez la documentation pour plus d'informations
 */
$paramIniFile = "./param.ini";
/*
 * Traitement de param.ini dans un contexte multi-bases (cf. documentation)
 */
//$chemin = substr($_SERVER["DOCUMENT_ROOT"],0, strpos($_SERVER["DOCUMENT_ROOT"],"/bin"));
//$paramIniFile = "$chemin/param.ini";
/*
 * Parametres SMARTY complementaires, charges systematiquement
 * Ne pas modifier !
 */
$SMARTY_variables["melappli"] = $APPLI_mail;
$SMARTY_variables["ident_type"] = $ident_type;
/*
        *  * Affichage par defaut des cartes Openstreetmap
        *   */
$mapDefaultX = -1.56;
$mapDefaultY = 46.10;
$mapDefaultZoom = 7;
/*
        *  * Variables de base de l'application
        *   */
$APPLI_mail = "geopoppy@geopoppy.com";
$APPLI_nom = "Prototype d'application";
//$APPLI_code = 'collec-develop';
$APPLI_fds = "display/CSS/blue.css";
$APPLI_address = "http://172.24.1.1/collec-develop";
$APPLI_modeDeveloppement = false;
$APPLI_modeDeveloppementDroit = false;
$APPLI_utf8 = true;
$APPLI_menufile = "param/menu.xml";
$APPLI_temp = "temp";
$APPLI_titre = "Gestion des échantillons ZA Alpes";
?>
