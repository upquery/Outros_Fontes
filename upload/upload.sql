set scan off

-- >>>>>>>-------------------------------------------------------------
-- >>>>>>> Aplicação: Upload
-- >>>>>>> Por:		Upquery Tec
-- >>>>>>> Data:	18/04/12
-- >>>>>>> Pacote:	Upload
-- >>>>>>>-------------------------------------------------------------

create or replace package upload is
	
	procedure main ( prm_alternativo varchar2 default null );
	
	PROCEDURE upload (arquivo  IN  VARCHAR2, prm_usuario varchar2 default null);
	
end upload;
/

create or replace package body upload is

	procedure main ( prm_alternativo varchar2 default null ) as
	
		ws_count   number := 0;
        ws_coluna  varchar2(400);
        ws_tabela  varchar2(400);
	
		begin
		htp.htmlopen;
		  htp.headopen;
		  htp.title('Upload Arquivo');
		  fcl.put_css('reset');
		  htp.headclose;
		  htp.p('<body style="margin: 0;">');

		  htp.p('<form enctype="multipart/form-data" action="dwu.upload.upload" method="post" style="float: left;">');
		  htp.p(fun.lang('Arquivo para upload')||': <input type="file" name="arquivo" style="max-width: 330px; border: inherit; border-radius: 0;">');
          
            if length(prm_alternativo) > 0 then
                htp.p('<input type="hidden" name="prm_usuario" style="display: none;" value="'||prm_alternativo||'">');
            else
                htp.p('<input type="hidden" name="prm_usuario" style="display: none;" value="">');
            end if;

		  htp.p('<input type="submit" value="Upload" style="border: 1px solid #777; border-radius: 0; background: #E1E1E1; height: 24px;" >');
		  htp.p('</form>');
 
            if length(prm_alternativo) > 0 then
                for i in(select column_value from table(fun.vpipe((prm_alternativo)))) loop
                    ws_count := ws_count+1;
                    if ws_count = 1 then
                        ws_coluna := i.column_value;
                    else
                        ws_tabela := i.column_value;
                    end if;
                end loop;
                if(fun.cdesc(ws_tabela, ws_coluna) <> ws_coluna) then
                    htp.p('<div style="float: right; height: 30px; line-height: 30px; font-weight: bold;">ARQUIVOS DO USUÁRIO: '||fun.cdesc(ws_tabela, ws_coluna)||'</div>');
                end if;
            end if;

		  htp.bodyclose;
		  htp.htmlclose;
    end main;
	
	PROCEDURE upload (arquivo  IN  VARCHAR2, prm_usuario varchar2 default null ) AS
		  l_nome_real  VARCHAR2(1000);
		BEGIN

		  HTP.htmlopen;
		  HTP.headopen;
		  HTP.title(fun.lang('Arquivo Carregado'));
		  HTP.headclose;
		  HTP.bodyopen;
		  HTP.header(1, 'STATUS');

		  l_nome_real := replace(SUBSTR(arquivo, INSTR(arquivo, '/') + 1), ' ', '_');

		  BEGIN

			DELETE FROM TAB_DOCUMENTOS
			WHERE  name = l_nome_real and
			usuario = user;

			UPDATE TAB_DOCUMENTOS
			SET    name = l_nome_real,
			usuario = nvl(prm_usuario, user)
			WHERE  name = arquivo;

			htp.p('<script>parent.alerta(''msg'', '''||fun.lang('Arquivo enviado com sucesso')||'!''); if(parent.document.getElementById(''browseredit'')){ var valor = parent.document.getElementById(''browseredit'').className; parent.ajax(''list'', ''anexo'', ''prm_chave=''+valor, false, ''editb'', '''', '''', ''bro''); } else { parent.ajax(''list'', ''uploaded'', ''prm_chave='||prm_usuario||''', false, ''content'');  parent.carregaPainel(''upload'', '''||prm_usuario||'''); }</script>');
		  EXCEPTION
			WHEN OTHERS THEN
			  HTP.print(fun.lang('Carregado ') || l_nome_real || fun.lang(' ERRO.'));
			  HTP.print(SQLERRM);
		  END;
    END upload;
	
end upload;
/
show error
exit