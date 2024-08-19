set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplicação:	Kernel Package
-- >>>>>>> Por:		Upquery Tec (Joãozinho)
-- >>>>>>> Data:	14/05/12
-- >>>>>>> Pacote:	S.A.C (Sistema de Avaliação de Clima)
-- >>>>>>>-------------------------------------------------------------

create or replace package Sac is
	
	procedure main;
	
	procedure perguntas ( senha integer );
	
	procedure avaliacao ( senha varchar2 );
		         
	procedure inserir_avaliacao( senha integer,
					  			 setor integer,
					  			 escolaridade integer, 
				      			 idade integer);
				      
	procedure inserir( avaliacao integer default null,
			           pergunta integer,
			           nota integer);
			
	procedure inserir_text(avaliacao integer default null,
					  pergunta integer,
					  nota integer,
				      obs varchar2 default null);	
	
	procedure fechar( avaliacao integer );
	
end Sac;
/

create or replace package body Sac is

	procedure main as
	
		ws_count number;
	
		begin
		htp.p('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
		htp.p('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">');
			htp.headOpen;
				htp.p('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
				htp.p('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
				htp.p('<TITLE>UpQuery Tec</TITLE>');
				htp.p('<link rel="apple-touch-icon" size="114x114" href="'||ret_var('URL_GIFS')||'ipad_icon.png">');
				htp.p('<META HTTP-EQUIV="Pragma" CONTENT="no-cache">');
				htp.p('<META HTTP-EQUIV="Expires" CONTENT="-1">');
				htp.p('<META NAME="apple-mobile-web-app-capable" CONTENT="yes">');
				htp.p('<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">');
				htp.p( '<input type="hidden" name="moviment"   id="movimento"      value="yes" >' );
				htp.p( '<input type="hidden" name="current_sc" id="current_screen" value="DEFAULT" >' );
				htp.p( '<input type="hidden" name="travapro"   id="lockp"          value="" >' );
				htp.p( '<input type="hidden" name="ndrobj"     id="drill_obj"      value="NOC" >' );
				htp.p( '<input type="hidden" name="reconx"     id="refcon"         value="N" >' );
				htp.p( '<input type="hidden" name="ndrtogo"    id="drill_go"       value="" >' );
				htp.p( '<input type="hidden" name="ndrobjx"    id="drill_x"        value="" >' );
				htp.p( '<input type="hidden" name="ndrobjy"    id="drill_y"        value="" >' );
				htp.p( '<input type="hidden" name="ndrshow"    id="drill_show"     value="" >' );
				fcl.put_script('Sai');
				fcl.put_css('sac_css');
			htp.headClose;
			htp.p('<body>');
				htp.p('<div id="avaliacao">');
					htp.p('<h1>SISTEMA DE AVALIAÇÃO DE CLIMA</h1>');
					htp.p('<div id="login">');
						htp.p('<form autocomplete="on" onSubmit="document.getElementById(''erro'').setAttribute(''class'',''invisivel''); x = document.getElementById(''senha'').value; if(x.length < 1){ document.getElementById(''erro'').setAttribute(''class'',''visivel''); } else { inject_html(''dwu.sac.avaliacao?senha=''+x); document.getElementById(''login'').setAttribute(''class'',''invisivel''); } return false;">');
							htp.p('<span>Senha: </span><input id="senha" type="password" />');
						htp.p('</form>');
						htp.p('<a class="acessar" onclick="document.getElementById(''erro'').setAttribute(''class'',''invisivel''); x = document.getElementById(''senha'').value; if(x.length < 1){ document.getElementById(''erro'').setAttribute(''class'',''visivel''); } else { inject_html(''dwu.sac.avaliacao?senha=''+x); document.getElementById(''login'').setAttribute(''class'',''invisivel''); }">Acessar</a>'); 
						htp.p('<small id="erro" class="invisivel">Acesso negado, favor preencher o campo de senha!</small>');
					htp.p('</div>');
					htp.p('<div id="conteudo"></div>');	
				htp.p('</div>');
			htp.p('</body>');
		htp.p('</html>');
	end main;
	
	--PROCEDURE COM OS DADOS INICIAIS E CASO RESPONDIDOS CARREGA AS PERGUNTAS

	procedure avaliacao( senha varchar2 ) as
	
		cursor crs_senhas is select * from SENHA;
		ws_senha crs_senhas%rowtype;
		
		cursor crs_idades is select * from IDADE;
		ws_idade crs_idades%rowtype;
		
		cursor crs_escolaridades is select * from ESCOLARIDADE;
		ws_escolaridade	crs_escolaridades%rowtype;
		
		cursor crs_setores is select * from SETOR1;
		ws_setor crs_setores%rowtype;
		
		cursor crs_avaliacoes is select * from AVALIACAO;
		ws_avaliacao crs_avaliacoes%rowtype;
		
		cursor crs_questoes is select * from QUESTAO_AVALIACAO;
		ws_questao	crs_questoes%rowtype;
		
		cursor crs_notas is select * from NOTA;
		ws_nota crs_notas%rowtype;
		
		n_exist integer;
		exist_aval integer;
		exist_nota integer;
		exist_pergunta integer;
		count_questao integer;
		count_completo integer;
	
	begin
	
		select count(*) into n_exist from SENHA  where trim(senha) = trim(DS_SENHA);
		if(n_exist = 1) then
			select * into ws_senha from SENHA  where trim(senha) = trim(DS_SENHA);
			select count(*) into exist_aval from AVALIACAO  where trim(ws_senha.cd_senha) = trim(CD_SENHA);
			if(exist_aval = 0) then
					htp.p('<div id="form_avaliacao">');
					htp.p('<div class="linha">Setor: <select id="setor">');
						open crs_setores;
							loop
								fetch crs_setores into ws_setor;
								exit when crs_setores%notfound;
								htp.p('<option value="'||ws_setor.cd_setor||'">'||ws_setor.ds_setor||'</option>');
							end loop;
						close crs_setores;
					htp.p('</select></div>');
					htp.p('<div class="linha">Escolaridade: <select id="escolaridade">');
						open crs_escolaridades;
							loop
								fetch crs_escolaridades into ws_escolaridade;
								exit when crs_escolaridades%notfound;
								htp.p('<option value="'||ws_escolaridade.cd_escolaridade||'">'||ws_escolaridade.ds_escolaridade||'</option>');
							end loop;
						close crs_escolaridades;
					htp.p('</select></div>');

					htp.p('<div class="linha">Idade: <select id="idade">');
						open crs_idades;
							loop
								fetch crs_idades into ws_idade;
								exit when crs_idades%notfound;
								htp.p('<option value="'||ws_idade.cd_idade||'">'||ws_idade.ds_idade||'</option>');
							end loop;
						close crs_idades;
					htp.p('</select></div>');
					htp.p('<div class="linha"><a onclick=" x = document.getElementById(''setor'').value; y = document.getElementById(''escolaridade'').value; z = document.getElementById(''idade'').value; inject_db(''dwu.sac.inserir_avaliacao?senha='||ws_senha.cd_senha||'&setor=''+x+''&escolaridade=''+y+''&idade=''+z); document.getElementById(''form_avaliacao'').setAttribute(''class'',''invisivel''); inject_html(''dwu.sac.perguntas?senha='||ws_senha.cd_senha||''');">Enviar</a></div>');
				htp.p('</div>');
			else
				select * into ws_avaliacao from AVALIACAO  where trim(ws_senha.cd_senha) = trim(CD_SENHA);
				select count(*) into exist_nota from NOTA  where trim(ws_avaliacao.cd_avaliacao) = trim(CD_AVALIACAO);
				select count(*) into exist_pergunta from QUESTAO_AVALIACAO;
				count_questao := 0;
				if(exist_nota <> exist_pergunta) then
					if(exist_nota > 0) then
						--se já existe alguma resposta dada.
						htp.p('<ul id="perguntas">');
							for ws_questao in (select * from QUESTAO_AVALIACAO where trim(CD_QUESTAO) not in (select CD_QUESTAO from NOTA where trim(ws_avaliacao.cd_avaliacao)= trim(CD_AVALIACAO)) order by NR_ORDEM) loop
								count_questao := count_questao+1;
								htp.p('<li id="'||count_questao||'">');
									htp.p('<h2>'||count_questao||' - '||ws_questao.ds_questao||'</h2>');
									if(ws_questao.cd_grupo = '8') then
										htp.p('<textarea id="textarea-'||ws_questao.nr_ordem||'" rows="5" cols="65"></textarea>');
										htp.p('<a id="concluir" onclick="x = document.getElementById(''textarea-'||ws_questao.nr_ordem||''').value; z = ''''; inject_db(''dwu.sac.inserir_text?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||ws_questao.cd_questao||'&nota=''+z+''&obs=''+x); document.getElementById('||count_questao||').setAttribute(''class'',''invisivel''); y = parseInt(document.getElementById(''soma'').value); y = y+1; document.getElementById(''soma'').value = y; if(y == ('||exist_pergunta||'-'||exist_nota||')){ document.getElementById(''perguntas'').setAttribute(''class'',''invisivel''); document.getElementById(''completo'').setAttribute(''class'',''linha visivel''); } ">Concluir</a>');
									else
										htp.p('<form id="form-'||ws_questao.nr_ordem||'">');
											htp.p('<input type="radio" name="nota" value="0" />0');
											htp.p('<input type="radio" name="nota" value="1" />1');
											htp.p('<input type="radio" name="nota" value="2" />2');
											htp.p('<input type="radio" name="nota" value="3" />3');
											htp.p('<input type="radio" name="nota" value="4" />4');
											htp.p('<input type="radio" name="nota" value="5" />5');
											htp.p('<input type="radio" name="nota" value="6" />6');
											htp.p('<input type="radio" name="nota" value="7" />7');
											htp.p('<input type="radio" name="nota" value="8" />8');
											htp.p('<input type="radio" name="nota" value="9" />9');
											htp.p('<input type="radio" name="nota" value="10" />10');
											htp.p('<input type="radio" name="nota" value="99"/>N/A');
										htp.p('</form>');
										htp.p('<a id="concluir" onclick=" x = document.getElementById(''form-'||ws_questao.nr_ordem||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){ if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||ws_questao.cd_questao||'&nota=''+z); document.getElementById('||count_questao||').setAttribute(''class'',''invisivel''); y = parseInt(document.getElementById(''soma'').value); y = y+1; document.getElementById(''soma'').value = y; if(y == ('||exist_pergunta||'-'||exist_nota||')){ document.getElementById(''perguntas'').setAttribute(''class'',''invisivel''); document.getElementById(''completo'').setAttribute(''class'',''linha visivel''); inject_db(''dwu.sac.fechar?avaliacao='||ws_avaliacao.cd_avaliacao||'''); } }}">Concluir</a>');
									end if;
								htp.p('</li>');
							end loop;
						htp.p('</ul>');
						htp.p('<div id="completo" class="linha invisivel">Pesquisa concluida com sucesso!</div>');
						htp.p('<input id="soma" class="invisivel" value="0" />');
					else
						count_questao := 0;
						count_completo := 0;
						htp.p('<ul id="perguntas">');			
							for ws_questao in (select * from QUESTAO_AVALIACAO order by NR_ORDEM) loop
								count_questao := count_questao+1;
								htp.p('<li id="'||count_questao||'">');
									htp.p('<h2>'||count_questao||' - '||ws_questao.ds_questao||'</h2>');
									if(ws_questao.cd_grupo = '8') then
										htp.p('<textarea id="textarea-'||ws_questao.nr_ordem||'" rows="5" cols="65"></textarea>');
										htp.p('<a id="concluir" onclick="x = document.getElementById(''textarea-'||ws_questao.nr_ordem||''').value; z = ''''; inject_db(''dwu.sac.inserir_text?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||ws_questao.cd_questao||'&nota=''+z+''&obs=''+x); document.getElementById('||count_questao||').setAttribute(''class'',''invisivel''); y = parseInt(document.getElementById(''soma'').value); y = y+1; document.getElementById(''soma'').value = y; if(y == '||exist_pergunta||'){ document.getElementById(''perguntas'').setAttribute(''class'',''invisivel''); document.getElementById(''completo'').setAttribute(''class'',''linha visivel''); } ">Concluir</a>');
									else
										htp.p('<form id="form-'||ws_questao.nr_ordem||'">');
											htp.p('<input type="radio" name="nota" value="0" />0');
											htp.p('<input type="radio" name="nota" value="1" />1');
											htp.p('<input type="radio" name="nota" value="2" />2');
											htp.p('<input type="radio" name="nota" value="3" />3');
											htp.p('<input type="radio" name="nota" value="4" />4');
											htp.p('<input type="radio" name="nota" value="5" />5');
											htp.p('<input type="radio" name="nota" value="6" />6');
											htp.p('<input type="radio" name="nota" value="7" />7');
											htp.p('<input type="radio" name="nota" value="8" />8');
											htp.p('<input type="radio" name="nota" value="9" />9');
											htp.p('<input type="radio" name="nota" value="10" />10');
											htp.p('<input type="radio" name="nota" value="99"/>N/A');
										htp.p('</form>');
										htp.p('<a id="concluir" onclick=" x = document.getElementById(''form-'||ws_questao.nr_ordem||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){ if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||ws_questao.cd_questao||'&nota=''+z); document.getElementById('||count_questao||').setAttribute(''class'',''invisivel''); y = parseInt(document.getElementById(''soma'').value); y = y+1; document.getElementById(''soma'').value = y; if(y == '||exist_pergunta||'){ document.getElementById(''perguntas'').setAttribute(''class'',''invisivel''); document.getElementById(''completo'').setAttribute(''class'',''linha visivel''); inject_db(''dwu.sac.fechar?avaliacao='||ws_avaliacao.cd_avaliacao||'''); } }}">Concluir</a>');
									end if;
								htp.p('</li>');
							end loop;
						htp.p('</ul>');
						htp.p('<div id="completo" class="linha invisivel">Pesquisa concluida com sucesso!</div>');
						htp.p('<input id="soma" class="invisivel" value="0" />');
					end if;
				else
					htp.p('<div id="completo" class="linha">Pesquisa concluída com sucesso!</div>');
				end if;
			end if;
		else
			htp.p('<div style="font-weight: bold;" class="linha">Login inexistente! <a onclick="this.parentNode.setAttribute(''class'',''invisivel''); document.getElementById(''login'').setAttribute(''class'',''visivel'');">Tentar novamente</a></div>');
			htp.p('<div id="login" class="invisivel">');
				htp.p('<form autocomplete="on" onSubmit="document.getElementById(''erro'').setAttribute(''class'',''invisivel''); x = document.getElementById(''senha'').value; if(x.length < 1){ document.getElementById(''erro'').setAttribute(''class'',''visivel''); } else { inject_html(''dwu.sac.avaliacao?senha=''+x); document.getElementById(''login'').setAttribute(''class'',''invisivel''); } return false;">');
					htp.p('<span>Senha: </span><input id="senha" type="password" />');
				htp.p('</form>');
				htp.p('<a class="acessar" onclick="document.getElementById(''erro'').setAttribute(''class'',''invisivel''); x = document.getElementById(''senha'').value; if(x.length < 1){ document.getElementById(''erro'').setAttribute(''class'',''visivel''); } else { inject_html(''dwu.sac.avaliacao?senha=''+x); document.getElementById(''login'').setAttribute(''class'',''invisivel''); }">Acessar</a>'); 
				htp.p('<small id="erro" class="invisivel">Acesso negado, favor preencher o campo de senha!</small>');
			htp.p('</div>');
			htp.p('<div id="conteudo"></div>');
		end if;
	
	end avaliacao;
	
	--PROCEDURE DAS PERGUNTAS
	
	procedure perguntas( senha integer ) as
		
		cursor crs_perguntas is select * from QUESTAO_AVALIACAO;
		ws_questao	crs_perguntas%rowtype;
		
		cursor crs_avaliacoes is select * from AVALIACAO;
		ws_avaliacao crs_avaliacoes%rowtype;
		
		n_exist integer;
		exist_pergunta integer;
		count_questao integer;
		count_completo integer;
	
	begin
	
		select count(*) into n_exist from SENHA  where trim(senha) = trim(CD_SENHA);
		select count(*) into exist_pergunta from QUESTAO_AVALIACAO;
		if(n_exist = 1) then
			select * into ws_avaliacao from AVALIACAO  where trim(senha) = trim(CD_SENHA);
			count_questao := 0;
			htp.p('<ul id="perguntas">');			
				for ws_questao in (select * from QUESTAO_AVALIACAO order by NR_ORDEM) loop
					count_questao := count_questao+1;
					htp.p('<li id="'||count_questao||'">');
						htp.p('<h2>'||count_questao||' - '||ws_questao.ds_questao||'</h2>');
						if(ws_questao.cd_grupo = '8') then
							htp.p('<textarea id="textarea-'||ws_questao.nr_ordem||'" rows="5" cols="65"></textarea>');
								htp.p('<a id="concluir" onclick="x = document.getElementById(''textarea-'||ws_questao.nr_ordem||''').value; z = ''''; inject_db(''dwu.sac.inserir_text?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||ws_questao.cd_questao||'&nota=''+z+''&obs=''+x); document.getElementById('||count_questao||').setAttribute(''class'',''invisivel''); y = parseInt(document.getElementById(''soma'').value); y = y+1; document.getElementById(''soma'').value = y; if(y == '||exist_pergunta||'){ document.getElementById(''perguntas'').setAttribute(''class'',''invisivel''); document.getElementById(''completo'').setAttribute(''class'',''linha visivel''); } ">Concluir</a>');
						else
							htp.p('<form id="form-'||ws_questao.nr_ordem||'">');
								htp.p('<input type="radio" name="nota" value="0" />0');
								htp.p('<input type="radio" name="nota" value="1" />1');
								htp.p('<input type="radio" name="nota" value="2" />2');
								htp.p('<input type="radio" name="nota" value="3" />3');
								htp.p('<input type="radio" name="nota" value="4" />4');
								htp.p('<input type="radio" name="nota" value="5" />5');
								htp.p('<input type="radio" name="nota" value="6" />6');
								htp.p('<input type="radio" name="nota" value="7" />7');
								htp.p('<input type="radio" name="nota" value="8" />8');
								htp.p('<input type="radio" name="nota" value="9" />9');
								htp.p('<input type="radio" name="nota" value="10" />10');
								htp.p('<input type="radio" name="nota" value="99"/>N/A');
							htp.p('</form>');
							htp.p('<a id="concluir" onclick=" x = document.getElementById(''form-'||ws_questao.nr_ordem||''').elements[''nota'']; for(i=0;i<x.length;i++){ if(x[i].checked){ if(x[i].value == 99){ z = ''''; } else { z = parseInt(x[i].value); } inject_db(''dwu.sac.inserir?avaliacao='||ws_avaliacao.cd_avaliacao||'&pergunta='||ws_questao.cd_questao||'&nota=''+z); document.getElementById('||count_questao||').setAttribute(''class'',''invisivel''); y = parseInt(document.getElementById(''soma'').value); y = y+1; document.getElementById(''soma'').value = y; if(y == '||exist_pergunta||'){ document.getElementById(''perguntas'').setAttribute(''class'',''invisivel''); document.getElementById(''completo'').setAttribute(''class'',''linha visivel''); inject_db(''dwu.sac.fechar?avaliacao='||ws_avaliacao.cd_avaliacao||'''); } }}">Concluir</a>');
						end if;
					htp.p('</li>');
				end loop;
			htp.p('</ul>');
			htp.p('<div id="completo" class="linha invisivel">Todas as perguntas foram avaliadas com sucesso!</div>');
			htp.p('<input id="soma" class="invisivel" value="0" />');
		end if;
	
	end perguntas;
	
	--PROCEDURE PARA ENVIAR AO DB OS DADOS INICIAIS
	
	procedure inserir_avaliacao(senha integer,
		setor integer,
		escolaridade integer, 
		idade integer) as
		begin
			INSERT INTO AVALIACAO VALUES ('',senha, setor, escolaridade, idade, sysdate, 0);
			commit;
	end inserir_avaliacao;
	
	--PROCEDURE PARA INSERIR RESPOSTAS NO DB
	
	procedure inserir(avaliacao integer default null,
		pergunta integer,
		nota integer) as
		begin
			INSERT INTO NOTA VALUES ('', avaliacao, pergunta, nota, '');
			commit;
	end inserir;
	
	procedure inserir_text(avaliacao integer default null,
			pergunta integer,
			nota integer,
			obs varchar2 default null) as
			begin
				INSERT INTO NOTA VALUES ('', avaliacao, pergunta, '', obs);
				commit;
	end inserir_text;
	
	procedure fechar(avaliacao integer) as
		begin
			update AVALIACAO set IN_FECHA = '1' where CD_AVALIACAO = avaliacao;
		end fechar;
	
end Sac;
/
show error
exit