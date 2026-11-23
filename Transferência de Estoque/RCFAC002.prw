#Include 'totvs.ch'
#Include "RWMAKE.CH"
#Include "TBICONN.CH"
#Include "TOPCONN.CH"
#Include 'FWMVCDef.ch'
#Include "PROTHEUS.CH"
#Include "RPTDEF.CH"
#Include "SHELL.CH"
#Include "FWPrintSetup.ch"
#Define _crlf Chr(13)+Chr(10)
#Define _cTmDE0 "001"
#Define _cTmRE0 "501"

/***********************************************************************
Autor: 
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Tipo: Atualizações
Rotina: Estoque/Custos
Função: 
Info: Transferência de Produtos
************************************************************************/
User Function debugReclass()

	//Cria o MsApp
	MsApp():New('SIGAEST')
	oApp:CreateEnv()

	//Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
	PtSetTheme("SUNSET")

	//Define o programa de inicialização
	oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",{|| RpcSetEnv("01","0201"), }),U_RCFAC002(),Final("TERMINO NORMAL")}
	
	//Seta Atributos
	__lInternet  := .T.
	lMsFinalAuto := .F.

	oApp:lMessageBar := .T.
	oApp:cModDesc    := 'SIGAEST'

	//Inicia a Janela
	oApp:Activate()

Return

/*=================================================================
Autor: 
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
User Function RCFAC002()

	Local cFiltroCod  := Space(TamSX3("B1_COD")[1])   
	Local cFiltroDesc := Space(TamSX3("B1_DESC")[1])
	Local cFiltroLote := Space(TamSX3("B8_LOTECTL")[1])
	Local cOpcao      := ""
	Local aOpcoes     := {"","01","02","22","24","25","28","33","35","49"}

	Private oGetEstoque := Nil
	Private oDlgEstoque := Nil
	Private aTamanho    := MsAdvSize()
	Private nJanLarg    := aTamanho[5]
	Private nJanAltu    := aTamanho[6]

	DEFINE MSDIALOG oDlgEstoque TITLE "Transferência de Produtos" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

    @ 007, 100 SAY "Produto:" SIZE 030, 007 OF oDlgEstoque PIXEL
    @ 005, 130 MSGET oFiltroProd VAR cFiltroCod SIZE 060, 010 OF oDlgEstoque PIXEL F3 "SB1" 

    @ 007, 200 SAY "Armazém:" SIZE 030, 007 OF oDlgEstoque PIXEL
    @ 005, 230 MSCOMBOBOX oFiltroArmaz VAR cOpcao ITEMS aOpcoes SIZE 030, 010 OF oDlgEstoque PIXEL 

	@ 005, 300 SAY "Descricao:" SIZE 030, 007 OF oDlgEstoque PIXEL
	@ 005, 330 MSGET oFiltroDesc VAR cFiltroDesc SIZE 060, 010 OF oDlgEstoque PIXEL

	@ 005, 400 SAY "Lote:" SIZE 030, 007 OF oDlgEstoque PIXEL
	@ 005, 430 MSGET oFiltroLote VAR cFiltroLote SIZE 030, 010 OF oDlgEstoque PIXEL F3 "SD5" // Criação de Índice novo e nova Consulta Padrão  Filial+Lote : D5_FILIAL+D5_LOTECTL

	@ 020, 005 BUTTON oBtnAtualizar PROMPT "&Atualizar" SIZE 042, 012 OF oDlgEstoque PIXEL Action(fUpdEstoque(cFiltroCod,cOpcao,cFiltroDesc,cFiltroLote))
	@ 005, 005 BUTTON oBtnConfirmar PROMPT "&Confirmar" SIZE 042, 012 OF oDlgEstoque PIXEL Action(xProdutos())

	fGetEstoque()
	fUpdEstoque()

	ACTIVATE MSDIALOG oDlgEstoque CENTERED

Return

/*=================================================================
Autor: 
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function fGetEstoque()

	Local nX           := 0      
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFieldFill   := {}
	Local aFields      := {"XX_OK","B2_LOCAL","NNR_DESCRI","B1_XGRLIGA","B1_XVARIAN","B1_XBITOLA","B1_XCOMPRI","B1_TIPO","B1_UM","B1_RASTRO","B8_LOTECTL","B8_SALDO","B8_SALDO2","B8_EMPENHO","DD_MOTIVO","B1_COD","B1_DESC"}
	Local aAlterFields := {}

	aAdd(aHeaderEx, {"SELECAO","XX_OK","@!",4,0,"","","C","","","",""})

	// Define field properties
	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))

	For nX := 1 to Len(aFields)
		If SX3->(DbSeek(aFields[nX]))
			aAdd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
	Next nX

	// Define field values
	For nX := 1 to Len(aFields)

		If DbSeek(aFields[nX])
			aAdd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		ElseIf Alltrim(aFields[nX]) == "XX_OK"
			aAdd(aFieldFill, "")
		Endif

	Next nX

	aAdd(aFieldFill, .F.)
	aAdd(aColsEx, aFieldFill)

	oGetEstoque         := MsNewGetDados():New( 040, 005, nJanAltu/2-25, nJanLarg/2-25, /*GD_INSERT+GD_DELETE+*/GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgEstoque, aHeaderEx, aColsEx)
	oGetEstoque:BChange := {||changeGet(@oGetEstoque)}

Return

/*=================================================================
Autor: 
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function changeGet(oGet)

	Local _x := 0

	nPosAtu  := oGet:nAt

	For _x := 1 to Len(oGet:aCols)

		GdFieldPut("XX_OK","",_x,oGet:aHeader,oGet:aCols)

	Next _x

	GdFieldPut("XX_OK","==>",oGet:nAt,oGet:aHeader,oGet:aCols)

	oGet:Refresh()

Return

/*=================================================================
Autor: 
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function fUpdEstoque(cFiltroCod,cFiltroLoc,cFiltroDesc,cFiltroLote)

	Local _x      := 0
	Local cQry    := ""
	Local _aLinha := {}

	cFiltroCod  := AllTrim(cFiltroCod)
    cFiltroLoc  := AllTrim(cFiltroLoc)
	cFiltroDesc := AllTrim(cFiltroDesc)
	cFiltroLote := AllTrim(cFiltroLote)

	cQry := "SELECT '' XX_OK,B1_COD,B1_DESC,B1_TIPO,B1_UM,B1_XGRLIGA,B1_XVARIAN,B1_XBITOLA,B1_XCOMPRI,B1_RASTRO,B2_LOCAL,NNR_DESCRI,B8_LOTECTL,ISNULL(B8_SALDO,B2_QATU) B8_SALDO,ISNULL(B8_SALDO2,B2_QTSEGUM) B8_SALDO2,ISNULL(B8_EMPENHO,B2_QEMP) B8_EMPENHO,DD_MOTIVO  "+_crlf
	cQry += "FROM SB1010 SB1"+_crlf
	cQry += "   INNER JOIN SB2010 SB2 ON SB2.D_E_L_E_T_='' AND SUBSTRING(SB2.B2_FILIAL,1,2)=SB1.B1_FILIAL AND SB2.B2_COD=SB1.B1_COD AND B2_FILIAL='"+cFilAnt+"'"+_crlf
	
    If !Empty(cFiltroCod)
        cQry += " AND B2_COD LIKE '" + cFiltroCod + "%' "+_crlf
    EndIf

    If !Empty(cFiltroLoc)
        cQry += " AND B2_LOCAL = '" + cFiltroLoc + "' "+_crlf
    EndIf

	cQry += "   INNER JOIN NNR010 NNR ON NNR.D_E_L_E_T_='' AND NNR_FILIAL=SB2.B2_FILIAL AND NNR.NNR_CODIGO=SB2.B2_LOCAL  "+_crlf
	cQry += "   LEFT  JOIN SB8010 SB8 ON SB8.D_E_L_E_T_='' AND SB8.B8_FILIAL=SB2.B2_FILIAL AND SB8.B8_PRODUTO=SB1.B1_COD AND B8_LOCAL=B2_LOCAL AND B8_SALDO>0 "+_crlf

	If !Empty(cFiltroLote)
        cQry += " AND B8_LOTECTL = '" + cFiltroLote + "' "+_crlf
    EndIf

	cQry += "   LEFT JOIN SDD010 SDD ON SDD.D_E_L_E_T_='' AND DD_FILIAL=B8_FILIAL AND DD_PRODUTO=B8_PRODUTO AND DD_LOCAL=B8_LOCAL AND DD_LOTECTL=B8_LOTECTL AND DD_SALDO>0  "+_crlf
	cQry += "WHERE SB1.D_E_L_E_T_='' "+_crlf
	cQry += "AND SB1.B1_TIPO IN ('MP','PI','PA') "+_crlf

	If !Empty(cFiltroDesc)
        cQry += "AND SB1.B1_DESC LIKE '%"+cFiltroDesc+"%' "+_crlf
    EndIf

	cQry += "AND SB2.B2_QATU > 0"

	If !Empty(cFiltroLoc)
        cQry += " AND B2_LOCAL = '" + cFiltroLoc + "' "+_crlf
	Else 
		cQry += "AND SB2.B2_LOCAL IN ('01','02','25','33','22','24','28','35','49')"
    EndIf
	
	cQry += "ORDER BY B1_LOCPAD,B1_DESC "+_crlf

	TcQuery cQry New Alias "SB2X"

	TCSetField("SB2X","Z2_EMISSAO","D")
	DbSelectArea("SB2X")

	SB2X->(DbGotop())

	_aStru := oGetEstoque:aHeader

	If !SB2X->(Eof())

		oGetEstoque:aCols := {}

		While !SB2X->(Eof())

			_aLinha := {}

			For _x := 1 to len(_aStru)
				_cCpo := _aStru[_x,2]
				aAdd(_aLinha,SB2X->&(_cCpo))
			Next _x

			aAdd(_aLinha,.F.)
			aAdd(oGetEstoque:aCols,_aLinha)

			SB2X->(DbSkip())

		EndDo

	Else

		_aLinha           := {}
		oGetEstoque:aCols := {}

		For _x := 1 to Len(_aStru)

			_cCpo := AllTrim(_aStru[_x,2])

			If _cCpo $ "XX_OK"
				aAdd(_aLinha,"")
			Else
				aAdd(_aLinha,CriaVar(_cCpo))
			Endif

		Next _x

		aAdd(_aLinha,.F.)
		aAdd(oGetEstoque:aCols,_aLinha)

	EndIf

	SB2X->(DbCloseArea())

	oGetEstoque:Refresh()

	changeGet(oGetEstoque)

Return

/*=================================================================
Autor: 
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function xConfirm(cCodOrigem,cDescOrigem,cLocOrigem,cLote,cCodDestino,cDescDestino,cLocDestino,cLoteDestino)

    Local aMATA650      := {} //Array com os campos
    Local nSitua        := 0
    Local cMensagem     := ""

    Private lMsErroAuto  := .F.
    Private oDlg         := Nil
    Private oLiga        := Nil
    Private oVariante    := Nil
    Private oBitola      := Nil
    Private oCompri      := Nil
    Private oPesoLote    := Nil
    Private oPcsLote     := Nil
    Private oQtdePcs     := Nil
    Private oPesoCons    := Nil
    Private oRastroDest  := Nil
    Private oPesoOrigem  := Nil
    Private oPesoDestino := Nil
    Private cMotivo      := ""
    Private aCols        := oGetEstoque:aCols
    Private aHeader      := oGetEstoque:aHeader
    Private n            := oGetEstoque:nAt

    nPesoLote    := GdFieldGet("B8_SALDO")
    nPcsLote     := GdFieldGet("B8_SALDO2") 
    nPesoCons    := 0
    nQtdePcs     := 0
    nPesoDestino := 0

    // Posiciona no Produto Destino para pegar as características dele
    DbSelectArea("SB1")
    SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD
    If SB1->(DbSeek(xFilial("SB1") + cCodDestino))
        cLiga     := SB1->B1_XGRLIGA 
        cVariante := SB1->B1_XVARIAN 
        nBitola   := SB1->B1_XBITOLA 
        nCompri   := SB1->B1_XCOMPRI
    EndIf

    _lRet := .T.

    DEFINE MSDIALOG oDlg TITLE "Reclassificação de Materiais" FROM 000, 000  TO 300, 600 COLORS 0, 16777215 PIXEL

    DbSelectArea("SB8")
    SB8->(DbSetOrder(3))

    If SB8->(!DbSeek(xFilial("SB8")+AvKey(cCodOrigem,"B8_PRODUTO")+Avkey(cLocOrigem,"B8_LOCAL")+AvKey(cLote,"B8_LOTECTL")))

        SB8->(DbSetOrder(3))
    
        If SB8->(DbSeek(xFilial("SB8")+AvKey(cCodDestino,"B8_PRODUTO")+Avkey(cLocDestino,"B8_LOCAL")+Avkey(cLoteDestino,"B8_LOTECTL")))
            
            //Não Loteado x Loteado
            nSitua := 1
            // ---

            nPesoDestino := SB8->B8_SALDO

			@ 006, 200 SAY oSay1 PROMPT "Comprimento (mm)" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL 
    		@ 005, 260 MSGET oCompri VAR nCompri SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999" Valid(nPesoCons := xPesoCalc(nBitola, nQtdePcs, nCompri), oPesoCons:Refresh(), .T.)
            
            @ 043, 010 SAY oSay1 PROMPT "Quantidade a Transferir " SIZE 050, 015 OF oDlg COLORS 0, 16777215 PIXEL
            @ 044, 060 MSGET oQtdTransf VAR nQtdePcs SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999" Valid(nPesoCons := xPesoCalc(nBitola, nQtdePcs,nCompri),oPesoCons:Refresh())
            
            @ 044, 110 SAY oSay1 PROMPT "Peso Origem (kgs)" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
            @ 044, 175 MSGET oPesoLote VAR nPesoLote SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999.99" When .F.

            @ 067, 110 SAY oSay1 PROMPT "Peso Destino (kgs)" SIZE 060, 015 OF oDlg COLORS 0, 16777215 PIXEL
            @ 064, 175 MSGET oPesoDestino VAR nPesoDestino SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999.99" When .F.

        Else 

            //Não Loteado x Não Loteado
            nSitua := 2
            // ---

            nPesoDestino := Posicione("SB2",1,xFilial("SB2")+AvKey(cCodDestino,"B2_COD")+Avkey(cLocDestino,"B2_LOCAL"),"B2_QATU") //Peso destino
            nQtdePcs     := 0 //Peças é zerado

			@ 006, 200 SAY oSay1 PROMPT "Comprimento (mm)" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL 
    		@ 005, 260 MSGET oCompri VAR nCompri SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999" When .F.

            @ 043, 010 SAY oSay1 PROMPT "Quantidade a Transferir " SIZE 050, 015 OF oDlg COLORS 0, 16777215 PIXEL
            @ 044, 060 MSGET oQtdTransf VAR nQtdePcs SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999" When .F.
            
            @ 044, 110 SAY oSay1 PROMPT "Peso Origem (kgs)" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
            @ 044, 175 MSGET oPesoLote VAR nPesoLote SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999.99" Valid(nPesoCons := nPesoDestino := nPesoLote,oPesoDestino:Refresh())

            @ 067, 110 SAY oSay1 PROMPT "Peso Destino (kgs)" SIZE 060, 015 OF oDlg COLORS 0, 16777215 PIXEL
            @ 064, 175 MSGET oPesoDestino VAR nPesoDestino SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999.99" When .F.

        Endif
    
    Elseif SB8->(DbSeek(xFilial("SB8")+Avkey(cCodOrigem,"B8_PRODUTO")+AvKey(cLocOrigem,"B8_LOCAL")+AvKey(cLote,"B8_LOTECTL")))

        SB8->(DbSetOrder(3))

        If SB8->(DbSeek(xFilial("SB8")+AvKey(cCodDestino,"B8_PRODUTO")+AvKey(cLocDestino,"B8_LOCAL")+AvKey(cLoteDestino,"B8_LOTECTL")))
            
            //Loteado x Loteado
            nSitua := 3 
            // ---

            nPesoDestino := SB8->B8_SALDO

		    @ 006, 200 SAY oSay1 PROMPT "Comprimento (mm)" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL 
    		@ 005, 260 MSGET oCompri VAR nCompri SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999" Valid(nPesoCons := xPesoCalc(nBitola, nQtdePcs, nCompri), oPesoCons:Refresh(), .T.)

            @ 043, 010 SAY oSay1 PROMPT "Quantidade a Transferir " SIZE 050, 015 OF oDlg COLORS 0, 16777215 PIXEL
            @ 044, 060 MSGET oQtdTransf VAR nQtdePcs SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999" Valid(Situa3(nQtdePcs,nPesoLote,@nPesoCons,nPcsLote),oPesoCons:Refresh())
            
            @ 044, 110 SAY oSay1 PROMPT "Peso Origem (kgs)" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
            @ 044, 175 MSGET oPesoLote VAR nPesoLote SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999.99" When .F.    
    
            @ 067, 110 SAY oSay1 PROMPT "Peso destino (kgs)" SIZE 060, 015 OF oDlg COLORS 0, 16777215 PIXEL
            @ 064, 175 MSGET oPesoDestino VAR nPesoDestino SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999.99" When .F.
    
        Else
            
            //Loteado x Não Loteado
            nSitua := 4 
			//Pegando informações do produto origem
			DbSelectArea("SB1")
			SB1->(DbSetOrder(1)) // B1_FILIAL + B1_COD
			If SB1->(DbSeek(xFilial("SB1") + cCodOrigem))
				cLiga     := SB1->B1_XGRLIGA 
				cVariante := SB1->B1_XVARIAN 
				nBitola   := SB1->B1_XBITOLA 
				nCompri   := SB1->B1_XCOMPRI
			EndIf
			// ---

			@ 006, 200 SAY oSay1 PROMPT "Comprimento (mm)" SIZE 050, 007 OF oDlg COLORS 0, 16777215 PIXEL 
   			@ 005, 260 MSGET oCompri VAR nCompri SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999" Valid(nPesoCons := xPesoCalc(nBitola, nQtdePcs, nCompri), oPesoCons:Refresh(), .T.)

            nPesoDestino := Posicione("SB2",1,xFilial("SB2")+AvKey(cCodDestino,"B2_COD")+Avkey(cLocDestino,"B2_LOCAL"),"B2_QATU") //Peso destino
            
            @ 043, 010 SAY oSay1 PROMPT "Quantidade a Transferir " SIZE 050, 015 OF oDlg COLORS 0, 16777215 PIXEL
            @ 044, 060 MSGET oQtdTransf VAR nQtdePcs SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999" Valid(nPesoCons := xPesoCalc(nBitola, nQtdePcs,nCompri),oPesoCons:Refresh())
            
            @ 044, 110 SAY oSay1 PROMPT "Peso Origem (kgs)" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
            @ 044, 175 MSGET oPesoLote VAR nPesoLote SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999.99" When .F.    

            @ 067, 110 SAY oSay1 PROMPT "Peso destino (kgs)" SIZE 060, 015 OF oDlg COLORS 0, 16777215 PIXEL
            @ 064, 175 MSGET oPesoDestino VAR nPesoDestino SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999.99" When .F.
        
        Endif 
        
    Endif   

    @ 006, 010 SAY oSay1 PROMPT "Liga" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 005, 040 MSGET oLiga VAR cLiga SIZE 030, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.

    @ 006, 080 SAY oSay1 PROMPT "Variante" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 005, 110 MSGET oVariante VAR cVariante SIZE 010, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.

    @ 006, 140 SAY oSay1 PROMPT "Bitola (pol)" SIZE 030, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 005, 170 MSGET oBitola VAR nBitola SIZE 010, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.

    @ 087, 095 SAY oSay1 PROMPT "Peso a Reclassificar (kgs)" SIZE 095, 007 OF oDlg COLORS 0, 16777215 PIXEL
    @ 084, 175 MSGET oPesoCons VAR nPesoCons SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL Picture "@E 999,999.99" When .F.

    @ 120, 060 BUTTON oButton2 PROMPT "Reclassificar" SIZE 037, 012 OF oDlg PIXEL Action(Validar(nSitua))
    @ 120, 200 BUTTON oButton2 PROMPT "Voltar" SIZE 037, 012 OF oDlg PIXEL Action(_lRet := .F.,oDlg:End())

    ACTIVATE MSDIALOG oDlg CENTERED

    If !_lRet
        Return .F.
    Endif

    cMensagem := "Deseja realmente confirmar as quantidades informadas?" + _crlf + _crlf
    cMensagem += "Comprimento (mm): " + cValToChar(nCompri) + _crlf
    cMensagem += "Quantidade a Transferir em Peças: " + cValToChar(nQtdePcs)

    If !FWAlertYesNo(cMensagem, "Reclassificação")
        Return .F.
    EndIf

    Begin Transaction

        aMATA650 := {}

        aAdd(aMATA650,{'C2_PRODUTO' ,cCodDestino 				,Nil})
        aAdd(aMATA650,{'C2_LOCAL'   ,cLocDestino 				,Nil})
        aAdd(aMATA650,{'C2_QUANT'   ,nPesoCons   				,Nil})
        aAdd(aMATA650,{'C2_QTSEGUM' ,IIf(nSitua == 4,0,nQtdePcs),Nil})
        aAdd(aMATA650,{'C2_DATPRI'  ,dDataBase   				,Nil})
        aAdd(aMATA650,{'C2_DATPRF'  ,dDataBase   				,Nil})
        aAdd(aMATA650,{'C2_BATCH'   ,'S'         				,Nil})
        aAdd(aMATA650,{'C2_RECURSO' ,'RECLAS'    				,Nil})
        aAdd(aMATA650,{'C2_OBS'     ,cMotivo     				,Nil})
        aAdd(aMATA650,{'AUTEXPLODE' ,"N"         				,Nil})

        lMsErroAuto := .F.

        MSExecAuto({|x,Y| Mata650(x,Y)},aMata650,3)

        If !lMsErroAuto

            _cOp := SC2->(C2_NUM+C2_ITEM+C2_SEQUEN)

            If !MTA241(_cTmRE0,cCodOrigem,cLocOrigem,nPesoCons,IIf(nSitua == 4,0,nQtdePcs),_cOp,cLote)
                DisarmTransaction()   //Desfaz a Transação em caso de erro
                Return .F.
			Else 
				lOk := .T.
            Endif

            If !MTA250(_cOp,cCodDestino,nPesoCons,nQtdePcs)
                DisarmTransaction()   //Desfaz a Transação em caso de erro
				Return .F.
			Else 
				lOk := .T.
            Endif 

        Else
            MostraErro("\dirdoc\","error_mata650.log")
			lOk := .F.
        Endif 

    End Transaction

	If lOk 
		FwAlertSuccess("Reclassificação Realizada com Sucesso! Ordem de Produção: "+_cOp,"Reclassificacao")
	Else 
		FwalertError("Erro ao reclassificar!","Produto Destino")
	Endif 


Return(.T.)

/*=================================================================
Autor: 
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function validarDestino(cCodDestino,cDescDestino)

	Local aArea := GetArea()
	Local lRet  := .T.

	If Empty(cCodDestino)

		cDescDestino := Space(TamSX3("B1_DESC")[1])
		lRet         := .F.

	EndIf

	If lRet

		DbSelectArea("SB1")
		SB1->(DbSetOrder(1))

		If !(SB1->(DbSeek(xFilial("SB1")+cCodDestino)))
			FwalertError("Produto "+cCodDestino+" não localizado!!","Produto Destino")
			lRet := .F.
		Else
			cDescDestino := SB1->B1_DESC
			oDescDestino:Refresh()
			lRet := .T.
		Endif

	Endif 

	RestArea(aArea)

Return(lRet)

/*=================================================================
Autor: 
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function MTA241(_cParTM,_cParCod,_cParLocal,_nParQt1um,_nParQt2um,_cParOp,_cParLote)

	Local _aCab1    := {}  // Array para o cabeçalho do movimento
	Local _aItem    := {}  // Array para os itens do movimento
	Local _atotitem := {}  // Array para agrupar todos os itens
	Local cErro     := ""
	Local lRet      := .T.

	Private lMsHelpAuto := .T. // Se .T., exibe mensagens de help
	Private lMsErroAuto := .F. // Se .F., não exibe erros automáticos

	dData := dDataBase

	_aCab1 := {;
	{"D3_DOC"    , _cParOp          ,Nil},; // Número do documento (gerado automaticamente)
	{"D3_TM"     , _cParTM          ,Nil},; // Tipo de movimento
	{"D3_CC"     , AvKey("","D3_CC"),Nil},; // Centro de custo (vazio)
	{"D3_EMISSAO", dData            ,Nil};  // Data de emissão (data atual)
	}

	// Monta os itens do movimento
	DbSelectArea("SB1")
	SB1->(DbSetOrder(1))

	SB1->(DbSeek(xFilial("SB1")+_cParCod))

	_aItem := {}

	aAdd(_aItem,{"D3_COD"    , _cParCod   ,Nil}) // Código do produto
	aAdd(_aItem,{"D3_UM"     , SB1->B1_UM ,Nil}) // Unidade de medida
	aAdd(_aItem,{"D3_QUANT"  , _nParQt1um ,Nil}) // Quantidade do item (1.99)
	aAdd(_aItem,{"D3_QTSEGUM", _nParQt2um ,Nil}) // Quantidade do item (1.99)
	aAdd(_aItem,{"D3_LOCAL"  , _cParLocal ,Nil}) // Local de estoque
	
	If !Empty(_cParLote)
		aAdd(_aItem,{"D3_LOTECTL", _cParLote ,Nil}) // Local de estoque
	EndIf

	aAdd(_aItem,{"D3_OP", _cParOp ,Nil}) // Custo do item

	// Adiciona o item ao array de itens
	aAdd(_atotitem, _aItem)

	// Executa a rotina de inclusão de movimento (MATA241)
	// Certifique-se de que _aCab1 e _atotitem são arrays válidos
	lMsErroAuto := .F.

	If ValType(_aCab1) == "A" .AND. ValType(_atotitem) == "A"
		MSExecAuto({|x, y, z| MATA241(x, y, z)}, _aCab1, _atotitem, 3)
	Else
		MessageBox("Erro: Arrays inválidos para execução automática.", "Erro",16)
		lRet := .F.
	EndIf

	If lRet

		// Verifica se houve erro na execução automática
		If lMsErroAuto

			cErro := MostraErro('\dirdoc\','error.log') // Exibe mensagem de erro

			DisarmTransaction() // Desfaz a transação em caso de erro

			Showlog(cErro)

			lRet := .F.

		Endif 

	Endif 

Return(lRet)

/*=================================================================
Autor: 
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function MTA250(cOpProd,cProdApt,nQtdOp,lEstorno)

	Local aVetor := {}
	Local cOp    := ""
	Local cCod   := ""
	Local _lRet  := .F.
	Local cTmPad := SuperGetMv("MV_TMPAD",.F.,"010")

	Private lMsErroAuto := .F.

	SC2->(DbSetOrder(1))

	If SC2->(DbSeek(xFilial("SC2")+cOpProd))

		cOp    := SC2->C2_NUM + SC2->C2_ITEM + SC2->C2_SEQUEN
		cCod   := SC2->C2_PRODUTO
		aVetor := {}

		aAdd(aVetor,{"D3_OP"      ,cOp       ,Nil})
		aAdd(aVetor,{"D3_COD"     ,cCod      ,Nil})
		aAdd(aVetor,{"D3_QUANT"   ,nPesoCons ,Nil})
		aAdd(aVetor,{"D3_QTSEGUM" ,nQtdePcs  ,Nil})
		aAdd(aVetor,{"D3_TM"      ,cTmPad    ,Nil})

		If !Empty(cLoteDestino)
			aAdd(aVetor,{"D3_LOTECTL" ,cLoteDestino,Nil})
		EndIf

		lMsErroAuto := .F.

		MSExecAuto({|x, y| mata250(x, y)},aVetor, 3 )

		If lMsErroAuto
			MostraErro()
			_lRet := .F.
		Else
			_lRet := .T.
		Endif

	Else
		MsgStop("Op não localizada!!!","Atenção")
		_lRet := .F.
	Endif

Return(_lRet)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: Validação de Regras
*==================================================================*/
Static Function validar(nSitua)

	If nSitua == 1 .Or. nSitua == 3

		If nQtdePcs <= 0

			FwalertError("Quantidade de peças menor ou igual à zero inválida!","Quantidade inválida")

			_lRet := .F.

		Else

			_lRet := .T.

			oDlg:End()

		Endif 

	Else 

		_lRet := .T.

		oDlg:End()

	Endif 

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: Nova tela de Produtos
*==================================================================*/
Static Function xProdutos()

	Local cOpcao      := ""
	Local aOpcoes     := {"01","02","22","24","25","28","33","35","49"}
	Local cCodOrigem  := ""
	Local cLocOrigem  := ""
	Local cDescOrigem := ""
	Local cLote       := ""

	Private oCodOrigem
	Private oDescOrigem
	Private oCodDestino
	Private oDescDestino
	Private oLoteOrigem
	Private oLoteDestino
	Private aCols         := oGetEstoque:aCols
	Private aHeader       := oGetEstoque:aHeader
	Private n             := oGetEstoque:nAt

	Private cCodDestino   := Space(TamSX3("B1_COD")[1])
	Private cDescDestino  := ""
	Private cLoteDestino  := Space(TamSX3("B8_LOTECTL")[1])
	Private cLocDestino   := ""

	cCodOrigem  := GdFieldGet("B1_COD") 
	cLocOrigem  := GdFieldGet("B2_LOCAL") 
	cDescOrigem := GdFieldGet("B1_DESC") 
	cLote       := GdFieldGet("B8_LOTECTL") 

	DEFINE MSDIALOG oDlg TITLE "Transferência de Produtos" FROM 000, 000  TO 150, 900 COLORS 0, 16777215 PIXEL

	@ 011, 010 SAY oSay1 PROMPT "Produto Origem" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 055 MSGET oCodOrigem VAR cCodOrigem SIZE 045, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.
	
	@ 010, 120 MSGET oDescOrigem VAR cDescOrigem SIZE 130, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.

	@ 030, 010 SAY oSay1 PROMPT "Produto Destino" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 055 MSGET oCodDestino VAR cCodDestino SIZE 50, 010 OF oDlg COLORS 0, 16777215 PIXEL F3 "SB1" Valid(validarDestino(cCodDestino,@cDescDestino),oLoteDestino:Refresh())
	
	@ 028, 120 MSGET oDescDestino VAR cDescDestino SIZE 130, 010 OF oDlg COLORS 0, 16777215 PIXEL When .F.

	@ 011, 255 SAY oSay1 PROMPT "Lote Origem" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 290 MSGET oLoteOrigem VAR cLote SIZE 050, 005 OF oDlg COLORS 0, 16777215 PIXEL F3 "SB8MFG" When ExisteLote(cCodOrigem,cLocOrigem,cLote)

	// Remoção da consulta padrão, para acrescentar tela nova de busca de lote destino - Nicolas B. Fernandes 2026/02/26
	@ 030, 255 SAY oSay1 PROMPT "Lote Destino" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 290 MSGET oLoteDestino VAR cLoteDestino SIZE 038, 005 OF oDlg COLORS 0, 16777215 PIXEL Valid(ExisteLote(cCodDestino,cOpcao,cLoteDestino),oLoteDestino:Refresh())
	@ 028, 330 BUTTON oBtnBuscaLote PROMPT "..." SIZE 010, 006 OF oDlg PIXEL Action( cLoteDestino := u_SelecLote(cCodDestino, cOpcao), oLoteDestino:Refresh() )

	@ 011, 348 SAY oSay1 PROMPT "Armazem Origem" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 010, 395 MSGET oArmazemOrigem VAR cLocOrigem SIZE 020, 005 OF oDlg COLORS 0, 16777215 PIXEL When .F.

	@ 030, 348 SAY oSay1 PROMPT "Armazem Destino" SIZE 060, 007 OF oDlg COLORS 0, 16777215 PIXEL
	@ 028, 395 MSCOMBOBOX oArmazemDestino VAR cOpcao ITEMS aOpcoes SIZE 030, 005 OF oDlg COLORS 0, 16777215 PIXEL

	@ 060, 060 BUTTON oButton2 PROMPT "Confirmar" SIZE 037, 012 OF oDlg PIXEL Action( If( xConfirm(cCodOrigem,cDescOrigem,cLocOrigem,cLote,cCodDestino,cDescDestino,cOpcao,cLoteDestino), oDlg:End(), Nil ) ) When !Empty(cCodDestino)	
	@ 060, 340 BUTTON oButton2 PROMPT "Voltar" SIZE 037, 012 OF oDlg PIXEL Action(_lRet:= .F.,oDlg:End())
	
	ACTIVATE MSDIALOG oDlg CENTERED
	
Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: Validação da tabela de lotes SB8
*==================================================================*/
Static Function ExisteLote(cCod,cLoc,cLote)

	Local lRet     := .F.
	Local cAreaSB8 := GetArea()

	If !Empty(cCod) .Or. !Empty(cLote) //Produto e lote informados então entro na validação

		DbSelectArea("SB8")
		SB8->(DbSetOrder(3))

		If SB8->(DbSeek(xFilial("SB8")+AvKey(cCod,"B8_PRODUTO")+AvKey(cLoc,"B8_LOCAL")+AvKey(cLote,"B8_LOTECTL")))
			lRet := .T.
		EndIf

	Endif 

	RestArea(cAreaSB8)

Return(lRet)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function Situa3(nQtdePcs,nPesoLote,nPesoCons,nPcsLote)

	Local lRet  := .F.
	Local aArea := GetArea()

	If nQtdePcs <= nPcsLote
		nPesoCons := nQtdePcs * (nPesoLote/nPcsLote)
		lRet      := .T.
	Else
		FwalertError("Quantidade de pecas superior ao saldo disponivel em estoque!","Quantidade invalida")
	Endif

	RestArea(aArea)

Return(lRet)

/*=================================================================
Autor: Nicolas B. Fernandes
Data: 26/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
User Function SelecLote(cProduto, cArmazem)

    Local oDlg, oTela, oColumn
    Local cTitulo   := "SELEÇÃO DE LOTE DESTINO"
    Local aLotes    := {}
    Local cRetorno  := ""
    
    Default cProduto := ""
    Default cArmazem := ""

    If Empty(cProduto)
        MsgAlert("Preencha o Produto Destino antes de buscar o lote.", "Aviso")
        Return cRetorno
    EndIf

    aLotes := xFiltraLotes(cProduto, cArmazem)

    If Len(aLotes) == 0
        MsgAlert("Nenhum lote disponível para o Produto/Armazém selecionado.", "Aviso")
        Return cRetorno
    EndIf

    DEFINE DIALOG oDlg TITLE cTitulo FROM 100,000 TO 400,600 PIXEL
    
    DEFINE FWBROWSE oTela DATA ARRAY ARRAY aLotes NO CONFIG NO REPORT NO LOCATE OF oDlg
    
    Add Column oColumn DATA { || aLotes[oTela:At(), 1] } TITLE "Lote"        SIZE 050 OF oTela
    Add Column oColumn DATA { || aLotes[oTela:At(), 2] } TITLE "Armazém"     SIZE 030 OF oTela
    Add Column oColumn DATA { || Transform(aLotes[oTela:At(), 3], "@E 999,999,999.99") } TITLE "Saldo" SIZE 050 OF oTela
    Add Column oColumn DATA { || DTOC(aLotes[oTela:At(), 4]) } TITLE "Validade" SIZE 040 OF oTela

    // No duplo clique, pega o Lote (posição 1 do array
	oTela:bLDblClick := {|| cRetorno := aLotes[oTela:At(), 1], oDlg:End() }

    ACTIVATE FWBROWSE oTela
    ACTIVATE DIALOG oDlg CENTERED

Return cRetorno

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 26/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function xFiltraLotes(cProduto, cArmazem)

    Local aLista := {}
    Local cQuery := ""
    Local cTemp  := GetNextAlias()
    
    cQuery := " SELECT B8_LOTECTL, B8_LOCAL, B8_SALDO, B8_DTVALID " + CRLF
    cQuery += " FROM " + RetSqlName("SB8") + " SB8 " + CRLF
    cQuery += " WHERE SB8.B8_FILIAL = '" + xFilial("SB8") + "' " + CRLF
    cQuery += " AND SB8.B8_PRODUTO = '" + cProduto + "' " + CRLF
    
    // Se informou armazém, filtra por ele também
    If !Empty(cArmazem)
        cQuery += " AND SB8.B8_LOCAL = '" + cArmazem + "' " + CRLF
    EndIf
    
    cQuery += " AND SB8.D_E_L_E_T_ = ' ' " + CRLF
    cQuery += " ORDER BY B8_DTVALID, B8_LOTECTL " + CRLF

    MPSysOpenQuery(cQuery, cTemp)

    While !(cTemp)->(EOF())
        aAdd(aLista, {;
            AllTrim((cTemp)->B8_LOTECTL),;            // [1] Lote
            AllTrim((cTemp)->B8_LOCAL),;              // [2] Armazém
            (cTemp)->B8_SALDO,;                       // [3] Saldo
            STOD((cTemp)->B8_DTVALID);                // [4] Validade
        })
        (cTemp)->(DbSkip())
    EndDo
    
    (cTemp)->(DbCloseArea())
    
Return(aLista)

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 26/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function xPesoCalc(nBitola, nQtdePcs, nCompri)

	Local nCalculado := 0
	Local nFator     := 0

	Do Case 
		Case nBitola == 4 
			nFator := 21.81
		Case nBitola == 5
			nFator := 34.08
		Case nBitola == 6 
			nFator := 49.07
		Case nBitola == 7
			nFator := 66.79
	End Case

	If nFator > 0
		nCalculado := Round( (nCompri / 1000) * nQtdePcs * nFator, 2 )
		nCalculado := Round( nCalculado / 1000, 3 )
		nCalculado := Round( nCalculado * 1000, 3 )
	Endif

Return(nCalculado)
