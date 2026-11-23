#Include "Totvs.ch"

/*=================================================================
Autor: Vinicius N. De Oliveira
Data: 27/07/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Obtem o token de seguranca (OAuth2 Client Credentials)
      utilizado para autenticar chamadas a outras APIs.
*==================================================================*/
User Function MLTAPI02()

	Local cUrl          := "https://login.microsoftonline.com/49158df8-04df-4db2-a1ae-ee3949ca3984/oauth2/v2.0/token"
	Local cClientId     := "cac65940-8aef-43f4-ab78-6c1fd2346157"
	Local cClientSecret := "O368Q~mVkC5r0SaPx9INRyzHe~dwFvbZX2PdwcQj"
	Local cScope        := "cac65940-8aef-43f4-ab78-6c1fd2346157/.default"
	Local cPayload      := ""
	Local aHeader       := {}
	Local cResponse     := ""
	Local cHeadRet      := ""
	Local cAccessToken  := ""

	cPayload := MLTMontaPayloadToken(cClientId, cClientSecret, cScope)
	aHeader  := MLTMontaHeaderToken()

	cResponse := HttpPost(cUrl, "application/x-www-form-urlencoded", cPayload, 120, aHeader, @cHeadRet)

	If Empty(cResponse)
		ConOut("MLTAPI002: Servidor nao retornou dados (timeout ou indisponivel).")
	Else
		cAccessToken := MLTTrataRespostaToken(cResponse)
	EndIf
//
Return cAccessToken

/*=================================================================
Autor: Vinicius N. De Oliveira
Data: 27/07/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Monta o corpo (x-www-form-urlencoded) da requisicao de token.
*==================================================================*/
Static Function MLTMontaPayloadToken(cClientId, cClientSecret, cScope)

	Local cPayload := ""

	cPayload += "grant_type=client_credentials"
	cPayload += "&client_id="     + cClientId
	cPayload += "&client_secret=" + cClientSecret
	cPayload += "&scope="         + cScope

Return cPayload

/*=================================================================
Autor: Vinicius N. De Oliveira
Data: 27/07/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Monta o header HTTP da requisicao de token.
*==================================================================*/
Static Function MLTMontaHeaderToken()

	Local aHeader := {}

	aAdd(aHeader, "Content-Type: application/x-www-form-urlencoded")

Return aHeader

/*=================================================================
Autor: Vinicius N. De Oliveira
Data: 27/07/2026
Consultoria: Fixsystem
Uso: Metalex
Info: Interpreta o JSON de retorno da requisicao de token e
      extrai o access_token.
*==================================================================*/
Static Function MLTTrataRespostaToken(cResponse)

	Local oJson        := Nil
	Local cAccessToken := ""

	FWJsonDeserialize(cResponse, @oJson)

	If ValType(oJson) == "O" .And. AttIsMemberOf(oJson,"access_token") .And. !Empty(oJson:access_token)
		cAccessToken := oJson:access_token
		ConOut("MLTAPI02: Token de seguranca obtido com sucesso.")
	Else
		ConOut("MLTAPI02: Nao foi possivel localizar o access_token no retorno: " + cResponse)
	EndIf

	If ValType(oJson) == "O"
		FreeObj(oJson)
	EndIf

Return cAccessToken
