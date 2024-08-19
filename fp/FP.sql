set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplicação: Formulario de Planejamento
-- >>>>>>> Por:		Upquery Tec (João)
-- >>>>>>> Data:	03/03/14
-- >>>>>>> Pacote:	F.P 1.0
-- >>>>>>>-------------------------------------------------------------

create or replace package FP is
	
	procedure main;
	
	procedure list_vendedor ( prm_empresa varchar2 default null );
	
	procedure list_client ( prm_empresa varchar2 default null,
	                        prm_vendedor varchar2 default null );
	
	procedure list_fields ( prm_empresa varchar2 default null,
	                        prm_vendedor varchar2 default null,
	                        prm_cliente varchar2 default null );
							
	procedure list_newproduto ( prm_empresa varchar2 default null,
	                            prm_vendedor varchar2 default null,
                                prm_cliente varchar2 default null,
                                prm_produto varchar2 default null );
							
	procedure update_planejamento ( prm_empresa varchar2 default null,
	                                prm_vendedor varchar2 default null,
	                                prm_cliente varchar2 default null,
									prm_produto varchar2 default null,
									prm_mes varchar2 default null,
									prm_quantidade number,
                                    prm_valor number );
									
	procedure updatev_planejamento ( prm_empresa varchar2 default null,
	                                prm_vendedor varchar2 default null,
	                                prm_cliente varchar2 default null,
									prm_produto varchar2 default null,
									prm_mes varchar2 default null,
									prm_valor number,
                                    prm_quantidade number );
									
	procedure add_produto ( prm_empresa varchar2 default null,
	                    prm_produto varchar2 default null,
	                    prm_vendedor varchar2 default null,
                        prm_cliente varchar2 default null );
	
end FP;
/

create or replace package body FP is

	procedure main as
		
		cursor crs_empresas is select cd_empresa, ds_empresa from taux_empresas order by cd_empresa asc;
		ws_empresa crs_empresas%rowtype;
		
		ws_count number;
	
		begin
		htp.p('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
		htp.p('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">');
			htp.headOpen;
				htp.p('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
				htp.p('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
				htp.p('<TITLE>Formulario de planejamento de vendas - Manchester</TITLE>');
				htp.p('<META HTTP-EQUIV="Pragma" CONTENT="no-cache">');
				htp.p('<META HTTP-EQUIV="Expires" CONTENT="-1">');
				htp.p('<META NAME="apple-mobile-web-app-capable" CONTENT="yes">');
				htp.p('<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">');
				fcl.put_script('fp');
				fcl.put_css('reset');
				fcl.put_css('fp');
			htp.headClose;
			htp.p('<body>');
			    htp.p('<img src="http://www.mqb.com.br/imagens/BIM1.png"/>');
			    htp.p('<h2>FORMULARIO DE PLANEJAMENTO DE VENDAS</h2>');
				htp.p('<div id="formulario">');
				    htp.p('Empresa: <select id="select-empresa" onchange="if(this.value != ''n/a''){ document.getElementById(''select-cliente'').innerHTML=''''; document.getElementById(''search'').value=''''; document.getElementById(''lista'').innerHTML=''''; document.getElementById(''add-produto'').innerHTML=''''; ajax(''list'', ''dwu.fp.list_vendedor'', ''prm_empresa=''+this.value, false, ''select-vendedor''); document.getElementById(''select-vendedor'').selectedIndex = -1;}">');
					htp.p('<option value="n/a" selected>---</option>');
					open crs_empresas;
					    loop
						    fetch crs_empresas into ws_empresa;
							exit when crs_empresas%notfound;
							htp.p('<option value="'||ws_empresa.cd_empresa||'">'||ws_empresa.cd_empresa||' - '||ws_empresa.ds_empresa||'</option>');
						end loop;
					close crs_empresas;
					htp.p('</select>');
					htp.p('Vendedor: <select id="select-vendedor" onchange="document.getElementById(''search'').value=''''; document.getElementById(''lista'').innerHTML=''''; document.getElementById(''add-produto'').innerHTML=''''; ajax(''list'', ''dwu.fp.list_client'', ''prm_empresa=''+document.getElementById(''select-empresa'').value+''&prm_vendedor=''+this.value, false, ''select-cliente''); document.getElementById(''select-cliente'').selectedIndex = -1;"></select>');
					htp.p('Cliente: <select id="select-cliente" onchange=" document.getElementById(''search'').value=''''; document.getElementById(''lista'').innerHTML=''''; document.getElementById(''add-produto'').innerHTML=''''; alerta(''feed-fixo'', ''Carregando dados!''); ajax(''list'', ''dwu.fp.list_fields'', ''prm_empresa=''+document.getElementById(''select-empresa'').value+''&prm_vendedor=''+document.getElementById(''select-vendedor'').value+''&prm_cliente=''+this.value, false, ''lista'');"></select>');
				    htp.p('Novo produto: <input id="search" type="text" placeholder="4 digitos" title="mínimo 4 digitos" onkeyup="document.getElementById(''add-produto'').innerHTML=''''; if(this.value.length > 3){ ajax(''list'', ''dwu.fp.list_newproduto'', ''prm_empresa=''+document.getElementById(''select-empresa'').value+''&prm_vendedor=''+document.getElementById(''select-vendedor'').value+''&prm_cliente=''+document.getElementById(''select-cliente'').value+''&prm_produto=''+this.value, true, ''add-produto''); }"><select id="add-produto"></select>');
					htp.p('<a id="add" onclick="if(document.getElementById(''select-cliente'').value.length > 0){ if(document.getElementById(''add-produto'').value.length > 0){ ajax(''fly'', ''dwu.fp.add_produto'', ''prm_empresa=''+document.getElementById(''select-empresa'').value+''&prm_produto=''+document.getElementById(''add-produto'').value+''&prm_vendedor=''+document.getElementById(''select-vendedor'').value+''&prm_cliente=''+document.getElementById(''select-cliente'').value, false); alerta(''feed-fixo'', ''Carregando dados!''); document.getElementById(''search'').value=''''; document.getElementById(''lista'').innerHTML=''''; document.getElementById(''add-produto'').innerHTML=''''; ajax(''list'', ''dwu.fp.list_fields'', ''prm_empresa=''+document.getElementById(''select-empresa'').value+''&prm_vendedor=''+document.getElementById(''select-vendedor'').value+''&prm_cliente=''+document.getElementById(''select-cliente'').value, false, ''lista'');} else { alerta(''feed-fixo'', ''Favor escolher um produto!''); }} else { alerta(''feed-fixo'', ''Favor escolher um cliente!''); }">+</a>');
				    htp.p('<span>Usuário: '||user||'</span>');
				htp.p('</div>');
				htp.p('<table>');
					htp.p('<thead>');
						htp.p('<tr>');
							htp.p('<td></td>');
							htp.p('<td></td>');
							htp.p('<td>Janeiro</td>');
							htp.p('<td>Fevereiro</td>');
							htp.p('<td>Março</td>');
							htp.p('<td>Abril</td>');
							htp.p('<td>Maio</td>');
							htp.p('<td>Junho</td>');
							htp.p('<td>Julho</td>');
							htp.p('<td>Agosto</td>');
							htp.p('<td>Setembro</td>');
							htp.p('<td>Outubro</td>');
							htp.p('<td>Novembro</td>');
							htp.p('<td>Dezembro</td>');
						htp.p('</tr>');
					htp.p('</thead>');
					htp.p('<tbody id="lista"></tbody>');
				htp.p('</table>');
				htp.p('<div id="feed-fixo"></div>');
			htp.p('</body>');
		htp.p('</html>');
	end main;
	
	procedure list_vendedor ( prm_empresa varchar2 default null ) as
							
		cursor crs_vendedores is select cd_representante, nm_representante from taux_representantes where cd_empresa = prm_empresa and st_representante = 'L' order by nm_representante asc;
		ws_vendedor crs_vendedores%rowtype;
	    
		begin
	    
		open crs_vendedores;
		    loop
			    fetch crs_vendedores into ws_vendedor;
				exit when crs_vendedores%notfound;
				htp.p('<option value="'||ws_vendedor.cd_representante||'">'||ws_vendedor.cd_representante||' - '||ws_vendedor.nm_representante||'</option>');
			end loop;
		close crs_vendedores;	
							
	end list_vendedor;
	
	procedure list_client ( prm_empresa varchar2 default null,
	                        prm_vendedor varchar2 default null ) as
							
		cursor crs_clientes is select cd_cliente, nm_cliente from taux_clientes where cd_representante = prm_vendedor order by nm_cliente asc;
		ws_cliente crs_clientes%rowtype;
	begin
	    open crs_clientes;
            loop
                fetch crs_clientes into ws_cliente;
                exit when crs_clientes%notfound;
				htp.p('<option value="'||ws_cliente.cd_cliente||'">'||ws_cliente.cd_cliente||' - '||ws_cliente.nm_cliente||'</option>');
            end loop;
        close crs_clientes;			
							
	end list_client;
	
	procedure list_fields ( prm_empresa varchar2 default null,
	                        prm_vendedor varchar2 default null,
	                        prm_cliente varchar2 default null ) as
							
		cursor crs_fields is select cd_produto, cdesc(cd_produto,'PSQ_PRODUTOS') as ds_produto, 
     nvl(sum(decode(mes_emissao,'01',nvl(quantidade, ''))), '') as mes_01,
     nvl(sum(decode(mes_emissao,'02',nvl(quantidade, ''))), '') as mes_02,
     nvl(sum(decode(mes_emissao,'03',nvl(quantidade, ''))), '') as mes_03,
     nvl(sum(decode(mes_emissao,'04',nvl(quantidade, ''))), '') as mes_04,
     nvl(sum(decode(mes_emissao,'05',nvl(quantidade, ''))), '') as mes_05,
     nvl(sum(decode(mes_emissao,'06',nvl(quantidade, ''))), '') as mes_06,
     nvl(sum(decode(mes_emissao,'07',nvl(quantidade, ''))), '') as mes_07,
     nvl(sum(decode(mes_emissao,'08',nvl(quantidade, ''))), '') as mes_08,
     nvl(sum(decode(mes_emissao,'09',nvl(quantidade, ''))), '') as mes_09,
     nvl(sum(decode(mes_emissao,'10',nvl(quantidade, ''))), '') as mes_10,
     nvl(sum(decode(mes_emissao,'11',nvl(quantidade, ''))), '') as mes_11,
     nvl(sum(decode(mes_emissao,'12',nvl(quantidade, ''))), '') as mes_12,
     0 as p_mes_01,
           0 as p_mes_02,
           0 as p_mes_03,
           0 as p_mes_04,
           0 as p_mes_05,
        0 as p_mes_06,
        0 as p_mes_07,
        0 as p_mes_08,
        0 as p_mes_09,
        0 as p_mes_10,
        0 as p_mes_11,
        0 as p_mes_12,
		0 as valor_1,
		0 as valor_2,
		0 as valor_3,
		0 as valor_4,
		0 as valor_5,
		0 as valor_6,
		0 as valor_7,
		0 as valor_8,
		0 as valor_9,
		0 as valor_10,
		0 as valor_11,
		0 as valor_12
     from dw_saidas
     where ano_emissao='2013' and cd_vendedor = prm_vendedor and cd_cliente = prm_cliente and cd_empresa = prm_empresa group by cd_produto
     union all
     select cd_produto, cdesc(cd_produto,'PSQ_PRODUTOS') as ds_produto, 
     0 as mes_01,
           0 as mes_02,
           0 as mes_03,
           0 as mes_04,
           0 as mes_05,
           0 as mes_06,
           0 as mes_07,
           0 as mes_08,
           0 as mes_09,
           0 as mes_10,
           0 as mes_11,
           0 as mes_12,
     nvl(sum(decode(mes_emissao,'01',nvl(quantidade, ''))), '') as p_mes_01,
     nvl(sum(decode(mes_emissao,'02',nvl(quantidade, ''))), '') as p_mes_02,
     nvl(sum(decode(mes_emissao,'03',nvl(quantidade, ''))), '') as p_mes_03,
     nvl(sum(decode(mes_emissao,'04',nvl(quantidade, ''))), '') as p_mes_04,
     nvl(sum(decode(mes_emissao,'05',nvl(quantidade, ''))), '') as p_mes_05,
     nvl(sum(decode(mes_emissao,'06',nvl(quantidade, ''))), '') as p_mes_06,
     nvl(sum(decode(mes_emissao,'07',nvl(quantidade, ''))), '') as p_mes_07,
     nvl(sum(decode(mes_emissao,'08',nvl(quantidade, ''))), '') as p_mes_08,
     nvl(sum(decode(mes_emissao,'09',nvl(quantidade, ''))), '') as p_mes_09,
     nvl(sum(decode(mes_emissao,'10',nvl(quantidade, ''))), '') as p_mes_10,
     nvl(sum(decode(mes_emissao,'11',nvl(quantidade, ''))), '') as p_mes_11,
     nvl(sum(decode(mes_emissao,'12',nvl(quantidade, ''))), '') as p_mes_12,
	 nvl(sum(decode(mes_emissao,'01',nvl(valor, ''))), '') as valor_1,
	 nvl(sum(decode(mes_emissao,'02',nvl(valor, ''))), '') as valor_2,
	 nvl(sum(decode(mes_emissao,'03',nvl(valor, ''))), '') as valor_3,
	 nvl(sum(decode(mes_emissao,'04',nvl(valor, ''))), '') as valor_4,
	 nvl(sum(decode(mes_emissao,'05',nvl(valor, ''))), '') as valor_5,
	 nvl(sum(decode(mes_emissao,'06',nvl(valor, ''))), '') as valor_6,
	 nvl(sum(decode(mes_emissao,'07',nvl(valor, ''))), '') as valor_7,
	 nvl(sum(decode(mes_emissao,'08',nvl(valor, ''))), '') as valor_8,
	 nvl(sum(decode(mes_emissao,'09',nvl(valor, ''))), '') as valor_9,
	 nvl(sum(decode(mes_emissao,'10',nvl(valor, ''))), '') as valor_10,
	 nvl(sum(decode(mes_emissao,'11',nvl(valor, ''))), '') as valor_11,
	 nvl(sum(decode(mes_emissao,'12',nvl(valor, ''))), '') as valor_12
     from dw_saidas_planejamento
     where ano_emissao='2014' and cd_vendedor = prm_vendedor and cd_cliente = prm_cliente and cd_empresa = prm_empresa group by cd_produto;
	    ws_field crs_fields%rowtype;
		
		ws_quantidade  number;
		
	begin
	    open crs_fields;
		    loop
			    fetch crs_fields into ws_field;
				exit when crs_fields%notfound;
				htp.p('<tr>');
					htp.p('<td title="'||ws_field.ds_produto||'">'||ws_field.cd_produto||' - '||ws_field.ds_produto||'</td>');
					htp.p('<td><input style="border: medium none; width: 70px; margin: 4px auto; background: transparent;" value="Quantidade" /><input style="border: medium none; width: 70px; margin: 4px auto; background: transparent;" value="Valor" /></td>');
					htp.p('<td><input onblur="upp('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''01'', this.value, this.nextElementSibling.value);" placeholder="'||ws_field.mes_01||'" value="'||ws_field.p_mes_01||'"/><input onblur="upv('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''01'', this.value, this.previousElementSibling.value);" placeholder="'||replace(ws_field.valor_1, '.', ',')||'" value="'||replace(ws_field.valor_1, '.', ',')||'"/></td>');
					htp.p('<td><input onblur="upp('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''02'', this.value, this.nextElementSibling.value);" placeholder="'||ws_field.mes_02||'" value="'||ws_field.p_mes_02||'"/><input onblur="upv('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''02'', this.value, this.previousElementSibling.value);" placeholder="'||replace(ws_field.valor_2, '.', ',')||'" value="'||replace(ws_field.valor_2, '.', ',')||'"/></td>');
					htp.p('<td><input onblur="upp('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''03'', this.value, this.nextElementSibling.value);" placeholder="'||ws_field.mes_03||'" value="'||ws_field.p_mes_03||'"/><input onblur="upv('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''03'', this.value, this.previousElementSibling.value);" placeholder="'||replace(ws_field.valor_3, '.', ',')||'" value="'||replace(ws_field.valor_3, '.', ',')||'"/></td>');
					htp.p('<td><input onblur="upp('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''04'', this.value, this.nextElementSibling.value);" placeholder="'||ws_field.mes_04||'" value="'||ws_field.p_mes_04||'"/><input onblur="upv('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''04'', this.value, this.previousElementSibling.value);" placeholder="'||replace(ws_field.valor_4, '.', ',')||'" value="'||replace(ws_field.valor_4, '.', ',')||'"/></td>');
					htp.p('<td><input onblur="upp('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''05'', this.value, this.nextElementSibling.value);" placeholder="'||ws_field.mes_05||'" value="'||ws_field.p_mes_05||'"/><input onblur="upv('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''05'', this.value, this.previousElementSibling.value);" placeholder="'||replace(ws_field.valor_5, '.', ',')||'" value="'||replace(ws_field.valor_5, '.', ',')||'"/></td>');
					htp.p('<td><input onblur="upp('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''06'', this.value, this.nextElementSibling.value);" placeholder="'||ws_field.mes_06||'" value="'||ws_field.p_mes_06||'"/><input onblur="upv('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''06'', this.value, this.previousElementSibling.value);" placeholder="'||replace(ws_field.valor_6, '.', ',')||'" value="'||replace(ws_field.valor_6, '.', ',')||'"/></td>');
					htp.p('<td><input onblur="upp('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''07'', this.value, this.nextElementSibling.value);" placeholder="'||ws_field.mes_07||'" value="'||ws_field.p_mes_07||'"/><input onblur="upv('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''07'', this.value, this.previousElementSibling.value);" placeholder="'||replace(ws_field.valor_7, '.', ',')||'" value="'||replace(ws_field.valor_7, '.', ',')||'"/></td>');
					htp.p('<td><input onblur="upp('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''08'', this.value, this.nextElementSibling.value);" placeholder="'||ws_field.mes_08||'" value="'||ws_field.p_mes_08||'"/><input onblur="upv('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''08'', this.value, this.previousElementSibling.value);" placeholder="'||replace(ws_field.valor_8, '.', ',')||'" value="'||replace(ws_field.valor_8, '.', ',')||'"/></td>');
					htp.p('<td><input onblur="upp('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''09'', this.value, this.nextElementSibling.value);" placeholder="'||ws_field.mes_09||'" value="'||ws_field.p_mes_09||'"/><input onblur="upv('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''09'', this.value, this.previousElementSibling.value);" placeholder="'||replace(ws_field.valor_9, '.', ',')||'" value="'||replace(ws_field.valor_9, '.', ',')||'"/></td>');
					htp.p('<td><input onblur="upp('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''10'', this.value, this.nextElementSibling.value);" placeholder="'||ws_field.mes_10||'" value="'||ws_field.p_mes_10||'"/><input onblur="upv('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''10'', this.value, this.previousElementSibling.value);" placeholder="'||replace(ws_field.valor_10, '.', ',')||'" value="'||replace(ws_field.valor_10, '.', ',')||'"/></td>');
					htp.p('<td><input onblur="upp('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''11'', this.value, this.nextElementSibling.value);" placeholder="'||ws_field.mes_11||'" value="'||ws_field.p_mes_11||'"/><input onblur="upv('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''11'', this.value, this.previousElementSibling.value);" placeholder="'||replace(ws_field.valor_11, '.', ',')||'" value="'||replace(ws_field.valor_11, '.', ',')||'"/></td>');
					htp.p('<td><input onblur="upp('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''12'', this.value, this.nextElementSibling.value);" placeholder="'||ws_field.mes_12||'" value="'||ws_field.p_mes_12||'"/><input onblur="upv('''||prm_empresa||''', '''||prm_vendedor||''', '''||prm_cliente||''', '''||ws_field.cd_produto||''', ''12'', this.value, this.previousElementSibling.value);" placeholder="'||replace(ws_field.valor_12, '.', ',')||'" value="'||replace(ws_field.valor_12, '.', ',')||'"/></td>');
			    htp.p('</tr>');
            end loop;
        close crs_fields;		   
							
	end list_fields;
	
	procedure list_newproduto ( prm_empresa varchar2 default null,
	                            prm_vendedor varchar2 default null,
                                prm_cliente varchar2 default null,
                                prm_produto varchar2 default null ) as
							
	begin
	    if ascii(upper(substr(prm_produto,1,1))) between 65 and 90 then
		    for i in(select cd_produto, ds_produto from taux_produtos tp where /*cd_produto in (select distinct(cd_produto) from dw_saidas ds where ds.cd_vendedor = prm_vendedor and ds.cd_cliente = prm_cliente and ds.cd_empresa = prm_empresa and ds.ano_emissao = '2013') and*/ cd_produto not in (select distinct(cd_produto) from dw_saidas_planejamento dsp where dsp.cd_vendedor = prm_vendedor and dsp.cd_cliente = prm_cliente and dsp.cd_empresa = prm_empresa) and ds_produto like (upper(prm_produto)||'%') order by ds_produto desc) loop
		        htp.p('<option value="'||i.cd_produto||'">'||i.cd_produto||' - '||i.ds_produto||'</option>');
		    end loop;
		else
		    for i in(select cd_produto, ds_produto from taux_produtos tp where /*cd_produto in (select distinct(cd_produto) from dw_saidas ds where ds.cd_vendedor = prm_vendedor and ds.cd_cliente = prm_cliente and ds.cd_empresa = prm_empresa and ds.ano_emissao = '2013') and*/ cd_produto not in (select distinct(cd_produto) from dw_saidas_planejamento dsp where dsp.cd_vendedor = prm_vendedor and dsp.cd_cliente = prm_cliente and dsp.cd_empresa = prm_empresa) and cd_produto like (prm_empresa||'-'||prm_produto||'%') order by ds_produto desc) loop
		        htp.p('<option value="'||i.cd_produto||'">'||i.cd_produto||' - '||i.ds_produto||'</option>');
		  end loop;
		end if;
							
	end list_newproduto;
	
	procedure update_planejamento ( prm_empresa varchar2 default null,
	                                prm_vendedor varchar2 default null,
	                                prm_cliente varchar2 default null,
									prm_produto varchar2 default null,
									prm_mes varchar2 default null,
									prm_quantidade number,
                                    prm_valor number ) as
									
									ws_count number;
									ws_duplicado exception;
									
	begin
	
	    select count(*)into ws_count from dw_saidas_planejamento where cd_empresa = prm_empresa and cd_vendedor = prm_vendedor and cd_cliente = prm_cliente and cd_produto = prm_produto and mes_emissao = prm_mes and ano_emissao = '2014';
		if ws_count = 0 then
            insert into dw_saidas_planejamento values(prm_empresa, prm_vendedor, prm_cliente, prm_produto, prm_mes, '2014', prm_quantidade, prm_valor);
        elsif ws_count = 1 then
		    update dw_saidas_planejamento
			set quantidade = prm_quantidade
			where cd_empresa = prm_empresa and 
			cd_vendedor = prm_vendedor and 
			cd_cliente = prm_cliente and 
			cd_produto = prm_produto and 
			mes_emissao = prm_mes and 
			ano_emissao = '2014';
		else
		    raise ws_duplicado;
		end if;
		
    exception 
	    when ws_duplicado then
    	    htp.p('!alerta Erro ao alterar, valor duplicado!');
		when others then
		    htp.p(sqlerrm);						
	end update_planejamento;
	
	procedure updatev_planejamento ( prm_empresa varchar2 default null,
	                                prm_vendedor varchar2 default null,
	                                prm_cliente varchar2 default null,
									prm_produto varchar2 default null,
									prm_mes varchar2 default null,
									prm_valor number,
									prm_quantidade number ) as
									
									ws_count number;
									ws_duplicado exception;
									
	begin
	
	    select count(*)into ws_count from dw_saidas_planejamento where cd_empresa = prm_empresa and cd_vendedor = prm_vendedor and cd_cliente = prm_cliente and cd_produto = prm_produto and mes_emissao = prm_mes and ano_emissao = '2014';
		if ws_count = 0 then
            insert into dw_saidas_planejamento values(prm_empresa, prm_vendedor, prm_cliente, prm_produto, prm_mes, '2014', prm_quantidade, prm_valor);
        elsif ws_count = 1 then
		    update dw_saidas_planejamento
			set valor = prm_valor
			where cd_empresa = prm_empresa and 
			cd_vendedor = prm_vendedor and 
			cd_cliente = prm_cliente and 
			cd_produto = prm_produto and 
			mes_emissao = prm_mes and 
			ano_emissao = '2014';
		else
		    raise ws_duplicado;
		end if;
		
    exception 
	    when ws_duplicado then
    	    htp.p('!alerta Erro ao alterar, valor duplicado!');
		when others then
		    htp.p(sqlerrm);						
	end updatev_planejamento;
	
	procedure add_produto ( prm_empresa varchar2 default null,
	                    prm_produto varchar2 default null,
	                    prm_vendedor varchar2 default null,
                        prm_cliente varchar2 default null ) as
									
        ws_count number;
									
	begin
	
        insert into dw_saidas_planejamento values(prm_empresa, prm_vendedor, prm_cliente, prm_produto, '', '2014', '', '');

    exception when others then
	    htp.p(sqlerrm);						
	end add_produto;

end FP;
/
show error
exit