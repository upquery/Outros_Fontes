set scan off

CREATE OR REPLACE PACKAGE PC is

	procedure main;
	
	procedure inserir_despesa (  prm_requisicao   varchar2 default null, 
			                     prm_emissao      varchar2 default null,
			                     prm_tipo         varchar2 default 'CARTAO-INTERNO',
								 prm_moeda        varchar2 default null, 
								 prm_despesa      varchar2 default null, 
								 prm_cartao       varchar2 default null, 
								 prm_valor        varchar2 default null, 
								 prm_obs          varchar2 default null,
								 prm_geo          varchar2 default null,
		                         prm_cambio       varchar2 default null,
		                         prm_moeda_troca  varchar2 default null,
		                         prm_item         varchar2 default null );
	
	procedure lista ( prm_requisicao varchar2 default null );
	
	procedure listar_solicitacoes;
	
	procedure alterar ( prm_item     number   default null,
	                    prm_despesa  varchar2 default null,
	                    prm_data     varchar2 default null,
						prm_valor    varchar2 default null );
	
	procedure excluir ( prm_item number default null );
	
	procedure moedas_usadas ( prm_requisicao varchar2 default null );
	
	procedure excluir_despesa ( prm_emissao varchar2 default null,
	                            prm_moeda   varchar2 default null );
	
	procedure excluir_troca_moeda ( prm_item varchar2 default null );

	procedure botoes;

	procedure inserir (  prm_cod             varchar2 default null,
	                     prm_solicitante     varchar2 default null,
	                     prm_aprovador       varchar2 default null,
						 prm_passageiro      varchar2 default null,
						 prm_filial          varchar2 default null,
						 prm_filial_despesa  varchar2 default null,
						 prm_funcao          varchar2 default null,
						 prm_centro          varchar2 default null,
						 prm_centro_despesa  varchar2 default null,
						 prm_motivo          varchar2 default null,
						 prm_cliente         varchar2 default null,
						 prm_origem          varchar2 default null,
						 prm_destino         varchar2 default null,
						 prm_origemv         varchar2 default null,
						 prm_destinov        varchar2 default null,
						 prm_ida             varchar2 default null,
						 prm_volta           varchar2 default null,
						 prm_diaria          varchar2 default null,
						 prm_hida            varchar2 default null,
						 prm_hvolta          varchar2 default null,
						 prm_hospedagem      varchar2 default null,
						 prm_preferencia     varchar2 default null,
						 prm_carro           varchar2 default null,
						 prm_retirada        varchar2 default null,
						 prm_situacao        varchar2 default null,
						 prm_aerea           varchar2 default null,
                         prm_ad_opcao        varchar2 default null,
                         prm_ad_cidade       varchar2 default null,
                         prm_ad_periodo      varchar2 default null,
                         prm_ad_periodo_i    varchar2 default null,
                         prm_ad_periodo_f    varchar2 default null  );
	
end pc;

/
create or replace package body pc is

	procedure main as

	    ws_count         number;
		ws_requisicao    varchar2(80) := '';
		ws_requisicao_ds varchar2(80);
		ws_data_atual    varchar2(10);

		begin
			htp.p('<div id="locker" class="noprint"></div>');
			
			htp.p('<ul class="main">');
			
			    htp.p('<li class="titulo">');
					htp.p('<div class="selectbox"><select autocomplete="off" id="solicitacoes" style="width: 98%; height: 26px; border-radius: 3px; position: absolute; top: 0px; left: 0px; border: medium none; background-color: transparent; cursor: pointer;" onchange="document.getElementById(''cartao_lancamento'').style.setProperty(''display'', ''block''); document.getElementById(''moedas_usadas_append'').style.setProperty(''display'', ''block''); reabrirPc(this.value); call(''moedas_usadas'', ''prm_requisicao=''+this.value, ''PC'').then(function(resposta){ document.getElementById(''emissao'').value = ''''; document.getElementById(''moeda'').selectedIndex = 0; document.getElementById(''despesa'').selectedIndex = 0; document.getElementById(''valor'').value = ''''; document.getElementById(''moedas_usadas_append'').classList.remove(''invisible''); document.getElementById(''moedas_usadas_append'').innerHTML = resposta; }).then(function(){ loading(); });">');
						pc.listar_solicitacoes;
					htp.p('</select></div>');

                htp.p('SOLICITAÇÃO</li>');
				
                htp.p('<div id="formulario">');
				    sv.formulario('', 'PC');
				htp.p('</div>');

				htp.p('<li style="min-height: 0; flex-wrap: wrap;  border-top: 1px solid #000;" id="ajax-botoes">');
				   pc.botoes;
				htp.p('</li>');
				

			htp.p('</ul>');	
					
			htp.p('<ul id="cartao_lancamento" class="main noprint" style="display: none;">');		
				htp.p('<li class="titulo">LANÇAMENTO DE DESPESAS</li>');

				htp.p('<li>');
					htp.p('<span class="desc">DATA DA DESPESA</span>');
					htp.p('<span class="input" style="width: 100%;">');
						htp.p('<input id="emissao" class="txt" type="text" data-atual="" value="" oninput="this.value = VMasker.toPattern(this.value, ''99/99/9999'');" />');
					htp.p('</span>');
				htp.p('</li>');
				
				htp.p('<li>');
					    htp.p('<span class="desc">TIPO DE GASTO</span>');
						htp.p('<span style="width: 100%;">');			
							htp.p('<select id="tipo-gasto" class="txt">');
								htp.p('<option value="DESPESA-INTERNA" selected>DINHEIRO</option>');
								htp.p('<option value="CARTAO-INTERNO">CARTÃO CORPORATIVO</option>');
							htp.p('</select>');
						htp.p('</span>');
					htp.p('</li>');

				htp.p('<li>');
				    htp.p('<span class="desc">TIPO DA MOEDA</span>');
					htp.p('<span style="width: 100%;">');			
						htp.p('<select id="moeda" class="txt" onchange="document.getElementById(''valor'').value = ''''; document.getElementById(''valor-cambio'').value = ''0,00'';">');
							for i in(select cd_moeda, ds_moeda, ds_simbolo from taux_moeda) loop
								if i.cd_moeda = 'REAL' then
								    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'" selected>'||i.ds_moeda||'</option>');
								else
								    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'">'||i.ds_moeda||'</option>');
								end if;
							end loop;
						htp.p('</select>');
					htp.p('</span>');
				htp.p('</li>');
				
				
				htp.p('<li>');
				    htp.p('<span class="desc">TIPO DA DESPESA</span>');
					htp.p('<span style="width: 100%;">');
						htp.p('<select id="despesa" class="txt">');
							htp.p('<option value="" selected disabled hidden>...</option>');
							for i in(select cd_despesa, ds_despesa from taux_tp_despesa where tp_despesa = '1' order by ds_despesa) loop
								htp.p('<option value="'||i.cd_despesa||'">'||i.ds_despesa||'</option>');
							end loop;
						htp.p('</select>');
					htp.p('</span>');
				htp.p('</li>');
				
				
				htp.p('<input id="moeda-troca" type="hidden" value="" />');

				htp.p('<li>');
				    htp.p('<span class="desc">VALOR DA MOEDA</span>');
					htp.p('<span style="width: 100%;" class="input">');			
						htp.p('<input id="valor" type="text" style="text-align: center;" oninput="this.value = VMasker.toMoney(this.value);" class="txt"/>');
					htp.p('</span>');
				htp.p('</li>');

                htp.p('<li style="display: none;">');
				    htp.p('<span class="desc">CÂMBIO DO DIA</span>');
					htp.p('<span style="width: 100%;" class="input">');			
						htp.p('<input id="valor-cambio" type="text" style="text-align: center;" oninput="this.value = VMasker.toMoney(this.value);" class="txt" value="0,00"/>');
					htp.p('</span>');
				htp.p('</li>');
				
				htp.p('<li>');
				    htp.p('<span class="desc">OBSERVAÇÃO</span>');
					htp.p('<span style="width: 80%;" class="input">');			
						htp.p('<textarea type="text" class="txt" id="obs"></textarea>');
					htp.p('</span>');
				htp.p('</li>');

				
				htp.p('<li style="height: auto; flex-wrap: wrap;"><a class="subicon" onclick="loading(); setTimeout(function(){ enviar_pc(); }, 500);">GRAVAR</a>');

			htp.p('</ul>');

			

			htp.p('<ul class="main invisible valores" id="moedas_usadas_append">');
			htp.p('</ul>');

			htp.p('<div class="sign2"></div>');
			
			htp.p('<div class="signc"></div>');
			
    end main;
    
    procedure inserir (  prm_cod             varchar2 default null,
	                     prm_solicitante     varchar2 default null,
	                     prm_aprovador       varchar2 default null,
						 prm_passageiro      varchar2 default null,
						 prm_filial          varchar2 default null,
						 prm_filial_despesa  varchar2 default null,
						 prm_funcao          varchar2 default null,
						 prm_centro          varchar2 default null,
						 prm_centro_despesa  varchar2 default null,
						 prm_motivo          varchar2 default null,
						 prm_cliente         varchar2 default null,
						 prm_origem          varchar2 default null,
						 prm_destino         varchar2 default null,
						 prm_origemv         varchar2 default null,
						 prm_destinov        varchar2 default null,
						 prm_ida             varchar2 default null,
						 prm_volta           varchar2 default null,
						 prm_diaria          varchar2 default null,
						 prm_hida            varchar2 default null,
						 prm_hvolta          varchar2 default null,
						 prm_hospedagem      varchar2 default null,
						 prm_preferencia     varchar2 default null,
						 prm_carro           varchar2 default null,
						 prm_retirada        varchar2 default null,
						 prm_situacao        varchar2 default null,
						 prm_aerea           varchar2 default null,
                         prm_ad_opcao        varchar2 default null,
                         prm_ad_cidade       varchar2 default null,
                         prm_ad_periodo      varchar2 default null,
                         prm_ad_periodo_i    varchar2 default null,
                         prm_ad_periodo_f    varchar2 default null ) AS


		WS_COUNT    NUMBER;
	    WS_STATUS   VARCHAR2(200);
		WS_CONTEUDO BLOB;
		WS_IDA      VARCHAR2(40);
		WS_VOLTA    VARCHAR2(40);
		ws_ad_ida   VARCHAR2(40);
		ws_ad_volta VARCHAR2(40);
		ws_email    varchar2(120);


	BEGIN

	    SELECT COUNT(*) INTO WS_COUNT FROM OPR_REQUISICAO_VIAGEM WHERE TRIM(COD) = TRIM(PRM_COD);


	    IF WS_COUNT = 0 THEN
            --primeiro envio
	        SELECT to_char(sysdate, 'ddmmyyhhss')||to_char(COUNT(*)+1) INTO WS_COUNT FROM OPR_REQUISICAO_VIAGEM;

			BEGIN
                
				IF PRM_SITUACAO = 'INICIADO' OR PRM_SITUACAO = 'ANTECIPADO' OR (PRM_SITUACAO = 'APROVADO' and trim(PRM_SOLICITANTE) = trim(prm_aprovador)) THEN
						WS_CONTEUDO := EMAIL_SOLICITACAO('sv', WS_COUNT, TRIM(PRM_SOLICITANTE), TRIM(PRM_APROVADOR), TRIM(PRM_PASSAGEIRO), PRM_FILIAL, PRM_FILIAL_DESPESA, PRM_FUNCAO, PRM_CENTRO, PRM_CENTRO_DESPESA, PRM_MOTIVO, TRIM(PRM_CLIENTE), PRM_ORIGEM, PRM_DESTINO, WS_IDA, WS_VOLTA, PRM_DIARIA, PRM_HIDA, PRM_HVOLTA, PRM_HOSPEDAGEM, PRM_PREFERENCIA, PRM_CARRO, PRM_RETIRADA, '', PRM_AEREA);
						GERA_ACAO('REQV001', WS_COUNT, USER, 'Solicitacao de viagem ['||WS_COUNT||']', WS_CONTEUDO, PRM_MOTIVO, WS_STATUS);
						
						begin
							select usu_email into ws_email from usuarios where trim(usu_nome) = (select trim(cd_aprovador) from opr_aprovadores where trim(cd_subordinado) =  user);

							fcl.Xsend_Mail('', ws_email, 'SOLICITACAO EM ABERTO', 'Solicitacao #'||WS_COUNT||' do usuário '||upper(user)||' em aberto');
						end;


					IF INSTR(WS_STATUS, '%NO_CHECK%') = 0 THEN

						UPDATE OPR_DESPESAS_VIAGEM SET CD_REQUISICAO = WS_COUNT WHERE CD_REQUISICAO = 'new' AND USUARIO =  USER;

						INSERT INTO OPR_REQUISICAO_VIAGEM (COD, USUARIO, CD_SOLICITANTE, CD_APROVADOR, NM_PASSAGEIRO, CD_UNIDADE, CD_UNIDADE_DESPESA, CD_DEPARTAMENTO, CD_CENTRO, CD_CENTRO_DESPESA, DS_MOTIVO, CD_CLIENTE , DS_ORIGEM, DS_DESTINO, DS_ORIGEMV, DS_DESTINOV, DT_SAIDA, DT_RETORNO, DIARIA, HR_SAIDA, HR_RETORNO, ST_HOSPEDAGEM, NM_HOTEL, ST_VEICULO, LOCAL_VEICULO, CD_FLOWCTR, CD_SITUACAO, FLOW_AGENCIA, FLOW_FINANCEIRO, ST_AEREA, CD_FINANCEIRO, AD_OPCAO, AD_CIDADE, AD_PERIODO, ad_periodo_i, ad_periodo_f )

						VALUES (WS_COUNT, USER, TRIM(PRM_SOLICITANTE), TRIM(PRM_APROVADOR), TRIM(PRM_PASSAGEIRO), PRM_FILIAL, PRM_FILIAL_DESPESA, PRM_FUNCAO, PRM_CENTRO, PRM_CENTRO_DESPESA, PRM_MOTIVO, PRM_CLIENTE, PRM_ORIGEM, PRM_DESTINO, PRM_ORIGEMV, PRM_DESTINOV, WS_IDA, WS_VOLTA, PRM_DIARIA, PRM_HIDA, PRM_HVOLTA, PRM_HOSPEDAGEM, PRM_PREFERENCIA, PRM_CARRO, PRM_RETIRADA, WS_STATUS, PRM_SITUACAO, '', '', PRM_AEREA, '', prm_ad_opcao, prm_ad_cidade, prm_ad_periodo, ws_ad_ida, ws_ad_volta ); 

						htp.p('ok');

					ELSE

						htp.p(WS_STATUS);

					END IF;

				ELSE

				    UPDATE OPR_DESPESAS_VIAGEM SET CD_REQUISICAO = WS_COUNT WHERE CD_REQUISICAO = 'new' AND USUARIO =  USER;

				    INSERT INTO OPR_REQUISICAO_VIAGEM (COD, USUARIO, CD_SOLICITANTE, CD_APROVADOR, NM_PASSAGEIRO, CD_UNIDADE, CD_UNIDADE_DESPESA, CD_DEPARTAMENTO, CD_CENTRO, CD_CENTRO_DESPESA, DS_MOTIVO, CD_CLIENTE , DS_ORIGEM, DS_DESTINO, DS_ORIGEMV, DS_DESTINOV, DT_SAIDA, DT_RETORNO, DIARIA, HR_SAIDA, HR_RETORNO, ST_HOSPEDAGEM, NM_HOTEL, ST_VEICULO, LOCAL_VEICULO, CD_FLOWCTR, CD_SITUACAO, FLOW_AGENCIA, FLOW_FINANCEIRO, ST_AEREA, CD_FINANCEIRO, AD_OPCAO, AD_CIDADE, AD_PERIODO, ad_periodo_i, ad_periodo_f )

					VALUES (WS_COUNT, USER, TRIM(PRM_SOLICITANTE), TRIM(PRM_APROVADOR), TRIM(PRM_PASSAGEIRO), PRM_FILIAL, PRM_FILIAL_DESPESA, PRM_FUNCAO, PRM_CENTRO, PRM_CENTRO_DESPESA, PRM_MOTIVO, PRM_CLIENTE, PRM_ORIGEM, PRM_DESTINO, PRM_ORIGEMV, PRM_DESTINOV, WS_IDA, WS_VOLTA, PRM_DIARIA, PRM_HIDA, PRM_HVOLTA, PRM_HOSPEDAGEM, PRM_PREFERENCIA, PRM_CARRO, PRM_RETIRADA, '', PRM_SITUACAO, '', '', PRM_AEREA, '', prm_ad_opcao, prm_ad_cidade, prm_ad_periodo, ws_ad_ida, ws_ad_volta); 

					htp.p('ok');

				END IF;

			EXCEPTION WHEN OTHERS THEN

				htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

			END;

		ELSE

		    BEGIN

				IF PRM_SITUACAO = 'INICIADO' OR PRM_SITUACAO = 'ANTECIPADO' OR (PRM_SITUACAO = 'APROVADO' and trim(PRM_SOLICITANTE) = trim(prm_aprovador)) THEN

					WS_CONTEUDO := EMAIL_SOLICITACAO('sv', TRIM(PRM_COD), TRIM(PRM_SOLICITANTE), TRIM(PRM_APROVADOR), TRIM(PRM_PASSAGEIRO), fun.cdesc(trim(prm_filial),'PSQ_FILIAL'), fun.cdesc(prm_filial_despesa,'PSQ_FILIAL'), fun.cdesc(prm_funcao,'TX_FUNCOES'), fun.cdesc(prm_centro,'PSQ_CUSTO'), fun.cdesc(trim(prm_centro_despesa),'PSQ_CUSTO'), PRM_MOTIVO, cdesc(trim(prm_cliente),'PSQ_CLIENTE'), cdesc(prm_origem, 'PSQ_CIDADES'), cdesc(prm_destino, 'PSQ_CIDADES'), WS_IDA, WS_VOLTA, PRM_DIARIA, PRM_HIDA, PRM_HVOLTA, PRM_HOSPEDAGEM, PRM_PREFERENCIA, PRM_CARRO, PRM_RETIRADA, '', PRM_AEREA);

					GERA_ACAO('REQV001', TRIM(PRM_COD), USER, 'Solicitacao de viagem ['||TRIM(PRM_COD)||']', WS_CONTEUDO, PRM_MOTIVO, WS_STATUS);

					IF INSTR(WS_STATUS, '%NO_CHECK%') = 0 THEN

						UPDATE OPR_REQUISICAO_VIAGEM SET
						CD_SOLICITANTE = TRIM(PRM_SOLICITANTE),
						CD_APROVADOR = TRIM(PRM_APROVADOR),
						NM_PASSAGEIRO = TRIM(PRM_PASSAGEIRO),
						CD_UNIDADE = PRM_FILIAL,
						CD_UNIDADE_DESPESA = PRM_FILIAL_DESPESA,
						CD_DEPARTAMENTO = PRM_FUNCAO,
						CD_CENTRO = PRM_CENTRO,
						CD_CENTRO_DESPESA = PRM_CENTRO_DESPESA,
						DS_MOTIVO = PRM_MOTIVO,
						CD_CLIENTE = PRM_CLIENTE,
						DS_ORIGEM = PRM_ORIGEM,
						DS_DESTINO = PRM_DESTINO,
						DS_ORIGEMV = PRM_ORIGEMV,
						DS_DESTINOV = PRM_DESTINOV,
						DT_SAIDA = WS_IDA,
						DT_RETORNO = WS_VOLTA,
						DIARIA = PRM_DIARIA,
						HR_SAIDA = PRM_HIDA,
						HR_RETORNO = PRM_HVOLTA,
						ST_HOSPEDAGEM = PRM_HOSPEDAGEM,
						NM_HOTEL = PRM_PREFERENCIA,
						ST_VEICULO = PRM_CARRO,
						LOCAL_VEICULO = PRM_RETIRADA,
						CD_FLOWCTR = WS_STATUS,
						CD_SITUACAO = PRM_SITUACAO,
						ST_AEREA = PRM_AEREA,
                        AD_OPCAO = prm_ad_opcao, 
                        AD_CIDADE = prm_ad_cidade,
                        AD_PERIODO = prm_ad_periodo,
                        ad_periodo_i = ws_ad_ida, 
                        ad_periodo_f = ws_ad_volta
						WHERE TRIM(COD) = TRIM(PRM_COD);

						htp.p('ok');

					ELSE

					    htp.p(WS_STATUS);

					END IF;

				ELSE

					UPDATE OPR_REQUISICAO_VIAGEM SET
					CD_SOLICITANTE = TRIM(PRM_SOLICITANTE),
					CD_APROVADOR = TRIM(PRM_APROVADOR),
					NM_PASSAGEIRO = TRIM(PRM_PASSAGEIRO),
					CD_UNIDADE = PRM_FILIAL,
					CD_UNIDADE_DESPESA = PRM_FILIAL_DESPESA,
					CD_DEPARTAMENTO = PRM_FUNCAO,
					CD_CENTRO = PRM_CENTRO,
					CD_CENTRO_DESPESA = PRM_CENTRO_DESPESA,
					DS_MOTIVO = PRM_MOTIVO,
					CD_CLIENTE = PRM_CLIENTE,
					DS_ORIGEM = PRM_ORIGEM,
					DS_DESTINO = PRM_DESTINO,
					DS_ORIGEMV = PRM_ORIGEMV,
					DS_DESTINOV = PRM_DESTINOV,
					DT_SAIDA = WS_IDA,
					DT_RETORNO = WS_VOLTA,
					DIARIA = PRM_DIARIA,
					HR_SAIDA = PRM_HIDA,
					HR_RETORNO = PRM_HVOLTA,
					ST_HOSPEDAGEM = PRM_HOSPEDAGEM,
					NM_HOTEL = PRM_PREFERENCIA,
					ST_VEICULO = PRM_CARRO,
					LOCAL_VEICULO = PRM_RETIRADA,
					CD_FLOWCTR = WS_STATUS,
					CD_SITUACAO = PRM_SITUACAO,
					ST_AEREA = PRM_AEREA,
                    AD_OPCAO = prm_ad_opcao, 
                    AD_CIDADE = prm_ad_cidade,
                    AD_PERIODO = prm_ad_periodo,
                    ad_periodo_i = ws_ad_ida, 
                    ad_periodo_f = ws_ad_volta
					WHERE TRIM(COD) = TRIM(PRM_COD);

					htp.p('ok');

				END IF;

			EXCEPTION WHEN OTHERS THEN

				htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' -- '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);

			END;

		END IF;
    exception when others then
        htp.p(sqlerrm);
	END INSERIR;

	
	procedure inserir_despesa (  prm_requisicao   varchar2 default null, 
			                     prm_emissao      varchar2 default null,
			                     prm_tipo         varchar2 default 'CARTAO-INTERNO',
								 prm_moeda        varchar2 default null, 
								 prm_despesa      varchar2 default null, 
								 prm_cartao       varchar2 default null, 
								 prm_valor        varchar2 default null, 
								 prm_obs          varchar2 default null,
								 prm_geo          varchar2 default null,
		                         prm_cambio       varchar2 default null,
		                         prm_moeda_troca  varchar2 default null,
		                         prm_item         varchar2 default null ) as

		ws_emissao  varchar2(40);
		ws_count    number;
		ws_cambio   varchar2(40);  

	begin
	
	    begin
	        ws_emissao   := to_date(prm_emissao, 'DD/MM/YYYY');
		exception when others then
			ws_emissao   := to_date(prm_emissao, 'DD/MM/YYYY');
		end;

		begin
			
            if prm_despesa = '0018' or prm_despesa = '0019' then
			    select count(*) into ws_count from 	OPR_DESPESAS_VIAGEM
			    where cd_requisicao = prm_requisicao and nr_item = prm_item;
			    if ws_count = 0 then
			        begin
					    select max(nr_item)+1 into ws_count from opr_despesas_viagem;
					exception when others then
					    ws_count := 1;
					end;
			        insert into OPR_DESPESAS_VIAGEM (CD_REQUISICAO, NR_ITEM, USUARIO, ST_CARTAO, DT_REGISTRO, DT_EMISSAO, LOCALIZACAO, CD_DESPESA, CD_MOEDA, VL_DESPESA, OBSERVACAO, TIPO, CAMBIO, CD_MOEDA_TROCA) values (prm_requisicao, nvl(ws_count, 1), user, prm_cartao, sysdate, ws_emissao, decode(prm_geo, 'undefined', 'INDEFINIDO', prm_geo), prm_despesa, prm_moeda, prm_valor, prm_obs, upper(prm_tipo), prm_cambio, prm_moeda_troca);
				    commit;
					htp.p('ok');
			    else
			        update OPR_DESPESAS_VIAGEM 
			        set dt_emissao = ws_emissao,
			        cd_moeda = prm_moeda,
			        vl_despesa = prm_valor,
			        cambio = prm_cambio,
			        cd_moeda_troca = prm_moeda_troca
			        where cd_requisicao = prm_requisicao and nr_item = prm_item;
				    commit;
					htp.p('ok');
			    end if;
			else
			    begin
				select cambio into ws_cambio from opr_despesas_viagem
			    where cd_requisicao = prm_requisicao and cd_moeda = prm_moeda and cd_despesa = '0019' and tipo = prm_tipo;
			    exception when others then
				    ws_cambio := 1;
				end;
				select max(nr_item)+1 into ws_count from opr_despesas_viagem;
		        insert into OPR_DESPESAS_VIAGEM (CD_REQUISICAO, NR_ITEM, USUARIO, ST_CARTAO, DT_REGISTRO, DT_EMISSAO, LOCALIZACAO, CD_DESPESA, CD_MOEDA, VL_DESPESA, OBSERVACAO, TIPO, CAMBIO, CD_MOEDA_TROCA) values (prm_requisicao, nvl(ws_count, 1), user, prm_cartao, sysdate, ws_emissao, decode(prm_geo, 'undefined', 'INDEFINIDO', prm_geo), prm_despesa, prm_moeda, prm_valor, prm_obs, upper(prm_tipo), nvl(ws_cambio, 1), prm_moeda_troca);
			    commit;
				htp.p('ok');
			end if;

		exception when others then
		    htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
		end;

	end inserir_despesa;

	
	procedure lista ( prm_requisicao varchar2 default null ) as

	cursor crs_linhas is 
	select cd_requisicao, nr_item, usuario, dt_registro, dt_emissao, localizacao, (select ds_despesa from taux_tp_despesa where cd_despesa = t1.cd_despesa) as despesa, cd_despesa, (select ds_simbolo from taux_moeda where cd_moeda = t1.cd_moeda) as moeda, vl_despesa, observacao
	from OPR_DESPESAS_VIAGEM t1
	where usuario = user and cd_requisicao = prm_requisicao and tipo = 'CARTAO-INTERNO'
	order by dt_emissao desc;

	ws_linha crs_linhas%rowtype;

	begin

		htp.p('<ul class="main invisible">');

	        htp.p('<li class="titulo">LISTA DE DESPESAS</li>');

			htp.p('<li>');
				htp.p('<span class="desc" style="text-align: center; min-width: calc(25% - 2px); width: calc(25% - 2px);">DATA DA DESPESA</span>');
				htp.p('<span class="desc" style="text-align: center; min-width: calc(25% - 2px); width: calc(25% - 2px);">TIPO DA DESPESA</span>');
				htp.p('<span class="desc" style="text-align: center; min-width: calc(25% - 2px); width: calc(25% - 2px);">VALOR GASTO </span>');
				htp.p('<span class="desc" style="text-align: center; min-width: 25%; width: 25%;"></span>');
			htp.p('</li>');

		open crs_linhas;
		    loop
			    fetch crs_linhas into ws_linha;
			    exit when crs_linhas%notfound;
			    htp.p('<li>');

					htp.p('<span class="input" style="border-right: 2px solid #333; min-width: calc(25% - 2px); width: calc(25% - 2px);">');
					    htp.p('<input id="'||ws_linha.nr_item||'-data" onchange="" class="txt" type="text" onmouseover="calendar.set(this.id);" value="'||to_char(to_date(ws_linha.dt_emissao), 'DD-Mon-YYYY')||'" title="'||ws_linha.dt_emissao||'">');
					htp.p('</span>');

					htp.p('<span class="input" style="border-right: 2px solid #333; min-width: calc(25% - 2px); width: calc(25% - 2px);">');
					    htp.p('<select id="'||ws_linha.nr_item||'-despesa" class="txt" onchange="">');
							for i in(select cd_despesa, ds_despesa from taux_tp_despesa where cd_despesa <> '0016' order by ds_despesa) loop
								if i.cd_despesa = ws_linha.cd_despesa then
								    htp.p('<option selected value="'||i.cd_despesa||'">'||i.ds_despesa||'</option>');
								else
								    htp.p('<option value="'||i.cd_despesa||'">'||i.ds_despesa||'</option>');
								end if;
							end loop;
						htp.p('</select>');
					htp.p('</span>');

					htp.p('<span class="input" style="border-right: 2px solid #333; min-width: calc(25% - 2px); width: calc(25% - 2px);"><input id="'||ws_linha.nr_item||'-valor" value="'||ws_linha.moeda||' '||trim(to_char(ws_linha.vl_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.'))||'" oninput="this.value = VMasker.toMoney(this.value);" type="text" class="txt"/></span>');
					htp.p('<span style="min-width: calc(25% - 2px); width: calc(25% - 2px); text-align: center;"><a onclick="var valor = parseFloat(document.getElementById('''||ws_linha.nr_item||'-valor'').value.replace(/\./g, '''').replace('','', ''.'')).toFixed(2); da_alterar(''prm_item='||ws_linha.nr_item||'&prm_despesa=''+document.getElementById('''||ws_linha.nr_item||'-despesa'').value+''&prm_data=''+document.getElementById('''||ws_linha.nr_item||'-data'').value+''&prm_valor=''+);" class="save" style="float: none; height: 33px; line-height: 33px; margin: 0 4px; display: inline; background-color: rgb(59, 165, 109); padding: 2px;">ALTERAR</a><a class="remove" title="Remover" onclick="if(confirm(''Excluir linha?'')){ excluir(this.parentNode.parentNode, ''pc'', ''prm_item='||ws_linha.nr_item||'''); }">X</a></span>');

				htp.p('</li>');
			end loop;
		close crs_linhas;

	    htp.p('</ul>');

	end lista;
	

	procedure alterar ( prm_item     number   default null,
	                    prm_despesa  varchar2 default null,
	                    prm_data     varchar2 default null,
						prm_valor    varchar2 default null ) as

	begin

	    begin

			update opr_despesas_viagem
			set dt_emissao = to_date(prm_data, 'DD-MON-YYYY HH24:MI', 'NLS_DATE_LANGUAGE=ENGLISH'),
			cd_despesa     = prm_despesa,
			vl_despesa     = to_number(prm_valor)
			where nr_item = prm_item;
			commit;
			htp.p('ok');		

		exception when others then
		    htp.p(sqlerrm);
		end;

	end;

	
	procedure excluir ( prm_item number default null ) as

	begin

	    begin

			delete from OPR_DESPESAS_VIAGEM
			where nr_item = prm_item and
			usuario = user; 
		    commit;
			htp.p('ok');

		exception when others then
		    htp.p(sqlerrm);
		end;

	end excluir;

	
	procedure moedas_usadas ( prm_requisicao varchar2 default null ) as 

        
        cursor crs_despesas_dia is
        select distinct cd_moeda, dt_emissao from opr_despesas_viagem
        where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa in ('0001', '0009', '0010', '0014', '0016') and tipo = 'DESPESA-INTERNA'
        order by dt_emissao desc;

        ws_dia crs_despesas_dia%rowtype;
        
        cursor crs_despesas_cartao is
        select distinct cd_moeda, dt_emissao from opr_despesas_viagem
        where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa in ('0001', '0009', '0010', '0014', '0016') and tipo = 'CARTAO-INTERNO'
        order by dt_emissao desc;

        ws_cartao crs_despesas_cartao%rowtype;
        
        
        cursor crs_adiantamentos is
        select nr_item, dt_emissao, cd_moeda, vl_despesa, cambio, cd_moeda_troca, rownum as linha from opr_despesas_viagem
        where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa = '0019'
        order by dt_emissao;

        ws_adiantamento crs_adiantamentos%rowtype;
        
        cursor crs_moedas is
        select cd_moeda, ds_moeda from taux_moeda;
        
        ws_moedas crs_moedas%rowtype;
        
        cursor crs_total_despesas is
        select 'TOTAL '||(select ds_moeda from taux_moeda where cd_moeda = t1.cd_moeda) as moeda, sum(vl_despesa) as despesa from opr_despesas_viagem t1 
        where cd_requisicao = prm_requisicao and tipo = 'DESPESA-INTERNA' group by cd_moeda;
        
        ws_total_despesa crs_total_despesas%rowtype;
        
        
        cursor crs_total_cartao is
        select 'TOTAL '||(select ds_moeda from taux_moeda where cd_moeda = t1.cd_moeda) as moeda, sum(vl_despesa) as despesa from opr_despesas_viagem t1 
        where cd_requisicao = prm_requisicao and tipo = 'CARTAO-INTERNO' group by cd_moeda;
        
        ws_total_cartao crs_total_cartao%rowtype;
        
        
        cursor crs_observacoes is
        select observacao, dt_emissao, 
        decode(cd_despesa, '0001', 'ALIMENTAÇÃO', '0016', 'TRANSPORTE', '0009', 'ALUGUEL', '0010', 'HOSPEDAGEM', '0014', 'OUTROS', 'INVALIDO') as despesa, 
        (select ds_moeda from taux_moeda where cd_moeda = t1.cd_moeda) as moeda from opr_despesas_viagem t1
        where length(trim(observacao)) > 0 and cd_requisicao = prm_requisicao and (tipo = 'DESPESA-INTERNA' or tipo = 'CARTAO-INTERNO')
        order by dt_emissao desc;
        
        ws_observacao crs_observacoes%rowtype;
        

        ws_despesa          number;
        ws_despesa_total    number;
        ws_moeda            varchar2(100);
        ws_cambio           number;
        ws_total_somatoria  number := 0;
        ws_numero_dias      number := 0;
        ws_total_moeda      number;
        ws_count            number := 0;
        ws_adiantamento_ok  varchar2(1);
        ws_hospedagem       number := 0;
        ws_outras           number := 0;
        ws_alimentacao      number := 0;
        ws_aluguel          number := 0;
        ws_transporte       number := 0;
        ws_despesa_total_s  number := 0;
        ws_count_moedas     number := 0;
        
	
	begin
	   
        
        /*if user = 'DWU' then
	        select ad_opcao into ws_adiantamento_ok from opr_requisicao_viagem where cod = prm_requisicao;
	    else
	        select ad_opcao into ws_adiantamento_ok from opr_requisicao_viagem where usuario = user and cod = prm_requisicao;
	    end if;
	
	    if ws_adiantamento_ok = 'S' then
	
		    htp.p('<li class="titulo">ADIANTAMENTO E MOEDAS USADAS</li>');
	        
	        htp.p('<li>');
				htp.p('<span class="desc" style="min-width: calc(20% - 2px); width: calc(20% - 2px);">DATA</span>');
				htp.p('<span class="desc" style="min-width: calc(20% - 2px); width: calc(20% - 2px);">MOEDA UTILIZADA</span>');
				htp.p('<span class="desc" style="min-width: calc(20% - 2px); width: calc(20% - 2px);">VALOR RECEBIDO</span>');
				
				htp.p('<span class="desc" style="min-width: calc(20% - 2px); width: calc(20% - 2px);">CÂMBIO DIA RECEBIDO</span>');
				htp.p('<span class="desc" style="min-width: 20%; width: 20%;">VALOR R$</span>');
	            --htp.p('<span class="desc" style="min-width: 18px; width: 18px;"></span>');
			htp.p('</li>');
	        

	        open crs_adiantamentos;
				loop
                fetch crs_adiantamentos into ws_adiantamento;
                exit when crs_adiantamentos%notfound;
                    ws_count := ws_count+1;
                    htp.p('<li class="'||ws_adiantamento.nr_item||'">');
                        htp.p('<span class="" style="min-width: calc(20% - 2px); width: calc(20% - 2px); border-right: 2px solid #555;"><input  class="txt" value="'||to_char(ws_adiantamento.dt_emissao, 'DD/MM/YYYY')||'" oninput="this.value = VMasker.toPattern(this.value, ''99/99/9999'');" onblur="enviar_adiantamento(this.parentNode.parentNode);"/></span>');
                        htp.p('<span class="" style="min-width: calc(20% - 2px); width: calc(20% - 2px); border-right: 2px solid #555;">');
	                        htp.p('<select class="txt" onchange="enviar_adiantamento(this.parentNode.parentNode);">');
								htp.p('<option data-simbolo="" value="">---</option>');
								for i in(select cd_moeda, ds_moeda, ds_simbolo from taux_moeda) loop
									if i.cd_moeda = ws_adiantamento.cd_moeda then
									    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'" selected>'||i.ds_moeda||'</option>');
									else
									    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'">'||i.ds_moeda||'</option>');
									end if;
								end loop;
						    htp.p('</select>');
						htp.p('</span>');
						
                        htp.p('<span class="" style="min-width: calc(20% - 2px); width: calc(20% - 2px); border-right: 2px solid #555;"><input  class="txt" value="'||to_char(ws_adiantamento.vl_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" oninput="this.value = VMasker.toMoney(this.value);" onblur="enviar_adiantamento(this.parentNode.parentNode);"/></span>');
                        
                        
                        htp.p('<span style="min-width: calc(20% - 2px); width: calc(20% - 2px); border-right: 2px solid #555;"><input  class="txt" value="'||to_char(ws_adiantamento.cambio, '999G999G999G999G990D0099999', 'NLS_NUMERIC_CHARACTERS=,.')||'" oninput="VMasker(this).maskMoney({ precision: 7 });" onblur="enviar_adiantamento(this.parentNode.parentNode);" /></span>');
                        htp.p('<span style="min-width: 20%; width: 20% ; border-right: 2px solid #555;" class="readonly"><input  class="txt" value="'||to_char(ws_adiantamento.vl_despesa*ws_adiantamento.cambio, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" disabled/></span>');
                        --htp.p('<span style="min-width: 20px; width: 20px;"><a class="remove" onclick="loading(); call(''excluir_troca_moeda'', ''prm_item='||ws_adiantamento.nr_item||''', ''da'').then(function(resposta){ if(resposta.indexOf(''OK'') != -1){ alerta(''feed-fixo'', tr_ex); setTimeout(function(){ call(''moedas_usadas'', ''prm_requisicao=''+document.getElementById(''solicitacoes'').value, ''DA'').then(function(resposta){ loading(); document.getElementById(''moedas_usadas_append'').classList.remove(''invisible''); document.getElementById(''moedas_usadas_append'').innerHTML = resposta; }) },1000); } else { alerta(''feed-fixo'', tr_xc); setTimeout(function(){ loading(); }, 1000); } });">X</a></span>');
                    htp.p('</li>');
	            end loop;
	        close crs_adiantamentos;
	        
	        
	        if ws_count < 4 then
	        loop
	            ws_count := ws_count+1;
	            htp.p('<li class="'||ws_count||'">');
	                htp.p('<span class="" style="min-width: calc(20% - 2px); width: calc(20% - 2px); border-right: 2px solid #555;"><input class="txt" value="" oninput="this.value = VMasker.toPattern(this.value, ''99/99/9999'');" onblur="enviar_adiantamento(this.parentNode.parentNode);"/></span>');
	                htp.p('<span class="" style="min-width: calc(20% - 2px); width: calc(20% - 2px); border-right: 2px solid #555;">');
	                    htp.p('<select class="txt" onchange="enviar_adiantamento(this.parentNode.parentNode);">');
							htp.p('<option data-simbolo="" value="">---</option>');
							for i in(select cd_moeda, ds_moeda, ds_simbolo from taux_moeda) loop
								if i.cd_moeda = 'REAL' then
								    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'" selected>'||i.ds_moeda||'</option>');
								else
								    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'">'||i.ds_moeda||'</option>');
								end if;
							end loop;
							
						htp.p('</select>');
	                htp.p('</span>');
	                
	                htp.p('<span class="" style="min-width: calc(20% - 2px); width: calc(20% - 2px); border-right: 2px solid #555;"><input class="txt" value="0,00" oninput="this.value = VMasker.toMoney(this.value);" onblur="enviar_adiantamento(this.parentNode.parentNode);"/></span>');
	                
	                htp.p('<span class="" style="min-width: calc(20% - 2px); width: calc(20% - 2px); border-right: 2px solid #555;"><input class="txt" value="0,00" oninput="this.value = VMasker.toMoney(this.value);" onblur="enviar_adiantamento(this.parentNode.parentNode);"/></span>');
	                htp.p('<span class="readonly" style="min-width: 20%; width: 20%; border-right: 2px solid #555;"><input disabled class="txt" value="0,00" /></span>');
	                --htp.p('<span style="min-width: 20px; width: 20px;"><a class="remove" onclick="loading(); call(''excluir_troca_moeda'', ''prm_item='||ws_count||''', ''da'').then(function(resposta){ if(resposta.indexOf(''OK'') != -1){ alerta(''feed-fixo'', tr_ex); setTimeout(function(){ call(''moedas_usadas'', ''prm_requisicao=''+document.getElementById(''solicitacoes'').value, ''DA'').then(function(resposta){ loading(); document.getElementById(''moedas_usadas_append'').classList.remove(''invisible''); document.getElementById(''moedas_usadas_append'').innerHTML = resposta; }) },1000); } else { alerta(''feed-fixo'', tr_xc); setTimeout(function(){ loading(); }, 1000); } });">X</a></span>');
	            htp.p('</li>');
	            
	            if ws_count = 4 then 
	                exit;
	            end if;
	        end loop;
	        end if;
			
			--htp.p('<li style="height: auto; flex-wrap: wrap; line-height: 32px;"><a class="subicon" onclick="loading(); enviar_adiantamento(this.parentNode);">GRAVAR</a></li>');

	        
	        htp.p('<li class="space"></li>');
			htp.p('<li class="space noprint"></li>');
			
			htp.p('<li class="titulo">MOEDA TROCADA DURANTE A VIAGEM</li>');
	        
	        htp.p('<li>');
				htp.p('<span class="desc" style="min-width: calc(17% - 5px); width: calc(17% - 5px);">DATA</span>');
				htp.p('<span class="desc" style="min-width: calc(17% - 5px); width: calc(17% - 5px);">MOEDA UTILIZADA</span>');
				htp.p('<span class="desc" style="min-width: calc(17% - 5px); width: calc(17% - 5px);">MOEDA DE TROCA</span>');
				htp.p('<span class="desc" style="min-width: calc(17% - 5px); width: calc(17% - 5px);">VALOR DA TROCA</span>');
				
				htp.p('<span class="desc" style="min-width: calc(16% - 5px); width: calc(16% - 5px);">CÂMBIO DIA TROCADO</span>');
				htp.p('<span class="desc" style="min-width: calc(16% + 16px); width: calc(16% + 16px);">VALOR</span>');
	            --htp.p('<span class="desc" style="min-width: 16px; width: 16px;"></span>');
			htp.p('</li>');
			
			ws_count := 0;
	        
	        open crs_conversoes;
				loop
	                fetch crs_conversoes into ws_conversao;
	                exit when crs_conversoes%notfound;
	                    ws_count := ws_count+1;
	                    htp.p('<li class="'||ws_conversao.nr_item||'">');
	                        htp.p('<span class="" style="min-width: calc(17% - 5px); width: calc(17% - 5px); border-right: 2px solid #555;"><input class="txt" value="'||to_char(ws_conversao.dt_emissao, 'DD/MM/YYYY')||'" oninput="this.value = VMasker.toPattern(this.value, ''99/99/9999'');" onblur="enviar_trocada(this.parentNode.parentNode);"/></span>');
	                        htp.p('<span class="" style="min-width: calc(17% - 5px); width: calc(17% - 5px); border-right: 2px solid #555;">');
		                        htp.p('<select class="txt" onchange="enviar_trocada(this.parentNode.parentNode);">');
									htp.p('<option data-simbolo="" value="">---</option>');
									for i in(select cd_moeda, ds_moeda, ds_simbolo from taux_moeda) loop
										if i.cd_moeda = ws_conversao.cd_moeda then
										    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'" selected>'||i.ds_moeda||'</option>');
										else
										    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'">'||i.ds_moeda||'</option>');
										end if;
									end loop;
									
							    htp.p('</select>');
							htp.p('</span>');
							htp.p('<span class="" style="min-width: calc(17% - 5px); width: calc(17% - 5px); border-right: 2px solid #555;">');
	                            htp.p('<select class="txt" onchange="enviar_trocada(this.parentNode.parentNode);">');
									htp.p('<option data-simbolo="" value="">---</option>');
									for i in(select cd_moeda, ds_moeda, ds_simbolo from taux_moeda) loop
										if i.cd_moeda = ws_conversao.cd_moeda_troca then
										    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'" selected>'||i.ds_moeda||'</option>');
										else
										    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'">'||i.ds_moeda||'</option>');
										end if;
									end loop;
									
							    htp.p('</select>');
	                        htp.p('</span>');
	                        htp.p('<span class="" style="min-width: calc(17% - 5px); width: calc(17% - 5px); border-right: 2px solid #555;"><input class="txt" value="'||to_char(ws_conversao.vl_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" oninput="this.value = VMasker.toMoney(this.value);" onblur="enviar_trocada(this.parentNode.parentNode);" /></span>');
	                        
	                        
	                        htp.p('<span style="min-width: calc(16% - 5px); width: calc(16% - 5px); border-right: 2px solid #555;"><input class="txt" value="'||to_char(ws_conversao.cambio, '999G999G999G999G990D0099999', 'NLS_NUMERIC_CHARACTERS=,.')||'" oninput="VMasker(this).maskMoney({ precision: 7 });" onblur="enviar_trocada(this.parentNode.parentNode);" /></span>');
	                        htp.p('<span style="min-width: calc(16% + 16px); width: calc(16% + 16px); border-right: 2px solid #555;" class="readonly"><input  class="txt" value="'||to_char(ws_conversao.vl_despesa*ws_conversao.cambio, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" disabled/></span>');
	                        --htp.p('<span style="min-width: 18px; width: 18px;"><a class="remove" onclick="loading(); call(''excluir_troca_moeda'', ''prm_item='||ws_conversao.nr_item||''', ''da'').then(function(resposta){ if(resposta.indexOf(''OK'') != -1){ alerta(''feed-fixo'', tr_ex); setTimeout(function(){ call(''moedas_usadas'', ''prm_requisicao=''+document.getElementById(''solicitacoes'').value, ''DA'').then(function(resposta){ loading(); document.getElementById(''moedas_usadas_append'').classList.remove(''invisible''); document.getElementById(''moedas_usadas_append'').innerHTML = resposta; }) },1000); } else { alerta(''feed-fixo'', tr_xc); setTimeout(function(){ loading(); }, 1000); } });">X</a></span>');
	                    htp.p('</li>');
	            end loop;
	        close crs_conversoes;
	        
	        if ws_count < 4 then
	        loop
	            ws_count := ws_count+1;
	            htp.p('<li class="'||ws_count||'">');
	                htp.p('<span class="" style="min-width: calc(17% - 5px); width: calc(17% - 5px); border-right: 2px solid #555;"><input class="txt" value="" oninput="this.value = VMasker.toPattern(this.value, ''99/99/9999'');" onblur="enviar_trocada(this.parentNode.parentNode);"/></span>');
	                htp.p('<span class="" style="min-width: calc(17% - 5px); width: calc(17% - 5px); border-right: 2px solid #555;">');
	                    htp.p('<select class="txt" onchange="enviar_trocada(this.parentNode.parentNode);">');
	                        htp.p('<option data-simbolo="" value="">---</option>');
							for i in(select cd_moeda, ds_moeda, ds_simbolo from taux_moeda) loop
								if i.cd_moeda = 'REAL' then
								    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'" selected>'||i.ds_moeda||'</option>');
								else
								    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'">'||i.ds_moeda||'</option>');
								end if;
							end loop;
						htp.p('</select>');
	                htp.p('</span>');
	                htp.p('<span class="" style="min-width: calc(17% - 5px); width: calc(17% - 5px); border-right: 2px solid #555;">');
	                    htp.p('<select class="txt" onchange="enviar_trocada(this.parentNode.parentNode);">');
	                        htp.p('<option data-simbolo="" value="">---</option>');
							for i in(select cd_moeda, ds_moeda, ds_simbolo from taux_moeda) loop
								if i.cd_moeda = 'REAL' then
								    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'" selected>'||i.ds_moeda||'</option>');
								else
								    htp.p('<option data-simbolo="'||i.ds_simbolo||'" value="'||i.cd_moeda||'">'||i.ds_moeda||'</option>');
								end if;
							end loop;
							
						htp.p('</select>');
	                htp.p('</span>');
	                htp.p('<span class="" style="min-width: calc(17% - 5px); width: calc(17% - 5px); border-right: 2px solid #555;"><input class="txt" value="0,00" oninput="this.value = VMasker.toMoney(this.value);" onblur="enviar_trocada(this.parentNode.parentNode);" /></span>');
	                
	                htp.p('<span class="" style="min-width: calc(16% - 5px); width: calc(16% - 5px); border-right: 2px solid #555;"><input class="txt" value="0,00" oninput="this.value = VMasker.toMoney(this.value);" onblur="enviar_trocada(this.parentNode.parentNode);" /></span>');
	                htp.p('<span class="readonly" style="min-width: calc(16% + 16px); width: calc(16% + 16px); border-right: 2px solid #555;"><input disabled class="txt" value="0,00" /></span>');
	                --htp.p('<span style="min-width: 18px; width: 18px;"><a class="remove" onclick="loading(); call(''excluir_troca_moeda'', ''prm_item='||ws_count||''', ''da'').then(function(resposta){ if(resposta.indexOf(''OK'') != -1){ alerta(''feed-fixo'', tr_ex); setTimeout(function(){ call(''moedas_usadas'', ''prm_requisicao=''+document.getElementById(''solicitacoes'').value, ''DA'').then(function(resposta){ loading(); document.getElementById(''moedas_usadas_append'').classList.remove(''invisible''); document.getElementById(''moedas_usadas_append'').innerHTML = resposta; }) },1000); } else { alerta(''feed-fixo'', tr_xc); setTimeout(function(){ loading(); }, 1000); } });">X</a></span>');
	            htp.p('</li>');
	            
	            if ws_count = 4 then 
	                exit;
	            end if;
	        end loop;
	        end if;
	        
	        --htp.p('<li style="height: auto; flex-wrap: wrap; line-height: 32px;"><a class="subicon" onclick="loading(); enviar_trocada(this.parentNode);">GRAVAR</a></li>');
		
		    htp.p('<li class="space"></li>');
			htp.p('<li class="space noprint"></li>');
		
		end if;*/
	
        htp.p('<li class="titulo">DESPESAS EM DINHEIRO</li>');
					
        htp.p('<li>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">DATA</span>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">ALIMENTAÇÃO</span>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">TRANSPORTE</span>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">ALUGUEL</span>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">HOSPEDAGEM</span>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">OUTRAS DESPESAS</span>');
            htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">TOTAL</span>');
            htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">MOEDA UTILIZADA</span>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">CÂMBIO</span>');
            htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">TOTAL R$</span>');
            htp.p('<span class="desc" style="min-width: 20px; width: 20px;"></span>');
		htp.p('</li>');
	
        open crs_despesas_dia;
            loop
                fetch crs_despesas_dia into ws_dia;
                exit when crs_despesas_dia%notfound;
				htp.p('<li>');

                    ws_despesa_total := 0;
                    ws_cambio        := 0;
                    ws_despesa       := 0;

                    select max(cambio) into ws_cambio from opr_despesas_viagem where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and dt_emissao = ws_dia.dt_emissao and cd_moeda = ws_dia.cd_moeda and tipo = 'DESPESA-INTERNA';
           
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_dia.dt_emissao, 'DD/MM/YYYY')||'"/></span>');
                   
					select nvl(sum(vl_despesa), 0) into ws_despesa from opr_despesas_viagem where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa = '0001' and dt_emissao = ws_dia.dt_emissao and cd_moeda = ws_dia.cd_moeda and tipo = 'DESPESA-INTERNA';
					ws_despesa_total := ws_despesa_total+ws_despesa;
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
					ws_alimentacao   := ws_alimentacao+ws_despesa;
					ws_despesa       := 0;

                    select nvl(sum(vl_despesa), 0) into ws_despesa from opr_despesas_viagem where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa = '0016' and dt_emissao = ws_dia.dt_emissao and cd_moeda = ws_dia.cd_moeda and tipo = 'DESPESA-INTERNA';
					ws_despesa_total := ws_despesa_total+ws_despesa;
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
					ws_transporte    := ws_transporte+ws_despesa;
					ws_despesa       := 0;

                    select nvl(sum(vl_despesa), 0) into ws_despesa from opr_despesas_viagem where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa = '0009' and dt_emissao = ws_dia.dt_emissao and cd_moeda = ws_dia.cd_moeda and tipo = 'DESPESA-INTERNA';
					ws_despesa_total := ws_despesa_total+ws_despesa;
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
					ws_aluguel       := ws_aluguel+ws_despesa;
					ws_despesa       := 0;

                    select nvl(sum(vl_despesa), 0) into ws_despesa from opr_despesas_viagem where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa = '0010' and dt_emissao = ws_dia.dt_emissao and cd_moeda = ws_dia.cd_moeda and tipo = 'DESPESA-INTERNA';
					ws_despesa_total := ws_despesa_total+ws_despesa;
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
				    ws_hospedagem    := ws_hospedagem+ws_despesa;
				    ws_despesa       := 0;
				    
				    select nvl(sum(vl_despesa), 0) into ws_despesa from opr_despesas_viagem where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa = '0014' and dt_emissao = ws_dia.dt_emissao and cd_moeda = ws_dia.cd_moeda and tipo = 'DESPESA-INTERNA';
					ws_despesa_total := ws_despesa_total+ws_despesa;
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
					ws_outras        := ws_outras+ws_despesa;
					ws_despesa       := 0;

                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa_total, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
                    ws_despesa_total_s := ws_despesa_total_s+ws_despesa_total;
                    
                    select ds_moeda into ws_moeda from taux_moeda where cd_moeda = ws_dia.cd_moeda;
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||ws_moeda||'"/></span>');
                    
                    if ws_dia.cd_moeda = '01' then
                        htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="-"/></span>');
                    else
                        htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_cambio, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
                        ws_despesa_total := ws_despesa_total*ws_cambio;
                    end if;
                    
                    ws_total_somatoria := ws_total_somatoria+ws_despesa_total;

                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt tot" disabled value="'||to_char(ws_despesa_total, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
                    
                    htp.p('<span style="min-width: 20px; width: 20px;"><a class="remove" onclick="loading(); call(''excluir_despesa'', ''prm_emissao='||ws_dia.dt_emissao||'&prm_moeda='||ws_dia.cd_moeda||''', ''da'').then(function(resposta){ if(resposta.indexOf(''OK'') != -1){ alerta(''feed-fixo'', tr_ex); setTimeout(function(){ call(''moedas_usadas'', ''prm_requisicao=''+document.getElementById(''solicitacoes'').value, ''DA'').then(function(resposta){ loading(); document.getElementById(''moedas_usadas_append'').classList.remove(''invisible''); document.getElementById(''moedas_usadas_append'').innerHTML = resposta; }) },1000); } else { alerta(''feed-fixo'', tr_xc); setTimeout(function(){ loading(); }, 1000); } });">X</a></span>');

                htp.p('</li>');
		    end loop;	
	    close crs_despesas_dia;

        select count(distinct cd_moeda) into ws_count_moedas from opr_despesas_viagem
        where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa in ('0001', '0009', '0010', '0014', '0016');

        /*if ws_count_moedas = 1 then
	   
		
        
	        htp.p('<li class="titulo">DESPESAS POR MOEDA</li>');
	        
	         htp.p('<li>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">TOTAL</span>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_alimentacao, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_transporte, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_aluguel, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_hospedagem, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_outras, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
	            htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_despesa_total_s, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
	            htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);"></span>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);"></span>');
	            htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_total_somatoria, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
	            htp.p('<span class="desc" style="min-width: 20px; width: 20px;"></span>');
			htp.p('</li>');  
			
		end if;    
			  
	        open crs_moedas;
	            loop
	                fetch crs_moedas into ws_moedas;
	                exit when crs_moedas%notfound;
	                
	                select sum(vl_despesa) into ws_total_moeda from opr_despesas_viagem
			        where usuario = user and cd_requisicao = prm_requisicao and cd_despesa in ('0001', '0009', '0010', '0014', '0016') and cd_moeda = ws_moedas.cd_moeda and tipo = 'DESPESA-INTERNA';
	                
	                if nvl(ws_total_moeda, 0) <> 0 then
	                
						htp.p('<li>');
						    htp.p('<span class="readonly" style="min-width: calc(50% - 2px); width: calc(50% - 2px); border-right: 2px solid #555;">GASTOS - '||ws_moedas.ds_moeda||'</span>');
		                    htp.p('<span class="readonly" style="min-width: 50%; width: 50%; border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(ws_total_moeda, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
		                htp.p('</li>');
	                
	                end if; 
	                
	            end loop;
	        close crs_moedas;*/
        

        
        /*begin
	        select to_number(ad_periodo) into ws_numero_dias from opr_requisicao_viagem
	        where (usuario = user or user = 'DWU') and cod = prm_requisicao;
	        
	        if ws_numero_dias = 0 then 
	            ws_numero_dias := 1;
	        end if;
	    exception when others then
	        ws_numero_dias := 1;
	    end;*/
	    
	    ws_numero_dias := 1;
        
        
        
        htp.p('<li class="titulo">DESPESAS TOTAIS</li>');
        
        if ws_total_somatoria = 0 then
            htp.p('');
	        /*htp.p('<li>');
	            htp.p('<span class="readonly" style="min-width: calc(50% - 2px); width: calc(50% - 2px); border-right: 2px solid #555;">TOTAL REAIS</span>');
	            htp.p('<span class="readonly" style="min-width: 50%; width: 50%;"><input style="text-align: right;" class="txt" disabled value="0"/></span>');
	         htp.p('</li>');*/
	          /*htp.p('<li>');
	        	htp.p('<span class="readonly" style="min-width: calc(50% - 2px); width: calc(50% - 2px); border-right: 2px solid #555;">MÉDIA GASTOS DIÁRIOS EM REAIS</span>');
	            htp.p('<span class="readonly" style="min-width: 50%; width: 50%;"><input style="text-align: right;" class="txt" disabled type="text" value="0" /></span>');
	        htp.p('</li>');*/
	    else
	    
		    /*htp.p('<li>');
	            htp.p('<span class="readonly" style="min-width: calc(50% - 2px); width: calc(50% - 2px); border-right: 2px solid #555;">TOTAL REAIS</span>');
	            htp.p('<span class="readonly" style="min-width: 50%; width: 50%;"><input style="text-align: right;" class="txt" disabled value="'||to_char(ws_total_somatoria, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
	         htp.p('</li>');
	          htp.p('<li>');
	        	htp.p('<span class="readonly" style="min-width: calc(50% - 2px); width: calc(50% - 2px); border-right: 2px solid #555;">MÉDIA GASTOS DIÁRIOS EM REAIS</span>');
	            htp.p('<span class="readonly" style="min-width: 50%; width: 50%;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(ws_total_somatoria/ws_numero_dias, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
	        htp.p('</li>');*/
	        
	      
            open crs_total_despesas;
                loop
                    fetch crs_total_despesas into ws_total_despesa;
                    exit when crs_total_despesas%notfound;
                    htp.p('<li>');
			            htp.p('<span class="readonly" style="min-width: calc(50% - 2px); width: calc(50% - 2px); border-right: 2px solid #555;">'||ws_total_despesa.moeda||'</span>');
			            htp.p('<span class="readonly" style="min-width: 50%; width: 50%;"><input style="text-align: right;" class="txt" disabled value="'||to_char(ws_total_despesa.despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
			         htp.p('</li>');
                end loop;
            close crs_total_despesas;
	    
	    end if;
        
        
        
        ws_alimentacao     := 0;
		ws_transporte      := 0;
		ws_aluguel         := 0;
		ws_hospedagem      := 0;
		ws_outras          := 0;
	    ws_despesa_total_s := 0;
        ws_total_somatoria := 0;
        ws_despesa_total   := 0;
        ws_despesa         := 0;
        
        htp.p('<li class="space"></li>');
        htp.p('<li class="space noprint"></li>');
        
        htp.p('<li class="titulo">DESPESAS COM CARTÃO CORPORATIVO</li>');
					
        htp.p('<li>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">DATA</span>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">ALIMENTAÇÃO</span>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">ALUGUEL</span>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">HOSPEDAGEM</span>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">OUTRAS DESPESAS</span>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">TRANSPORTE</span>');
            htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">TOTAL</span>');
            htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">MOEDA UTILIZADA</span>');
			htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">CÂMBIO</span>');
            htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">TOTAL R$</span>');
            htp.p('<span class="desc" style="min-width: 20px; width: 20px;"></span>');
		htp.p('</li>');
	
        open crs_despesas_cartao;
            loop
                fetch crs_despesas_cartao into ws_cartao;
                exit when crs_despesas_cartao%notfound;
				htp.p('<li>');

                    ws_despesa_total := 0;
                    ws_cambio := 0;

                    select max(cambio) into ws_cambio from opr_despesas_viagem where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and dt_emissao = ws_cartao.dt_emissao and cd_moeda = ws_cartao.cd_moeda and tipo = 'CARTAO-INTERNO';
           
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_cartao.dt_emissao, 'DD/MM/YYYY')||'"/></span>');
                   
					select nvl(sum(vl_despesa), 0) into ws_despesa from opr_despesas_viagem where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa = '0001' and dt_emissao = ws_cartao.dt_emissao and cd_moeda = ws_cartao.cd_moeda and tipo = 'CARTAO-INTERNO';
					ws_despesa_total := ws_despesa_total+ws_despesa;
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
					ws_alimentacao   := ws_alimentacao+ws_despesa;
					ws_despesa       := 0;

                    select nvl(sum(vl_despesa), 0) into ws_despesa from opr_despesas_viagem where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa = '0009' and dt_emissao = ws_cartao.dt_emissao and cd_moeda = ws_cartao.cd_moeda and tipo = 'CARTAO-INTERNO';
					ws_despesa_total := ws_despesa_total+ws_despesa;
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
					ws_transporte    := ws_transporte+ws_despesa;
					ws_despesa       := 0;

                    select nvl(sum(vl_despesa), 0) into ws_despesa from opr_despesas_viagem where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa = '0010' and dt_emissao = ws_cartao.dt_emissao and cd_moeda = ws_cartao.cd_moeda and tipo = 'CARTAO-INTERNO';
					ws_despesa_total := ws_despesa_total+ws_despesa;
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
					ws_aluguel       := ws_aluguel+ws_despesa;
					ws_despesa       := 0;

                    select nvl(sum(vl_despesa), 0) into ws_despesa from opr_despesas_viagem where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa = '0014' and dt_emissao = ws_cartao.dt_emissao and cd_moeda = ws_cartao.cd_moeda and tipo = 'CARTAO-INTERNO';
					ws_despesa_total := ws_despesa_total+ws_despesa;
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
				    ws_hospedagem    := ws_hospedagem+ws_despesa;
				    ws_despesa       := 0;
				    
				    select nvl(sum(vl_despesa), 0) into ws_despesa from opr_despesas_viagem where (usuario = user or user = 'DWU') and cd_requisicao = prm_requisicao and cd_despesa = '0016' and dt_emissao = ws_cartao.dt_emissao and cd_moeda = ws_cartao.cd_moeda and tipo = 'CARTAO-INTERNO';
					ws_despesa_total := ws_despesa_total+ws_despesa;
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
					ws_outras        := ws_outras+ws_despesa;
					ws_despesa       := 0;

                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa_total, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
                    
                    ws_despesa_total_s := ws_despesa_total_s+ws_despesa_total;
                    
                    
                    select ds_moeda into ws_moeda from taux_moeda where cd_moeda = ws_cartao.cd_moeda;
                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||ws_moeda||'"/></span>');
                    
                    if ws_cartao.cd_moeda = '01' then
                        htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="-"/></span>');
                    else
                        htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_cambio, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
                        ws_despesa_total := ws_despesa_total*ws_cambio;
                    end if;
                    
                    ws_total_somatoria := ws_total_somatoria+ws_despesa_total;

                    htp.p('<span class="readonly" style="min-width: calc(10% - 4px); width: calc(10% - 4px); border-right: 2px solid #555;"><input class="txt" disabled value="'||to_char(ws_despesa_total, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
                    
                    htp.p('<span style="min-width: 20px; width: 20px;"><a class="remove" onclick="loading(); call(''excluir_despesa'', ''prm_emissao='||ws_cartao.dt_emissao||'&prm_moeda='||ws_cartao.cd_moeda||''', ''da'').then(function(resposta){ if(resposta.indexOf(''OK'') != -1){ alerta(''feed-fixo'', tr_ex); setTimeout(function(){ call(''moedas_usadas'', ''prm_requisicao=''+document.getElementById(''solicitacoes'').value, ''DA'').then(function(resposta){ loading(); document.getElementById(''moedas_usadas_append'').classList.remove(''invisible''); document.getElementById(''moedas_usadas_append'').innerHTML = resposta; }) },1000); } else { alerta(''feed-fixo'', tr_xc); setTimeout(function(){ loading(); }, 1000); } });">X</a></span>');

                htp.p('</li>');
		    end loop;	
	    close crs_despesas_cartao;
	    
	    
	    if ws_count_moedas = 1 then
	        htp.p('<li>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">TOTAL</span>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_alimentacao, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_transporte, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_aluguel, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_hospedagem, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_outras, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
	            htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_despesa_total_s, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
	            htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);"></span>');
				htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);"></span>');
	            htp.p('<span class="desc" style="min-width: calc(10% - 4px); width: calc(10% - 4px);">'||to_char(ws_total_somatoria, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'</span>');
	            htp.p('<span class="desc" style="min-width: 20px; width: 20px;"></span>');
			htp.p('</li>');
		end if;
	    
	    

        begin
	        select to_number(ad_periodo) into ws_numero_dias from opr_requisicao_viagem
	        where (usuario = user or user = 'DWU') and cod = prm_requisicao;
	        
	        if ws_numero_dias = 0 then 
	            ws_numero_dias := 1;
	        end if;
	    exception when others then
	        ws_numero_dias := 1;
	    end;
	    
	    
        

        htp.p('<li class="titulo">DESPESAS TOTAIS</li>');
        
        if ws_total_somatoria = 0 then
            htp.p('');
	        /*htp.p('<li>');
	            htp.p('<span class="readonly" style="min-width: calc(50% - 2px); width: calc(50% - 2px); border-right: 2px solid #555;">TOTAL R$</span>');
	            htp.p('<span class="readonly" style="min-width: 50%; width: 50%;"><input style="text-align: right;" class="txt" disabled value="0"/></span>');
	        htp.p('</li>');
	        htp.p('<li>');
	        	htp.p('<span class="readonly" style="min-width: calc(50% - 2px); width: calc(50% - 2px); border-right: 2px solid #555;">MÉDIA GASTOS DIÁRIOS EM R$</span>');
	            htp.p('<span class="readonly" style="min-width: 50%; width: 50%;"><input style="text-align: right;" class="txt" disabled type="text" value="0" /></span>');
	        htp.p('</li>');*/
	    else
	    
	        /*htp.p('<li>');
	            htp.p('<span class="readonly" style="min-width: calc(50% - 2px); width: calc(50% - 2px); border-right: 2px solid #555;">TOTAL R$</span>');
	            htp.p('<span class="readonly" style="min-width: 50%; width: 50%;"><input style="text-align: right;" class="txt" disabled value="'||to_char(ws_total_somatoria, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
	        htp.p('</li>');
	        htp.p('<li>');
	        	htp.p('<span class="readonly" style="min-width: calc(50% - 2px); width: calc(50% - 2px); border-right: 2px solid #555;">MÉDIA GASTOS DIÁRIOS EM R$</span>');
	            htp.p('<span class="readonly" style="min-width: 50%; width: 50%;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(ws_total_somatoria/ws_numero_dias, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
	        htp.p('</li>');*/
	        
	        open crs_total_cartao;
                loop
                    fetch crs_total_cartao into ws_total_cartao;
                    exit when crs_total_cartao%notfound;
                    htp.p('<li>');
			            htp.p('<span class="readonly" style="min-width: calc(50% - 2px); width: calc(50% - 2px); border-right: 2px solid #555;">'||ws_total_cartao.moeda||'</span>');
			            htp.p('<span class="readonly" style="min-width: 50%; width: 50%;"><input style="text-align: right;" class="txt" disabled value="'||to_char(ws_total_cartao.despesa, '999G999G999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'"/></span>');
			         htp.p('</li>');
                end loop;
            close crs_total_cartao;
	    
	    end if;
        
        
        
        
        
        select count(*) into ws_count from opr_despesas_viagem
        where length(trim(observacao)) > 0 and cd_requisicao = prm_requisicao and (tipo = 'DESPESA-INTERNA' or tipo = 'CARTAO-INTERNO');
        
        if ws_count > 0 then
        
            htp.p('<li class="space"></li>');
            htp.p('<li class="space noprint"></li>');
        
	        htp.p('<li class="titulo">OBSERVAÇÕES</li>');
	        
	        htp.p('<li>');
				htp.p('<span class="desc" style="min-width: calc(20% - 2px); width: calc(25% - 2px);">DATA</span>');
				htp.p('<span class="desc" style="min-width: calc(20% - 2px); width: calc(25% - 2px);">TIPO DE MOEDA</span>');
				htp.p('<span class="desc" style="min-width: calc(20% - 2px); width: calc(25% - 2px);">TIPO DA DESPESA</span>');
				htp.p('<span class="desc" style="min-width: 40%; width: 40%;">OBSERVAÇÃO</span>');
			htp.p('</li>');
	        
	        open crs_observacoes;
	            loop
	                fetch crs_observacoes into ws_observacao;
	                exit when crs_observacoes%notfound;
	                
		            htp.p('<li>');
						htp.p('<span class="readonly" style="min-width: calc(20% - 2px); width: calc(20% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(ws_observacao.dt_emissao, 'DD/MM/YYYY')||'" /></span>');
						htp.p('<span class="readonly" style="min-width: calc(20% - 2px); width: calc(20% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||ws_observacao.moeda||'" /></span>');
						htp.p('<span class="readonly" style="min-width: calc(20% - 2px); width: calc(20% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||ws_observacao.despesa||'" /></span>');
						htp.p('<span class="readonly" style="min-width: 40%; width: 40%;"><input style="text-align: right;" class="txt" disabled type="text" value="'||ws_observacao.observacao||'" /></span>');
					htp.p('</li>');
	                    
	            end loop;
	        close crs_observacoes;
        
        end if;
        
        
        /*htp.p('<li class="titulo">RESUMO E ACERTO DE DESPESAS</li>');
        
        htp.p('<li>');
			htp.p('<span class="desc" style="min-width: calc(25% - 2px); width: calc(25% - 2px);">ADIANTAMENTO E MOEDAS USADAS</span>');
			htp.p('<span class="desc" style="min-width: calc(25% - 2px); width: calc(25% - 2px);">MOEDA TROCADA DURANTE A VIAGEM</span>');
			htp.p('<span class="desc" style="min-width: calc(25% - 2px); width: calc(25% - 2px);">LANÇAMENTO DE DESPESAS</span>');
			htp.p('<span class="desc" style="min-width: 25%; width: 25%;">TOTAL</span>');
		htp.p('</li>');
		
		htp.p('<li>');
			htp.p('<span class="desc" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px);">TIPO DE MOEDA</span>');
			htp.p('<span class="desc" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px);">VALOR RECEBIDO</span>');
			htp.p('<span class="desc" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px);">VALOR DA TROCA</span>');
			htp.p('<span class="desc" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px);">ENTRADA DE MOEDA</span>');
			htp.p('<span class="desc" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px);">DESPESAS DINHEIRO</span>');
			htp.p('<span class="desc" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px);">SALDO DINHEIRO DÉBITO/CRÉDITO</span>');
			htp.p('<span class="desc" style="min-width: calc(7% - 2px); width: calc(7% - 2px);">CÂMBIO DIA RECEBIDO</span>');
			htp.p('<span class="desc" style="min-width: calc(6% - 2px); width: calc(6% - 2px);">CÂMBIO DIA TROCADO</span>');
			htp.p('<span class="desc" style="min-width: 11.5%; width: 12.5%;">SALDO A DEVOLVER EM R$</span>');	
		htp.p('</li>');
		
		for i in(select (select ds_moeda from taux_moeda where cd_moeda = t1.cd_moeda) as moeda, vl_despesa, (select sum(vl_despesa) from opr_despesas_viagem where cd_despesa = '0018' and cd_moeda = t1.cd_moeda and cd_requisicao = prm_requisicao and tipo <> 'CARTAO-INTERNO') as troca, (select sum(vl_despesa*cambio) from opr_despesas_viagem where cd_despesa = '0018' and cd_moeda_troca = t1.cd_moeda and cd_requisicao = prm_requisicao and tipo <> 'CARTAO-INTERNO') as entrada, (select sum(vl_despesa) from opr_despesas_viagem where cd_despesa <> '0018' and cd_despesa <> '0019' and cd_moeda = t1.cd_moeda and cd_requisicao = prm_requisicao and tipo <> 'CARTAO-INTERNO') as despesa, cambio from opr_despesas_viagem t1 where cd_despesa = '0019' and cd_requisicao = prm_requisicao and vl_despesa <> 0 and cd_moeda is not null and cd_moeda_troca is null AND TIPO <> 'CARTAO-INTERNO') loop
		    
            
            ws_despesa         := nvl(i.vl_despesa, 0)-nvl(i.troca, 0)+nvl(i.entrada, 0)-nvl(i.despesa, 0);
            ws_despesa_total   := ws_despesa*i.cambio;
		    
		    htp.p('<li>');
				htp.p('<span class="readonly" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||i.moeda||'" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(i.vl_despesa, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(i.troca, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(i.entrada, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(i.despesa, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(ws_despesa, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(7% - 2px); width: calc(7% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(i.cambio, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(6% - 2px); width: calc(6% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="" /></span>');
				htp.p('<span class="readonly" style="min-width: 11.5%; width: 12.5% ;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(ws_despesa_total, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
		    htp.p('</li>');
		end loop;
		
		htp.p('<li style="background: #065182; width: 100%;"></li>');
		
		for a in(select (select ds_moeda from taux_moeda where cd_moeda = t1.cd_moeda_troca) as moeda, sum(vl_despesa*cambio) as entrada, (select sum(vl_despesa) from opr_despesas_viagem where cd_despesa <> '0018' and cd_despesa <> '0019' and cd_moeda = t1.cd_moeda_troca and cd_requisicao = prm_requisicao and tipo <> 'CARTAO-INTERNO') as despesa, cambio from opr_despesas_viagem t1 where cd_despesa = '0018' and cd_requisicao = prm_requisicao and cd_moeda_troca is not null and tipo <> 'CARTAO-INTERNO' and cd_moeda_troca not in (select cd_moeda from opr_despesas_viagem where cd_despesa = '0019' and cd_requisicao = prm_requisicao and cd_moeda is not null) group by cd_moeda_troca, cambio) loop
		    
		    if a.moeda = 'REAL' then
		        ws_cambio := 1;
		    else
		        ws_cambio := a.cambio;
		    end if;
		    
		    ws_despesa         := nvl(a.entrada, 0)-nvl(a.despesa, 0);
            ws_despesa_total   := ws_despesa/ws_cambio;
		    
		    htp.p('<li>');
				htp.p('<span class="readonly" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||a.moeda||'" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value=""/></span>');
				htp.p('<span class="readonly" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(a.entrada, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(a.despesa, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(12.5% - 2px); width: calc(12.5% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(ws_despesa, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(7% - 2px); width: calc(7% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="" /></span>');
				htp.p('<span class="readonly" style="min-width: calc(6% - 2px); width: calc(6% - 2px); border-right: 2px solid #555;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(ws_cambio, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
				htp.p('<span class="readonly" style="min-width: 11.5%; width: 12.5% ;"><input style="text-align: right;" class="txt" disabled type="text" value="'||to_char(ws_despesa_total, '999G999G990D00', 'NLS_NUMERIC_CHARACTERS=,.')||'" /></span>');
		    htp.p('</li>');
		end loop;*/
		
		--calculo de saida, já calculado no resumo
		
		htp.p('<li class="noprint">');
		    sv.print;
		htp.p('</li>');
        
    exception when others then 
        htp.p(sqlerrm);
	end moedas_usadas;
	
	
	procedure excluir_troca_moeda ( prm_item varchar2 default null ) as
	
	    ws_count number;
	
	begin
	    
	    delete from opr_despesas_viagem 
	    where trim(nr_item) = trim(prm_item)
		and usuario = user;
	    commit;
	    
	    select count(*) into ws_count 
	    from opr_despesas_viagem 
	    where trim(nr_item) = trim(prm_item)
		and usuario = user;
	    
	    insert into log_eventos values (sysdate, 'Exclusão de despesa da emissão #'||prm_item, user, 'excluir_troca_moeda', 'DA','01');
	    
	    if ws_count = 0 then
	        htp.p('OK');
	    else
	        htp.p('FAIL');
	    end if;
	    
	end excluir_troca_moeda;
	
	
	procedure excluir_despesa ( prm_emissao varchar2 default null,
	                            prm_moeda   varchar2 default null ) as
	
	    ws_count number;
	
	begin
	
	    delete from opr_despesas_viagem 
	    where trim(dt_emissao) = trim(prm_emissao) and
	    trim(cd_moeda) = trim(prm_moeda) 
		and usuario = user;
	    commit;
	    
	    select count(*) into ws_count 
	    from opr_despesas_viagem 
	    where trim(dt_emissao) = trim(prm_emissao) and
	    trim(cd_moeda) = trim(prm_moeda)
		and usuario = user;
	    
	    insert into log_eventos values (sysdate, 'Exclusão de despesa da emissão do dia '||prm_emissao||' e da moeda #'||prm_moeda, user, 'excluir_despesa', 'DA','01');
	    
	    if ws_count = 0 then
	        htp.p('OK');
	    else
	        htp.p('FAIL');
	    end if;
	exception when others then
	    htp.p(sqlerrm);
	end excluir_despesa;
	
	PROCEDURE BOTOES AS


	    WS_SITUACAO    VARCHAR2(20);
		ws_count       number;
        ws_exist       number;

	BEGIN
        
        htp.p('<a class="subicon" onclick="setTimeout(function(){ enviar(''INTERNO''); }, 1000);">GRAVAR</a>');

	EXCEPTION WHEN OTHERS THEN

		sv.print;

	END BOTOES;
	
	procedure listar_solicitacoes AS

	    CURSOR CRS_ATENDIMENTOS IS
		SELECT COD, DS_MOTIVO, length(cod) as tamanho FROM OPR_REQUISICAO_VIAGEM
		WHERE (USUARIO = USER or user = 'DWU') AND cd_situacao = 'INTERNO'
		order by to_number(nvl(substr(cod, 11, 70), cod)) desc;

		WS_ATENDIMENTO CRS_ATENDIMENTOS%ROWTYPE;

	BEGIN

	    htp.p('<option value="N/A" hidden selected>---</option>');
	
		OPEN CRS_ATENDIMENTOS;
			LOOP
			FETCH CRS_ATENDIMENTOS INTO WS_ATENDIMENTO;
			EXIT WHEN CRS_ATENDIMENTOS%NOTFOUND;
				if WS_ATENDIMENTO.tamanho > 10 then
				    htp.p('<option value="'||WS_ATENDIMENTO.COD||'">'||substr(WS_ATENDIMENTO.COD, 11, 70)||'  -  '||WS_ATENDIMENTO.DS_MOTIVO||'</option>');
				else
				    htp.p('<option value="'||WS_ATENDIMENTO.COD||'">'||WS_ATENDIMENTO.COD||'  -  '||WS_ATENDIMENTO.DS_MOTIVO||'</option>');
				end if;
			END LOOP;
		CLOSE CRS_ATENDIMENTOS;

	END listar_solicitacoes;
	

end pc;
/
show error
exit