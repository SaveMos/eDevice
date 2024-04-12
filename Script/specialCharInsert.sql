-- # Inserito
-- * Modificato
-- ç Eliminato
set @str = "op0;op1;op2;op4;op5;op6;op7;op8;op9;op10;op11;op12";
CALL Conta_Separatori(@str , ';' , @num);
 set @str1 = SUBSTRING_INDEX(@str, ';', 5);
 set @str2 = SUBSTRING_INDEX(@str, ';', 5 - (@num +1));
 set @str3 =CONCAT(@str1 ,";" , "#" , ";", @str2);
 -- select SUBSTRING_INDEX(@str, ';', 5) as f1 , SUBSTRING_INDEX(@str, ';', 5 - (@num +1)) as f2;
 -- select @str3;
