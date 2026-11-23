#Include "totvs.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
#Define _crlf Chr(13)+Chr(10)
#Define _cTmDE0 "001"
#Define _cTmRE0 "501"

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: Fixsystem
Tipo: Atualizações
Rotina: Faturamento
Função: embala_v3
Info: Serra Automática 1 Corte - 3100
************************************************************************/
User Function z3telaSerra()

	MsApp():New('SIGAEST')
	
	oApp:CreateEnv()
	
	PtSetTheme("SUNSET")
	
	oApp:bMainInit   := {|| MsgRun("Configurando ambiente...","Aguarde...",{|| RpcSetEnv("01","0201"), }),u_embala_v3(),Final("TERMINO NORMAL")}
	
	__lInternet      := .T.
	lMsFinalAuto     := .F.
	
	oApp:lMessageBar := .T.
	oApp:cModDesc    := 'SIGAEST'
	
	oApp:Activate()
	
Return

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: Fixsystem
Tipo: Atualizações
Rotina: Faturamento
Função: embala_v3
Info: Serra Automática 1 Corte - 3100
************************************************************************/
User Function Serra3100()

	Local oButton1             := Nil
	Local oButton2             := Nil
	Local oSay4                := Nil
	Local oSay8                := Nil
	Local oSay9                := Nil
	Local nLeftW               := 0
	Local nBlkW                := 0
	Local nX1                  := 0
	Local nX2                  := 0
	Local nApL                 := 0
	Local nBot                 := 0
	Local nOpBot               := 0
	Local nLotsBot             := 0
	Private oPanelApontamento  := Nil
	Private oPanelSerra        := Nil
	Private oProduto           := Nil
	Private oFilLiga           := Nil
	Private oFilVarian         := Nil
	Private oFilBitola         := Nil
	Private oFilCompri         := Nil
	Private oFilLote           := Nil
	Private oFilCorte          := Nil
	Private nFilCorte          := 0
	Private oBtnFiltrar        := Nil
	Private oBtnLimpar         := Nil
	Private oSayFLiga          := Nil
	Private oSayFVar           := Nil
	Private oSayFBit           := Nil
	Private oSayFCmp           := Nil
	Private oSayFLote          := Nil
	Private oSayFFus           := Nil
	Private oFilSZC            := Nil
	Private oFilFus            := Nil
	Private oHrIni             := Nil
	Private oHrFim             := Nil
	Private oCaixa             := Nil
	Private oFusao             := Nil
	Private oLiga              := Nil
	Private oOS                := Nil
	Private oTurno             := Nil
	Private oComprimento       := Nil
	Private oCompLote          := Nil
	Private oDiametro          := Nil
	Private oPecas             := Nil
	Private oConcessao         := Nil
	Private oPesoBal           := Nil
	Private oPesoLiq           := Nil
	Private oTara              := Nil
	Private oQuant             := Nil
	Private oRecurso           := Nil
	Private oCodigo            := Nil
	Private cCodCavaco         := Padr("4000445",15)
	Private cProduto           := Space(15)
	Private cFilLiga           := Space(5)
	Private cFilVarian         := Space(2)
	Private cFilBitola         := Space(1)
	Private cHrIni             := "  :  "
	Private cHrFim             := "  :  "
	Private cFusao             := Space(5)
	Private cLiga              := Space(5)
	Private cOS                := Space(6)
	Private cTurno             := Space(5)
	Private nFilCompri         := 0
	Private nComprim           := 0
	Private nComprimLote       := 0
	Private _nCompLote         := 0
	Private nDiametro          := 0
	Private _nPcs              := 0
	Private _nPesoBal          := 0
	Private _nPesoAlo          := 0
	Private _nPesoLiq          := 0
	Private nPesoPerda         := 0
	Private nPercRM            := 0
	Private nTara              := 0
	Private _nQuantMP          := 0
	Private cRecurso           := "EMB  "
	Private nConcessao         := "N"
	Private oRecSerra          := Nil
	Private oPesoPerda         := Nil
	Private oHrIniSerra        := Nil
	Private oHrFimSerra        := Nil
	Private oPcsSerra          := Nil
	Private cOpProgramada      := ""
	Private nQtDesejada        := 0
	Private nQtProduzida       := 0
	Private nSaldoOP           := 0
	Private nSerraQtDes        := 0
	Private nSerraQtProd       := 0
	Private nSerraSaldo        := 0
	Private oPesoSerra         := Nil
	Private cRecSerra          := "SERRA1"
	Private oLoteSerr          := Nil
	Private oLocSerr           := Nil
	Private oCodLote           := Nil
	Private oCodProd           := Nil
	Private cLoteSerr          := ""
	Private cLocSerr           := ""
	Private cCodLote           := ""
	Private cCodProd           := ""
	Private cHrIniSerra        := "  :  "
	Private cHrFimSerra        := "  :  "
	Private oPesoLote          := Nil
	Private nPesoLote          := 0
	Private oPecasLote         := Nil
	Private _nPcsLote          := 0
	Private nPcsSerra          := 0
	Private nPesoSerra         := 0
	Private oGetSB8            := Nil
	Private oGetSC2            := Nil
	Private oGetSD4            := Nil
	Private oGetProgSerra      := Nil
	Private oGetProgEmb        := Nil
	Private oSayProgSerra      := Nil
	Private oSayProgEmb        := Nil
	Private oFilProgSerra      := Nil
	Private oFilProgEmb        := Nil
	Private oFilEmbAte         := Nil
	Private oCompSerra         := Nil
	Private oBtnRefresh        := Nil
	Private dFilProgSerra      := CToD("  /  /  ")
	Private dFilProgEmb        := CToD("  /  /  ")
	Private dFilEmbAte         := CToD("  /  /  ")
	Private oDlg               := Nil
	Private cQry               := ""
	Private _aTaras            := {}
	Private aTamanho           := MsAdvSize()
	Private nJanLarg           := aTamanho[5]
	Private nJanAltu           := aTamanho[6]
	Private _lPesoManual       := .F.
	Private cTipo              := "3"
	Private cIPLink            := AllTrim(GetMV("MV_IPBAL",.F.,"45.167.181.50"))
	Private cIp                := Padr('189.56.89.34',100)
	Private nPorta             := 23
	Private nCompSerrar        := 0
	Private nParCompr          := GetMV("XX_COMPR",.F.,3500)
	Private cFilLote           := Space(15)
	Private cFilFus            := Space(15)
	Private lRegUnico          := .F.

	aAdd(_aTaras,{3100,"4",6})
	aAdd(_aTaras,{3100,"5",6})
	aAdd(_aTaras,{6200,"4",5})
	aAdd(_aTaras,{6200,"5",5})
	aAdd(_aTaras,{6100,"4",5})
	aAdd(_aTaras,{6100,"5",5})
	aAdd(_aTaras,{6000,"4",5})
	aAdd(_aTaras,{6000,"5",5})
	aAdd(_aTaras,{6300,"4",5})
	aAdd(_aTaras,{6300,"5",5})
	aAdd(_aTaras,{6200,"4",9})
	aAdd(_aTaras,{6200,"5",9})
	aAdd(_aTaras,{6200,"6",19.5})
	aAdd(_aTaras,{6200,"7",19.5})
	aAdd(_aTaras,{6100,"6",15})
	aAdd(_aTaras,{6100,"7",15})
	aAdd(_aTaras,{6000,"6",15})
	aAdd(_aTaras,{6000,"7",15})
	aAdd(_aTaras,{6300,"6",15})
	aAdd(_aTaras,{6300,"7",15})
	aAdd(_aTaras,{450,"4",6})
	aAdd(_aTaras,{450,"5",6})
	aAdd(_aTaras,{450,"6",6})
	aAdd(_aTaras,{450,"7",6})
	aAdd(_aTaras,{470,"4",6})
	aAdd(_aTaras,{470,"5",6})
	aAdd(_aTaras,{470,"6",6})
	aAdd(_aTaras,{470,"7",6})
	aAdd(_aTaras,{918,"4",6})
	aAdd(_aTaras,{918,"5",6})
	aAdd(_aTaras,{918,"6",6})
	aAdd(_aTaras,{918,"7",6})
	aAdd(_aTaras,{950,"4",4})
	aAdd(_aTaras,{950,"5",4})
	aAdd(_aTaras,{950,"6",4})
	aAdd(_aTaras,{950,"7",4})
	aAdd(_aTaras,{930,"4",4})
	aAdd(_aTaras,{930,"6",4})

	_aBalancas:= {}

	aAdd(_aBalancas,{'187.8.231.172',9006})
	aAdd(_aBalancas,{cIPLink,9001}) //89.56.89.36
	aAdd(_aBalancas,{cIPLink,9002})
	aAdd(_aBalancas,{cIPLink,9003})
	aAdd(_aBalancas,{cIPLink,9004})
	aAdd(_aBalancas,{cIPLink,9005})

	//Geometria dos blocos Serra (esquerda) e Embalagem (direita), lado a lado
	nApL     := nJanLarg/2-264
	nLeftW   := nApL-10
	nBot     := nJanAltu/2-20

	nOpBot   := nBot        //grids de OP agora usam a altura toda (antes: nPnlTop-6)
	nLotsBot := 40+Int((nOpBot-60)/2)
	nBlkW    := Int((nLeftW-5-8)/2)
	nX1      := 5
	nX2      := nX1+nBlkW+8

	DEFINE MSDIALOG oDlg TITLE "Serra Automática 1 Corte - 3100" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL
	SetKey(VK_F10, {|| liberaManual()})
	SetKey(VK_F11, {|| showlog(cQry)})

	@ 001, nApL MSPANEL oPanelSerra PROMPT "Serra 1" SIZE 258, nLotsBot-1 OF oDlg COLORS 1000, 16777215 RAISED
	@ 010, 010 SAY oSay4 PROMPT "Recurso" SIZE 046, 007 OF oPanelSerra COLORS 0, 16777215 PIXEL
	@ 008, 060 MSGET oRecSerra VAR cRecSerra SIZE 060, 010 OF oPanelSerra COLORS 0, 16777215 PIXEL F3 "SH1" when .F.
	@ 010, 130 SAY oSay4 PROMPT "Lote" SIZE 046, 007 OF oPanelSerra COLORS 0, 16777215 PIXEL
	@ 008, 180 MSGET oLoteSerr VAR cLoteSerr SIZE 070, 010 OF oPanelSerra COLORS 0, 16777215 PIXEL F3 "SH1" when .F.

	@ 027, 130 SAY oSay4 PROMPT "Armazem" SIZE 046, 007 OF oPanelSerra COLORS 0, 16777215 PIXEL
	@ 025, 180 MSGET oLocSerr VAR cLocSerr SIZE 040, 010 OF oPanelSerra COLORS 0, 16777215 PIXEL F3 "SH1" when .F.

	@ 045, 010 SAY oSay4 PROMPT "Hora Inicio" SIZE 046, 007 OF oPanelSerra COLORS 0, 16777215 PIXEL
	@ 043, 060 MSGET oHrIniSerra VAR cHrIniSerra SIZE 030, 010 OF oPanelSerra COLORS 0, 16777215 PIXEL Picture "99:99"
	@ 045, 130 SAY oSay4 PROMPT "Hora Termino" SIZE 046, 007 OF oPanelSerra COLORS 0, 16777215 PIXEL
	@ 043, 180 MSGET oHrFimSerra VAR cHrFimSerra SIZE 030, 010 OF oPanelSerra COLORS 0, 16777215 PIXEL Picture "99:99"

	@ 062, 010 SAY oSay8 PROMPT "Peso Lote" SIZE 046, 007 OF oPanelSerra COLORS 0, 16777215 PIXEL
	@ 060, 060 MSGET oPesoLote VAR nPesoLote SIZE 060, 010 OF oPanelSerra COLORS 0, 16777215 PIXEL Picture "@E 9,999.99999" when .F.
	@ 062, 130 SAY oSay8 PROMPT "Pecas Lote" SIZE 046, 007 OF oPanelSerra COLORS 0, 16777215 PIXEL
	@ 060, 180 MSGET oPecasLote VAR _nPcsLote SIZE 060, 010 OF oPanelSerra COLORS 0, 16777215 PIXEL Picture "@E 9,999" when .F.

	@ 079, 010 SAY oSay8 PROMPT "Pecas Entrada" SIZE 046, 007 OF oPanelSerra COLORS 0, 16777215 PIXEL
	@ 077, 060 MSGET oPcsSerra VAR nPcsSerra SIZE 060, 010 OF oPanelSerra COLORS 0, 16777215 PIXEL Picture "@E 999" valid(validarPecas())
	@ 079, 130 SAY oSay8 PROMPT "Peso Entrada" SIZE 046, 007 OF oPanelSerra COLORS 0, 16777215 PIXEL
	@ 077, 180 MSGET oPesoSerra VAR nPesoSerra SIZE 060, 010 OF oPanelSerra COLORS 0, 16777215 PIXEL Picture "@E 9,999.99" when .F.

	@ 096, 010 SAY oSay4 PROMPT "Produto Entrada" SIZE 046, 007 OF oPanelSerra COLORS 0, 16777215 PIXEL
	@ 094, 060 MSGET oCodLote VAR cCodLote SIZE 060, 010 OF oPanelSerra COLORS 0, 16777215 PIXEL F3 "SH1" when .F.
	@ 096, 130 SAY oSay4 PROMPT "Produto Saída" SIZE 046, 007 OF oPanelSerra COLORS 0, 16777215 PIXEL
	@ 094, 180 MSGET oCodProd VAR cCodProd SIZE 060, 010 OF oPanelSerra COLORS 0, 16777215 PIXEL F3 "SH1" when .F.
	@ 113, 010 SAY oSay4 PROMPT "Comprimento (mm)" SIZE 060, 007 OF oPanelSerra COLORS 0, 16777215 PIXEL
	@ 111, 060 MSGET oCompSerra VAR nCompSerrar SIZE 060, 010 OF oPanelSerra COLORS 0, 16777215 PIXEL Picture "@E 9999"
	@ 138, 080 BUTTON oButton1 PROMPT "Finalizar Serra" SIZE 110, 012 OF oPanelSerra PIXEL Action(Processa({||finalizarSerra(),"Finalizando..."}))

	//---- Bloco EMBALAGEM (esquerda, metade superior): grid de OPs programadas, no lugar da extinta tela "Itens Serrados"
	@ 001, nX1 SAY oSayProgEmb PROMPT "EMBALAGEM" SIZE 200, 007 OF oDlg COLORS 1000, 16777215 PIXEL
	@ 011, nX1 SAY oSay9 PROMPT "De:" SIZE 014, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 011, nX1+070 SAY oSay9 PROMPT "Até:" SIZE 016, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 009, nX1+020 MSGET oFilProgEmb VAR dFilProgEmb SIZE 044, 010 OF oDlg COLORS 0, 16777215 PIXEL Valid(fUpdProgramada("E") >= 0)
	@ 009, nX1+090 MSGET oFilEmbAte VAR dFilEmbAte SIZE 044, 010 OF oDlg COLORS 0, 16777215 PIXEL Valid(fUpdProgramada("E") >= 0)
	@ 009, nX1+160 BUTTON oBtnRefresh PROMPT "&Atualizar" SIZE 060, 012 OF oDlg PIXEL Action (xRefresh())

	oGetProgEmb := fGetProgramada(025, nX1, nLotsBot, nLeftW, "E")

	//---- Bloco SERRA (esquerda, metade inferior): grid de OPs programadas, empilhada abaixo da grid de Embalagem
	@ nLotsBot+7, nX1 SAY oSayProgSerra PROMPT "SERRA" SIZE 200, 007 OF oDlg COLORS 1000, 16777215 PIXEL

	//Filtros da grid de Serra
	@ nLotsBot+5,  nX1+040 BUTTON oBtnFiltrar PROMPT "&Filtrar" SIZE 045, 010 OF oDlg PIXEL Action(fUpdProgramada("S"))
	@ nLotsBot+5,  nX1+090 BUTTON oBtnLimpar PROMPT "&Limpar Filtro" SIZE 055, 010 OF oDlg PIXEL Action(xLimpaFiltros())
	@ nLotsBot+16, nX1     SAY oSayFLiga PROMPT "Liga" SIZE 028, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ nLotsBot+23, nX1     MSGET oFilLiga VAR cFilLiga SIZE 028, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ nLotsBot+16, nX1+032 SAY oSayFVar PROMPT "Variante" SIZE 028, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ nLotsBot+23, nX1+032 MSGET oFilVarian VAR cFilVarian SIZE 028, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ nLotsBot+16, nX1+064 SAY oSayFBit PROMPT "Bitola" SIZE 028, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ nLotsBot+23, nX1+064 MSGET oFilBitola VAR cFilBitola SIZE 028, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ nLotsBot+16, nX1+096 SAY oSayFCmp PROMPT "Compr. Corte" SIZE 040, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ nLotsBot+23, nX1+096 MSGET oFilCorte VAR nFilCorte SIZE 032, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 9999"
	@ nLotsBot+16, nX1+132 SAY oSayFLote PROMPT "Lote" SIZE 028, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ nLotsBot+23, nX1+132 MSGET oFilLote VAR cFilLote SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL
	@ nLotsBot+16, nX1+181 SAY oSayFFus PROMPT "Fusao" SIZE 028, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ nLotsBot+23, nX1+181 MSGET oFilFus VAR cFilFus SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL

	oGetProgSerra := fGetProgramada(nLotsBot+37, nX1, nOpBot, nLeftW, "S")

	fUpdSB8()
	fUpdProgramada("S")
	fUpdProgramada("E")

	ACTIVATE MSDIALOG oDlg CENTERED

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function xLimpaFiltros()

	cFilLiga := Space(5)
	oFilLiga:Refresh()
	
	cFilVarian := Space(2)
	oFilVarian:Refresh()

	cFilBitola := Space(1)
	oFilBitola:Refresh()

	nFilCorte := 0
	oFilCorte:Refresh()

	cFilLote := Space(15)
	oFilLote:Refresh()

	cFilFus := Space(15)
	oFilFus:Refresh()

	fUpdProgramada("S")

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function xRefresh()

	fUpdSB8()
	fUpdProgramada("S")
	fUpdProgramada("E")

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function validarPecas()

	nPesoSerra := nPesoLote/_nPcsLote*nPcsSerra
	oPesoSerra:Refresh()
	
Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static function liberaManual()

	cCodUsr    := RetCodUsr()
	cNomUsr    := UsrRetName(cCodUsr)
	aGrupos    := UsrRetGrp(cNomUsr, cCodUsr)
	
	If aScan(aGrupos,"000000") > 0 .Or. FunName() == "RPC"
		_lPesoManual:=!_lPesoManual
		oPesoBal:Refresh()
		FwAlertInfo(Iif(_lPesoManual,"Peso manual ativado.","Peso manual desativado."),"Modo de leitura de peso")
	Endif

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info:
*==================================================================*/
Static Function validarPeso()

	Local _x := 0

	If nTara > 20
		FwAlertError("Tara informada maior que o permitido!!!","Validacao de peso")
		Return(.F.)
	Endif 
	
	_nPesoLiq := _nPesoBal - nTara
	_nPesoAlo := 0
	
	For _x := 1 to Len(oGetSD4:aCols)
		_nPesoAlo += GdFieldGet("D4_QUANT",_x,,oGetSD4:aHeader,oGetSD4:aCols)
	Next
	
	oPesoAlocado:Refresh()
	
	nPercRM    := _nPesoLiq / _nPesoAlo *100
	nPesoPerda := Round(_nPesoLiq - _nPesoAlo,0)
	
	oPesoPerda:Refresh()
	oPesoLiq:Refresh()

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function remover()

	Local _aCols   := aClone(oGetSD4:aCols)
	Local _cLote   := GdFieldGet("D4_LOTECTL",oGetSD4:nAt,,oGetSD4:aHeader,oGetSD4:aCols)
	Local _xRecSB8 := GdFieldGet("XX_RECNO",oGetSD4:nAt,,oGetSD4:aHeader,oGetSD4:aCols)
	Local _x

	If !FWAlertYesNo("Tem certeza que deseja remover o lote "+_cLote+" da linha "+cValToChar(oGetSD4:nAt)+" selecionada?","Remover lote")
		Return
	EndIf

	_nSaldo     := GdFieldGet("B8_SALDO",_xRecSB8,,oGetSB8:aHeader,oGetSB8:aCols)
	_nSaldo2    := GdFieldGet("B8_SALDO2",_xRecSB8,,oGetSB8:aHeader,oGetSB8:aCols)
	_nPesoMP    := GdFieldGet("D4_QUANT",oGetSD4:nAt,,oGetSD4:aHeader,oGetSD4:aCols)
	_nQuantMP   := GdFieldGet("D4_QTSEGUM",oGetSD4:nAt,,oGetSD4:aHeader,oGetSD4:aCols)

	GdFieldPut("B8_SALDO",_nSaldo+_nPesoMP,_xRecSB8,oGetSB8:aHeader,oGetSB8:aCols)
	GdFieldPut("B8_SALDO2",_nSaldo2+_nQuantMP,_xRecSB8,oGetSB8:aHeader,oGetSB8:aCols)

	aDel(_aCols,oGetSD4:nAt)
	aSize(_aCols,len(_aCols)-1)

	If Len(oGetSD4:aCols) == 1
		_aLinha := {}
		aAdd(_aLinha,{"","",0,0,"",.F.})
		oGetSD4:aCols := aClone(_aLinha)
	Else
		oGetSD4:aCols := aClone(_aCols)
	EndIf

	oGetSD4:Refresh()

	_nPcs := 0

	For _x := 1 to Len(oGetSD4:aCols)
		_nPcs += GdFieldGet("D4_QTSEGUM",_x,,oGetSD4:aHeader,oGetSD4:aCols)
	Next

	oQuant:SetFocus()

	validarPeso()
	FwalertInfo("Item removido com sucesso!!!","Remocao de item")

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function fGetSC2()

	Local nX           := 0
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFieldFill   := {}
	Local aFields      := {"C2_OK","C2_OP","C2_DATPRI","XX_COMPRI","B8_LOTECTL","B1_XGRLIGA","B1_XBITOLA","B8_SALDO","B8_SALDO2","B1_XCOMPRI","B8_PRODUTO","B1_DESC","C2_PRODUTO","B8_DATA","B8_LOCAL"}
	Local aAlterFields := {}

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	For nX := 1 to Len(aFields)
	
		If SX3->(DbSeek(aFields[nX]))		
			aAdd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Else
			aAdd(aHeaderEx, {"Compr Saida","XX_COMPRI","",4,0,".T.",".T.","N","",""})
		Endif
		
	Next nX

	For nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			aAdd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Else
			aAdd(aFieldFill, 0)
		Endif
	Next nX
	
	aAdd(aFieldFill, .F.)
	aAdd(aColsEx, aFieldFill)

	oGetSC2 := MsNewGetDados():New( 215, 005, 300, nJanLarg/2-610, /*GD_INSERT+GD_DELETE+*/GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
	oGetSC2:BChange := {||changeSC2()}

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function changeGet(oGet)

	Local _x := 0

	If oGet:nAt < 1 .Or. oGet:nAt > Len(oGet:aCols)
		oGet:nAt := 1
	EndIf

	nPosAtu := oGet:nAt
	
	For _x := 1 to Len(oGet:aCols)
		GdFieldPut("C2_OK","",_x,oGet:aHeader,oGet:aCols)
	Next
	
	GdFieldPut("C2_OK","==>",oGet:nAt,oGet:aHeader,oGet:aCols)

	oGet:Refresh()
	
Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: Mudo a cor da linha posicionada
*==================================================================*/
Static Function fCorLinha(oGet)

    Local nCorLinha := 16777215  //Branco
	Local cSeta     := GdFieldGet("C2_OK",oGet:nAt,,oGet:aHeader,oGet:aCols)

	If cSeta == "==>" 
		nCorLinha := 16776960 //Ciano
	Endif 

Return(nCorLinha)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info:
*==================================================================*/
Static Function changeSC2()

	Private aCols   := oGetSC2:aCols
	Private aHeader := oGetSC2:aHeader
	Private n       := oGetSC2:nAt

	cLoteSerr   := GdFieldGet("B8_LOTECTL")
	cCodLote    := GdFieldGet("B8_PRODUTO")
	cLocSerr    := GdFieldGet("B8_LOCAL")
	nPesoLote   := GdFieldGet("B8_SALDO")
	_nPcsLote   := GdFieldGet("B8_SALDO2")
	cCodProd    := GdFieldGet("C2_PRODUTO")
	cHrIniSerra := "  :  "
	cHrFimSerra := "  :  "
	
	oLoteSerr:Refresh()
	oCodLote:Refresh()
	oLocSerr:Refresh()
	oPesoLote:Refresh()
	oCodProd:Refresh()
	oHrIniSerra:Refresh()
	oHrFimSerra:Refresh()
	
Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info:
*==================================================================*/
Static Function fGetSD4()

	Local nX           := 0
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFieldFill   := {}
	Local aFields      := {"D4_COD","D4_LOTECTL","D4_QUANT","D4_QTSEGUM","D4_LOCAL","XX_RECNO"}
	Local aAlterFields := {}

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))
	
	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			aAdd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX
	
	aAdd(aHeaderEx,{"RECNO","XX_RECNO","",10,0,"","","N","","","",""})

	For nX := 1 to Len(aFields)
		If DbSeek(aFields[nX])
			aAdd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Else
			aAdd(aFieldFill, 0)
		Endif
	Next nX
	
	aAdd(aFieldFill, .F.)
	aAdd(aColsEx, aFieldFill)

	oGetSD4 := MsNewGetDados():New( 085, 005, 150, 250, /*GD_INSERT+GD_DELETE+*/GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oPanelApontamento, aHeaderEx, aColsEx)

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info:
*==================================================================*/
Static Function changeSB8()

	Private aCols   := oGetSB8:aCols
	Private aHeader := oGetSB8:aHeader
	Private n       := oGetSB8:nAt

	cFusao       := GdFieldGEt("B8_LOTECTL")
	cLiga        := GdFieldGEt("B1_XGRLIGA")
	nDiametro    := GdFieldGEt("B1_XBITOLA")
	nComprimLote := GdFieldGEt("B1_XCOMPRI")
	nComprim     := GdFieldGEt("XX_COMPRI")
	nPosTara     := aScan(_aTaras,{|x|x[1] == nComprim .And. val(x[2]) == nDiametro})
	
	If nPosTara > 0
		nTara := _aTaras[nPosTara,3]
	Else
		nTara := 10
	Endif 

	cLoteSerr   := cFusao
	cCodLote	:= GdFieldGEt("B8_PRODUTO")
	nPesoLote 	:= GdFieldGet("B8_SALDO")
	_nPcsLote   := GdFieldGet("B8_SALDO2")
	
	//Atualiza os campos da Serra 1 na tela
	oLoteSerr:Refresh()
	oCodLote:Refresh()
	oPesoLote:Refresh()
	oPecasLote:Refresh()
	changeGet(@oGetSB8)
	
Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info:
*==================================================================*/
Static Function fUpdSB8()

	Local _aLinha := {}
	Local _x      := 0

	//Tela "Itens Serrados" removida da interface; a grid oGetSB8 nao existe mais, entao esta funcao nao tem mais o que atualizar.
	If oGetSB8 == Nil
		Return(.T.)
	EndIf

	cQry := "SELECT '' C2_OK,'' ZD_COD,G1_COD,B8_PRODUTO,SB1.B1_DESC,SB1.B1_TIPO,B8_LOTECTL,B8_SALDO,B8_SALDO2,B8_EMPENHO,B8_EMPENH2,B8_DATA,B8_LOCAL,SB1.B1_XGRLIGA,SB1.B1_XVARIAN,SB1.B1_XBITOLA,SB1.B1_XCOMPRI,SB1X.B1_XCOMPRI XX_COMPRI " + _crlf
	cQry += "FROM "+RetSQLName("SB8")+" SB8 " + _crlf
	cQry += "   INNER JOIN "+RetSQLName("SB1") +" SB1 ON SB1.D_E_L_E_T_='' AND B1_COD=B8_PRODUTO  " + _crlf 
	cQry += "   INNER JOIN "+RetSQLName("SG1") +" SG1 ON SG1.D_E_L_E_T_='' AND B1_COD=G1_COMP AND SUBSTRING(G1_FILIAL,1,2)=B1_FILIAL " + _crlf 
	cQry += "   INNER JOIN "+RetSQLName("SB1") +" SB1X ON SB1X.D_E_L_E_T_='' AND SB1X.B1_COD=G1_COD AND SB1X.B1_LOCPAD='29' " + _crlf 
	
	If nFilCompri > 0
		cQry += "   AND SB1X.B1_XCOMPRI="+cValToChar(nFilCompri)+" " + _crlf 
	EndIf

	cQry += "WHERE SB8.D_E_L_E_T_='' AND B8_FILIAL='"+cFilAnt+"' AND B8_SALDO >0 " + _crlf
	
	cQry += "AND B8_LOCAL='49' " + _crlf
	cQry += "AND B8_SALDO2 > 0 " + _crlf

	If !Empty(cFilLiga)
		cQry += "AND SB1.B1_XGRLIGA='"+cFilLiga+"' " + _crlf
	EndIf

	If !Empty(cFilVarian)
		cQry += "AND SB1.B1_XVARIAN='"+cFilVarian+"' " + _crlf
	EndIf

	If !Empty(cFilBitola)
		cQry += "AND SB1.B1_XBITOLA='"+cFilBitola+"' " + _crlf
	EndIf

	cQry += "ORDER BY B8_DATA " + _crlf

	conout(cQry)

	TcQuery cQry New Alias "SB8X"

	TCSetField("SB8X","B8_DATA","D",/*nSize*/,/*nPrecision*/)

	DbSelectArea("SB8X")
	DbGotop()

	_aStru := oGetSB8:aHeader

	//Controle de filtro de atualização de grids de registro único
	If Select(SB8X) == 1 
		lRegUnico := .T.
	Else 
		lRegUnico := .F.
	Endif 
	// --- 

	If !SB8X->(Eof())
	
		oGetSB8:aCols := {}
		
		While !SB8X->(Eof())
		
			_aLinha := {}
			
			For _x := 1 to len(_aStru)
				_cCpo := _aStru[_x,2]
				aAdd(_aLinha,SB8X->&(_cCpo))
			Next
			
			aAdd(_aLinha,.F.)
			aAdd(oGetSB8:aCols,_aLinha)
			
			SB8X->(DbSkip())
			
		EndDo
		
	Else
		
		oGetSB8:aCols := {}
		
		For _x := 1 to len(_aStru)
		
			_cCpo := _aStru[_x,2]
			
			If _cCpo == "XX_COMPRI"
				aAdd(_aLinha,0)
			Else
				aAdd(_aLinha,criavar(_cCpo))
			Endif
			
		Next
		
		aAdd(_aLinha,.F.)
		aAdd(oGetSB8:aCols,_aLinha)
		
	EndIf
	
	SB8X->(DbCloseArea())
	
	oGetSB8:Refresh()
	changeSB8()

	If lRegUnico
		selecionaOP("S")
	Endif 

Return(.T.)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info:
*==================================================================*/
Static Function fUpdSC2()

	Local _aLinha := {}
	Local _x      := 0
	
	cQry := "SELECT '' C2_OK,C2_NUM+C2_ITEM+C2_SEQUEN C2_OP,ISNULL(C2_DATPRI,'20491231') C2_DATPRI,C2_PRODUTO,G1_COD,B8_PRODUTO,SB1.B1_DESC,SB1.B1_TIPO,B8_LOTECTL,B8_SALDO,B8_SALDO2,B8_EMPENHO,B8_EMPENH2,B8_DATA,B8_LOCAL,SB1.B1_XGRLIGA,SB1.B1_XVARIAN,SB1.B1_XBITOLA,SB1.B1_XCOMPRI,SB1X.B1_XCOMPRI XX_COMPRI " + _crlf
	cQry += "FROM "+RetSQLName("SB8")+" SB8 " + _crlf
	cQry += "   INNER JOIN "+RetSQLName("SB1") +" SB1 ON SB1.D_E_L_E_T_='' AND B1_COD=B8_PRODUTO  " + _crlf
	cQry += "   INNER JOIN "+RetSQLName("SG1") +" SG1 ON SG1.D_E_L_E_T_='' AND B1_COD=G1_COMP AND SUBSTRING(G1_FILIAL,1,2)=B1_FILIAL " + _crlf 
	cQry += "   INNER JOIN "+RetSQLName("SB1") +" SB1X ON SB1X.D_E_L_E_T_='' AND SB1X.B1_COD=G1_COD " + _crlf 

	If nFilCompri > 0
		cQry += "   AND SB1X.B1_XCOMPRI="+cValToChar(nFilCompri)+" " + _crlf 
	EndIf

	cQry += "   INNER JOIN "+RetSQLName("SC2") +" SC2 ON SC2.D_E_L_E_T_='' AND C2_FILIAL=B8_FILIAL AND C2_PRODUTO=G1_COD AND C2_DATRF='' AND C2_QUANT-C2_QUJE>0 AND C2_RECURSO='SERRA1' "  + _crlf 
	cQry += "WHERE SB8.D_E_L_E_T_='' AND B8_FILIAL='"+cFilAnt+"' AND B8_SALDO>0 " + _crlf
	cQry += "AND B8_LOCAL='49' " + _crlf

	If !Empty(cFilLiga)
		cQry += "AND SB1.B1_XGRLIGA='"+cFilLiga+"' " + _crlf
	EndIf

	If !Empty(cFilVarian)
		cQry += "AND SB1.B1_XVARIAN='"+cFilVarian+"' " + _crlf
	EndIf

	If !Empty(cFilBitola)
		cQry += "AND SB1.B1_XBITOLA='"+cFilBitola+"' " + _crlf
	EndIf

	cQry += "ORDER BY ISNULL(C2_DATPRI,'20491231') , B8_DATA " + _crlf

	conout(cQry)
	
	TcQuery cQry New Alias "SB8X"
	TCSetField("SB8X","C2_DATPRI","D",/*nSize*/,/*nPrecision*/)
	TCSetField("SB8X","B8_DATA","D",/*nSize*/,/*nPrecision*/)
	DbSelectArea("SB8X")
	
	DbGotop()
	
	_aStru := oGetSC2:aHeader
	
	If !SB8X->(Eof())
	
		oGetSC2:aCols := {}
		
		While !SB8X->(Eof())
		
			_aLinha := {}
			
			For _x := 1 to len(_aStru)
			
				_cCpo := _aStru[_x,2]
				
				aAdd(_aLinha,SB8X->&(_cCpo))
				
			Next
			
			aAdd(_aLinha,.F.)
			aAdd(oGetSC2:aCols,_aLinha)
			
			SB8X->(DbSkip())
			
		EndDo
		
	Else
		oGetSC2:aCols := {}
	
		For _x := 1 to len(_aStru)
		
			_cCpo := _aStru[_x,2]
			
			If _cCpo == "XX_COMPRI"
				aAdd(_aLinha,0)
			Else
				aAdd(_aLinha,criavar(_cCpo))
			Endif 
			
		Next
		
		aAdd(_aLinha,.F.)
		aAdd(oGetSC2:aCols,_aLinha)
		
	Endif 
	
	SB8X->(DbCloseArea())
	oGetSC2:Refresh()

Return(.T.)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info:
*==================================================================*/
Static Function finalizarSerra()

	Private lMsErroAuto 	:= .F.
	Private lMsHelpAuto     := .T.

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))
	
	SB1->(DbSeek(xFilial("SB1")+cCodProd))
	
	cLocProd  := SB1->B1_LOCPAD
	nComSaida := SB1->B1_XCOMPRI
	nQtde1um  := Round(nPesoLote/_nPcsLote*nPcsSerra,5)
	nQtde2um  := nPcsSerra*2

	If !FWAlertYesNo("Confirma apontamento de serra?","Serra automatica 1")
		Return
	Endif

	Begin Transaction
		
		aMATA650 := {}
		
		aAdd(aMATA650,{'C2_PRODUTO' ,cCodProd ,NIL})
		aAdd(aMATA650,{'C2_LOCAL'   ,SB1->B1_LOCPAD ,NIL})
		aAdd(aMATA650,{'C2_QUANT'   ,nQtde1um ,NIL})
		aAdd(aMATA650,{'C2_QTSEGUM' ,nQtde2um ,NIL})
		aAdd(aMATA650,{'C2_DATPRI'  ,dDatabase ,NIL})
		aAdd(aMATA650,{'C2_DATPRF'  ,dDatabase ,NIL})
		aAdd(aMATA650,{'C2_BATCH'   ,'S' ,NIL})
		aAdd(aMATA650,{'AUTEXPLODE' ,"N" ,NIL})

		lMsErroAuto := .F.

		MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)

		If lMsErroAuto
			_cError := MostraErro("\dirdoc\","error_mata650.log")
			DisarmTransaction()
			showlog(_cError)
			Return
		EndIf

		_cOpEmb := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)

		_aCab1 := {}

		aAdd(_aCab1,{"D3_DOC", _cOpEmb, NIL}) // N?ero do documento (gerado automaticamente)
		aAdd(_aCab1,{"D3_TM", _cTmRE0, NIL})                            // Tipo de movimento
		aAdd(_aCab1,{"D3_CC", "        ", NIL})                           // Centro de custo (vazio)
		aAdd(_aCab1,{"D3_EMISSAO", dDataBase, NIL})                        // Data de emiss? (data atual)

		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))
		
		SB1->(DbSeek(xFilial("SB1")+cCodLote))

		_aItens := {}    // Array para agrupar todos os itens
		_aItem  := {}

		aAdd(_aItem,{"D3_COD", cCodLote, NIL})   // C?igo do produto
		aAdd(_aItem,{"D3_UM", SB1->B1_UM, NIL})       // Unidade de medida
		aAdd(_aItem,{"D3_QUANT", nQtde1um, NIL})     // Quantidade do item (1.99)
		aAdd(_aItem,{"D3_QTSEGUM", nPcsSerra, NIL})     // Quantidade do item (1.99)
		aAdd(_aItem,{"D3_LOCAL", cLocSerr, NIL})     // Local de estoque
		aAdd(_aItem,{"D3_LOTECTL", cLoteSerr, NIL})     // Local de estoque
		aAdd(_aItem,{"D3_OP", _cOpEmb, NIL})        // Custo do item

		// Adiciona o item ao array de itens
		aAdd(_aItens, _aItem)

		lMsErroAuto := .F.

		MSExecAuto({|x, y, z| MATA241(x, y, z)}, _aCab1, _aItens, 3)

		If lMsErroAuto

			MostraErro()
			DisarmTransaction()
			Return(.F.)

		Endif

		DbSelectArea("SG2")
		SG2->(DbSetOrder(1))

		If !SG2->(DbSeek(xFilial("SG2")+cCodProd+"01"+"40"))

			Reclock("SG2",.T.)
			SG2->G2_FILIAL := xFilial("SG2")
			SG2->G2_PRODUTO := cCodProd
			SG2->G2_CODIGO  := "01"
			SG2->G2_OPERAC  := "40"
			SG2->G2_TEMPAD  := 1
			SG2->G2_LOTEPAD := 1
			SG2->G2_OPE_OBR := "S"
			SG2->G2_LAU_OBR := "S"
			SG2->(MsUnlock())

		EndIf

		aVetor := {}

		aAdd(aVetor,{"H6_OP"      ,_cOpEmb     ,NIL})
		aAdd(aVetor,{"H6_PRODUTO" ,cCodProd    ,NIL})
		aAdd(aVetor,{"H6_RECURSO" ,cRecSerra   ,NIL})
		aAdd(aVetor,{"H6_OPERAC"  ,"40"        ,NIL})
		aAdd(aVetor,{"H6_DTAPONT" ,dDataBase   ,NIL})
		aAdd(aVetor,{"H6_DATAINI" ,dDataBase   ,NIL})
		aAdd(aVetor,{"H6_HORAINI" ,cHrIniSerra ,NIL})
		aAdd(aVetor,{"H6_DATAFIN" ,dDataBase   ,NIL})
		aAdd(aVetor,{"H6_HORAFIN" ,cHrFimSerra ,NIL})
		aAdd(aVetor,{"H6_PT"      ,'P'         ,NIL})
		aAdd(aVetor,{"H6_LOCAL"   ,cLocProd    ,NIL})
		aAdd(aVetor,{"H6_LOTECTL" ,Substr(cLoteSerr,1,5)+"."+cValToChar(nComSaida)   ,NIL})
		aAdd(aVetor,{"H6_OPERADO" ,cUserName   ,NIL})
		aAdd(aVetor,{"H6_QTDPROD" ,nQtde1um    ,NIL})
		aAdd(aVetor,{"H6_QTDPRO2" ,nQtde2um    ,NIL})
		aAdd(aVetor,{"H6_XCOMPRI" ,nComSaida   ,NIL})
		aAdd(aVetor,{"H6_XTARA"   ,0           ,NIL})

		lMsErroAuto := .F.

		MSExecAuto({|x| mata681(x)},aVetor, 3)

		If lMsErroAuto
			MostraErro()
			DisarmTransaction()
			Return
		EndIf

		nPcsSerra   := 0
		cHrIniSerra := "  :  "
		cHrFimSerra := "  :  "
		cLocSerr    := ""
		nPesoLote   := 0
		nCompSerrar := 0
		cCodLote    := ""
		cLoteSerr   := ""
		cCodProd    := ""

		fwAlertSuccess("Serra finalizada com sucesso!!!","Serra")

	End Transaction

	fUpdSB8()
	fUpdProgramada("S")

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info:
*==================================================================*/
Static Function MTA241(_cParTM,_cParCod,_cParLocal,_nParQt1um,_nParQt2um,_cParOp,_cParLote)

	Local _aCab1    := {}     // Array para o cabe?lho do movimento
	Local _aItem    := {}    // Array para os itens do movimento
	Local _atotitem := {}   // Array para agrupar todos os itens
	Local cErro

	// Vari?veis para controle de executo autom?tica
	Private lMsHelpAuto := .T. // Se .T., exibe mensagens de help
	Private lMsErroAuto := .F. // Se .F., n? exibe erros autom?icos

	_aCab1 := {;
	{"D3_DOC", _cParOp, NIL},; // Numero do documento (gerado automaticamente)
	{"D3_TM", _cParTM, NIL},;                            // Tipo de movimento
	{"D3_CC", "        "    , NIL},;                           // Centro de custo (vazio)
	{"D3_EMISSAO", dDataBase, NIL};                        // Data de emiss? (data atual)
	}

	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	SB1->(DbSeek(xFilial("SB1")+_cParCod))

	_aItem := {;
	{"D3_COD", _cParCod      ,Nil},;   // Codigo do produto
	{"D3_UM", SB1->B1_UM     ,Nil},;   // Unidade de medida
	{"D3_QUANT", _nParQt1um  ,Nil},;   // Quantidade do item (1.99)
	{"D3_QTSEGUM", _nParQt2um,Nil},;   // Quantidade do item (1.99)
	{"D3_LOCAL", _cParLocal  ,Nil},;   // Local de estoque
	{"D3_LOTECTL", _cParLote ,Nil},;   // Local de estoque
	{"D3_OP", _cParOp        ,Nil};    // Custo do item
	}

	// Adiciona o item ao array de itens
	aAdd(_atotitem, _aItem)
	MSExecAuto({|x, y, z| MATA241(x, y, z)}, _aCab1, _atotitem, 3)
	
	If lMsErroAuto
		cErro := MostraErro('\dirdoc\','error.log')          // Exibe mensagem de erro
		MessageBox(cErro,"Erro",16)
		Return(.F.)
	Endif

Return(.T.)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info:
*==================================================================*/
Static Function validaBalanca()

	conout(cTipo)

	cIp    := _aBalancas[val(cTipo),1]
	nPorta := _aBalancas[val(cTipo),2]

Return(.T.)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info:
*==================================================================*/
Static Function LerPeso()

	Local cBuffer := ""
	Local cLog := ""
	Private oObj := tSocketClient():New()

	validaBalanca()

	cTime := Time()
	cPeso 	 := ""
	nCont 	 := 0
	cLog += "-------------" +_crlf
	nResp := oObj:Connect( nPorta,cIp,500)

	if(nResp == 0 )
		cLog += "Conexao realizada com sucesso..."+Alltrim(cIp)+"/"+Alltrim(Str(nPorta))+" " + Time()+ " " +_crlf
	Else
		cLog += "--> Tentativa de Conex?: "+Alltrim(cIp)+"/"+Alltrim(Str(nPorta))+" " + Time()+ " " +_crlf
	Endif

	if( !oObj:IsConnected() )
		cLog += "Falha na conexao "+Alltrim(cIp)+"/"+Alltrim(Str(nPorta))+" " + Time()+ " " +_crlf
		oObj:CloseConnection()
		Return
	Else
		cBuffer := ""
		nResp = oObj:Receive( @cBuffer, 2000 )
		if( nResp >= 0 )
			cLog += "--> Dados Recebidos ["+cBuffer+"]"+_crlf
			cLog += "--> Dados nResp " + cValToChar(nResp)+_crlf
		Else
			cBuffer := "000000"
		Endif
	Endif

	oObj:CloseConnection()

	cPeso     := Substr(cBuffer,at("`" ,cBuffer)+1,7)
	_nPesoBal := Val(cPeso)/100

	oPesoBal:Refresh()

	validarPeso()

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: Monta a linha em branco das grids de OPs programadas
*==================================================================*/
Static Function fLinhaVaziaProg(aHeaderEx)

	Local aLinha := {}
	Local nX     := 0

	For nX := 1 To Len(aHeaderEx)

		If aHeaderEx[nX,8] == "N"
			aAdd(aLinha,0)
		ElseIf aHeaderEx[nX,8] == "D"
			aAdd(aLinha,CToD("  /  /  "))
		ElseIf aHeaderEx[nX,8] == "L"
			aAdd(aLinha,.F.)
		Else
			aAdd(aLinha,Space(aHeaderEx[nX,4]))
		EndIf

	Next nX

	aAdd(aLinha,.F.)

Return(aLinha)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: Cria a grid reduzida de OPs programadas (Serra ou Embalagem)
 na tela principal
*==================================================================*/
Static Function fGetProgramada(nTop,nLeft,nBottom,nRight,cTpProg)

	Local nX           := 0
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFields      := {}
	Local aAlterFields := {}
	Local oGet         := Nil

	If cTpProg == "S"
		aFields := {"C2_OK","B1_XGRLIGA","B1_XVARIAN","B1_XBITOLA","B8_LOTECTL","B1_XCOMPRI","XX_COMPRI","B8_SALDO","B8_SALDO2","G1_COD","B1_DESC","B8_PRODUTO","B8_LOCAL"}
	Else
		aFields := {"C2_OK","B1_XGRLIGA","B1_XVARIAN","B1_XBITOLA","C2_QTSEGUM","XX_SALDO","C2_OP","C2_PRODUTO","C2_QUANT","QTD_PROD2","C2_DATPRI"}
	EndIf

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))

	For nX := 1 to Len(aFields)

		If aFields[nX] == "C2_QTSEGUM" .And. cTpProg == "E"
			aAdd(aHeaderEx, {"Qtd 2a UM (Amarrado)",aFields[nX],"@E 999,999",12,2,"","","N","","","",""})
		Elseif aFields[nX] == "XX_SALDO"
			aAdd(aHeaderEx, {"Saldo Amarrados",aFields[nX],"@E 999,999",12,2,"","","N","","","",""})
		Elseif aFields[nX] == "QTD_PROD2"
			aAdd(aHeaderEx, {"Qtde Produzida",aFields[nX],"@E 999,999",12,2,"","","N","","","",""})
		Elseif aFields[nX] == "XX_COMPRI"
			aAdd(aHeaderEx, {"Compr Saida",aFields[nX],"@E 9999",4,0,"","","N","","","",""})
		Elseif aFields[nX] == "B8_SALDO" .And. cTpProg == "S"
			aAdd(aHeaderEx, {"Saldo Kg",aFields[nX],"@E 999,999.99",12,2,"","","N","","","",""})
		Elseif aFields[nX] == "B8_SALDO2" .And. cTpProg == "S"
			aAdd(aHeaderEx, {"Saldo Pc",aFields[nX],"@E 999,999",12,2,"","","N","","","",""})
		Elseif aFields[nX] == "G1_COD" .And. cTpProg == "S"
			aAdd(aHeaderEx, {"Produto Entrada",aFields[nX],"@!",15,0,"","","C","","","",""})
		Elseif aFields[nX] == "B8_PRODUTO" .And. cTpProg == "S"
			aAdd(aHeaderEx, {"Produto Saída",aFields[nX],"@!",15,0,"","","C","","","",""})
		Elseif aFields[nX] == "C2_DATPRI" .And. cTpProg == "E"
			aAdd(aHeaderEx, {"Data Programada",aFields[nX],"@!",15,0,"","","C","","","",""})
		Elseif SX3->(DbSeek(aFields[nX]))
			aAdd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif

	Next nX

	aAdd(aColsEx, fLinhaVaziaProg(aHeaderEx))

	oGet := MsNewGetDados():New( nTop, nLeft, nBottom, nRight, /*GD_INSERT+GD_DELETE+*/GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
	oGet:oBrowse:lUseDefaultColors := .F.
	oGet:BChange := {|| selecionaOP(cTpProg)}
	oGet:oBrowse:SetBlkBackColor({|| fCorLinha(oGet)})

Return(oGet)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: Carrega a grid de OPs programadas e atualiza o titulo com a 
quantidade
*==================================================================*/
Static Function fUpdProgramada(cTpProg)

	Local oGet       := Nil
	Local aStru      := {}
	Local aLinha     := {}
	Local cTemp      := GetNextAlias()
	Local cCpo       := ""
	Local nX         := 0
	Local nQtd       := 0
	Local dFiltro    := CToD("  /  /  ")
	Local dFiltroAte := CToD("  /  /  ")

	If cTpProg == "E"	
		oGet       := oGetProgEmb
		dFiltro    := dFilProgEmb
		dFiltroAte := dFilEmbAte
	Else
		oGet := oGetProgSerra
	EndIf

	If cTpProg == "S"
		
		cQry := "SELECT '' C2_OK,G1_COD,B8_PRODUTO,SB1.B1_DESC,SB1.B1_TIPO,B8_LOTECTL,B8_SALDO,B8_SALDO2,B8_EMPENHO,B8_EMPENH2,B8_DATA,B8_LOCAL,SB1.B1_XGRLIGA,SB1.B1_XVARIAN,SB1.B1_XBITOLA,SB1.B1_XCOMPRI,SB1X.B1_XCOMPRI XX_COMPRI " + _crlf
		cQry += "FROM "+RetSQLName("SB8")+" SB8 " + _crlf
		cQry += "   INNER JOIN "+RetSQLName("SB1") +" SB1 ON B1_COD=B8_PRODUTO AND SB1.D_E_L_E_T_<>'*' " + _crlf
		cQry += "   INNER JOIN "+RetSQLName("SG1") +" SG1 ON B1_COD=G1_COMP AND SUBSTRING(G1_FILIAL,1,2)=B1_FILIAL AND SG1.D_E_L_E_T_<>'*' " + _crlf
		cQry += "   INNER JOIN "+RetSQLName("SB1") +" SB1X ON SB1X.B1_COD=G1_COD AND SB1X.D_E_L_E_T_<>'*' " + _crlf
		cQry += "WHERE B8_FILIAL='"+cFilAnt+"' " + _crlf
		cQry += "AND B8_SALDO > 0 " + _crlf
		cQry += "AND B8_SALDO2 > 0 " + _crlf
		cQry += "AND B8_LOCAL = '49' " + _crlf
		cQry += "AND SB1.B1_XCOMPRI = 6200 "+ _crlf
		cQry += "AND SB1X.B1_XCOMPRI <= "+cValToChar(nParCompr)+" "+ _crlf

		If nFilCorte > 0
			cQry += "AND SB1X.B1_XCOMPRI = "+cValToChar(nFilCorte)+" "+ _crlf
		EndIf

		If !Empty(cFilLiga)
			cQry += "AND SB1.B1_XGRLIGA='"+cFilLiga+"' " + _crlf
		EndIf

		If !Empty(cFilVarian)
			cQry += "AND SB1.B1_XVARIAN='"+cFilVarian+"' " + _crlf
		EndIf

		If !Empty(cFilBitola)
			cQry += "AND SB1.B1_XBITOLA='"+cFilBitola+"' " + _crlf
		EndIf

		If !Empty(cFilFus)
			cQry += "AND B8_LOTECTL LIKE '"+AllTrim(cFilFus)+"%' " + _crlf
		EndIf

		If !Empty(cFilLote)
			cQry += "AND B8_LOTECTL LIKE '%"+AllTrim(cFilLote)+"%' " + _crlf
		EndIf

		cQry += "AND SB8.D_E_L_E_T_<>'*' " + _crlf

		cQry += "ORDER BY B8_DATA " + _crlf
	
	Else

		cQry := "SELECT '' C2_OK,C2_NUM+C2_ITEM+C2_SEQUEN AS C2_OP,C2_PRODUTO,C2_QUANT,C2_QTSEGUM,C2_DATPRI,B1_XGRLIGA,B1_XVARIAN,B1_XBITOLA," + _crlf
		cQry += "ISNULL(QTD_PROD2,0) AS QTD_PROD2,(C2_QTSEGUM - ISNULL(QTD_PROD2,0)) AS XX_SALDO " + _crlf
		cQry += "FROM "+RetSQLName("SC2")+" SC2 " + _crlf
		cQry += "	INNER JOIN "+RetSQLName("SB1")+" SB1 ON SB1.D_E_L_E_T_='' AND B1_COD=C2_PRODUTO AND B1_XCOMPRI=3100 " + _crlf
		cQry += "	LEFT JOIN (SELECT H6_OP,SUM(H6_QTDPRO2) QTD_PROD2 FROM "+RetSQLName("SH6")+" SH6 WHERE SH6.D_E_L_E_T_='' AND H6_FILIAL='"+cFilAnt+"' GROUP BY H6_OP) SH6 ON SH6.H6_OP = C2_NUM+C2_ITEM+C2_SEQUEN " + _crlf
		cQry += "WHERE SC2.D_E_L_E_T_='' AND C2_FILIAL='"+cFilAnt+"' " + _crlf
		cQry += "AND C2_DATRF = '' " + _crlf
		cQry += "AND C2_DATPRI <= '"+DToS(Date())+"' " + _crlf
		cQry += "AND (C2_QTSEGUM - ISNULL(QTD_PROD2,0)) > 0 " + _crlf
		cQry += "AND SC2.C2_QUJE < SC2.C2_QUANT " + _crlf
		cQry += "AND SC2.C2_OBS = '>> PROGRAMADA <<' "+ _crlf

		If !Empty(dFiltro) .And. !Empty(dFiltroAte)
			cQry += "AND C2_DATPRI BETWEEN '"+DToS(dFiltro)+"' AND '"+DToS(dFiltroAte)+"' " + _crlf
		EndIf

		cQry += "ORDER BY C2_DATPRI DESC,C2_NUM ASC,C2_ITEM ASC,C2_SEQUEN ASC " + _crlf

	EndIf

	DbUseArea(.T.,"TOPCONN",TcGenQry(,,ChangeQuery(cQry)),cTemp,.F.,.T.)

	If cTpProg == "E"
		TCSetField(cTemp,"C2_DATPRI","D",/*nSize*/,/*nPrecision*/)
	EndIf

	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())

	aStru := oGet:aHeader
	oGet:aCols := {}

	While !(cTemp)->(Eof())

		aLinha := {}

		For nX := 1 To Len(aStru)
			cCpo := aStru[nX,2]
			aAdd(aLinha,(cTemp)->&(cCpo))
		Next nX

		aAdd(aLinha,.F.)
		aAdd(oGet:aCols,aLinha)

		nQtd += 1

		(cTemp)->(DbSkip())

	EndDo

	(cTemp)->(DbCloseArea())

	If nQtd == 0
		aAdd(oGet:aCols,fLinhaVaziaProg(aStru))
	EndIf

	changeGet(oGet)

	If cTpProg == "E"
		oSayProgEmb:SetText("Embalagens Programadas ("+cValToChar(nQtd)+")")
	Else
		oSayProgSerra:SetText("Serra ("+cValToChar(nQtd)+")")
	EndIf

Return(nQtd)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 21/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: Seleciona a OP da grid programada (Serra ou Embalagem) e filtra 
os lotes
*==================================================================*/
Static Function selecionaOP(cTpProg)

	Local oGet        := Nil
	Local nQuant      := 0
	Local nQtdeProduz := 0
	Local nSaldoXX    := 0

	If cTpProg == "E"
		oGet := oGetProgEmb
	Else
		oGet := oGetProgSerra
	Endif 

	If cTpProg == "E"
	
		If Empty(GdFieldGet("C2_OP",oGet:nAt,,oGet:aHeader,oGet:aCols))
			Return
		Endif 
		
	Else
		
		If Empty(GdFieldGet("B8_PRODUTO",oGet:nAt,,oGet:aHeader,oGet:aCols))
			Return
		Endif 
		
	EndIf

	If cTpProg == "E"

		nQuant        := GdFieldGet("C2_QTSEGUM",oGet:nAt,,oGet:aHeader,oGet:aCols)
		nQtdeProduz   := GdFieldGet("QTD_PROD2",oGet:nAt,,oGet:aHeader,oGet:aCols)
		nSaldoXX      := GdFieldGet("XX_SALDO",oGet:nAt,,oGet:aHeader,oGet:aCols)
		cOpProgramada := GdFieldGet("C2_OP",oGet:nAt,,oGet:aHeader,oGet:aCols)

		changeGet(oGet)

		nFilCompri   := 3100
		nQtDesejada  := nQuant
		nQtProduzida := nQtdeProduz
		nSaldoOP     := nSaldoXX
		cFilLiga     := PadR(GdFieldGet("B1_XGRLIGA",oGet:nAt,,oGet:aHeader,oGet:aCols),5)
		cFilVarian   := PadR(GdFieldGet("B1_XVARIAN",oGet:nAt,,oGet:aHeader,oGet:aCols),2)
		cFilBitola   := PadR(cValToChar(GdFieldGet("B1_XBITOLA",oGet:nAt,,oGet:aHeader,oGet:aCols)),1)

	ElseIf cTpProg == "S"

		changeGet(oGet)

		nFilCompri := 6200
		cFilLiga   := GdFieldGet("B1_XGRLIGA",oGet:nAt,,oGet:aHeader,oGet:aCols)
		cFilBitola := cValToChar(GdFieldGet("B1_XBITOLA",oGet:nAt,,oGet:aHeader,oGet:aCols))
		
		cLoteSerr := ""
		oLoteSerr:Refresh()

		cLocSerr := GdFieldGet("B8_LOCAL",oGet:nAt,,oGet:aHeader,oGet:aCols)
		oLocSerr:Refresh()

		cCodLote := GdFieldGet("B8_PRODUTO",oGet:nAt,,oGet:aHeader,oGet:aCols)
		oCodLote:Refresh()

		cCodProd := GdFieldGet("G1_COD",oGet:nAt,,oGet:aHeader,oGet:aCols)
		oCodProd:Refresh()

		nPesoLote := GdFieldGet("B8_SALDO",oGet:nAt,,oGet:aHeader,oGet:aCols)
		oPesoLote:Refresh()

		_nPcsLote := GdFieldGet("B8_SALDO2",oGet:nAt,,oGet:aHeader,oGet:aCols)
		oPecasLote:Refresh()

		cLoteSerr := GdFieldGet("B8_LOTECTL",oGet:nAt,,oGet:aHeader,oGet:aCols)
		oLoteSerr:Refresh()

		nCompSerrar := GdFieldGet("XX_COMPRI",oGet:nAt,,oGet:aHeader,oGet:aCols)
		oCompSerra:Refresh()

		cHrIniSerra := SubStr(Time(),1,5)
		oHrIniSerra:Refresh()

		Return

	Endif 

	oFilLiga:Refresh()
	oFilVarian:Refresh()
	oFilBitola:Refresh()

	fUpdSB8()
	
	fUpdProgramada('S')

Return
