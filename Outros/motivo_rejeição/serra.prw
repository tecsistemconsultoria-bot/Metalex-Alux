#Include "totvs.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
#Define _crlf Chr(13)+Chr(10)
#Define _cTmDE0 "001"
#Define _cTmRE0 "501"
#Define _cTabRej "Z2" // INC1833293 - tabela SX5 dos motivos de rejeicao

User Function zDebugSerra()
	MsApp():New('SIGATST')
	oApp:CreateEnv()
	PtSetTheme("SUNSET")
	oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",;
		{|| RpcSetEnv("01","0201"), }),;
		U_telaSerra(),;
		Final("TERMINO NORMAL")}
	__lInternet := .T.
	lMsFinalAuto := .F.
	oApp:lMessageBar:= .T.
	oApp:cModDesc:= 'SIGATST'
	oApp:Activate()
Return Nil

User Function telaSerra()
	Local oButton1
	Local oFont18 := TFont():New("MS Sans Serif",,026,,.F.,,,,,.F.,.F.)
	Local oRadMenu1
	Local nRadSerra := 1
	Local _aSerras := {"SERRA2","SERCNC"}
	Local oSay1
	Private oDiametro
	Private oFusao
	Private oLiga
	Private oProduto
	Private oDescProduto
	Private oQtde
	Private oUsuario
	Private oNome
	Private oAngulo
	Private oComprim1
	Private oComprim2
	Private oComprimento
	Private oPesoCons
	Private oComprimCons
	Private oComprimProd
	Private oComprimSaida
	Private oDescarteCabeca
	Private oDescartePe
	Private oDesvioMax
	Private oMaxEntrada
	Private oMinEntrada
	Private oQtdePcs
	Private oPesoProd
	Private oPesoCavaco
	Private oPesoPonta
	Private oQtdeKgs
	Private oRetilin1
	Private oRetilin2
	Private oToleranciaSaida
	Private oVelocidade
	Private oLote
	Private oDtIniOP
	Private oHrIniOP
	Private oDtFinOP
	Private oHrFinOP
	Private oGetParadas
	Private dData := dDatabase
	Private dDtIniOP := dData
	Private dDtFinOP := dData
	Private cHrIniOP := "     "
	Private cHrFinOP := "     "
	Private dDtIniParada := Date()
	Private dDtFimParada := Stod('')
	Private cHrFinOP := "00:00"
	Private oDtIniParada
	Private oHrIniParada
	Private oDtFimParada
	Private oHrFimParada
	Private cOpPriorid := ""
	Private cHrIniParada := "  :  "
	Private cHrFimParada := "     "
	Private cMotParada := Space(10)
	Private cDiametro := "0"
	Private cLote := ""
	Private cFusao := Space(5)
	Private cLiga := ""
	Private cProdFusao := ""
	Private cLocalFusao := "22"
	Private cQtde := ""
	Private cUsuario := __cUserId
	Private cNome := cUserName
	Private nAngulo := 0
	Private nComprim1 := 0
	Private nComprim2 := 0
	Private nComprimento := 0
	Private nComprimSaida := 0
	Private nCompriLote := 0
	Private oPcsLote
	Private nPcsLote := 0
	Private nPesoLote := 0
	Private oPesoLote
	Private oPesoPeca
	Private nPecasLote := 0
	Private nComprimProd := 0
	Private nDescarteCabeca := 0
	Private nDescartePe := 0
	Private nDesvioMax := 0
	Private nMaxEntrada := 0
	Private nMinEntrada := 0
	Private nQtdePcs := 0
	Private nPesoCons := 0
	Private nPesoProd := 0
	Private nPesoPeca := 0
	Private nQtdeKgs := 0
	Private nRetilin1 := 0
	Private nRetilin2 := 0
	Private nToleranciaSaida := 0
	Private nVelocidade := 0
	Private nDiametro := 0
	Private cCodCavaco := Padr(Supergetmv("MX_CODCAV",.f.,"4000445"),15)
	Private cCodPonta := Padr("4000006",15)
	Private cCodRejeitado := Padr("4000442",15)
	Private nPesoCavaco := 0
	Private nPesoPonta := 0
	Private nEspessCavaco := Supergetmv("MX_ESPCAV",.f.,10)
	Private _aFator := {}
	Private oBtnSelecionar
	Private oButton1
	Private oTipoProducao
	Private nTipoProducao := "P"
	Private oFont18 := TFont():New("MS Sans Serif",,035,,.F.,,,,,.F.,.F.)
	Private oFont48 := TFont():New("MS Sans Serif",,086,,.F.,,,,,.F.,.F.)
	Private oProduto
	Private oCodDefeito
	Private oDescDefeito
	Private oGet4
	Private oObservacao
	Private oGet6
	Private oGet7
	Private cProduto      := Space(15)
	Private cDescProduto  := ""
	Private cCodDefeito   := Space(2)
	Private aMotRej       := {}
	Private cDescDefeito  := ""
	Private cObservacao   := ""
	Private oGet8
	Private nGet8 := 0
	Private oGet9
	Private nGet9 := 0
	Private oGroup1
	Private oGroup2
	Private oGroup3
	Private oGroup4
	Private oGroup5
	Private oGroup6
	Private oGroup7
	Private oSay1
	Private oSay10
	Private oSay11
	Private oSay12
	Private oSay13
	Private oSay14
	Private oSay15
	Private oSay16
	Private oSay17
	Private oSay18
	Private oSay19
	Private oSay2
	Private oSay20
	Private oSay21
	Private oSay22
	Private oSay23
	Private oSay24
	Private oSay25
	Private oSay26
	Private oSay3
	Private oSay4
	Private oSay5
	Private oSay6
	Private oSay7
	Private oSay8
	Private oSay9
	Private oFolder
	Private oDlg
	Private oRecurso
	Private cRecurso := Space(6)
	Private oGetSB8
	Private oGetPrioridades
	Private oGetSD3
	Private oGetParadas
	Private oPecasLote
	Private oComprimLote
	Private oComprimEnt
	Private oOpPriorid
	Private cOpPriorid := ""
	Private nB8_SALDO2 := 0
	Private nB8_SALDO := 0
	// dDatabase:= dData
	AADD(_aFator,0)//1
	AADD(_aFator,0)//2
	AADD(_aFator,0)//3
	AADD(_aFator,0.02181)//4
	AADD(_aFator,0.03408)//5
	AADD(_aFator,0.04907)//6
	AADD(_aFator,0.06679)//7



	DEFINE MSDIALOG oDlg TITLE "Escolha a Serra" FROM 000, 000  TO 200, 500 COLORS 0, 16777215 PIXEL

	@ 027, 010 RADIO oRadMenu1 VAR nRadSerra ITEMS "Automatica 2 - Billet","Serra CNC" SIZE 150, 033 OF oDlg COLOR 0, 16777215 PIXEL
	@ 005, 011 SAY oSay1 PROMPT "Escolha a serra para prosseguir" SIZE 150, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 068, 015 BUTTON oButton1 PROMPT "Confirmar" SIZE 037, 012 OF oDlg PIXEL Action(oDlg:End())

	ACTIVATE MSDIALOG oDlg CENTERED
	// oDlg:End()
	cRecurso := _aSerras[nRadSerra]

	DbSelectArea("SH1")
	DbSetOrder(1)
	If DbSeek(xFilial("SH1")+cRecurso)
		cMotParada := SH1->H1_XMOTPAR
		dDtIniParada := SH1->H1_XDTPARA
		cHrIniParada := SH1->H1_XHRPARA
	EndIf
	aMotRej := carregaMotivos()
	DEFINE MSDIALOG oDlg TITLE "Serra automatica" FROM 000, 000  TO 800, 1800 COLORS 0, 16777215 PIXEL

	@ 010, 005 SAY oSay26 PROMPT "Fusao:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 009, 050 MSGET oFusao VAR cFusao SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 009, 100 BUTTON oBtnSelecionar PROMPT "Atualizar" SIZE 037, 012 OF oDlg PIXEL Action(fUpdSB8())
	@ 009, 180 BUTTON oBtnSelecionar PROMPT "Selecionar" SIZE 037, 012 OF oDlg PIXEL Action(selecionarLote())
	@ 009, 230 MSGET oData VAR dData SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL when .F.
	@ 010, 280 SAY oSay26 PROMPT "Serra:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 009, 320 MSGET oRecurso VAR cRecurso SIZE 040, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "SH1" When .F.
	@ 009, 400 BUTTON oBtnFechar PROMPT "&Fechar" SIZE 042, 012 OF oDlg PIXEL Action(oDlg:end())

	@ 025, 005 SAY oSay1 PROMPT "Fusoes disponiveis:" SIZE 053, 007 OF oDlg COLORS 0, 16777215 PIXEL
	fGetSB8()
	fUpdSB8()
	fGetPrioridades()
	fUpdPrioridades()


	@ 030, 485 MSGET oLote VAR cLote SIZE 155, 060 OF oDlg COLORS 0, 16777215 FONT oFont48 PIXEL When .F.
	@ 030, 700 SAY oSay26 PROMPT "Liga:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 030, 748 MSGET oLiga VAR cLiga SIZE 080, 020 OF oDlg COLORS 0, 16777215 FONT oFont18 PIXEL When .F.
	@ 055, 700 SAY oSay26 PROMPT "Diametro:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 055, 748 MSGET oDiametro VAR cDiametro SIZE 080, 020 OF oDlg COLORS 0, 16777215 FONT oFont18 PIXEL Picture "@!" When .F.
	@ 080, 700 SAY oSay26 PROMPT "Pecas:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 080, 748 MSGET oPecasLote VAR nPecasLote SIZE 080, 020 OF oDlg COLORS 0, 16777215 FONT oFont18 PIXEL Picture "@E 9999" When .F.
	@ 105, 700 SAY oSay26 PROMPT "Comprimento:" SIZE 025, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 105, 748 MSGET oComprimLote VAR nCompriLote SIZE 080, 020 OF oDlg COLORS 0, 16777215 FONT oFont18 PIXEL Picture "@E 99999" When .F.

	@ 095, 485 SAY oSay2 PROMPT "Responsavel" SIZE 049, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 105, 485 MSGET oUsuario VAR cUsuario SIZE 035, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ 105, 525 MSGET oNome VAR cNome SIZE 140, 010 OF oDlg COLORS 0, 16777215 PIXEL

	@ 135, 485 FOLDER oFolder SIZE 350, 250 OF oDlg ITEMS "Producao","Ocorrencias","Qualidade","EPP" COLORS 0, 16777215 PIXEL
	//Producao
	@ 005, 005 SAY oSay4 PROMPT "Tipo de Producao:" SIZE 056, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 004, 060 MSCOMBOBOX oTipoProducao VAR nTipoProducao ITEMS {"P=Producao","R=Rejeicao"} SIZE 050, 010 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL Valid(validaTipoProducao())
	@ 025, 005 SAY oSay4 PROMPT "Op Prioridade:" SIZE 056, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 024, 045 MSGET oOpPriorid VAR cOpPriorid SIZE 040, 010 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL When .F.
	@ 042, 005 SAY oSay7 PROMPT "Produto:" SIZE 040, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 041, 045 MSGET oProduto VAR cProduto SIZE 042, 010 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL F3 "SG1X" Valid(validaProduto())
	@ 041, 091 MSGET oDescProduto VAR cDescProduto SIZE 137, 010 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL When .F.
	@ 060, 005 SAY oSay8 PROMPT "Motivo Rej.:" SIZE 035, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 059, 045 MSCOMBOBOX oCodDefeito VAR cCodDefeito ITEMS aMotRej SIZE 183, 010 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL // INC1833293 - sem When: o combo ficava bloqueado
	@ 074, 005 SAY oSay9 PROMPT "Observacao:" SIZE 035, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 073, 045 MSGET oObservacao VAR cObservacao SIZE 183, 010 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL


	@ 090, 005 SAY oSay21 PROMPT "Data Inicial:" SIZE 034, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 089, 040 MSGET oDtIniOP VAR dDtIniOP SIZE 050, 010 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 089, 100 MSGET oHrIniOP VAR cHrIniOP SIZE 020, 010 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL Picture "99:99"
	@ 105, 005 SAY oSay22 PROMPT "Data Final:" SIZE 034, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 104, 040 MSGET oDtFinOP VAR dDtFinOP SIZE 050, 010 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 104, 100 MSGET oHrFinOP VAR cHrFinOP SIZE 020, 010 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL Picture "99:99"

	@ 005, 140 SAY oSay6 PROMPT "Peso Peca" SIZE 040, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 004, 190 MSGET oPesoPeca VAR nPesoPeca SIZE 038, 010 OF oFolder:aDialogs[1] PICTURE "@E 99,999.99" When .F. COLORS 0, 16777215 PIXEL
	@ 005, 230 SAY oSay6 PROMPT "Comprim Entrada" SIZE 040, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 004, 290 MSGET oComprimEnt VAR nCompriLote SIZE 038, 010 OF oFolder:aDialogs[1] PICTURE "@E 9999" When .F. COLORS 0, 16777215 PIXEL
	@ 020, 140 SAY oSay6 PROMPT "Pcs Entrada" SIZE 040, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 019, 190 MSGET oPcsLote VAR nPcsLote SIZE 038, 010 OF oFolder:aDialogs[1] PICTURE "@E 99,999.99" When .F. COLORS 0, 16777215 PIXEL
	@ 020, 230 SAY oSay6 PROMPT "Peso Entrada" SIZE 040, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 019, 290 MSGET oPesoLote VAR nPesoLote SIZE 038, 010 OF oFolder:aDialogs[1] PICTURE "@E 99,999.99" When .F. COLORS 0, 16777215 PIXEL
	@ 035, 230 SAY oSay6 PROMPT "Comprim Saida" SIZE 040, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 034, 290 MSGET oComprimProd VAR nComprimProd SIZE 038, 010 OF oFolder:aDialogs[1] PICTURE "@E 9999" COLORS 0, 16777215 PIXEL valid(validaQtde()) When (nComprimProd > 1000 .AND. nTipoProducao == "P")
	@ 050, 230 SAY oSay5 PROMPT "Qtde Pecas" SIZE 040, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 049, 290 MSGET oQtdePcs VAR nQtdePcs SIZE 038, 010 OF oFolder:aDialogs[1] PICTURE "@E 999" COLORS 0, 16777215 PIXEL valid(validaQtde()) When nComprimProd > 1000
	@ 065, 230 SAY oSay5 PROMPT "Qtde KGs" SIZE 040, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 064, 290 MSGET oPesoProd VAR nPesoProd SIZE 038, 010 OF oFolder:aDialogs[1] PICTURE "@E 99,999.99" COLORS 0, 16777215 PIXEL when .F.
	@ 080, 230 SAY oSay5 PROMPT "Peso Cavaco "+cValToChar(nEspessCavaco)+"+"+cValToChar(nEspessCavaco)+" mm" SIZE 060, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 079, 290 MSGET oPesoCavaco VAR nPesoCavaco SIZE 038, 010 OF oFolder:aDialogs[1] PICTURE "@E 99,999.99" COLORS 0, 16777215 PIXEL when .F.
	@ 095, 230 SAY oSay5 PROMPT "Peso Ponta" SIZE 040, 007 OF oFolder:aDialogs[1] COLORS 0, 16777215 PIXEL
	@ 094, 290 MSGET oPesoPonta VAR nPesoPonta SIZE 038, 010 OF oFolder:aDialogs[1] PICTURE "@E 99,999.99" COLORS 0, 16777215 PIXEL when .F.
	@ 110, 253 BUTTON oButton1 PROMPT "Salvar" SIZE 037, 012 OF oFolder:aDialogs[1] PIXEL action(apontarProducao())
	fGetSD3()

	//Ocorrencias
	@ 011, 005 SAY oSay10 PROMPT "Data Inicio:" SIZE 034, 007 OF oFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
	@ 010, 050 MSGET oDtIniParada VAR dDtIniParada SIZE 060, 010 OF oFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
	@ 011, 125 SAY oSay11 PROMPT "Hora Inicio:" SIZE 035, 007 OF oFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
	@ 010, 170 MSGET oHrIniParada VAR cHrIniParada SIZE 060, 010 OF oFolder:aDialogs[2] COLORS 0, 16777215 PIXEL Picture "99:99"
	@ 026, 005 SAY oSay10 PROMPT "Data Final:" SIZE 034, 007 OF oFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
	@ 025, 050 MSGET oDtFimParada VAR dDtFimParada SIZE 060, 010 OF oFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
	@ 026, 125 SAY oSay11 PROMPT "Hora Final:" SIZE 035, 007 OF oFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
	@ 025, 170 MSGET oHrFimParada VAR cHrFimParada SIZE 060, 010 OF oFolder:aDialogs[2] COLORS 0, 16777215 PIXEL Picture "99:99"
	@ 041, 005 SAY oSay12 PROMPT "Motivo:" SIZE 025, 007 OF oFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
	@ 040, 050 MSGET oMotParada VAR cMotParada SIZE 060, 010 OF oFolder:aDialogs[2] COLORS 0, 16777215 PIXEL F3 "CYN004"
	@ 065, 010 BUTTON oBtnIniciar PROMPT "&Iniciar" SIZE 060, 012 OF oFolder:aDialogs[2] PIXEL Action(Processa({||iniciarParada(),"Efetivando inicio..."}))
	@ 065, 080 BUTTON oBtnFinalizar PROMPT "Fina&lizar" SIZE 060, 012 OF oFolder:aDialogs[2] PIXEL Action(Processa({||finalizarParada(),"Efetivando Termino..."}))
	@ 065, 160 BUTTON oBtnFinalizar PROMPT "&Excluir" SIZE 060, 012 OF oFolder:aDialogs[2] PIXEL Action(Processa({||excluirParada(),"Excluir parada..."}))
	@ 078, 005 SAY oSay13 PROMPT "Paradas:" SIZE 025, 007 OF oFolder:aDialogs[2] COLORS 0, 16777215 PIXEL
	fGetOcorrencias()
	fUpdSh6Paradas()

	@ 006, 007 SAY oSay10 PROMPT "Amostra dos Tarugos Recebidos" SIZE 088, 007 OF oFolder:aDialogs[3] COLORS 0, 16777215 PIXEL
	@ 018, 049 SAY oSay12 PROMPT "Retilineidade" SIZE 062, 007 OF oFolder:aDialogs[3] COLORS 0, 16777215 PIXEL
	@ 018, 124 SAY oSay13 PROMPT "Comprimento" SIZE 065, 007 OF oFolder:aDialogs[3] COLORS 0, 16777215 PIXEL
	@ 032, 009 SAY oSay11 PROMPT "Amostra 1" SIZE 025, 007 OF oFolder:aDialogs[3] COLORS 0, 16777215 PIXEL
	@ 030, 051 MSGET oRetilin1 VAR nRetilin1 SIZE 060, 010 OF oFolder:aDialogs[3] PICTURE "@E 99.99" COLORS 0, 16777215 PIXEL
	@ 029, 122 MSGET oComprim1 VAR nComprim1 SIZE 060, 010 OF oFolder:aDialogs[3] PICTURE "@E 9999" COLORS 0, 16777215 PIXEL
	@ 049, 009 SAY oSay14 PROMPT "Amostra 2" SIZE 025, 007 OF oFolder:aDialogs[3] COLORS 0, 16777215 PIXEL
	@ 047, 050 MSGET oRetilin2 VAR nRetilin2 SIZE 060, 010 OF oFolder:aDialogs[3] PICTURE "@E 99.99" COLORS 0, 16777215 PIXEL
	@ 047, 122 MSGET oComprim2 VAR nComprim2 SIZE 060, 010 OF oFolder:aDialogs[3] PICTURE "@E 9999" COLORS 0, 16777215 PIXEL

	//EPP
	@ 008, 010 GROUP oGroup2 TO 060, 102 PROMPT "Entrada da Serra (mm)" OF oFolder:aDialogs[4] COLOR 0, 16777215 PIXEL
	@ 020, 015 SAY oSay15 PROMPT "Min" SIZE 025, 007 OF oGroup2 COLORS 0, 16777215 PIXEL
	@ 035, 015 MSGET oMinEntrada VAR nMinEntrada SIZE 029, 010 OF oGroup2 PICTURE "@E 9999" COLORS 0, 16777215 PIXEL
	@ 020, 053 SAY oSay16 PROMPT "Max" SIZE 025, 007 OF oGroup2 COLORS 0, 16777215 PIXEL
	@ 035, 053 MSGET oMaxEntrada VAR nMaxEntrada SIZE 029, 010 OF oGroup2 PICTURE "@E 9999" COLORS 0, 16777215 PIXEL

	@ 075, 010 GROUP oGroup3 TO 126, 103 PROMPT "Comprimento de Saida" OF oFolder:aDialogs[4] COLOR 0, 16777215 PIXEL
	@ 087, 015 SAY oSay19 PROMPT "Comprim." SIZE 025, 007 OF oGroup3 COLORS 0, 16777215 PIXEL
	@ 102, 015 MSGET oComprimSaida VAR nComprimSaida SIZE 029, 010 OF oGroup3 COLORS 0, 16777215 PIXEL
	@ 087, 053 SAY oSay20 PROMPT "Tolerancia (mm)" SIZE 025, 007 OF oGroup3 COLORS 0, 16777215 PIXEL
	@ 102, 053 MSGET oToleranciaSaida VAR nToleranciaSaida SIZE 029, 010 OF oGroup3 COLORS 0, 16777215 PIXEL

	@ 145, 010 GROUP oGroup4 TO 199, 102 PROMPT "Retilineidade" OF oFolder:aDialogs[4] COLOR 0, 16777215 PIXEL
	@ 157, 015 SAY oSay17 PROMPT "Comprim." SIZE 025, 007 OF oGroup4 COLORS 0, 16777215 PIXEL
	@ 172, 015 MSGET oGet8 VAR nGet8 SIZE 029, 010 OF oGroup4 COLORS 0, 16777215 PIXEL
	@ 157, 053 SAY oSay18 PROMPT "Desv Max (mm)" SIZE 041, 007 OF oGroup4 COLORS 0, 16777215 PIXEL
	@ 172, 053 MSGET oGet9 VAR nGet9 SIZE 029, 010 OF oGroup4 COLORS 0, 16777215 PIXEL

	@ 008, 136 GROUP oGroup5 TO 061, 229 PROMPT "Avanco da Serra" OF oFolder:aDialogs[4] COLOR 0, 16777215 PIXEL
	@ 020, 141 SAY oSay21 PROMPT "Velocidade" SIZE 038, 007 OF oGroup5 COLORS 0, 16777215 PIXEL
	@ 035, 141 MSGET oVelocidade VAR nVelocidade SIZE 029, 010 OF oGroup5 COLORS 0, 16777215 PIXEL

	@ 075, 136 GROUP oGroup6 TO 128, 227 PROMPT "Descarte das Pontas (mm)" OF oFolder:aDialogs[4] COLOR 0, 16777215 PIXEL
	@ 087, 141 SAY oSay22 PROMPT "Pe >" SIZE 038, 007 OF oGroup6 COLORS 0, 16777215 PIXEL
	@ 102, 141 MSGET oDescartePe VAR nDescartePe SIZE 029, 010 OF oGroup6 COLORS 0, 16777215 PIXEL
	@ 087, 180 SAY oSay23 PROMPT "Cabeca >" SIZE 038, 007 OF oGroup6 COLORS 0, 16777215 PIXEL
	@ 102, 180 MSGET oDescarteCabeca VAR nDescarteCabeca SIZE 029, 010 OF oGroup6 COLORS 0, 16777215 PIXEL

	@ 145, 136 GROUP oGroup7 TO 199, 226 PROMPT "Perpendicularidade" OF oFolder:aDialogs[4] COLOR 0, 16777215 PIXEL
	@ 157, 141 SAY oSay24 PROMPT "Angulo" SIZE 038, 007 OF oGroup7 COLORS 0, 16777215 PIXEL
	@ 172, 141 MSGET oAngulo VAR nAngulo SIZE 029, 010 OF oGroup7 COLORS 0, 16777215 PIXEL
	@ 157, 180 SAY oSay25 PROMPT "Desvio Max" SIZE 038, 007 OF oGroup7 COLORS 0, 16777215 PIXEL
	@ 172, 180 MSGET oDesvioMax VAR nDesvioMax SIZE 029, 010 OF oGroup7 COLORS 0, 16777215 PIXEL

	ACTIVATE MSDIALOG oDlg CENTERED

Return

//------------------------------------------------
Static Function fGetSB8()
	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"C2_OK","C2_OP","B8_LOTECTL","B1_XGRLIGA","B1_XVARIAN","B1_XBITOLA","H6_XCOMPRI","B1_XCOMPRI","B8_SALDO2","B8_SALDO","C2_PRODUTO","C2_DATPRI","B8_DATA","B8_EMPENHO","H6_QTDPROD","H6_QTDPRO2","B8_PRODUTO"}
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

	oGetSB8 := MsNewGetDados():New( 035, 004, 255, 480, /*GD_INSERT+GD_DELETE+*/GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
	oGetSB8:oBrowse:blDblClick := {||selecionarLote()}
	oGetSB8:oBrowse:lUseDefaultColors := .F.
	oGetSB8:oBrowse:SetBlkBackColor({|| fTrocaCor(oGetSB8:nAt)[1]})
	oGetSB8:oBrowse:SetBlkColor({|| fTrocaCor(oGetSB8:nAt)[2]})

Return

Static Function fTrocaCor(nLinha)

	Local nCorFundo, nCorTexto
	Local nLine  := nLinha
	Local nPosFusao := aScan(oGetSB8:aHeader, {|x| x[2] == "B8_LOTECTL"})
	Local nPosEmp := aScan(oGetSB8:aHeader, {|x| x[2] == "B8_EMPENHO"})
	Local nPosOk := aScan(oGetSB8:aHeader, {|x| x[2] == "C2_OK"})

	If oGetSB8:aCols[nLine, nPosEmp] >0
		nCorFundo := CLR_RED
		nCorTexto := CLR_WHITE
	ElseIf oGetSB8:aCols[nLine, nPosEmp] >0
		nCorFundo := CLR_RED
		nCorTexto := CLR_WHITE
	Elseif oGetSB8:aCols[nLine, nPosFusao] == cLote
		nCorFundo := CLR_YELLOW
		nCorTexto := CLR_BLACK
	Else /*Amarelo*/
		nCorFundo := CLR_WHITE
		nCorTexto := CLR_BLACK
	EndIf
	// oGetSB8:Refresh()
Return{nCorFundo,nCorTexto}

Static Function fGetPrioridades()
	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"C2_OP","C2_PRODUTO","B1_XBITOLA","B1_XCOMPRI","C2_QUANT","C2_QTSEGUM","C2_QUJE","C2_OBS"}
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

	oGetPrioridades := MsNewGetDados():New( 270, 004, 350, 480, /*GD_INSERT+GD_DELETE+*/GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
	// oGetPrioridades:oBrowse:blDblClick := {||selecionarLote()}
	// oGetPrioridades:oBrowse:lUseDefaultColors := .F.
	// oGetPrioridades:oBrowse:SetBlkBackColor({|| fTrocaCor(oGetSB8:nAt)[1]})
	// oGetPrioridades:oBrowse:SetBlkColor({|| fTrocaCor(oGetSB8:nAt)[2]})

Return


//------------------------------------------------
Static Function fGetSD3()
	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"D3_COD","D3_TM","D3_LOTECTL","B1_DESC","D3_UM","D3_QUANT","D3_USUARIO","D3_EMISSAO","D3_NUMSEQ"}
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

	oGetSD3 := MsNewGetDados():New( 150, 003, 220, 341, /*GD_INSERT+GD_DELETE+*/GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oFolder:aDialogs[1], aHeaderEx, aColsEx)

Return

Static Function fGetOcorrencias()
	//------------------------------------------------
	Local nX
	Local aHeaderEx := {}
	Local aColsEx := {}
	Local aFieldFill := {}
	Local aFields := {"H6_OP","H6_MOTIVO","H6_DATAINI","H6_HORAINI","H6_DATAFIN","H6_HORAFIN","H6_TEMPO","H6_IDENT"}
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
	aAdd(aHeaderEx, {"Recno",         "XX_RECNO",  "",  012,                      0,                        ".T.",              ".T.", "N", "",    ""} )
	// Define field values
	For nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			Aadd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif
	Next nX
	Aadd(aFieldFill, 0)
	Aadd(aFieldFill, .F.)
	Aadd(aColsEx, aFieldFill)

	oGetParadas := MsNewGetDados():New( 085, 007, 170, 400, GD_INSERT+GD_DELETE+GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oFolder:aDialogs[2], aHeaderEx, aColsEx)

Return

Static Function fUpdSB8()

	Local cQry := ""
	Local _aLinha := {}
	Local _x := 0
	cQry := "SELECT '' C2_OK,C2_NUM+C2_ITEM+C2_SEQUEN C2_OP,ISNULL(C2_DATPRI,'20491231') C2_DATPRI,C2_PRODUTO, B8_PRODUTO,B8_LOTECTL,B8_SALDO,B8_EMPENHO,B8_SALDO2,B8_DATA,B8_LOCAL,SB1.B1_XGRLIGA,SB1.B1_XVARIAN,SB1.B1_XBITOLA,ISNULL(SB1X.B1_XCOMPRI,SB1.B1_XCOMPRI) B1_XCOMPRI,H6_XCOMPRI,H6_QTDPROD,H6_QTDPRO2 " + _crlf
	cQry += "FROM "+RetSQLName("SB8")+" SB8 " + _crlf
	cQry += "   INNER JOIN "+RetSQLName("SH6") +" SH6 ON SH6.D_E_L_E_T_='' AND B8_PRODUTO=H6_PRODUTO AND H6_LOTECTL=B8_LOTECTL " + _crlf //AND B1_FILIAL=SUBSTRING(C2_FILIAL,1,2)
	cQry += "   LEFT JOIN "+RetSQLName("SG1") +" SG1 ON SG1.D_E_L_E_T_='' AND SUBSTRING(B8_FILIAL,1,2)=G1_FILIAL AND G1_COMP=B8_PRODUTO " + _crlf //AND B1_FILIAL=SUBSTRING(C2_FILIAL,1,2)
	cQry += "   LEFT JOIN "+RetSQLName("SB1") +" SB1 ON SB1.D_E_L_E_T_='' AND SB1.B1_FILIAL=SUBSTRING(G1_FILIAL,1,2) AND SB1.B1_COD=G1_COD  " + _crlf //AND B1_FILIAL=SUBSTRING(C2_FILIAL,1,2)
	cQry += "   LEFT JOIN "+RetSQLName("SC2") +" SC2 ON SC2.D_E_L_E_T_='' AND C2_FILIAL=B8_FILIAL AND C2_PRODUTO=G1_COD AND C2_DATRF='' AND C2_RECURSO='"+cRecurso+"' "  + _crlf //AND B1_FILIAL=SUBSTRING(C2_FILIAL,1,2)
	cQry += "   LEFT JOIN "+RetSQLName("SB1") +" SB1X ON SB1X.D_E_L_E_T_='' AND SB1X.B1_COD=C2_PRODUTO AND SUBSTRING(C2_FILIAL,1,2)=SB1X.B1_FILIAL  " + _crlf //AND B1_FILIAL=SUBSTRING(C2_FILIAL,1,2)
	cQry += "WHERE SB8.D_E_L_E_T_='' AND B8_FILIAL='"+cFilAnt+"' AND B8_SALDO>0 " + _crlf
	cQry += "AND B8_LOCAL='"+cLocalFusao+"' " + _crlf
	If !Empty(cFusao)
		cQry += " AND B8_LOTECTL = '"+cFusao+"'" +_crlf
	EndIf
	cQry += "ORDER BY ISNULL(C2_DATPRI,'20491231') , B8_DATA " + _crlf
	conout(cQry)
	TcQuery cQry New Alias "SB8X"
	TCSetField("SB8X","C2_DATPRI","D",/*nSize*/,/*nPrecision*/)
	TCSetField("SB8X","B8_DATA","D",/*nSize*/,/*nPrecision*/)
	DbSelectArea("SB8X")
	DbGotop()
	_aStru := oGetSB8:aHeader
	If  !SB8X->(Eof())
		oGetSB8:aCols := {}
		While !SB8X->(Eof())
			_aLinha := {}
			For _x := 1 to len(_aStru)
				_cCpo := _aStru[_x,2]
				AADD(_aLinha,SB8X->&(_cCpo))
			Next
			AADD(_aLinha,.F.)
			AADD(oGetSB8:aCols,_aLinha)
			SB8X->(DbSkip())
		EndDo
	Else
		oGetSB8:aCols := {}
		For _x := 1 to len(_aStru)
			_cCpo := _aStru[_x,2]
			AADD(_aLinha,criavar(_cCpo))
		Next
		AADD(_aLinha,.F.)
		AADD(oGetSB8:aCols,_aLinha)
	EndIf
	SB8X->(DbCloseArea())
	oGetSB8:Refresh()
Return
Static Function fUpdPrioridades()

	Local cQry := ""
	Local _aLinha := {}
	Local _x := 0
	cQry := "SELECT '' C2_OK,C2_XSEQ,C2_RECURSO,C2_NUM+C2_ITEM+C2_SEQUEN C2_OP,C2_LOCAL,C2_XFUSAO,C2_PRODUTO,B1_DESC,B1_XBITOLA,B1_XCOMPRI,B1_XGRLIGA,B1_XVARIAN,B1_TIPO,C2_EMISSAO,C2_DATPRI,C2_DATPRF,C2_DATRF,C2_QUANT,C2_QUJE,C2_QTSEGUM,C2_OBS,C2_XDTPROD,C2_XOPDEST,C2_XSH1DES,C2_XJUSTIF " + _crlf
	cQry += "FROM "+RetSQLName("SC2")+" SC2 " + _crlf
	cQry += "   INNER JOIN "+RetSQLName("SB1") +" SB1 ON SB1.D_E_L_E_T_='' AND B1_COD=C2_PRODUTO  " + _crlf //AND B1_FILIAL=SUBSTRING(C2_FILIAL,1,2)
	cQry += "WHERE SC2.D_E_L_E_T_='' AND C2_FILIAL='"+cFilAnt+"' " + _crlf
	cQry += "AND C2_RECURSO='"+cRecurso+"' "
	cQry += "AND EXISTS (SELECT 1 FROM SG2010 SG2 "
	cQry += "WHERE SG2.D_E_L_E_T_='' AND G2_FILIAL=C2_FILIAL "
	cQry += "AND G2_OPERAC='30' AND G2_PRODUTO=C2_PRODUTO) " + _crlf
	cQry += "AND C2_DATRF='' " + _crlf
	cQry += "ORDER BY C2_DATPRI,C2_NUM,C2_RECURSO  " + _crlf
	conout(cQry)
	TcQuery cQry New Alias "SC2X"
	TCSetField("SC2X","C2_EMISSAO","D",/*nSize*/,/*nPrecision*/)
	TCSetField("SC2X","C2_DATPRI","D",/*nSize*/,/*nPrecision*/)
	TCSetField("SC2X","C2_DATPRF","D",/*nSize*/,/*nPrecision*/)
	TCSetField("SC2X","C2_DATRF","D",/*nSize*/,/*nPrecision*/)
	TCSetField("SC2X","C2_XDTPROD","D",/*nSize*/,/*nPrecision*/)
	TCSetField("SC2X","C2_XDTPAR","D",/*nSize*/,/*nPrecision*/)
	DbSelectArea("SC2X")
	DbGotop()
	_aStru := oGetPrioridades:aHeader
	If  !SC2X->(Eof())
		oGetPrioridades:aCols := {}
		While !SC2X->(Eof())
			_aLinha := {}
			For _x := 1 to len(_aStru)
				_cCpo := _aStru[_x,2]
				AADD(_aLinha,SC2X->&(_cCpo))
			Next
			AADD(_aLinha,.F.)
			AADD(oGetPrioridades:aCols,_aLinha)
			SC2X->(DbSkip())
		EndDo
	Else
		oGetPrioridades:aCols := {}
		For _x := 1 to len(_aStru)
			_cCpo := _aStru[_x,2]
			AADD(_aLinha,criavar(_cCpo))
		Next
		AADD(_aLinha,.F.)
		AADD(oGetPrioridades:aCols,_aLinha)
	EndIf
	SC2X->(DbCloseArea())
	oGetPrioridades:Refresh()
Return

Static Function fUpdsd3()

	Local cQry := ""
	Local _aLinha := {}
	Local _x := 0
	cQry := "SELECT D3_COD,D3_TM,B1_DESC,D3_UM,D3_QUANT,D3_TM,D3_USUARIO,D3_EMISSAO,D3_DOC,D3_NUMSEQ,D3_LOTECTL " + _crlf
	cQry += "FROM "+RetSQLName("SD3")+" SD3 " + _crlf
	cQry += "   INNER JOIN "+RetSQLName("SB1") +" SB1 ON SB1.D_E_L_E_T_='' AND B1_COD=D3_COD  " + _crlf //AND B1_FILIAL=SUBSTRING(C2_FILIAL,1,2)
	cQry += "WHERE SD3.D_E_L_E_T_='' AND D3_FILIAL='"+cFilAnt+"' AND D3_LOTECTL='"+cLote+"' AND D3_ESTORNO<>'S' " + _crlf
	// cQry += "AND D3_CF='PR0' " + _crlf
	cQry += "ORDER BY D3_NUMSEQ " + _crlf
	conout(cQry)
	TcQuery cQry New Alias "SD3X"
	TCSetField("SD3X","D3_EMISSAO","D",/*nSize*/,/*nPrecision*/)
	DbSelectArea("SD3X")
	DbGotop()
	_aStru := oGetSD3:aHeader
	If  !SD3X->(Eof())
		oGetSD3:aCols := {}
		While !SD3X->(Eof())
			_aLinha := {}
			For _x := 1 to len(_aStru)
				_cCpo := _aStru[_x,2]
				AADD(_aLinha,SD3X->&(_cCpo))
			Next
			AADD(_aLinha,.F.)
			AADD(oGetSD3:aCols,_aLinha)
			SD3X->(DbSkip())
		EndDo
	Else
		oGetSD3:aCols := {}
		For _x := 1 to len(_aStru)
			_cCpo := _aStru[_x,2]
			AADD(_aLinha,criavar(_cCpo))
		Next
		AADD(_aLinha,.F.)
		AADD(oGetSD3:aCols,_aLinha)
	EndIf
	SD3X->(DbCloseArea())
	oGetSD3:Refresh()
Return

Static Function fUpdSh6Paradas()

	Local cQry := ""
	Local _aLinha := {}
	Local _x := 0
	cQry := "SELECT H6_RECURSO,H6_MOTIVO,H6_OPERADO,H6_OP,H6_DATAINI,H6_HORAINI,H6_DATAFIN,H6_HORAFIN,H6_TEMPO,H6_LOCAL,H6_IDENT,R_E_C_N_O_ XX_RECNO " + _crlf
	cQry += "FROM "+RetSQLName("SH6")+" SH6 " + _crlf
	cQry += "WHERE SH6.D_E_L_E_T_='' AND H6_FILIAL='"+cFilAnt+"' AND H6_DATAINI>='"+DTOS(DATE()-1)+"'  AND H6_RECURSO='"+cRecurso+"' " + _crlf
	cQry += "AND H6_TIPO='I' " + _crlf
	cQry += "ORDER BY H6_DATAINI DESC " + _crlf
	conout(cQry)
	TcQuery cQry New Alias "SH6X"
	TCSetField("SH6X","H6_DATAINI","D",/*nSize*/,/*nPrecision*/)
	TCSetField("SH6X","H6_DATAFIN","D",/*nSize*/,/*nPrecision*/)
	DbSelectArea("SH6X")
	DbGotop()
	_aStru := oGetParadas:aHeader
	If  !SH6X->(Eof())
		oGetParadas:aCols := {}
		While !SH6X->(Eof())
			_aLinha := {}
			For _x := 1 to len(_aStru)
				_cCpo := _aStru[_x,2]
				AADD(_aLinha,SH6X->&(_cCpo))
			Next
			AADD(_aLinha,.F.)
			AADD(oGetParadas:aCols,_aLinha)
			SH6X->(DbSkip())
		EndDo
	Else
		oGetParadas:aCols := {}
		For _x := 1 to len(_aStru)
			_cCpo := Alltrim(_aStru[_x,2])
			If _cCpo == "XX_RECNO"
				AADD(_aLinha,0)
			Else
				AADD(_aLinha,criavar(_cCpo))
			EndIf
		Next
		AADD(_aLinha,.F.)
		AADD(oGetParadas:aCols,_aLinha)
	EndIf
	SH6X->(DbCloseArea())
	oGetParadas:Refresh()
Return


// 20/10/2026 FixSystem - Leonardo Barboza Ribeiro Leite: INC1833293 - limpa o motivo de rejeicao ao trocar de lote
Static Function selecionarLote()
	Local _x := 0
	Local oB8_SALDO2
	Local oDlgSelecao
	Private aCols := oGetSB8:aCols
	Private aHeader := oGetSB8:aHeader
	Private n := oGetSB8:nAt
	nTipoProducao := "P"
	oTipoProducao:Refresh()
	limpaMotivo()
	nQtdePcs := 0
	cOpPriorid  := GdFieldGEt("C2_OP")
	cProdFusao  := GdFieldGEt("B8_PRODUTO")
	cLote       := GdFieldGEt("B8_LOTECTL")
	// cLocalFusao := GdFieldGEt("B8_LOCAL")
	cLiga       := GdFieldGEt("B1_XGRLIGA")
	nDiametro   := GdFieldGEt("B1_XBITOLA")
	cDiametro   := cValToChar(nDiametro)
	cQtde       := "Pecas/Compr: "+cValToChar(GdFieldGEt("B8_SALDO2")) +"/"+ cValToChar(GdFieldGEt("H6_XCOMPRI"))
	nCompriLote := GdFieldGEt("H6_XCOMPRI")
	nComprimProd := GdFieldGEt("B1_XCOMPRI")
	// nCompriLote := GdFieldGEt("B1_XCOMPRI")
	nB8_SALDO2 := GdFieldGEt("B8_SALDO2")
	nB8_SALDO := GdFieldGEt("B8_SALDO")
	If nComprimProd < 1000
		While .T.
			DEFINE MSDIALOG oDlgSelecao TITLE "Fusao de entrada" FROM 000, 000  TO 300, 500 COLORS 0, 16777215 PIXEL
			@ 005, 005 SAY oSay2 PROMPT "Pecas disponiveis:" SIZE 050, 007 OF oDlgSelecao COLORS 0, 16777215 PIXEL
			@ 004, 060 MSGET oB8_SALDO2 VAR nB8_SALDO2 SIZE 040, 010 OF oDlgSelecao COLORS 0, 16777215 PIXEL PICTURE "9999" when .F.
			@ 005, 105 SAY oSay2 PROMPT "Peso disponivel (kgs):" SIZE 050, 007 OF oDlgSelecao COLORS 0, 16777215 PIXEL
			@ 004, 160 MSGET oB8_SALDO2 VAR nB8_SALDO SIZE 040, 010 OF oDlgSelecao COLORS 0, 16777215 PIXEL PICTURE "9999" when .F.
			@ 020, 005 SAY oSay2 PROMPT "Pecas desejadas:" SIZE 065, 007 OF oDlgSelecao COLORS 0, 16777215 PIXEL
			@ 019, 060 MSGET oB8_SALDO2 VAR nPecasLote SIZE 040, 010 OF oDlgSelecao COLORS 0, 16777215 PIXEL PICTURE "9999" Valid(nPesoLote:=nB8_SALDO/nB8_SALDO2*nPecasLote)
			@ 020, 105 SAY oSay2 PROMPT "Peso desejado (kgs):" SIZE 050, 007 OF oDlgSelecao COLORS 0, 16777215 PIXEL
			@ 019, 160 MSGET oB8_SALDO2 VAR nPesoLote SIZE 040, 010 OF oDlgSelecao COLORS 0, 16777215 PIXEL PICTURE "9999" when .F.
			@ 035, 004 BUTTON oBtnSalvar PROMPT "&Confirmar" SIZE 072, 025 OF oDlgSelecao PIXEL Action (oDlgSelecao:End())
			ACTIVATE MSDIALOG oDlgSelecao CENTERED
			If nPecasLote > 0
				If nPecasLote > nB8_SALDO2
					FwalertInfo("Numero de pecas informado maior que o saldo disponivel","Validacao de quantidade")
				Else
					nPcsLote := nPecasLote
					oPcsLote:Refresh()
					Exit
				EndIf
			Else
				FwalertInfo("Informe a quantidade de pecas desejadas para prosseguir","Quantidade de pecas")
			EndIf
		EndDo


		// nPesoLote   := GdFieldGEt("B8_SALDO")/GdFieldGEt("B8_SALDO2")
		// nPecasLote  := 1
	Else
		nPesoLote   := GdFieldGEt("B8_SALDO")
		// nQtdePcs	:= GdFieldGEt("B8_SALDO2")
		nPecasLote  := GdFieldGEt("B8_SALDO2")
	EndIf
	nPesoPeca   := GdFieldGEt("B8_SALDO") / GdFieldGEt("B8_SALDO2")
	For _x := 1 to len(oGetSB8:aCols)
		oGetSB8:aCols[_x,1] := ""
	Next
	oGetSB8:aCols[oGetSB8:nAt,1] := "==>"
	oGetSB8:Refresh()
	If !Empty(GdFieldGEt("C2_PRODUTO"))
		cProduto := GdFieldGEt("C2_PRODUTO")
		DbSelectArea("SB1")
		DbSetOrder(1)
		DbSeek(xFilial("SB1")+cProduto)
		cDescProduto := SB1->B1_DESC
	Else
		DbSelectArea("SG1")
		DbSetOrder(2)
		If DbSeek(xFilial("SG1")+cProdFusao)
			cProduto    := SG1->G1_COD
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+cProduto)
			cDescProduto := SB1->B1_DESC
		Else
			cProduto        := Space(15)
			cDescProduto    := Space(15)
		EndIf
	EndIf
	If nComprimProd < 1000
		nQtdePcs := noround(nCompriLote/nComprimProd,0)*nPcsLote
	EndIf
	validaQtde()
	oProduto:Refresh()
	oDescProduto:Refresh()
	oComprimLote:Refresh()
	oComprimProd:Refresh()
	oComprimEnt:Refresh()
	oPecasLote:Refresh()
	oPesoLote:Refresh()
	oLote:Refresh()
	oLiga:Refresh()
	oDiametro:Refresh()
	oQtdePcs:Refresh()
	// oQtde:Refresh()
	fUpdSD3()
Return

// 20/10/2026 FixSystem - Leonardo Barboza Ribeiro Leite: INC1833293 - valida e grava o motivo de rejeicao (D3_XMOTREJ)
Static Function apontarProducao()

	Local aMATA650 := {} //-Array com os campos
	Local cMotRej := codMotivo(cCodDefeito, aMotRej) // INC1833293 - so aceita motivo que exista na tabela Z2
	Local nRecIni := 0 // 18/11/2026 FixSystem: INC1833293 - ultimo recno da SD3 antes dos movimentos da rejeicao
	//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
	//³ 3 - Inclusao ³
	//³ 4 - Alteracao ³
	//³ 5 - Exclusao ³
	//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
	Local nOpc := 3
	Private lMsErroAuto := .F.
	if dDtIniOP < DATE()-1
		FwalertInfo("Data de producao nao pode ser menor que ontem!!!","Data de producao invalida")
		Return
	EndIf
	if dDtFinOP > DATE()
		FwalertInfo("Data de producao nao pode ser maior que hoje!!!","Data de producao invalida")
		Return
	EndIf
	If cHrFinOP > substr(time(),1,5)
		FwalertInfo("Hora final nao pode ser maior que a hora atual!!!","Hora final invalida")
		Return
	EndIf
	If nPesoPonta<0
		FwalertInfo("Peso da ponta nao pode ser negativo!!!","Validacao de peso da ponta")
		Return
	EndIf
	If !validaRejeicao(nTipoProducao, cMotRej)
		Return
	EndIf

	if nRetilin1 <=0
		FwalertInfo("Retiliniedade 1 deve ser informada!!!","Validacao")
		Return
	EndIf

	If nRetilin2 <=0
		FwalertInfo("Retiliniedade 2 deve ser informada!!!","Validacao")
		Return
	Endif

	cHrFinOP := inctime(time(),0,nQtdePcs,0)
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+cProduto)
	If nTipoProducao == "P"
		If !SB1->B1_RASTRO == "L"
			FwalertInfo("O produto selecionado nao controla lote e deveria controlar!!!","Rastreabilidade do produto produzido!!")
			Return
		EndIf
	EndIf
	If !FWAlertYesNo("Confirma apontamento da producao??","Apontamento de producao")
		Return
	EndIf

	If nComprimProd > nCompriLote
		FwalertInfo("Comprimento da producao nao pode ser maior que o comprimento do lote selecionado","Validacao de comprimento")
		Return .T.
	EndIf

	If nPesoCons>nPesoProd
		If nPesoCavaco < 0
			nPesoCavaco := 0
			nPesoPonta := nPesoCons-nPesoProd
		EndIf
		If nPesoPonta < 0
			nPesoPonta := 0
			nPesoCavaco := nPesoCons-nPesoProd
		EndIf
		If (nPesoCons-nPesoProd-nPesoPonta) > 0
			nPesoCavaco := nPesoCons-nPesoProd-nPesoPonta
		EndIf
	Else
		nPesoProd := nPesoCons
		nPesoCavaco := 0
		nPesoPonta := 0
	EndIf


	Begin Transaction
		If nTipoProducao == "R"
			_cDocSuc := NextNumero("SD3", 2, "D3_DOC", .T.)
			nRecIni := ultimoRecSD3()
			_cOpSuc := ""
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+cProdFusao)
			If !MTA241("501",cProdFusao,cLocalFusao,nPesoCons,nQtdePcs,_cOpSuc,cLote,_cDocSuc)
				DisarmTransaction()   // Desfaz a transação em caso de erro
				Return
			EndIf
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+cCodRejeitado)
			If !MTA241("001",cCodRejeitado,SB1->B1_LOCPAD,nPesoProd,0,_cOpSuc,"",_cDocSuc)
				DisarmTransaction()
				Return
			EndIf
			// 11/11/2026 FixSystem - Leonardo Barboza Ribeiro Leite: INC1833293 - grava o motivo de rejeicao nos movimentos do documento (sem OP no fluxo novo)
			// 11/11/2026 FixSystem: INC1833293 - sem motivo gravado na SD3 a rejeicao e desfeita
			// 18/11/2026 FixSystem: INC1833293 - localiza os movimentos pelo recno/TM/produto/armazem, nao pelo D3_DOC
			If !gravaMotivo(nRecIni, {{"501", cProdFusao, cLocalFusao}, {"001", cCodRejeitado, Posicione("SB1", 1, xFilial("SB1") + cCodRejeitado, "B1_LOCPAD")}}, _cDocSuc, cMotRej)
				DisarmTransaction()
				Return
			EndIf
			limpaMotivo()
		Else
			If Empty(cOpPriorid)
				aMATA650 := {}
				aadd(aMATA650,{'C2_FILIAL' ,"01" ,NIL})
				// aadd(aMATA650,{'C2_NUM' ,"000060" ,NIL})
				// aadd(aMATA650,{'C2_ITEM' ,"01" ,NIL})
				// aadd(aMATA650,{'C2_SEQUEN' ,"001" ,NIL})
				aadd(aMATA650,{'C2_PRODUTO' ,cProduto ,NIL})
				aadd(aMATA650,{'C2_LOCAL'   ,SB1->B1_LOCPAD ,NIL})
				aadd(aMATA650,{'C2_QUANT'   ,nPesoProd ,NIL})
				aadd(aMATA650,{'C2_QTSEGUM' ,nQtdePcs ,NIL})
				aadd(aMATA650,{'C2_DATPRI'  ,dData ,NIL})
				aadd(aMATA650,{'C2_DATPRF'  ,dData ,NIL})
				aadd(aMATA650,{'C2_BATCH' ,'S' ,NIL})
				aadd(aMATA650,{'AUTEXPLODE' ,"N" ,NIL})

				//ÚÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄ¿
				//³ Se alteracao ou exclusao, deve-se posicionar no registro ³
				//³ da SC2 antes de executar a rotina automatica ³
				//ÀÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÄÙ
				msExecAuto({|x,Y| Mata650(x,Y)},aMata650,nOpc)
			EndIf
			If !lMsErroAuto
				ConOut("Sucesso! ")
				If Empty(cOpPriorid).or. nTipoProducao == "R"
					_cOpSerra := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)
				Else
					_cOpSerra := cOpPriorid
				EndIf

				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+cProdFusao)
				If !MTA241(_cTmRE0,cProdFusao,cLocalFusao,nPesoCons,nQtdePcs,_cOpSerra,cLote,"")
					DisarmTransaction()   // Desfaz a transação em caso de erro
					Return
				EndIf
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+cCodCavaco)
				If nPesoCavaco > 0
					If !MTA241(_cTmDE0,cCodCavaco,SB1->B1_LOCPAD,nPesoCavaco,0,_cOpSerra,"")
						DisarmTransaction()
						Return
					EndIf
				EndIf
				DbSelectArea("SB1")
				DbSetOrder(1)
				DbSeek(xFilial("SB1")+cCodPonta)
				If nPesoPonta>0
					If !MTA241(_cTmDE0,cCodPonta,SB1->B1_LOCPAD,nPesoPonta,0,_cOpSerra,"")
						DisarmTransaction()
						Return
					EndIf
				EndIf
				If !MTA681(_cOpSerra)
					DisarmTransaction()   // Desfaz a transação em caso de erro
				Else
					nComprimProd := 0
					nQtdePcs    := 0
					validaQtde()
					fUpdSB8()
					fUpdPrioridades()
				EndIf
			Else
				ConOut("Erro!")
				MostraErro("\dirdoc\","error_mata650.log")
			EndIf
		EndIf

	End Transaction
	fwAlertSuccess("Apontamento realizado com sucesso!!!","Apontamento")
	// u_tEnvMail('lucas@fixsystem.com.br',"Apontamento de producao - Serra","Apontamento realizado pela op",{})

Return


Static Function MTA241(_cParTM,_cParCod,_cParLocal,_nParQt1um,_nParQt2um,_cParOp,_cParLote,_cParDocSuc)
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
	dData := dData

	_aCab1 := {}

	If !Empty(_cParDocSuc)
		AADD(_aCab1,{"D3_DOC", _cParDocSuc, NIL}) // Número do documento (gerado automaticamente)
	Else
		AADD(_aCab1,{"D3_DOC", _cParOp, NIL}) // Número do documento (gerado automaticamente)
	EndIf
	AADD(_aCab1,{"D3_TM", _cParTM, NIL})                            // Tipo de movimento
	AADD(_aCab1,{"D3_CC", "        ", NIL})                           // Centro de custo (vazio)
	AADD(_aCab1,{"D3_EMISSAO", dData, NIL})                        // Data de emissão (data atual)

	// Monta os itens do movimento
	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+_cParCod)
	_aItem := {;
		{"D3_COD", _cParCod, NIL},;   // Código do produto
		{"D3_UM", SB1->B1_UM, NIL},;       // Unidade de medida
		{"D3_QUANT", _nParQt1um, NIL},;     // Quantidade do item (1.99)
		{"D3_QTSEGUM", _nParQt2um, NIL},;     // Quantidade do item (1.99)
		{"D3_LOCAL", _cParLocal, NIL},;     // Local de estoque
		{"D3_LOTECTL", _cParLote, NIL},;     // Local de estoque
		{"D3_OP", _cParOp, NIL};        // Custo do item
		}
	// Adiciona o item ao array de itens
	aAdd(_atotitem, _aItem)
	// Executa a rotina de inclusão de movimento (MATA241)
	// Certifique-se de que _aCab1 e _atotitem são arrays válidos
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

Static Function MTA681(_cOpSerra)

	Local aVetor := {}
	Local nOpc   := 3 //Incluir
	Private lMsErroAuto :=.F.
	Private lMsHelpAuto :=.T.

	DbSelectArea("SB1")
	DbSetOrder(1)
	DbSeek(xFilial("SB1")+cProduto)
	cOperacao := "30"
	DbSelectArea("SG2")
	DbSetOrder(1)
	If !DbSeek(xFilial("SG2")+cProduto+"01")
		Reclock("SG2",.T.)
		SG2->G2_FILIAL := xFilial("SG2")
		SG2->G2_PRODUTO := cProduto
		SG2->G2_CODIGO  := "01"
		SG2->G2_OPERAC  := cOperacao
		SG2->G2_TEMPAD  := 1
		SG2->G2_LOTEPAD := 1
		SG2->G2_OPE_OBR := "S"
		SG2->G2_LAU_OBR := "S"
		MsUnlock()
	Else
		cOperacao := SG2->G2_OPERAC
	EndIf


	aVetor := {}
	AADD(aVetor,{"H6_OP"      ,_cOpSerra        ,NIL})
	AADD(aVetor,{"H6_PRODUTO" ,cProduto         ,NIL})
	AADD(aVetor,{"H6_RECURSO" ,cRecurso         ,NIL})
	AADD(aVetor,{"H6_OPERAC"  ,cOperacao        ,NIL})
	AADD(aVetor,{"H6_DTAPONT" ,dData            ,NIL})
	AADD(aVetor,{"H6_DATAINI" ,dDtIniOP         ,NIL})
	AADD(aVetor,{"H6_HORAINI" ,cHrIniOP         ,NIL})
	AADD(aVetor,{"H6_DATAFIN" ,dDtFinOP         ,NIL})
	AADD(aVetor,{"H6_HORAFIN" ,cHrFinOP         ,NIL})
	If nPesoProd < SC2->(C2_QUANT-C2_QUJE)
		AADD(aVetor,{"H6_PT"      ,'P'              ,NIL})
	Else
		AADD(aVetor,{"H6_PT"      ,'T'              ,NIL})
	EndIf
	AADD(aVetor,{"H6_LOCAL"   ,SB1->B1_LOCPAD   ,NIL})
	If SB1->B1_RASTRO == "L"
		AADD(aVetor,{"H6_LOTECTL" ,Alltrim(cLote)+"."+cValToChar(nComprimProd)        ,NIL})
	EndIf
	AADD(aVetor,{"H6_OPERADO" ,cUsuario         ,NIL})
	AADD(aVetor,{"H6_XCOMPRI" ,nComprimProd     ,NIL})
	AADD(aVetor,{"H6_QTDPROD" ,nPesoProd        ,NIL})
	AADD(aVetor,{"H6_QTDPRO2" ,nQtdePcs         ,NIL})
	AADD(aVetor,{"H6_XRET1"   ,nRetilin1        ,NIL})
	AADD(aVetor,{"H6_XRET2"   ,nRetilin2        ,NIL})
	AADD(aVetor,{"H6_XRCOMP1" ,nComprim1        ,NIL})
	AADD(aVetor,{"H6_XRCOMP2" ,nComprim2        ,NIL})

	MSExecAuto({|x| mata681(x)},aVetor, nOpc)

	If lMsErroAuto
		If (!IsBlind())
			// MostraErro()
		Else // EM ESTADO DE JOB
		ENDIF
		cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
		FWAlertError(cError,"Erro producao")
		return .f.
	Else
		nTipoProducao := "P"
		oTipoProducao:Refresh()
		fwAlertSuccess("Apontamento realizado com sucesso!!!","Apontamento de producao")
		return .t.
	EndIf
Return .T.


Static Function validaProduto()

	If Empty(cProduto)
		cDescProduto := ""
	EndIf
	If nTipoProducao == "R"
		cProduto := Padr(cCodRejeitado,15)
		DbSelectArea("SB1")
		DbSetOrder(1)
		If DbSeek(xFilial("SB1")+cProduto)
			cDescProduto := SB1->B1_DESC
		EndIf
		oProduto:Refresh()
		oDescProduto:Refresh()
		Return .T.
	EndIf

	DbSelectArea("SB1")
	DbSetOrder(1)
	If DbSeek(xFilial("SB1")+cProduto)
		DbSelectArea("SG1")
		DbSetOrder(1)
		If DbSeek(xFilial("SG1")+cProduto+cProdFusao)
			cDescProduto := SB1->B1_DESC
		Else
			FwalertInfo("Este produto nao pertence a estrutura do produto selecionado!!!","De-para serra-fusao")
			Return .T.
		EndIf
	Else
		cDescProduto := ""
	EndIf
	oDescProduto:Refresh()
Return

Static Function validaQtde()
	If nComprimProd > 1000
		If nQtdePcs > nPecasLote
			FwalertInfo("Quantidade de pecas nao pode ser maior que a quantidade de pecas disponivel do lote","Validacao de quantidade de pecas")
			Return .F.
		EndIf
	EndIf

	If nTipoProducao == "P"
		If nComprimProd > nCompriLote
			FwalertInfo("Comprimento da producao nao pode ser maior que o comprimento do lote selecionado","Validacao de comprimento")
			Return .T.
		EndIf

		If !cValToChar(nComprimProd) $ "6300/6200/6100/6000/5800/5000/3100/3000/950/930/918/470/450" .AND. UPPER(READVAR()) == "NCOMPRIMPROD"
			If FWAlertYesNo("Comprimento fora do padrao 6300/6200/6100/6000/5800/5000/3100/3000/950/930/918/470/450!!! Abortar?? ","Comprimento")
				Return .F.
			EndIf
		EndIf

		If nComprimProd > 1000
			nPcsLote        := nQtdePcs
			nPesoCons       := nPesoPeca*nQtdePcs
			nPesoLote		:= nB8_SALDO/nB8_SALDO2*nQtdePcs
			nPesoCavaco     := nPesoCons/nCompriLote*(nEspessCavaco*2)
			nPesoProd       := nComprimProd*_aFator[nDiametro]*nQtdePcs
			nPesoPonta      := nPesoCons-nPesoCavaco-nPesoProd
		Else
			// nPcsLote        := 1
			nPesoCons       := nPesoLote//nPecasLote*nQtdePcs
			nPesoCavaco     := nPesoCons/nPcsLote/nCompriLote*(nEspessCavaco*nQtdePcs+nEspessCavaco*nPcsLote)
			nPesoProd       := nComprimProd*_aFator[nDiametro]*nQtdePcs
			nPesoPonta      := nPesoCons-nPesoCavaco-nPesoProd
		EndIf
	Else
		nPesoCons       := nPesoPeca*nQtdePcs
		nPesoProd       := nPesoCons
		nPesoPonta 		:= 0

	EndIf
	// oPecasCons:Refresh()
	// oPesoCons:Refresh()
	oPesoCavaco:Refresh()
	oPesoPonta:Refresh()
	oPesoProd:Refresh()
	oPesoPeca:Refresh()
	// oPesoCons:Refresh()
Return .T.


Static Function iniciarParada()

	DbSelectArea("SH1")
	DbSetOrder(1)
	If DbSeek(xFilial("SH1")+cRecurso)
		If Empty(SH1->H1_XDTPARA)
			IF Empty(dDtIniParada) .or. cHrIniParada == "  :  "
				If FWAlertYesNo("Nao foi informada uma parada. Deseja iniciar com a data e hora de agora?","Iniciar parada")
					dDtIniParada := Date()
					cHrIniParada := Substr(Time(),1,5)
				Else
					Return
				EndIf
			EndIf
			Reclock("SH1",.F.)
			SH1->H1_XMOTPAR     := cMotParada
			SH1->H1_XDTPARA     := dDtIniParada
			SH1->H1_XHRPARA     := cHrIniParada
			SH1->H1_XSTATUS     := '3'
			MsUnlock()
			fwAlertSuccess("Parada iniciada com sucesso!!!","Inicio de parada")
		Else
			cMotParada := SH1->H1_XMOTPAR
			dDtIniParada := SH1->H1_XDTPARA
			cHrIniParada := SH1->H1_XHRPARA
			oMotParada:Refresh()
			oDtIniParada:Refresh()
			oHrIniParada:Refresh()
			FwalertInfo("O equipamento ja se encontra com status de parada. Pode apenas ser finalizada a parada ja iniciada","Controle de parada")
		EndIf
	EndIf

Return

Static Function finalizarParada()

	Local aVetor := {}
	Local nOpc   := 3 //Incluir
	Private lMsErroAuto :=.F.
	Private lMsHelpAuto :=.T.
	If Empty(cMotParada)
		FWAlertError("Informe um motivo para a parada!!","Motivo nao informado")
		Return
	EndIf
	If Empty(dDtFimParada)
		If FWAlertYesNo("Nao foi informado um horario final de parada. Deseja finalizar com a data e hora de agora?","Finalizar parada")
			dDtFimParada := Date()
			cHrFimParada := Substr(Time(),1,5)
		Else
			Return
		EndIf
	EndIf

	// {"H6_OP"      ,cOp                     ,NIL},;
	// {"H6_XOP"     ,cOp                     ,NIL},;
	aVetor := {;
		{"H6_RECURSO" ,cRecurso                     ,NIL},;
		{"H6_MOTIVO"  ,cMotParada                     ,NIL},;
		{"H6_OPERAC"  ,"01"                     ,NIL},;
		{"H6_DTAPONT" ,dDtIniParada                    ,NIL},;
		{"H6_DATAINI" ,dDtIniParada                    ,NIL},;
		{"H6_HORAINI" ,cHrIniParada                  ,NIL},;
		{"H6_DATAFIN" ,dDtFimParada                    ,NIL},;
		{"H6_HORAFIN" ,cHrFimParada                  ,NIL},;
		{"H6_OPERADO" ,cUsuario             ,NIL}}
	dDatabase := dData

	MSExecAuto({|x| mata682(x)},aVetor, nOpc)

	If lMsErroAuto
		If (!IsBlind())
			// MostraErro()
		Else // EM ESTADO DE JOB
		ENDIF
		cError := MostraErro("/dirdoc", "error.log") // ARMAZENA A MENSAGEM DE ERRO
		Showlog(cError)
		return .f.
	Else
		DbSelectArea("SH1")
		DbSetOrder(1)
		If DbSeek(xFilial("SH1")+cRecurso)
			Reclock("SH1",.F.)
			SH1->H1_XMOTPAR     := ""
			SH1->H1_XDTPARA     := Stod('')
			SH1->H1_XHRPARA     := ""
			SH1->H1_XSTATUS     := '2'
			MsUnlock()
			dDtIniParada := Stod('')
			dDtFimParada := Stod('')
			cHrIniParada := "  :  "
			cHrFimParada := "     "
			oDtIniParada:Refresh()
			oHrIniParada:Refresh()
			oDtFimParada:Refresh()
			oHrFimParada:Refresh()
		EndIf
		fwAlertSuccess("Apontamento realizado com sucesso!!!","Apontamento de parada")
		fUpdSh6Paradas()
	EndIf
Return .T.

Static Function excluirParada()
	Local _nRecno := GdFieldGet("XX_RECNO",oGetParadas:nAt,,oGetParadas:aHeader,oGetParadas:aCols)

	DbSelectArea("SH6")
	DbGoto(_nRecno)
	If !SH6->(Eof())
		If !FWAlertYesNo("Confirma exclusao da parada selecionada?","Exclusao de parada")
			Return
		EndIf
		Reclock("SH6",.F.)
		DbDelete()
		MsUnlock()
		fUpdSh6Paradas()
	EndIf
Return


// 20/10/2026 FixSystem - Leonardo Barboza Ribeiro Leite: INC1833293 - motivo de rejeicao so com tipo R
Static Function validaTipoProducao()

	If nTipoProducao == "R"
		cProduto := Padr(cCodRejeitado,15)
		DbSelectArea("SB1")
		DbSetOrder(1)
		If DbSeek(xFilial("SB1")+cProduto)
			cDescProduto := SB1->B1_DESC
		EndIf
	Else
		DbSelectArea("SG1")
		DbSetOrder(2)
		If DbSeek(xFilial("SG1")+cProdFusao)
			cProduto    := SG1->G1_COD
			DbSelectArea("SB1")
			DbSetOrder(1)
			DbSeek(xFilial("SB1")+cProduto)
			cDescProduto := SB1->B1_DESC
		Else
			cProduto        := Space(15)
			cDescProduto    := Space(15)
		EndIf
		limpaMotivo()
	EndIf
	oProduto:Refresh()
	oDescProduto:Refresh()
	oCodDefeito:Refresh()
Return .T.


/*/{Protheus.doc} carregaMotivos
Monta os itens do combo de motivo de rejeicao da tela da serra a partir da tabela generica Z2 (SX5).
@type     Static Function
@author   FixSystem - Leonardo Barboza Ribeiro Leite
@since    20/10/2026
@version  1.0
@return   Array, itens no formato "chave=descricao", com o primeiro item em branco
@obs      INC1833293
/*/
Static Function carregaMotivos()
	Local aRet := {Space(2) + "=Selecione o motivo"}
	Local aSX5 := FWGetSX5(_cTabRej)
	Local nX   := 0

	For nX := 1 To Len(aSX5)
		aAdd(aRet, Padr(AllTrim(aSX5[nX][3]), 2) + "=" + AllTrim(aSX5[nX][4]))
	Next nX
Return aRet

/*/{Protheus.doc} validaRejeicao
Impede o apontamento de tarugo rejeitado sem motivo de rejeicao.
@type     Static Function
@author   FixSystem - Leonardo Barboza Ribeiro Leite
@since    20/10/2026
@version  1.0
@param    cTipo, Character, tipo de producao (P ou R)
@param    cMotivo, Character, codigo do motivo selecionado no combo
@return   Logical, .T. quando pode apontar
@obs      INC1833293
/*/
Static Function validaRejeicao(cTipo, cMotivo)
	Local lRet := .T.

	// 09/11/2026 FixSystem - Leonardo Barboza Ribeiro Leite: INC1833293 - tarugo rejeitado (4000442) so pelo tipo R
	If cTipo <> "R" .And. AllTrim(cProduto) == AllTrim(cCodRejeitado)
		FwAlertInfo("Para sucatar tarugo use Tipo de Producao = R - Rejeicao e informe o motivo de rejeicao.","Motivo de rejeicao")
		lRet := .F.
	ElseIf cTipo == "R" .And. Empty(cMotivo)
		FwAlertInfo("Tarugo rejeitado exige o motivo de rejeicao. Selecione o motivo no campo Motivo Rej. da aba Producao.","Motivo de rejeicao")
		lRet := .F.
	EndIf
Return lRet

/*/{Protheus.doc} gravaMotivo
Grava o motivo de rejeicao nos movimentos (SD3) da rejeicao incluidos pela tela da serra.
@type     Static Function
@author   FixSystem - Leonardo Barboza Ribeiro Leite
@since    20/10/2026
@version  1.3
@param    nRecIni, Numeric, maior R_E_C_N_O_ da SD3 antes dos MATA241 da rejeicao (ver ultimoRecSD3)
@param    aMovs, Array, movimentos esperados no formato {{cTM, cProduto, cArmazem}, ...}
@param    cDoc, Character, documento enviado ao MATA241 (usado so na mensagem de erro)
@param    cMotivo, Character, codigo do motivo (tabela Z2)
@return   Logical, .T. quando o motivo foi gravado em todos os movimentos esperados
@obs      INC1833293. O fluxo de rejeicao nao gera mais OP (alteracao de 01/11): sao dois movimentos (RE 501 e DE 001). Chamada dentro da transacao do apontamento.
          18/11/2026 FixSystem: os movimentos passam a ser localizados pelos registros gravados apos nRecIni (TM, produto e armazem),
          e nao mais pelo D3_DOC, porque o MATA241 pode gravar o movimento com outro numero de documento.
/*/
Static Function gravaMotivo(nRecIni, aMovs, cDoc, cMotivo)
	Local aArea     := GetArea()
	Local aAreaSD3  := SD3->(GetArea())
	Local cAliasQry := ""
	Local cQuery    := ""
	Local lAchou    := .F.
	Local lRet      := .T.
	Local nX        := 0

	If SD3->(FieldPos("D3_XMOTREJ")) == 0
		FwAlertError("Campo D3_XMOTREJ nao existe na tabela SD3. Rejeicao nao apontada.","Motivo de rejeicao")
		RestArea(aAreaSD3)
		RestArea(aArea)
		Return .F.
	EndIf

	For nX := 1 To Len(aMovs)
		lAchou    := .F.
		cAliasQry := GetNextAlias()
		cQuery := "SELECT R_E_C_N_O_ AS RECSD3 "
		cQuery += "  FROM " + RetSqlName("SD3")
		cQuery += " WHERE D3_FILIAL  = '" + xFilial("SD3") + "'"
		cQuery += "   AND R_E_C_N_O_ > " + cValToChar(nRecIni)
		cQuery += "   AND D3_TM      = '" + aMovs[nX][1] + "'"
		cQuery += "   AND D3_COD     = '" + aMovs[nX][2] + "'"
		cQuery += "   AND D3_LOCAL   = '" + aMovs[nX][3] + "'"
		cQuery += "   AND D3_ESTORNO <> 'S'"
		cQuery += "   AND D_E_L_E_T_ = ' '"
		TCQuery cQuery New Alias (cAliasQry)

		While !(cAliasQry)->(Eof())
			SD3->(DbGoTo((cAliasQry)->RECSD3))
			If !SD3->(Eof())
				RecLock("SD3", .F.)
				SD3->D3_XMOTREJ := cMotivo
				SD3->(MsUnlock())
				lAchou := .T.
			EndIf
			(cAliasQry)->(DbSkip())
		EndDo
		(cAliasQry)->(DbCloseArea())

		If !lAchou
			FwAlertError("Movimento do documento " + AllTrim(cDoc) + " (TM " + aMovs[nX][1] + ", produto " + AllTrim(aMovs[nX][2]) + ") nao localizado para gravar o motivo de rejeicao. Rejeicao nao apontada.","Motivo de rejeicao")
			lRet := .F.
			Exit
		EndIf
	Next nX

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

/*/{Protheus.doc} limpaMotivo
Limpa o motivo de rejeicao da tela da serra.
@type     Static Function
@author   FixSystem - Leonardo Barboza Ribeiro Leite
@since    20/10/2026
@version  1.0
@obs      INC1833293
/*/
Static Function limpaMotivo()
	cCodDefeito := Space(2)
	If ValType(oCodDefeito) == "O"
		oCodDefeito:Refresh()
	EndIf
Return

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
