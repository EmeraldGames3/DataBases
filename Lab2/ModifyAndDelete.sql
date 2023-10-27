USE COMPUTER_STORE

SELECT * FROM OperatingSystem;

-- Add some operating systems
INSERT INTO OperatingSystem (os_ID, os_name, os_version)
VALUES
    (4, 'Windows', '10'),
    (5, 'Mac OS', 'Catalina'),
    (6, 'Linux', 'Ubuntu 20.04'),
    (7, 'Windows', '8'),
    (8, 'Windows', '7'),
	(9, 'Windows', NULL),
	(10, 'Windows', '12'),
    (11, 'Linux', 'Mint 22'),
    (12, 'Mac OS', 'Catalina 2');

SELECT * FROM OperatingSystem;

-- Modify data using BETWEEN
UPDATE OperatingSystem
SET os_version = 'Windows 22'
WHERE os_name = 'Windows' 
AND os_version BETWEEN '0' AND '9' 
AND os_version NOT LIKE '1%'

-- Modify data using LIKE
UPDATE OperatingSystem
SET os_version = 'Big Sur'
WHERE os_version LIKE 'C%';

-- Modify data using IN
UPDATE OperatingSystem
SET os_version = 'Fedora 36'
WHERE os_version IN ('Ubuntu 20.04');

-- Modify Data Using IN
UPDATE OperatingSystem
SET os_version = 'Windows 24'
WHERE os_name = 'Windows'
AND os_version IN ('12', '10', '7');

-- Modify Data Using LIKE
UPDATE OperatingSystem
SET os_version = 'Big Sur'
WHERE os_version LIKE 'Mint%';

-- Modify Data Using IS NULL
UPDATE OperatingSystem
SET os_version = 'Puma'
WHERE os_version IS NULL;

-- Delete new data using LIKE condition
DELETE FROM OperatingSystem
WHERE os_version LIKE 'Windows%';

-- Delete new data using an IN condition
DELETE FROM OperatingSystem
WHERE os_version IN ('Cheetah', 'Catalina', 'Fedora 36', 'Ubuntu 20.04', 'Mint 22', 'Puma', 'Big Sur')

-- Show the final OperatingSystem table after modifications and deletions
SELECT * FROM OperatingSystem;