set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Por:		Upquery Tec
-- >>>>>>> Data:	26/02/16
-- >>>>>>> Pacote:	MSG
-- >>>>>>>-------------------------------------------------------------


create or replace package msg is

	procedure main;
	
	procedure enviar ( prm_origem varchar2 default null, 
	                   prm_msg    varchar2 default null, 
					   prm_fone   varchar2 default null );
	
end msg;
/

create or replace package body msg is

	procedure main as
	
		begin

		htp.p('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
		htp.p('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">');
			htp.p('<head>');
				htp.p('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
				htp.p('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
				htp.p('<meta name="apple-mobile-web-app-capable" content="yes">');
				htp.p('<meta name="apple-mobile-web-app-status-bar-style" content="black" />');
				htp.p('<title>Upquery - Mensagem</title>');
				htp.p('<link rel="apple-touch-icon" size="114x114" href="">');
				htp.p('<META HTTP-EQUIV="Pragma" CONTENT="no-cache">');
				htp.p('<META HTTP-EQUIV="Expires" CONTENT="-1">');
				htp.p('<META HTTP-EQUIV="CACHE-CONTROL" CONTENT="NO-CACHE">');
				htp.p('<script>');
				    htp.p('function sendmsg(){ var msg = encodeURIComponent(document.getElementById(''msg'').value); var fone = document.getElementById(''fone'').value; var ajaxRequest; ');
					htp.p('ajaxRequest = new XMLHttpRequest(); ajaxRequest.onreadystatechange = function(){ if(ajaxRequest.readyState == 4){ if(ajaxRequest.status == 200){ getmsg(ajaxRequest.responseText) }}} ');
					htp.p('ajaxRequest.open(''POST'', ''dwu.msg.enviar'', false); ajaxRequest.send(''prm_origem=&prm_msg=''+msg+''&prm_fone=''+fone); }');
				    htp.p('function getmsg(x){ var ajaxRequest; ');
					htp.p('ajaxRequest = new XMLHttpRequest(); ajaxRequest.onreadystatechange = function(){ console.log(ajaxRequest.readyState); if(ajaxRequest.readyState == 4){ if(ajaxRequest.status == 200){ alert(''enviado com sucesso!''); }}} ');
					htp.p('ajaxRequest.open(''GET'', x, false); ajaxRequest.send(null); }');
				
				htp.p('</script>');
			htp.p('</head>');
			htp.p('<body>');
			    htp.p('<h1>FORMULÁRIO DE MENSAGEM</h1>');
				htp.p('<input placeholder="telefone" type="text" id="fone" style="display: block; margin: 5px 0;"/>');
				htp.p('<textarea id="msg" placeholder="MENSAGEM" style="display: block; margin: 5px 0;"></textarea>');
				htp.p('<button style="display: block; margin: 5px 0;" onclick="sendmsg();" >enviar</button>');
            htp.p('</body>');
        htp.p('</html>');
    end main;
	
	procedure enviar ( prm_origem varchar2 default null, 
	                   prm_msg    varchar2 default null, 
					   prm_fone   varchar2 default null ) as
	
	begin
	
	    Send_Sms(prm_origem, prm_msg, prm_fone);
	
	end enviar;
	
end msg;
/
show error
exit
