create or replace PACKAGE PDI IS
	
	PROCEDURE MAIN( CODE VARCHAR2, PRM_RELOAD VARCHAR2 DEFAULT NULL );

	PROCEDURE TELAINICIAL( PRM_CODE VARCHAR2 DEFAULT NULL );

	PROCEDURE ADMIN;

	PROCEDURE NORMAL;

	PROCEDURE LOGOUT;


	

	PROCEDURE RETORNAHTML ( PRM_TIPO VARCHAR2, PRM_USUARIO NUMBER );

	PROCEDURE CADASTRODEESTATICOS  ( PRM_COD VARCHAR2 DEFAULT NULL );

	PROCEDURE LISTADEESTATICOS ( PRM_COD VARCHAR2 DEFAULT NULL );

	PROCEDURE EDITARESTATICO ( PRM_COD          VARCHAR2,
					           PRM_QUESTIONARIO NUMBER,
							   PRM_TIPO         VARCHAR2,
							   PRM_CONTEUDO     CLOB );


	
	

	PROCEDURE CADASTRODEPERGUNTA  ( PRM_COD       NUMBER DEFAULT NULL, 
									PRM_CATEGORIA VARCHAR2 DEFAULT NULL,
									PRM_SETOR     NUMBER   DEFAULT NULL );

	PROCEDURE LISTADEPERGUNTAS ( PRM_COD NUMBER DEFAULT NULL,
								 PRM_CATEGORIA VARCHAR2 DEFAULT NULL,
								 PRM_SETOR     NUMBER DEFAULT NULL );

	procedure visualizarPerguntas ( prm_setor varchar2 default null );

	PROCEDURE ADICIONARPERGUNTA ( PRM_COD           NUMBER DEFAULT 0,
								  PRM_TIPO          VARCHAR2,
								  PRM_SETOR         VARCHAR2,
								  PRM_JUSTIFICATIVA VARCHAR2,
								  PRM_FORMATO       VARCHAR2,
								  PRM_PERGUNTA      VARCHAR2,
								  PRM_ORDEM         NUMBER DEFAULT NULL );

	PROCEDURE EXCLUSAODEPERGUNTA ( PRM_COD NUMBER );



	
	

	PROCEDURE CADASTRODEFORMATO ( PRM_COD NUMBER DEFAULT NULL );

	PROCEDURE LISTADEFORMATOS ( PRM_COD NUMBER DEFAULT NULL );

	PROCEDURE ADICIONARFORMATO ( PRM_COD    NUMBER DEFAULT 0,
								 PRM_TIPO   VARCHAR2,
								 PRM_VALOR  VARCHAR2,
								 PRM_DESC   VARCHAR2 );

	PROCEDURE EXCLUSAODEFORMATO ( PRM_COD NUMBER );



	
	

	PROCEDURE CADASTRODESETOR ( PRM_COD NUMBER DEFAULT NULL );

	PROCEDURE LISTADESETORES ( PRM_COD NUMBER DEFAULT NULL );

	PROCEDURE ADICIONARSETOR ( PRM_COD    NUMBER DEFAULT 0,
							   PRM_NOME   VARCHAR2 );

	PROCEDURE EXCLUSAODESETOR ( PRM_COD NUMBER );

	
	


	PROCEDURE CADASTRODECATEGORIA( PRM_COD NUMBER DEFAULT NULL );

	PROCEDURE LISTADECATEGORIAS ( PRM_COD NUMBER DEFAULT NULL );

	PROCEDURE ADICIONARCATEGORIA ( PRM_COD NUMBER DEFAULT 0,
								   PRM_NOME   VARCHAR2,
								   PRM_TEMA VARCHAR2,
								   PRM_DESC VARCHAR2 );

	PROCEDURE EXCLUSAODECATEGORIA ( PRM_COD NUMBER );


	


	PROCEDURE CADASTRODEUSUARIO ( PRM_COD NUMBER DEFAULT NULL, PRM_BUSCA VARCHAR2 DEFAULT NULL );

	PROCEDURE LISTADEUSUARIOS ( PRM_COD NUMBER DEFAULT NULL, PRM_BUSCA VARCHAR2 DEFAULT NULL );

	PROCEDURE ADICIONARUSUARIO ( PRM_COD          NUMBER DEFAULT 0,
								 PRM_NOME         VARCHAR2,
								 PRM_LOGIN        VARCHAR2,
								 PRM_SETOR        NUMBER,
								 PRM_TELEFONE     VARCHAR2,
								 PRM_EMAIL        VARCHAR2,
								 PRM_QUESTIONARIO VARCHAR2,
								 prm_hierarquia   number );

	PROCEDURE EXCLUSAODEUSUARIO ( PRM_COD NUMBER );

	PROCEDURE ADICIONARRELACIONAMENTO ( PRM_COD 			 NUMBER DEFAULT NULL,
										PRM_USUARIO          NUMBER,
										PRM_USUARIO_AVALIADO NUMBER,
										PRM_SETOR            NUMBER );

	PROCEDURE EXCLUSAODERELACIONAMENTO ( PRM_COD NUMBER );

	procedure cadastroDeRelacionamento ( prm_usuario number, prm_cod number default null, prm_busca varchar2 default null );

	PROCEDURE LISTADERELACIONAMENTO ( PRM_COD NUMBER DEFAULT NULL, PRM_USUARIO NUMBER );


	

	PROCEDURE AVALIACAO  (  PRM_AVALIADO NUMBER DEFAULT NULL );

	procedure preAvaliacao ( prm_usuario varchar2 );

	PROCEDURE MENUDEAVALIACOES ( PRM_AVALIADO NUMBER DEFAULT NULL );

	PROCEDURE QUESTAO ( PRM_AVALIADO NUMBER,
						PRM_COD NUMBER DEFAULT NULL, 
						PRM_CLASS VARCHAR2 DEFAULT NULL );

	PROCEDURE QUESTOES ( PRM_AVALIADO NUMBER,
						 PRM_CLASS    VARCHAR2 DEFAULT NULL );

	PROCEDURE PROGRESSO ( PRM_ENVIADA NUMBER, PRM_TOTAL NUMBER );


	PROCEDURE ADICIONARAVALIACAO ( PRM_AVALIADO     NUMBER,
								   PRM_PERGUNTA     NUMBER,
								   PRM_VALOR        NUMBER,
								   PRM_JUSTIFICATIVA varchar2 DEFAULT NULL
								   );

	procedure updateAvaliacao ( prm_avaliado     number,
								prm_pergunta     number,
								prm_valor        number,
								prm_justificativa varchar2 default null
							  );

	FUNCTION RETORNAUSUARIO RETURN NUMBER;

	FUNCTION CONVERTE( PRM_TEXTO VARCHAR2 DEFAULT NULL ) RETURN VARCHAR2;

	FUNCTION RETORNAICONE ( PRM_ICONE VARCHAR2 ) RETURN VARCHAR2;

	FUNCTION GENERATEHASH ( PRM_COD VARCHAR2, PRM_NOME VARCHAR2, PRM_SETOR VARCHAR2 )  RETURN VARCHAR2;

	FUNCTION TESTAADMIN RETURN VARCHAR2;

	procedure listaDeJustificativa;

	procedure adicionarJustificativa ( prm_cod 	 number,
									   prm_thumb  varchar2 );

END PDI;
/
create or replace package body PDI is

	procedure main ( code varchar2, prm_reload varchar2 default null ) as

		ws_count  number := 0;
		ws_code   varchar2(80);
		ws_status varchar2(20);
		ws_tipo      varchar2(10);

		begin

			select count(*) into ws_count from pdi_usuarios where hashcode = code and cd_cliente = fun.ret_var('CLIENTE');
			
			if ws_count > 0 then
			
				begin

					ws_code := Owa_Cookie.Get('PDIHASH').vals(1);

					if replace(ws_code, 'PDIHASH=', '') <> code then

						/* mata o login corrente
						if length(replace(ws_code, 'PDIHASH=', '')) > 0 then
							pdi.logout;
							DBMS_LOCK.SLEEP(2);
							pdi.telaInicial(ws_code);
						end if;*/
						
						owa_util.mime_header('text/html', FALSE, NULL);
							owa_cookie.send(
							name    => 'PDIHASH',
							value   => code,
							expires => sysdate+(1/2)
						);

						owa_util.http_header_close;

					end if;

				exception when others then

					owa_util.mime_header('text/html', FALSE, NULL);
						owa_cookie.send(
						name    => 'PDIHASH',
						value   => code,
						expires => sysdate+(1/2)
					);

					owa_util.http_header_close;
					
				end;
				
				/*if nvl(Owa_Cookie.Get('PDIHASH').Vals(1), '0') = '0' then
					
					owa_util.mime_header('text/html', FALSE, NULL);
						owa_cookie.send(
						name    => 'PDIHASH',
						value   => code,
						expires => sysdate+(1/300)
					);

					owa_util.http_header_close;
					
					DBMS_LOCK.sleep(3);

				end if;*/

				htp.p('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
		htp.p('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">');
			htp.p('<head>');
				htp.p('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
				htp.p('<meta http-equiv="Content-Type" content="text/html;" />');
				htp.p('<TITLE>Plano de desenvolvimento individual</TITLE>');
				htp.p('<META HTTP-EQUIV="Pragma" CONTENT="no-cache, no-store, must-revalidate">');
				htp.p('<META HTTP-EQUIV="Expires" CONTENT="0">');
				htp.p('<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">');
				htp.p('<meta name="apple-mobile-web-app-capable" content="yes" />');
				htp.p('<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">');
				htp.p('<link rel="favicon" href="'||fun.r_gif('upquery-icon','PNG')||'" />');
				htp.p('<link rel="shortcut icon" href="'||fun.r_gif('upquery-icon','PNG')||'" />');
				htp.p('<link rel="apple-touch-startup-image" href="'||fun.r_gif('upquery-icon','PNG')||'">');
				htp.p('<meta name="apple-mobile-web-app-status-bar-style" content="black">');
				htp.p('<link href="https://fonts.googleapis.com/css?family=Montserrat" rel="stylesheet" type="text/css">');
				fcl.keywords;
				htp.p('<script src="dwu.fcl.download?arquivo=pdi.js"></script>');
				htp.p('<script src="dwu.fcl.download?arquivo=loading-bar.js"></script>');
				htp.p('<script src="dwu.fcl.download?arquivo=vanilla-masker.js"></script>');
				htp.p('<link rel="stylesheet" href="dwu.fcl.download?arquivo=pdi.css">');
				htp.p('<link rel="stylesheet" href="dwu.fcl.download?arquivo=default-min.css">');
				htp.p('<link rel="stylesheet" href="dwu.fcl.download?arquivo=loading-bar.css">');
				htp.p('<link rel="stylesheet" href="dwu.fcl.download?arquivo=ideativo.css">');
			htp.p('</head>');
			htp.p('<body onload="testCookie();">');
				--DBMS_LOCK.SLEEP(3);

				

			htp.p('</body>');
		htp.p('</html>');

		else
			htp.p('<h1>C&oacute;digo inv&aacute;lido!</h1>');
		end if;

	exception when others then
		htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end main;

	procedure telaInicial ( prm_code varchar2 default null ) as 

		ws_semSessao exception;
		ws_code      varchar2(80);
		ws_status 	varchar2(20);
		ws_tipo      varchar2(10);

	begin

		if nvl(prm_code, '0') <> '0' then
		    ws_code := prm_code;
		else
			ws_code := Owa_Cookie.Get('PDIHASH').Vals(1);
		end if;

		select tipo into ws_tipo from pdi_usuarios where hashcode = ws_code and cd_cliente = fun.ret_var('CLIENTE');

		select status into ws_status from pdi_controle where cd_cliente = fun.ret_var('CLIENTE');

		if nvl(ws_status, 'I') = 'A' or ws_tipo = 'A' then
			htp.p('<div id="background"></div>');
				
			if pdi.retornaUsuario <> 0 then
				select tipo into ws_tipo from pdi_usuarios where hashcode = ws_code and cd_cliente = fun.ret_var('CLIENTE');

				if ws_tipo = 'A' then
					pdi.admin;
				else
					pdi.normal;
				end if;
			else
				htp.p('<h1>C&oacute;digo inv&aacute;lido! 2</h1>');
			end if;
		else
			htp.p('<h1>Avalia&ccedil;&atilde;o encerrada, obrigado por participar!</h1>');
		end if;


	exception 
		when ws_semsessao then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end telaInicial;

	procedure admin as

	begin

		htp.p('<ul id="menu-admin">');
			htp.p('<li class="selected"><a id="cadastroDePergunta">CADASTRO DE PERGUNTAS</a></li>');
			htp.p('<li><a id="cadastroDeCategoria">CADASTRO DE TEMAS</a></li>');
			htp.p('<li><a id="cadastroDeSetor">CADASTRO DE SETORES</a></li>');
			htp.p('<li><a id="cadastroDeUsuario">CADASTRO DE USU&Aacute;RIO</a></li>');
			htp.p('<li><a id="cadastroDeFormato">CADASTRO DE FORMATOS</a></li>');
			--htp.p('<li><a id="avaliacao">EXEMPLO DE QUESTION&Aacute;RIO</a></li>');
			htp.p('<li><a id="cadastroDeEstaticos">TEXTOS DA TELA INICIAL</a></li>');
			htp.p('<li><a id="visualizarPerguntas">LISTAR FORMUL&Aacute;RIO</a></li>');
			htp.p('<li><a id="listaDeJustificativa">LISTA DE JUSTIFICATIVA</a></li>');
		htp.p('</ul>');

		htp.p('<div id="conteudo">');
			pdi.cadastroDePergunta;
		htp.p('</div>');

		--htp.p('<a id="home"><svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="480px" height="480px" viewBox="0 0 480 480" enable-background="new 0 0 480 480" xml:space="preserve"> <g> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5C5CC0" d="M5.692,241.825c15.618-13.652,31.299-27.239,46.863-40.956 C115.261,145.683,177.94,90.463,240.629,35.254c1.145-0.999,2.326-1.912,3.723-3.072c7.711,6.971,15.295,13.791,22.856,20.644 c68.807,62.352,137.613,124.692,206.42,187.033c0.43,0.408,0.967,0.709,1.461,1.042c0,0.312,0,0.612,0,0.924 c-12.105,12.577-23.157,14.629-38.926,6.434c-5.907-3.051-11.621-6.831-16.584-11.235 c-57.41-51.245-114.649-102.673-171.92-154.047c-1.031-0.913-2.105-1.762-3.479-2.932c-7.954,6.703-15.859,13.373-23.754,20.053 c-55.499,46.928-110.976,93.876-166.475,140.771c-2.782,2.363-5.688,4.64-8.754,6.616c-15.972,10.215-26.917,8.851-39.505-4.747 C5.692,242.427,5.692,242.137,5.692,241.825z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5C5CC0" d="M242.869,110.581c15.381,13.662,30.547,27.153,45.713,40.633 c37.895,33.705,75.768,67.432,113.726,101.04c2.771,2.449,3.889,4.855,3.889,8.572c-0.129,56.68-0.064,113.338-0.15,170.019 c0,3.147-0.451,6.401-1.311,9.441c-1.139,4.038-4.296,6.165-8.378,6.82c-1.504,0.247-3.04,0.279-4.555,0.279 c-36.819,0.011-73.64,0.011-110.438,0c-0.924,0-1.825-0.097-3.479-0.183c0-1.783,0-3.545,0-5.284 c0.043-29.646,0.086-59.28,0.107-88.903c0-11.966-4.49-17.519-16.434-17.884c-17.229-0.526-34.517-0.258-51.756,0.15 c-7.067,0.172-10.967,4.64-11.729,11.687c-0.183,1.664-0.172,3.351-0.183,5.026c-0.097,30.247-0.182,60.493-0.279,90.739 c0,1.504,0,3.008,0,5.124c-2.083,0-3.716,0-5.349,0c-36.498,0.043-73.017,0.097-109.504,0.129 c-10.221,0.011-13.158-2.879-13.158-13.028c-0.021-58.356-0.043-116.701,0.086-175.057c0.011-2.105,0.956-4.952,2.481-6.23 c56.208-47.313,112.522-94.478,168.826-141.651C241.456,111.623,241.967,111.269,242.869,110.581z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5C5CC0" d="M419.343,174.382c-7.282-6.176-14.006-11.869-20.729-17.572 c-7.455-6.305-14.973-12.535-22.299-18.99c-1.32-1.149-2.643-3.169-2.664-4.813c-0.236-17.229-0.193-34.468-0.215-51.696 c0-0.43,0.193-0.859,0.365-1.514c15.081,0,30.118,0,45.542,0C419.343,111.064,419.343,142.331,419.343,174.382z"/> </g> </svg></a>');

	end admin;

	procedure normal as 

		ws_count     number;
		ws_pct       number;
		ws_progresso number;
		ws_total     number;
		ws_enviada   number;
		ws_usuario   number := 0;
		ws_auto      varchar2(80);

	begin

	    ws_usuario := pdi.retornaUsuario;
		
		htp.p('<div id="container" class="lista">');

			--htp.p('<div>');
			--htp.p('<img src="dwu.fcl.download?arquivo=logo_sistem.png" />');
			--htp.p('</div>');
			
			htp.p('<div id="logo">');
				pdi.retornaHtml('logo', ws_usuario);
			htp.p('</div>');

			htp.p('<p>Com o objetivo de desenvolver ainda mais os profissionais da nossa empresa, lan&ccedil;amos na segunda-feira o projeto Desenvolver+.</p>');

			htp.p('<p>Como parte do programa, vamos realizar essa an&aacute;lise (Plano de Desenvolvimento Individual), para que possamos identificar os aspectos comportamentais e de atua&ccedil;&atilde;o de cada coordenador e gerente, levando em conta a sua pr&oacute;pria percep&ccedil;&atilde;o, da sua equipe e dire&ccedil;&atilde;o.</p>');

			htp.p('<p>O question&aacute;rio foi desenvolvido em parceria com uma empresa especialista em an&aacute;lise de dados e &eacute; an&ocirc;nimo. Por isso, responda com honestidade e sempre que poss&iacute;vel, justifique a sua resposta.</p>');
			

			--antes texto ficava na tela inicial
			/*pdi.retornaHtml('titulo', ws_usuario);

			pdi.retornaHtml('principal', ws_usuario);*/

			htp.p('<div style="margin-top: 80px;">');
				htp.p('<h4 style="text-align: center;">AVALIA&Ccedil;&Otilde;ES DISPON&Iacute;VEIS</h4>');
				
				htp.p('<ul id="login">');
					for i in (
						select t1.cd_relacionamento, t1.cd_usuario, t1.cd_usuario_avaliado, t1.cd_setor, t2.nm_usuario, t3.nm_setor
						from pdi_relacionamento t1
						left join pdi_usuarios t2 on t2.cd_usuario = t1.cd_usuario_avaliado and t2.cd_cliente = fun.ret_var('CLIENTE')
						left join pdi_setores t3 on t3.cd_setor = t1.cd_setor and t3.cd_cliente = fun.ret_var('CLIENTE')
						where t1.cd_usuario = ws_usuario and
						t1.cd_cliente = fun.ret_var('CLIENTE')
						order by t1.cd_setor, t2.nm_usuario
					) loop

						select count(*) into ws_enviada from pdi_pergunta where 
						(select cd_setor from pdi_relacionamento where cd_usuario_avaliado = i.cd_usuario_avaliado and cd_usuario = ws_usuario and cd_cliente = fun.ret_var('CLIENTE'))
						in (select to_number(column_value) from table(fun.vpipe(cd_setores))) and
						cd_pergunta in (select cd_pergunta from pdi_avaliacao where cd_usuario_avaliado = i.cd_usuario_avaliado and cd_usuario = ws_usuario and cd_cliente = fun.ret_var('CLIENTE')) and
						--tp_categoria = ws_categoria and
						cd_cliente = fun.ret_var('CLIENTE');

						select count(*) into ws_total from pdi_pergunta where 
						(select cd_setor from pdi_relacionamento where cd_usuario_avaliado = i.cd_usuario_avaliado and cd_usuario = ws_usuario and cd_cliente = fun.ret_var('CLIENTE'))
						in (select to_number(column_value) from table(fun.vpipe(cd_setores))) and
						--tp_categoria = ws_categoria and
						cd_cliente = fun.ret_var('CLIENTE');

						if ws_total > 0 then
							ws_pct := 100/ws_total;
							ws_progresso := ceil(ws_pct*(ws_enviada));

							if ws_usuario = i.cd_usuario_avaliado then
								ws_auto := '(A)';
							else
								ws_auto := '';
							end if;
							
							if ws_progresso = 100 then
								htp.p('<li title="'||i.cd_usuario_avaliado||'" data-pct="'||trunc(ws_progresso)||'%" class="completo">'||i.nm_usuario||ws_auto||'</li>');
							elsif ws_progresso = 0 then
								htp.p('<li title="'||i.cd_usuario_avaliado||'">'||i.nm_usuario||ws_auto||'</li>');
							else
								htp.p('<li title="'||i.cd_usuario_avaliado||'" data-pct="'||trunc(ws_progresso)||'%">'||i.nm_usuario||ws_auto||'<span style="width: '||ws_progresso||'%;"></span></li>');
							end if;
						end if;

					end loop;
				htp.p('</ul>');
			htp.p('</div>');

			--htp.p('<a id="logout"><svg version="1.1" id="Capa_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 384.971 384.971" style="enable-background:new 0 0 384.971 384.971;" xml:space="preserve"> <g> <g id="Sign_Out"> <path d="M180.455,360.91H24.061V24.061h156.394c6.641,0,12.03-5.39,12.03-12.03s-5.39-12.03-12.03-12.03H12.03 C5.39,0.001,0,5.39,0,12.031V372.94c0,6.641,5.39,12.03,12.03,12.03h168.424c6.641,0,12.03-5.39,12.03-12.03 C192.485,366.299,187.095,360.91,180.455,360.91z"/> <path d="M381.481,184.088l-83.009-84.2c-4.704-4.752-12.319-4.74-17.011,0c-4.704,4.74-4.704,12.439,0,17.179l62.558,63.46H96.279 c-6.641,0-12.03,5.438-12.03,12.151c0,6.713,5.39,12.151,12.03,12.151h247.74l-62.558,63.46c-4.704,4.752-4.704,12.439,0,17.179 c4.704,4.752,12.319,4.752,17.011,0l82.997-84.2C386.113,196.588,386.161,188.756,381.481,184.088z"/> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg></a>');

		htp.p('</div>');

	end normal;

	procedure logout as

		ws_id_session  Varchar2(80);
		ws_cookie      owa_cookie.cookie;

	begin

		ws_cookie := owa_cookie.get('PDIHASH');
		ws_id_session := ws_cookie.vals(1);
		owa_util.mime_header('text/html', FALSE, NULL);
		Owa_Cookie.Send(Name=>'PDIHASH', Value=> ws_id_session, Expires => Sysdate - 9);
		owa_util.http_header_close;

		htp.p('<h4>SESS&Atilde;O ENCERRADA!</h4>');

	exception when others then
		htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end logout;


	------------- HTML -------------


	procedure retornaHtml ( prm_tipo varchar2, prm_usuario number ) as

		ws_conteudo    clob;
		ws_questionario number := 2;

	begin 

		--auto
		if pdi.retornaUsuario = prm_usuario then
			ws_questionario := 1;
		end if;
		
		select conteudo into ws_conteudo 
		from pdi_estaticos 
		where tp_estatico = prm_tipo and
		(cd_questionario = ws_questionario or cd_questionario is null) and
		cd_cliente = fun.ret_var('CLIENTE');
		htp.p(ws_conteudo);

	end retornaHtml;

	procedure cadastroDeEstaticos  ( prm_cod varchar2 default null ) as

		cursor crs_estaticos is 
		select cd_estatico, tp_estatico, conteudo, cd_questionario
		from pdi_estaticos where
		cd_estatico = prm_cod and
		cd_cliente = fun.ret_var('CLIENTE'); 

		ws_estatico crs_estaticos%rowtype;

		cursor crs_tipos is 
		select cd_questionario, ds_questionario from
		pdi_tipo_questionario
		where cd_cliente = fun.ret_var('CLIENTE');

		ws_tipo crs_tipos%rowtype;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;
		
		open crs_estaticos;
		loop
		fetch crs_estaticos into ws_estatico;
		exit when crs_estaticos%notfound;
		end loop;
		close crs_estaticos;

			htp.p('<div class="cadastro" id="editarEstatico">');

				htp.p('<ul>');

					htp.p('<li style="display: none;">');
						
						htp.p('<label for="prm_cod">cod</label>');
						htp.p('<input id="prm_cod" class="get" readonly value="'||ws_estatico.cd_estatico||'" />');
					
					htp.p('</li>');
					
					htp.p('<li>');
						
						htp.p('<label for="prm_questionario">Tipo de avalia&ccedil;&atilde;o</label>');
						htp.p('<select id="prm_questionario" class="get">');
							htp.p('<option value="">Nenhuma/Qualquer usu&aacute;rio</option>');
							open crs_tipos;
								loop
									fetch crs_tipos into ws_tipo;
									exit when crs_tipos%notfound;
									if ws_estatico.cd_questionario = ws_tipo.cd_questionario then
										htp.p('<option value="'||ws_tipo.cd_questionario||'" selected>'||ws_tipo.ds_questionario||'</option>');
									else
										htp.p('<option value="'||ws_tipo.cd_questionario||'">'||ws_tipo.ds_questionario||'</option>');
									end if;
								end loop;
							close crs_tipos;
						htp.p('</select>');

					htp.p('</li>');

					htp.p('<li>');
						
						htp.p('<label for="prm_tipo">Nome</label>');
						htp.p('<input id="prm_tipo" class="get" readonly value="'||ws_estatico.tp_estatico||'" />');
					
					htp.p('</li>');

					htp.p('<li>');
						htp.p('<label for="prm_conteudo">Conte&uacute;do</label>');
						htp.p('<textarea id="prm_conteudo" class="get" data-min="1" data-encode="">'||ws_estatico.conteudo||'</textarea>');
					htp.p('</li>');

					htp.p('<li>');
						if nvl(prm_cod, 'N/A') <> 'N/A' then
							htp.p('<a class="addpurple">SALVAR ALTERA&Ccedil;&Otilde;ES</a>');
						end if;
					htp.p('</li>');

				htp.p('</ul>');

			htp.p('</div>');

			pdi.listaDeEstaticos(prm_cod);

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end cadastroDeEstaticos;

	procedure listaDeEstaticos ( prm_cod varchar2 default null ) as 

		cursor crs_estaticos is 
		select cd_estatico, tp_estatico, conteudo, t1.cd_questionario, t2.ds_questionario
		from pdi_estaticos t1
		left join pdi_tipo_questionario t2 on t2.cd_questionario = t1.cd_questionario and t2.cd_cliente = fun.ret_var('CLIENTE')
		where
		/*cd_estatico = nvl(prm_cod, cd_estatico) and*/
		t1.cd_cliente = fun.ret_var('CLIENTE'); 

		ws_estatico crs_estaticos%rowtype;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		htp.p('<h4>LISTA DE TEXTOS</h4>');

		htp.p('<table>');
				htp.p('<thead>');
					htp.p('<tr>');
						htp.p('<th>NOME</th>');
						htp.p('<th>CONTE&Uacute;DO</th>');
						htp.p('<th>TIPO</th>');
						htp.p('<th></th>');
					htp.p('</tr>');
				htp.p('</thead>');
				htp.p('<tbody>');
					open crs_estaticos;
						loop
							fetch crs_estaticos into ws_estatico;
							exit when crs_estaticos%notfound;
							if ws_estatico.cd_estatico = prm_cod then
								htp.p('<tr class="selected">');
							else
								htp.p('<tr>');
							end if;
								htp.p('<td>'||ws_estatico.tp_estatico||'</td>');
								htp.p('<td>'||ws_estatico.conteudo||'</td>');
								htp.p('<td>'||ws_estatico.ds_questionario||'</td>');
								htp.p('<td>');
									htp.p('<a data-par="prm_cod='||ws_estatico.cd_estatico||'" data-req="cadastroDeEstaticos" data-res="conteudo" class="edit">'||pdi.retornaIcone('edit')||'</a>');
									--htp.p('<a data-par="prm_cod='||ws_estatico.tp_estatico||'" data-req="exclusaoDeFormato" class="remove"></a>');
								htp.p('</td>');
							htp.p('</tr>');
						end loop;
					close crs_estaticos;
				htp.p('</tbody>');
			htp.p('</table>');
	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end listaDeEstaticos;

	procedure editarEstatico ( prm_cod          varchar2,
							   prm_questionario number,
							   prm_tipo         varchar2,
							   prm_conteudo     clob ) as

		ws_count    number;
		ws_formato number := 1;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		update pdi_estaticos
		set conteudo = converte(prm_conteudo),
		tp_estatico  = prm_tipo,
		cd_questionario = prm_questionario
		where cd_estatico = prm_cod and
		cd_cliente = fun.ret_var('CLIENTE');
		
		ws_count := sql%rowcount;
		
		if ws_count <> 0 then
			commit;
			htp.p('Salvo com sucesso!');
		else
			rollback;
			htp.p('Erro ao salvar!');
		end if;

    exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end editarEstatico;


	----------- PERGUNTA -----------


	procedure cadastroDePergunta  ( prm_cod       number default null, 
									prm_categoria varchar2 default null,
									prm_setor     number   default null ) as

		cursor crs_categorias is 
		select ds_categoria, nm_categoria, ti_categoria 
		from pdi_categorias where
		cd_cliente = fun.ret_var('CLIENTE'); 

		ws_categoria crs_categorias%rowtype;

		cursor crs_formatos is
		select distinct tp_formato 
		from pdi_formato_perguntas where 
		cd_cliente = fun.ret_var('CLIENTE');
		ws_formato crs_formatos%rowtype;

		cursor crs_pergunta is
		select cd_pergunta, ds_pergunta, tp_categoria, justificativa, tp_formato, cd_setores, ordem
		from pdi_pergunta
		where cd_pergunta = prm_cod and
		cd_cliente = fun.ret_var('CLIENTE');

		ws_pergunta crs_pergunta%rowtype;

		cursor crs_setores is
		select cd_setor, nm_setor
		from pdi_setores
		where cd_cliente = fun.ret_var('CLIENTE');

		ws_setor crs_setores%rowtype;

		ws_checked varchar2(80) := '';

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		open crs_pergunta;
		loop
		fetch crs_pergunta into ws_pergunta;
		exit when crs_pergunta%notfound;
		end loop;
		close crs_pergunta;

			htp.p('<div class="cadastro" id="adicionarPergunta">');

				htp.p('<ul class="centro">');
					htp.p('<li style="display: none;">');
						htp.p('<label for="prm_cod">C&Oacute;DIGO</label>');
						htp.p('<input id="prm_cod" class="get" type="number" placeholder="" value="'||ws_pergunta.cd_pergunta||'"/>');
					htp.p('</li>');

					htp.p('<li>');
						
						htp.p('<ul class="horizontal">');
							
							--htp.p('<li>');
								
								
								/*htp.p('<select id="prm_setor" class="get">');
									open crs_setores;
										loop
											fetch crs_setores into ws_setor;
											exit when crs_setores%notfound;
											if ws_setor.cd_setor = ws_pergunta.cd_setor then 
												htp.p('<option value="'||ws_setor.cd_setor||'" title="'||ws_setor.cd_setor||'" selected>'||ws_setor.nm_setor||'</option>');
											else
												htp.p('<option value="'||ws_setor.cd_setor||'" title="'||ws_setor.cd_setor||'">'||ws_setor.nm_setor||'</option>');
											end if;
										end loop;
									close crs_setores;
								htp.p('</select>');*/

							--htp.p('</li>');
						
							htp.p('<li>');	
								htp.p('<label for="prm_tipo">Tema</label>');
								htp.p('<select id="prm_tipo" class="get">');
									open crs_categorias;
										loop
											fetch crs_categorias into ws_categoria;
											exit when crs_categorias%notfound;
											if ws_categoria.nm_categoria = ws_pergunta.tp_categoria then 
												htp.p('<option value="'||ws_categoria.nm_categoria||'" title="'||ws_categoria.ti_categoria||'" selected>'||ws_categoria.nm_categoria||'</option>');
											else
												htp.p('<option value="'||ws_categoria.nm_categoria||'" title="'||ws_categoria.ti_categoria||'">'||ws_categoria.nm_categoria||'</option>');
											end if;
										end loop;
									close crs_categorias;
								htp.p('</select>');
							htp.p('</li>');

						
							htp.p('<li>');
								htp.p('<label for="prm_justificativa">Justificativa</label>');
								htp.p('<select id="prm_justificativa" class="get">');
									htp.p('<option value="S">SIM</option>');
									if ws_pergunta.justificativa = 'N' then
										htp.p('<option value="N" selected>N&Atilde;O</option>');
									else
										htp.p('<option value="N">N&Atilde;O</option>');
									end if;
								htp.p('</select>');
							htp.p('</li>');
					
							htp.p('<li>');	
								htp.p('<label for="prm_formato">Formato</label>');
								htp.p('<select id="prm_formato" class="get">');
									open crs_formatos;
										loop
											fetch crs_formatos into ws_formato;
											exit when crs_formatos%notfound;
											if ws_formato.tp_formato = ws_pergunta.tp_formato then
												htp.p('<option value="'||ws_formato.tp_formato||'" selected>'||ws_formato.tp_formato||'</option>');
											else
												htp.p('<option value="'||ws_formato.tp_formato||'">'||ws_formato.tp_formato||'</option>');
											end if;
										end loop;
									close crs_formatos;
								htp.p('</select>');
							htp.p('</li>');
						htp.p('</ul>');
					htp.p('</li>');

					htp.p('<li>');
					    htp.p('<label for="prm_setor">Setor</label>');
						htp.p('<ul id="prm_setor" class="get multibox" title="'||ws_pergunta.cd_setores||'" data-min="1">');
							open crs_setores;
								loop
									fetch crs_setores into ws_setor;
									exit when crs_setores%notfound;
									htp.p('<li>');
										
										if nvl(prm_cod, 0) <> 0 then
										    begin
												select 'checked' into ws_checked from table(fun.vpipe(ws_pergunta.cd_setores)) where column_value = ws_setor.cd_setor;
											exception when others then
												ws_checked := '';
											end;
										end if;
										
										htp.p('<label for="">'||ws_setor.nm_setor||'</label>');
										htp.p('<input data-parent="prm_setor" class="multicheck" type="checkbox" value="'||ws_setor.cd_setor||'" title="'||ws_setor.cd_setor||'"  '||ws_checked||' />');
									htp.p('</li>');
								end loop;
							close crs_setores;
						htp.p('</ul>');
					htp.p('</li>');

					htp.p('<li class="centro">');
						htp.p('<label for="prm_pergunta">Pergunta</label>');
						htp.p('<textarea id="prm_pergunta" class="get" data-min="1">'||ws_pergunta.ds_pergunta||'</textarea>');

						htp.p('<label for="prm_ordem">Ordem</label>');
						htp.p('<input id="prm_ordem" class="get" data-min="1" value="'||ws_pergunta.ordem||'" onkeypress="if(event.key == 0){ return false; }" oninput="this.value = VMasker.toPattern(this.value, ''9999'');" />');

						if nvl(prm_cod, 0) <> 0 then
							htp.p('<a class="nova" style="float: right;">CANCELAR</a>');
							htp.p('<a class="addpurple" style="float: right;">SALVAR ALTERA&Ccedil;&Otilde;ES</a>');
						else
							htp.p('<a class="addpurple" style="float: right;">CADASTRAR PERGUNTA</a>');
						end if;
					
					htp.p('</li>');

				htp.p('</ul>');

			htp.p('</div>');

			pdi.listaDePerguntas(prm_cod, prm_categoria, prm_setor);

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end cadastroDePergunta;


	procedure listaDePerguntas ( prm_cod       number default null,
								 prm_categoria varchar2 default null,
								 prm_setor     number default null ) as 

		cursor crs_perguntas is 
		select cd_pergunta, ds_pergunta, tp_categoria, t1.cd_setores, /*nm_setor,*/ justificativa, ordem,
		decode(justificativa, 'S', 'SIM', 'N', 'N&Atilde;O') as justificativa_desc, tp_formato 
		from pdi_pergunta t1
		--left join pdi_setores t2 on t1.cd_setores like '%'||t2.cd_setor||'|%'  and t2.cd_cliente = fun.ret_var('CLIENTE')
		
		where tp_categoria = nvl(prm_categoria, tp_categoria) and
		(nvl(trim(to_char(prm_setor)), cd_setores) = cd_setores or 
		prm_setor in (select column_value from table(fun.vpipe(cd_setores))) ) and
		t1.cd_cliente = fun.ret_var('CLIENTE')
		order by tp_categoria, ordem asc, ds_pergunta asc;

		ws_pergunta crs_perguntas%rowtype;

		cursor crs_categorias is 
		select ds_categoria, nm_categoria, ti_categoria 
		from pdi_categorias where 
		cd_cliente = fun.ret_var('CLIENTE'); 

		ws_categoria crs_categorias%rowtype;

		cursor crs_setores is 
		select cd_setor, nm_setor 
		from pdi_setores
		where 
		cd_cliente = fun.ret_var('CLIENTE')
		order by nm_setor asc;

		ws_setor crs_setores%rowtype;

		ws_setor_texto varchar2(400);

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		htp.p('<h4>LISTA DE PERGUNTAS</h4>');

		htp.p('<select id="prm_setor" class="filtro">');
			htp.p('<option value="">Todas os setores</option>');
			open crs_setores;
				loop
					fetch crs_setores into ws_setor;
					exit when crs_setores%notfound;
					if ws_setor.cd_setor = prm_setor then 
						htp.p('<option value="'||ws_setor.cd_setor||'" title="'||ws_setor.cd_setor||'" selected>'||ws_setor.nm_setor||'</option>');
					else
						htp.p('<option value="'||ws_setor.cd_setor||'" title="'||ws_setor.cd_setor||'">'||ws_setor.nm_setor||'</option>');
					end if;
				end loop;
			close crs_setores;
		htp.p('</select>');
		
		htp.p('<select id="prm_categoria" class="filtro">');
			htp.p('<option value="">Todas os temas</option>');
			open crs_categorias;
				loop
					fetch crs_categorias into ws_categoria;
					exit when crs_categorias%notfound;
					if ws_categoria.nm_categoria = prm_categoria then 
						htp.p('<option value="'||ws_categoria.nm_categoria||'" title="'||ws_categoria.ti_categoria||'" selected>'||ws_categoria.nm_categoria||'</option>');
					else
						htp.p('<option value="'||ws_categoria.nm_categoria||'" title="'||ws_categoria.ti_categoria||'">'||ws_categoria.nm_categoria||'</option>');
					end if;
				end loop;
			close crs_categorias;
		htp.p('</select>');

		htp.p('<div class="limit">');
			htp.p('<table>');
				htp.p('<thead>');
					htp.p('<tr>');
						htp.p('<th>PERGUNTA</th>');
						htp.p('<th>SETOR</th>');
						htp.p('<th>TEMA</th>');
						htp.p('<th>JUSTIFICATIVA</th>');
						htp.p('<th>FORMATO</th>');
						htp.p('<th>ORDEM</th>');
						htp.p('<th></th>');
					htp.p('</tr>');
				htp.p('</thead>');
				htp.p('<tbody>');
					open crs_perguntas;
						loop
							fetch crs_perguntas into ws_pergunta;
							exit when crs_perguntas%notfound;
							if ws_pergunta.cd_pergunta = prm_cod then
								htp.p('<tr class="selected">');
							else
								htp.p('<tr>');
							end if;
								htp.p('<td>'||ws_pergunta.ds_pergunta||'</td>');

								ws_setor_texto := '';
								for i in (
									select nm_setor from pdi_setores where cd_setor in (
										select column_value from table(fun.vpipe((ws_pergunta.cd_setores)))
									) and cd_cliente = fun.ret_var('CLIENTE')
								) loop
									ws_setor_texto := ws_setor_texto||', '||i.nm_setor;
								end loop;
								ws_setor_texto := substr(ws_setor_texto, 3, length(ws_setor_texto));

								htp.p('<td>'||ws_setor_texto||'</td>');
								htp.p('<td>'||ws_pergunta.tp_categoria||'</td>');
								htp.p('<td>'||ws_pergunta.justificativa_desc||'</td>');
								htp.p('<td>'||ws_pergunta.tp_formato||'</td>');
								htp.p('<td>'||ws_pergunta.ordem||'</td>');
								htp.p('<td>');
									htp.p('<a data-par="prm_cod='||ws_pergunta.cd_pergunta||'" data-req="cadastroDePergunta" data-res="conteudo" class="edit">'||pdi.retornaIcone('edit')||'</a>');
									htp.p('<a data-par="prm_cod='||ws_pergunta.cd_pergunta||'" data-req="exclusaoDePergunta" data-res="conteudo" class="remove">'||pdi.retornaIcone('lixo')||'</a>');
								htp.p('</td>');
							htp.p('</tr>');
						end loop;
					close crs_perguntas;
				htp.p('</tbody>');
			htp.p('</table>');
		htp.p('</div>');

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end listaDePerguntas;

	procedure visualizarPerguntas ( prm_setor varchar2 default null ) as 

		cursor crs_perguntas is 
		select cd_pergunta, ds_pergunta, tp_categoria, justificativa, tp_formato, ds_categoria, nm_categoria, ti_categoria, ordem from (
			select cd_pergunta, ds_pergunta, tp_categoria, justificativa, tp_formato, ds_categoria, nm_categoria, ti_categoria, rownum as linha, ordem from (
				select cd_pergunta, ds_pergunta, tp_categoria, justificativa, tp_formato,
				ds_categoria, nm_categoria, ti_categoria, ordem
				from pdi_pergunta t1
				left join pdi_categorias t2 on tp_categoria = nm_categoria and t2.cd_cliente = fun.ret_var('CLIENTE')
				where 
				/*(select cd_setor from pdi_relacionamento where cd_usuario_avaliado = prm_avaliado and cd_usuario = pdi.retornaUsuario and cd_cliente = fun.ret_var('CLIENTE'))
				in (select to_number(column_value) from table(fun.vpipe(cd_setores))) and
				cd_pergunta not in (
					select cd_pergunta from pdi_avaliacao where cd_usuario_avaliado = prm_avaliado and cd_usuario = pdi.retornaUsuario and cd_cliente = fun.ret_var('CLIENTE')
				) 
				and*/
				prm_setor in (select column_value from table(fun.vpipe(cd_setores))) and
				t1.cd_cliente = fun.ret_var('CLIENTE')
				order by tp_categoria, ordem asc, cd_pergunta asc) 
		);

		ws_pergunta crs_perguntas%rowtype;

		ws_categoria varchar2(80) := 'N/A';

		cursor crs_setores is 
		select cd_setor, nm_setor 
		from pdi_setores
		where 
		cd_cliente = fun.ret_var('CLIENTE')
		order by nm_setor asc;

		ws_setor crs_setores%rowtype;

		ws_setor_texto varchar2(400);

	begin

		htp.p('<div class="questao report" id="visualizarPerguntas">');

		htp.p('<select id="prm_setor" class="filtro">');
			htp.p('<option value="">Todas os setores</option>');
			open crs_setores;
				loop
					fetch crs_setores into ws_setor;
					exit when crs_setores%notfound;
					if ws_setor.cd_setor = prm_setor then 
						htp.p('<option value="'||ws_setor.cd_setor||'" title="'||ws_setor.cd_setor||'" selected>'||ws_setor.nm_setor||'</option>');
					else
						htp.p('<option value="'||ws_setor.cd_setor||'" title="'||ws_setor.cd_setor||'">'||ws_setor.nm_setor||'</option>');
					end if;
				end loop;
			close crs_setores;
		htp.p('</select>');
		
			open crs_perguntas;
				loop
					fetch crs_perguntas into ws_pergunta;
					exit when crs_perguntas%notfound;

					if ws_categoria <> ws_pergunta.ti_categoria then
						htp.p('<h4>'||ws_pergunta.ti_categoria||' <a class="opendesc">?</a></h4>');

						htp.p('<span class="desc invisible">'||ws_pergunta.ds_categoria||'</span>');
						ws_categoria := ws_pergunta.ti_categoria;
					end if;

					htp.p('<div class="avaliacao" title="'||ws_pergunta.cd_pergunta||'">');
					
						htp.p('<span class="pergunta">'||ws_pergunta.ordem||' - '||ws_pergunta.ds_pergunta||'</span>');

					htp.p('</div>');

				end loop;
			close crs_perguntas;

	    htp.p('</div>');

	end visualizarPerguntas;

	procedure adicionarPergunta ( prm_cod           number default 0,
								  prm_tipo          varchar2,
								  prm_setor         varchar2,
								  prm_justificativa varchar2,
								  prm_formato       varchar2,
								  prm_pergunta      varchar2,
								  prm_ordem         number default null ) as

		ws_count    number;
		ws_pergunta number := 1;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		select nvl(max(cd_pergunta), 0)+1 into ws_pergunta from pdi_pergunta;

		merge into pdi_pergunta t1
			using (select prm_cod as cod, prm_tipo as tipo, prm_setor as setor, prm_justificativa as justificativa, 
			converte(prm_formato) as formato, prm_pergunta as pergunta, prm_ordem as ordem from dual) t2
			on (t1.cd_pergunta = t2.cod and t1.cd_cliente = fun.ret_var('CLIENTE'))
			when matched then update 
			set t1.tp_categoria = converte(t2.tipo),
			t1.cd_setores    = t2.setor,
			t1.justificativa = t2.justificativa,
			t1.tp_formato    = t2.formato,
			t1.ds_pergunta   = converte(t2.pergunta),
			t1.ordem         = t2.ordem

			when not matched then insert (cd_pergunta, tp_categoria, cd_setores, justificativa, tp_formato, ds_pergunta, cd_cliente, ordem) 
			values (ws_pergunta, converte(prm_tipo), prm_setor, prm_justificativa, converte(prm_formato), converte(prm_pergunta), fun.ret_var('CLIENTE'), prm_ordem);

		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Pergunta salva com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Pergunta #'||prm_cod||' salva com sucesso!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao salvar a pergunta!');
		end if;

    exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao adicionar a pergunta #'||prm_cod||' do sistema! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
	end adicionarPergunta;

	procedure exclusaoDePergunta ( prm_cod number ) as

		ws_count number;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		delete from pdi_pergunta where cd_pergunta = prm_cod and cd_cliente = fun.ret_var('CLIENTE');

		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Pergunta removida com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Pergunta #'||prm_cod||' excluida do sistema!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao remover a pergunta!');
		end if;

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao excluir a pergunta #'||prm_cod||' do sistema! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
	end exclusaoDePergunta;


	-------------- FORMATO --------------


	procedure cadastroDeFormato ( prm_cod number default null ) as 

		cursor crs_formatos is 
		select tp_formato, cd_formato, ds_formato, vl_formato 
		from pdi_formato_perguntas
		where cd_formato = prm_cod and
		cd_cliente = fun.ret_var('CLIENTE')
		order by ds_formato asc;

		ws_formato crs_formatos%rowtype;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		open crs_formatos;
		loop
		fetch crs_formatos into ws_formato;
		exit when crs_formatos%notfound;
		end loop;
		close crs_formatos;

			htp.p('<div class="cadastro" id="adicionarFormato">');

				htp.p('<ul>');
					htp.p('<li style="display: none;">');
						htp.p('<label for="prm_cod">C&Oacute;DIGO</label>');
						htp.p('<input id="prm_cod" class="get" type="number" placeholder="" value="'||ws_formato.cd_formato||'"/>');
					htp.p('</li>');

					htp.p('<li>');
						htp.p('<label for="prm_tipo">Tipo</label>');
						htp.p('<input id="prm_tipo" class="get" data-min="1" list="datalist" value="'||ws_formato.tp_formato||'">');
						htp.p('<datalist id="datalist">');
							for i in (  select distinct tp_formato
										from pdi_formato_perguntas
										where cd_cliente = fun.ret_var('CLIENTE')
										order by tp_formato asc) loop
							htp.p('<option>'||i.tp_formato||'</option>');							
							end loop;
						htp.p('</datalist>');
					htp.p('</li>');

					htp.p('<li>');
						htp.p('<label for="prm_valor">Valor da op&ccedil&atilde;o</label>');
						htp.p('<input id="prm_valor" class="get" value="'||ws_formato.vl_formato||'" oninput="this.value = VMasker.toPattern(this.value, ''99999999999'');"/>');
					htp.p('</li>');

					htp.p('<li>');
						htp.p('<label for="prm_desc">Descri&ccedil;&atilde;o da op&ccedil&atilde;o</label>');
						htp.p('<textarea id="prm_desc" data-min="1" class="get" data-encode="*" placeholder="Vazio caso seja dissertativa">'||ws_formato.ds_formato||'</textarea>');
					htp.p('</li>');

					htp.p('<li>');
						if nvl(prm_cod, 0) <> 0 then
							htp.p('<a class="addpurple">SALVAR ALTERA&Ccedil;&Otilde;ES</a>');
							htp.p('<a class="nova">CANCELAR</a>');
						else
							htp.p('<a class="addpurple">CADASTRAR FORMATO</a>');
						end if;
					htp.p('</li>');

				htp.p('</ul>');

			htp.p('</div>');

			pdi.listaDeFormatos(prm_cod);

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end cadastroDeFormato;


	procedure listaDeFormatos ( prm_cod number default null ) as 

		cursor crs_formatos is 
		select tp_formato, cd_formato, ds_formato, vl_formato 
		from pdi_formato_perguntas
		where cd_cliente = fun.ret_var('CLIENTE')
		order by tp_formato, vl_formato, ds_formato asc;

		ws_formato crs_formatos%rowtype;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		htp.p('<h4>LISTA DE FORMATOS</h4>');

		htp.p('<div class="limit">');	
			htp.p('<table>');
				htp.p('<thead>');
					htp.p('<tr>');
						htp.p('<th>TIPO</th>');
						htp.p('<th>DESCRI&Ccedil;&Atilde;O</th>');
						htp.p('<th>VALOR</th>');
						htp.p('<th></th>');
					htp.p('</tr>');
				htp.p('</thead>');
				htp.p('<tbody>');
					open crs_formatos;
						loop
							fetch crs_formatos into ws_formato;
							exit when crs_formatos%notfound;
							if ws_formato.cd_formato = prm_cod then
								htp.p('<tr class="selected">');
							else
								htp.p('<tr>');
							end if;
								htp.p('<td>'||ws_formato.tp_formato||'</td>');
								htp.p('<td>'||ws_formato.ds_formato||'</td>');
								htp.p('<td style="text-align: right;">'||ws_formato.vl_formato||'</td>');
								htp.p('<td>');
									htp.p('<a data-par="prm_cod='||ws_formato.cd_formato||'" data-req="cadastroDeFormato" data-res="conteudo" class="edit">'||pdi.retornaIcone('edit')||'</a>');
									htp.p('<a data-par="prm_cod='||ws_formato.cd_formato||'" data-req="exclusaoDeFormato" data-res="conteudo" class="remove">'||pdi.retornaIcone('lixo')||'</a>');
								htp.p('</td>');
							htp.p('</tr>');
						end loop;
					close crs_formatos;
				htp.p('</tbody>');
			htp.p('</table>');
		htp.p('</div>');

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end listaDeFormatos;

	procedure adicionarFormato ( prm_cod    number default 0,
								 prm_tipo   varchar2,
								 prm_valor  varchar2,
								 prm_desc   varchar2 ) as

		ws_count    number;
		ws_formato number := 1;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;
	
		select nvl(max(cd_formato), 0)+1 into ws_formato from pdi_formato_perguntas;

		merge into pdi_formato_perguntas t1
			using (select prm_cod as cod, converte(prm_tipo) as tipo, prm_valor as valor, converte(prm_desc) as descr from dual) t2
			on (t1.cd_formato = t2.cod and t1.cd_cliente = fun.ret_var('CLIENTE'))
			when matched then update 
			set t1.tp_formato = t2.tipo,
			t1.ds_formato = t2.descr,
			t1.vl_formato = t2.valor

			when not matched then insert (tp_formato, cd_formato, ds_formato, vl_formato, cd_cliente) 
			values (converte(prm_tipo), ws_formato, converte(prm_desc), prm_valor, fun.ret_var('CLIENTE'));
		
		ws_count := sql%rowcount;
		
		if ws_count <> 0 then
			commit;
			htp.p('Formato salvo com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Formato adicionado ao sistema!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao salvar o formato!');
		end if;
    
	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao excluir formato #'||prm_cod||' do sistema! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
	end adicionarFormato;

	procedure exclusaoDeFormato ( prm_cod number ) as

		ws_count number;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		delete from pdi_formato_perguntas where cd_formato = prm_cod and cd_cliente = fun.ret_var('CLIENTE');

		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Formato removido com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Formato #'||prm_cod||' excluido do sistema!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao remover o formato!');
		end if;

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao excluir formato #'||prm_cod||' do sistema! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
	end exclusaoDeFormato;


	-------------- SETOR --------------


	procedure cadastroDeSetor ( prm_cod number default null ) as 

		cursor crs_setores is 
		select cd_setor, nm_setor 
		from pdi_setores
		where cd_setor = prm_cod and
		cd_cliente = fun.ret_var('CLIENTE')
		order by nm_setor asc;

		ws_setor crs_setores%rowtype;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		open crs_setores;
		loop
		fetch crs_setores into ws_setor;
		exit when crs_setores%notfound;
		end loop;
		close crs_setores;


		htp.p('<div class="cadastro" id="adicionarSetor">');

			htp.p('<ul>');
				htp.p('<li style="display: none;">');
					htp.p('<label for="prm_cod">C&Oacute;DIGO</label>');
					htp.p('<input id="prm_cod" class="get" type="number" placeholder="" value="'||ws_setor.cd_setor||'"/>');
				htp.p('</li>');

				htp.p('<li>');
					htp.p('<label for="prm_nome">Nome</label>');
					htp.p('<input id="prm_nome" class="get" data-min="1" value="'||ws_setor.nm_setor||'">');
				htp.p('</li>');

				htp.p('<li>');
				    if nvl(prm_cod, 0) <> 0 then
						htp.p('<a class="addpurple">SALVAR ALTERA&Ccedil;&Otilde;ES</a>');
						htp.p('<a class="nova">CANCELAR</a>');
					else
						htp.p('<a class="addpurple">CADASTRAR SETOR</a>');
					end if;
				htp.p('</li>');

			htp.p('</ul>');

		htp.p('</div>');

		pdi.listaDeSetores(prm_cod);

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end cadastroDeSetor;


	procedure listaDeSetores ( prm_cod number default null ) as 

		cursor crs_setores is 
		select cd_setor, nm_setor 
		from pdi_setores
		where 
		cd_cliente = fun.ret_var('CLIENTE')
		order by nm_setor asc;

		ws_setor crs_setores%rowtype;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		htp.p('<h4>LISTA DE SETORES</h4>');

		htp.p('<div class="limit">');
			htp.p('<table>');
				htp.p('<thead>');
					htp.p('<tr>');
						htp.p('<th>NOME</th>');
						htp.p('<th></th>');
					htp.p('</tr>');
				htp.p('</thead>');
				htp.p('<tbody>');
					open crs_setores;
						loop
							fetch crs_setores into ws_setor;
							exit when crs_setores%notfound;
							if ws_setor.cd_setor = prm_cod then
								htp.p('<tr class="selected">');
							else
								htp.p('<tr>');
							end if;
								htp.p('<td>'||ws_setor.nm_setor||'</td>');
								htp.p('<td>');
									htp.p('<a data-par="prm_cod='||ws_setor.cd_setor||'" data-req="cadastroDeSetor" data-res="conteudo" class="edit">'||pdi.retornaIcone('edit')||'</a>');
									htp.p('<a data-par="prm_cod='||ws_setor.cd_setor||'" data-req="exclusaoDeSetor" data-res="conteudo" class="remove">'||pdi.retornaIcone('lixo')||'</a>');
								htp.p('</td>');
							htp.p('</tr>');
						end loop;
					close crs_setores;
				htp.p('</tbody>');
			htp.p('</table>');
		htp.p('</div>');

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end listaDeSetores;

	procedure adicionarSetor ( prm_cod    number default 0,
							   prm_nome   varchar2 ) as

		ws_count    number;
		ws_setor number := 1;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		select nvl(max(cd_setor), 0)+1 into ws_setor from pdi_setores;

		merge into pdi_setores t1
			using (select prm_cod as cod, converte(prm_nome) as nome from dual) t2
			on (t1.cd_setor = t2.cod and t1.cd_cliente = fun.ret_var('CLIENTE'))
			when matched then update
			set t1.nm_setor = t2.nome

			when not matched then insert (cd_setor, nm_setor, cd_cliente)
			values (ws_setor, converte(prm_nome), fun.ret_var('CLIENTE'));
		
		ws_count := sql%rowcount;
		
		if ws_count <> 0 then
			commit;
			htp.p('Setor salvo com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Setor #'||prm_cod||' adicionado ao sistema!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao salvar o setor!');
		end if;
    
	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao adicionar o setor #'||prm_cod||' ao sistema! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
	end adicionarSetor;

	procedure exclusaoDeSetor ( prm_cod number ) as

		ws_count number;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		delete from pdi_setores where cd_setor = prm_cod and cd_cliente = fun.ret_var('CLIENTE');

		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Setor removido com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Setor #'||prm_cod||' removido do sistema!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao remover o setor!');
		end if;

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end exclusaoDeSetor;


	---------- CATEGORIA ----------


	procedure cadastroDeCategoria ( prm_cod number default null )  as

		cursor crs_categorias is 
		select cd_categoria, ds_categoria, nm_categoria, ti_categoria 
		from pdi_categorias
		where cd_categoria = prm_cod and
		cd_cliente = fun.ret_var('CLIENTE'); 

		ws_categoria crs_categorias%rowtype;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		open crs_categorias;
		loop
		fetch crs_categorias into ws_categoria;
		exit when crs_categorias%notfound;
		end loop;
		close crs_categorias;

			htp.p('<div class="cadastro" id="adicionarCategoria">');

				htp.p('<ul>');
					htp.p('<li style="display: none;">');
						htp.p('<label for="prm_cod">C&Oacute;DIGO</label>');
						htp.p('<input id="prm_cod" class="get" type="number" placeholder="" value="'||ws_categoria.cd_categoria||'"/>');
					htp.p('</li>');

					htp.p('<li>');
						htp.p('<label for="prm_nome">Tema</label>');
						htp.p('<input id="prm_nome" class="get" data-min="1" value="'||ws_categoria.nm_categoria||'">');
					htp.p('</li>');

					htp.p('<li>');
						
						htp.p('<ul class="horizontal">');						
							htp.p('<li>');
								htp.p('<label for="prm_tema">Descri&ccedil;&atilde;o</label>');
								htp.p('<textarea id="prm_tema" class="get" data-min="1">'||ws_categoria.ti_categoria||'</textarea>');
							htp.p('</li>');
							htp.p('<li>');
								htp.p('<label for="prm_desc">Observa&ccedil;&atilde;o</label>');
								htp.p('<textarea id="prm_desc" class="get" data-min="1">'||ws_categoria.ds_categoria||'</textarea>');
							htp.p('</li>');
						htp.p('</ul>');
					htp.p('</li>');

					htp.p('<li>');
						if nvl(prm_cod, 0) <> 0 then
							htp.p('<a class="addpurple">SALVAR ALTERA&Ccedil;&Otilde;ES</a>');
							htp.p('<a class="nova">CANCELAR</a>');
						else
							htp.p('<a class="addpurple">CADASTRAR TEMA</a>');
						end if;
					htp.p('</li>');

				htp.p('</ul>');

			htp.p('</div>');

			pdi.listaDeCategorias(prm_cod);

		htp.p('</div>');

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end cadastroDeCategoria;

	procedure listaDeCategorias ( prm_cod number default null ) as 

		cursor crs_categorias is 
		select cd_categoria, ds_categoria, nm_categoria, ti_categoria 
		from pdi_categorias
		where cd_cliente = fun.ret_var('CLIENTE'); 

		ws_categoria crs_categorias%rowtype;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		htp.p('<h4>LISTA DE TEMAS</h4>');

		htp.p('<div class="limit">');
			htp.p('<table>');
				htp.p('<thead>');
					htp.p('<tr>');
						htp.p('<th>TEMA</th>');
						htp.p('<th>DESCRI&Ccedil;&Atilde;O</th>');
						htp.p('<th>OBSERVA&Ccedil;&Atilde;O</th>');
						htp.p('<th></th>');
					htp.p('</tr>');
				htp.p('</thead>');
				htp.p('<tbody>');
					open crs_categorias;
						loop
							fetch crs_categorias into ws_categoria;
							exit when crs_categorias%notfound;
							if ws_categoria.cd_categoria = prm_cod then
								htp.p('<tr class="selected">');
							else
								htp.p('<tr>');
							end if;
								htp.p('<td>'||ws_categoria.nm_categoria||'</td>');
								htp.p('<td>'||ws_categoria.ti_categoria||'</td>');
								htp.p('<td>'||ws_categoria.ds_categoria||'</td>');
								htp.p('<td>');
									htp.p('<a data-par="prm_cod='||ws_categoria.cd_categoria||'" data-req="cadastroDeCategoria" data-res="conteudo" class="edit">'||pdi.retornaIcone('edit')||'</a>');
									htp.p('<a data-par="prm_cod='||ws_categoria.cd_categoria||'" data-req="exclusaoDeCategoria" data-res="conteudo" class="remove">'||pdi.retornaIcone('lixo')||'</a>');
								htp.p('</td>');
							htp.p('</tr>');
						end loop;
					close crs_categorias;
				htp.p('</tbody>');
			htp.p('</table>');
		htp.p('</div>');

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end listaDeCategorias;

	procedure adicionarCategoria ( prm_cod  number default 0,
								   prm_nome varchar2,
								   prm_tema varchar2,
								   prm_desc varchar2 ) as

		ws_count    number;
		ws_categoria number := 1;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		select nvl(max(cd_categoria), 0)+1 into ws_categoria from pdi_categorias;

		merge into pdi_categorias t1
			using (select prm_cod as cod, converte(prm_nome) as nome, converte(prm_tema) as tema, converte(prm_desc) as descr from dual) t2
			on (t1.cd_categoria = t2.cod and t1.cd_cliente = fun.ret_var('CLIENTE'))
			when matched then update 
			set t1.ds_categoria = t2.descr,
			t1.nm_categoria = t2.nome,
			t1.ti_categoria = t2.tema

			when not matched then insert (cd_categoria, ds_categoria, nm_categoria, ti_categoria, cd_cliente) 
			values (trim(ws_categoria), converte(prm_desc), converte(prm_nome), converte(prm_tema), fun.ret_var('CLIENTE'));
		
		ws_count := sql%rowcount;
		
		if ws_count <> 0 then
			commit;
			htp.p('Tema salvo com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Tema adicionado ao sistema!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao salvar o tema!');
		end if;
    
	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao adicionar o tema '||prm_cod||' ao sistema! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
	end adicionarCategoria;

	procedure exclusaoDeCategoria ( prm_cod number ) as

		ws_count number;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		delete from pdi_categorias where cd_categoria = prm_cod and cd_cliente = fun.ret_var('CLIENTE');

		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Tema removido com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Tema #'||prm_cod||' removido do sistema!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao remover o tema!');
		end if;

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao remover o tema '||prm_cod||' do sistema! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
	end exclusaoDeCategoria;


	------------ USUÁRIO -------------


	procedure cadastroDeUsuario ( prm_cod number default null, prm_busca varchar2 default null )  as

		cursor crs_usuarios is 
		select cd_usuario, nm_usuario, telefone, email, cd_setor, login, cd_questionario, cd_hierarquia
		from pdi_usuarios
		where cd_usuario = prm_cod and
		cd_cliente = fun.ret_var('CLIENTE');

		ws_usuario crs_usuarios%rowtype;

		cursor crs_setores is
		select cd_setor, nm_setor
		from pdi_setores
		where cd_cliente = fun.ret_var('CLIENTE');

		ws_setor crs_setores%rowtype;

		cursor crs_tipos is 
		select cd_questionario, ds_questionario from
		pdi_tipo_questionario
		where cd_cliente = fun.ret_var('CLIENTE');

		ws_tipo crs_tipos%rowtype;

		cursor crs_hierarquias is 
		select cd_hierarquia, nm_hierarquia from
		pdi_hierarquia
		where cd_cliente = fun.ret_var('CLIENTE');

		ws_hierarquia crs_hierarquias%rowtype;

		ws_ligacao number;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		open crs_usuarios;
		loop
		fetch crs_usuarios into ws_usuario;
		exit when crs_usuarios%notfound;
		end loop;
		close crs_usuarios;

		htp.p('<div class="cadastro" id="adicionarUsuario">');

			htp.p('<ul>');
				htp.p('<li style="display: none;">');
					htp.p('<label for="prm_cod">C&Oacute;DIGO</label>');
					htp.p('<input id="prm_cod" class="get" type="number" placeholder="" value="'||ws_usuario.cd_usuario||'"/>');
				htp.p('</li>');

				htp.p('<li>');
					
					htp.p('<ul class="horizontal">');
					    htp.p('<li>');
							htp.p('<label for="prm_nome">Nome</label>');
							htp.p('<input id="prm_nome" class="get" data-min="1" data-encode="*" value="'||ws_usuario.nm_usuario||'">');
						htp.p('</li>');

						htp.p('<li>');	
							htp.p('<label for="prm_setor">Setor</label>');
							htp.p('<select id="prm_setor" class="get" data-min="1">');
								htp.p('<option value="" hidden></option>');
								open crs_setores;
									loop
										fetch crs_setores into ws_setor;
										exit when crs_setores%notfound;
										if ws_setor.cd_setor = ws_usuario.cd_setor then 
											htp.p('<option value="'||ws_setor.cd_setor||'" title="'||ws_setor.cd_setor||'" selected>'||ws_setor.nm_setor||'</option>');
										else
											htp.p('<option value="'||ws_setor.cd_setor||'" title="'||ws_setor.cd_setor||'">'||ws_setor.nm_setor||'</option>');
										end if;
									end loop;
								close crs_setores;
							htp.p('</select>');
						htp.p('</li>');
					htp.p('</ul>');
				htp.p('</li>');

				htp.p('<li>');	
					htp.p('<ul class="horizontal">');
						htp.p('<li>');
							htp.p('<label for="prm_telefone">Telefone</label>');
							htp.p('<input id="prm_telefone" class="get" data-min="1" value="'||ws_usuario.telefone||'">');
						htp.p('</li>');
						htp.p('<li>');
							htp.p('<label for="prm_email">Email</label>');
							htp.p('<input id="prm_email" class="get" data-min="1" value="'||ws_usuario.email||'">');
						htp.p('</li>');
					htp.p('</ul>');
				htp.p('</li>');	

				htp.p('<li>');	
					htp.p('<ul class="horizontal">');
						htp.p('<li style="display: none;">');
							htp.p('<label for="prm_login">Login</label>');
							htp.p('<input id="prm_login" class="get" value="'||ws_usuario.login||'">');
						htp.p('</li>');

						htp.p('<li>');
							htp.p('<label for="prm_hierarquia">Hierarquia</label>');
							htp.p('<select id="prm_hierarquia" class="get" data-min="1">');
								htp.p('<option value="" hidden></option>');
								open crs_hierarquias;
									loop
										fetch crs_hierarquias into ws_hierarquia;
										exit when crs_hierarquias%notfound;
										if ws_usuario.cd_hierarquia = ws_hierarquia.cd_hierarquia then
										    htp.p('<option value="'||ws_hierarquia.cd_hierarquia||'" selected>'||ws_hierarquia.nm_hierarquia||'</option>');
										else
    										htp.p('<option value="'||ws_hierarquia.cd_hierarquia||'">'||ws_hierarquia.nm_hierarquia||'</option>');
										end if;
									end loop;
								close crs_hierarquias;
							htp.p('</select>');
						htp.p('</li>');
						
						htp.p('<li>');
							htp.p('<label for="prm_questionario">Texto inicial</label>');
							htp.p('<select id="prm_questionario" class="get" data-min="1">');
								htp.p('<option value="" hidden></option>');
								open crs_tipos;
									loop
										fetch crs_tipos into ws_tipo;
										exit when crs_tipos%notfound;
										if ws_usuario.cd_questionario = ws_tipo.cd_questionario then
										    htp.p('<option value="'||ws_tipo.cd_questionario||'" selected>'||ws_tipo.ds_questionario||'</option>');
										else
    										htp.p('<option value="'||ws_tipo.cd_questionario||'">'||ws_tipo.ds_questionario||'</option>');
										end if;
									end loop;
								close crs_tipos;
							htp.p('</select>');
						htp.p('</li>');
					htp.p('</ul>');
				htp.p('</li>');

				htp.p('<li>');	
					if nvl(prm_cod, 0) <> 0 then
						htp.p('<a class="addpurple">SALVAR ALTERA&Ccedil;&Otilde;ES</a>');
						htp.p('<a class="nova">CANCELAR</a>');
					else
						htp.p('<a class="addpurple">CADASTRAR USU&Aacute;RIO</a>');
					end if;
				htp.p('</li>');

			htp.p('</ul>');

		htp.p('</div>');

		/*htp.p('<div class="cadastro metade" id="adicionarRelacionamento">');
				
			if nvl(prm_cod, 0) <> 0 then
				pdi.cadastroDeRelacionamento(prm_usuario => prm_cod);
			end if;
			
		htp.p('</div>');*/

		pdi.listaDeUsuarios(prm_cod, prm_busca);

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end cadastroDeUsuario;

	procedure listaDeUsuarios ( prm_cod number default null, prm_busca varchar2 default null  ) as 

		cursor crs_usuarios is 
		select cd_usuario, nm_usuario, telefone, email, t1.cd_setor, t2.nm_setor, login
		from pdi_usuarios t1
		left join pdi_setores t2 on t2.cd_setor = t1.cd_setor and t2.cd_cliente = fun.ret_var('CLIENTE') 
		where t1.cd_cliente = fun.ret_var('CLIENTE') and nvl(tipo, 'N') <> 'A' and
		upper(trim(nm_usuario)) like ('%'||nvl(upper(trim(prm_busca)), upper(trim(nm_usuario)))||'%')
		order by nm_usuario; 

		ws_usuario crs_usuarios%rowtype;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		htp.p('<h4>LISTA DE USU&Aacute;RIOS</h4>');

		htp.p('<input type="search" id="prm_busca" class="filtro" placeholder="busca por usu&aacute;rio" value="'||prm_busca||'" />');

		htp.p('<div class="limit">');
			htp.p('<table>');
				htp.p('<thead>');
					htp.p('<tr>');
						htp.p('<th>NOME</th>');
						--htp.p('<th>LOGIN</th>');
						htp.p('<th>SETOR</th>');
						htp.p('<th>TELEFONE</th>');
						htp.p('<th>EMAIL</th>');
						htp.p('<th></th>');
					htp.p('</tr>');
				htp.p('</thead>');
				htp.p('<tbody>');
					open crs_usuarios;
						loop
							fetch crs_usuarios into ws_usuario;
							exit when crs_usuarios%notfound;
							if ws_usuario.cd_usuario = prm_cod then
								htp.p('<tr class="selected">');
							else
								htp.p('<tr>');
							end if;
								htp.p('<td>'||ws_usuario.nm_usuario||'</td>');
								--htp.p('<td>'||ws_usuario.login||'</td>');
								htp.p('<td>'||ws_usuario.nm_setor||'</td>');
								htp.p('<td>'||ws_usuario.telefone||'</td>');
								htp.p('<td>'||ws_usuario.email||'</td>');
								htp.p('<td>');
									htp.p('<a data-par="prm_cod='||ws_usuario.cd_usuario||'" data-req="cadastroDeUsuario" data-res="conteudo" class="edit">'||pdi.retornaIcone('edit')||'</a>');
									htp.p('<a data-par="prm_usuario='||ws_usuario.cd_usuario||'" data-req="cadastroDeRelacionamento" data-res="conteudo" class="edit ligacao">'||pdi.retornaIcone('ligacao')||'</a>');
									htp.p('<a data-par="prm_cod='||ws_usuario.cd_usuario||'" data-req="exclusaoDeUsuario" data-res="conteudo" class="remove">'||pdi.retornaIcone('lixo')||'</a>');
								htp.p('</td>');
							htp.p('</tr>');
						end loop;
					close crs_usuarios;
				htp.p('</tbody>');
			htp.p('</table>');
		htp.p('</div>');

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end listaDeUsuarios;

	procedure adicionarUsuario ( prm_cod          number default 0,
								 prm_nome         varchar2,
								 prm_login        varchar2,
								 prm_setor        number,
								 prm_telefone     varchar2,
								 prm_email        varchar2,
								 prm_questionario varchar2,
								 prm_hierarquia   number ) as

		ws_count    number;
		ws_usuario  number := 1;
		ws_hash     varchar2(200);

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		select nvl(max(cd_usuario), 0)+1 into ws_usuario from pdi_usuarios;

		ws_hash := pdi.generateHash(ws_usuario, prm_nome, prm_setor);

		merge into pdi_usuarios t1
			using (select prm_cod as cod, converte(prm_nome) as nome, prm_login as login, prm_hierarquia as hierarquia, prm_telefone as telefone, prm_email as email, prm_setor as setor, prm_questionario as questionario from dual) t2
			on (t1.cd_usuario = t2.cod and t1.cd_cliente = fun.ret_var('CLIENTE'))
			when matched then update 
			set t1.nm_usuario = t2.nome,
			t1.telefone = t2.telefone,
			t1.email = t2.email,
			t1.cd_setor = t2.setor,
			t1.login    = t2.login,
			t1.cd_hierarquia = t2.hierarquia,
			t1.cd_questionario = t2.questionario

			when not matched then insert (cd_usuario, nm_usuario, cd_hierarquia, telefone, email, cd_setor, login, cd_cliente, hashcode, tipo, cd_questionario) 
			values (ws_usuario, converte(prm_nome), prm_hierarquia, prm_telefone, prm_email, prm_setor, prm_login, fun.ret_var('CLIENTE'), ws_hash, 'N', prm_questionario);
		
		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Salvo com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Usuário '||ws_usuario||' salvo com sucesso!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao salvar!');
		end if;

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao adicionar o usuário '||prm_cod||' ao sistema! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
	end adicionarUsuario;

	procedure exclusaoDeUsuario ( prm_cod number ) as

		ws_count number;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		delete from pdi_usuarios where cd_usuario = prm_cod and cd_cliente = fun.ret_var('CLIENTE');

		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Removido com sucesso!');
			delete from pdi_relacionamento where cd_usuario = prm_cod and cd_cliente = fun.ret_var('CLIENTE');
			commit;
			insert into bi_log_sistema values(sysdate, 'Usuário '||prm_cod||' removido do sistema!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao remover!');
		end if;

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao remover o usuário '||prm_cod||' do sistema! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
	end exclusaoDeUsuario;


	---------- RELACIONAMENTO ----------


	procedure adicionarRelacionamento ( prm_cod 			 number default null,
										prm_usuario          number,
										prm_usuario_avaliado number,
										prm_setor            number ) as

		ws_relacionamento number;
		ws_count          number;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		select nvl(max(cd_relacionamento), 0)+1 into ws_relacionamento from pdi_relacionamento;

		merge into pdi_relacionamento t1
			using (select prm_cod as cod, prm_usuario as usuario, prm_usuario_avaliado as avaliado, prm_setor as setor from dual) t2
			on (t1.cd_relacionamento = t2.cod and t1.cd_cliente = fun.ret_var('CLIENTE'))
			when matched then update 
			set t1.cd_usuario      = t2.usuario,
			t1.cd_usuario_avaliado = t2.avaliado,
			t1.cd_setor               = t2.setor

			when not matched then insert ( cd_relacionamento, cd_usuario, cd_usuario_avaliado, cd_setor, cd_cliente ) 
			values ( ws_relacionamento, prm_usuario, prm_usuario_avaliado, prm_setor, fun.ret_var('CLIENTE') );

		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Adicionado com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Relacionamento #'||prm_cod||' adicionado ao sistema!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao adicionar!');
		end if;

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao adicionar o relacionamento #'||prm_cod||'! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
	end adicionarRelacionamento;

	procedure exclusaoDeRelacionamento ( prm_cod number ) as

		ws_count number;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		delete from pdi_relacionamento where cd_relacionamento = prm_cod and cd_cliente = fun.ret_var('CLIENTE');

		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Removido com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Relacionamento #'||prm_cod||' removido do sistema!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao remover!');
		end if;

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao excluir o relacionamento #'||prm_cod||'! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
	end exclusaoDeRelacionamento;


	procedure cadastroDeRelacionamento ( prm_usuario number, 
										 prm_cod     number default null, 
										 prm_busca   varchar2 default null ) as

		cursor crs_lista_usuarios is 
		select cd_usuario, nm_usuario
		from pdi_usuarios
		where 
		--não avalia a si msm, regra foi comentada para autoavaliação
		--cd_usuario <> prm_usuario and
		--não lista que já existe
		cd_usuario not in (select cd_usuario_avaliado from pdi_relacionamento where (cd_usuario = prm_usuario and cd_relacionamento <> nvl(prm_cod, 0)) and cd_cliente = fun.ret_var('CLIENTE')) and
		cd_cliente = fun.ret_var('CLIENTE') and nvl(tipo, 'N') <> 'A' 
		order by nm_usuario; 

		ws_lista_usuario crs_lista_usuarios%rowtype;

		cursor crs_setores is
		select cd_setor, nm_setor
		from pdi_setores
		where cd_cliente = fun.ret_var('CLIENTE')
		order by nm_setor;

		ws_setor crs_setores%rowtype;

		cursor crs_relacionamentos is
		select t1.cd_relacionamento, t1.cd_usuario, t1.cd_usuario_avaliado, t1.cd_setor/*, t2.nm_usuario, t3.nm_setor*/
		from pdi_relacionamento t1
		/*left join pdi_usuarios t2 on t2.cd_usuario = t1.cd_usuario_avaliado and t2.cd_cliente = fun.ret_var('CLIENTE')
		left join pdi_setores t3 on t3.cd_setor = t1.cd_setor*/
		where t1.cd_relacionamento = prm_cod  and
		t1.cd_cliente = fun.ret_var('CLIENTE')
		order by t1.cd_setor;

		ws_relacionamento crs_relacionamentos%rowtype;

		ws_usuario  varchar2(80);
		ws_selected varchar2(80) := '';

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		open crs_relacionamentos;
			loop
				fetch crs_relacionamentos into ws_relacionamento;
				exit when crs_relacionamentos%notfound;
			end loop;
		close crs_relacionamentos;

		select nm_usuario into ws_usuario from pdi_usuarios where cd_usuario = prm_usuario and cd_cliente = fun.ret_var('CLIENTE');

		if nvl(prm_cod, 0) = 0 then
		    htp.p('<div class="cadastro" id="adicionarRelacionamento">');
		end if;

			htp.p('<ul>');
			
				htp.p('<li class="align">');
					htp.prn('<span style="margin: 0 0 0 14px;"><strong>'||ws_usuario||'</strong> vai avaliar o usu&aacute;rio </span>');

					htp.p('<input type="hidden" class="get" id="prm_cod" value="'||prm_cod||'"/>');

					htp.p('<input type="hidden" class="get" id="prm_usuario" value="'||prm_usuario||'"/>');

					htp.prn('<select class="get" id="prm_usuario_avaliado" data-min="1">');
						open crs_lista_usuarios;
							loop
								fetch crs_lista_usuarios into ws_lista_usuario;
								exit when crs_lista_usuarios%notfound;

								if ws_lista_usuario.cd_usuario = ws_relacionamento.cd_usuario_avaliado then
									ws_selected := 'selected';
								else
									ws_selected := '';
								end if;
								
								if ws_lista_usuario.cd_usuario = prm_usuario then
									htp.p('<option value="'||ws_lista_usuario.cd_usuario||'" '||ws_selected||'>'||ws_lista_usuario.nm_usuario||' (autoavalia&ccedil;&atilde;o)</option>');
								else
									htp.p('<option value="'||ws_lista_usuario.cd_usuario||'" '||ws_selected||'>'||ws_lista_usuario.nm_usuario||'</option>');
								end if;
							end loop;
						close crs_lista_usuarios;
					htp.prn('</select>');

					htp.prn('<span> usando a avalia&ccedil;&atilde;o de  </span>');

					htp.prn('<select class="get" id="prm_setor" data-min="1">');
						htp.p('<option value="" hidden></option>');
							open crs_setores;
								loop
									fetch crs_setores into ws_setor;
									exit when crs_setores%notfound;
										if ws_setor.cd_setor = ws_relacionamento.cd_setor then
											htp.p('<option selected value="'||ws_setor.cd_setor||'" title="'||ws_setor.cd_setor||'">'||ws_setor.nm_setor||'</option>');
										else
											htp.p('<option value="'||ws_setor.cd_setor||'" title="'||ws_setor.cd_setor||'">'||ws_setor.nm_setor||'</option>');
										end if;
								end loop;
							close crs_setores;
					htp.prn('</select>');
					
					if nvl(prm_cod, 0) <> 0 then
						htp.p('<a class="addpurple small">SALVAR</a>');
					else
						htp.p('<a class="addpurple small">ADICIONAR</a>');
					end if;
				htp.p('</li>');
			
				htp.p('<li>');
					pdi.listaDeRelacionamento(prm_cod, prm_usuario);
				htp.p('</li>');

			htp.p('</ul>');
		
		if nvl(prm_cod, 0) = 0 then
			htp.p('</div>');
		end if;

		if nvl(prm_cod, 0) = 0 then
		    pdi.listaDeUsuarios(prm_usuario);
		end if;

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end cadastroDeRelacionamento;


	procedure listaDeRelacionamento ( prm_cod number default null, prm_usuario number ) as

		cursor crs_relacionamentos is
		select t1.cd_relacionamento, t1.cd_usuario, t1.cd_usuario_avaliado, t1.cd_setor, t2.nm_usuario, t3.nm_setor
		from pdi_relacionamento t1
		left join pdi_usuarios t2 on t2.cd_usuario = t1.cd_usuario_avaliado and t2.cd_cliente = fun.ret_var('CLIENTE')
		left join pdi_setores t3 on t3.cd_setor = t1.cd_setor
		where t1.cd_usuario = prm_usuario  and
		t1.cd_cliente = fun.ret_var('CLIENTE')
		order by t1.cd_setor, t2.nm_usuario;

		ws_relacionamento crs_relacionamentos%rowtype;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		htp.p('<table>');
			htp.p('<thead>');
				htp.p('<tr>');
					htp.p('<th>USU&Aacute;RIO AVALIADO</th>');
					htp.p('<th>TIPO DE AVALIA&Ccedil;&Atilde;O (SETOR)</th>');
					htp.p('<th></th>');
				htp.p('</tr>');
			htp.p('</thead>');
			htp.p('<tbody>');
				open crs_relacionamentos;
					loop
						fetch crs_relacionamentos into ws_relacionamento;
						exit when crs_relacionamentos%notfound;
						if ws_relacionamento.cd_relacionamento = prm_cod then
							htp.p('<tr class="selected">');
						else
							htp.p('<tr>');
						end if;
							htp.p('<td>'||ws_relacionamento.nm_usuario||'</td>');
							htp.p('<td>'||ws_relacionamento.nm_setor||'</td>');
							htp.p('<td>');
								htp.p('<a data-par="prm_usuario='||ws_relacionamento.cd_usuario||'&prm_cod='||ws_relacionamento.cd_relacionamento||'" data-req="cadastroDeRelacionamento" data-res="adicionarRelacionamento" data-res-par="prm_usuario='||ws_relacionamento.cd_usuario||'" class="edit">'||pdi.retornaIcone('edit')||'</a>');
								htp.p('<a data-par="prm_cod='||ws_relacionamento.cd_relacionamento||'" data-req="exclusaoDeRelacionamento" data-res="adicionarRelacionamento" class="remove">'||pdi.retornaIcone('lixo')||'</a>');
							htp.p('</td>');
						htp.p('</tr>');
					end loop;
				close crs_relacionamentos;
			htp.p('</tbody>');
		htp.p('</table>');

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end listaDeRelacionamento;


	---------- QUESTIONARIO ----------


	procedure avaliacao ( prm_avaliado number default null ) as 

		ws_enviada	   number;
		ws_total       number;
		ws_categoria   varchar2(80);
		ws_usuario     varchar2(80);
		ws_avaliador   varchar2(80);
		ws_cd_usuario  number;
		ws_avaliado    number;
		ws_tipo        varchar2(10);
	
	begin

		ws_cd_usuario := retornaUsuario;

		ws_avaliado := prm_avaliado;

	    select nm_usuario, tipo into ws_usuario, ws_tipo from pdi_usuarios where cd_usuario = prm_avaliado and cd_cliente = fun.ret_var('CLIENTE');

		select nm_usuario into ws_avaliador from pdi_usuarios where cd_usuario = ws_cd_usuario and cd_cliente = fun.ret_var('CLIENTE');

		if ws_tipo = 'A' then
		    ws_avaliado := 1;
		end if;
		
		if nvl(ws_avaliado, 0) <> 0 then

			htp.p('<input type="hidden" id="avaliado" value="'||ws_avaliado||'" />');

			htp.p('<div id="menu-final">');	
				htp.p('<span>Analisando o perfil do(a) profissional '||ws_usuario||'</span>');
				htp.p('<span>Logado como: '||ws_avaliador||'</span>');
				htp.p('<a id="home"><svg version="1.1" id="Layer_1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="480px" height="480px" viewBox="0 0 480 480" enable-background="new 0 0 480 480" xml:space="preserve"> <g> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5C5CC0" d="M5.692,241.825c15.618-13.652,31.299-27.239,46.863-40.956 C115.261,145.683,177.94,90.463,240.629,35.254c1.145-0.999,2.326-1.912,3.723-3.072c7.711,6.971,15.295,13.791,22.856,20.644 c68.807,62.352,137.613,124.692,206.42,187.033c0.43,0.408,0.967,0.709,1.461,1.042c0,0.312,0,0.612,0,0.924 c-12.105,12.577-23.157,14.629-38.926,6.434c-5.907-3.051-11.621-6.831-16.584-11.235 c-57.41-51.245-114.649-102.673-171.92-154.047c-1.031-0.913-2.105-1.762-3.479-2.932c-7.954,6.703-15.859,13.373-23.754,20.053 c-55.499,46.928-110.976,93.876-166.475,140.771c-2.782,2.363-5.688,4.64-8.754,6.616c-15.972,10.215-26.917,8.851-39.505-4.747 C5.692,242.427,5.692,242.137,5.692,241.825z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5C5CC0" d="M242.869,110.581c15.381,13.662,30.547,27.153,45.713,40.633 c37.895,33.705,75.768,67.432,113.726,101.04c2.771,2.449,3.889,4.855,3.889,8.572c-0.129,56.68-0.064,113.338-0.15,170.019 c0,3.147-0.451,6.401-1.311,9.441c-1.139,4.038-4.296,6.165-8.378,6.82c-1.504,0.247-3.04,0.279-4.555,0.279 c-36.819,0.011-73.64,0.011-110.438,0c-0.924,0-1.825-0.097-3.479-0.183c0-1.783,0-3.545,0-5.284 c0.043-29.646,0.086-59.28,0.107-88.903c0-11.966-4.49-17.519-16.434-17.884c-17.229-0.526-34.517-0.258-51.756,0.15 c-7.067,0.172-10.967,4.64-11.729,11.687c-0.183,1.664-0.172,3.351-0.183,5.026c-0.097,30.247-0.182,60.493-0.279,90.739 c0,1.504,0,3.008,0,5.124c-2.083,0-3.716,0-5.349,0c-36.498,0.043-73.017,0.097-109.504,0.129 c-10.221,0.011-13.158-2.879-13.158-13.028c-0.021-58.356-0.043-116.701,0.086-175.057c0.011-2.105,0.956-4.952,2.481-6.23 c56.208-47.313,112.522-94.478,168.826-141.651C241.456,111.623,241.967,111.269,242.869,110.581z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5C5CC0" d="M419.343,174.382c-7.282-6.176-14.006-11.869-20.729-17.572 c-7.455-6.305-14.973-12.535-22.299-18.99c-1.32-1.149-2.643-3.169-2.664-4.813c-0.236-17.229-0.193-34.468-0.215-51.696 c0-0.43,0.193-0.859,0.365-1.514c15.081,0,30.118,0,45.542,0C419.343,111.064,419.343,142.331,419.343,174.382z"/> </g> </svg></a>');
			htp.p('</div>');

			/*select categoria into ws_categoria from (select categoria, rownum as linha from (select distinct tp_categoria as categoria from pdi_pergunta where
			cd_pergunta not in (select cd_pergunta from pdi_avaliacao where cd_usuario = ws_avaliado and cd_cliente = fun.ret_var('CLIENTE')) and
			cd_cliente = fun.ret_var('CLIENTE'))) where linha = 1;*/

			select count(*)+1 into ws_enviada from pdi_pergunta where 
			(select cd_setor from pdi_relacionamento where cd_usuario_avaliado = ws_avaliado and cd_usuario = pdi.retornaUsuario and cd_cliente = fun.ret_var('CLIENTE'))
			in (select to_number(column_value) from table(fun.vpipe(cd_setores))) and
			cd_pergunta in (select cd_pergunta from pdi_avaliacao where cd_usuario_avaliado = ws_avaliado and cd_usuario = pdi.retornaUsuario and cd_cliente = fun.ret_var('CLIENTE')) and
			--tp_categoria = ws_categoria and
			cd_cliente = fun.ret_var('CLIENTE');

			select count(*) into ws_total from pdi_pergunta where 
			(select cd_setor from pdi_relacionamento where cd_usuario_avaliado = ws_avaliado and cd_usuario = pdi.retornaUsuario and cd_cliente = fun.ret_var('CLIENTE'))
			in (select to_number(column_value) from table(fun.vpipe(cd_setores))) and
			--tp_categoria = ws_categoria and
			cd_cliente = fun.ret_var('CLIENTE');

			if ws_enviada = 1 then
				pdi.preAvaliacao(ws_avaliado);
			end if;

			--pdi.progresso(ws_enviada, ws_total );
			pdi.questoes(ws_avaliado);
			--pdi.questao(ws_avaliado, 1);
			--pdi.questao(ws_avaliado, 2, 'next');

		end if;
		
	exception when others then
		htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end avaliacao;

	procedure preAvaliacao ( prm_usuario varchar2 ) as

	begin

		htp.p('<div id="curtain">');
			htp.p('<div>');
				pdi.retornaHtml('titulo', prm_usuario);

				pdi.retornaHtml('principal', prm_usuario);

				htp.p('<a class="addpurple" onclick="this.parentNode.parentNode.classList.add(''close'');">COME&Ccedil;AR!!!</a>');
			htp.p('</div>');
		htp.p('</div>');

	end preAvaliacao;

	procedure menuDeAvaliacoes ( prm_avaliado number default null ) as 

		cursor crs_informacoes is
		select count(*) as avaliacoes,
		sum(case 
		when respondidas-perguntas = 0 and perguntas > 0 then 1
		else 0 end) avaliadas,
		sum(case 
		when respondidas-perguntas <> 0 or perguntas = 0 then 1
		else 0 end) as falta_avaliar,
		sum(case 
		when respondidas > 0 and respondidas-perguntas <> 0 then 1 
		else 0 end) as andamento,
		sum(case 
		when respondidas = 0 then 1 
		else 0 end) as nao_iniciada
		from(
		select t1.cd_usuario_avaliado as avaliado, count(t2.cd_pergunta) as perguntas, count(t3.cd_avaliacao) as respondidas from pdi_relacionamento t1
		left join pdi_pergunta t2 on t1.cd_setor in (select to_number(column_value) from table(fun.vpipe(t2.cd_setores))) and t2.cd_cliente = fun.ret_var('CLIENTE')
		left join pdi_avaliacao t3 on t3.cd_usuario = 1 and t3.cd_usuario_avaliado = t1.cd_usuario_avaliado and t3.cd_pergunta = t2.cd_pergunta and t2.cd_cliente = fun.ret_var('CLIENTE')
		where t1.cd_usuario = 1 and t1.cd_cliente = fun.ret_var('CLIENTE')
		group by t1.cd_usuario_avaliado);

		ws_informacao crs_informacoes%rowtype;
		
		ws_setor         varchar2(80) := 'N/A';
		ws_avaliacoes    number := 0;
		ws_falta         number;
		ws_avaliar       number;
		ws_andamento     number;
		ws_nao_iniciada  number;
		ws_count         number;

	begin

		open crs_informacoes;
			loop
				fetch crs_informacoes into ws_informacao;
				exit when crs_informacoes%notfound;
			end loop;
		close crs_informacoes;

		ws_count := 0;

		htp.p('<div id="menudeavaliacoes">');
			htp.p('<div>');
				htp.p('<span class="titulo">Avalia&ccedil;&otilde;es dispon&iacute;veis</span>');
				for i in (
					select t1.cd_relacionamento, t1.cd_usuario, t1.cd_usuario_avaliado, t1.cd_setor, t2.nm_usuario, t3.nm_setor
					from pdi_relacionamento t1
					left join pdi_usuarios t2 on t2.cd_usuario = t1.cd_usuario_avaliado and t2.cd_cliente = fun.ret_var('CLIENTE')
					left join pdi_setores t3 on t3.cd_setor = t1.cd_setor
					where t1.cd_usuario = pdi.retornaUsuario  and
					t1.cd_cliente = fun.ret_var('CLIENTE')
					order by t1.cd_setor, t2.nm_usuario
				) loop
					ws_avaliacoes := ws_avaliacoes+1;
					
					if ws_setor <> i.nm_setor then
						select count(*) into ws_count from pdi_relacionamento where cd_usuario = pdi.retornaUsuario and cd_usuario_avaliado = prm_avaliado and cd_setor = i.cd_setor and cd_cliente = fun.ret_var('CLIENTE');
						htp.p('</ul>');
						
						if ws_count > 0 then
							htp.p('<ul class="opcoes selected">');
						else
							htp.p('<ul class="opcoes">');
						end if;

						htp.p('<li class="setor"><a>'||i.nm_setor||'</a></li>');
						
						ws_setor := i.nm_setor;
					end if;

					if prm_avaliado = i.cd_usuario_avaliado then
						htp.p('<li class="nome selected">');
					else
						htp.p('<li class="nome">');
					end if;
						htp.p('<a title="'||i.cd_usuario_avaliado||'">'||i.nm_usuario||'</a>');
					htp.p('</li>');
					ws_count := 0;
				end loop;	
				htp.p('</ul>');
			htp.p('</div>');

			htp.p('<div>');
				htp.p('<ul id="situacoes">');
					htp.p('<li class="total">AVALIA&Ccedil;&Otilde;ES: '||ws_informacao.avaliacoes||'</li>');
					htp.p('<li class="avaliados">AVALIADOS: '||ws_informacao.avaliadas||'</li>');
					htp.p('<li class="falta">FALTA AVALIAR: '||ws_informacao.falta_avaliar||'</li>');
					htp.p('<li>EM ANDAMENTO: '||ws_informacao.andamento||'</li>');
					htp.p('<li class="naoiniciada">N&Atilde;O INICIADA: '||ws_informacao.nao_iniciada||'</li>');
				htp.p('</ul>');
			htp.p('</div>');
		htp.p('</div>');

	end menuDeAvaliacoes;

	procedure questao ( prm_avaliado number,
						prm_cod number default null, 
						prm_class varchar2 default null ) as

		cursor crs_perguntas is 
		select cd_pergunta, ds_pergunta, tp_categoria, justificativa, tp_formato, ds_categoria, nm_categoria, ti_categoria from (
			select cd_pergunta, ds_pergunta, tp_categoria, justificativa, tp_formato, ds_categoria, nm_categoria, ti_categoria, rownum as linha from (
				select cd_pergunta, ds_pergunta, tp_categoria, justificativa, tp_formato,
				ds_categoria, nm_categoria, ti_categoria, ordem
				from pdi_pergunta t1
				left join pdi_categorias t2 on tp_categoria = nm_categoria and t2.cd_cliente = fun.ret_var('CLIENTE')
				where /*cd_pergunta = nvl(prm_cod, 1) and*/
				(select cd_setor from pdi_relacionamento where cd_usuario_avaliado = prm_avaliado and cd_usuario = pdi.retornaUsuario and cd_cliente = fun.ret_var('CLIENTE'))
				in (select to_number(column_value) from table(fun.vpipe(cd_setores))) and
				cd_pergunta not in (
					select cd_pergunta from pdi_avaliacao where cd_usuario_avaliado = prm_avaliado and cd_usuario = pdi.retornaUsuario and cd_cliente = fun.ret_var('CLIENTE')
				) /*and
				tp_categoria in (
					select categoria from (select categoria, rownum as linha from (select distinct tp_categoria as categoria from pdi_pergunta where
					cd_pergunta not in (select cd_pergunta from pdi_avaliacao where cd_usuario_avaliado = prm_avaliado and cd_usuario = pdi.retornaUsuario and cd_cliente = fun.ret_var('CLIENTE')) and
					cd_cliente = fun.ret_var('CLIENTE'))) where linha = 1
				)*/
				and
				t1.cd_cliente = fun.ret_var('CLIENTE')
				order by tp_categoria, ordem asc, cd_pergunta asc) 
		) where linha = nvl(prm_cod, 1);

		ws_pergunta crs_perguntas%rowtype;

		ws_usuario     varchar2(80);
		ws_teste_valor number;

	begin

		open crs_perguntas;
		loop
		fetch crs_perguntas into ws_pergunta;
		exit when crs_perguntas%notfound;
		end loop;
		close crs_perguntas;

		--testa se perguntas em aberto do usuário escolhido
		if nvl(ws_pergunta.cd_pergunta, 0) = 0 then

			htp.p('<div class="questao '||prm_class||'">');
				htp.p('<div class="concluida">');
					pdi.retornaHtml('logo', ws_usuario);
					pdi.retornaHtml('avaliado', ws_usuario);
					--htp.p('<h4>Nenhuma pergunta em aberto, usu&aacute;rio avaliado com sucesso!</h4>');
				htp.p('</div>');
			htp.p('</div>');

		else

			--htp.p('<h4>AVALIANDO O USU&Aacute;RIO '||upper(ws_usuario)||'</h4>');

			htp.p('<div class="questao '||prm_class||'">');

				htp.p('<h4>'||ws_pergunta.ti_categoria||' <a class="opendesc">?</a></h4>');

				htp.p('<span class="desc invisible">'||ws_pergunta.ds_categoria||'</span>');

				htp.p('<div class="avaliacao" title="'||ws_pergunta.cd_pergunta||'">');
				
					htp.p('<span class="pergunta">'||ws_pergunta.ds_pergunta||'</span>');
					
					select sum(vl_formato) into ws_teste_valor from pdi_formato_perguntas where tp_formato = ws_pergunta.tp_formato and cd_cliente = fun.ret_var('CLIENTE');

					--verifica se tem opções
					if nvl(ws_teste_valor, 0) <> 0 then

						htp.p('<ul class="opcoes">');
						
							for i in (select tp_formato, cd_formato, ds_formato, vl_formato from pdi_formato_perguntas where tp_formato = ws_pergunta.tp_formato and cd_cliente = fun.ret_var('CLIENTE') order by vl_formato) loop
								htp.p('<li>');
									htp.p('<input name="'||ws_pergunta.cd_pergunta||'" type="radio" value="'||i.vl_formato||'" id="'||ws_pergunta.cd_pergunta||'_'||i.cd_formato||'" />');
									htp.p('<label for="'||ws_pergunta.cd_pergunta||'_'||i.cd_formato||'">'||i.ds_formato||'</label>');
								htp.p('</li>');
							end loop;
						
						htp.p('</ul>');

					end if;

					--verifica se tem justificativa
					if ws_pergunta.justificativa = 'S' then
						htp.p('<div class="justificativa">');
							htp.p('<label for="'||ws_pergunta.cd_pergunta||'_justificativa">Justificativa:</label>');
							htp.p('<textarea id="'||ws_pergunta.cd_pergunta||'_justificativa"></textarea>');
						htp.p('</div>');
					end if;

					htp.p('<a class="addpurple">PR&Oacute;XIMA PERGUNTA</a>');

					--var bar1 = new ldBar(document.querySelector('.ldBar'));
					--bar1.set(80);
					--htp.p('<div class="ldBar" data-type="fill" data-preset="stripe" data-value="0"></div>');

				htp.p('</div>');

			htp.p('</div>');

		end if;

	exception when others then
		htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end questao;

	procedure questoes ( prm_avaliado number, 
						 prm_class    varchar2 default null ) as

		cursor crs_perguntas is 
		select cd_pergunta, ds_pergunta, tp_categoria, justificativa, tp_formato, ds_categoria, nm_categoria, ti_categoria, vl_justificativa, vl_avaliacao, rownum as linha from (
			select t1.cd_pergunta, t1.ds_pergunta, tp_categoria, t1.justificativa as justificativa, tp_formato,
			ds_categoria, nm_categoria, ti_categoria, t1.ordem,
			t3.justificativa as vl_justificativa, vl_avaliacao
			from pdi_pergunta t1
			left join pdi_categorias t2 on tp_categoria = nm_categoria and t2.cd_cliente = fun.ret_var('CLIENTE')
			left join pdi_avaliacao t3 on t3.cd_usuario_avaliado = prm_avaliado and t3.cd_usuario = pdi.retornaUsuario and t3.cd_cliente = fun.ret_var('CLIENTE') and t3.cd_pergunta = t1.cd_pergunta
			where 
			(select cd_setor from pdi_relacionamento where cd_usuario_avaliado = prm_avaliado and cd_usuario = pdi.retornaUsuario and cd_cliente = fun.ret_var('CLIENTE'))
			in (select to_number(column_value) from table(fun.vpipe(cd_setores))) and
			/*cd_pergunta not in (
				select cd_pergunta from pdi_avaliacao where cd_usuario_avaliado = prm_avaliado and cd_usuario = pdi.retornaUsuario and cd_cliente = fun.ret_var('CLIENTE')
			) 
			and*/
			t1.cd_cliente = fun.ret_var('CLIENTE')
			order by tp_categoria, ordem asc, cd_pergunta asc
		);

		ws_pergunta crs_perguntas%rowtype;

		ws_usuario     varchar2(80);
		ws_teste_valor number;
		ws_categoria   varchar2(80) := 'N/A';
		ws_salvo       varchar2(20) := 'N';

	begin

		open crs_perguntas;
		loop
		fetch crs_perguntas into ws_pergunta;
		exit when crs_perguntas%notfound;

			if nvl(ws_pergunta.vl_avaliacao, 999) <> 999 or nvl(ws_pergunta.vl_justificativa, 'N/A') <> 'N/A' then
				ws_salvo := 'salvo';
			else
				ws_salvo := '';
			end if;

		
			htp.p('<div class="questao '||prm_class||'">');

				if ws_pergunta.ti_categoria <> ws_categoria then
					htp.p('<h4>'||ws_pergunta.ti_categoria||' <a class="opendesc">?</a></h4>');
					ws_categoria := ws_pergunta.ti_categoria;
				end if;

				htp.p('<span class="desc invisible">'||ws_pergunta.ds_categoria||'</span>');

				htp.p('<div class="avaliacao '||ws_salvo||'" title="'||ws_pergunta.cd_pergunta||'">');

					htp.p('<img class="check" src="dwu.fcl.download?arquivo=pdi_check.png" />');
				
					htp.p('<span class="pergunta">'||ws_pergunta.ds_pergunta||'</span>');
										
					select sum(vl_formato) into ws_teste_valor from pdi_formato_perguntas where tp_formato = ws_pergunta.tp_formato and cd_cliente = fun.ret_var('CLIENTE');

					--verifica se tem opções
					if nvl(ws_teste_valor, 0) <> 0 then

						htp.p('<ul class="opcoes">');
						
							for i in (select tp_formato, cd_formato, ds_formato, vl_formato from pdi_formato_perguntas where tp_formato = ws_pergunta.tp_formato and cd_cliente = fun.ret_var('CLIENTE') order by vl_formato) loop
								htp.p('<li>');
									if ws_pergunta.vl_avaliacao = i.vl_formato then
										htp.p('<input checked name="'||ws_pergunta.cd_pergunta||'" type="radio" value="'||i.vl_formato||'" id="'||ws_pergunta.cd_pergunta||'_'||i.cd_formato||'" />');
									else	
										htp.p('<input name="'||ws_pergunta.cd_pergunta||'" type="radio" value="'||i.vl_formato||'" id="'||ws_pergunta.cd_pergunta||'_'||i.cd_formato||'" />');
									end if;
									htp.p('<label for="'||ws_pergunta.cd_pergunta||'_'||i.cd_formato||'">'||i.ds_formato||'</label>');
								htp.p('</li>');
							end loop;
						
						htp.p('</ul>');

					end if;

					--verifica se tem justificativa
					if ws_pergunta.justificativa = 'S' then
						htp.p('<div class="justificativa">');
							htp.p('<label for="'||ws_pergunta.cd_pergunta||'_justificativa">Justificativa:</label>');
							htp.p('<textarea id="'||ws_pergunta.cd_pergunta||'_justificativa">'||ws_pergunta.vl_justificativa||'</textarea>');
						htp.p('</div>');
					end if;

					htp.p('<a class="addpurple '||ws_salvo||'"></a>');

				htp.p('</div>');

			htp.p('</div>');

		end loop;
		close crs_perguntas;

	exception when others then
		htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end questoes;

	procedure progresso ( prm_enviada number, prm_total number ) as

		ws_pct       number;
		ws_progresso number;

	begin
		
		begin
			ws_pct := 100/(prm_total-1);
			ws_progresso := ws_pct*(prm_enviada-1);
		exception when others then
			ws_pct       := 0;
			ws_progresso := 0;
		end;

		htp.p('<div id="progresso" title="'||prm_total||'">');
					
			htp.p('<ul>');

				for i in 1..prm_total loop
					if prm_enviada >= i then
						if prm_enviada = i then
							htp.p('<li class="preenchida current">'||trim(to_char(i, '900'))||'</li>');
						else
							htp.p('<li class="preenchida">'||trim(to_char(i, '900'))||'</li>');
						end if;
					else
						htp.p('<li>'||trim(to_char(i, '900'))||'</li>');
					end if;
				end loop;

			htp.p('</ul>');

			htp.p('<span id="linha"><span id="andamento" data-parte="'||ws_pct||'" data-atual="'||ws_progresso||'" style="width: '||ws_progresso||'%;"></span></span>');

		htp.p('</div>');

	end progresso;


	procedure adicionarAvaliacao ( prm_avaliado     number,
								   prm_pergunta     number,
								   prm_valor        number,
								   prm_justificativa varchar2 default null
								 ) as

		ws_avaliacao number;
		ws_count     number;
		ws_usuario   number;
		ws_semacesso exception;

	begin

		select nvl(max(cd_avaliacao), 0)+1 into ws_avaliacao from pdi_avaliacao;

		ws_usuario := pdi.retornaUsuario;

		if ws_usuario = 0 then
			raise ws_semacesso;
		end if;

		--adicionar cd_usuario_avaliado
		insert into pdi_avaliacao ( cd_avaliacao, cd_usuario, cd_usuario_avaliado, cd_pergunta, justificativa, vl_avaliacao, cd_cliente)
		values ( ws_avaliacao, ws_usuario, prm_avaliado, prm_pergunta, converte(prm_justificativa), prm_valor, fun.ret_var('CLIENTE'));

		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Enviada com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Avaliação #'||ws_avaliacao||' enviada com sucesso!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao enviar!');
		end if;
	exception
		when ws_semacesso then
			rollback;
			htp.p('Erro ao enviar! Sem acesso ou sessão!');
			insert into bi_log_sistema values(sysdate, 'Erro ao avaliar #'||ws_avaliacao||'! Sessão do usuário caiu antes de enviar', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
		when others then
		rollback;
		htp.p('Erro ao enviar!');
		insert into bi_log_sistema values(sysdate, 'Erro ao avaliar #'||ws_avaliacao||'! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        commit;
	end adicionarAvaliacao;


	procedure updateAvaliacao ( prm_avaliado     number,
								prm_pergunta     number,
								prm_valor        number,
								prm_justificativa varchar2 default null
							  ) as

		ws_avaliacao number;
		ws_count     number;
		ws_usuario   number;
		ws_semacesso exception;

	begin

		select nvl(max(cd_avaliacao), 0)+1 into ws_avaliacao from pdi_avaliacao;

		ws_usuario := pdi.retornaUsuario;

		if ws_usuario = 0 then
			raise ws_semacesso;
		end if;

		merge into pdi_avaliacao t1
			using (select prm_valor as valor, prm_justificativa as justificativa from dual) t2
			on (t1.cd_pergunta = prm_pergunta and t1.cd_cliente = fun.ret_var('CLIENTE') and t1.cd_usuario_avaliado = prm_avaliado and t1.cd_usuario = ws_usuario)
			when matched then update 
			set t1.justificativa = t2.justificativa, 
			t1.vl_avaliacao      = valor

			when not matched then insert ( cd_avaliacao, cd_usuario, cd_usuario_avaliado, cd_pergunta, justificativa, vl_avaliacao, cd_cliente ) 
			values ( ws_avaliacao, ws_usuario, prm_avaliado, prm_pergunta, converte(prm_justificativa), prm_valor, fun.ret_var('CLIENTE') );

		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Salvo com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Avaliação #'||ws_avaliacao||' salva com sucesso!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao salvar!');
		end if;

	exception
		when ws_semacesso then
			rollback;
			htp.p('Erro ao salvar! Sem acesso ou sessão!');
			insert into bi_log_sistema values(sysdate, 'Erro ao salvar #'||ws_avaliacao||'! Sessão do usuário caiu antes de enviar', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
		when others then
		rollback;
		htp.p('Erro ao enviar!');
		insert into bi_log_sistema values(sysdate, 'Erro ao salvar #'||ws_avaliacao||'! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        commit;
	end updateAvaliacao;


	---------- AVALIAÇÃO DE JUSTIFICATIVA --------------


	procedure listaDeJustificativa as 

		cursor crs_justificativas(prm_condicao varchar2) is 
		select t1.cd_avaliacao, t1.cd_pergunta, t1.justificativa, t2.justificativa as st_justificativa, ds_pergunta, t3.st_thumb as thumb
		from pdi_avaliacao t1
		left join pdi_pergunta t2 on t2.cd_pergunta = t1.cd_pergunta and t2.justificativa = 'S' and t2.cd_cliente = fun.ret_var('CLIENTE')
		left join pdi_justificativa t3 on t3.cd_avaliacao = t1.cd_avaliacao and t1.cd_cliente = fun.ret_var('CLIENTE')
		where t1.cd_cliente = fun.ret_var('CLIENTE') and decode(t3.st_thumb, 'UP', 'S', 'DOWN', 'S', 'NEUTRAL', 'S', 'N') = prm_condicao and t1.justificativa is not null;

		ws_justificativa crs_justificativas%rowtype;

		ws_selected varchar2(40) := '';

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		htp.p('<h4>JUSTIFICATIVAS N&Atilde;O AVALIADAS</h4>');

		htp.p('<div class="limit">');	
			htp.p('<table>');
				htp.p('<thead>');
					htp.p('<tr>');
						--htp.p('<th>TIPO</th>');
						htp.p('<th>PERGUNTA</th>');
						htp.p('<th>AVALIA&Ccedil;&Atilde;O</th>');
						htp.p('<th></th>');
					htp.p('</tr>');
				htp.p('</thead>');
				htp.p('<tbody>');
					open crs_justificativas('N');
						loop
							fetch crs_justificativas into ws_justificativa;
							exit when crs_justificativas%notfound;
							htp.p('<tr>');
								--htp.p('<td>'||ws_justificativa.cd_avaliacao||'</td>');
								htp.p('<td>'||ws_justificativa.ds_pergunta||'</td>');
								htp.p('<td style="text-align: right;">'||ws_justificativa.justificativa||'</td>');
								htp.p('<td style="width: 104px;">');
									htp.p('<a class="thumb" data-par="prm_cod='||ws_justificativa.cd_avaliacao||'&prm_thumb=UP" data-req="adicionarJustificativa" data-res="listaDeJustificativa"><img src="dwu.fcl.download?arquivo=thumbs-up.png" /></a>');
									--htp.p('<a class="thumb neutral" data-par="prm_cod='||ws_justificativa.cd_avaliacao||'&prm_thumb=NEUTRAL" data-req="adicionarJustificativa" data-res="listaDeJustificativa"><span></span></a>');
									htp.p('<a class="thumb neutral" data-par="prm_cod='||ws_justificativa.cd_avaliacao||'&prm_thumb=NEUTRAL" data-req="adicionarJustificativa" data-res="listaDeJustificativa"><img src="dwu.fcl.download?arquivo=full-moon.png" /></a>');
									htp.p('<a class="thumb down" data-par="prm_cod='||ws_justificativa.cd_avaliacao||'&prm_thumb=DOWN" data-req="adicionarJustificativa" data-res="listaDeJustificativa"><img src="dwu.fcl.download?arquivo=thumbs-up.png" /></a>');
								htp.p('</td>');

								ws_selected := '';

							htp.p('</tr>');
						end loop;
					close crs_justificativas;
				htp.p('</tbody>');
			htp.p('</table>');
		htp.p('</div>');

		htp.p('<h4>JUSTIFICATIVAS AVALIADAS</h4>');

		htp.p('<div class="limit">');
			htp.p('<table>');
				htp.p('<thead>');
					htp.p('<tr>');
						--htp.p('<th>TIPO</th>');
						htp.p('<th>PERGUNTA</th>');
						htp.p('<th>AVALIA&Ccedil;&Atilde;O</th>');
						htp.p('<th></th>');
					htp.p('</tr>');
				htp.p('</thead>');
				htp.p('<tbody>');
					open crs_justificativas('S');
						loop
							fetch crs_justificativas into ws_justificativa;
							exit when crs_justificativas%notfound;
							htp.p('<tr>');
								--htp.p('<td>'||ws_justificativa.cd_avaliacao||'</td>');
								htp.p('<td>'||ws_justificativa.ds_pergunta||'</td>');
								htp.p('<td style="text-align: right;">'||ws_justificativa.justificativa||'</td>');
								htp.p('<td style="width: 104px;">');
									if ws_justificativa.thumb = 'UP' then
										ws_selected := ' selected';
									else
										ws_selected := '';
									end if;
									htp.p('<a class="thumb'||ws_selected||'" data-par="prm_cod='||ws_justificativa.cd_avaliacao||'&prm_thumb=UP" data-req="adicionarJustificativa"><img src="dwu.fcl.download?arquivo=thumbs-up.png" /></a>');
									if ws_justificativa.thumb = 'NEUTRAL' then
										ws_selected := ' selected';
									else
										ws_selected := '';
									end if;
									--htp.p('<a class="thumb neutral'||ws_selected||'" data-par="prm_cod='||ws_justificativa.cd_avaliacao||'&prm_thumb=NEUTRAL" data-req="adicionarJustificativa"><span></span></a>');
									htp.p('<a class="thumb neutral'||ws_selected||'" data-par="prm_cod='||ws_justificativa.cd_avaliacao||'&prm_thumb=NEUTRAL" data-req="adicionarJustificativa"><img src="dwu.fcl.download?arquivo=full-moon.png" /></a>');
									if ws_justificativa.thumb = 'DOWN' then
										ws_selected := ' selected';
									else
										ws_selected := '';
									end if;
									htp.p('<a class="thumb down'||ws_selected||'" data-par="prm_cod='||ws_justificativa.cd_avaliacao||'&prm_thumb=DOWN" data-req="adicionarJustificativa"><img src="dwu.fcl.download?arquivo=thumbs-up.png" /></a>');
								htp.p('</td>');

								ws_selected := '';

							htp.p('</tr>');
						end loop;
					close crs_justificativas;
				htp.p('</tbody>');
			htp.p('</table>');
		htp.p('</div>');

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
	end listaDeJustificativa;


	procedure adicionarJustificativa ( prm_cod 	 number,
									   prm_thumb varchar2 ) as

		ws_justificativa  number;
		ws_count          number;

		ws_semAcesso exception;

	begin

		if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		--create table pdi_justificativa ( cd_justificativa number, cd_avaliacao number, st_thumb varchar2(3), cd_cliente varchar2(80) );

		select nvl(max(cd_justificativa), 0)+1 into ws_justificativa from pdi_justificativa;

		merge into pdi_justificativa t1
			using (select prm_cod as cod, prm_thumb as thumb from dual) t2
			on (t1.cd_avaliacao = prm_cod and t1.cd_cliente = fun.ret_var('CLIENTE'))
			when matched then update 
			set t1.st_thumb      = prm_thumb

			when not matched then insert ( cd_justificativa, cd_avaliacao, st_thumb, cd_cliente ) 
			values ( ws_justificativa, prm_cod, prm_thumb, fun.ret_var('CLIENTE') );

		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Adicionado com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Avaliação da justificativa alterada no sistema!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao alterar!');
		end if;

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao alterar avaliação da justificativa #'||prm_cod||'! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
	end adicionarJustificativa;


	procedure avaliarJustificativa ( prm_cod       number default 0,
									 prm_avaliacao number,
								     prm_positivo  varchar2 ) as

		ws_count    number;
		ws_cod      number := 1;

		ws_semAcesso exception;

	begin

		/*if testaAdmin <> 'A' then
			raise ws_semAcesso;
		end if;

		select nvl(max(cd_justificativa), 0)+1 into ws_cod from pdi_justificativa_avaliada;

		merge into pdi_justificativa_avaliada t1
			using (select prm_cod as cod, prm_avaliacao as avaliacao, prm_positivo as positivo from dual) t2
			on (t1.cd_justificativa = t2.cod and t1.cd_avaliacao = t2.avaliacao and t1.cd_cliente = fun.ret_var('CLIENTE'))
			when matched then update 
			set t1.positivo = t2.positivo

			when not matched then insert (cd_justificativa, cd_avaliacao, positivo, cd_cliente) 
			values (trim(prm_cod), prm_avaliacao, prm_positivo, fun.ret_var('CLIENTE'));

		ws_count := sql%rowcount;

		if ws_count <> 0 then
			commit;
			htp.p('Avalia&ccedil;&atilde;o da justificativa salva com sucesso!');
			insert into bi_log_sistema values(sysdate, 'Avalia&ccedil;&atilde;o da justificativa adicionada ao sistema!', fun.ret_var('CLIENTE'), 'EVENTO');
        	commit;
		else
			rollback;
			htp.p('Erro ao salvar a avalia&ccedil;&atilde;o da justificativa!');
		end if;*/

		htp.p('');

	exception 
		when ws_semAcesso then
			htp.p('Sem acesso a esta tela!');
		when others then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			insert into bi_log_sistema values(sysdate, 'Erro ao adicionar a avalia&ccedil;&atilde;o da justificativa '||prm_cod||' ao sistema! ('||DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE||')', fun.ret_var('CLIENTE'), 'ERRO');
        	commit;
	end avaliarJustificativa;


	---------- UTILS ------------


	function retornaUsuario return number as

		ws_usuario number;
		ws_user    varchar2(80);
	begin

		ws_user := Owa_Cookie.Get('PDIHASH').Vals(1);

		select cd_usuario into ws_usuario from pdi_usuarios where hashcode = ws_user and cd_cliente = fun.ret_var('CLIENTE');

		return ws_usuario;

	exception when others then
		return 0;
	end retornaUsuario;

	function retornaIcone ( prm_icone varchar2 ) return varchar2 as

	begin

	    case prm_icone
			when 'ligacao' then
				return '<svg style="fill: var(--azul-escuro); stroke: var(--azul-escuro); stroke-width: 10px;" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" viewBox="0 0 512 512" style="enable-background:new 0 0 512 512;" xml:space="preserve"> <g> <g> <path d="M256,119.467c-75.093,0-136.533,61.44-136.533,136.533S180.907,392.533,256,392.533S392.533,331.093,392.533,256 S331.093,119.467,256,119.467z M256,375.467c-65.707,0-119.467-53.76-119.467-119.467S190.293,136.533,256,136.533 S375.467,190.293,375.467,256S321.707,375.467,256,375.467z"/> </g> </g> <g> <g> <path d="M335.36,354.133c-3.413-3.413-5.12-4.267-6.827-5.12l-37.547-17.92c-1.707-0.853-3.413-2.56-3.413-4.267v-11.093 c0.853-0.853,10.24-16.213,12.8-23.893c5.973-3.413,10.24-9.387,10.24-17.067v-15.36c0-4.267-1.707-8.533-4.267-11.947V230.4 c0.853-6.827-0.853-42.667-50.347-42.667c-23.893,0-39.253,7.68-46.933,21.333c-4.267,7.68-5.12,14.507-5.12,21.333v17.92 c-2.56,3.413-4.267,7.68-4.267,11.947v15.36c0,5.973,2.56,11.093,6.827,14.507c1.707,5.12,11.093,23.04,12.8,26.453v10.24 c0,1.707-0.853,3.413-2.56,4.267l-34.987,17.92c-2.56,0.853-4.267,3.413-7.68,7.68s0.853,5.12,5.12,7.68 c23.04,15.36,46.08,28.16,74.24,28.16c29.013,0,56.32-9.387,80.213-25.6C338.773,363.52,338.773,357.547,335.36,354.133z M253.44,373.76c-19.627,1.707-40.107-3.413-57.173-12.8l29.013-15.36c7.68-3.413,11.947-11.093,11.947-19.627V312.32 c0-1.707-0.853-4.267-1.707-5.973c0,0-0.853-0.853-1.707-2.56c-1.707-2.56-3.413-5.12-5.12-7.68 c-2.56-4.267-4.267-9.387-5.12-14.507c-0.853-2.56-1.707-4.267-3.413-5.12c-0.853-0.853-1.707-1.707-1.707-2.56v-15.36 c0-0.853,0-0.853,0.853-1.707c1.707-1.707,2.56-4.267,2.56-6.827v-21.333v-0.853c0-3.413,0-7.68,2.56-11.093 c4.267-7.68,13.653-12.8,31.573-12.8c17.92,0,27.307,5.12,31.573,12.8c2.56,4.267,2.56,7.68,2.56,11.093v0.853v21.333 c0,2.56,0.853,5.12,2.56,6.827c0.853,0.853,0.853,0.853,0.853,1.707v15.36c0,0.853-0.853,1.707-2.56,2.56 c-2.56,0.853-5.12,2.56-5.973,5.12c-2.56,7.68-11.947,22.187-12.8,23.04c-1.707,1.707-2.56,3.413-2.56,5.973v13.653 c0,8.533,5.12,16.213,12.8,19.627L312.32,358.4C294.4,368.64,274.773,373.76,253.44,373.76z"/> </g> </g> <g> <g> <path d="M256,0c-23.893,0-42.667,18.773-42.667,42.667c0,23.893,18.773,42.667,42.667,42.667 c23.893,0,42.667-18.773,42.667-42.667C298.667,18.773,279.893,0,256,0z M256,68.267c-14.507,0-25.6-11.093-25.6-25.6 c0-14.507,11.093-25.6,25.6-25.6c14.507,0,25.6,11.093,25.6,25.6C281.6,57.173,270.507,68.267,256,68.267z"/> </g> </g> <g> <g> <path d="M256,426.667c-23.893,0-42.667,18.773-42.667,42.667C213.333,493.227,232.107,512,256,512 c23.893,0,42.667-18.773,42.667-42.667C298.667,445.44,279.893,426.667,256,426.667z M256,494.933 c-14.507,0-25.6-11.093-25.6-25.6c0-14.507,11.093-25.6,25.6-25.6c14.507,0,25.6,11.093,25.6,25.6 C281.6,483.84,270.507,494.933,256,494.933z"/> </g> </g> <g> <g> <path d="M469.333,213.333c-23.893,0-42.667,18.773-42.667,42.667c0,23.893,18.773,42.667,42.667,42.667 C493.227,298.667,512,279.893,512,256C512,232.107,493.227,213.333,469.333,213.333z M469.333,281.6 c-14.507,0-25.6-11.093-25.6-25.6c0-14.507,11.093-25.6,25.6-25.6c14.507,0,25.6,11.093,25.6,25.6 C494.933,270.507,483.84,281.6,469.333,281.6z"/> </g> </g> <g> <g> <path d="M42.667,213.333C18.773,213.333,0,232.107,0,256c0,23.893,18.773,42.667,42.667,42.667 c23.893,0,42.667-18.773,42.667-42.667C85.333,232.107,66.56,213.333,42.667,213.333z M42.667,281.6 c-14.507,0-25.6-11.093-25.6-25.6c0-14.507,11.093-25.6,25.6-25.6c14.507,0,25.6,11.093,25.6,25.6 C68.267,270.507,57.173,281.6,42.667,281.6z"/> </g> </g> <g> <g> <path d="M256,68.267c-5.12,0-8.533,3.413-8.533,8.533V128c0,5.12,3.413,8.533,8.533,8.533s8.533-3.413,8.533-8.533V76.8 C264.533,71.68,261.12,68.267,256,68.267z"/> </g> </g> <g> <g> <path d="M256,375.467c-5.12,0-8.533,3.413-8.533,8.533v51.2c0,5.12,3.413,8.533,8.533,8.533s8.533-3.413,8.533-8.533V384 C264.533,378.88,261.12,375.467,256,375.467z"/> </g> </g> <g> <g> <path d="M435.2,247.467H384c-5.12,0-8.533,3.413-8.533,8.533s3.413,8.533,8.533,8.533h51.2c5.12,0,8.533-3.413,8.533-8.533 S440.32,247.467,435.2,247.467z"/> </g> </g> <g> <g> <path d="M128,247.467H76.8c-5.12,0-8.533,3.413-8.533,8.533s3.413,8.533,8.533,8.533H128c5.12,0,8.533-3.413,8.533-8.533 S133.12,247.467,128,247.467z"/> </g> </g> <g> <g> <path d="M135.68,75.093c-17.067-17.067-44.373-17.067-60.587,0c-17.067,17.067-17.067,43.52,0,60.587 c17.067,17.067,43.52,17.067,60.587,0S152.747,92.16,135.68,75.093z M122.88,122.88c-10.24,10.24-26.453,10.24-35.84,0 c-10.24-10.24-10.24-26.453,0-35.84c10.24-10.24,26.453-10.24,35.84,0C133.12,97.28,133.12,113.493,122.88,122.88z"/> </g> </g> <g> <g> <path d="M436.907,376.32c-17.067-17.067-43.52-17.067-60.587,0c-17.067,17.067-17.067,43.52,0,60.587 c17.067,17.067,43.52,17.067,60.587,0C453.973,420.693,453.973,393.387,436.907,376.32z M424.96,424.96 c-10.24,10.24-26.453,10.24-35.84,0c-10.24-10.24-10.24-26.453,0-35.84c9.387-10.24,25.6-10.24,35.84,0 S435.2,415.573,424.96,424.96z"/> </g> </g> <g> <g> <path d="M436.907,75.093c-17.067-17.067-43.52-17.067-60.587,0c-17.067,17.067-17.067,43.52,0,60.587 c17.067,16.213,44.373,16.213,60.587,0C453.973,118.613,453.973,92.16,436.907,75.093z M424.96,122.88 c-10.24,10.24-26.453,10.24-35.84,0c-10.24-10.24-10.24-26.453,0-35.84c10.24-10.24,26.453-10.24,35.84,0 C435.2,97.28,435.2,113.493,424.96,122.88z"/> </g> </g> <g> <g> <path d="M135.68,376.32c-17.067-17.067-43.52-17.067-60.587,0s-17.067,43.52,0,60.587c17.067,17.067,43.52,17.067,60.587,0 C151.893,420.693,151.893,393.387,135.68,376.32z M122.88,424.96c-9.387,10.24-25.6,10.24-35.84,0 c-10.24-10.24-10.24-26.453,0-35.84c10.24-10.24,26.453-10.24,35.84,0C133.12,399.36,133.12,415.573,122.88,424.96z"/> </g> </g> <g> <g> <path d="M170.667,159.573l-35.84-35.84c-3.413-3.413-8.533-3.413-11.947,0c-2.56,2.56-2.56,8.533,0,11.947l35.84,35.84 c3.413,3.413,8.533,3.413,11.947,0S174.08,162.987,170.667,159.573z"/> </g> </g> <g> <g> <path d="M388.267,376.32l-35.84-35.84c-3.413-3.413-8.533-3.413-11.947,0c-3.413,3.413-3.413,8.533,0,11.947l35.84,35.84 c3.413,3.413,8.533,3.413,11.947,0C391.68,384.853,391.68,379.733,388.267,376.32z"/> </g> </g> <g> <g> <path d="M388.267,122.88c-2.56-2.56-8.533-2.56-11.947,0l-35.84,35.84c-3.413,3.413-3.413,8.533,0,11.947 c3.413,3.413,8.533,3.413,11.947,0l35.84-35.84C391.68,131.413,391.68,126.293,388.267,122.88z"/> </g> </g> <g> <g> <path d="M171.52,340.48c-3.413-3.413-8.533-3.413-11.947,0l-35.84,35.84c-3.413,3.413-3.413,8.533,0,11.947s8.533,3.413,11.947,0 l35.84-35.84C174.933,349.013,174.933,343.893,171.52,340.48z"/> </g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> <g> </g> </svg>';
			
			when 'edit' then
				return '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="480px" height="480px" viewBox="0 0 480 480" enable-background="new 0 0 480 480" xml:space="preserve"> <g> <g> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5F5FAA" d="M385.398,17.105c7.436,2.989,15.604,4.883,22.213,9.186 c15.268,9.946,22.662,24.93,22.713,43.135c0.143,51.367,0.053,102.722,0.027,154.077c0,0.966-0.221,1.945-0.389,3.259 c-11.775-2.396-22.92-0.799-34.064,4.239c0-48.584,0-96.55,0-144.8c-114.729,0-229.129,0-344.085,0c0,1.61,0,3.13,0,4.69 c0,94.875,0,189.789,0,284.68c0,13.656,6.597,20.188,20.318,20.201c54.408,0,108.829,0,163.237,0c1.727,0,3.453,0,5.784,0 c-3.246,11.117-6.286,21.799-9.624,32.375c-0.309,0.967-2.68,1.83-4.071,1.844c-17.419,0.115-34.832,0.078-52.244,0.078 c-34.832,0-69.649,0.063-104.487-0.027c-26.399-0.064-46.717-16.064-52.295-40.982c-0.451-2.088-0.876-4.174-1.327-6.275 c0-106.213,0-212.439,0-318.653c0.296-1.108,0.657-2.203,0.876-3.324c3.955-20.884,16.027-34.708,36.151-41.473 c2.68-0.915,5.502-1.494,8.246-2.229C170.054,17.105,277.717,17.105,385.398,17.105z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5F5FAA" d="M266.121,462.895c-5.836-3.582-6.711-5.695-4.818-12.174 c5.592-19.172,11.184-38.355,16.904-57.488c0.684-2.254,1.867-4.664,3.518-6.287c27.559-27.609,55.219-55.104,82.867-82.623 c0.4-0.4,0.863-0.76,0.838-0.721c18.191,17.973,36.307,35.867,54.73,54.086c-0.773,0.811-1.816,1.957-2.898,3.025 c-26.631,26.504-53.225,53.031-79.971,79.404c-2.33,2.305-5.598,4.16-8.748,5.127c-17.998,5.541-36.086,10.719-54.123,16.053 c-1.354,0.4-2.635,1.059-3.943,1.598C269.014,462.895,267.564,462.895,266.121,462.895z M292.701,398.232 c-3.363,11.414-6.615,22.365-9.791,33.33c-0.219,0.746-0.207,1.777,0.143,2.473c2.293,4.613,7.084,6.635,12.02,5.166 c9.656-2.873,19.326-5.771,29.182-8.723c-1.65-8.373-3.119-16.336-4.846-24.234c-0.23-1.133-1.404-2.666-2.396-2.898 C309.127,401.529,301.18,399.971,292.701,398.232z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5F5FAA" d="M462.895,307.027c-1.662,6.094-5.553,10.654-10.023,14.895 c-5.566,5.27-10.926,10.783-16.002,15.807c-17.379-17.225-34.734-34.41-51.984-51.496c7.406-7.561,14.531-15.576,22.418-22.738 c6.17-5.58,16.201-5.219,22.352,0.592c9.799,9.211,19.275,18.836,28.551,28.604c2.242,2.383,3.156,6.055,4.689,9.133 C462.895,303.563,462.895,305.289,462.895,307.027z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5F5FAA" d="M172.393,189.012c0-11.595,0-22.713,0-34.051 c57.307,0,114.342,0,171.676,0c0,11.39,0,22.585,0,34.051C286.787,189.012,229.764,189.012,172.393,189.012z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5F5FAA" d="M172.38,257.85c0-11.568,0-22.688,0-34.038 c57.294,0,114.343,0,171.688,0c0,11.363,0,22.559,0,34.038C286.813,257.85,229.764,257.85,172.38,257.85z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5F5FAA" d="M328.17,292.766c-0.928,1.082-1.572,1.971-2.318,2.73 c-9.768,9.727-19.494,19.494-29.369,29.092c-1.281,1.25-3.445,2.254-5.199,2.254c-38.574,0.131-77.134,0.09-115.714,0.09 c-0.973,0-1.952-0.115-3.163-0.205c0-11.363,0-22.482,0-33.961C224.146,292.766,275.914,292.766,328.17,292.766z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5F5FAA" d="M137.607,155.102c0,11.313,0,22.405,0,33.833 c-11.416,0-22.598,0-34.033,0c0-11.247,0-22.353,0-33.833C114.712,155.102,125.921,155.102,137.607,155.102z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5F5FAA" d="M103.619,223.683c11.402,0,22.392,0,33.794,0 c0,11.415,0,22.688,0,34.22c-11.305,0-22.392,0-33.794,0C103.619,246.514,103.619,235.316,103.619,223.683z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5F5FAA" d="M103.574,292.623c11.357,0,22.463,0,33.903,0 c0,11.287,0,22.482,0,34.014c-11.286,0-22.469,0-33.903,0C103.574,315.26,103.574,304.053,103.574,292.623z"/> </g> </g> </svg>';

			when 'lixo' then
				return '<svg version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" x="0px" y="0px" width="480px" height="480px" viewBox="0 0 480 480" enable-background="new 0 0 480 480" xml:space="preserve"> <g> <g> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5F5FAA" d="M303.422,27.257c6.269,6.493,12.705,12.817,18.692,19.548 c3.45,3.898,7.208,5.146,12.396,5.09c24.315-0.281,48.659-0.112,72.988-0.112c1.726,0,3.408,0,5.413,0c0,16.421,0,32.449,0,48.813 c-114.356,0-228.74,0-343.412,0c0-16.056,0-32.112,0-48.813c1.662,0,3.316,0,4.999,0c25.479,0,50.973-0.056,76.453,0.042 c2.973,0.014,5.132-0.729,7.208-2.889c6.085-6.353,12.382-12.466,18.566-18.707c0.883-0.869,1.528-1.977,2.265-2.973 C220.477,27.257,261.957,27.257,303.422,27.257z"/> <path fill-rule="evenodd" clip-rule="evenodd" fill="#5F5FAA" d="M388.751,274.297c0-47.649,0-95.313,0-142.977 c0-1.711,0-3.394,0-5.385c-98.412,0-196.39,0-295.055,0c0,1.486,0,3.015,0,4.515c0,95.762-0.028,191.51,0,287.272 c0,27.008,15.383,45.784,41.858,51.295c0.386,0.07,0.743,0.407,1.122,0.617c69.694,0,139.387,0,209.081,0 c4.368-1.346,8.961-2.201,13.041-4.108c20.074-9.325,29.869-25.409,29.925-47.369 C388.807,370.213,388.751,322.255,388.751,274.297z M162.128,410.992c0,8.539-6.941,15.48-15.495,15.48 c-8.554,0-15.467-6.941-15.467-15.48V175.857c0-8.568,6.913-15.496,15.467-15.496c8.554,0,15.495,6.927,15.495,15.496V410.992z M224.88,410.992c0,8.539-6.941,15.48-15.481,15.48s-15.467-6.941-15.467-15.48V175.857c0-8.568,6.927-15.496,15.467-15.496 s15.481,6.927,15.481,15.496V410.992z M287.646,410.992c0,8.539-6.948,15.48-15.481,15.48c-8.554,0-15.481-6.941-15.481-15.48 V175.857c0-8.568,6.928-15.496,15.481-15.496c8.533,0,15.481,6.927,15.481,15.496V410.992z M350.412,410.992 c0,8.539-6.927,15.48-15.48,15.48c-8.555,0-15.481-6.941-15.481-15.48V175.857c0-8.568,6.927-15.496,15.481-15.496 c8.554,0,15.48,6.927,15.48,15.496V410.992z"/> </g> </g> </svg>';
		end case;

	end retornaIcone;


	function converte( prm_texto varchar2 default null ) return varchar2 as

		ws_convertido varchar2(4000);
		ws_charset varchar2(200);

	begin

		ws_charset := fun.ret_var('CHARSET');

		if nvl(ws_charset, 'AL32UTF8') <> 'AL32UTF8' then
			
			begin
				select CONVERT(prm_texto, ws_charset, 'AL32UTF8') into ws_convertido from dual;
				
			exception when others then
				ws_convertido := prm_texto;
			end;

			return ws_convertido;
		else
			return prm_texto;
		end if;

	end converte;

	function generateHash ( prm_cod varchar2, prm_nome varchar2, prm_setor varchar2 ) return varchar2 as

	begin

	    return ltrim(to_char(dbms_utility.get_hash_value(upper(trim(prm_nome))||'/'||upper(trim(prm_cod)), 1000000000, power(2,30) ), rpad( 'X',29,'X')||'X'))||
		ltrim(to_char(dbms_utility.get_hash_value(upper(trim(prm_setor)), 1000000000, power(2,30) ), rpad( 'X',29,'X')||'X'))||
		ltrim( to_char(dbms_utility.get_hash_value(upper(trim(fun.ret_var('CLIENTE'))), 100000000, power(2,30) ), rpad( 'X',29,'X')||'X' ) );

	end generateHash;

	function testaAdmin return varchar2 as

	    ws_tipo varchar2(80) := 'N';
		ws_code varchar2(80);

	begin

		ws_code := Owa_Cookie.Get('PDIHASH').vals(1);

	    select tipo into ws_tipo from pdi_usuarios where hashcode = ws_code and cd_cliente = fun.ret_var('CLIENTE');

		return ws_tipo;

	end testaAdmin;

end PDI;
/
show error
exit