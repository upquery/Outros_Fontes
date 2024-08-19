create or replace PROCEDURE Request_Progs AS

    CURSOR CRS_SEQ (PRM_DADOS clob ) IS
           SELECT COLUMN_VALUE
           FROM   TABLE(vpipe(PRM_DADOS));

    WS_SEQ  			CRS_SEQ%ROWTYPE;

    CURSOR CRS_UPSEQ (PRM_NOVA_VERSAO VARCHAR2) IS
           SELECT   SEQUENCIA,
                    VERSAO_SISTEMA,
                    NM_CONTEUDO,
                    TIPO,
                    NAME,
                    MIME_TYPE,
                    DOC_SIZE,
                    DAD_CHARSET,
                    LAST_UPDATED,
                    CONTENT_TYPE
           FROM     UPDATE_SEQUENCE
           WHERE    trim(VERSAO_SISTEMA) = '000'--trim(PRM_NOVA_VERSAO)
           ORDER BY TIPO asc, nm_conteudo desc;

    WS_UPSEQ  			CRS_UPSEQ%ROWTYPE;

    WS_PIECES        UTL_HTTP.HTML_PIECES;
    WS_PIECES_P      UTL_HTTP.HTML_PIECES;
    WS_PIECES_E      UTL_HTTP.HTML_PIECES;
    WS_PIECES_C      UTL_HTTP.HTML_PIECES;
    WS_PIECES_J      UTL_HTTP.HTML_PIECES;
    WS_PIECES_A      UTL_HTTP.HTML_PIECES;
    WS_PIECES_f      UTL_HTTP.HTML_PIECES;


    WS_DADOS         clob;
    ws_dados_padrao  clob;
    WS_TEMP          CLOB;
    WS_URL           clob;
    ws_blob          blob;
    WS_VARIAVEL      VARCHAR2(18000);
    ws_versao        varchar2(80)     := '140';
    ws_retvar        varchar2(80);
    ws_tipos         varchar2(1200);
    WS_NOVA_VERSAO   NUMBER           := NULL;
    WS_CTCOL         NUMBER;
    WS_LOB_LEN       NUMBER;
    ws_rowcount      number;
    ws_mcount        number;
    WS_COUNT         NUMBER;
    V_INTCUR         PLS_INTEGER;
    V_INTIDX         PLS_INTEGER;
    V_INTNUMROWS     PLS_INTEGER;
    LEN              PLS_INTEGER;
    V_VCSTMT         DBMS_SQL.VARCHAR2A;
    WS_ITENS         DBMS_SQL.VARCHAR2A;
    ws_cursor        integer;
    ws_exec          integer;

    ws_dest_offset    number := 1;
    ws_src_offset     number := 1;
    ws_conversao      varchar2(40) := 'AL32UTF8';
    ws_lang_context   number := 0;
    ws_warning        number;
   

    --Nested para tradução de log
    function nested_translate ( prm_texto varchar2 default null ) return varchar2 as
    begin
    
        if instr(prm_texto, 'primary key violated') > 0 then
            return 'Impossível aplicar chave primaria';
        elsif instr(prm_texto, 'name is already used by an existing object') > 0 then
            return 'Nome já esta sendo usado por outro objeto';
        elsif instr(prm_texto, 'column being added already exists') > 0 then
            return 'Coluna já existe na tabela';
        else
            return prm_texto;
        end if;
    
    
    end nested_translate;

BEGIN

    EXECUTE IMMEDIATE ('truncate table UPDATE_SEQUENCE');

    WS_CTCOL := 0;

    --Endereço da base de update
    SELECT trim(conteudo) into ws_retvar FROM VAR_CONTEUDO WHERE USUARIO = 'DWU' AND VARIAVEL = 'REQUEST_REG';

    WS_URL   :=  'http://'||ws_retvar||'/update/dwu.GET_PROGS?Prm_Senha=XXXX&Prm_Conteudo=LIST_SCRIPTS&prm_versao='||ws_versao||'&prm_tipo=GET_LIST';
    WS_PIECES :=  UTL_HTTP.REQUEST_PIECES(WS_URL,65535);
    WS_dados :=   WS_PIECES(1)||WS_PIECES(2);

    --Loop para pegar a lista de updates
    OPEN CRS_SEQ(WS_dados);
        LOOP
            FETCH CRS_SEQ INTO WS_SEQ;
            EXIT WHEN CRS_SEQ%NOTFOUND;

            WS_CTCOL := WS_CTCOL + 1;
            WS_ITENS(WS_CTCOL) := TRIM(WS_SEQ.COLUMN_VALUE);
            IF  WS_CTCOL = 10 THEN
                WS_CTCOL := 0;
                INSERT INTO UPDATE_SEQUENCE VALUES (TRIM(WS_ITENS(1)),TRIM(WS_ITENS(2)),TRIM(WS_ITENS(3)),TRIM(WS_ITENS(4)),TRIM(WS_ITENS(5)),TRIM(WS_ITENS(6)),TRIM(WS_ITENS(7)),TRIM(WS_ITENS(8)),TO_DATE(NVL(TRIM(WS_ITENS(9)),'010199'),'ddmmyy'),TRIM(WS_ITENS(10)));
                ws_versao := WS_ITENS(2);
                COMMIT;
            END IF;

        END LOOP;   
    CLOSE CRS_SEQ;
    
    htp.p('<html>');
    
        htp.p('<head>');
            htp.p('<style>table { width: 100%; font-family: tahoma; } table tr th { position: sticky;top: 0;background: #FFF; font-size: 20px; } table tr td { border: 1px solid #333; padding: 2px; }</style>');
        htp.p('</head>');
        
        htp.p('<body>');    
            htp.p('<table>');
            
                htp.p('<thead>');
                    htp.p('<tr>');
                        htp.p('<th>NOME</th>');
                        htp.p('<th>TIPO</th>');
                        htp.p('<th>SITUAÇÃO</th>');
                    htp.p('</tr>');
                htp.p('</thead>');
                
                htp.p('<tbody>');
        
                    --Loop principal da tabela upgrade_system
                    OPEN CRS_UPSEQ(ws_versao);
                        LOOP
                            FETCH CRS_UPSEQ INTO WS_UPSEQ;
                            EXIT WHEN CRS_UPSEQ%NOTFOUND;
                            
                            begin
                                WS_URL    := 'http://'||ws_retvar||'/update/dwu.get_progs?Prm_Senha=XXXX&Prm_Conteudo='||TRIM(WS_UPSEQ.NM_CONTEUDO)||'&prm_versao='||TRIM(WS_UPSEQ.VERSAO_SISTEMA)||'&prm_tipo='||TRIM(WS_UPSEQ.TIPO);
                                WS_PIECES :=  UTL_HTTP.REQUEST_PIECES(WS_URL,65535);
                            exception when others then
                               exit;
                            end;
                
                            htp.p('<tr>');
                            
                            htp.p('<td>'||upper(ws_upseq.nm_conteudo)||'</td>');
                            
                            htp.p('<td>'||ws_upseq.TIPO||'</td>');
                
                            --Cria as packages, procedures e functions
                            begin
                                IF  ws_upseq.tipo IN ('PROCEDURE','PACKAGE_SPEC','PACKAGE_BODY','FUNCTION') THEN
                                    LEN := 1;
                                    V_VCSTMT(LEN) := '';
                
                                    FOR I IN 1..WS_PIECES.COUNT LOOP
                
                                        IF  INSTR(WS_PIECES(I),CHR(10)) = 0 THEN
                                            V_VCSTMT(LEN) := V_VCSTMT(LEN)||SUBSTR(WS_PIECES(I),1,LENGTH(WS_PIECES(I)));
                                        ELSE
                                            V_VCSTMT(LEN) := V_VCSTMT(LEN)||SUBSTR(WS_PIECES(I),1,INSTR(WS_PIECES(I),CHR(10)));
                                            LEN := LEN + 1;
                                            V_VCSTMT(LEN) := '';
                                            V_VCSTMT(LEN) := V_VCSTMT(LEN)||SUBSTR(WS_PIECES(I),(INSTR(WS_PIECES(I),CHR(10))+1),LENGTH(WS_PIECES(I)));
                                        END IF;
                
                                    END LOOP;
                
                                    V_INTIDX := LEN;
                                    V_INTCUR := DBMS_SQL.OPEN_CURSOR;
                                    DBMS_SQL.PARSE( C => V_INTCUR, STATEMENT => V_VCSTMT, LB => 1, UB => V_INTIDX, LFFLG => FALSE, LANGUAGE_FLAG => DBMS_SQL.NATIVE);
                                    V_INTNUMROWS := DBMS_SQL.EXECUTE(V_INTCUR);
                                    DBMS_SQL.CLOSE_CURSOR(V_INTCUR);
                                    htp.p('<td>OK</td>');
                                END IF;
                               
                            exception when others then
                              htp.p('<td>'||nested_translate(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE)||'</td>');
                          end;
                          
                          
                          --Insere na tab_documentos os arquivos de css, js e imagens
                          BEGIN
                            IF  WS_UPSEQ.TIPO = 'DOCUMENTO' THEN
                                WS_TEMP := '';
                                LEN := 0;
                                FOR I IN 1..WS_PIECES.COUNT LOOP
                                    WS_TEMP := WS_TEMP||WS_PIECES(I);
                                END LOOP;
                                DELETE FROM TAB_DOCUMENTOS WHERE NAME = WS_UPSEQ.NAME;
                                COMMIT;
                                INSERT INTO TAB_DOCUMENTOS VALUES (WS_UPSEQ.NAME,WS_UPSEQ.MIME_TYPE,WS_UPSEQ.DOC_SIZE,WS_UPSEQ.DAD_CHARSET,WS_UPSEQ.LAST_UPDATED,WS_UPSEQ.CONTENT_TYPE,C2B(WS_TEMP), USER);
                                COMMIT;
                                htp.p('<td>OK</td>');
                            END IF;
                            
                            exception when others then
                              htp.p('<td>'||nested_translate(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE)||'</td>');
                          end;
                
                          --Executa os tipos script como create e insert
                          begin
                            IF  WS_UPSEQ.TIPO = 'SCRIPT' THEN
                                WS_TEMP := '';
                                LEN := 0;
                                FOR I IN 1..WS_PIECES.COUNT LOOP
                                    WS_TEMP := WS_TEMP||WS_PIECES(I);
                                END LOOP;
                                EXECUTE IMMEDIATE WS_TEMP;
                                COMMIT;
                                htp.p('<td>OK</td>');
                            END IF;
                          exception when others then
                              htp.p('<td>'||nested_translate(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE)||'</td>');
                          end;
                                       
                          htp.p('</tr>');
                          
                
                    END LOOP;   
                    CLOSE CRS_UPSEQ;
                    
                htp.p('</tbody>');
        
             htp.p('</table>');
         
             WS_URL := '';
             
             --Pega lista de tipos dos padrões
             begin
                 WS_URL    := 'http://'||ws_retvar||'/update/dwu.get_padroes?prm_tipo=';
                 WS_TIPOS  :=  utl_http.request(WS_URL);
             exception when others then
                 htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
             end;
             
             delete from bi_object_padrao;
             ws_rowcount := sql%rowcount;
             
             --Testa e mostra o número de linhas do bi_object_padrão excluidas
             if ws_rowcount <> 0 then
                 htp.p('<h4>Foram excluidos '||ws_rowcount||' registros da tabela de padrões</h4>');
                 commit;
             end if;
        
             --Loop dos tipos para inserir
             for t in(select column_value as tipo from table((vpipe(WS_TIPOS, ',')))) loop
                 ws_dados_padrao := '';
                 
                 begin
                     
                     WS_URL    := 'http://'||ws_retvar||'/update/dwu.get_padroes?prm_tipo='||t.tipo;
                     WS_PIECES_P :=  UTL_HTTP.REQUEST_PIECES(WS_URL,20000);
                     
                     FOR I IN 1..WS_PIECES_P.COUNT LOOP
                          ws_dados_padrao :=   ws_dados_padrao||WS_PIECES_P(i);
                     end loop;
                
                     execute immediate 'begin '||ws_dados_padrao||' end;';
                 exception when others then
                     exit;
                 end;
                 
             end loop;
             
             commit;
             
             --Testa e mostra o número de linhas do bi_object_padrão incluidas
             select count(*) into ws_rowcount from bi_object_padrao;
             
             if ws_rowcount <> 0 then
                 htp.p('<h4>Foram incluidos '||ws_rowcount||' registros na tabela de padrões</h4>');
                 commit;
             end if;
         
         htp.p('</body>');
         
    htp.p('</html>');




    ------------------------------------ MAPAS ------------------------------------------



    -------------- ESTADOS -----------------

    --verifica se tabela existe
    select count(*) into ws_mcount from all_objects where object_name = 'BI_ESTADOS_BRASIL';

    if ws_mcount = 0 then

        execute immediate 'CREATE TABLE BI_ESTADOS_BRASIL ( CD_ESTADO VARCHAR2(2), NM_ESTADO VARCHAR2(200), JSON CLOB, SEQUENCIA NUMBER);';
        commit;

    end if;

    --verifica dados do mapa
    select count(*) into ws_mcount from bi_estados_brasil;
    
    if ws_mcount = 0 then
    
        ws_dados_padrao := '';
        
        WS_URL    := 'http://'||ws_retvar||'/update/dwu.get_padroes?prm_tipo=ESTADOS';
        WS_PIECES_E :=  UTL_HTTP.REQUEST_PIECES(WS_URL,40000);
        
        FOR e IN 1..WS_PIECES_E.COUNT LOOP
            ws_dados_padrao :=   ws_dados_padrao||WS_PIECES_E(e);
        end loop;

        --insert de estados e sequencias
        execute immediate 'begin '||ws_dados_padrao||' end;';
        commit;

    end if;

    --verifica se json é nulo se sim pega dados da base 
    for e in (select cd_estado, sequencia from bi_estados_brasil where json is null order by sequencia asc) loop

        ws_url          := '';
        ws_dados_padrao := '';

        WS_URL    := ('http://'||ws_retvar||'/update/dwu.get_padroes?prm_tipo=ESTADO&prm_chave='||e.cd_estado||'&prm_sequence='||e.sequencia);
        WS_PIECES_J :=  UTL_HTTP.REQUEST_PIECES(WS_URL, 40000);

        FOR p IN 1..WS_PIECES_j.COUNT LOOP
            ws_dados_padrao :=   ws_dados_padrao||WS_PIECES_j(p);
        end loop;

        update bi_estados_brasil 
        set json = ws_dados_padrao
        where cd_estado = e.cd_estado and
        sequencia = e.sequencia;
        commit;

    end loop;

    ws_url          := '';

    ------------- CIDADES --------------

    --verifica se tabela existe
    select count(*) into ws_mcount from all_objects where object_name = 'BI_CIDADES_BRASIL';

    if ws_mcount = 0 then

        execute immediate 'CREATE TABLE BI_CIDADES_BRASIL 
        ( CD_CIDADE NUMBER, NM_CIDADE VARCHAR2(200), CD_ESTADO VARCHAR2(2), NM_ESTADO VARCHAR2(200), JSON CLOB, SEQUENCIA NUMBER);';
        commit;

    end if;

    --verifica dados do mapa
    select count(*) into ws_mcount from bi_cidades_brasil;
    
    if ws_mcount = 0 then
    
        ws_dados_padrao := '';
        
        WS_URL    := 'http://'||ws_retvar||'/update/dwu.get_padroes?prm_tipo=CIDADES';
        WS_PIECES_C :=  UTL_HTTP.REQUEST_PIECES(WS_URL, 40000);
        
        FOR c IN 1..WS_PIECES_C.COUNT LOOP
            ws_dados_padrao :=   ws_dados_padrao||WS_PIECES_C(c);
        end loop;

        --htp.p(ws_dados_padrao);

        --insert de cidades e sequencias
        execute immediate 'begin '||ws_dados_padrao||' end;';
        commit;

    end if;

    --verifica se json é nulo se sim pega dados da base 
    for c in (select cd_cidade, sequencia from bi_cidades_brasil where json is null order by sequencia asc) loop

        ws_url          := '';
        ws_dados_padrao := '';

        WS_URL    := 'http://'||ws_retvar||'/update/dwu.get_padroes?prm_tipo=CIDADE&prm_chave='||c.cd_cidade||'&prm_sequence='||c.sequencia;
        WS_PIECES_J :=  UTL_HTTP.REQUEST_PIECES(WS_URL, 40000);

        FOR p IN 1..WS_PIECES_j.COUNT LOOP
            ws_dados_padrao :=   ws_dados_padrao||WS_PIECES_j(p);
        end loop;

        update bi_cidades_brasil 
        set json = ws_dados_padrao
        where cd_cidade = c.cd_cidade and
        sequencia = c.sequencia;
        commit;

    end loop;



    ------------------------------------ ARQUIVOS ------------------------------------------

    begin

        ws_dados_padrao := '';
        
        delete from tab_documentos where usuario = 'SYS'; 
        
        WS_URL    := 'http://'||ws_retvar||'/update/dwu.get_padroes?prm_tipo=ARQUIVOS';
        WS_PIECES_A :=  UTL_HTTP.REQUEST_PIECES(WS_URL, 40000);

        FOR A IN 1..WS_PIECES_A.COUNT LOOP
            ws_dados_padrao :=   ws_dados_padrao||WS_PIECES_A(A);
        end loop;

        execute immediate 'begin '||ws_dados_padrao||' end;';

        commit;

        for f in(select name from tab_documentos where usuario = 'SYS' and blob_content is null) loop

            ws_url          := '';
            ws_dados_padrao := '';

            WS_URL    := 'http://'||ws_retvar||'/update/dwu.get_padroes?prm_tipo=ARQUIVO&prm_chave='||f.name;
            WS_PIECES_f :=  UTL_HTTP.REQUEST_PIECES(WS_URL, 40000);

            FOR l IN 1..WS_PIECES_f.COUNT LOOP
                ws_dados_padrao :=   ws_dados_padrao||WS_PIECES_f(l);
            end loop;

            select VALUE into ws_conversao
            from NLS_DATABASE_PARAMETERS
            where PARAMETER='NLS_CHARACTERSET';

            ws_dest_offset := 1;
            ws_src_offset := 1;
            ws_lang_context := 0;

            --força nls dar update, 178 é nls_charset_id('WE8MSWIN1252')

            dbms_lob.createtemporary(ws_blob, true, dbms_lob.call);
            dbms_lob.converttoblob(ws_blob, ws_dados_padrao, dbms_lob.lobmaxsize, ws_dest_offset, ws_src_offset, 178, ws_lang_context, ws_warning);

            update tab_documentos 
            set blob_content = ws_blob
            where name = f.name and usuario = 'SYS';
            commit;

        end loop;

    exception when others then
        htp.p(sqlerrm);
        rollback;
    end;

    
exception when others then
    htp.p(DBMS_UTILITY.FORMAT_ERROR_STACK||' - '||DBMS_UTILITY.FORMAT_ERROR_BACKTRACE);
END REQUEST_PROGS;