create or replace PROCEDURE UPQ_EXP AS 
    type generic_cursor is ref cursor;
    crs_saida           generic_cursor;
   Cursor Crs_Seq Is
           SELECT TABLE_NAME FROM TABLES_TO_EXPORT;
    Ws_Seq           Crs_Seq%Rowtype;
    ws_vazio            boolean := True;
    ws_cursor           integer;
    ws_ref_cursor       sys_refcursor;
    ws_busca            varchar2(4000);
    ws_colunas          varchar2(4000);
    ws_insert           varchar2(4000);
    ws_modelo           varchar2(4000);
    ws_ct_col           integer;
    ws_counter          integer;
    ws_linhas           integer;
    ws_virgula          char(1);
    ws_lquery           number;
    ret_coluna          varchar2(2000);
   ws_query_montada   varchar2(4000);
BEGIN

        Open Crs_Seq;
        Loop
           Fetch Crs_Seq Into Ws_Seq;
                 Exit When Crs_Seq%Notfound;

                select trim(LISTAGG(COLUMN_NAME,'|') WITHIN GROUP (ORDER BY COLUMN_ID)) into ws_colunas
                from   ALL_TAB_COLUMNS
                where  TABLE_NAME = ws_seq.TABLE_NAME;

                select count(*)   into ws_ct_col
                from   table(vpipe(ws_colunas));

                select 'select '||LISTAGG(COLUMN_NAME,',')
                       WITHIN GROUP (ORDER BY COLUMN_ID)||' FROM '||ws_seq.TABLE_NAME into ws_query_montada
                from   ALL_TAB_COLUMNS
                where  TABLE_NAME = ws_seq.TABLE_NAME;

                select 'insert into '||ws_seq.TABLE_NAME||' ('||LISTAGG(COLUMN_NAME,',')
                       WITHIN GROUP (ORDER BY COLUMN_ID)||') VALUES (' into ws_modelo
                from   ALL_TAB_COLUMNS
                where  TABLE_NAME = ws_seq.TABLE_NAME;

                if  trim(ws_colunas) is not null then

                  ws_cursor := dbms_sql.open_cursor;

                    ws_vazio  := True;
                    dbms_sql.parse(ws_cursor, ws_query_montada,DBMS_SQL.NATIVE);
                    ws_linhas := dbms_sql.execute(ws_cursor);

                    ws_counter := 0;
                    loop
                        ws_counter := ws_counter + 1;
                        if  ws_counter > ws_ct_col then
                            exit;
                        end if;
                        dbms_sql.define_column(ws_cursor, ws_counter, ret_coluna, 2000);
                    end loop;

                    loop
                         ws_linhas := dbms_sql.fetch_rows(ws_cursor);
                         if  ws_linhas = 1 then
                             ws_vazio := False;
                         else
                             exit;
                         end if;

                         ws_virgula := ' ';
                         ws_counter := 0;
                         ws_insert  := ws_modelo;
                         loop

                             ws_counter := ws_counter + 1;
                             if  ws_counter > ws_ct_col then
                                 exit;
                             end if;

                            dbms_sql.column_value(ws_cursor, ws_counter, ret_coluna);
                            if  ret_coluna is null then
                                ws_insert := ws_insert||ws_virgula||'null';
                            else
                                ws_insert := ws_insert||ws_virgula||' utl_raw.cast_to_varchar2('||chr(39)||utl_raw.cast_to_raw(ret_coluna)||chr(39)||')';
                            end if;
                            ws_virgula := ',';

                        end loop;
                    
                        ws_insert := ws_insert||');';

                        htp.p(ws_insert);

                    end loop;

                      if  DBMS_SQL.is_open(ws_cursor) then
                          DBMS_SQL.close_cursor(ws_cursor);
                      end if;

                end if;
 
        End Loop;
        Close Crs_Seq;

END UPQ_EXP;
