DROP DATABASE IF EXISTS eDevice;
CREATE DATABASE eDevice CHARACTER SET UTF8 collate utf8_general_ci;
use eDevice;

SET FOREIGN_KEY_CHECKS = 0;

SET sql_notes = 0; 

SET max_sp_recursion_depth = 100;

SET group_concat_max_len = 1000000;

SET GLOBAL event_scheduler = ON;

drop table if exists Predisposizione;
CREATE TABLE predisposizione (
    nome VARCHAR(255) PRIMARY KEY,
    descrizione TEXT
)  ENGINE=INNODB;

drop table if exists Scala_Qualita;
CREATE TABLE Scala_Qualita (
    Valore INT PRIMARY KEY,
    CHECK (valore BETWEEN 1 AND 5)
)  ENGINE=INNODB;

DROP TABLE IF EXISTS categoria_prodotto;
CREATE TABLE categoria_prodotto (
    Nome VARCHAR(100) PRIMARY KEY,
    Predisposizione VARCHAR(255) NULL,
    CONSTRAINT Pred FOREIGN KEY (Predisposizione) REFERENCES predisposizione (Nome)  ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

DROP TABLE IF EXISTS tipo_prodotto;
CREATE TABLE tipo_prodotto (
    Nome VARCHAR(45) PRIMARY KEY,
    Categoria VARCHAR(100) NOT NULL,
    Sconto_Iniziale INT UNSIGNED NOT NULL DEFAULT '0',
    Passo INT UNSIGNED NOT NULL DEFAULT '0',
    Soglia_Lotti INT UNSIGNED NOT NULL,
    CONSTRAINT Categoria FOREIGN KEY (Categoria) REFERENCES categoria_prodotto (Nome)  ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

DROP TABLE IF EXISTS componente;
CREATE TABLE componente (
    COD_Componente INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(45) NOT NULL,
    Prezzo DOUBLE UNSIGNED NOT NULL,
    Peso DOUBLE UNSIGNED NOT NULL,
    Coefficente_Svalutazione INT UNSIGNED NOT NULL,
    Parte TINYINT DEFAULT NULL
)  ENGINE=INNODB;

drop table if exists Compone;
CREATE TABLE Compone (
    COD_Componente INT,
    COD_Parte INT,
    PRIMARY KEY (cod_componente , cod_parte),
    CONSTRAINT comppart FOREIGN KEY (cod_componente) REFERENCES componente (cod_componente) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT partpart FOREIGN KEY (cod_parte)REFERENCES componente (cod_componente) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop trigger if exists Check_Insert_Compone;
delimiter $$
create trigger Check_Insert_Compone before insert on Compone for each row 
begin

 if(new.cod_componente = 1 OR new.cod_parte = 1 OR new.cod_componente = 28 OR new.cod_parte = 28 OR new.cod_componente = new.cod_parte OR new.cod_parte is null OR new.cod_componente is null) then
 signal sqlstate '45000' set message_text = 'Input non valido!'; 
 end if;
 
 
end $$
delimiter ;


drop table if exists Componente_Materiale;
CREATE TABLE Componente_Materiale (
    COD_Componente INT,
    Materiale VARCHAR(255),
    quantita INT UNSIGNED NOT NULL,
    PRIMARY KEY (cod_componente , Materiale),
    CONSTRAINT compMat FOREIGN KEY (cod_componente) REFERENCES componente (cod_componente) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT matcomp FOREIGN KEY (Materiale) REFERENCES Materiale (Nome) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

DROP TABLE IF EXISTS utensile;
CREATE TABLE utensile (
    Nome VARCHAR(100) PRIMARY KEY
)  ENGINE=INNODB;

DROP TABLE IF EXISTS Oggetto;
	CREATE TABLE oggetto (
    Marca VARCHAR(100) NOT NULL,
    Modello VARCHAR(100) NOT NULL,
    Numero_Facce INT UNSIGNED NOT NULL,
    Prezzo INT UNSIGNED NOT NULL,
    Tipo_Prodotto VARCHAR(45) NOT NULL,
    Data_Uscita DATE NOT NULL,
    PRIMARY KEY (Marca , Modello),
    KEY Tipo_Prodotto (Tipo_Prodotto),
    CONSTRAINT Tipo_Prodotto_Ogg FOREIGN KEY (Tipo_Prodotto)  REFERENCES tipo_prodotto (Nome) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;


DROP TABLE IF EXISTS Materiale;
CREATE TABLE materiale (
    Nome VARCHAR(255) PRIMARY KEY,
    Valore INT UNSIGNED NOT NULL,
    Tossico TINYINT NOT NULL
)  ENGINE=INNODB;

DROP TABLE IF EXISTS caratteristica_prodotto;
CREATE TABLE caratteristica_prodotto (
    Caratteristica_Variante VARCHAR(50) PRIMARY KEY,
    Unita_di_Misura VARCHAR(10)
)  ENGINE=INNODB;

DROP TABLE IF EXISTS Oggetto_caratteristica_prodotto;
CREATE TABLE Oggetto_caratteristica_prodotto (
    Marca VARCHAR(100),
    Modello VARCHAR(100),
    Caratteristica VARCHAR(50),
    valore VARCHAR(255) NOT NULL,
    PRIMARY KEY (Marca , Modello , Caratteristica),
    CONSTRAINT Ogg_Caratt FOREIGN KEY (Marca , Modello) REFERENCES Oggetto (Marca , Modello)  ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Caratt_Caratt FOREIGN KEY (Caratteristica) REFERENCES caratteristica_prodotto (Caratteristica_Variante) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

DROP TABLE IF EXISTS caratteristiche_giunzione;
CREATE TABLE caratteristiche_giunzione (
    Caratteristica VARCHAR(100) PRIMARY KEY,
    Unita_Misura VARCHAR(4) NOT NULL
)  ENGINE=INNODB;

DROP TABLE IF EXISTS giunzione;
CREATE TABLE giunzione (
    Tipo_Giunzione VARCHAR(50) PRIMARY KEY
)  ENGINE=INNODB;

DROP TABLE IF EXISTS Giunzione_Caratteristica;
CREATE TABLE Giunzione_Caratteristica (
    Tipo_Giunzione VARCHAR(50),
    Caratteristica VARCHAR(100),
    PRIMARY KEY (Tipo_Giunzione , Caratteristica)
)  ENGINE=INNODB;

DROP TABLE IF EXISTS Giunzione_Componente_DX;
CREATE TABLE Giunzione_Componente_DX (
    COD_Collegamento INT PRIMARY KEY,
    COD_Componente INT,
    Tipo_Assemblamento VARCHAR(255),
    CONSTRAINT Assembla_Giun_Dx FOREIGN KEY (Tipo_Assemblamento) REFERENCES Giunzione (Tipo_Giunzione)ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Comp_Giun_Dx FOREIGN KEY (COD_Componente) REFERENCES Componente (COD_Componente) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

DROP TABLE IF EXISTS Giunzione_Componente_SX;
CREATE TABLE Giunzione_Componente_SX (
    COD_Collegamento INT PRIMARY KEY,
    COD_Componente INT,
    Tipo_Assemblamento VARCHAR(255),
    CONSTRAINT Assembla_Giun_Sx FOREIGN KEY (Tipo_Assemblamento) REFERENCES Giunzione (Tipo_Giunzione) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Comp_Giun_Sx FOREIGN KEY (COD_Componente) REFERENCES Componente (COD_Componente) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop trigger if exists Int_ref_giunzione_dx_del;
delimiter $$
create trigger Int_ref_giunzione_dx_del after delete on Giunzione_Componente_DX for each row
begin

delete from Giunzione_Componente_SX where cod_collegamento = old.cod_collegamento;

end $$
DELIMITER ;	

drop trigger if exists  Int_ref_giunzione_sx_del;
delimiter $$
create trigger Int_ref_giunzione_sx_del after delete on Giunzione_Componente_sX for each row
begin

delete from Giunzione_Componente_DX where cod_collegamento = old.cod_collegamento;

end $$
DELIMITER ;	

drop trigger if exists Int_ref_giunzione_dx_up;
delimiter $$
create trigger Int_ref_giunzione_dx_up after update on Giunzione_Componente_DX for each row
begin
declare c int;
select gd.COD_Collegamento into c
from Giunzione_Componente_SX gd
where gd.cod_collegamento = OLD.Cod_collegamento;


if(new.cod_collegamento <> c) then
update Giunzione_Componente_SX set COD_Collegamento = new.cod_collegamento
where cod_collegamento = old.cod_collegamento;
end if;

end $$
DELIMITER ;	

drop trigger if exists Int_ref_giunzione_sx_up;
delimiter $$
create trigger Int_ref_giunzione_sx_up after update on Giunzione_Componente_sX for each row
begin
declare c int;

select gd.COD_Collegamento into c
from Giunzione_Componente_DX gd
where gd.cod_collegamento = OLD.Cod_collegamento;


if(new.cod_collegamento <> c) then
update Giunzione_Componente_DX set COD_Collegamento = new.cod_collegamento
where cod_collegamento = old.cod_collegamento;
end if;

end $$
DELIMITER ;	

drop procedure if exists Congiungi_Componenti;
delimiter $$
create procedure Congiungi_Componenti (IN Comp1 INT , IN Comp2 INT , IN Giunz VARCHAR(50))
begin
declare e int;
declare Max_Id int;

select 1 into e
from Giunzione_Componente_DX gd inner join Giunzione_Componente_SX gs using(COD_collegamento)
where gs.cod_componente = comp1 and gd.cod_componente = comp2 and gs.Tipo_Assemblamento = giunz;

if (e = 1 ) then signal sqlstate '45000' set message_text = 'La coppia specificata con quel tipo di giunzione esiste gia!'; end if;

select ( MAX(COD_Collegamento) +1 ) into Max_Id from Giunzione_Componente_DX;
 
 if (max_id is null) then set max_id = 1; end if;

 insert into Giunzione_Componente_DX values (Max_Id , Comp1 , Giunz);
 insert into Giunzione_Componente_SX values (Max_Id , Comp2 , Giunz);
 
 
end $$
delimiter ;

DROP TABLE IF EXISTS Operazione;
CREATE TABLE Operazione (
    ID_Operazione INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(100) NOT NULL
)  ENGINE=INNODB;

drop table if exists Precedenza_Tecnologica;
CREATE TABLE Precedenza_Tecnologica (
    Operazione1 INT,
    Operazione2 INT,
    PRIMARY KEY (operazione1 , operazione2),
    CONSTRAINT op1_prec FOREIGN KEY (operazione1) REFERENCES operazione (ID_Operazione) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT op2_prec FOREIGN KEY (operazione2) REFERENCES operazione (ID_Operazione) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Utilizzo;
CREATE TABLE Utilizzo (
    Utensile VARCHAR(255),
    ID_Operazione INT,
    Step INT UNSIGNED,
    PRIMARY KEY (Utensile , ID_operazione , step),
    CONSTRAINT utensile_utilizzo FOREIGN KEY (Utensile) REFERENCES utensile (nome) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT op_utilizzo FOREIGN KEY (ID_Operazione) REFERENCES Operazione (ID_Operazione) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Operazione_Componente_Oggetto;
CREATE TABLE Operazione_Componente_Oggetto (
    ID_Operazione INT,
    Marca VARCHAR(255),
    Modello VARCHAR(255),
    COD_Componente INT,
    Quantita INT UNSIGNED NOT NULL,
    Faccia INT UNSIGNED NOT NULL,
    Descrizione TEXT NOT NULL,
    PRIMARY KEY (id_operazione , marca , modello , cod_componente),
    CONSTRAINT Ogg_ope_comp FOREIGN KEY (Marca , Modello)
        REFERENCES Oggetto (Marca , Modello)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT comp_ope_comp FOREIGN KEY (COD_Componente)
        REFERENCES Componente (COD_Componente)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT ape_ope_comp FOREIGN KEY (ID_Operazione)
        REFERENCES Operazione (ID_Operazione)
        ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

DROP TABLE IF EXISTS Sede_Produzione;
CREATE TABLE Sede_Produzione (
    COD_Sede INT AUTO_INCREMENT,
    Provincia varchar(255) not null,
    Nome_Via VARCHAR(50) NOT NULL,
    Numero_Civico VARCHAR(20) NOT NULL,
	constraint prov_sede foreign key (Provincia) references Provincia (nome) on delete cascade on update cascade ,
    PRIMARY KEY (COD_sede)
)  ENGINE=INNODB;

DROP TABLE IF EXISTS Operatore;
CREATE TABLE Operatore (
    COD_Fiscale VARCHAR(255) PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Cognome VARCHAR(255) NOT NULL,
    Sesso CHAR NOT NULL,
    Nome_Via VARCHAR(50) NOT NULL,
    Numero_Civico VARCHAR(20) NOT NULL,
    Provincia varchar(255) not null,
	constraint prov_op foreign key (Provincia) references Provincia (nome) on delete cascade on update cascade  ,
    Telefono INT(6) NOT NULL UNIQUE,
    Sede_Produzione INT NOT NULL,
    DataNascita DATE NOT NULL,
    DataAssunzione DATE NOT NULL,
    Paga_Oraria INT UNSIGNED NOT NULL,
    Specializzazione VARCHAR(255),
    CONSTRAINT Spec FOREIGN KEY (Specializzazione)
        REFERENCES Tipo_prodotto (nome)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Lavoro FOREIGN KEY (Sede_produzione)
        REFERENCES Sede_produzione (COD_Sede)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CHECK (DataAssunzione > '2000-01-01'),
    CHECK (DataAssunzione > DataNascita),
    CHECK (sesso IN ('M' , 'F')),
    CHECK (telefono BETWEEN 111111 AND 999999)
    
)  ENGINE=INNODB;

drop table if exists Prestazioni_operatore;
CREATE TABLE Prestazioni_operatore (
    Operatore VARCHAR(255),
    Operazione INT,
    SommaTempi BIGINT UNSIGNED DEFAULT 0,
    SommaTempi_e2 BIGINT UNSIGNED DEFAULT 0,
    Num_Prestazioni BIGINT UNSIGNED DEFAULT 0,
    PRIMARY KEY (operatore , operazione),
    CONSTRAINT Operat FOREIGN KEY (Operatore)        REFERENCES Operatore (CoD_Fiscale)        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Operaz FOREIGN KEY (Operazione)        REFERENCES Operazione (ID_operazione)        ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop procedure if exists Cronometro_Prestazioni_Operatore;
delimiter $$
create procedure Cronometro_Prestazioni_Operatore( IN _Operatore VARCHAR(255) , IN _OP INT , IN Tempo Double)
begin

declare err tinyint default null;

select 1 into err
from Prestazioni_operatore where Operazione = _OP and Operatore = _Operatore;

if(err = 1) then
update Prestazioni_operatore
 set 
 SommaTempi = Sommatempi + ABS(Tempo) , 
 Sommatempi_e2 = Sommatempi_e2 + (tempo * tempo) , 
 Num_Prestazioni = Num_prestazioni + 1 
where Operatore = _Operatore AND Operazione = _Op;

else
insert into Prestazioni_Operatore values (_operatore , _Op , ABS(tempo) , tempo*tempo , 1);
end if;

end $$
delimiter ;

drop procedure if exists Varianza_Prestazioni_Operatore;
delimiter $$
create procedure Varianza_Prestazioni_Operatore( IN _Operatore VARCHAR(255) , IN _OP INT  , OUT Media_ DOUBLE , OUT Varianza_ double)
begin


declare err tinyint default null;
select 1 into err from Operatore where cod_FISCALE = _Operatore;
if(err is null) then signal sqlstate '45000' set message_text = 'Operatore inesistente'; end if;

set err=null;
select 1 into err from Operazione where id_Operazione = _OP;
if(err is null) then signal sqlstate '45000' set message_text = 'Operazione inesistente'; end if;

with t1 as(
select po.Operatore ,po.Operazione ,
(po.SommaTempi_e2/po.Num_Prestazioni) as a , -- somma dei tempi ELEVATI alla 2
(po.sommatempi/po.Num_Prestazioni) as d -- media aritmetica dei tempi

from prestazioni_operatore po
where po.Operatore = _Operatore and po.Operazione = _OP
)

select TRUNCATE(d , 3) as Media1, TRUNCATE(a - d*d , 3) as Varianza1 INTO Media_ ,Varianza_
from t1;


end $$
delimiter ;

drop procedure if exists Classifica_operai_Tempo_Medio_Operazione;
delimiter $$
create procedure Classifica_operai_Tempo_Medio_Operazione(IN Ope INT)
begin

declare err tinyint default null;
select 1 into err from prestazioni_operatore where operazione = ope;
if(err is null) then signal sqlstate '45000' set message_text = 'Operazione inesistente o non ancora usata'; end if; 

select
 dense_rank()over(order by (AVG(SommaTempi / Num_Prestazioni))) as Posizione,
 o.Cognome ,
 o.Nome , 
 CONCAT(TRUNCATE(AVG(SommaTempi / Num_Prestazioni), 3) , '  s') as Media ,
 o.Specializzazione , 
 o.Sede_Produzione
 
from  prestazioni_operatore po 
inner join operatore o on o.COD_Fiscale = po.Operatore
inner join operazione op on op.ID_Operazione = po.Operazione
where po.operazione = ope
group by po.operatore , po.Operazione
order by Media asc;

end $$
delimiter ;

drop procedure if exists Classifica_operai_Varianza_Operazione;
delimiter $$
create procedure Classifica_operai_Varianza_Operazione(IN Ope INT)
begin
	declare finito int default 0;
    declare err tinyint default null;
    declare varr double ;
    declare med double;
    declare opera varchar(255) ;
    
    declare curs cursor for
    select distinct po.Operatore
  	from  prestazioni_operatore po 
    where po.Operazione = Ope;
    
    declare continue handler for not found set finito = 1;
    
	select 1 into err from prestazioni_operatore where operazione = ope;
	if(err is null) then signal sqlstate '45000' set message_text = 'Operazione inesistente o non ancora usata'; end if; 
    
	drop temporary table if exists Varianza_Buffer;
    create temporary table Varianza_Buffer(
		Posizione int ,
        Cognome varchar(255) ,
        Nome varchar(255) ,
        Varianza double ,
        Media varchar(10) ,
        Specializzazione varchar(255) ,
        Sede_Produzione int 
    );
    
    insert into Varianza_Buffer 
		 select		
         dense_rank()over(order by (AVG(SommaTempi / Num_Prestazioni))) as Posizione,
		 o.Cognome ,		
		 o.Nome , 
		 0 ,	
         CONCAT(TRUNCATE(AVG(SommaTempi / Num_Prestazioni) , 3) , '  s') as Media ,
		 o.Specializzazione , 	
         o.Sede_Produzione
		 
		from  prestazioni_operatore po 
		inner join operatore o on o.COD_Fiscale = po.Operatore
		inner join operazione op on op.ID_Operazione = po.Operazione
		where po.operazione = ope		
        group by po.operatore , po.Operazione;		
		
        
        open curs;
        
        prel : loop
        
        fetch curs into opera;
        if(finito = 1 ) then leave prel; end if;
        
        call Varianza_Prestazioni_Operatore(opera , ope , med , varr);
        
        update Varianza_Buffer set varianza = varr 
        where (Nome , Cognome) IN (select Nome , Cognome from operatore where COD_Fiscale = opera);
        
        end loop prel;
        close curs;
        
        select * from Varianza_Buffer order by Varianza asc;
        
        drop temporary table if exists Varianza_Buffer;
		   
			

end $$
delimiter ;

drop procedure if exists Popola_Prestazioni; -- serve per popolare il DB , inserisce dati randomici!
delimiter $$
create procedure Popola_Prestazioni(in a int , in seq int)
begin

if(a is null or a <= 0 or a > 1000000) then set a = 20; end if;

drop temporary table if exists t1;
create temporary table t1 (
operatore varchar(255) ,
operazione int ,
tempo int 
);

while(a >= 0) do
call Inserisci_Prestazioni(seq);
set a = a - 1;
end while;

drop temporary table if exists t1;
end $$
delimiter ;


drop procedure if exists Inserisci_Prestazioni; -- serve per popolare il DB , inserisce dati randomici!
delimiter $$
create procedure Inserisci_Prestazioni(in seq int)
begin
declare a varchar(255);
declare b int;
declare c int;
declare finito int default 0;

declare curs cursor for
select Operatore , Operazione ,if(Tempo < 15 , Tempo + 15 , Tempo) as Tempo
from t1;

declare continue handler for not found set finito = 1;

truncate t1;
insert into t1
select  ass.Operatore , o.operazione , floor(ABS((RAND() * 25))) as Tempo
from OP_Seq o
inner join stazione s on (s.NUM_Inizio <= o.Numero_Operazione AND s.Num_fine >= o.Numero_Operazione)
inner join assegnazione_attuale ass on ass.Stazione  = s.ID_Stazione
where o.id_sequenza = 1;


open curs;
calc : loop
fetch curs into a , b , c;
if(finito = 1) then leave calc; end if;

call Cronometro_Prestazioni_Operatore(a , b , c);

end loop calc;
close curs;


end $$
delimiter ;



DROP TABLE IF EXISTS Sequenza;
CREATE TABLE Sequenza (
    ID_Sequenza INT PRIMARY KEY AUTO_INCREMENT,
    Marca VARCHAR(100) NOT NULL,
    Modello VARCHAR(100) NOT NULL,
    Timestamp_Creazione TIMESTAMP NOT NULL,
    Revisione TINYINT NOT NULL DEFAULT 0,
    Tempo_Max_Stazione INT UNSIGNED NOT NULL,
    Max_Numero_Operazioni_per_Stazione INT UNSIGNED NOT NULL,
    check ( Tempo_Max_Stazione > 0) ,
	check ( Max_Numero_Operazioni_per_Stazione  > 0) ,
    CONSTRAINT Ogg FOREIGN KEY (Marca , Modello) REFERENCES Oggetto (Marca , Modello) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

DROP TABLE IF EXISTS Stazione;
CREATE TABLE Stazione (
    ID_Stazione INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(100) NOT NULL,
    ID_Sequenza INT,
    NUM_Inizio INT UNSIGNED,
    NUM_Fine INT UNSIGNED,
    CONSTRAINT Sequenza FOREIGN KEY (ID_Sequenza)
        REFERENCES Sequenza (ID_Sequenza)
        ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

DROP PROCEDURE IF EXISTS Crea_Sequenza;
delimiter $$
create procedure Crea_Sequenza(IN _Marc VARCHAR(255) ,IN _Mod VARCHAR(255) , IN _TMax INT , _NumMax INT)
begin
	insert into Sequenza values (null , _Marc , _Mod , current_timestamp , 0 , ABS(_TMax) , ABS(_NumMax) );
end $$
delimiter ;

 DROP PROCEDURE IF EXISTS Assegna_Stazione_a_Sequenza;
delimiter $$
create procedure Assegna_Stazione_a_Sequenza(In _Seq INT , IN _Nome VARCHAR(100))
begin
	insert into stazione values (null , _Nome , _Seq , 0 ,0);
end $$
delimiter ;

drop table if exists OP_SEQ;
CREATE TABLE op_seq (
    ID_Sequenza INT,
    Operazione INT,
    Numero_Operazione INT NOT NULL,
    COD_Componente INT,
    PRIMARY KEY (id_sequenza , operazione , numero_operazione),
    CONSTRAINT OP_Sequenza FOREIGN KEY (ID_Sequenza)
        REFERENCES Sequenza (ID_Sequenza)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT OP_Operaz FOREIGN KEY (Operazione)
        REFERENCES Operazione (ID_operazione)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT OP_Seq_Comp FOREIGN KEY (COD_Componente)
        REFERENCES Componente (COD_Componente)
        ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

DROP PROCEDURE IF EXISTS Assegna_Operazione_a_Sequenza;
delimiter $$
create procedure Assegna_Operazione_a_Sequenza(In _Seq INT , In _Op INT , IN _Staz INT , IN Comp INT) 
begin
	
    
    declare errore tinyint default null;
    declare MaxOp_Seq int default 0;
    declare MaxOp_Staz int default 0;
	declare MaxOp_Staz_pre int default 0;
	declare MinOp_Staz int default 0;
    
    select 1 into errore from Sequenza where id_sequenza = _Seq;
    if(errore is null) then signal sqlstate '45000' set message_text = 'Sequenza Inesistente!'; end if;
    
	select 1 into errore from Stazione where id_sequenza = _Seq and id_stazione = _staz;
    if(errore is null) then signal sqlstate '45000' set message_text = 'Stazione Inesistente!'; end if;
    
	select 1 into errore from operazione where id_operazione = _OP;
    if(errore is null) then signal sqlstate '45000' set message_text = 'Operazione Inesistente!'; end if;
    
    select 1 into errore from componente where COD_Componente = comp;
    if(errore is null) then signal sqlstate '45000' set message_text = 'Componente Inesistente!'; end if;
    
    
    
    drop temporary table if exists buffer;
    create temporary table buffer like OP_SEQ;
    
    select if(MAX(Numero_Operazione) is null , 0 ,MAX(Numero_Operazione))  into MaxOp_Seq
    from OP_SEQ
    where ID_Sequenza = _Seq;
    
    select Num_Inizio , Num_Fine into MinOp_Staz , MaxOp_Staz
    from Stazione   
    where ID_Stazione = _Staz;
    
	select if(MAX(Num_Fine) is null , 0 , MAX(Num_Fine)) into MaxOp_Staz_Pre   
    from Stazione    
    where ID_Stazione < _Staz and ID_Sequenza = _Seq;
    
    
    
    if(MinOp_Staz = 0 AND MaxOp_Staz = 0) then-- se la stazione è vuota
  
   -- insert into buffer select * from OP_SEQ  where ID_Sequenza = _Seq and Num_Operazione <=  MaxOp_Staz_Pre;
	insert into buffer values( _Seq , _Op ,  MaxOp_Staz_Pre + 1 , comp);
    insert into buffer select ID_Sequenza , Operazione , Numero_Operazione + 1 , COD_Componente from OP_SEQ  where  ID_Sequenza = _Seq and Numero_Operazione >  MaxOp_Staz_Pre;
  
	delete from Op_Seq where Numero_Operazione > MaxOp_Staz_Pre;
    insert into Op_Seq select * from buffer;
    
	update stazione set Num_Inizio = MaxOp_Staz_Pre + 1 , Num_fine =  MaxOp_Staz_Pre + 1 where ID_Stazione = _staz; 
    update stazione set Num_Inizio = Num_Inizio + 1 ,Num_fine = Num_Fine + 1 
    where ID_Stazione > _staz and Num_fine <> 0 and ID_Sequenza = _Seq;
    
    drop temporary table buffer;
  
  else
    
	insert into buffer values( _Seq , _Op ,  MaxOp_Staz + 1 , comp);
    insert into buffer select ID_Sequenza ,Operazione, Numero_Operazione + 1 , COD_Componente from OP_SEQ  where  ID_Sequenza = _Seq and Numero_Operazione >=  MaxOp_Staz +1;
  
	delete from Op_Seq where Numero_Operazione > MaxOp_Staz;
    insert into Op_Seq select * from buffer;
    
	update stazione set Num_fine =  MaxOp_Staz + 1 where ID_Stazione = _staz; 
    update stazione set Num_Inizio = Num_Inizio + 1 ,Num_fine = Num_Fine + 1
    where ID_Stazione > _staz and Num_fine <> 0 and ID_Sequenza = _Seq;
    
    drop temporary table buffer;
  
	
    
    end if;
    
    
    
end $$
delimiter ;

DROP PROCEDURE IF EXISTS Valida_Sequenza;
delimiter $$
create procedure Valida_Sequenza(In _Seq INT)
begin
	  
    declare errore int;

   select 1 into errore from Sequenza where id_sequenza = _Seq;
    if(errore is null) then signal sqlstate '45000' set message_text = 'Sequenza Inesistente!'; end if;
    
    drop temporary table if exists tab1;
    create temporary table tab1(
    operazione int ,
    operazione2 int
    );
    
    insert into tab1 
    (
    with t1 as(
    select o.operazione , o.Numero_Operazione , pt.operazione2
    from Op_Seq o 
    left outer join Precedenza_tecnologica PT on o.operazione = pt.Operazione1
    where o.ID_Sequenza = _Seq 
    order by o.numero_operazione
    )
    
    select t.operazione , T.OPERAZIONE2
    from t1 t
    where operazione2 is not null and  -- LE OPERAZIONI CON OP2 A NULL SONO QUELLE CHE NON NECESSITANO OPERAZIONI PRECEDENTI
    NOT EXISTS 
    (
    select 1 from t1 p
    where p.numero_operazione < t.numero_operazione and p.operazione = t.operazione2 -- cerco se nelle operazioni precedenti a queella in esame esiste quella che deve essere fatta prima
    )
    );
    
    
    set Errore = (select count(*) from tab1);
    
    if(errore = 0) then
    update sequenza set revisione = 1 where id_sequenza = _seq;
    else
    update sequenza set revisione = 0 where id_sequenza = _seq;
 
    signal sqlstate '45000' set message_text = 'Violazioni di vincoli di precedenza tecnologica!';
    end if;

    
    drop temporary table tab1;
end $$
delimiter ;

drop trigger if exists Svalida_Sequenza_Update;
delimiter $$
create trigger Svalida_Sequenza_Update after update on Op_seq for each row
 begin
 
 update sequenza set revisione = 0 
 where id_sequenza = old.ID_sequenza or id_sequenza = new.ID_sequenza;  -- nel caso avesse modificato l'id sequenza con un altra sequenza

 
 end $$
 delimiter ;

drop trigger if exists Svalida_Sequenza_Insert;
delimiter $$
create trigger Svalida_Sequenza_insert after insert on Op_seq for each row
 begin
 
 update sequenza set revisione = 0 where id_sequenza = new.ID_sequenza;
 
 end $$
 delimiter ;

drop trigger if exists Svalida_Sequenza_Delete;
delimiter $$
create trigger Svalida_Sequenza_Delete after delete on Op_seq for each row
 begin
 
 update sequenza set revisione = 0 where id_sequenza = old.id_sequenza;
 
 end $$
 delimiter ;

DROP TABLE IF EXISTS Assegnazione_Attuale;
CREATE TABLE Assegnazione_Attuale (
    Operatore VARCHAR(255),
    Stazione INT,
    Ora_Inizio INT UNSIGNED,
    Ora_Fine INT UNSIGNED,
    Anno INT UNSIGNED,
    PRIMARY KEY (operatore , stazione),
    CONSTRAINT Operat_assat FOREIGN KEY (Operatore)
        REFERENCES Operatore (CoD_Fiscale)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Staz_assat FOREIGN KEY (Stazione)
        REFERENCES Stazione (ID_Stazione)
        ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop trigger if exists Controllo_Anno_Assegnazione_Attuale;
delimiter $$
create trigger Controllo_Anno_Assegnazione_Attuale before insert on Assegnazione_attuale for each row
begin

if(NEW.anno <> YEAR(current_date))
then signal sqlstate '45000' set message_text ='Anno non valido'; end if;

IF(NEW.anno = YEAR(current_date) AND 12 = MONTH(current_date) AND 31 = DAY(current_date))
then signal sqlstate '45000' set message_text ='Vietato definire turni durante il 31 dicembre , aspetta fino a domani!'; end if;

end $$
delimiter ;

DROP TABLE IF EXISTS Assegnazione_Passata;
CREATE TABLE Assegnazione_Passata (
    Operatore VARCHAR(255),
    Stazione INT,
    Ora_Inizio INT UNSIGNED,
    Ora_Fine INT UNSIGNED,
    Anno INT UNSIGNED,
    PRIMARY KEY (operatore , stazione , anno),
    check(anno >= 2000) ,
    CONSTRAINT Operat_asspat FOREIGN KEY (Operatore)
        REFERENCES Operatore (CoD_Fiscale)
        ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Staz_asspat FOREIGN KEY (Stazione)
        REFERENCES Stazione (ID_Stazione)
        ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop event if exists Trasferimento_Annuale_Turni;
delimiter $$
create event Trasferimento_Annuale_Turni on schedule every 1 year starts '2021-12-31 22:00:00' DO
begin
insert into Assegnazione_Passata (select * from assegnazione_attuale where ANNO = YEAR(current_date));
delete from assegnazione_attuale where  ANNO = YEAR(current_date);
end $$
delimiter ;

DROP TABLE IF EXISTS Magazzino;
CREATE TABLE Magazzino (
    ID_Magazzino INT PRIMARY KEY AUTO_INCREMENT,
    Nome_Via VARCHAR(50) NOT NULL,
    Numero_Civico VARCHAR(20) NOT NULL,
    Mt_Quadri INT UNSIGNED NOT NULL,
    Predisposizione VARCHAR(255) NOT NULL,
	Provincia varchar(255) not null,
    CONSTRAINT Predo FOREIGN KEY (Predisposizione) REFERENCES predisposizione (Nome) ON DELETE CASCADE ON UPDATE CASCADE ,
	constraint prov_mag foreign key (Provincia) references Provincia (nome) on delete cascade on update cascade
)  ENGINE=INNODB;

DROP TABLE IF EXISTS Lotto;
CREATE TABLE Lotto (
    ID_Lotto INT PRIMARY KEY,
    Sede_Produzione INT NOT NULL,
    ID_Sequenza INT NOT NULL,
    ID_Magazzino INT NOT NULL,
    Scaffale INT UNSIGNED NOT NULL,
    Ripiano INT UNSIGNED NOT NULL,
    posizione INT UNSIGNED NOT NULL,
    Quantita_prodotti INT UNSIGNED DEFAULT 0,
    Data_inizio DATE NOT NULL,
    Data_fine_prevista DATE NOT NULL,
    data_fine_effettiva DATE DEFAULT NULL,
    data_venduto DATE DEFAULT NULL,
    CHECK (Data_inizio > '2000-01-01'),
    CHECK (Data_inizio < Data_fine_prevista),
    UNIQUE (ID_Magazzino , scaffale , ripiano , posizione),
    CONSTRAINT Luogo_prod FOREIGN KEY (Sede_produzione) REFERENCES Sede_produzione (COD_Sede) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Stock FOREIGN KEY (ID_Magazzino) REFERENCES Magazzino (ID_Magazzino) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop procedure if exists Avvia_Produzione_Lotto;
delimiter $$
create procedure Avvia_Produzione_Lotto(  IN _Seq INT ,In _Mag INT , IN _Sede INT, IN _DataInizio DATE , IN _DataFinePrev DATE  , IN _S INT , IN _R INT , IN _P INT)
begin 
	declare errore tinyint default 1;
    declare Lotto_ric int;
    
	set errore = (select 1 from sequenza where id_sequenza = _Seq ); -- controllo se esiste la sequenza desiderata
    if(errore is NULL) then signal sqlstate '45000' set message_text ='ERRORE , Sequenza inesistente'; end if;
    
    set errore = (select 1 from sequenza where id_sequenza = _Seq  and Revisione = 1); -- controllo se la sequenz adesiderata è valida
    if(errore is NULL) then signal sqlstate '45000' set message_text ='ERRORE , Sequenza esistente ed idonea all ogetto ma non ancora Validata!'; end if;
    
    set errore = (select 1 from Sede_produzione where COD_Sede = _Sede); -- controllo se esiste la sede di produzione scelta
    if(errore is NULL) then signal sqlstate '45000' set message_text ='ERRORE , Sede di produzione inesistente'; end if;
    
	set errore = (select 1 from Magazzino where id_Magazzino = _Mag); -- controllo se esiste il magazzino desiderato
    if(errore is NULL) then signal sqlstate '45000' set message_text ='ERRORE , Magazzino inesistente'; end if;
    
    CALL Controlla_Disponibilita_Spazio_In_Mag (_Mag , _S , _R , _P , errore); -- controllo se esiste la locazione scelta nel magazzino scelto
	if(errore = 1) then signal sqlstate '45000' set message_text ='ERRORE , Locazione nel magazzino occupata!'; end if;
    
	if(_Datafineprev < _datainizio OR _Datafineprev  < CURRENT_DATE) then signal sqlstate '45000' set message_text ='ERRORE , data fine prevista non valida'; end if;
    
    if( _datainizio < '2000-01-01' OR _datainizio < CURRENT_DATE) then signal sqlstate '45000' set message_text ='ERRORE , data inizio non valida'; end if;
    
	select MAX(ID_Lotto) + 1 Into Lotto_ric from  (select ID_Lotto from Lotto UNION select ID_Lotto from Lotto_Ricondizionati) as D ; -- calcoloil nuovo ID_Lotto
    
    insert into lotto values (Lotto_ric , _Sede , _Seq , _Mag , _S, _R,_P , 0 , _Datainizio ,_DataFinePrev  , NULL , NULL);

end $$
delimiter ;

drop procedure if exists Controlla_Disponibilita_Spazio_In_Mag;
delimiter $$
create procedure Controlla_Disponibilita_Spazio_In_Mag (In _Mag INT , IN _S INT , IN _R INT , IN _P INT , OUT err INT)
begin

select 1 into err
from 
(
select 1 from Lotto where id_Magazzino = _Mag AND Posizione = _P AND Ripiano = _R AND scaffale = _S
UNION
select 1 from Lotto_Resi where id_Magazzino = _Mag AND Posizione = _P AND Ripiano = _R AND scaffale = _S
UNION
select 1 from Lotto_Ricondizionati where id_Magazzino = _Mag AND Posizione = _P AND Ripiano = _R AND scaffale = _S
 ) as D;
 
if(err is null) then set err = 0; end if;
    

end $$
delimiter ;

drop procedure if exists Unita_In_produzione_Creata;
delimiter $$
create procedure Unita_In_produzione_Creata(IN _Lotto INT) -- quando un unità di uno specifico lotto viene creata 
begin 
	
   declare a int default 0;
   declare soglia INT;
   declare qp INT;

  set a = (select 1 from lotto where id_lotto = _Lotto AND data_fine_effettiva is null ); -- controllo se esiste il lotto e se è in produzione
  if(a is NULL) then signal sqlstate '45000' set message_text ='ERRORE ,Lotto inesistente'; end if;
  
  set soglia =
   (
     select Soglia_Lotti 
    from lotto l 
    inner join sequenza s using(ID_Sequenza)
    inner join oggetto o using(marca , modello)
    inner join Tipo_Prodotto t on t.nome = o.tipo_prodotto
    where l.ID_lotto = _Lotto
    );
    
set qp = (select quantita_prodotti from lotto where id_lotto = _lotto);

if(qp + 1 = soglia) then 
update lotto set quantita_prodotti = (quantita_prodotti + 1), data_fine_effettiva = current_date where id_lotto = _lotto;
call Concludi_Produzione_Lotto(_lotto);
else 
update lotto set quantita_prodotti = (quantita_prodotti + 1) where id_lotto = _lotto;
end if;

end $$
delimiter ;

drop procedure if exists Concludi_Produzione_Lotto;
delimiter $$
create procedure Concludi_Produzione_Lotto(IN _Lotto INT)
begin 
	
   declare a int default 0;
   declare NUM_Prod INT;
    
    set a = (select 1 from lotto where id_lotto = _Lotto AND data_fine_effettiva is not null ); -- controllo se esiste il lotto e se è stato concluso
    if(a is NULL) then signal sqlstate '45000' set message_text ='ERRORE ,Lotto Inesistente o gia concluso!'; end if;

   set a = 0;
   set NUM_prod = -- recupero il numero di prodtti da inserire 
   (
    select Soglia_Lotti
   from lotto l 
	inner join sequenza s using(ID_Sequenza)
	inner join oggetto o using(marca , modello)
    inner join Tipo_Prodotto t on t.nome = o.tipo_prodotto
    where l.ID_lotto = _Lotto
    );
    
    while ( a < NUM_prod ) DO
     insert into Prodotto values(null , _Lotto , null , 0);
     set a = a +1;
    end while;
    
    call Popola_Prestazioni(NUM_Prod , (select ID_Sequenza from lotto where id_lotto = _lotto));
    
    call Trasferimento_Storico_Lotto(_lotto);

end $$
delimiter ;

DROP TABLE IF EXISTS PezzoIncompleto;
CREATE TABLE PezzoIncompleto (
    ID_Pezzo INT PRIMARY KEY AUTO_INCREMENT,
    ID_Lotto INT NOT NULL,
    Num_Ultima_Op INT UNSIGNED NOT NULL,
    Immissione INT DEFAULT NULL,
    Time_Stamp_Incompletamento TIMESTAMP NOT NULL,
    CHECK ( Time_Stamp_Incompletamento  > '2000-01-01') ,
    CONSTRAINT lotto FOREIGN KEY (ID_lotto) REFERENCES Lotto (ID_Lotto) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

DROP TABLE IF EXISTS TipoEvento;
CREATE TABLE TipoEvento (
    Nome VARCHAR(200) PRIMARY KEY
)  ENGINE=INNODB;

DROP TABLE IF EXISTS StoricoDeiLotti_Attuali;
CREATE TABLE StoricoDeiLotti_Attuali (
    ID_Lotto INT,
    Timestamp_evento TIMESTAMP,
    tipoevento VARCHAR(200),
    info TEXT NOT NULL,
    ritardo_generato INT  UNSIGNED NOT NULL,
    CHECK ( Timestamp_evento  > '2000-01-01') ,
    PRIMARY KEY (ID_Lotto , timestamp_evento),
    CONSTRAINT lotto_ev_att FOREIGN KEY (ID_lotto) REFERENCES Lotto (ID_Lotto) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT tipoev1 FOREIGN KEY (tipoevento) REFERENCES Tipoevento (nome) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop procedure if exists inserimento_pezzo_incompleto;
delimiter $$
create procedure inserimento_pezzo_incompleto (IN Lotto_ INT , IN Ultima_Op_ INT)
begin

	declare p tinyint default 0;
	declare max_op int;

	set p = (select 1 from lotto where id_lotto = lotto_ and data_fine_effettiva is null);
	if( p is null )then signal sqlstate '45000' set message_text = 'Lotto inesistente o gia concluso!'; 
	else

		select MAX(os.Numero_Operazione) into MAX_Op
		from lotto l
		inner join sequenza s using(ID_Sequenza)
		inner join op_seq os using(ID_Sequenza);

		if(max_op < Ultima_Op_ or Ultima_Op_  <= 0) then signal sqlstate '45000' set message_text = 'Operazione Inesistente!';  end if;

		insert into PezzoIncompleto VALUES(null ,Lotto_  , Ultima_Op_ , null, current_timestamp);
		insert into StoricoDeiLotti_Attuali values(Lotto_ , current_timestamp, 'Ritardo Umano' , 'Generato un pezzo incompleto' , 1);
	end if;

    
    
end $$
delimiter ;

drop procedure if exists Immissione_pezzo_incompleto;
delimiter $$
create procedure Immissione_pezzo_incompleto(IN Lotto_ INT , IN Pezzo INT)
begin

declare seq int;
declare seq2 int;
declare p tinyint default 0;

select 1 into p from lotto where id_lotto = new.id_lotto and data_fine_effettiva is null;
if p is null then signal sqlstate '45000' set message_text = 'Lotto inesistente o gia concluso!';  end if;

set p = null;

select 1 into p from pezzoincompleto where ID_Pezzo = pezzo and Immissione is null;
if p is null then signal sqlstate '45000' set message_text = 'Pezzo incompleto inesistente o gia riutilizzato!';  end if;

select ID_Sequenza into seq
from lotto l inner join pezzoincompleto using(ID_Lotto)
where  ID_Pezzo = pezzo;

select ID_Sequenza into seq2
from lotto l where id_lotto = lotto_;


if(seq <> seq2 ) then signal sqlstate '45000' set message_text = 'Il Pezzo incompleto e il lotto sono incompatibili a causa della sequenza!';  end if;
set p = null;

set p = (select 1 from pezzoincompleto where ID_Pezzo = Pezzo and Immissione is null);
if p is null then signal sqlstate '45000' set message_text = 'Pezzo incompleto inesistente o già immesso!';  end if;

call Unita_In_produzione_Creata(Lotto_);
update pezzoincompleto set immissione = Lotto_ where id_pezzo = pezzo;


    
    
end $$
delimiter ;

DROP TABLE IF EXISTS StoricoDeiLotti_Passati;
CREATE TABLE StoricoDeiLotti_Passati (
    ID_Lotto INT,
    Timestamp_evento TIMESTAMP ,
    tipoevento VARCHAR(200),
    info TEXT NOT NULL,
    ritardo_generato INT UNSIGNED,
    PRIMARY KEY (ID_Lotto , timestamp_evento),
	CHECK ( Timestamp_evento  > '2000-01-01') ,
    CONSTRAINT lotto_ev_pass FOREIGN KEY (ID_lotto) REFERENCES Lotto (ID_Lotto)  ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT tipoev2 FOREIGN KEY (tipoevento) REFERENCES Tipoevento (nome) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop procedure if exists Conta_Pezzi_Incompleti_Stazione;
delimiter $$
create procedure Conta_Pezzi_Incompleti_Stazione (IN _Staz INT , OUT Num_ INT)
begin

declare p tinyint default 0;
set p = (select 1 from stazione where id_stazione = _staz);
if ( p is null ) then signal sqlstate '45000' set message_text = 'Stazione Inesistente!'; end if;

select count(ID_Pezzo) as Numero into Num_
from stazione s
inner join sequenza se on se.id_sequenza = s.id_sequenza
inner join lotto l on l.ID_Sequenza= se.ID_Sequenza
inner join pezzoincompleto pi on pi.ID_Lotto = l.id_lotto
where id_stazione = _staz and pi.Num_Ultima_Op between s.NUM_Inizio and s.NUM_Fine;

end $$
delimiter ;

drop procedure if exists Trasferimento_Storico_Lotto; -- per trasferire gli eventi di un lotto concluso 
delimiter $$
create procedure Trasferimento_Storico_Lotto(in _Lotto INT)
begin

declare p tinyint;
set p = (select 1 from lotto where id_lotto = _lotto and data_fine_effettiva is not null);
if p is null then signal sqlstate '45000' set message_text = 'Lotto inesistente o non ancora concluso!';end if;

insert into StoricoDeiLotti_passati select * from StoricoDeiLotti_attuali where ID_Lotto = _Lotto;

delete from StoricoDeiLotti_Attuali where id_lotto = _lotto;


end $$
delimiter ;

drop table if exists persona;
CREATE TABLE persona (
    COD_Fiscale VARCHAR(255) PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Cognome VARCHAR(255) NOT NULL,
    Sesso CHAR NOT NULL,
    Nome_Via VARCHAR(50) NOT NULL,
    Numero_Civico VARCHAR(20) NOT NULL,
    Provincia varchar(255) not null,
    Telefono INT NOT NULL UNIQUE,
    DataNascita DATE NOT NULL,
    tipologia_documento VARCHAR(255) NOT NULL,
    Numero_Documento INT UNSIGNED NOT NULL,
    ente_Documento VARCHAR(255) NOT NULL,
    Data_Scadenza_Documento DATE NOT NULL,
    CHECK (Data_Scadenza_Documento > DataNascita),
    CHECK (sesso IN ('M' , 'F')),
    CHECK (telefono BETWEEN 111111 AND 999999),
    constraint prov_pers foreign key (Provincia) references Provincia (nome) on delete cascade on update cascade 
   
)  ENGINE=INNODB;

drop table if exists Account;
CREATE TABLE Account (
    NickName VARCHAR(255) PRIMARY KEY,
    COD_Fiscale VARCHAR(255) NOT NULL,
    Data_Iscrizione TIMESTAMP NOT NULL,
    Password VARCHAR(255) NOT NULL,
    Domanda_Sicurezza TEXT NOT NULL,
    Risposta_Sicurezza TEXT NOT NULL,
    KEY NickNames (Nickname),
	CHECK (Data_Iscrizione > '2000-01-01') ,
    CONSTRAINT Persona_Account FOREIGN KEY (COD_Fiscale) REFERENCES Persona (COD_Fiscale)  ON DELETE CASCADE ON UPDATE CASCADE
 
)  ENGINE=INNODB;

drop table if exists Provincia;
CREATE TABLE Provincia (
    id_Provincia INT,
    Nome VARCHAR(50) PRIMARY KEY,
    id_regione INT
)  ENGINE=INNODB;

drop table if exists Cambio_Provincia;
CREATE TABLE Cambio_Provincia (
    prov1 VARCHAR(255),
    prov2 VARCHAR(255),
    TempoMedio DOUBLE UNSIGNED NOT NULL,
    PRIMARY KEY (prov1 , prov2),
    CONSTRAINT prov1Provi FOREIGN KEY (Prov1) REFERENCES Provincia (Nome) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT prov2Provi FOREIGN KEY (Prov2) REFERENCES Provincia (Nome) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Hub;
CREATE TABLE Hub (
    Provincia varchar(255) primary key ,
    Nome_Via VARCHAR(50) NOT NULL,
    Numero_Civico VARCHAR(20) NOT NULL,
    CONSTRAINT prov_hub FOREIGN KEY (Provincia) REFERENCES Provincia (Nome) ON DELETE CASCADE ON UPDATE CASCADE
  
)  ENGINE=INNODB;

drop table if exists Ordine;
CREATE TABLE Ordine (
    COD_Ordine INT PRIMARY KEY AUTO_INCREMENT,
    NickName VARCHAR(255),
    Timestamp_Ordine TIMESTAMP NOT NULL,
    Timestamp_Fine_Pendenza TIMESTAMP DEFAULT NULL,
    Stato VARCHAR(50) NOT NULL,
	CHECK (Timestamp_Ordine > '2000-01-01') ,
    CHECK (Stato IN ('Pendente' , 'Processazione' , 'Preparazione' , 'Spedito' , 'Evaso')) ,
    CONSTRAINT Ord_Account FOREIGN KEY (NickName) REFERENCES Account (Nickname) ON DELETE CASCADE ON UPDATE CASCADE

)  ENGINE=INNODB;


drop procedure if exists Creazione_Ordine;
delimiter $$
create procedure Creazione_Ordine(IN Nick VARCHAR(255), IN Via VARCHAR(50) , IN NUMciv VARCHAR(50) , IN Provincia varchar(255)) 
begin

	declare err int default null;
	declare ord int;

	select 1 into err    from account where NickName = nick;
	if(err is null) then signal sqlstate '45000' set message_text = 'Acount inesistente'; end if;
		
	select (MAX(COD_Ordine) +1) into ord from ordine;

	if (ord is null) then set ord = 1; end if;

	if(Via is null OR Via = ' ' OR NUMciv is null OR NUMciv = ' ' OR Provincia is null OR Provincia = ' ') then
	select p.Nome_Via , p.Numero_Civico , p.provincia into Via , NumCIv , provincia
	from account a 
	inner join persona p on p.COD_Fiscale = a.COD_Fiscale
	where a.nickname = nick;

	end if;

	insert into Ordine VALUES(ord , Nick , current_timestamp  , NULL , 'Pendente' );
	insert into Spedizione values (ord , Provincia , Via , NUMciv  , NULL , NULL , NULL , NULL);


end $$
delimiter ;

drop procedure if exists Switch_Stato_Ordine;
delimiter $$
create procedure Switch_Stato_Ordine(IN _Ordine INT) 
begin
declare errore int default 0;
declare Stato_Nuovo varchar(50);
declare Stato_Vecchio varchar(50);
declare data_prev date;

declare MaxProvi varchar(255);


set errore = (select if(COD_Ordine is NULL , 1 , 0) from ordine where COD_Ordine = _Ordine); -- controllo se esiste l'ordine
if( errore = 1 ) then signal sqlstate '45000' set message_text = 'ERRORE! ordine inesistente!'; end if;

set Stato_Vecchio = (select Stato from ordine where COD_Ordine = _Ordine);
set Stato_Nuovo = Stato_vecchio; -- se viene fatto uno switch ordine di un ordine pendente , quest ultimo rimarrà invariato

if(Stato_vecchio = 'Processazione') then 
update prodotto set prenotato = 0 where cod_ordine = _ordine;
set Stato_Nuovo = 'Preparazione';

elseif(Stato_Vecchio = 'Preparazione') then 
set Stato_Nuovo = 'Spedito';




with t1 as(
select (select cp.TempoMedio from cambio_Provincia cp where cp.prov1 = h.Provincia and cp.prov2 = 'Livorno') as Temp
from ordine o 
inner join prodotto p using(COD_Ordine)
inner join lotto l using(ID_Lotto)
inner join Magazzino m using(ID_Magazzino)
inner join Hub h using(Provincia)
where cod_ordine = _Ordine
)

select (current_date + interval (MAX(temp) + 1440) minute) into Data_Prev
from t1; -- prendo il tempo massimo di spedizione , ossia il tempo medio più lungo tra tutti i magazzini  da cui vengono i prodotti

update spedizione set Stato_Spedizione = 'Spedita' , data_partenza = current_date , data_consegna_prevista = data_prev where cod_ordine = _Ordine;

elseif(Stato_Vecchio = 'Spedito' AND 'In Consegna' = (select stato_spedizione from spedizione where cod_ordine = _ordine)) then 
set Stato_Nuovo = 'Evaso';
update spedizione set Stato_Spedizione = 'Consegnata' , data_consegna_effettiva = current_date where cod_ordine = _Ordine;
CALL Assicura_Ordine_Prodotto(_ordine);

elseif(Stato_Vecchio = 'Evaso' ) then 
set Stato_Nuovo = 'Evaso';

end if;


UPDATE Ordine SET Stato = Stato_Nuovo WHERE COD_Ordine = _Ordine;



end $$
delimiter ;


drop procedure if exists Stato_Ordini_Contatore;
delimiter $$
create procedure Stato_Ordini_Contatore()
begin

drop temporary table if exists stati_ordini;
create temporary table stati_ordini(
stato varchar(255) primary key
);
insert into Stati_ordini values ('Pendente');
insert into Stati_ordini values ('Processazione');
insert into Stati_ordini values ('Preparazione');
insert into Stati_ordini values ('Spedito');
insert into Stati_ordini values ('Evaso');



select s1.Stato , COUNT(o1.COD_Ordine) as Numero_Ordini
from Stati_ordini s1 left outer join ordine o1 on o1.Stato = s1.stato
group by s1.stato;
drop temporary table if exists stati_ordini;
end$$
delimiter ;

drop procedure if exists Cancella_Ordine;
delimiter $$
create procedure Cancella_Ordine(IN _Ordine INT) 
begin

	declare errore tinyint;
    set errore = (select 1 from ordine where COD_Ordine = _Ordine); -- controllo se esiste l'ordine
	if( errore is null ) then signal sqlstate '45000' set message_text = 'ERRORE! ordine inesistente!'; end if;
    
    set errore = (select 1 from ordine where COD_Ordine = _Ordine and Stato = 'Pendente'); 
    if( errore is null) then signal sqlstate '45000' set message_text = 'ERRORE! ordine non pendente!'; end if;
    
    update Prodotto set prenotato = 0 , COD_Ordine = NULL where COD_Ordine = _Ordine;
    
    delete from ordine where COD_Ordine = _Ordine;


end $$
delimiter ;

drop procedure if exists Show_Details_Ordine;
delimiter $$
create procedure Show_Details_Ordine(IN _Ordine INT , IN Fattura TINYINT) 
begin

	declare errore tinyint;
	declare Stat varchar(50);
    
    if(fattura is null) then set fattura = 0; end if;
    set errore = (select 1 from ordine where COD_Ordine = _Ordine); -- controllo se esiste l'ordine
	if( errore is null ) then signal sqlstate '45000' set message_text = 'ERRORE! ordine inesistente!'; end if;
    
	
    select Stato into Stat
    from ordine 
    where COD_Ordine = _ordine;
   if(fattura = 0) then 
    if(Stat = 'Pendente') then
    select o.NickName , o.Timestamp_Ordine , o.Stato , 
    SUM(Quantita_Da_Soddisfare) as Quantita_Da_Soddisfare_Totale ,
    SUM(Quantita_Rimanente_Da_Soddisfare) as Quantita_Rimanente_Da_Sodisfare_Totale ,
	(SUM(Quantita_Da_Soddisfare) - SUM(Quantita_Rimanente_Da_Soddisfare)) as Quantita_Soddisfatta_Totale ,
    AVG(Quantita_Da_Soddisfare) as Quantita_Da_Soddisfare_Media ,
    AVG(Quantita_Rimanente_Da_Soddisfare) as Quantita_Rimanente_Da_Sodisfare_Media ,
	AVG(Quantita_Da_Soddisfare - Quantita_Rimanente_Da_Soddisfare) as Quantita_Soddisfatta_Media 
    
    
    from ordine o inner join ordinependente_oggetto oo using(COD_ordine)
    where o.cod_ordine = _ordine
    group by o.cod_ordine;
    
    
    
    
    elseif(Stat = 'Processazione') then
		
	with T1 as (
		select COD_Seriale , Marca , Modello , Qualita
	from (
		select COD_Seriale , COD_Ordine , p.ID_Lotto , s.Marca , s.Modello , 0 as Qualita 		from prodotto p		inner join lotto l on l.id_lotto = p.id_lotto		 inner join sequenza s using(ID_Sequenza)
	UNION
		select COD_Seriale , COD_Ordine , p1.ID_Lotto , Marca , Modello , Qualita from prodotto p1 inner join lotto_ricondizionati l1 on l1.id_lotto = p1.id_lotto
		) as P
		where COD_Ordine = _ordine
		)
		,
		t2 as(
		select COD_Seriale ,Marca , Modello, qualita , o.prezzo , tp.Passo ,if(qualita = 0 , 0 , tp.Sconto_Iniziale) as Sconto_Iniziale
		from t1 
		inner join oggetto o using(Marca , Modello)
		inner join tipo_prodotto tp on tp.nome = o.tipo_prodotto
		)

		select COD_Seriale , Marca , Modello , FLOOR((Prezzo - (Prezzo*(Qualita*Passo + Sconto_Iniziale)/100))) as Prezzo
		from t2;
        
    elseif(Stat = 'Preparazione') then
     
    with T1 as (
		select COD_Seriale , Marca , Modello , Qualita
	from (
		select COD_Seriale , COD_Ordine , p.ID_Lotto , s.Marca , s.Modello , 0 as Qualita from prodotto p inner join lotto l on l.id_lotto = p.id_lotto		 inner join sequenza s using(ID_Sequenza)
	UNION
		select COD_Seriale , COD_Ordine , p1.ID_Lotto , Marca , Modello , Qualita from prodotto p1 inner join lotto_ricondizionati l1 on l1.id_lotto = p1.id_lotto
		) as P
		where COD_Ordine = _ordine
		)
		,
		t2 as(
		select COD_Seriale ,Marca , Modello, qualita , o.prezzo , tp.Passo ,if(qualita = 0 , 0 , tp.Sconto_Iniziale) as Sconto_Iniziale
		from t1 
		inner join oggetto o using(Marca , Modello)
		inner join tipo_prodotto tp on tp.nome = o.tipo_prodotto
		)

		select COD_Seriale , Marca , Modello , FLOOR((Prezzo - (Prezzo*(Qualita*Passo + Sconto_Iniziale)/100))) as Prezzo
		from t2;
        
    elseif(Stat = 'Spedito') then
    with T1 as (
		select COD_Seriale , Marca , Modello , Qualita
	from (
		select COD_Seriale , COD_Ordine , p.ID_Lotto ,  s.Marca , s.Modello , 0 as Qualita 		from prodotto p		inner join lotto l on l.id_lotto = p.id_lotto		 inner join sequenza s using(ID_Sequenza)
	UNION
		select COD_Seriale , COD_Ordine , p1.ID_Lotto , Marca , Modello , Qualita from prodotto p1 inner join lotto_ricondizionati l1 on l1.id_lotto = p1.id_lotto
		) as P
		where COD_Ordine = _ordine
		)
		,
		t2 as(
		select COD_Seriale ,Marca , Modello, qualita , o.prezzo , tp.Passo ,if(qualita = 0 , 0 , tp.Sconto_Iniziale) as Sconto_Iniziale
		from t1 
		inner join oggetto o using(Marca , Modello)
		inner join tipo_prodotto tp on tp.nome = o.tipo_prodotto
		)

		select COD_Seriale , Marca , Modello , FLOOR((Prezzo - (Prezzo*(Qualita*Passo + Sconto_Iniziale)/100))) as Prezzo
		from t2;
        
    elseif(Stat = 'Evaso')then
    with T1 as (
		select COD_Seriale , Marca , Modello , Qualita
	from (
		select COD_Seriale , COD_Ordine , p.ID_Lotto , s.Marca , s.Modello , 0 as Qualita from prodotto p	inner join lotto l on l.id_lotto = p.id_lotto inner join sequenza s using(ID_Sequenza)
	UNION
		select COD_Seriale , COD_Ordine , p1.ID_Lotto , Marca , Modello , Qualita from prodotto p1 inner join lotto_ricondizionati l1 on l1.id_lotto = p1.id_lotto
		) as P
		where COD_Ordine = _ordine
		)
		,
		t2 as(
		select COD_Seriale ,Marca , Modello, qualita , o.prezzo , tp.Passo ,if(qualita = 0 , 0 , tp.Sconto_Iniziale) as Sconto_Iniziale
		from t1 
		inner join oggetto o using(Marca , Modello)
		inner join tipo_prodotto tp on tp.nome = o.tipo_prodotto
		)

		select COD_Seriale , Marca , Modello , FLOOR((Prezzo - (Prezzo*(Qualita*Passo + Sconto_Iniziale)/100))) as Prezzo
		from t2;
        
    
    end if;
    
    else
    
    with T1 as (
		select COD_Seriale , Marca , Modello , Qualita
	from (
		select COD_Seriale , COD_Ordine , p.ID_Lotto , s.Marca , s.Modello , 0 as Qualita from prodotto p inner join lotto l on l.id_lotto = p.id_lotto inner join sequenza s using(ID_Sequenza)
	UNION
		select COD_Seriale , COD_Ordine , p1.ID_Lotto , Marca , Modello , Qualita from prodotto p1 inner join lotto_ricondizionati l1 on l1.id_lotto = p1.id_lotto
		) as P
		where COD_Ordine = _ordine
		)
		,
		t2 as(
		select qualita , o.prezzo , tp.Passo ,if(qualita = 0 , 0 , tp.Sconto_Iniziale) as Sconto_Iniziale
		from t1 
		inner join oggetto o using(Marca , Modello)
		inner join tipo_prodotto tp on tp.nome = o.tipo_prodotto
		)
		,
		t3 as(
		select FLOOR((Prezzo - (Prezzo*(Qualita*Passo + Sconto_Iniziale)/100))) as Prezzo
		from t2
        )
        ,
    t4 as(
    select SUM(Prezzo) as Prezzo
	from t3
    )
    
    select _Ordine as Codice_Ordine , CONCAT( Prezzo ,' ' ,  _ucs2 0x20AC) as Prezzo
    from t4;
    
    end if;
    



end $$
delimiter ;

drop table if exists prodotto;
CREATE TABLE prodotto (
    COD_Seriale INT PRIMARY KEY AUTO_INCREMENT,
    ID_Lotto INT NOT NULL,
    COD_Ordine INT DEFAULT 0,
    Prenotato TINYINT DEFAULT 0,
    KEY Prodotti (COD_Seriale)
)  ENGINE=INNODB;


drop table if exists OrdinePendente_Oggetto;
CREATE TABLE OrdinePendente_Oggetto (
    COD_Ordine INT,
    Marca VARCHAR(100),
    Modello VARCHAR(100),
    Quantita_Da_Soddisfare INT NOT NULL,
    Quantita_Rimanente_Da_Soddisfare INT NOT NULL,
    PRIMARY KEY (COD_Ordine , Marca , Modello),
    CONSTRAINT Ordine_OrdinePend FOREIGN KEY (COD_Ordine) REFERENCES Ordine (COD_ordine) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Ogg_OrdinePend FOREIGN KEY (Marca , Modello)  REFERENCES Oggetto (Marca , Modello) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

-- all inserimento di un ordine tramite la appostita procedura (che tra l altro prepara il record della spedizione)
-- non ha requisiti , essi vanno assegnati tramite assegnazione_prodotti_ordine 
-- quindi dopo aver inserito un ordine va eseguita l'assegnazione , dopo aver eseguito tutte le assegnazioni occorre eseguire la Check_Fine_Pendenza per verificare se i requisiti sono già tutti soddisfatti


drop procedure if exists Assegnazione_Prodotti_Ordine;
delimiter $$
create procedure Assegnazione_Prodotti_Ordine(IN _Ordine INT , IN _Marca VARCHAR(255) , IN _Mod VARCHAR(255) , In Quantita INT )
begin 
declare Num_Prod int default 0;

set Num_Prod = (
with Lotti_T as (select id_Lotto from lotto  inner join sequenza s using(ID_Sequenza) where s.Marca = _Marca and s.Modello = _Mod and data_fine_effettiva is not null)
select COUNT(*) from prodotto where ID_Lotto IN (select * from Lotti_T) and COD_ordine is null);

if(Num_Prod >= Quantita) THEN
update prodotto set COD_Ordine = _Ordine , prenotato = 0 where COD_Seriale IN
 ( 
 
	with Lotti_T as 
		(
			select id_Lotto -- prendo i lotti che mi servono 
			from lotto 
			 inner join sequenza s using(ID_Sequenza)
			where s.Marca = _Marca and s.Modello = _Mod and data_fine_effettiva is not null
		) ,
 
	t1 as(
		select p.COD_Seriale , 
		row_number() over() as Num  -- prendo i prodotti non prenotati o venduti appartenenti a queilotti
		from (select * from prodotto) as P  -- inoltre li numero
		where p.ID_Lotto IN (select * from Lotti_T) and COD_ordine is null
		)

select cod_seriale
from t1 -- prenoto i primi *quantita* prodotti
where num <= quantita

);


 INSERT INTO OrdinePendente_Oggetto VALUES(_Ordine , _Marca , _Mod ,Quantita , 0);
 
ELSE

Update prodotto set COD_Ordine = _Ordine , prenotato = 1 
where COD_Seriale IN (  with Lotti_T as (select id_Lotto from lotto  inner join sequenza s using(ID_Sequenza) where Marca = _Marca and Modello = _Mod and data_fine_effettiva is not null)
select p.COD_Seriale from (select * from prodotto) as P where p.ID_Lotto IN (select * from Lotti_T) and p.prenotato = 0 and p.COD_ordine is null  );

INSERT INTO Ordinependente_Oggetto VALUES(_Ordine , _Marca , _Mod ,Quantita ,Quantita - Num_prod);
end if;


end $$
delimiter ;

drop procedure if exists Assegnazione_Specifico_Prodotto_Ordine;
delimiter $$
create procedure Assegnazione_Specifico_Prodotto_Ordine(IN _Ordine INT , IN _Serial INT )
begin 
	declare errore int;
    
    select 1 into errore from prodotto where COD_Seriale = _serial and COD_ordine is null;
    if(errore is null) then signal sqlstate '45000' set message_text = 'Il prodotto non esiste o è già stato venduto/prenotato!'; end if;
    
    select 1 into errore from ordine where cod_ordine = _ordine and stato = 'pendente';
    if(errore is null) then signal sqlstate '45000' set message_text = 'Ordine inesistente o non pendente!'; end if;
    
    update Prodotto set COD_ordine = _Ordine , prenotato = 0 where cod_seriale = _serial;
    
end $$
delimiter ;

drop procedure if exists Check_fine_Pendenza;
delimiter $$
create procedure Check_fine_Pendenza(IN _Ordine INT )
begin 
    declare fine_pend int default 0;
    
    select COUNT(*) into fine_pend
    from ordinependente_oggetto op
    where op.cod_ordine =_ordine and Quantita_Rimanente_Da_Soddisfare <> 0;
    
    if(fine_pend = 0) then call fine_pendenza(_ordine); end if;

end $$
delimiter ;

drop trigger if exists Prenotazione_Prodotti_Ordini_Pendenti_Before;
delimiter $$
create trigger Prenotazione_Prodotti_Ordini_Pendenti_Before before insert on Prodotto for each row
begin 
	declare mar varchar(255);
    declare model varchar(255);
    
    declare Primo int;
    declare q int;
    
    
    select marca , modello into mar , model
    from lotto
	 inner join sequenza s using(ID_Sequenza)
    where id_lotto = new.id_lotto;
    
    select COD_ordine into Primo  -- prendo il primo della lista in modo che prenoti i prodotti
    from ordinependente_oggetto op 
	inner join ordine using(cod_ordine)
    where op.marca = marca and op.modello = model
    order by timestamp_ordine asc
    limit 1;
    
   
   if(primo is not null) then 
   set new.cod_ordine = Primo;
   set new.prenotato = 1; 
   end if;
   
   
   
end $$
delimiter ;

drop trigger if exists Prenotazione_Prodotti_Ordini_Pendenti_After;
delimiter $$
create trigger Prenotazione_Prodotti_Ordini_Pendenti_After after insert on Prodotto for each row
begin 
	 
    declare mar varchar(255);
    declare model varchar(255);
	
    if(new.cod_ordine is not null) then
   
SELECT marca, modello INTO mar , model 
FROM lotto  inner join sequenza s using(ID_Sequenza) WHERE id_lotto = new.id_lotto;
    
UPDATE ordinependente_oggetto 
SET     Quantita_Rimanente_Da_Soddisfare = Quantita_Rimanente_Da_Soddisfare - 1
WHERE    cod_ordine = new.cod_ordine        AND marca = mar        AND modello = model;
 
call check_fine_pendenza (new.cod_ordine);
   end if;
end $$
delimiter ;

drop trigger if exists Gestione_Data_Venduto_In_Lotto;
delimiter $$
create trigger Gestione_Data_Venduto_In_Lotto after update on Prodotto for each row
begin

	declare data_vend_lott date;
    declare num_prod int;
    declare num_prod_vend int;
    
    
    select Data_Venduto into data_vend_lott from lotto where id_lotto = new.id_lotto;
    
    if(data_vend_lott is null) then
		select tp.soglia_lotti into num_prod
		from lotto l 
		inner join sequenza s using(ID_Sequenza)
		inner join oggetto o using(marca , modello)
		inner join tipo_prodotto tp on tp.Nome = o.Tipo_Prodotto
		where id_lotto = new.id_lotto;
		
		select COUNT(*) into num_prod_vend 
		from prodotto p
		where id_lotto = new.id_lotto and COD_Ordine is not null and Prenotato = 0;
    
    
    
		if( (new.COD_Ordine is not null AND new.Prenotato = 0 AND new.cod_seriale = old.cod_seriale AND new.id_lotto = old.id_lotto) and num_prod_vend = num_prod) then
    
			update lotto set data_venduto = current_date where id_lotto = new.id_lotto;
    
    
		end if;
	end if;
end $$

delimiter ;

drop procedure if exists fine_pendenza;
delimiter $$
create procedure fine_pendenza(IN _Ordine INT)
begin 

	update ordine set stato = 'processazione' , Timestamp_fine_Pendenza = current_timestamp where cod_ordine = _ordine; -- passa allo stato di processazione
    delete from ordinependente_oggetto where cod_ordine = _ordine; -- elimino tutti i record relativi alla fase pendente
  

end $$
delimiter ;

drop table if exists Magazzino_Componente;
CREATE TABLE Magazzino_Componente (
    ID_Magazzino INT PRIMARY KEY AUTO_INCREMENT,
    Nome_Via VARCHAR(50) NOT NULL,
    Numero_Civico VARCHAR(20) NOT NULL,
	Provincia varchar(255) not null ,
     Mt_Quadri INT UNSIGNED NOT NULL ,
    constraint prov_mag_comp foreign key (Provincia) references Provincia (nome) on delete cascade on update cascade  
   
)  ENGINE=INNODB;

drop table if exists spedizione;
CREATE TABLE spedizione (
    cod_ordine INT PRIMARY KEY,
    Provincia varchar(255) not null ,
   
    Nome_Via VARCHAR(50) NOT NULL,
    Numero_Civico VARCHAR(20) NOT NULL,
    data_Partenza DATE DEFAULT NULL,
    data_consegna_prevista DATE DEFAULT NULL,
    data_consegna_effettiva DATE DEFAULT NULL,
    stato_spedizione VARCHAR(255) DEFAULT NULL,
	constraint prov_sped foreign key (Provincia) references Provincia (nome) on delete cascade on update cascade  ,
    CONSTRAINT ordine_sped FOREIGN KEY (COD_Ordine) REFERENCES Ordine (COD_Ordine) ON DELETE CASCADE ON UPDATE CASCADE,
   
    CHECK (data_partenza < data_consegna_prevista)
)  ENGINE=INNODB;

drop table if exists Spedizione_Hub;
CREATE TABLE Spedizione_Hub (
    prov_hub varchar(255),
    cod_spedizione INT,
    timestamp_passaggio TIMESTAMP NOT NULL,
    CHECK ( timestamp_passaggio > '2000-01-01') ,
    CONSTRAINT Rel_sped FOREIGN KEY (COD_Spedizione) REFERENCES Spedizione (COD_Ordine) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Rel_Hub_Sped FOREIGN KEY (prov_Hub) REFERENCES Hub (Provincia)  ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop trigger if exists Controllo_Cambio_Stato_ordine_Spedizione_Hub;
delimiter $$
create trigger Controllo_Cambio_Stato_ordine_Spedizione_Hub before insert on spedizione_hub for each row
begin
	declare s varchar(255);
    
    select stato into s
    from ordine where cod_ordine = new.cod_spedizione;
    
    if(s <> 'Spedito') then signal sqlstate '45000' set message_text = 'Ordine non ancora spedito o evaso!'; end if;

    
end $$
delimiter ;

drop procedure if exists Passaggio_Spedizione_Hub;
delimiter $$
create procedure Passaggio_Spedizione_Hub(IN _sped INT, IN Provi varchar(255))
begin 
    insert into Spedizione_Hub values ( Provi	,_sped , current_timestamp);
end $$
delimiter ;

drop trigger if exists Cambio_Stato_Spedizione_Hub;
delimiter $$
create trigger Cambio_Stato_Spedizione_Hub after insert on spedizione_hub for each row
begin
	declare prov_ob varchar(255);
    declare Num int;
    
    select COUNT(*) - 1 into Num
    from spedizione_hub
    where COD_spedizione = new.cod_spedizione;
     if(num is null) then set num = 0; end if;
     
    select Provincia into prov_ob
	from ordine o
	inner join account using(nickname)
	inner join persona using(COD_Fiscale)
    where new.cod_spedizione = o.COD_Ordine;
    
    if(num = 0) then  -- è il primo hub toccato
    update spedizione set stato_spedizione = 'In transito' where COD_ordine = new.cod_spedizione;
    end if;
    
    if(new.prov_hub = prov_ob)then  -- è l'ultimo hub
    update spedizione set stato_spedizione = 'In consegna' where COD_ordine = new.cod_spedizione;
    end if;
    

    
end $$
delimiter ;

drop table if exists recensione;
CREATE TABLE recensione (
    cod_recensione INT PRIMARY KEY AUTO_INCREMENT,
    Marca VARCHAR(255),
    Modello VARCHAR(255),
    COD_Ordine INT,
    Affidabilita INT,
    Esperienza INT,
    Performance INT,
    Design INT,
    Testo_Recensione TEXT ,
    CHECK (Affidabilita BETWEEN 0 AND 5),
    CHECK (Esperienza BETWEEN 0 AND 5),
    CHECK (Performance BETWEEN 0 AND 5),
    CHECK (Design BETWEEN 0 AND 5),
    CONSTRAINT ordine_rec FOREIGN KEY (COD_Ordine) REFERENCES Ordine (COD_Ordine) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Ogg_Rec FOREIGN KEY (Marca , Modello) REFERENCES Oggetto (Marca , Modello) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop trigger if exists ControlloDataConsegnaEffettiva_Spedizione;
delimiter $$
create trigger ControlloDataConsegnaEffettiva_Spedizione
 before update on spedizione for each row
 begin
	if(new.data_consegna_effettiva is not null AND new.data_consegna_effettiva < new.Data_partenza ) then 
    signal sqlstate '45000' set message_text ='ERRORE Data partenza superiore alla data consegna effettiva!';
    end if;
	
 end $$
delimiter ;

drop procedure if exists Recensisci_Oggetto;
delimiter $$
create procedure Recensisci_Oggetto(IN _Ordine INT, IN _Marca VARCHAR(255) , IN _Mod VARCHAR(255) , IN Aff INT , IN Esp INT , IN Per INT , IN Des INT , IN _testo TEXT)
begin 
	declare errore tinyint default 0;
	
    set errore = ( -- se l'ordine non esiste , oppure se il nickname specificato non ha mai ordinato nulla
    select if(cod_ordine is null , 1 , 0) from ordine where cod_ordine = _ordine);
    if (errore = 1) then signal sqlstate'45000' set message_text = 'ERRORE! Ordine Inesistente'; end if;
    
    set errore = (-- se l'ordine esiste ma non è evaso , quindi il cliente non può sapere come sono fatti i prodotti
    select if(cod_ordine is not null , 1 , 0) from ordine where cod_ordine = _ordine and Stato <> 'Evaso');
    if (errore = 1) then signal sqlstate'45000' set message_text = 'ERRORE! Ordine non ancora evaso!'; end if;
    
    set errore = ( -- se l'ordine esiste ed è evaso , ma in quell ordine non sono stati ordinati i prodotti specificati
	select if(o.cod_ordine is null , 1 , 0) 
    from ordine o
    inner join prodotto p on p.cod_ordine = o.cod_ordine
    inner join lotto l on p.id_lotto = l.id_lotto
	 inner join sequenza s using(ID_Sequenza)
    where p.cod_ordine = _ordine and s.marca = _Marca and s.modello = _Mod and p.prenotato <> 1
    limit 1
    );
    if (errore = 1) then signal sqlstate'45000' set message_text = 'ERRORE! Nell ordine specificato non è stato acquistato il prodotto indicato nei parametri!'; end if;


	insert into recensione values (null , _Marca , _mod , _ordine , aff , esp , per , des , _testo);
end $$
delimiter ;

DROP TABLE IF EXISTS Scorte_Magazzino_Componente;
CREATE TABLE Scorte_Magazzino_Componente (
    id_magazzino INT,
    cod_componente INT,
    quantita INT UNSIGNED NOT NULL,
    PRIMARY KEY (id_magazzino , cod_componente),
    CONSTRAINT mag_comp_scorte FOREIGN KEY (id_magazzino) REFERENCES magazzino_componente (id_magazzino) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT comp_mag_scorte FOREIGN KEY (cod_componente) REFERENCES componente (cod_componente) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

DROP TABLE IF EXISTS Ordine_Interno_SedeProduzione;
CREATE TABLE Ordine_Interno_SedeProduzione (
    cod_sede INT,
    id_magazzino INT,
    cod_componente INT,
    timestamp_ordine TIMESTAMP,
    quantita INT UNSIGNED NOT NULL,
    PRIMARY KEY (cod_sede , id_magazzino , cod_componente),
    CHECK (timestamp_ordine > '2000-01-01'),
    CONSTRAINT sede_scorte_ord FOREIGN KEY (cod_sede) REFERENCES sede_produzione (cod_sede) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT mag_comp_sede_ord FOREIGN KEY (id_magazzino) REFERENCES magazzino_componente (id_magazzino) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT comp_sede_ord FOREIGN KEY (cod_componente) REFERENCES componente (cod_componente)  ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop procedure if exists Rifornisci_Magazzino_Componente;
delimiter $$
create procedure Rifornisci_Magazzino_Componente (In Mag INT , In Comp INT , IN Quant INT)
begin
	declare r tinyint default null;
    
    select 1 into r from scorte_Magazzino_Componente where cod_componente = comp AND id_Magazzino = Mag;
    if(r is not null) then
	update scorte_Magazzino_Componente set Quantita = Quantita + abs(Quant) where cod_componente = comp AND id_Magazzino = Mag;
    else
    insert into scorte_Magazzino_Componente values (Mag , Comp , ABS(Quant));
    end if;

end $$
delimiter ;


DROP TABLE IF EXISTS Scorte_SedeProduzione;
CREATE TABLE Scorte_SedeProduzione (
    cod_sede INT,
    cod_componente INT,
    quantita INT UNSIGNED NOT NULL,
    PRIMARY KEY (cod_sede , cod_componente),
    CONSTRAINT sede_scorte FOREIGN KEY (cod_sede) REFERENCES sede_produzione (cod_sede) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT comp_sede FOREIGN KEY (cod_componente) REFERENCES componente (cod_componente) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop procedure if exists ordine_interno_Sede_Magazzino;
delimiter $$
create procedure ordine_interno_Sede_Magazzino (in sed INT , in Mag INT , In comp INT , in Quant INT)
begin

	declare errore int;
    
	if(quant < 0 or quant is null) then set quant = 0;  end if;
    
	select 1 into errore from sede_produzione where cod_sede = sed;
    if(errore is null) then signal sqlstate '45000' set message_TEXT = 'Sede Inesistente!'; end if;
    
    select 1 into errore from Magazzino_Componente where id_magazzino =  mag;
    if(errore is null) then signal sqlstate '45000' set message_TEXT = 'Magazzino Inesistente!';end if;
	
    select 1 into errore from Componente where cod_componente = comp;
    if(errore is null) then signal sqlstate '45000' set message_TEXT = 'Componente Inesistente!';end if;

	set errore = null; -- riciclo errore
    
    select 1 into errore from Scorte_Magazzino_Componente where id_magazzino = mag and cod_componente = comp and quantita >= quant; -- controllo se il magazzino ha quella scorta e sopratutto se ha abbastanza componenti per soddisfare la richiesta
    if(errore = 1) then 
     update Scorte_Magazzino_Componente set Quantita = quantita - quant where id_Magazzino = Mag and cod_componente = comp; -- se esiste la scorta la aggiorno
    else 
    signal sqlstate '45000' set message_TEXT = 'Scorte del magazzino insufficenti a soddisfare la richiesta!'; 
    end if;
    
    
    select 1 into errore from Scorte_SedeProduzione where COD_Sede = sed and cod_componente = comp;
    if(errore = 1 ) then 
    update Scorte_SedeProduzione set Quantita = quantita + quant where COD_Sede = sed and cod_componente = comp; -- se esiste la scorta la aggiorno
    else 
    insert into Scorte_SedeProduzione values (sed , comp , quant); -- se non esiste la scorta la creo
    end if;
    
   
		
end $$

delimiter ;

drop table if exists Garanzia;
CREATE TABLE Garanzia (
    COD_Garanzia INT PRIMARY KEY AUTO_INCREMENT,
    Tipo_prodotto VARCHAR(255),
    Classe_Guasto VARCHAR(255),
    Costo INT UNSIGNED,
    Durata INT UNSIGNED,
    Numero_Volte_Acquistata INT UNSIGNED DEFAULT 0,
    COD_Componente INT,
    CONSTRAINT Tipo_Prodotto_Garanzia FOREIGN KEY (Tipo_Prodotto) REFERENCES tipo_prodotto (Nome)  ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Componente_Garanzia FOREIGN KEY (COD_Componente) REFERENCES Componente (Cod_Componente)ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

insert into Garanzia values (null , 'Tutti' ,'Tutti' , 0 , 24, 0 , 28 ); -- codice = 1 , è la garanzia di base

drop table if exists Garanzia_Prodotto;
CREATE TABLE Garanzia_prodotto (
    COD_Seriale INT,
    COD_Garanzia INT,
    Timestamp_Inizio TIMESTAMP,
    Durata INT UNSIGNED,
    Numero_Garanzie INT UNSIGNED,
    CHECK (timestamp_inizio > '2000-01-01'),
    PRIMARY KEY (cod_seriale , cod_garanzia , timestamp_inizio),
    CONSTRAINT garanzia_prod FOREIGN KEY (cod_seriale) REFERENCES prodotto (cod_seriale)  ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT garanzia_gar FOREIGN KEY (cod_garanzia) REFERENCES Garanzia (cod_garanzia) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop procedure if exists Catalogo_Garanzie;
delimiter $$
create procedure Catalogo_Garanzie(In _Marc VARCHAR(255) , IN _mod VARCHAR(255))
begin
if(_Marc is null and _Mod is null) then  
select g.Tipo_prodotto , o.Marca , o.Modello ,  g.Classe_Guasto ,
if(c.Nome = 'Tutto', 'Tutti i componenti' , c.Nome)  as Nome_Componente ,

CONCAT(Costo , ' ',_ucs2 0x20AC) as Costo, CONCAT(Durata , ' Mesi') as Durata , Numero_Volte_Acquistata
from garanzia g
inner join oggetto o using(tipo_prodotto)
inner join componente c using(COD_Componente)
where g.COD_Garanzia <> 1;

elseif( _Marc is not null and _Mod is null) then
select g.Tipo_prodotto , o.Marca , o.Modello ,  g.Classe_Guasto ,
if(c.Nome = 'Tutto', 'Tutti i componenti' , c.Nome)  as Nome_Componente ,

CONCAT(Costo , ' ',_ucs2 0x20AC) as Costo, CONCAT(Durata , ' Mesi') as Durata , Numero_Volte_Acquistata
from garanzia g
inner join oggetto o using(tipo_prodotto)
inner join componente c using(COD_Componente)
where g.COD_Garanzia <> 1  AND o.marca = _Marc;

else 
select g.Tipo_prodotto , o.Marca , o.Modello ,  g.Classe_Guasto ,
if(c.Nome = 'Tutto', 'Tutti i componenti' , c.Nome)  as Nome_Componente ,

CONCAT(Costo , ' ',_ucs2 0x20AC) as Costo, CONCAT(Durata , ' Mesi') as Durata , Numero_Volte_Acquistata
from garanzia g
inner join oggetto o using(tipo_prodotto)
inner join componente c using(COD_Componente)
where g.COD_Garanzia <> 1  AND o.marca = _Marc and o.modello = _mod; 
end if;
end $$
delimiter ;

drop procedure if exists Assicura_Ordine_prodotto; -- UTILIZZATA SOLO DA SWITCH_ORDINE : dato un ordine , applica la garanzia base a tutti i rpodotti appena acquistati
delimiter $$
create procedure Assicura_Ordine_prodotto(IN _Ord INT)
begin
    
    declare finito int default 0;
    declare Prod int;
    
    declare curs cursor for
    select COD_Seriale from prodotto where COD_ordine = _Ord;
    
    declare continue handler for not found set finito = 1;
    
   
    open curs;
    prel : loop
    
    fetch curs into Prod;
	if finito = 1 then leave prel; end if;
    call Assicura_Prodotto(Prod , 1);
     
  
    end loop prel;
    close curs;
    
    end $$
delimiter ;

drop procedure if exists Assicura_Prodotto_Client; -- utilizzata dal client
delimiter $$
create procedure Assicura_Prodotto_Client(IN _Serial INT , In _Gar INT)
begin
  	declare errore tinyint;
    declare tipogar varchar(255);
	
	SELECT 1 INTO errore FROM prodotto WHERE cod_seriale = _serial AND cod_ordine IS NOT NULL;
	if (errore is null) then  signal sqlstate'45000' set message_text ='Prodotto inesistente o non venduto!'; end if;
        
	SELECT 1 INTO errore FROM garanzia WHERE cod_garanzia = _gar;
	if (errore is null) then  signal sqlstate'45000' set message_text ='ERRORE! Garanzia Inesistente!';  end if;
    
    select g.Classe_Guasto into tipogar
    from garanzia g where COD_Garanzia = _gar;
    
    if(tipogar IN('Assistenza Fisica Componenti' , 'Assistenza Fisica Parti') or _gar = 1 ) then -- se la garanzia è quella base non serve fare questo controllo...
        signal sqlstate'45000' set message_text ='ERRORE! Impossibile applicare questo tipo di garanzia!'; 
       else
       select 1 into errore  
       from prodotto p 
        inner join lotto l on l.ID_Lotto = p.id_lotto
        inner join oggetto o Using(Marca , Modello)
        where cod_seriale = _serial and (o.Tipo_prodotto = (select tipo_prodotto from garanzia where cod_garanzia = _gar));
		end if;
        
        if (errore is null) then signal sqlstate'45000' set message_text = 'ERRORE! La garanzia esiste ma è INCOMPATIBILE con il prodotto scelto!'; end if;
		
        CALL Assicura_Prodotto(_serial , _gar);
    end $$
delimiter ;

drop trigger if exists Componente_Aggiungi_Garanzia_AF;
delimiter $$
create trigger  Componente_Aggiungi_Garanzia_AF after insert on Componente for each row
begin

if(new.parte = 0) then
	insert into Garanzia values (null , 'Tutti' , 'Assistenza Fisica Componenti' , 0 , 6 , 0 , new.cod_componente);
    else
    insert into Garanzia values (null , 'Tutti' , 'Assistenza Fisica Parte' , 0 , 12 , 0 , new.cod_componente);
    end if;
end $$

delimiter ;


drop procedure if exists Assicura_Prodotto;
delimiter $$
create procedure Assicura_Prodotto(IN _Serial INT , In _Gar INT)
begin

declare errore int default null;

SELECT cod_seriale INTO errore
 FROM garanzia_prodotto WHERE COD_Seriale = _serial AND cod_garanzia = _gar  AND 
 CURRENT_TIMESTAMP <= (timestamp_inizio + INTERVAL Durata MONTH); -- e se è ancora in corso

        if (errore is not null) then
       
		update Garanzia_prodotto set Numero_Garanzie = Numero_Garanzie + 1 ,
        Durata = (-1*(ABS(PERIOD_DIFF( DATE_FORMAT(timestamp_inizio , '%Y%m') , DATE_FORMAT(current_timestamp , '%Y%m')))) + 2*(select Durata from garanzia where COD_Garanzia = _Gar))
        where COD_Garanzia = _Gar and COD_Seriale = _serial;
	
		else
         
       insert into Garanzia_prodotto values (_serial , _gar , current_timestamp , (select Durata from garanzia where COD_Garanzia = _Gar) , 1 );
        end if;
        
UPDATE garanzia SET Numero_Volte_Acquistata = Numero_Volte_Acquistata + 1 WHERE cod_Garanzia = _gar;
    end $$
delimiter ;
    
drop table if exists Motivazioni_reso;
CREATE TABLE Motivazioni_reso (
    Nome VARCHAR(255) PRIMARY KEY,
    Descrizione TEXT 
)  ENGINE=INNODB;
 
 drop procedure if exists Inserimento_Motivazione_di_reso;
 delimiter $$
 create procedure Inserimento_Motivazione_di_reso (In Nome VARCHAR(255) ,IN Testo TEXT)
 begin
 
	if(testo is null OR testo = ' ') then signal sqlstate '45000' set message_text = 'Testo non Valido!'; end if;

    insert into Motivazioni_reso values(Nome , testo);
 end $$
 delimiter ;
 
 drop procedure if exists Cancellazione_Motivazione_di_reso;
 delimiter $$
 create procedure Cancellazione_Motivazione_di_reso(In _Nome VARCHAR(255))
 begin
 
 declare err int;
 select 1 into err from motivazioni_reso where Nome = _Nome;
if(err is null) then signal sqlstate '45000' set message_text = 'Motivazione di reso inesistente!'; end if;

   delete from motivazioni_reso where Nome = _nome;
 end $$
 delimiter ;
 
drop table if exists Richiesta_Di_reso;
CREATE TABLE Richiesta_Di_reso (
    COD_Seriale INT,
    Timestamp_Invio TIMESTAMP,
    Nickname VARCHAR(255),
    Motivazione VARCHAR(255),
    Timestamp_Accettazione TIMESTAMP DEFAULT NULL,
    Timestamp_Rifiuto TIMESTAMP DEFAULT NULL,
    PRIMARY KEY (COD_Seriale , Timestamp_invio),
    CHECK (timestamp_invio > '2000-01-01'),
    CONSTRAINT Accou_RichReso FOREIGN KEY (NickName) REFERENCES Account (Nickname) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Prod_RichReso FOREIGN KEY (COD_Seriale)  REFERENCES prodotto (cod_Seriale) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Motivazione_RichReso FOREIGN KEY (Motivazione) REFERENCES Motivazioni_Reso (Nome) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Lotto_Ricondizionati;
CREATE TABLE Lotto_Ricondizionati (
    ID_Lotto INT PRIMARY KEY,
    Marca VARCHAR(100) NOT NULL,
    Modello VARCHAR(100) NOT NULL,
    ID_Magazzino INT NOT NULL,
    Scaffale INT UNSIGNED NOT NULL,
    Ripiano INT UNSIGNED NOT NULL,
    posizione INT UNSIGNED NOT NULL,
    Quantita_prodotti INT UNSIGNED DEFAULT 0,
    qualita INT ,
    UNIQUE (ID_Magazzino , scaffale , ripiano , posizione),
    CONSTRAINT Ogg_Lotto_ric FOREIGN KEY (Marca , Modello) REFERENCES Oggetto (Marca , Modello)ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Lotto_Ric_Qualit FOREIGN KEY (Qualita) REFERENCES scala_qualita (valore) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Stock_ric FOREIGN KEY (ID_Magazzino) REFERENCES Magazzino (ID_Magazzino) ON DELETE CASCADE ON UPDATE CASCADE
);

drop procedure if exists Invio_Richiesta_Di_reso;
delimiter $$
create procedure Invio_Richiesta_Di_reso(IN _Serial INT , IN Nick VARCHAR(255) , IN _Mot VARCHAR(255))
begin
declare errore tinyint default 0;
declare giorni_passati int;
declare ts timestamp default current_timestamp;

    set errore = (
    select if(p.cod_seriale is null , 1 , 0)
    from prodotto p 
    inner join ordine o on o.cod_ordine = p.cod_ordine
    where p.cod_seriale = _serial and o.stato = 'evaso' and o.nickname = Nick
    limit 1
    );
    if (errore = 1) then signal sqlstate'45000' set message_text = 'ERRORE! Prodotto non valido!'; end if;


	select datediff(current_date ,s.data_consegna_effettiva ) into giorni_passati
    from spedizione s 
    inner join prodotto p on p.cod_ordine = s.cod_ordine and p.cod_seriale = _Serial;
    
    if(giorni_passati > 59) then signal sqlstate'45000' set message_text = 'ERRORE! Periodo di reso scaduto!'; end if; -- il numero massimo di giorni per il reso è 60 giorni
    
   insert into richiesta_di_reso values(_Serial , ts , Nick , _Mot , NULL ,NULL);

   if(_Mot = 'Diritto di Recesso') then -- l approvazione di una richiesta di reso avviene istantaneamente in caso di diritto di recesso
   call Esito_Richiesta_Di_reso(_Serial , ts , 1);
   end if;

end $$ 
delimiter ;

drop procedure if exists Esito_Richiesta_Di_reso;
delimiter $$
create procedure Esito_Richiesta_Di_reso(IN _Ser INT , IN _TI Timestamp , IN Esito TINYINT)
begin
	declare errore tinyint default 0;

    set errore = (
     select 1
     from richiesta_di_reso
     where cod_seriale = _Ser and timestamp_invio = _TI and (timestamp_accettazione is not null OR timestamp_rifiuto is not null)
    );
    if (errore = 1) then signal sqlstate'45000' set message_text = 'ERRORE! richiesta di reso gia valutata!'; end if;

	if(Esito = 1) then
	update Richiesta_di_reso set Timestamp_accettazione = current_timestamp where cod_seriale = _ser and timestamp_invio = _TI;
    else
    update Richiesta_di_reso set Timestamp_rifiuto = current_timestamp where cod_seriale = _ser and timestamp_invio = _TI;
    end if;
end $$ 
delimiter ;

drop procedure if exists Inserimento_Reso;
delimiter $$
create procedure Inserimento_Reso(IN _Ser INT,IN _Quality INT , IN _Mag INT , IN _S int , IN _R INT, IN _P int)
begin

declare errore tinyint default 0;
declare Lotto_Reso int;

declare Soglia_r int;
declare Qp_r int;

declare _Marc varchar(255);
declare _Mod varchar(255);

     select 1 into errore
     from richiesta_di_reso
     where cod_seriale = _Ser and timestamp_accettazione is not NULL;
    if (errore is null ) then signal sqlstate'45000' set message_text = 'ERRORE! prodotto inesistente!'; end if;
    
    set errore = null;
  
    select s.Marca , s.Modello into _Marc , _Mod
    from prodotto p 
	inner join lotto l on p.id_lotto = l.ID_Lotto
	 inner join sequenza s using(ID_Sequenza)
    where p.cod_seriale = _ser;
    
    select ID_Lotto into Lotto_reso
    from Lotto_Resi
    where Marca = _Marc AND Modello = _Mod AND    
    ID_Magazzino = _Mag AND Qualita = _Quality AND
    data_Completamento is null;
    
    if (Lotto_reso is not null) then -- se un lotto esiste gia
    
    insert into Reso values (_Ser , Lotto_reso , 0);
   
    select Quantita_prodotti +1 into Qp_r 
    from Lotto_resi where ID_Lotto = Lotto_reso;
    
    select FLOOR(Soglia_Lotti/4) into Soglia_r
    from tipo_prodotto tp 
	inner join oggetto o on o.Tipo_Prodotto = tp.Nome
    where o.Marca = _Marc and o.Modello = _Mod;
    
    if ( Qp_r = Soglia_r) then
    update Lotto_resi set Quantita_prodotti = soglia_r , Data_Completamento = current_date where ID_Lotto = lotto_reso;
    else
    update Lotto_resi set Quantita_prodotti = Quantita_prodotti + 1 where ID_Lotto = lotto_reso;
    end if;
    
    ELSE -- se il lotto non esiste
	CALL Controlla_Disponibilita_Spazio_In_Mag(_Mag , _S , _R , _P , errore);
	if(errore = 1) then signal sqlstate '45000' set message_text ='ERRORE , Locazione nel magazzino occupata!'; end if;
   
   insert into Lotto_resi values (null , _Marc , _Mod , _Mag , _s , _R , _p , _quality , 1 , current_date , null , null);
    
    set Lotto_Reso = (select MAX(ID_Lotto) from Lotto_resi);
    
	insert into Reso values (_Ser , Lotto_reso , 0);
    
     if ( 1 = Soglia_r) then -- nel caso eccezionale in cui la soglia lotti_reso sia pari a 1
    update Lotto_resi set Quantita_prodotti = soglia_r , Data_Completamento = current_date where ID_Lotto = lotto_reso;
   
    end if;
    end if;
    

end $$
delimiter ;

drop table if exists Lotto_Resi;
CREATE TABLE Lotto_Resi (
    ID_Lotto INT PRIMARY KEY AUTO_INCREMENT,
    Marca VARCHAR(100) NOT NULL,
    Modello VARCHAR(100) NOT NULL,
    ID_Magazzino INT NOT NULL,
    Scaffale INT UNSIGNED NOT NULL,
    Ripiano INT UNSIGNED NOT NULL,
    posizione INT UNSIGNED NOT NULL,
    Qualita INT NOT NULL,
    Quantita_prodotti INT UNSIGNED NOT NULL DEFAULT 0,
    Data_Inizio DATE NOT NULL,
    Data_Completamento DATE DEFAULT NULL,
    data_Ricondizionamento DATE DEFAULT NULL,
    CHECK (Data_inizio > '2000-01-01'),
    UNIQUE (ID_Magazzino , scaffale , ripiano , posizione),
    CONSTRAINT Lotto_resi_qualiti FOREIGN KEY (Qualita) REFERENCES scala_qualita (Valore) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Ogg_LottoR FOREIGN KEY (Marca , Modello) REFERENCES Oggetto (Marca , Modello) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Stock_LottoR FOREIGN KEY (ID_Magazzino) REFERENCES Magazzino (ID_Magazzino)  ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Reso;
CREATE TABLE Reso (
    COD_Seriale INT PRIMARY KEY,
    ID_Lotto INT,
    Valutato INT UNSIGNED NOT NULL,
    CONSTRAINT Reso_LottoR FOREIGN KEY (ID_Lotto) REFERENCES Lotto_resi (ID_Lotto) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Cambio_Codice;
CREATE TABLE Cambio_Codice (
    Cod_Seriale_NEW INT,
    Cod_Seriale_OLD INT,
    Timestamp_Ricodifica TIMESTAMP NOT NULL,
    CHECK (Timestamp_Ricodifica > '2000-01-01'),
    PRIMARY KEY (Cod_Seriale_NEW , Cod_Seriale_OLD),
    CONSTRAINT prod_vecchio FOREIGN KEY (Cod_seriale_OLD) REFERENCES Prodotto (COD_Seriale) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT prod_ric FOREIGN KEY (Cod_seriale_NEW) REFERENCES Prodotto (COD_Seriale) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;


drop trigger if exists check_ricodificazione;
delimiter $$
CREATE TRIGGER check_ricodificazione before insert on cambio_codice for each row
begin
if(	new.Cod_Seriale_NEW = new.Cod_Seriale_OLD) then
signal sqlstate '45000' set message_text = 'ERRORE Il codice nuovo è uguale a quello vecchio!'; end if;
end $$
delimiter ;

drop table if exists Radice_Tree_Test;
CREATE TABLE Radice_Tree_Test (
    cod_nodo INT PRIMARY KEY,
    Marca VARCHAR(255),
    Modello VARCHAR(255),
    CONSTRAINT rad_oggetto FOREIGN KEY (Marca , Modello) REFERENCES Oggetto (Marca , Modello) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Nodo_Tree_Test;
CREATE TABLE Nodo_Tree_Test (
    cod_nodo INT PRIMARY KEY AUTO_INCREMENT,
    cod_radice INT,
    cod_padre INT,
    Descrizione TEXT NOT NULL,
    COD_Componente INT,
    peso INT UNSIGNED,
    Quantita_Componente INT UNSIGNED NOT NULL,
    CONSTRAINT comp_nodo FOREIGN KEY (COD_Componente) REFERENCES Componente (COD_Componente) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Rad_nodo FOREIGN KEY (COD_Radice) REFERENCES Radice_Tree_test (COD_Nodo) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop procedure if exists Inserimento_Radice_Tree_Test;
delimiter $$
create procedure Inserimento_Radice_Tree_Test (IN _Marca VARCHAR(255) , IN _Mod VARCHAR(255) , IN Descr TEXT , IN Comp INT , in quant int)
begin

	
	declare errore int default 1; 
    
    declare Rad_Cod int;
	declare rad_Cod_Ok tinyint default 0;
    
    select 1 into errore -- se la radice associata a quell oggetto esiste già da errore = null
    from radice_tree_test
    where Marca = _Marca and Modello = _Mod;
    
    if(errore is null) then signal sqlstate '45000' set message_text = 'ERRORE , L Oggetto specificato possiede gia una radice!'; end if;
    
	genera_codice : 
       while ( true ) DO
		set Rad_Cod = FLOOR(RAND() * 99999);
        
        select COUNT(*) into rad_cod_ok
        from (
        select COD_Nodo from radice_tree_test        
        UNION		
        select COD_Nodo from Nodo_tree_test
        ) as D
        where Cod_Nodo = Rad_Cod;
        
        if(rad_cod_ok = 0) then leave genera_codice; end if;
    end while genera_codice;
    
    
    insert into Radice_tree_test values (Rad_Cod , _Marca , _Mod);
    insert into Nodo_Tree_test values(Rad_Cod , NULL ,NULL , Descr , Comp ,0 , quant); -- inserisco il nodo radice anche nell albero vero e proprio
    
end $$
delimiter ;

drop procedure if exists Inserimento_Nodo_Tree_Test;
delimiter $$
create procedure Inserimento_Nodo_Tree_Test (IN _Marca VARCHAR(255) , IN _Mod VARCHAR(255) , IN Fath INT, IN Descr TEXT , IN _Comp INT , IN Quant int)
begin

	
	declare errore tinyint default 1; 
    declare fine int ;
    declare rad int;
    declare Liv int default 0;
  
    
    select 1 into errore -- se la radice associata a quell oggetto esiste già da errore = null
    from radice_tree_test
    where Marca = _Marca and Modello = _Mod;
    if(errore is null) then signal sqlstate '45000' set message_text = 'ERRORE ,Non esiste una radice per l oggetto specificato!'; end if;
    
    select cod_nodo into rad
    from radice_tree_test
    where Marca = _Marca and Modello = _Mod;
    
    drop temporary table if exists tree;
    create temporary table Tree (
		cod_nodo int primary key auto_increment,
		cod_padre int ,
		peso int ,
        Livello INT
    
    );
    
    drop temporary table if exists Temp_tree; -- tabella ausiliaria , la uso come buffer durante la generazione dell albero
    create temporary table Temp_Tree like tree;
    
    
    
    insert into tree 
	select COD_Nodo , NULL  as cod_Padre , 0 as Peso, Liv as Livello
    from Radice_Tree_test
	where Modello = _Mod and Marca = _Marca;
    
    
    
   genera_Albero : 
       WHILE (true) DO
       
      
		select count(*) into fine
        from Nodo_tree_test 
        where COD_Padre IN (select cod_Nodo from tree where livello = liv);
        
        if(fine = 0) then leave genera_albero; end if;
        
        insert into Temp_tree
        select cod_nodo , cod_padre , 0 , Liv + 1
        from Nodo_tree_Test nt
        where cod_padre IN (select cod_Nodo from tree where livello = liv );
        
        insert into tree select * from temp_tree; 
        truncate temp_tree;
        
        set liv = liv + 1;
        
        
        
    END WHILE genera_albero;
    
    select 1 into errore -- riciclo la variabile errore
    from tree 
    where COD_Nodo = Fath;
    
    if(errore IS NULL) then signal sqlstate '45000' set message_text = 'ERRORE ,Non esiste il nodo padre specificato nell albero!'; 
    else
    insert into Nodo_tree_test values (null , rad ,fath , descr , _comp , 0 , quant);
    end if;
    
end $$
delimiter ;

drop procedure if exists Bilancia_Pesi;
delimiter $$
create procedure Bilancia_Pesi (IN Ma VARCHAR(255) , IN Mo VARCHAR(255))
begin
	declare errore tinyint default 1; 
    declare maxliv int default 0;
    
   declare rad int;
  
  
    
    select 1 into errore
    from radice_tree_test
    where cod_nodo = rad;
    if(errore is null) then signal sqlstate '45000' set message_text = 'ERRORE , Non esiste la radice!'; end if;
   
   select cod_nodo into Rad
    from radice_tree_test
    where Marca = Ma and Modello = Mo;
    
    call TestTree (Ma , Mo);
    
    select MAX(Livello) into MaxLiv
    from tree;
    
	drop temporary table if exists BufferPesi;
    create temporary table BufferPesi (
		cod_nodo int primary key auto_increment,
		peso int 
    );
    
    drop temporary table if exists Buffer2 ;
     create temporary table Buffer2 like bufferpesi;
    
    insert into BufferPesi
    select COD_Nodo , 1 from tree;

    
     genera_pesi: 
       WHILE (true) DO
       
       
     insert into Buffer2
       with t1 as(
      select tree.COD_Padre , tree.COD_Nodo , if(bp.Peso is null , 0 , bp.peso) as P
      from tree left outer join bufferpesi bp on bp.cod_nodo = tree.cod_nodo
      where livello = maxliv
      )
      
      select COD_Padre , SUM(t1.P) + 1 as Peso
      from t1 
      group by COD_Padre;
       
       
       replace into bufferpesi select * from buffer2;
       truncate buffer2;
       
	set maxliv = maxliv -1;
    if(maxliv = 0) then leave  genera_pesi; end if;
      
        
    END WHILE genera_pesi;
	
    
    update Nodo_Tree_Test nt  set peso = (select bp.peso from BufferPesi bp where bp.cod_nodo = nt.cod_nodo);
	
    drop temporary table Buffer2;
	drop temporary table BufferPesi;
end $$
delimiter ;

drop procedure if exists TestTree;
delimiter $$
create procedure TestTree (IN _Marca VARCHAR(255) , IN _Mod VARCHAR(255))
begin

	declare errore tinyint default 1; 
    declare fine int ;
    declare rad int;
    declare Liv int default 0;
  
    
    select 1 into errore -- se la radice associata a quell oggetto esiste già da errore = null
    from radice_tree_test
    where Marca = _Marca and Modello = _Mod;
    if(errore is null) then signal sqlstate '45000' set message_text = 'ERRORE ,Non esiste una radice per l oggetto specificato!'; end if;
    
    select cod_nodo into rad -- prendo la radice dell oggetto
    from radice_tree_test
    where Marca = _Marca and Modello = _Mod;
    
    drop temporary table if exists tree;
    create temporary table Tree (
		cod_nodo int primary key auto_increment,
		cod_padre int ,
		peso int ,
        Livello INT , 
        esito tinyint 
    );
    
    drop temporary table if exists Temp_tree; -- tabella ausiliaria , la uso come buffer durante la generazione dell albero
    create temporary table Temp_Tree like tree;
    
    insert into tree -- inserisco la radice per prima
	select rtt.COD_Nodo , NULL  as cod_Padre ,ntt.peso as Peso, Liv as Livello , NULL
    from Radice_Tree_test rtt
    inner join Nodo_Tree_Test ntt on rtt.cod_Nodo = ntt.COD_Nodo
	where Modello = _Mod and Marca = _Marca;
    
    
    
   genera_Albero : 
       WHILE (true) DO
		select count(*) into fine
        from Nodo_tree_test 
        where COD_Padre IN (select cod_Nodo from tree where livello = liv);
        
        if(fine = 0) then leave genera_albero; end if;
        
        insert into Temp_tree
        select cod_nodo , cod_padre , peso , Liv + 1 , NULL
        from Nodo_tree_Test nt
        where cod_padre IN (select cod_Nodo from tree where livello = liv );
        
        insert into tree select * from temp_tree; 
        truncate temp_tree;
        
        set liv = liv + 1;
        
    END WHILE genera_albero;
	
    -- select * from tree;
    drop temporary table Temp_tree;
end $$
delimiter ;

drop procedure if exists Inizia_Ricondizionamento_Lotto_Reso;
delimiter $$
create procedure Inizia_Ricondizionamento_Lotto_Reso(IN _Lotto INT)
begin
	declare errore tinyint default null; 
	select 1 into errore 
    from lotto_resi
    where ID_Lotto = _lotto;
    if(errore is null) then signal sqlstate '45000' set message_text = 'ERRORE ,Lotto Inesistente!'; end if;
    
set errore = null;
	select 1 into errore 
    from lotto_resi
    where ID_Lotto = _lotto and Data_Completamento is not null;
    if(errore is null) then signal sqlstate '45000' set message_text = 'ERRORE ,Lotto Non ancora completato!'; end if;
    
    
    update lotto_resi set data_Ricondizionamento = current_date where ID_lotto = _lotto;

end $$
delimiter ;

drop procedure if exists Inizio_Ricondizionamento_Reso;
delimiter $$
create procedure Inizio_Ricondizionamento_Reso(IN _Reso INT , IN _Mag INT ,  IN _S INT , IN _R INT , IN _P INT , IN X_Perc double)
begin
	declare errore tinyint default null; 
    
    declare _marc varchar(255);
	declare _mod varchar(255);
    
    CALL Controlla_Disponibilita_Spazio_In_Mag (_Mag , _S , _R , _P , errore);
	if(errore = 1) then signal sqlstate '45000' set message_text ='ERRORE , Locazione nel magazzino occupata!'; end if;
    
    
    if(ABS(X_Perc) >= 1) then signal sqlstate '45000' set message_text = 'Percentuale non valida!'; end if;
    set X_Perc = ABS(X_Perc);
    set errore = null;
    
	select 1 into errore 
    from Reso
    where cod_seriale = _reso;
    if(errore is null) then signal sqlstate '45000' set message_text = 'ERRORE ,Reso Inesistente!'; end if;
    
    set errore = null;
    
    select 1 into errore 
    from Reso r inner join lotto_resi lr using(id_lotto)
    where cod_seriale = _reso and lr.data_Ricondizionamento is not null;
    if(errore is null) then signal sqlstate '45000' set message_text = 'ERRORE ,Lotto Inesistente o non ancora mandato in ricondizionamento!'; end if;
    
    select Marca , Modello into _Marc , _Mod -- prendo la marca e il modello del reso
    from reso r
    inner join lotto_resi lr using(ID_lotto)
    where cod_seriale = _reso;
    
    call TestTree(_Marc , _mod); -- genero il test tree associato
    
    drop temporary table if exists Test_Tree_Tab; -- creo una tabella di supporto dove verrano caricati e scaricati i nodi
    create temporary table Test_Tree_Tab (
        cod_nodo int primary key ,
		cod_padre int ,
		peso int ,
        Livello INT , 
        esito tinyint  ,
		Figli_Falliti int default 0
    ); -- la tabella in cui il tecnico lavorerà
   
	insert into Test_Tree_Tab select tree.* , 0  from tree where livello = 0;  -- carico la radice (ossia il primo test) nella tabella di supporto
   
    drop temporary table if exists Nodi_Fallito; -- creo una tabella di supporto per i nodi che avranno fallito il test
    create temporary table Nodi_Fallito(
    cod_nodo int primary key ,
    cod_padre int 
    
    );
    
    set @Liv = 0; -- il livello in cui sto lavorando
    set @current_Reso = _reso; -- il reso su cui sto effettuando il test
    set @X = X_Perc; -- il valore per il controllo X% => 0,5 = 50%
    
    set @Mag_Ric = _Mag;
    set @S_r = _s;
    set @R_r = _r;
    set @P_r = _p;
   
 
 
end $$
delimiter ;


drop procedure if exists Esito_Nodo;
delimiter $$
create procedure Esito_Nodo(in nod int , in esit tinyint)
begin
	declare err tinyint default null;
    declare num_liv int;
	declare complete_liv int;
    
	if(esit not in (1 , 0)) then signal sqlstate'45000' set message_text = 'Parametro di esito non valido!'; end if;
    
    select 1 into err from Test_Tree_Tab ttt where cod_nodo = nod and livello = @liv;
    if(err is null) then signal sqlstate '45000' set message_text = 'Il Nodo è inesistente!'; end if;
    
     select 1 into err from Test_Tree_Tab ttt where cod_nodo = nod and ttt.esito is null and livello = @liv;
    if(err is null) then signal sqlstate '45000' set message_text = 'Il Nodo esiste ma è già stato valutato!'; end if;
     
    if(esit = 1) then

		call test_successo(nod);
    
   else
		call test_fallito(nod);
    
    end if;
   
    select COUNT(*) into num_liv -- conto i nodi totali del livello corrente
    from Test_Tree_Tab ttt
    where livello = @liv;
    
  
	select COUNT(*) into complete_liv -- conto i nodi valutati del livello corrente
    from Test_Tree_Tab ttt
    where livello = @liv and ttt.esito is not null;
    

    if(num_liv = complete_liv) then
    insert into Test_Tree_Tab
    select tree.* , 0 from tree where cod_padre IN (select cod_nodo from nodi_fallito);
    TRUNCATE nodi_fallito;
	set  @liv = @liv + 1;
    
    end if;
    
 
    
    
    
end $$
delimiter ;

drop procedure if exists Controllo_X;
delimiter $$
create procedure Controllo_X(IN fath INT)
begin
	

    declare Num_Figli int;
    declare Num_Figli_F int;
   
   if(fath is not null) then

   select COUNT(*) into Num_Figli -- conto i figli del nodo padre
   from Test_Tree_Tab where COD_Padre = fath; 
   
   select Figli_falliti into Num_Figli_F
   from Test_Tree_Tab where COD_Nodo = fath; 
   
   if(Num_Figli * @X <= Num_Figli_F) then
		call Test_Fallito_X(fath , Num_Figli);
    end if;
    
    end if;
  
 
	
    
   
end $$
delimiter ;

drop procedure if exists Test_Fallito;
delimiter $$
create procedure Test_Fallito(IN nod INT)
begin
	declare fath int;
    
    select COD_Padre into fath from tree where cod_nodo = nod;
    
    update Test_Tree_Tab set esito = 0 where cod_nodo = nod;
    
    
    if(fath is null) then
    
		insert into Nodi_Fallito values (nod , NULL); -- se il nodo è la radice non faccio il controllo dell'X%
    
    else
		insert into Nodi_Fallito values (nod , fath);
		
		update Test_Tree_Tab set Figli_Falliti = Figli_Falliti + 1 where cod_nodo = fath;
    
		call Controllo_X(fath);
    
    end if;

end $$
delimiter ;

drop procedure if exists Test_Fallito_X;
delimiter $$
create procedure Test_Fallito_X(IN nod INT , in cont int)
begin
	delete from Nodi_Fallito where cod_padre = nod;
    delete from Test_Tree_Tab where cod_padre = nod;
    
    update Test_Tree_Tab set esito = 0 , Figli_Falliti = cont where cod_nodo = nod;
    
    call Controllo_X ((select COD_Padre from tree where cod_nodo = nod));

end $$
delimiter ;

drop procedure if exists Test_Successo;
delimiter $$
create procedure Test_Successo(IN nod INT)
begin

    update Test_Tree_Tab set esito = 1 where COD_Nodo = nod;
    
end $$
delimiter ;

drop procedure if exists Concludi_Test_tree_reso;
delimiter $$
create procedure concludi_Test_tree_reso(IN _reso INT )
begin
	
	declare Life int;
    declare Peso_B int;
    declare quality int;
    declare Points int;
  
  
  
  truncate tree;
  insert into tree select COD_Nodo , COD_Padre , Peso , Livello , esito
  from Test_Tree_Tab;
    


SELECT peso INTO Life FROM tree WHERE cod_padre IS NULL;-- prendo il peso della radice
    
SELECT SUM(peso) INTO Peso_B FROM tree WHERE Esito = 1; -- calcolo il peso buono
if(peso_b is null) then set peso_b = 0; end if;
    
     Set points = (Peso_B* 100)/life;
     
     If     (points >= 80)  then set quality = 1; 
	 elseIf (points between 60 and 79 )  then set quality = 2; 
	 elseIf (points between 40 and 59 )  then set quality = 3; 
	 elseIf (points between 20 and 39 )  then set quality = 4; 
	 elseIf (points <= 19)  then set quality = 5; 
	 end if;
     
    update reso set valutato = quality where cod_seriale = _reso;
    call Ricondizionamento_Reso(@current_Reso , Quality);
end $$
delimiter ;

drop procedure if exists Show_tree;
delimiter $$
create procedure Show_tree(in liv int , in Way tinyint)
begin
-- way => 0 
	if(liv is null) then 
    select * from Test_Tree_tab order by Livello asc;
    elseif(Way < 0 or way is null) then
    select * from Test_Tree_tab where livello <= liv order by Livello asc;
     elseif(Way > 0) then
    select * from Test_Tree_tab where livello >= liv order by Livello asc;
     elseif(Way = 0) then
    select * from Test_Tree_tab where livello = liv order by Livello asc;
    end if;
end $$
delimiter ;

drop procedure if exists Ricondizionamento_Reso;
delimiter $$
create procedure Ricondizionamento_Reso(In _reso INT , IN _Qual INT)
begin

	declare Marc varchar(255);
    declare Model varchar(255);
    declare Lotto_Ric int;
	declare Q_Lotto int;
    declare soglia_r int;
    
    declare New_serial int;
    
    declare N_ord int;
    
    select s.Marca , s.Modello into Marc , Model
    from prodotto p 
	inner join lotto l using(ID_Lotto)
	inner join sequenza s using(ID_Sequenza)
    where p.cod_seriale = _reso;
    
    select ID_Lotto , Quantita_prodotti into  Lotto_Ric , Q_lotto
    from lotto_ricondizionati
    where Marca = Marc AND Modello = Model 
    AND ID_Magazzino = @Mag_Ric AND Qualita = _Qual;
    
	select FLOOR(Soglia_Lotti/4) into Soglia_r
    from tipo_prodotto tp inner join oggetto o on o.Tipo_Prodotto = tp.Nome
    where o.Marca = Marc and o.Modello = Model;
    
    if(Lotto_Ric is not null AND Q_Lotto < Soglia_r) then
    
	select MAX(COD_Seriale) + 1 Into New_serial 
	from  prodotto;
    
	insert into prodotto values (New_Serial , Lotto_Ric , NULL , NULL );
    update lotto_ricondizionati set  Quantita_Prodotti = Quantita_Prodotti +1 where ID_Lotto = Lotto_Ric;
   
   else
    
    
    select MAX(ID_Lotto) + 1 Into Lotto_ric 
	from  (select ID_Lotto from Lotto UNION select ID_Lotto from Lotto_Ricondizionati) as D ;
    
    insert into Lotto_Ricondizionati values (Lotto_Ric ,  Marc , Model  ,@Mag_Ric , @S_r , @R_r ,@P_r , 1 , _qual);
  
	select MAX(COD_Seriale) + 1 Into New_serial 
	from  prodotto;
    
	insert into prodotto values (New_Serial , Lotto_Ric , NULL ,0);
    
    end if;
    
    insert into cambio_codice values (new_serial , _reso , current_timestamp);
    
    select MAX(COD_ordine) + 1 into N_ord
    from Ordine_Pezzi_Ricondizionamento;
    
    if(N_ord is null) then set N_ord = 1; end if;
    
    
    insert into Ordine_Pezzi_Ricondizionamento values (N_ord, new_serial , current_timestamp ); -- ,  current_timestamp + interval 2 day , null);
    
    insert into Ordine_Pezzi_Ricondizionamento_Componente
	select N_ord , nt.cod_componente , nt.Quantita_Componente
	from tree t inner join nodo_tree_test nt using(COD_Nodo)
	where t.esito = 0;
    
    

    SET FOREIGN_KEY_CHECKS=0;
	drop temporary table if exists Nodi_Successo;
	drop temporary table if exists Test_Tree_tab;
    SET FOREIGN_KEY_CHECKS=1;
  
end $$
delimiter ;

drop trigger if exists Cancellazione_lotto_ric_trigger;
delimiter $$
create trigger Cancellazione_lotto_ric_trigger after delete on lotto_ricondizionati for each row
begin

delete from prodotto where ID_Lotto = OLD.ID_lotto;

end $$
delimiter ;

drop trigger if exists Aggiornamento_lotto_ric_trigger;
delimiter $$
create trigger Aggiornamento_lotto_ric_trigger after update  on lotto_ricondizionati for each row
begin

update prodotto set prodotto.id_lotto = new.id_lotto where prodotto.ID_Lotto = OLD.ID_lotto;

end $$
delimiter ;

drop table if exists Ordine_Pezzi_Ricondizionamento;
CREATE TABLE Ordine_Pezzi_Ricondizionamento (
    COD_Ordine INT PRIMARY KEY AUTO_INCREMENT,
    cod_seriale INT,
    Timestamp_ordine TIMESTAMP NOT NULL,
    check(timestamp_ordine > '2000-01-01') ,
    CONSTRAINT Ordine_pezzi_ric_reso FOREIGN KEY (COD_Seriale) REFERENCES Prodotto (COD_Seriale)  ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Ordine_Pezzi_Ricondizionamento_Componente;
CREATE TABLE Ordine_Pezzi_Ricondizionamento_Componente (
    COD_Ordine INT,
    cod_componente INT,
    Quantita INT UNSIGNED NOT NULL,
    PRIMARY KEY (cod_ordine , cod_componente),
    CONSTRAINT Ordine_pezzi_ric_ FOREIGN KEY (COD_Ordine) REFERENCES Ordine_Pezzi_Ricondizionamento (COD_Ordine) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Ordine_pezzi_ric_comp FOREIGN KEY (COD_Componente)  REFERENCES Componente (COD_Componente) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Classe_Guasto;
CREATE TABLE Classe_Guasto (
    Nome VARCHAR(50) PRIMARY KEY
)  ENGINE=INNODB;

drop table if exists Guasto;
CREATE TABLE Guasto (
    COD_Guasto INT PRIMARY KEY AUTO_INCREMENT,
    Nome VARCHAR(255) NOT NULL,
    Classe_Guasto VARCHAR(255),
    Descrizione_Guasto TEXT NOT NULL,
    CONSTRAINT guasto_classe FOREIGN KEY (classe_guasto)  REFERENCES classe_guasto (nome)  ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Sintomo;
CREATE TABLE Sintomo (
    COD_Sintomo INT PRIMARY KEY AUTO_INCREMENT,
    Descrizione_Sintomo TEXT NOT NULL
)  ENGINE=INNODB;

drop table if exists Rimedio;
CREATE TABLE Rimedio (
    COD_Rimedio INT PRIMARY KEY AUTO_INCREMENT,
    Descrizione_Rimedio TEXT NOT NULL
)  ENGINE=INNODB;

drop table if exists Guasto_Sintomo;
CREATE TABLE Guasto_Sintomo (
    cod_guasto INT,
    cod_sintomo INT,
    PRIMARY KEY (cod_guasto , cod_sintomo),
    CONSTRAINT Guasto_sintomo_guasto FOREIGN KEY (COD_Guasto)REFERENCES Guasto (COD_Guasto)  ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Guasto_sintomo_sintomo FOREIGN KEY (COD_sintomo) REFERENCES Sintomo (COD_Sintomo) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Oggetto_Guasto_Rimedio;
CREATE TABLE Oggetto_Guasto_Rimedio (
    Marca VARCHAR(255),
    Modello VARCHAR(255),
    COD_Guasto INT,
    COD_Rimedio INT,
    Contatore_Successi INT UNSIGNED NOT NULL,
    COD_Errore INT UNSIGNED NOT NULL,
    PRIMARY KEY (Marca , Modello , COD_Guasto , COD_Rimedio),
    CONSTRAINT Guasto_Oggetto_Guasto_Rimedio FOREIGN KEY (COD_Guasto) REFERENCES Guasto (COD_Guasto) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Rimedio_Oggetto_Guasto_Rimedio FOREIGN KEY (COD_Rimedio) REFERENCES Rimedio (COD_Rimedio) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Oggetto_Guasto_Rimedio_oggetto FOREIGN KEY (Marca , Modello) REFERENCES Oggetto (Marca , Modello) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Prodotto_Guasto;
CREATE TABLE Prodotto_Guasto (
    COD_Seriale INT,
    COD_Guasto INT,
    Data_Rivenimento_Guasto DATE,
    Rimediato TINYINT NOT NULL,
	check( Data_Rivenimento_Guasto > '2000-01-01') ,
    PRIMARY KEY (COD_Seriale , COD_Guasto , Data_Rivenimento_Guasto),
    CONSTRAINT Prodotto_Guasto_Guasto FOREIGN KEY (COD_Guasto) REFERENCES Guasto (COD_Guasto) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Prodotto_Guasto_Prodotto FOREIGN KEY (COD_Seriale) REFERENCES prodotto (COD_Seriale) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop procedure if exists Prodotto_Guastato;
delimiter $$
create procedure Prodotto_Guastato (IN _ser int , in _Guast int)
begin

declare errore int default null;
declare _mar varchar(255);
declare _mod varchar(255);

select 1 into errore
from prodotto where cod_seriale = _ser and cod_ordine is not null and prenotato = 0;
if(errore is null) then signal sqlstate '45000' set message_text = 'Prodotto Inesistente!'; end if;

set errore = null;
select 1 into errore
from reso where cod_seriale = _ser;
if(errore is not null) then signal sqlstate '45000' set message_text = 'Il prodotto specificato esiste ma è un Reso!'; end if;

set errore = null;
select 1 into errore
from Guasto where cod_guasto= _guast;
if(errore is null) then signal sqlstate '45000' set message_text = 'Guasto Inesistente!'; end if;

insert into Prodotto_Guasto values (_ser , _guast , current_date , 0);


end $$
delimiter ;

drop procedure if exists Guasto_Rimediato;
delimiter $$
create procedure  Guasto_Rimediato(IN _ser int , in _Guast int , in data_guast date , in rimed int)
begin

declare errore int;
declare _mar varchar(255);
declare _mod varchar(255);

declare cod int;

select 1 into errore
from prodotto where cod_seriale = _ser and cod_ordine is not null and prenotato = 0;
if(errore is null) then signal sqlstate '45000' set message_text = 'Prodotto Inesistente!'; end if;

select 1 into errore
from Guasto where cod_guasto= _guast;
if(errore is null) then signal sqlstate '45000' set message_text = 'Guasto Inesistente!'; end if;

select 1 into errore
from rimedio where cod_rimedio= rimed;
if(errore is null) then signal sqlstate '45000' set message_text = 'Rimedio Inesistente!'; end if;


if(data_guast < '2000-01-01' or data_guast > current_date) then signal sqlstate '45000' set message_text = 'Data del Guasto non valida!'; end if;

set errore = null;
select 1 into errore
from Prodotto_Guasto 
where cod_guasto = _guast and cod_seriale = _ser and Data_Rivenimento_Guasto = Data_guast and rimediato = 0;
if(errore is null) then signal sqlstate '45000' set message_text = 'Caso di guasto Inesistente o già riparato!'; end if;


select s.Marca , s.Modello into _Mar , _mod
from lotto l 
inner join prodotto p using(id_lotto)
inner join sequenza s using(ID_Sequenza)
where COD_Seriale = _ser;

set errore = null;
select 1 into errore 
from Oggetto_Guasto_Rimedio
where cod_guasto = _guast and cod_rimedio = rimed and Marca = _Mar and Modello = _mod;

if(errore is null) then  -- se il record non esiste
	select MAX(COD_Errore) + 1 into cod  from Oggetto_Guasto_Rimedio;
	if(cod is null) then set cod = 1; end if;    
    insert into Oggetto_Guasto_Rimedio values (_Mar , _Mod , _Guast , Rimed , 1 ,  cod);
else -- se il record esiste gia
	update Oggetto_Guasto_Rimedio
    set Contatore_Successi = Contatore_Successi + 1
    where cod_guasto = _guast and cod_rimedio = rimed and Marca = _Mar and Modello = _mod; 
end if;

update Prodotto_Guasto set rimediato = 1 where cod_guasto = _guast and cod_seriale = _ser and Data_Rivenimento_Guasto = Data_guast;

end $$
delimiter ;

drop procedure if exists Report_Oggetto_Guasto_Rimedio_Marca_Mod;
delimiter $$
create procedure  Report_Oggetto_Guasto_Rimedio_Marca_Mod(IN _Marc VARCHAR(255) , IN _Mod VARCHAR(255))
begin

declare errore int default null;

select 1 into errore
from oggetto where marca = _marc and modello = _mod;
if(errore is null) then signal sqlstate '45000' set message_text = 'Oggetto Inesistente!'; end if;

SELECT og.Marca , og.Modello ,g.nome as Guasto, r.Descrizione_Rimedio as Rimedio, og.Contatore_Successi 
from oggetto_guasto_rimedio og
inner join guasto g using(cod_guasto)
inner join rimedio r using(COD_Rimedio)
where og.marca = _Marc and og.Modello = _mod;

end $$
delimiter ;

drop table if exists Domande_Assistenza;
CREATE TABLE Domande_Assistenza (
    Marca VARCHAR(255),
    Modello VARCHAR(255),
    Ordine_Domanda INT UNSIGNED NOT NULL,
    Testo_Domanda TEXT NOT NULL,
    COD_Rimedio INT,
    PRIMARY KEY (Marca , Modello , Ordine_domanda),
    CONSTRAINT Rimedio_Ass_Virt FOREIGN KEY (COD_Rimedio) REFERENCES Rimedio (COD_Rimedio) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Domande_Ass_Virt_oggetto FOREIGN KEY (Marca , Modello) REFERENCES Oggetto (Marca , Modello) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop procedure if exists Assistenza_Virtuale;
delimiter $$
create procedure Assistenza_Virtuale (IN _Marc VARCHAR(255) , IN _Mod VARCHAR(255))
begin

with t1 as(
select da.Ordine_Domanda as Numero ,
    da.testo_domanda as Domanda ,
    'Se No -> ' as Nop ,
    r.descrizione_rimedio as Rimedio 
    
    from Domande_Assistenza da 
    inner join rimedio r on r.cod_rimedio = da.cod_rimedio
    where da.marca= 'HP' and da.modello = 'MegaPC'
    order by da.Ordine_Domanda asc
    )
    
    select
    p.Numero , p.Domanda ,
    p.Nop as '' , p.Rimedio , 
    IF(p.Numero < (select MAX(t.Numero) from t1 t ) ,    
    CONCAT(' Se Si -> Vai alla domanda ', Numero +1) ,
	' Se Si -> Contatta l Assistenza Fisica' )as '' 
    from t1 p;
	
end $$
delimiter ;

drop table if exists Centro_Assistenza;
CREATE TABLE Centro_Assistenza (
    Provincia varchar(255) PRIMARY KEY,
    Nome_Via VARCHAR(50) NOT NULL,
    Numero_Civico VARCHAR(20) NOT NULL,
	UNIQUE (Nome_via , Numero_Civico , Provincia),
    CONSTRAINT centro_assProvi FOREIGN KEY (Provincia) REFERENCES Provincia (nome) ON UPDATE CASCADE ON DELETE CASCADE
  
   
)  ENGINE=INNODB;

drop table if exists Scorte_CentroAssistenza;
CREATE TABLE Scorte_CentroAssistenza (
    prov_Centro_Assistenza varchar(255),
    COD_Componente INT,
    Quantita INT UNSIGNED NOT NULL,
    PRIMARY KEY (prov_Centro_Assistenza , cod_componente),
    CONSTRAINT CentroAss_scorte FOREIGN KEY (prov_centro_Assistenza) REFERENCES Centro_Assistenza (Provincia) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT comp_CentroAss FOREIGN KEY (cod_componente) REFERENCES componente (cod_componente) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE = INNODB;

DROP TABLE IF EXISTS Ordine_Interno_CentroAssistenza;
CREATE TABLE Ordine_Interno_CentroAssistenza (
    Prov_Centro_Assistenza VARCHAR(255),
    id_magazzino INT,
    cod_componente INT,
    timestamp_ordine TIMESTAMP,
    quantita INT UNSIGNED NOT NULL,
    PRIMARY KEY (prov_Centro_Assistenza , id_magazzino , cod_componente),
    CHECK (timestamp_ordine > '2000-01-01'),
    CONSTRAINT CentroAss_scorte_ord FOREIGN KEY (prov_Centro_Assistenza) REFERENCES Centro_Assistenza (Provincia) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT mag_comp_CentroAss_ord FOREIGN KEY (id_magazzino) REFERENCES magazzino_componente (id_magazzino)ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT comp_CentroAss_ord FOREIGN KEY (cod_componente) REFERENCES componente (cod_componente) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop procedure if exists ordine_interno_Centro_Assistenza_Magazzino;
delimiter $$
create procedure ordine_interno_Centro_Assistenza_Magazzino (in Cass varchar(255) , in Mag INT , In comp INT , in Quant INT)
begin

	declare errore int;
    
	if(quant < 0 or quant is null) then set quant = 0;  end if;
    
	select 1 into errore from centro_assistenza where  Provincia = cass;
    if(errore is null) then signal sqlstate '45000' set message_TEXT = 'Centro Assistenza Inesistente!'; end if;
    
    select 1 into errore from Magazzino_Componente where id_magazzino =  mag;
    if(errore is null) then signal sqlstate '45000' set message_TEXT = 'Magazzino Inesistente!';end if;
	
    select 1 into errore from Componente where cod_componente = comp;
    if(errore is null) then signal sqlstate '45000' set message_TEXT = 'Componente Inesistente!';end if;

	set errore = null; -- riciclo errore
    
    select 1 into errore from Scorte_Magazzino_Componente where id_magazzino = mag and cod_componente = comp and quantita >= quant; -- controllo se il magazzino ha quella scorta e sopratutto se ha abbastanza componenti per soddisfare la richiesta
    if(errore = 1) then 
     update Scorte_Magazzino_Componente set Quantita = quantita - quant where id_Magazzino = Mag and cod_componente = comp; -- se esiste la scorta la aggiorno
    else 
    signal sqlstate '45000' set message_TEXT = 'Scorte del magazzino insufficenti a soddisfare la richiesta!'; 
    end if;
    
    
    select 1 into errore from Scorte_CentroAssistenza where ID_Centro_Assistenza = cass and cod_componente = comp;
    if(errore = 1 ) then 
    update Scorte_CentroAssistenza set Quantita = quantita + quant where ID_Centro_Assistenza = Cass and cod_componente = comp; -- se esiste la scorta la aggiorno
    else 
    insert into Scorte_CentroAssistenza values (Cass , comp , quant); -- se non esiste la scorta la creo
    end if;
    
   
		
end $$
delimiter ;

drop table if exists Tecnico;
CREATE TABLE Tecnico (
    COD_Fiscale VARCHAR(255) PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Cognome VARCHAR(255) NOT NULL,
    sesso char not null ,
    Nome_Via VARCHAR(50) NOT NULL,
    Numero_Civico VARCHAR(20) NOT NULL,
    Provincia varchar(255) not null ,
    DataNascita DATE NOT NULL,
    DataAssunzione DATE NOT NULL,
    Paga_Oraria INT UNSIGNED NOT NULL,
    Specializzazione VARCHAR(255),
    Prov_Centro_Assistenza varchar(255) NOT NULL,
    a_domicilio TINYINT NOT NULL,
	Telefono INT(6) NOT NULL UNIQUE,
   
    CONSTRAINT Spec_tec FOREIGN KEY (Specializzazione) REFERENCES Tipo_prodotto (nome) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Lavoro_tec FOREIGN KEY (Prov_Centro_Assistenza) REFERENCES Centro_assistenza (Provincia) ON DELETE CASCADE ON UPDATE CASCADE,
    constraint prov_tec foreign key (Provincia) references Provincia (nome) on delete cascade on update cascade  ,
    UNIQUE (Nome_via , Numero_Civico ,Provincia),
    CHECK (DataAssunzione > '2000-01-01'),
     CHECK (telefono BETWEEN 111111 AND 999999) ,
    check (sesso in ('M' , 'F')) ,
    CHECK (DataAssunzione > DataNascita)
)  ENGINE=INNODB;

drop table if exists Veicolo;
CREATE TABLE Veicolo (
    targa INT PRIMARY KEY AUTO_INCREMENT,
    Marca VARCHAR(255),
    Modello VARCHAR(255),
    Capacita_Carico INT UNSIGNED NOT NULL,
    DataAcquisto DATE NOT NULL,
    CHECK (dataacquisto > '2000-01-01')
)  ENGINE=INNODB;

drop table if exists Squadra;
CREATE TABLE Squadra (
    COD_Squadra INT PRIMARY KEY AUTO_INCREMENT,
    TargaVeicolo INT,
    Categoria INT UNSIGNED NOT NULL,
    Prov_Centro_Assistenza varchar(255),
    CHECK (Categoria IN (1 , 2, 3)),
    CONSTRAINT Lavoro_Sq FOREIGN KEY (Prov_Centro_Assistenza)  REFERENCES Centro_assistenza (Provincia) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Veicolo_Sq FOREIGN KEY (TargaVeicolo) REFERENCES Veicolo (Targa) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Trasportatore;
CREATE TABLE trasportatore (
    COD_Fiscale VARCHAR(255) PRIMARY KEY,
    Nome VARCHAR(255) NOT NULL,
    Cognome VARCHAR(255) NOT NULL,
	sesso char not null ,
    Nome_Via VARCHAR(50) NOT NULL,
    Numero_Civico VARCHAR(20) NOT NULL,
	Provincia varchar(255) not null,
  
    COD_Squadra INT,
    DataNascita DATE NOT NULL,
    DataAssunzione DATE NOT NULL,
    Paga_Oraria INT UNSIGNED NOT NULL,
    Telefono INT(6) NOT NULL UNIQUE,
    UNIQUE (Nome_via , Numero_Civico , Provincia),
    CHECK (DataAssunzione > '2000-01-01'),
    CHECK (DataAssunzione > DataNascita),
	CHECK (telefono BETWEEN 111111 AND 999999) ,
    check (sesso in ('M' , 'F')) ,
	constraint prov_trasp foreign key (Provincia) references Provincia (nome) on delete cascade on update cascade  ,
    CONSTRAINT Tec_sq FOREIGN KEY (COD_Squadra) REFERENCES Squadra (COD_Squadra) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop trigger if exists Controllo_Numero_Trasportatori_Squadra;
 delimiter $$
 create trigger Controllo_Numero_Trasportatori_Squadra before insert on Trasportatore for each row
 begin
	
    declare Cate int;
	declare Num int;
    
    select Categoria into cate
    from squadra
    where COD_Squadra = new.COD_Squadra;
    
    select COUNT(*) into num
    from trasportatore 
    where cod_squadra = new.COD_Squadra;
    
    if(num = 1 and cate = 1) then Signal sqlstate '45000' set message_text = 'La squadra è piena!'; 
    elseif(num = 2 and cate = 2) then Signal sqlstate '45000' set message_text = 'La squadra è piena!'; 
	elseif(num = 3 and cate = 3) then Signal sqlstate '45000' set message_text = 'La squadra è piena!'; 
    end if;
    
    
    
    
 end $$
 delimiter ;

 drop trigger if exists Controllo_Tipo_Veicolo_Squadra;
 delimiter $$
 create trigger Controllo_Tipo_Veicolo_Squadra before insert on Squadra for each row
 begin
	
	declare Num int;
    
    select Capacita_Carico into num
    from veicolo 
    where targa = new.Targaveicolo;
    
    if( num <= 15 and new.categoria <> 1) then Signal sqlstate '45000' set message_text = 'Il veicolo non è idoneo alla squadra!'; 
    elseif( 16 <= num and num <= 50 and new.categoria <> 2) then Signal sqlstate '45000' set message_text = 'Il veicolo non è idoneo alla squadra!'; 
	elseif(num > 50 and new.categoria <> 3) then Signal sqlstate '45000' set message_text = 'Il veicolo non è idoneo alla squadra!'; 
    end if;
    
    
    
    
 end $$
 delimiter ;
	
drop table if exists Richiesta_Intervento;
CREATE TABLE Richiesta_Intervento (
    COD_Ticket INT,
    Intervento TINYINT,
    Data_Desiderata DATE,
    NickName VARCHAR(255),
    CF_Tecnico VARCHAR(255),
    Timestamp_Ticket TIMESTAMP NOT NULL,
    Marca VARCHAR(255),
    Modello VARCHAR(255),
    Nome_Via VARCHAR(50) NOT NULL,
    Numero_Civico VARCHAR(20) NOT NULL,
    Provincia varchar(255) not null ,
    FasciaOraria_Desiderata INT UNSIGNED NOT NULL,
    DurataIntervento INT UNSIGNED ,
    
    PRIMARY KEY (COD_Ticket , Intervento , Data_Desiderata),
    CHECK (FasciaOraria_Desiderata IN (1 , 2)),
    UNIQUE (CF_Tecnico , Data_Desiderata , FasciaOraria_Desiderata),
	constraint prov_rich_int foreign key (Provincia) references Provincia (nome) on delete cascade on update cascade  ,
    CONSTRAINT RichInt_Tec FOREIGN KEY (CF_Tecnico) REFERENCES Tecnico (COD_Fiscale) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT RichInt_Account FOREIGN KEY (NickName) REFERENCES Account (Nickname)  ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT RichInt_oggetto FOREIGN KEY (Marca , Modello) REFERENCES Oggetto (Marca , Modello) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Preventivo;
CREATE TABLE Preventivo (
    COD_Ticket INT PRIMARY KEY,
    COD_Seriale INT,
    Prezzo_Indicativo INT UNSIGNED NOT NULL,
    DataDecisione DATE,
    DecisioneSubito TINYINT,
    Accettato TINYINT,
    Trasporto TINYINT,
	CHECK (DataDecisione > '2000-01-01'),
    CONSTRAINT PrevRichInt FOREIGN KEY (COD_Ticket) REFERENCES Richiesta_Intervento (COD_Ticket) ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT prod_prev FOREIGN KEY (Cod_seriale) REFERENCES Prodotto (COD_Seriale) ON DELETE CASCADE ON UPDATE CASCADE
)  ENGINE=INNODB;

drop table if exists Pagamento_AF;
CREATE TABLE Pagamento_AF (
    COD_Ticket INT PRIMARY KEY,
    Prezzo INT UNSIGNED NOT NULL,
    MetodoPagamento VARCHAR(255) NOT NULL,
    Garanzia INT UNSIGNED,
    CONSTRAINT Pag_RichInt FOREIGN KEY (COD_Ticket) REFERENCES Richiesta_Intervento (COD_Ticket)  ON UPDATE CASCADE ON DELETE CASCADE
)  ENGINE=INNODB;

drop table if exists Prenotazione_Trasporto;
CREATE TABLE Prenotazione_Trasporto (
    COD_Ticket INT PRIMARY KEY,
    Squadra INT,
    DataTrasporto DATE NOT NULL,
    Fascia_Oraria INT UNSIGNED NOT NULL,
    CHECK (Fascia_oraria IN (1 , 2)),
    UNIQUE (Squadra , DataTrasporto , Fascia_Oraria),
     CHECK (DataTrasporto > '2000-01-01') ,
    CONSTRAINT PrenTrasp_Sqad FOREIGN KEY (Squadra) REFERENCES Squadra (COD_Squadra) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT PrenTrasp_RichInt FOREIGN KEY (COD_Ticket) REFERENCES Richiesta_Intervento (COD_Ticket) ON UPDATE CASCADE ON DELETE CASCADE
   
)  ENGINE=INNODB;

drop table if exists Ordine_Pezzi_AF;
CREATE TABLE Ordine_Pezzi_AF (
    COD_Ordine INT PRIMARY KEY AUTO_INCREMENT,
    COD_Guasto INT,
    COD_Ticket INT,
    Timestamp_Ordine TIMESTAMP NOT NULL,
	CHECK ( Timestamp_Ordine > '2000-01-01') ,
    CONSTRAINT Ord_Af_Guast FOREIGN KEY (COD_Guasto) REFERENCES Guasto (COD_Guasto)  ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Ord_Af_RichInt FOREIGN KEY (COD_Ticket) REFERENCES Richiesta_Intervento (COD_Ticket)ON UPDATE CASCADE ON DELETE CASCADE
)  ENGINE=INNODB;

drop table if exists Ordine_Pezzi_AF_Componente;
CREATE TABLE Ordine_Pezzi_AF_Componente (
    COD_Ordine INT,
    COD_Componente INT,
    Quantita INT UNSIGNED NOT NULL,
    PRIMARY KEY (COD_Ordine , COD_Componente),
    CONSTRAINT Ord_Af_Guast_Comp_Ord FOREIGN KEY (COD_Ordine) REFERENCES Ordine_Pezzi_AF (COD_Ordine) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Ord_Af_Guast_Comp_Comp FOREIGN KEY (COD_Componente) REFERENCES Componente (COD_Componente) ON UPDATE CASCADE ON DELETE CASCADE
)  ENGINE=INNODB;

drop table if exists Riparazione;
CREATE TABLE Riparazione (
    COD_Ticket INT,
    COD_Guasto INT,
    Tempo_Riparazione INT UNSIGNED,
    PRIMARY KEY (COD_Ticket , COD_Guasto),
    CONSTRAINT Rip_Guast FOREIGN KEY (COD_Guasto) REFERENCES Guasto (COD_Guasto) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT Rip_RichInt FOREIGN KEY (COD_Ticket) REFERENCES Richiesta_Intervento (COD_Ticket) ON UPDATE CASCADE ON DELETE CASCADE
)  ENGINE=INNODB;

drop procedure if exists Scegli_Giorno_Diagnosi;
delimiter $$
create procedure Scegli_Giorno_Diagnosi(IN Data_ date ,IN fascia INT , OUT Tec_ VARCHAR(255))
begin
	
	declare rr int;
   
    select COUNT(*) into rr
    from Calendario_tecnici ct
    where ct.Data_Occupata = Data_ and ct.Fascia_Oraria_Occupata = fascia;
   
   if(rr = (select count(*) from tecnico where Prov_Centro_Assistenza = @cassa)) then signal sqlstate '45000' set message_text= 'Non esistono possibilita , Tutti i tecnici sono occupati per quel giorno in quella fascia oraria'; 
   else
   
   with t1 as(
	select * from 
	(
	select COD_Fiscale as CF_TECNICO ,Data_ as Data_Scelta, 1 as Fascia_des from tecnico where Prov_Centro_Assistenza = @Cassa and Specializzazione = @spec
    UNION 
    select COD_Fiscale as CF_TECNICO ,Data_  as Data_Scelta, 2 as fascia_des from tecnico where Prov_Centro_Assistenza = @Cassa and Specializzazione = @spec
	) as D 
	)
	
,
    t2 as(
	select CF_Tecnico ,
    Data_Scelta ,
    Fascia_des ,
	if((select 1 from richiesta_intervento r1 where r1.cf_tecnico = t1.CF_tecnico and r1.Data_Desiderata =Data_ AND r1.FasciaOraria_Desiderata = fascia_Des  ) is null , 0 ,(select 1 from richiesta_intervento r1 where r1.cf_tecnico = t1.CF_tecnico and r1.Data_Desiderata =Data_ AND r1.FasciaOraria_Desiderata = fascia_Des  ) )as Occupato ,
    @CProvi as Prov_cliente ,
    (select provincia from richiesta_intervento r1 where r1.cf_tecnico = t1.CF_tecnico and r1.Data_Desiderata = Data_ AND r1.FasciaOraria_Desiderata = fascia_Des  ) as Prov_cliente_occupato ,
    (select COUNT(*) from richiesta_intervento r1 WHERE r1.CF_Tecnico = t1.CF_tecnico) as Numero_interventi
    from t1
    order by CF_tecnico , Data_Scelta , Fascia_des
   
   )
   ,
   t3 as (
    select CF_Tecnico ,
    SUM(occupato) as Slot_Occupati ,
    if(Prov_cliente = SUM(if(Prov_cliente_occupato is null , 0 , Prov_cliente_occupato )) , 1 , 0) as Stessa_Provincia ,
    MAX(Numero_Interventi) as Num_Interventi_Precedenti
   from t2
   where NOT EXISTS (select 1 from richiesta_intervento r1 	where r1.CF_tecnico = t2.cf_tecnico and r1.Data_Desiderata = Data_  and r1.FasciaOraria_Desiderata = Fascia)
   group by cf_tecnico 
   having SUM(occupato) <= 1
   )
   
   select CF_Tecnico into Tec_
   from t3
   order by Slot_Occupati DESC, Stessa_Provincia DESC ,  Num_Interventi_Precedenti ASC
   limit 1;
  
   
   
   end if;
    
end $$
delimiter ;

drop procedure if exists Inserimento_Richiesta_Intervento_DOM;
delimiter $$
create procedure Inserimento_Richiesta_Intervento_DOM 
(IN _Nick VARCHAR(255) ,IN _Marc VARCHAR(255) ,IN _Mod VARCHAR(255) ,In Dat DATE ,In _fascia INT ,In via VARCHAR(20) , IN _CIV varchar(25)  , IN Provi varchar(255))
begin
	
    
    declare CASS varchar(255);
    declare Tp varchar(255);
    declare tick int;
    
    select h2.Provincia into Cass -- il centro assistenza più vicino
	from hub h1 
	inner join cambio_Provincia cp on cp.prov1 =h1.Provincia
	inner join centro_assistenza h2 on cp.prov2 = h2.Provincia
	order by tempomedio asc	limit 1;
    
    select tipo_prodotto into tp
    from oggetto where marca = _Marc and modello = _mod;
    
    drop temporary table if exists Calendario_tecnici;
    create temporary table calendario_tecnici (
    CF_tecnico varchar(255) ,
    data_occupata date ,
	Fascia_Oraria_Occupata int ,
	primary key(CF_tecnico , data_occupata , fascia_oraria_occupata)
   
    );
   
   insert into Calendario_tecnici
    select CF_tecnico as Tecnico , Data_Desiderata as Data_Occupata , ri.FasciaOraria_Desiderata as Fascia_Oraria_Occupata
	from richiesta_intervento ri
	inner join tecnico t on t.COD_fiscale = ri.CF_tecnico
	where 
    t.specializzazione = tp and 
    t.a_domicilio = 1 and -- a domicilio
    t.Prov_Centro_Assistenza = Cass  -- tecnico idoneo alprodotto specificato
    order by Data_Desiderata ,cf_tecnico , ri.FasciaOraria_Desiderata asc; 
    
    set @cassa = Cass;
    set @Spec = tp;
    set @CProvi =  Provi;
    
    CALL Scegli_Giorno_Diagnosi (Dat , _fascia , @tec);
    if(@tec is null ) then signal sqlstate '45000' set message_text= 'Non esistono possibilita , Tutti i tecnici sono occupati per quel giorno in quella fascia oraria';
	else
    select MAX(COD_Ticket) + 1 into tick
    from richiesta_intervento;    if(tick is null) then set tick = 1; end if;
    
    insert into Richiesta_Intervento values (tick ,0 , Dat , _nick , @tec ,current_timestamp , _Marc , _Mod ,via , _civ  ,Provi , _fascia , null );
	end if;
    
end $$
delimiter ;

drop table if exists Intervento_In_Azienda;
CREATE TABLE Intervento_In_Azienda (
    cod_Ticket INT PRIMARY KEY,
    COD_Seriale INT,
    CF_Tecnico VARCHAR(255),
    Finito TINYINT,
    Attivo TINYINT,
    Timestamp_Inizio_Lavoro TIMESTAMP,
    Timestamp_Fine_Lavoro TIMESTAMP 

)  ENGINE=INNODB;

drop trigger if exists Integ_Ref_eliminazione_tecnico_intervento_azienda;
delimiter $$
create trigger  Integ_Ref_eliminazione_tecnico_intervento_azienda after delete on tecnico for each row
begin

	delete from intervento_in_azienda where CF_Tecnico = old.COD_Fiscale;
end $$
delimiter ;

drop trigger if exists Integ_Ref_update_tecnico_intervento_azienda;
delimiter $$
create trigger  Integ_Ref_update_tecnico_intervento_azienda after update on tecnico for each row
begin

	update intervento_in_azienda set cf_tecnico = new.cod_fiscale where CF_Tecnico = old.COD_Fiscale;
end $$
delimiter ;

drop trigger if exists Integ_Ref_eliminazione_Prodotto_intervento_azienda;
delimiter $$
create trigger Integ_Ref_eliminazione_Prodotto_intervento_azienda after delete on prodotto for each row
begin

	delete from intervento_in_azienda where COD_Seriale = old.cod_seriale;
end $$
delimiter ;

drop trigger if exists Integ_Ref_update_Prodotto_intervento_azienda;
delimiter $$
create trigger  Integ_Ref_update_Prodotto_intervento_azienda after update on  prodotto for each row
begin

	update intervento_in_azienda set COD_Seriale = new.cod_seriale where COD_Seriale = old.COD_seriale;
end $$
delimiter ;

DROP PROCEDURE IF EXISTS Conta_Separatori;
DELIMITER $$
CREATE PROCEDURE Conta_Separatori(IN STR TEXT , IN Separatore CHAR , OUT Num INT)  -- Procedura che conta i ';' Conta_Separatori(STR , ';')
BEGIN

SELECT (LENGTH(STR)-LENGTH(REPLACE(STR, Separatore, ''))) into Num;

END; $$
DELIMITER ;

DROP PROCEDURE IF EXISTS String_To_Tab;
DELIMITER $$
CREATE PROCEDURE String_To_Tab(IN STR TEXT ) 
BEGIN

		DECLARE NUM_Operazioni INT DEFAULT 0;
		DECLARE i INT DEFAULT 0;
		DECLARE c INT DEFAULT 0;
		DECLARE disp BOOLEAN default false;
		DECLARE Operazione_Testa TEXT DEFAULT NULL; 
		DECLARE Operazione_Coda TEXT DEFAULT NULL;

		if(STR IS NULL OR STR = "") THEN SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'ERRORE , Stringa vuota!';END IF;

		DROP TEMPORARY TABLE IF EXISTS Operazioni_Rimedio;
		CREATE TEMPORARY TABLE Operazioni_Rimedio(
		NumeroOperazione INT ,
		Operazione TEXT
		);

		CALL Conta_Separatori(STR , ';' , NUM_Operazioni);
		SET NUM_Operazioni = NUM_Operazioni + 1;

		if(NUM_Operazioni = 1) then INSERT INTO Operazioni_Rimedio VALUES ( 1 , STR); -- se la stringa era composta da una sola sottostringa( nessun ';')

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
		SET STR = SUBSTRING_INDEX(STR, ';', -(NUM_Operazioni - i -  if( disp is true , false , true) )); 
		end if;

		if(Operazione_Testa != "") then
		INSERT INTO Operazioni_Rimedio VALUES ( c + 1 , Operazione_Testa); 
		set c = c + 1;
		end if;
		set i = i + 1;

		UNTIL i = NUM_Operazioni + disp 
		END REPEAT;
		 

		end if;


END; $$
DELIMITER ;

 drop procedure if exists Retrieve;
 delimiter $$
 create procedure Retrieve (In Lista TEXT , IN Tipo_Prodo VARCHAR(255)) 
 begin
 
 
  call String_To_Tab(Lista);
 
 
 drop table if exists Guasti_Affinita;
 create table Guasti_Affinita (
 COD_Guasto int ,
 Affinita INT
 );
 
 insert into Guasti_Affinita
 with t1 as(
 select ori.NumeroOperazione as Nums , ori.Operazione as COD_Sintomo 
 from Operazioni_Rimedio ori
 )
 ,
 t2 as(
 select distinct Nums , COD_Sintomo , COD_Guasto , o.tipo_prodotto
 from t1
 inner join guasto_sintomo gs using(cod_sintomo) -- per ogni sintomo prendo i guasti associati
 inner join prodotto_guasto pg using(cod_guasto) -- guasti che si sono verificati
 inner join prodotto p using(COD_Seriale) -- su un prodotto
 inner join lotto l using(ID_lotto) -- dello stesso tipo
 inner join sequenza s using(ID_Sequenza)
 inner join oggetto o using(Marca , Modello) -- del prodotto specificato
 where o.Tipo_Prodotto = tipo_prodo
 
 )
 
 select COD_Guasto , (COUNT(COD_Sintomo) * 30) as Affinity
 from t2
 group by cod_guasto;
 
 end $$
 delimiter ;
 
 drop procedure if exists Reuse_;
 delimiter $$
 create procedure Reuse_() 
 begin
 drop table if exists Rimedio_Principale;
 create table Rimedio_Principale (
Rango int ,
COD_Guasto INT ,
COD_Rimedio INT ,
punti_revise int ,
stringa_mod text
 );
 
 
 insert into Rimedio_Principale
 with t1 as(
	select ga.COD_Guasto ,ogr.COD_Rimedio , (ga.Affinita + ogr.contatore_successi) as Affinita
    from Guasti_Affinita ga inner join Oggetto_Guasto_Rimedio ogr using(COD_Guasto)
    )
    
    select RANK() OVER(partition by COD_Guasto order by Affinita) as Rango , COD_Guasto , COD_Rimedio , 0 , null
    from t1;
    set @points = 0;
 end $$
 delimiter ;
 
 drop procedure if exists Revise;
 delimiter $$
 create procedure Revise(In Rimed INT) 
 begin
	declare e int;
    declare tes text;
    
  
    set @points = 0;
    
    
	drop table if exists Rimedio_Modificato;
	create table Rimedio_Modificato like operazioni_rimedio;
    
    drop table if exists Rimedio_Modificato_2;
	create table Rimedio_Modificato_2 like operazioni_rimedio;
  

    select 1 into e from Rimedio_Principale where cod_rimedio = Rimed;
    if(e is null) then signal sqlstate '45000' set message_text = 'Rimedio inesistente!'; end if;
    
    select Descrizione_Rimedio into tes
    from rimedio
    where cod_rimedio = rimed;
    
    set @rimed = rimed;
    
    call String_To_Tab(tes);
    
      
    insert into Rimedio_Modificato select * from operazioni_rimedio;
	insert into Rimedio_Modificato_2 select * from operazioni_rimedio;
   
    
   
 end $$
 delimiter ;
 
 drop procedure if exists Revise_modifica_Sezione;
 delimiter $$
 create procedure Revise_modifica_Sezione(In Sez int , In Test text) 
 begin
 declare e int;
 declare b int;
 
	declare c text;
    select operazione into c 
    from Rimedio_Modificato_2 where NumeroOperazione = Sez;
 
	 select 1 into e from Rimedio_Modificato where NumeroOperazione = sez;
     select 1 into b from Rimedio_Modificato_2 where NumeroOperazione = sez;
    if(e is null AND b is null) then signal sqlstate '45000' set message_text = 'Rimedio inesistente!'; end if;
	if(test is null) then signal sqlstate '45000' set message_text = 'Testo non valido'; end if;
   
	update Rimedio_Modificato  set operazione = Test where NumeroOperazione = Sez;
    update Rimedio_Modificato_2 set operazione = '*' where NumeroOperazione = Sez;
    
    if( c not in ('ç' , '#' , '*') ) then   set @points = @points + 0.5; end if;
	update rimedio_principale
    set punti_revise = @points ,
    stringa_mod = (select GROUP_CONCAT(Operazione separator ';') as rim from rimedio_modificato)
    where cod_rimedio = @rimed;
   
 end $$
 delimiter ;
 
 drop procedure if exists Revise_elimina_Sezione;
 delimiter $$
 create procedure Revise_elimina_Sezione(In Sez int) 
 begin
	declare e int;
	declare b int;
    declare c text;
    select operazione into c 
    from Rimedio_Modificato_2 where NumeroOperazione = Sez;
    
	 select 1 into e from Rimedio_Modificato where NumeroOperazione = sez;
     select 1 into b from Rimedio_Modificato_2 where NumeroOperazione = sez;
    if(e is null AND b is null) then signal sqlstate '45000' set message_text = 'Rimedio inesistente!'; end if;
 
    delete from Rimedio_Modificato where NumeroOperazione = Sez;
    update Rimedio_Modificato_2 set operazione = 'ç' where NumeroOperazione = Sez;
    
       if( c <> '#' ) then   set @points = @points + 1; end if;
         update rimedio_principale set punti_revise = @points,
    stringa_mod = (select GROUP_CONCAT(Operazione separator ';') as rim from rimedio_modificato) where cod_rimedio = @rimed;
     
 end $$
 delimiter ;
 
 drop procedure if exists Revise_Inserisci_Sezione;
 delimiter $$
 create procedure Revise_Inserisci_Sezione(In new_sez int ,In test text) 
 begin
	declare m int;
   
    
    if(new_sez <= 0 or New_sez is null) then signal sqlstate '45000' set message_text = 'Numero della Nuova sezione non valido'; end if;
     if(test is null) then signal sqlstate '45000' set message_text = 'Testo non valido'; end if;
    
    select MAX(NumeroOperazione) into m
    from rimedio_modificato;
    
    if(m is null) then set m = 0; end if;
    
    if(m < new_sez) then
    insert into rimedio_modificato values (m+1 , test);
    insert into rimedio_modificato_2 values (m+1 , '#');
    else
    update rimedio_modificato   set NumeroOperazione = NumeroOperazione + 1 where NumeroOperazione >= m; -- faccio spazio tra quelli dopo
    update rimedio_modificato_2 set NumeroOperazione = NumeroOperazione + 1 where NumeroOperazione >= m;
    insert into rimedio_modificato values (m , test);
    insert into rimedio_modificato_2 values (m , '#');
    
    
    end if;
     set @points = @points + 1;
	 update rimedio_principale set punti_revise = @points,
    stringa_mod = (select GROUP_CONCAT(Operazione separator ';') as rim from rimedio_modificato) where cod_rimedio = @rimed;
 
 end $$
 delimiter ;
 
 drop procedure if exists Retrieve_Show_Rimedio_Modificato;
 delimiter $$
 create procedure Retrieve_Show_Rimedio_Modificato() 
 begin
	
    select rm.* , rm2.operazione
    from rimedio_modificato rm right outer join rimedio_modificato_2 rm2 on rm.numerooperazione = rm2.numerooperazione;
 
 end $$
 delimiter ;
 
 drop procedure if exists Retrieve_Show_Rimedio_Modificato;
 delimiter $$
 create procedure Retrieve_Show_Rimedio_Modificato() 
 begin
	
    select rm.* , rm2.operazione
    from rimedio_modificato rm right outer join rimedio_modificato_2 rm2 on rm.numerooperazione = rm2.numerooperazione;
 
 end $$
 delimiter ;
 
 drop procedure if exists Retain_;
 delimiter $$
 create procedure Retain_( in rimed int , in guasto_risolto int , IN ser int ) 
 begin
	
    declare score double;
    declare num int default 0;


    declare rim int;
	declare d_rim text;
	declare rimfr int;

   
    select COD_Rimedio , r.Descrizione_Rimedio , punti_revise into  rim , d_rim , score
    from rimedio_principale rp 
    inner join rimedio r using(COD_rimedio)
    where COD_Rimedio = rimed and cod_guasto = guasto_risolto;

    call Conta_Separatori(d_rim , ';' , num);

    if(score >= (num*0.4)) then 
    
    select MAX(COD_Rimedio) + 1 into rimfr from rimedio;
	insert into Rimedio values (rimfr , (select stringa_mod from rimedio_principale where cod_rimedio = rimed and cod_guasto = guasto_risolto));
    call Guasto_Rimediato(ser , guasto_risolto , current_date , rimfr);
   else
    call Guasto_Rimediato(ser , guasto_risolto , current_date , rimed);
    
    end if;
 
   
    
 end $$
 delimiter ;

 drop procedure if exists Assegna_Prodotto_AF;
 delimiter $$
 create procedure Assegna_Prodotto_AF(IN Tick int , in Tec VARCHAR(255)) 
 begin
 declare e int;
 
 select 1 into e from tecnico t where COD_Fiscale = tec and t.a_domicilio = 0;
 if(e is null) then signal sqlstate '45000' set message_text = 'Tecnico inesistente!'; end if;
 
	update intervento_in_azienda set CF_tecnico = tec , finito = 0, attivo = 1 , Timestamp_inizio_lavoro = current_timestamp where cod_ticket = tick;
    
   
 end $$
 delimiter ;

drop procedure if exists Esegui_Diagnosi;
delimiter $$
create procedure Esegui_Diagnosi(In _Ser INT , In Tick INT , IN Durat INT , IN Lista_Guasti TEXT )
begin
	declare er tinyint;
    
    select 1 into er from richiesta_intervento where COD_Ticket = tick and intervento = 0 and NOT EXISTS (select 1 from richiesta_intervento where Intervento = 1 and COD_Ticket = tick);
    if er is null then signal sqlstate '45000' set message_text = 'Richiesta di diagnosi inesistente o dianosi già eseguita'; end if;
    
    call String_To_Tab(Lista_Guasti); -- dal prodotto ottengo tutti i guasti trovati dal tecnico
    
    insert into prodotto_guasto
    select _Ser , Operazione as COD_Guasto , current_date as Data_Rivenimento_Guasto , 0 as Rimediato
    from operazioni_rimedio;
    
    insert into riparazione
    select Tick , Operazione as COD_Guasto , null
    from operazioni_rimedio;
    
    insert into ordine_pezzi_af 
    select NULL , Operazione as COD_Guasto , tick , current_timestamp from operazioni_rimedio;
    
    update richiesta_intervento set DurataIntervento = Durat where COD_Ticket = tick and Intervento = 0;
    
  
    
end $$
delimiter ;

drop procedure if exists Intervento_Riparazione_Guasto;
delimiter $$
create procedure Intervento_Riparazione_Guasto(In Tick INT , IN guast INT , IN Durat int)
begin
	declare er tinyint;
    declare ser int;
    
    select 1 into er from richiesta_intervento where COD_Ticket = tick and intervento = 0;
    if er is null then signal sqlstate '45000' set message_text = 'Richiesta di diagnosi inesistente o dianosi già eseguita'; end if;
    
    
  update riparazione set Tempo_Riparazione = durat where COD_Ticket = tick and COD_Guasto = guast;
  
  select COD_Seriale into ser 
  from preventivo where COD_Ticket = tick;
  
  update prodotto_guasto set rimediato = 1 , Data_Rivenimento_Guasto  = current_date 
  where COD_Seriale = ser and cod_guasto = guast;
    
    
    
end $$
delimiter ;

drop procedure if exists Esegui_Ordine_Pezzi_Af;
delimiter $$
create procedure Esegui_Ordine_Pezzi_Af(In ordine int , in comp int , in quant int)
begin

    insert into ordine_pezzi_af_componente values (ordine , comp , quant);
    
    update scorte_centroassistenza set quantita = quantita - quant where cod_componente = comp and
    prov_centro_assistenza = (
    select ca.Provincia
    from centro_assistenza ca 
    inner join tecnico t on t.Prov_Centro_Assistenza = ca.Provincia
    inner join richiesta_intervento ri on t.COD_Fiscale = ri.CF_Tecnico
    inner join ordine_pezzi_af op on op.COD_Ticket = ri.COD_Ticket
    where op.cod_ordine = ordine
    limit 1);

   
end $$
delimiter ;

drop procedure if exists Inserisci_Preventivo;
delimiter $$
create procedure Inserisci_Preventivo (In Tick INT ,In _ser INT , IN Prez DOUBLE , In Dec_Sub TINYINT , IN Acc TINYINT , IN Trasp TINYINT)
begin
	declare er tinyint;
    
    select 1 into er from richiesta_intervento where COD_Ticket = tick and intervento = 0 and NOT EXISTS (select 1 from richiesta_intervento where Intervento = 1 and COD_Ticket = tick);
    if er is null then signal sqlstate '45000' set message_text = 'Richiesta di diagnosi inesistente'; end if;
    
    insert into preventivo values (tick , _ser , prez , NULL , dec_sub , acc , trasp);
    if(dec_sub = 1 and acc = 1) then
        call Esito_Preventivo(tick , 1 , 1);
     end if;
end $$
delimiter ;

drop procedure if exists Esito_Preventivo;
delimiter $$
create procedure Esito_Preventivo (In Tick INT , IN Acc TINYINT , In dec_sub int )
begin
	declare er int;
    declare Az int;
    declare s int;
    
    select 1 into er from preventivo where DataDecisione is null and COD_ticket = tick;
    if(er is null) then signal sqlstate '45000' set message_text = 'Esito del preventivo gia deciso'; end if;
    
    
    update preventivo set DataDecisione = current_date , Accettato = acc , DecisioneSubito = Dec_Sub where COD_Ticket = tick;
    
    select p.Trasporto , p.COD_Seriale into az , s
    from preventivo p where cod_ticket = tick;
    
    if(az = 1 and acc = 1) then 
    insert into intervento_in_azienda values (tick , s , null , null , null , null , null);
    end if;
    
end $$
delimiter ;

drop procedure if exists Show_Appuntamenti_Tecnico;
delimiter $$
create procedure Show_Appuntamenti_Tecnico(In Tec VARCHAR(255))
begin

select COD_Ticket , Nome_Via , Numero_Civico , Provincia,IF(Intervento = 0 , 'Diagnosi' , 'Intervento') as Attivita , 
Data_Desiderata as Data ,
 if(FasciaOraria_Desiderata = 1 , '[10:00 - 12:30] ','[14:00 - 16:30] ')as Fascia_Oraria 

from richiesta_intervento
order by Data_Desiderata asc;
end $$
delimiter ;

drop procedure if exists Pianifica_Intervento_Domicilio;
delimiter $$
create procedure Pianifica_Intervento_Domicilio(In Tick int , In data_des INT , in fascia int)
begin
declare er int;
declare dat date;

	if(fascia not in (1 , 2)) then signal sqlstate '45000' set message_text = 'fascia oraria non valida'; end if;
	
    select 1 into er from richiesta_intervento where Intervento = 0 and COD_ticket = tick;
    if(er is null) then signal sqlstate '45000' set message_text = 'Occorre eseguire prima una diagnosi!'; end if;
    
     select 1 into er from preventivo where DataDecisione is not null and Accettato = 1 and COD_ticket = tick and trasporto = 0;
    if(er is null) then signal sqlstate '45000' set message_text = 'Esito del preventivo non ancora deciso!'; end if;
    
  
     set er = null;
     select 1 into er from pagamento_af where COD_ticket = tick;
    if(er = 1) then signal sqlstate '45000' set message_text = 'Intervento a Domicilio gia concluso!'; end if;
    
	insert into Richiesta_Intervento
    select tick , 1 , data_des , nickname , CF_Tecnico , current_timestamp ,Marca , Modello , Nome_Via , Numero_Civico ,Provincia , fascia , NULL
    from richiesta_intervento
    where cod_ticket = tick 
    order by data_desiderata desc
    limit 1;

end $$
delimiter ;

drop procedure if exists Esegui_Intervento_Domicilio;
delimiter $$
create procedure Esegui_Intervento_Domicilio(In Tick int , In Durata INT )
begin
	declare er int;
	declare dat date;

	
    
    select 1 into er from richiesta_intervento where Intervento = 0 and COD_ticket = tick;
    if(er is null) then signal sqlstate '45000' set message_text = 'Occorre eseguire prima una diagnosi!'; end if;
    
    select 1 into er from richiesta_intervento where Intervento = 1 and COD_ticket = tick and DurataIntervento is null;
    if(er is null) then signal sqlstate '45000' set message_text = 'Intervento inesistente!'; end if;
    
    update richiesta_intervento set DurataIntervento = Durata where COD_Ticket = tick AND Data_Desiderata = current_date  AND Intervento = 1;
   
end $$
delimiter ;

drop table if exists MV_Resoconto_Annuale;
CREATE TABLE MV_Resoconto_Annuale (
    Marca VARCHAR(255),
    Modello VARCHAR(255),
    Anno INT UNSIGNED,
    Numero_Unita_Nuove_prodotte INT UNSIGNED,
    Numero_Unita_Nuove_vendute INT UNSIGNED,
    Guadagno_Lordo_Unita_Nuove INT UNSIGNED,
    Costo_Materiali DOUBLE UNSIGNED,
    costo_manodopera INT UNSIGNED,
    Numero_Unita_Ricondizionate_Prodotte INT UNSIGNED,
    Numero_Unita_Ricondizionate_Vendute INT UNSIGNED,
    Guadagno_Lordo_Unita_Ricondizionate INT UNSIGNED
)  ENGINE=INNODB;

drop table if exists LOG_MV_Resoconto_Annuale;
CREATE TABLE LOG_MV_Resoconto_Annuale LIKE mv_resoconto_annuale;

insert into LOG_MV_Resoconto_Annuale
select Marca , Modello , year(current_date),0,0,0,0,0,0,0,0 from oggetto;

drop procedure if exists Update_LOG_MV_Resoconto_Annuale;
delimiter $$
create procedure Update_LOG_MV_Resoconto_Annuale()
begin

	update LOG_MV_Resoconto_Annuale lm
    set 
    Numero_Unita_Nuove_prodotte = Numero_Unita_Nuove_prodotte + (select mm.Numero_Unita_Nuove_prodotte from MV_Resoconto_Mensile mm where mm.marca =lm.marca and lm.modello = mm.modello) ,
    Numero_Unita_Nuove_vendute = Numero_Unita_Nuove_vendute + (select mm.Numero_Unita_Nuove_vendute from MV_Resoconto_Mensile mm where mm.marca =lm.marca and lm.modello = mm.modello) ,
    Guadagno_Lordo_Unita_Nuove = Guadagno_Lordo_Unita_Nuove + (select  mm.Guadagno_Lordo_Unita_Nuove from MV_Resoconto_Mensile mm where mm.marca =lm.marca and lm.modello = mm.modello) ,
	Costo_Materiali =Costo_Materiali + (select mm.Costo_Materiali  from MV_Resoconto_Mensile mm where mm.marca =lm.marca and lm.modello = mm.modello) ,
    costo_manodopera = costo_manodopera+(select mm.costo_manodopera from MV_Resoconto_Mensile mm where mm.marca =lm.marca and lm.modello = mm.modello) ,
    Numero_Unita_Ricondizionate_Prodotte = Numero_Unita_Ricondizionate_Prodotte +(select mm.Numero_Unita_Ricondizionate_Prodotte from MV_Resoconto_Mensile mm where mm.marca =lm.marca and lm.modello = mm.modello) ,
    Numero_Unita_Ricondizionate_Vendute =   Numero_Unita_Ricondizionate_Vendute + (select   mm.Numero_Unita_Ricondizionate_Vendute from MV_Resoconto_Mensile mm where mm.marca =lm.marca and lm.modello = mm.modello) ,
    Guadagno_Lordo_Unita_Ricondizionate = Guadagno_Lordo_Unita_Ricondizionate + (select mm.Guadagno_Lordo_Unita_Ricondizionate from MV_Resoconto_Mensile mm where mm.marca =lm.marca and lm.modello = mm.modello) 
    ;
    
    if(MONTH(current_date) = 1) then
		call Update_MV_Resoconto_Annuale();
    end if;
 
end $$
delimiter ;

drop procedure if exists Update_MV_Resoconto_Annuale;
delimiter $$
create procedure Update_MV_Resoconto_Annuale()
begin
	insert into MV_Resoconto_Annuale
    select * from LOG_MV_Resoconto_Annuale;
    truncate LOG_MV_Resoconto_Annuale;
	
end $$
delimiter ;

drop table if exists MV_Resoconto_Mensile;
CREATE TABLE MV_Resoconto_Mensile (
    Marca VARCHAR(255),
    Modello VARCHAR(255),
    Mese INT UNSIGNED,
    Anno INT UNSIGNED,
    Numero_Unita_Nuove_prodotte INT UNSIGNED,
    Numero_Unita_Nuove_vendute INT UNSIGNED,
    Guadagno_Lordo_Unita_Nuove INT UNSIGNED,
    Costo_Materiali DOUBLE UNSIGNED,
    costo_manodopera INT UNSIGNED,
    Numero_Unita_Ricondizionate_Prodotte INT UNSIGNED,
    Numero_Unita_Ricondizionate_Vendute INT UNSIGNED,
    Guadagno_Lordo_Unita_Ricondizionate INT UNSIGNED
)  ENGINE=INNODB;

drop table if exists MV_Resoconto_Annuale;
CREATE TABLE MV_Resoconto_Annuale LIKE mv_resoconto_mensile;

drop table if exists LOG_MV_Resoconto_Annuale;
CREATE TABLE LOG_MV_Resoconto_Annuale LIKE mv_resoconto_mensile;

drop event if exists Refresh_MV_resoconto_Mensile;
delimiter $$
create event Refresh_MV_resoconto_Mensile 
on schedule every 1 month starts '2021-03-01 02:00:00'
do begin
	call Refresh_MV_resoconto_Mensile_Proc();
end $$
delimiter ;

drop procedure if exists Refresh_MV_resoconto_Mensile_Proc;
delimiter $$
create procedure Refresh_MV_resoconto_Mensile_Proc()
begin
call Update_MV_Resoconto_Annuale();

truncate mv_resoconto_mensile;

insert into MV_Resoconto_Mensile
with t1 as(
	select
    pop.Marca as Marca,
    pop.Modello as modello,
   MONTH(CURRENT_DATE) as Mese_Corrente,
   YEAR(CURRENT_DATE) as Anno_Corrente ,  
     (select counT(COD_Seriale) from prodotto p inner join lotto l using(ID_Lotto) inner join sequenza s using(ID_Sequenza) where MONTH(data_fine_effettiva) = MONTH(Current_date) AND YEAR(data_fine_effettiva) =YEAR(Current_date)  and s.Marca = pop.marca and s.modello = pop.modello) as Numero_Unita_Nuove_Prodotte,
    (SELECT COUNT(p.COD_Seriale) from prodotto p inner join ordine o using(COD_ordine) inner join lotto l  using(ID_lotto) inner join sequenza s using(ID_Sequenza) where o.stato <> 'pendente' and MONTH(o.Timestamp_Fine_Pendenza) = MONTH(CURRENT_DATE) AND YEAR(o.Timestamp_Fine_Pendenza) = YEAR(CURRENT_DATE) and s.Marca = pop.marca and s.modello = pop.modello) as Numero_Unita_Nuove_Vendute,
	(SELECT SUM(Prezzo)from prodotto p inner join ordine o using(COD_ordine) inner join lotto l  using(ID_lotto) inner join sequenza s using(ID_Sequenza) inner join oggetto og using(marca , modello) where o.stato <> 'pendente'  and s.Marca = pop.marca and s.modello = pop.modello) as Guadagno_Lordo_Unita_Nuove,
    
	(select counT(COD_Seriale) from prodotto p inner join lotto_ricondizionati l using(ID_Lotto) where  l.marca = pop.marca and l.modello = pop.modello) as Numero_Unita_Ricondizionate_Prodotte ,
     (SELECT COUNT(p.COD_Seriale) from prodotto p inner join ordine o using(COD_ordine) inner join lotto_ricondizionati l  using(ID_lotto)  where o.stato <> 'pendente' and MONTH(o.Timestamp_Fine_Pendenza) = MONTH(CURRENT_DATE) AND YEAR(o.Timestamp_Fine_Pendenza) = YEAR(CURRENT_DATE) and l.Marca = pop.marca and l.modello = pop.modello) as Numero_Unita_Ricondizionate_Vendute ,
    (SELECT SUM(Prezzo)from prodotto p inner join ordine o using(COD_ordine) inner join lotto_ricondizionati l  using(ID_lotto) inner join oggetto og using(marca , modello) where o.stato <> 'pendente'  and l.Marca = pop.marca and l.modello = pop.modello) as Guadagno_Lordo_Unita_Ricondizionate ,
    ( 
    with t1 as(select op.id_sequenza , SUM(((cm.quantita /1000) * m.Valore)) as Costo_Materiali from OP_Seq op inner join operazione o on o.ID_Operazione = op.operazione inner join componente c on c.COD_Componente =op.cod_componente inner join componente_materiale cm on cm.COD_Componente = c.COD_Componente inner join materiale m on m.Nome = cm.Materiale group by op.ID_Sequenza)
    select (SUM(Costo_Materiali) * (select COUNT(ID_Lotto) from lotto l where MONTH(l.data_fine_effettiva) = MONTH(current_date) and YEAR(l.data_fine_effettiva) = YEAR(current_date) and  l.id_sequenza = s.id_sequenza  )) as Costo_Materiali 
    from t1 inner join sequenza s on t1.id_sequenza = s.id_sequenza  where s.Marca = pop.marca and s.Modello = pop.Modello  group by Marca , Modello
    ) as Costo_Materiali ,
    (
with t1 as(
select se.Marca ,se.Modello ,id_lotto ,l.ID_Sequenza,SUM((ABS(Datediff(l.data_fine_effettiva , l.data_inizio))*8)*Paga_Oraria) as Costo_Operai
from lotto l 
inner join sequenza se using(ID_Sequenza)
inner join stazione s on s.id_sequenza = l.id_sequenza 
inner join assegnazione_attuale ast on ast.Stazione = s.id_stazione
inner join operatore o on o.cod_fiscale = ast.operatore group by id_lotto
)
select SUM(Costo_operai) as Costo_Manodopera  from t1 where Marca = pop.marca and Modello=pop.Modello group by Marca,Modello 
) as Costo_Manodopera

    
   
    
    from oggetto pop
    )
    
    select 
    Marca ,
    Modello , 
    Mese_Corrente,
    Anno_Corrente,
    Numero_Unita_Nuove_Prodotte , 
    Numero_Unita_Nuove_Vendute , 
    if( Guadagno_Lordo_Unita_Nuove is null , 0 ,  Guadagno_Lordo_Unita_Nuove) as Guadagno_Lordo_Unita_Nuove ,
	if(Costo_Materiali is null , 0 , Costo_Materiali) as Costo_Materiali ,
    if(Costo_Manodopera is null , 0 , Costo_Manodopera) as Costo_Manodopera ,
    Numero_Unita_Ricondizionate_Prodotte  , 
    Numero_Unita_Ricondizionate_Vendute ,
	if(Guadagno_Lordo_Unita_Ricondizionate is null , 0 , Guadagno_Lordo_Unita_Ricondizionate) as Guadagno_Lordo_Unita_Ricondizionate 
    
    from t1;
end $$
delimiter ;

drop procedure if exists Concludi_Intervento_Domicilio;
delimiter $$
create procedure Concludi_Intervento_Domicilio(In Tick int , IN Metodo VARCHAR(255))
begin
	declare er int;
    declare Prezzo_Tot int;
	declare Prezzo_Scalat int;
    
    
	
    
    select 1 into er from richiesta_intervento where Intervento = 0 and COD_ticket = tick;
    if(er is null) then signal sqlstate '45000' set message_text = 'Occorre eseguire prima una diagnosi!'; end if;
    
    select 1 into er from richiesta_intervento where Intervento = 1 and COD_ticket = tick and DurataIntervento is null;
    if(er is null) then signal sqlstate '45000' set message_text = 'Intervento inesistente!'; end if;
    
	SELECT distinct  SUM(floor((c.Prezzo*aoc.quantita + ( r.Tempo_Riparazione/60 * t.Paga_Oraria)))) into Prezzo_Scalat
	 FROM 
	 ordine_pezzi_af oa 
	 natural join ordine_pezzi_af_componente aoc
	 inner join richiesta_intervento ri using(COD_Ticket)
	 inner join preventivo p using(COD_Ticket)
	 inner join garanzia_prodotto gp using(cod_seriale)
	 inner join garanzia g using(cod_garanzia)
	 inner join componente c on c.COD_Componente = aoc.COD_Componente
	 inner join riparazione r using(cod_ticket , cod_guasto)
	 inner join tecnico t on t.COD_Fiscale = ri.CF_Tecnico
	 where gp.timestamp_inizio + interval gp.durata month > current_date and
	 (g.COD_Componente = 28 OR g.COD_Componente = aoc.COD_Componente)
	  and  oa.COD_Ticket = tick
	 GROUP BY oa.cod_ticket;
	 
	SELECT distinct SUM(floor((c.Prezzo*aoc.quantita + ( r.Tempo_Riparazione/60* t.Paga_Oraria )))) into Prezzo_tot
	 FROM 
	 ordine_pezzi_af oa 
	 natural join ordine_pezzi_af_componente aoc
	 inner join richiesta_intervento ri using(COD_Ticket)
	 inner join preventivo p using(COD_Ticket)
	 inner join componente c on c.COD_Componente = aoc.COD_Componente
	 inner join riparazione r using(cod_ticket , cod_guasto)
	 inner join tecnico t on t.COD_Fiscale = ri.CF_Tecnico
	 where oa.COD_Ticket = tick
	 GROUP BY oa.cod_ticket;
	 
	insert into pagamento_af values (tick , prezzo_tot , metodo , Prezzo_Scalat);
		
	
   
end $$
delimiter ;


drop procedure if exists Prenota_Trasporto;
delimiter $$
create procedure Prenota_Trasporto (IN Tick INT , IN Data_Alt DATE , IN Fasc_Alt INT)
begin

	
    declare Peso_ int default 0;
    declare Tip_Squad int;
    declare sq int;
    
    declare fasc int;
    
    
    if(fasc_alt not in (1 , 2)) then signal sqlstate '45000' set message_text ='Fascia oraria non valida!'; end if;
	if(Data_alt < current_date) then signal sqlstate '45000' set message_text ='Data non valida , inserire una data successiva a quella corrente!'; end if;
    
    select distinct floor(Valore/1000) into Peso_ -- calcolo il peso dell oggetto specificato nel ticket
    from richiesta_intervento ri
    inner join oggetto o using(Marca , Modello)
    inner join Oggetto_caratteristica_prodotto cp using(Marca , Modello)
    where cp.Caratteristica = 'Peso'  and ri.cod_ticket = tick;
    

    if(peso_ < 15) then set tip_squad = 1; end if; -- calcolo il tipo di squadra più adatto
    if(peso_ >= 15 and peso_ < 50) then set tip_squad = 2; end if;
    if(peso_ >= 50) then set tip_squad = 3; end if;
    
    
    select FasciaOraria_Desiderata into fasc
    from richiesta_intervento -- ricavo la fascia oraria della diagnosi associata al trasporto da prenotare
    where COD_Ticket = tick and intervento = 0;
   
    
    
    with t1 as (
    select row_number()over() as num , s.COD_Squadra  
    from squadra s
    inner join tecnico t on t.Prov_Centro_Assistenza = s.Prov_Centro_Assistenza
    inner join richiesta_intervento ri on ri.CF_Tecnico = t.COD_Fiscale
    where ri.COD_Ticket = tick and s.Prov_Centro_Assistenza = t.Prov_Centro_Assistenza and s.Categoria = tip_squad
    and not exists (select 1 from prenotazione_trasporto pt1 where pt1.Squadra = s.COD_Squadra AND 
    ri.Data_Desiderata = pt1.DataTrasporto and ri.FasciaOraria_Desiderata = pt1.Fascia_Oraria)
    )
    ,
    t2 as(
    select MAX(Num) as m
    from t1
    )
    
    select COD_Squadra into sq
    from t1
    where NUM = (FLOOR((RAND() * (select * from t2 limit 1)) + 1));
    
    
    if(sq is not null  ) then
		insert into prenotazione_trasporto values (Tick , sq , current_date , fasc);
    else
     with t1 as (
    select row_number()over() as num , s.COD_Squadra  
    from squadra s
    inner join tecnico t on t.Prov_Centro_Assistenza = s.Prov_Centro_Assistenza
    inner join richiesta_intervento ri on ri.CF_Tecnico = t.COD_Fiscale
    where ri.COD_Ticket = tick and s.Prov_Centro_Assistenza = t.Prov_Centro_Assistenza and s.Categoria = tip_squad
    and not exists (select 1 from prenotazione_trasporto pt1 where pt1.Squadra = s.COD_Squadra AND 
    ri.Data_Desiderata = Data_Alt and ri.FasciaOraria_Desiderata = Fasc_Alt)
    )
    ,
    t2 as(
    select MAX(Num) as m     from t1
    )
    
    select COD_Squadra into sq
    from t1
    where NUM = (FLOOR((RAND() * (select * from t2 limit 1)) + 1));
    
    if(sq is null) then signal sqlstate '45000' set message_text = 'Nessuna squadra disponibile per quella data!'; end if;
    insert into prenotazione_trasporto values (Tick , sq , Data_Alt , Fasc_Alt );
    
    
    end if;
    

    

end$$

delimiter ;


drop procedure if exists Annulla_Trasporto;
delimiter $$
create procedure Annulla_Trasporto (IN Tick INT)
begin

	delete from prenotazione_trasporto where COD_Ticket = tick and DataTrasporto > current_date;
  
    

end$$

delimiter ;

drop procedure if exists Concludi_Intervento_Azienda;
delimiter $$
create procedure Concludi_Intervento_Azienda(In Tick int , IN Metodo VARCHAR(255))
begin
	declare er int;
    declare Prezzo_Tot int;
	declare Prezzo_Scalat int;
    
    
	
    
    select 1 into er from richiesta_intervento where Intervento = 0 and COD_ticket = tick;
    if(er is null) then signal sqlstate '45000' set message_text = 'Occorre eseguire prima una diagnosi!'; end if;
    
    select 1 into er from richiesta_intervento where Intervento = 1 and COD_ticket = tick and DurataIntervento is null;
    if(er is null) then signal sqlstate '45000' set message_text = 'Intervento inesistente!'; end if;
    
SELECT distinct  SUM(floor((c.Prezzo*aoc.quantita + ( r.Tempo_Riparazione/60 * t.Paga_Oraria)))) into Prezzo_Scalat
 FROM 
 ordine_pezzi_af oa 
 natural join ordine_pezzi_af_componente aoc
 inner join richiesta_intervento ri using(COD_Ticket)
 inner join preventivo p using(COD_Ticket)
 inner join garanzia_prodotto gp using(cod_seriale)
 inner join garanzia g using(cod_garanzia)
 inner join componente c on c.COD_Componente = aoc.COD_Componente
 inner join riparazione r using(cod_ticket , cod_guasto)
 inner join tecnico t on t.COD_Fiscale = ri.CF_Tecnico
 where gp.timestamp_inizio + interval gp.durata month > current_date and
 (g.COD_Componente = 28 OR g.COD_Componente = aoc.COD_Componente)
  and  oa.COD_Ticket = tick
 GROUP BY oa.cod_ticket;
 
SELECT distinct SUM(floor((c.Prezzo*aoc.quantita + ( r.Tempo_Riparazione/60* t.Paga_Oraria )))) into Prezzo_tot
 FROM 
 ordine_pezzi_af oa 
 natural join ordine_pezzi_af_componente aoc
 inner join richiesta_intervento ri using(COD_Ticket)
 inner join preventivo p using(COD_Ticket)
 inner join componente c on c.COD_Componente = aoc.COD_Componente
 inner join riparazione r using(cod_ticket , cod_guasto)
 inner join tecnico t on t.COD_Fiscale = ri.CF_Tecnico
 where oa.COD_Ticket = tick
 GROUP BY oa.cod_ticket;
 
insert into pagamento_af values (tick , prezzo_tot , metodo , Prezzo_Scalat);
update intervento_in_azienda set timestamp_fine_lavoro = current_timestamp where cod_ticket = tick;
    
	
   
end $$
delimiter ;

drop procedure if exists Cerca_Rimedio_in_base_codice_errore;
delimiter $$
create procedure Cerca_Rimedio_in_base_codice_errore(In err int , OUT Rimed INT)
begin
	
	select COD_Rimedio into Rimed
    from oggetto_guasto_rimedio
    where COD_Errore = err;
   
end $$
delimiter ;

drop procedure if exists Trend_Prod;
delimiter $$
create procedure Trend_Prod()
begin


select Marca , Modello ,'', Numero_Unita_Nuove_vendute as Numero_Vendite, '', AVG(Affidabilita) as Affidabilita , AVG(Esperienza) as Esperienza , AVG(Performance) as Performance , AVG(Design) as Design
 from mv_resoconto_mensile
 inner join recensione r using(Marca , Modello)
 group by  Marca , Modello
order by Numero_Unita_Nuove_vendute DESC
 limit 5;

end $$
delimiter ;


drop table if exists MV_Resoconto_Settimanale;
CREATE TABLE MV_Resoconto_Settimanale (
    Settimana DATE PRIMARY KEY,
    Numero_Unita_Vendute INT UNSIGNED,
    Numero_Unita_Nuove_vendute INT UNSIGNED,
    Numero_Unita_Ricondizionate_vendute INT UNSIGNED,
    Marca_TOP VARCHAR(255),
    Modello_TOP VARCHAR(255),
    Numero_Preventivi_Accettati INT
)  ENGINE=INNODB;

drop event if exists  Deferred_Update_MV_Resoconto_Settimanale
delimiter $$
create event Deferred_Update_MV_Resoconto_Settimanale
on schedule every 1 week starts '2021-03-27 02:00:00'
do begin
	call Update_MV_Resoconto_Settimanale();
end$$

delimiter ;


drop procedure if exists Update_MV_Resoconto_Settimanale;
delimiter $$
create procedure Update_MV_Resoconto_Settimanale()
begin

    
    insert into MV_Resoconto_Settimanale values (
		current_date ,
        (select COUNT(COD_Seriale) from ordine o inner join prodotto using(cod_ordine) where o.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)) ,
        (select COUNT(COD_Seriale) from ordine o inner join prodotto using(cod_ordine) inner join lotto l using(id_lotto) where o.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)) ,
	    (select COUNT(COD_Seriale) from ordine o inner join prodotto using(cod_ordine) inner join lotto_ricondizionati l using(id_lotto) where o.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)) ,
(select Marca
from ( (select Marca , Modello , COUNT(COD_Seriale) as Num from ordine o inner join prodotto using(cod_ordine)  inner join lotto l using(id_lotto)  inner join sequenza s using(ID_Sequenza)
 where o.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)
 group by Marca , Modello order by num desc limit 1) UNION ( select Marca , Modello , COUNT(COD_Seriale) as Num from ordine o inner join prodotto using(cod_ordine)  inner join lotto_ricondizionati l using(id_lotto) 
 where o.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)
 group by Marca , Modello order by num desc limit 1)  )as D  order by num limit 1) ,
 (select Modello
from ( (select Marca , Modello , COUNT(COD_Seriale) as Num from ordine o inner join prodotto using(cod_ordine)  inner join lotto l using(id_lotto)  inner join sequenza s using(ID_Sequenza)
 where o.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)
 group by Marca , Modello order by num desc limit 1) UNION ( select Marca , Modello , COUNT(COD_Seriale) as Num from ordine o inner join prodotto using(cod_ordine)  inner join lotto_ricondizionati l using(id_lotto) 
 where o.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)
 group by Marca , Modello order by num desc limit 1)  )as D  order by num limit 1) ,
   (select COUNT(*)  from preventivo p  where p.DataDecisione between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)  and p.Accettato = 1)
    
    
    
    );
	
end$$

delimiter ;

drop table if exists MV_Resoconto_Ordini_Giornaliero;
CREATE TABLE MV_Resoconto_Ordini_Giornaliero (
    Giorno DATE PRIMARY KEY,
    Numero_Ordini_Nuovi INT UNSIGNED,
    Numero_Ordini_Pendenti INT UNSIGNED,
    Numero_Ordini_Processazione INT UNSIGNED,
    Numero_Ordini_Preparazione INT UNSIGNED,
    Numero_Ordini_Spediti INT UNSIGNED,
    Numero_Ordini_Evasi INT UNSIGNED
)  ENGINE=INNODB;

drop procedure if exists Update_MV_Resoconto_Ordini_Giornaliero;
delimiter $$
create procedure Update_MV_Resoconto_Ordini_Giornaliero()
begin


declare ev int;
declare nov int;
declare pend int;
declare proc int;
declare prep int;
declare sped int;

drop temporary table if exists stati_ordini;
create temporary table stati_ordini(stato varchar(255) primary key);
insert into Stati_ordini values ('Pendente');insert into Stati_ordini values ('Processazione');insert into Stati_ordini values ('Preparazione');insert into Stati_ordini values ('Spedito');insert into Stati_ordini values ('Evaso');

select COUNT(o1.COD_Ordine) into nov
from Stati_ordini s1 left outer join ordine o1 on o1.Stato = s1.stato and o1.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute);

select  COUNT(o1.COD_Ordine) into ev
from Stati_ordini s1 left outer join ordine o1 on o1.Stato = s1.stato and o1.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)
where s1.stato = 'evaso'group by s1.stato;

select  COUNT(o1.COD_Ordine) into pend
from Stati_ordini s1 left outer join ordine o1 on o1.Stato = s1.stato and o1.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)
where s1.stato = 'Pendente'group by s1.stato;

select  COUNT(o1.COD_Ordine) into proc
from Stati_ordini s1 left outer join ordine o1 on o1.Stato = s1.stato and o1.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)
where s1.stato = 'Processazione'group by s1.stato;

select  COUNT(o1.COD_Ordine) into prep
from Stati_ordini s1 left outer join ordine o1 on o1.Stato = s1.stato and o1.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)
where s1.stato = 'Preparazione'group by s1.stato;

select  COUNT(o1.COD_Ordine) into Sped
from Stati_ordini s1 left outer join ordine o1 on o1.Stato = s1.stato and o1.Timestamp_Fine_Pendenza between (current_timestamp - interval 1 week) and (current_timestamp + interval 1 minute)
where s1.stato = 'Spedito'group by s1.stato;

replace into MV_Resoconto_Ordini_Giornaliero values (current_date , nov , pend , proc , prep , sped ,ev );

drop temporary table if exists stati_ordini;

end $$


drop event if exists Event_Update_MV_Resoconto_Ordini_Giornaliero;
delimiter $$
create event Event_Update_MV_Resoconto_Ordini_Giornaliero
on schedule every 1 day starts '2021-03-05 02:00:00' do
begin
call Update_MV_Resoconto_Ordini_Giornaliero();
end $$
delimiter ;

drop table if exists MV_Monitor_Sequenze;
create table MV_Monitor_Sequenze (

	ID_Sequenza int primary key ,
    Marca varchar(255) ,
    Modello varchar(255) ,
   Timestamp_Creazione timestamp ,
   Revisionata varchar(30) ,
    Num_volte_usata int ,
   Num_Stazioni int ,
	Num_Medio_Operazioni_per_Stazione int ,
	Num_Min_Operazioni_fra_le_Stazioni int ,
	Num_Max_Operazioni_fra_le_Stazioni int ,
	Num_Cambi_Faccia int , 
	Num_Cambi_Attrezzi int ,
	Num_Pezzi_Incompleti int  ,
	Ritardo_Totale_Generato varchar(40)
) engine = innoDB;


drop procedure if exists Refresh_On_Dem_MV_Monitor_Sequenze;
delimiter $$
create procedure Refresh_On_Dem_MV_Monitor_Sequenze()
begin

replace into MV_Monitor_Sequenze
select s.ID_Sequenza , s.Marca , s.Modello , s.Timestamp_Creazione , IF(s.Revisione = 1 , 'Valida' , 'Non ancora Validata') as Revisionata,
(select count(*) from lotto where id_sequenza = s.ID_Sequenza) as Numero_Volte_Usata ,
(select COUNT(*) from stazione sta1 where sta1.ID_Sequenza = s.id_sequenza) as Num_Stazioni 
,
(
with t1 as(select  COUNT(*) as N
from stazione sta inner join OP_Seq os on os.ID_Sequenza = sta.ID_Sequenza and (os.numero_operazione between sta.NUM_Inizio and sta.NUM_Fine)
where  os.id_sequenza = s.id_sequenza
group by id_stazione )
select IF(AVG(N) is null , 0 ,FLOOR(AVG(N)))  from t1
) as Num_Medio_Operazioni_per_Stazione
,
(
with t1 as(select  COUNT(*) as N
from stazione sta inner join OP_Seq os where os.ID_Sequenza = sta.ID_Sequenza and (os.numero_operazione between sta.NUM_Inizio and sta.NUM_Fine)
group by id_stazione )
select N from t1 where N = (select MIN(N) from t1)
) as Num_Min_Operazioni_per_Stazione  
,
(
with t1 as(select  COUNT(*) as N
from stazione sta inner join OP_Seq os on os.ID_Sequenza = sta.ID_Sequenza and (os.numero_operazione between sta.NUM_Inizio and sta.NUM_Fine)
where os.id_sequenza = s.id_sequenza
group by id_stazione )
select N from t1 where N = (select MAX(N) from t1)
) as Num_MAX_Operazioni_per_Stazione 
,
(
with t1 as (select distinct os.Numero_Operazione  , oco.faccia from op_seq os 
inner join sequenza s on os.id_sequenza = s.id_sequenza
inner join operazione_componente_oggetto oco on (oco.marca = s.marca AND oco.modello = s.modello AND oco.ID_Operazione = os.Operazione)
where os.id_sequenza = s.id_sequenza
order by os.Numero_Operazione asc)

select SUM(if(p.faccia <> t.faccia , 1 , 0)) 
from t1 t left outer join t1 p on t.numero_operazione = p.numero_operazione - 1
) as Num_Cambi_Facce
,
(

with t1 as(
select os.Numero_Operazione , u.Utensile 
from op_seq os
inner join utilizzo u on u.ID_Operazione = os.Operazione
order by os.Numero_Operazione , u.Step asc
)
,
t2 as(
select IF(t.utensile <> p.utensile ,1 , 0) as Cambio_Utensile
from t1 t left outer join t1 p on t.Numero_Operazione = p.Numero_Operazione - 1
)

select SUM(Cambio_Utensile) 
from t2

) as Cambio_Utensile ,
(
select  count(id_pezzo)
from pezzoincompleto pi 
inner join lotto using(id_lotto)
inner join sequenza s1 using(ID_Sequenza)
where s1.id_sequenza = s.id_sequenza
group by s1.id_sequenza
) as Num_Pezzi_Incompleti ,
(
select CONCAT(SUM(Ritardo_Totale_Generato) , ' Minuti ')
from (
select  s1.ID_Sequenza ,'Pass' as g , if(sum(sp.ritardo_generato) is null , 0 ,sum(sp.ritardo_generato) ) as Ritardo_Totale_Generato
from lotto l
inner join storicodeilotti_passati sp using(id_lotto)
inner join sequenza s1 using(ID_Sequenza)
where s1.id_sequenza = s.id_sequenza
group by s1.id_sequenza
UNION
select s1.id_sequenza  ,'Att' as g ,if(sum(sp.ritardo_generato) is null , 0 ,sum(sp.ritardo_generato) ) as Ritardo_Totale_Generato
from lotto l
inner join storicodeilotti_attuali sp using(id_lotto)
inner join sequenza s1 using(ID_Sequenza)
where s1.id_sequenza = s.id_sequenza
group by s1.id_sequenza
) as D
) as Ritardo_Totale_Generato
from sequenza s;

end $$
delimiter ;


drop event if exists Refresh_Deferred_MV_Monitor_Sequenze
delimiter $$
create event Refresh_Deferred_MV_Monitor_Sequenze on schedule 
every 1 day starts '2021-03-06 02:00:00'
do begin 

call Refresh_On_Dem_MV_Monitor_Sequenze();
end $$
delimiter ;


drop table if exists  MV_Monitor_Lotti_In_Produzione;
create table MV_Monitor_Lotti_In_Produzione (

	id_lotto int primary key ,
    Marca VARCHAR(255) ,
    Modello VARCHAR(255) ,
    
	Data_Inizio date ,
    Data_Fine_Prevista date ,
    Data_Fine_Minima date ,
    
    Numero_Prodotti int ,
    
    Ritardi_Umani varchar(10) ,
    Ritardi_Vari varchar(10) ,
    Ritardi TEXT 
    

) engine = innodb;

drop procedure if exists Refresh_MV_Monitor_Lotti_Proc;
delimiter $$
create procedure Refresh_MV_Monitor_Lotti_Proc()
begin


	replace into MV_Monitor_Lotti_In_Produzione 
    with t1 as(
select l.ID_Lotto ,
s.Marca ,
s.Modello ,
l.Data_inizio ,
l.Data_fine_prevista ,
l.Quantita_prodotti ,
if(sl.tipoevento = 'Ritardo Umano' , 'Ritardo Umano' , 'Ritardi Vari') as TipoEvento ,
(SUM(sl.ritardo_generato) / 60) as Ore_Ritardo -- in ore
from lotto l
inner join sequenza s using(ID_Sequenza)
inner join storicodeilotti_attuali sl using(id_lotto)
where l.data_fine_effettiva is null
group by l.id_lotto , sl.tipoevento  -- un lotto ancora in produzione

)


select p.ID_Lotto , p.Marca , p.Modello , p.Data_Inizio , p.Data_Fine_Prevista , 
DATE((p.Data_Inizio + interval (p.Ore_Ritardo + r.Ore_Ritardo) hour)) as Data_Fine_Minima ,
p.Quantita_prodotti ,
CONCAT(p.Ore_Ritardo , ' h') as Ritardi_Umani ,
CONCAT(r.Ore_Ritardo , ' h') as Ritardi_Vari ,
(
with t1 as(
select 
CONCAT( 'Evento -> ' , sl.info ) as info,
if(sl.info = 'Generato un pezzo incompleto' ,
(SELECT CONCAT(' | Responsabile -> ',o.Nome , ' ', o.Cognome , ' |') FROM pezzoincompleto pi
inner join lotto l using(ID_Lotto) inner join sequenza s using(ID_Sequenza)
inner join stazione sta on (sta.ID_Sequenza = s.id_sequenza AND pi.Num_Ultima_Op between sta.NUM_Inizio AND sta.NUM_Fine)
inner join assegnazione_attuale aat on aat.Stazione = sta.ID_Stazione inner join operatore o on o.COD_Fiscale = aat.Operatore
where l.id_lotto = sl.id_lotto AND pi.Time_Stamp_Incompletamento = sl.timestamp_evento)
 , ' | Responsabile -> Nessuno  | ') as Operaio_responsabile ,
CONCAT( ' Data -> ' , DATE(sl.Timestamp_evento) , ' alle ' , Hour(sl.Timestamp_evento) ,':',Minute(sl.Timestamp_evento) ,':',Second(sl.Timestamp_evento) ,' '  ) as Momento,
CONCAT(' | Ritardo Generato -> ' , sl.ritardo_generato , ' min ; ') as Ritardo

from storicodeilotti_attuali sl 
)

select GROUP_CONCAT((CONCAT(info , Operaio_responsabile , Momento , Ritardo))separator '') 
from t1
) as Lista_Ritardi

from t1 p
inner join t1 r on r.id_lotto = p.id_lotto
where p.tipoevento = 'Ritardo Umano' AND r.tipoevento = 'Ritardi Vari';

end $$

delimiter ;

drop event if exists Refresh_Deferred_MV_Monitor_Lotti;
delimiter $$
create event Refresh_Deferred_MV_Monitor_Lotti on schedule 
every 1 day starts '2021-03-05 01:30:00'
do begin CALL Refresh_MV_Monitor_Lotti_Proc(); end $$
delimiter ;

drop procedure if exists Stampa_Lista_Eventi;
delimiter $$
create procedure Stampa_Lista_Eventi(In Lott INT)
begin
	declare st text;
    declare er tinyint default null;
    
    select 1 into er from mv_monitor_lotti_in_produzione mv where mv.id_lotto = lott;
    if(er is null) then signal sqlstate '45000' set message_text = 'ERRORE , il lotto non esiste o non è più in produzione'; end if;
    
    select  m.Ritardi into st
    from mv_monitor_lotti_in_produzione m;
    
    call String_To_Tab(st);
    
    select * from Operazioni_Rimedio;
    drop table if exists Operazioni_Rimedio;

end $$

delimiter ;





SET FOREIGN_KEY_CHECKS=1;


INSERT INTO Provincia (id_Provincia, nome, id_regione) VALUES -- presa da internet
(1, 'Torino', 1),(2, 'Vercelli', 1),(3, 'Novara', 1),(4, 'Cuneo', 1),(5, 'Asti', 1),(6, 'Alessandria', 1),(7, 'Aosta', 2),(8, 'Imperia', 7),(9, 'Savona', 7),(10, 'Genova', 7),(11, 'La Spezia', 7),(12, 'Varese', 3),(13, 'Como', 3),(14, 'Sondrio', 3),(15, 'Milano', 3),(16, 'Bergamo', 3),(17, 'Brescia', 3),
(18, 'Pavia', 3),(19, 'Cremona', 3),(20, 'Mantova', 3),(21, 'Bolzano / Bozen', 4),(22, 'Trento', 4),(23, 'Verona', 5),(24, 'Vicenza', 5),(25, 'Belluno', 5),(26, 'Treviso', 5),(27, 'Venezia', 5),(28, 'Padova', 5),(29, 'Rovigo', 5),(30, 'Udine', 6),(31, 'Gorizia', 6),(32, 'Trieste', 6),(33, 'Piacenza', 8),(34, 'Parma', 8),(35, 'Reggio nell''Emilia', 8),(36, 'Modena', 8),(37, 'Bologna', 8),(38, 'Ferrara', 8),(39, 'Ravenna', 8),(40, 'Forlì-Cesena', 8),(41, 'Pesaro e Urbino', 11),(42, 'Ancona', 11),(43, 'Macerata', 11),(44, 'Ascoli Piceno', 11),

(45, 'Massa-Carrara', 9),(46, 'Lucca', 9),(47, 'Pistoia', 9),(48, 'Firenze', 9),(49, 'Livorno', 9),(50, 'Pisa', 9),(51, 'Arezzo', 9),(52, 'Siena', 9),(53, 'Grosseto', 9),

(54, 'Perugia', 10),(55, 'Terni', 10),(56, 'Viterbo', 12),(57, 'Rieti', 12),(58, 'Roma', 12),(59, 'Latina', 12),(60, 'Frosinone', 12),(61, 'Caserta', 15),(62, 'Benevento', 15),(63, 'Napoli', 15),(64, 'Avellino', 15),(65, 'Salerno', 15),(66, 'L''Aquila', 13),(67, 'Teramo', 13),(68, 'Pescara', 13),
(69, 'Chieti', 13),(70, 'Campobasso', 14),(71, 'Foggia', 16),(72, 'Bari', 16),(73, 'Taranto', 16),(74, 'Brindisi', 16),(75, 'Lecce', 16),(76, 'Potenza', 17),(77, 'Matera', 17),(78, 'Cosenza', 18),(79, 'Catanzaro', 18),(80, 'Reggio di Calabria', 18),(81, 'Trapani', 19),(82, 'Palermo', 19),(83, 'Messina', 19),(84, 'Agrigento', 19),(85, 'Caltanissetta', 19),(86, 'Enna', 19),(87, 'Catania', 19),(88, 'Ragusa', 19),(89, 'Siracusa', 19),(90, 'Sassari', 20),(91, 'Nuoro', 20),
(92, 'Cagliari', 20),(93, 'Pordenone', 6),(94, 'Isernia', 14),(95, 'Oristano', 20),(96, 'Biella', 1),(97, 'Lecco', 3),(98, 'Lodi', 3),(99, 'Rimini', 8),(100, 'Prato', 9),(101, 'Crotone', 18),(102, 'Vibo Valentia', 18),(103, 'Verbano-Cusio-Ossola', 1),(104, 'Olbia-Tempio', 20),(105, 'Ogliastra', 20),(106, 'Medio Campidano', 20),(107, 'Carbonia-Iglesias', 20),(108, 'Monza e della Brianza', 3),(109, 'Fermo', 11),(110, 'Barletta-Andria-Trani', 16);

alter table Provincia drop column id_regione; -- riadattata
alter table Provincia drop column id_Provincia;

insert into Cambio_Provincia -- Generazione Tempi Medi Provincia-Provincia
with t1 as(select p1.nome as Prov1 , p2.nome as Prov2 from Provincia p1 cross join Provincia p2 where p1.nome <> p2.nome)
, t2 as(select Prov1 , Prov2 , if((floor(rand()*1000)) < 20 , (floor(rand()*1000))+20 , (floor(rand()*1000))) as TempoMedio from t1 )
,t3 as(select p.Prov1 , p.Prov2 , p.tempomedio as Tempo1, (select t.TempoMedio from t2 t where (p.Prov1 = t.Prov2 and p.Prov2 = t.Prov1)) as Tempo2 from t2 p)

select prov1 , prov2 , FLOOR(((Tempo1 + Tempo2)/2)) as TempoMedio from t3;
-- rendo uguali i tempi dei doppioni (facendo una media dei due tempi) del tipo (p1 , p2) = (p2 , p1)

insert into predisposizione values ('Dispositivi Fissi' , 'Dispositivi elettronici piuttosto pesanti e fissi');
insert into predisposizione values ('Dispositivi Tascabili' , 'Dispositivi elettronici leggeri e tascabili');

INSERT INTO categoria_prodotto VALUES ('Computer','Dispositivi Fissi');
INSERT INTO categoria_prodotto VALUES ('Elettrodomestici','Dispositivi Fissi');
INSERT INTO categoria_prodotto VALUES ('Telefonia','Dispositivi Tascabili');
INSERT INTO categoria_prodotto VALUES ('Tutte',NULL);

insert into Sede_produzione values (null ,'Firenze' , 'GrandiSogni' , '7' );

insert into Scala_qualita values (1);
insert into Scala_qualita values (2);
insert into Scala_qualita values (3);
insert into Scala_qualita values (4);
insert into Scala_qualita values (5);

INSERT INTO tipo_prodotto VALUES ('Tutti','Tutte',0,0,0);
INSERT INTO tipo_prodotto VALUES ('Desktop','Computer',10,10,20);
INSERT INTO tipo_prodotto VALUES ('Lavastoviglie','Elettrodomestici',0,0,100);
INSERT INTO tipo_prodotto VALUES ('Lavatrice','Elettrodomestici',0,0,100);
INSERT INTO tipo_prodotto VALUES ('Portatile','Computer',0,0,100);
INSERT INTO tipo_prodotto VALUES ('Smartphone','Telefonia',0,0,100);
INSERT INTO tipo_prodotto VALUES ('SmartTV','Elettrodomestici',0,0,100);
INSERT INTO tipo_prodotto VALUES ('Tablet','Telefonia',0,0,100);

INSERT INTO Componente VALUES (NULL , 'Nulla' , 0 , 0 , 0 , 0);
INSERT INTO Componente VALUES (NULL , 'Bullone' , 0.03 , 0.04 , 5 , 0);
INSERT INTO Componente VALUES (NULL , 'Vite' , 0.02 , 0.04 , 5 , 0);
INSERT INTO Componente VALUES (NULL , 'LED' , 0.01 , 0.01 , 5 , 0);
INSERT INTO Componente VALUES (NULL , 'Scheda Madre' , 50 , 2 , 5 , 1); -- 5
INSERT INTO Componente VALUES (NULL , 'Scheda Video' , 100 , 2 , 5 , 1);
INSERT INTO Componente VALUES (NULL , 'RAM' , 30 , 0.5 , 5 , 0); -- 7
INSERT INTO Componente VALUES (NULL , 'Case PC' , 50 , 1 , 5 , 1); -- 8
INSERT INTO Componente VALUES (NULL , 'Alimentatore PC' , 150 , 10 , 5 , 1);
INSERT INTO Componente VALUES (NULL , 'Bullone' , 0.03 , 0.04 , 5 , 0);
INSERT INTO Componente VALUES (NULL , 'Cesto Lavatoj' , 20 , 10 , 5 , 0);
INSERT INTO Componente VALUES (NULL , 'Pulsante' , 0.05 , 0.01 , 5 , 0);
INSERT INTO Componente VALUES (NULL , 'Rivetto' , 0.01 , 0.04 , 5 , 0);
INSERT INTO Componente VALUES (NULL , 'Condensatore' , 0.01 , 0.01 , 5 , 0);
INSERT INTO Componente VALUES (NULL , 'Microfono Telefono' , 5 , 0.02 , 5 , 1);
INSERT INTO Componente VALUES (NULL , 'Cassa Telefono' , 10 , 0.02 , 5 , 1);
INSERT INTO Componente VALUES (NULL , 'Batteria Telefono' , 20 , 0.02 , 5 , 1); -- 17
INSERT INTO Componente VALUES (NULL , 'Scheda Madre S10' , 50 , 0.07 , 5 , 1);
INSERT INTO Componente VALUES (NULL , 'CPU Telefono' , 100 , 0.05 , 5 , 1);
INSERT INTO Componente VALUES (NULL , 'Dissipatore PC' , 15 , 0.1 , 5 , 1);
INSERT INTO Componente VALUES (NULL , 'CPU Desktop' , 200 , 0.1 , 5 , 1); -- 21
INSERT INTO Componente VALUES (NULL , 'Circuiti' , 0.06 , 0.05 , 5 , 0);
INSERT INTO Componente VALUES (NULL , 'Porte Logiche' , 0.01 , 0.01 , 5 , 0); -- 23
INSERT INTO Componente VALUES (NULL , 'Condensatore' , 0.01 , 0.01 , 5 , 0);
INSERT INTO Componente VALUES (NULL, 'Motore Lavatrice Lavatoj' ,150 , 30 , 10 , 1);
INSERT INTO Componente VALUES (NULL , 'Display S10' ,20 , 0.5 , 10 , 1);
INSERT INTO Componente VALUES (NULL , 'Maschera MOBO' ,20 , 0.5 , 10 , 1);
INSERT INTO Componente VALUES (NULL , 'Tutto' , 0 , 0 , 0 , 0);
INSERT INTO Componente VALUES (NULL , 'Disco Rigido PC' , 25 , 50 , 5 , 0); -- 29
INSERT INTO Componente VALUES (NULL , 'Cavo' , 1 , 2 , 5 , 0); -- 30
INSERT INTO Componente VALUES (NULL , 'Disco sistema operativo' ,100 , 0.5 , 10 , 1);
INSERT INTO Componente VALUES (NULL , 'Socket CPU' ,10 , 0.5 , 10 , 0);
INSERT INTO Componente VALUES (NULL , 'Set di Memorie PC' ,150 , 2 , 10 , 1); -- 33

insert into compone values ( 22 , 5);
insert into compone values ( 32 , 5);
insert into compone values ( 4  , 5);
insert into compone values ( 23  , 21);
insert into compone values ( 29  , 33);
insert into compone values ( 7  , 33);

Insert into Materiale values ('Ferro' ,2 ,0 );
Insert into Materiale values ('Plastica' , 3,1  );
Insert into Materiale values ('Vetro' , 5,0 );
Insert into Materiale values ('Oro' , 70 ,0  );
Insert into Materiale values ('Gomma' , 2 ,1  );
Insert into Materiale values ('Carta' , 1, 0);
Insert into Materiale values ('Rame' , 10, 0);
Insert into Materiale values ('Zinco' , 5, 0);
Insert into Materiale values ('Alluminio' ,7 ,0);
Insert into Materiale values ('Uranio' , 100,1);
Insert into Materiale values ('Litio' , 2, 1);

insert into Componente_Materiale values (30 , 'Gomma' , 30);
insert into Componente_Materiale values (8 , 'Alluminio' , 3000);
insert into Componente_Materiale values (23 , 'Oro' , 100);
insert into Componente_Materiale values (7 , 'Oro' , 100);
insert into Componente_Materiale values (32 , 'Plastica' , 200);
insert into Componente_Materiale values (5 , 'Oro' , 400);
insert into Componente_Materiale values (5 , 'Plastica' , 100);

INSERT INTO utensile VALUES ('Cacciavite');
INSERT INTO utensile VALUES ('Chiave Inglese');
INSERT INTO utensile VALUES ('Forbici');
INSERT INTO utensile VALUES ('Mano');
INSERT INTO utensile VALUES ('Martello');
INSERT INTO utensile VALUES ('Pappagallo');
INSERT INTO utensile VALUES ('Pinza');
INSERT INTO utensile VALUES ('Saldatrice');

INSERT INTO Oggetto VALUES('Samsung' , 'S10' , 2 , 800, 'Smartphone', '2019-12-03');
INSERT INTO Oggetto VALUES('Apple' , 'MAC' , 1 , 3000, 'Desktop', '2020-8-10');
INSERT INTO Oggetto VALUES('Apple' , 'IPhoneX' , 2 , 1200, 'Smartphone', '2020-1-14');
INSERT INTO Oggetto VALUES('Samsung' , 'Lavatoj' , 6 , 2000 , 'Lavatrice', '2019-05-18');
INSERT INTO Oggetto VALUES('HP' , 'MegaPC' , 2 , 5000 , 'Desktop', '2018-07-24');


insert into caratteristica_prodotto values ('RAM' , 'GB');
insert into caratteristica_prodotto values ('CPU' , 'Core');
insert into caratteristica_prodotto values ('Scheda Video' , 'GB'); 
insert into caratteristica_prodotto values ('Altezza' , 'Cm');
insert into caratteristica_prodotto values ('Peso' , 'g');
insert into caratteristica_prodotto values ('Larghezza' , 'Cm');
insert into caratteristica_prodotto values ('Lunghezza' , 'Cm');
insert into caratteristica_prodotto values ('Obbiettivo Fotocamera' , 'MP');
insert into caratteristica_prodotto values ('Hard Disk' , 'GB');
insert into caratteristica_prodotto values ('Cache' , 'MB');
insert into caratteristica_prodotto values ('Batteria' , 'Amp');
insert into caratteristica_prodotto values ('Capacita Cesto' , 'l');
insert into caratteristica_prodotto values ('Colore' , null);

insert into Oggetto_Caratteristica_Prodotto values ('HP' , 'MegaPC' , 'RAM ' , '16');
insert into Oggetto_Caratteristica_Prodotto values ('HP' , 'MegaPC' , 'CPU' , '32');
insert into Oggetto_Caratteristica_Prodotto values ('HP' , 'MegaPC' , 'Peso' , '4000');
insert into Oggetto_Caratteristica_Prodotto values ('HP' , 'MegaPC' , 'Scheda Video' , '7');
insert into Oggetto_Caratteristica_Prodotto values ('HP' , 'MegaPC' , 'Hard Disk' , '3072');
insert into Oggetto_Caratteristica_Prodotto values ('HP' , 'MegaPC' , 'Cache' , '254');
insert into Oggetto_Caratteristica_Prodotto values ('HP' , 'MegaPC' , 'Colore' ,'Nero'); 
insert into Oggetto_Caratteristica_Prodotto values ('HP' , 'MegaPC' , 'Altezza' , '20');
insert into Oggetto_Caratteristica_Prodotto values ('HP' , 'MegaPC' , 'Larghezza' ,'30'); 
insert into Oggetto_Caratteristica_Prodotto values ('HP' , 'MegaPC' , 'Lunghezza' ,'50'); 

INSERT INTO  caratteristiche_giunzione values ('Spessore Saldatura' , 'mm');
INSERT INTO  caratteristiche_giunzione values ('Profondita chiodo' , 'mm');
INSERT INTO  caratteristiche_giunzione values ('Profondita rivetto' , 'mm');
INSERT INTO  caratteristiche_giunzione values ('Giri di Bullone' , 'Num');
INSERT INTO  caratteristiche_giunzione values ('Giri di vite ' , 'Num');

INSERT INTO giunzione VALUES ('Chiodo'); -- 1
INSERT INTO giunzione VALUES ('Rivetti');
INSERT INTO giunzione VALUES ('Saldatura');
INSERT INTO giunzione VALUES ('Vite e Bullone');
INSERT INTO giunzione VALUES ('Incastro'); -- 5
INSERT INTO giunzione VALUES ('Colla'); -- 6

insert into Giunzione_Caratteristica values ('Saldatura' , 'Spessore Saldatura');
insert into Giunzione_Caratteristica values ('Rivetti' , 'Profondita rivetto');
insert into Giunzione_Caratteristica values ('Chiodo' , 'Profondita chiodo');
insert into Giunzione_Caratteristica values ('Colla' , 'Grammi Colla');
insert into Giunzione_Caratteristica values ('Vite e Bullone' , 'Giri di Bullone');
insert into Giunzione_Caratteristica values ('Vite e Bullone' , 'Giri di Vite');

call Congiungi_Componenti( 5 , 8 ,'Vite e Bullone');
call Congiungi_Componenti( 5 , 7 , 'Incastro');
call Congiungi_Componenti( 5 , 6 , 'Vite e Bullone');
call Congiungi_Componenti( 21 , 32 , 'Incastro');
call Congiungi_Componenti( 29 , 5 , 'Vite e Bullone');
call Congiungi_Componenti( 5 , 32 , 'Vite e Bullone');
call Congiungi_Componenti( 4 , 8 ,'Colla');
call Congiungi_Componenti( 5 , 9 ,'Incastro');

insert into operazione values (null , 'Avvitamento Bullone');
insert into operazione values (null , 'Avvitamento Vite');
insert into operazione values (null , 'Inserimento Vite');
insert into operazione values (null , 'Apertura Box Lavatrice'); -- 4
insert into operazione values (null , 'Montaggio CPU');
insert into operazione values (null , 'Montaggio Scheda Video');
insert into operazione values (null , 'Montaggio Fotocamera');
insert into operazione values (null , 'Montaggio Cestello');
insert into operazione values (null , 'Montaggio Motore'); -- 9
insert into operazione values (null , 'Inserimento Rivetto');
insert into operazione values (null , 'Apertura e Preparazione Case'); -- 11 -- 
insert into operazione values (null , 'Inserire e Fissare Scheda Madre'); -- 12 
insert into operazione values (null , 'Inserire e Fissare CPU'); -- 13 
insert into operazione values (null , 'Fissare Disco Rigido'); -- 14
insert into operazione values (null , 'Inserire RAM'); -- 15
insert into operazione values (null , 'Inserire Scheda Video'); --  16
insert into operazione values (null , 'Inserire e Fissare Alimentatore'); -- 17
insert into operazione values (null , 'Connettere tutti i Cavi'); -- 18
insert into operazione values (null , 'Prendere la maschera della MOBO'); -- 19
insert into operazione values (null , 'fissare le interfacce');  -- 20
insert into operazione values (null , 'Insallazione SO'); -- 21
insert into operazione values (null , 'Test Accensione'); -- 22
insert into operazione values (null , 'Chiusura Case'); -- 23

insert into Precedenza_Tecnologica values (9,4);
insert into Precedenza_Tecnologica values (12,11);
insert into Precedenza_Tecnologica values (13,11);
insert into Precedenza_Tecnologica values (14,11);
insert into Precedenza_Tecnologica values (15,11);
insert into Precedenza_Tecnologica values (16,11);
insert into Precedenza_Tecnologica values (17,11);
insert into Precedenza_Tecnologica values (18,11);
insert into Precedenza_Tecnologica values (13,12);
insert into Precedenza_Tecnologica values (15,12);
insert into Precedenza_Tecnologica values (16,12);
insert into Precedenza_Tecnologica values (17,12);
insert into Precedenza_Tecnologica values (19,12);
insert into Precedenza_Tecnologica values (22 , 21);

insert into Utilizzo values ('mano' , 11 , 1); -- Sequenza HP MegaPC
insert into Utilizzo values ('mano' , 12 , 1);
insert into Utilizzo values ('Cacciavite' , 12 , 2);
insert into Utilizzo values ('mano' , 13 , 1);
insert into Utilizzo values ('Cacciavite' , 13 , 2);
insert into Utilizzo values ('mano' , 14 , 1);
insert into Utilizzo values ('Cacciavite' , 14 , 2);
insert into Utilizzo values ('mano' , 15 , 1);
insert into Utilizzo values ('mano' , 16 , 1);
insert into Utilizzo values ('mano' , 17 , 1);
insert into Utilizzo values ('Cacciavite' , 17 , 2);
insert into Utilizzo values ('mano' , 18 , 1);
insert into Utilizzo values ('mano' , 19 , 1);
insert into Utilizzo values ('mano' , 20 , 1);
insert into Utilizzo values ('mano' , 21 , 1);
insert into Utilizzo values ('mano' , 22 , 1);
insert into Utilizzo values ('mano' , 23 , 1);
insert into Utilizzo values ('Cacciavite' , 23 , 2); -- Sequenza HP MegaPC

insert into  Operazione_Componente_Oggetto values (11 , 'HP' , 'MegaPC' ,8 , 1 ,1, 'Posare il case sul nastro e smontare la calotta superiore');
insert into  Operazione_Componente_Oggetto values (12 , 'HP' , 'MegaPC' ,5,1 ,1, 'Prendere con cura la MOBO e inserirla nell apposito alloggio');
insert into  Operazione_Componente_Oggetto values (12 , 'HP' , 'MegaPC' ,3,4 ,1, 'Fissare la scheda madre');
insert into  Operazione_Componente_Oggetto values (13 , 'HP' , 'MegaPC' ,21 ,1, 1,'Prendere con estrema cura il processore e adagiarlo nel suo alloggio');
insert into  Operazione_Componente_Oggetto values (13 , 'HP' , 'MegaPC' ,3 ,1,1, 'Fissare il processore');
insert into  Operazione_Componente_Oggetto values (14 , 'HP' , 'MegaPC' ,29,1 ,1, 'Prendere con cura il disco rigido e inserirlo nell apposito alloggio');
insert into  Operazione_Componente_Oggetto values (14 , 'HP' , 'MegaPC' ,3,4 ,1, 'Fissare il disco rigido');
insert into  Operazione_Componente_Oggetto values (15,  'HP' , 'MegaPC' ,7 ,1 ,1,'Inserire la RAM nel suo alloggio');
insert into  Operazione_Componente_Oggetto values (16 , 'HP' , 'MegaPC' ,6,1 ,1, 'Prendere con cura la scheda video e inserirla nell apposito alloggio');
insert into  Operazione_Componente_Oggetto values (16 , 'HP' , 'MegaPC' ,3,2,1,'Fissare la scheda video');
insert into  Operazione_Componente_Oggetto values (17 , 'HP' , 'MegaPC' ,9,1,1,'Prendere con cura l alimentatore e inserirlo nell apposito alloggio');
insert into  Operazione_Componente_Oggetto values (17 , 'HP' , 'MegaPC' ,3,4,1, 'Fissare l alimentatore ');
insert into  Operazione_Componente_Oggetto values (18 , 'HP' , 'MegaPC' ,30,5,1, 'Conntettere tutti i cavi');
insert into  Operazione_Componente_Oggetto values (19 , 'HP' , 'MegaPC' ,27,1,2, 'Prendere e inserire la mascera della MOBO');
insert into  Operazione_Componente_Oggetto values (20 , 'HP' , 'MegaPC' ,23,1,2, 'Fissare le interfacce');
insert into  Operazione_Componente_Oggetto values (21 , 'HP' , 'MegaPC' ,31,1,1, 'Installa il sistema operativo');
insert into  Operazione_Componente_Oggetto values (22 , 'HP' , 'MegaPC' ,12,1,1, 'test accensione');
insert into  Operazione_Componente_Oggetto values (23 , 'HP' , 'MegaPC' ,8,1,1, 'Prendere la calotta superiore del case');
insert into  Operazione_Componente_Oggetto values (23 , 'HP' , 'MegaPC' ,3,4,1,'fissare la calotta');

INSERT INTO Operatore VALUES('tti1' , 'Ingrano' , 'Meccanismi' , 'M',  'Maralli' , '56'  , 'Firenze' , '158458' , 1 , '1978-06-04' , '2005-06-23' , 7.5 , 'Desktop');
INSERT INTO Operatore VALUES('aaa1' , 'Chiavina' , 'Bullonetti' , 'F', 'Brutti' , '34'  , 'Firenze' , '157454' , 1 , '1994-06-04' , '2010-02-11' , 8.0 , 'Desktop');
INSERT INTO Operatore VALUES('pbe1' , 'Paolo' , 'Bruti' , 'M', 'Trulli' , '1' , 'Arezzo' , '158788' , 1 , '1985-06-04' , '2007-09-05' , 9.0 , 'Desktop');

insert into Magazzino_Componente VALUES(null  ,'Rughi' , '23'  , 'Grosseto' , 10000 );
insert into Scorte_Magazzino_Componente
select 1 as COD_Magazzino , COD_Componente , 10000 as quantita
from componente
where cod_componente <> 1 and cod_componente <> 28;

insert into Scorte_SedeProduzione 
select 1 as COD_Sede , COD_Componente , 1000 as quantita
from componente
where cod_componente <> 1 and cod_componente <> 28;



call ordine_interno_Sede_Magazzino ( 1, 1 , 2 , 3000);
call ordine_interno_Sede_Magazzino ( 1, 1 , 5, 1000);
call ordine_interno_Sede_Magazzino ( 1, 1 , 5 , 4000);
call ordine_interno_Sede_Magazzino ( 1, 1 , 2 , 3000);

CALL Crea_Sequenza ('HP' , 'MegaPC' , 3 , 10);

CALL Assegna_Stazione_a_Sequenza( 1 , 'Assemblamento Scheda Madre');
CALL Assegna_Stazione_a_Sequenza( 1 , 'Assemblamento Periferiche' );
CALL Assegna_Stazione_a_Sequenza( 1 , 'Chiusura Case e Finalizzazione');

CALL Assegna_Operazione_a_Sequenza(1 ,11 , 1 , 8);
CALL Assegna_Operazione_a_Sequenza(1 , 12, 1 , 5);
CALL Assegna_Operazione_a_Sequenza(1 ,13 , 1 , 19);
CALL Assegna_Operazione_a_Sequenza(1 ,14 , 1 , 29);
CALL Assegna_Operazione_a_Sequenza(1 ,15 , 1 , 7);
CALL Assegna_Operazione_a_Sequenza(1 ,16 , 1 , 6);
CALL Assegna_Operazione_a_Sequenza(1 ,17 , 1 , 9);
CALL Assegna_Operazione_a_Sequenza(1 , 18, 1 , 30);
CALL Assegna_Operazione_a_Sequenza(1 ,19 , 2 , 27);
CALL Assegna_Operazione_a_Sequenza(1 ,20 , 2 , 23);
CALL Assegna_Operazione_a_Sequenza(1 ,21 , 3 , 31);
CALL Assegna_Operazione_a_Sequenza(1 ,22 , 3 , 1);
CALL Assegna_Operazione_a_Sequenza(1 ,23, 3 , 3);

call  Valida_Sequenza(1);

insert into Assegnazione_attuale values ('tti1' , 1 , 9 , 18 , 2021);
insert into Assegnazione_attuale values ('aaa1' , 2 , 9 , 18 , 2021);
insert into Assegnazione_attuale values ('pbe1' , 3 , 9 , 18 , 2021);

insert into Assegnazione_passata values ('tti1' , 1 , 9 , 18 , 2020);
insert into Assegnazione_passata values ('aaa1' , 2 , 9 , 18 , 2020);
insert into Assegnazione_passata values ('pbe1' , 3 , 9 , 18 , 2020);
insert into Assegnazione_passata values ('tti1' , 1 , 8 , 18 , 2019);
insert into Assegnazione_passata values ('aaa1' , 2 , 8 , 18 , 2019);
insert into Assegnazione_passata values ('pbe1' , 3 , 8 , 18 , 2019);

insert into Magazzino VALUES(null  ,'Mori' , '2'  , 20000 , 'Dispositivi Fissi', 'Firenze');

insert into lotto values (1 , 1 , 1 , 1 , 6,9 ,3 , 20 , '2019-01-01' , '2019-02-01' , '2019-02-01' , NULL);
insert into lotto values (2 , 1 , 1 ,1 , 3,10 ,3 , 19 , '2021-01-01' , '2021-03-01' , NULL , NULL);



call Popola_Prestazioni(40 , 1);

insert into PezzoIncompleto VALUES(null , 2 , 4, null, current_timestamp - interval 6 hour);
insert into PezzoIncompleto VALUES(null , 2 , 10 , null , current_timestamp - interval 3 hour);
insert into PezzoIncompleto VALUES(null , 2 , 6 , null , current_timestamp - interval 30 minute);

insert into tipoevento values ('Incendio');
insert into tipoevento values ('Ritardo Umano');
insert into tipoevento values ('Perdita di Gas');
insert into tipoevento values ('Malfunzionamento Nastro');
insert into tipoevento values ('Guasto al motore del nastro');
insert into tipoevento values ('Insufficenza di Personale');

insert into StoricoDeiLotti_Attuali values(2 , current_timestamp - interval 7 day , 'Incendio' , 'Sono stati danneggiati 2 pezzi sul nastro' , 24);
insert into StoricoDeiLotti_Attuali values(2 , current_timestamp - interval 6 hour, 'Ritardo Umano' , 'Generato un pezzo incompleto' , 1);
insert into StoricoDeiLotti_Attuali values(2 , current_timestamp - interval 30 minute, 'Ritardo Umano' , 'Generato un pezzo incompleto' , 1);

insert into Classe_Guasto values ('Tutti'); -- Speciale
insert into Classe_Guasto values ('Incuria'); -- Speciale
insert into Classe_Guasto values ('Assistenza Fisica Componenti'); -- Speciale
insert into Classe_Guasto values ('Assistenza Fisica Parti'); -- Speciale

insert into Classe_Guasto values ('Rottura Lamina di Metallo');
insert into Classe_Guasto values ('Deformazione Lamina di Metallo');
insert into Classe_Guasto values ('Rottura Circuiti');
insert into Classe_Guasto values ('Fusione Circuiti');
insert into Classe_Guasto values ('Rottura Plastiche');
insert into Classe_Guasto values ('Problemi Software');
insert into Classe_Guasto values ('Rottura Dischi di Memorizzazione');

insert into Guasto Values(null , 'Fusione MOBO' , 'Fusione Circuiti' , 'A causa di alte temperature i bus e il resto dei circuiti che compongono la MOBO si sono fusi fino a renderli inutilizzabili');
insert into Guasto Values(null , 'Fusione CPU' , 'Fusione Circuiti' , 'A causa di alte temperature i circuiti che compongono la CPU si sono bruciati');
insert into Guasto Values(null , 'Fusione RAM' , 'Fusione Circuiti' , 'A causa di alte temperature le componenti della RAM si sono bruciati');
insert into Guasto Values(null , 'Ammaccatura Case' , 'Deformazione Lamina di Metallo' , 'A causa di urti o incuria il case è ammaccato');
insert into Guasto Values(null , 'Rottura Hard Disk' , 'Rottura Dischi di Memorizzazione' , 'A causa di urti o di eccessivo utilizzo il disco della memoria secondaria non funziona a dovere');
insert into Guasto Values(null , 'Sistema Operativo Installato Male' , 'Problemi Software' , 'Il sistema operativo non è stato installato a dovere durante la procedura di montaggio');
insert into Guasto Values(null , 'Sistema Operativo Impostato Male' , 'Problemi Software' , 'L utilizzatore ha modificato in modo errato le impostazioni di sistema');

insert into Sintomo values(null , 'Non viene caricato il programma di Bootstrap');
insert into Sintomo values(null , 'Il pc non si accende (Nessun segno di vita)');
insert into Sintomo values(null , 'Ammaccature sulla superifice del Case');
insert into Sintomo values(null , 'Gravi bug di sistema e imprevedibilita della macchina in caso di comandi');
insert into Sintomo values(null , 'Il sistema è impostato in modo ambiguo');

insert into guasto_sintomo values ( 2 , 2);
insert into guasto_sintomo values ( 5 ,1 );
insert into guasto_sintomo values ( 1 ,1 );
insert into guasto_sintomo values ( 4 ,1 );
insert into guasto_sintomo values ( 1 , 2);
insert into guasto_sintomo values ( 3 , 2);
insert into guasto_sintomo values ( 4 , 3);
insert into guasto_sintomo values ( 6 , 4);
insert into guasto_sintomo values (7  , 5);

insert into Rimedio values (null , 'Aprire il case;Smontare il Socket;Sostituzione CPU;Rimontare Case;');
insert into Rimedio values (null , 'Aprire il case;Sostituzione RAM;Rimontare Case;');
insert into Rimedio values (null , 'Aprire il case;Sostituzione MOBO;Rimontare Case;');
insert into Rimedio values (null , 'Aprire il case;Rimuovere tutto il contenuto;Riparazione Case;Rimontare Case;');
insert into Rimedio values (null , 'Aprire il case;Sostituzione Hard Disk;Rimontare Case;'); -- 5
insert into Rimedio values (null , 'Reinstallazione del Sistema Operativo;');
insert into Rimedio values (null , 'Reset del Sistema Operativo;');

insert into Rimedio values (null , 'Attacca la spina alla corrente elettrica;'); -- 8
insert into Rimedio values (null , 'Accendi il Monitor;'); -- 9
insert into Rimedio values (null , 'Riavvia il PC;');

insert into Domande_Assistenza values ('HP' , 'MegaPC' , 1 , 'La spina della corrente è attaccata?' ,  8);
insert into Domande_Assistenza values ('HP' , 'MegaPC' , 2 , 'Lo schermo è acceso?' , 9);

insert into Garanzia values (null  , 'Desktop' ,'Tutti' , 150 , 12, 0 , 28 ); -- 2 Kasko per desktop
insert into Garanzia values (null  , 'Desktop' ,'Rottura Circuiti' , 50 , 12, 0 , 20 ); 
insert into Garanzia values (null  , 'Desktop' ,'Rottura Circuiti' , 40 , 12, 0 , 7 ); 
insert into Garanzia values (null  , 'Desktop' ,'Rottura Circuiti' , 35 , 12, 0 , 5 ); 
insert into Garanzia values (null  , 'Desktop' ,'Rottura Lamina di Metallo' , 15 , 12, 0 , 8 );

insert into Garanzia
select null  , 'Tutti' ,'Assistenza Fisica Componenti' , 0 , 6 , 0 , COD_Componente
from componente
where Parte = 0; 

insert into Garanzia
select null  , 'Tutti' ,'Assistenza Fisica Parti' , 0 , 12 , 0 , COD_Componente
from componente
where Parte = 1;

insert into persona values ('trb4' , 'Paolo' ,'Paoloni' ,'M' , 'Chi' , 'NonSo'  , 'Arezzo' , 876564 , '1995-04-06' , 'Carta di Indentita' , 336222 , 'Stato Italiano' , '2023-04-06');
insert into persona values ('svsv1' , 'Galli' ,'Marrittu' ,'M' , 'Vitale' , '58'  , 'Firenze' , 766854, '1999-08-19' , 'Carta di Indentita' , 534543 , 'Stato Italiano' , '2023-07-19');
insert into persona values ('tnrt4' , 'Tarallina' ,'Tortigliani' ,'F' , 'Chi' , 'SaiTu' , 'Lucca' , 872342 , '1958-04-23' , 'Carta di Indentita' , 338122 , 'Stato Italiano' , '2022-04-23');

insert into account values ('Cucciolotta' , 'tnrt4' , current_timestamp - interval 6 YEAR, 'abcd' , 'Alfabeto' , 'si');
insert into account values ('ErBirri' , 'trb4' , current_timestamp - interval 5 YEAR , 'Analisi' , '2' , 'Fatta');
insert into account values ('Diablus' , 'svsv1' , current_timestamp - interval 3 YEAR, 'sfddf' , 'domanda?' , 'si domanda');
insert into account values ('General_candy' , 'svsv1' , current_timestamp - interval 5 MONTH, 'Mh' , 'Mh' , 'Mh');

insert into Hub VALUES( 'Arezzo' , 'Brilli' , '34'  );
insert into Hub VALUES( 'Grosseto' , 'Trilli' , '32' );
insert into Hub VALUES(  'Lucca', 'Grilli' , '38'  );
insert into Hub VALUES(  'Pistoia', 'Vrilli' , '31' );
insert into Hub VALUES(  'Prato', 'Qrilli' , '44'  );
insert into Hub VALUES( 'Siena', 'Xrilli' , '34'   );
insert into Hub VALUES( 'Pisa', 'Crilli' , '32'   );
insert into Hub VALUES( 'Firenze', 'Frilli' , '38'   );
insert into Hub VALUES(  'Massa-Carrara', 'Arilli' , '31'  );
insert into Hub VALUES( 'Livorno', 'Prilli' , '44'  );


insert into centro_assistenza values ('Firenze' , 'Assistenzialisti' , 'Fix1'  );
insert into centro_assistenza values ('Pisa' , 'Riparazionisti' , 'a2'  );

insert into Scorte_CentroAssistenza
select 'Firenze' as Prov_centro_Assistenza , COD_Componente , 1000 as quantita
from componente
where cod_componente <> 1 and cod_componente <> 28;

insert into Scorte_CentroAssistenza
select 'Pisa'  as Prov_centro_Assistenza , COD_Componente , 1000 as quantita
from componente
where cod_componente <> 1 and cod_componente <> 28;


insert into veicolo values (null ,'FIAT' ,'Panda',15, '2008-03-05');
insert into veicolo values (null ,'FIAT' ,'Panda',15, '2012-03-05');
insert into veicolo values (null ,'Ford' ,'Raptor',50, '2009-05-14');
insert into veicolo values (null ,'Ford' ,'Raptor',50, '2010-05-03');
insert into veicolo values (null ,'FIAT' ,'Fiorino',2000,'2015-06-04');
insert into veicolo values (null ,'FIAT' ,'Fiorino',2000,'2014-06-04');

insert into Squadra values (null , 1 , 1 ,'Firenze'); 
insert into Squadra values (null , 3 , 2 ,'Firenze');
insert into Squadra values (null , 5 , 3 ,'Firenze');
insert into Squadra values (null , 2 , 1 ,'Pisa');
insert into Squadra values (null , 4 , 2 ,'Pisa');
insert into Squadra values (null , 6 , 3 ,'Pisa');

insert into Trasportatore values ('fsd5' ,'Leggeri' , 'Leggerini' , 'M', 'PocoDenso' ,'l4','Pisa',1 , '1987-05-07' , '2005-08-06' , 8 , 838564);
insert into Trasportatore values ('fsd6' , 'Medioni' , 'Medianti' , 'M', 'Denso' , 'm4','Pisa',2 ,'1970-05-07' , '2004-02-13' ,10 , 876565);
insert into Trasportatore values ('fsd7' , 'Medini' , 'Medianti' , 'M', 'Denso' , 'm5','Pisa',2 ,'1971-05-07' , '2004-02-05' , 10 , 176564);
insert into Trasportatore values ('fsd8' , 'Pesantoni' , 'Pesanti' , 'M', 'MoltoDenso' ,'p4','Pisa', 3 , '1984-01-10' , '2003-10-24' , 11 , 876343);
insert into Trasportatore values ('fsd9' ,'Pesantini' , 'Pesanti' , 'M', 'MoltoDenso' ,'p5','Pisa', 3 , '1985-07-15' , '2003-10-24' , 11 , 876233);
insert into Trasportatore values ('fsd2' ,  'Pesantelli', 'Pesanti', 'M' , 'MoltoDenso' ,'p6','Pisa', 3 , '1986-04-20' , '2003-10-24' , 11 , 876556);
insert into Trasportatore values ('xsd5' ,'Brandelli' , 'Logori' , 'M', 'PocoDenso' ,'l7','Pisa', 4 , '1980-05-07' , '2005-08-06' , 8 , 876512);
insert into Trasportatore values ('fxd6' , 'Brandellini' , 'Stracci' , 'M', 'Denso' , 'm9','Pisa',5 ,'1965-10-07' , '2001-02-13' ,10 , 876513);
insert into Trasportatore values ('fsx7' , 'Brandina' , 'Spaccato' , 'M', 'Denso' , 'm1','Pisa',5 ,'1981-05-07' , '2010-12-25' , 10 , 876514);
insert into Trasportatore values ('ysd8' , 'Titanelli' , 'Gigante' , 'M', 'MoltoDenso' ,'q4','Pisa', 6, '1970-01-10' , '2010-11-24' , 11 , 876515);
insert into Trasportatore values ('fyd9' ,'Titanone' , 'Gigante', 'M' , 'MoltoDenso' ,'q5','Pisa', 6 , '1935-12-14' , '2000-10-24' , 11, 876516);
insert into Trasportatore values ('fsy2' , 'Titanini', 'Gigante', 'M' , 'MoltoDenso' ,'q6','Pisa', 6 , '1971-04-04' , '2012-03-24' , 11, 876517);

 



insert into Tecnico values ('frf3' ,'Micio' , 'Gatto', 'M' , 'Felini' , 'D3'  , 'Grosseto' , '1980-05-03' , '2005-04-07',  10 , 'Desktop' , 'Firenze' , 0 , 876518);
insert into Tecnico values ('crc3' ,'Lupo' , 'Cane', 'M' , 'Canidi' , 'S3' , 'Grosseto' , '1985-06-19' , '2004-01-02', 11 , 'Desktop' , 'Firenze' , 0 , 876519);
insert into Tecnico values ('grt6' ,'Topo' , 'criceto', 'M' , 'Roditori' , 'r3'  , 'Grosseto' , '1977-04-11' , '2001-10-23', 15 , 'Desktop' , 'Pisa' , 0 , 876520);
insert into Tecnico values ('trp53' ,'Vitello' , 'Toro', 'M' , 'Mucca' , 'w3'  , 'Arezzo' , '1990-05-03' , '2013-04-07',  10 , 'Desktop' , 'Firenze' , 1 , 876521);
insert into Tecnico values ('cfg5' ,'Pappagalli' , 'Conifera', 'M' , 'Tropico' , 't3'  , 'Arezzo', '1960-10-13' , '2000-01-24', 16 , 'Desktop' , 'Firenze' , 1 , 876522);
insert into Tecnico values ('mprt' ,'Vitello' , 'Muflone' , 'M', 'Mucca' , 'w2' ,'Arezzo' , '1989-11-13' , '2013-04-07', 15 , 'Desktop' , 'Pisa' , 1 , 876523);

CALL Creazione_Ordine ('Diablus' , 'Vitale' , '58' , 'Firenze');
CALL Assegnazione_Prodotti_Ordine (1 , 'HP' , 'MegaPC' , 1);
CALL Check_Fine_Pendenza (1);

CALL Creazione_Ordine ('Cucciolotta' ,  'Chi' , 'SaiTu', 'Lucca');
CALL Assegnazione_Prodotti_Ordine (2 , 'HP' , 'MegaPC' , 2);
CALL Check_Fine_Pendenza (2);

CALL Creazione_Ordine ('Diablus' , 'Vitale' , '58' , 'Firenze');
CALL Assegnazione_Prodotti_Ordine (3 , 'HP' , 'MegaPC' , 30);
CALL Check_Fine_Pendenza (3);

insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0); insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);
insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0); 
insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);insert into Prodotto values(null , 1 , 0 , 0);


call switch_stato_ordine (1);
call switch_stato_ordine (1);
call Passaggio_Spedizione_Hub(1 , 'Firenze');
call switch_stato_ordine (1);

call switch_stato_ordine (2);
call switch_stato_ordine (2);
call switch_stato_ordine (2);
call Passaggio_Spedizione_Hub(2 , 'Lucca');
call switch_stato_ordine (2);



call Recensisci_Oggetto(2 , 'HP' , 'MegaPC' , 3 , 2 , 1 , 2 , "Non mi è piaciuto...PER NULLA! :( ");
call Recensisci_Oggetto(2 , 'HP' , 'MegaPC' , 3 , 2 , 3 , 3 , "Mh no dai forse non è cosi male ");
call Recensisci_Oggetto(2 , 'HP' , 'MegaPC' , 3 , 3, 3 , 3 , "Mh si dai è decente ");
call Recensisci_Oggetto(2 , 'HP' , 'MegaPC' , 4 ,4 , 4 , 4 , "Invece  è molto carino ");
call Recensisci_Oggetto(2 , 'HP' , 'MegaPC' , 5 , 4 , 5 , 5 , "Vale i soldi spesi! ");
call Recensisci_Oggetto(2 , 'HP' , 'MegaPC' , 1 , 1 , 1 , 1 , "NO");



set @a = (select sleep(2));
call Unita_In_produzione_Creata(2);

call  Avvia_Produzione_Lotto( 1 ,1 , 1, current_date , current_date + interval 1 day ,6 , 9 , 13);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);
call Unita_In_produzione_Creata(3);

insert into Motivazioni_reso VALUES('Diritto di Recesso' , NULL);
insert into Motivazioni_reso VALUES('Prestazioni Insufficienti' , 'Il prodotto non ha soddisfatto le mie aspettative riguardo le prestazioni');
insert into Motivazioni_reso VALUES('Design Brutto' , 'Il prodotto non soddisfa i miei gusti');

call Inserimento_Radice_Tree_Test ('HP' , 'MegaPC' , 'Prova Scheda Madre' , 5 , 1);
call inserimento_nodo_tree_test ('HP' , 'MegaPC' ,(select COD_Nodo from radice_tree_test where Marca = 'HP' and Modello = 'MegaPC'), 'Prova Memorie' , 33 , 1);
call inserimento_nodo_tree_test ('HP' , 'MegaPC' ,(select COD_Nodo from nodo_tree_test where COD_Padre = (select COD_Nodo from radice_tree_test where Marca = 'HP' and Modello = 'MegaPC')), 'Testa RAM' , 7 , 1);
call inserimento_nodo_tree_test ('HP' , 'MegaPC' ,(select COD_Nodo from nodo_tree_test where COD_Padre = (select COD_Nodo from radice_tree_test where Marca = 'HP' and Modello = 'MegaPC')), 'Testa Hard Disk' , 29 , 1);
call inserimento_nodo_tree_test ('HP' , 'MegaPC' ,(select COD_Nodo from radice_tree_test where Marca = 'HP' and Modello = 'MegaPC'), 'Prova CPU' , 19 , 1);
call inserimento_nodo_tree_test ('HP' , 'MegaPC' ,(select COD_Nodo from radice_tree_test where Marca = 'HP' and Modello = 'MegaPC'), 'Ispeziona Case' , 8 , 1);

call Bilancia_pesi('HP' , 'MegaPC'); -- Occorre sempre chiamare questa funzionalità dopo aver effettuato alcune modifche dell albero
call TestTree('HP' , 'MegaPC'); -- Si aggiorna il test tree di un determinato oggetto




call switch_stato_ordine (3);
call switch_stato_ordine (3);
call Passaggio_Spedizione_Hub(3 , 'Firenze');
call switch_stato_ordine (3);
call switch_stato_ordine (3);


call Invio_Richiesta_Di_reso(2 , 'Cucciolotta' , 'Design Brutto');
call Invio_Richiesta_Di_reso(3 , 'Cucciolotta' , 'Diritto di Recesso');

call Invio_Richiesta_Di_reso(4 , 'Diablus' , 'Diritto di Recesso');
call Invio_Richiesta_Di_reso(5 , 'Diablus'  , 'Diritto di Recesso');
call Invio_Richiesta_Di_reso(6 , 'Diablus'  , 'Diritto di Recesso');
call Invio_Richiesta_Di_reso(7 , 'Diablus'  , 'Diritto di Recesso');

call Inserimento_Reso(3 ,4 , 1 , 6, 9, 5);
call Inserimento_Reso(4 ,4 , 1 , 6, 9, 5);
call Inserimento_Reso(5 ,4 , 1 , 6, 9, 5);
call Inserimento_Reso(6 ,4 , 1 , 6, 9, 5);
call Inserimento_Reso(7 ,4 , 1 , 6, 9, 5); 

call Invio_Richiesta_Di_reso(8 , 'Diablus'  , 'Diritto di Recesso');
call Invio_Richiesta_Di_reso(9 , 'Diablus'  , 'Diritto di Recesso');
call Inserimento_Reso(8 ,4 , 1 , 6, 9, 20);
call Inserimento_Reso(9 ,4 , 1 , 6, 9, 20);

call Invio_Richiesta_Di_reso(10 , 'Diablus'  , 'Diritto di Recesso');
call Invio_Richiesta_Di_reso(11 , 'Diablus'  , 'Diritto di Recesso');
call Inserimento_Reso(10  ,5 , 1 , 6, 10, 20);
call Inserimento_Reso(11  ,5 , 1 , 6, 10, 20);

call Inizia_Ricondizionamento_Lotto_Reso(1);
set @r = (select cod_nodo from radice_tree_test where marca = 'HP' and Modello = 'MegaPC');

call Inizio_Ricondizionamento_Reso(3, 1, 10 , 10 , 10 , 0.5);
call Esito_Nodo(@r , 1);
call Concludi_Test_tree_reso(3);

call Inizio_Ricondizionamento_Reso(4, 1, 2 , 1 , 1, 0.5);
call Esito_Nodo(@r , 0);
call Esito_Nodo (@r + 1 , 0);
call Esito_Nodo (@r + 4,  1);
call Esito_Nodo(@r + 5 , 1);
call Esito_Nodo (@r + 2 , 1);
call Esito_Nodo (@r + 3 , 1);
call Concludi_Test_tree_reso(4);

call Inizio_Ricondizionamento_Reso(5, 1,1 , 2 ,1, 0.5);
call Esito_Nodo (@r , 0);
call Esito_Nodo (@r + 1 , 1);
call Esito_Nodo (@r + 4,  0);
call Esito_Nodo(@r + 5 , 0);
call Concludi_Test_tree_reso(5);


call Inizio_Ricondizionamento_Reso(6, 1, 1 , 1, 2 , 0.5);
call Esito_Nodo (@r , 0);
call Esito_Nodo (@r + 1 , 0);
call Esito_Nodo (@r + 4,  1);
call Esito_Nodo (@r + 5,  1);
call Esito_Nodo (@r + 2 , 0);


call Concludi_Test_tree_reso(6);

call Inizio_Ricondizionamento_Reso(7, 1, 3 , 1 , 1, 0.5);
call Esito_Nodo (@r , 0);
call Esito_Nodo (@r + 1 , 1);
call Esito_Nodo (@r + 4,  1);
call Esito_Nodo (@r + 5,  0);

call Concludi_Test_tree_reso(7);



CALL Creazione_Ordine ('Diablus' , 'Vitale' , '58' , 'Firenze');
CALL Assegnazione_Prodotti_Ordine (4, 'HP' , 'MegaPC' , 2);
CALL Assegnazione_Specifico_Prodotto_Ordine( 4 , 63);
CALL Assegnazione_Specifico_Prodotto_Ordine( 4 , 61);
CALL Check_Fine_Pendenza(4);

call Switch_Stato_Ordine(4);
call Switch_Stato_Ordine(4);
call Switch_Stato_Ordine(4);

call Prodotto_Guastato(1 , 1);
call Prodotto_Guastato(1 , 4);

call Prodotto_Guastato(12 , 1);
call Prodotto_Guastato(13 , 1);
call Prodotto_Guastato(13 , 6);
call Prodotto_Guastato(14 , 1);

call Prodotto_Guastato(15 , 6);
call Prodotto_Guastato(16 , 6);

call Guasto_Rimediato( 1 , 1 , current_date , 3);
call Guasto_Rimediato( 1 , 4 , current_date , 4);
call Guasto_Rimediato( 12, 1 , current_date , 3);
call Guasto_Rimediato( 13, 1 , current_date , 3);

call Guasto_Rimediato( 13, 6 , current_date , 6);
call Guasto_Rimediato( 14, 1 , current_date , 2);
call Guasto_Rimediato( 15, 6 , current_date , 7);
call Guasto_Rimediato( 16, 6 , current_date , 6);

call Refresh_MV_resoconto_Mensile_Proc();


insert into richiesta_intervento values (1 , 0 , current_date - interval 2 day, 'Diablus' ,'cfg5' , current_timestamp - interval 3 day,'HP' , 'MegaPC', 'Vitale' , '58'  ,'Firenze' ,2, null);
insert into richiesta_intervento values (2 , 0 , current_date , 'Diablus' ,'cfg5' , current_timestamp - interval 1 day,'HP' , 'MegaPC', 'Vitale' , '58' ,'Firenze' ,1, null );
insert into richiesta_intervento values (3 , 0 , current_date , 'Diablus' ,'trp53' , current_timestamp - interval 1 day,'HP' , 'MegaPC', 'Vitale' , '58'  ,'Firenze' ,2, null );

insert into richiesta_intervento values (4 , 0 , current_date - interval 3 day , 'Diablus' ,'trp53' , current_timestamp - interval 3 day,'HP' , 'MegaPC', 'Vitale' , '58'  , 'Firenze' ,2, 60 );
insert into prodotto_guasto values (21 , 2 ,current_date - interval 3 day , 0 );
insert into prodotto_guasto values (21 , 3 ,current_date - interval 3 day , 0 );
insert into riparazione values(   4 , 2, 30);
insert into riparazione values(   4 , 3, 30);
insert into ordine_pezzi_af values (1 , 2 , 4 , current_timestamp - interval 3 day);
insert into ordine_pezzi_af values (2 , 3 , 4 , current_timestamp - interval 3 day);
insert into preventivo values (4 , 21 , 100 , current_date - interval 3 day , 1 , 1 , 0 );
insert into ordine_pezzi_af_componente values( 1 , 21 , 1);
insert into ordine_pezzi_af_componente values( 2 , 7 ,  1);
insert into richiesta_intervento values (4 ,1 , current_date - interval 2 day , 'Diablus' ,'trp53' , current_timestamp - interval 2 day,'HP' , 'MegaPC', 'Vitale' , '58' , 'Firenze' ,2, 60 );
call Concludi_Intervento_Domicilio(4 , 'Carta');


call Update_MV_Resoconto_Ordini_Giornaliero();

call Prodotto_Guastato(26 , 1);
call retrieve("1;2" , 'Desktop');
call reuse_();
 
call revise(2);
call Revise_Inserisci_Sezione(1 , 'Prova1;');
call Revise_Inserisci_Sezione(4 , 'Prova2;');
call Revise_elimina_Sezione(4);

call revise(3);
call Revise_Inserisci_Sezione(1 , 'Prova3;');

call retain_(2 , 1 , 26);

call Prenota_Trasporto (3 , '2021-04-06' , 2);
call esegui_diagnosi (3, 1, 30 , "2;3;"); 
call inserisci_preventivo ( 1 ,3 , 70 , 1 , 1 , 1);

call Assegna_Prodotto_AF(1 ,  'crc3');
call Intervento_Riparazione_Guasto(1 , 2 , 20);
call Intervento_Riparazione_Guasto(1 , 3 , 40);
call Esegui_Ordine_Pezzi_Af(3, 21 , 1);
call Esegui_Ordine_Pezzi_Af(4, 7 , 2);
call Concludi_Intervento_Azienda(1 , 'Carta');

call Update_MV_Resoconto_Settimanale();
call Update_MV_Resoconto_Ordini_Giornaliero();


call Inserimento_Richiesta_Intervento_DOM('diablus' , 'HP' , 'MegaPC' , current_date + interval 3 day , 1 , 'Vitale' , '58' , 'Grosseto');

call Avvia_Produzione_Lotto( 1 , 1 , 1 , current_date , current_date + interval 2 day , 43 , 5 , 7);
call Unita_In_produzione_Creata(8);
call Unita_In_produzione_Creata(8);

call Unita_In_produzione_Creata(8);
call Unita_In_produzione_Creata(8);
call Unita_In_produzione_Creata(8);
call Unita_In_produzione_Creata(8);

call inserimento_pezzo_incompleto( 8 , 5);
set @a = (select sleep(1));
call inserimento_pezzo_incompleto( 8 , 4);
set @a = (select sleep(1));
call inserimento_pezzo_incompleto( 8 , 13);
insert into StoricoDeiLotti_Attuali values(8 , current_timestamp + interval 1 second, 'Guasto al motore del nastro' , 'Motore del nastro rotto' , 1440);

call Refresh_MV_Monitor_Lotti_Proc();
call Refresh_On_Dem_MV_Monitor_Sequenze();



