use clinica;
-- Criação das tabelas (Pacientes, veterinarios e consultar)
CREATE TABLE Pacientes (
    id_paciente INT PRIMARY KEY AUTO_INCREMENT, 
    nome VARCHAR(100), 
    especie VARCHAR(50), 
    idade INT 
);

CREATE TABLE Veterinarios (
    id_veterinario INT PRIMARY KEY AUTO_INCREMENT,
    nome VARCHAR(100), 
    especialidade VARCHAR(50)
);

CREATE TABLE Consultas (
    id_consulta INT PRIMARY KEY AUTO_INCREMENT, 
    id_paciente INT, 
    id_veterinario INT, 
    data_consulta DATE, 
    custo DECIMAL(10,2), 
    FOREIGN KEY (id_paciente) REFERENCES Pacientes(id_paciente), 
    FOREIGN KEY (id_veterinario) REFERENCES Veterinarios(id_veterinario) 
);

-- Agendamento de consultas
DELIMITER //

CREATE PROCEDURE agendar_consulta(
    IN p_id_paciente INT,
    IN p_id_veterinario INT,
    IN p_data_consulta DATE,
    IN p_custo DECIMAL(10, 2)
)
BEGIN
    INSERT INTO Consultas (id_paciente, id_veterinario, data_consulta, custo)
    VALUES (p_id_paciente, p_id_veterinario, p_data_consulta, p_custo);
END //

DELIMITER ;


-- Atualizar paciente
DELIMITER //

CREATE PROCEDURE atualizar_paciente(
    IN p_id_paciente INT,
    IN p_novo_nome VARCHAR(100),
    IN p_nova_especie VARCHAR(50),
    IN p_nova_idade INT
)
BEGIN
    UPDATE Pacientes
    SET nome = p_novo_nome,
        especie = p_nova_especie,
        idade = p_nova_idade
    WHERE id_paciente = p_id_paciente;
END //

DELIMITER ;

-- Remover pacientes
DELIMITER //

CREATE PROCEDURE remover_consulta(
    IN p_id_consulta INT
)
BEGIN
    DELETE FROM Consultas
    WHERE id_consulta = p_id_consulta;
END //

DELIMITER ;

-- Function somando todos os gastos do paciente
DELIMITER //

CREATE FUNCTION total_gasto_paciente(p_id_paciente INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE total DECIMAL(10,2);
    SELECT COALESCE(SUM(custo), 0) INTO total
    FROM Consultas
    WHERE id_paciente = p_id_paciente;
    RETURN total;
END //

DELIMITER ;

-- Criação do Trigger para verificar idade do paciente
DELIMITER //

CREATE TRIGGER verificar_idade_paciente
BEFORE INSERT ON Pacientes
FOR EACH ROW
BEGIN
    IF NEW.idade <= 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'A idade do paciente deve ser um número positivo.'; -- Se enviar um número negativo, enviara uma mensagem de erro com uma mensagem.
    END IF;
END //

DELIMITER ;

-- Criação do Trigger para atualizar custo da consulta
DELIMITER //

CREATE TRIGGER atualizar_custo_consulta
AFTER UPDATE ON Consultas
FOR EACH ROW
BEGIN
    IF OLD.custo <> NEW.custo THEN
        INSERT INTO Log_Consultas (id_consulta, custo_antigo, custo_novo)
        VALUES (NEW.id_consulta, OLD.custo, NEW.custo);
    END IF;
END //

DELIMITER ;

-- Testes

SELECT * FROM Pacientes WHERE id_paciente = 1;
INSERT INTO Pacientes (nome, especie, idade) 
VALUES ('Paciente 1', 'Cachorro', 3);

SELECT * FROM Veterinarios WHERE id_veterinario = 1;
INSERT INTO Veterinarios (nome, especialidade) 
VALUES ('Veterinario 1', 'Clínica Geral');

CALL agendar_consulta(1, 1, '2024-09-18', 300.00);

SELECT * FROM Consultas WHERE id_paciente = 1 AND id_veterinario = 1;

CALL atualizar_paciente(1, 'ScoobyDoo', 'Cachorro', 5);

SELECT * FROM Pacientes WHERE id_paciente = 1;

CALL remover_consulta(1);

SELECT total_gasto_paciente(1);

INSERT INTO Pacientes (nome, especie, idade) VALUES ('Teste', 'Cachorro', -2);

UPDATE Consultas SET custo = 350.00 WHERE id_consulta = 1;





    




