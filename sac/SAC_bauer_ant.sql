create or replace package body Sac is

	procedure main as
	
		ws_count number;

		begin
		fcl.refresh_Session;
		htp.p('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
		htp.p('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">');
			htp.headOpen;
				htp.p('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
				htp.p('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
				htp.p('<TITLE>AVALIACAO DE CLIMA</TITLE>');
				htp.p('<META HTTP-EQUIV="Pragma" CONTENT="no-cache, no-store, must-revalidate">');
				htp.p('<META HTTP-EQUIV="Expires" CONTENT="0">');
				htp.p('<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">');
				htp.p('<meta name="apple-mobile-web-app-capable" content="yes" />');
				htp.p('<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">');
				htp.p('<link rel="favicon" href="'||fun.r_gif('upquery-icon','PNG')||'" />');
				htp.p('<link rel="shortcut icon" href="'||fun.r_gif('upquery-icon','PNG')||'" />');
				htp.p('<link rel="apple-touch-startup-image" href="'||fun.r_gif('upquery-icon','PNG')||'">');
				htp.p('<meta name="apple-mobile-web-app-status-bar-style" content="black">');
                htp.p('<link href="https://fonts.googleapis.com/css?family=Montserrat" rel="stylesheet" type="text/css">');
				fcl.keywords;
				htp.p('<script src="dwu.fcl.download?arquivo=sac.js"></script>');
				htp.p('<link rel="stylesheet" href="dwu.fcl.download?arquivo=sac08112017.css">');
				htp.p('<link rel="stylesheet" href="dwu.fcl.download?arquivo=default.css">');
				--ver 1.3
			htp.headClose;
			htp.p('<body>');
			    htp.p('<div id="background"></div>');
				htp.p('<div id="avaliacao">');
					htp.p('<h1>AVALIACAO DE CLIMA</h1>');

					htp.p('<div id="conteudo"><div style="font-style: italic; font-weight: bold; font-size: 24px; line-height: 32px; margin: 20px; color: #333;"><p style="margin-bottom: 20px;">Bem Vindo!</p><p>Sua Opiniao e muito Importante!</p><p>A pesquisa de clima e uma oportunidade para voce expressar sua opiniao e sua satisfacao em relacao ao meio de trabalho e a empresa.</p><p style="margin-top: 20px;">Obrigado pela sua participacao!</p></div></div>');	
				    htp.p('<div id="logo">');
				        htp.p('<img src="dwu.fcl.download?arquivo=bauer_logo.jpg" />');
				    htp.p('</div>');
				    htp.p('<div id="login">');
						--htp.p('<form autocomplete="on" onSubmit="document.getElementById(''erro'').setAttribute(''class'',''invisivel''); x = document.getElementById(''senha'').value; if(x.length < 1){ document.getElementById(''erro'').setAttribute(''class'',''visivel''); } else { inject_html(''dwu.sac.avaliacao?prm_senha=''+x); document.getElementById(''login'').setAttribute(''class'',''invisivel''); } return false;">');
							--htp.p('<span>Senha: </span>');
							htp.p('<input placeholder="SENHA" id="senha" type="number" pattern="[0-9]*" onkeypress="if(event.which == ''13''){ this.nextElementSibling.click(); }" onchange="document.getElementById(''erro'').setAttribute(''class'',''invisivel'');"/>');
						--htp.p('</form>');
						htp.p('<a id="button-login" class="concluir" onclick="document.getElementById(''erro'').setAttribute(''class'',''invisivel''); x = document.getElementById(''senha'').value; if(x.length < 1){ document.getElementById(''erro'').setAttribute(''class'',''visivel''); } else { inject_html(''dwu.sac.avaliacao?prm_senha=''+x); document.getElementById(''login'').setAttribute(''class'',''invisivel''); }">Acessar</a>'); 
						htp.p('<small id="erro" class="invisivel">Acesso negado, favor preencher o campo de senha!</small>');
					htp.p('</div>');
				htp.p('</div>');
				if user = 'DWU' then
				    htp.p('<div id="edit-bar">');
					    htp.p('<a id="exclusao" onclick="inject_edit(''dwu.sac.dlt'');">DELETE</a>');
					    htp.p('<a id="cadastro" onclick="inject_edit(''dwu.sac.add'');">ADD</a>');
					    htp.p('<div id="edit-form">');
					        sac.add;
					    htp.p('</div>');
					htp.p('</div>');
				end if;
				htp.p('<p id="alerta" style="color: #CC0000; font-weight: bold; transition: opacity 0.2s linear; -webkit-transition: opacity 0.2s linear; opacity: 0; position: fixed; right: 0; bottom: 2px;"></p>');
			
            --htp.p('<div id="completo" class="linha invisivel">Pesquisa concluida!</div>');
            htp.p('</body>');
		htp.p('</html>');
	end main;

	procedure avaliacao( prm_senha varchar2 ) as

		/*cursor crs_funcoes is select cd_perfil, ds_perfil from sac_perfil where tipo = 'cargo' order by ds_perfil asc;
		ws_funcao crs_funcoes%rowtype;*/

		cursor crs_turnos is select cd_perfil, ds_perfil from sac_perfil where tipo = 'turno' order by ds_perfil asc;
		ws_turno crs_turnos%rowtype;

		/*cursor crs_idades is select cd_perfil, ds_perfil from sac_perfil where tipo = 'idade' order by ds_perfil asc;
		ws_idade crs_idades%rowtype;*/

		/*cursor crs_escolaridades is select cd_perfil, ds_perfil from sac_perfil where tipo = 'escolaridade' order by ds_perfil asc;
		ws_escolaridade	crs_escolaridades%rowtype;

		cursor crs_tempo is select cd_perfil, ds_perfil from sac_perfil where tipo = 'tempo' order by ds_perfil asc;
		ws_tempo crs_tempo%rowtype;


		--novos
		cursor crs_setor is select cd_perfil, ds_perfil from sac_perfil where tipo = 'setor' order by ds_perfil asc;
		ws_setor crs_setor%rowtype;*/

		/*cursor crs_unidade is select cd_perfil, ds_perfil from sac_perfil where tipo = 'unidade' order by ds_perfil asc;
		ws_unidade crs_unidade%rowtype;*/



		cursor crs_avaliacoes is select cd_avaliacao, cd_senha, cd_funcao, cd_turno, cd_idade, cd_escolaridade, cd_tempo, cd_setor, cd_unidade, dt_avaliacao, in_fecha from AVALIACAO;
		ws_avaliacao crs_avaliacoes%rowtype;

		cursor crs_questoes is select cd_questao, ds_questao, cd_grupo, cd_formulario, nr_ordem from QUESTAO_AVALIACAO order by cd_grupo, nr_ordem;
		ws_questao	crs_questoes%rowtype;

		cursor crs_notas is select cd_avaliacao, cd_questao, vl_nota, vl_obs from NOTA;
		ws_nota crs_notas%rowtype;

		n_exist integer;
		exist_aval integer;
		exist_nota number;
		exist_pergunta number;
		count_questao integer;
		count_completo integer;
		ws_senha       varchar2(80);

	begin

		select count(*) into n_exist from SENHA  where trim(prm_senha) = trim(DS_SENHA);
		if(n_exist = 1) then
			select ds_senha into ws_senha from SENHA where trim(prm_senha) = trim(DS_SENHA) and ROWNUM = 1;
			select count(cd_senha) into exist_aval from AVALIACAO where trim(prm_senha) = trim(CD_SENHA);
			if(exist_aval = 0) then
				htp.p('<div id="form_avaliacao">');

					/*htp.p('<div class="linha">Unidade: <select id="unidade">');
						htp.p('<option value="none" disabled selected hidden>Escolha a unidade de negocio</option>');
						open crs_unidade;
							loop
								fetch crs_unidade into ws_unidade;
								exit when crs_unidade%notfound;
								htp.p('<option value="'||ws_unidade.cd_perfil||'">'||ws_unidade.ds_perfil||'</option>');
							end loop;
						close crs_unidade;
					htp.p('</select></div>');*/

					/*htp.p('<div class="linha">Setor: <select id="setor">');
						htp.p('<option value="none" disabled selected hidden>Escolha o setor de trabalho</option>');
						open crs_setor;
							loop
								fetch crs_setor into ws_setor;
								exit when crs_setor%notfound;
								htp.p('<option value="'||ws_setor.cd_perfil||'">'||ws_setor.ds_perfil||'</option>');
							end loop;
						close crs_setor;
					htp.p('</select></div>');*/

					htp.p('<div class="linha">Turno: <select id="turno">');
						htp.p('<option value="none" disabled selected hidden>Escolha o turno</option>');
						open crs_turnos;
							loop
								fetch crs_turnos into ws_turno;
								exit when crs_turnos%notfound;
								htp.p('<option value="'||ws_turno.cd_perfil||'">'||ws_turno.ds_perfil||'</option>');
							end loop;
						close crs_turnos;
					htp.p('</select></div>');

					/*htp.p('<div class="linha">Funcao: <select id="funcao">');
						htp.p('<option value="none" disabled selected hidden>Escolha a funcao</option>');
						open crs_funcoes;
							loop
								fetch crs_funcoes into ws_funcao;
								exit when crs_funcoes%notfound;
								htp.p('<option value="'||ws_funcao.cd_perfil||'">'||ws_funcao.ds_perfil||'</option>');
							end loop;
						close crs_funcoes;
					htp.p('</select></div>');*/

					/*htp.p('<div class="linha">Tempo: <select id="tempo">');
						htp.p('<option value="none" disabled selected hidden>Escolha o tempo de trabalho</option>');
						open crs_tempo;
							loop
								fetch crs_tempo into ws_tempo;
								exit when crs_tempo%notfound;
								htp.p('<option value="'||ws_tempo.cd_perfil||'">'||ws_tempo.ds_perfil||'</option>');
							end loop;
						close crs_tempo;
					htp.p('</select></div>');

					htp.p('<div class="linha">Idade: <select id="idade">');
						htp.p('<option value="none" disabled selected hidden>Escolha a idade</option>');
						open crs_idades;
							loop
								fetch crs_idades into ws_idade;
								exit when crs_idades%notfound;
								htp.p('<option value="'||ws_idade.cd_perfil||'">'||ws_idade.ds_perfil||'</option>');
							end loop;
						close crs_idades;
					htp.p('</select></div>');*/

					/*htp.p('<div class="linha">Escolaridade: <select id="escolaridade">');
						htp.p('<option value="none" disabled selected hidden>Escolha a escolaridade</option>');
						open crs_escolaridades;
							loop
								fetch crs_escolaridades into ws_escolaridade;
								exit when crs_escolaridades%notfound;
								htp.p('<option value="'||ws_escolaridade.cd_perfil||'">'||ws_escolaridade.ds_perfil||'</option>');
							end loop;
						close crs_escolaridades;
					htp.p('</select></div>');*/

					htp.p('<div class="linha"><a class="concluir" onclick="var ok = 0; var tags = document.getElementById(''form_avaliacao'').getElementsByTagName(''select''); for(i=0;i<tags.length;i++){ if(tags[i].value != ''none''){ ok = ok+1; } } if(ok == 1){ inject_db(''dwu.sac.inserir_avaliacao?prm_senha='||ws_senha||'&funcao=&turno=''+tags[0].value+''&idade=&escolaridade=&tempo=&setor=&unidade=''); inject_html(''dwu.sac.perguntas?prm_senha='||ws_senha||'''); document.getElementById(''form_avaliacao'').setAttribute(''class'',''invisivel''); } else { alerta(''alerta'', ''Favor preencher todos os campos!''); }">ENVIAR</a></div>');


				htp.p('</div>');

			else
				select cd_avaliacao, cd_senha, cd_funcao, cd_turno, cd_idade, cd_escolaridade, cd_tempo, cd_setor, cd_unidade, dt_avaliacao, in_fecha into ws_avaliacao from AVALIACAO where trim(prm_senha) = trim(cd_senha) and ROWNUM = 1;
				select count(*) into exist_nota from NOTA  where trim(ws_avaliacao.cd_avaliacao) = trim(CD_AVALIACAO);
				select count(*) into exist_pergunta from questao_avaliacao;
				count_questao := 0;
				if (exist_pergunta - exist_nota) <> 0 then
					if(exist_nota > 0) then
						htp.p('<ul id="perguntas">');
							for i in (select cd_questao, ds_questao, cd_grupo, cd_formulario, nr_ordem, tipo from QUESTAO_AVALIACAO where trim(CD_QUESTAO) not in (select CD_QUESTAO from NOTA where trim(CD_AVALIACAO) = trim(ws_avaliacao.cd_avaliacao)) order by nr_ordem) loop
								count_questao := count_questao+1;
								htp.p('<li id="'||count_questao||'">');
									htp.p('<h2>'||count_questao||' - '||i.ds_questao||'</h2>');
									if i.tipo = 'texto' then
										htp.p('<textarea id="textarea-'||i.cd_questao||'" rows="5" cols="65" maxlength="4000" onkeyup="this.nextElementSibling.innerHTML = (''CARACTERES RESTANTES: ''+this.value.length);"></textarea>');
										htp.p('<span>CARACTERES RESTANTES: 4000</span>');
										htp.p('<a class="concluir" onclick="var x = document.getElementById(''textarea-'||i.cd_questao||''').value; inject_db(''dwu.sac.inserir_text?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||i.cd_questao||'&nota=&obs=''+x); check_sac('''||ws_avaliacao.cd_avaliacao||''', '''||i.cd_questao||''', '''||count_questao||''');">ENVIAR</a>');
									elsif i.tipo = 'confirm' then
									    htp.p('<select id="select-'||i.cd_questao||'">');
											htp.p('<option value="SIM">SIM</option>');
											htp.p('<option value="NAO">NAO</option>');
										htp.p('</select>');
										htp.p('<a class="concluir" onclick="var x = document.getElementById(''select-'||i.cd_questao||''').value; inject_db(''dwu.sac.inserir_text?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||i.cd_questao||'&nota=&obs=''+x); check_sac('''||ws_avaliacao.cd_avaliacao||''', '''||i.cd_questao||''', '''||count_questao||''');">ENVIAR</a>');
									elsif i.tipo = 'opiniao' then
										htp.p('<form id="form-'||i.cd_questao||'">');
											htp.p('<input type="radio" name="nota" value="1" id="input1'||i.cd_questao||'" /><label for="input1'||i.cd_questao||'">Nunca/Nao</label>');
											htp.p('<input type="radio" name="nota" value="2" id="input2'||i.cd_questao||'" /><label for="input2'||i.cd_questao||'">Quase nunca</label>');
											htp.p('<input type="radio" name="nota" value="3" id="input3'||i.cd_questao||'" /><label for="input3'||i.cd_questao||'">As vezes</label>');
											htp.p('<input type="radio" name="nota" value="4" id="input4'||i.cd_questao||'" /><label for="input4'||i.cd_questao||'">Quase sempre</label>');
											htp.p('<input type="radio" name="nota" value="5" id="input5'||i.cd_questao||'" /><label for="input5'||i.cd_questao||'">Sempre/Sim</label>');
										htp.p('</form>');
										htp.p('<a class="concluir" onclick="var x = document.getElementById(''form-'||i.cd_questao||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){ if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||i.cd_questao||'&nota=''+z); check_sac('''||ws_avaliacao.cd_avaliacao||''', '''||i.cd_questao||''', '''||count_questao||'''); }}">ENVIAR</a>');

									else
										htp.p('<form id="form-'||i.cd_questao||'">');
											htp.p('<input type="radio" name="nota" value="0" id="input0'||i.cd_questao||'" /><label for="input0'||i.cd_questao||'">0</label>');
											htp.p('<input type="radio" name="nota" value="1" id="input1'||i.cd_questao||'" /><label for="input1'||i.cd_questao||'">1</label>');
											htp.p('<input type="radio" name="nota" value="2" id="input2'||i.cd_questao||'" /><label for="input2'||i.cd_questao||'">2</label>');
											htp.p('<input type="radio" name="nota" value="3" id="input3'||i.cd_questao||'" /><label for="input3'||i.cd_questao||'">3</label>');
											htp.p('<input type="radio" name="nota" value="4" id="input4'||i.cd_questao||'" /><label for="input4'||i.cd_questao||'">4</label>');
											htp.p('<input type="radio" name="nota" value="5" id="input5'||i.cd_questao||'" /><label for="input5'||i.cd_questao||'">5</label>');
											htp.p('<input type="radio" name="nota" value="6" id="input6'||i.cd_questao||'" /><label for="input6'||i.cd_questao||'">6</label>');
											htp.p('<input type="radio" name="nota" value="7" id="input7'||i.cd_questao||'" /><label for="input7'||i.cd_questao||'">7</label>');
											htp.p('<input type="radio" name="nota" value="8" id="input8'||i.cd_questao||'" /><label for="input8'||i.cd_questao||'">8</label>');
											htp.p('<input type="radio" name="nota" value="9" id="input9'||i.cd_questao||'" /><label for="input9'||i.cd_questao||'">9</label>');
											htp.p('<input type="radio" name="nota" value="10" id="input10'||i.cd_questao||'" /><label for="input10'||i.cd_questao||'">10</label>');
											htp.p('<input type="radio" name="nota" value="99" id="inputna'||i.cd_questao||'" /><label for="inputna'||i.cd_questao||'">N/A</label>');
										htp.p('</form>');
										htp.p('<a class="concluir" onclick="var x = document.getElementById(''form-'||i.cd_questao||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){ if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||i.cd_questao||'&nota=''+z); check_sac('''||ws_avaliacao.cd_avaliacao||''', '''||i.cd_questao||''', '''||count_questao||'''); }}">ENVIAR</a>');
									end if;
								htp.p('</li>');
							end loop;
						htp.p('</ul>');
						htp.p('<div id="completo" class="linha invisivel">Pesquisa concluida com sucesso!</div>');
					else
						count_questao := 0;
						count_completo := 0;
						htp.p('<ul id="perguntas">');			
							for i in (select cd_questao, ds_questao, cd_grupo, cd_formulario, nr_ordem, tipo from QUESTAO_AVALIACAO order by nr_ordem) loop
								count_questao := count_questao+1;
								htp.p('<li id="'||count_questao||'">');
									htp.p('<h2>'||count_questao||' - '||i.ds_questao||'</h2>');
									if i.tipo = 'texto' then
										htp.p('<textarea id="textarea-'||i.cd_questao||'" rows="5" cols="65" maxlength="4000" onkeyup="this.nextElementSibling.innerHTML = (''CARACTERES RESTANTES: ''+this.value.length);"></textarea>');
										htp.p('<span>CARACTERES RESTANTES: 4000</span>');
										htp.p('<a class="concluir" onclick="x = document.getElementById(''textarea-'||i.cd_questao||''').value; z = ''''; inject_db(''dwu.sac.inserir_text?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||i.cd_questao||'&nota=''+z+''&obs=''+x); check_sac('''||ws_avaliacao.cd_avaliacao||''', '''||i.cd_questao||''', '''||count_questao||''');">ENVIAR</a>');
									elsif i.tipo = 'confirm' then
									    htp.p('<select id="select-'||i.cd_questao||'">');
											htp.p('<option value="SIM">SIM</option>');
											htp.p('<option value="NAO">NAO</option>');
										htp.p('</select>');
										htp.p('<a class="concluir" onclick="var x = document.getElementById(''select-'||i.cd_questao||''').value; inject_db(''dwu.sac.inserir_text?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||i.cd_questao||'&nota=&obs=''+x); check_sac('''||ws_avaliacao.cd_avaliacao||''', '''||i.cd_questao||''', '''||count_questao||''');">ENVIAR</a>');
									elsif i.tipo = 'opiniao' then
										htp.p('<form id="form-'||i.cd_questao||'">');
											htp.p('<input type="radio" name="nota" value="1" id="input1'||i.cd_questao||'" /><label for="input1'||i.cd_questao||'">Nunca/Nao</label>');
											htp.p('<input type="radio" name="nota" value="2" id="input2'||i.cd_questao||'" /><label for="input2'||i.cd_questao||'">Quase nunca</label>');
											htp.p('<input type="radio" name="nota" value="3" id="input3'||i.cd_questao||'" /><label for="input3'||i.cd_questao||'">As vezes</label>');
											htp.p('<input type="radio" name="nota" value="4" id="input4'||i.cd_questao||'" /><label for="input4'||i.cd_questao||'">Quase sempre</label>');
											htp.p('<input type="radio" name="nota" value="5" id="input5'||i.cd_questao||'" /><label for="input5'||i.cd_questao||'">Sempre/Sim</label>');
										htp.p('</form>');
										htp.p('<a class="concluir" onclick="var x = document.getElementById(''form-'||i.cd_questao||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){  if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||i.cd_questao||'&nota=''+z); check_sac('''||ws_avaliacao.cd_avaliacao||''', '''||i.cd_questao||''', '''||count_questao||''');}}">ENVIAR</a>');
									else
										htp.p('<form id="form-'||i.cd_questao||'">');
											htp.p('<input type="radio" name="nota" value="0" id="input0'||i.cd_questao||'" /><label for="input0'||i.cd_questao||'">0</label>');
											htp.p('<input type="radio" name="nota" value="1" id="input1'||i.cd_questao||'" /><label for="input1'||i.cd_questao||'">1</label>');
											htp.p('<input type="radio" name="nota" value="2" id="input2'||i.cd_questao||'" /><label for="input2'||i.cd_questao||'">2</label>');
											htp.p('<input type="radio" name="nota" value="3" id="input3'||i.cd_questao||'" /><label for="input3'||i.cd_questao||'">3</label>');
											htp.p('<input type="radio" name="nota" value="4" id="input4'||i.cd_questao||'" /><label for="input4'||i.cd_questao||'">4</label>');
											htp.p('<input type="radio" name="nota" value="5" id="input5'||i.cd_questao||'" /><label for="input5'||i.cd_questao||'">5</label>');
											htp.p('<input type="radio" name="nota" value="6" id="input6'||i.cd_questao||'" /><label for="input6'||i.cd_questao||'">6</label>');
											htp.p('<input type="radio" name="nota" value="7" id="input7'||i.cd_questao||'" /><label for="input7'||i.cd_questao||'">7</label>');
											htp.p('<input type="radio" name="nota" value="8" id="input8'||i.cd_questao||'" /><label for="input8'||i.cd_questao||'">8</label>');
											htp.p('<input type="radio" name="nota" value="9" id="input9'||i.cd_questao||'" /><label for="input9'||i.cd_questao||'">9</label>');
											htp.p('<input type="radio" name="nota" value="10" id="input10'||i.cd_questao||'" /><label for="input10'||i.cd_questao||'">10</label>');
											htp.p('<input type="radio" name="nota" value="99" id="inputna'||i.cd_questao||'" /><label for="inputna'||i.cd_questao||'">N/A</label>');
										htp.p('</form>');
										htp.p('<a class="concluir" onclick=" x = document.getElementById(''form-'||i.cd_questao||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){  if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||i.cd_questao||'&nota=''+z); check_sac('''||ws_avaliacao.cd_avaliacao||''', '''||i.cd_questao||''', '''||count_questao||''');}}">ENVIAR</a>');
									end if;
								htp.p('</li>');
							end loop;
						htp.p('</ul>');
						htp.p('<div id="completo" class="linha invisivel">Pesquisa concluida com sucesso!</div>');
					end if;
				else
				    htp.p('<div id="completo" class="linha">Pesquisa ja foi concluida!</div>');
			    end if;
			end if;
		else
			htp.p('<div style="font-weight: bold;" class="linha">Login inexistente! <a onclick="this.parentNode.setAttribute(''class'',''invisivel''); document.getElementById(''login'').setAttribute(''class'',''visivel'');">Tentar novamente</a></div>');

			htp.p('<div id="conteudo"><div style="font-style: italic; font-weight: bold; font-size: 24px; line-height: 32px; margin: 20px; color: #333;"><p style="margin-bottom: 20px;">Bem Vindo!</p><p>Sua Opiniao e muito Importante!</p><p>A pesquisa de clima e uma oportunidade para voce expressar sua opiniao e sua satisfacao em relacao a empresa.</p><p style="margin-top: 20px;">Obrigado pela sua participacao!</p></div></div>');
		    htp.p('<div id="login" class="invisivel">');
				--htp.p('<form autocomplete="on" onSubmit="document.getElementById(''erro'').setAttribute(''class'',''invisivel''); x = document.getElementById(''senha'').value; if(x.length < 1){ document.getElementById(''erro'').setAttribute(''class'',''visivel''); } else { inject_html(''dwu.sac.avaliacao?prm_senha=''+x); document.getElementById(''login'').setAttribute(''class'',''invisivel''); } return false;">');
					htp.p('<span>Senha: </span><input id="senha" type="number" pattern="[0-9]*" inputmode="numeric" onkeypress="if(event.which == ''13''){ this.nextElementSibling.click(); }" />');
				--htp.p('</form>');
				htp.p('<a class="acessar" onclick="document.getElementById(''erro'').setAttribute(''class'',''invisivel''); x = document.getElementById(''senha'').value; if(x.length < 1){ document.getElementById(''erro'').setAttribute(''class'',''visivel''); } else { inject_html(''dwu.sac.avaliacao?prm_senha=''+x); document.getElementById(''login'').setAttribute(''class'',''invisivel''); }">Acessar</a>'); 
				htp.p('<small id="erro" class="invisivel">Acesso negado, favor preencher o campo de senha!</small>');
			htp.p('</div>');
		end if;

	end avaliacao;

	procedure perguntas( prm_senha varchar2 ) as

		cursor crs_perguntas is select cd_questao, ds_questao, cd_grupo, cd_formulario, nr_ordem from QUESTAO_AVALIACAO order by nr_ordem;
		ws_questao	crs_perguntas%rowtype;

		cursor crs_avaliacoes is select cd_avaliacao, cd_senha, cd_funcao, cd_turno, cd_idade, cd_escolaridade, cd_tempo, cd_setor, cd_unidade, dt_avaliacao, in_fecha from AVALIACAO;
		ws_avaliacao crs_avaliacoes%rowtype;

		n_exist integer;
		count_questao integer;
		count_completo integer;
		count_avaliacao integer;

	begin

		select count(ds_senha) into n_exist from SENHA  where trim(prm_senha) = trim(DS_SENHA);
		if(n_exist = 1) then
		    select count(cd_avaliacao) into count_avaliacao from AVALIACAO where trim(prm_senha) = trim(CD_SENHA);
			if(count_avaliacao = 1) then
				select * into ws_avaliacao from AVALIACAO where trim(prm_senha) = trim(CD_SENHA);
				count_questao := 0;
				htp.p('<ul id="perguntas">');			
					for ws_questao in (select cd_questao, ds_questao, cd_grupo, nr_ordem, tipo from QUESTAO_AVALIACAO order by nr_ordem) loop
						count_questao := count_questao+1;
						htp.p('<li id="'||count_questao||'">');
							htp.p('<h2>'||count_questao||' - '||ws_questao.ds_questao||'</h2>');
							if ws_questao.tipo = 'texto' then
								htp.p('<textarea id="textarea-'||ws_questao.cd_questao||'" rows="5" cols="65" maxlength="4000" onkeyup="this.nextElementSibling.innerHTML = (''CARACTERES RESTANTES: ''+this.value.length);"></textarea>');
								htp.p('<span>CARACTERES RESTANTES: 4000</span>');
								htp.p('<a class="concluir" onclick="x = document.getElementById(''textarea-'||ws_questao.cd_questao||''').value; z = ''''; inject_db(''dwu.sac.inserir_text?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||ws_questao.cd_questao||'&nota=''+z+''&obs=''+x); check_sac('''||ws_avaliacao.cd_avaliacao||''', '''||ws_questao.cd_questao||''', '''||count_questao||''');">ENVIAR</a>');
							elsif ws_questao.tipo = 'confirm' then
							    htp.p('<select id="select-'||ws_questao.cd_questao||'">');
									htp.p('<option value="SIM">SIM</option>');
									htp.p('<option value="NAO">NAO</option>');
								htp.p('</select>');
								htp.p('<a class="concluir" onclick="var x = document.getElementById(''select-'||ws_questao.cd_questao||''').value; inject_db(''dwu.sac.inserir_text?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||ws_questao.cd_questao||'&nota=&obs=''+x); check_sac('''||ws_avaliacao.cd_avaliacao||''', '''||ws_questao.cd_questao||''', '''||count_questao||''');">ENVIAR</a>');
							elsif ws_questao.tipo = 'opiniao' then
								htp.p('<form id="form-'||ws_questao.cd_questao||'">');
									htp.p('<input type="radio" name="nota" value="1" id="input1'||ws_questao.cd_questao||'" /><label for="input1'||ws_questao.cd_questao||'">Nunca/Nao</label>');
									htp.p('<input type="radio" name="nota" value="2" id="input2'||ws_questao.cd_questao||'" /><label for="input2'||ws_questao.cd_questao||'">Quase nunca</label>');
									htp.p('<input type="radio" name="nota" value="3" id="input3'||ws_questao.cd_questao||'" /><label for="input3'||ws_questao.cd_questao||'">As vezes</label>');
									htp.p('<input type="radio" name="nota" value="4" id="input4'||ws_questao.cd_questao||'" /><label for="input4'||ws_questao.cd_questao||'">Quase sempre</label>');
									htp.p('<input type="radio" name="nota" value="5" id="input5'||ws_questao.cd_questao||'" /><label for="input5'||ws_questao.cd_questao||'">Sempre/Sim</label>');
								htp.p('</form>');
								htp.p('<a class="concluir" onclick=" x = document.getElementById(''form-'||ws_questao.cd_questao||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){ if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||ws_questao.cd_questao||'&nota=''+z); check_sac('''||ws_avaliacao.cd_avaliacao||''', '''||ws_questao.cd_questao||''', '''||count_questao||'''); }}">ENVIAR</a>');
							else
								htp.p('<form id="form-'||ws_questao.cd_questao||'">');
									htp.p('<input type="radio" name="nota" value="0" id="input0'||ws_questao.cd_questao||'" /><label for="input0'||ws_questao.cd_questao||'">0</label>');
									htp.p('<input type="radio" name="nota" value="1" id="input1'||ws_questao.cd_questao||'" /><label for="input1'||ws_questao.cd_questao||'">1</label>');
									htp.p('<input type="radio" name="nota" value="2" id="input2'||ws_questao.cd_questao||'" /><label for="input2'||ws_questao.cd_questao||'">2</label>');
									htp.p('<input type="radio" name="nota" value="3" id="input3'||ws_questao.cd_questao||'" /><label for="input3'||ws_questao.cd_questao||'">3</label>');
									htp.p('<input type="radio" name="nota" value="4" id="input4'||ws_questao.cd_questao||'" /><label for="input4'||ws_questao.cd_questao||'">4</label>');
									htp.p('<input type="radio" name="nota" value="5" id="input5'||ws_questao.cd_questao||'" /><label for="input5'||ws_questao.cd_questao||'">5</label>');
									htp.p('<input type="radio" name="nota" value="6" id="input6'||ws_questao.cd_questao||'" /><label for="input6'||ws_questao.cd_questao||'">6</label>');
									htp.p('<input type="radio" name="nota" value="7" id="input7'||ws_questao.cd_questao||'" /><label for="input7'||ws_questao.cd_questao||'">7</label>');
									htp.p('<input type="radio" name="nota" value="8" id="input8'||ws_questao.cd_questao||'" /><label for="input8'||ws_questao.cd_questao||'">8</label>');
									htp.p('<input type="radio" name="nota" value="9" id="input9'||ws_questao.cd_questao||'" /><label for="input9'||ws_questao.cd_questao||'">9</label>');
									htp.p('<input type="radio" name="nota" value="10" id="input10'||ws_questao.cd_questao||'" /><label for="input10'||ws_questao.cd_questao||'">10</label>');
									htp.p('<input type="radio" name="nota" value="99" id="inputna'||ws_questao.cd_questao||'" /><label for="inputna'||ws_questao.cd_questao||'">N/A</label>');
								htp.p('</form>');
								htp.p('<a class="concluir" onclick=" x = document.getElementById(''form-'||ws_questao.cd_questao||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){ if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||ws_questao.cd_questao||'&nota=''+z); check_sac('''||ws_avaliacao.cd_avaliacao||''', '''||ws_questao.cd_questao||''', '''||count_questao||'''); }}">ENVIAR</a>');
							end if;
						htp.p('</li>');
					end loop;
				htp.p('</ul>');
				htp.p('<div id="completo" class="linha invisivel">Pesquisa concluida com sucesso!</div>');
				htp.p('<input id="soma" class="invisivel" value="0" />');
			else
                    fcl.jMsg('Usuario nao encontrado, favor recarregar a pagina!');
					htp.p(sqlerrm);
			end if;
		end if;

	end perguntas;

	procedure inserir_avaliacao( prm_senha varchar2,
					  			 funcao number default 0,
								 turno number default 0,
								 idade  number default 0,
					  			 escolaridade number default 0, 
				      			 tempo number default 0,
								 setor number default 0,
								 unidade number default 0 ) as

		vl_avaliacao number;
		count_aval number;
		ws_count number;


		begin

		--prm_senha=053292&funcao=4&turno=2&idade=2&escolaridade=1&tempo=2&setor=2&unidade=1

			select count(*) into ws_count from avaliacao where cd_senha = prm_senha;

			if ws_count = 0 then

				select nvl(count(cd_avaliacao), 0) into count_aval from avaliacao;
				if(count_aval = 0) then
					INSERT INTO AVALIACAO (cd_avaliacao, cd_senha, cd_funcao, cd_turno, cd_idade, cd_escolaridade, cd_tempo, cd_setor, cd_unidade, dt_avaliacao, in_fecha) VALUES (1, prm_senha, funcao, turno, idade, escolaridade, tempo, setor, unidade, sysdate, 0);
				else
					select max(cd_avaliacao) into vl_avaliacao from avaliacao;
					vl_avaliacao := vl_avaliacao+1;
					begin
						 INSERT INTO AVALIACAO (cd_avaliacao, cd_senha, cd_funcao, cd_turno, cd_idade, cd_escolaridade, cd_tempo, cd_setor, cd_unidade, dt_avaliacao, in_fecha) VALUES (vl_avaliacao, prm_senha, funcao, turno, idade, escolaridade, tempo, setor, unidade, sysdate, 0);
					exception
						 when others then
							fcl.jMsg('Erro ao inserir avaliacao(incrementar)');
							htp.p(sqlerrm);
					end;   
				end if;
				commit;
			end if;
	exception
	    when others then
		    fcl.jMsg('Erro ao inserir avaliacao');
			htp.p(sqlerrm);
	end inserir_avaliacao;

	procedure inserir( avaliacao integer default null,
		               pergunta integer,
		               nota integer ) as

	cod number;
	ws_count number;
	ws_double exception;
	begin
		--verificar sequencias
		select count(*) into ws_count from nota where cd_avaliacao = avaliacao and cd_questao = pergunta;
		if ws_count = 0 then
		    select count(*)+1 into cod from nota;
		    INSERT INTO NOTA VALUES (cod, avaliacao, pergunta, nota, '');
	        commit;
		else
		    raise ws_double;
		end if;
	exception
	    when ws_double then
	        htp.p('Ja existe!');
	    when others then
	        rollback;
		    htp.p(sqlerrm);
	end inserir;

	procedure check_nota ( prm_avaliacao integer,
                           prm_questao integer ) as

	ws_count number;
	begin

	    select count(*) into ws_count from nota where cd_questao = prm_questao and cd_avaliacao = prm_avaliacao;
	    htp.p(ws_count);
	end check_nota;

	procedure inserir_text( avaliacao integer default null,
			                pergunta integer,
			                nota integer,
			                obs varchar2 default null) as
	cod number;
	ws_count number;
	ws_double exception;
	begin	
	    --verificar sequencias
		select count(*) into ws_count from nota where cd_avaliacao = avaliacao and cd_questao = pergunta;
		if ws_count = 0 then

			select count(*)+1 into cod from nota;
		    INSERT INTO NOTA VALUES (cod, avaliacao, pergunta, '', obs);
		    commit;
		else
		    raise ws_double;
		end if;
	exception
	when ws_double then
	    htp.p('Ja existe!');
	when others then
	    rollback;
		htp.p(sqlerrm);
	end inserir_text;

	procedure fechar(avaliacao integer) as
		begin
			update AVALIACAO set IN_FECHA = '1' where CD_AVALIACAO = avaliacao;
		exception
			when others then
				fcl.jMsg('Erro ao fechar a avaliacao');
				htp.p(sqlerrm);
		end fechar;

	procedure add as

		cursor crs_grupos is 
		select cd_perfil, ds_perfil
		from sac_perfil where tipo = 'grupo'
		order by ds_perfil asc;

		ws_grupo crs_grupos%rowtype;

	    begin
		    htp.p('<h2 style="font-weight: bold; margin: 5px 0;">CADASTRO DE PERGUNTAS</h2>');
			htp.p('<form>');
			    htp.p('<input type="text" value="" placeholder="inserir pergunta" id="pergunta"/>');
				htp.p('<label style="margin: 0 0 0 5px;">Grupo: </label>');
				htp.p('<select style="margin: 0 5px 0 0;" id="grupo" value="">');
					open crs_grupos;
                        loop
                            fetch crs_grupos into ws_grupo;
                            exit when crs_grupos%notfound;
                            htp.p('<option value="'||ws_grupo.cd_perfil||'">'||ws_grupo.ds_perfil||'</option>');
                        end loop;
                    close crs_grupos;							
				htp.p('</select>');
				htp.p('<label style="margin: 0 0 0 5px;">Tipo: </label>');
				htp.p('<select style="margin: 0 5px 0 0;" id="tipo" value="">');
                    htp.p('<option value="nota">Nota</option>');	
                    htp.p('<option value="texto">Texto</option>');
                    htp.p('<option value="confirm">Confirmacao</option>');
                    htp.p('<option value="opiniao">Opiniao</option>');					
				htp.p('</select>');
			    htp.p('<a class="link" onclick="var pergunta = document.getElementById(''pergunta'').value; var grupo = document.getElementById(''grupo'').value; var tipo = document.getElementById(''tipo'').value; insert_question(''dwu.sac.add_pergunta'', ''prm_pergunta=''+pergunta+''&prm_grupo=''+grupo+''&prm_tipo=''+tipo);">enviar</a>');
		    htp.p('</form>');

			/*htp.p('<h2 style="font-weight: bold; margin: 5px 0;">CADASTRO DE ESCOLARIDADE</h2>');
			htp.p('<form>');
			    htp.p('<input type="text" value="" placeholder="nova escolaridade" id="escolaridade" style="width: 70%; border-radius: 3px; border: 1px solid #999; box-shadow: 1px 2px 1px 0 #666 inset; padding: 3px; margin: 2px 10px 10px 2px;" />');
			    htp.p('<a class="link" onclick=" insert_question(''dwu.sac.add_cadastro'', ''prm_valor=''+document.getElementById(''escolaridade'').value+''&prm_tipo=escolaridade'');">enviar</a>');
		    htp.p('</form>');

			htp.p('<h2 style="font-weight: bold; margin: 5px 0;">CADASTRO DE SETOR</h2>');
			htp.p('<form>');
			    htp.p('<input type="text" value="" placeholder="novo setor" id="setor" style="width: 70%; border-radius: 3px; border: 1px solid #999; box-shadow: 1px 2px 1px 0 #666 inset; padding: 3px; margin: 2px 10px 10px 2px;" />');
			    htp.p('<a class="link" onclick=" insert_question(''dwu.sac.add_cadastro'', ''prm_valor=''+document.getElementById(''setor'').value+''&prm_tipo=setor'');">enviar</a>');
		    htp.p('</form>');*/

	    end add;

	procedure add_pergunta ( prm_pergunta varchar2 default null,
                             prm_grupo varchar2 default null,
							 prm_tipo char default '1' ) as

        ws_count number;
        ws_sequence  number;		

	    begin

			begin
				select count(*)+1 into ws_sequence from questao_avaliacao;
			    select count(*) into ws_count from questao_avaliacao where trim(ds_questao) = trim(prm_pergunta);
			        if(ws_count > 0) then
					    htp.p('!DUPLICADO');
					else
				        insert into questao_avaliacao values(ws_sequence, trim(prm_pergunta), trim(prm_grupo), '5', ws_sequence, prm_tipo);
			            htp.p('!ADD');
					end if;
			exception when others then
			    htp.p('!ERRO');
			end;
	    end add_pergunta;

		procedure add_cadastro ( prm_valor varchar2 default null,
							     prm_tipo char default '1' ) as	

        ws_count number;								 

	    begin
		    if(prm_tipo = 'escolaridade') then
			    begin
				    select count(*) into ws_count from sac_perfil where trim(ds_perfil) = trim(prm_valor) and tipo = 'escolaridade';
			        if(ws_count > 0) then
					    htp.p('!DUPLICADO');
					else
					    insert into sac_perfil values((select max(cd_perfil) from sac_perfil where tipo = 'escolaridade')+1, prm_valor, 'escolaridade');
						 htp.p('!ADD');
					end if;
			    exception when others then
			        htp.p('!ERRO');
			    end;
			else
			    begin
				    select count(*) into ws_count from sac_perfil where trim(ds_perfil) = trim(prm_valor) and tipo = 'setor';
					if(ws_count > 0) then
					    htp.p('!DUPLICADO');
					else
			            insert into sac_perfil values((select max(cd_perfil) from sac_perfil where tipo = 'setor')+1, prm_valor, 'setor');
						htp.p('!ADD');
					end if;
			    exception when others then
			        htp.p('!ERRO');
			    end;
			end if;

	    end add_cadastro;



		procedure dlt as

		cursor crs_perguntas is 
		select ds_questao, cd_questao
		from questao_avaliacao
		order by ds_questao asc;

		ws_pergunta crs_perguntas%rowtype;

		/*cursor crs_setores is 
		select ds_perfil, cd_perfil
		from sac_perfil
		where tipo = 'setor'
		order by ds_perfil asc;

		ws_setor crs_setores%rowtype;

		cursor crs_escolaridades is 
		select ds_perfil, cd_perfil
		from sac_perfil
		where tipo = 'escolaridade'
		order by ds_perfil asc;

		ws_escolaridade crs_escolaridades%rowtype;*/

	    begin
		    htp.p('<h2 style="font-weight: bold; margin: 5px 0;">EXCLUSAO DE PERGUNTAS</h2>');
			htp.p('<select id="pergunta-dlt">');
			open crs_perguntas;
			    loop
				    fetch crs_perguntas into ws_pergunta;
					exit when crs_perguntas%notfound;
					htp.p('<option value="'||ws_pergunta.cd_questao||'">'||ws_pergunta.ds_questao||'</option>');
				end loop;
			close crs_perguntas;
			htp.p('</select>');
			htp.p('<a class="link" onclick="insert_question(''dwu.sac.dlt_cadastro'', ''prm_valor=''+document.getElementById(''pergunta-dlt'').value+''&prm_tipo=perguntas'');">Excluir</a>');


			/*htp.p('<h2 style="font-weight: bold; margin: 5px 0;">ESCOLARIDADE</h2>');
			htp.p('<select id="escolaridade-dlt">');
			open crs_escolaridades;
			    loop
				    fetch crs_escolaridades into ws_escolaridade;
					exit when crs_escolaridades%notfound;
					htp.p('<option value="'||ws_escolaridade.cd_perfil||'">'||ws_escolaridade.ds_perfil||'</option>');
				end loop;
			close crs_escolaridades;
			htp.p('</select>');
			htp.p('<a class="link" onclick="insert_question(''dwu.sac.dlt_cadastro'', ''prm_valor=''+document.getElementById(''escolaridade-dlt'').value+''&prm_tipo=escolaridade'');">Excluir</a>');


			htp.p('<h2 style="font-weight: bold; margin: 5px 0;">SETOR</h2>');
			htp.p('<select id="setor-dlt">');
			open crs_setores;
			    loop
				    fetch crs_setores into ws_setor;
					exit when crs_setores%notfound;
					htp.p('<option value="'||ws_setor.cd_perfil||'">'||ws_setor.ds_perfil||'</option>');
				end loop;
			close crs_setores;
			htp.p('</select>');
			htp.p('<a class="link" onclick="insert_question(''dwu.sac.dlt_cadastro'', ''prm_valor=''+document.getElementById(''setor-dlt'').value+''&prm_tipo=setor'');">Excluir</a>');
			*/
			htp.p('<p id="alerta" style="color: #CC0000; font-weight: bold; transition: opacity 0.2s linear; -webkit-transition: opacity 0.2s linear; opacity: 0;"></p>');
	    end dlt;

		procedure dlt_cadastro ( prm_valor varchar2 default null,
							     prm_tipo char default '1' ) as	

        ws_count number;								 

	    begin
		    if(prm_tipo = 'escolaridade') then
			    begin
				    select count(*) into ws_count from sac_perfil where trim(cd_perfil) = trim(prm_valor) and tipo = 'escolaridade';
			        if(ws_count > 1) then
					    htp.p('!DUPLICADO');
					else
					    delete from sac_perfil where cd_perfil = prm_valor and tipo = 'escolaridade';
			            htp.p('!DLT');
					end if;
			    exception when others then
			        htp.p('!ERRO');
			    end;
			elsif(prm_tipo = 'setor') then
			    begin
				    select count(*) into ws_count from sac_perfil where trim(cd_perfil) = trim(prm_valor) and tipo = 'setor';
					if(ws_count > 1) then
					    htp.p('!DUPLICADO');
					else
			            delete from sac_perfil where cd_perfil = prm_valor and tipo = 'setor';
			            htp.p('!DLT');
					end if;
			    exception when others then
			        htp.p('!ERRO');
			    end;
			else
			    begin
				    select count(*) into ws_count from questao_avaliacao where trim(cd_questao) = trim(prm_valor);
					if(ws_count > 1) then
					    htp.p('!DUPLICADO');
					else
			            delete from questao_avaliacao where cd_questao = prm_valor;
			            htp.p('!DLT');
					end if;
			    exception when others then
			        htp.p('!ERRO');
			    end;

			end if;

	    end dlt_cadastro;
end Sac;