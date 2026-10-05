-- =============================================================================
-- SELECTs de evidência para o vídeo
-- Rodar ANTES e DEPOIS de cada operação (INSERT / UPDATE / DELETE), SEM CORTES
-- =============================================================================

-- Tabela 1: clientes
SELECT * FROM dbo.clientes ORDER BY id;

-- Tabela 2: contas
SELECT * FROM dbo.contas ORDER BY id;

-- Relacionamento contas -> clientes (FK cliente_id)
SELECT ct.id      AS conta_id,
       ct.numero,
       ct.saldo,
       cl.id      AS cliente_id,
       cl.nome    AS cliente
FROM dbo.contas ct
JOIN dbo.clientes cl ON cl.id = ct.cliente_id
ORDER BY ct.id;
