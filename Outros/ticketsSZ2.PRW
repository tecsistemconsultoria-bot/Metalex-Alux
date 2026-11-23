#Include "totvs.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
#Define _crlf Chr(13)+Chr(10)

/***********************************************************************
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Tipo: API
Rotina: Específica
Função: RRECC002
Info: Tickets 
************************************************************************/
User Function RRECC002()

	Local cFiltro     := ""
	Local cAlias      := "SZ2"
	Local aCores      := {}

	Private cCadastro := "Tickets"
	Private aRotina   := {}

	aAdd(aCores,{ 'SZ2->Z2_STATUS=="1"' , 'BR_VERMELHO'  })    // Inicial pendente
	aAdd(aCores,{ 'SZ2->Z2_STATUS=="2"' , 'BR_MARRON'    })    // Posto avancado
	aAdd(aCores,{ 'SZ2->Z2_STATUS=="3"' , 'BR_AMARELO'   })    // Em classificacao
	aAdd(aCores,{ 'SZ2->Z2_STATUS=="4"' , 'BR_AZUL'      })    // Final pendente
	aAdd(aCores,{ 'SZ2->Z2_STATUS=="5"' , 'BR_VERDE'     })    // Finalizado

	aAdd(aRotina, { "Pesquisar"            , "AxPesqui"             , 0, 1 })
	aAdd(aRotina, { "Visualizar"           , "AxVisual"             , 0, 2 })
	aAdd(aRotina, { "&Balanca"             , "U_ticketBalanca"      , 0, 4 })
	aAdd(aRotina, { "&Posto"               , "U_ticketPosto"        , 0, 4 })
	aAdd(aRotina, { "&Classificacao"       , "U_ticketClassificacao", 0, 4 })
	aAdd(aRotina, { "&Enviar dados VA"     , "U_xEnvUni(1)"         , 0, 4 }) 
	aAdd(aRotina, { "&Enviar dados VA Novo", "U_xEnvUni(2)"         , 0, 4 })
	aAdd(aRotina, { "&Enviar todos VA"     , "U_xEnvPar(1)"         , 0, 4 })
	aAdd(aRotina, { "&Enviar todos VA Novo", "U_xEnvPar(2)"         , 0, 4 })
	aAdd(aRotina, { "&Enviar API Autenticada", "U_MLTAPI03(.F.)"    , 0, 4 })
	aAdd(aRotina, { "Excluir Ticket"       , "U_AXDELSZ2()"         , 0, 5 })

	If __cUserID $ SuperGetMV("MX_USRADM",.T.,"000000")

		aAdd(aRotina, { "Incluir"   , "AxInclui" , 0, 3 })
		aAdd(aRotina, { "Alterar"   , "AxAltera" , 0, 4 })
		aAdd(aRotina, { "Excluir"   , "AxDeleta" , 0, 5 })

	EndIf

	DbSelectArea(cAlias)
	(cAlias)->(DbSetOrder(1))

	MBrowse(6, 1, 22, 75, cAlias,,,,,,aCores,,,,,,,,cFiltro)

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
User Function zdebugtic()

	MsApp():New('SIGAFAT')    //Cria o MsApp

	oApp:CreateEnv()

	PtSetTheme("OCEAN")    //Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
	oApp:cStartProg    := 'U_RRECC002()' //Define o programa que será executado após o login
	__lInternet        := .T.    //Seta Atributos

	oApp:Activate()    //Inicia a Janela

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
User Function ticketBalanca()

	Local oSay1      := Nil
	Local oTimer1    := Nil
	Private oObj     := tSocketClient():New()
	Private oIp      := Nil
	Private cIp      := Padr('189.56.89.34',100)
	Private cIPLink  := AllTrim(GetMV("MV_IPBAL",.F.,"45.167.181.50"))
	Private oPorta   := Nil
	Private nPorta   := 23
	Private oTime    := Nil
	Private cTime    := ""
	Private oLog     := Nil
	Private cLog     := ""
	Private oPeso    := Nil
	Private oPsIni   := Nil
	Private oPsFin   := Nil
	Private oPsLiq   := Nil
	Private nPeso    := 0
	Private nPsIni   := SZ2->Z2_PESOI
	Private nPsFin   := SZ2->Z2_PESOF
	Private nPsLiq   := SZ2->Z2_PESOL
	Private oPeso2   := Nil
	Private cPeso    := ""
	Private oTicket  := Nil
	Private cPlaca   := SZ2->Z2_PLACA
	Private cCodSZ0  := SZ2->Z2_CODSZ0
	Private cTicket  := SZ2->Z2_COD
	Private oBalanca := Nil
	Private cBalanca := "2"

	_aBalancas:= {}

	aAdd(_aBalancas,{'187.8.231.172',9006})
	aAdd(_aBalancas,{cIPLink,9001}) //89.56.89.36
	aAdd(_aBalancas,{cIPLink,9002})
	aAdd(_aBalancas,{cIPLink,9003})
	aAdd(_aBalancas,{cIPLink,9004})
	aAdd(_aBalancas,{cIPLink,9005})

	cIp    := Padr('189.56.89.34',100)
	nPorta := 9001

	Static oDlg

	DEFINE MSDIALOG oDlg TITLE "Coleta de Peso - CheckList: "+cCodSZ0 FROM 000, 000  TO 400, 600 COLORS 0, 16777215 PIXEL
	
	oDlg:lMaximized := .T.
	
	@ 010, 005 SAY oSay1 PROMPT "Balança:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 040 MSCOMBOBOX oBalanca VAR cBalanca ITEMS {"1=Rodoviaria SJRP","2=Rodoviaria Ara","3=Embalagem","4=Serra","5=Centro de coleta","6=Patio"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL valid(validaBalanca())
	@ 010, 130 SAY oSay1 PROMPT "IP/Porta:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 170 MSGET oIp VAR cIp SIZE 049, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.
	@ 010, 220 MSGET oPorta VAR nPorta SIZE 020, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 99999" When .F.

	@ 025, 005 SAY oSay1 PROMPT "Ticket:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 025, 040 MSGET oTicket VAR cTicket SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.
	@ 040, 005 SAY oSay1 PROMPT "Peso Inicial (kg):" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 040 MSGET oPsIni VAR nPsIni SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999,999.99" When .F.
	@ 040, 090 SAY oSay1 PROMPT "Peso Final (kg):" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 140 MSGET oPsFin VAR nPsFin SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999,999.99" When .F.
	@ 040, 190 SAY oSay1 PROMPT "Peso Liquido (kg):" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 240 MSGET oPsLiq VAR nPsLiq SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999,999.99" When .F.

	@ 065, 005 SAY oSay1 PROMPT "Peso Lido:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 065, 040 MSGET oPeso VAR nPeso SIZE 050, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999,999.99" valid(vldPesoManual()) when cFilAnt == "0202"
	@ 065, 160 BUTTON oBtnConsumo PROMPT "&Ler Peso" SIZE 060, 012 OF oDlg PIXEL Action(MsgRun("Aguarde...","Lendo peso...",{|| lerPeso()})) When (SZ2->Z2_PESOF == 0)
	@ 065, 225 BUTTON oBtnConsumo PROMPT "&Salvar" SIZE 060, 012 OF oDlg PIXEL Action(salvarPeso()) When (SZ2->Z2_PESOF == 0)
	@ 090, 005 SAY oSay1 PROMPT "Log:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 090, 040 GET oLog VAR cLog OF oDlg MULTILINE SIZE 245, 100 COLORS 0, 16777215 HSCROLL PIXEL
	@ 200, 225 BUTTON oBtnFechar PROMPT "&Fechar" SIZE 060, 012 OF oDlg PIXEL Action(oDlg:End())
	
	validaBalanca()

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function LerPeso()

	Local nVarPeso := 0
	Local nMedia   := 0
	Local _x       := 0

	For _x := 1 to 3
		nVarPeso := lerserial()
		nMedia += nVarPeso
	Next

	If nMedia <= 0
		FwalertInfo("Erro na leitura do peso, favor tentar novamente!!!","Leitura de peso")
		Return
	EndIf

	IF nVarPeso == nMedia/3

		nPeso := nVarPeso

		If FWAlertYesNo("Confirma o peso lido: "+Alltrim(Str(nPeso))+" kg?","Leitura de peso")
			cLog += "Peso lido com sucesso: "+Alltrim(Str(nPeso))+" kg"+_crlf
			oLog:Refresh()
		Else
			nPeso := 0
			cLog += "Leitura de peso cancelada pelo usuario."+_crlf
			oLog:Refresh()
		EndIf

	Else
		nPeso := 0
		FwalertInfo("Peso instavel, favor tentar novamente!!!","Leitura de peso")
	EndIf

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 07/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Envio da API do VA
*==================================================================*/
User Function xEnvUni(nOpcA)

	Local nRecnoSZ2 := SZ2->(Recno())
	Local cTpSZ0    := ""

	If SZ2->Z2_TPTICK == "R"

		DbSelectArea("SZ0")
		SZ0->(DbsetOrder(1))

		If SZ0->(DbSeek(xFilial("SZ0")+SZ2->Z2_CODSZ0))
			cTpSZ0 := SZ0->Z0_TIPO
		Endif 

		If AllTrim(cTpSZ0) == "R" .Or. Empty(cTpSZ0)

			//Reposicionando na tabela SZ2
			DbSelectArea("SZ2")
			SZ2->(DbGoTo(nRecnoSZ2))
			// ---

			If nOpcA == 1
				U_wsapp_va(.F.)
			Else
				U_MLTAPI001(.F.)
			Endif 

		Endif 

	Else 
		MsgAlert("Só será possível o envio para os tickets do tipo Recebimento!","Atenção")
	Endif 

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function lerserial()

	Local nX        := 0
	Local _cIpSc    := Alltrim(cIp)
	Local nPort     := nPorta
	Local cBuffer   := ""
	Local nPesoBal  := 0
	
	cTime    := Time()
	cPeso 	 := ""
	nCont 	 := 0
	cLog     += "-------------" +_crlf

	oLog:Refresh()
	nResp := oObj:Connect( nPorta,cIp,500)

	if(nResp == 0 )
		cLog += "Conexao realizada com sucesso..."+Alltrim(cIp)+"/"+Alltrim(Str(nPorta))+" " + Time()+ " " +_crlf
		oLog:Refresh()
	Else
		cLog += "--> Tentativa de Conexão: "+Alltrim(cIp)+"/"+Alltrim(Str(nPorta))+" " + Time()+ " " +_crlf
		oLog:Refresh()
	Endif

	if( !oObj:IsConnected() )
		cLog += "Falha na conexao "+Alltrim(cIp)+"/"+Alltrim(Str(nPorta))+" " + Time()+ " " +_crlf
		oLog:Refresh()
		Return 0
	Else

		cBuffer := ""
		nResp   := oObj:Receive( @cBuffer, 2000 )

		if( nResp >= 0 )
			cLog += "--> Dados Recebidos ["+cBuffer+"]"+_crlf
			cLog += "--> Dados nResp " + cValToChar(nResp)+_crlf
		Else
			cBuffer := "000000"
		Endif
	
	Endif
	
	oObj:CloseConnection()
	oLog:Refresh()

	If cFilAnt == "0201"
		cPeso := Substr(cBuffer,at(Chr(002) ,cBuffer)+3,7)
	Else
		cPeso := Substr(cBuffer,at(Chr(002) ,cBuffer)+3,5)
	EndIf
	
	nPesoBal := Val(cPeso)

	If SZ2->Z2_STATUS == "1" //Aguardando pesagem inicial
		nPsIni := nPesoBal
	ElseIf SZ2->Z2_STATUS == "4" //Aguardando pesagem final
		nPsFin := nPesoBal
		nPsLiq := nPsIni-nPsFin
	EndIf

	oPsIni:Refresh()
	oPsFin:Refresh()
	oPsLiq:Refresh()
	oPeso:Refresh()

Return(nPesoBal)

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function salvarPeso()

	If nPeso <= 0
		MessageBox("Peso nao informado!!!","Peso Inicial",1)
		Return
	EndIf

	If SZ2->Z2_PESOI == 0

		Reclock("SZ2",.F.)
		SZ2->Z2_PESOI   := nPeso
		SZ2->Z2_DTPSI   := date()
		SZ2->Z2_HRPSI   := TIME()
		SZ2->Z2_STATUS  := "4"//enviado para classificacao
		SZ2->(MsUnlock())

		If SZ2->Z2_TPTICK == "R"

			u_wsapp_va(.T.) //API VA Antiga 
			U_MLTAPI001(.T.) //API VA Nova 

		Endif 

		MessageBox("Peso inicial coletado com sucesso!!!","Peso Inicial",1)

		oDlg:End()

	Else

		Reclock("SZ2",.F.)
		SZ2->Z2_PESOF   := nPeso
		SZ2->Z2_PESOL   := Abs(SZ2->Z2_PESOI-SZ2->Z2_PESOF)
		SZ2->Z2_DTPSF   := date()
		SZ2->Z2_HRPSF   := TIME()
		SZ2->Z2_STATUS  := "5" //finalizado
		SZ2->(MsUnlock())

		If SZ2->Z2_TPTICK == "R"

			u_wsapp_va(.T.) //API VA Antiga 
			U_MLTAPI001(.T.) //API VA Nova 

		Endif 

		MessageBox("Peso final coletado com sucesso!!!","Peso Final",1)

		If MessageBox("Deseja gerar outro ticket?","Ticket adicional",4) == 6
			geraTicket()
		EndIf

		oDlg:End()

	Endif

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function validaBalanca()

	conout(cBalanca)

	cIp    := _aBalancas[val(cBalanca),1]
	nPorta := _aBalancas[val(cBalanca),2]

	oIp:Refresh()
	oPorta:Refresh()

Return(.T.)

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
User Function ticketClassificacao

	Private oPsIni     := Nil
	Private oPsFin     := Nil
	Private oPsLiq     := Nil
	Private oPsEmb     := Nil
	Private oTicket    := Nil
	Private oObsEmb    := Nil
	Private oProduto   := Nil
	Private oDescricao := Nil
	Private oRnc       := Nil
	Private _nPsPlt    := 0
	Private _nPsBag    := 0
	Private _nPsToco   := 0
	Private _nPsCaixa  := 0
	Private _nPsPltP   := 0
	Private _nPsPltM   := 0
	Private _nPsBagM   := 0
	Private _nPsTocoM  := 0
	Private _nPsNA     := 0
	Private QtdNA      := SZ2->Z2_CNA
	Private QtdPalet   := SZ2->Z2_CPALET
	Private QtdBag     := SZ2->Z2_CBAG
	Private QtdBagM    := SZ2->Z2_CBAGM
	Private QtdTocoM   := SZ2->Z2_CTOCOM
	Private QtdToco    := SZ2->Z2_CTOCO
	Private QtdCaixa   := SZ2->Z2_CCAIXA
	Private cTicket    := SZ2->Z2_COD
	Private nPsIni     := SZ2->Z2_PESOI
	Private nPsFin     := SZ2->Z2_PESOF
	Private nPsLiq     := SZ2->Z2_PESOL
	Private nPsEmb     := SZ2->Z2_PESOEMB
	Private cObsEmb    := SZ2->Z2_OBSEMB
	Private cProduto   := SZ2->Z2_PRODUTO
	Private cDescricao := SZ2->Z2_DESCRI
	Private cRNC       := "N"
	Private QtPaletP   := SZ2->Z2_CPALETP
	Private QtPaletM   := SZ2->Z2_CPALETM
	Private cDestino   := SZ2->Z2_DESTINO

	If SZ2->Z2_STATUS == "1" //pesagem inicial
		FwalertInfo("Peso inicial nao coletado","Ticket")
		Return
	EndIf

	If SZ2->Z2_STATUS == "6" //pesagem inicial
		FwalertInfo("Ticket ja faturado nao pode ser alterado","Ticket")
		Return
	EndIf

	If Empty(SZ2->Z2_DESTINO)
		FwalertInfo("Destino ainda nao informado para este ticket","Ticket")
		Return
	EndIf

	DEFINE MSDIALOG oDlg TITLE "Classificacao de materiais" FROM 000, 000  TO 400, 650 COLORS 0, 16777215 PIXEL
	
	@ 015, 005 SAY oSay1 PROMPT "Ticket:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 015, 055 MSGET oTicket VAR cTicket SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.
	@ 030, 005 SAY oSay1 PROMPT "Peso Inicial (kg):" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, 055 MSGET oPsIni VAR nPsIni SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999,999.99" When .F.
	@ 030, 110 SAY oSay1 PROMPT "Peso Final (kg):" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, 160 MSGET oPsFin VAR nPsFin SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999,999.99" When .F.
	@ 030, 210 SAY oSay1 PROMPT "Peso Liquido (kg):" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, 260 MSGET oPsLiq VAR nPsLiq SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999,999.99" When .F.
	@ 045, 005 SAY oSay1 PROMPT "Peso Embalagem (kg):" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 045, 055 MSGET oPsEmb VAR nPsEmb              SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999,999.99" //When .F.
	@ 060, 005 SAY oSay1 PROMPT "Obs Embalagem (kg):" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 060, 055 MSGET oObsEmb VAR cObsEmb            SIZE 100, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@!"
	@ 060, 200 SAY oSay1 PROMPT "RNC?:"             SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 060, 255 MSCOMBOBOX oRnc VAR cRNC             ITEMS {"N=Nao","S=Sim"} SIZE 50, 010 OF oDlg COLORS 0, 16777215 PIXEL Valid(validaRnc())

	@ 080, 005 GROUP oGroup1 TO 145, 320 PROMPT "Embalagens" OF oDlg COLOR 0, 16777215 PIXEL

	@ 090, 010 SAY oSay8  PROMPT "Pallet P (15 Kg)" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 097, 008 MSGET Cmb_PalP VAR QtPaletP          SIZE 035, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999"

	@ 090, 055 SAY oSay8  PROMPT "Pallet M (18 Kg)" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 097, 053 MSGET Cmb_PalM VAR QtPaletM          SIZE 035, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999"

	@ 090, 100 SAY oSay8  PROMPT "Pallet G (22 Kg)" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 097, 098 MSGET Cmb_PalG VAR QtdPalet          SIZE 035, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999"

	@ 110, 010 SAY oSay9  PROMPT "Bag M (2 KG)"     SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 117, 008 MSGET Cmb_BgM VAR QtdBagM            SIZE 031, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999"

	@ 110, 045 SAY oSay9  PROMPT "Bag G (3 KG)"     SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 117, 043 MSGET Cmb_BgG VAR QtdBag             SIZE 031, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999"

	@ 110, 080 SAY oSay10 PROMPT "Toco M (3 Kg)"    SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 117, 078 MSGET Cmb_tcM VAR QtdTocoM           SIZE 031, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999"

	@ 110, 115 SAY oSay10 PROMPT "Toco G (5 Kg)"    SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 117, 113 MSGET Cmb_tcG VAR QtdToco            SIZE 031, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999"

	@ 110, 150 SAY oSay17 PROMPT "Caixa (5 Kg)"     SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 117, 148 MSGET Cmb_Caixa VAR QtdCaixa         SIZE 031, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999"

	@ 110, 185 SAY oSay11 PROMPT "N/A (0 kg)"       SIZE 035, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 117, 183 MSGET Cmb_NA VAR QtdNA               SIZE 031, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999"

	@ 150, 005 SAY oSay1 PROMPT "Produto:"          SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 150, 055 MSGET oProduto VAR cProduto          SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@!" F3 "SB1X03" valid(validaProduto())
	@ 165, 005 SAY oSay1 PROMPT "Descricao:"        SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 165, 055 MSGET oDescricao VAR cDescricao      SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@!" When .F.
	@ 162, 212 BUTTON oBtnCalc PROMPT "Calc.Emb."   SIZE 072, 015 OF oDlg PIXEL Action (fCalculo())

	@ 185, 080 BUTTON oBtnSalvar PROMPT "Confirmar" SIZE 072, 015 OF oDlg PIXEL Action (salvarClassificacao())
	@ 185, 158 BUTTON oBtnFechar PROMPT "&Fechar"   SIZE 072, 015 OF oDlg PIXEL Action(oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function fCalculo()

	Local _nPesoPltP  := 15
	Local _nPesoPltM  := 18
	Local _nPesoPlt   := 22
	Local _nPesoBagM  := 2
	Local _nPesoBag   := 3
	Local _nPesoTcM   := 3
	Local _nPesoToco  := 5
	Local _nPesoCaixa := 5
	Local _nPesoNA    := 0

	_nPsPltP  := Val(QtPaletP) * _nPesoPltP
	_nPsPltM  := Val(QtPaletM) * _nPesoPltM
	_nPsPlt   := Val(QtdPalet) * _nPesoPlt
	_nPsBagM  := Val(QtdBagM) * _nPesoBagM
	_nPsBag   := Val(QtdBag) * _nPesoBag
	_nPsTocoM := Val(QtdTocoM) * _nPesoTcM
	_nPsToco  := Val(QtdToco)  * _nPesoToco
	_nPsCaixa := Val(QtdCaixa) * _nPesoCaixa
	_nPsNA    := Val(QtdNA) * _nPesoNA

	nPsEmb := _nPsPltP + _nPsPltM + _nPsPlt + _nPsBagM + _nPsBag + _nPsTocoM + _nPsToco + _nPsCaixa + _nPsNA

	oPsEmb:Refresh()

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function salvarClassificacao()

	fCalculo()

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	If SB1->(DbSeek(xFilial("SB1")+cProduto))

		If cRNC == "S" .and. Empty(cObsEmb)
			MessageBox("Informe na observacao o motivo da RNC!!","Classificacao",0)
			Return
		EndIf

		If !MessageBox("Confirma gravacao da classificacao?","Classificacao",4) == 6
			Return
		EndIf

		Reclock("SZ2",.F.)
		SZ2->Z2_PRODUTO := SB1->B1_COD
		SZ2->Z2_DESCRI  := SB1->B1_DESC
		SZ2->Z2_TIPO    := SB1->B1_TIPO
		SZ2->Z2_UM      := SB1->B1_UM
		SZ2->Z2_PESOEMB := nPsEmb
		SZ2->Z2_RNC     := cRNC
		SZ2->Z2_OBSEMB  := cObsEmb

		// Gravação das QUANTIDADES 
		SZ2->Z2_CPALETP := QtPaletP
		SZ2->Z2_CPALETM := QtPaletM
		SZ2->Z2_CPALET  := QtdPalet
		SZ2->Z2_CBAGM   := QtdBagM
		SZ2->Z2_CBAG    := QtdBag
		SZ2->Z2_CTOCOM  := QtdTocoM
		SZ2->Z2_CTOCO   := QtdToco
		SZ2->Z2_CCAIXA  := QtdCaixa
		SZ2->Z2_CNA     := QtdNA

		// Gravação dos PESOS CALCULADOS 
		SZ2->Z2_QPALETP := _nPsPltP
		SZ2->Z2_QPALETM := _nPsPltM
		SZ2->Z2_QPALET  := _nPsPlt
		SZ2->Z2_QBAGM   := _nPsBagM
		SZ2->Z2_QBAG    := _nPsBag
		SZ2->Z2_QTOCOM  := _nPsTocoM
		SZ2->Z2_QTOCO   := _nPsToco
		SZ2->Z2_QCAIXA  := _nPsCaixa
		SZ2->Z2_QNA     := _nPsNA
		SZ2->(MsUnlock())

		If SZ2->Z2_TPTICK == "R"

			u_wsapp_va(.T.) //API VA Antiga 
			U_MLTAPI001(.T.) //API VA Nova 

		Endif 

		MessageBox("Classificacao realizada com sucesso!!","Classificacao",0)

		oDlg:End()

	Else
		MessageBox("Produto invalido!!","Classificacao",0)
	EndIf

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
User Function ticketPosto

	Private oPsIni     := Nil
	Private oPsFin     := Nil
	Private oPsLiq     := Nil
	Private oPsEmb     := Nil
	Private oTicket    := Nil
	Private oPlaca     := Nil
	Private oProduto   := Nil 
	Private oObsEmb    := Nil
	Private cPlaca     := SZ2->Z2_PLACA
	Private cTicket    := SZ2->Z2_COD
	Private cCodSZ0    := SZ2->Z2_CODSZ0
	Private nPsIni     := SZ2->Z2_PESOI
	Private nPsFin     := SZ2->Z2_PESOF
	Private nPsLiq     := SZ2->Z2_PESOL
	Private nPsEmb     := SZ2->Z2_PESOEMB
	Private cObsEmb    := SZ2->Z2_OBSEMB
	Private cProduto   := SZ2->Z2_PRODVA
	Private cDescricao := SZ2->Z2_DESCVA
	Private cTpRec     := IIf(Empty(SZ2->Z2_TPREC),"",AllTrim(SZ2->Z2_TPREC) + "-" + AllTrim(SZ2->Z2_DESCRE))
	Private cNConta    := IIf(Empty(SZ2->Z2_NCONTA),"",AllTrim(SZ2->Z2_NCONTA) + "-" + AllTrim(SZ2->Z2_DESCCON))
	Private cFScata    := IIf(Empty(SZ2->Z2_FSUCATA),"",AllTrim(SZ2->Z2_FSUCATA) + "-" + AllTrim(SZ2->Z2_DESCSUC))
	Private aTpRec     := xFilSX5("XZ")
	Private aNCrec     := xFilSX5("ZA")
	Private aFSrec     := xFilSX5("ZB")
	Private oDestino   := Nil
	Private oGetSZ4    := Nil
	Private cDestino   := IIf(Empty(SZ2->Z2_DESTINO),"",SZ2->Z2_DESTINO)

	If SZ2->Z2_TPTICK == "C" //Coleta
		FwalertInfo("Somente tickets do tipo recebimento podem ser destinados","Destinacao do ticket")
		Return
	EndIf

	If SZ2->Z2_STATUS  == "6" //Faturado
		FwalertInfo("Somente tickets nao finalizados podem ser destinados","Destinacao do ticket")
		Return
	EndIf

	DEFINE MSDIALOG oDlg TITLE "Posto Avancado" FROM 000, 000  TO 400, 1600 COLORS 0, 16777215 PIXEL
	@ 010, 005 SAY oSay1 PROMPT "Ticket:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 040 MSGET oTicket VAR cTicket SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.
	@ 025, 005 SAY oSay1 PROMPT "Placa:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 025, 040 MSGET oPlaca VAR cPlaca SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.
	@ 040, 005 SAY oSay1 PROMPT "Peso Inicial (kg):" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 040 MSGET oPsIni VAR nPsIni SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999,999.99" When .F.
	@ 040, 090 SAY oSay1 PROMPT "Peso Final (kg):" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 140 MSGET oPsFin VAR nPsFin SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999,999.99" When .F.
	@ 040, 190 SAY oSay1 PROMPT "Peso Liquido (kg):" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 040, 240 MSGET oPsLiq VAR nPsLiq SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999,999.99" When .F.

	@ 070, 005 SAY oSay1 PROMPT "Destino:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 040 MSCOMBOBOX oDestino VAR cDestino ITEMS {"1=Patio1","2=Patio2","3=CentroDeReciclagem","4=LinhaDeReciclagem","5=Tarugo Revenda"} SIZE 072, 010 OF oDlg COLORS 0, 16777215 PIXEL
	
	//Incluso por Vinicius N. de Oliveira - 18/03/2026
	@ 070, 140 SAY oSay1 PROMPT "Tipo de Recebimento:" SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 200 MSCOMBOBOX oDestino VAR cTpRec ITEMS aTpRec SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL
	// ---

	//Incluso por Vinicius N. de Oliveira - 14/07/2026
	@ 070, 360 SAY oSay1 PROMPT "Nível de Contaminação:" SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 420 MSCOMBOBOX oDestino VAR cNConta ITEMS aNCrec SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 070, 580 SAY oSay1 PROMPT "Formato Sucata:" SIZE 070, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 070, 640 MSCOMBOBOX oDestino VAR cFScata ITEMS aFSrec SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL
	// ---

	@ 085, 005 SAY oSay1 PROMPT "Produto:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 085, 055 MSGET oProduto VAR cProduto SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@!" F3 "SB1X03" valid(validaProduto())
	@ 100, 005 SAY oSay1 PROMPT "Descricao:" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 100, 055 MSGET oDescricao VAR cDescricao SIZE 150, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@!" When .F.

	@ 115, 104 BUTTON oBtnSalvar PROMPT "Confirmar" SIZE 072, 015 OF oDlg PIXEL Action (salvarDestino())
	@ 115, 225 BUTTON oBtnFechar PROMPT "&Fechar" SIZE 060, 012 OF oDlg PIXEL Action(oDlg:End())

	fGetSZ4()

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function fGetSZ4()
	
	Local nX
	Local _nItem 
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFieldFill   := {}
	Local aFields      := {"Z4_OPER","Z4_CLIFOR","Z4_LOJA","Z4_NOME","XX_PRODUTO","Z4_QTDENF","Z4_EMISSAO","Z4_CNPJ","Z4_DOC","Z4_SERIE","Z4_CHAVE"}
	Local aAlterFields := {}
	Local _x           := 0
	Local cError       := ""
	Local cWarning     := ""
	Local _cXml        := ""

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))

	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			aAdd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
		If aFields[nX] == "XX_PRODUTO"
			aAdd(aHeaderEx, {"Produto","XX_PRODUTO",  "",  50,0,".T.",".T.", "C", "",    ""} )
		EndIf
	Next nX

	// Define field values
	DbSelectArea("SZ4")
	SZ4->(DbSetOrder(1))

	If SZ4->(DbSeek(xFilial("SZ4")+cCodSZ0))

		While !SZ4->(Eof()) .AND. SZ4->Z4_CODSZ0 == cCodSZ0

			cQry := "SELECT CKO_CHVDOC CHAVE,R_E_C_N_O_ RECCKO " +_crlf
			cQry += "FROM CKOCOL CKO "+_crlf
			cQry += "WHERE CKO.D_E_L_E_T_='' "+_crlf
			cQry += "AND CKO_CHVDOC='"+SZ4->Z4_CHAVE+"' "

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

			oDet := OXML:_NFEPROC:_NFE:_INFNFE:_DET
			oDet := IIf(ValType(oDet)=="O",{oDet},oDet)

			For _nItem := 1 to Len(oDet)

				_xProd      := oDet[_nItem]:_PROD:_xProd:TEXT
				_nQtdCom    := Val(oDet[_nItem]:_PROD:_qCom:TEXT)
				aFieldFill  := {}

				For _x := 1 to Len(aFields)
					_cCpo := aFields[_x]
					If _cCpo == "XX_PRODUTO"
						aAdd(aFieldFill, _xProd)
					ElseIf _cCpo == "Z4_QTDENF"
						aAdd(aFieldFill, _nQtdCom)
					Else
						aAdd(aFieldFill, SZ4->&(_cCpo))
					EndIf
				Next

				aAdd(aFieldFill, .F.)
				aAdd(aColsEx, aFieldFill)
			Next

			SZ4->(DbSkip())

		EndDo

	Else

		aFieldFill := {}

		For _x := 1 to Len(aFields)

			_cCpo := aFields[_x]

			If _cCpo == "XX_PRODUTO"
				aAdd(aFieldFill, "")
			Else
				aAdd(aFieldFill, Criavar(_cCpo))
			EndIf

		Next
	
		aAdd(aFieldFill, .F.)
		aAdd(aColsEx, aFieldFill)
	
	EndIf

	oGetSZ4 := MsNewGetDados():New( 130, 007, 384, 800, GD_UPDATE+GD_DELETE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function salvarDestino()

	If !MessageBox("Confirma envio do ticket?","Posto avançado",4) == 6
		Return
	EndIf

	Reclock("SZ2",.F.)
	SZ2->Z2_DESTINO := cDestino //enviado para pesagem final
	SZ2->Z2_PRODVA  := cProduto
	SZ2->Z2_DESCVA  := cDescricao
	SZ2->Z2_TPREC   := SubStr(AllTrim(cTpRec),1,2)
	SZ2->Z2_DESCRE  := SubStr(AllTrim(cTpRec),4)
	SZ2->Z2_NCONTA  := SubStr(AllTrim(cNConta),1,2)
	SZ2->Z2_DESCCON := SubStr(AllTrim(cNConta),4)
	SZ2->Z2_FSUCATA := SubStr(AllTrim(cFScata),1,3)
	SZ2->Z2_DESCSUC := SubStr(AllTrim(cFScata),5)
	SZ2->(MsUnlock())

	If SZ2->Z2_TPTICK == "R"

		u_wsapp_va(.T.) //API VA Antiga 
		U_MLTAPI001(.T.) //API VA Nova 

	Endif  

	MessageBox("Destino informado com sucesso!!","Posto avancado",0)

	oDlg:End()

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function validaProduto()

	If Empty(cProduto)
		cDescricao := ""
	Else

		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))

		If SB1->(DbSeek(xFilial("SB1")+cProduto))
			cDescricao := Alltrim(SB1->B1_DESC)//+" - "+SB1->B1_TIPO+" - "+SB1->B1_UM // Vinicius N. de Oliveira - 20/03/2026 - Solicitado por Danilo
		Else
			MessageBox("Produto nao encontrado!!!","Produto",0)
			cProduto := Space(15)
			oProduto:setFocus()
			cDescricao := ""
		EndIf

	EndIf

	oProduto:Refresh()
	oDescricao:Refresh()

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function geraTicket()

	Local cCodSZ2 := ""
	Local _Placa  := SZ2->Z2_PLACA

	DbSelectArea("SZ0")
	SZ0->(DbSetOrder(1))

	If SZ0->(DbSeek(xFilial("SZ0")+cCodSZ0))
	
		cCodSZ2 := GetSXENum("SZ2","Z2_COD")

		ConfirmSX8()

		Reclock("SZ2",.T.)
		SZ2->Z2_FILIAL  := xFilial("SZ2")
		SZ2->Z2_COD     := cCodSZ2
		SZ2->Z2_CODSZ0  := cCodSZ0
		SZ2->Z2_EMISSAO := date()
		SZ2->Z2_HORA    := time()
		SZ2->Z2_PLACA   := _Placa
		SZ2->Z2_STATUS  := "2" //pesagem inicial
		SZ2->Z2_PESOI   := nPeso
		SZ2->Z2_DTPSI   := date()
		SZ2->Z2_HRPSI   := TIME()
		SZ2->Z2_TPTICK  := SZ0->Z0_TIPO
		SZ2->(MsUnlock())

		If SZ2->Z2_TPTICK == "R" .And. SZ2->Z2_FILIAL <> '0202'

			u_wsapp_va(.T.) //API VA Antiga 
			U_MLTAPI001(.T.) //API VA Nova 

		Endif 

		FwAlertSuccess("Ticket adicional "+cCodSZ2+"gerado com sucesso!!!","Ticket adicional")
	
	Else
		FwAlertError("Checklist nao localizado!!!","Ticket adicional")
	EndIf

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function vldPesoManual()

	If nPeso > 0

		If SZ2->Z2_STATUS == "1" //Aguardando pesagem inicial
			nPsIni := nPeso
		ElseIf SZ2->Z2_STATUS == "4" //Aguardando pesagem final
			nPsFin := nPeso
			nPsLiq := nPsIni-nPsFin
		EndIf

		oPsIni:Refresh()
		oPsFin:Refresh()
		oPsLiq:Refresh()
		oPeso:Refresh()

	EndIf

Return(.T.)

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function validaRnc()

	If cRNC == "S"
		cProduto := Padr("2999999",15)
		validaProduto()
	Else
		cProduto := Space(15)
	EndIf

Return

/*=================================================================
Autor: Lucas Floridi
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
User Function AXDELSZ2()

	If SZ2->Z2_STATUS == "6"
		FwAlertError("Ticket faturado nao pode ser excluido!!!","Exclusao de ticket")
		Return
	EndIf

	If SZ2->Z2_PESOF > 0
		FwAlertError("Ticket com peso final coletado nao pode ser excluido!!!","Exclusao de ticket")
		Return
	EndIf

	If !Empty(SZ2->Z2_PRODUTO)
		FwAlertError("Ticket com produto ja informado nao pode ser excluido!!!","Exclusao de ticket")
		Return
	EndIf

	DbSelectArea("SZ0")
	SZ0->(DbSetOrder(1))

	If SZ0->(DbSeek(xFilial("SZ0")+SZ2->Z2_CODSZ0))

		If SZ0->Z0_STATUS == "F"
			FwAlertError("Ticket faturado nao pode ser excluido!!!","Exclusao de ticket")
		Else
			If FWAlertYesNo("Confirma exclusao do ticket?","Confirmacao de exclusao")
				Reclock("SZ2",.F.)
				DBDelete()
				MsUnlock()
			EndIf

		EndIf

	Else
		FwAlertError("Checklist nao localizado!!!","Exclusao de checklist")
	EndIf

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 18/03/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Filtro tabelas na SX5
*==================================================================*/
Static Function xFilSX5(cTabela)

	Local aAreaSX5 := GetArea()
	Local cTemp    := GetNextAlias()
	Local cQuery   := ""
	Local aRetorno := {}

	cQuery := "SELECT * FROM "+RetSQLName("SX5")
	cQuery += " WHERE X5_FILIAL = '"+xFilial("SX5")+"'"
	cQuery += "		AND X5_TABELA = '"+cTabela+"'"
	cQuery += "		AND D_E_L_E_T_ <> '*'"

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

	aAdd(aRetorno,"")

    While !((cTemp)->(Eof()))
		
		aAdd(aRetorno,AllTrim((cTemp)->X5_CHAVE)+"-"+AllTrim((cTemp)->X5_DESCRI))

		(cTemp)->(DbSkip())

	EndDo

	RestArea(aAreaSX5)

Return(aRetorno)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Envio por lote
*==================================================================*/
User Function xEnvPar(nOpcA)

	Local aAreaSZ2  := GetArea()
	Local nRecnoSZ2 := SZ2->(Recno())
	Local nX        := 0
	Local cPerg     := Padr("WSAPPVA",10)
	Local cQuery    := ""
	Local cTemp     := GetNextAlias()
	Local aDadosFil := {}
    
    //Incluir as perguntas na tabela SX1
    AjustaSX1(cPerg)
    
    If Pergunte(cPerg,.T.)

		cQuery := " SELECT * FROM "+RetSQLName("SZ2")
		cQuery += "	WHERE Z2_EMISSAO BETWEEN '"+DToS(mv_par01)+"' AND '"+DToS(mv_par02)+"'"
		cQuery += "		AND D_E_L_E_T_ <> '*'"

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

			aAdd(aDadosFil,(cTemp)->R_E_C_N_O_)

			(cTemp)->(DbSkip())

		EndDo

		(cTemp)->(DbCloseArea())

		If Len(aDadosFil) > 0
    
			If nOpcA == 1 

				For nX := 1 To Len(aDadosFil)
					
					DbSelectArea("SZ2")
					SZ2->(DbGoTo(aDadosFil[nX]))
					
					U_app_vall(.T.)

				Next nX

			Else 

				For nX := 1 To Len(aDadosFil)

					DbSelectArea("SZ2")
					SZ2->(DbGoTo(aDadosFil[nX]))

					U_xEvLoteAPI(.T.)
				
				Next nX

			Endif

		Else 
			MsgALert("Não foram encontrados dados com os parâmetros informados!","Atenção")
		Endif 

	Endif 

	SZ2->(DbGoTo(nRecnoSZ2))

	RestArea(aAreaSZ2)

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 06/04/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Parâmetros 
*==================================================================*/
Static Function AjustaSX1(cPerg)

    Local aRegs := {}
    Local nI    := 0
    Local nJ    := 0
    
    aAdd(aRegs,{cPerg,"01","Emissão de?"  ,"","","mv_ch1","D",08,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
    aAdd(aRegs,{cPerg,"02","Emissão até?" ,"","","mv_ch2","D",08,00,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})

    DbSelectArea("SX1")
    SX1->(DbSetOrder(1))
    
    For nI := 1 To Len(aRegs)
    
        If !SX1->(DbSeek(cPerg + aRegs[nI,2]))
        
            RecLock("SX1",.T.)
            
            For nJ := 1 To FCount()

                If nJ <= Len(aRegs[nI])
                    FieldPut(nJ,aRegs[nI,nJ])
                Endif 
            
            Next nJ 
            
            SX1->(MsUnlock())
    
        Endif 
    
    Next nI

Return
