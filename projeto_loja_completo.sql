--01_create_database.sql
CREATE DATABASE GAMESTORESQL;
GO
USE GAMESTORESQL;
GO
--02_create_tables.sql
CREATE TABLE Clientes (
ClienteID INT PRIMARY KEY IDENTITY(1,1),
Nome NVARCHAR(100) NOT NULL,
Email NVARCHAR(100) NOT NULL UNIQUE,
Telefone NVARCHAR(100),
DataCadastro DATE DEFAULT GETDATE()
);

CREATE TABLE Fornecedores (
FornecedorID INT PRIMARY KEY IDENTITY(1,1),
Nome NVARCHAR(100) NOT NULL,
Contato NVARCHAR(100),
Telefone NVARCHAR(20)
);

CREATE TABLE Produtos (
ProdutoID INT PRIMARY KEY IDENTITY(1,1),
Nome NVARCHAR(100) NOT NULL,
Preco DECIMAL(10,2) NOT NULL CHECK(Preco >= 0),
Estoque INT NOT NULL CHECK (Estoque >= 0),
FornecedorID INT,
FOREIGN KEY (FornecedorID) REFERENCES Fornecedores(FornecedorID)
);

CREATE TABLE Pedidos (
PedidoID INT PRIMARY KEY IDENTITY(1,1),
ClienteID INT NOT NULL,
DataPedido DATETIME DEFAULT GETDATE(),
FOREIGN KEY (ClienteID) REFERENCES Clientes(ClienteID)
);

CREATE TABLE ItensPedido (
ItemID INT PRIMARY KEY IDENTITY(1,1),
PedidoID INT NOT NULL,
ProdutoID INT NOT NULL,
Quantidade INT NOT NULL CHECK(Quantidade > 0),
PrecoUnitario DECIMAL(10,2) NOT NULL,
FOREIGN KEY (PedidoID) REFERENCES Pedidos(PedidoID),
FOREIGN KEY (ProdutoID) REFERENCES Produtos(ProdutoID) 
);


--03_insert_data.sql
-- Inserir clientes
INSERT INTO Clientes (Nome, Email, Telefone)
VALUES
('João Silva', 'joao@email.com', '11999999999'),
('Ana Costa', 'ana@email.com', '11888888888'),
('Carlos Lima', 'carlos@email.com', '11777777777'),
('Bruna Ferreira', 'bruna@email.com', '11666666666'),
('Diego Souza', 'diego@email.com', '11555555555'),
('Larissa Ramos', 'larissa@email.com', '11444444444'),
('Paulo Mendes', 'paulo@email.com', '11333333333'),
('Juliana Rocha', 'juliana@email.com', '11222222222');

-- Inserir fornecedores
INSERT INTO Fornecedores (Nome, Contato, Telefone)
VALUES
('GameTech', 'Fernanda Dias', '1122334455'),
('LevelUp Distribuidora', 'Marcos Tavares', '1133445566'),
('PixelGames', 'Camila Duarte', '11717171717'),
('Xtreme Hardware', 'Eduardo Reis', '11616161616'),
('TopGaming', 'Rafael Nunes', '11515151515');

-- Inserir produtos
INSERT INTO Produtos (Nome, Preco, Estoque, FornecedorID)
VALUES
('Controle Xbox Series X', 349.90, 20, 1),
('Teclado Mecânico RGB', 299.00, 15, 1),
('Mouse Gamer 8000 DPI', 159.90, 25, 2),
('Headset Surround 7.1', 499.90, 10, 2),
('Cadeira Gamer Reclinável', 999.90, 5, 3),
('Placa de Vídeo RTX 3060', 2299.90, 7, 4),
('Monitor 144Hz 24"', 1199.90, 12, 5),
('Mousepad XL Antiderrapante', 59.90, 30, 2),
('Suporte para Headset com RGB', 89.90, 20, 1),
('Webcam Full HD 1080p', 349.90, 14, 4);

-- Inserir pedidos
INSERT INTO Pedidos (ClienteID)
VALUES
(1), (2), (3), (4), (5);

-- Inserir itens do pedido
INSERT INTO ItensPedido (PedidoID, ProdutoID, Quantidade, PrecoUnitario)
VALUES
-- Pedido 1 - João
(1, 1, 1, 349.90),
(1, 2, 1, 299.00),

-- Pedido 2 - Ana
(2, 3, 2, 159.90),

-- Pedido 3 - Carlos
(3, 4, 1, 499.90),
(3, 5, 1, 999.90),

-- Pedido 4 - Bruna
(4, 2, 1, 299.00),
(4, 6, 1, 2299.90),

-- Pedido 5 - Diego
(5, 3, 1, 159.90),
(5, 8, 2, 59.90),
(5, 9, 1, 89.90);


--04_queries.sql
--Listar todos os produtos com seus respectivos fornecedores
SELECT P.Nome AS Produto,P.Preco , F.Nome
FROM Produtos P
INNER JOIN Fornecedores F ON P.FornecedorID = F.FornecedorID

--Mostrar os pedidos com nome do cliente e valor total
SELECT P.PedidoID, C.Nome AS Cliente, SUM(I.PrecoUnitario * I.Quantidade) AS Valor_Total
FROM Clientes C
INNER JOIN Pedidos P ON C.ClienteID = P.ClienteID
INNER JOIN ItensPedido I ON P.PedidoID = I.PedidoID
GROUP BY  P.PedidoID, C.Nome;

--Produtos com estoque abaixo de 10
SELECT Nome, Estoque
FROM Produtos
WHERE Estoque < 10;

-- Clientes que já fizeram pedidos
SELECT DISTINCT C.Nome
FROM Clientes C
INNER JOIN Pedidos P ON C.ClienteID = P.ClienteID;

--Total de vendas por produto
SELECT 
    P.Nome AS Produto,
    SUM(IP.Quantidade) AS TotalVendido,
    SUM(IP.Quantidade * IP.PrecoUnitario) AS ReceitaTotal
FROM ItensPedido IP
INNER JOIN Produtos P ON IP.ProdutoID = P.ProdutoID
GROUP BY P.Nome;

--  Produto mais caro
SELECT TOP 1 Nome, Preco
FROM Produtos
ORDER BY Preco DESC;

--Clientes que compraram acima de R$1000
SELECT 
    C.Nome,
    SUM(IP.Quantidade * IP.PrecoUnitario) AS TotalComprado
FROM Clientes C
INNER JOIN Pedidos P ON C.ClienteID = P.ClienteID
INNER JOIN ItensPedido IP ON P.PedidoID = IP.PedidoID
GROUP BY C.Nome
HAVING SUM(IP.Quantidade * IP.PrecoUnitario) > 1000;

-- Pedidos com mais de 2 itens
SELECT 
    PedidoID,
    COUNT(*) AS TotalItens
FROM ItensPedido
GROUP BY PedidoID
HAVING COUNT(*) > 2;
 
-- Produtos e o número de vezes que foram vendidos
SELECT 
    P.Nome,
    COUNT(IP.ProdutoID) AS VezesVendidas
FROM Produtos P
LEFT JOIN ItensPedido IP ON P.ProdutoID = IP.ProdutoID
GROUP BY P.Nome;
-- Fornecedores com mais de 1 produto no catálogo
SELECT 
    F.Nome AS Fornecedor,
    COUNT(P.ProdutoID) AS TotalProdutos
FROM Fornecedores F
INNER JOIN Produtos P ON F.FornecedorID = P.FornecedorID
GROUP BY F.Nome
HAVING COUNT(P.ProdutoID) > 1;


--Total de pedidos por cliente usando CTE
WITH TotalPedidosPorCliente AS (
    SELECT 
        c.ClienteID,
        c.Nome,
        COUNT(p.PedidoID) AS TotalPedidos
    FROM Clientes c
    LEFT JOIN Pedidos p ON c.ClienteID = p.ClienteID
    GROUP BY c.ClienteID, c.Nome
)
SELECT * FROM TotalPedidosPorCliente
ORDER BY TotalPedidos DESC;

--CTE com filtragem: produtos com mais de 1 pedido
WITH ProdutosMaisVendidos AS (
    SELECT 
        p.ProdutoID,
        p.Nome,
        COUNT(ip.ItemID) AS TotalVendas
    FROM Produtos p
    INNER JOIN ItensPedido ip ON p.ProdutoID = ip.ProdutoID
    GROUP BY p.ProdutoID, p.Nome
)
SELECT * FROM ProdutosMaisVendidos
WHERE TotalVendas > 1;

--Ranking de produtos mais vendidos (por quantidade)
SELECT 
    p.Nome,
    SUM(ip.Quantidade) AS QuantidadeTotal,
    RANK() OVER (ORDER BY SUM(ip.Quantidade) DESC) AS Ranking
FROM Produtos p
INNER JOIN ItensPedido ip ON p.ProdutoID = ip.ProdutoID
GROUP BY p.Nome;


-- 05_Views.sql
-- View com pedidos e nome do cliente
CREATE VIEW vw_PedidosClientes AS
SELECT 
    p.PedidoID,
    p.DataPedido,
    c.Nome AS NomeCliente
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID;

--View com total de vendas por produto
CREATE VIEW vw_TotalVendasProduto AS
SELECT 
    pr.Nome AS NomeProduto,
    SUM(ip.Quantidade * ip.PrecoUnitario) AS TotalVendido
FROM ItensPedido ip
JOIN Produtos pr ON ip.ProdutoID = pr.ProdutoID
GROUP BY pr.Nome;

-- View com pedidos e total de itens
CREATE VIEW vw_PedidosComTotais AS
SELECT 
    p.PedidoID,
    c.Nome AS Cliente,
    p.DataPedido,
    SUM(ip.Quantidade * ip.PrecoUnitario) AS TotalPedido
FROM Pedidos p
JOIN Clientes c ON p.ClienteID = c.ClienteID
JOIN ItensPedido ip ON p.PedidoID = ip.PedidoID
GROUP BY p.PedidoID, c.Nome, p.DataPedido;


--06_StoredProcedures.sql

-- Procedure para inserir um novo cliente
CREATE PROCEDURE sp_InserirCliente
    @Nome NVARCHAR(100),
    @Email NVARCHAR(100),
    @Telefone NVARCHAR(20)
AS
BEGIN
    INSERT INTO Clientes (Nome, Email, Telefone)
    VALUES (@Nome, @Email, @Telefone)
END;

--Procedure para buscar pedidos por cliente
CREATE PROCEDURE sp_PedidosPorCliente
    @ClienteID INT
AS
BEGIN
    SELECT * FROM Pedidos
    WHERE ClienteID = @ClienteID
END;

--07_Triggers.sql

-- Trigger para impedir exclusão de produtos com pedidos
CREATE TRIGGER trg_ImpedirExclusaoProdutoComPedidos
ON Produtos
INSTEAD OF DELETE
AS
BEGIN
    IF EXISTS (
        SELECT 1 
        FROM deleted d
        JOIN ItensPedido ip ON d.ProdutoID = ip.ProdutoID
    )
    BEGIN
        RAISERROR('Não é possível excluir produtos com pedidos associados.', 16, 1)
        ROLLBACK TRANSACTION
    END
    ELSE
    BEGIN
        DELETE FROM Produtos WHERE ProdutoID IN (SELECT ProdutoID FROM deleted)
    END
END;

-- Trigger para registrar alterações de preço
CREATE TABLE HistoricoPrecoProduto (
    ID INT IDENTITY PRIMARY KEY,
    ProdutoID INT,
    PrecoAntigo DECIMAL(10,2),
    PrecoNovo DECIMAL(10,2),
    DataAlteracao DATETIME DEFAULT GETDATE()
);

CREATE TRIGGER trg_AuditarPrecoProduto
ON Produtos
AFTER UPDATE
AS
BEGIN
    INSERT INTO HistoricoPrecoProduto (ProdutoID, PrecoAntigo, PrecoNovo)
    SELECT d.ProdutoID, d.PrecoUnitario, i.PrecoUnitario
    FROM deleted d
    JOIN inserted i ON d.ProdutoID = i.ProdutoID
    WHERE d.PrecoUnitario <> i.PrecoUnitario
END;


