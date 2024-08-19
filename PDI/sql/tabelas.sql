--create table pdi_html ( tp_conteudo varchar2(80), conteudo clob, cd_cliente varchar2(80) );
create table pdi_estaticos ( cd_estatico number, tp_estatico varchar2(80), conteudo clob, cd_cliente varchar2(80),cd_questionario number,  CONSTRAINT cd_estatico primary key (cd_estatico) );
----------------------------------------------------------------------------------------------------------------
create table pdi_pergunta ( cd_pergunta number, ds_pergunta varchar2(4000), ordem number, cd_setores varchar2(80), tp_categoria varchar2(200), justificativa char(1), tp_formato varchar2(80), cd_cliente varchar2(80) );
alter table pdi_pergunta add constraint cd_pergunta primary key (cd_pergunta);
----------------------------------------------------------------------------------------------------------------
create table pdi_formato_perguntas ( tp_formato varchar2(80), cd_formato number, ds_formato varchar2(200), vl_formato number, cd_cliente varchar2(80) );
alter table pdi_formato_perguntas add constraint cd_formato primary key (cd_formato);
----------------------------------------------------------------------------------------------------------------
create table pdi_tipo_questionario ( cd_questionario number, ds_questionario varchar2(80), cd_cliente varchar2(80) );
alter table pdi_tipo_questionario add constraint cd_questionario primary key (cd_questionario);
----------------------------------------------------------------------------------------------------------------
create table pdi_categorias ( cd_categoria number, ds_categoria varchar2(800), nm_categoria varchar2(80), ti_categoria varchar2(80), cd_cliente varchar2(80) );
alter table pdi_categorias add constraint cd_categoria primary key (cd_categoria);
----------------------------------------------------------------------------------------------------------------
create table pdi_usuarios ( cd_usuario number, nm_usuario varchar2(80), cd_hierarquia number, login varchar2(80), cd_setor number, telefone varchar2(20), email varchar2(40), hashcode varchar2(200), cd_questionario number, tipo varchar2(20), cd_cliente varchar2(80) );
alter table pdi_usuarios add constraint cd_usuario primary key (cd_usuario);
alter table pdi_usuarios add cd_questionario number;
----------------------------------------------------------------------------------------------------------------
create table pdi_setores  ( cd_setor number, nm_setor varchar2(120), cd_cliente varchar2(80) );
alter table pdi_setores add constraint cd_setor primary key (cd_setor);
----------------------------------------------------------------------------------------------------------------
create table pdi_relacionamento ( cd_relacionamento number, cd_usuario number, cd_usuario_avaliado number, cd_setor number, cd_cliente varchar2(80) );
alter table pdi_relacionamento add constraint cd_relacionamento primary key (cd_relacionamento);
----------------------------------------------------------------------------------------------------------------
create table pdi_tipo_relacionamento ( cd_tipo number, nm_relacionamento varchar2(80), cd_cliente varchar2(80) );
alter table pdi_tipo_relacionamento add constraint cd_tipo primary key (cd_tipo);
----------------------------------------------------------------------------------------------------------------
create table pdi_avaliacao ( cd_avaliacao number, cd_usuario number, cd_usuario_avaliado number, cd_pergunta number, justificativa clob, vl_avaliacao number, cd_cliente varchar2(80) );
alter table pdi_avaliacao add constraint cd_avaliacao primary key (cd_avaliacao);
----------------------------------------------------------------------------------------------------------------
create table pdi_hierarquia ( cd_hierarquia number, nm_hierarquia varchar2(80), cd_cliente varchar2(80) );
alter table pdi_hierarquia add constraint cd_hierarquia primary key (cd_hierarquia);
----------------------------------------------------------------------------------------------------------------
create table pdi_controle (	status varchar2(20), cd_cliente varchar2(80), ultima_alteracao date);
----------------------------------------------------------------------------------------------------------------
create table pdi_justificativa ( cd_justificativa number, cd_avaliacao number, st_thumb varchar2(4), cd_cliente varchar2(80) );
alter table pdi_justificativa add constraint cd_justificativa primary key (cd_justificativa);
----------------------------------------------------------------------------------------------------------------