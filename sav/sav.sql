set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Por:		Upquery Tec
-- >>>>>>> Data:	16/01/16
-- >>>>>>> Pacote:	SV
-- >>>>>>>-------------------------------------------------------------


create or replace package sv is

	procedure main;
	
	procedure inserir (  prm_solicitante varchar2 default null, 
	                     prm_aprovador   varchar2 default null, 
						 prm_passageiro  varchar2 default null, 
						 prm_motivo      varchar2 default null, 
						 prm_cliente     varchar2 default null, 
						 prm_origem      varchar2 default null, 
						 prm_destino     varchar2 default null, 
						 prm_saida       varchar2 default null, 
						 prm_retorno     varchar2 default null, 
						 prm_hsaida      varchar2 default null, 
						 prm_hretorno    varchar2 default null, 
						 prm_hospedagem  varchar2 default null, 
						 prm_hotel       varchar2 default null, 
						 prm_veiculo     varchar2 default null,
						 prm_local       varchar2 default null );
	
end sv;
/

create or replace package body sv is

	procedure main as
		
		cursor crs_centro is 
		select cd_custo, nm_custo from taux_cc;
		ws_centro crs_centro%rowtype;
		
		cursor crs_cidades is
		select codigo_cidade, nm_cidade, codigo_estado from cidade
		where codigo_estado = 24;
		ws_cidade crs_cidades%rowtype;
		
		begin
		 
		htp.p('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
		htp.p('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">');
			htp.p('<head>');
				htp.p('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
				htp.p('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
				htp.p('<meta name="apple-mobile-web-app-capable" content="yes">');
				htp.p('<meta name="apple-mobile-web-app-status-bar-style" content="black" />');
				htp.p('<title>Upquery Solicitação de Adiantamento de Viagem</title>');
				htp.p('<link rel="apple-touch-icon" size="114x114" href="">');
				htp.p('<META HTTP-EQUIV="Pragma" CONTENT="no-cache">');
				htp.p('<META HTTP-EQUIV="Expires" CONTENT="-1">');
				htp.p('<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">');
				htp.p('<meta name="viewport" content="width=device-width, user-scalable=no, maximum-scale=1"/>');
				htp.p('<link href="https://fonts.googleapis.com/css?family=Montserrat" rel="stylesheet" type="text/css">');
				fcl.put_css('reset_1210');
				fcl.put_css('sv');
				fcl.put_script('sv');
				fcl.put_script('calendario');
				fcl.put_css('calendario');
			htp.p('</head>');
			htp.p('<body>');
				htp.p('<ul class="main">');
					htp.p('<li class="titulo">SOLICITAÇÃO DE AÉREOS E/ OU HOTEL/TRANSPORTE</li>');
					htp.p('<li>');
						htp.p('<span class="desc">SOLICITANTE</span>');
						htp.p('<span style="width: 80%;"><input type="text" class="txt" id="solicitante" required="true" readonly/></span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">APROVADOR</span>');
						htp.p('<span style="width: 80%;"><input type="text" class="txt" id="aprovador" value="UPQUERY" readonly /></span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">PASSAGEIRO</span>');
						htp.p('<span style="width: 40%;" class="input"><input type="text" class="txt" style="text-transform: capitalize;" required="true"/></span>');
						htp.p('<span class="desc2">MATRICULA</span>');
						htp.p('<span></span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">UNIDADE DE NEGÓCIO</span>');
						htp.p('<span></span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">DEPARTAMENTO</span>');
						htp.p('<span></span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">CENTRO DE CUSTO</span>');
						htp.p('<span>');
							htp.p('<select id="cc" class="txt">');
								open crs_centro;
									loop
									fetch crs_centro into ws_centro;
									exit when crs_centro%notfound;
										htp.p('<option value="'||ws_centro.cd_custo||'">'||ws_centro.nm_custo||'</option>');
									end loop;
								close crs_centro;
							htp.p('</select>');
						htp.p('</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">MOTIVO DA DESPESA</span>');
						htp.p('<span style="width: 80%"><input type="text" class="txt" id="motivo" required="true"/></span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">CLIENTE</span>');
						htp.p('<span>');
						    htp.p('<select id="cliente" class="txt">');
						        htp.p('<option value="01">CLIENTE 1</option>');
						        htp.p('<option value="02">CLIENTE 2</option>');
						        htp.p('<option value="03">CLIENTE 3</option>');
						    htp.p('</select>');
						htp.p('</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">CIDADE DE ORIGEM</span>');
						htp.p('<span>');
							htp.p('<select id="origem" class="txt">');
								open crs_cidades;
								    loop
									fetch crs_cidades into ws_cidade;
									exit when crs_cidades%notfound;
									    htp.p('<option value="'||ws_cidade.codigo_cidade||'">'||ws_cidade.nm_cidade||'</option>');
									end loop;
								close crs_cidades;
							htp.p('</select>');
						htp.p('</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">CIDADE DE DESTINO</span>');
						htp.p('<span style="width: 60%;"><input type="text" class="txt" id="destino" required="true"/></span>');
						htp.p('<span class="desc2" style="border-right: none; width: calc(20% - 2px);">DIÁRIA HOTEL</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">DATA DE IDA</span>');
						htp.p('<span class="input">');
							htp.p('<input readonly id="date1" class="txt" type="text" required="true" onclick="this.showCalendar();" onmouseover="calendar.set(this.id);" />');
						htp.p('</span>');
						htp.p('<span class="desc2">DATA DE VOLTA</span>');
						htp.p('<span class="input">');
							htp.p('<input readonly id="date2" class="txt" type="text" required="true" onclick="this.showCalendar();" onmouseover="calendar.set(this.id);"/>');
						htp.p('</span>');
						htp.p('<span class="desc2" style="border-right: none; width: calc(20% - 2px);"><output id="diarias"/></span>');
					htp.p('<li>');
						htp.p('<span class="desc">HORÁRIO DA VIAGEM IDA</span>');
						htp.p('<span class="input">');
							htp.p('<select id="time1" class="txt">');
								htp.p('<option value="M">MANHÃ</option>');
								htp.p('<option value="T">TARDE</option>');
								htp.p('<option value="N">NOITE</option>');
							htp.p('</select>');
						htp.p('</span>');
						htp.p('<span class="desc2">HORÁRIO DA VIAGEM VOLTA</span>');
						htp.p('<span class="input">');
							htp.p('<select id="time2" class="txt">');
								htp.p('<option value="M">MANHÃ</option>');
								htp.p('<option value="T">TARDE</option>');
								htp.p('<option value="N">NOITE</option>');
							htp.p('</select>');
						htp.p('</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">HOSPEDAGEM</span>');
						htp.p('<span class="input" style="text-align: center;">');
							htp.p('<input type="checkbox" id="hospedagem"/>');
						htp.p('</span>');
						htp.p('<span class="desc2">PRÊFERENCIA DE HOTEL</span>');
						htp.p('<span  style="width: 40%;">');
							htp.p('<input type="text" class="txt" required="true" id="preferencia"/>');
						htp.p('</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">ALUGUEL DE CARRO</span>');
						htp.p('<span class="input" style="text-align: center;">');
							htp.p('<input type="checkbox" id="carro"/>');
						htp.p('</span>');
						htp.p('<span class="desc2">LOCAL DE RETIRADA</span>');
						htp.p('<span style="width: 40%;">');
							htp.p('<input type="text" class="txt" required="true" id="retirada"/>');
						htp.p('</span>');
					htp.p('</li>');
					htp.p('<li><a onclick="enviar();" style="border-right: 2px solid rgb(0, 0, 0);">ENVIAR</a><a onclick="document.getElementsByClassName(''main'')[1].classList.toggle(''invisible'');">ADIANTAMENTO</a></li>');
				htp.p('</ul>');
				htp.p('<ul class="main invisible">');
					htp.p('<li class="titulo">VIAGEM NACIONAL</li>');
					htp.p('<li>');
						htp.p('<span class="desc">DIAS DE VIAGEM</span>');
						htp.p('<span style="width: 80%;"><input type="number" style="text-align: center;" class="txt" required="true" placeholder="DIAS"/></span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">ALIMENTAÇÃO</span>');
						htp.p('<span class="input"><input type="text" style="text-align: right;" onkeypress="return input(event, ''integer'')" onkeyup="mascara(this, ''R$'', '','');" class="txt" required="true" placeholder="R$"/></span>');
						htp.p('<span>R$</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">TRANSPORTE</span>');
						htp.p('<span class="input"><input type="text" style="text-align: right;" onkeypress="return input(event, ''integer'')" onkeyup="mascara(this, ''R$'', '','');" class="txt" required="true" placeholder="R$"/></span>');
						htp.p('<span>R$</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">HOSPEDAGEM</span>');
						htp.p('<span class="input"><input type="text" style="text-align: right;" onkeypress="return input(event, ''integer'')" onkeyup="mascara(this, ''R$'', '','');" class="txt" required="true" placeholder="R$"/></span>');
						htp.p('<span>R$</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">OUTROS</span>');
						htp.p('<span class="input"><input type="text" style="text-align: right;" onkeypress="return input(event, ''integer'')" onkeyup="mascara(this, ''R$'', '','');" class="txt" required="true" placeholder="R$"/></span>');
						htp.p('<span>R$</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">ADIANTAMENTO RECEBIDO</span>');
						htp.p('<span>R$</span>');
					htp.p('</li>');
					htp.p('<li class="titulo">VIAGEM INTERNACIONAL</li>');
					htp.p('<li>');
						htp.p('<span class="desc">DIAS DE VIAGEM</span>');
						htp.p('<span style="width: 80%;"><input type="number" style="text-align: center;" class="txt" required="true" placeholder="DIAS"/></span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">ALIMENTAÇÃO</span>');
						htp.p('<span class="input"><input type="text" style="text-align: right;" onkeypress="return input(event, ''integer'')" onkeyup="mascara(this, ''USD'', ''.'');" class="txt" required="true" placeholder="USD"/></span>');
						htp.p('<span>R$</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">TRANSPORTE</span>');
						htp.p('<span class="input"><input type="text" style="text-align: right;" onkeypress="return input(event, ''integer'')" onkeyup="mascara(this, ''USD'', ''.'');" class="txt" required="true" placeholder="USD"/></span>');
						htp.p('<span>R$</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">HOSPEDAGEM</span>');
						htp.p('<span class="input"><input type="text" style="text-align: right;" onkeypress="return input(event, ''integer'')" onkeyup="mascara(this, ''USD'', ''.'');" class="txt" required="true" placeholder="USD"/></span>');
						htp.p('<span>R$</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">OUTROS</span>');
						htp.p('<span class="input"><input type="text" style="text-align: right;" onkeypress="return input(event, ''integer'')" onkeyup="mascara(this, ''USD'', ''.'');" class="txt" required="true" placeholder="USD"/></span>');
						htp.p('<span>R$</span>');
					htp.p('</li>');
					htp.p('<li>');
						htp.p('<span class="desc">ADIANTAMENTO RECEBIDO</span>');
						htp.p('<span class="input"><input type="text" style="text-align: right;" onkeypress="return input(event, ''integer'')" onkeyup="mascara(this, ''USD'', ''.'');" class="txt" required="true" placeholder="USD"/></span>');
					htp.p('</li>');
				htp.p('</ul>');
            htp.p('</body>');
        htp.p('</html>');
    end main;
	
	procedure inserir (  prm_solicitante varchar2 default null, 
	                     prm_aprovador   varchar2 default null, 
						 prm_passageiro  varchar2 default null, 
						 prm_motivo      varchar2 default null, 
						 prm_cliente     varchar2 default null, 
						 prm_origem      varchar2 default null, 
						 prm_destino     varchar2 default null, 
						 prm_saida       varchar2 default null, 
						 prm_retorno     varchar2 default null, 
						 prm_hsaida      varchar2 default null, 
						 prm_hretorno    varchar2 default null, 
						 prm_hospedagem  varchar2 default null, 
						 prm_hotel       varchar2 default null, 
						 prm_veiculo     varchar2 default null,
						 prm_local       varchar2 default null ) as
	
	begin
	
	    insert into OPR_REQUISICAO_VIAGEM (COD, USUARIO, CD_SOLICITANTE, CD_APROVADOR, NM_PASSAGEIRO, CD_UNIDADE, CD_DEPARTAMENTO, CD_CENTRO, DS_MOTIVO, CD_CLIENTE , DS_ORIGEM, DS_DESTINO, DT_SAIDA, DT_RETORNO, HR_SAIDA, HR_RETORNO, ST_HOSPEDAGEM, NM_HOTEL, ST_VEICULO, LOCAL_VEICULO, CD_FLOWCTR, CD_SITUACAO)
	    values ('01', user, prm_solicitante, prm_aprovador, prm_passageiro, '01', '01', '01', prm_motivo, prm_cliente, prm_origem, prm_destino, prm_saida, prm_retorno, prm_hsaida, prm_hretorno, prm_hospedagem, prm_hotel, prm_veiculo, prm_local, '01', 'aberta');
	
	end inserir;
	
end sv;
/
show error
exit
