#Include "totvs.ch"
#Include "TBICONN.ch"
#Include "TOPCONN.ch"
#Define _crlf Chr(13)+Chr(10)
/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATR235  บAutor  ณLucas Fl๓ridi Leme  บ Data ณ  02/10/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ Rela็ใo de notas de venda e o valo de frete referente      บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ Protheus 11 Fortaleza                                     บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
User Function RFATRD06()
	//Cria o MsApp
	MsApp():New('SIGAFAT')
	oApp:CreateEnv()
	//Seta o tema do Protheus (SUNSET = Vermelho; OCEAN = Azul)
	PtSetTheme("SUNSET")
	//Define o programa de inicializa็ใo
	oApp:bMainInit:= {|| MsgRun("Configurando ambiente...","Aguarde...",;
		{|| RpcSetEnv("01","0201"), }),;
		U_RFATR006(),;
		Final("TERMINO NORMAL")}
	//Seta Atributos
	__lInternet := .T.
	lMsFinalAuto := .F.
	oApp:lMessageBar:= .T.
	oApp:cModDesc:= 'SIGAFAT'

	//Inicia a Janela
	oApp:Activate()
Return

User Function RFATR006

	cPerg := "RFATR006"
	
	If !U_CheckAgent()
		REturn
	EndIf
	ValidPerg()
	If Pergunte(cPerg,.T.)
		Processa({||Gera(),"Processando..."})
	EndIf

Return

Static Function Gera()
	Local _x

	cQry := "SELECT 'VENDA/RETORNO' ORIGEM, D2_FILIAL FILIAL "+_crlf
	cQry += ",D2_EMISSAO EMISSAO "+_crlf
	cQry += ",D2_DOC DOCUMENTO "+_crlf
	cQry += ",D2_SERIE SERIE "+_crlf
	cQry += ",D2_ITEM ITEM "+_crlf
	cQry += ",D2_CLIENTE CLIENTE "+_crlf
	cQry += ",D2_LOJA LOJA "+_crlf
	cQry += ",A1_NOME NOME "+_crlf
	cQry += ",A1_EST ESTADO "+_crlf
	cQry += ",D2_COD ID_PRODUTO "+_crlf
	cQry += ",B1_DESC PRODUTO "+_crlf
	cQry += ",D2_QUANT QUANTIDADE "+_crlf
	cQry += ",D2_PRCVEN PRECO "+_crlf
	cQry += ",D2_TOTAL VAL_MERCADORIA "+_crlf
	cQry += ",D2_VALIPI VALIPI "+_crlf
	cQry += ",D2_TOTAL+D2_VALIPI VALOR_BRUTO "+_crlf
	cQry += ",D2_VALICM VALICMS "+_crlf
	cQry += ",D2_PEDIDO PEDIDO "+_crlf
	cQry += ",D2_ITEMPV ITEMPV "+_crlf
	cQry += ",F4_CODIGO TES "+_crlf
	cQry += ",F4_DUPLIC DUPLICATA "+_crlf
	cQry += ",F4_ESTOQUE ESTOQUE "+_crlf
	cQry += ",D2_SERIORI SERIE_ORIGEM "+_crlf
	cQry += ",D2_NFORI NF_ORIGEM "+_crlf
	cQry += ",C6_OBSCONT OBS_RET "+_crlf
	cQry += ",CASE C6_XMODTAB "+_crlf
	cQry += "	WHEN '01' THEN 'VENDA' "+_crlf
	cQry += "	WHEN '02' THEN 'MO SUCATA' "+_crlf
	cQry += "	WHEN '03' THEN 'MO LIMPEZA' "+_crlf
	cQry += "	WHEN '04' THEN 'MO LINGOTE' "+_crlf
	cQry += "	WHEN '05' THEN 'MO LINGOTE' "+_crlf
	cQry += "	ELSE C6_XMODTAB END MODALIDADE "+_crlf
	cQry += ",C6_OPER OPERACAO "+_crlf
	cQry += ",C6_CF CF "+_crlf
	cQry += ",C6_XORDSEP NUM_OS "+_crlf
	cQry += ",C6_XLME LME "+_crlf
	cQry += ",C6_XDOLAR DOLAR "+_crlf
	cQry += ",C6_XTIPOPR TIPO_PRECO "+_crlf
	cQry += ",C6_XPREMI PREMIO "+_crlf
	cQry += ",B1_XGRLIGA LIGA "+_crlf
	cQry += ",B1_XVARIAN VARIANTE "+_crlf
	cQry += ",B1_XBITOLA BITOLA "+_crlf
	cQry += ",B1_XCOMPRI COMPRIMENTO "+_crlf
	
	//Adicionado por Vinicius N. de Oliveira - FixSystem - 10/02/2026 
	cQry += ",C6_XDESPFI DESPESA_FIN "+_crlf
	cQry += ",D2_PICM PERC_ICMS "+_crlf
	cQry += ",D2_ALQPIS PERC_PIS "+_crlf
	cQry += ",D2_ALQCOF PERC_COFINS "+_crlf
	cQry += ",CASE C6_XMODTAB "+_crlf
	cQry += "	WHEN '01' THEN C6_XPREMI * C6_XDOLAR "+_crlf
	cQry += "ELSE "+_crlf
	cQry += "	C6_XPREMI END VL_UNI_FIN "+_crlf
	cQry += ",D2_PRCVEN * D2_QUANT VL_TOT_FIN "+_crlf
	cQry += ",(C6_XPREMI * D2_QUANT)/100 VL_SEM_CUSTO_FIN "+_crlf
	// ---

	cQry += " "+_crlf
	cQry += "FROM SD2010 SD2 "+_crlf
	cQry += "  INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_='' AND B1_FILIAL=SUBSTRING(D2_FILIAL,1,2) AND B1_COD=D2_COD "+_crlf
	cQry += "  INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_='' AND F4_FILIAL=SUBSTRING(D2_FILIAL,1,2) AND F4_CODIGO=D2_TES "+_crlf
	IF mv_par05 == 1
		cQry += "  AND F4_DUPLIC='S' "+_crlf
	ENDIF
	cQry += "  INNER JOIN SA1010 SA1 ON SA1.D_E_L_E_T_='' AND A1_COD=D2_CLIENTE AND A1_LOJA=D2_LOJA "+_crlf
	cQry += "  INNER JOIN SC6010 SC6 ON SC6.D_E_L_E_T_='' AND C6_FILIAL=D2_FILIAL AND C6_NUM=D2_PEDIDO AND D2_ITEMPV=C6_ITEM "+_crlf
	cQry += "WHERE SD2.D_E_L_E_T_='' "+_crlf
	cQry += "AND D2_FILIAL BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "+_crlf
	cQry += "AND D2_EMISSAO BETWEEN '"+dtos(mv_par03)+"' AND '"+dtos(mv_par04)+"' "+_crlf
	cQry += "AND D2_TIPO='N'	 "+_crlf
	cQry += "UNION ALL "+_crlf
	cQry += "SELECT 'DEVOLUCAO DE VENDA' ORIGEM,D1_FILIAL FILIAL "+_crlf
	cQry += ",D1_DTDIGIT EMISSAO "+_crlf
	cQry += ",D1_DOC DOCUMENTO "+_crlf
	cQry += ",D1_SERIE SERIE "+_crlf
	cQry += ",D1_ITEM ITEM "+_crlf
	cQry += ",D1_FORNECE CLIENTE "+_crlf
	cQry += ",D1_LOJA LOJA "+_crlf
	cQry += ",A1_NOME NOME "+_crlf
	cQry += ",A1_EST ESTADO "+_crlf
	cQry += ",D1_COD ID_PRODUTO "+_crlf
	cQry += ",B1_DESC PRODUTO "+_crlf
	cQry += ",-D1_QUANT QUANTIDADE "+_crlf
	cQry += ",D1_VUNIT  PRECO "+_crlf
	cQry += ",-D1_TOTAL VAL_MERCADORIA "+_crlf
	cQry += ",-D1_VALIPI VALIPI "+_crlf
	cQry += ",-(D1_TOTAL+D1_VALIPI) VALOR_BRUTO "+_crlf
	cQry += ",-D1_VALICM VALICMS "+_crlf
	cQry += ",D1_PEDIDO PEDIDO "+_crlf
	cQry += ",D1_ITEMPV ITEMPV "+_crlf
	cQry += ",F4_CODIGO TES "+_crlf
	cQry += ",F4_DUPLIC DUPLICATA "+_crlf
	cQry += ",F4_ESTOQUE ESTOQUE "+_crlf
	cQry += ",D1_SERIORI SERIE_ORIGEM "+_crlf
	cQry += ",D1_NFORI NF_ORIGEM "+_crlf
	cQry += ",C6_OBSCONT OBS_RET "+_crlf
	cQry += ",CASE C6_XMODTAB "+_crlf
	cQry += "	WHEN '01' THEN 'VENDA' "+_crlf
	cQry += "	WHEN '02' THEN 'MO SUCATA' "+_crlf
	cQry += "	WHEN '03' THEN 'MO LIMPEZA' "+_crlf
	cQry += "	WHEN '04' THEN 'MO LINGOTE' "+_crlf
	cQry += "	WHEN '05' THEN 'MO LINGOTE' "+_crlf
	cQry += "	ELSE C6_XMODTAB END MODALIDADE "+_crlf
	cQry += ",C6_OPER OPERACAO "+_crlf
	cQry += ",C6_CF CF "+_crlf
	cQry += ",C6_XORDSEP NUM_OS "+_crlf
	cQry += ",C6_XLME LME "+_crlf
	cQry += ",C6_XDOLAR DOLAR "+_crlf
	cQry += ",C6_XTIPOPR TIPO_PRECO "+_crlf
	cQry += ",C6_XPREMI PREMIO "+_crlf
	cQry += ",B1_XGRLIGA LIGA "+_crlf
	cQry += ",B1_XVARIAN VARIANTE "+_crlf
	cQry += ",B1_XBITOLA BITOLA "+_crlf
	cQry += ",B1_XCOMPRI COMPRIMENTO "+_crlf
	
	//Adicionado por Vinicius N. de Oliveira - FixSystem - 10/02/2026 
	cQry += ",C6_XDESPFI DESPESA_FIN "+_crlf
	cQry += ",D1_PICM PERC_ICMS "+_crlf
	cQry += ",D1_ALQPIS PERC_PIS "+_crlf
	cQry += ",D1_ALQCOF PERC_COFINS "+_crlf
	cQry += ",CASE C6_XMODTAB  "+_crlf
	cQry += "	WHEN '01' THEN C6_XPREMI * C6_XDOLAR "+_crlf 
	cQry += "ELSE "+_crlf
	cQry += "	C6_XPREMI END VL_UNI_FIN "+_crlf
	cQry += ",D1_VUNIT * D1_QUANT VL_TOT_FIN "+_crlf
	cQry += ",(C6_XPREMI * D1_QUANT)/100  VL_SEM_CUSTO_FIN "+_crlf	
	//---
	
	cQry += " "+_crlf
	cQry += "FROM SD1010 SD1 "+_crlf
	cQry += "  INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_='' AND B1_FILIAL=SUBSTRING(D1_FILIAL,1,2) AND B1_COD=D1_COD "+_crlf
	cQry += "  INNER JOIN SF4010 SF4 ON SF4.D_E_L_E_T_='' AND F4_FILIAL=SUBSTRING(D1_FILIAL,1,2) AND F4_CODIGO=D1_TES "+_crlf
	IF mv_par05 == 1
		cQry += "  AND F4_DUPLIC='S' "+_crlf
	ENDIF
	cQry += "  INNER JOIN SA1010 SA1 ON SA1.D_E_L_E_T_='' AND A1_COD=D1_FORNECE AND A1_LOJA=D1_LOJA "+_crlf
	cQry += "  INNER JOIN SD2010 SD2 ON SD2.D_E_L_E_T_='' AND D2_CLIENTE=D1_FORNECE AND D2_LOJA=D1_LOJA AND D2_DOC=D1_NFORI AND D2_SERIE=D1_SERIORI AND D2_ITEM=D1_ITEMORI "+_crlf
	cQry += "  INNER JOIN SC6010 SC6 ON SC6.D_E_L_E_T_='' AND C6_FILIAL=D2_FILIAL AND C6_NUM=D2_PEDIDO AND D2_ITEMPV=C6_ITEM "+_crlf
	cQry += "WHERE SD1.D_E_L_E_T_='' "+_crlf
	cQry += "AND D1_FILIAL BETWEEN '"+mv_par01+"' AND '"+mv_par02+"' "+_crlf
	cQry += "AND D1_DTDIGIT BETWEEN '"+dtos(mv_par03)+"' AND '"+dtos(mv_par04)+"' "+_crlf
	cQry += "AND D1_TIPO='D'	 "+_crlf

	If __cUserID == "000000" //.and. funname("RPC")
		Showlog(cQry)
	EndIf
	TcQuery cQry New Alias "QRY1"
	TCSetField("QRY1","EMISSAO","D",/*nSize*/,/*nPrecision*/)

	DbSelectArea("QRY1")
	DbGotop()
	ProcRegua(QRY1->(RecCount()))
	If !QRY1->(Eof())
		_aStru := QRY1->(DbStruct())
		oExcel    := FWMSEXCEL():New()
		oExcel:AddworkSheet("DADOS")
		oExcel:AddTable ("DADOS","DADOS")
		For _x := 1 to Len(_aStru)
			If _aStru[_x,2] == "N"
				oExcel:AddColumn("DADOS","DADOS",_aStru[_x,1],3,2)
			ElseIf _aStru[_x,2] == "D"
				oExcel:AddColumn("DADOS","DADOS",_aStru[_x,1],1,4)
			ElseIf _aStru[_x,2] == "C"
				If "/" $ _aStru[_x,1]
					oExcel:AddColumn("DADOS","DADOS",_aStru[_x,1],1,4)
				Else
					oExcel:AddColumn("DADOS","DADOS",_aStru[_x,1],1,1)
				EndIf
			EndIf
		Next

		While !QRY1->(Eof())
			IncProc("Gerando Excel....")
			_aLinha := Array(Len(_aStru))
			For _x := 1 To Len(_aStru)
				_cCpo := Alltrim(_aStru[_x,1])
				_aLinha[_x] := QRY1->&(_cCpo)
			Next

			oExcel:AddRow("DADOS","DADOS",_aLinha)
			QRY1->(DbSkip())
		EndDo
		oExcel:Activate()
		_cFile := (CriaTrab(NIL, .F.) + ".xml")
		While File(_cFile)
			_cFile := (CriaTrab(NIL, .F.) + ".xml")
		EndDo
		oExcel:GetXMLFile(_cFile)
		oExcel:DeActivate()
		If !(File(_cFile))
			_cFile := ""
			QRY1->(DbCloseArea())
			Break
		EndIf
		_cFileTMP := (GetTempPath() + _cFile)
		If !(__CopyFile(_cFile , _cFileTMP))
			fErase( _cFile )
			_cFile := ""
			QRY1->(DbCloseArea())
			Break
		EndIf
		fErase(_cFile)
		_cFile := _cFileTMP
		If !(File(_cFile))
			_cFile := ""
			QRY1->(DbCloseArea())
			Break
		EndIf
		oMsExcel := MsExcel():New()
		oMsExcel:WorkBooks:Open(_cFile)
		oMsExcel:SetVisible(.T.)
		oMsExcel := oMsExcel:Destroy()

		FreeObj(oExcel)
		oExcel := NIL

	EndIf
	QRY1->(DbCloseArea())

Return

/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
ฑฑษออออออออออัออออออออออหอออออออัออออออออออออออออออออหออออออัอออออออออออออปฑฑ
ฑฑบPrograma  ณRFATR235  บAutor  ณMicrosiga           บ Data ณ  10/02/14   บฑฑ
ฑฑฬออออออออออุออออออออออสอออออออฯออออออออออออออออออออสออออออฯอออออออออออออนฑฑ
ฑฑบDesc.     ณ                                                            บฑฑ
ฑฑบ          ณ                                                            บฑฑ
ฑฑฬออออออออออุออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออนฑฑ
ฑฑบUso       ณ AP                                                        บฑฑ
ฑฑศออออออออออฯออออออออออออออออออออออออออออออออออออออออออออออออออออออออออออผฑฑ
ฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑฑ
฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿฿
*/
Static Function ValidPerg()
	Local i,j
	_sAlias := GetArea()
	dbSelectArea("SX1")
	dbSetOrder(1)
	cPerg   := PADR(cPerg,10)
	aRegs   := {}
	//Grupo/Ordem/Pergunta/Variavel/Tipo/Tamanho/Decimal/Presel/GSC/Valid/Var01/Def01/Cnt01/Var02/Def02/Cnt02/Var03/Def03/Cnt03/Var04/Def04/Cnt04/Var05/Def05/Cnt05
	aAdd(aRegs,{cPerg,"01","De Filial      ?","","","mv_ch1","C",04,0,0,"G","","mv_par01","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cPerg,"02","Ate Filial     ?","","","mv_ch2","C",04,0,0,"G","naovazio()","mv_par02","","","","","","","","","","","","","","","","","","","","","","","","","SM0","","",""})
	aAdd(aRegs,{cPerg,"03","Data Inicial   ?","","","mv_ch3","D",08,0,0,"G","naovazio()","mv_par03","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"04","Data Final     ?","","","mv_ch4","D",08,0,0,"G","naovazio()","mv_par04","","","","","","","","","","","","","","","","","","","","","","","","","","","",""})
	aAdd(aRegs,{cPerg,"05","Filtra por     ?","","","mv_ch5","C",01,0,0,"C","naovazio()","mv_par05","Faturamento","","","","","Todos","","","","","","","","","","","","","","","","","","","","","",""})

	For i:=1 to Len(aRegs)
		If !dbSeek(cPerg+aRegs[i,2])
			RecLock("SX1",.T.)
			For j:=1 to FCount()
				If j <= Len(aRegs[i])
					FieldPut(j,aRegs[i,j])
				Endif
			Next
			MsUnlock()
		Endif
	Next

	RestArea(_sAlias)

Return
