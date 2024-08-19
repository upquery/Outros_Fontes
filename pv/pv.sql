set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplicação: Ponto Venda
-- >>>>>>> Por:		Upquery Tec (João)
-- >>>>>>> Data:	26/03/14
-- >>>>>>> Pacote:	P.V 1.0
-- >>>>>>>-------------------------------------------------------------

create or replace package PV is
	
	procedure main;
	
	procedure clientes ( prm_cod varchar2 default null );
	
	procedure produtos ( prm_cod varchar2 default null );
	
	procedure enviar ( prm_cliente varchar2 default null,
	                   prm_produto varchar2 default null,
					   prm_quantidade varchar2 default null, 
					   prm_preco varchar2 default null,
					   prm_entrega varchar2 default null );
					   
	procedure excluir ( prm_venda varchar2 default null );
					   
	procedure listar;
	
	procedure preencher;
	
	
end PV;
/

create or replace package body PV is

	procedure main as
	
	cursor crs_vendas is select ID_VENDA, CD_VENDEDOR, CD_CLIENTE, CD_PRODUTO, QUANTIDADE, VL_PRECO, DT_ENTREGA, DT_ENVIO, STATUS from atendimento_vendas;
	
	ws_venda crs_vendas%rowtype;
	
	begin
		htp.p('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
		htp.p('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">');
			htp.headOpen;
				htp.p('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
				htp.p('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
				htp.p('<TITLE>Ponto Venda</TITLE>');
				htp.p('<META HTTP-EQUIV="Pragma" CONTENT="no-cache">');
				htp.p('<META HTTP-EQUIV="Expires" CONTENT="-1">');
				htp.p('<META NAME="apple-mobile-web-app-capable" CONTENT="yes">');
				htp.p('<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">');
				htp.p('<meta name="viewport" content="user-scalable=0" />');
				fcl.put_script('pv');
				fcl.put_css('reset');
				fcl.put_css('pv');
			htp.headClose;
			htp.p('<body>');
			    htp.p('<div id="msg" style="z-index: 999; height: 20px; bottom: 2px; position: fixed; width: 100%; text-align: center; color: #CC0000; transition: all 0.3s linear;"></div>');
				htp.p('<div id="main">');
				htp.p('<ul class="lista">');
				    htp.p('<li class="center"><img src="http://www.mqb.com.br/imagens/BIM1.png" /></li>');
					htp.p('<li class="center" style="white-space: nowrap;">MANCHESTER QUIMICA - '||to_char(sysdate, 'DD/MM/YY')||'</li>');
					htp.p('<li class="null"> </li>');
					htp.p('<li>Cliente: <input class="right" type="text" placeholder="3 dígitos" title="no minimo 3 dígitos" onkeyup="if(this.value.length > 2){ ajax(''list'', ''dwu.pv.clientes'', ''prm_cod=''+this.value, false, ''pv-clientes''); }"/></li>');
					htp.p('<li>');
					    htp.p('<select id="pv-clientes" class="right">');
						
						htp.p('</select>');
					htp.p('</li>');
					htp.p('<li class="null"> </li>');
					htp.p('<li>Produto: <input class="right" type="text" placeholder="6 dígitos" title="no mínimo 6 dígitos" onkeyup="if(this.value.length > 5){ ajax(''list'', ''dwu.pv.produtos'', ''prm_cod=''+this.value, false, ''pv-produtos''); }"/></li>');
					htp.p('<li>');
					    htp.p('<select id="pv-produtos" class="right">');
						
						htp.p('</select>');
					htp.p('</li>');
					htp.p('<li class="null"> </li>');
					htp.p('<li>QTDE:  <input id="pv-quant" class="right" type="number" value="" placeholder="0" onkeyup="var regex = new RegExp(''^[0-9.,]+$''); if(regex.test(this.value)){ this.style.setProperty(''box-shadow'', ''0px 0px 1px 1px #00AA00''); } else { this.style.setProperty(''box-shadow'', ''0px 0px 1px 1px #CC0000''); }"/></li>');
					htp.p('<li class="null"> </li>');
					htp.p('<li>ÚLTIMO PREÇO: <span class="right">99999999,99</span></li>');
                    htp.p('<li>PREÇO: <input id="pv-preco" class="right" type="text" value="" placeholder="0,00" onkeyup="var regex = new RegExp(''^[0-9.,]+$''); if(regex.test(this.value)){ this.style.setProperty(''box-shadow'', ''0px 0px 1px 1px #00AA00''); } else { this.style.setProperty(''box-shadow'', ''0px 0px 1px 1px #CC0000''); }"/></li>');
                    htp.p('<li>ENTREGA: <input id="pv-entrega" class="right" type="date" value="12/12/2012" /></li>');
					htp.p('<li class="null"> </li>');
					htp.p('<li>TOTAL: <span class="right">99999999,99</span></li>');
					htp.p('<li class="null"> </li>');
					htp.p('<li><a class="link" onclick="var regex = new RegExp(''^[0-9.,]+$''); var cliente = document.getElementById(''pv-clientes'').value; var produto = document.getElementById(''pv-produtos'').value; var quant = document.getElementById(''pv-quant'').value; var preco = document.getElementById(''pv-preco'').value; var entrega = document.getElementById(''pv-entrega'').value; if(regex.test(quant)){ if(regex.test(preco)){ ajax(''fly'', ''dwu.pv.enviar'', ''prm_cliente=''+cliente+''&prm_produto=''+produto+''&prm_quantidade=''+quant+''&prm_preco=''+preco+''&prm_entrega=''+entrega, false); noerror('''', ''Enviado com sucesso!'', ''msg''); } else { document.getElementById(''pv-preco'').style.setProperty(''box-shadow'', ''0 0 3px 0 #CC0000''); alerta(''msg'', ''Campo preço inválido!''); } } else { document.getElementById(''pv-quant'').style.setProperty(''box-shadow'', ''0 0 3px 0 #CC0000''); alerta(''msg'', ''Campo quantidade inválido!''); }">ENVIAR</a><a class="link right">FINALIZAR</a></li>');
					htp.p('<li class="center"><a class="link" onclick="ajax(''list'', ''dwu.pv.listar'', '''', false, ''main'');">LISTAR ULTIMOS</a></li>');
				htp.p('</ul>');
					htp.p('</div>');
				htp.p('</body>');
		htp.p('</html>');
	end main;
	
	procedure clientes ( prm_cod varchar2 default null ) as
	
	    cursor crs_clientes is 
		select  cd_cliente, nm_cliente
        from taux_clientes
		where (cd_cliente like ('6-'||upper(prm_cod)||'%') or (nm_cliente like ('%'||upper(prm_cod)||'%') and cd_cliente like ('6-%'))) 
		--and cd_representante = (select conteudo from filtros_geral where cd_usuario = user and cd_coluna = 'CD_VENDEDOR' and condicao = 'IGUAL')
		order by nm_cliente;	
	
	    ws_cliente crs_clientes%rowtype; 
		
	begin
	
	    open crs_clientes;
		    loop
			    fetch crs_clientes into ws_cliente;
				exit when crs_clientes%notfound;
				htp.p('<option value="'||ws_cliente.cd_cliente||'">'||ws_cliente.nm_cliente||'</option>');
			end loop;
		close crs_clientes;
	end clientes;
	
	procedure produtos ( prm_cod varchar2 default null ) as
	
			cursor crs_produtos is 
			select cd_produto, ds_produto
			from taux_produtos
			where cd_produto like ('6-'||upper(prm_cod)||'%') or (ds_produto like ('%'||upper(prm_cod)||'%') and cd_produto like ('6-%'))
			order by ds_produto;	
		
			ws_produto crs_produtos%rowtype; 
		
	    begin
	
			open crs_produtos;
				loop
					fetch crs_produtos into ws_produto;
					exit when crs_produtos%notfound;
					htp.p('<option value="'||ws_produto.cd_produto||'">'||replace(ws_produto.cd_produto, '6-', '')||' - '||ws_produto.ds_produto||'</option>');
				end loop;
			close crs_produtos;
	end produtos;
	
	procedure enviar ( prm_cliente varchar2 default null,
	                   prm_produto varchar2 default null,
					   prm_quantidade varchar2 default null, 
					   prm_preco varchar2 default null,
					   prm_entrega varchar2 default null ) as
					   
		ws_count number;
					   
	begin
	    select count(*) into ws_count from atendimento_vendas;
	    insert into atendimento_vendas values (ws_count||to_char(sysdate, 'YYYYMMDDHHSS'),'1', prm_cliente, prm_produto, to_number(replace(prm_quantidade, ',', '.')), to_number(replace(prm_preco, ',', '.')), to_date(prm_entrega, 'DD/MM/YYYY'), sysdate, '1');
	
	end enviar;
	
	procedure excluir ( prm_venda varchar2 default null ) as
					   
	begin
	
	    delete from atendimento_vendas where id_venda = prm_venda;
	
	end excluir;
	
	procedure listar as
	
	cursor crs_vendas is 
	select id_venda, cd_vendedor, cd_cliente, cd_produto, (select ds_produto from taux_produtos tp where tp.cd_produto = av.cd_produto) as produto, quantidade, vl_preco, dt_entrega, dt_envio, status 
	from atendimento_vendas av
	where status = '1';
	
	ws_venda crs_vendas%rowtype;
	
	begin		
	htp.p('<h1 style="margin: 20px 0; text-align: center; font-weight: bold;">LISTA DE CADASTROS</h1>');
	htp.p('<table class="lista">');
	    htp.p('<thead>');
		    htp.p('<tr>');
				htp.p('<th>PRODUTO</th>');
				htp.p('<th>QUANTIDADE</th>');
				htp.p('<th>PRECO</th>');
				htp.p('<th></th>');
			htp.p('</tr>');
		htp.p('</thead>');
		htp.p('<tbody>');
			open crs_vendas;
				loop
					fetch crs_vendas into ws_venda;
					exit when crs_vendas%notfound;
					htp.p('<tr>');
						htp.p('<td title="'||ws_venda.cd_produto||'">'||ws_venda.produto||'</td>');
						htp.p('<td>'||replace(ws_venda.quantidade, '.', ',')||'</td>');
						htp.p('<td>R$ '||replace(ws_venda.vl_preco, '.', ',')||'</td>');
						htp.p('<td><a class="remove" onclick="ajax(''fly'', ''dwu.pv.excluir'', ''prm_venda='||ws_venda.id_venda||'''); noerror(this, ''Excluido com sucesso!'', ''msg'');">X</a></td>');
					htp.p('</tr>');
				end loop;
			close crs_vendas;
		htp.p('</tbody>');
	htp.p('</table>');
	htp.p('<a class="link" style="margin-top: 30px; display: block; text-align: center;" onclick="ajax(''list'', ''dwu.pv.preencher'', '''', false, ''main'');">VOLTAR</a>');
	
	end listar;
	
	procedure preencher as
	
	begin
	   htp.p('<ul class="lista">');
			htp.p('<li class="center"><img src="http://www.mqb.com.br/imagens/BIM1.png" /></li>');
			htp.p('<li class="center" style="white-space: nowrap;">MANCHESTER QUIMICA - '||to_char(sysdate, 'DD/MM/YY')||'</li>');
			htp.p('<li class="null"> </li>');
			htp.p('<li>Cliente: <input class="right" type="text" placeholder="4 dígitos" title="no minimo 4 dígitos" onkeyup="if(this.value.length > 3){ ajax(''list'', ''dwu.pv.clientes'', ''prm_cod=''+this.value, false, ''pv-clientes''); }"/></li>');
			htp.p('<li>');
				htp.p('<select id="pv-clientes" class="right">');
				
				htp.p('</select>');
			htp.p('</li>');
			htp.p('<li class="null"> </li>');
			htp.p('<li>Produto: <input class="right" type="text" placeholder="6 dígitos" title="no mínimo 6 dígitos" onkeyup="if(this.value.length > 5){ ajax(''list'', ''dwu.pv.produtos'', ''prm_cod=''+this.value, false, ''pv-produtos''); }"/></li>');
			htp.p('<li>');
				htp.p('<select id="pv-produtos" class="right">');
				
				htp.p('</select>');
			htp.p('</li>');
			htp.p('<li class="null"> </li>');
			htp.p('<li>QTDE:  <input id="pv-quant" class="right" type="number" value="" placeholder="0" onkeyup="var regex = new RegExp(''^[0-9.,]+$''); if(regex.test(this.value)){ this.style.setProperty(''box-shadow'', ''0 0 3px 0 #00AA00''); } else { this.style.setProperty(''box-shadow'', ''0 0 3px 0 #CC0000''); }"/></li>');
			htp.p('<li class="null"> </li>');
			htp.p('<li>ÚLTIMO PREÇO: <span class="right">99999999,99</span></li>');
            htp.p('<li>PREÇO: <input id="pv-preco" class="right" type="text" value="" placeholder="0,00" onkeyup="var regex = new RegExp(''^[0-9.,]+$''); if(regex.test(this.value)){ this.style.setProperty(''box-shadow'', ''0 0 3px 0 #00AA00''); } else { this.style.setProperty(''box-shadow'', ''0 0 3px 0 #CC0000''); }"/></li>');
            htp.p('<li>ENTREGA: <input id="pv-entrega" class="right" type="date" value="12/12/2012" /></li>');
			htp.p('<li class="null"> </li>');
			htp.p('<li>TOTAL: <span class="right">99999999,99</span></li>');
			htp.p('<li class="null"> </li>');
			htp.p('<li><a class="link" onclick="var regex = new RegExp(''^[0-9.,]+$''); var cliente = document.getElementById(''pv-clientes'').value; var produto = document.getElementById(''pv-produtos'').value; var quant = document.getElementById(''pv-quant'').value; var preco = document.getElementById(''pv-preco'').value; var entrega = document.getElementById(''pv-entrega'').value; if(regex.test(quant)){ if(regex.test(preco)){ ajax(''fly'', ''dwu.pv.enviar'', ''prm_cliente=''+cliente+''&prm_produto=''+produto+''&prm_quantidade=''+quant+''&prm_preco=''+preco+''&prm_entrega=''+entrega, false); noerror('''', ''Enviado com sucesso!'', ''msg''); } else { document.getElementById(''pv-preco'').style.setProperty(''box-shadow'', ''0 0 3px 0 #CC0000''); alerta(''msg'', ''Campo preço inválido!''); } } else { document.getElementById(''pv-quant'').style.setProperty(''box-shadow'', ''0 0 3px 0 #CC0000''); alerta(''msg'', ''Campo quantidade inválido!''); }">ENVIAR</a><a class="link right">FINALIZAR</a></li>');
			htp.p('<li class="center"><a class="link" onclick="ajax(''list'', ''dwu.pv.listar'', '''', false, ''main'');">LISTAR ULTIMOS</a></li>');
		htp.p('</ul>');
	end preencher;

end PV;
/
show error
exit