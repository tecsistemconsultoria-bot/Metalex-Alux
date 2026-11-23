#Include "totvs.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
#Include "RPTDef.ch"
#Include "FWPrintSetup.ch"
#Define PAD_LEFT    0
#Define PAD_RIGHT   1
#Define PAD_CENTER  2

//Cores
#Define COR_CINZA   RGB(180, 180, 180)
#Define COR_PRETO   RGB(000, 000, 000)
#Define COR_AZUL    RGB( 0, 0, 128 )
#Define _crlf Chr(13)+Chr(10)

User Function RRECC001()
	Local cFiltro := ""
	LOCAL cAlias := "SZ0"
	LOCAL aCores  := {}
	PRIVATE cCadastro := "CheckList"
	PRIVATE aRotina     := {}

	// ajusteSZ0()

	AADD(aCores,{ 'SZ0->Z0_STATUS=="A"' , 'ENABLE'  })    // Ativo
	AADD(aCores,{ 'SZ0->Z0_STATUS=="P"' , 'BR_AMARELO' })    // Inativo
	AADD(aCores,{ 'SZ0->Z0_STATUS=="F"' , 'BR_VERDE' })    // Inativo

	AADD(aRotina, { "Pesquisar" , "AxPesqui", 0, 1 })
	AADD(aRotina, { "Visualizar", "AxVisual"  , 0, 2 })
	AADD(aRotina, { "Incluir"   , "U_checkSz0(1)"   , 0, 3 })
	AADD(aRotina, { "Alterar"   , "U_checkSz0(2)"   , 0, 4 })
	AADD(aRotina, { "Relacionar NFE"   	, "U_REC001NFE()"   , 0, 4 })
	AADD(aRotina, { "Tickets Relacionados"   , "U_REC001SZ2()"   , 0, 4 })
	AADD(aRotina, { "Fechamento"   , "U_REC001FIM()"   , 0, 4 })
	aadd(aRotina, { "Relatorio de Portaria" ,"U_RRECR001", 0 , 2, 0 , Nil})
	If __cUserID $ SuperGetMV("MX_USRADM",.T.,"000000")
		AADD(aRotina, { "AxAltera"   , "AxAltera"  , 0, 4 })
	EndIf
	AADD(aRotina, { "Excluir"    , "U_AXDELSZ0()" , 0, 5 })

	dbSelectArea(cAlias)
	dbSetOrder(1)

	DbSelectArea("SZO")
	DbSelectArea("SZP")

	mBrowse(6, 1, 22, 75, cAlias,,,,,,aCores,,,,,,,,cFiltro)
Return

User Function AXDELSZ0

	DbSelectArea("SZ4")
	DbSetOrder(1)
	If DbSeek(xFilial("SZ4")+SZ0->Z0_COD)
		FwalertInfo("Ha notas vinculadas a esse checklist!! Solicite exclusao","Exclusao de checklist")
		Return
	EndIf
	DbSelectArea("SZ2")
	DbSetOrder(3)
	If !DbSeek(xFilial("SZ2")+SZ0->Z0_COD)
		If FWAlertYesNo("Confirma exclusao do checklist?","Confirmacao de exclusao")
			// AxDeleta('SZ0', SZ0->(Recno()), 5)
			Reclock("SZ0",.F.)
			DBDelete()
			MsUnlock()
		EndIf
	Else
		FwalertInfo("Checklist nao pode ser excluido, pois ha ticket vinculado!!!","Exclusao de checklist")
	EndIf
Return

User Function zdebugrec()
	MsApp():New('SIGACOM')    //Cria o MsApp
	oApp:CreateEnv()
	PtSetTheme("OCEAN")    //Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
	oApp:cStartProg    := 'u_RRECC001()' //Define o programa que será executado após o login
	__lInternet := .T.    //Seta Atributos
	oApp:Activate()    //Inicia a Janela
Return Nil

User Function checkSz0(_nOpc)

	Local oSay1
	Local oSay2
	Local oSay3
	Private oBtnSalvar
	Private oCodigo
	Private oPlaca
	Private oCpf
	Private oCodDA4
	Private oNome
	Private cCodSZ0 := Space(6) //Space(TamSX3("Z0_COD")[1])
	Private cNome := Space(100) //Space(TamSX3("Z0_COD")[1])
	Private cPlaca := Space(8)
	Private cCpf := Space(11)
	Private cCodDA4 := Space(6)
	Private cNomDA4 := ""
	Private oCalco
	Private nCalco := 0
	Private oGetSZ1
	Private oDlgCheck
	Private oFinalidade
	Private cFinalidade := "R"
	Private cSucata := Space(40)

	If _nOpc == 1
		cCodSZ0 := GetSXENUM("SZ0","Z0_COD")
		Confirmsx8()
	Else
		DbSelectArea("SZ0")
		cCodSZ0 := SZ0->Z0_COD
		cCpf    := SZ0->Z0_CPF
		cCodDA4 := SZ0->Z0_CODDA4
		cNomDA4 := SZ0->Z0_NOMMOTR
		cPlaca  := SZ0->Z0_PLACA
		nCalco  := SZ0->Z0_CALCO
		cFinalidade := SZ0->Z0_TIPO 
		cSucata  := SZ0->Z0_NOMSUCA
	EndIf

	DEFINE MSDIALOG oDlgCheck TITLE "Checklist" FROM 000, 000  TO 650, 950 COLORS 0, 16777215 PIXEL
	@ 010, 004 SAY oSay1 PROMPT "Checklist" SIZE 025, 007 OF oDlgCheck COLORS 0, 16777215 PIXEL
	@ 009, 035 MSGET oCodigo VAR cCodSZ0 F3 "SZ0" SIZE 060, 010 OF oDlgCheck COLORS 0, 16777215 PIXEL when .F.
	@ 010, 100 SAY oSay1 PROMPT "Finalidade:" SIZE 035, 007 OF oDlgCheck COLORS 0, 16777215 PIXEL
	@ 009, 135 MSCOMBOBOX oFinalidade VAR cFinalidade ITEMS {"C=Coleta","R=Recebimento","A=Almoxarifado","G=CGM","E=Residuo","I=Interna,D=Devolucao"} SIZE 50, 010 OF oDlgCheck COLORS 0, 16777215 PIXEL
	@ 025, 004 SAY oSay2 PROMPT "Placa:" SIZE 025, 007 OF oDlgCheck COLORS 0, 16777215 PIXEL
	@ 024, 035 MSGET oPlaca VAR cPlaca SIZE 060, 010 OF oDlgCheck COLORS 0, 16777215 PIXEL Valid(validaPlaca()) PICTURE "@!R XXX-9X99"
	@ 025, 100 SAY oSay2 PROMPT "Calco:" SIZE 025, 007 OF oDlgCheck COLORS 0, 16777215 PIXEL
	@ 024, 135 MSGET oCalco VAR nCalco SIZE 060, 010 OF oDlgCheck COLORS 0, 16777215 PIXEL PICTURE "99"
	@ 010, 200 SAY oSay2 PROMPT "Nome Sucateiro:" SIZE 045, 010 OF oDlgCheck COLORS 0, 16777215 PIXEL
	@ 008, 245 MSGET oSucata VAR cSucata SIZE 080, 010 OF oDlgCheck COLORS 0, 16777215 PIXEL

	@ 040, 004 SAY oSay3 PROMPT "CPF:" SIZE 025, 007 OF oDlgCheck COLORS 0, 16777215 PIXEL
	@ 039, 035 MSGET oCpf VAR cCpf SIZE 060, 010 OF oDlgCheck COLORS 0, 16777215 PIXEL Valid (validaCpf())
	@ 040, 100 SAY oSay3 PROMPT "Codigo:" SIZE 025, 007 OF oDlgCheck COLORS 0, 16777215 PIXEL
	@ 039, 135 MSGET oCodDA4 VAR cCodDA4 SIZE 030, 010 OF oDlgCheck COLORS 0, 16777215 PIXEL When .F.
	@ 040, 180 SAY oSay3 PROMPT "Nome:" SIZE 025, 007 OF oDlgCheck COLORS 0, 16777215 PIXEL
	@ 039, 215 MSGET oNome VAR cNomDA4 SIZE 80, 010 OF oDlgCheck COLORS 0, 16777215 PIXEL When .F.

	@ 060, 004 BUTTON oBtnSalvar PROMPT "&Salvar" SIZE 072, 025 OF oDlgCheck PIXEL Action (salvarChecklist(.F.))
	@ 060, 084 BUTTON oBtnSalvar PROMPT "Salvar todos &como Sim" SIZE 072, 025 OF oDlgCheck PIXEL Action (salvarChecklist(.T.))
	@ 010, 400 BUTTON oBtnSalvar PROMPT "&Fechar" SIZE 075, 015 OF oDlgCheck PIXEL Action (oDlgCheck:End())
	@ 030, 400 BUTTON oBtnSalvar PROMPT "&Motoristas" SIZE 075, 015 OF oDlgCheck PIXEL Action (OMSA040())
	@ 050, 400 BUTTON oBtnSalvar PROMPT "&Veiculos" SIZE 075, 015 OF oDlgCheck PIXEL Action (OMSA060())
	fGetSZ1(_nOpc)
	ACTIVATE MSDIALOG oDlgCheck CENTERED

Return
//------------------------------------------------
Static Function fGetSZ1(_nOpc)
	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"Z1_CODQUES","Z1_QUESTAO","Z1_RESP"}
	Local aAlterFields := {"Z1_RESP"}
	Local _aQuestoes := {}

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	If _nOpc == 1
		AADD(_aQuestoes,{"01","O freio de serviço está funcionando? (Relato do motorista e verificação visual"})
		AADD(_aQuestoes,{"02","As luzes externas estão funcionando? (FAROL BAIXO, FREIO, SETAS E LUZ DE FREIO"})
		AADD(_aQuestoes,{"03","O freio estacionário está funcionando? (relato do motorista e verificação visual"})
		AADD(_aQuestoes,{"04","O caminhão está sem vazamentos? (combustível, óleo, água ou lubrificante"})
		AADD(_aQuestoes,{"05","O cinto de segurança está travado e bem ajustado?"})
		AADD(_aQuestoes,{"06","Os retrovisores estão fixados, ajustados e com o espelho em boas condições?"})
		AADD(_aQuestoes,{"07","As trancas ou travas das portas e caçambas estão fechando e travando corretamente?"})
		AADD(_aQuestoes,{"08","A sirene de ré está funcionando? Foi testada? Está com som perceptível?"})
		AADD(_aQuestoes,{"09","Os pneus estão em condições de uso? (sem cortes profundos, deformação e não aparecendo lona"})
		AADD(_aQuestoes,{"10","A buzina está funcionando?"})
		AADD(_aQuestoes,{"11","O motorista está portando os EPI's obrigatórios? (calçado de segurança c/ biqueira, capacete com jugular, óculos de segurança, colete refletivo e luvas)?"})
		AADD(_aQuestoes,{"12","Todos os equipamentos rotativos estão protegidos? Acessos bloqueados?"})
		AADD(_aQuestoes,{"13","A guarda e assoalho estão em boas condições? (Pino de travamento, articulação da guarda"})
		AADD(_aQuestoes,{"14","O estribo e alças de apoio estão em boas condições? (Bem fixadas e sem avarias"})
		AADD(_aQuestoes,{"15","O cartão de integração de segurança está válido? (Prazo de um ano"})
		AADD(_aQuestoes,{"16","As rodas estão bem fixadas (com todos os parafusos)?"})
		AADD(_aQuestoes,{"17","O caminhão está provido de calços de segurança conforme o padrão mínimo das dimensões?"})
		AADD(_aQuestoes,{"18","Calços posicionados no eixo mais pesado?"})
		AADD(_aQuestoes,{"19","Eixo dianteiro articulado posicionado em direção a mureta?"})
		AADD(_aQuestoes,{"20","As dobradiças e encaixes / engates G laterais das carrocerias estão bem fixados e em boas condições (sem deformações)>"})
		// DbSelectArea("SX5")
		// DbSetOrder(1)
		// If DbSeek(xFilial("SX5")+"Z0")
		//     While !SX5->(Eof()) .and. SX5->X5_TABELA == "Z0"
		//         AADD(_aQuestoes,{Alltrim(SX5->X5_CHAVE),ALLTRIM(SX5->X5_DESCRI)})
		//         SX5->(DbSkip())
		//     EndDo
		// EndIf
		// Define field properties

		// Define field values
		For nX := 1 to Len(_aQuestoes)
			aFieldFill := {}
			Aadd(aFieldFill, _aQuestoes[nX,1])
			Aadd(aFieldFill, _aQuestoes[nX,2])
			Aadd(aFieldFill, "N")
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
		Next nX
	Else
		DbSelectArea("SZ1")
		DbSetOrder(1)
		If DbSeek(xFilial("SZ1")+cCodSZ0)
			While !SZ1->(Eof()) .and. cCodSZ0 == SZ1->Z1_CODSZ0
				aFieldFill := {}
				Aadd(aFieldFill, SZ1->Z1_CODQUES)
				Aadd(aFieldFill, SZ1->Z1_QUESTAO)
				Aadd(aFieldFill, SZ1->Z1_RESP)
				Aadd(aFieldFill, .F.)
				Aadd(aColsEx, aFieldFill)
				SZ1->(DbSkip())
			EndDo
		EndIf
	EndIf

	oGetSZ1 := MsNewGetDados():New( 090, 007, 300, 460, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgCheck, aHeaderEx, aColsEx)

Return

Static Function validaCpf()
	If Empty(cCpf)
		cNome := ""
		cCodDA4 := ""
	Else
		DbSelectArea("DA4")
		DbSetOrder(3)
		If !DbSeek(xFilial("DA4")+Padr(cCpf,TamSX3("DA4_CGC")[1]))
			cNome := ""
			cCodDA4 := ""
			MessageBox("CPF nao localizado!!","Validacao de CPF",0)
			Return .F.
		Else
			cCodDA4 := DA4->DA4_COD
			cNome   := DA4->DA4_NOME
		EndIf
	EndIf
	oNome:Refresh()

Return .T.

Static Function validaPlaca()
	If Empty(cPlaca)
		Return .T.
	EndIf

	DbSelectArea("DA3")
	DbSetOrder(3)
	If !DbSeek(xFilial("DA3")+Padr(cPlaca,TamSX3("DA3_PLACA")[1]))
		MessageBox("Placa nao encontrada!! Solicite cadastramento.","Validacao de veiculo",2)
		Return .F.
	EndIf

Return .T.


Static Function salvarChecklist(_lAprovado)
	Local _cCodQues := ""
	Local _x
	Local _lOk := .T.
	If Empty(cCodSZ0)
		MessageBox("Checklist nao informado!!","Erro",0)
		Return
	EndIf
	If Empty(cCpf)
		MessageBox("CPF nao informado!!","Erro",0)
		oCpf:setFocus()
		Return
	EndIf
	If Empty(cPlaca)
		MessageBox("Placa nao informada!!","Erro",0)
		oPlaca:setFocus()
		Return
	EndIf
	Begin Transaction
		For _x := 1 to len(oGetSZ1:aCols)
			_cCodQues := GdFieldGet("Z1_CODQUES",_x,,oGetSZ1:aHeader,oGetSZ1:aCols)
			_cQuestao := GdFieldGet("Z1_QUESTAO",_x,,oGetSZ1:aHeader,oGetSZ1:aCols)
			If _lAprovado
				_cResp    := "S"
			Else
				_cResp    := GdFieldGet("Z1_RESP",_x,,oGetSZ1:aHeader,oGetSZ1:aCols)
			EndIf
			DbSelectArea("SZ1")
			DbSetOrder(1)
			If DbSeek(xFilial("SZ1")+cCodSZ0+_cCodQues)
				Reclock("SZ1",.F.)
			Else
				Reclock("SZ1",.T.)
			EndIf
			SZ1->Z1_FILIAL  := xFilial("SZ1")
			SZ1->Z1_CODSZ0  := cCodSZ0
			SZ1->Z1_CODQUES := _cCodQues
			SZ1->Z1_QUESTAO := _cQuestao
			SZ1->Z1_RESP    := _cResp
			MsUnlock()
			If _cResp # "S"
				_lOk := .F.
			EndIf
		Next
		DbSelectArea("SZ0")
		DbSetOrder(1)
		If DbSeek(xFilial("SZ0")+cCodSZ0)
			Reclock("SZ0",.F.)
			cCodTicket := SZ0->Z0_TICKET
			If Empty(SZ0->Z0_TICKET)
				If _lOk .and. cFinalidade == "C"
					cCodTicket := gerarTicket("C")
				Else
					cCodTicket := ""
				EndIf
			EndIf
		Else
			If _lOk .and. cFinalidade == "C"
				cCodTicket := gerarTicket("C")
			Else
				cCodTicket := ""
			EndIf
			Reclock("SZ0",.T.)
			SZ0->Z0_EMISSAO := Date()
			SZ0->Z0_HORA    := Time()
		EndIf
		SZ0->Z0_FILIAL  := XfILIAL("SZ0")
		SZ0->Z0_COD     := cCodSZ0
		SZ0->Z0_PLACA   := cPlaca
		SZ0->Z0_CALCO   := nCalco
		SZ0->Z0_NOMSUCA := cSucata
		SZ0->Z0_CPF     := cCpf
		SZ0->Z0_CODDA4  := cCodDA4
		SZ0->Z0_NOMMOTR := cNomDA4
		SZ0->Z0_TIPO    := cFinalidade
		SZ0->Z0_TICKET  := cCodTicket
		If _lOk
			SZ0->Z0_STATUS  := "A"
		Else
			SZ0->Z0_STATUS  := "P"
		EndIf
		MsUnlock()

		If !_lOk
			MessageBox("Checklist gravado com pendencias!!","Gravacao de checklist",0)
		Else
			If cFinalidade == "C"
				fwAlertInfo("Checklist gravado com sucesso!!! Ticket: "+cCodTicket+".","Gravacao de checklist")
			Else
				fwAlertInfo("Checklist gravado com sucesso!!!","Gravacao de checklist")
			EndIf
		EndIf
		oDlgCheck:End()
	End Transaction
Return

Static Function changeGet(oGet)
	Local _x
	nPosAtu := oGet:nAt
	For _x := 1 to Len(oGet:aCols)
		GdFieldPut("XX_OK","",_x,oGet:aHeader,oGet:aCols)
	Next
	GdFieldPut("XX_OK","==>",oGet:nAt,oGet:aHeader,oGet:aCols)
	oGet:Refresh()
Return


User Function REC001NFE()

	Local oSay1
	Local oSay2
	Local oSay3
	Private oBtnSalvar
	Private oCodigo
	Private oPlaca
	Private oVeiculo
	Private oCpf
	Private oCodDA4
	Private oNome
	Private oChave
	Private cCodSZ0 := "000002" //Space(6) //Space(TamSX3("Z0_COD")[1])
	Private cPlaca := space(8)
	Private cVeiculo := "        "
	Private cCpf := Space(11)
	Private cNome := Space(10)
	Private cChave := Space(44)
	Private oGetSZ4XML
	Private oDlgNfe
	// Private _aCfopCom := SuperGetMV("MV_CFOPCOM","5101;5102;6101;6102")
	// Private _aCfopRem := SuperGetMV("MV_CFOPREM","5124;6124")
	Private _cTesCeOr  := "007" //SuperGetMV("MV_TESCOE","007")
	// Private _cTesRemS  := SuperGetMV("MV_TESREMS","008")
	Private _cTesRemI  := space(3)//"015" //SuperGetMV("MV_TESREMI","015")

	// RPCSetType(3)
	// Prepare Environment Empresa "99" Filial '01' Tables "SA1","SF2" Modulo "FIN"

	IF SZ0->Z0_TIPO == "C"
		FWAlertError("Checklist com finalidade de Coleta nao precisa relacionar NFE!!","Relacionar NFE")
		Return
	EndIf

	cCodSZ0 := SZ0->Z0_COD
	cCpf    := SZ0->Z0_CPF
	cCodDA4 := SZ0->Z0_CODDA4
	cNomDA4 := SZ0->Z0_NOMMOTR
	cPlaca  := SZ0->Z0_PLACA


	DEFINE MSDIALOG oDlgNfe TITLE "Checklist de Veiculo" FROM 000, 000  TO 800, 1600 COLORS 0, 16777215 PIXEL

	@ 010, 004 SAY oSay1 PROMPT "Checklist" SIZE 025, 007 OF oDlgNfe COLORS 0, 16777215 PIXEL
	@ 009, 035 MSGET oCodigo VAR cCodSZ0 F3 "SZ0" SIZE 060, 010 OF oDlgNfe COLORS 0, 16777215 PIXEL when .F.
	@ 025, 004 SAY oSay2 PROMPT "Placa:" SIZE 025, 007 OF oDlgNfe COLORS 0, 16777215 PIXEL
	@ 024, 035 MSGET oPlaca VAR cPlaca SIZE 060, 010 OF oDlgNfe COLORS 0, 16777215 PIXEL When .F.
	@ 025, 104 SAY oSay2 PROMPT "Veiculo:" SIZE 025, 007 OF oDlgNfe COLORS 0, 16777215 PIXEL
	@ 024, 135 MSGET oVeiculo VAR cVeiculo SIZE 060, 010 OF oDlgNfe COLORS 0, 16777215 PIXEL When .F.
	@ 040, 004 SAY oSay3 PROMPT "CPF:" SIZE 025, 007 OF oDlgNfe COLORS 0, 16777215 PIXEL
	@ 039, 035 MSGET oCpf VAR cCpf SIZE 060, 010 OF oDlgNfe COLORS 0, 16777215 PIXEL When .F.
	@ 040, 104 SAY oSay3 PROMPT "Nome:" SIZE 025, 007 OF oDlgNfe COLORS 0, 16777215 PIXEL
	@ 039, 135 MSGET oNome VAR cNome SIZE 100, 010 OF oDlgNfe COLORS 0, 16777215 PIXEL When .F.
	@ 055, 004 SAY oSay3 PROMPT "Chave/NF:" SIZE 025, 007 OF oDlgNfe COLORS 0, 16777215 PIXEL
	@ 054, 035 MSGET oChave VAR cChave SIZE 100, 010 OF oDlgNfe COLORS 0, 16777215 PIXEL Valid(validaChave())
	@ 010, 240 BUTTON oBtnSalvar PROMPT "&Gravar Chaves" SIZE 050, 025 OF oDlgNfe PIXEL Action (gravarChaves())
	@ 040, 240 BUTTON oBtnSalvar PROMPT "&Gerar Tickets" SIZE 050, 025 OF oDlgNfe PIXEL Action (gerarTicket("R"),oDlgNfe:End())
	@ 010, 330 BUTTON oBtnSalvar PROMPT "&Fechar" SIZE 052, 012 OF oDlgNfe PIXEL Action (oDlgNfe:End())
	fGetSZ4XML()

	ACTIVATE MSDIALOG oDlgNfe CENTERED

Return

Static Function fGetSZ4XML()
	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"Z4_CHAVE","Z4_OPER","Z4_EMISSAO","Z4_PSBXML","Z4_PSLXML","Z4_CNPJ","Z4_DOC","Z4_SERIE","Z4_CLIFOR","Z4_LOJA","Z4_NOME","Z4_TICKET","Z4_VLRNF","Z4_QTDENF"}
	Local aAlterFields := {}
	Local _x := 0
	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	// Define field values
	DbSelectArea("SZ4")
	DbSetOrder(1)
	If DbSeek(xFilial("SZ4")+cCodSZ0)
		While !SZ4->(Eof()) .AND. SZ4->Z4_CODSZ0 == cCodSZ0
			aFieldFill := {}
			For _x := 1 to Len(aFields)
				_cCpo := aFields[_x]
				Aadd(aFieldFill, SZ4->&(_cCpo))
			Next
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			SZ4->(DbSkip())
		EndDo

	Else
		aFieldFill := {}
		For _x := 1 to Len(aFields)
			_cCpo := aFields[_x]
			Aadd(aFieldFill, Criavar(_cCpo))
		Next
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	EndIf
	oGetSZ4XML := MsNewGetDados():New( 090, 007, 384, 800, GD_UPDATE+GD_DELETE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgNfe, aHeaderEx, aColsEx)

Return

User Function REC001FIM()

	Local oSay1
	Local oSay2
	Local oSay3
	Private oGetSZ2NF
	Private oGetSZ4NF
	Private oGetSD1
	Private oBtnSalvar
	Private oCodigo
	Private oPlaca
	Private oVeiculo
	Private oCpf
	Private oCodDA4
	Private oNome
	Private oChave
	Private cCodSZ0 := "000002" //Space(6) //Space(TamSX3("Z0_COD")[1])
	Private cPlaca := space(8)
	Private cVeiculo := "        "
	Private cCpf := Space(11)
	Private cNome := Space(10)
	Private cChave := Space(44)
	Private oGetSZ4NF
	Private dData := ddatabase
	Private oData
	Private oQtdeNF
	Private _nQtdeNF := 0
	Private oQtdeClass
	Private oDiferenca
	Private _nDiferenca := 0
	Private _nQtdeClass := 0
	Private oDlgFechamento
	Private oTesRemI
	Private oInformacao
	Private cInformacao := ""
	Private aTamanho  := MsAdvSize()
	Private nJanLarg    := aTamanho[5]
	Private nJanAltu    := aTamanho[6]
	Private _cTesRemI  := space(3)//"015" //SuperGetMV("MV_TESREMI","015")
	Private oDocumentos
	Private cDocumentos := ""
	// RPCSetType(3)
	// Prepare Environment Empresa "99" Filial '01' Tables "SA1","SF2" Modulo "FIN"

	If !SZ0->Z0_TIPO == "R"
		FwalertInfo("Somente checklist do tipo recebimento pode usar a rotina de fechamento!!!","Fechamento de checklist")
		Return
	EndIf
	cCodSZ0 := SZ0->Z0_COD
	cCpf    := SZ0->Z0_CPF
	cVeiculo := SZ0->Z0_CODDA4
	cNome 	:= SZ0->Z0_NOMMOTR
	cPlaca  := SZ0->Z0_PLACA
	cDocumentos := SZ0->Z0_DOCS
	cParceiro := SZ0->Z0_NOME


	DEFINE MSDIALOG oDlgFechamento TITLE "Fechamento Checklist" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	oDlgFechamento:lMaximized := .T.
	@ 010, 004 SAY oSay1 PROMPT "Checklist" SIZE 025, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 009, 035 MSGET oCodigo VAR cCodSZ0 F3 "SZ0" SIZE 060, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL when .F.
	@ 010, 104 SAY oSay1 PROMPT "Data" SIZE 025, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 009, 135 MSGET oData VAR dData SIZE 060, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL when .F.
	@ 025, 004 SAY oSay2 PROMPT "Placa:" SIZE 025, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 024, 035 MSGET oPlaca VAR cPlaca SIZE 060, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL When .F.
	@ 025, 104 SAY oSay2 PROMPT "Veiculo:" SIZE 025, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 024, 135 MSGET oVeiculo VAR cVeiculo SIZE 060, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL When .F.
	@ 040, 004 SAY oSay3 PROMPT "CPF:" SIZE 025, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 039, 035 MSGET oCpf VAR cCpf SIZE 060, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL When .F.
	@ 040, 104 SAY oSay3 PROMPT "Nome:" SIZE 025, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 039, 135 MSGET oNome VAR cNome SIZE 100, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL When .F.
	@ 040, 270 SAY oSay3 PROMPT "Documentos:" SIZE 025, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 039, 300 MSGET oDocumentos VAR cDocumentos SIZE 100, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL readonly
	@ 040, 410 SAY oSay3 PROMPT "Cliente/Fornecedor:" SIZE 025, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 039, 450 MSGET oParceiro VAR cParceiro SIZE 100, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL readonly
	@ 055, 004 SAY oSay3 PROMPT "Qtde NF:" SIZE 065, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 054, 070 MSGET oQtdeNF VAR _nQtdeNF SIZE 50, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL When .F. Picture "@E 999,999.99"
	@ 055, 134 SAY oSay3 PROMPT "Qtde Classificacao:" SIZE 065, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 054, 200 MSGET oQtdeClass VAR _nQtdeClass SIZE 50, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL When .F. Picture "@E 999,999.99"
	@ 055, 270 SAY oSay3 PROMPT "Diferenca:" SIZE 065, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 054, 300 MSGET oDiferenca VAR _nDiferenca SIZE 50, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL When .F. Picture "@E 999,999.99"
	@ 055, 470 SAY oSay3 PROMPT "TES Remessa:" SIZE 065, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 054, 534 MSGET oTesRemI VAR _cTesRemI SIZE 50, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL F3 "SF4"
	@ 070, 010 SAY oSay3 PROMPT "Materiais Encontrados:" SIZE 065, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	fGetSZ2F()
	@ 155, 010 SAY oSay3 PROMPT "Notas relacionadas:" SIZE 065, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	fGetSZ4F()
	@ 255, 010 SAY oSay3 PROMPT "Escrituracao estimada:" SIZE 065, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 255, 080 MSGET oInformacao VAR cInformacao SIZE 200, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL READONLY
	@ 255, 340 BUTTON oBtnSalvar PROMPT "&Vincular PC" SIZE 050, 012 OF oDlgFechamento PIXEL Action (vincularPC())
	fGetSD1()
	@ 010, 204 BUTTON oBtnSalvar PROMPT "&Gerar NFE" SIZE 072, 025 OF oDlgFechamento PIXEL Action (Processa({||gerarNFE(),"Escriturando notas... Aguarde!!!"})) WHEN !SZ0->Z0_STATUS  == "F"
	@ 010, 304 BUTTON oBtnSalvar PROMPT "&Excluir NFE" SIZE 072, 012 OF oDlgFechamento PIXEL Action (Processa({||ExcluirNfe(),"Escriturando notas... Aguarde!!!"})) WHEN SZ0->Z0_STATUS  == "F"
	@ 010, 404 BUTTON oBtnSalvar PROMPT "&Fechar" SIZE 072, 012 OF oDlgFechamento PIXEL Action (oDlgFechamento:End())
	@ 025, 404 BUTTON oBtnImprime PROMPT "&Imprimir" SIZE 072, 012 OF oDlgFechamento PIXEL Action (msgrun("Gerando comunicado","Aguarde...",{||impComunicado()}))
	ACTIVATE MSDIALOG oDlgFechamento CENTERED

Return

Static Function ExcluirNfe()
	Local _x
	Local cNumDoc     := "M103CTELA"

	Local nOpc      := 5
	Local aCab      := {}
	Local aItens     := {}
	Local aLinha     := {}
	Private lMsErroAuto := .F.
	Private lMsHelpAuto     := .T.
	Private lAutoErrNoFile  := .T.

	If !FWAlertYesNo("Confirma exclusao da nota fiscal??","Exclusao de NF")
		Return
	EndIf

	Begin Transaction
		For _x := 1 to Len(oGetSZ4NF:aCols)
			_cChave := GdFieldGet("Z4_CHAVE",_x,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)
			DbSelectArea("SZ4")
			DbSetOrder(2)
			If !DbSeek(xFilial("SZ4")+_cChave)
				FwalertInfo("Chave nao localizada na amarracao!!!","Exclusao de NF")
				DisarmTransaction()
				Return
			EndIf
			DbSelectArea("SF1")
			SF1->(DbSetOrder(8))
			If !SF1->(DbSeek(xFilial("SF1") + _cChave  ))
				FwalertInfo("Documento nao localizado!!!","Exclusao de NF")
				DisarmTransaction()
				Return
			EndIf
			aCab      := {}
			aadd(aCab,{"F1_TIPO" ,      SF1->F1_TIPO ,NIL})
			aadd(aCab,{"F1_FORMUL" ,    SF1->F1_FORMUL ,NIL})
			aadd(aCab,{"F1_DOC" ,       SF1->F1_DOC,NIL})
			aadd(aCab,{"F1_SERIE" ,     SF1->F1_SERIE ,NIL})
			aadd(aCab,{"F1_EMISSAO" ,   SF1->F1_EMISSAO,NIL})
			aadd(aCab,{"F1_DTDIGIT" ,   SF1->F1_DTDIGIT,NIL})
			aadd(aCab,{"F1_FORNECE" ,   SF1->F1_FORNECE ,NIL})
			aadd(aCab,{"F1_LOJA" ,      SF1->F1_LOJA ,NIL})
			aadd(aCab,{"F1_ESPECIE" ,   SF1->F1_ESPECIE ,NIL})

			dbSelectArea("SD1")
			SD1->(dbSetOrder(1))
			SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
			aItens     := {}
			While !Eof() .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == ;
					SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
				If !Empty(SD1->D1_XOPUPDC)
					FwalertInfo("Update cost já realizado!!! Solicite exclusao para prosseguir.","Exclusao de NF")
					DisarmTransaction()
					Return
				EndIf
				DbSelectArea("SB2")
				DbSetOrder(1)
				If DbSeek(xFilial("SB2")+SD1->D1_COD+SD1->D1_LOCAL)
					If SB2->B2_QATU < SD1->D1_QUANT
						FwalertInfo("Saldo em estoque insuficiente para exclusao!!!","Exclusao de NF")
						DisarmTransaction()
						Return
					EndIf
				EndIf
				aItens := {}
				aAdd(aItens,{'D1_DOC',SD1->D1_DOC       ,NIL})
				aAdd(aItens,{'D1_SERIE',SD1->D1_SERIE   ,NIL})
				aAdd(aItens,{'D1_FORNECE',SD1->D1_FORNECE,NIL})
				aAdd(aItens,{'D1_LOJA',SD1->D1_LOJA     ,NIL})
				aadd(aItens,{"D1_ITEM",SD1->D1_ITEM     ,NIL})
				aadd(aItens,{"D1_COD" ,SD1->D1_COD      ,NIL})
				aadd(aItens,{"D1_UM"  ,SD1->D1_UM       ,NIL})
				aadd(aItens,{"D1_LOCAL",SD1->D1_LOCAL   ,NIL})
				aadd(aItens,{"D1_QUANT",SD1->D1_QUANT   ,NIL})
				aadd(aItens,{"D1_VUNIT",SD1->D1_VUNIT   ,NIL})
				aadd(aItens,{"D1_TOTAL",SD1->D1_TOTAL   ,NIL})
				aadd(aItens,{"D1_TES"  ,SD1->D1_TES     ,NIL})
				aAdd(aLinha,aItens)
				SD1->(dbSkip())
			EndDo
			lMsErroAuto := .F.
			MSExecAuto({|x,y,z,b,a| MATA103(x,y,z,b,,,,,,,,,,,a)},aCab,aLinha,nOpc,.T.,)
			If lMsErroAuto
				cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
				DisarmTransaction()
				showlog(cError)
				Return
			Else
				DbSelectArea("SF1")
				SF1->(DbSetOrder(8))
				If SF1->(DbSeek(xFilial("SF1") + _cChave  ))
					FwalertInfo("Documento nao excluido!!!","Exclusao de NF")
					DisarmTransaction()
					Return
				EndIf
				Reclock("SZ4",.F.)
				SZ4->Z4_TICKET := ""
				MsUnLock()
			EndIf
		Next
		For _x := 1 to Len(oGetSZ2NF:aCols)
			_cCodSZ2 := GdFieldGet("Z2_COD",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols)
			DbSelectArea("SZ2");DbSetOrder(1)
			If DbSeek(xFilial("SZ2")+_cCodSZ2)
				// Reclock("SZ2",.F.)
				// // SZ2->Z2_STATUS := ""
				// MsUnlock()
			EndIf
		Next
		DbSelectArea("SZ0")
		DbSetOrder(1)
		If DbSeek(xFilial("SZ0")+cCodSZ0)
			Reclock("SZ0",.f.)
			SZ0->Z0_STATUS := "A"
			MsUnLock()
		EndIf
	End Transaction
	fwAlertSuccess("Documentos excluidos com sucesso!!!","Exclusao de documentos")

Return
Static Function fGetSD1()
	//------------------------------------------------
	Local nX
	Local _x
	Local _y
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"D1_DOC","D1_SERIE","D1_ITEM","D1_COD","D1_QUANT","D1_XSLDTIC","D1_VUNIT","Z4_CHAVE","D1_FORNECE","D1_LOJA","D1_EMISSAO","D1_XCODSZ2","D1_PEDIDO","D1_ITEMPC"}
	Local aAlterFields := {}
	Static oGetSD1

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	// Define field values
	For nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)

	_nQtdDev := 0
	_nPendente := 0
	aColsSD1 := {}
	For _x := 1 to Len(oGetSZ2NF:aCols)
		_nQtdSZ2 := GdFieldGet("Z2_PESOL",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols)//-GdFieldGet("Z2_PESOEMB",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols)
		For _y := 1 to Len(oGetSZ4NF:aCols)
			_nSaldoSZ4 := GdFieldGet("XX_SALDO",_y,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)
			_nZ4QTDNF := GdFieldGet("Z4_QTDENF",_y,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)
			If _nSaldoSZ4 <= 0
				Loop
			EndIf
			If _nQtdSZ2 < _nSaldoSZ4
				If GdFieldGet("Z4_CLIFOR",_y,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols) $ "000918/004750"
					_nDif := _nSaldoSZ4-_nQtdSZ2
					If _nDif/_nZ4QTDNF <= 0.005
						// _nQtdSZ2 := _nSaldoSZ4
					EndIf
				Else
					If _nSaldoSZ4-_nQtdSZ2 <= 20
						// _nQtdSZ2 := _nSaldoSZ4
					EndIf
				EndIf
				_nSaldoSZ4 -= _nQtdSZ2
				_nQtdFim := _nQtdSZ2
				_nQtdSZ2 := 0
			Else
				_nQtdFim := _nSaldoSZ4
				_nQtdSZ2 -= _nQtdFim
				_nSaldoSZ4  := 0
			EndIf
			GdFieldPut("XX_SALDO",_nSaldoSZ4,_y,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)
			_aLinha := {}
			AADD(_aLinha,GdFieldGet("Z4_DOC",_y,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols))
			AADD(_aLinha,GdFieldGet("Z4_SERIE",_y,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols))
			AADD(_aLinha,StrZero(_x,4))
			AADD(_aLinha,GdFieldGet("Z2_PRODUTO",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols))
			AADD(_aLinha,_nQtdFim)
			AADD(_aLinha,_nQtdSZ2)
			_nVunitNF := GdFieldGet("Z4_VLRNF",_y,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)/GdFieldGet("Z4_QTDENF",_y,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)
			AADD(_aLinha,_nVunitNF)
			AADD(_aLinha,GdFieldGet("Z4_CHAVE",_y,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols))
			AADD(_aLinha,GdFieldGet("Z4_CLIFOR",_y,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols))
			AADD(_aLinha,GdFieldGet("Z4_LOJA",_y,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols))
			AADD(_aLinha,GdFieldGet("Z4_EMISSAO",_y,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols))
			AADD(_aLinha,GdFieldGet("Z2_COD",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols))
			AADD(_aLinha,"")
			AADD(_aLinha,"")
			AADD(_aLinha,.F.)
			AADD(aColsSD1,_aLinha)
			If _nQtdSZ2 == 0
				exit
			EndIf
		Next
	Next

	If Len(aColsSD1) > 0
		aColsEx := AClone(aColsSD1)
	EndIf
	oGetSD1 := MsNewGetDados():New( 270, 006, 350, nJanLarg/2-25, /*GD_INSERT+*/GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgFechamento, aHeaderEx, aColsEx)

	cInformacao := "Escrituracao estimada gerada automaticamente."
	_nDiferenca := _nQtdeClass - _nQtdeNF
	oDiferenca:Refresh()

	_lDentroTol := .F.
	If GdFieldGet("Z4_CLIFOR",len(oGetSZ4NF:aCols),,oGetSZ4NF:aHeader,oGetSZ4NF:aCols) $ "000918/004750"
		If Abs(_nDiferenca/_nQtdeNF) <= 0.005
			_lDentroTol := .T.
		EndIf
	Else
		If Abs(_nDiferenca) <= 20
			_lDentroTol := .T.
		EndIf
	EndIf

	If _lDentroTol .and. _nDiferenca < 0
		_nQtdSD1 := GdFieldGet("D1_QUANT",Len(oGetSD1:aCols),,oGetSD1:aHeader,oGetSD1:aCols) - _nDiferenca
		GdFieldPut("D1_QUANT",_nQtdSD1,Len(oGetSD1:aCols),oGetSD1:aHeader,oGetSD1:aCols)
		GdFieldPut("D1_XSLDTIC",0,Len(oGetSD1:aCols),oGetSD1:aHeader,oGetSD1:aCols)
		cInformacao := "Ajuste automatico de diferenca dentro 0,5% ou 20kgs."
	EndIf
	oInformacao:Refresh()
Return


Static Function consultaSF1()

	DEFINE MSDIALOG oDlgSF1 TITLE "Consulta Fechamentos" FROM 000, 000  TO 750, 1500 COLORS 0, 16777215 PIXEL
	@ 010, 004 SAY oSay1 PROMPT "Checklist" SIZE 025, 007 OF oDlgFechamento COLORS 0, 16777215 PIXEL
	@ 009, 035 MSGET oCodigo VAR cCodSZ0 F3 "SZ0" SIZE 060, 010 OF oDlgFechamento COLORS 0, 16777215 PIXEL when .F.
	fGetSF1()

	ACTIVATE MSDIALOG oDlgSF1 CENTERED

Return

Static Function fGetSZ2F()
	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"Z2_STATUS","Z2_COD","Z2_PRODUTO","Z2_DESCRI","Z2_PESOI","Z2_PESOF","Z2_PESOEMB","Z2_PESOL","XX_PESO","Z2_PEDIDO","Z2_ITEMPC","Z2_DTPSI","Z2_HRPSI","Z2_DTPSF","Z2_HRPSF"}
	Local aAlterFields := {}

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Else
			Aadd(aHeaderEx, {"Peso Final","XX_PESO","@E 999,999.99",12,2,"","","N","","","",""})
		Endif
	Next nX

	// Define field values

	cQry := "SELECT * "
	cQry += "FROM SZ2010 SZ2 "
	cQry += "WHERE SZ2.D_E_L_E_T_='' AND Z2_CODSZ0='"+cCodSZ0+"' AND Z2_FILIAL='"+cFilAnt+"' "
	cQry += "ORDER BY Z2_PRODUTO DESC "

	TcQuery cQry New Alias "SZ2X"
	TCSetField("SZ2X","Z2_DTPSI","D")
	TCSetField("SZ2X","Z2_DTPSF","D")
	If !SZ2X->(Eof())
		While !SZ2X->(Eof())
			// If SZ2->Z2_STATUS # "5"
			aFieldFill := {}
			Aadd(aFieldFill, SZ2X->Z2_STATUS)
			Aadd(aFieldFill, SZ2X->Z2_COD)
			// Aadd(aFieldFill, SZ2X->Z2_PARTICI)
			Aadd(aFieldFill, SZ2X->Z2_PRODUTO)
			Aadd(aFieldFill, SZ2X->Z2_DESCRI)
			Aadd(aFieldFill, SZ2X->Z2_PESOI)
			Aadd(aFieldFill, SZ2X->Z2_PESOF)
			Aadd(aFieldFill, SZ2X->Z2_PESOEMB)
			Aadd(aFieldFill, abs(SZ2X->Z2_PESOL)-SZ2X->Z2_PESOEMB)
			Aadd(aFieldFill, 0)
			Aadd(aFieldFill, SZ2X->Z2_PEDIDO)
			Aadd(aFieldFill, SZ2X->Z2_ITEMPC)
			Aadd(aFieldFill, SZ2X->Z2_DTPSI)
			Aadd(aFieldFill, SZ2X->Z2_HRPSI)
			Aadd(aFieldFill, SZ2X->Z2_DTPSF)
			Aadd(aFieldFill, SZ2X->Z2_HRPSF)
			Aadd(aFieldFill, .F.)
			Aadd(aColsEx, aFieldFill)
			_nQtdeClass += Abs(SZ2X->Z2_PESOL)-SZ2X->Z2_PESOEMB
			// EndIf
			SZ2X->(DbSkip())
		EndDo
	EndIf
	SZ2X->(DbCloseArea())
	If Len(aColsEx) == 0
		aFieldFill := {}
		Aadd(aFieldFill, "")
		Aadd(aFieldFill, "")
		Aadd(aFieldFill, "")
		Aadd(aFieldFill, 0)
		Aadd(aFieldFill, 0)
		Aadd(aFieldFill, 0)
		Aadd(aFieldFill, 0)
		Aadd(aFieldFill, 0)
		Aadd(aFieldFill, "")
		Aadd(aFieldFill, "")
		Aadd(aFieldFill, STOD(''))
		Aadd(aFieldFill, '')
		Aadd(aFieldFill, STOD(''))
		Aadd(aFieldFill, '')
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	EndIf
	oGetSZ2NF := MsNewGetDados():New( 080, 004, 150, nJanLarg/2-25, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgFechamento, aHeaderEx, aColsEx)


Return

Static Function fGetSZ4F()
	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"Z4_RATEIO","Z4_CHAVE","Z4_OPER","Z4_EMISSAO","Z4_PSBXML","Z4_PSLXML","Z4_CNPJ","Z4_DOC","Z4_SERIE","Z4_CLIFOR","Z4_LOJA","Z4_NOME","Z4_TICKET","Z4_VLRNF","Z4_QTDENF","XX_SALDO"}
	Local aAlterFields := {}
	Local _x := 0
	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Else
			Aadd(aHeaderEx, {"Peso Final","XX_SALDO","@E 999,999.99",12,2,"","","N","","","",""})
		Endif
	Next nX

	// Define field values
	_nPesoTotal := 0
	DbSelectArea("SZ4")
	DbSetOrder(1)
	If DbSeek(xFilial("SZ4")+cCodSZ0)
		While !SZ4->(Eof()) .AND. SZ4->Z4_CODSZ0 == cCodSZ0
			If !Empty(SZ4->Z4_CLIFOR)
				aFieldFill := {}
				For _x := 1 to Len(aFields)
					_cCpo := aFields[_x]
					If _cCpo == "XX_SALDO"
						Aadd(aFieldFill, SZ4->Z4_QTDENF)
					Else
						Aadd(aFieldFill, SZ4->&(_cCpo))
					EndIf
				Next
				Aadd(aFieldFill, .F.)
				Aadd(aColsEx, aFieldFill)
				_nPesoTotal += SZ4->Z4_PSLXML
				_nQtdeNF += SZ4->Z4_QTDENF
			EndIf
			SZ4->(DbSkip())
		EndDo

	EndIf
	If Len(aColsEx) == 0
		FwalertInfo("Nenhuma nota fiscal amarrada a este checklist via chave!!!","Fechamento de checklist")
		aFieldFill := {}
		For _x := 1 to Len(aFields)
			_cCpo := aFields[_x]
			If _cCpo == "XX_SALDO"
				Aadd(aFieldFill, 0)
			Else
				Aadd(aFieldFill, Criavar(_cCpo))
			EndIf
		Next
		Aadd(aFieldFill, .F.)
		Aadd(aColsEx, aFieldFill)
	EndIf
	oGetSZ4NF := MsNewGetDados():New( 175, 004, 250, nJanLarg/2-25, GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgFechamento, aHeaderEx, aColsEx)

	For _x := 1 to Len(oGetSZ4NF:aCols)
		_nPesoXML := GdFieldGet("Z4_QTDENF",_x,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)
		GdFieldPut("Z4_RATEIO",Round(_nPesoXML/_nQtdeNF*100,2),_x,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)
	Next
	_nDiferenca := _nQtdeClass - _nQtdeNF
	oDiferenca:Refresh()
Return

Static Function validaChave()
	Local aFieldFill
	Local cError   := ""
	Local cWarning := ""
	Local _cXml     := ""
	Local _x
	Private oDlgDocManual
	Private cDocManual := Space(9)
	Private cParceiro   := Space(60)
	Private _lRetDocManual := .F.
	If Empty(cChave)
		Return .T.
	EndIf

	DbSelectArea("SZ4")
	DbSetOrder(2)
	If DbSeek(xFilial("SZ4")+cChave)
		FwalertInfo("Chave ja informada no checklist "+SZ4->Z4_CODSZ0,"Validacao de chave")
		Return
	EndIf

	cQry := "SELECT CKO_CHVDOC CHAVE,R_E_C_N_O_ RECCKO " +_crlf
	cQry += "FROM CKOCOL CKO "+_crlf
	cQry += "WHERE CKO.D_E_L_E_T_='' "+_crlf
	cQry += "AND CKO_CHVDOC='"+cChave+"' "
	TcQuery cQry New Alias "CKOX"
	DbSelectArea("CKOX")
	If !CKOX->(Eof())
		DbSelectArea("CKO")
		DBGoTo(CKOX->RECCKO)
		_cXml := CKO->CKO_XMLRET
	Else
		CKOX->(DbCloseArea())
		DEFINE MSDIALOG oDlgDocManual TITLE "Documento Manual" FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL
		@ 010, 004 SAY oSay1 PROMPT "Chave nao localizada. voce pode informar o documento manualmente." SIZE 300, 007 OF oDlgDocManual COLORS 0, 16777215 PIXEL
		@ 025, 004 SAY oSay1 PROMPT "Documento" SIZE 025, 007 OF oDlgDocManual COLORS 0, 16777215 PIXEL
		@ 024, 050 MSGET oDocManual VAR cDocManual SIZE 060, 010 OF oDlgDocManual COLORS 0, 16777215 PIXEL
		@ 040, 004 SAY oSay1 PROMPT "Fornecedor/Cliente" SIZE 025, 007 OF oDlgDocManual COLORS 0, 16777215 PIXEL
		@ 039, 050 MSGET oParceiro VAR cParceiro SIZE 120, 010 OF oDlgDocManual COLORS 0, 16777215 PIXEL
		@ 055, 004 button oBtnSalvar PROMPT "&Salvar" SIZE 050, 012 OF oDlgDocManual PIXEL Action (Processa({||salvarDocManual()}),_lRetDocManual := .T.)
		ACTIVATE MSDIALOG oDlgDocManual CENTERED
		If _lRetDocManual
			oDlgNfe:End()
		EndIf
		Return
	EndIf
	CKOX->(DbCloseArea())

	oXml := XmlParser( _cXml, "_", @cError, @cWarning )
	If (oXml == NIL )
		MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
		Return
	Else
		If !oXml:_NFEPROC:_NFE:_INFNFE:_DEST:_CNPJ:TEXT == SM0->M0_CGC
			MessageBox("CNPJ de destino invalido!!","Validacao de cnpj",0)
			Return .F.
		EndIf
	Endif
	If aScan(oGetSZ4XML:aCols, {|x| AllTrim(x[1]) == Alltrim(cChave)})>0
		MessageBox("Chave ja existente!!","Leitura de chave",0)
		Return .F.
	Else
		_cCnpjEmit := OXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
		_cCliFor    := ""
		_cLoja      := ""
		If AT("CFOP>5901",_cXml) > 0 ;
				.or. AT("CFOP>6901",_cXml) > 0
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek(xFilial("SA1")+_cCnpjEmit)
				_cCliFor    := SA1->A1_COD
				_cLoja      := SA1->A1_LOJA
			Else
				MessageBox("Cliente de cnpj "+_cCnpjEmit+" nao cadastrado!!","Leitura de chave",0)
				Return .F.
			EndIf
		Else//If AT("CFOP>5101",_cXml) > 0 ;
				// .or. AT("CFOP>6101",_cXml) > 0;
				// .or. AT("CFOP>5102",_cXml) > 0;
				// .or. AT("CFOP>6102",_cXml) > 0;
				// .or. AT("CFOP>5124",_cXml) > 0;
				// .or. AT("CFOP>6124",_cXml) > 0;
				// .or. AT("CFOP>5924",_cXml) > 0;
				// .or. AT("CFOP>6924",_cXml) > 0
			DbSelectArea("SA2")
			DbSetOrder(3)
			If DbSeek(xFilial("SA2")+_cCnpjEmit)
				_cCliFor    := SA2->A2_COD
				_cLoja      := SA2->A2_LOJA
			Else
				MessageBox("Fornecedor de cnpj "+_cCnpjEmit+" nao cadastrado!!","Leitura de chave",0)
				Return .F.
			EndIf
			// Else
			// 	MessageBox("Operacao "+OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT+" nao mapeada!!","Leitura de chave",0)
			// 	Return .F.
		EndIf

		oDet := OXML:_NFEPROC:_NFE:_INFNFE:_DET
		oDet := IIf(ValType(oDet)=="O",{oDet},oDet)
		_nVlrTot := 0
		_nQtdTot := 0
		For _x := 1 to Len(oDet)
			_nVlrTot += Val(oDet[_x]:_PROD:_vProd:TEXT)
			If oDet[_x]:_PROD:_uCom:TEXT $ "TO,TL,TON"
				_nQtdTot += Val(oDet[_x]:_PROD:_qCom:TEXT)*1000
			Else
				_nQtdTot += Val(oDet[_x]:_PROD:_qCom:TEXT)
			EndIf
		Next
		aFieldFill := {}
		Aadd(aFieldFill, cChave)
		Aadd(aFieldFill, OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT) //oper
		Aadd(aFieldFill, STOD(REPLACE(SUBSTR(OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_dhEmi:TEXT,1,10),"-",""))) //emissao
		// Aadd(aFieldFill, val(OXML:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL:_PESOB:TEXT)) //peso bruto
		// Aadd(aFieldFill, val(OXML:_NFEPROC:_NFE:_INFNFE:_TRANSP:_VOL:_PESOL:TEXT)) //peso bruto
		Aadd(aFieldFill, _nQtdTot) //peso bruto
		Aadd(aFieldFill, _nQtdTot) //peso bruto
		Aadd(aFieldFill, OXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT) //peso bruto
		Aadd(aFieldFill, Strzero(val(OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NNF:TEXT),9)) //DOC
		Aadd(aFieldFill, OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_SERIE:TEXT) //SERIE
		Aadd(aFieldFill, _cCliFor) //clifor
		Aadd(aFieldFill, _cLoja) //loja
		Aadd(aFieldFill, OXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_XNOME:TEXT) //peso bruto
		Aadd(aFieldFill, "ticket") //peso bruto
		Aadd(aFieldFill, _nVlrTot) //peso bruto
		Aadd(aFieldFill, _nQtdTot) //peso bruto
		Aadd(aFieldFill, "") //peso bruto
		Aadd(aFieldFill, "") //peso bruto
		Aadd(aFieldFill, .F.)
		If Empty(oGetSZ4XML:aCols[1,1])
			oGetSZ4XML:aCols := {}
		EndIf
		Aadd(oGetSZ4XML:aCols, aFieldFill)
		oGetSZ4XML:Refresh()
		cChave := Space(44)
	EndIf
	oChave:Refresh()
Return .T.

static Function salvarDocManual()
	If Empty(cDocManual) .or. Empty(cParceiro)
		FwalertInfo("Preencha os campos para salvar o documento manualmente!!!","Documento manual")
		Return .F.
	Else
		Reclock("SZ4",.T.)
		SZ4->Z4_FILIAL 	:= xFilial("SZ4")
		SZ4->Z4_CODSZ0 	:= cCodSZ0
		SZ4->Z4_DOC		:= cDocManual
		SZ4->Z4_CHAVE	:= cDocManual
		SZ4->Z4_NOME 	:= cParceiro
		MsUnlock()
		Reclock("SZ0",.F.)
		SZ0->Z0_FILIAL 	:= xFilial("SZ4")
		SZ0->Z0_DOCS	:= cDocManual
		SZ0->Z0_NOME 	:= cParceiro
		MsUnlock()
		MessageBox("Documento salvo com sucesso!!!","Documento manual",0)
		oDlgDocManual:End()
		_lRetDocManual := .T.
	EndIf

return

Static Function gravarChaves()
	Local _x,_y
	Local _cChave
	Local _cDocs 	:= ""
	Local _cCliFor 	:= ""
	Local _cNome 	:= ""
	Local _cProduto := ""

	For _x := 1 to Len(oGetSZ4XML:aCols)
		_cChave 	:= GdFieldGet("Z4_CHAVE",_x,,oGetSZ4XML:aHeader,oGetSZ4XML:aCols)
		If !Empty(_cChave)
			_cDoc 		:= GdFieldGet("Z4_DOC",_x,,oGetSZ4XML:aHeader,oGetSZ4XML:aCols)
			_cCliFor 	:= GdFieldGet("Z4_CLIFOR",_x,,oGetSZ4XML:aHeader,oGetSZ4XML:aCols)
			_cNome 		:= GdFieldGet("Z4_NOME",_x,,oGetSZ4XML:aHeader,oGetSZ4XML:aCols)
			DbSelectArea("SZ4")
			DbSetOrder(1)
			If DbSeek(xFilial("SZ4")+cCodSZ0+_cChave)
				If oGetSZ4XML:aCols[_x,len(oGetSZ4XML:aHeader)+1]
					Reclock("SZ4",.F.)
					DBDelete()
					MsUnlock()
				Else
					Reclock("SZ4",.F.)
					For _y := 1 to len(oGetSZ4XML:aHeader)
						_cCpo := oGetSZ4XML:aHeader[_y,2]
						SZ4->&(_cCpo)   := GdFieldGet(_cCpo,_x,,oGetSZ4XML:aHeader,oGetSZ4XML:aCols)
					Next
					MsUnlock()
				EndIf
			Else
				Reclock("SZ4",.T.)
				SZ4->Z4_FILIAL  := xFilial("SZ4")
				SZ4->Z4_CODSZ0  := cCodSZ0
				For _y := 1 to len(oGetSZ4XML:aHeader)
					_cCpo := oGetSZ4XML:aHeader[_y,2]
					SZ4->&(_cCpo)   := GdFieldGet(_cCpo,_x,,oGetSZ4XML:aHeader,oGetSZ4XML:aCols)
				Next
				MsUnlock()
			EndIf
			If Empty(_cDocs)
				_cDocs    := _cDoc
			ElseIf !_cDoc $ _cDocs
				_cDocs    := Alltrim(_cDocs) + "," + Alltrim(_cDoc)
			EndIf
		EndIf
	Next
	DbSelectArea("SZ0")
	DbSetOrder(1)
	If DbSeek(xFilial("SZ0")+cCodSZ0)
		Reclock("SZ0",.F.)
		SZ0->Z0_NOME    := _cNome
		SZ0->Z0_CLIFOR  := _cCliFor
		SZ0->Z0_DOCS	:= _cDocs
		MsUnlock()
	EndIf
	MessageBox("Amarracao salva com sucesso!!!","Gravacao",0)
	oDlgNfe:End()
Return .T.

User Function REC001SZ2
	Private cCodSZ0 := SZ0->Z0_COD
	Private cCpf    := SZ0->Z0_CPF
	Private cCodDA4 := SZ0->Z0_CODDA4
	Private cNomDA4 := SZ0->Z0_NOMMOTR
	Private cPlaca  := SZ0->Z0_PLACA
	Private nCalco  := SZ0->Z0_CALCO
	Private cFinalidade := SZ0->Z0_TIPO
	Private cSucata := SZ0->Z0_NOMSUCA
	Private oGetTickets

	DEFINE MSDIALOG oDlg TITLE "Tickets" FROM 000, 000  TO 600, 1200 COLORS 0, 16777215 PIXEL
	IF SZ0->Z0_TIPO == "R"
		@ 005, 005 BUTTON oBtnVincular PROMPT "&Novo Ticket" SIZE 070, 012 OF oDlg PIXEL Action(Processa({||ticketAdicional(),"Vinculando Ticket a OS"}))
	EndIf
	@ 005, 105 BUTTON oBtnFechar PROMPT "&Fechar" SIZE 070, 012 OF oDlg PIXEL Action(oDlg:End())
	fGetTickets()
	fUpdTickets()
	ACTIVATE MSDIALOG oDlg CENTERED


Return

Static Function ticketAdicional()

	If SZ0->Z0_STATUS  == "F"
		FwalertInfo("Checklist ja encerrado!!! Selecione outro","Ticket adicional")
		Return
	EndIf
	gerarTicket("R")
	fUpdTickets()

Return

Static Function fGetSB8()
	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"B8_DATA","B8_LOTECTL","B1_XBITOLA","B1_XGRLIGA","B1_XVARIAN","H6_XCOMPRI","H6_QTDPROD","B8_SALDO","H6_QTDPRO2","B8_SALDO2","B8_PRODUTO"}
	Local aAlterFields := {}

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	// Define field values
	For nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)

	oGetSB8 := MsNewGetDados():New( 030, 004, 255, 480, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return
//------------------------------------------------
Static Function fGetTickets()
	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"XX_OK","Z2_COD","Z0_PLACA","Z2_STATUS","Z2_EMISSAO","Z2_HORA","Z2_PESOI","Z2_PESOF","Z2_PESOL","Z2_PESONF","Z2_PSBRUT","Z2_TRANSP","Z2_NOMESA4"}
	Local aAlterFields := {"Z2_TRANSP"}

	Aadd(aHeaderEx, {"SELECAO","XX_OK","@!",4,0,"","","C","","","",""})

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX
	Aadd(aHeaderEx, {"Volumes","XX_VOLUMES","@E 999,999",6,0,"","","N","","","",""})

	For nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		ElseIf Alltrim(aFields[nX]) == "XX_OK"
			Aadd(aFieldFill, "")
		Endif
	Next nX
	Aadd(aFieldFill, 0)
	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)
	oGetTickets := MsNewGetDados():New( 020, 005, 200, 600, /*GD_INSERT+GD_DELETE+*/GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,1, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
	// oGetTickets:BChange := {||changeSZ2()}
	// oGetTickets:oBrowse:lUseDefaultColors := .F.
	// oGetTickets:oBrowse:SetBlkBackColor({|| fCorTicket(oGetTickets:nAt)[1]})
	// oGetTickets:oBrowse:SetBlkColor({|| fCorTicket(oGetTickets:nAt)[2]})
	// fUpdSC2()
Return


Static Function fUpdTickets()
	Local _x
	Local _aLinha := {}

	cQry := "SELECT '' XX_OK,Z2_STATUS,Z2_COD,Z0_PLACA,Z2_EMISSAO,Z2_HORA,Z2_PESOI,Z2_PESOF,Z2_PESOL,Z2_TRANSP,Z2_NOMESA4,ISNULL(PESONF,0) Z2_PESONF,ISNULL(VOLUMES,0) XX_VOLUMES,ISNULL(PESO_BRUTO,0) Z2_PSBRUT "
	cQry += "FROM SZ2010 SZ2 "
	cQry += "   INNER JOIN SZ0010 SZ0 ON SZ0.D_E_L_E_T_='' AND Z0_COD=Z2_CODSZ0 AND Z2_FILIAL=Z0_FILIAL "
	cQry += "   LEFT JOIN (SELECT ZO_FILIAL,ZO_PLACA,ZO_CODSZ2,SUM(ZP_QUANT) PESONF,COUNT(*) VOLUMES,SUM(ISNULL(H6_XTARA,0)+ZP_QUANT) PESO_BRUTO "
	cQry += "       FROM SZO010 SZO "
	cQry += "           INNER JOIN SC6010 SC6 ON SC6.D_E_L_E_T_='' AND C6_FILIAL=ZO_FILIAL AND C6_NUM=ZO_PEDIDO AND C6_ITEM=ZO_ITEMPV "
	cQry += "           INNER JOIN SZP010 SZP ON SZP.D_E_L_E_T_='' AND ZP_FILIAL=ZO_FILIAL AND ZP_NUMOS=ZO_NUMOS "
	cQry += "           LEFT JOIN SH6010 SH6 ON SH6.D_E_L_E_T_='' AND H6_FILIAL=ZO_FILIAL AND H6_LOTECTL=ZP_LOTECTL AND H6_PRODUTO=ZP_COD "
	cQry += "       WHERE SZO.D_E_L_E_T_='' AND ZO_NF='' "
	cQry += "       GROUP BY ZO_FILIAL,ZO_PLACA,ZO_CODSZ2) OSS ON OSS.ZO_PLACA=Z2_PLACA AND OSS.ZO_CODSZ2=Z2_COD AND ZO_FILIAL=Z2_FILIAL "
	cQry += "WHERE SZ2.D_E_L_E_T_='' "
	cQry += "AND Z2_CODSZ0='"+SZ0->Z0_COD+"' "
	cQry += "AND Z2_FILIAL='"+SZ0->Z0_FILIAL+"' "
	// cQry += "AND NOT EXISTS (SELECT 1 FROM SZO010 SZO WHERE SZO.D_E_L_E_T_='' AND ZO_FILIAL=Z2_FILIAL AND Z2_COD=ZO_CODSZ2) "
	cQry += "ORDER BY Z2_COD DESC "
	TcQuery cQry New Alias "SZ2X"
	TCSetField("SZ2X","Z2_EMISSAO","D")
	DbSelectArea("SZ2X")
	DbGotop()
	_aStru := oGetTickets:aHeader
	If  !SZ2X->(Eof())
		oGetTickets:aCols := {}
		While !SZ2X->(Eof())
			_aLinha := {}
			For _x := 1 to len(_aStru)
				_cCpo := _aStru[_x,2]
				AADD(_aLinha,SZ2X->&(_cCpo))
			Next
			AADD(_aLinha,.F.)
			AADD(oGetTickets:aCols,_aLinha)
			SZ2X->(DbSkip())
		EndDo
	Else
		_aLinha := {}
		oGetTickets:aCols := {}
		For _x := 1 to len(_aStru)
			_cCpo := Alltrim(_aStru[_x,2])
			If _cCpo $ "Z2_COD" .or. substr(_cCpo,1,2) == "XX"
				AADD(_aLinha,"")
			Else
				AADD(_aLinha,criavar(_cCpo))
			EndIf
		Next
		AADD(_aLinha,.F.)
		AADD(oGetTickets:aCols,_aLinha)
	EndIf
	SZ2X->(DbCloseArea())
	oGetTickets:Refresh()
Return


Static Function gerarTicket(cFinalidade)
	Local cCodSZ2 := ""
	Local cTexto := ""
	If cFinalidade == "C"
		cTexto := "COLETA"
	Else
		cTexto := "RECEBIMENTO"
		If !FWAlertYesNo("Confirma geracao do ticket com a finalidade "+cTexto+"?","Tickets")
			Return
		EndIf
	EndIf
	// DbSelectArea("SZ4")
	// DbSetOrder(1)
	// If DbSeek(xFilial("SZ4")+cCodSZ0)
	// While !SZ4->(Eof()) .and. SZ2->Z2_CODSZ0 == cCodSZ0
	cCodSZ2 := GetSXENUM("SZ2","Z2_COD")
	ConfirmSX8()

	Reclock("SZ2",.T.)
	SZ2->Z2_FILIAL := xFilial("SZ2")
	SZ2->Z2_COD     := cCodSZ2
	SZ2->Z2_CODSZ0  := cCodSZ0
	SZ2->Z2_EMISSAO := date()
	SZ2->Z2_HORA    := time()
	SZ2->Z2_PLACA   := cPlaca
	SZ2->Z2_STATUS  := "1" //pesagem inicial
	If SZ2->(FIELDPOS("Z2_TPTICK"))> 0
		SZ2->Z2_TPTICK  := cFinalidade
	EndIf
	If cFinalidade == "C"
		SZ2->Z2_OBSEMB  := "COLETA"
	EndIf
	MsUnlock()
	
	If cFinalidade == "R" .And. SZ2->Z2_FILIAL <> '0202'

		fwAlertSuccess("Ticket "+cCodSZ2+" gerado com sucesso!!","Ticket")

		DbSelectArea("SZ2")
		SZ2->(DbGoTo(Recno()))

	EndIf

Return cCodSZ2

Static Function vincularPC()
	Private _cCodSZ2    := GdFieldGet("D1_XCODSZ2",oGetSD1:nAt,,oGetSD1:aHeader,oGetSD1:aCols)
	Private _cProdSZ2      := GdFieldGet("D1_COD",oGetSD1:nAt,,oGetSD1:aHeader,oGetSD1:aCols)
	Private oGetSC7
	DEFINE MSDIALOG oDlgSC7 TITLE "Pedidos de Compras" FROM 000, 000  TO 600, 1200 COLORS 0, 16777215 PIXEL
	@ 005, 005 BUTTON oBtnVincular PROMPT "&Selecionar" SIZE 070, 012 OF oDlgSC7 PIXEL Action(Processa({||selecionarSC7(),"Vinculando PC a NF"}))
	@ 005, 100 BUTTON oBtnFechar PROMPT "&Fechar" SIZE 070, 012 OF oDlgSC7 PIXEL Action(oDlgSC7:End())
	@ 005, 200 SAY oSay3 PROMPT "Ticket:" SIZE 065, 007 OF oDlgSC7 COLORS 0, 16777215 PIXEL
	@ 004, 250 MSGET oQtdeNF VAR _cCodSZ2 SIZE 100, 010 OF oDlgSC7 COLORS 0, 16777215 PIXEL When .F.
	fGetSC7()
	fUpdSC7()
	changeGet(@oGetSC7)
	ACTIVATE MSDIALOG oDlgSC7 CENTERED

Return

Static Function fGetSC7()
	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"XX_OK","C7_NUM","C7_ITEM","C7_PRODUTO","C7_DESCRI","C7_QUANT","C7_PRECO","C7_TOTAL","C7_EMISSAO","C7_DATPRF"}
	Local aAlterFields := {}


	Aadd(aHeaderEx, {"SELECAO","XX_OK","@!",4,0,"","","C","","","",""})
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			Aadd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	For nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		ElseIf Alltrim(aFields[nX]) == "XX_OK"
			Aadd(aFieldFill, "")
		Endif
	Next nX
	Aadd(aFieldFill, 0)
	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)
	oGetSC7 := MsNewGetDados():New( 020, 005, 200, 600, /*GD_INSERT+GD_DELETE+*/GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,1, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgSC7, aHeaderEx, aColsEx)
	oGetSC7:BChange := {||changeGet(@oGetSC7)}
	// oGetTickets:oBrowse:lUseDefaultColors := .F.
	// oGetTickets:oBrowse:SetBlkBackColor({|| fCorTicket(oGetTickets:nAt)[1]})
	// oGetTickets:oBrowse:SetBlkColor({|| fCorTicket(oGetTickets:nAt)[2]})
	// fUpdSC2()
Return

Static Function fUpdSC7()
	Local _x
	Local _aLinha := {}
	Local _cFornece := GdFieldGet("Z4_CLIFOR",oGetSZ4NF:nAt,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)
	cQry := "SELECT '' XX_OK,SC7.* "
	cQry += "FROM SC7010 SC7 "
	cQry += "WHERE SC7.D_E_L_E_T_='' "
	cQry += "AND C7_FILIAL='"+cFilAnt+"' "
	cQry += "AND C7_FORNECE='"+_cFornece+"' "
	cQry += "AND C7_PRODUTO='"+_cProdSZ2+"' "
	cQry += "AND C7_QUANT-C7_QUJE>0 AND C7_RESIDUO<>'S' "
	cQry += "ORDER BY C7_NUM DESC "
	TcQuery cQry New Alias "SC7X"
	TCSetField("SC7X","C7_EMISSAO","D")
	TCSetField("SC7X","C7_DATPRF","D")
	DbSelectArea("SC7X")
	DbGotop()
	_aStru := oGetSC7:aHeader
	If !SC7X->(Eof())
		oGetSC7:aCols := {}
		While !SC7X->(Eof())
			_aLinha := {}
			For _x := 1 to len(_aStru)
				_cCpo := _aStru[_x,2]
				AADD(_aLinha,SC7X->&(_cCpo))
			Next
			AADD(_aLinha,.F.)
			AADD(oGetSC7:aCols,_aLinha)
			SC7X->(DbSkip())
		EndDo
	Else
		_aLinha := {}
		oGetSC7:aCols := {}
		For _x := 1 to len(_aStru)
			_cCpo := Alltrim(_aStru[_x,2])
			If _cCpo $ "C7_NUM/XX_OK"
				AADD(_aLinha,"")
			Else
				AADD(_aLinha,criavar(_cCpo))
			EndIf
		Next
		AADD(_aLinha,.F.)
		AADD(oGetSC7:aCols,_aLinha)
	EndIf
	SC7X->(DbCloseArea())
	oGetSC7:Refresh()
Return

Static Function selecionarSC7

	Local _cC7_NUM := GdFieldGet("C7_NUM",oGetSC7:nAt,,oGetSC7:aHeader,oGetSC7:aCols)
	Local _cC7_ITEM := GdFieldGet("C7_ITEM",oGetSC7:nAt,,oGetSC7:aHeader,oGetSC7:aCols)

	If !FWAlertYesNo("Confirma vinculo do pedido de compra selecionado?","Vinculo de pedido")
		Return
	EndIf
	GdFieldPut("D1_PEDIDO",_cC7_NUM,oGetSD1:nAt,oGetSD1:aHeader,oGetSD1:aCols)
	GdFieldPut("D1_ITEMPC",_cC7_ITEM,oGetSD1:nAt,oGetSD1:aHeader,oGetSD1:aCols)
	_cChave := GdFieldGet("D1_XCODSZ2",oGetSD1:nAt,,oGetSD1:aHeader,oGetSD1:aCols)
	DbSelectArea("SZ2")
	DbSetOrder(1)
	If DbSeek(xFilial("SZ2")+_cCodSZ2)
		Reclock("SZ2",.f.)
		SZ2->Z2_PEDIDO      := _cC7_NUM
		SZ2->Z2_ITEMPC  := _cC7_ITEM
		MsUnLock()
	EndIf
	fwAlertInfo("Vinculo realizado com sucesso!!!","Vinculo de pedido")
	oGetSD1:Refresh()
	oDlgSC7:End()
Return

Static Function gerarNFE()
	Local cQry := ""
	Local oCab      := JsonObject():New()
	Local oItem     := JsonObject():New()
	Local oItens    := JsonObject():New()
	Local _aItens := {}
	Local _nXNF := 0
	Local _nXIT := 0
	Private aCols := oGetSD1:aCols
	Private aHeader := oGetSD1:aHeader

	// If _nQtdeClass > _nQtdeNF
	// 	MessageBox("Quantidade classificada superior ao total das notas relacionadas ao checklist!!! "+_crlf+;
		// 		"Confira os tickets, relacionamento das notas recebidas ou solicite NF complementar."+_crlf+;
		// 		"Os documentos serao escriturados com a quantidade da NF e constara no relatorio de fechamento do ticket a necessidade de nota complementar.";
		// 		,"Fechamento do checklist",0)
	// 	// Return
	// EndIf

	if !FWAlertYesNo("Confirma geracao da NF com o TES "+_cTesRemI+"?","Gerar NF")
		Return
	EndIf
	Begin Transaction
		_nXNF := 1
		While _nXNF <= Len(oGetSD1:aCols)
			// For _nXNF := 1 to Len(oGetSD1:aCols)
			n := _nXNF
			_cChave := GdFieldGet("Z4_CHAVE")
			_aItens := {}
			oCab    := JsonObject():New()
			oCab['documento']   := GdFieldGet("D1_DOC")
			oCab['serie']       := GdFieldGEt("D1_SERIE")
			oCab['chave']       := GdFieldGEt("Z4_CHAVE")
			oCab['fornecedor']  := GdFieldGEt("D1_FORNECE")
			oCab['loja']        := GdFieldGEt("D1_LOJA")
			oCab['emissao']     := GdFieldGEt("D1_EMISSAO")
			While _cChave == GdFieldGet("Z4_CHAVE")
				oItem    := JsonObject():New()
				oItem['produto']    := GdFieldGet("D1_COD")
				oItem['quantidade'] := GdFieldGet("D1_QUANT")
				oItem['qtd_ticket'] := GdFieldGet("D1_XSLDTIC")
				oItem['preco']      := GdFieldGEt("D1_VUNIT")
				oItem['total']      := Round(GdFieldGet("D1_QUANT")*GdFieldGEt("D1_VUNIT"),2)
				oItem['ticket']      := GdFieldGEt("D1_XCODSZ2")
				oItem['pedido']      := GdFieldGEt("D1_PEDIDO")
				oItem['item_pedido'] := GdFieldGEt("D1_ITEMPC")
				AADD(_aItens,oItem)
				n++
				_nXNF ++
				If n > len(oGetSD1:aCols)
					Exit
				EndIf
			EndDo
			If EXEC103(oCab,_aItens)
				DbSelectArea("SZ4")
				DbSetOrder(1)
				If DbSeek(xFilial("SZ4")+cCodSZ0+_cChave)
					Reclock("SZ4",.f.)
					SZ4->Z4_TICKET  := "OK"
					MsUnLock()
				EndIF
				DbSelectArea("SZ0")
				DbSetOrder(1)
				If DbSeek(xFilial("SZ0")+cCodSZ0)
					Reclock("SZ0",.f.)
					SZ0->Z0_STATUS  := "F"
					MsUnLock()
				EndIF
			Else
				DisarmTransaction()
				Return
			EndIf
		EndDo
	End Transaction
	oDlgFechamento:End()
	fwAlertSuccess("Notas escrituradas com sucesso!!","Fechamento CheckList")

Return

Static Function EXEC103(oCab,_aItens)

	Local aCab          := {}
	Local aItem         := {}
	Local aItens        := {}
	Local nOpc          := 3
	Local cNum          := ""
	Local nI            := 0
	Local nX            := 0
	Local nReg          := 1
	Local cInicio       := Time()
	Local cError        := ""
	Local cWarning      := ""
	Private lMsErroAuto := .F.
	Private lMsHelpAuto := .T.

	// PREPARE ENVIRONMENT EMPRESA "01" FILIAL "1001" MODULO "COM" FUNNAME "MATA103"
	SetFunname("MATA103")
	lMsErroAuto := .F.
	aCab := {}
	aItem := {}
	aItens := {}
	cChave := oCab['chave']
	cQry := "SELECT CKO_CHVDOC CHAVE,R_E_C_N_O_ RECCKO " +_crlf
	cQry += "FROM CKOCOL CKO "+_crlf
	cQry += "WHERE CKO.D_E_L_E_T_='' "+_crlf
	cQry += "AND CKO_CHVDOC='"+cChave+"' "
	TcQuery cQry New Alias "CKOX"
	DbSelectArea("CKOX")
	If !CKOX->(Eof())
		DbSelectArea("CKO")
		DBGoTo(CKOX->RECCKO)
		_cXml := CKO->CKO_XMLRET
	Else
		CKOX->(DbCloseArea())
		MessageBox("Chave nao localizado!!!","Validacao de chave",0)
		Return
	EndIf
	CKOX->(DbCloseArea())

	oXml := XmlParser( _cXml, "_", @cError, @cWarning )
	If (oXml == NIL )
		MsgStop("Falha ao gerar Objeto XML : "+cError+" / "+cWarning)
		Return
	Else
		_cCnpjEmit := OXML:_NFEPROC:_NFE:_INFNFE:_EMIT:_CNPJ:TEXT
		_cCliFor    := ""
		_cLoja      := ""
		_cTipoNF := ""
		_cTes   := ""
		_lPreNota := .F.
		//Remessa do cliente
		If AT("CFOP>5901",_cXml) > 0 ;
				.or. AT("CFOP>6901",_cXml) > 0;
				.or. AT("CFOP>5202",_cXml) > 0
			DbSelectArea("SA1")
			DbSetOrder(3)
			If DbSeek(xFilial("SA1")+_cCnpjEmit)
				_cCliFor    := SA1->A1_COD
				_cLoja      := SA1->A1_LOJA
				_cTipoNF := "B"
				_cTes   := "005"
			Else
				MessageBox("Cliente de cnpj "+_cCnpjEmit+" nao cadastrado!!","Leitura de chave",0)
				Return .F.
			EndIf
		//Compra
		ElseIf AT("CFOP>5101",_cXml) > 0 ;
				.or. AT("CFOP>6101",_cXml) > 0;
				.or. AT("CFOP>5102",_cXml) > 0;
				.or. AT("CFOP>6102",_cXml) > 0;				
				.or. AT("CFOP>5120",_cXml) > 0;
				.or. AT("CFOP>5923",_cXml) > 0
			DbSelectArea("SA2")
			DbSetOrder(3)
			If DbSeek(xFilial("SA2")+_cCnpjEmit)
				_cCliFor    := SA2->A2_COD
				_cLoja      := SA2->A2_LOJA
				_cTipoNF := "N"
				_cTes   := "003"
				_lPreNota := .T.
			Else
				MessageBox("Fornecedor de cnpj "+_cCnpjEmit+" nao cadastrado!!","Leitura de chave",0)
				Return .F.
			EndIf
		//Remessa por conta e ordem
		ElseIf AT("CFOP>5924",_cXml) > 0;
				.or. AT("CFOP>6924",_cXml) > 0
			DbSelectArea("SA2")
			DbSetOrder(3)
			If DbSeek(xFilial("SA2")+_cCnpjEmit)
				_cCliFor    := SA2->A2_COD
				_cLoja      := SA2->A2_LOJA
				_cTipoNF := "N"
				_cTes   := "007"
			Else
				MessageBox("Fornecedor de cnpj "+_cCnpjEmit+" nao cadastrado!!","Leitura de chave",0)
				Return .F.
			EndIf
		Else
			MessageBox("Operacao "+OXML:_NFEPROC:_NFE:_INFNFE:_IDE:_NATOP:TEXT+" nao mapeada!!","Leitura de chave",0)
			Return .F.
		EndIf

		aadd(aCab,{"F1_FILIAL"      ,cFilAnt        ,NIL})
		aadd(aCab,{"F1_TIPO"        ,_cTipoNF        ,NIL})
		aadd(aCab,{"F1_FORMUL"      ,"N"        ,NIL})
		aadd(aCab,{"F1_DOC"         ,oCab['documento']       ,NIL})
		aadd(aCab,{"F1_SERIE"       ,oCab['serie']      ,NIL})
		aadd(aCab,{"F1_FORNECE"     ,oCab['fornecedor']   ,NIL})
		aadd(aCab,{"F1_LOJA"        ,oCab['loja']       ,NIL})
		aadd(aCab,{"F1_EMISSAO"     ,oCab['emissao']  ,NIL})
		aadd(aCab,{"F1_DTDIGIT"     ,ddatabase  ,NIL})
		aadd(aCab,{"F1_ESPECIE"     ,"SPED"      ,NIL})
		aadd(aCab,{"F1_CHVNFE"      ,oCab['chave']      ,NIL})
		If _cTipoNF == "N"
			aadd(aCab,{"F1_COND"        ,"001"      ,NIL})
		EndIf
		aadd(aCab,{"F1_DESPESA"     , 0 , Nil})
		aadd(aCab,{"F1_DESCONT"     , 0 , Nil})
		aadd(aCab,{"F1_SEGURO"      , 0 , Nil})
		aadd(aCab,{"F1_FRETE"       , 0 , Nil})
		aadd(aCab,{"F1_MOEDA"       , 1 , Nil})
		aadd(aCab,{"F1_TXMOEDA"     , 1 , Nil})
		// aadd(aCab,{"F1_STATUS"      , "A" , Nil})
		aadd(aCab,{"F1_VOLUME1"     ,0, Nil})
		aadd(aCab,{"F1_PLIQUI"      ,0, Nil})
		aadd(aCab,{"F1_PBRUTO"      ,0, Nil})
		aadd(aCab,{"F1_XCODSZ0"     ,cCodSZ0, Nil})
		If _cTipoNF == "N"
			aadd(aCab,{"F1_XNOME"      	, SA2->A2_NOME, Nil})
		Else
			aadd(aCab,{"F1_XNOME"      	, SA1->A1_NOME, Nil})
		EndIf

		If !Empty(_cTesRemI) .and. _cTipoNF == "B" .and. SA1->A1_EST # "SP"
			If !FWAlertYesNo("O Tes padrao foi modificado para essa operacao!!! Tem certeza que deseja continuar com este tes?")
				REturn
			Else
				_cTes := _cTesRemI
			EndIf
		EndIf
		For nX := 1 To Len(_aItens)
			oItem := _aItens[nX]
			_cProd := oItem['produto']
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+_cProd)

			aItem := {}
			aadd(aItem,{"D1_ITEM"       ,StrZero(nX,4) ,NIL})
			aadd(aItem,{"D1_COD"        ,PadR(_cProd,TamSx3("D1_COD")[1]) ,NIL})
			aadd(aItem,{"D1_UM"         ,SB1->B1_UM   ,NIL})
			aadd(aItem,{"D1_QUANT"      ,oItem['quantidade']     ,NIL})
			aadd(aItem,{"D1_XSLDTIC"    ,oItem['qtd_ticket']     ,NIL})
			aadd(aItem,{"D1_VUNIT"      ,oItem['preco']     ,NIL})
			aadd(aItem,{"D1_TOTAL"      ,oItem['total']     ,NIL})
			aadd(aItem,{"D1_CONTA"      ,SB1->B1_CONTA     ,NIL})
			If !_lPreNota
				aadd(aItem,{"D1_TES"        ,_cTes  ,NIL}) //TES DEVOLUCAO - Poder3
			Else
				aadd(aItem,{"D1_TES"        ,"003"  ,NIL}) //TES DEVOLUCAO - Poder3
			EndIf
			aadd(aItem,{"D1_LOCAL"      ,SB1->B1_LOCPAD    ,NIL})
			If !Empty(oItem['pedido'])
				aadd(aItem,{"D1_PEDIDO"     ,oItem['pedido']    ,NIL})
				aadd(aItem,{"D1_ITEMPC"     ,oItem['item_pedido']    ,NIL})
			EndIf
			aadd(aItem,{"D1_XCODSZ2"    ,oItem['ticket']    ,NIL})
			aAdd(aItens,aItem)
		Next nX
		IF _lPreNota
			MSExecAuto({|x,y,z,a| MATA140(x,y,z)},aCab,aItens,nOpc)
		Else
			MSExecAuto({|x,y,z,a| MATA103(x,y,z)},aCab,aItens,nOpc)
		EndIf
		If !lMsErroAuto
			ConOut("    Incluido NF: " + cNum)
		Else
			cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
			showlog(cError)
			ConOut("Erro na inclusao!")
		EndIf
	Endif
	Conout("Inicio: " + cInicio)
	ConOut("Fim: " + Time())
Return !lMsErroAuto

Static Function Imprimir()

	_cChave := GdFieldGet("Z4_CHAVE",oGetSZ4NF:nAt,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)
	_nPesoNF := GdFieldGet("Z4_PSLXML",oGetSZ4NF:nAt,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)
	DbSelectArea("SF1")
	SF1->(DbSetOrder(8))
	If !SF1->(DbSeek(xFilial("SF1") + _cChave  ))
		FwalertInfo("Documento nao localizado!!!","Exclusao de NF")
		DisarmTransaction()
		Return
	EndIf
	msgrun("","",{||imprimeFechamento(@_cChave)})

Return

User Function tstSZ0Imp()

	//Cria o MsApp
	MsApp():New('SIGACOM')
	oApp:CreateEnv()

	//Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
	PtSetTheme("SUNSET")

	//Define o programa de inicialização
	oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",{|| RpcSetEnv("01","0201"), }),tstimp()}
	//Seta Atributos
	__lInternet := .T.
	lMsFinalAuto := .F.
	oApp:lMessageBar:= .T.
	oApp:cModDesc:= 'SIGACOM'

	//Inicia a Janela
	oApp:Activate()


Return

Static Function tstimp()
	Private cCodSZ0 := "000103"
	_nQtdeClass := 0
	_nQtdeNF := 0
	DbSelectArea("SZ4")
	DbSetOrder(1)
	If DbSeek(xFilial("SZ4")+cCodSZ0)
		While !SZ4->(Eof()) .and. SZ4->Z4_CODSZ0 == cCodSZ0
			imprimeFechamento(SZ4->Z4_CHAVE)
			SZ4->(DbSkip())
		EndDo
	EndIf
Return

Static Function imprimeFechamento(_cChave)
	Local _x
	Local cCaminho    := ""
	Private nLinCab   := 50
	Private nColIni   := 010
	Private nColFin   := 550
	Private nColMeio  := (nColFin-nColIni)/2
	Private nTamLin   := 010
	Private oPrintPvt
	Private cNomeFont := "Arial"
	Private oFontDet  := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontEmp  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontDetN := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
	Private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
	Private dDataGer  := Date()
	Private cHoraGer  := Time()

	cCaminho  := GetTempPath()
	cArquivo  := "fechamento_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')

	DbSelectArea("SZ0")
	DbSetOrder(1)
	DbSeek(xFilial("SZ0")+cCodSZ0)
	DbSelectArea("SZ4")
	DbSetOrder(2)
	DbSeek(xFilial("SZ4")+_cChave)

	DbSelectArea("SF1")
	DbSetOrder(8)
	DbSeek(xFilial("SF1")+_cChave)
	If SF1->F1_TIPO == "B"
		DbSelectArea("SA1");DbSetOrder(1)
		DbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA)
		_cNome := SA1->A1_NOME
	Else
		DbSelectArea("SA2");DbSetOrder(1)
		DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
		_cNome := SA2->A2_NOME
	EndIf

	nPeso := 15000
	//Criando o objeto do FMSPrinter
	oPrintPvt := FWMSPrinter():New(cArquivo, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)

	//Setando os atributos necessários do relatório
	oPrintPvt:SetResolution(72)
	oPrintPvt:SetLandscape()
	oPrintPvt:SetPaperSize(DMPAPER_A4)
	oPrintPvt:SetMargin(60, 60, 60, 60)
	nLin:= 50

	cTexto := "COMUNICADO DE PESAGEM "
	oPrintPvt:SayBitMap(050,0050,"\system\mlogo.png",0100,0100 )
	oPrintPvt:SayAlign(nLin+=30, nColMeio - 120, cTexto, oFontTit, 240, 20, COR_PRETO, PAD_CENTER, 0)
	oPrintPvt:SayAlign(nLin+=30, nColMeio - 120, Alltrim(SM0->M0_CIDENT)+", "+cvaltochar(day(SF1->F1_DTDIGIT))+" de "+mesExtenso(month(SF1->F1_DTDIGIT))+" de "+cvaltochar(year(SF1->F1_DTDIGIT)), oFontTit, 240, 20, COR_PRETO, PAD_CENTER, 0)
	oPrintPvt:SayAlign(nLin+=60, 50, "A "+ _cNome, oFontTit, 240, 20, COR_PRETO, PAD_LEFT, 0)
	cDeclara1 := "Declaramos ter recebido vosso material, conforme registro em nossa balança "
	cDeclara2 := " (original do tiket em nossos arquivos) e demonstrações abaixo "
	oPrintPvt:SayAlign(nLin+=20, 50,   "Ref Danfe: "+SF1->F1_DOC +" Serie: "+SF1->F1_SERIE + " De: "+dtoc(SF1->F1_EMISSAO), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	// oPrintPvt:SayAlign(nLin+=20, 50,   "Percentual de perda aplicado: "+Transform(_nQtdeClass,"@E 999,999")+" Kgs C/5%", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	// If Opercao triangular
	// 	oPrintPvt:SayAlign(nLin+=20, 50,   "Fornecedor: "+_cNome, oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	// EndIf
	oPrintPvt:SayAlign(nLin+=20, 50,   "Placa: "+SZ0->Z0_PLACA , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLin+=20, 50,   "Peso Danfe: "+Transform(_nPesoNF,"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLin+=20, nColMeio-120,   cDeclara1, oFontDet, 0300, nTamLin, COR_PRETO, PAD_CENTER, 0)
	oPrintPvt:SayAlign(nLin+=20, nColMeio-120,   cDeclara2, oFontDet, 0300, nTamLin, COR_PRETO, PAD_CENTER, 0)


	_nQtdSZ2 := 0
	_nQtdEst := 0

	SD1->(dbSetOrder(1))
	SD1->(DbSeek(xFilial("SD1")+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA))
	aItens     := {}
	While !Eof() .And. SD1->D1_FILIAL+SD1->D1_DOC+SD1->D1_SERIE+SD1->D1_FORNECE+SD1->D1_LOJA == ;
			SF1->F1_FILIAL+SF1->F1_DOC+SF1->F1_SERIE+SF1->F1_FORNECE+SF1->F1_LOJA
		_nPesol := 0
		DbSelectArea("SZ2")
		DbSetOrder(1)
		If DbSeek(xFilial("SZ2")+SD1->D1_XCODSZ2)
			_nPesol := SZ2->Z2_PESOL-SZ2->Z2_PESOEMB
			_nQtdSZ2 += SZ2->Z2_PESOL-SZ2->Z2_PESOEMB
			IF !Alltrim(SD1->D1_COD) == "2999999"
				_nQtdEst += SD1->D1_QUANT
			EndIf
		EndIf
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+SD1->D1_COD)
		oPrintPvt:SayAlign(nLin+=10, 50,   "ITEM "+Alltrim(SD1->D1_COD)+" - "+Alltrim(SB1->B1_DESC)/*+" - RM "+Transform(SB1->B1_XRM,"999.99")+"%"*/, oFontDetN, 0300, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin+=10, 60,   "PESOS", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 240,   "QTDE (Kgs)", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 360,   "VL UNIT (R$)", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 480,   "VALOR (R$)", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)

		oPrintPvt:SayAlign(nLin+=10, 60,   "QTDE ESCRITURADA", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 240,   Transform(SD1->D1_QUANT,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 360,   Transform(SD1->D1_VUNIT,"@E 9,999.99999"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 480,   Transform(SD1->D1_TOTAL,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)

		oPrintPvt:SayAlign(nLin+=10, 60,   "BALANCA METALEX", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 240,   Transform(_nPesol,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 360,   Transform(SD1->D1_TOTAL/SD1->D1_QUANT,"@E 9,999.99999"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 480,   Transform(SD1->D1_TOTAL/SD1->D1_QUANT*_nPesol,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)

		If _nPesol > SD1->D1_QUANT
			nQtdComp := _nPesol - SD1->D1_QUANT
			oPrintPvt:SayAlign(nLin+=10, 60,   "DANFE COMPLEMENTAR", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			oPrintPvt:SayAlign(nLin, 240,   Transform(nQtdComp,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			oPrintPvt:SayAlign(nLin, 360,   Transform(SD1->D1_TOTAL/SD1->D1_QUANT,"@E 9,999.99999"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			oPrintPvt:SayAlign(nLin, 480,   Transform(nQtdComp*SD1->D1_TOTAL/SD1->D1_QUANT,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		EndIf
		IF Alltrim(SD1->D1_COD) == "2999999"
			oPrintPvt:SayAlign(nLin+=10, 60,   "MATERIAL REJEITADO", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			oPrintPvt:SayAlign(nLin, 240,   Transform(SD1->D1_QUANT,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			oPrintPvt:SayAlign(nLin, 360,   Transform(SD1->D1_VUNIT,"@E 9,999.99999"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			oPrintPvt:SayAlign(nLin, 480,   Transform(SD1->D1_TOTAL,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		EndIf
		nLin+=10
		SD1->(dbSkip())
	EndDo

	If _nQtdSZ2 > SZ4->Z4_QTDENF
		nQtdEst := _nQtdeNF
		nQtdComp := _nQtdSZ2 - SZ4->Z4_QTDENF
		cCompl1 := "Solicitamos Documento Fiscal (DANFE) complementar do peso à menor recebido para"
		cCompl2 := "regularização, conforme artigo 182 do Decreto Estadual 45490/00 (RICMS-SP)"
		oPrintPvt:SayAlign(nLin+=10, 60,   "MATERIAL EM ESTOQUE", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 240,   Transform(_nQtdEst,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 360,   Transform(SZ4->Z4_VLRNF/SZ4->Z4_QTDENF,"@E 9,999.99999"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 480,   Transform(_nQtdEst*SZ4->Z4_VLRNF/SZ4->Z4_QTDENF,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)

		oPrintPvt:SayAlign(nLin+=10, 60,   "DANFE COMPLEMENTAR", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 240,   Transform(nQtdComp,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 360,   Transform(SZ4->Z4_VLRNF/SZ4->Z4_QTDENF,"@E 9,999.99999"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 480,   Transform(nQtdComp*SZ4->Z4_VLRNF/SZ4->Z4_QTDENF,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)

		oPrintPvt:SayAlign(nLin+=15, nColMeio-120,   cCompl1, oFontDet, 0300, nTamLin, COR_PRETO, PAD_CENTER, 0)
		oPrintPvt:SayAlign(nLin+=15, nColMeio-120,   cCompl2, oFontDet, 0300, nTamLin, COR_PRETO, PAD_CENTER, 0)
	Else
		oPrintPvt:SayAlign(nLin+=10, 60,   "MATERIAL EM ESTOQUE", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 240,   Transform(_nQtdEst,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 360,   Transform(SZ4->Z4_VLRNF/SZ4->Z4_QTDENF,"@E 9,999.99999"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 480,   Transform(_nQtdEst*SZ4->Z4_VLRNF/SZ4->Z4_QTDENF,"@E 999,999.99"), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		cCompl1 := "Os Lançamentos em nossos livros estão de acordo com as correções acima."
		cCompl1 += "Declaramos que não nos creditamos do valor do imposto à maior destacado em seu "
		cCompl1 += "documento fiscal e autorizamos V.Depto.Fiscal pleitearem sua restituição(se for o caso) "
		cCompl1 += "junto as repartições competentes, nos termos do artigo 63 parágrafo 4º do Decreto "
		cCompl1 += "Estadual 45490/00(RICMS-SP)"
		For _x := 1 to MLCount(cCompl1,80,/*nTabSize*/,.T.)
			oPrintPvt:SayAlign(nLin+=15, nColMeio-120,   MemoLine(cCompl1,80,_x) , oFontDet, 0300, nTamLin, COR_PRETO, PAD_CENTER, 0)
		Next
	EndIf
	nLin+=20
	oPrintPvt:SayAlign(nLin+=20, 120,   "FOTOS", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayBitMap(nLin,060,"\system\caminhao1.jpg",0100,0100 )
	oPrintPvt:SayBitMap(nLin,250,"\system\caminhao2.jpg",0100,0100 )

	nLin := 700
	cEndereco   := Alltrim(SM0->M0_ENDENT)+" - Cep: "+Alltrim(SM0->M0_CEPENT)+" "+Alltrim(SM0->M0_CIDENT)+" - "+Alltrim(SM0->M0_ESTENT)+" - Fone "+Alltrim(SM0->M0_TEL)
	oPrintPvt:SayAlign(nLin+=20, nColMeio-100,   "Atenciosamente", oFontDet, 0200, nTamLin, COR_PRETO, PAD_CENTER, 0)
	oPrintPvt:SayAlign(nLin+=30, nColMeio-100,   "METALEX LTDA", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_CENTER, 0)
	oPrintPvt:SayAlign(nLin+=15, nColMeio-100,   cEndereco, oFontDet, 0500, nTamLin, COR_PRETO, PAD_CENTER, 0)

	oPrintPvt:Preview()

Return

Static Function impComunicado()

	Local oBody
	Local _cBodyMail := ""
	// Private _cCodSZO    := GdFieldGet("ZO_NUMOS",oGetSZOFat:nAt,,oGetSZOFat:aHeader,oGetSZOFat:aCols)
	// Private _cCodSZ2    := GdFieldGet("ZO_CODSZ2",oGetSZOFat:nAt,,oGetSZOFat:aHeader,oGetSZOFat:aCols)
	Private _cEmail := Space(254)
	Private oGetEmail
	Private oEnvio
	Private _lEnvio := .F.

	_cChave := GdFieldGet("Z4_CHAVE",oGetSZ4NF:nAt,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)

	DbSelectArea("SF1")
	DbSetOrder(8)
	DbSeek(xFilial("SF1")+_cChave)
	If SF1->F1_TIPO == "B"
		DbSelectArea("SA1");DbSetOrder(1)
		DbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA)
		_cNome := SA1->A1_NOME
		_cEmail := SA1->A1_EMAIL
	Else
		DbSelectArea("SA2");DbSetOrder(1)
		DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
		_cNome := SA2->A2_NOME
		_cEmail := Alltrim(SA2->A2_EMAIL)

		DbSelectArea("SD1")
		DbSetOrder(1)
		If DbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
			If Alltrim(SD1->D1_CF) $ '1924/2924'
				DbSelectArea("SDH")
				DbSetOrder(1)
				If DbSeek(xFilial("SDH")+SD1->D1_NUMSEQ)
					DbSelectArea("SA1")
					DbSetOrder(1)
					If DbSeek(xFilial("SA1")+SDH->(DH_CLIENTE+DH_LOJACLI))
						_cA1_NOME := SA1->A1_NOME
						_cNFCobertura := SDH->DH_DOC
						_cEmail += ";"+Alltrim(SA1->A1_EMAIL)
					EndIf
				Else
					FwalertInfo("Nota de cobertura nao vinculada!!!","Operacao triangular")
					Return
				EndIf
			EndIf
		EndIf
	EndIf
	_cEmail := Padr(_cEmail,254)
	_cBodyMail := ""
	// PREPARE ENVIRONMENT EMPRESA "01" FILIAL "0201" MODULO "COM"
	//Se a pergunta for confirmada
	DEFINE MSDIALOG oDlgComunicado TITLE "Comunicado de pesagem" FROM 000, 000  TO 400, 800 COLORS 0, 16777215 PIXEL
	@ 005, 050 BUTTON oBtnGerar PROMPT "&Gerar Comunicado" SIZE 060, 012 OF oDlgComunicado PIXEL Action(Processa({|| relComunicado(_cBodyMail)}))
	@ 005, 175 BUTTON oBtnFechar PROMPT "&Fechar" SIZE 042, 012 OF oDlgComunicado PIXEL Action(oDlgComunicado:End())

	@ 020, 005 SAY oSay1 PROMPT "Email " SIZE 40, 012 OF oDlgComunicado COLORS 0, 16777215 PIXEL
	@ 020, 045 MSGET oGetEmail VAR _cEmail SIZE 300, 012 OF oDlgComunicado COLORS 0, 16777215 PIXEL
	@ 035, 005 CHECKBOX oEnvio VAR _lEnvio PROMPT "Envia email?" SIZE 045, 015 OF oDlgComunicado COLORS 0, 16777215 PIXEL
	@ 050, 005 GET oBody VAR _cBodyMail OF oDlgComunicado MULTILINE SIZE 300, 090 COLORS 0, 16777215 HSCROLL PIXEL

	ACTIVATE MSDIALOG oDlgComunicado CENTERED



Return

Static Function relComunicado(_cBodyMail)
	Local cCaminho    := ""
	Local _x := 0
	Private nLinCab   := 50
	Private nColIni   := 010
	Private nColFin   := 550
	Private nColMeio  := (nColFin-nColIni)/2
	Private nTamLin   := 010
	Private oPrintPvt
	Private cNomeFont := "Arial"
	Private oFontDet  := TFont():New(cNomeFont, 9, -10, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontEmp  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontDetN := TFont():New(cNomeFont, 9, -10, .T., .T., 5, .T., 5, .T., .F.)
	Private oFontRod  := TFont():New(cNomeFont, 9, -08, .T., .F., 5, .T., 5, .T., .F.)
	Private oFontTit  := TFont():New(cNomeFont, 9, -13, .T., .T., 5, .T., 5, .T., .F.)
	Private dDataGer  := Date()
	Private cHoraGer  := Time()

	cCaminho  := GetTempPath()
	cArquivo  := "fechamento_"+cCodSZ0+"_" + dToS(dDataGer) + "_" + StrTran(cHoraGer, ':', '-')

	DbSelectArea("SZ0")
	DbSetOrder(1)
	If !DbSeek(xFilial("SZ0")+cCodSZ0)
		FwalertInfo("Codigo do checklist nao localizado!!!","Impressao de Fechamento")
		Return
	EndIf

	If SZ0->Z0_STATUS # "F"
		FwalertInfo("CheckList ainda nao foi finalizado","Comunicado de pesagem")
		Return
	EndIf
	DbSelectArea("SZ4")
	DbSetOrder(1)
	If !DbSeek(xFilial("SZ4")+cCodSZ0)
		FwalertInfo("NF nao relacionada nao localizado!!!","Impressao de Fechamento")
		Return
	EndIf

	_cNome := SZ4->Z4_NOME
	_cChave := GdFieldGet("Z4_CHAVE",oGetSZ4NF:nAt,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)

	DbSelectArea("SF1")
	DbSetOrder(8)
	DbSeek(xFilial("SF1")+_cChave)
	If SF1->F1_TIPO == "B"
		DbSelectArea("SA1");DbSetOrder(1)
		DbSeek(xFilial("SA1")+SF1->F1_FORNECE+SF1->F1_LOJA)
		_cNome := SA1->A1_NOME
	Else
		DbSelectArea("SA2");DbSetOrder(1)
		DbSeek(xFilial("SA2")+SF1->F1_FORNECE+SF1->F1_LOJA)
		_cNome := SA2->A2_NOME
	EndIf

	//Criando o objeto do FMSPrinter
	If _lEnvio
		lServer := .T.
		_cPathServer := "/comunicados"
		lViewPDF := .F.
	Else
		_cPathServer := ""
		lServer := .F.
		lViewPDF := .T.
	EndIf
	lAdjustToLegacy := .F.
	lDisabeSetup := .T.
	oPrintPvt   := FWMSPrinter():New(cArquivo       ,IMP_PDF                , lAdjustToLegacy, _cPathServer , lDisabeSetup ,            , @oPrintPvt        , ""        ,lServer,           ,           , lViewPDF)
	// oPrintPvt := FWMSPrinter():New(cArquivo			, IMP_PDF, .F., "", .T., , @oPrintPvt, "", , , , .T.)
	If _lEnvio
		oPrintPvt:lInJob := .T.
	EndIf

	//Setando os atributos necessários do relatório
	oPrintPvt:SetResolution(72)
	oPrintPvt:SetLandscape()
	oPrintPvt:SetPaperSize(DMPAPER_A4)
	oPrintPvt:SetMargin(60, 60, 60, 60)
	nLin:= 50
	_cA1_NOME := ""
	_cNFCobertura := ""
	If SF1->F1_TIPO == "N"
		DbSelectArea("SD1")
		DbSetOrder(1)
		If DbSeek(xFilial("SD1")+SF1->(F1_DOC+F1_SERIE+F1_FORNECE+F1_LOJA))
			If Alltrim(SD1->D1_CF) $ '1924/2924'
				DbSelectArea("SDH")
				DbSetOrder(1)
				If DbSeek(xFilial("SDH")+SD1->D1_NUMSEQ)
					DbSelectArea("SA1")
					DbSetOrder(1)
					If DbSeek(xFilial("SA1")+SDH->(DH_CLIENTE+DH_LOJACLI))
						_cA1_NOME := SA1->A1_NOME
						_cNFCobertura := SDH->DH_DOC
					EndIf
				Else
					FwalertInfo("Nota de cobertura nao vinculada!!!","Operacao triangular")
					Return
				EndIf
			EndIf
		EndIf
	EndIf

	cTexto := "COMUNICADO DE PESAGEM"
	oPrintPvt:SayBitMap(050,0050,"\system\mlogo.png",0100,0100 )
	oPrintPvt:SayAlign(nLin+=30, nColMeio - 100, cTexto, oFontTit, 240, 20, COR_PRETO, PAD_CENTER, 0)
	oPrintPvt:SayAlign(nLin+=30, nColMeio - 100, "Checklist "+cCodSZ0, oFontTit, 240, 20, COR_PRETO, PAD_CENTER, 0)
	oPrintPvt:SayAlign(nLin+=30, nColMeio - 100, Alltrim(SM0->M0_CIDENT)+", "+cvaltochar(day(SF1->F1_DTDIGIT))+" de "+mesExtenso(month(SF1->F1_DTDIGIT))+" de "+cvaltochar(year(SF1->F1_DTDIGIT)), oFontTit, 240, 20, COR_PRETO, PAD_CENTER, 0)
	If Empty(_cA1_NOME)
		oPrintPvt:SayAlign(nLin+=60, 50, "A "+ _cNome, oFontTit, 240, 20, COR_PRETO, PAD_LEFT, 0)
	Else
		oPrintPvt:SayAlign(nLin+=60, 50, "A "+ _cA1_NOME, oFontTit, 240, 20, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin+=30, 50, "Fornecedor "+ _cNome, oFontTit, 400, 20, COR_PRETO, PAD_LEFT, 0)
	EndIf
	cDeclara1 := "Declaramos ter recebido vosso material, conforme registro em nossa balança "
	cDeclara2 := " (original do tiket em nossos arquivos) e demonstrações abaixo "
	// oPrintPvt:SayAlign(nLin+=20, 50,   "Ref Danfe: "+SF1->F1_DOC +" Serie: "+SF1->F1_SERIE + " De: "+dtoc(SF1->F1_EMISSAO), oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	// oPrintPvt:SayAlign(nLin+=20, 50,   "Percentual de perda aplicado: "+Transform(_nQtdeClass,"@E 999,999")+" Kgs C/5%", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	// If Opercao triangular
	// 	oPrintPvt:SayAlign(nLin+=20, 50,   "Fornecedor: "+_cNome, oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	// EndIf
	oPrintPvt:SayAlign(nLin+=20, 50,   "Placa: "+SZ0->Z0_PLACA , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLin+=20, nColMeio-120,   cDeclara1, oFontDet, 0300, nTamLin, COR_PRETO, PAD_CENTER, 0)
	oPrintPvt:SayAlign(nLin+=20, nColMeio-120,   cDeclara2, oFontDet, 0300, nTamLin, COR_PRETO, PAD_CENTER, 0)


	oPrintPvt:SayAlign(nLin, 50,   "Danfe(s): " , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	nLin += 15
	oPrintPvt:SayAlign(nLin, 050,   "Documento" , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLin, 100,   "Qtde" , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLin, 150,   "Preco" , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLin, 200,   "Total" , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	nLin += 10
	_nTotNF := 0
	_cNotas := ""
	For _x := 1 to len(oGetSZ4NF:aCols)
		_nZ4_QTDNF := GdFieldGet("Z4_QTDENF",_x,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)
		_nZ4_VLRNF := GdFieldGet("Z4_VLRNF",_x,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)
		_nZ4_PRECO := IIf(_nZ4_QTDNF != 0, _nZ4_VLRNF / _nZ4_QTDNF, 0)
		oPrintPvt:SayAlign(nLin, 50,   GdFieldGet("Z4_DOC",_x,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols) , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 100,   Transform(_nZ4_QTDNF,"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 150,   Transform(_nZ4_PRECO,"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 200,   Transform(_nZ4_VLRNF,"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		_cNotas += GdFieldGet("Z4_DOC",_x,,oGetSZ4NF:aHeader,oGetSZ4NF:aCols)+ "/"
		nLin += 10
		_nTotNF += _nZ4_QTDNF
	Next
	oPrintPvt:SayAlign(nLin, 050,   "Total" , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLin, 100,   Transform(_nTotNF,"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)

	nLin += 10
	nLin += 10

	nLin += 10
	oPrintPvt:SayAlign(nLin, 50,   "Balança : " , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	nLin += 15
	oPrintPvt:SayAlign(nLin, 050,   "Ticket" , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	// oPrintPvt:SayAlign(nLin, 100,   "Peso Inicial" , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	// oPrintPvt:SayAlign(nLin, 150,   "Peso Final" , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLin, 100,   "Peso Liquido" , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLin, 170,   "Produto" , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayAlign(nLin, 220,   "Descrição" , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	// oPrintPvt:SayAlign(nLin, 500,   "Data/Hora" , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	nLin += 10
	nLin += 10
	_nTotTic := 0
	_nTotDev := 0
	For _x := 1 to len(oGetSZ2NF:aCols)
		If Alltrim(GdFieldGet("Z2_PRODUTO",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols)) == "2999999"
			_nTotDev += GdFieldGet("Z2_PESOL",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols)
		EndIf
		oPrintPvt:SayAlign(nLin, 50,   GdFieldGet("Z2_COD",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols) , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		// oPrintPvt:SayAlign(nLin, 100,   transform(GdFieldGet("Z2_PESOI",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols),"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		// oPrintPvt:SayAlign(nLin, 150,   transform(GdFieldGet("Z2_PESOF",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols),"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 100,   transform(GdFieldGet("Z2_PESOL",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols),"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 170,   GdFieldGet("Z2_PRODUTO",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols) , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		oPrintPvt:SayAlign(nLin, 220,   GdFieldGet("Z2_DESCRI",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols) , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		// oPrintPvt:SayAlign(nLin, 500,   dtoc(GdFieldGet("Z2_DTPSF",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols))+" "+GdFieldGet("Z2_HRPSF",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols) , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		nLin += 10
		_nTotTic += GdFieldGet("Z2_PESOL",_x,,oGetSZ2NF:aHeader,oGetSZ2NF:aCols)
	Next
	oPrintPvt:SayAlign(nLin, 100,   transform(_nTotTic,"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	nLin += 10
	nLin += 10

	_lComplementar := .F.
	_lDentroTol := .T.
	_nDiferenca := _nQtdeClass - _nQtdeNF
	If GdFieldGet("Z4_CLIFOR",len(oGetSZ4NF:aCols),,oGetSZ4NF:aHeader,oGetSZ4NF:aCols) $ "000918/004750"
		If Abs(_nDiferenca/_nQtdeNF) > 0.005
			_lDentroTol := .F.
		EndIf
	Else
		If Abs(_nDiferenca) > 20
			_lDentroTol := .F.
		EndIf
	EndIf
	_cTitMail := "Comunicado de Pesagem - Checklist: "+cCodSZ0
	_cBcc := "isabela.silva.is1@metalex.com.br"
	// _cBcc := "lucasfloridi@gmail.com"
	_cBodyMail := "Segue em anexo Pesagem da(s) Danfe(s) abaixo <br>"
	_cBodyMail += "<br>
	_cBodyMail += _cNotas
	_cBodyMail += "<br>

	If _lDentroTol

		oPrintPvt:SayAlign(nLin, 50, "Material em estoque (kgs): " + Transform(_nQtdeNF-_nTotDev,"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
		nLin+=10
		_cTitMail := "Peso Recebido OK / NF: "+_cNotas

		_cBodyMail += "Informo que o peso mencionado em sua DANFE esteve de acordo o peso recebido. <br>"

		cCompl1 := "Os Lançamentos em nossos livros estão de acordo com as correções acima."
		cCompl1 += "Declaramos que não nos creditamos do valor do imposto à maior destacado em seu "
		cCompl1 += "documento fiscal e autorizamos V.Depto.Fiscal pleitearem sua restituição(se for o caso) "
		cCompl1 += "junto as repartições competentes, nos termos do artigo 63 parágrafo 4º do Decreto "
		cCompl1 += "Estadual 45490/00(RICMS-SP)"
		For _x := 1 to MLCount(cCompl1,80,/*nTabSize*/,.T.)
			oPrintPvt:SayAlign(nLin+=15, 50,   MemoLine(cCompl1,80,_x) , oFontDet, 0300, nTamLin, COR_PRETO, PAD_LEFT, 0)
		Next
	Else
		If _nDiferenca > 0

			oPrintPvt:SayAlign(nLin, 50, "Material em estoque (kgs): " + Transform(_nQtdeNF-_nTotDev,"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			nLin+=20
			oPrintPvt:SayAlign(nLin, 50, "Necessidade de complemento (kgs): " + Transform(_nDiferenca,"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			cCompl1 := "Solicitamos Documento Fiscal (DANFE) complementar do peso à menor recebido para"
			cCompl2 := "regularização, conforme artigo 182 do Decreto Estadual 45490/00 (RICMS-SP)"
			oPrintPvt:SayAlign(nLin+=15, 50,   cCompl1, oFontDet, 0300, nTamLin, COR_PRETO, PAD_LEFT, 0)
			oPrintPvt:SayAlign(nLin+=15, 50,   cCompl2, oFontDet, 0300, nTamLin, COR_PRETO, PAD_LEFT, 0)

			_cTitMail := "Complemento NF: "+_cNotas

			_cBodyMail += "Por gentileza, enviar ainda hoje a NF Complementar referenciando a remessa tratada, para que possamos efetuar a entrada fiscal do seu material na empresa. <br>"
		Else
			oPrintPvt:SayAlign(nLin, 50, "Material em estoque (kgs): " + Transform(_nQtdeClass-_nTotDev,"@E 999,999.99") , oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
			nLin+=10

			_cTitMail := "Divergencia de Peso a Menor - NF: "+_cNotas
			_cBodyMail += "OBS: Houve uma divergência de peso entre o peso de sua DANFE e o peso recebido, portanto foi considerado pela Metalex o peso da nossa balança. <br>"

			cCompl1 := "Os Lançamentos em nossos livros estão de acordo com as correções acima."
			cCompl1 += "Declaramos que não nos creditamos do valor do imposto à maior destacado em seu "
			cCompl1 += "documento fiscal e autorizamos V.Depto.Fiscal pleitearem sua restituição(se for o caso) "
			cCompl1 += "junto as repartições competentes, nos termos do artigo 63 parágrafo 4º do Decreto "
			cCompl1 += "Estadual 45490/00(RICMS-SP)"
			For _x := 1 to MLCount(cCompl1,80,/*nTabSize*/,.T.)
				oPrintPvt:SayAlign(nLin+=15, 50,   MemoLine(cCompl1,80,_x) , oFontDet, 0300, nTamLin, COR_PRETO, PAD_LEFT, 0)
			Next
		EndIf
	EndIf
	If !Empty(_cNFCobertura)
		_cTitMail += "("+Alltrim(_cNFCobertura)+")"
	EndIf


	_cBodyMail += "<br>"
	_cBodyMail += "Checklist: "+cCodSZ0
	_cBodyMail += "<br>"
	_cBodyMail += "Fico no aguardo e agradeço atenção,"
	_cBodyMail += "<br>"
	_cBodyMail += "<br>"
	_cBodyMail += "Atenciosamente,"
	_cBodyMail += "<br>"
	_cBodyMail += "Favor não responder esse email. "
	_cBodyMail += "<br>"
	_cBodyMail += "Entrar em contato de acordo com sua necessidade. "
	_cBodyMail += "<br>"
	_cBodyMail += "<br>"
	_cBodyMail += "Recebimento de Sucatas"
	_cBodyMail += "<br>"
	_cBodyMail += "isabela.silva.is1@metalex.com.br"

	nLin+=20
	oPrintPvt:SayAlign(nLin+=20, 120,   "FOTOS", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_LEFT, 0)
	oPrintPvt:SayBitMap(nLin,060,"\system\caminhao1.jpg",0100,0100 )
	oPrintPvt:SayBitMap(nLin,250,"\system\caminhao2.jpg",0100,0100 )

	nLin := 700
	cEndereco   := Alltrim(SM0->M0_ENDENT)+" - Cep: "+Alltrim(SM0->M0_CEPENT)+" "+Alltrim(SM0->M0_CIDENT)+" - "+Alltrim(SM0->M0_ESTENT)+" - Fone "+Alltrim(SM0->M0_TEL)
	oPrintPvt:SayAlign(nLin+=20, nColMeio-100,   "Atenciosamente", oFontDet, 0200, nTamLin, COR_PRETO, PAD_CENTER, 0)
	oPrintPvt:SayAlign(nLin+=30, nColMeio-100,   "METALEX LTDA", oFontDetN, 0200, nTamLin, COR_PRETO, PAD_CENTER, 0)
	oPrintPvt:SayAlign(nLin+=15, nColMeio-250,   cEndereco, oFontDet, 0500, nTamLin, COR_PRETO, PAD_CENTER, 0)

	oPrintPvt:Preview()
	If _lEnvio
		If !FWAlertYesNo("Confirma envio do email? "+_crlf+_cBodyMail,"Envio de email")
			Return
		EndIf
		If u_tEnvMail(_cEmail,_cTitMail,;
				_cBodyMail,"/comunicados/"+cArquivo+".pdf",;
				_cBcc)
			FWAlertInfo("E-mail enviado com sucesso!","Envio de e-mail")
		Else
			FWAlertError("Falha ao enviar e-mail!","Envio de e-mail")
		EndIf
	EndIf

Return

Static Function ajusteSZ0

	DbSelectArea("SZ4")
	DbGotop()
	While !Eof()
		_cDoc := SZ4->Z4_DOC
		_cNome := SZ4->Z4_NOME
		DbSelectArea("SZ0")
		DbSetOrder(1)
		If DbSeek(SZ4->Z4_FILIAL+SZ4->Z4_CODSZ0)
			If Reclock("SZ0",.F.)
				SZ0->Z0_NOME    := _cNome
				SZ0->Z0_CLIFOR  := SZ4->Z4_CLIFOR
				If Empty(SZ0->Z0_DOCS)
					SZ0->Z0_DOCS    := _cDoc
				ElseIf !_cDoc $ SZ0->Z0_DOCS
					SZ0->Z0_DOCS    := Alltrim(SZ0->Z0_DOCS) + "," + Alltrim(_cDoc)
				EndIf
				MsUnlock()
			EndIf
		EndIf
		SZ4->(dbSkip())
	EndDo

Return
