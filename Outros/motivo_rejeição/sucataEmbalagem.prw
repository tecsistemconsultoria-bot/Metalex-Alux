#INCLUDE 'totvs.ch'
#INCLUDE "RWMAKE.CH"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDef.ch'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FWPrintSetup.ch"
#Define _cTmDE0 "001"
#Define _cTmRE0 "501"
#Define _cTabRej "Z2" // INC1833293 - tabela SX5 dos motivos de rejeicao


User Function dbg_suc3()

	MsApp():New('SIGAFAT')
	oApp:CreateEnv()
	//Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
	PtSetTheme("OCEAN")
	//Define o programa que ser� executado ap�s o login
	//oApp:cStartProg	:= 'U_MXFAT01A'
	oApp:cStartProg	:= 'U_RCFAC001()'
	//Seta Atributos
	__lInternet := .T.
	//Inicia a Janela
	oApp:Activate()
Return Nil

USER FUNCTION RCFAC001()
	Local cFiltro := "B8_SALDO>0 AND B8_LOCAL = '49'"
	LOCAL cAlias := "SB8"
	Private cCodDestino := Padr("4000474",TamSX3("B1_COD")[1])
	PRIVATE cCadastro := "Estoque pos serra (v3)"
	PRIVATE aRotina     := {}

	AADD(aRotina, { "Pesquisar"   , "AxPesqui"          , 0, 1 })
	AADD(aRotina, { "Visualizar"  , "AxVisual"  	    , 0, 2 })
	// AADD(aRotina, { "Incluir"     , "AxInclui"          , 0, 3 })
	// AADD(aRotina, { "Alterar"     , "AxAltera"          , 0, 4 })
	// AADD(aRotina, { "Excluir"     , "AxDeleta"          , 0, 5 })
	AADD(aRotina, { "Sucatar"   , "u_RCFAS001"        , 0, 4 })
	// AADD(aRotina, { "IMP2"        , "u_EtqLfCR()"         , 0, 7 })
	// AADD(aRotina, { "IMP3"        , "u_xetq3()"         , 0, 8 })
	// AADD(aRotina, { "IMP4"        , "u_xetq4()"        	, 0, 9 })
	// AADD(aRotina, { "IMP5"        , "u_xetq5()"        	, 0, 10 })
	// AADD(aRotina, { "IMP6"        , "u_xetq6()"         , 0, 11 })
	// AADD(aRotina, { "IMP7"        , "u_EtqLoteFechado()", 0, 12 })

	dbSelectArea(cAlias)
	dbSetOrder(1)
	// mBrowse(6, 1, 22, 75, cAlias)
	mBrowse(6, 1, 22, 75, cAlias,,,,,,/*aCores*/,,,,,,,,cFiltro)



RETURN


// 09/11/2026 FixSystem - Leonardo Barboza Ribeiro Leite: INC1833293 - motivo de rejeicao obrigatorio no sucateamento
User Function RCFAS001()

	Local aMATA650 := {} //-Array com os campos
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 3 - Inclusao ³
	//³ 4 - Alteracao ³
	//³ 5 - Exclusao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nOpc := 3
	Local cDocRE := "" // INC1833293 - documento da requisicao (saida do lote)
	Local cDocDE := "" // INC1833293 - documento da devolucao (entrada da sucata)
	Local nRecIni := 0 // 18/11/2026 FixSystem: INC1833293 - ultimo recno da SD3 antes de cada MATA241
	Private lMsErroAuto := .F.
	Private oDlg
	Private oLiga
	Private oVariante
	Private oBitola
	Private oCompri
	Private oPesoLote
	Private oPcsLote
	Private oQtdePcs
	Private oPesoCons
	Private oMotRej
	Private cMotRej := Space(2)
	Private aMotRej := carregaMotivos()
	DbSelectArea("SB1")
	DbSetOrder(1)
	If !DbSeek(xFilial("SB1")+cCodDestino)
		FwalertError("Produto "+cCodDestino+" nao localizado!!","Produto Sucatado")
		Return
	EndIf
	cLocDestino := SB1->B1_LOCPAD
	cCodOrigem  := SB8->B8_PRODUTO
	cLocOrigem  := SB8->B8_LOCAL
	cLote       := SB8->B8_LOTECTL
	nPesoLote   := SB8->B8_SALDO
	nPcsLote   := SB8->B8_SALDO2
	nPesoCons := SB8->B8_SALDO
	nQtdePcs    := SB8->B8_SALDO2

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+cCodOrigem)
	cLiga       := SB1->B1_XGRLIGA
	cVariante   := SB1->B1_XVARIAN
	cBitola     := SB1->B1_XBITOLA
	nCompri     := SB1->B1_XCOMPRI

	// 09/11/2026 FixSystem - Leonardo Barboza Ribeiro Leite: INC1833293 - fechar pelo X nao pode sucatar sem passar pela validar()
	_lRet := .F.
	DEFINE MSDIALOG oDlg TITLE "Sucatar Embalagem "+Funname() FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL
	@ 006, 010 SAY oSay1 PROMPT "Liga" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 005, 040 MSGET oLiga VAR cLiga SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.
	@ 006, 080 SAY oSay1 PROMPT "Variante" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 005, 110 MSGET oVariante VAR cVariante SIZE 010, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.
	@ 006, 140 SAY oSay1 PROMPT "Bitola (pol)" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 005, 170 MSGET oBitola VAR cBitola SIZE 010, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.
	@ 006, 200 SAY oSay1 PROMPT "Comprimento (mm)" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 005, 260 MSGET oCompri VAR nCompri SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.

	@ 020, 010 SAY oSay1 PROMPT "Lote" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 020, 040 MSGET oLote VAR cLote SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.

	@ 040, 010 SAY oSay1 PROMPT "Qtde Lote (kgs)" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 060 MSGET oPcsLote VAR nPcsLote SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "9999" When .F.
	@ 040, 110 SAY oSay1 PROMPT "Qtde Lote (kgs)" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 160 MSGET oPesoLote VAR nPesoLote SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999.99" When .F.

	@ 060, 010 SAY oSay1 PROMPT "Pecas Sucatadas (pcs)" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 060, 060 MSGET oQtdePcs VAR nQtdePcs SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999" Valid(nPesoCons := nQtdePcs * nPesoLote/nPcsLote,oPesoCons:Refresh())
	@ 060, 110 SAY oSay1 PROMPT "Peso Sucatado (kgs)" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 060, 160 MSGET oPesoCons VAR nPesoCons SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999.99" When .F.

	@ 080, 010 SAY oSay1 PROMPT "Motivo Rej." SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 079, 060 MSCOMBOBOX oMotRej VAR cMotRej ITEMS aMotRej SIZE 145, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 100, 060 BUTTON oButton2 PROMPT "Sucatar" SIZE 037, 012 OF oDlg PIXEL Action(Validar())
	@ 100, 200 BUTTON oButton2 PROMPT "Cancelar" SIZE 037, 012 OF oDlg PIXEL Action(_lRet:= .F.,oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED


	// 11/11/2026 FixSystem: INC1833293 - so segue com motivo que exista na tabela Z2
	cMotRej := codMotivo(cMotRej, aMotRej)
	If !_lRet .Or. Empty(cMotRej)
		Return
	EndIf

	// If !FwinputBox("Confirme a lote a ser sucatado","") == cLote
	//     FwalertError("Confirmacao de lote invalida!!!","Confirmacao de lote")
	//     Return
	// EndIf
	If !FWAlertYesNo("Confirma o sucateamento de "+cValToChar(nQtdePcs)+" pecas do lote "+cLote+" selecionado??","Sucateamento")
		Return
	EndIf

	Begin Transaction

		// 11/11/2026 FixSystem: INC1833293 - sem motivo gravado na SD3 o sucateamento e desfeito
		cDocRE := NextNumero("SD3", 2, "D3_DOC", .T.)
		nRecIni := ultimoRecSD3()
		If !MTA241(_cTmRE0,cCodOrigem,cLocOrigem,nPesoCons,nQtdePcs,"",cLote,cDocRE)
			DisarmTransaction()   // Desfaz a transação em caso de erro
			Return
		EndIf
		If !gravaMotivo(nRecIni, _cTmRE0, cCodOrigem, cLocOrigem, cDocRE, cMotRej)
			DisarmTransaction()
			Return
		EndIf
		cDocDE := NextNumero("SD3", 2, "D3_DOC", .T.)
		nRecIni := ultimoRecSD3()
		If !MTA241(_cTmDE0,cCodDestino,cLocDestino,nPesoCons,nQtdePcs,"","",cDocDE)
			DisarmTransaction()   // Desfaz a transação em caso de erro
			Return
		EndIf
		If !gravaMotivo(nRecIni, _cTmDE0, cCodDestino, cLocDestino, cDocDE, cMotRej)
			DisarmTransaction()
			Return
		EndIf
	End Transaction
	fwAlertSuccess("Sucateamento realizado com sucesso!!!","Sucateamento")
	// u_tEnvMail('lucas@fixsystem.com.br',"Apontamento de producao - Serra","Apontamento realizado pela op",{})

Return


Static Function MTA241(_cParTM,_cParCod,_cParLocal,_nParQt1um,_nParQt2um,_cParOp,_cParLote,_cParDoc)
	Local _aCab1 := {}       // Array para o cabeçalho do movimento
	Local _aItem := {}       // Array para os itens do movimento
	Local _atotitem := {}    // Array para agrupar todos os itens
	Local cErro
	// Variáveis para controle de execução automática
	Private lMsHelpAuto := .T. // Se .T., exibe mensagens de help
	Private lMsErroAuto := .F. // Se .F., não exibe erros automáticos
	// Prepara o ambiente (empresa, filial e módulo)
	// Prepare Environment Empresa "T1" Filial "D MG 01" Modulo "EST"
	// Monta o cabeçalho do movimento
	// {"D3_DOC", NextNumero("SD3", 2, "D3_DOC", .T.), NIL},; // Número do documento (gerado automaticamente)
	dData := dDataBase

	// INC1833293 - o documento vem de quem chama, para o gravaMotivo localizar o movimento
	If Empty(_cParDoc)
		_cParDoc := NextNumero("SD3", 2, "D3_DOC", .T.)
	EndIf
	_aCab1 := {}
	aadd(_aCab1,{"D3_DOC", _cParDoc, NIL})  // Número do documento (gerado automaticamente)
	aadd(_aCab1,{"D3_TM", _cParTM, NIL})                            // Tipo de movimento
	aadd(_aCab1,{"D3_CC", "        ", NIL})                           // Centro de custo (vazio)
	aadd(_aCab1,{"D3_EMISSAO", dData, NIL})                        // Data de emissão (data atual)

	// Monta os itens do movimento
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+_cParCod)
	_aItem := {}
	AADD(_aItem,{"D3_COD", _cParCod, NIL})   // Código do produto
	AADD(_aItem,{"D3_UM", SB1->B1_UM, NIL})       // Unidade de medida
	AADD(_aItem,{"D3_QUANT", _nParQt1um, NIL})     // Quantidade do item (1.99)
	AADD(_aItem,{"D3_QTSEGUM", _nParQt2um, NIL})     // Quantidade do item (1.99)
	AADD(_aItem,{"D3_LOCAL", _cParLocal, NIL})     // Local de estoque
	If !Empty(_cParLote)
		AADD(_aItem,{"D3_LOTECTL", _cParLote, NIL})     // Local de estoque
	EndIf
	// AADD(_aItem,{"D3_OP", _cParOp, NIL})        // Custo do item

	// Adiciona o item ao array de itens
	aAdd(_atotitem, _aItem)
	// Executa a rotina de inclusão de movimento (MATA241)
	// Certifique-se de que _aCab1 e _atotitem são arrays válidos
	lMsErroAuto := .F.
	If ValType(_aCab1) == "A" .AND. ValType(_atotitem) == "A"
		MSExecAuto({|x, y, z| MATA241(x, y, z)}, _aCab1, _atotitem, 3)
	Else
		MessageBox("Erro: Arrays inválidos para execução automática.", "Erro",16)
		Return .F.
	EndIf
	// Verifica se houve erro na execução automática
	If lMsErroAuto
		cErro := MostraErro('\dirdoc\','error.log')          // Exibe mensagem de erro
		DisarmTransaction()   // Desfaz a transação em caso de erro
		Showlog(cErro)
		// Break                // Interrompe a execução
		Return .F.
	EndIf
Return .T.


Static Function MTA250(cOpProd,cProdApt,nQtdOp,lEstorno)
	Local aVetor
	Local dData
	Local nOpc := 3 //-Opção de execução da rotina,
	Local cOp := ""
	Local cCod := ""
	Local _lRet := .F.
	Local cTmPad := SuperGetMv("MV_TMPAD",.F.,"010")
	//prepare environment empresa "99" filial "01" modulo "est"
	Private lMsErroAuto := .F.
	aVetor := {}
	// dDataBase:=_dDtDigit
	SC2->(DbSetOrder(1))
	If SC2->(DbSeek(xFilial("SC2")+cOpProd))
		cOp := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
		cCod := SC2->C2_PRODUTO
		aVetor := {}
		AADD(aVetor,{"D3_OP" ,cOp ,NIL})
		AADD(aVetor,{"D3_COD" ,cCod,NIL})
		AADD(aVetor,{"D3_QUANT" ,nPesoCons,NIL})
		AADD(aVetor,{"D3_QTSEGUM" ,nQtdePcs,NIL})
		AADD(aVetor,{"D3_TM" ,cTmPad,NIL})
		// AADD(aVetor,{"D3_XCODSZ2" ,_cCodSZ2,NIL})
		// {"D3_LOTECTL" ,_cLote,NIL}}
		lMsErroAuto := .F.
		MSExecAuto({|x, y| mata250(x, y)},aVetor, 3 )

		If lMsErroAuto
			CONOUT("Erro")
			mostraerro()
			_lRet := .F.
		Else
			_lRet := .T.
			CONOUT("Incluido com sucesso")
		Endif
	Else
		MsgStop("Op não localizada!!!","Atenção")
		_lRet := .F.
	Endif
return _lRet

// 09/11/2026 FixSystem - Leonardo Barboza Ribeiro Leite: INC1833293 - motivo de rejeicao obrigatorio
Static Function validar()

	If nQtdePcs > nPcsLote
		FwalertError("Quantidade de pecas superior ao saldo disponivel em estoque!!!","Quantidade invalida")
		_lRet := .F.
		// Return
	ElseIf nQtdePcs<= 0
		FwalertError("Quantidade de pecas menor ou igual a zero invalida!!!","Quantidade invalida")
		_lRet := .F.
		// Return
	ElseIf Empty(codMotivo(cMotRej, aMotRej))
		FwalertError("Selecione o motivo de rejeicao no campo Motivo Rej.","Motivo de rejeicao")
		_lRet := .F.
	Else
		_lRet := .T.
		oDlg:End()
	EndIf

Return

/*/{Protheus.doc} carregaMotivos
Monta os itens do combo de motivo de rejeicao do sucateamento a partir da tabela generica Z2 (SX5).
@type     Static Function
@author   FixSystem - Leonardo Barboza Ribeiro Leite
@since    09/11/2026
@version  1.0
@return   Array, itens no formato "chave=descricao", com o primeiro item em branco
@obs      INC1833293. Mesma regra do serra.prw e do sucataEmbalagem.prw.
/*/
Static Function carregaMotivos()
	Local aRet := {Space(2) + "=Selecione o motivo"}
	Local aSX5 := FWGetSX5(_cTabRej)
	Local nX   := 0

	For nX := 1 To Len(aSX5)
		aAdd(aRet, Padr(AllTrim(aSX5[nX][3]), 2) + "=" + AllTrim(aSX5[nX][4]))
	Next nX
Return aRet

/*/{Protheus.doc} gravaMotivo
Grava o motivo de rejeicao nos movimentos internos (SD3) que o MATA241 acabou de incluir.
@type     Static Function
@author   FixSystem - Leonardo Barboza Ribeiro Leite
@since    09/11/2026
@version  1.2
@param    nRecIni, Numeric, maior R_E_C_N_O_ da SD3 antes do MATA241 (ver ultimoRecSD3)
@param    cTM, Character, tipo de movimento usado no MATA241
@param    cCod, Character, produto do movimento
@param    cLocal, Character, armazem do movimento
@param    cDoc, Character, documento enviado ao MATA241 (usado so na mensagem de erro)
@param    cMotivo, Character, codigo do motivo (tabela Z2)
@return   Logical, .T. quando o motivo foi gravado em pelo menos um movimento
@obs      INC1833293. Chamada dentro da transacao, logo apos o MTA241. Retorno .F. faz o sucateamento ser desfeito (motivo obrigatorio).
          18/11/2026 FixSystem: o movimento passa a ser localizado pelos registros gravados apos nRecIni (TM, produto e armazem),
          e nao mais pelo D3_DOC, porque o MATA241 pode gravar o movimento com outro numero de documento.
/*/
Static Function gravaMotivo(nRecIni, cTM, cCod, cLocal, cDoc, cMotivo)
	Local aArea     := GetArea()
	Local aAreaSD3  := SD3->(GetArea())
	Local cAliasQry := GetNextAlias()
	Local cQuery    := ""
	Local lRet      := .F.

	If SD3->(FieldPos("D3_XMOTREJ")) == 0
		FwAlertError("Campo D3_XMOTREJ nao existe na tabela SD3. Sucateamento nao realizado.","Motivo de rejeicao")
		RestArea(aAreaSD3)
		RestArea(aArea)
		Return .F.
	EndIf

	cQuery := "SELECT R_E_C_N_O_ AS RECSD3 "
	cQuery += "  FROM " + RetSqlName("SD3")
	cQuery += " WHERE D3_FILIAL  = '" + xFilial("SD3") + "'"
	cQuery += "   AND R_E_C_N_O_ > " + cValToChar(nRecIni)
	cQuery += "   AND D3_TM      = '" + cTM + "'"
	cQuery += "   AND D3_COD     = '" + cCod + "'"
	cQuery += "   AND D3_LOCAL   = '" + cLocal + "'"
	cQuery += "   AND D3_ESTORNO <> 'S'"
	cQuery += "   AND D_E_L_E_T_ = ' '"
	TCQuery cQuery New Alias (cAliasQry)

	While !(cAliasQry)->(Eof())
		SD3->(DbGoTo((cAliasQry)->RECSD3))
		If !SD3->(Eof())
			RecLock("SD3", .F.)
			SD3->D3_XMOTREJ := cMotivo
			SD3->(MsUnlock())
			lRet := .T.
		EndIf
		(cAliasQry)->(DbSkip())
	EndDo
	(cAliasQry)->(DbCloseArea())

	If !lRet
		FwAlertError("Movimento do documento " + AllTrim(cDoc) + " (TM " + cTM + ", produto " + AllTrim(cCod) + ") nao localizado para gravar o motivo de rejeicao. Sucateamento nao realizado.","Motivo de rejeicao")
	EndIf

	RestArea(aAreaSD3)
	RestArea(aArea)
Return lRet

/*/{Protheus.doc} ultimoRecSD3
Devolve o maior R_E_C_N_O_ da SD3, para o gravaMotivo localizar so os movimentos incluidos depois.
@type     Static Function
@author   FixSystem
@since    18/11/2026
@version  1.0
@return   Numeric, maior R_E_C_N_O_ da SD3 (0 quando a tabela esta vazia)
@obs      INC1833293.
/*/
Static Function ultimoRecSD3()
	Local cAliasQry := GetNextAlias()
	Local cQuery    := "SELECT MAX(R_E_C_N_O_) AS MAXREC FROM " + RetSqlName("SD3")
	Local nRec      := 0

	TCQuery cQuery New Alias (cAliasQry)
	If !(cAliasQry)->(Eof())
		nRec := (cAliasQry)->MAXREC
	EndIf
	(cAliasQry)->(DbCloseArea())

	If ValType(nRec) <> "N"
		nRec := 0
	EndIf
Return nRec

/*/{Protheus.doc} codMotivo
Devolve o codigo do motivo de rejeicao escolhido no combo, ou vazio quando nada valido foi escolhido.
@type     Static Function
@author   FixSystem
@since    11/11/2026
@version  1.0
@param    cVar, Character, conteudo da variavel ligada ao combo
@param    aItens, Array, itens do combo no formato "chave=descricao" (o primeiro e o "Selecione o motivo")
@return   Character, codigo do motivo (tabela Z2) ou "" quando nao selecionado
@obs      INC1833293. Nao confia so no Empty() da variavel: confere se o codigo existe de fato na lista de motivos.
/*/
Static Function codMotivo(cVar, aItens)
	Local cCod := AllTrim(cValToChar(cVar))
	Local nPos := 0

	If "=" $ cCod
		cCod := AllTrim(SubStr(cCod, 1, At("=", cCod) - 1))
	EndIf
	If Empty(cCod)
		Return ""
	EndIf

	nPos := aScan(aItens, {|x| AllTrim(SubStr(x, 1, At("=", x) - 1)) == cCod})
	If nPos <= 1
		Return ""
	EndIf
Return cCod
