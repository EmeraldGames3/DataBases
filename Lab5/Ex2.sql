USE Lab5;
GO

--a
EXEC sys.sp_helpindex @objname = N'Ta';

--clustered index scan
SELECT * FROM Ta WHERE a2 > 2000 ORDER BY idA DESC;
--clustered index seek
SELECT * FROM Ta WHERE idA BETWEEN 1200 AND 5000;
--nonclustered index scan
SELECT idA, a2 FROM Ta ORDER BY a2;
--nonclustered index seek
SELECT idA, a2 FROM Ta WHERE a2 >= 500 AND a2 <= 1000;

--b
CREATE NONCLUSTERED INDEX I_a3 ON Ta(a3);
DROP INDEX Ta.I_a3

-- nonclustered index seek with key look up
SELECT * FROM Ta WHERE a3 BETWEEN 100 AND 110;

--c
SELECT * FROM Tb WHERE b2 = 500;

CREATE NONCLUSTERED INDEX I_b2 ON Tb(b2) INCLUDE (b3);
DROP INDEX Tb.I_b2

--d
SELECT Tc.idC, Ta.a2, Ta.a3
FROM Tc
JOIN Ta ON Tc.idA = Ta.idA
WHERE Tc.idA = 682

SELECT Tc.idC, Tb.b2
FROM Tc
JOIN Tb ON Tc.idB = Tb.idB
WHERE Tc.idB = 1713

CREATE NONCLUSTERED INDEX I_idA ON Tc(idA)
CREATE NONCLUSTERED INDEX I_idB ON Tc(idB)

DROP INDEX Tc.I_idA
DROP INDEX Tc.I_idB