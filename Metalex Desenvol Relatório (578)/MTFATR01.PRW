#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'TOTVS.ch'

/***********************************************************************
Autor: Vinciius .N de Oliveira
Data: 13/04/2026
Consultoria: FixSystem
Uso: Metalex
Tipo: Atualizações
Rotina: Espoecifica
Função: MTFATR01
Info: Relatório de Estoque
************************************************************************/
User Function MTFATR01()

	Local cPath      := GetMV("XX_XARQUI",.F.,"C:\temp\")
    Local cData      := StrTran(DToS(Date()),"/","")
    Local cHora      := StrTran(Time(),":","")
    Local cDtHora    := AllTrim(cData+"_"+cHora)
    Local cNomeArq   := "Saldo_de_Produto_"+cDtHora+".xml"
	Local cArquivo   := cPath + cNomeArq
	Local cPerg		 := Padr("MTFATR01",10)
	
	If !ExistDir(cPath)
        MakeDir(cPath)
    EndIf

	ValidPerg(cPerg)
	
	If Pergunte(cPerg,.T.)
		Processa({|| MTFATR01(cArquivo),"Processando... Favor Aguardar."})
	Endif

Return 

/*=================================================================
Autor: Vinciius .N de Oliveira
Data: 13/04/2026
Consultoria: FixSystem
Uso: Metalflex
Info: Query
*==================================================================*/
Static Function MTFATR01(cArquivo)

	Local oExcel    := FWMSExcel():New()
	Local cQuery    := ""
	Local cAlias    := ""
	Local cDataIni  := DToS(MV_PAR01 - Day(MV_PAR01))
	Local cDataFim  := DToS(LastDate(MV_PAR01))
	Local cPeriodo  := AnoMes(MV_PAR01)
	Local aLinha    := {}

	cQuery += " SELECT"
	cQuery += " B2_FILIAL FILIAL,"
	cQuery += " B2_LOCAL ARMAZEM,"
	cQuery += " B1_TIPO TIPO,"
	cQuery += " B1_COD PRODUTO,"
	cQuery += " B1_CONTA ID_CONTA,"
	cQuery += " CT1_DESC01 CONTA,"
	cQuery += " ISNULL(SALDO_INICIAL, 0) SALDO_INICIAL,"
	cQuery += " B9_QINI VOL_INI,"
	cQuery += " ISNULL(MOVIMENTO, 0) MOVIMENTO,"
	cQuery += " QUANTIDADE VOL_MOV,"
	cQuery += " ISNULL(SALDO_FINAL, 0) SALDO_FINAL,"
	cQuery += " B2_QATU VOL_FIM"
	cQuery += " FROM "+RetSQLName("SB1")+" SB1"
	cQuery += " INNER JOIN "+RetSQLName("SB2")+" SB2"
	cQuery += " 	ON SB2.D_E_L_E_T_ <> '*'"
	cQuery += " 	AND B2_COD = B1_COD"
	cQuery += " LEFT JOIN CT1010 CT1"
	cQuery += " 	ON CT1.D_E_L_E_T_ <> '*'"
	cQuery += " 	AND CT1_CONTA = B1_CONTA"
	cQuery += " LEFT JOIN"
	cQuery += "   (SELECT B9_FILIAL FILIAL,"
	cQuery += "   B9_LOCAL LOCAL,"
	cQuery += "   B1_COD PRODUTO,"
	cQuery += "   B1_TIPO TIPO,"
	cQuery += "   SUM(B9_VINI1) SALDO_INICIAL,"
	cQuery += "   B9_QINI"
	cQuery += " FROM "+RetSQLName("SB9")+" SB9"
	cQuery += "    INNER JOIN "+RetSQLName("SB1")+" SB1" 
	cQuery += "			ON SB1.D_E_L_E_T_ <> '*'"
	cQuery += "    		AND B1_COD = B9_COD"
	cQuery += "    WHERE SB9.D_E_L_E_T_ <> '*'"
	cQuery += "      	AND B9_DATA = '"+cDataIni+"'"
	cQuery += "    GROUP BY B9_FILIAL,"
	cQuery += "     B9_LOCAL,"
	cQuery += "     B1_COD,"
	cQuery += "     B1_TIPO,"
	cQuery += "     B9_QINI) INICIAL"
	cQuery += " 	ON INICIAL.TIPO = B1_TIPO"
	cQuery += " 	AND B1_COD = PRODUTO"
	cQuery += " 	AND INICIAL.FILIAL = B2_FILIAL"
	cQuery += " 	AND INICIAL.LOCAL = B2_LOCAL"
	cQuery += " LEFT JOIN"
	cQuery += "   (SELECT B9_FILIAL FILIAL,"
	cQuery += "    B9_LOCAL LOCAL,"
	cQuery += "    B1_COD PRODUTO,"
	cQuery += "    B1_TIPO TIPO,"
	cQuery += "    SUM(B9_VINI1) SALDO_FINAL"
	cQuery += "    FROM "+RetSQLName("SB9")+" SB9"
	cQuery += "    INNER JOIN "+RetSQLName("SB1")+" SB1"
	cQuery += "			ON SB1.D_E_L_E_T_ <> '*'"
	cQuery += "    		AND B1_COD = B9_COD"
	cQuery += "    WHERE SB9.D_E_L_E_T_ <> '*'"
	cQuery += "      AND B9_DATA = '"+cDataFim+"'"
	cQuery += "    GROUP BY B9_FILIAL,"
	cQuery += "     B9_LOCAL,"
	cQuery += "     B1_COD,"
	cQuery += "     B1_TIPO) FINAL"
	cQuery += "		ON FINAL.TIPO = B1_TIPO"
	cQuery += " 	AND B1_COD = FINAL.PRODUTO"
	cQuery += " 	AND FINAL.FILIAL = B2_FILIAL"
	cQuery += " 	AND FINAL.LOCAL = B2_LOCAL"
	cQuery += " LEFT JOIN"
	cQuery += "   (SELECT FILIAL,"
	cQuery += "    	LOCAL,"
	cQuery += "    	PRODUTO,"
	cQuery += "    	SUM(CUSTO) MOVIMENTO,"
	cQuery += "     QUANTIDADE"
	cQuery += "    FROM V_MOVIMENTOS "
	cQuery += "    WHERE DT_EMISSAO LIKE '"+cPeriodo+"%'"
	cQuery += "      AND ESTOQUE = 'S'"
	cQuery += "    GROUP BY FILIAL,"
	cQuery += "     LOCAL,"
	cQuery += "     PRODUTO,"
	cQuery += "     QUANTIDADE) MOVIMENTO"
	cQuery += "		ON MOVIMENTO.PRODUTO = B1_COD"
	cQuery += " 	AND B2_FILIAL = MOVIMENTO.FILIAL"
	cQuery += " 	AND B2_LOCAL = MOVIMENTO.LOCAL"
	cQuery += " WHERE SB1.D_E_L_E_T_ <> '*'"

	cAlias := MPSysOpenQuery(cQuery)

    oExcel:AddworkSheet("SB2")
    oExcel:AddTable("SB2", "Saldos Físico")

	oExcel:AddColumn("SB2", "Saldos Físico", "Filial",       	2, 1) 
	oExcel:AddColumn("SB2", "Saldos Físico", "Local",      		2, 1) 
	oExcel:AddColumn("SB2", "Saldos Físico", "Tipo",       		2, 1) 
	oExcel:AddColumn("SB2", "Saldos Físico", "Produto",    		2, 1) 
	oExcel:AddColumn("SB2", "Saldos Físico", "Conta",	  		2, 1) 
	oExcel:AddColumn("SB2", "Saldos Físico", "Desc. Conta", 	2, 1) 
	oExcel:AddColumn("SB2", "Saldos Físico", "Saldo Inicial", 	2, 2) 
	oExcel:AddColumn("SB2", "Saldos Físico", "Volume Inicial", 	2, 2) 
	oExcel:AddColumn("SB2", "Saldos Físico", "Movimento", 		2, 2) 
	oExcel:AddColumn("SB2", "Saldos Físico", "Volume Movimento",2, 2) 
	oExcel:AddColumn("SB2", "Saldos Físico", "Saldo Final", 	2, 2) 
	oExcel:AddColumn("SB2", "Saldos Físico", "Volume Final", 	2, 2) 

	While !(cAlias)->(Eof())

        aLinha := {}
        
        aAdd(aLinha,(cAlias)->FILIAL)              // Filial
        aAdd(aLinha,(cAlias)->ARMAZEM)             // Local
        aAdd(aLinha,(cAlias)->TIPO)                // Tipo
        aAdd(aLinha,(cAlias)->PRODUTO)             // Codigo de Produto
		aAdd(aLinha,(cAlias)->ID_CONTA)            // Id conta
        aAdd(aLinha,(cAlias)->CONTA)               // Descr conta
        aAdd(aLinha,(cAlias)->SALDO_INICIAL)       // Saldo Inicial
		aAdd(aLinha,(cAlias)->VOL_INI)             // Volume Inicial
        aAdd(aLinha,(cAlias)->MOVIMENTO)           // Movimento
		aAdd(aLinha,(cAlias)->VOL_MOV)             // Volume Movimento
		aAdd(aLinha,(cAlias)->SALDO_FINAL)         // Saldo Final
		aAdd(aLinha,(cAlias)->VOL_FIM)             // Volume Final

        oExcel:AddRow("SB2", "Saldos Físico", aLinha)
			
        (cAlias)->(DbSkip())
		
    EndDo
	
	(cAlias)->(DbCloseArea())

    oExcel:Activate()
	oExcel:GetXMLFile(cArquivo)
	oExcel:DeActivate()

	ShellExecute("Open",cArquivo,"","",5) //Abertura da pasta local onde consta o arquivo Excel

Return

/*=================================================================
Autor: Vinciius .N de Oliveira
Data: 13/04/2026
Consultoria: FixSystem
Uso: Metalflex
Info: Validação das perguntas da SX1
*==================================================================*/
Static Function ValidPerg(cPerg)

	Local aRegs := {}
	Local nI    := 0
	Local nJ    := 0
	
	aAdd(aRegs,{cPerg,"01","Data de referencia?"  ,"","","mv_ch1","D",06,00,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","SB2"})

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
