#Include "Totvs.ch"
#Define CRLF Chr(13)+Chr(10)

/*=================================================================
Autor: Vinicius N. De Oliveira
Data: 27/07/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Envia os dados de recebimento de carga (SZ2/SZ0/SZ4/SB1) para
      a API "recebimento-carga" (APIM). Chamada via tela/botao, com
      o SZ2 ja posicionado no ticket corrente pelo chamador (mesmo
      modelo do wsapp_va()).
*==================================================================*/
User Function MLTAPI03(_lJob)

	Local cUrlApi    := "https://apim-cba-daa-prod.azure-api.net/api-protheus/v1/protheus/recebimento-carga"
	Local cSubKey    := "546905ba5e654616b764c51a7eb446c6"
	Local nTimeOut   := 120
	Local aHeader    := {}
	Local cHeaderRet := ""
	Local cToken     := ""
	Local cXmlBody   := ""
	Local cResponse  := ""
	Local cPath      := "\LogVA\"
	Local cNameLog   := "LOG_CARGA_"+AllTrim(SZ2->Z2_COD)
	Local cData      := StrTran(DToS(Date()),"/","")
	Local cHora      := StrTran(Time(),":","")
	Local cDtHora    := AllTrim(cData+"_"+cHora)

	Default _lJob := .F.

	If !ExistDir(cPath)
		MakeDir(cPath)
	EndIf

	DbSelectArea("SZ0")
	SZ0->(DbSetOrder(1))
	SZ0->(DbSeek(xFilial("SZ0")+SZ2->Z2_CODSZ0))

	If AllTrim(SZ0->Z0_TIPO) == "R" .And. SZ0->Z0_FILIAL == '0201'

		cToken := u_MLTAPI02()

		If Empty(cToken)

			ConOut("MLTAPI03: Token de seguranca nao obtido, integracao cancelada.")

			If !_lJob
				FwAlertInfo("Nao foi possivel obter o token de seguranca.","Erro de Integracao")
			EndIf

			Return cResponse

		EndIf

		cXmlBody := MLTMontaXmlCarga()
		aHeader  := MLTMontaHeaderCarga(cToken, cSubKey)

		cResponse := HttpPost(cUrlApi, "application/xml", cXmlBody, nTimeOut, aHeader, @cHeaderRet)

		If !Empty(cResponse)

			ConOut("MLTAPI03: HttpPost Ok")
			VarInfo("Retorno recebimento-carga", cResponse)

			If !_lJob
				Showlog(cResponse)
				Showlog(cXmlBody)
			EndIf

			MLTGravaLogCarga(cPath, cNameLog, cDtHora, "RETORNO", cResponse)
			MLTGravaLogCarga(cPath, cNameLog, cDtHora, "BODY", cXmlBody)

		Else

			If !_lJob
				FwAlertInfo("HttpPost Failed.","Erro WebService")
				ConOut("MLTAPI03: HttpPost Failed.")
				VarInfo("Header", cHeaderRet)
			EndIf

			MLTGravaLogCarga(cPath, cNameLog, cDtHora, "RETORNO", cHeaderRet)
			MLTGravaLogCarga(cPath, cNameLog, cDtHora, "BODY", cXmlBody)

		EndIf

	EndIf

Return cResponse

/*=================================================================
Autor: Vinicius N. De Oliveira
Data: 27/07/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Monta o header HTTP da requisicao de recebimento de carga.
*==================================================================*/
Static Function MLTMontaHeaderCarga(cToken, cSubKey)

	Local aHeader := {}

	aAdd(aHeader, "Content-Type: application/xml")
	aAdd(aHeader, "Authorization: Bearer " + cToken)
	aAdd(aHeader, "Ocp-Apim-Subscription-Key: " + cSubKey)

Return aHeader

/*=================================================================
Autor: Vinicius N. De Oliveira
Data: 27/07/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Monta o XML de recebimento de carga a partir do registro SZ2
      corrente e das tabelas relacionadas (SZ0/SZ4/SB1/DA3). Mesmos
      campos e regras de negocio de wsapp_va().
*==================================================================*/
Static Function MLTMontaXmlCarga()

	Local cXml       := ""
	Local cProcesSuc := ""
	Local cTpOrig    := ""
	Local cLocPad    := ""
	Local cCodForSZ0 := ""
	Local cSucateiro := ""
	Local cNomeCli   := ""
	Local cGrupo     := ""
	Local cCodProd   := SZ2->Z2_PRODVA
	Local cDescricao := ""
	Local cPlaca     := ""
	Local cCargaSKU  := ""
	Local aResult    := {}
	Local nPerda     := 0
	Local cDtEnt     := ""
	Local cDtSai     := ""
	Local cDtRampa   := ""
	Local cDtClass   := ""

	cXml := '<?xml version="1.0" encoding="UTF-8"?>' + CRLF
	cXml += '<IntegrationModel>' + CRLF
	cXml += '   <sq_etiqueta>' + SZ2->Z2_COD + '</sq_etiqueta>' + CRLF
	cXml += '   <cd_empresa>5</cd_empresa>' + CRLF
	cXml += '   <nome_emp>METALEX LTDA</nome_emp>' + CRLF

	DbSelectArea("SZ4")
	SZ4->(DbSetOrder(1))

	If SZ4->(DbSeek(xFilial("SZ4")+SZ2->Z2_CODSZ0))

		aResult := xFilCliSuc()

		If Len(aResult) >= 2
			If Empty(aResult[2])
				cNomeCli   := aResult[1]
				cSucateiro := cNomeCli
			Else
				cSucateiro := aResult[1]
				cNomeCli   := aResult[2]
			EndIf
		EndIf

		If !Empty(SZ4->Z4_CLIFOR)
			cXml += '   <cd_parceiro>' + SZ4->Z4_CLIFOR + '</cd_parceiro>' + CRLF
		Else
			cXml += '   <cd_parceiro/>' + CRLF
		EndIf

		cXml += '   <nome_cli>' + cNomeCli + '</nome_cli>' + CRLF
		cXml += '   <nr_nota_fiscal>' + AllTrim(SZ4->Z4_DOC) + '</nr_nota_fiscal>' + CRLF
		cXml += '   <nr_chave>' + AllTrim(SZ4->Z4_CHAVE) + '</nr_chave>' + CRLF
		cXml += '   <no_sucateiro>' + cSucateiro + '</no_sucateiro>' + CRLF

	Else

		cXml += '   <cd_parceiro/>' + CRLF
		cXml += '   <nome_cli/>' + CRLF
		cXml += '   <nr_nota_fiscal/>' + CRLF
		cXml += '   <nr_chave/>' + CRLF
		cXml += '   <no_sucateiro/>' + CRLF

	EndIf

	If !Empty(cCodProd)
		cXml += '   <cd_mercadoria>' + AllTrim(cCodProd) + '</cd_mercadoria>' + CRLF
	Else
		cXml += '   <cd_mercadoria/>' + CRLF
	EndIf

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	If SB1->(DbSeek(xFilial("SB1")+cCodProd))
		cDescricao := SB1->B1_DESC
		cGrupo     := SB1->B1_GRUPO
	EndIf

	If !Empty(cDescricao)
		cXml += '   <no_abreviado>' + AllTrim(cDescricao) + '</no_abreviado>' + CRLF
	Else
		cXml += '   <no_abreviado/>' + CRLF
	EndIf

	cXml += '   <nr_placa>' + SZ2->Z2_PLACA + '</nr_placa>' + CRLF
	cXml += '   <tp_operacao>R</tp_operacao>' + CRLF

	cDtEnt := DToS(SZ2->Z2_DTPSI)
	cDtEnt := Stuff(cDtEnt,7,0,"-")
	cDtEnt := Stuff(cDtEnt,5,0,"-")

	If !Empty(SZ2->Z2_HRPSI)
		cXml += '   <dt_entrada>' + cDtEnt + "T" + SZ2->Z2_HRPSI + ':00</dt_entrada>' + CRLF
	Else
		cXml += '   <dt_entrada/>' + CRLF
	EndIf

	cDtSai := DToS(SZ2->Z2_DTPSF)
	cDtSai := Stuff(cDtSai,7,0,"-")
	cDtSai := Stuff(cDtSai,5,0,"-")

	If !Empty(SZ2->Z2_HRPSF)
		cXml += '   <dt_saida>' + cDtSai + "T" + SZ2->Z2_HRPSF + ':59</dt_saida>' + CRLF
	Else
		cXml += '   <dt_saida/>' + CRLF
	EndIf

	cXml += '   <peso_entrada>' + cValToChar(SZ2->Z2_PESOI) + '</peso_entrada>' + CRLF
	cXml += '   <peso_saida>' + cValToChar(SZ2->Z2_PESOF) + '</peso_saida>' + CRLF
	cXml += '   <cancelado_sn>N</cancelado_sn>' + CRLF
	cXml += '   <peso_desconto>' + cValToChar(SZ2->Z2_PESOEMB) + '</peso_desconto>' + CRLF
	cXml += '   <peso_nf>' + cValToChar(SZ2->Z2_PESOF) + '</peso_nf>' + CRLF
	cXml += '   <cd_funcionario>' + __cUserID + '</cd_funcionario>' + CRLF

	If !Empty(SZ0->Z0_NOMMOTR)
		cXml += '   <no_motorista>' + AllTrim(SZ0->Z0_NOMMOTR) + '</no_motorista>' + CRLF
	Else
		cXml += '   <no_motorista/>' + CRLF
	EndIf

	cXml += '   <no_serie>1</no_serie>' + CRLF

	cDtRampa := DToS(SZ0->Z0_EMISSAO)
	cDtRampa := Stuff(cDtRampa,7,0,"-")
	cDtRampa := Stuff(cDtRampa,5,0,"-")

	cXml += '   <dt_entrada_rampa>' + cDtRampa + "T" + SZ0->Z0_HORA + ':00</dt_entrada_rampa>' + CRLF

	If !Empty(cCodProd)

		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))

		If SB1->(DbSeek(xFilial("SB1")+cCodProd))

			cLocPad := SB1->B1_LOCPAD

			If SB1->B1_XRM > 0
				cProcesSuc := IIf(SB1->B1_XRM >= 97,"S","N")
				cXml += '   <pe_perda>' + cValToChar(100-SB1->B1_XRM) + '</pe_perda>' + CRLF
			Else
				cProcesSuc := "N"
				cXml += '   <pe_perda>0</pe_perda>' + CRLF
			EndIf

		EndIf

	Else

		cProcesSuc := ""
		cXml += '   <pe_perda>0</pe_perda>' + CRLF

	EndIf

	If !Empty(cLocPad)

		cCodForSZ0 := Posicione("SZ0",1,xFilial("SZ0")+SZ2->Z2_CODSZ0,"Z0_CLIFOR")

		If cCodForSZ0 == "000918" .And. cLocPad == "03"
			cTpOrig := "CBA"
		ElseIf cLocPad == "03" .And. (Empty(cCodForSZ0) .Or. cCodForSZ0 <> "000918")
			cTpOrig := "TER"
		Else
			cTpOrig := "PRO"
		EndIf

	EndIf

	cXml += '   <no_localizacao>PAT</no_localizacao>' + CRLF

	If !Empty(SZ2->Z2_TPREC)
		cXml += '   <tp_recebimento>' + SZ2->Z2_TPREC + '</tp_recebimento>' + CRLF
	Else
		cXml += '   <tp_recebimento/>' + CRLF
	EndIf

	cXml += '   <nr_peso_placa>1</nr_peso_placa>' + CRLF

	If cGrupo $ ('0117|0118|0102|0104|0107')
		cXml += '   <tp_suc>S</tp_suc>' + CRLF
	Else
		cXml += '   <tp_suc>N</tp_suc>' + CRLF
	EndIf

	cXml += '   <tp_pat>MLX</tp_pat>' + CRLF
	cXml += '   <tp_orig>' + cTpOrig + '</tp_orig>' + CRLF
	cXml += '   <tp_rnc>N</tp_rnc>' + CRLF
	cXml += '   <tp_ao>N</tp_ao>' + CRLF
	cXml += '   <qt_peso>' + cValToChar(SZ2->Z2_PESOI-SZ2->Z2_PESOF-SZ2->Z2_PESOEMB) + '</qt_peso>' + CRLF
	cXml += '   <qt_saldo>0</qt_saldo>' + CRLF
	cXml += '   <qtde_bag>' + cValToChar(SZ2->Z2_QBAGM + SZ2->Z2_QBAG) + '</qtde_bag>' + CRLF
	cXml += '   <qtde_pal>' + cValToChar(SZ2->Z2_QPALETP + SZ2->Z2_QPALETM + Val(SZ2->Z2_CPALET)) + '</qtde_pal>' + CRLF
	cXml += '   <qtde_toco>' + cValToChar(SZ2->Z2_QTOCOM + SZ2->Z2_QTOCO) + '</qtde_toco>' + CRLF
	cXml += '   <qtde_na>' + cValToChar(SZ2->Z2_QNA) + '</qtde_na>' + CRLF

	cDtClass := DToS(SZ2->Z2_DTPSF)
	cDtClass := Stuff(cDtClass,7,0,"-")
	cDtClass := Stuff(cDtClass,5,0,"-")
	cPlaca   := AllTrim(Posicione("DA3",3,xFilial("DA3")+SZ2->Z2_PLACA,"DA3_DESC"))

	If cDtClass <> "    -  -  "
		cXml += '   <dt_class>' + cDtClass + '</dt_class>' + CRLF
	Else
		cXml += '   <dt_class/>' + CRLF
	EndIf

	If SZ2->Z2_PROCLR == "S"
		nPerda := Round((1-(SZ2->Z2_QPR0ESI + SZ2->Z2_QPR0EBA + SZ2->Z2_QPR0ISI + SZ2->Z2_QPR0IPR)/SZ2->Z2_PESONF)*100,2)
	Else
		nPerda := 0
	EndIf

	cXml += '   <no_arquivo_xml_nf>0</no_arquivo_xml_nf>' + CRLF
	cXml += '   <tp_veiculo>' + cPlaca + '</tp_veiculo>' + CRLF
	cXml += '   <sucata_processo>' + cProcesSuc + '</sucata_processo>' + CRLF
	cXml += '   <lote_para_centro_coleta>' + IIf(SZ2->Z2_DESTINO == '3','S','N') + '</lote_para_centro_coleta>' + CRLF
	cXml += '   <lote_para_linha_reciclagem>' + IIf(SZ2->Z2_DESTINO == '4','S','N') + '</lote_para_linha_reciclagem>' + CRLF

	If !Empty(SZ2->Z2_NCONTA)
		cXml += '   <nivel_contaminacao_sucata>' + AllTrim(SZ2->Z2_NCONTA) + '</nivel_contaminacao_sucata>' + CRLF
	Else
		cXml += '   <nivel_contaminacao_sucata/>' + CRLF
	EndIf

	If !Empty(SZ2->Z2_FSUCATA)
		cXml += '   <formato_sucata>' + AllTrim(SZ2->Z2_FSUCATA) + '</formato_sucata>' + CRLF
	Else
		cXml += '   <formato_sucata/>' + CRLF
	EndIf

	cXml += '   <peso_sucata_limpa>' + cValToChar(SZ2->Z2_QPR0ESI + SZ2->Z2_QPR0EBA + SZ2->Z2_QPR0ISI + SZ2->Z2_QPR0IPR) + '</peso_sucata_limpa>' + CRLF
	cXml += '   <pe_perda_real>' + cValToChar(nPerda) + '</pe_perda_real>' + CRLF
	cXml += '   <peso_particulado_grosseiro>' + cValToChar(SZ2->Z2_QREJCON) + '</peso_particulado_grosseiro>' + CRLF
	cXml += '   <peso_particulado_fino>' + cValToChar(SZ2->Z2_QREJPEN) + '</peso_particulado_fino>' + CRLF
	cXml += '   <peso_material_ferroso>' + cValToChar(SZ2->Z2_QREJMG1 + SZ2->Z2_QREJMG2) + '</peso_material_ferroso>' + CRLF
	cXml += '   <peso_material_nao_metalico>' + cValToChar(SZ2->Z2_QREJPEN) + '</peso_material_nao_metalico>' + CRLF
	cXml += '   <peso_material_organico>' + cValToChar(SZ2->Z2_QREJEDD) + '</peso_material_organico>' + CRLF
	cXml += '   <estagio_dados_lote_sucata>PI</estagio_dados_lote_sucata>' + CRLF

	cDtClass  := DToS(Date())
	cDtClass  := Stuff(cDtClass,7,0,"-")
	cDtClass  := Stuff(cDtClass,5,0,"-")
	cCargaSKU := xCheckList()

	cXml += '   <dt_mudanca_estagio>' + cDtClass + '</dt_mudanca_estagio>' + CRLF
	cXml += '   <peso_liquido>' + cValToChar(SZ2->Z2_PESOL) + '</peso_liquido>' + CRLF
	cXml += '   <carga_sku_unico>' + cCargaSKU + '</carga_sku_unico>' + CRLF
	cXml += '</IntegrationModel>' + CRLF

Return cXml

/*=================================================================
Autor: Vinicius N. De Oliveira
Data: 27/07/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Grava arquivo de log (retorno/body) da integracao de carga.
*==================================================================*/
Static Function MLTGravaLogCarga(cPath, cNameLog, cDtHora, cSufixo, cConteudo)
	MemoWrite(cPath + cNameLog + "_" + cSufixo + "_" + cDtHora + ".xml", cConteudo)
Return
/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 31/03/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Filtra sucateiro e cliente
*==================================================================*/   
Static Function xFilCliSuc()

    Local aAreaQry  := GetArea()
    Local cQuery    := ""
    Local aResult   := {}
    Local cTemp     := GetNextAlias()

	cQuery := " SELECT DISTINCT Z0_FILIAL FILIAL,Z0_COD CHECKLIST"
	cQuery += " ,CONVERT(DATE,Z0_EMISSAO) DT_CHECKLIST"
	cQuery += " ,Z2_COD TICKET"
	cQuery += " ,Z0_PLACA PLACA" 
	cQuery += " ,Z0_TIPO TIPO" 
	cQuery += " ,Z0_STATUS STATUS" 
	cQuery += " ,Z0_NOME NOME" 
	cQuery += " ,D1_CF CFOP" 
	cQuery += " ,CASE" 
	cQuery += " 	WHEN SUBSTRING(D1_CF,2,3) IN ('101','102')THEN 'COMPRA'" 
	cQuery += " 	WHEN SUBSTRING(D1_CF,2,3) IN ('924') THEN 'REMESSA'" 
	cQuery += " 	ELSE 'OUTRAS ENTRADAS' END OPERACAO" 
	cQuery += " ,DH_DOC NF_COBERTURA"
	cQuery += " ,DH_CLIENTE CODCLI"
	cQuery += " ,DH_LOJACLI LOJACLI"
	cQuery += " ,A1_NOME NOM_CLI"
	cQuery += " ,Z0_DOCS DOCUMENTOS" 
	cQuery += " ,Z0_OBS OBSERVACAO" 
	cQuery += " ,Z2_PRODUTO COD_PROD" 
	cQuery += " ,Z2_DESCRI DESC_PROD" 
	cQuery += " ,Z2_PESOI PESO_INICIAL" 
	cQuery += " ,Z2_PESOF PESO_FINAL" 
	cQuery += " ,Z2_PESOL PESO_LIQ_BAL" 
	cQuery += " ,Z2_PESOEMB PESO_EMB" 
	cQuery += " ,Z2_PESOL-Z2_PESOEMB PESO_LIQ_NF" 
	cQuery += " FROM "+RetSQLName("SZ0")+" SZ0"  
	cQuery += " 	INNER JOIN "+RetSQLName("SZ2")+" SZ2 ON SZ2.D_E_L_E_T_ <> '*' AND SZ2.Z2_FILIAL=SZ0.Z0_FILIAL AND SZ2.Z2_CODSZ0=SZ0.Z0_COD"  
	cQuery += " 	LEFT JOIN "+RetSQLName("SD1")+" SD1 ON SD1.D_E_L_E_T_ <> '*' AND D1_FILIAL=Z2_FILIAL AND D1_COD=Z2_PRODUTO AND D1_XCODSZ2=Z2_COD"
	cQuery += " 	AND EXISTS (SELECT 1 FROM "+RetSQLName("SZ4")+" SZ4 WHERE SZ4.D_E_L_E_T_ <> '*' AND Z4_FILIAL=Z2_FILIAL AND Z4_DOC=D1_DOC AND Z4_SERIE=D1_SERIE AND Z4_CLIFOR=D1_FORNECE AND Z4_LOJA=D1_LOJA) 
	cQuery += " 	LEFT JOIN "+RetSQLName("SDH")+" SDH ON SDH.D_E_L_E_T_ <> '*' AND DH_FILIAL=Z2_FILIAL AND DH_NDOC=Z0_DOCS AND DH_NDOC<>''"
	cQuery += " 	LEFT JOIN "+RetSQLName("SA1")+" SA1 ON SA1.D_E_L_E_T_ <> '*' AND A1_COD=DH_CLIENTE AND DH_LOJACLI=A1_LOJA" 
	cQuery += " WHERE SZ0.D_E_L_E_T_ <> '*'"
	cQuery += " 	AND Z0_FILIAL = '"+SZ2->Z2_FILIAL+"'"
	cQuery += " 	AND Z0_COD = '"+SZ2->Z2_CODSZ0+"'"
	cQuery += " ORDER BY Z0_FILIAL,Z0_COD" 

	//Convers�o da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execu��o da query no banco de dados
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)
	
	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())
	
	While !((cTemp)->(Eof()))

		aAdd(aResult,AllTrim((cTemp)->NOME)) //Sucateiro
		aAdd(aResult,AllTrim((cTemp)->NOM_CLI)) //Cliente

		(cTemp)->(DbSkip())

	EndDo

	(cTemp)->(DbCloseArea())

    RestArea(aAreaQry)

Return(aResult)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 23/03/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Filtra os checklists
*==================================================================*/
Static Function xCheckList()

    Local aAreaSZ2  := GetArea()
    Local cQuery    := ""
    Local cResult   := ""
    Local cTemp     := GetNextAlias()
    Local nQtdCheck := 0

    cQuery := "SELECT * FROM "+RetSQLName("SZ2")
    cQuery += " WHERE Z2_FILIAL = '"+SZ2->Z2_FILIAL+"'"
    cQuery += "     AND Z2_CODSZ0 = '"+SZ2->Z2_CODSZ0+"'"
    cQuery += "     AND D_E_L_E_T_ <> '*'"

    //Protecao para verificar se ha dados ja na tabela temporaria
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()
	Endif

	//Conversao da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execucao da query no banco de dados
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)

	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())

	While !((cTemp)->(Eof()))

		nQtdCheck ++

		(cTemp)->(DbSkip())

	EndDo

	(cTemp)->(DbCloseArea())

    RestArea(aAreaSZ2)

    If nQtdCheck > 1

        cResult := "N"

    Else

        cResult := "S"

    Endif

Return(cResult)
