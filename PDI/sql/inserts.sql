--------------------------------  PERGUNTAS   ------------------------------------

Insert into PDI_PERGUNTAS (CD_PERGUNTA,DS_PERGUNTA,TP_CATEGORIA,JUSTIFICATIVA,TP_FORMATO,CD_CLIENTE,CD_SETOR) values 
('1','Quando ocorrem problemas inesperados, você tem base de conhecimento para realizar pesquisas e solucionar o problema?','desenvolvimento','S','pct',fun.ret_var('CLIENTE'),'1');
----------------------------------------------------------------------------------------------------------------
Insert into PDI_PERGUNTAS (CD_PERGUNTA,DS_PERGUNTA,TP_CATEGORIA,JUSTIFICATIVA,TP_FORMATO,CD_CLIENTE,CD_SETOR) values 
('2','Quando ocorrem problemas inesperados, o coordenador tem base de conhecimento para realizar pesquisas e solucionar o problema?','produtos','S','pct',fun.ret_var('CLIENTE'),'1');
----------------------------------------------------------------------------------------------------------------
Insert into PDI_PERGUNTAS (CD_PERGUNTA,DS_PERGUNTA,TP_CATEGORIA,JUSTIFICATIVA,TP_FORMATO,CD_CLIENTE,CD_SETOR) values 
('3','Você consegue explicar problemas técnicos para outro profissional e consegue compreender as instruções que são passadas?','produtos','S','pct',fun.ret_var('CLIENTE'),'2');
----------------------------------------------------------------------------------------------------------------
Insert into PDI_PERGUNTAS (CD_PERGUNTA,DS_PERGUNTA,TP_CATEGORIA,JUSTIFICATIVA,TP_FORMATO,CD_CLIENTE,CD_SETOR) values 
('4','Você consegue explicar problemas técnicos para outro profissional e consegue compreender as instruções que são passadas?','negócio','S','pct',fun.ret_var('CLIENTE'),'2');
----------------------------------------------------------------------------------------------------------------
Insert into PDI_PERGUNTAS (CD_PERGUNTA,DS_PERGUNTA,TP_CATEGORIA,JUSTIFICATIVA,TP_FORMATO,CD_CLIENTE,CD_SETOR) values 
('5','Qual é sua experiencia no geral com a empresa?','produtos','N','aberta',fun.ret_var('CLIENTE'),'2');


--------------------------  FORMATO DAS PERGUNTAS   ------------------------------

insert into pdi_formato_perguntas ( tp_formato, cd_formato, ds_formato, cd_cliente) values
('pct', 1, 'NA - Não aplicável', fun.ret_var('CLIENTE'));
--------------------------------------------------------------------------------------------
insert into pdi_formato_perguntas ( tp_formato, cd_formato, ds_formato, cd_cliente) values
('pct', 2, '10% - Deixo muito a desejar', fun.ret_var('CLIENTE'));
--------------------------------------------------------------------------------------------
insert into pdi_formato_perguntas ( tp_formato, cd_formato, ds_formato, cd_cliente) values
('pct', 3, '25% - Encontro muitas dificuldades', fun.ret_var('CLIENTE'));
--------------------------------------------------------------------------------------------
insert into pdi_formato_perguntas ( tp_formato, cd_formato, ds_formato, cd_cliente) values
('pct', 4, '50% - Tenho compreensão razoável do assunto', fun.ret_var('CLIENTE'));
--------------------------------------------------------------------------------------------
insert into pdi_formato_perguntas ( tp_formato, cd_formato, ds_formato, cd_cliente) values
('pct', 5, '70% - Consigo compreender e lidar com muitas situações', fun.ret_var('CLIENTE'));
--------------------------------------------------------------------------------------------
insert into pdi_formato_perguntas ( tp_formato, cd_formato, ds_formato, cd_cliente) values
('pct', 6, '85% - Tenho domínio do assunto', fun.ret_var('CLIENTE'));
--------------------------------------------------------------------------------------------
insert into pdi_formato_perguntas ( tp_formato, cd_formato, ds_formato, cd_cliente) values
('pct', 7, '100% - Sou refêrencia na empresa', fun.ret_var('CLIENTE'));



--------------------------  SETORES   ------------------------------

insert into pdi_setores values (1, 'desenvolvimento', fun.ret_var('CLIENTE'));
-----------------------------------------------------------------------
insert into pdi_setores values (2, 'gerencia', fun.ret_var('CLIENTE'));



--------------------------  TIPOS DE RELACIONAMENTOS   ------------------------------

insert into pdi_tipo_relacionamento (cd_tipo,nm_relacionamento,cd_cliente) values ('1','Superior(es)',fun.ret_var('CLIENTE'));
-------------------------------------------------------------------------------------------------------------------------------
insert into pdi_tipo_relacionamento (cd_tipo,nm_relacionamento,cd_cliente) values ('2','Subordinado(s)',fun.ret_var('CLIENTE'));



--------------------------  CATEGORIAS   ------------------------------


Insert into PDI_CATEGORIAS (CD_CATEGORIA,DS_CATEGORIA,NM_CATEGORIA,TI_CATEGORIA,CD_CLIENTE) values 
('1','Refere-se a compreensão dos softwares que nós desenvolvemos. Indica a capacidade de efetuar lançamentos e realizar processos dentro do software.
Também compreende o funcionamento niterno, entendo o código fonte do sistema e a estrutura de armazenamento dos dados.','desenvolvimento','TEMA: CONHECIMENTO DAS FERRAMENTAS DE DESENVOLVIMENTO','000000027');
-------------------------------------------------------------------------------------------------------------------------------
Insert into PDI_CATEGORIAS (CD_CATEGORIA,DS_CATEGORIA,NM_CATEGORIA,TI_CATEGORIA,CD_CLIENTE) values 
('2','Refere-se a compreensão dos softwares que nós desenvolvemos.
Indica a capacidade de efetuar lançamentos e realizar processos dentro do software.
Também compreende o funcionamento interno, entndendo o código fonte do sistema e a estrutura de armazenamento dos dados. 
Oculto para quem tiver dúvidas.','produtos','TEMA: CONHECIMENTO FUNCIONAL E TÉCNICO DOS PRODUTOS QUE CRIAMOS','000000027');
-------------------------------------------------------------------------------------------------------------------------------
Insert into PDI_CATEGORIAS (CD_CATEGORIA,DS_CATEGORIA,NM_CATEGORIA,TI_CATEGORIA,CD_CLIENTE) values 
('3','Indica a compreensão dos processos que são realizados nos clientes utilizando o nosso software.
','negócio','TEMA: CONHECIMENTO DOS PROCESSOS DE NEGÓCIO','000000027');