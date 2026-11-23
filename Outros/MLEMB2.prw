#Include "totvs.ch"
#Include "topconn.ch"
#Include "tbiconn.ch"
#Define _crlf Chr(13)+Chr(10)

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 16/09/2026
Consultoria: Fixsystem
Tipo: Atualizações
Rotina: Faturamento
Função: MLPROG01
Info: Tela de programação 3100
************************************************************************/
User Function z3telaProgSer()

	//Cria o MsAppa
	MsApp():New('SIGAPCP')
	oApp:CreateEnv()

	//Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
	PtSetTheme("SUNSET")

	//Define o programa de inicialização
	oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",{|| RpcSetEnv("01","0201"),}),U_MLEMB2(),Final("TERMINO NORMAL")}

	//Seta Atributos
	__lInternet  := .T.
	lMsFinalAuto := .F.
	
	oApp:lMessageBar := .T.
	oApp:cModDesc    := 'SIGAPCP'

	//Inicia a Janela
	oApp:Activate()
	
Return Nil

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 16/09/2026
Consultoria: Fixsystem
Tipo: Atualizações
Rotina: Faturamento
Função: MLEMB2
Info: Tela de programação 3100
************************************************************************/
User Function MLEMB2()

	//Local oBtnFiltrar          := Nil
	Local oBtnGerarOp          := Nil
	Local oBtnExcluirOp        := Nil
	Local oBtnEncerrar         := Nil
	Local oBtnFechar           := Nil
	Local oSay1                := Nil
	Local oSay2                := Nil
	Private cProduto           := Space(TamSX3("B1_COD")[1])
	Private cDescricao         := Space(TamSX3("B1_DESC")[1])
	Private cProduto2          := Space(TamSX3("B1_COD")[1])
	Private cDescricao2        := Space(TamSX3("B1_DESC")[1])
	Private aProdPai           := {}
	Private cCompLigaVarBit    := Space(60)
	Private nQtAmarrado        := 0
	Private nCompri            := 0
	Private nLiga              := 0
	Private nVariant           := 0
	Private nBitola            := 0
	Private dDtProgramada      := Date()
	Private oDtFilIni          := Nil
	Private oDtFilFim          := Nil
	Private dDtFilIni          := Date()
	Private dDtFilFim          := Date()
	Private oRecurso           := Nil
	Private oQtProg            := Nil
	Private oProduto           := Nil
	Private oDescricao         := Nil
	Private oCompLigaVarBit    := Nil
	Private oDtInicio          := Nil
	Private oDtTermino         := Nil
	//Private oObservacao        := Nil
	Private cObservacao        := ">> PROGRAMADA <<" //Space(TamSX3("C2_OBS")[1])
	Private cVisEncer          := "Não"
	Private oDlgProgramacao    := Nil
	Private oGetSC2            := Nil
	Private oBtnProd           := Nil
	Private oGetProduto        := Nil
	Private _aFator            := {}
	Private aTamanho           := MsAdvSize()
	Private nJanLarg           := aTamanho[5]
	Private nJanAltu           := aTamanho[6]

	DEFINE MSDIALOG oDlgProgramacao TITLE "Programação de Ordens de Produção da Embalagem" FROM 000, 000  TO nJanAltu, nJanLarg COLORS 0, 16777215 PIXEL

	// ---- Filtros ----
	@ 005, 006 SAY oSay1 PROMPT "Filtros >>" SIZE 040, 007 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	@ 005, 135 SAY oSay2 PROMPT "Data de:" SIZE 035, 007 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	@ 004, 175 MSGET oDtFilIni VAR dDtFilIni SIZE 041, 010 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	@ 005, 225 SAY oSay2 PROMPT "Data até:" SIZE 035, 007 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	@ 004, 265 MSGET oDtFilFim VAR dDtFilFim SIZE 041, 010 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	@ 004, (nJanLarg - 050) BUTTON oBtnFechar PROMPT "&Tela Embalagem" SIZE 60, 012 OF oDlgProgramacao PIXEL Action(xTelaEmb())

	// ---- Nova Programação ----
	@ 020, 006 SAY oSay1 PROMPT "Nova Programação" SIZE 090, 007 OF oDlgProgramacao COLORS 1000, 16777215 PIXEL

	@ 040, 005 SAY oSay2 PROMPT "Produto:" SIZE 075, 007 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	@ 049, 005 MSGET oProduto VAR cProduto SIZE 060, 010 OF oDlgProgramacao COLORS 0, 16777215 PIXEL 
	@ 049, 070 BUTTON oBtnProd PROMPT "..." SIZE 015, 010 OF oDlgProgramacao PIXEL Action(xSelectProd())
	@ 040, 130 SAY oSay2 PROMPT "Qt Amarrado:" SIZE 075, 007 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	@ 049, 125 MSGET oQtProg VAR nQtAmarrado SIZE 060, 010 OF oDlgProgramacao COLORS 0, 16777215 PIXEL Picture "@E 999,999.99"
	@ 040, 190 SAY oSay2 PROMPT "Data Programação:" SIZE 090, 007 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	@ 049, 190 MSGET oDtInicio VAR dDtProgramada SIZE 070, 010 OF oDlgProgramacao COLORS 0, 16777215 PIXEL

	@ 070, 005 SAY oSay2 PROMPT "Descrição:" SIZE 075, 007 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	@ 079, 005 MSGET oDescricao VAR cDescricao SIZE 600, 010 OF oDlgProgramacao COLORS 0, 16777215 PIXEL When .F.

	@ 100, 005 SAY oSay2 PROMPT "Comp./Liga/Var./Bitola:" SIZE 090, 007 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	@ 109, 005 MSGET oCompLigaVarBit VAR cCompLigaVarBit SIZE 250, 010 OF oDlgProgramacao COLORS 0, 16777215 PIXEL When .F.

	//@ 130, 005 SAY oSay2 PROMPT "Observação:" SIZE 075, 007 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	//@ 139, 005 MSGET oObservacao VAR cObservacao SIZE 600, 010 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	@ 130, 005 SAY oSay2 PROMPT "Vis.Encerradas:" SIZE 075, 007 OF oDlgProgramacao COLORS 0, 16777215 PIXEL
	@ 139, 005 MSCOMBOBOX oComprCorte VAR cVisEncer ITEMS {"Sim","Não"} SIZE 072, 010 OF oDlgProgramacao COLORS 0, 16777215 PIXEL valid(xAtuPainel())

	@ 168, 085 BUTTON oBtnGerarOp PROMPT "&Gerar OP" SIZE 070, 012 OF oDlgProgramacao PIXEL Action(xGerarOP())
	@ 168, 160 BUTTON oBtnExcluirOp PROMPT "Excluir OP" SIZE 070, 012 OF oDlgProgramacao PIXEL Action(excluirOP())
	@ 168, 235 BUTTON oBtnEncerrar PROMPT "&Encerrar OP" SIZE 055, 012 OF oDlgProgramacao PIXEL Action(encerrarOP())

	// ---- Grid de Ordens de Produção (SC2) ----
	@ 190, 006 SAY oSay1 PROMPT "Ordens de Produção" SIZE 090, 007 OF oDlgProgramacao COLORS 0, 16777215 PIXEL

	xTelaSC2()
	xfUpdGetSC2()

	ACTIVATE MSDIALOG oDlgProgramacao CENTERED

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 02/10/2026
Consultoria: FixSystem
Uso: Metalex
Info: Visualiza OP's encerradas
*==================================================================*/
Static Function xAtuPainel()

	xfUpdGetSC2()

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 17/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: Seleção de Produtos
*==================================================================*/
Static Function xSelectProd()

	Local cPerg := Padr("MLEMB2",10)

	//Incluir as perguntas na tabela SX1
	AjustaSX1(cPerg)

	If Pergunte(cPerg,.T.)
		xFilProd()
	Endif 

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 17/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: Seleção de Produtos
*==================================================================*/
Static Function xFilProd()

	Local oButton      := Nil
	Local aTamanho     := MsAdvSize()
	Local nJanLarg     := aTamanho[5]
	Local nJanAltu     := aTamanho[6]
	Private oDlg       := Nil
	
	DEFINE MSDIALOG oDlg TITLE "Produto" FROM 000,000 TO nJanAltu, nJanLarg COLORS 0,16777215 PIXEL

	@005,005 BUTTON oButton PROMPT "&Seleciona Produto" SIZE 070,012 OF oDlg PIXEL Action(xEscProd(),oDlg:End())

	xTelaProd()
	xfUpdGetProd()

	ACTIVATE MSDIALOG oDlg CENTERED
	
Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 17/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: Seleção de Produtos
*==================================================================*/
Static Function xTelaProd()

	Local nX           := 0      
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFieldFill   := {}
	Local aFields      := {"C2_OK","B1_COD","B1_DESC","B1_XGRLIGA","B1_XVARIAN","B1_XBITOLA","B1_XCOMPRI","B1_TIPO"}
	Local aAlterFields := {}
	Local aTamanho     := MsAdvSize()
	Local nJanLarg     := aTamanho[5]
	Local nJanAltu     := aTamanho[6]

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))

	For nX := 1 to Len(aFields)
	
		If SX3->(DbSeek(aFields[nX]))
			aAdd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
			SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
		Endif
		
	Next nX

	For nX := 1 to Len(aFields)

		If DbSeek(aFields[nX])
			aAdd(aFieldFill, CriaVar(SX3->X3_CAMPO))
		Endif

	Next nX

	aAdd(aFieldFill,.F.)
	aAdd(aColsEx,aFieldFill)

	oGetProduto         := MsNewGetDados():New( 040, 005, nJanAltu/2-25, nJanLarg/2-25, /*GD_INSERT+GD_DELETE+*/GD_UPDATE, "AllwaysTrue", "AllwaysTrue", "+Field1+Field2", aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlg, aHeaderEx, aColsEx)
	oGetProduto:BChange := {||changeGet(oGetProduto)}
	oGetProduto:oBrowse:lUseDefaultColors := .F.
	oGetProduto:oBrowse:SetBlkBackColor({|| fCorLinha(oGetProduto)})

Return

/*=================================================================
Autor: 
Data: 24/02/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function changeGet(oGet)

	Local nX := 0

	//Grid vazia - nada para marcar (evita "array out of bounds" no GdFieldPut)
	If Len(oGet:aCols) == 0
		Return
	Endif

	For nX := 1 To Len(oGet:aCols)
		GdFieldPut("C2_OK","",nX,oGet:aHeader,oGet:aCols)
	Next nX

	If oGet:nAt >= 1 .And. oGet:nAt <= Len(oGet:aCols)
		GdFieldPut("C2_OK","==>",oGet:nAt,oGet:aHeader,oGet:aCols)
	Endif

	oGet:Refresh()

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 17/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: Seleção de Produtos
*==================================================================*/
Static Function xfUpdGetProd()

	Local cQuery    := ""
	Local cTemp     := GetNextAlias()
	Local aStru     := {}
	Local aProdutos := {}
	Local nX        := 0
	Local cCpo      := ""

	cQuery := " SELECT '' AS C2_OK,SG1.G1_COMP AS B1_COD,SB1COMP.B1_DESC AS B1_DESC,SB1COMP.B1_TIPO AS B1_TIPO,"
	cQuery += " SB1.B1_COD AS PRODUTO2,SB1.B1_DESC AS DESC2,SB1.B1_TIPO AS TIPO2,"
	cQuery += " SB1.B1_XCOMPRI AS B1_XCOMPRI , SB1.B1_XGRLIGA AS B1_XGRLIGA, SB1.B1_XVARIAN AS B1_XVARIAN,SB1.B1_XBITOLA AS B1_XBITOLA"
	cQuery += " FROM " + RetSQLName("SB1") + " SB1" 
	cQuery += "	INNER JOIN " + RetSQLName("SG1") + " SG1"
	cQuery += " 	ON SG1.G1_COD = SB1.B1_COD"
	cQuery += "		AND SG1.D_E_L_E_T_ <> '*'"
	cQuery += "	INNER JOIN " + RetSQLName("SB1") + " SB1COMP"
	cQuery += "     ON SB1COMP.B1_COD = SG1.G1_COMP"
	cQuery += "     AND SB1COMP.D_E_L_E_T_ <> '*'"
	cQuery += "	INNER JOIN " + RetSQLName("SG1") + " SG16200"
	cQuery += "		ON SG16200.G1_COD = SG1.G1_COMP"
	cQuery += "		AND SG16200.D_E_L_E_T_ <> '*'"
	cQuery += "	INNER JOIN " + RetSQLName("SB1") + " SB1COMP2"
	cQuery += "		ON SB1COMP2.B1_COD = SG16200.G1_COMP" 
	cQuery += "		AND SB1COMP2.D_E_L_E_T_ <> '*'"
	cQuery += " WHERE SB1.D_E_L_E_T_ <> '*'" 
	cQuery += "		AND SB1.B1_COD LIKE '6%'" 
	cQuery += "		AND SB1.B1_XCOMPRI = 3100" 

	If !Empty(mv_par01)
		cQuery += " AND SB1.B1_XGRLIGA LIKE '%"+AllTrim(mv_par01)+"%'"
	Endif 

	If !Empty(mv_par02)
		cQuery += " AND SB1.B1_XVARIAN LIKE '%"+AllTrim(mv_par02)+"%'"
	Endif 

	If !Empty(mv_par03)
		cQuery += " AND SB1.B1_XBITOLA LIKE '%"+AllTrim(mv_par03)+"%'"
	Endif 

	cQuery += " ORDER BY SB1.B1_COD" 
	
	//Proteção para verificar se há dados na tabela temporária
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
    	cTemp := GetNextAlias()	
	Endif 
	
	//Conversão da query para a sintaxe do banco de dados do cliente
	cQuery := ChangeQuery(cQuery)

	//Execuçção da query no banco de dados
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.F.,.T.)
	
	DbSelectArea(cTemp)
	(cTemp)->(DbGoTop())
	
	aStru := oGetProduto:aHeader

	aProdPai := {}
	
	If !(cTemp)->(Eof())
	
		oGetProduto:aCols := {}
		
		While !(cTemp)->(Eof())
		
			aProdutos := {}
		
			For nX := 1 To Len(aStru)
			
				cCpo := aStru[nX,2]
				
				aAdd(aProdutos,(cTemp)->&(cCpo))
				
			Next nX
			
			aAdd(aProdutos,.F.)
			aAdd(oGetProduto:aCols,aProdutos)

			//Guarda produto/descrição "pai" (SB1) fora da grid, por posição de linha
			aAdd(aProdPai,{(cTemp)->PRODUTO2,(cTemp)->DESC2})
			
			(cTemp)->(DbSkip())
			
		EndDo
		
	Else
		
		oGetProduto:aCols := {}
		
		For nX := 1 To Len(aStru)
		
			cCpo := aStru[nX,2]

			aAdd(aProdutos,CriaVar(cCpo))
			
		Next
		
		aAdd(aProdutos,.F.)
		aAdd(oGetProduto:aCols,aProdutos)

		aAdd(aProdPai,{"",""})
		
	EndIf
	
	(cTemp)->(DbCloseArea())
	
	oGetProduto:Refresh()
	
	changeGet(@oGetProduto)

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 17/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function xTelaSC2()

	Local nX           := 0
	Local aHeaderEx    := {}
	Local aColsEx      := {}
	Local aFieldFill   := {}
	Local aFields      := {"C2_OK","C2_OP","C2_PRODUTO","B1_DESC","C2_QUANT","C2_QTSEGUM","B2_QATU","C2_RECURSO","C2_EMISSAO","C2_DATPRI"}
	Local aAlterFields := {}

	DbSelectArea("SX3")
	SX3->(DbSetOrder(2))

	For nX := 1 to Len(aFields)

		If SX3->(DbSeek(aFields[nX]))

			If aFields[nX] == "C2_QUANT"
				aAdd(aHeaderEx, {"Qtd. Kg",aFields[nX],"@E 999,999",12,2,"","","N","","","",""})
			Elseif aFields[nX] == "C2_QTSEGUM"
				aAdd(aHeaderEx, {"Qtd. Amarrado",aFields[nX],"@E 999,999",12,2,"","","N","","","",""})
			ElseIf aFields[nX] == "B2_QATU"
				aAdd(aHeaderEx, {"Saldo Amarrado",aFields[nX],"@E 999,999",12,2,"","","N","","","",""})
			Else 
				aAdd(aHeaderEx, {AllTrim(X3Titulo()),SX3->X3_CAMPO,SX3->X3_PICTURE,SX3->X3_TAMANHO,SX3->X3_DECIMAL,SX3->X3_VALID,;
				SX3->X3_USADO,SX3->X3_TIPO,SX3->X3_F3,SX3->X3_CONTEXT,SX3->X3_CBOX,SX3->X3_RELACAO})
			Endif 

		Endif

	Next nX

	For nX := 1 to Len(aFields)
		aAdd(aFieldFill, CriaVar(aFields[nX]))
	Next nX

	aAdd(aFieldFill,.F.)
	aAdd(aColsEx,aFieldFill)

	oGetSC2 := MsNewGetDados():New( 205, 005, nJanAltu - 010, nJanLarg - 010, 0, "AllwaysTrue", "AllwaysTrue", , aAlterFields,, 999, "AllwaysTrue", "", "AllwaysTrue", oDlgProgramacao, aHeaderEx, aColsEx)
	oGetSC2:BChange := {||changeGet(oGetSC2)}

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 17/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: Seleção de Produtos
*==================================================================*/
Static Function xfUpdGetSC2()

	Local cQuery    := ""
	Local cTemp     := GetNextAlias()
	Local aStru     := {}
	Local aLinha    := {}
	Local nX        := 0
	Local cCpo      := ""
	Local cValor    := ""

	cQuery := " SELECT '' AS C2_OK,SC2.C2_NUM+SC2.C2_ITEM+SC2.C2_SEQUEN AS C2_OP,SC2.C2_PRODUTO,B1_DESC,"
	cQuery += " SC2.C2_QUANT,SC2.C2_QTSEGUM,SC2.C2_QUJE,SC2.C2_RECURSO,SC2.C2_EMISSAO,SC2.C2_DATPRI,(C2_QTSEGUM - ISNULL(QTD_PROD2,0)) AS B2_QATU"
	cQuery += " FROM " + RetSQLName("SC2") + " SC2"
	cQuery += " INNER JOIN " +RetSQLName("SB1")+ " SB1"
	cQuery += " ON SB1.B1_COD = SC2.C2_PRODUTO"
	cQuery += " AND SB1.D_E_L_E_T_ = ' '"
	cQuery += "	LEFT JOIN (SELECT H6_OP,SUM(H6_QTDPRO2) QTD_PROD2 FROM "+RetSQLName("SH6")+" SH6 WHERE SH6.D_E_L_E_T_='' AND H6_FILIAL='"+xFilial("SH6")+"' GROUP BY H6_OP) SH6 ON SH6.H6_OP = C2_NUM+C2_ITEM+C2_SEQUEN"
	cQuery += " WHERE SC2.D_E_L_E_T_ = ' '"
	cQuery += "   AND SC2.C2_FILIAL = '" + xFilial("SC2") + "'"
	cQuery += "   AND SC2.C2_RECURSO = 'EMB'"
	cQuery += "	  AND SC2.C2_OBS = '>> PROGRAMADA <<'"

	If cVisEncer == "Não"
		cQuery += "   AND SC2.C2_QUJE < SC2.C2_QUANT"
	Endif 

	If !Empty(dDtFilIni) .And. !Empty(dDtFilFim)
		cQuery += "   AND SC2.C2_EMISSAO BETWEEN '" + DTOS(dDtFilIni) + "' AND '" + DTOS(dDtFilFim) + "'"
	Endif

	cQuery += " ORDER BY SC2.C2_NUM"

	//Proteção para verificar se há dados na tabela temporária
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

	aStru := oGetSC2:aHeader

	oGetSC2:aCols := {}

	While !(cTemp)->(Eof())

		aLinha := {}

		For nX := 1 To Len(aStru)

			cCpo := aStru[nX,2]

			cValor := (cTemp)->&(cCpo)

			//Datas do Protheus ficam gravadas como texto (AAAAMMDD) no banco físico;
			//sem converter pra Data de verdade, a grid não consegue aplicar a máscara.
			If aStru[nX,8] == "D" .And. ValType(cValor) == "C"
				cValor := SToD(cValor)
			Endif

			aAdd(aLinha,cValor)
		
		Next nX

		aAdd(aLinha,.F.)
		aAdd(oGetSC2:aCols,aLinha)

		(cTemp)->(DbSkip())

	EndDo

	(cTemp)->(DbCloseArea())

	oGetSC2:Refresh()

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 17/09/2026
Consultoria: FixSystem
Uso: Metalex
Info: Captura o produto e monta o campo único Comprim.|Liga|Variante|Bitola
      a partir dos dados já carregados na grid de seleção de produtos
*==================================================================*/
Static Function xEscProd()

	nCompri  := GdFieldGet("B1_XCOMPRI",oGetProduto:nAt,,oGetProduto:aHeader,oGetProduto:aCols)
	nLiga    := GdFieldGet("B1_XGRLIGA",oGetProduto:nAt,,oGetProduto:aHeader,oGetProduto:aCols)
	nVariant := GdFieldGet("B1_XVARIAN",oGetProduto:nAt,,oGetProduto:aHeader,oGetProduto:aCols)
	nBitola  := GdFieldGet("B1_XBITOLA",oGetProduto:nAt,,oGetProduto:aHeader,oGetProduto:aCols)

	cProduto   := GdFieldGet("B1_COD" ,oGetProduto:nAt,,oGetProduto:aHeader,oGetProduto:aCols)
	cDescricao := GdFieldGet("B1_DESC",oGetProduto:nAt,,oGetProduto:aHeader,oGetProduto:aCols)

	//Produto/Descrição 2 (SB1), usados depois para gerar a OPS
	cProduto2   := aProdPai[oGetProduto:nAt][1]
	cDescricao2 := aProdPai[oGetProduto:nAt][2]

	cCompLigaVarBit := AllTrim(Transform(nCompri,"@E 9,999")) + " | " + AllTrim(cValToChar(nLiga)) + " | " + AllTrim(cValToChar(nVariant)) + " | " + AllTrim(cValToChar(nBitola))

	oProduto:Refresh()
	oDescricao:Refresh()
	oCompLigaVarBit:Refresh()

Return

/*=================================================================
Autor: Vinicius Nascimento de Oliveira
Data: 16/09/2026
Consultoria: Fixsystem
Uso: Metalex
Info: 
*==================================================================*/
Static Function xGerarOP()

	Local aAuto      := {}
	Local cProdEmb   := cProduto2
	Local cProdSerra := cProduto
	Local nPesoCalc  := xCalcQuant(nQtAmarrado)
	Local nQtdeCalc  := nPesoCalc * nQtAmarrado //nQtAmarrado * xCalcQuant()

	Private lMsErroAuto    := .F.
	Private lAutoErrNoFile := .T. 

	//Validações mínimas antes de acionar o Mata650 - sem isso o Mata650 rejeita
	//silenciosamente (ou com log vazio) quando falta produto/quantidade.
	If Empty(cProduto)
		FWAlertInfo("Selecione um produto antes de gerar a OP.","Gerar OP")
		Return
	Endif

	If Empty(cProdEmb) .Or. Empty(cProdSerra)
		FWAlertInfo("Não foi possível identificar o produto principal (Produto2). Selecione o produto novamente.","Gerar OP")
		Return
	Endif

	If nQtAmarrado <= 0
		FWAlertInfo("Informe a Qt Amarrado (maior que zero) antes de gerar a OP.","Gerar OP")
		Return
	Endif

	If nQtdeCalc <= 0
		FWAlertInfo("Não foi possível calcular a quantidade (verifique a Bitola do produto). ","Gerar OP")
		Return
	Endif

	aAdd(aAuto, {"C2_FILIAL" , xFilial("SC2") , Nil})
	aAdd(aAuto, {"C2_PRODUTO", cProdEmb       , Nil})
	aAdd(aAuto, {"C2_QUANT"  , nQtdeCalc      , Nil})
	aAdd(aAuto, {"C2_QTSEGUM", nQtAmarrado    , Nil})
	aAdd(aAuto, {"C2_LOCAL"  , "29"           , Nil})
	aAdd(aAuto, {"C2_DATPRI" , dDtProgramada  , Nil}) 
	aAdd(aAuto, {"C2_BATCH"  , "S"            , Nil})
	aAdd(aAuto, {"C2_DATPRF" , dDtProgramada  , Nil})
	aAdd(aAuto, {"C2_RECURSO", "EMB"          , Nil})
	aAdd(aAuto, {'C2_OBS'    , cObservacao    , Nil})
	aAdd(aAuto, {'AUTEXPLODE', "N"         	  , Nil})

	Begin Transaction 

		MsExecAuto({|x,y| Mata650(x,y)},aAuto,3)

		If lMsErroAuto
			
			MostraErro()

			DisarmTransaction()
		
		Else
		
			FWAlertSuccess("Ordem de Produção "+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+" gerada com sucesso!", "Sucesso")

			cCompLigaVarBit := ""
			cProduto        := ""
			cDescricao      := ""
			nQtAmarrado     := 0
			dDtProgramada   := Date()
			
			oCompLigaVarBit:Refresh()
			oProduto:Refresh()
			oDescricao:Refresh()
			oQtProg:Refresh()
			oDtInicio:Refresh()			

			xfUpdGetSC2()

		Endif

	End Transaction

Return

/*=================================================================
Autor: Vinicius Nascimento de Oliveira
Data: 03/09/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Exclusão de OP
*==================================================================*/
Static Function excluirOP()

	Local cNumOP  := ""

	Private lMsHelpAuto := .T. // Se .T., exibe mensagens de help
	Private lMsErroAuto := .F. // Se .F., não exibe erros automáticos

	//Sem OP na grid (ou nenhuma linha selecionada) - nada a fazer
	If Len(oGetSC2:aCols) == 0 .Or. oGetSC2:nAt <= 0
		FWAlertInfo("Selecione uma OP na grid antes de excluir.","Excluir OP")
		Return
	Endif

	cNumOP := GdFieldGet("C2_OP",oGetSC2:nAt,,oGetSC2:aHeader,oGetSC2:aCols)

	If Empty(cNumOP)
		FWAlertInfo("Selecione uma OP na grid antes de excluir.","Excluir OP")
		Return
	Endif

	If MsgYesNo("Deseja realmente encerra a OP "+cNumOP)

		DbSelectArea("SC2")
		DbSetOrder(1)

		If DbSeek(xFilial("SC2")+cNumOP)

			If !Empty(SC2->C2_DATRF)

				FwalertInfo("Essa OP já está encerrada!!!","Encerramento de OP")
				xfUpdGetSC2()
				Return

			EndIf

			If SC2->C2_QUJE > 0

				If FWAlertYesNo("Confirma encerramento da ordem?","Encerramento de ordem")
					Reclock("SC2",.F.)
					SC2->C2_DATRF := Date()
					MsUnlock()
					FwAlertSuccess("OP Encerrada com sucesso")
					xfUpdGetSC2()
				Endif

			Endif

			If !Empty(SC2->C2_XFUSAO)
				FwAlertInfo("Ordem de producao excluida com sucesso!!!","Exclusao de OP")
				Return
			Endif

			If !FWAlertYesNo("Confirma exclusao da OP "+SC2->C2_NUM+SC2->C2_ITEM+SC2->C2_SEQUEN+"?","Exclusao de OP")
				Return
			Endif

			aMATA650 := {}

			aAdd(aMATA650,{'C2_FILIAL' ,xFilial("SC2") , Nil})
			aAdd(aMATA650,{'C2_NUM'    ,SC2->C2_NUM    , Nil})
			aAdd(aMATA650,{'C2_ITEM'   ,SC2->C2_ITEM   , Nil})
			aAdd(aMATA650,{'C2_SEQUEN' ,SC2->C2_SEQUEN , Nil})

			Begin Transaction 

				MsExecAuto({|x,Y| Mata650(x,Y)},aMata650,5)

				If lMsErroAuto

					_cErro := MostraErro("\dirdoc\","error_mata650.log")

					Showlog(_cErro)

					_lRet := .F.

					DisarmTransaction()

					Return

				Else
						
					FwAlertInfo("Ordem de produção excluída com sucesso!!!","Exclusão de OP")
						
					xfUpdGetSC2()

				Endif 

			End Transaction

		Endif 

	Endif 

Return

/*=================================================================
Autor: Vinicius Nascimento de Oliveira
Data: 23/09/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Encerrar OP
*==================================================================*/
Static Function encerrarOP()

	Local cNumOP := ""

	Private lMsHelpAuto := .T. // Se .T., exibe mensagens de help
	Private lMsErroAuto := .F. // Se .F., não exibe erros automáticos

	cNumOP := GdFieldGet("C2_OP",oGetSC2:nAt,,oGetSC2:aHeader,oGetSC2:aCols)

	DbSelectArea("SC2")
	SC2->(DbSetOrder(1))

	If SC2->(DbSeek(xFilial("SC2")+cNumOP))

		If !Empty(SC2->C2_DATRF)

			FwalertInfo("Essa OP ja está encerrada!!!","Encerramento de OP")
			xfUpdGetSC2()

			Return

		Endif

		If SC2->C2_QUJE > 0

			If FWAlertYesNo("Confirma encerramento da ordem "+cNumOP+"?","Encerramento de ordem")
				
				Reclock("SC2",.F.)
				SC2->C2_DATRF := Date()
				SC2->(MsUnlock())

				FwAlertSuccess("OP Encerrada com sucesso")

				xfUpdGetSC2()

			Endif

		Else

			FwalertInfo("Ordem nao iniciada nao pode ser encerrada!!","Encerramento de ordem")

			Return

		Endif

	Endif

Return

/*=================================================================
Autor: Vinicius Nascimento de Oliveira
Data: 09/09/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Calcula o Peso
*==================================================================*/
Static Function xCalcQuant(nQtAmarrado)

	/*Local nDiametro  := nBitola * 25.4 //Inserir informação - Bitola (multiplicar por 25.4 milimetros - mm)
	Local nDensidade := 0.0000027
	Local nArea      := (3.141592653589793 * (nDiametro ^ 2)) / 4 
	Local nPeso      := Round(((nArea * nCompri) * nDensidade),2)*/
	Local aFator     := {}
	Local nPeso      := 0
	Local nQtdPecas  := xCalcPecas()

	aAdd(aFator,0)//1
	aAdd(aFator,0)//2
	aAdd(aFator,0)//3
	aAdd(aFator,0.02181)//4
	aAdd(aFator,0.03408)//5
	aAdd(aFator,0.04907)//6
	aAdd(aFator,0.06679)//7

	nPeso := Round(nQtdPecas * nCompri * aFator[nBitola],2)

Return(nPeso)

/*=================================================================
Autor: Vinicius Nascimento de Oliveira
Data: 09/09/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Calcula o Peso do Amarrado em Kg
*==================================================================*/
Static Function xCalcPecas()

	Local nQtdPecas := 0

	If nBitola == 4 //Bitola 4 polegadas =  17 peças
		nQtdPecas := 17
	Elseif nBitola == 5 //Bitola 5 polegadas =  14 peças
		nQtdPecas :=  14 
	Endif 

Return(nQtdPecas) 

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
Data: 02/10/2026
Consultoria: FixSystem
Uso: Metalex
Info: Atalho para tela embalagem
*==================================================================*/
Static Function xTelaEmb()

	oDlgProgramacao:end()

	U_telaEmbalagem()

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data:02/10/2026
Consultoria: FixSystem
Uso: Metalex
Info: Perguntas da SX1
*==================================================================*/
Static Function AjustaSX1(cPerg)

	Local aRegs := {}
	Local nI    := 0
	Local nJ    := 0
	
	aAdd(aRegs,{cPerg,"01","Liga:"    ,"","","mv_ch1","C",15,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"02","Variant:" ,"","","mv_ch2","C",15,00,0,"G","","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"03","Bitola:"  ,"","","mv_ch3","C",15,00,0,"G","","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","",""})

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
