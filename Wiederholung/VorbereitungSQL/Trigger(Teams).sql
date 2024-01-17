use test
go

create table StudentenNew2( id int primary key, Nachname varchar(50), Vorname varchar(50), geburtsDatum date, email varchar(50))

insert into StudentenNew2 values
(1, 'Popa','Dumitru', '1980-3-4', 'dumitru@gmail.com'),
(2, 'Tanase', 'Alexandra', '2000-1-1','alexandra@yahoo.com')

insert into StudentenNew2 values
(2, 'Tanase', 'Alexandra', '2000-1-1','alexandra@yahoo.com')

delete from StudentenNew2 
where id = 1

select * from StudentenNew2



--integrity constraint auf Geburtsdatum
alter table StudentenNew2
add constraint gebDatumConstraint 
check (geburtsDatum between '1990-1-1' and '2002-1-1') 

insert into StudentenNew2 values (3, 'Tarnu', 'Andrei', '1970-1-1','andrei@yahoo.com')


--lösche integrity constraint
alter table StudentenNew2 drop constraint gebDatumConstraint

-----------------------------------------------------------------------------------
--trigger - version 1 - raiseerror
create trigger insertStudenten on StudentenNew2
for insert
as
begin
IF EXISTS (SELECT *
           FROM StudentenNew2 
		   WHERE geburtsDatum < '1990-1-1' OR geburtsDatum > '2002-1-1' 
           )
BEGIN
RAISERROR ('Falsche Geburtsdatum', 16, 1);
end
end

drop trigger insertStudenten 

insert into StudentenNew2 values (3, 'Tarnu', 'Andrei', '1970-1-1','andrei@yahoo.com')
insert into StudentenNew2 values (11, 'Tarnu', 'Andrei', '1991-1-1','andrei@yahoo.com')
--wurde das Tupel eingefügt?
select * from StudentenNew2



delete from StudentenNew2 where id=3 or id =11

-----------------------------------------------------------------------------------
--version 2 - insert, check, delete
create trigger insertStudenten on StudentenNew2
after insert
as
begin
IF EXISTS (SELECT *
           FROM StudentenNew2 
		   WHERE geburtsDatum < '1990-1-1' OR geburtsDatum > '2002-1-1' 
           )
BEGIN
	delete from StudentenNew2 where geburtsDatum < '1990-1-1' OR geburtsDatum > '2002-1-1'
	RAISERROR ('Falsche Geburtsdatum', 16, 1);
end
end


drop trigger insertStudenten 

insert into StudentenNew2 values (35, 'Tarnu', 'Andrei', '1970-1-1','andrei@yahoo.com')
--wurde das Tupel eingefügt?
select * from StudentenNew2

insert into StudentenNew2 values (3, 'Popa','Dumitru', '1980-3-4', 'dumitru@gmail.com'),
								(4, 'Popescu','Ana', '2001-3-4', 'ana@gmail.com')

select * from StudentenNew2


-----------------------------------------------------------------------------------
--version 3 - just check, 
create trigger insertStudenten on StudentenNew2
instead of insert
as
begin
IF EXISTS (SELECT *
           FROM StudentenNew2 
		   WHERE geburtsDatum < '1990-1-1' OR geburtsDatum > '2002-1-1' 
           )
BEGIN
RAISERROR ('Falsche Geburtsdatum', 16, 1);
end
end


drop trigger insertStudenten 

insert into StudentenNew2 values (5, 'Matei','Laura', '2000-3-4', 'laura@gmail.com'),
								(6, 'Sandu','Ana', '1970-3-4', 'anas@gmail.com')

insert into StudentenNew2 values (5, 'Matei','Laura', '2000-3-4', 'laura@gmail.com')

--wurde das Tupel eingefügt?
select * from StudentenNew2 

-----------------------------------------------------------------------------------

--version 4 -  check, insert if ok
create trigger insertStudenten on StudentenNew2
instead of insert
as
begin
IF EXISTS (SELECT *
           FROM inserted 
		   WHERE geburtsDatum < '1990-1-1' OR geburtsDatum > '2002-1-1'
           )
	RAISERROR ('Falsche Geburtsdatum', 16, 1);
else 
	insert into StudentenNew2
	select * from inserted

end


drop trigger insertStudenten 

insert into StudentenNew2 values (6, 'Matei','Laura', '1800-3-4', 'laura@gmail.com')

insert into StudentenNew2 values (6, 'Matei','Laura', '2000-3-4', 'laura@gmail.com'),
								(7, 'Sandu','Ana', '1970-3-4', 'anas@gmail.com')

insert into StudentenNew2 values (5, 'Matei','Laura', '2000-3-4', 'laura@gmail.com')
								
--wurde das Tupel eingefügt?
select * from StudentenNew2



-------------------------------------------------
--trigger - version 5 - raiseerror
create trigger insertStudenten on StudentenNew2
after insert
as
begin
IF EXISTS (SELECT *
           FROM StudentenNew2 
		   WHERE geburtsDatum < '1990-1-1' OR geburtsDatum > '2002-1-1'
           )
BEGIN
RAISERROR ('Falsche Geburtsdatum', 16, 1);
rollback
end
end

drop trigger insertStudenten 

insert into StudentenNew2 values (7, 'Fane','Sabina', '1999-3-4', 'sabina@gmail.com'),
								(8, 'Maris','Ana', '1950-3-4', 'anam@gmail.com')
								
--wurde das Tupel eingefügt?
select * from StudentenNew2


insert into StudentenNew2 values (7, 'Fane','Sabina', '1999-3-4', 'sabina@gmail.com')
--wurde das Tupel eingefügt?
select * from StudentenNew2


delete from StudentenNew2 where matrNr = 8

--------------------------------------------
create trigger insertStudenten on StudentenNew2
instead of insert
as
begin
		   insert into StudentenNew2 
		   select * from inserted
		   WHERE geburtsDatum >= '1990-1-1' AND geburtsDatum <= '2002-1-1' 
       
end

drop trigger insertStudenten 
delete from StudentenNew2 where MatrNr=10
insert into StudentenNew2 values (9, 'Dan','Mirela', '1998-3-4', 'mirela@gmail.com'),
								(10, 'Ban','Stefan', '1950-3-4', 'stefan@gmail.com')
	
--wurde das Tupel eingefügt?
select * from StudentenNew2




