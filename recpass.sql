set define off;
create or replace procedure recpass ( prm_usuario varchar2 default null,
                                      prm_email   varchar2 default null,
                                      prm_senha   varchar2 default null )

as

    ws_senha   			varchar2(80);
    ws_para    			varchar2(80);
    ws_usuario 			varchar2(80);
    ws_count   			number;
    Mail_Conn  			Utl_Smtp.Connection;
    crlf       			VARCHAR2(2):= CHR(13) || CHR(10);
    ws_mail    			clob;
    l_boundary    		VARCHAR2(50) := '----=*#abc1234321cba#*=';
    ws_mensagem   		varchar2(2000);
    ws_to         		varchar2(20);
    ws_conteudo   		varchar2(80);
    ws_correio_port 	varchar2(120);
    ws_correio_pass 	varchar2(120);
    ws_correio_user 	varchar2(120);
    ws_correio      	varchar2(120);
	ws_email			varchar2(200);
	ws_error			exception;

begin

    if nvl(prm_email, 'N/A') = 'N/A' then

		htp.p('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
				htp.p('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">');
					htp.p('<head>');
						htp.p('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
						htp.p('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
						htp.p('<TITLE>Recuperar Senha</TITLE>');
						htp.p('<META HTTP-EQUIV="Pragma" CONTENT="no-cache, no-store, must-revalidate">');
						htp.p('<META HTTP-EQUIV="Expires" CONTENT="0">');
						htp.p('<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">');
						htp.p('<meta name="apple-mobile-web-app-capable" content="yes" />');
						htp.p('<meta name="viewport" content="width=device-width, user-scalable=no, initial-scale=1, maximum-scale=1">');
						htp.p('<meta name="apple-mobile-web-app-status-bar-style" content="black">');
		                htp.p('<link href="https://fonts.googleapis.com/css?family=Montserrat" rel="stylesheet" type="text/css">');
						htp.p('<script src="dwu.fcl.download?arquivo=chamado.js"></script>');

						htp.p('<style>html, body, div, span { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } object, iframe, h1, h2, h3 { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } h4, h5, h6, p { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } pre, a, abbr, address { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } cite, code, del, dfn, em { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } ins, kbd, q, img { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } samp, small, big, strong { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } sub, sup, tt, var, b { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } table, tr, i { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } td, th, tbody, thead, tfooter { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } dl, dt, dd, ol, ul { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } form, label, legend, li, fieldset { margin: 0; padding: 0; border: 0; font-size: 100%; font: inherit;vertical-align: baseline; border-spacing: 0; } caption, article, aside, canvas, details { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } figcaption, footer, header, embed, figure { margin: 0; padding: 0; border: 0; font-size: 100%;  vertical-align: baseline; border-spacing: 0; } nav, output, ruby { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } section, summary, time, mark { margin: 0; padding: 0; border: 0; font-size: 100%; vertical-align: baseline; border-spacing: 0; } * { -webkit-touch-callout: none; -webkit-text-size-adjust: none; -webkit-tap-highlight-color: rgba(0,0,0,0); -webkit-transform-style: flat; } video, article, aside, details, figcaption { display: block; } figure, footer, header, menu, nav, section { display: block; } html { font-family: arial; height: 100%; position: relative; -webkit-touch-callout: none; width: 100%; display: inline-block; background-color: #FFF; } body { -webkit-text-size-adjust: none; /*margin: -2px 0;*/ position: relative; overflow: auto; line-height: 1; height: 100%; } ul { list-style: none; } blockquote, q { quotes: none; } blockquote:before, blockquote:after, q:before, q:after { content: ''; content: none; } a { cursor: pointer; }</style>');
						htp.p('<style>body { font-family: "montserrat", monospace; font-weight: bold; height: 100%; width: 100%; } div#content { min-width: 280px;height: calc(100% - 20px); width: calc(100% - 20px);} div#header, div#main { background-color: #EFEFEF; border-radius: 20px; background-color: #FFFFFF; box-shadow: 4px 6px 13px 6px rgb(157 152 192);  -webkit-overflow-scrolling: touch; } div#main { width: 400px;position: relative; padding: 20px; height: 150px; top: calc(50% - 75px); left: calc(50% + 100px); } h2 { font-size: 26px; color: #3C8846; text-align: center; } ul#lista { margin: 40px 0; } ul#lista li { line-height: 26px; min-height: 58px; display: flex; flex-wrap: wrap; } ul li { margin: 20px 0; }</style>');
						htp.p('<style>table { margin: 20px 0; width: 100%; } table tr td, table tr th { border: 1px solid #FEFEFE; padding: 10px 10px; flex-grow: 1; flex-basis: 20px; background-color: #56AA56; color: #DEDEDE; } table tr:nth-child(even) td, table tr th { background-color: #348834; }</style>');
						htp.p('<style>ul li span.desc { width: 240px; } ul li span.input { width: calc(100% - 240px); min-width: 240px; } ul li span.input.red:after { content: "*"; font-size: 20px; color: #CC0000; } ul li span input, ul li span select, ul li span textarea { max-height: 140px; min-width: 140px; width: calc(100% - 20px); max-width: 600px; border-radius: 6px; border: 1px solid #777; padding: 6px 3px; box-shadow: 0px 2px 3px 0px #AAA inset; } ul li span.red input, ul li span.red select, ul li span.red textarea { box-shadow: 0px 2px 3px 0px #AAA inset, 0 0 3px 1px #CC0000; } a#button { color: #EFEFEF; background-color: #3C8846; border-radius: 6px; padding: 10px 15px; box-shadow: 0px 0 1px 1px #444; cursor: pointer; margin-bottom: 10px; float: left; transition: background 0.1s linear; position: relative; left: calc(50% - 60px); top: 15px;  } .readonly { background-color: #BBB; color: #777; cursor: default; }</style>');
						htp.p('<style>ul#painel { position: absolute; bottom: 0; display: flex; flex-flow: row; } ul#painel li { color: #EFEFEF; background-color: #3984B5; padding: 10px 15px; box-shadow: 0px 0 1px 1px #444; cursor: pointer; font-size: 12px; transition: background 0.1s linear; margin: 20px 0; } ul#painel li:active, a#button:active { background-color: #3C8846; } </style>');
		                htp.p('<style> a#button:active { background-color: #3C8846; } </style>');
						htp.p('<style> input { background: #e0e0f0; } </style>');
						htp.p('<style> img.fundo { z-index:-1; position: absolute; width:100%; height:100%; } </style>');
						htp.p('<style> ::-webkit-input-placeholder {color: #3C8846;font-weight: bold;} </style>');

						--style para dispositivos mobile:
						htp.p('<style>@media all and (max-device-width: 800px) and (orientation: portrait) {  div#main { font-size: 12px; width: 43%; height: 25%; margin: 0px; padding: 12px; left: 49%;} input, h2,a#button {font-size:10px; padding:10px;} a#button{ left:25%; } img.fundo{width:100%; height:100%;}}</style>');

					htp.p('</head>');

					htp.p('<body>');

					    htp.p('<div id="content">');

						    htp.p('<img class = "fundo" src="dwu.fcl.download?arquivo=background.png"/>');
							--htp.p('<img class = "queryda" src="dwu.fcl.download?arquivo=queryda-01.png"/>');
						    htp.p('<div id="main">');

		                        htp.p('<h2>RECUPERAR SENHA</h2>');

								htp.p('<ul>');

                                    htp.p('<li> <span class="input"> <input id="email" type="text" placeholder="E-MAIL"/> </span> </li>');
		                            htp.p('<li> <a id="button">ENVIAR</a> </li>');

								htp.p('</ul>');

						    htp.p('</div>');

						htp.p('</div>');

					htp.p('</body>');


					htp.p('<script>

								document.addEventListener(''click'', function(e){ 
										if(e.target.id == ''button''){ 
											if(document.getElementById(''email'').value.length>1){
												send_recpass(document.getElementById(''email'').value);
											}else{
												alert(''Você precisa inserir um e-mail'');
											}
                                        }
										});
							</script>');

				    htp.p('<script>

								function send_recpass(email){
									call(''recpass'', ''&prm_email=''+email).then(function(resposta){ 
										if(resposta.indexOf(''OK'') != -1){ 
											console.log(''enviado''); 
											alert(''Senha provisória enviada com sucesso. Verifique sua caixa de entrada ou spam.''); 
										} else if (resposta.indexOf(''!FMail'') != -1)  { 
											alert(''Erro ao enviar, e-mail cadastrado para outro usuario, contate o suporte.'');
										}else{
											alert(''Erro ao enviar, e-mail inexistente ou não cadastrado no sistema.'');
										}
									}); 
								};
							</script>');

				    htp.p('<script>
								function call(x, y){ 
									return new Promise(function(resolve, reject){ 
										var request = new XMLHttpRequest(); 
										request.open(''POST'', ''dwu.recpass'', true); 
										request.onload = function(){ 
											if(request.status == 200){ 
												resolve(request.responseText.trim()); 
												} else { 
													reject(request.responseText.trim()); 
													} 
												}; 
												request.onerror = function(){ 
													console.log(''error''); 
											}; 
											request.send(y);
										}); 
									}
							</script>');

		htp.p('</html>');

	else

	    begin

			select count(*) into ws_count from opr_contatos where  trim(lower(email)) = trim(lower(prm_email));

			if ws_count >1 then
				raise ws_error;
			end if;	

			select usuario,email into ws_usuario,ws_email from opr_contatos where  trim(lower(email)) = trim(lower(prm_email));

			ws_senha:= to_char(sysdate,'DDMMYYYYHHMI');



	        if ws_count <> 0 /*and length(prm_senha) > 0*/ then

	            select count(*) into ws_count from all_users where  trim(lower(username)) = trim(lower(ws_usuario));

	            --select nvl(prm_senha, to_char(dbms_random.value(100, 999), '999')||dbms_random.string('L', 3)) into ws_senha from dual;

                --select prm_senha into ws_senha from dual;

	            if ws_count <> 0 then

				    execute immediate 'alter user "'||upper(ws_usuario)||'" identified by "'||trim(ws_senha)||'"';
				    commit;

				else

				    execute immediate 'create user "'||trim(ws_usuario)||'" identified by "'||trim(ws_senha)||'"';
				    execute immediate 'grant connect to "'||upper(trim(ws_usuario))||'"';
				    execute immediate 'grant execute on dwu.chamado to "'||upper(trim(ws_usuario))||'"';
				    commit;

				end if;

			    select nvl(prm_email, email) into ws_para from opr_contatos where trim(lower(usuario)) = trim(lower(ws_usuario));

			    --fcl.xsend_Mail('xxx', trim(lower(ws_email)),'CHAMADO DA UPQUERY','SENHA DE CHAMADO: '||ws_senha);

			    select trim(conteudo) into ws_correio_port from var_conteudo where variavel = 'CORREIO_PORT';
			    select trim(conteudo) into ws_correio_user from var_conteudo where variavel = 'CORREIO_USER';
			    select trim(conteudo) into ws_correio_pass from var_conteudo where variavel = 'CORREIO_PASS';
			    select trim(conteudo) into ws_correio 	   from var_conteudo where variavel = 'CORREIO';

			    mail_conn := utl_smtp.open_connection(ws_correio, ws_correio_port);
			    Utl_Smtp.Helo(Mail_Conn, ws_correio);

			    --ws_mensagem := 'Sua senha temporaria: '||ws_senha||'. Acesse a aba PERFIL no Portal do Cliente e troque sua senha. <br> Atenciosamente,<br>Equipe UpQuery';
				ws_mensagem := 'Voc&ecirc; esta recebendo este e-mail pois foi solicitado pelo sistema a troca da senha.<br>
								Nova senha: '||ws_senha||'<br>
								Para altera&ccedil;&atilde;o da senha provis&oacute;ria, acesse a aba Perfil dispon&iacute;vel no Portal do Cliente.<br>
								Equipe UpQuery.';

			    Utl_Smtp.Command( Mail_Conn, 'AUTH LOGIN');
			    Utl_Smtp.Command( Mail_Conn, Utl_Raw.Cast_To_Varchar2( Utl_Encode.Base64_Encode( Utl_Raw.Cast_To_Raw(ws_correio_user))) );
			    Utl_Smtp.Command( Mail_Conn, Utl_Raw.Cast_To_Varchar2( Utl_Encode.Base64_Encode( Utl_Raw.Cast_To_Raw(ws_correio_pass))) );

			    ws_mail:= 'Date: ' || to_char( Sysdate, 'dd Mon yy hh24:mi:ss' ) || Crlf ||  'From: Registro de chamados - UpQuery <'||ws_correio_user||'>'||Crlf ||  'Subject: Nova senha - Portal do Cliente'|| Crlf ||  'To: <'||ws_para||'>'||
			            '            MIME-Version: 1.0'||crlf
			            ||'Content-Type: multipart/alternative; boundary="'||l_boundary ||'"'||crlf||crlf
			            ||'--' ||l_boundary ||crlf||'Content-Type: text/html; charset=iso-8859-1"'||crlf||crlf
			            ||ws_mensagem||crlf||'--' ||l_boundary|| '--'||crlf;

			    utl_smtp.helo(mail_conn, ws_correio);
			    Utl_Smtp.Mail(Mail_Conn, '<'||ws_correio_user||'>');
			    Utl_Smtp.Rcpt(Mail_Conn, '<'||ws_para||'>');
			    Utl_Smtp.Data(Mail_Conn, ws_mail);

			    Utl_Smtp.Quit(Mail_Conn);


				commit;

				htp.p('OK');
		    else
		        htp.p('FAIL');
		    end if;
		exception when ws_error then
			htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
			htp.p('!FMail');
		 when others then
		   rollback;
		   htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
		end;

	end if;
end recpass;