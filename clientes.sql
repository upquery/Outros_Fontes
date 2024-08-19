set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplicação:	Kernel Package
-- >>>>>>> Por:		Upquery Tec
-- >>>>>>> Data:	21/09/2015
-- >>>>>>> Pacote:	CLIENTES

-- >>>>>>>-------------------------------------------------------------

create or replace package cliente is
	
	procedure main;

end cliente;
/

create or replace package body cliente is

	procedure main as
	
		cursor crs_clientes is select cliente, url, versao, info, telefone, classe, responsavel from clientes order by cliente;
		ws_cliente crs_clientes%rowtype;

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
				fcl.put_css('reset');
				fcl.put_css('default');
				fcl.put_css('expand');
				htp.p('<style>html { overflow: auto; } tr.off { text-decoration: line-through; } </style>');
			htp.headClose;
			htp.p('<body style="margin: 10px; border: 1px solid #000; width: calc(100% - 30px); padding: 5px; font-size: 22px; font-weight: bold;">');
				htp.p('<h1>LISTA DE CLIENTES</h1>');
				
				htp.p('<table class="linha">');
					htp.p('<thead>');
						htp.p('<tr>');
						    htp.p('<td>CLIENTE</td>');
							htp.p('<td>VERSÃO</td>');
							htp.p('<td>TELEFONE</td>');
							htp.p('<td>RESPONSAVEL</td>');
							htp.p('<td>INFORMAÇÃO</td>');
						htp.p('</tr>');
					htp.p('</thead>');
					htp.p('<tbody>');
					open crs_clientes;
						loop
							fetch crs_clientes into ws_cliente;
							exit when crs_clientes%notfound;
                                htp.p('<tr class="'||ws_cliente.classe||'">');
									htp.p('<td><a class="link" style="color: #CC0000 !important; " href="'||ws_cliente.url||'">'||upper(ws_cliente.cliente)||'</a></td>');
									htp.p('<td>'||ws_cliente.versao||'</td>');
									htp.p('<td><a class="link" href="tel:'||ws_cliente.telefone||'">'||ws_cliente.telefone||'</a></td>');
									htp.p('<td>'||ws_cliente.responsavel||'</td>');
									htp.p('<td>'||ws_cliente.info||'</td>');
								htp.p('</tr>');
						end loop;
					close crs_clientes;
					htp.p('</tbody>');
				htp.p('</table>');
			htp.p('</body>');
		htp.p('</html>');
	end main;
	
end cliente;
/
show error
exit