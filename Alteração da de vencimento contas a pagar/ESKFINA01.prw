#Include 'Protheus.ch'
#Include 'Parmtype.ch'
#Include 'FwMBrowse.ch'
#Include 'FwMVCDef.ch'
#Include 'FwBrowse.ch'

/***********************************************************************
Autor: Vinicius N. de Oliveira
Data: 11/10/2021
Consultoria: Prox
Uso: Eskala
Tipo: Atualizações
Rotina: Faturamento
Função: ESKFINA01
Info: Interface para alteração das datas de vencimento - Contas a Pagar
************************************************************************/
User Function ESKFINA01()

	Local aAreaXX    := GetArea()
	Local aSize2     := MsAdvSize(.F.)
	Local oColumn2   := Nil
	Local oPanel2    := Nil
	Local oButton2   := Nil
	Local oFornece   := Nil
	Local cTitulo2   := "Alteração em Lote da Data de Vencimento"
	
	Private cCodForn  := Space(8)
	Private cCodLoja  := Space(4)
	Private cCodFil   := Space(8)
	Private cFilAtual := cFilAnt
	Private dEmisDe   := SToD("  /  /    ")
	Private dEmisAte  := SToD("  /  /    ")
	Private dVencDe   := SToD("  /  /    ")
	Private dVencAte  := SToD("  /  /    ")
	Private oDlg2     := Nil
	Private oBrowse2  := Nil
	Private nValor    := 0
	Private nAlterado := 0 
	Private aTitulo   := {}

	DEFINE MSDIALOG oDlg2 TITLE cTitulo2 FROM aSize2[7],000 TO aSize2[6],aSize2[5] PIXEL
	
	oPanel := tPanel():New(00,00,,oDlg2,,,,,,100,45)

	//Campo de pesquisa de fornecedor - Campo livre para digitação
	oFornece := TGet():New(008,010,{|u| IIf( PCount() == 0, cCodForn, cCodForn := u ) },oDlg2,015,011,"",{|u| Vazio() .Or. ExistCpo("SA2",cCodForn) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCodForn",,,,,,,"Fornecedor",1)
	oFornece:cF3 := "SA2" 

	oFornece := TGet():New(008,055,{|u| IIf( PCount() == 0, cCodLoja, cCodLoja := u ) },oDlg2,002,011,"",{|u| Vazio() .Or. ExistCpo("SA2",cCodForn+cCodLoja) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCodLoja",,,,,,,"Loja",1)	

	oFornece := TGet():New(008,085,{|u| IIf( PCount() == 0, AllTrim(Posicione("SA2",1,xFilial("SA2")+@cCodForn+@cCodLoja,"A2_NOME")), AllTrim(Posicione("SA2",1,xFilial("SA2")+@cCodForn+@cCodLoja,"A2_NOME")) := u ) },oDlg2,150,011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.T.,.F.,,"AllTrim(Posicione('SA2',1,xFilial('SA2')+@cCodForn+@cCodLoja,'A2_NOME'))",,,,,,,"Razão",1)

	oFornece := TGet():New(008,240,{|u| IIf( PCount() == 0, dEmisDe, dEmisDe := u ) },oDlg2,040,011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"dEmisDe",,,,,,,"Emissão De ?",1)
	oFornece := TGet():New(008,285,{|u| IIf( PCount() == 0, dEmisAte, dEmisAte := u ) },oDlg2,040,011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"dEmisAte",,,,,,,"Emissão Até ?",1)

	oFornece := TGet():New(008,330,{|u| IIf( PCount() == 0, dVencDe, dVencDe := u ) },oDlg2,040,011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"dVencDe",,,,,,,"Vencimento De ?",1)
	oFornece := TGet():New(008,375,{|u| IIf( PCount() == 0, dVencAte, dVencAte := u ) },oDlg2,040,011,"",,0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"dVencAte",,,,,,,"Vencimento Até ?",1)

	oFornece := TGet():New(008,420,{|u| IIf( PCount() == 0, cCodFil, cCodFil := u ) },oDlg2,015,011,"",{|u| Vazio() .Or. ExistCpo("SM0",cEmpAnt+cCodFil) },0,,,.F.,,.T.,,.F.,,.F.,.F.,,.F.,.F.,,"cCodFil",,,,,,,"Filial",1)
	oFornece:cF3 := "SM0" 

	oFornece:SetCss("QLineEdit{" + ;
	"border-style: solid;" + ;
	"border-radius: 5px;" + ;
	"border-color: white;" + ;
	"font: 16px arial, sans-serif;" + ;
	"color: rgb(10, 80, 201);" + ;
	"background-repeat: no-repeat;" + ;
	"background-attachment: fixed;" + ;
	"QPushButton:hover {background-color: rgb(10, 188, 201); color: white;" + ;
	"padding-left:25px}")
	// ---

	// Contador de registros filtrados em tela
	@008,480 SAY "Títulos Alterados: "+cValToChar(@nAlterado) SIZE 100,020 OF oPanel PIXEL
	@015,480 SAY "Valor Total: R$ "+AllTrim(cValToChar(Transform(@nValor,"@E 99,999,999,999.99"))) SIZE 100,020 OF oPanel PIXEL
	
	// Botão para Pesquisa - Botão para Pesquisa
	oButton := TButton():New(012,620,"Filtrar",oDlg2,{|| FWMsgRun(, {|| IIf(!Empty(cCodFil),xFilTit(),MsgAlert("Favor preencher a filial!")) }, 'Aguarde', 'Buscando Titulos...') },030,018,,,.F.,.T.,.F.,,.F.,,,.F.)

	oButton:SetCss("QPushButton{" + ;
	"background-color: white;" + ;
	"background-image:url(rpo:pesquisa_labordental.png);" + ;
	"border-style: solid;" + ;
	"border-width: 2px;" + ;
	"border-radius: 12px;" + ;
	"border-color: white;" + ;
	"padding: 6px;" + ;
	"text-align: left;" + ;
	"font: 16px arial, sans-serif;" + ;
	"color: rgb(10, 80, 201);" + ;
	"background-position: center right;" + ;
	"background-repeat: none}" + ;
	"QPushButton:hover {background-color: rgb(10, 188, 201); color: white}")
	// ---

	oPanel:Align := CONTROL_ALIGN_TOP
	
	oPanel2  := TPanel():New(00,00,,oDlg2,,,,,,60,45)
	
    oButton2 := TButton():New(010,605,"Efetivar",oPanel2,{|| IIf( Len(aTitulo) > 0 ,FWMsgRun(, {||xEfetiva() }, 'Aguarde', 'Realizando as alterações...'),MsgAlert("Para a alteração deverá ter registros filtrados!","Atenção")) },035,018,,,.F.,.T.,.F.,,.F.,,,.F.)
	
	oButton2:SetCss("QPushButton{" + ;
	"background-color: white;" + ;
	"border-style: solid;" + ;
	"border-width: 2px;" + ;
	"border-radius: 12px;" + ;
	"border-color: white;" + ;
	"padding: 6px;" + ;
	"text-align: left;" + ;
	"font: 16px arial, sans-serif;" + ;
	"color: rgb(10, 80, 201);" + ;
	"background-position: center right;" + ;
	"background-repeat: none}" + ;
	"QPushButton:hover {background-color: rgb(10, 201, 45); color: white}")
	
	oButton2 := TButton():New(010,020,"Cancelar",oPanel2,{|| oDlg2:End() },040,018,,,.F.,.T.,.F.,,.F.,,,.F.)
	
	oButton2:SetCss("QPushButton{" + ;
	"background-color: white;" + ;
	"border-style: solid;" + ;
	"border-width: 2px;" + ;
	"border-radius: 12px;" + ;
	"border-color: white;" + ;
	"padding: 6px;" + ;
	"text-align: left;" + ;
	"font: 16px arial, sans-serif;" + ;
	"color: rgb(10, 80, 201);" + ;
	"background-position: center right;" + ;
	"background-repeat: none}" + ;
	"QPushButton:hover {background-color: rgb(173, 0, 0); color: white}")
	
	oPanel2:Align := CONTROL_ALIGN_BOTTOM
	
	// Define o Browse
	oBrowse2 := FWBrowse():New()
	oBrowse2:SetDataArray()
	oBrowse2:SetArray(aTitulo)
	oBrowse2:DisableConfig()
	oBrowse2:DisableReport()
	oBrowse2:SetOwner(oDlg2)
		
	//Adiciona legenda no Browse
	oBrowse2:AddLegend('aTitulo[oBrowse2:At(),01]',"GREEN","Sem baixa")
	oBrowse2:AddLegend('!aTitulo[oBrowse2:At(),01]',"BLUE","Baixado parcialmente")

	oColumn2 := FWBrwColumn():New()
	oColumn2:SetData({||aTitulo[oBrowse2:At(),02]})
	oColumn2:SetTitle("Cod.Fornec.")
	oColumn2:SetType("C")
	oColumn2:SetSize(006)
	oBrowse2:SetColumns({oColumn2})
	
	oColumn2 := FWBrwColumn():New()
	oColumn2:SetData({||aTitulo[oBrowse2:At(),03]})
	oColumn2:SetTitle("Loja")
	oColumn2:SetType("C")
	oColumn2:SetSize(003)
	oBrowse2:SetColumns({oColumn2})
	
	oColumn2 := FWBrwColumn():New()
	oColumn2:SetData({||aTitulo[oBrowse2:At(),04]})
	oColumn2:SetTitle("Razão")
	oColumn2:SetType("C")
	oColumn2:SetSize(040)
	oBrowse2:SetColumns({oColumn2})	
	
	oColumn2 := FWBrwColumn():New()
	oColumn2:SetData({||aTitulo[oBrowse2:At(),05]})
	oColumn2:SetTitle("Num.Tit.")
	oColumn2:SetType("C")
	oColumn2:SetSize(006)
	oBrowse2:SetColumns({oColumn2})		
	
	oColumn2 := FWBrwColumn():New()
	oColumn2:SetData({||aTitulo[oBrowse2:At(),06]})
	oColumn2:SetTitle("Vencto.Atual")
	oColumn2:SetType("D")
	oColumn2:SetSize(008)
	oBrowse2:SetColumns({oColumn2})		
	
	oColumn2 := FWBrwColumn():New()
	oColumn2:SetData({||aTitulo[oBrowse2:At(),07]})
	oColumn2:SetTitle("Vencto.Novo")
	oColumn2:SetType("D")
	oColumn2:SetSize(008)
	oBrowse2:SetColumns({oColumn2})	

	oColumn2 := FWBrwColumn():New()
	oColumn2:SetData({||aTitulo[oBrowse2:At(),08]})
	oColumn2:SetTitle("Valor")
	oColumn2:SetType("N")
	oColumn2:SetSize(005)
	oColumn2:SetPicture("@E 99,999,999,999.99")
	oBrowse2:SetColumns({oColumn2})		

	oBrowse2:GetBackColor(16777215)
	oBrowse2:GetClrAlterRow(16770250)
	oBrowse2:SetLineHeight(20)
	
	oBrowse2:SetEditCell(.T.)
	oBrowse2:aColumns[07]:lEdit    := .T.
	oBrowse2:aColumns[07]:cReadVar := 'aTitulo[oBrowse2:At(),07]'
	oBrowse2:bValidEdit            := {|| xValidData()}
	
	oBrowse2:Activate()
	
	Activate MSDIALOG oDlg2 Centered
	
	RestArea(aAreaXX)

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 11/10/2021
Consultoria: Prox
Uso: Skala
Info: Filtra os títulos no Contas a Pagar
*==================================================================*/
Static Function xFilTit()

	Local cQuery   := ""
	Local cNomeFor := ""
	Local cTemp    := GetNextAlias() 
	Local lStatus  := .T.
	
	//Atualizao das variáveis para novas buscas
	aTitulo := {}
	nValor  := 0

	//Acesso a filial no qual utilizo na busca do filtro
	cFilAnt := cCodFil
	
	cQuery := " SELECT * FROM "+RetSQLName("SE2")
	cQuery += " WHERE E2_FILIAL = '"+cCodFil+"'"

	//caso não tenha fornecedor e loja preenchidos trago todos os títulos
	If !Empty(cCodForn) .And. !Empty(cCodLoja)
		cQuery += " 	AND E2_FORNECE = '"+cCodForn+"'"
		cQuery += "		AND E2_LOJA = '"+cCodLoja+"'"
	Endif 

	cQuery += "		AND E2_EMISSAO BETWEEN '"+DToS(dEmisDe)+"' AND '"+DToS(dEmisAte)+"'"
	cQuery += "		AND E2_VENCREA BETWEEN '"+DToS(dVencDe)+"' AND '"+DToS(dVencAte)+"'"
	cQuery += "		AND E2_NUMBOR = ' '"
	cQuery += "		AND E2_SALDO > 0"
	cQuery += "		AND D_E_L_E_T_ <> '*'"
	cQuery += " ORDER BY E2_FILIAL,E2_PREFIXO,E2_NUM,E2_FORNECE,E2_LOJA,E2_VENCREA"
	
	//Verifico se o alias alocado para a tabela já consta como existente, se sim fecho o alias e aloco um novo
	If Select(cTemp) > 0
		(cTemp)->(DbCloseArea())
		cTemp := GetNextAlias()
	Endif
	
	cQuery := ChangeQuery(cQuery)
	
	DbUseArea(.T.,"TOPCONN",TcGenQry(,,cQuery),cTemp,.T.,.T.)

	DbSelectArea(cTemp)
	
	(cTemp)->(DbGoTop())
	
	While !(cTemp)->(EOF())
	
		cNomeFor := AllTrim(Posicione("SA2",1,xFilial("SA2")+(cTemp)->E2_FORNECE+(cTemp)->E2_LOJA,"A2_NOME"))
		lStatus  := IIf((cTemp)->E2_VALOR == (cTemp)->E2_SALDO,.T.,.F.)
	
		aAdd(aTitulo,{lStatus,(cTemp)->E2_FORNECE,(cTemp)->E2_LOJA,cNomeFor,(cTemp)->E2_NUM,SToD((cTemp)->E2_VENCREA),SToD("  /  /    "),(cTemp)->E2_VALOR,(cTemp)->R_E_C_N_O_})
	
		(cTemp)->(DbSkip())
	
	EndDo
	
	If Len(aTitulo) == 0
		MsgAlert("Não foram encontrados títulos nos parâmetros informados!","Atenção")		
	Endif 
	
	oBrowse2:SetArray(aTitulo)
	oBrowse2:Refresh()

Return 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 11/10/2021
Consultoria: Prox
Uso: Skala
Info: Validação da Data de Vencimento Nova
*==================================================================*/
Static Function xValidData()

	Local lRet := .T.
	Local nX   := 0
	
	If !Empty(aTitulo[oBrowse2:At(),07])
		If aTitulo[oBrowse2:At(),07] < dDataBase
			MsgAlert("Não é permitido data menor que a data atual!","Atenção")
			lRet := .F.
		Endif 
	Endif

	nValor    := 0
	nAlterado := 0

	For nX := 1 To Len(aTitulo)
		If !Empty(aTitulo[nX,07])
			nValor += aTitulo[nX,08]
			nAlterado++
		Endif 
	Next nX

Return(lRet) 

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 11/10/2021
Consultoria: Prox
Uso: Skala
Info: Efetiva a alteração das datas de vencimentos 
*==================================================================*/
Static Function xEfetiva()

	Local aNewArray := {}
	Local aArray    := {}
	Local aDados    := {}
	Local nX        := 0
	Local lSucess   := .T.
	
	Private lMsErroAuto := .F.
	
	aEval(aTitulo,{|x,y|IIf(!Empty(x[7]),aAdd(aNewArray,{x[2],x[3],x[4],x[5],x[6],x[7],x[8],x[9]}),)})

	Begin Transaction 

	For nX := 1 To Len(aNewArray)
	
		SE2->(DbGoTo(aNewArray[nX,8]))
	
		aArray := {;
				  { "E2_PREFIXO" , SE2->E2_PREFIXO     				  , Nil},;
                  { "E2_NUM"     , SE2->E2_NUM        				  , Nil},;
                  { "E2_TIPO"    , SE2->E2_TIPO       				  , Nil},;
                  { "E2_NATUREZ" , SE2->E2_NATUREZ    				  , Nil},;
                  { "E2_FORNECE" , SE2->E2_FORNECE    				  , Nil},;
                  { "E2_EMISSAO" , SE2->E2_EMISSAO    				  , Nil},;
                  { "E2_VENCTO"  , aNewArray[nX,6]                    , Nil},;
                  { "E2_VENCREA" , DataValida(aNewArray[nX,6],.T.)    , Nil},;
                  { "E2_VALOR"   , SE2->E2_VALOR      				  , Nil};
				  }
 
		MsExecAuto({|x,y,z|FINA050(x,y,z)},aArray,,4)  // 3 - Inclusao, 4 - Alteração, 5 - Exclusão
 
		If lMsErroAuto
			MostraErro()
			MsgAlert("A operação será cancelada por conta da inconsistência!","Atenção")
			DisarmTransaction()	
			lSucess := .F.	
		Endif
	
	Next nX
	
	End Transaction

	If lSucess .And. Len(aNewArray) > 0
		aEval(aNewArray,{|x,y|IIf(!Empty(x[7]),aAdd(aDados,{x[1],x[2],x[3],x[4],x[5],DataValida(x[6],.T.),x[7]}),)}) //Atualizo array com os dados ara gerar o relatório
		xGerExcel(aDados)
	Elseif lSucess .And. Len(aNewArray) == 0
		MsgAlert("Não há registros com novas datas!","Atenção")
	Endif 
	
	//Restauro para a filial atual
	cFilAnt := cFilAtual
	
Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 11/10/2021
Consultoria: Prox
Uso: Skala
Info: Relatório com os registros atualizados  
*==================================================================*/
Static Function xGerExcel(aDados)

	Local aItens     := {}
	Local aCabec     := {"Cod.Fornec.","Loja","Razão","Num.Tit.","Vencto.Atual","Vencto.Novo","Valor"}
	Local nX         := 0
	Local nY         := 0
	Local nVlrTotal  := 0
	Local cAba       := "CONTAS A PAGAR"
	Local cTabela    := "LOG DE ALTERAÇÃO"
	Local cHora      := Time()
	Local cPasta     := GetMV("XX_XARQUI",.F.,"C:\temp\")
	Local cArquivo   := cPasta+'RelSE2_'+AllTrim(StrTran(cHora,":",""))+'_.xml'
	Local oFWMsExcel := Nil

	//Verifico se há a pasta existe no computador do usuário, caso não exista eu crio a mesma
	If !ExistDir(cPasta)
	  	MakeDir(cPasta)
	Endif
     
	//Criando o objeto que irá gerar o conteúdo do Excel
	oFWMsExcel := FWMSExcel():New()

	//Aba
	oFWMsExcel:AddworkSheet(cAba) //Não utilizar número junto com sinal de menos. Ex.: 1-

	//Criando a Tabela
	oFWMsExcel:AddTable(cAba,cTabela)

	For nX := 1 To Len(aCabec)
		//Adiciono coluna no excel
		oFWMsExcel:AddColumn(cAba,cTabela,aCabec[nX],1,1,.F.)
	Next nX

	For nX := 1 To Len(aDados)

		aItens := Array(Len(aDados[nX]))

		For nY := 1 To Len(aDados[nX])

			aItens[nY] := aDados[nX,nY]

			If ValType(aDados[nX,nY]) == "N"
				nVlrTotal += aDados[nX,nY]
			Endif 

		Next nY

		//Adiciono linha no excel
		oFWMsExcel:AddRow(cAba,cTabela,aItens)

	Next nX

	aItens := {"","","","","","Total",nVlrTotal}

	//Adiciono linha no excel
	oFWMsExcel:AddRow(cAba,cTabela,aItens)

	//Ativando o arquivo e gerando o xml
	oFWMsExcel:Activate()

	oFWMsExcel:GetXMLFile(cArquivo)

	//Verificação se o arquivo foi criado
	If File(cArquivo)
		ShellExecute("Open",cArquivo,"","",5) //Abro o arquivo xml
	Else
		MsgAlert("Erro na geração do relatório!","Erro")
	Endif
	
	//Fecho a tela após a extração do relatório de log
	oDlg2:End()

Return
