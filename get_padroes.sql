create or replace procedure get_padroes ( prm_tipo     varchar2 default null,
                                          prm_chave    varchar2 default null,
                                          prm_sequence number   default null ) as

    cursor crs_padroes is select TP_OBJETO, CD_PROP, CD_TIPO, LABEL, VL_DEFAULT, SUFIXO, SCRIPT, VALIDACAO, ST_PERSONALIZADO, ORDEM, GRUPO, HINT 
    from bi_object_padrao
    where upper(trim(TP_OBJETO)) = upper(trim(prm_tipo));
    ws_padrao crs_padroes%rowtype;

    cursor crs_estados is select cd_estado, nm_estado, json, sequencia from 
    bi_estados_brasil;
    ws_estado crs_estados%rowtype;
    
    cursor crs_cidades is 
    select cd_cidade, replace(nm_cidade, chr(39), '') as nm_cidade, cd_estado, 
    nm_estado, sequencia
    from bi_cidades_brasil;
    ws_cidade crs_cidades%rowtype;
    
    cursor crs_arquivos is
    select NAME, MIME_TYPE, DOC_SIZE, DAD_CHARSET, 
    LAST_UPDATED, CONTENT_TYPE, BLOB_CONTENT
    from tab_documentos
    where usuario = 'SYS' and BLOB_CONTENT is not null;
    ws_arquivo crs_arquivos%rowtype;

    ws_lista varchar2(800);
    ws_json  clob;
    ws_blob  blob;

    ws_dest_offset    number := 1;
    ws_src_offset     number := 1;
    ws_conversao      varchar2(40) := 'WE8MSWIN1252';
    ws_lang_context   number := 0;
    ws_warning        number;

begin

    if nvl(prm_tipo, 'N/A') = 'N/A' then

        select listagg(tp_objeto, ',') within group (order by tp_objeto) into ws_lista from(select distinct tp_objeto from bi_object_padrao);
        htp.p(upper(trim(ws_lista))||',');
        
    elsif prm_tipo = 'ARQUIVOS' then
    
        open crs_arquivos;
            loop
                fetch crs_arquivos into ws_arquivo;
                exit when crs_arquivos%notfound;
                   htp.p('insert into tab_documentos values('''||ws_arquivo.NAME||''', '''||ws_arquivo.MIME_TYPE||''', '''||ws_arquivo.DOC_SIZE||''', '''||ws_arquivo.DAD_CHARSET||''', '''||ws_arquivo.LAST_UPDATED||''', '''||ws_arquivo.CONTENT_TYPE||''', '''', ''SYS'');');
            end loop;
        close crs_arquivos;
    elsif prm_tipo = 'ARQUIVO' then

        select VALUE into ws_conversao
        from NLS_DATABASE_PARAMETERS
        where PARAMETER='NLS_CHARACTERSET';
    
        select blob_content into ws_blob from tab_documentos where name = prm_chave;
        dbms_lob.createtemporary(ws_json, true, dbms_lob.call);
        dbms_lob.converttoclob(ws_json, ws_blob, dbms_lob.lobmaxsize, ws_dest_offset, ws_src_offset, nls_charset_id(ws_conversao), ws_lang_context, ws_warning);
        htp.p(ws_json);
    
    elsif prm_tipo = 'CIDADES' then

         open crs_cidades;
            loop
                fetch crs_cidades into ws_cidade;
                exit when crs_cidades%notfound;
                    htp.p('insert into bi_cidades_brasil values ('''||ws_cidade.cd_cidade||''', '''||ws_cidade.nm_cidade||''', '''||ws_cidade.cd_estado||''', '''||ws_cidade.nm_estado||''', '''', '''||ws_cidade.sequencia||''');');
            end loop;
        close crs_cidades;
        
    elsif prm_tipo = 'CIDADE' then
    
        select json into ws_json from bi_cidades_brasil where cd_cidade = prm_chave and sequencia = prm_sequence;
        htp.p(ws_json);
        
    elsif prm_tipo = 'ESTADOS' then

         open crs_estados;
            loop
                fetch crs_estados into ws_estado;
                exit when crs_estados%notfound;
                    htp.p('insert into bi_estados_brasil values ('''||ws_estado.cd_estado||''', '''||ws_estado.nm_estado||''', '''', '''||ws_estado.sequencia||''');');
            end loop;
        close crs_estados;

    elsif prm_tipo = 'ESTADO' then
    
        select json into ws_json from bi_estados_brasil where cd_estado = prm_chave and sequencia = prm_sequence;
        htp.p(ws_json);
        
    else

        open crs_padroes;
            loop
                fetch crs_padroes into ws_padrao;
                exit when crs_padroes%notfound;
                    htp.p('Insert into BI_OBJECT_PADRAO values ('''||ws_padrao.TP_OBJETO||''', '''||ws_padrao.CD_PROP||''', '''||ws_padrao.CD_TIPO||''', '''||ws_padrao.LABEL||''', '''||ws_padrao.VL_DEFAULT||''',
                    '''||ws_padrao.SUFIXO||''', '''||ws_padrao.SCRIPT||''', '''||ws_padrao.VALIDACAO||''', '''||ws_padrao.ST_PERSONALIZADO||''', '''||ws_padrao.ORDEM||''',
                    '''||ws_padrao.GRUPO||''', '''||ws_padrao.HINT||''');');
            end loop;
        close crs_padroes;

    end if;

end get_padroes;