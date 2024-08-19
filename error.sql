set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplica��o: Error list
-- >>>>>>> Por:		Upquery
-- >>>>>>> Data:	09/07/15
-- >>>>>>> Pacote:	Error
-- >>>>>>>-------------------------------------------------------------

create or replace package error is
	
	procedure main;
	
end error;
/

create or replace package body error is

	procedure main as
	
	cursor crs_erros is
	select name, type, text, attribute, line LINHA_ERRO, position POSICAO_ERRO 
	from USER_ERRORS
    order by name, sequence;
	
	ws_erro crs_erros%rowtype;


begin

	htp.p('<table class="lista">');
		htp.p('<thead>');
		    htp.p('<tr>');
			    htp.p('<th>NOME</th>');
				htp.p('<th>TIPO</th>');
				htp.p('<th>TEXTO</th>');
				htp.p('<th>ATRIBUTO</th>');
				htp.p('<th>LINHA</th>');
				htp.p('<th>POSICAO</th>');
			htp.p('<tr>');
		htp.p('</thead>');
		htp.p('<tbody>');
		open crs_erros;
			loop
				fetch crs_erros into ws_erro;
				exit when crs_erros%notfound;
					htp.p('<tr>');
						htp.p('<td>'||ws_erro.name||'</td>');
						htp.p('<td>'||ws_erro.type||'</td>');
						htp.p('<td>'||ws_erro.text||'</td>');
						htp.p('<td>'||ws_erro.attribute||'</td>');
						htp.p('<td>'||ws_erro.LINHA_ERRO||'</td>');
						htp.p('<td>'||ws_erro.POSICAO_ERRO||'</td>');
					htp.p('</tr>');
			end loop;
		close crs_erros;
	    htp.p('</tbody>');
    htp.p('</table>');
    end main;
	
end error;
/
show error
exit