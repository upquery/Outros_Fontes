set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplica��o: Avalia��o de Clima
-- >>>>>>> Por:		Upquery Tec (Jo�ozinho)
-- >>>>>>> Data:	14/05/12
-- >>>>>>> Pacote:	S.A.C 1.3(Sistema de Avalia��o de Clima)
-- >>>>>>>-------------------------------------------------------------

--create table sac_perfil ( cd_perfil number, ds_perfil varchar2(400), tipo varchar2(80)) 30/09/2015
--create table avaliacao (cd_avaliacao number, cd_senha number, cd_funcao number, cd_turno number, cd_idade number, cd_escolaridade number, cd_tempo number, cd_setor number, cd_unidade number,  dt_avaliacao date, in_fecha number) 14/10/2015

create or replace package Sac is
	
	procedure main;

    PROCEDURE MSG ( PRM_TIPO VARCHAR2 DEFAULT NULL );
	
	procedure perguntas ( prm_senha varchar2 );
	
	procedure avaliacao ( prm_senha varchar2 );
		         
	PROCEDURE INSERIR_AVALIACAO( PRM_SENHA VARCHAR2,
					  			 FUNCAO NUMBER DEFAULT 0,
								 TURNO NUMBER DEFAULT 0,
								 IDADE  NUMBER DEFAULT 0,
					  			 ESCOLARIDADE NUMBER DEFAULT 0, 
				      			 TEMPO NUMBER DEFAULT 0,
								 SETOR NUMBER DEFAULT 0,
								 UNIDADE NUMBER DEFAULT 0,
								 SEXO NUMBER DEFAULT 0 );
				      
	procedure inserir( avaliacao integer default null,
			           pergunta integer,
			           nota integer);
			
	procedure inserir_text(avaliacao integer default null,
					  pergunta integer,
					  nota integer,
				      obs varchar2 default null);	
	
	procedure check_nota ( prm_avaliacao integer,
                           prm_questao integer );
	
	procedure fechar( avaliacao integer );
	
	procedure add;
	
	procedure add_pergunta ( prm_pergunta varchar2 default null,
                             prm_grupo varchar2 default null,
							 prm_tipo char default '1' );
							 
	procedure add_cadastro ( prm_valor varchar2 default null,
							 prm_tipo char default '1' );
							 
	procedure dlt;
	
	procedure dlt_cadastro ( prm_valor varchar2 default null,
							     prm_tipo char default '1' );
	
end Sac;
/
create or replace PACKAGE BODY Sac IS

	PROCEDURE MAIN AS
	
		WS_COUNT NUMBER;
	
		BEGIN
		FCL.REFRESH_SESSION;
		HTP.P('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
		HTP.P('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">');
			HTP.HEADOPEN;
				HTP.P('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
				HTP.P('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
				HTP.P('<TITLE>AVALIA&Ccedil;&Atilde;O DE CLIMA</TITLE>');
				HTP.P('<META HTTP-EQUIV="Pragma" CONTENT="no-cache, no-store, must-revalidate">');
				HTP.P('<META HTTP-EQUIV="Expires" CONTENT="0">');
				HTP.P('<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">');
				HTP.P('<meta name="apple-mobile-web-app-capable" content="yes" />');
				HTP.P('<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">');
				HTP.P('<link rel="favicon" href="'||FUN.R_GIF('upquery-icon','PNG')||'" />');
				HTP.P('<link rel="shortcut icon" href="'||FUN.R_GIF('upquery-icon','PNG')||'" />');
				HTP.P('<link rel="apple-touch-startup-image" href="'||FUN.R_GIF('upquery-icon','PNG')||'">');
				HTP.P('<meta name="apple-mobile-web-app-status-bar-style" content="black">');
                HTP.P('<link href="https://fonts.googleapis.com/css?family=Montserrat" rel="stylesheet" type="text/css">');
				FCL.KEYWORDS;
				HTP.P('<script src="dwu.fcl.download?arquivo=sac.js"></script>');
				
				HTP.P('<link rel="stylesheet" href="dwu.fcl.download?arquivo=default.css">');
				HTP.P('<link rel="stylesheet" href="dwu.fcl.download?arquivo=sac_bauer.css">');
				
			HTP.HEADCLOSE;
			HTP.P('<body>');
			    HTP.P('<div id="background"></div>');
				HTP.P('<div id="avaliacao">');
					HTP.P('<h1>AVALIA&Ccedil;&Atilde;O DE CLIMA</h1>');
					
					HTP.P('<div id="conteudo">');	
                        MSG('bemvindo');
					HTP.P('</div>');
				    HTP.P('<div id="logo">');
				        HTP.P('<img src="dwu.fcl.download?arquivo=logo_smalticeram.png" />');
				    HTP.P('</div>');
				    HTP.P('<div id="login">');
						
							
							HTP.P('<input placeholder="SENHA" id="senha" type="number" pattern="[0-9]*" onkeypress="if(event.which == ''13''){ this.nextElementSibling.click(); }" onchange="document.getElementById(''erro'').setAttribute(''class'',''invisivel'');"/>');
						
						HTP.P('<a id="button-login" class="concluir" onclick="document.getElementById(''erro'').setAttribute(''class'',''invisivel''); x = document.getElementById(''senha'').value; if(x.length < 1){ document.getElementById(''erro'').setAttribute(''class'',''visivel''); } else { inject_html(''dwu.sac.avaliacao?prm_senha=''+x); document.getElementById(''login'').setAttribute(''class'',''invisivel''); }">Acessar</a>'); 
						HTP.P('<small id="erro" class="invisivel">Acesso negado, favor preencher o campo de senha!</small>');
					HTP.P('</div>');
				HTP.P('</div>');
				IF USER = 'DWU' THEN
				    HTP.P('<div id="edit-bar">');
					    HTP.P('<a id="exclusao" onclick="inject_edit(''dwu.sac.dlt'');">DELETE</a>');
					    HTP.P('<a id="cadastro" onclick="inject_edit(''dwu.sac.add'');">ADD</a>');
					    HTP.P('<div id="edit-form">');
					        SAC.ADD;
					    HTP.P('</div>');
					HTP.P('</div>');
				END IF;
				HTP.P('<p id="alerta" style="color: #CC0000; font-weight: bold; transition: opacity 0.2s linear; -webkit-transition: opacity 0.2s linear; opacity: 0; position: fixed; right: 0; bottom: 2px;"></p>');
			HTP.P('</body>');
		HTP.P('</html>');
	END MAIN;

	PROCEDURE AVALIACAO( PRM_SENHA VARCHAR2 ) AS
		
		CURSOR CRS_TURNOS IS 
		SELECT CD_PERFIL, DS_PERFIL 
		FROM SAC_PERFIL 
		WHERE TIPO = 'turno' AND ANO = TO_CHAR(SYSDATE, 'YYYY') 
		ORDER BY CD_PERFIL ASC;
		WS_TURNO CRS_TURNOS%ROWTYPE;

		CURSOR CRS_IDADES IS 
        SELECT CD_PERFIL, DS_PERFIL 
        FROM SAC_PERFIL 
        WHERE TIPO = 'idade'  AND ANO = TO_CHAR(SYSDATE, 'YYYY') 
        ORDER BY CD_PERFIL ASC;
		WS_IDADE CRS_IDADES%ROWTYPE;

		CURSOR CRS_ESCOLARIDADES IS 
        SELECT CD_PERFIL, DS_PERFIL
        FROM SAC_PERFIL 
        WHERE TIPO = 'escolaridade'  AND ANO = TO_CHAR(SYSDATE, 'YYYY') 
        ORDER BY CD_PERFIL ASC;
		WS_ESCOLARIDADE	CRS_ESCOLARIDADES%ROWTYPE;

		CURSOR CRS_TEMPO IS 
        SELECT CD_PERFIL, DS_PERFIL 
        FROM SAC_PERFIL 
        WHERE TIPO = 'tempo'  AND ANO = TO_CHAR(SYSDATE, 'YYYY') 
        ORDER BY CD_PERFIL ASC;
		WS_TEMPO CRS_TEMPO%ROWTYPE;


		
		CURSOR CRS_SETOR IS 
        SELECT CD_PERFIL, DS_PERFIL 
        FROM SAC_PERFIL
        WHERE TIPO = 'setor'  AND ANO = TO_CHAR(SYSDATE, 'YYYY') 
        ORDER BY CD_PERFIL ASC;
		WS_SETOR CRS_SETOR%ROWTYPE;

		CURSOR CRS_UNIDADE IS 
        SELECT CD_PERFIL, DS_PERFIL 
        FROM SAC_PERFIL 
        WHERE TIPO = 'unidade'  AND ANO = TO_CHAR(SYSDATE, 'YYYY') 
        ORDER BY CD_PERFIL ASC;
		WS_UNIDADE CRS_UNIDADE%ROWTYPE;
		
		CURSOR CRS_SEXO IS 
        SELECT CD_PERFIL, DS_PERFIL 
        FROM SAC_PERFIL 
        WHERE TIPO = 'sexo'  AND ANO = TO_CHAR(SYSDATE, 'YYYY') 
        ORDER BY CD_PERFIL ASC;
		WS_SEXO CRS_SEXO%ROWTYPE;

		CURSOR CRS_PERFIL IS
		SELECT CD_PERFIL, DS_PERFIL, TIPO
		FROM SAC_PERFIL WHERE ANO = TO_CHAR(SYSDATE, 'YYYY') 
		ORDER BY TIPO, CD_PERFIL ASC;
		WS_PERFIL CRS_PERFIL%ROWTYPE;
		
		CURSOR CRS_AVALIACOES IS 
		SELECT CD_AVALIACAO, CD_SENHA, CD_FUNCAO, CD_TURNO, CD_IDADE, CD_ESCOLARIDADE, CD_TEMPO, CD_SETOR, CD_UNIDADE, DT_AVALIACAO, IN_FECHA 
		FROM AVALIACAO
		WHERE ANO = TO_CHAR(SYSDATE, 'YYYY');
		WS_AVALIACAO CRS_AVALIACOES%ROWTYPE;
		
		CURSOR CRS_QUESTOES IS 
		SELECT CD_QUESTAO, DS_QUESTAO, CD_GRUPO, CD_FORMULARIO, NR_ORDEM 
		FROM QUESTAO_AVALIACAO 
		WHERE ANO = TO_CHAR(SYSDATE, 'YYYY')
		ORDER BY CD_GRUPO, NR_ORDEM;
		WS_QUESTAO	CRS_QUESTOES%ROWTYPE;
		
		CURSOR CRS_NOTAS IS 
		SELECT CD_AVALIACAO, CD_QUESTAO, VL_NOTA, VL_OBS 
		FROM NOTA
		WHERE ANO = TO_CHAR(SYSDATE, 'YYYY');
		WS_NOTA CRS_NOTAS%ROWTYPE;
		
		N_EXIST         INTEGER;
		EXIST_AVAL      INTEGER;
		EXIST_NOTA      NUMBER;
		EXIST_PERGUNTA  NUMBER;
		COUNT_QUESTAO   INTEGER;
		COUNT_COMPLETO  INTEGER;
		WS_SENHA        VARCHAR2(80);
		WS_PERFIL_GRUPO VARCHAR2(80);
		WS_COUNT        NUMBER;

	
	BEGIN
	
		SELECT COUNT(*) INTO N_EXIST FROM SENHA WHERE TRIM(PRM_SENHA) = TRIM(DS_SENHA) AND ANO = TO_CHAR(SYSDATE, 'YYYY');
		IF N_EXIST = 1 THEN
			
			SELECT DS_SENHA INTO WS_SENHA FROM SENHA WHERE TRIM(PRM_SENHA) = TRIM(DS_SENHA) AND ANO = TO_CHAR(SYSDATE, 'YYYY') AND ROWNUM = 1;
			SELECT COUNT(CD_SENHA) INTO EXIST_AVAL FROM AVALIACAO WHERE TRIM(PRM_SENHA) = TRIM(CD_SENHA) AND ANO = TO_CHAR(SYSDATE, 'YYYY');
			
			IF EXIST_AVAL = 0 THEN
				HTP.P('<div id="form_avaliacao">');
					

					























					










					










					HTP.P('<div class="linha">Tempo: <select id="tempo">');
						HTP.P('<option value="none" disabled selected hidden>Escolha o tempo de trabalho</option>');
						OPEN CRS_TEMPO;
							LOOP
								FETCH CRS_TEMPO INTO WS_TEMPO;
								EXIT WHEN CRS_TEMPO%NOTFOUND;
								HTP.P('<option value="'||WS_TEMPO.CD_PERFIL||'">'||WS_TEMPO.DS_PERFIL||'</option>');
							END LOOP;
						CLOSE CRS_TEMPO;
					HTP.P('</select></div>');

					










					HTP.P('<div class="linha">Escolaridade: <select id="escolaridade">');
						HTP.P('<option value="none" disabled selected hidden>Escolha a escolaridade</option>');
						OPEN CRS_ESCOLARIDADES;
							LOOP
								FETCH CRS_ESCOLARIDADES INTO WS_ESCOLARIDADE;
								EXIT WHEN CRS_ESCOLARIDADES%NOTFOUND;
								HTP.P('<option value="'||WS_ESCOLARIDADE.CD_PERFIL||'">'||WS_ESCOLARIDADE.DS_PERFIL||'</option>');
							END LOOP;
						CLOSE CRS_ESCOLARIDADES;
					HTP.P('</select></div>');

                    HTP.P('<div class="linha">Unidade: <select id="unidade">');
						HTP.P('<option value="none" disabled selected hidden>Escolha a unidade de neg�cio</option>');
						OPEN CRS_UNIDADE;
							LOOP
								FETCH CRS_UNIDADE INTO WS_UNIDADE;
								EXIT WHEN CRS_UNIDADE%NOTFOUND;
								HTP.P('<option value="'||WS_UNIDADE.CD_PERFIL||'">'||WS_UNIDADE.DS_PERFIL||'</option>');
							END LOOP;
						CLOSE CRS_UNIDADE;
					HTP.P('</select></div>');
					
					










                    




















					









					
					HTP.P('<div class="linha"><a class="concluir" onclick="var ok = 0; var tags = document.getElementById(''form_avaliacao'').getElementsByTagName(''select''); for(i=0;i<tags.length;i++){ if(tags[i].value != ''none''){ ok = ok+1; } } if(ok == 3){ inject_db(''dwu.sac.inserir_avaliacao?prm_senha='||WS_SENHA||'&funcao=&turno=&idade=''+tags[2].value+''&escolaridade=''+tags[1].value+''&tempo=''+tags[0].value+''&setor=&unidade=&sexo=''); inject_html(''dwu.sac.perguntas?prm_senha='||WS_SENHA||'''); document.getElementById(''form_avaliacao'').setAttribute(''class'',''invisivel''); } else { alerta(''alerta'', ''Favor preencher todos os campos!''); }">ENVIAR</a></div>');

							
				HTP.P('</div>');
					
			ELSE
				SELECT CD_AVALIACAO, CD_SENHA, CD_FUNCAO, CD_TURNO, CD_IDADE, CD_ESCOLARIDADE, CD_TEMPO, CD_SETOR, CD_UNIDADE, DT_AVALIACAO, IN_FECHA INTO WS_AVALIACAO FROM AVALIACAO WHERE TRIM(PRM_SENHA) = TRIM(CD_SENHA) AND ANO = TO_CHAR(SYSDATE, 'YYYY') AND ROWNUM = 1;
				SELECT COUNT(*) INTO EXIST_NOTA FROM NOTA WHERE TRIM(WS_AVALIACAO.CD_AVALIACAO) = TRIM(CD_AVALIACAO) AND ANO = TO_CHAR(SYSDATE, 'YYYY');
				SELECT COUNT(*) INTO EXIST_PERGUNTA FROM QUESTAO_AVALIACAO WHERE ANO = TO_CHAR(SYSDATE, 'YYYY');
				COUNT_QUESTAO := 0;
				IF (EXIST_PERGUNTA - EXIST_NOTA) <> 0 THEN
					IF EXIST_NOTA > 0 THEN
						HTP.P('<ul id="perguntas">');
							FOR I IN (SELECT CD_QUESTAO, DS_QUESTAO, CD_GRUPO, CD_FORMULARIO, NR_ORDEM, TIPO FROM QUESTAO_AVALIACAO WHERE TRIM(CD_QUESTAO) NOT IN (SELECT CD_QUESTAO FROM NOTA WHERE TRIM(CD_AVALIACAO) = TRIM(WS_AVALIACAO.CD_AVALIACAO) AND ANO = TO_CHAR(SYSDATE, 'YYYY')) AND ANO = TO_CHAR(SYSDATE, 'YYYY') ORDER BY NR_ORDEM) LOOP
								COUNT_QUESTAO := COUNT_QUESTAO+1;
								HTP.P('<li id="'||COUNT_QUESTAO||'">');
									HTP.P('<h2>'||COUNT_QUESTAO||' - '||I.DS_QUESTAO||'</h2>');
									IF I.TIPO = 'texto' THEN
										HTP.P('<textarea id="textarea-'||I.CD_QUESTAO||'" rows="5" cols="65" maxlength="4000" onkeyup="this.nextElementSibling.innerHTML = (''CARACTERES RESTANTES: ''+(4000-this.value.length));"></textarea>');
										HTP.P('<span>CARACTERES RESTANTES: 4000</span>');
										HTP.P('<a class="concluir" onclick="var x = document.getElementById(''textarea-'||I.CD_QUESTAO||''').value; inject_db(''dwu.sac.inserir_text?avaliacao='||WS_AVALIACAO.CD_AVALIACAO||'&pergunta='||I.CD_QUESTAO||'&nota=&obs=''+x); check_sac('''||WS_AVALIACAO.CD_AVALIACAO||''', '''||I.CD_QUESTAO||''', '''||COUNT_QUESTAO||''');">ENVIAR</a>');
									ELSIF I.TIPO = 'confirm' THEN
									    HTP.P('<select id="select-'||I.CD_QUESTAO||'">');
											HTP.P('<option value="SIM">SIM</option>');
											HTP.P('<option value="N&Atilde;O">N&Atilde;O</option>');
										HTP.P('</select>');
										HTP.P('<a class="concluir" onclick="var x = document.getElementById(''select-'||I.CD_QUESTAO||''').value; inject_db(''dwu.sac.inserir_text?avaliacao='||WS_AVALIACAO.CD_AVALIACAO||'&pergunta='||I.CD_QUESTAO||'&nota=&obs=''+x); check_sac('''||WS_AVALIACAO.CD_AVALIACAO||''', '''||I.CD_QUESTAO||''', '''||COUNT_QUESTAO||''');">ENVIAR</a>');
									ELSIF I.TIPO = 'opiniao' THEN
										HTP.P('<form id="form-'||I.CD_QUESTAO||'">');
											HTP.P('<input type="radio" name="nota" value="1" id="input1'||I.CD_QUESTAO||'" /><label for="input1'||I.CD_QUESTAO||'">Nunca/N&atilde;o</label>');
											HTP.P('<input type="radio" name="nota" value="2" id="input2'||I.CD_QUESTAO||'" /><label for="input2'||I.CD_QUESTAO||'">Quase nunca</label>');
											HTP.P('<input type="radio" name="nota" value="3" id="input3'||I.CD_QUESTAO||'" /><label for="input3'||I.CD_QUESTAO||'">As vezes</label>');
											HTP.P('<input type="radio" name="nota" value="4" id="input4'||I.CD_QUESTAO||'" /><label for="input4'||I.CD_QUESTAO||'">Quase sempre</label>');
											HTP.P('<input type="radio" name="nota" value="5" id="input5'||I.CD_QUESTAO||'" /><label for="input5'||I.CD_QUESTAO||'">Sempre/Sim</label>');
										HTP.P('</form>');
										HTP.P('<a class="concluir" onclick="var x = document.getElementById(''form-'||I.CD_QUESTAO||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){ if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||WS_AVALIACAO.CD_AVALIACAO||'&pergunta='||I.CD_QUESTAO||'&nota=''+z); check_sac('''||WS_AVALIACAO.CD_AVALIACAO||''', '''||I.CD_QUESTAO||''', '''||COUNT_QUESTAO||'''); }}">ENVIAR</a>');
									
									ELSE
										HTP.P('<form id="form-'||I.CD_QUESTAO||'">');
											HTP.P('<input type="radio" name="nota" value="0" id="input0'||I.CD_QUESTAO||'" /><label for="input0'||I.CD_QUESTAO||'">0</label>');
											HTP.P('<input type="radio" name="nota" value="1" id="input1'||I.CD_QUESTAO||'" /><label for="input1'||I.CD_QUESTAO||'">1</label>');
											HTP.P('<input type="radio" name="nota" value="2" id="input2'||I.CD_QUESTAO||'" /><label for="input2'||I.CD_QUESTAO||'">2</label>');
											HTP.P('<input type="radio" name="nota" value="3" id="input3'||I.CD_QUESTAO||'" /><label for="input3'||I.CD_QUESTAO||'">3</label>');
											HTP.P('<input type="radio" name="nota" value="4" id="input4'||I.CD_QUESTAO||'" /><label for="input4'||I.CD_QUESTAO||'">4</label>');
											HTP.P('<input type="radio" name="nota" value="5" id="input5'||I.CD_QUESTAO||'" /><label for="input5'||I.CD_QUESTAO||'">5</label>');
											HTP.P('<input type="radio" name="nota" value="6" id="input6'||I.CD_QUESTAO||'" /><label for="input6'||I.CD_QUESTAO||'">6</label>');
											HTP.P('<input type="radio" name="nota" value="7" id="input7'||I.CD_QUESTAO||'" /><label for="input7'||I.CD_QUESTAO||'">7</label>');
											HTP.P('<input type="radio" name="nota" value="8" id="input8'||I.CD_QUESTAO||'" /><label for="input8'||I.CD_QUESTAO||'">8</label>');
											HTP.P('<input type="radio" name="nota" value="9" id="input9'||I.CD_QUESTAO||'" /><label for="input9'||I.CD_QUESTAO||'">9</label>');
											HTP.P('<input type="radio" name="nota" value="10" id="input10'||I.CD_QUESTAO||'" /><label for="input10'||I.CD_QUESTAO||'">10</label>');
											HTP.P('<input type="radio" name="nota" value="99" id="inputna'||I.CD_QUESTAO||'" /><label for="inputna'||I.CD_QUESTAO||'">N/A</label>');
										HTP.P('</form>');
										HTP.P('<a class="concluir" onclick="var x = document.getElementById(''form-'||I.CD_QUESTAO||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){ if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||WS_AVALIACAO.CD_AVALIACAO||'&pergunta='||I.CD_QUESTAO||'&nota=''+z); check_sac('''||WS_AVALIACAO.CD_AVALIACAO||''', '''||I.CD_QUESTAO||''', '''||COUNT_QUESTAO||'''); }}">ENVIAR</a>');
									END IF;
								HTP.P('</li>');
							END LOOP;
						HTP.P('</ul>');
						HTP.P('<div id="completo" class="linha invisivel">Pesquisa conclu&iacute;da com sucesso!</div>');
					ELSE
						COUNT_QUESTAO  := 0;
						COUNT_COMPLETO := 0;
						HTP.P('<ul id="perguntas">');			
							FOR I IN (SELECT CD_QUESTAO, DS_QUESTAO, CD_GRUPO, CD_FORMULARIO, NR_ORDEM, TIPO FROM QUESTAO_AVALIACAO WHERE ANO = TO_CHAR(SYSDATE, 'YYYY') ORDER BY NR_ORDEM) LOOP
								COUNT_QUESTAO := COUNT_QUESTAO+1;
								HTP.P('<li id="'||COUNT_QUESTAO||'">');
									HTP.P('<h2>'||COUNT_QUESTAO||' - '||I.DS_QUESTAO||'</h2>');
									IF I.TIPO = 'texto' THEN
										HTP.P('<textarea id="textarea-'||I.CD_QUESTAO||'" rows="5" cols="65" maxlength="4000" onkeyup="this.nextElementSibling.innerHTML = (''CARACTERES RESTANTES: ''+(4000-this.value.length));"></textarea>');
										HTP.P('<span>CARACTERES RESTANTES: 4000</span>');
										HTP.P('<a class="concluir" onclick="var x = document.getElementById(''textarea-'||I.CD_QUESTAO||''').value; z = ''''; inject_db(''dwu.sac.inserir_text?avaliacao='||WS_AVALIACAO.CD_AVALIACAO||'&pergunta='||I.CD_QUESTAO||'&nota=''+z+''&obs=''+x); check_sac('''||WS_AVALIACAO.CD_AVALIACAO||''', '''||I.CD_QUESTAO||''', '''||COUNT_QUESTAO||''');">ENVIAR</a>');
									ELSIF I.TIPO = 'confirm' THEN
									    HTP.P('<select id="select-'||I.CD_QUESTAO||'">');
											HTP.P('<option value="SIM">SIM</option>');
											HTP.P('<option value="N&Atilde;O">N&Atilde;O</option>');
										HTP.P('</select>');
										HTP.P('<a class="concluir" onclick="var x = document.getElementById(''select-'||I.CD_QUESTAO||''').value; inject_db(''dwu.sac.inserir_text?avaliacao='||WS_AVALIACAO.CD_AVALIACAO||'&pergunta='||I.CD_QUESTAO||'&nota=&obs=''+x); check_sac('''||WS_AVALIACAO.CD_AVALIACAO||''', '''||I.CD_QUESTAO||''', '''||COUNT_QUESTAO||''');">ENVIAR</a>');
									ELSIF I.TIPO = 'opiniao' THEN
										HTP.P('<form id="form-'||I.CD_QUESTAO||'">');
											HTP.P('<input type="radio" name="nota" value="1" id="input1'||I.CD_QUESTAO||'" /><label for="input1'||I.CD_QUESTAO||'">Nunca/N&atilde;o</label>');
											HTP.P('<input type="radio" name="nota" value="2" id="input2'||I.CD_QUESTAO||'" /><label for="input2'||I.CD_QUESTAO||'">Quase nunca</label>');
											HTP.P('<input type="radio" name="nota" value="3" id="input3'||I.CD_QUESTAO||'" /><label for="input3'||I.CD_QUESTAO||'">As vezes</label>');
											HTP.P('<input type="radio" name="nota" value="4" id="input4'||I.CD_QUESTAO||'" /><label for="input4'||I.CD_QUESTAO||'">Quase sempre</label>');
											HTP.P('<input type="radio" name="nota" value="5" id="input5'||I.CD_QUESTAO||'" /><label for="input5'||I.CD_QUESTAO||'">Sempre/Sim</label>');
										HTP.P('</form>');
										HTP.P('<a class="concluir" onclick="var x = document.getElementById(''form-'||I.CD_QUESTAO||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){  if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||WS_AVALIACAO.CD_AVALIACAO||'&pergunta='||I.CD_QUESTAO||'&nota=''+z); check_sac('''||WS_AVALIACAO.CD_AVALIACAO||''', '''||I.CD_QUESTAO||''', '''||COUNT_QUESTAO||''');}}">ENVIAR</a>');
									ELSE
										HTP.P('<form id="form-'||I.CD_QUESTAO||'">');
											HTP.P('<input type="radio" name="nota" value="0" id="input0'||I.CD_QUESTAO||'" /><label for="input0'||I.CD_QUESTAO||'">0</label>');
											HTP.P('<input type="radio" name="nota" value="1" id="input1'||I.CD_QUESTAO||'" /><label for="input1'||I.CD_QUESTAO||'">1</label>');
											HTP.P('<input type="radio" name="nota" value="2" id="input2'||I.CD_QUESTAO||'" /><label for="input2'||I.CD_QUESTAO||'">2</label>');
											HTP.P('<input type="radio" name="nota" value="3" id="input3'||I.CD_QUESTAO||'" /><label for="input3'||I.CD_QUESTAO||'">3</label>');
											HTP.P('<input type="radio" name="nota" value="4" id="input4'||I.CD_QUESTAO||'" /><label for="input4'||I.CD_QUESTAO||'">4</label>');
											HTP.P('<input type="radio" name="nota" value="5" id="input5'||I.CD_QUESTAO||'" /><label for="input5'||I.CD_QUESTAO||'">5</label>');
											HTP.P('<input type="radio" name="nota" value="6" id="input6'||I.CD_QUESTAO||'" /><label for="input6'||I.CD_QUESTAO||'">6</label>');
											HTP.P('<input type="radio" name="nota" value="7" id="input7'||I.CD_QUESTAO||'" /><label for="input7'||I.CD_QUESTAO||'">7</label>');
											HTP.P('<input type="radio" name="nota" value="8" id="input8'||I.CD_QUESTAO||'" /><label for="input8'||I.CD_QUESTAO||'">8</label>');
											HTP.P('<input type="radio" name="nota" value="9" id="input9'||I.CD_QUESTAO||'" /><label for="input9'||I.CD_QUESTAO||'">9</label>');
											HTP.P('<input type="radio" name="nota" value="10" id="input10'||I.CD_QUESTAO||'" /><label for="input10'||I.CD_QUESTAO||'">10</label>');
											HTP.P('<input type="radio" name="nota" value="99" id="inputna'||I.CD_QUESTAO||'" /><label for="inputna'||I.CD_QUESTAO||'">N/A</label>');
										HTP.P('</form>');
										HTP.P('<a class="concluir" onclick=" x = document.getElementById(''form-'||I.CD_QUESTAO||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){  if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||WS_AVALIACAO.CD_AVALIACAO||'&pergunta='||I.CD_QUESTAO||'&nota=''+z); check_sac('''||WS_AVALIACAO.CD_AVALIACAO||''', '''||I.CD_QUESTAO||''', '''||COUNT_QUESTAO||''');}}">ENVIAR</a>');
									END IF;
								HTP.P('</li>');
							END LOOP;
						HTP.P('</ul>');
						HTP.P('<div id="completo" class="linha invisivel">Pesquisa conclu&iacute;da com sucesso!</div>');
					END IF;
				ELSE
				    HTP.P('<div id="completo" class="linha">Pesquisa j&aacute; foi conclu&iacute;da!</div>');
			    END IF;
			END IF;
		ELSE
			HTP.P('<div style="font-weight: bold;" class="linha">Login inexistente! <a onclick="this.parentNode.setAttribute(''class'',''invisivel''); document.getElementById(''login'').setAttribute(''class'',''visivel'');">Tentar novamente</a></div>');
			
			HTP.P('<div id="conteudo">');	
                MSG('bemvindo');
			HTP.P('</div>');
		    HTP.P('<div id="login" class="invisivel">');
					HTP.P('<span>Senha: </span><input id="senha" type="number" pattern="[0-9]*" inputmode="numeric" onkeypress="if(event.which == ''13''){ this.nextElementSibling.click(); }" />');
				HTP.P('<a class="acessar" onclick="document.getElementById(''erro'').setAttribute(''class'',''invisivel''); x = document.getElementById(''senha'').value; if(x.length < 1){ document.getElementById(''erro'').setAttribute(''class'',''visivel''); } else { inject_html(''dwu.sac.avaliacao?prm_senha=''+x); document.getElementById(''login'').setAttribute(''class'',''invisivel''); }">Acessar</a>'); 
				HTP.P('<small id="erro" class="invisivel">Acesso negado, favor preencher o campo de senha!</small>');
			HTP.P('</div>');
		END IF;
	
	END AVALIACAO;

	PROCEDURE MSG ( PRM_TIPO VARCHAR2 DEFAULT NULL ) AS 

        WS_CONTEUDO VARCHAR2(5000);

	BEGIN
		SELECT CONTEUDO INTO WS_CONTEUDO FROM SAC_MSG WHERE DS_TIPO = PRM_TIPO;
		HTP.P(WS_CONTEUDO);

	END MSG;
	
	PROCEDURE PERGUNTAS( PRM_SENHA VARCHAR2 ) AS
		
		CURSOR CRS_PERGUNTAS IS 
		SELECT CD_QUESTAO, DS_QUESTAO, CD_GRUPO, CD_FORMULARIO, NR_ORDEM 
		FROM QUESTAO_AVALIACAO
        WHERE ANO = TO_CHAR(SYSDATE, 'YYYY')		
		ORDER BY NR_ORDEM;
		WS_QUESTAO	CRS_PERGUNTAS%ROWTYPE;
		
		CURSOR CRS_AVALIACOES IS 
		SELECT CD_AVALIACAO, CD_SENHA, CD_FUNCAO, CD_TURNO, CD_IDADE, CD_ESCOLARIDADE, CD_TEMPO, CD_SETOR, CD_UNIDADE, DT_AVALIACAO, IN_FECHA, ANO, CD_SEXO
		FROM AVALIACAO
		WHERE ANO = TO_CHAR(SYSDATE, 'YYYY');
		WS_AVALIACAO CRS_AVALIACOES%ROWTYPE;
		
		N_EXIST         INTEGER;
		COUNT_QUESTAO   INTEGER;
		COUNT_COMPLETO  INTEGER;
		COUNT_AVALIACAO INTEGER;
	
	BEGIN
	
		SELECT COUNT(DS_SENHA) INTO N_EXIST FROM SENHA WHERE TRIM(PRM_SENHA) = TRIM(DS_SENHA) AND ANO = TO_CHAR(SYSDATE, 'YYYY');
		IF N_EXIST = 1 THEN
		    SELECT COUNT(CD_AVALIACAO) INTO COUNT_AVALIACAO FROM AVALIACAO WHERE TRIM(PRM_SENHA) = TRIM(CD_SENHA) AND ANO = TO_CHAR(SYSDATE, 'YYYY');
			IF(COUNT_AVALIACAO = 1) THEN
				SELECT * INTO WS_AVALIACAO FROM AVALIACAO WHERE TRIM(PRM_SENHA) = TRIM(CD_SENHA) AND ANO = TO_CHAR(SYSDATE, 'YYYY');
				COUNT_QUESTAO := 0;
				HTP.P('<ul id="perguntas">');			
					FOR WS_QUESTAO IN (SELECT CD_QUESTAO, DS_QUESTAO, CD_GRUPO, NR_ORDEM, TIPO FROM QUESTAO_AVALIACAO WHERE ANO = TO_CHAR(SYSDATE, 'YYYY') ORDER BY NR_ORDEM) LOOP
						COUNT_QUESTAO := COUNT_QUESTAO+1;
						HTP.P('<li id="'||COUNT_QUESTAO||'">');
							HTP.P('<h2>'||COUNT_QUESTAO||' - '||WS_QUESTAO.DS_QUESTAO||'</h2>');
							IF WS_QUESTAO.TIPO = 'texto' THEN
								HTP.P('<textarea id="textarea-'||WS_QUESTAO.CD_QUESTAO||'" rows="5" cols="65" maxlength="4000" onkeyup="this.nextElementSibling.innerHTML = (''CARACTERES RESTANTES: ''+(4000-this.value.length));"></textarea>');
								HTP.P('<span>CARACTERES RESTANTES: 4000</span>');
								HTP.P('<a class="concluir" onclick="var x = document.getElementById(''textarea-'||WS_QUESTAO.CD_QUESTAO||''').value; z = ''''; inject_db(''dwu.sac.inserir_text?avaliacao='||WS_AVALIACAO.CD_AVALIACAO||'&pergunta='||WS_QUESTAO.CD_QUESTAO||'&nota=''+z+''&obs=''+x); check_sac('''||WS_AVALIACAO.CD_AVALIACAO||''', '''||WS_QUESTAO.CD_QUESTAO||''', '''||COUNT_QUESTAO||''');">ENVIAR</a>');
							ELSIF WS_QUESTAO.TIPO = 'confirm' THEN
							    HTP.P('<select id="select-'||WS_QUESTAO.CD_QUESTAO||'">');
									HTP.P('<option value="SIM">SIM</option>');
									HTP.P('<option value="N&Atilde;O">N&Atilde;O</option>');
								HTP.P('</select>');
								HTP.P('<a class="concluir" onclick="var x = document.getElementById(''select-'||WS_QUESTAO.CD_QUESTAO||''').value; inject_db(''dwu.sac.inserir_text?avaliacao='||WS_AVALIACAO.CD_AVALIACAO||'&pergunta='||WS_QUESTAO.CD_QUESTAO||'&nota=&obs=''+x); check_sac('''||WS_AVALIACAO.CD_AVALIACAO||''', '''||WS_QUESTAO.CD_QUESTAO||''', '''||COUNT_QUESTAO||''');">ENVIAR</a>');
							ELSIF WS_QUESTAO.TIPO = 'opiniao' THEN
								HTP.P('<form id="form-'||WS_QUESTAO.CD_QUESTAO||'">');
									HTP.P('<input type="radio" name="nota" value="1" id="input1'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input1'||WS_QUESTAO.CD_QUESTAO||'">Nunca/N&atilde;o</label>');
									HTP.P('<input type="radio" name="nota" value="2" id="input2'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input2'||WS_QUESTAO.CD_QUESTAO||'">Quase nunca</label>');
									HTP.P('<input type="radio" name="nota" value="3" id="input3'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input3'||WS_QUESTAO.CD_QUESTAO||'">As vezes</label>');
									HTP.P('<input type="radio" name="nota" value="4" id="input4'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input4'||WS_QUESTAO.CD_QUESTAO||'">Quase sempre</label>');
									HTP.P('<input type="radio" name="nota" value="5" id="input5'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input5'||WS_QUESTAO.CD_QUESTAO||'">Sempre/Sim</label>');
								HTP.P('</form>');
								HTP.P('<a class="concluir" onclick=" x = document.getElementById(''form-'||WS_QUESTAO.CD_QUESTAO||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){ if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||WS_AVALIACAO.CD_AVALIACAO||'&pergunta='||WS_QUESTAO.CD_QUESTAO||'&nota=''+z); check_sac('''||WS_AVALIACAO.CD_AVALIACAO||''', '''||WS_QUESTAO.CD_QUESTAO||''', '''||COUNT_QUESTAO||'''); }}">ENVIAR</a>');
							ELSE
								HTP.P('<form id="form-'||WS_QUESTAO.CD_QUESTAO||'">');
									HTP.P('<input type="radio" name="nota" value="0" id="input0'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input0'||WS_QUESTAO.CD_QUESTAO||'">0</label>');
									HTP.P('<input type="radio" name="nota" value="1" id="input1'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input1'||WS_QUESTAO.CD_QUESTAO||'">1</label>');
									HTP.P('<input type="radio" name="nota" value="2" id="input2'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input2'||WS_QUESTAO.CD_QUESTAO||'">2</label>');
									HTP.P('<input type="radio" name="nota" value="3" id="input3'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input3'||WS_QUESTAO.CD_QUESTAO||'">3</label>');
									HTP.P('<input type="radio" name="nota" value="4" id="input4'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input4'||WS_QUESTAO.CD_QUESTAO||'">4</label>');
									HTP.P('<input type="radio" name="nota" value="5" id="input5'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input5'||WS_QUESTAO.CD_QUESTAO||'">5</label>');
									HTP.P('<input type="radio" name="nota" value="6" id="input6'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input6'||WS_QUESTAO.CD_QUESTAO||'">6</label>');
									HTP.P('<input type="radio" name="nota" value="7" id="input7'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input7'||WS_QUESTAO.CD_QUESTAO||'">7</label>');
									HTP.P('<input type="radio" name="nota" value="8" id="input8'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input8'||WS_QUESTAO.CD_QUESTAO||'">8</label>');
									HTP.P('<input type="radio" name="nota" value="9" id="input9'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input9'||WS_QUESTAO.CD_QUESTAO||'">9</label>');
									HTP.P('<input type="radio" name="nota" value="10" id="input10'||WS_QUESTAO.CD_QUESTAO||'" /><label for="input10'||WS_QUESTAO.CD_QUESTAO||'">10</label>');
									HTP.P('<input type="radio" name="nota" value="99" id="inputna'||WS_QUESTAO.CD_QUESTAO||'" /><label for="inputna'||WS_QUESTAO.CD_QUESTAO||'">N/A</label>');
								HTP.P('</form>');
								HTP.P('<a class="concluir" onclick=" x = document.getElementById(''form-'||WS_QUESTAO.CD_QUESTAO||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){ if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||WS_AVALIACAO.CD_AVALIACAO||'&pergunta='||WS_QUESTAO.CD_QUESTAO||'&nota=''+z); check_sac('''||WS_AVALIACAO.CD_AVALIACAO||''', '''||WS_QUESTAO.CD_QUESTAO||''', '''||COUNT_QUESTAO||'''); }}">ENVIAR</a>');
							END IF;
						HTP.P('</li>');
					END LOOP;
				HTP.P('</ul>');
				HTP.P('<div id="completo" class="linha invisivel">Pesquisa conclu&iacute;da com sucesso!</div>');
				HTP.P('<input id="soma" class="invisivel" value="0" />');
			ELSE
                    --FCL.JMSG('Usu&aacute;rio n&atilde;o encontrado, favor recarregar a p&aacute;gina!');
					HTP.P(SQLERRM);
			END IF;
		END IF;
	
	END PERGUNTAS;
	
	PROCEDURE INSERIR_AVALIACAO( PRM_SENHA VARCHAR2,
					  			 FUNCAO NUMBER DEFAULT 0,
								 TURNO NUMBER DEFAULT 0,
								 IDADE  NUMBER DEFAULT 0,
					  			 ESCOLARIDADE NUMBER DEFAULT 0, 
				      			 TEMPO NUMBER DEFAULT 0,
								 SETOR NUMBER DEFAULT 0,
								 UNIDADE NUMBER DEFAULT 0,
								 SEXO NUMBER DEFAULT 0 ) AS
		
		VL_AVALIACAO NUMBER;
		COUNT_AVAL NUMBER;
		WS_COUNT NUMBER;
		
		
		BEGIN
		
		
		    
			SELECT COUNT(*) INTO WS_COUNT FROM AVALIACAO WHERE CD_SENHA = PRM_SENHA AND ANO = TO_CHAR(SYSDATE, 'YYYY');
			
			IF WS_COUNT = 0 THEN
			
				SELECT NVL(COUNT(CD_AVALIACAO), 0) INTO COUNT_AVAL FROM AVALIACAO WHERE ANO = TO_CHAR(SYSDATE, 'YYYY');
				IF(COUNT_AVAL = 0) THEN
					INSERT INTO AVALIACAO (CD_AVALIACAO, CD_SENHA, CD_FUNCAO, CD_TURNO, CD_IDADE, CD_ESCOLARIDADE, CD_TEMPO, CD_SETOR, CD_UNIDADE, DT_AVALIACAO, IN_FECHA, ANO, CD_SEXO) VALUES (1, PRM_SENHA, FUNCAO, TURNO, IDADE, ESCOLARIDADE, TEMPO, SETOR, UNIDADE, SYSDATE, 0, TO_CHAR(SYSDATE, 'YYYY'), SEXO);
				ELSE
					SELECT MAX(CD_AVALIACAO) INTO VL_AVALIACAO FROM AVALIACAO WHERE ANO = TO_CHAR(SYSDATE, 'YYYY');
					VL_AVALIACAO := VL_AVALIACAO+1;
					BEGIN
						 INSERT INTO AVALIACAO (CD_AVALIACAO, CD_SENHA, CD_FUNCAO, CD_TURNO, CD_IDADE, CD_ESCOLARIDADE, CD_TEMPO, CD_SETOR, CD_UNIDADE, DT_AVALIACAO, IN_FECHA, ANO, CD_SEXO) VALUES (VL_AVALIACAO, PRM_SENHA, FUNCAO, TURNO, IDADE, ESCOLARIDADE, TEMPO, SETOR, UNIDADE, SYSDATE, 0, TO_CHAR(SYSDATE, 'YYYY'), SEXO);
					EXCEPTION
						 WHEN OTHERS THEN
							--FCL.JMSG('Erro ao inserir avalia&ccedil;&atilde;o(incrementar)');
							HTP.P(SQLERRM);
					END;   
				END IF;
				COMMIT;
			END IF;
	EXCEPTION
	    WHEN OTHERS THEN
		    --FCL.JMSG('Erro ao inserir avalia&ccedil;&atilde;o');
			HTP.P(SQLERRM);
	END INSERIR_AVALIACAO;
	
	PROCEDURE INSERIR( AVALIACAO INTEGER DEFAULT NULL,
		               PERGUNTA INTEGER,
		               NOTA INTEGER ) AS
		
	COD NUMBER;
	WS_COUNT NUMBER;
	WS_DOUBLE EXCEPTION;
	BEGIN
		
		SELECT COUNT(*) INTO WS_COUNT FROM NOTA WHERE CD_AVALIACAO = AVALIACAO AND CD_QUESTAO = PERGUNTA AND ANO = TO_CHAR(SYSDATE, 'YYYY');
		IF WS_COUNT = 0 THEN
		    SELECT COUNT(*)+1 INTO COD FROM NOTA;
		    INSERT INTO NOTA (CD_NOTA, CD_AVALIACAO, CD_QUESTAO, VL_NOTA, VL_OBS, ANO) VALUES (COD, AVALIACAO, PERGUNTA, NOTA, '', TO_CHAR(SYSDATE, 'YYYY'));
	        COMMIT;
			HTP.P('OK');
		ELSE
		    RAISE WS_DOUBLE;
		END IF;
	EXCEPTION
	    WHEN WS_DOUBLE THEN
	        HTP.P('J&aacute; existe!');
	    WHEN OTHERS THEN
	        ROLLBACK;
		    HTP.P('Erro ao enviar!');
	END INSERIR;
	
	PROCEDURE CHECK_NOTA ( PRM_AVALIACAO INTEGER,
                           PRM_QUESTAO INTEGER ) AS
						   
	WS_COUNT NUMBER;
	BEGIN
	
	    SELECT COUNT(*) INTO WS_COUNT FROM NOTA WHERE CD_QUESTAO = PRM_QUESTAO AND CD_AVALIACAO = PRM_AVALIACAO AND ANO = TO_CHAR(SYSDATE, 'YYYY');
	    HTP.P(WS_COUNT);
	END CHECK_NOTA;
	
	PROCEDURE INSERIR_TEXT( AVALIACAO INTEGER DEFAULT NULL,
			                PERGUNTA INTEGER,
			                NOTA INTEGER,
			                OBS VARCHAR2 DEFAULT NULL) AS
	COD NUMBER;
	WS_COUNT NUMBER;
	WS_DOUBLE EXCEPTION;
	BEGIN	
	    
		SELECT COUNT(*) INTO WS_COUNT FROM NOTA WHERE CD_AVALIACAO = AVALIACAO AND CD_QUESTAO = PERGUNTA AND ANO = TO_CHAR(SYSDATE, 'YYYY');
		IF WS_COUNT = 0 THEN
		   
			SELECT COUNT(*)+1 INTO COD FROM NOTA;
		    INSERT INTO NOTA VALUES (COD, AVALIACAO, PERGUNTA, '', OBS, TO_CHAR(SYSDATE, 'YYYY'));
		    COMMIT;
		ELSE
		    RAISE WS_DOUBLE;
		END IF;
	EXCEPTION
	WHEN WS_DOUBLE THEN
	    HTP.P('J� existe!');
	WHEN OTHERS THEN
	    ROLLBACK;
		HTP.P(SQLERRM);
	END INSERIR_TEXT;
	
	PROCEDURE FECHAR(AVALIACAO INTEGER) AS
		BEGIN
			UPDATE AVALIACAO SET IN_FECHA = '1' WHERE CD_AVALIACAO = AVALIACAO AND ANO = TO_CHAR(SYSDATE, 'YYYY');
		EXCEPTION
			WHEN OTHERS THEN
				--FCL.JMSG('Erro ao fechar a avalia&ccedil;&atilde;o');
				HTP.P(SQLERRM);
		END FECHAR;
		
	PROCEDURE ADD AS
	    
		CURSOR CRS_GRUPOS IS 
		SELECT CD_PERFIL, DS_PERFIL
		FROM SAC_PERFIL WHERE TIPO = 'grupo' AND ANO = TO_CHAR(SYSDATE, 'YYYY')
		ORDER BY DS_PERFIL ASC;
		
		WS_GRUPO CRS_GRUPOS%ROWTYPE;
		
	    BEGIN
		    HTP.P('<h2 style="font-weight: bold; margin: 5px 0;">CADASTRO DE PERGUNTAS</h2>');
			HTP.P('<form>');
			    HTP.P('<input type="text" value="" placeholder="inserir pergunta" id="pergunta"/>');
				HTP.P('<label style="margin: 0 0 0 5px;">Grupo: </label>');
				HTP.P('<select style="margin: 0 5px 0 0;" id="grupo" value="">');
					OPEN CRS_GRUPOS;
                        LOOP
                            FETCH CRS_GRUPOS INTO WS_GRUPO;
                            EXIT WHEN CRS_GRUPOS%NOTFOUND;
                            HTP.P('<option value="'||WS_GRUPO.CD_PERFIL||'">'||WS_GRUPO.DS_PERFIL||'</option>');
                        END LOOP;
                    CLOSE CRS_GRUPOS;							
				HTP.P('</select>');
				HTP.P('<label style="margin: 0 0 0 5px;">Tipo: </label>');
				HTP.P('<select style="margin: 0 5px 0 0;" id="tipo" value="">');
                    HTP.P('<option value="nota">Nota</option>');	
                    HTP.P('<option value="texto">Texto</option>');
                    HTP.P('<option value="confirm">Confirma&ccedil;&atilde;o</option>');
                    HTP.P('<option value="opiniao">Opini&atilde;o</option>');					
				HTP.P('</select>');
			    HTP.P('<a class="link" onclick="var pergunta = document.getElementById(''pergunta'').value; var grupo = document.getElementById(''grupo'').value; var tipo = document.getElementById(''tipo'').value; insert_question(''dwu.sac.add_pergunta'', ''prm_pergunta=''+pergunta+''&prm_grupo=''+grupo+''&prm_tipo=''+tipo);">enviar</a>');
		    HTP.P('</form>');
			
			











	    END ADD;
		
	PROCEDURE ADD_PERGUNTA ( PRM_PERGUNTA VARCHAR2 DEFAULT NULL,
                             PRM_GRUPO    VARCHAR2 DEFAULT NULL,
							 PRM_TIPO     CHAR DEFAULT '1' ) AS
		
        WS_COUNT NUMBER;
        WS_SEQUENCE  NUMBER;		
		
	BEGIN
		
		BEGIN
			SELECT COUNT(*)+1 INTO WS_SEQUENCE FROM QUESTAO_AVALIACAO WHERE ANO = TO_CHAR(SYSDATE, 'YYYY');
			SELECT COUNT(*) INTO WS_COUNT FROM QUESTAO_AVALIACAO WHERE TRIM(DS_QUESTAO) = TRIM(PRM_PERGUNTA) AND ANO = TO_CHAR(SYSDATE, 'YYYY');
				IF(WS_COUNT > 0) THEN
					HTP.P('!DUPLICADO');
				ELSE
					INSERT INTO QUESTAO_AVALIACAO (CD_QUESTAO, DS_QUESTAO, CD_GRUPO, CD_FORMULARIO, NR_ORDEM, TIPO, ANO) VALUES(WS_SEQUENCE, TRIM(PRM_PERGUNTA), TRIM(PRM_GRUPO), '5', WS_SEQUENCE, PRM_TIPO, TO_CHAR(SYSDATE, 'YYYY'));
					HTP.P('!ADD');
				END IF;
		EXCEPTION WHEN OTHERS THEN
			HTP.P('!ERRO');
		END;
	END ADD_PERGUNTA;
		
	PROCEDURE ADD_CADASTRO ( PRM_VALOR VARCHAR2 DEFAULT NULL,
							 PRM_TIPO  CHAR DEFAULT '1' ) AS	

	WS_COUNT NUMBER;								 
	
	BEGIN
		IF PRM_TIPO = 'escolaridade' THEN
			BEGIN
				SELECT COUNT(*) INTO WS_COUNT FROM SAC_PERFIL WHERE TRIM(DS_PERFIL) = TRIM(PRM_VALOR) AND TIPO = 'escolaridade' AND ANO = TO_CHAR(SYSDATE, 'YYYY');
				IF WS_COUNT > 0 THEN
					HTP.P('!DUPLICADO');
				ELSE
					INSERT INTO SAC_PERFIL (CD_PERFIL, DS_PERFIL, TIPO, ANO) VALUES((SELECT MAX(CD_PERFIL) FROM SAC_PERFIL WHERE TIPO = 'escolaridade')+1, PRM_VALOR, 'escolaridade', TO_CHAR(SYSDATE, 'YYYY'));
					HTP.P('!ADD');
				END IF;
			EXCEPTION WHEN OTHERS THEN
				HTP.P('!ERRO');
			END;
		ELSE
			BEGIN
				SELECT COUNT(*) INTO WS_COUNT FROM SAC_PERFIL WHERE TRIM(DS_PERFIL) = TRIM(PRM_VALOR) AND TIPO = 'setor' AND ANO = TO_CHAR(SYSDATE, 'YYYY');
				IF WS_COUNT > 0 THEN
					HTP.P('!DUPLICADO');
				ELSE
					INSERT INTO SAC_PERFIL (CD_PERFIL, DS_PERFIL, TIPO, ANO) VALUES((SELECT MAX(CD_PERFIL) FROM SAC_PERFIL WHERE TIPO = 'setor')+1, PRM_VALOR, 'setor', TO_CHAR(SYSDATE, 'YYYY'));
					HTP.P('!ADD');
				END IF;
			EXCEPTION WHEN OTHERS THEN
				HTP.P('!ERRO');
			END;
		END IF;
		
	END ADD_CADASTRO;
		

	PROCEDURE DLT AS
	
	CURSOR CRS_PERGUNTAS IS 
	SELECT DS_QUESTAO, CD_QUESTAO
	FROM QUESTAO_AVALIACAO WHERE
	ANO = TO_CHAR(SYSDATE, 'YYYY')
	ORDER BY DS_QUESTAO ASC;
	
	WS_PERGUNTA CRS_PERGUNTAS%ROWTYPE;
	
	














	
	BEGIN
		HTP.P('<h2 style="font-weight: bold; margin: 5px 0;">EXCLUS&Atilde;O DE PERGUNTAS</h2>');
		HTP.P('<select id="pergunta-dlt">');
		OPEN CRS_PERGUNTAS;
			LOOP
				FETCH CRS_PERGUNTAS INTO WS_PERGUNTA;
				EXIT WHEN CRS_PERGUNTAS%NOTFOUND;
				HTP.P('<option value="'||WS_PERGUNTA.CD_QUESTAO||'">'||WS_PERGUNTA.DS_QUESTAO||'</option>');
			END LOOP;
		CLOSE CRS_PERGUNTAS;
		HTP.P('</select>');
		HTP.P('<a class="link" onclick="insert_question(''dwu.sac.dlt_cadastro'', ''prm_valor=''+document.getElementById(''pergunta-dlt'').value+''&prm_tipo=perguntas'');">Excluir</a>');

		
		
























		HTP.P('<p id="alerta" style="color: #CC0000; font-weight: bold; transition: opacity 0.2s linear; -webkit-transition: opacity 0.2s linear; opacity: 0;"></p>');
	END DLT;
		
	PROCEDURE DLT_CADASTRO ( PRM_VALOR VARCHAR2 DEFAULT NULL,
							 PRM_TIPO CHAR DEFAULT '1' ) AS	

	WS_COUNT NUMBER;								 
	
	BEGIN
		IF(PRM_TIPO = 'escolaridade') THEN
			BEGIN
				SELECT COUNT(*) INTO WS_COUNT FROM SAC_PERFIL WHERE TRIM(CD_PERFIL) = TRIM(PRM_VALOR) AND TIPO = 'escolaridade' AND ANO = TO_CHAR(SYSDATE, 'YYYY');
				IF(WS_COUNT > 1) THEN
					HTP.P('!DUPLICADO');
				ELSE
					DELETE FROM SAC_PERFIL WHERE CD_PERFIL = PRM_VALOR AND TIPO = 'escolaridade' AND ANO = TO_CHAR(SYSDATE, 'YYYY');
					HTP.P('!DLT');
				END IF;
			EXCEPTION WHEN OTHERS THEN
				HTP.P('!ERRO');
			END;
		ELSIF(PRM_TIPO = 'setor') THEN
			BEGIN
				SELECT COUNT(*) INTO WS_COUNT FROM SAC_PERFIL WHERE TRIM(CD_PERFIL) = TRIM(PRM_VALOR) AND TIPO = 'setor' AND ANO = TO_CHAR(SYSDATE, 'YYYY');
				IF(WS_COUNT > 1) THEN
					HTP.P('!DUPLICADO');
				ELSE
					DELETE FROM SAC_PERFIL WHERE CD_PERFIL = PRM_VALOR AND TIPO = 'setor' AND ANO = TO_CHAR(SYSDATE, 'YYYY');
					HTP.P('!DLT');
				END IF;
			EXCEPTION WHEN OTHERS THEN
				HTP.P('!ERRO');
			END;
		ELSE
			BEGIN
				SELECT COUNT(*) INTO WS_COUNT FROM QUESTAO_AVALIACAO WHERE TRIM(CD_QUESTAO) = TRIM(PRM_VALOR) AND ANO = TO_CHAR(SYSDATE, 'YYYY');
				IF(WS_COUNT > 1) THEN
					HTP.P('!DUPLICADO');
				ELSE
					DELETE FROM QUESTAO_AVALIACAO WHERE CD_QUESTAO = PRM_VALOR AND ANO = TO_CHAR(SYSDATE, 'YYYY');
					HTP.P('!DLT');
				END IF;
			EXCEPTION WHEN OTHERS THEN
				HTP.P('!ERRO');
			END;
		
		END IF;
		
	END DLT_CADASTRO;
	
END SAC;