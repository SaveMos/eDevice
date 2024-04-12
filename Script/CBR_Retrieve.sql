


-- DROP TEMPORARY TABLE IF EXISTS Operazioni_Rimedio;
DROP PROCEDURE IF EXISTS Conta_Separatori;
DROP PROCEDURE IF EXISTS ROBA;

DELIMITER $$

 -- Procedura che conta i ';' Conta_Separatori(STR , ';')
CREATE PROCEDURE Conta_Separatori(IN STR TEXT , IN Separatore CHAR , OUT Num INT)
BEGIN

SELECT (LENGTH(STR)-LENGTH(REPLACE(STR, Separatore, ''))) into Num;



END; $$
DELIMITER ;

DELIMITER $$

CREATE PROCEDURE ROBA(IN STR TEXT )
BEGIN

DECLARE NUM_Operazioni INT DEFAULT 0;
DECLARE i INT DEFAULT 0;
DECLARE c INT DEFAULT 0;

DECLARE disp BOOLEAN default false;

DECLARE Ret TEXT DEFAULT NULL; 
DECLARE Operazione_Testa TEXT DEFAULT NULL; 
DECLARE Operazione_Coda TEXT DEFAULT NULL;

if(STR IS NULL OR STR = "") THEN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'ERRORE , Stringa vuota!';
    END IF;

CREATE TEMPORARY TABLE Operazioni_Rimedio(

NumeroOperazione INT PRIMARY KEY,
Operazione TEXT

);

CALL Conta_Separatori(STR , ';' , NUM_Operazioni);
SET NUM_Operazioni = NUM_Operazioni + 1;

if(NUM_Operazioni = 1) then -- se la stringa era composta da una sola sottostringa( nessun ';')
INSERT INTO Operazioni_Rimedio VALUES ( 1 , STR); 

else

IF(NUM_Operazioni % 2 = 1) THEN
SET Operazione_Testa = SUBSTRING_INDEX(STR, ';', 1); -- Prendo la prima sottostringa 
SET Operazione_Testa = TRIM(Operazione_Testa);

if(Operazione_Testa != "") then
INSERT INTO Operazioni_Rimedio VALUES ( 1 , Operazione_Testa); 
SET c = c + 1;
SET i = i + 1;
set disp = true;

end if;

SET NUM_Operazioni = NUM_Operazioni - 1;
SET STR = SUBSTRING_INDEX(STR, ';', -(NUM_Operazioni));
-- select 'DISPARI' , STR;

END IF;
 
REPEAT
SET Operazione_Testa = SUBSTRING_INDEX(STR, ';', 1); -- Prendo la prima sottostringa 
SET Operazione_Testa = TRIM(Operazione_Testa);

if(i = 0) then 
SET STR = SUBSTRING_INDEX(STR, ';', -(NUM_Operazioni - 1)); -- Taglio la prima sottostringa
else
SET STR = SUBSTRING_INDEX(STR, ';', -(NUM_Operazioni - i -  if( disp is true , false , true) )); -- CAPIRE PERCHè FUNZIONA!
end if;

if(Operazione_Testa != "") then
INSERT INTO Operazioni_Rimedio VALUES ( c + 1 , Operazione_Testa); 
set c = c + 1;
end if;
set i = i + 1;

UNTIL i = NUM_Operazioni + disp -- Capire perchè + disp funziona
END REPEAT;
 

end if;

-- select * from Operazioni_Rimedio;

 select GROUP_CONCAT(Operazione SEPARATOR ';') into Ret from Operazioni_Rimedio; -- per ricostruire la stringa
 
 -- Select Ret;
 
 if(Ret IS NULL OR Ret = "") THEN
	SIGNAL SQLSTATE '45000'
    SET MESSAGE_TEXT = 'ERRORE , Stringa non valida!';
    END IF;




END; $$
DELIMITER ;
 
 