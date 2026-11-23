#Include "TOTVS.ch"
#Include "TOPCONN.ch"
#Include "REPORT.ch"

/*/{Protheus.doc} MLREJ01
Relatorio de rejeicoes: movimentos internos (SD3) com motivo de rejeicao (D3_XMOTREJ), filtrados pela data de emissao.
@type     User Function
@author   FixSystem
@since    18/11/2026
@version  1.0
@obs      INC1833293. Os movimentos de rejeicao da serra e do sucateamento de embalagem nao tem OP,
          por isso a SC2 entra com LEFT JOIN (o poco fica em branco nesses casos).
/*/
User Function MLREJ01()
	Local aPergs  := {}
	Local aRet    := {}
	Local oReport := Nil

	aAdd(aPergs, {1, "Emissao de" , FirstDate(dDataBase), "", "", "", "", 50, .T.})
	aAdd(aPergs, {1, "Emissao ate", dDataBase           , "", "MV_PAR02 >= MV_PAR01", "", "", 50, .T.})

	If !ParamBox(aPergs, "Relatorio de rejeicoes", @aRet, , , , , , , , .F.)
		Return
	EndIf

	oReport := ReportDef(aRet[1], aRet[2])
	oReport:PrintDialog()
Return

/*/{Protheus.doc} ReportDef
Monta a estrutura do relatorio de rejeicoes.
@type     Static Function
@author   FixSystem
@since    18/11/2026
@version  1.0
@param    dDataDe, Date, emissao inicial
@param    dDataAte, Date, emissao final
@return   Object, objeto TReport
/*/
Static Function ReportDef(dDataDe, dDataAte)
	Local oReport  := Nil
	Local oSection := Nil
	Local cTitulo  := "Relatorio de rejeicoes - " + DToC(dDataDe) + " a " + DToC(dDataAte)

	oReport := TReport():New("MLREJ01", cTitulo, , {|oRep| PrintReport(oRep, dDataDe, dDataAte)}, ;
		"Lista os movimentos internos com motivo de rejeicao no periodo informado.")
	oReport:SetLandscape()
	oReport:SetTotalInLine(.F.)

	oSection := TRSection():New(oReport, "Rejeicoes", {"SD3"})

	TRCell():New(oSection, "FILIAL"     , , "Filial"       , "@!"                         , TamSX3("D3_FILIAL")[1])
	TRCell():New(oSection, "DT_REJEICAO", , "Dt. Rejeicao" , ""                           , 10)
	TRCell():New(oSection, "FUSAO"      , , "Fusao"        , "@!"                         , TamSX3("D3_LOTECTL")[1])
	TRCell():New(oSection, "SKU"        , , "SKU"          , "@!"                         , TamSX3("D3_COD")[1])
	TRCell():New(oSection, "LIGA"       , , "Liga"         , "@!"                         , 10)
	TRCell():New(oSection, "VARIANTE"   , , "Variante"     , "@!"                         , 8)
	TRCell():New(oSection, "BITOLA"     , , "Bitola"       , "@!"                         , 8)
	TRCell():New(oSection, "PECAS"      , , "Pecas"        , PesqPict("SD3", "D3_QTSEGUM"), TamSX3("D3_QTSEGUM")[1])
	TRCell():New(oSection, "QTDE_TN"    , , "Qtde"         , PesqPict("SD3", "D3_QUANT")  , TamSX3("D3_QUANT")[1])
	TRCell():New(oSection, "DEFEITO"    , , "Defeito"      , "@!"                         , 30)
	TRCell():New(oSection, "SETOR"      , , "Setor"        , "@!"                         , 24)
	TRCell():New(oSection, "USUARIO"    , , "Usuario"      , "@!"                         , 40)
	TRCell():New(oSection, "POCO"       , , "Poco"         , "@!"                         , 10)
	TRCell():New(oSection, "TURNO"      , , "Turno"        , "@!"                         , 8)

	TRFunction():New(oSection:Cell("PECAS")  , , "SUM", , , , , .F., .T.)
	TRFunction():New(oSection:Cell("QTDE_TN"), , "SUM", , , , , .F., .T.)
Return oReport

/*/{Protheus.doc} PrintReport
Executa a consulta e imprime as linhas do relatorio de rejeicoes.
@type     Static Function
@author   FixSystem
@since    18/11/2026
@version  1.0
@param    oReport, Object, objeto TReport
@param    dDataDe, Date, emissao inicial
@param    dDataAte, Date, emissao final
/*/
Static Function PrintReport(oReport, dDataDe, dDataAte)
	Local oSection  := oReport:Section(1)
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local nTotal    := 0
	Local aUsuarios := {} // cache login -> nome completo

	cQuery := "SELECT DISTINCT SD3.D3_FILIAL  AS FILIAL, "
	cQuery += "       SD3.D3_EMISSAO AS DT_REJEICAO, "
	cQuery += "       SD3.D3_LOTECTL AS FUSAO, "
	cQuery += "       SD3.D3_COD     AS SKU, "
	cQuery += "       SB1.B1_XGRLIGA AS LIGA, "
	cQuery += "       SB1.B1_XVARIAN AS VARIANTE, "
	cQuery += "       SB1.B1_XBITOLA AS BITOLA, "
	cQuery += "       SD3.D3_QTSEGUM AS PECAS, "
	cQuery += "       SD3.D3_QUANT   AS QTDE_TN, "
	cQuery += "       SX5.X5_DESCRI  AS DEFEITO, "
	cQuery += "       CASE "
	cQuery += "           WHEN SD3.D3_LOCAL = '49' THEN 'EMBALAGEM' "
	cQuery += "           WHEN SD3.D3_LOCAL = '22' THEN 'SERRA' "
	cQuery += "           WHEN SD3.D3_LOCAL = '24' THEN 'FUNDICAO' "
	cQuery += "           ELSE 'NAO IDENTIFICADO (' + RTRIM(SD3.D3_LOCAL) + ')' "
	cQuery += "       END AS SETOR, "
	cQuery += "       SD3.D3_USUARIO AS USUARIO, "
	cQuery += "       ISNULL(SC2.C2_XPOCO, '') AS POCO "
	cQuery += "  FROM " + RetSqlName("SD3") + " SD3 "
	cQuery += " INNER JOIN " + RetSqlName("SX5") + " SX5 "
	cQuery += "    ON SX5.X5_TABELA  = 'Z2' "
	cQuery += "   AND SX5.X5_CHAVE   = SD3.D3_XMOTREJ "
	cQuery += "   AND SX5.D_E_L_E_T_ <> '*' "
	cQuery += "  LEFT JOIN " + RetSqlName("SC2") + " SC2 "
	cQuery += "    ON SC2.C2_FILIAL  = SD3.D3_FILIAL "
	cQuery += "   AND SC2.C2_NUM + SC2.C2_ITEM + SC2.C2_SEQUEN = SD3.D3_OP "
	cQuery += "   AND SC2.D_E_L_E_T_ <> '*' "
	cQuery += " INNER JOIN " + RetSqlName("SB1") + " SB1 "
	cQuery += "    ON SB1.B1_FILIAL  = '02' "
	cQuery += "   AND SB1.B1_COD     = SD3.D3_COD "
	cQuery += "   AND SB1.D_E_L_E_T_ <> '*' "
	cQuery += " WHERE SD3.D3_XMOTREJ <> '' "
	cQuery += "   AND SD3.D3_EMISSAO BETWEEN '" + DToS(dDataDe) + "' AND '" + DToS(dDataAte) + "' "
	cQuery += "   AND SD3.D3_ESTORNO <> 'S' "
	cQuery += "   AND SD3.D3_LOTECTL <> ' '"
	cQuery += "   AND SD3.D_E_L_E_T_ <> '*' "
	cQuery += " ORDER BY SD3.D3_FILIAL, SD3.D3_EMISSAO, SD3.D3_LOTECTL, SD3.D3_COD "

	TCQuery cQuery New Alias (cAliasQry)
	TCSetField(cAliasQry, "DT_REJEICAO", "D", 8, 0)

	Count To nTotal
	oReport:SetMeter(nTotal)
	(cAliasQry)->(DbGoTop())

	oSection:Init()
	While !(cAliasQry)->(Eof())
		If oReport:Cancel()
			Exit
		EndIf

		oSection:Cell("FILIAL"     ):SetValue((cAliasQry)->FILIAL)
		oSection:Cell("DT_REJEICAO"):SetValue((cAliasQry)->DT_REJEICAO)
		oSection:Cell("FUSAO"      ):SetValue((cAliasQry)->FUSAO)
		oSection:Cell("SKU"        ):SetValue((cAliasQry)->SKU)
		oSection:Cell("LIGA"       ):SetValue((cAliasQry)->LIGA)
		oSection:Cell("VARIANTE"   ):SetValue((cAliasQry)->VARIANTE)
		oSection:Cell("BITOLA"     ):SetValue((cAliasQry)->BITOLA)
		oSection:Cell("PECAS"      ):SetValue((cAliasQry)->PECAS)
		oSection:Cell("QTDE_TN"    ):SetValue((cAliasQry)->QTDE_TN)
		oSection:Cell("DEFEITO"    ):SetValue(AllTrim((cAliasQry)->DEFEITO))
		oSection:Cell("SETOR"      ):SetValue(AllTrim((cAliasQry)->SETOR))
		oSection:Cell("USUARIO"    ):SetValue(nomeUsuario((cAliasQry)->USUARIO, @aUsuarios))
		oSection:Cell("POCO"       ):SetValue((cAliasQry)->POCO)
		oSection:Cell("TURNO"      ):SetValue("")
		oSection:PrintLine()

		oReport:IncMeter()
		(cAliasQry)->(DbSkip())
	EndDo
	oSection:Finish()

	(cAliasQry)->(DbCloseArea())
Return

/*/{Protheus.doc} nomeUsuario
Converte o login gravado no D3_USUARIO no nome completo do usuario (cadastro de usuarios do Protheus).
@type     Static Function
@author   FixSystem
@since    18/11/2026
@version  1.0
@param    cLogin, Character, login do usuario (D3_USUARIO)
@param    aCache, Array, cache {login, nome} ja consultados, passado por referencia
@return   Character, nome completo; o proprio login quando o usuario nao e encontrado
/*/
Static Function nomeUsuario(cLogin, aCache)
	Local cChave := AllTrim(cLogin)
	Local cNome  := cChave
	Local aUser  := {}
	Local nPos   := 0

	If Empty(cChave)
		Return ""
	EndIf

	nPos := aScan(aCache, {|x| x[1] == cChave})
	If nPos > 0
		Return aCache[nPos][2]
	EndIf

	PswOrder(2) // busca pelo nome de login
	If PswSeek(cChave, .T.)
		aUser := PswRet()
		If Len(aUser) > 0 .And. Len(aUser[1]) >= 4 .And. !Empty(aUser[1][4])
			cNome := AllTrim(aUser[1][4])
		EndIf
	EndIf

	aAdd(aCache, {cChave, cNome})
Return cNome
