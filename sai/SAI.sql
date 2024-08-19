set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplicação: Avaliação Interna
-- >>>>>>> Por:		Upquery Tec
-- >>>>>>> Data:	18/04/12
-- >>>>>>> Pacote:	S.A.I (Sistema de Avaliação Interna)
-- >>>>>>>-------------------------------------------------------------

create or replace package Sai is
	
	procedure main;
	
	procedure avaliacao (value1	varchar default null,
		             value2	varchar default null );
		         
	procedure inserir(avaliacao integer,
					  questao integer,
					  nota number default null, 
				      obs varchar2);
				   
	procedure fechar(avaliacao integer);
	
end Sai;
/

create or replace package body Sai is

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
				fcl.put_css('sai_css');
			htp.headClose;
			htp.p('<body>');
			ws_count := 0;
				htp.p('<div id="avaliacao">');
					htp.p('<h1>SISTEMA DE AVALIAÇÃO INTERNA</h1>');
					htp.p('<div id="login">');
						htp.p('<form autocomplete="on">');
							htp.p('<span>Usuário: </span><input id="usuario" type="text" name="funcionario"/>');
							htp.p('<span>Senha: </span><input id="senha" type="password" name="senha" onkeydown=""/>');
						htp.p('</form>');
						htp.p('<a class="acessar" onclick="document.getElementById(''msg0'').setAttribute(''class'',''invisivel''); document.getElementById(''msg1'').setAttribute(''class'',''invisivel''); document.getElementById(''msg2'').setAttribute(''class'',''invisivel''); x = document.getElementById(''usuario'').value; y = document.getElementById(''senha'').value; if(x.length < 1){ if(y.length < 1){ document.getElementById(''msg0'').setAttribute(''class'',''msg''); } else {document.getElementById(''msg1'').setAttribute(''class'',''msg''); }} else if(y.length < 1) { document.getElementById(''msg2'').setAttribute(''class'',''msg''); } else { inject_html('||chr(39)||'dwu.sai.avaliacao?value1=''+x+''&value2='||chr(39)||'+y); document.getElementById(''login'').setAttribute(''class'',''invisivel''); }">Acessar</a>');
						htp.p('<small id="msg0" class="invisivel">Acesso negado, favor preencher os campos de usuário e senha!</small>'); 
						htp.p('<small id="msg1" class="invisivel">Acesso negado, favor preencher o campo de usuário!</small>');
						htp.p('<small id="msg2" class="invisivel">Acesso negado, favor preencher o campo de senha!</small>');
					htp.p('</div>');
					htp.p('<div id="conteudo"></div>');	
				htp.p('</div>');
			htp.p('</body>');
		htp.p('</html>');
	end main;

	procedure avaliacao ( value1 varchar default null,
					      value2 varchar default null ) as

		cursor crs_avaliados is select * from TEST_PROFFORM where trim(value2) = trim(CD_AVALIADOR);
		ws_avaliados	crs_avaliados%rowtype;
		
		cursor crs_form is select * from TEST_PROFFORM;
		ws_form	crs_form%rowtype;

		cursor crs_avaliado is	select * from TEST_PROFISSIONAL;
		ws_avaliado crs_avaliado%rowtype;
		
		cursor crs_questoes is select * from TEST_QUESTAO_AVALIACAO;	
		ws_questao crs_questoes%rowtype;
		
		cursor crs_formulario is select * from TEST_FORMULARIO;
		ws_formulario crs_formulario%rowtype;
		
		cursor crs_avaliacoes is select * from TEST_AVALIACAO;
		ws_avaliacao crs_avaliacoes%rowtype;
		
		ws_profissional integer;
		ws_count integer;
		ws_exist integer;
		ws_exist2 integer;
		ws_count2 integer;
		ws_count3 integer;
		ws_count4 integer;
		ws_count5 integer;
		ws_count6 integer;

	begin
	
		
		select count(*) into ws_exist from TEST_AVALIADOR
		where trim(CD_AVALIADOR) = trim(value2) and trim(DS_AVALIADOR) = trim(value1);
		if(ws_exist = 1) then
			select count(*) into ws_exist2 from TEST_AVALIACAO
			where trim(CD_AVALIADOR) = trim(value2) and trim(IN_FECHA) = 1;
			if(ws_exist2 <> 0) then
				htp.p('<h2 id="completo" class="visivel">FORMULÁRIO CONCLUÍDO</h2>');
			else
				htp.p('<h2 id="completo" class="invisivel">FORMULÁRIO CONCLUÍDO</h2>');
			end if;
			select count(*) into ws_profissional from TEST_PROFFORM
			where trim(CD_AVALIADOR) = trim(value2);
			ws_count := 0;
			htp.p('<ul id="avaliados">');
				open crs_avaliados;
					loop
						fetch crs_avaliados into ws_avaliados;
						exit when crs_avaliados%notfound;
						ws_count := ws_count+1;
						if(mod(ws_count,2) = 0) then
							if(ws_profissional = ws_count) then
								htp.p('<li class="last even">');
							else
								htp.p('<li class="even">');
							end if;
						else
							if(ws_profissional = ws_count) then
								htp.p('<li class="last odd">');
							else
								htp.p('<li class="odd">');
							end if;
						end if;
						select * into ws_avaliado from TEST_PROFISSIONAL where trim(CD_PROFISSIONAL) = trim(ws_avaliados.cd_profissional);
						select * into ws_form from TEST_PROFFORM where trim(CD_PROFISSIONAL) = trim(ws_avaliado.cd_profissional) and trim(CD_AVALIADOR) = trim(value2);
						select * into ws_formulario from TEST_FORMULARIO where trim(CD_FORMULARIO) = trim(ws_form.cd_formulario);
						select count(*) into ws_count3 from TEST_AVALIACAO where trim(CD_AVALIADOR) = trim(value2) and trim(CD_PROFISSIONAL) = trim(ws_avaliado.cd_profissional);
						if(ws_count3 <> 0 ) then
							select * into ws_avaliacao from TEST_AVALIACAO where trim(CD_AVALIADOR) = trim(value2) and trim(CD_PROFISSIONAL) = trim(ws_avaliado.cd_profissional);
						else
							INSERT INTO TEST_AVALIACAO VALUES ((NVL((SELECT MAX(CD_AVALIACAO) FROM TEST_AVALIACAO),1)+1), trim(value2), trim(ws_avaliado.cd_profissional), trim(ws_form.cd_formulario), sysdate,'0');
							commit; 
							select * into ws_avaliacao from TEST_AVALIACAO where trim(CD_AVALIADOR) = trim(value2) and trim(CD_PROFISSIONAL) = trim(ws_avaliado.cd_profissional);
						end if;
							htp.p('<div class="nome">Funcionário: '||ws_avaliado.ds_profissional||' ('||ws_formulario.ds_formulario||')</div>');
							if (ws_avaliacao.in_fecha = 1) then
								htp.p('<div id="avaliar-'||ws_count||'" class="avaliar"><span>Avaliado</span></div>');
							else
								htp.p('<div id="avaliar-'||ws_count||'" class="avaliar"><a title="Avaliar o funcionário '||ws_avaliado.ds_profissional||', responder questionário." id="avaliar" onclick=" questoes = document.getElementById('''||ws_avaliado.ds_profissional||'-questoes''); if(questoes.getAttribute(''class'') == ''invisivel''){ questoes.setAttribute(''class'',''visivel''); } else { questoes.setAttribute(''class'',''invisivel''); };">Avaliar</a></div>');
								htp.p('<div id="'||ws_avaliado.ds_profissional||'-questoes" class="invisivel" >');
								--ws_count5 := 1;
								for ws_questao in (select * from TEST_QUESTAO_AVALIACAO where trim(CD_FORMULARIO) = trim(ws_avaliados.cd_formulario)) loop
									htp.p('<div class="linha">');
										htp.p('<div class="em-linha">Pergunta: '||ws_questao.ds_questao||'	</div>');
										select count(*) into ws_count4 from TEST_NOTA_AVALIACAO where trim(CD_AVALIACAO) = trim(ws_avaliacao.cd_avaliacao) and trim(CD_QUESTAO) = trim(ws_questao.cd_questao);
										if(ws_count4 = 0) then
											htp.p('<div id="'||ws_questao.cd_questao||'-'||ws_avaliado.ds_profissional||'-campo">');
												htp.p('<form id="'||ws_questao.cd_questao||'-'||ws_avaliado.ds_profissional||'-nota">');
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
												htp.p('<div class="titulo">Comentário</div><textarea id="'||ws_questao.cd_questao||'-'||ws_avaliado.ds_profissional||'-comentario" rows="5" cols="65" onfocus="if(this.value==''Digite seu comentário''){ this.value=''''; this.style.color=''#000''; }" onblur=" if(this.value == ''''){ this.value=''Digite seu comentário'';  this.style.color=''#666'';} else { this.style.color=''#000''; document.getElementById('''||ws_questao.cd_questao||'-'||ws_avaliado.ds_profissional||'-alerta'').setAttribute(''class'',''invisivel''); }">Digite seu comentário</textarea>');
												htp.p('<small class="invisivel" id="'||ws_questao.cd_questao||'-'||ws_avaliado.ds_profissional||'-alerta">Nota abaixo de 7 é obrigatório preenchimento do comentário</small>');	
											htp.p('</div>');
											htp.p('<big><a class="concluir '||ws_count||'" onclick=" validate('''||ws_questao.cd_questao||''', '''||ws_avaliado.ds_profissional||''', '''||ws_avaliacao.cd_avaliacao||''', '''||ws_count||''', '''||ws_profissional||'''); ">Concluir</a></big>');
										else
											htp.p('<big><a class="concluido" name="concluido">Concluido</a></big>');
										end if;
									htp.p('</div>');
									--ws_count5 := ws_count5+1;
								end loop;
							htp.p('</div>');
						end if;
						htp.p('</li>');
					end loop;
				close crs_avaliados;
			htp.p('</ul>');
		else
			htp.p('<small class="msg" id="msg3">Usuário ou senha incorretos!<a onclick="document.getElementById(''login'').setAttribute(''class'',''invisivel''); document.getElementById(''msg3'').setAttribute(''class'',''invisivel''); ">Tentar novamente</a></small>');
		end if;
	end avaliacao;
	
	procedure inserir(avaliacao integer,
	questao integer,
	nota number default null, 
	obs varchar2) as
	begin
		INSERT INTO TEST_NOTA_AVALIACAO VALUES (avaliacao, questao, nota, obs);
		commit;
	end inserir;
	
	procedure fechar(avaliacao integer) as
		begin
			UPDATE TEST_AVALIACAO set IN_FECHA = 1, DT_AVALIACAO = sysdate where trim(CD_AVALIACAO) = avaliacao;
			commit;
	end fechar;
	
end Sai;
/
show error
exit