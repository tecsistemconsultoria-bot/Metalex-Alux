#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'Totvs.ch'
#Define CRLF Chr(13)+Chr(10)

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 16/03/2026
Consultoria: Fixsystem
Uso: Metalex
Tipo: API
Rotina: Específica
Função: MLTAPI001
Info: Nova API do VA (Json)
************************************************************************/
User Function MLTAPI001(_lJob)

    Local aXmlBatch := {}
	Local cRet      := ""

	DbSelectArea("SZ2")
	SZ2->(DbsetOrder(1))
		
	If SZ2->Z2_TPTICK == "R" .And. SZ2->Z2_FILIAL == '0201'
	
		MsgRun("Processando ticket "+SZ2->Z2_COD,"Aguarde...",{|| cRet := U_APIGERAXML()})
		
		If !Empty(cRet)
			aAdd(aXmlBatch,cRet)			
		Endif 
		
	EndIf
	
    If Len(aXmlBatch) > 0
        MsgRun("Enviando lote para VA ("+cValToChar(Len(aXmlBatch))+" tickets)","Aguarde...",{|| u_APIVA(aXmlBatch, _lJob) })
    EndIf

Return

/*=================================================================
Autor: Vinicius N. De Oliveira
Data: 25/03/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Envio em lote 
*==================================================================*/  
User Function xEvLoteAPI(_lJob)

    Local aXmlBatch := {}
	Local cRet      := ""

    If SZ2->Z2_TPTICK == "R" .And. SZ2->Z2_FILIAL == '0201'
		
		MsgRun("Processando ticket "+SZ2->Z2_COD,"Aguarde...",{|| cRet := U_APIGERAXML()})
		
		If !Empty(cRet)
			aAdd(aXmlBatch,cRet)			
		Endif 
		
    EndIf
        
    If Len(aXmlBatch) > 0
        MsgRun("Enviando lote para VA ("+cValToChar(Len(aXmlBatch))+" tickets)","Aguarde...",{|| U_APIVA(aXmlBatch, _lJob) })
    EndIf

Return

/*=================================================================
Autor: Vinicius N. De Oliveira
Data: 16/03/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/   
User Function APIVA(aXmlBatch, _lJob)

	Local cUrlVa     := "https://apprecebimentovideoanalytics-b4buacc6hdeuhhas.eastus2-01.azurewebsites.net/v1/xml/upload"
	Local nTimeOut   := 120
	Local aHeaderVA  := {}
	Local cHeaderRet := ""
	Local cPostRetVa := ""
    Local oJsonVA    := Nil
    Local _cDataRef  := ""
    Local _cPostVa   := ""
    Local cErrParse  := ""
    Local cMens      := 'Message_Identifier=JD&Message_Type=TruckPostion'
	Local cPath      := "\LogVA\"
	Local cNameLog   := "LOG_VA_"+AllTrim(SZ2->Z2_COD)
	Local cData      := StrTran(DToS(Date()),"/","")
	Local cHora      := StrTran(Time(),":","")
	Local cDtHora    := AllTrim(cData+"_"+cHora)
	
	If !ExistDir(cPath)
		MakeDir(cPath)
	Endif 

    _cDataRef := DToS(Date())
    _cDataRef := Stuff(_cDataRef,7,0,"-")
    _cDataRef := Stuff(_cDataRef,5,0,"-")

    oJsonVA := JsonObject():New()

    oJsonVA['data_referencia'] := _cDataRef
    oJsonVA['usuario']         := 'postman_batch'
    oJsonVA['xmls']            := aXmlBatch 

    _cPostVa := EncodeUTF8(oJsonVA:toJson())

    aAdd(aHeaderVA,'User-Agent: Mozilla/4.0 (compatible; Protheus '+GetBuild()+')')
    aAdd(aHeaderVA,'Content-Type: application/json; charset=utf-8')
    aAdd(aHeaderVA,'Authorization: Bearer [k!G282&Qnw9')

    cPostRetVA := HttpPost(cUrlVa, cMens, _cPostVa, nTimeOut, aHeaderVA, @cHeaderRet)

    If !Empty(cPostRetVA)

        ConOut("HttpPost Ok")
        VarInfo("Retorno WS", cPostRetVA)

        oRetJson := JsonObject():New()
        
        cErrParse := oRetJson:FromJson(cPostRetVA)

        If Empty(cErrParse)

            If !_lJob
                Showlog(cPostRetVA)
                Showlog(_cPostVa)
            EndIf

        Else

            ConOut("Erro ao fazer o parse do retorno: " + cErrParse)
            
            If !_lJob
                FwalertError("Erro ao processar a resposta da API: " + cErrParse, "Erro de Parse JSON")
            EndIf
        EndIf
        
        FreeObj(oRetJson)

    Else

        If !_lJob

            FwalertInfo("HttpPost Failed.", "Erro WebService")
            ConOut("HttpPost Failed.")
            VarInfo("Header", cHeaderRet)

        Endif

    Endif
	
	MemoWrite(cPath+cNameLog+"_RETORNO_API_NOVA_"+cDtHora+".xml",cPostRetVA)
	MemoWrite(cPath+cNameLog+"_BODY_API_NOVA_"+cDtHora+".xml",_cPostVa)

    FreeObj(oJsonVA)

Return

/*=================================================================
Autor: Vinicius N. De Oliveira
Data: 16/03/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
User Function APIGERAXML()

    Local cMsg        := ""
    Local _cDescricao := ""
    Local _cDtEnt     := ""
    Local _cDtSai     := ""
    Local _cDtRampa   := ""
    Local _cDtClass   := ""
    Local cPlaca      := ""
    Local cCargaSKU   := ""
	Local cProcesSuc  := ""
	Local cTpOrig     := ""
	Local cLocPad     := ""
	Local cCodForSZ0  := ""
	Local cSucateiro  := ""
	Local cNomeCli    := ""
	Local cGrupo 	  := ""

	Local aResult     := {}
    DbSelectArea("SZ0")

    SZ0->(DbsetOrder(1))
    SZ0->(DbSeek(xFilial("SZ0")+SZ2->Z2_CODSZ0))  

    If AllTrim(SZ0->Z0_TIPO) == "R" .And. SZ0->Z0_FILIAL == '0201'

		cMsg := '<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/" xmlns:tem="http://tempuri.org/">'
		cMsg += '<soapenv:Header/>'
		cMsg += '<soapenv:Body>'
		cMsg += '<tem:SincronizarDadosSIMNaAppAnaliseSucata>'
		cMsg += '<tem:lstDados>'
		cMsg += '<tem:IntegrationModel>'
		cMsg += '<tem:sq_etiqueta>'+SZ2->Z2_COD+'</tem:sq_etiqueta>'
		cMsg += '               <tem:cd_empresa>5</tem:cd_empresa> '
		cMsg += '               <tem:nome_emp>METALEX LTDA</tem:nome_emp> '
		
		DbSelectArea("SZ4")
		SZ4->(DbsetOrder(1))
		
		If SZ4->(DbSeek(xFilial("SZ4")+SZ2->Z2_CODSZ0))
	
			aResult := xFilCliSuc()
	
			If Len(aResult) >= 2
	
				cSucateiro := aResult[1]
				cNomeCli   := aResult[2]
					
				If Empty(cNomeCli) 
						cNomeCli   := aResult[1]
						cSucateiro := cNomeCli 
				Else
						cSucateiro := aResult[1]
						cNomeCli   := aResult[2]
				Endif 
	
			Endif 
	
			If !Empty(SZ4->Z4_CLIFOR)
				cMsg += '               <tem:cd_parceiro>'+SZ4->Z4_CLIFOR+'</tem:cd_parceiro> '+CRLF 
			Else 
				cMsg += '               <tem:cd_parceiro> </tem:cd_parceiro> '+CRLF
			Endif 
	
			cMsg += '               <tem:nome_cli>'+cNomeCli+'</tem:nome_cli> '+CRLF
			cMsg += '               <tem:nr_nota_fiscal>'+AllTrim(SZ4->Z4_DOC)+'</tem:nr_nota_fiscal> '+CRLF
			cMsg += '               <tem:nr_chave>'+AllTrim(SZ4->Z4_CHAVE)+'</tem:nr_chave> '+CRLF
			cMsg += '               <tem:no_sucateiro>'+cSucateiro+'</tem:no_sucateiro> '+CRLF
	
		Else
	
			cMsg += '               <tem:cd_parceiro> </tem:cd_parceiro> '+CRLF 
			cMsg += '               <tem:nome_cli> </tem:nome_cli> '+CRLF
			cMsg += '               <tem:nr_nota_fiscal> </tem:nr_nota_fiscal> '+CRLF
			cMsg += '               <tem:nr_chave> </tem:nr_chave> '+CRLF
			cMsg += '               <tem:no_sucateiro> </tem:no_sucateiro> '+CRLF
	
		EndIf
		
		If !Empty(SZ2->Z2_PRODUTO)
			cMsg += '               <tem:cd_mercadoria>'+AllTrim(SZ2->Z2_PRODUTO)+'</tem:cd_mercadoria> '+CRLF
		Else 
			cMsg += '               <tem:cd_mercadoria> </tem:cd_mercadoria> '+CRLF
		Endif 
		
		_cDescricao := ""
		
		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		
		If SB1->(DbSeek(xFilial("SB1")+SZ2->Z2_PRODUTO))
			_cDescricao := AllTrim(SB1->B1_DESC)
			cGrupo      := SB1->B1_GRUPO
		EndIf
		
		If !Empty(_cDescricao)
			cMsg += '               <tem:no_abreviado>'+AllTrim(_cDescricao)+'</tem:no_abreviado> '+CRLF
		Else 
			cMsg += '               <tem:no_abreviado> </tem:no_abreviado> '+CRLF
		Endif 
	
		cMsg += '               <tem:nr_placa>'+SZ2->Z2_PLACA+'</tem:nr_placa> '+CRLF //chave
		cMsg += '               <tem:tp_operacao>R</tem:tp_operacao> '+CRLF
		
		_cDtEnt := DToS(SZ2->Z2_DTPSI)
		_cDtEnt := Stuff(_cDtEnt,7,0,"-")
		_cDtEnt := Stuff(_cDtEnt,5,0,"-")
		
		If !Empty(SZ2->Z2_HRPSI)
			cMsg += '               <tem:dt_entrada>'+_cDtEnt+"T"+SZ2->Z2_HRPSI+':00</tem:dt_entrada> '+CRLF //chave
		Else
			cMsg += '               <tem:dt_entrada> </tem:dt_entrada> '+CRLF
		Endif 
	
		_cDtSai := DToS(SZ2->Z2_DTPSF)
		_cDtSai := Stuff(_cDtSai,7,0,"-")
		_cDtSai := Stuff(_cDtSai,5,0,"-")
		
		If !Empty(SZ2->Z2_HRPSF)
			cMsg += '               <tem:dt_saida>'+_cDtSai+"T"+SZ2->Z2_HRPSF+':59</tem:dt_saida> '+CRLF
		Else 
			cMsg += '               <tem:dt_saida> </tem:dt_saida> '+CRLF
		Endif 
	
		cMsg += '               <tem:peso_entrada>'+cValToChar(SZ2->Z2_PESOI)+'</tem:peso_entrada> '+CRLF
		cMsg += '               <tem:peso_saida>'+cValToChar(SZ2->Z2_PESOF)+'</tem:peso_saida> '+CRLF
		cMsg += '               <tem:cancelado_sn>N</tem:cancelado_sn> '+CRLF
		cMsg += '               <tem:peso_desconto>'+cValToChar(SZ2->Z2_PESOEMB)+'</tem:peso_desconto> '+CRLF
		cMsg += '               <tem:peso_nf>'+cValToChar(SZ2->Z2_PESOF)+'</tem:peso_nf> '+CRLF
		cMsg += '               <tem:cd_funcionario>'+__cUserID+'</tem:cd_funcionario> '+CRLF
	
		If !Empty(SZ0->Z0_NOMMOTR)
			cMsg += '               <tem:no_motorista>'+AllTrim(SZ0->Z0_NOMMOTR)+'</tem:no_motorista> '+CRLF
		Else
			cMsg += '               <tem:no_motorista> </tem:no_motorista> '+CRLF
		Endif 
	
		cMsg += '               <tem:no_serie>1</tem:no_serie> '+CRLF
		
		_cDtRampa := DToS(SZ0->Z0_EMISSAO)
		_cDtRampa := Stuff(_cDtRampa,7,0,"-")
		_cDtRampa := Stuff(_cDtRampa,5,0,"-")
		
		cMsg += '               <tem:dt_entrada_rampa>'+_cDtRampa+"T"+SZ0->Z0_HORA+':00</tem:dt_entrada_rampa> '+CRLF
		
		If !Empty(SZ2->Z2_PRODUTO)
	
			DbSelectArea("SB1")
			SB1->(DbsetOrder(1))
			
			If SB1->(DbSeek(xFilial("SB1")+SZ2->Z2_PRODUTO))
	
				cLocPad := SB1->B1_LOCPAD
	
				If SB1->B1_XRM > 0		    
	
					cProcesSuc := IIf(SB1->B1_XRM >= 97,"S","N")
	
					cMsg += '               <tem:pe_perda>'+cValToChar(100-SB1->B1_XRM)+'</tem:pe_perda> '+CRLF
				Else
	
					cProcesSuc := "N"
	
					cMsg += '               <tem:pe_perda>0</tem:pe_perda> '+CRLF
				EndIf
	
			EndIf
	
		Else
	
			cProcesSuc := ""
	
			cMsg += '               <tem:pe_perda>0</tem:pe_perda> '+CRLF
			
		EndIf
	
		cCodForSZ0 := ""
		cSucateiro := ""
		cNomeCli   := ""
	
		//Regra tp_orig
		If !Empty(cLocPad)
	
			cCodForSZ0 := Posicione("SZ0",1,xFilial("SZ0")+SZ2->Z2_CODSZ0,"Z0_CLIFOR")
	
			If cCodForSZ0 == "000918" .And. cLocPad == "03"
			
				cTpOrig := "CBA"
	
			Elseif cLocPad == "03" .And. (Empty(cCodForSZ0) .Or. cCodForSZ0 <> "000918")
	
				cTpOrig := "TER"
			
			Else
	
				cTpOrig := "PRO"
	
			Endif 
	
		Endif
		// --- 
		
		cMsg += '               <tem:no_localizacao>PAT</tem:no_localizacao> '+CRLF
	
		If !Empty(SZ2->Z2_TPREC)
			cMsg += '               <tem:tp_recebimento>'+SZ2->Z2_TPREC+'</tem:tp_recebimento> '+CRLF
		Else 
			cMsg += '               <tem:tp_recebimento> </tem:tp_recebimento> '+CRLF
		Endif 
	
		cMsg += '               <tem:nr_peso_placa>1</tem:nr_peso_placa> '+CRLF
		
		
		If cGrupo $ ('0117|0118|0102|0104|0107')
			cMsg += '               <tem:tp_suc>S</tem:tp_suc> '+CRLF
		Else
			cMsg += '               <tem:tp_suc>N</tem:tp_suc> '+CRLF
		EndiF 

		cMsg += '               <tem:tp_pat>MLX</tem:tp_pat> '+CRLF
		cMsg += '               <tem:tp_orig>'+cTpOrig+'</tem:tp_orig> '+CRLF
		cMsg += '               <tem:tp_rnc>N</tem:tp_rnc> '+CRLF
		cMsg += '               <tem:tp_ao>N</tem:tp_ao> '+CRLF
		cMsg += '               <tem:qt_peso>'+cValToChar(SZ2->Z2_PESOI-SZ2->Z2_PESOF-SZ2->Z2_PESOEMB)+'</tem:qt_peso> '+CRLF
		cMsg += '               <tem:qt_saldo>0</tem:qt_saldo> '+CRLF
		cMsg += '               <tem:qtde_bag>'+cValToChar(SZ2->Z2_QBAGM + SZ2->Z2_QBAG)+'</tem:qtde_bag> '+CRLF
		cMsg += '               <tem:qtde_pal>'+cValToChar(SZ2->Z2_QPALETP + SZ2->Z2_QPALETM + SZ2->Z2_QPALET)+'</tem:qtde_pal> '+CRLF
		cMsg += '               <tem:qtde_toco>'+cValToChar(SZ2->Z2_QTOCOM + SZ2->Z2_QTOCO)+'</tem:qtde_toco> '+CRLF
		cMsg += '               <tem:qtde_na>'+cValToChar(SZ2->Z2_QNA)+'</tem:qtde_na> '+CRLF
		
		_cDtClass := DToS(SZ2->Z2_DTPSF)
		_cDtClass := Stuff(_cDtClass,7,0,"-")
		_cDtClass := Stuff(_cDtClass,5,0,"-")
		cPlaca    := AllTrim(Posicione("DA3",3,xFilial("DA3")+SZ2->Z2_PLACA,"DA3_DESC"))
		cVazDtClass := "    -  -  "
		
		If _cDtClass <> cVazDtClass
			cMsg += '               <tem:dt_class>'+_cDtClass+'</tem:dt_class> '+CRLF
		Else 
			cMsg += '               <tem:dt_class> </tem:dt_class> '+CRLF
		Endif 
	
		If SZ2->Z2_PROCLR == "S"
			nPerda := Round((1-(SZ2->Z2_QPR0ESI + SZ2->Z2_QPR0EBA + SZ2->Z2_QPR0ISI + SZ2->Z2_QPR0IPR)/SZ2->Z2_PESONF)*100,2)
		Else 
			nPerda := 0
		Endif 
	
		cMsg += '               <tem:no_arquivo_xml_nf>0</tem:no_arquivo_xml_nf> '+CRLF
		cMsg += '               <tem:tp_veiculo>'+cPlaca+'</tem:tp_veiculo> '+CRLF
		cMsg += '               <tem:sucata_processo>'+cProcesSuc+'</tem:sucata_processo> '+CRLF
		cMsg += '               <tem:lote_para_centro_coleta>'+IIf(SZ2->Z2_DESTINO == '3','S','N')+'</tem:lote_para_centro_coleta> '+CRLF
		cMsg += '               <tem:lote_para_linha_reciclagem>'+IIf(SZ2->Z2_DESTINO == '4','S','N')+'</tem:lote_para_linha_reciclagem> '+CRLF
		
		If !Empty(SZ2->Z2_NCONTA)
			cMsg += '               <tem:nivel_contaminacao_sucata>'+AllTrim(SZ2->Z2_NCONTA)+'</tem:nivel_contaminacao_sucata> '+CRLF
		Else 
			cMsg += '               <tem:nivel_contaminacao_sucata> </tem:nivel_contaminacao_sucata> '+CRLF	
		Endif 
		
		If !Empty(SZ2->Z2_FSUCATA)
			cMsg += '               <tem:formato_sucata>'+AllTrim(SZ2->Z2_FSUCATA)+'</tem:formato_sucata> '+CRLF
		Else 
			cMsg += '               <tem:formato_sucata> </tem:formato_sucata> '+CRLF
		Endif 
		
		cMsg += '               <tem:peso_sucata_limpa>'+cValToChar(SZ2->Z2_QPR0ESI + SZ2->Z2_QPR0EBA + SZ2->Z2_QPR0ISI + SZ2->Z2_QPR0IPR)+'</tem:peso_sucata_limpa> '+CRLF
		cMsg += '               <tem:pe_perda_real>'+cValToChar(nPerda)+'</tem:pe_perda_real> '+CRLF
		cMsg += '               <tem:peso_particulado_grosseiro>'+cValToChar(SZ2->Z2_QREJCON)+'</tem:peso_particulado_grosseiro> '+CRLF
		cMsg += '               <tem:peso_particulado_fino>'+cValToChar(SZ2->Z2_QREJPEN)+'</tem:peso_particulado_fino> '+CRLF
		cMsg += '               <tem:peso_material_ferroso>'+cValToChar(SZ2->Z2_QREJMG1 + SZ2->Z2_QREJMG2)+'</tem:peso_material_ferroso> '+CRLF
		cMsg += '               <tem:peso_material_nao_metalico>'+cValToChar(SZ2->Z2_QREJPEN)+'</tem:peso_material_nao_metalico> '+CRLF
		cMsg += '               <tem:peso_material_organico>'+cValToChar(SZ2->Z2_QREJEDD)+'</tem:peso_material_organico> '+CRLF
		cMsg += '               <tem:estagio_dados_lote_sucata>PI</tem:estagio_dados_lote_sucata> '+CRLF
		
		_cDtClass := DToS(Date())
		_cDtClass := Stuff(_cDtClass,7,0,"-")
		_cDtClass := Stuff(_cDtClass,5,0,"-")
	
		cCargaSKU := xCheckList()
	
		cMsg += '               <tem:dt_mudanca_estagio>'+_cDtClass+'</tem:dt_mudanca_estagio> '+CRLF
		cMsg += '               <tem:peso_liquido>'+cValToChar(SZ2->Z2_PESOL)+'</tem:peso_liquido> '+CRLF
		cMsg += '               <tem:carga_sku_unico>'+cCargaSKU+'</tem:carga_sku_unico> '+CRLF
		cMsg += '            </tem:IntegrationModel> '+CRLF
		cMsg += '         </tem:lstDados> '+CRLF
		cMsg += '         <tem:modoOperacao>1</tem:modoOperacao> '+CRLF
		cMsg += '         <tem:bRetornaFotoPlaca>1</tem:bRetornaFotoPlaca> '+CRLF
		cMsg += '         <tem:idIntegracao>1</tem:idIntegracao> '+CRLF
		cMsg += '         <tem:StatusSolicitacaoAssincrona>1</tem:StatusSolicitacaoAssincrona> '+CRLF
		cMsg += '         <tem:MensagemDeErro>1</tem:MensagemDeErro> '+CRLF
		cMsg += '      </tem:SincronizarDadosSIMNaAppAnaliseSucata> '+CRLF
		cMsg += '   </soapenv:Body> '+CRLF
		cMsg += '</soapenv:Envelope> '+CRLF	
		
	Else 
		
		cMsg := ""
		
	Endif 

Return(cMsg)

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

    //Proteção para verificar se há dados já na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()	
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
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

/*=================================================================
Autor: Lucas Floridi
Data: 16/03/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/   
User Function ENVAPI()

	MsApp():New('SIGAEST')
	oApp:CreateEnv()
	PtSetTheme("SUNSET")
	
    oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",{|| RpcSetEnv("01","0201"), }), u_MLTAPI001(.F.), Final("TERMINO NORMAL")}
	
    __lInternet  := .T.
	lMsFinalAuto := .F.
	
	oApp:lMessageBar := .T.
	oApp:cModDesc    := 'SIGAEST'
	oApp:Activate()

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

	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execução da query no banco de dados
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

