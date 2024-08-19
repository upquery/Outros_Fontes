create or replace procedure impressao_envelope ( prm_filial varchar2 ) as

ws_valor1    varchar2(6);
ws_valor2    varchar2(6);
ws_conteudo varchar2(4000);
ws_count    number := 0;
ws_start    number := 1;
ws_array_senha DBMS_SQL.VARCHAR2_TABLE;

    cursor crs_senhas is
    select ds_senha from senha 
    where filial = prm_filial;
    
    ws_senha crs_senhas%rowtype;

begin

    open crs_senhas;
        loop
            fetch crs_senhas into ws_senha;
            exit when crs_senhas%notfound;
            ws_count := ws_count+1;
            ws_array_senha(ws_count) := ws_senha.ds_senha;
        end loop;
    close crs_senhas;



loop
    ws_valor1 := ws_array_senha(ws_start);
    begin
        ws_valor2 := ws_array_senha(ws_start+1);
    exception when others then
        ws_valor2 := '000000';
    end;

      ws_conteudo := ('

























                                                                                                                                  '||ws_valor1||'                                                   '||ws_valor2||'          











');
      
      htp.p(ws_conteudo);
      ws_start := ws_start+2;
      if ws_start > ws_count then
          exit;
      end if;
end loop;



end impressao_envelope;