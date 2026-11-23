#INCLUDE 'totvs.ch'
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"
#INCLUDE 'FWMVCDef.ch'
#INCLUDE "PROTHEUS.CH"
#INCLUDE "RPTDEF.CH"
#INCLUDE "SHELL.CH"
#INCLUDE "FWPrintSetup.ch"

#define _crlf chr(13)+Chr(10)

User Function EtqEmb(_cOpEmb, cHrFim)

    Local oPrinter        := Nil
    Local oFont1          := TFont():New("Arial", , -10, .T., .T.)
    Local oFont2          := TFont():New("Arial", , -5,  .T., .T.)
    Local oFont3          := TFont():New("Arial", , -8,  .T., .T.)
    Local COR_PRETO       := RGB(000, 000, 000)
    Local nLinha, nColuna := 0
    Local lAdjustToLegacy := .F.
    Local lDisableSetup   := .T.
    Local cQuery, cCodigo, cDescr, cCorridas := ""
    Local aLotes          := {}
    Local _cArquivo       := ""
	Local _cUsr           := RetCodUsr() 
	Local _cMat           := UsrRetName(_cUsr)
    Local _nPecas         := 0
    Local aImps           := GetImpWindows(.F.)
    Local lPremium        := .F.
    Local nPeca           := 0
    Local nTotalEtiq      := 0
    Local cTodasCorridas  := ""
    Local nI              := 0
    Local nY              := 0

    cQuery := "SELECT H6_PRODUTO, B1_DESC, B1_XGRLIGA, B1_XVARIAN, B1_XCOMPR, H6_XCOMPRI, H6_LOTECTL, H6_QTDPROD, H6_QTDPRO2, H6_XTARA, H6_OP, H6_DATAINI, H6_HORAFIN " + _crlf
    cQuery += "FROM SH6010 SH6 " + _crlf
    cQuery += "INNER JOIN SB1010 SB1 ON SB1.D_E_L_E_T_='' AND B1_COD=H6_PRODUTO " + _crlf
    cQuery += "WHERE SH6.D_E_L_E_T_='' AND H6_OP='" + _cOpEmb + "' " + _crlf
    
    TcQuery cQuery New Alias "SH6X"

    If !SH6X->(Eof())

        cCodigo  := SH6X->H6_PRODUTO
        cDescr   := SH6X->B1_DESC
        nPesoLiq := SH6X->H6_QTDPROD
        nPesoBru := SH6X->(H6_QTDPROD + H6_XTARA)
        _nPecas  := SH6X->H6_QTDPRO2
        dData    := STOD(SH6X->H6_DATAINI)
        cHrFimH6 := SH6X->H6_HORAFIN
        cLiga    := SH6X->B1_XGRLIGA
        cVarian  := SH6X->B1_XVARIAN
        cCompr   := SH6X->H6_XCOMPRI
        _cLote   := Alltrim(SH6X->H6_LOTECTL)

        cQry := "SELECT SUBSTRING(D3_LOTECTL,1,CHARINDEX('.',D3_LOTECTL)-1) D3_LOTECTL, D3_QTSEGUM" + _crlf
        cQry += "FROM SD3010 SD3 "
        cQry += "WHERE SD3.D_E_L_E_T_='' AND D3_FILIAL='" + cFilAnt + "' AND D3_OP='" + _cOpEmb + "' AND D3_ESTORNO<>'S' AND D3_LOTECTL<>'' AND D3_TM='501' "
        
        TcQuery cQry New Alias "SD3X"

        While !SD3X->(Eof())
            aAdd(aLotes,{Alltrim(SD3X->D3_LOTECTL),SD3X->D3_QTSEGUM})
            SD3X->(DbSkip())
        EndDo

        SD3X->(DbCloseArea())

    Else
        MessageBox("Lote nao disponivel", "Lote", 1)
        SH6X->(DBCloseArea())
        Return
    EndIf

    SH6X->(DBCloseArea())

    _cArquivo := strtran(_cLote, ".", "_") + "_" + strtran(time(), ":", "")

    oPrinter  := FWMSPrinter():New(_cArquivo, IMP_SPOOL, lAdjustToLegacy, "\spool", lDisableSetup, , , "ZDesigner ZD220-203dpi ZPL", .F., , , .T., 1)
    
    oPrinter:SetResolution(72)
    oPrinter:SetPortrait()
    oPrinter:SetPaperSize(9)
    oPrinter:SetMargin(0, 3, 0, 0)

    If aScan(aImps, "ZDesigner ZD220-203dpi ZPL") <= 0
        oPrinter:Setup()
    EndIf

    //Verifico se trata-se de uma etiqueta de Liga premium
    lPremium := GetPremium(cLiga,cVarian)
    // ---

    For nI := 1 To Len(aLotes)
        cTodasCorridas += aLotes[nI,1] + IIf(nI < Len(aLotes), " / ", "")
    Next nI
    
    //Caso não seja liga premium eu trato a quantidade da etiqueta impressa
    If !lPremium
	
        cCorridas  := cTodasCorridas 

        //Inicio Etiqueta Normal
        nLinha  := 20
        nColuna := 25

        oPrinter:StartPage()

        oPrinter:Box(010, 020, 215, 280, "-8")
        oPrinter:Box(010, 020, 040, 280, "-8")
        oPrinter:SayBitMap(011, nColuna + 100, "\system\asi.jpg", 0045, 0025)
        
        nLinha += 10
        
        oPrinter:Say(nLinha, nColuna, "METALEX", oFont1, , COR_PRETO)
        oPrinter:Say(nLinha, nColuna + 150, "MADE IN BRASIL", oFont1, , COR_PRETO)
        
        nLinha += 20
        
        oPrinter:Say(nLinha, nColuna, "PRODUTO: " + cDescr, oFont1, , COR_PRETO)
        
        nLinha += 10
        
        oPrinter:Say(nLinha, nColuna, "PRODUCT: " + cDescr, oFont2, , COR_PRETO)
        
        nLinha += 10
        
        oPrinter:Say(nLinha, nColuna, "LIGA:" + cLiga, oFont1, , COR_PRETO)
        oPrinter:Say(nLinha, nColuna + 140, "COMPRIMENTO:" + cValToChar(cCompr), oFont1, , COR_PRETO)
        
        nLinha += 10
        
        oPrinter:Say(nLinha, nColuna, "ALLOY" + cLiga, oFont2, , COR_PRETO)
        oPrinter:Say(nLinha, nColuna + 140, "LENGHT" + cValtochar(cCompr), oFont2, , COR_PRETO)
        
        nLinha += 10
        
        oPrinter:Say(nLinha, nColuna, "PESO LÍQUIDO(kg): " + cValToChar(nPesoLiq), oFont1, , COR_PRETO)
        oPrinter:Say(nLinha, nColuna + 140, "PESO BRUTO(kg): " + cvaltochar(nPesoBru), oFont1, , COR_PRETO)
        
        nLinha += 10
        
        oPrinter:Say(nLinha, nColuna, "NET WEIGTH(kg): " + cvaltochar(nPesoLiq), oFont2, , COR_PRETO)
        oPrinter:Say(nLinha, nColuna + 140, "GROSS WEIGHT (kg): " + cvaltochar(nPesoBru), oFont2, , COR_PRETO)
        
        nLinha += 10
        
        oPrinter:Say(nLinha, nColuna, "DATA/HORA: " + dtoc(dData) + " - " + cHrFimH6, oFont1, , COR_PRETO)
        oPrinter:Say(nLinha, nColuna + 140, "MAT: " + _cMat, oFont1, , COR_PRETO)
        
        nLinha += 10
        
        oPrinter:Say(nLinha, nColuna, "DATE/TIME: " + dtoc(dData) + " - " + cHrFimH6, oFont2, , COR_PRETO)
        
        nLinha += 10
        
        oPrinter:Say(nLinha, nColuna, "QUANT. TARUGOS: " + cvaltochar(_nPecas), oFont1, , COR_PRETO)
        
        oPrinter:Say(nLinha, nColuna + 140, "NR ETIQ: " + _cLote, oFont1, , COR_PRETO)
        
        nLinha += 10
        
        oPrinter:Say(nLinha, nColuna, "QUANT.BILLETS: " + cvaltochar(_nPecas), oFont2, , COR_PRETO)
        oPrinter:Say(nLinha, nColuna + 140, "LABEL: " + _cLote, oFont2, , COR_PRETO)
        
        nLinha += 10
        
        oPrinter:Say(nLinha, nColuna, "CORRIDAS: " + cCorridas, oFont1, , COR_PRETO)
        
        nLinha += 10
        
        oPrinter:Say(nLinha, nColuna, "CASTER NUMBER: " + cCorridas, oFont2, , COR_PRETO)
        
        nLinha += 10

        oPrinter:Code128(nLinha, nColuna + 10, cvaltochar(_cLote), 1, 20, .T., oFont3, )
        
        nLinha += 30

        oPrinter:EndPage()
        //--- Fim etiqueta Normal ---

    Else 

        For nY := 1 To Len(aLotes)

            nTotalEtiq := aLotes[nY,2]
            cCorridas  := aLotes[nY,1]
            
            //Inicio impressão etiqueta Premium
            For nPeca := 1 To nTotalEtiq
                
                nLinha  := 20
                nColuna := 25
                _nPecas := 1

                oPrinter:StartPage()

                oPrinter:Box(010, 020, 215, 280, "-8")
                oPrinter:Box(010, 020, 040, 280, "-8")
                oPrinter:SayBitMap(011, nColuna + 100, "\system\asi.jpg", 0045, 0025)
                
                nLinha += 10
                
                oPrinter:Say(nLinha, nColuna, "METALEX", oFont1, , COR_PRETO)
                oPrinter:Say(nLinha, nColuna + 150, "MADE IN BRASIL", oFont1, , COR_PRETO)
                
                nLinha += 20
                
                oPrinter:Say(nLinha, nColuna, "PRODUTO: " + cDescr, oFont1, , COR_PRETO)
                
                nLinha += 10
                
                oPrinter:Say(nLinha, nColuna, "PRODUCT: " + cDescr, oFont2, , COR_PRETO)
                
                nLinha += 10
                
                oPrinter:Say(nLinha, nColuna, "LIGA:" + cLiga, oFont1, , COR_PRETO)
                oPrinter:Say(nLinha, nColuna + 140, "COMPRIMENTO:" + cValToChar(cCompr), oFont1, , COR_PRETO)
                
                nLinha += 10
                
                oPrinter:Say(nLinha, nColuna, "ALLOY" + cLiga, oFont2, , COR_PRETO)
                oPrinter:Say(nLinha, nColuna + 140, "LENGHT" + cValtochar(cCompr), oFont2, , COR_PRETO)
                
                nLinha += 10
                
                oPrinter:Say(nLinha, nColuna, "PESO LÍQUIDO(kg): " + cValToChar(nPesoLiq), oFont1, , COR_PRETO)
                oPrinter:Say(nLinha, nColuna + 140, "PESO BRUTO(kg): " + cvaltochar(nPesoBru), oFont1, , COR_PRETO)
                
                nLinha += 10
                
                oPrinter:Say(nLinha, nColuna, "NET WEIGTH(kg): " + cvaltochar(nPesoLiq), oFont2, , COR_PRETO)
                oPrinter:Say(nLinha, nColuna + 140, "GROSS WEIGHT (kg): " + cvaltochar(nPesoBru), oFont2, , COR_PRETO)
                
                nLinha += 10
                
                oPrinter:Say(nLinha, nColuna, "DATA/HORA: " + dtoc(dData) + " - " + cHrFimH6, oFont1, , COR_PRETO)
                oPrinter:Say(nLinha, nColuna + 140, "MAT: " + _cMat, oFont1, , COR_PRETO)
                
                nLinha += 10
                
                oPrinter:Say(nLinha, nColuna, "DATE/TIME: " + dtoc(dData) + " - " + cHrFimH6, oFont2, , COR_PRETO)
                
                nLinha += 10
                
                oPrinter:Say(nLinha, nColuna, "QUANT. TARUGOS: " + cvaltochar(_nPecas), oFont1, , COR_PRETO)
                
                oPrinter:Say(nLinha, nColuna + 140, "NR ETIQ: " + _cLote + "-" + StrZero(nPeca, 3), oFont1, , COR_PRETO)
                
                nLinha += 10
                
                oPrinter:Say(nLinha, nColuna, "QUANT.BILLETS: " + cvaltochar(_nPecas), oFont2, , COR_PRETO)
                oPrinter:Say(nLinha, nColuna + 140, "LABEL: " + _cLote, oFont2, , COR_PRETO)
                
                nLinha += 10
                
                oPrinter:Say(nLinha, nColuna, "CORRIDAS: " + cCorridas, oFont1, , COR_PRETO)
                
                nLinha += 10
                
                oPrinter:Say(nLinha, nColuna, "CASTER NUMBER: " + cCorridas, oFont2, , COR_PRETO)
                
                nLinha += 10

                oPrinter:Code128(nLinha, nColuna + 10, _cLote, 1, 20, .T., oFont3, )
                
                nLinha += 30

                oPrinter:EndPage()

            Next nPeca
            //-- Fim etiqueta premium---

        Next nY 

    Endif
    //---

    oPrinter:Preview()

Return

/*=================================================================
Autor: Vinicius N. de Oliveira
Data: 15/05/2026
Consultoria: FixSystem
Info: Identificação da etiqueta liga premium na tabela SZ6 
*==================================================================*/
Static Function GetPremium(cLiga,cVarian)

    Local cQuery    := ""
    Local cAliasQry := GetNextAlias()
    Local lPremium  := .F.

    cQuery := " SELECT Z6_TIPO FROM " + RetSqlName("SZ6") + " SZ6 "
    cQuery += " WHERE Z6_GRLIGA = '" + cLiga + "' "
    cQuery += " AND Z6_VARIAN = '" + cVarian + "' "
    cQuery += " AND Z6_TIPO = 'P' "
    cQuery += " AND SZ6.D_E_L_E_T_ = ' ' "
    
    MPSysOpenQuery(cQuery, cAliasQry)

    If !(cAliasQry)->(EOF())
        lPremium := .T.
    EndIf

    (cAliasQry)->(DBCloseArea())

Return(lPremium)
