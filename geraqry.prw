/*
ÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜÜ
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
±±ÉÍÍÍÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍËÍÍÍÍÍÍÑÍÍÍÍÍÍÍÍÍÍÍÍÍ»±±
±±ºPrograma  ³GERAQRY V1.3 º Autor Diego T. Fialho   º Data ³  02/04/15   º±±
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÊÍÍÍÍÍÍÏÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±ºDesc.     ³ Programa para gerar uma query para copiar dados de uma     º±±
±±º          ³ para outra.                                                º±±   
±±ÌÍÍÍÍÍÍÍÍÍÍØÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍÍ¹±±
±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±±
ßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßßß
*/

#Include "protheus.ch"
#Include "fileio.ch"
#INCLUDE "TBICONN.CH"
#INCLUDE "TOPCONN.CH"

User Function geraqry()  
Local aLstTabela := {"ACY","CN0","CN1","CN5","CNK","CNL","CT8","CTA","DA0","DA1","DA3","SA3","SA4",;  	  //Array com as tabelas que serão copiadas
                     "SA6","SAH","SB1","SBM","SE4","SED","SES","SF4","SF5","SF7","SG1","SG5","SM4","SU5",;
                     "SA2","CT1","CT5","CTS","CVN","CTN","CVE","CVF"}

Local cEmpDest := {"130"} //Empresa(s) destino
Local cEmpOri             //Empresa de origem
Local nEmpInd,nTabInd
Local nHandJob
Private cPath := "C:\TEMP\CARGA\"  //Diretório onde os arquivos serão salvos

  PREPARE ENVIRONMENT EMPRESA "99" FILIAL "01" TABLES "SIX","SX2","SX3"
    cEmpOri  := "090"
    If !(ExistDir(cPath))		//Rotina para verificar se o diretório existe, se não existir será criado
		cTempPath := cPath
		aTempPath := {}
		
		While AT("\",cTempPath) > 0
			AADD(aTempPath,SUBSTR(cTempPath,1,AT("\",cTempPath)))
			cTempPath := SUBSTR(cTempPath,AT("\",cTempPath)+1,Len(cTempPath))
		End
		AADD(aTempPath,cTempPath)
		cTempPath := ""
		
		For i := 1 To Len(aTempPath)
			MakeDir(cTempPath+aTempPath[i])
			cTempPath := cTempPath + aTempPath[i]
		Next
    EndIf
    
    nHandJob := Fcreate(cPath + "JOB.SQL")
    For nEmpInd:= 1 To Len(cEmpDest)
          
        For nTabInd := 1 To Len(aLstTabela)
            cptbgv(aLstTabela[nTabInd],cEmpOri,cEmpDest[nEmpInd])  
            
            FWrite(nHandJob,("@C:\Temp\Carga\"+aLstTabela[nTabInd]+cEmpOri+cEmpDest[nEmpInd]) + "_query.txt"+CRLF)            
        Next
    Next
    FClose(nHandJob)
  RESET ENVIRONMENT
    	
Return
//////////////////////////////////////////////////////////
Static Function cptbgv(cAlias,cEmp1,cEmp2)
	Local aCampos := {}
	Local cQueryInsert := "INSERT INTO "
	Local cQuerySelect := "SELECT "
	Local cQueryChave  := ""
	Local cQuery
	Local i
	Local cNomeArquivo := ""
	Local cFilialEmp
	Local nArquivo
	Local cChave
	Private aChave := {}              

	dbSelectArea("SX2")
	SX2->(DbSetOrder(1))
    SX2->(dbSeek(cAlias))       
    
    cFilialEmp := IIf(SX2->X2_MODO = 'E','01','  ')
    cChave := SX2->X2_UNICO
    
    If cChave == ' '
    	While (AT("+",cChave) <> 0)
			cChave := cutChv(cChave)
    	End
		AADD(aChave,cChave)
	Else
		dbSelectArea("SIX")
		SIX->(DbSetOrder(1))
	    SIX->(dbSeek(cAlias))
	    cChave := SIX->CHAVE	    
	    While (AT("+",cChave) <> 0)
			cChave := cutChv(cChave)
    	End
		AADD(aChave,cChave)
	EndIf
	
	dbSelectArea("SX3")
	SX3->(DbSetOrder(1))
	
	If SX3->(dbSeek(cAlias))
		cNomeArquivo := (cPath+cAlias+cEmp1+cEmp2) + "_query.txt"
		cQueryInsert := cQueryInsert + cAlias + cEmp2 + " (" + CRLF
		
		Do While !Sx3->(Eof()) .And. (x3_arquivo == cAlias) 
		    If "USERLGI" $ x3_campo .Or.;
		       "USERLGA" $ x3_campo
		       Sx3->(dbSkip())
		       Loop
            EndIf
			
			If x3_context <> "V"
				AADD(aCampos,x3_campo)
			EndIf
			Sx3->(dbSkip())
		EndDo
	   
		For i := 1 To Len(aChave)
			If "_FILIAL" $ aChave[i]
				cQueryChave := cQueryChave + cAlias + cEmp2 + "." + aCampos[1] + " = '" + cFilialEmp + "'
			Else
				cQueryChave := cQueryChave + cAlias + cEmp1 + "." + ALLTRIM(aChave[i]) + " = " + ALLTRIM(cAlias + cEmp2 + "." + aChave[i])
			EndIf
			
			If i <> Len(aChave)
				cQueryChave := cQueryChave + " AND " + CRLF
			EndIf
		Next
		
		For i := 1 To Len(aCampos)
			cQueryInsert := cQueryInsert + aCampos[i]
			If "_FILIAL" $ aCampos[i]
               cQuerySelect := cQuerySelect + "'"+cFilialEmp+"'"
            Else
   			   cQuerySelect := cQuerySelect + aCampos[i]            
            EndIf   

			If i <> Len(aCampos)
				cQueryInsert := cQueryInsert + ","
				cQuerySelect := cQuerySelect + ","
				If i % 7 == 0
					cQueryInsert := cQueryInsert + CRLF
					cQuerySelect := cQuerySelect + CRLF
				EndIf
			Else
				cQueryInsert := cQueryInsert + ",R_E_C_N_O_,D_E_L_E_T_)" + CRLF
				cQuerySelect := cQuerySelect + ",R_E_C_N_O_,D_E_L_E_T_ " + CRLF+"FROM " + cAlias + cEmp1
				cQuery := cQueryInsert + cQuerySelect
			EndIf
		Next   
		cQuery += CRLF
		cQuery += "WHERE D_E_L_E_T_ <> '*' AND NOT EXISTS (SELECT NULL FROM " + cAlias + cEmp1 + " WHERE " + cQueryChave + ");" 
		cQuery += CRLF		
		
		nArquivo := Fcreate(cNomeArquivo)
		FWrite(nArquivo,cQuery)
		FClose(nArquivo)
	Else
		msgalert("O alias informado não existe")
	EndIf
Return

Static Function cutChv(cChave)
	Local chv
	chv := SUBSTR(cChave,AT("+",cChave)+1,Len(cChave))
	AADD(aChave,SUBSTR(cChave,1,AT("+",cChave)-1))
Return chv
