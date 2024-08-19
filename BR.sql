set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplicação:	Kernel Package
-- >>>>>>> Por:		Upquery Tec
-- >>>>>>> Data:	14/08/12
-- >>>>>>> Pacote:	BR (Bug Report)
-- create table bugs (ds_bug varchar2(400), situacao varchar2(400), enviado date, fechado date, prioridade varchar2(100), parecer varchar2(400))
-- alter table bugs add tipo varchar2(10);
-- >>>>>>>-------------------------------------------------------------

create or replace package Br is
	
	procedure main;
	
	procedure inserir ( prm_descricao varchar2 default null,
	                    prm_prioridade varchar2 default null,
						prm_tipo varchar2 default 'bug',
						prm_navegador varchar2 default 'Todos',
						prm_setor varchar2 default 'Outro');
						
	procedure alterar_situacao ( prm_situacao varchar2 default null, 
								 prm_descricao varchar2 default null );
								 
	procedure alterar_descricao ( prm_descricao varchar2 default null, 
								  prm_alteracao varchar2 default null );
								  
	procedure alterar_parecer ( prm_parecer varchar2 default null, 
								  prm_alteracao varchar2 default null );
	
end Br;
/

create or replace package body Br is

	procedure main as
	
		cursor crs_bugs is select code, ds_bug, situacao, enviado, fechado, prioridade, parecer, tipo, navegador, versao, setor from bugs where situacao <> 'removido' order by situacao asc, prioridade asc, enviado asc;
		ws_bug crs_bugs%rowtype;
		
		ws_datanumber number := ((to_number(to_char(sysdate, 'mm'))-1)*30)+to_number(to_char(sysdate, 'dd'));
		ws_opacity    number;
	
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
				fcl.put_css('bug_css');
				fcl.put_script('br');
			htp.headClose;
			htp.p('<body>');
				htp.p('<h1>Bug & Sugestão</h1>');
				--htp.p('<small>para a release 2.0.8</small>');
				htp.p('<div class="inserir">');
				    htp.p('<textarea id="descricao-enviar"></textarea>');
					htp.p('<select id="prioridade-enviar">');
						htp.p('<option title="EX: usabilidade, despadronizado, erros de texto">Baixa</option>');
						htp.p('<option title="EX: pequenos erros/detalhes contornaveis">Media</option>');
						htp.p('<option title="EX: telas com erro, erro em graficos e outros objetos">Alta</option>');
						htp.p('<option title="EX: calculo de colunas, resultados incorretos de formula, erro em consulta">Urgente</option>');
					htp.p('</select>');
					htp.p('<select id="tipo-enviar">');
					    htp.p('<option>Bug</option>');
						htp.p('<option>Despadronizado</option>');
						htp.p('<option>Segurança</option>');
						htp.p('<option>Sugestão</option>');
						htp.p('<option>Usabilidade</option>');
					htp.p('</select>');
					htp.p('<select id="navegador-enviar">');
					    htp.p('<option>Todos</option>');
						htp.p('<option>Chrome</option>');
						htp.p('<option>Firefox</option>');
						htp.p('<option>Internet Explorer</option>');
						htp.p('<option>Safari</option>');
						htp.p('<option>Outros</option>');
					htp.p('</select>');
					htp.p('<select id="setor-enviar">');
					    htp.p('<option>Desenvolvimento</option>');
						htp.p('<option>Teste</option>');
						htp.p('<option>Outro</option>');
					htp.p('</select>');
					htp.p('<a onclick=" descricao = encodeURIComponent(document.getElementById(''descricao-enviar'').value); prioridade = document.getElementById(''prioridade-enviar'').value; navegador = document.getElementById(''navegador-enviar'').value; var tipo = document.getElementById(''tipo-enviar'').value; var setor = document.getElementById(''setor-enviar'').value; ajax(''list'', ''dwu.br.inserir'', ''prm_descricao=''+descricao+''&prm_prioridade=''+prioridade+''&prm_tipo=''+tipo+''&prm_navegador=''+navegador+''&prm_setor=''+setor, false, ''conteudo'');">+</a>');
				htp.p('</div>');
				htp.p('<table>');
					htp.p('<thead>');
						htp.p('<tr>');
						    htp.p('<td class="versao">Versão</td>');
						    htp.p('<td class="code"></td>');
							htp.p('<td class="descricao">Descrição</td>');
							htp.p('<td class="parecer">Parecer</td>');
							htp.p('<td class="situacao">Situação</td>');
							htp.p('<td class="enviado">Enviado</td>');
							htp.p('<td class="fechado">Fechado</td>');
							htp.p('<td class="prioridade">Prioridade</td>');
							htp.p('<td class="tipo">Tipo</td>');
							htp.p('<td class="navegador">Navegador</td>');
							htp.p('<td class="setor">Setor</td>');
						htp.p('</tr>');
					htp.p('</thead>');
					htp.p('<tbody id="conteudo">');
					open crs_bugs;
						loop
							fetch crs_bugs into ws_bug;
							exit when crs_bugs%notfound;
                            if(ws_bug.situacao <> 'fechado' and ws_bug.situacao <> 'inconclusivo') then
							    htp.p('<tr>');
								    htp.p('<td class="versao">'||ws_bug.versao||'</td>');
									htp.p('<td class="code">#'||ws_bug.code||'</td>');
									htp.p('<td class="descricao">'||ws_bug.ds_bug||'</td>');
									htp.p('<td class="parecer">'||ws_bug.parecer||'</td>');
									htp.p('<td class="situacao">');
                                            htp.p('<select onchange="ajax(''fly'', ''dwu.br.alterar_situacao'', ''prm_situacao=''+this.value+''&prm_descricao=''+encodeURIComponent('''||ws_bug.ds_bug||'''))">');
                                                if ws_bug.situacao = 'aberto' then
												    htp.p('<option value="aberto" selected>aberto</option>');
												else
												    htp.p('<option value="aberto">aberto</option>');
												end if;
												if ws_bug.situacao = 'fechado' then
												    htp.p('<option value="fechado" selected>fechado</option>');
												else
												    htp.p('<option value="fechado">fechado</option>');
												end if;
												if ws_bug.situacao = 'inconclusivo' then
												    htp.p('<option value="inconclusivo" selected>inconclusivo</option>');
												else
												    htp.p('<option value="inconclusivo">inconclusivo</option>');
												end if;
												if ws_bug.situacao = 'removido' then
												    htp.p('<option value="removido" selected>removido</option>');
												else
												    htp.p('<option value="removido">removido</option>');
												end if;
											htp.p('</select></td>');
									if ws_datanumber > ((to_number(to_char(ws_bug.enviado, 'mm'))-1)*30)+to_number(to_char(ws_bug.enviado, 'dd'))+4 and ws_bug.situacao <> 'fechado' then
										htp.p('<td class="enviado atrasado">'||to_char(ws_bug.enviado, 'dd/mm/yyyy')||'</td>');
									else
										htp.p('<td class="enviado">'||to_char(ws_bug.enviado, 'dd/mm/yyyy')||'</td>');
									end if;
									htp.p('<td class="fechado">'||to_char(ws_bug.fechado, 'dd/mm/yyyy')||'</td>');
									htp.p('<td class="prioridade">'||ws_bug.prioridade||'</td>');
									htp.p('<td class="tipo">'||ws_bug.tipo||'</td>');
									htp.p('<td class="navegador">'||ws_bug.navegador||'</td>');
									htp.p('<td class="setor">'||ws_bug.setor||'</td>');
								htp.p('</tr>');	
							else
							    if ws_datanumber < (((to_number(to_char(ws_bug.fechado, 'mm'))-1)*30)+to_number(to_char(ws_bug.fechado, 'dd')))+4 then							
									ws_opacity := 1-((ws_datanumber-((((to_number(to_char(ws_bug.fechado, 'mm'))-1)*30)+to_number(to_char(ws_bug.fechado, 'dd')))))*2/10);
						            htp.p('<tr style="opacity: '||ws_opacity||';">');
										htp.p('<td class="versao">'||ws_bug.versao||'</td>');
										htp.p('<td class="code">#'||ws_bug.code||'</td>');
										htp.p('<td class="descricao" >'||ws_bug.ds_bug||'</td>');
										htp.p('<td class="parecer">'||ws_bug.parecer||'</td>');
										htp.p('<td class="situacao">');
                                            htp.p('<select onchange="ajax(''fly'', ''dwu.br.alterar_situacao'', ''prm_situacao=''+this.value+''&prm_descricao=''+encodeURIComponent('''||ws_bug.ds_bug||'''))">');
                                                if ws_bug.situacao = 'aberto' then
												    htp.p('<option value="aberto" selected>aberto</option>');
												else
												    htp.p('<option value="aberto">aberto</option>');
												end if;
												if ws_bug.situacao = 'fechado' then
												    htp.p('<option value="fechado" selected>fechado</option>');
												else
												    htp.p('<option value="fechado">fechado</option>');
												end if;
												if ws_bug.situacao = 'inconclusivo' then
												    htp.p('<option value="inconclusivo" selected>inconclusivo</option>');
												else
												    htp.p('<option value="inconclusivo">inconclusivo</option>');
												end if;
												if ws_bug.situacao = 'removido' then
												    htp.p('<option value="removido" selected>removido</option>');
												else
												    htp.p('<option value="removido">removido</option>');
												end if;
											htp.p('</select></td>');
										if ws_datanumber > ((to_number(to_char(ws_bug.enviado, 'mm'))-1)*30)+to_number(to_char(ws_bug.enviado, 'dd'))+4 and ws_bug.situacao <> 'fechado' then
											htp.p('<td class="enviado atrasado">'||to_char(ws_bug.enviado, 'dd/mm/yyyy')||'</td>');
										else
											htp.p('<td class="enviado">'||to_char(ws_bug.enviado, 'dd/mm/yyyy')||'</td>');
										end if;
										htp.p('<td class="fechado">'||to_char(ws_bug.fechado, 'dd/mm/yyyy')||'</td>');
										htp.p('<td class="prioridade">'||ws_bug.prioridade||'</td>');
										htp.p('<td class="tipo">'||ws_bug.tipo||'</td>');
										htp.p('<td class="navegador">'||ws_bug.navegador||'</td>');
										htp.p('<td class="setor">'||ws_bug.setor||'</td>');
									htp.p('</tr>');
								end if;
							end if;
						end loop;
					close crs_bugs;
					htp.p('</tbody>');
				htp.p('</table>');
			htp.p('</body>');
		htp.p('</html>');
	end main;
	
	procedure inserir ( prm_descricao varchar2 default null,
	                    prm_prioridade varchar2 default null,
						prm_tipo varchar2 default 'bug',
						prm_navegador varchar2 default 'Todos',
						prm_setor varchar2 default 'Outro') as
	
	    cursor crs_bugs is select code, ds_bug, situacao, enviado, fechado, prioridade, parecer, tipo, navegador, versao, setor from bugs where situacao <> 'removido' order by situacao asc, prioridade desc, enviado asc;
		ws_bug crs_bugs%rowtype;
		
		ws_datanumber number := ((to_number(to_char(sysdate, 'mm'))-1)*30)+to_number(to_char(sysdate, 'dd'));
	    ws_opacity    number;
		ws_next_code  number;
		
	begin
	    select max(code)+1 into ws_next_code from bugs;
		insert into bugs values(prm_descricao, 'aberto', sysdate, '', prm_prioridade, '', prm_tipo, ws_next_code, prm_navegador, '1.3.1', prm_setor);
		commit;
		
	open crs_bugs;
		loop
			fetch crs_bugs into ws_bug;
			exit when crs_bugs%notfound;
                if(ws_bug.situacao <> 'fechado' and ws_bug.situacao <> 'inconclusivo') then
					htp.p('<tr>');
					    htp.p('<td class="versao">'||ws_bug.versao||'</td>');
						htp.p('<td class="code">#'||ws_bug.code||'</td>');
						htp.p('<td class="descricao" contenteditable="true" value="'||ws_bug.ds_bug||'" onblur=" valor = this.innerHTML; ajax(''fly'', ''dwu.br.alterar_descricao'', ''prm_descricao='||ws_bug.ds_bug||'&prm_alteracao=''+valor); ">'||ws_bug.ds_bug||'</td>');
						htp.p('<td class="parecer" contenteditable="true" value="'||ws_bug.parecer||'">'||ws_bug.parecer||'</td>');
						
						htp.p('<td class="situacao">');
                                            htp.p('<select onchange="ajax(''fly'', ''dwu.br.alterar_situacao'', ''prm_situacao=''+this.value+''&prm_descricao=''+encodeURIComponent('''||ws_bug.ds_bug||'''))">');
                                                if ws_bug.situacao = 'aberto' then
												    htp.p('<option value="aberto" selected>aberto</option>');
												else
												    htp.p('<option value="aberto">aberto</option>');
												end if;
												if ws_bug.situacao = 'fechado' then
												    htp.p('<option value="fechado" selected>fechado</option>');
												else
												    htp.p('<option value="fechado">fechado</option>');
												end if;
												if ws_bug.situacao = 'inconclusivo' then
												    htp.p('<option value="inconclusivo" selected>inconclusivo</option>');
												else
												    htp.p('<option value="inconclusivo">inconclusivo</option>');
												end if;
												if ws_bug.situacao = 'inconclusivo' then
												    htp.p('<option value="removido" selected>removido</option>');
												else
												    htp.p('<option value="removido">removido</option>');
												end if;
											htp.p('</select></td>');
						
						
						--htp.p('<td class="situacao '||ws_bug.situacao||'" onclick=" if(this.innerHTML == ''aberto''){ this.innerHTML = ''fechado''; this.style.color=''#FF9900''; this.title = ''fechado''; } else { if(this.innerHTML == ''fechado''){ this.innerHTML = ''removido''; this.title = ''removido''; this.style.color=''#CC0000''; } else { this.innerHTML = ''aberto''; this.title = ''aberto''; this.style.color=''#000000''; } } ajax(''fly'', ''dwu.br.alterar_situacao'', ''prm_situacao=''+this.title+''&prm_descricao='||ws_bug.ds_bug||'''); ">'||ws_bug.situacao||'</td>');
						if ws_datanumber > ((to_number(to_char(ws_bug.fechado, 'mm'))-1)*30)+to_number(to_char(ws_bug.fechado, 'dd'))+4 and ws_bug.situacao <> 'fechado' then
							htp.p('<td class="enviado atrasado">'||to_char(ws_bug.enviado, 'dd/mm/yyyy')||'</td>');
						else
							htp.p('<td class="enviado">'||to_char(ws_bug.enviado, 'dd/mm/yyyy')||'</td>');
						end if;
						htp.p('<td class="fechado">'||to_char(ws_bug.fechado, 'dd/mm/yyyy')||'</td>');
						htp.p('<td class="prioridade">'||ws_bug.prioridade||'</td>');
						htp.p('<td class="tipo">'||ws_bug.tipo||'</td>');
						htp.p('<td class="navegador">'||ws_bug.navegador||'</td>');
						htp.p('<td class="setor">'||ws_bug.setor||'</td>');
					htp.p('</tr>');	
				else
					if ws_datanumber < (((to_number(to_char(ws_bug.fechado, 'mm'))-1)*30)+to_number(to_char(ws_bug.fechado, 'dd')))+4 then		
						ws_opacity := 1-((ws_datanumber-((((to_number(to_char(ws_bug.fechado, 'mm'))-1)*30)+to_number(to_char(ws_bug.fechado, 'dd')))))*2/10);
						htp.p('<tr style="opacity: '||ws_opacity||';">');
						    htp.p('<td class="versao">'||ws_bug.versao||'</td>');
							htp.p('<td class="code">#'||ws_bug.code||'</td>');
							htp.p('<td class="descricao" contenteditable="true" value="'||ws_bug.ds_bug||'" onblur=" valor = this.innerHTML; ajax(''fly'', ''dwu.br.alterar_descricao'', ''prm_descricao='||ws_bug.ds_bug||'&prm_alteracao=''+valor); ">'||ws_bug.ds_bug||'</td>');
							htp.p('<td class="parecer" contenteditable="true" value="'||ws_bug.parecer||'">'||ws_bug.parecer||'</td>');
							
							htp.p('<td class="situacao">');
                                            htp.p('<select onchange="ajax(''fly'', ''dwu.br.alterar_situacao'', ''prm_situacao=''+this.value+''&prm_descricao=''+encodeURIComponent('''||ws_bug.ds_bug||'''))">');
                                                if ws_bug.situacao = 'aberto' then
												    htp.p('<option value="aberto" selected>aberto</option>');
												else
												    htp.p('<option value="aberto">aberto</option>');
												end if;
												if ws_bug.situacao = 'fechado' then
												    htp.p('<option value="fechado" selected>fechado</option>');
												else
												    htp.p('<option value="fechado">fechado</option>');
												end if;
												if ws_bug.situacao = 'inconclusivo' then
												    htp.p('<option value="inconclusivo" selected>inconclusivo</option>');
												else
												    htp.p('<option value="inconclusivo">inconclusivo</option>');
												end if;
												if ws_bug.situacao = 'inconclusivo' then
												    htp.p('<option value="removido" selected>removido</option>');
												else
												    htp.p('<option value="removido">removido</option>');
												end if;
											htp.p('</select></td>');
							
							--htp.p('<td class="situacao '||ws_bug.situacao||'" onclick=" if(this.innerHTML == ''aberto''){ this.innerHTML = ''fechado''; this.style.color=''#FF9900''; this.title = ''fechado''; } else { if(this.innerHTML == ''fechado''){ this.innerHTML = ''removido''; this.title = ''removido''; this.style.color=''#CC0000''; } else { this.innerHTML = ''aberto''; this.title = ''aberto''; this.style.color=''#000000''; } } ajax(''fly'', ''dwu.br.alterar_situacao'', ''prm_situacao=''+this.title+''&prm_descricao='||ws_bug.ds_bug||'''); ">'||ws_bug.situacao||'</td>');
							if ws_datanumber > ((to_number(to_char(ws_bug.fechado, 'mm'))-1)*30)+to_number(to_char(ws_bug.fechado, 'dd'))+4 and ws_bug.situacao <> 'fechado' then
								htp.p('<td class="enviado atrasado">'||to_char(ws_bug.enviado, 'dd/mm/yyyy')||'</td>');
							else
								htp.p('<td class="enviado">'||to_char(ws_bug.enviado, 'dd/mm/yyyy')||'</td>');
							end if;
							htp.p('<td class="fechado">'||to_char(ws_bug.fechado, 'dd/mm/yyyy')||'</td>');
							htp.p('<td class="prioridade">'||ws_bug.prioridade||'</td>');
							htp.p('<td class="tipo">'||ws_bug.tipo||'</td>');
							htp.p('<td class="navegador">'||ws_bug.navegador||'</td>');
							htp.p('<td class="setor">'||ws_bug.setor||'</td>');
						htp.p('</tr>');
						end if;
					end if;
					
		end loop;
	close crs_bugs;
	
	end inserir;
	
	procedure alterar_situacao ( prm_situacao varchar2 default null, 
								 prm_descricao varchar2 default null ) as
	begin
		update bugs set situacao = prm_situacao where ds_bug = prm_descricao;
		case prm_situacao
		    when 'fechado' then
			    update bugs set fechado = sysdate where ds_bug = prm_descricao;
			when 'inconclusivo' then
			    update bugs set fechado = sysdate where ds_bug = prm_descricao;
		    when 'removido' then
			    update bugs set fechado = sysdate where ds_bug = prm_descricao;
			else
			    update bugs set fechado = '' where ds_bug = prm_descricao;
		end case;
	end alterar_situacao;
	
	procedure alterar_descricao ( prm_descricao varchar2 default null, prm_alteracao varchar2 default null ) as
	begin
		update bugs set ds_bug = prm_alteracao where ds_bug = prm_descricao;
	end alterar_descricao;
	
	procedure alterar_parecer ( prm_parecer varchar2 default null, prm_alteracao varchar2 default null ) as
	begin
		update bugs set parecer = prm_alteracao where ds_bug = prm_parecer;
	end alterar_parecer;
	
end Br;
/
show error
exit