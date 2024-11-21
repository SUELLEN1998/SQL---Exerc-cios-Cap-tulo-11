

--Laborat�rio 1

--A--Usando o banco de dados PEDIDOS

--1. Apresentar os cargos que n�o possuem associa��o na tabela de empregado
 SELECT COD_CARGO
 FROM TB_CARGO
 EXCEPT
 SELECT COD_CARGO
 FROM TB_EMPREGADO

 
--2. Criar a tabela TB_MAIOR_SALARIO
 SELECT COD_DEPTO
     , NOME 
  , DATA_NASCIMENTO
 INTO TB_MAIOR_SALARIO
 FROM TB_EMPREGADO
 WHERE SALARIO>5000

 
--3. Usando a tabela TB_MAIOR_SALARIO, exiba os registros que s�o comuns para as tabelas TB_MAIOR_SALARIO e TB_EMPREGADO
 SELECT COD_DEPTO
     , NOME 
  , DATA_NASCIMENTO
 FROM TB_EMPREGADO
 INTERSECT
 SELECT COD_DEPTO
     , NOME 
  , DATA_NASCIMENTO
 FROM TB_MAIOR_SALARIO

 
--4. Exibir a coluna NOME da tabela TB_EMPREGADO e a coluna NOME da tabela TB_VENDEDOR no mesmo result set (resultado da query).
 SELECT NOME, 'EMPREGADO' AS TABELA
 FROM TB_EMPREGADO
 UNION
 SELECT NOME, 'VENDEDOR'
 FROM TB_VENDEDOR
 ORDER BY TABELA

--5. Exibir a coluna NOME da tabela TB_EMPREGADO e a coluna NOME da tabela TB_MAIOR_SALARIO.

--O resultado n�o deve conter registros duplicados.
 SELECT NOME AS EMPREGADO
 FROM TB_EMPREGADO
 UNION 
SELECT NOME AS EMP_MAIOR_SALARIO
 FROM TB_MAIOR_SALARIO
 ORDER BY 1

 
--6. Exibir a coluna NOME da tabela TB_EMPREGADO e a coluna NOME da tabela TB_MAIOR_SALARIO.

--O resultado deve manter os registros duplicados.
 SELECT NOME AS EMPREGADO
 FROM TB_EMPREGADO
 UNION ALL
 SELECT NOME AS EMP_MAIOR_SALARIO
 FROM TB_MAIOR_SALARIO
 ORDER BY 1

--7. Preparar a tabela TEMP_CARGO para realizar o exerc�cio:
--Criar a tabela TEMP_CARGO a partir da tabela TB_CARGO.
 SELECT *
 INTO TEMP_CARGO
 FROM TB_CARGO
 SELECT * FROM TB_CARGO

--Apagar os registros com c�digo do cargo 5,9,10 da tabela TEMP_CARGO
 DELETE 
FROM TEMP_CARGO
 WHERE COD_CARGO IN (5,9,10)

 
--Atualizar em 10% o SALARIO_INIC dos c�digos de cargo 4 e 12
 UPDATE TEMP_CARGO
SET SALARIO_INIC=SALARIO_INIC *1.10
 WHERE COD_CARGO IN (4,12)

--8. Criar um script para comparar as tabelas TEMP_CARGO e TB_CARGO e realizar os passos:
--Atualizar a coluna SALARIO_INIC com o SALARIO_INIC da tabela TB_CARGO quando estiverem diferentes.

--Inserir na tabela TEMP_CARGO os registros de cargo quando estes n�o existirem na tabela. 
SET IDENTITY_INSERT TEMP_CARGO ON
 MERGE TEMP_CARGO AS EMPCARGO 

--TABELA ALVO
 USING TB_CARGO AS CARGO

-- TABELA FONTE
 ON EMPCARGO.COD_CARGO=CARGO.COD_CARGO
 WHEN MATCHED AND EMPCARGO.SALARIO_INIC <> CARGO.SALARIO_INIC 
THEN
   UPDATE
   SET EMPCARGO.SALARIO_INIC=CARGO.SALARIO_INIC
 WHEN NOT MATCHED THEN 
   INSERT(COD_CARGO,CARGO,SALARIO_INIC)
   VALUES(COD_CARGO,CARGO,SALARIO_INIC);
 SET IDENTITY_INSERT TEMP_CARGO OFF

--9. Preparar a tabela PRODUTOS_COPIA para realizar o exerc�cio:

-- Gere uma c�pia da tabela TB_PRODUTO chamada PRODUTOS_COPIA;
 SELECT * INTO PRODUTOS_COPIA FROM TB_PRODUTO;

--Exclua da tabela PRODUTOS_COPIA os produtos que sejam do tipo 'CANETA', exibindo os registros que foram exclu�dos (OUTPUT);
 DELETE FROM PRODUTOS_COPIA
 OUTPUT DELETED.*
 FROM PRODUTOS_COPIA PROD
 INNER JOIN TB_TIPOPRODUTO TIPO
 ON PROD.COD_TIPO = TIPO.COD_TIPO
 WHERE TIPO.TIPO = 'CANETA'

--Aumente em 10% os pre�os de venda dos produtos do tipo REGUA, mostrando com OUTPUT as seguintes colunas: ID_PRODUTO, DESCRICAO, PRECO_VENDA_ANTIGO e PRECO_VENDA_NOVO;
 UPDATE PRODUTOS_COPIA 
SET PRECO_VENDA = PRECO_VENDA * 1.10
 OUTPUT INSERTED.ID_PRODUTO, INSERTED.DESCRICAO, 
       DELETED.PRECO_VENDA AS PRECO_VENDA_ANTIGO, 
       INSERTED.PRECO_VENDA AS PRECO_VENDA_NOVO
 FROM PRODUTOS_COPIA PRODC
 INNER JOIN TB_TIPOPRODUTO TIPO
 ON PRODC.COD_TIPO = TIPO.COD_TIPO
 WHERE TIPO.TIPO = 'REGUA'

--10. Utilizando o comando MERGE, fa�a com que a tabela PRODUTOS_COPIA volte a ser id�ntica � tabela TB_PRODUTO, 
--ou seja, o que foi deletado de PRODUTOS_COPIA deve ser 
--reinserido, e os produtos que tiveram seus pre�os alterados 
--devem ser alterados novamente para que voltem a ter o pre�o 
--anterior. O MERGE deve possuir uma cl�usula OUTPUT que mostre 
--as seguintes colunas: a��o executada pelo MERGE (DELETE, 
INSERT, UPDATE), ID_PRODUTO, PRECO_VENDA_ANTIGO, PRECO_VENDA_ NOVO.
 SET IDENTITY_INSERT PRODUTOS_COPIA ON
 EXEC SP_HELP PRODUTOS_COPIA
 MERGE PRODUTOS_COPIA PC
 USING TB_PRODUTO P
 ON PC.ID_PRODUTO = P.ID_PRODUTO
 WHEN MATCHED AND PC.PRECO_VENDA <> P.PRECO_VENDA THEN
     UPDATE SET PC.PRECO_VENDA = P.PRECO_VENDA
 WHEN NOT MATCHED THEN
     INSERT (ID_PRODUTO,COD_PRODUTO,DESCRICAO,COD_UNIDADE,
             COD_TIPO,PRECO_CUSTO,PRECO_VENDA,
             QTD_REAL,QTD_MINIMA,CLAS_FISC,IPI,PESO_LIQ)
     VALUES (ID_PRODUTO,COD_PRODUTO,DESCRICAO,COD_UNIDADE,
             COD_TIPO,PRECO_CUSTO,PRECO_VENDA,
             QTD_REAL,QTD_MINIMA,CLAS_FISC,IPI,PESO_LIQ)        
OUTPUT $ACTION, INSERTED.ID_PRODUTO, 
                DELETED.PRECO_VENDA AS PRECO_VENDA_ANTIGO,
                INSERTED.PRECO_VENDA AS PRECO_VENDA_NOVO;
 SET IDENTITY_INSERT PRODUTOS_COPIA OFF


--11. Criar um script para manter os dados abaixo em mem�ria:

-- NUM_PEDIDO
-- NOME DO CLIENTE
-- DATA_EMISSAO 
-- VLR_TOTAL
 WITH DADOS_PED
 AS
 (SELECT PED.NUM_PEDIDO
       ,CLI.NOME
    ,PED.DATA_EMISSAO
    ,PED.VLR_TOTAL
 FROM TB_PEDIDO AS PED
 INNER JOIN TB_CLIENTE AS CLI
 ON PED.CODCLI=CLI.CODCLI)
 SELECT *
 FROM DADOS_PED

--12. Criar uma vis�o para exibir:

--NUM_PEDIDO
--DATA_EMISSAO
--NOME DO CLIENTE
--QUANTIDADE DO PRODUTO
--DESCRICAO DO PRODUTO 
--PERIODO DE JAN/2016

 CREATE VIEW VW_COMPRAS_CLIENTE
 WITH SCHEMABINDING
 AS
 SELECT NUM_PEDIDO
      ,DATA_EMISSAO
   ,CLI.NOME AS NOME_CLIENTE
 FROM DBO.TB_PEDIDO AS PED
 INNER JOIN DBO.TB_CLIENTE AS CLI
 ON PED.CODCLI=CLI.CODCLI

--13. Criar um �ndice para a view criada no exerc�cio anterior VW_COMPRAS_CLIENTE para a coluna NUM_PEDIDO.
 CREATE UNIQUE CLUSTERED INDEX NDX_NUMPED 
ON VW_COMPRAS_CLIENTE(NUM_PEDIDO)


