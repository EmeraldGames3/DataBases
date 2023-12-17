USE Lab5;
GO

EXEC sys.sp_helpindex @objname = N'Ta' 
EXEC sys.sp_helpindex @objname = N'Tb' 
EXEC sys.sp_helpindex @objname = N'Tc' 

EXEC sys.sp_helpindex @objname = N'Ta' 

CREATE NONCLUSTERED INDEX IX_a3 ON Ta(a3);
DROP INDEX Ta.IX_a3

SELECT a2 FROM Ta WHERE a2  >= 1000						    --nonclustered index seek

SELECT * FROM Ta WHERE idA <= 2000      					--clustered index seek

SELECT a2 FROM Ta WHERE a2 >= 10000 ORDER BY idA DESC       --clustered index scan

SELECT idA, a2 FROM Ta ORDER BY a2 DESC                     --nonclustered index scan


--b)

SELECT a3 FROM Ta WHERE a2 = 1000                           --key lookup, because index for a2 doesn't include attribute a3 so it has to fetch the additional info
															--from the clustered index or from the base table

--c)

SELECT idB FROM Tb WHERE b2 = 330
--without nonclustered index on b2 : used a clustered index scan, estimated subtree cost (esc): 0.0117672
--with nonclustered index on b2 : used nonclustered index seek, esc: 0.0032831

CREATE NONCLUSTERED INDEX IX_b2 ON Tb(b2) WHERE b2 < 500;
DROP INDEX Tb.IX_b2

--d)

SELECT Tc.idC, Ta.a2, Ta.a3
FROM Tc
JOIN Ta ON Tc.idA = Ta.idA
WHERE Tc.idA = 200

--it does a nested loop because the query joins a smaller table with a larger table (Ta contains 10k entries, Tc contains 30k entries)
--it performs the outer loop, which is reprsented by the smaller table first, and then goes and performs the larger table, which is represented by the larger table

--without foreign key index it performs a combination of both a clustered index scan and a clustered index seek.
--    clustered index scan is used to retreive all columns from the Tc table when joining it with the Ta table, esc: 0.093319
--    clustered index seek is used to find the rows that match the condition in the where clause, esc: 0.0032831

--with foreign key index it performs a combination of both a clustered index seek and a nonclustered index seek and it helps the performance because now it can only
--retrieve the rows that are relevant for the query
--    esc for clustered index seek: 0.0032831
--    esc for nonclustered index seek: 0.0032853

SELECT Tc.idC, Tb.b2
FROM Tc
JOIN Tb ON Tc.idB = Tb.idB
WHERE Tc.idB = 12069

--without foreign key index it performs a combination of both a clustered index scan and a clustered index seek.
--    clustered index scan is used to retreive all columns from the Tc table when joining it with the Ta table, esc: 0.093319
--    clustered index seek is used to find the rows that match the condition in the where clause, esc: 0.0032831

--with foreign key index it performs a combination of both a clustered index seek and a nonclustered index seek and it helps the performance because now it can only
--retrieve the rows that are relevant for the query
--    esc for clustered index seek: 0.0032831
--    esc for nonclustered index seek: 0.003293

CREATE NONCLUSTERED INDEX IX_idA ON Tc(idA)
CREATE NONCLUSTERED INDEX IX_idB ON Tc(idB)

DROP INDEX Tc.IX_idA
DROP INDEX Tc.IX_idB