-- =============================================================================
-- Dados iniciais (opcional) - executar no Query Editor ANTES de gravar o vídeo
-- Garante que existam clientes para associar às contas.
-- =============================================================================
INSERT INTO dbo.clientes (nome, email) VALUES
  ('Steve Jobs',  'steve.jobs@dimdim.com'),
  ('Ana Pereira', 'ana.pereira@dimdim.com');

INSERT INTO dbo.contas (numero, saldo, cliente_id) VALUES
  ('0001-1', 5000.00, (SELECT id FROM dbo.clientes WHERE email = 'steve.jobs@dimdim.com'));

SELECT * FROM dbo.clientes ORDER BY id;
SELECT * FROM dbo.contas   ORDER BY id;
