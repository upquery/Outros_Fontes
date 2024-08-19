set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplicação: Tradução Colunas
-- >>>>>>> Por:		Upquery Tec (João)
-- >>>>>>> Data:	03/03/14
-- >>>>>>> Pacote:	T.C 1.0
-- >>>>>>>-------------------------------------------------------------

create or replace package TC is
	
	procedure main;
					 
	procedure update_language ( prm_default varchar2 default null,
	                            prm_texto varchar2 default null,
								prm_linguagem varchar2 default null );
	
	
end TC;
/

create or replace package body TC is

	procedure main as
	
	    cursor crs_padroes is 
	    select cd_tabela, cd_coluna, cd_linguagem, texto, (SELECT TEXTO
        FROM   TRADUCAO_COLUNAS ING 
        WHERE  ING.CD_LINGUAGEM='ENGLISH' AND
               ING.LANG_DEFAULT=PTG.LANG_DEFAULT AND
               ING.CD_TABELA=PTG.CD_TABELA AND
               ING.CD_COLUNA=PTG.CD_COLUNA) AS INGLES 
	    from traducao_colunas PTG where CD_LINGUAGEM='PORTUGUESE'
	    order by tipo, cd_tabela, cd_coluna, texto;
		ws_padrao crs_padroes%rowtype;	
		ws_count number;
	
		begin
		htp.p('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
		htp.p('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">');
			htp.headOpen;
				htp.p('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
				htp.p('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
				htp.p('<TITLE>Tradução de Colunas</TITLE>');
				htp.p('<META HTTP-EQUIV="Pragma" CONTENT="no-cache">');
				htp.p('<META HTTP-EQUIV="Expires" CONTENT="-1">');
				htp.p('<META NAME="apple-mobile-web-app-capable" CONTENT="yes">');
				htp.p('<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">');
				fcl.put_script('tc');
				fcl.put_css('reset');
				fcl.put_css('tc');
			htp.headClose;
			htp.p('<body>');
			
	    --htp.p('<h2>TRADUÇÃO DE COLUNAS</h2>');
		htp.p('<table class="linha" style="margin: 0 auto;">');
		   htp.p('<thead>');
		   htp.p('<tr>');
		       htp.p('<th style="width: 50%;">PORTUGUES</th>');
			   htp.p('<th style="width: 50%;">INGLES</th>');
		   htp.p('</tr>');
		   htp.p('</thead>');
		   htp.p('<tbody>');
				open crs_padroes;
					loop
						fetch crs_padroes into ws_padrao;
						exit when crs_padroes%notfound;
						
						htp.p('<tr>');
							htp.p('<td style="width: 50%; white-space: nowrap; max-width: 300px; text-overflow: ellipsis; overflow: hidden;" title="'||ws_padrao.texto||'">'||ws_padrao.texto||'</td>');
							htp.p('<td style="width: 50%"><input type="text" class="'||ws_padrao.ingles||'" value="'||ws_padrao.ingles||'" onblur="if(this.value != this.className){ if(this.value.trim().length > 0){ ajax(''fly'', ''dwu.tc.update_language'', ''prm_default='||ws_padrao.texto||'&prm_texto=''+this.value+''&prm_linguagem=ENGLISH''); noerror(''TRADUÇÃO ALTERADA COM SUCESSO!'', '''||ws_padrao.texto||'-alert''); this.setAttribute(''class'', this.value); } else { alerta('''||ws_padrao.texto||'-alert'', ''NÃO PODE ESTAR EM BRANCO!'') }}"/></td>');
						htp.p('</tr>');
						
						htp.p('<tr><td></td><td class="alert" id="'||ws_padrao.texto||'-alert"></td></tr>');
					end loop;
				close crs_padroes;
				htp.p('</tbody>');
				htp.p('</table>');
				
			htp.p('</body>');
		htp.p('</html>');
	end main;
	
	procedure update_language ( prm_default varchar2 default null,
	                            prm_texto varchar2 default null,
								prm_linguagem varchar2 default null ) as
								
	    ws_count number;
		ws_duplicada exception;
												
	begin
	
	    select count(*) into ws_count 
		from traducao_colunas 
		where lang_default = prm_default and
		cd_linguagem = prm_linguagem;
		
		if ws_count = 1 then
			update traducao_colunas 
			set texto = prm_texto
			where lang_default = prm_default and
			cd_linguagem = prm_linguagem;
		elsif ws_count = 0 then
		    insert into traducao_colunas 
			values ((select cd_tabela from traducao_colunas where cd_linguagem = 'PORTUGUESE' and lang_default = prm_default), 
			(select cd_coluna from traducao_colunas where cd_linguagem = 'PORTUGUESE' and lang_default = prm_default), 
			prm_linguagem, prm_texto, prm_default, 
			(select tipo from traducao_colunas where cd_linguagem = 'PORTUGUESE' and lang_default = prm_default), 'N');
		else
		    raise ws_duplicada;
		end if;
		
	
	exception 
	    when ws_duplicada then
		    htp.p(prm_default);
	    when others then
	        htp.p(sqlerrm);
	end update_language;


end TC;
/
show error
exit