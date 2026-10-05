-- DDL DimDim (Azure SQL) - executar no Query Editor
CREATE TABLE dbo.clientes (
    id    BIGINT IDENTITY(1,1) PRIMARY KEY,
    nome  NVARCHAR(100) NOT NULL,
    email NVARCHAR(150) NOT NULL
);

CREATE TABLE dbo.contas (
    id         BIGINT IDENTITY(1,1) PRIMARY KEY,
    numero     NVARCHAR(20)  NOT NULL,
    saldo      DECIMAL(18,2) NOT NULL DEFAULT 0,
    cliente_id BIGINT NOT NULL,
    CONSTRAINT fk_contas_clientes FOREIGN KEY (cliente_id)
        REFERENCES dbo.clientes(id) ON DELETE CASCADE
);
