set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplicação: Avaliação Interna
-- >>>>>>> Por:		Upquery Tec
-- >>>>>>> Data:	18/04/12
-- >>>>>>> Pacote:	D.I (Double input)
-- >>>>>>>-------------------------------------------------------------

create or replace package di is
	
	procedure main;
	
	Function encrypt (p_text  IN  VARCHAR2) RETURN RAW;
	
	PROCEDURE padstring (p_text  IN OUT  VARCHAR2);
	
	Function decrypt (P_Raw  In  Raw) Return Varchar2;
	
	procedure evento ( prm_texto varchar2 default null,
                       prm_tipo varchar2 default null);
	
	g_key     RAW(32767)  := UTL_RAW.cast_to_raw('69198823');
    g_pad_chr VARCHAR2(1) := '~';
	
end di;
/

create or replace package body di is

	procedure main as
	
		ws_count number;
	
		begin
		--voltolini automatico
		htp.p('<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.0 Strict//EN" "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">');
		htp.p('<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="pt-br" lang="pt-br">');
			htp.headOpen;
				fcl.put_script('di');
				htp.p('<meta http-equiv="X-UA-Compatible" content="IE=edge,chrome=1" />');
				htp.p('<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />');
				htp.p('<TITLE>UpQuery Tec</TITLE>');
				htp.p('<link rel="apple-touch-icon" size="114x114" href="'||ret_var('URL_GIFS')||'ipad_icon.png">');
				htp.p('<META HTTP-EQUIV="Pragma" CONTENT="no-cache">');
				htp.p('<META HTTP-EQUIV="Expires" CONTENT="-1">');
				htp.p('<META NAME="apple-mobile-web-app-capable" CONTENT="yes">');
			htp.headClose;
			htp.p('<body>');
			    htp.p('Criptar: <input id="enter" type="text"/>');
				htp.p('<input id="exit" readonly="true" style="width: 400px;"/>');
				htp.p('<input type="button" value="enviar" onclick="ajax(''prm_texto=''+document.getElementById(''enter'').value+''&prm_tipo=encript'', ''exit'');">');
			    htp.p('<br />Descriptar: <input id="enter-code" type="text" style="width: 400px;"/>');
				htp.p('<input id="exit-code" readonly="true"/>');
				htp.p('<input type="button" value="enviar" onclick="ajax(''prm_texto=''+document.getElementById(''enter-code'').value+''&prm_tipo=decript'', ''exit-code'');">');
			
			htp.p('</body>');
		htp.p('</html>');
	end main;
	
	FUNCTION encrypt (p_text  IN  VARCHAR2) RETURN RAW IS
  -- --------------------------------------------------
    l_text       VARCHAR2(32767) := p_text;
    l_encrypted  RAW(32767);
  BEGIN
    padstring(l_text);
    DBMS_OBFUSCATION_TOOLKIT.desencrypt(input          => UTL_RAW.cast_to_raw(l_text),
                                        key            => g_key,
                                        encrypted_data => l_encrypted);
    RETURN l_encrypted;
  END;
  
  FUNCTION decrypt (p_raw  IN  RAW) RETURN VARCHAR2 IS
  -- --------------------------------------------------
    l_decrypted  VARCHAR2(32767);
  BEGIN
    DBMS_OBFUSCATION_TOOLKIT.desdecrypt(input => p_raw,
                                        key   => g_key,
                                        decrypted_data => l_decrypted);

    RETURN RTrim(UTL_RAW.cast_to_varchar2(l_decrypted), g_pad_chr);
  END;
  
  PROCEDURE padstring (p_text  IN OUT  VARCHAR2) IS
  -- --------------------------------------------------
    l_units  NUMBER;
  BEGIN
    IF LENGTH(p_text) MOD 8 > 0 THEN
      l_units := TRUNC(LENGTH(p_text)/8) + 1;
      p_text  := RPAD(p_text, l_units * 8, g_pad_chr);
    END IF;
  END;
  
  procedure evento ( prm_texto varchar2 default null,
                     prm_tipo varchar2 default null) as
					 
  begin
  
  if prm_tipo = 'encript' then
      htp.p(encrypt(prm_texto));
  else
      htp.p(decrypt(prm_texto));
  end if;
  
  end;
	
end di;
/
show error
exit