create or replace procedure relatorio_diario ( prm_cliente   varchar2 default null,
                                               prm_inicio    number   default null,
                                               prm_intervalo number   default null,
                                               prm_email     varchar2 default null ) as 
    
    cursor crs_atendimento is
    select cd_local, t1.cd_cliente, nr_item, cd_analista, ds_atendimento, trim(trunc((dt_termino-dt_inicio)*24)||':'||trim(to_char(60*(((dt_termino-dt_inicio)*24)-trunc((dt_termino-dt_inicio)*24)), '00'))) as horas, km_final, 
    km_inicial, nvl(cod_chamado, 'N/A') as cod_chamado, to_char(dt_inicio, 'HH24:MI') as dt_inicio, to_char(dt_termino, 'HH24:MI') as dt_termino, total_km as km,
    t2.nm_cliente as cliente, to_char(dt_inicio, 'DD/MM') as dia
    from opr_atendimento t1
    left join opr_clientes t2 on t1.cd_cliente = t2.cd_cliente
    where t1.dt_inicio > (sysdate-nvl(prm_inicio, 1)) and t1.dt_inicio < (sysdate-nvl(prm_inicio, 1)+nvl(prm_intervalo, 1)) and t1.cd_cliente in (select nvl(column_value, t1.cd_cliente) from table(fun.vpipe(prm_cliente)))  and dt_termino is not null and st_cobranca = 'S'
    order by cd_cliente, cd_analista, dia, dt_inicio;
    
    ws_atendimento crs_atendimento%rowtype;
    
    ws_cliente_grupo varchar2(200);
    ws_executadas    nvarchar2(16000);
    ws_email         varchar2(200);
    ws_cabecalho     varchar2(200);
    ws_info          varchar2(200);
    ws_br            varchar2(200);
    ws_info_ativ     varchar2(200);
    ws_atividades    varchar2(28000);
    ws_total_horas   varchar2(200);
    ws_total_km      varchar2(200);
    ws_dia           varchar2(200);
    ws_total         varchar2(300);
    Mail_Conn        utl_smtp.connection;
    Ws_Msg           varchar2(32000);
    l_boundary       varchar2(50) := '----=*#abc1234321cba#*=';
    
begin
     
     select to_char(sysdate-(1/24), 'DD/MM') into ws_dia from dual;
     ws_cliente_grupo := '';
     ws_br            := '<tr><td colspan="7"></td></tr>';
     ws_total         := '<tr><td colspan="7"></td></tr>';
     ws_info          := '<tr><td colspan="7"><b>RELAT&Oacute;RIO DE ATIVIDADES TARIFADAS CONFORME CONTRATO<b></td></tr>';
     ws_cabecalho     := '<tr><td>CHAMADO</td><td>ANALISTA</td><td>DIA</td><td>IN&Iacute;CIO</td><td>FINAL</td><td>HORAS</td><td>KM</td></tr>';
     ws_info_ativ     := '<tr><td colspan="7"><strong>ATIVIDADES DESENVOLVIDAS<strong></td></tr>';
     
     open crs_atendimento;
         loop
             fetch crs_atendimento into ws_atendimento;
             exit when crs_atendimento%notfound;
             if ws_atendimento.cd_cliente <> nvl(ws_cliente_grupo, 'N/A') then
                 if nvl(ws_cliente_grupo, 'N/A') <> 'N/A' then
                     select trim(trunc(sum(dt_termino-dt_inicio)*24)||':'||trim(to_char(trunc(60*(sum(dt_termino-dt_inicio)*24-trunc(sum(dt_termino-dt_inicio)*24))), '00'))), sum(total_km) into ws_total_horas, ws_total_km from opr_atendimento where dt_inicio > (sysdate-nvl(prm_inicio, 1)) and dt_inicio < (sysdate-nvl(prm_inicio, 1)+nvl(prm_intervalo, 1)) and dt_termino is not null and st_cobranca = 'S' and trim(cd_cliente) = ws_cliente_grupo;
                     --select trim(trunc(sum(dt_termino-dt_inicio)*24)||':'||trim(to_char(trunc(60*(sum(dt_termino-dt_inicio)*24-trunc(sum(dt_termino-dt_inicio)*24))), '00'))), sum(total_km) into ws_total_horas, ws_total_km from opr_atendimento where dt_inicio > sysdate-4.5 and trim(cd_cliente) = '000000048' and dt_inicio < sysdate and dt_termino is not null and st_cobranca = 'S';
                     
                     if nvl(prm_email, 'N/A') <> 'N/A' then
                         aux.xsend_mail('', prm_email, 'UPQUERY - ATIVIDADES EXECUTADAS ', '<table style="font-family: courier;">'||ws_br||ws_info||ws_br||ws_br||ws_br||ws_br||ws_br||ws_executadas||ws_br||ws_br||ws_total||'<tr><td>TOTAL</td><td></td><td></td><td></td><td></td><td><b>'||ws_total_horas||'</b></td><td>'||ws_total_km||'</td></tr>'||ws_br||ws_br||ws_br||ws_br||ws_br||ws_br||ws_info_ativ||ws_br||ws_br||'</table><table>'||ws_atividades||'</table>');
                     else
                         for ml in(select email from opr_contatos_relatorios where cd_cliente = ws_cliente_grupo and st_rel_diario = 'S') loop
                             aux.xsend_mail('', 'fabiano@upquery.com', 'UPQUERY - ATIVIDADES EXECUTADAS('||ml.email||') ', '<table style="font-family: courier;">'||ws_br||ws_info||ws_br||ws_br||ws_br||ws_br||ws_executadas||ws_br||ws_br||ws_total||'<tr><td>TOTAL</td><td></td><td></td><td></td><td></td><td><b>'||ws_total_horas||'</b></td><td>'||ws_total_km||'</td></tr>'||ws_br||ws_br||ws_br||ws_br||ws_br||ws_br||ws_info_ativ||ws_br||ws_br||'</table><table>'||ws_atividades||'</table>');
                             aux.xsend_mail('', 'suporte@upquery.com', 'UPQUERY - ATIVIDADES EXECUTADAS('||ml.email||') ', '<table style="font-family: courier;">'||ws_br||ws_info||ws_br||ws_br||ws_br||ws_br||ws_executadas||ws_br||ws_br||ws_total||'<tr><td>TOTAL</td><td></td><td></td><td></td><td></td><td><b>'||ws_total_horas||'</b></td><td>'||ws_total_km||'</td></tr>'||ws_br||ws_br||ws_br||ws_br||ws_br||ws_br||ws_info_ativ||ws_br||ws_br||'</table><table>'||ws_atividades||'</table>');
                             aux.xsend_mail('', ml.email, 'UPQUERY - ATIVIDADES EXECUTADAS ', '<table style="font-family: courier;">'||ws_br||ws_info||ws_br||ws_br||ws_br||ws_br||ws_executadas||ws_br||ws_br||ws_total||'<tr><td>TOTAL</td><td></td><td></td><td></td><td></td><td><b>'||ws_total_horas||'</b></td><td>'||ws_total_km||'</td></tr>'||ws_br||ws_br||ws_br||ws_br||ws_br||ws_br||ws_info_ativ||ws_br||ws_br||'</table><table>'||ws_atividades||'</table>');
                         end loop;
                     end if;
                 end if;
                 ws_cliente_grupo := ws_atendimento.cd_cliente;
                 ws_executadas := '<tr><td colspan="7">CLIENTE: <strong>'||ws_atendimento.cliente||'</strong></td></tr>'||ws_br||ws_br||ws_br||ws_cabecalho||ws_br||'<tr><td style="font-family: courier;">'||ws_atendimento.cod_chamado||'</td><td style="font-family: courier;">'||trim(replace(ws_atendimento.cd_analista, ' ', ''))||'</td><td style="font-family: courier;">'||ws_atendimento.dia||'</td><td style="font-family: courier;">'||ws_atendimento.dt_inicio||'</td><td style="font-family: courier;">'||ws_atendimento.dt_termino||'</td><td style="font-family: courier;">'||ws_atendimento.horas||'</td><td style="font-family: courier;">'||ws_atendimento.km||'</td></tr>';
                 ws_atividades := '<tr><td colspan="7" style="font-family: courier;">'||translate(trim(ws_atendimento.ds_atendimento), 'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu', 'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu')||'</td></tr>';
             else
                 ws_executadas := ws_executadas||ws_br||ws_br||'<tr><td style="font-family: courier;">'||ws_atendimento.cod_chamado||'</td><td style="font-family: courier;">'||trim(replace(ws_atendimento.cd_analista, ' ', ''))||'</td><td style="font-family: courier;">'||ws_atendimento.dia||'</td><td style="font-family: courier;">'||ws_atendimento.dt_inicio||'</td><td style="font-family: courier;">'||ws_atendimento.dt_termino||'</td><td style="font-family: courier;">'||ws_atendimento.horas||'</td><td style="font-family: courier;">'||ws_atendimento.km||'</td></tr>';
                 ws_atividades := ws_atividades||'<tr><td colspan="7" style="font-family: courier;">'||translate(trim(ws_atendimento.ds_atendimento), 'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu', 'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu')||'</td></tr>';

             end if;
         end loop;
    close crs_atendimento;


    select trim(trunc(sum(dt_termino-dt_inicio)*24)||':'||trim(to_char(trunc(60*(sum(dt_termino-dt_inicio)*24-trunc(sum(dt_termino-dt_inicio)*24))), '00'))), sum(total_km) into ws_total_horas, ws_total_km from opr_atendimento where dt_inicio > (sysdate-nvl(prm_inicio, 1)) and dt_inicio < (sysdate-nvl(prm_inicio, 1)+nvl(prm_intervalo, 1)) and dt_termino is not null and st_cobranca = 'S'  and trim(cd_cliente) = ws_cliente_grupo;
    --select trim(trunc(sum(dt_termino-dt_inicio)*24)||':'||trim(to_char(trunc(60*(sum(dt_termino-dt_inicio)*24-trunc(sum(dt_termino-dt_inicio)*24))), '00'))), sum(total_km) into ws_total_horas, ws_total_km from opr_atendimento where dt_inicio > sysdate-4.5 and trim(cd_cliente) = '000000048' and dt_inicio < sysdate and dt_termino is not null and st_cobranca = 'S';
    --ULTIMA LINHA
    
    if nvl(prm_email, 'N/A') <> 'N/A' then
       aux.xsend_mail('', prm_email, 'UPQUERY - ATIVIDADES EXECUTADAS ', '<table style="font-family: courier;">'||ws_br||ws_info||ws_br||ws_br||ws_br||ws_br||ws_br||ws_executadas||ws_br||ws_br||ws_total||'<tr><td>TOTAL</td><td></td><td></td><td></td><td></td><td><b>'||ws_total_horas||'</b></td><td>'||ws_total_km||'</td></tr>'||ws_br||ws_br||ws_br||ws_br||ws_br||ws_br||ws_info_ativ||ws_br||ws_br||'</table><table>'||ws_atividades||'</table>');
    else
        for ml2 in(select email from opr_contatos_relatorios where cd_cliente = ws_cliente_grupo and st_rel_diario = 'S') loop
            aux.xsend_mail('', 'fabiano@upquery.com', 'UPQUERY - ATIVIDADES EXECUTADAS('||ml2.email||') ', '<table style="font-family: courier;">'||ws_br||ws_info||ws_br||ws_br||ws_br||ws_br||ws_br||ws_executadas||ws_br||ws_br||ws_total||'<tr><td>TOTAL</td><td></td><td></td><td></td><td></td><td><b>'||ws_total_horas||'</b></td><td>'||ws_total_km||'</td></tr>'||ws_br||ws_br||ws_br||ws_br||ws_br||ws_br||ws_info_ativ||ws_br||ws_br||'</table><table>'||ws_atividades||'</table>');
            aux.xsend_mail('', 'suporte@upquery.com', 'UPQUERY - ATIVIDADES EXECUTADAS('||ml2.email||') ', '<table style="font-family: courier;">'||ws_br||ws_info||ws_br||ws_br||ws_br||ws_br||ws_br||ws_executadas||ws_br||ws_br||ws_total||'<tr><td>TOTAL</td><td></td><td></td><td></td><td></td><td><b>'||ws_total_horas||'</b></td><td>'||ws_total_km||'</td></tr>'||ws_br||ws_br||ws_br||ws_br||ws_br||ws_br||ws_info_ativ||ws_br||ws_br||'</table><table>'||ws_atividades||'</table>');
            aux.xsend_mail('', ml2.email, 'UPQUERY - ATIVIDADES EXECUTADAS ', '<table style="font-family: courier;">'||ws_br||ws_info||ws_br||ws_br||ws_br||ws_br||ws_br||ws_executadas||ws_br||ws_br||ws_total||'<tr><td>TOTAL</td><td></td><td></td><td></td><td></td><td><b>'||ws_total_horas||'</b></td><td>'||ws_total_km||'</td></tr>'||ws_br||ws_br||ws_br||ws_br||ws_br||ws_br||ws_info_ativ||ws_br||ws_br||'</table><table>'||ws_atividades||'</table>');
        end loop;
    end if;







    --email dentro do exec para teste
    --begin

			/*
            mail_conn := utl_smtp.open_connection(nvl(trim(fun.ret_var('CORREIO')), 'smtp.upquery.com'), nvl(trim(fun.ret_var('CORREIO_PORT')), '587'));
			Utl_Smtp.Helo(Mail_Conn, nvl(trim(fun.ret_var('CORREIO')), 'smtp.upquery.com'));

			Utl_Smtp.Command( Mail_Conn, 'AUTH LOGIN');
			Utl_Smtp.Command( Mail_Conn, Utl_Raw.Cast_To_Varchar2( Utl_Encode.Base64_Encode( Utl_Raw.Cast_To_Raw(nvl(trim(fun.ret_var('CORREIO_USER')), 'dwu@upquery.com')))) );
			Utl_Smtp.Command( Mail_Conn, Utl_Raw.Cast_To_Varchar2( Utl_Encode.Base64_Encode( Utl_Raw.Cast_To_Raw(nvl(trim(fun.ret_var('CORREIO_PASS')), 'ao5m3d9xk9s932s')))) );
            */
            
            --insert into err_txt_joao values(ws_atividades);

           	--ws_atividades  := translate(trim(ws_atividades), 'ACEIOUAEIOUAEIOUAOEUaceiouaeiouaeiouaoeu', '&Aacute;&Ccedil;&Eacute;&Iacute;&Oacute;&Uacute;&Agrave;&Egrave;&Igrave;&Ograve;&Ugrave;&Acirc;&Ecirc;&Icirc;&Ocirc;&Ucirc;&Atilde;&Otilde;&Euml;&Uuml;&aacute;&ccedil;&eacute;&iacute;&oacute;&uacute;&agrave;&egrave;&igrave;&ograve;&ugrave;&acirc;&ecirc;&icirc;&ocirc;&ucirc;&atilde;&otilde;&euml;&uuml;');


			/*Ws_Msg:= ('Date: '||to_char(Sysdate, 'dd Mon yy hh24:mi:ss')||UTL_TCP.crlf||'From: UPQUERY <'||trim(ret_var('CORREIO_USER'))||'>'||UTL_TCP.crlf ||  'Subject: UPQUERY - ATIVIDADES EXECUTADAS DO DIA '||ws_dia||UTL_TCP.crlf ||  'To: <'||i.email||'>'||
						'            MIME-Version: 1.0'||UTL_TCP.crlf
						||'Content-Type: multipart/alternative; boundary="'||l_boundary||'"'||UTL_TCP.crlf||UTL_TCP.crlf
						||'--' ||l_boundary ||UTL_TCP.crlf||'Content-Type: text/html; charset="UTF-8"'||UTL_TCP.crlf||UTL_TCP.crlf
						||'<table style="font-family: courier;">'||ws_br||ws_info||ws_br||ws_br||ws_br||ws_br||ws_br||ws_executadas||ws_br||ws_br||ws_total||'<tr><td colspan="4">TOTAL</td><td><b>'||ws_total_horas||'</b></td><td>'||ws_total_km||'</td></tr>'||ws_br||ws_br||ws_br||ws_br||ws_br||ws_br||ws_info_ativ||ws_br||ws_br||ws_atividades||'</table>'||UTL_TCP.crlf||'--'||l_boundary||'--'||UTL_TCP.crlf);
		   */
           -- utl_mail.send(sender => nvl(trim(fun.ret_var('CORREIO_USER')), 'dwu@upquery.com'), recipients => i.email, subject => 'UPQUERY - ATIVIDADES EXECUTADAS DO DIA '||ws_dia, message => '<table style="font-family: courier;">'||ws_br||ws_info||ws_br||ws_br||ws_br||ws_br||ws_br||ws_executadas||ws_br||ws_br||ws_total||'<tr><td colspan="4">TOTAL</td><td><b>'||ws_total_horas||'</b></td><td>'||ws_total_km||'</td></tr>'||ws_br||ws_br||ws_br||ws_br||ws_br||ws_br||ws_info_ativ||ws_br||ws_br||ws_atividades||'</table>');
           
			/*utl_smtp.helo(mail_conn, nvl(trim(fun.ret_var('CORREIO')), 'smtp.upquery.com'));
			Utl_Smtp.Mail(Mail_Conn, '<'||nvl(trim(fun.ret_var('CORREIO_USER')), 'dwu@upquery.com')||'>');
			Utl_Smtp.Rcpt(Mail_Conn, '<'||i.email||'>');
			UTL_SMTP.data(Mail_Conn, Ws_Msg);

			Utl_Smtp.Quit(Mail_Conn);
            */
	   -- end;
    
    
    
    
    
end relatorio_diario;