/*
-- Create test views
*/
CREATE VIEW dbo.vwReadSelectOne
AS
-- This is auto-generated code
select 1 AS ImportantData; 

CREATE VIEW dbo.vwReadSelectTwo
AS
-- This is auto-generated code
select 2 AS ImportantData; 

CREATE VIEW dbo.vwReadSelectThree
AS
-- This is auto-generated code
select 3 AS ImportantData; 

/*
-- Test views
*/
-- Test
select * 
from dbo.vwReadSelectOne

select * 
from dbo.vwReadSelectTwo

select * 
from dbo.vwReadSelectThree

/*
-- Create test user
*/
-- Create login
CREATE LOGIN viewtestuser WITH PASSWORD = '<pwd>';
-- Create user on DB
CREATE USER viewtestuser FROM LOGIN viewtestuser;

/*
-- Test 1 - Grant to one view specifically on the user
*/
-- Grant SELECT on the view dbo.vwReadSelectOne
GRANT SELECT ON dbo.vwReadSelectOne TO viewtestuser;

-- GRANT ALTER on the view dbo.vwReadSelectOne
GRANT ALTER ON dbo.vwReadSelectOne TO viewtestuser;

/*
-- Test 2 - Create role and apply permissions
*/
-- Create the role
CREATE ROLE ViewAlterRole;

-- Grant ALTER permission on each view to the role
GRANT ALTER ON dbo.vwReadSelectOne TO ViewAlterRole;
GRANT ALTER ON dbo.vwReadSelectTwo TO ViewAlterRole;
GRANT ALTER ON dbo.vwReadSelectThree TO ViewAlterRole;

-- Step 3: (Optional) Add a user to the role
ALTER ROLE ViewAlterRole ADD MEMBER viewtestuser;


/****
--- Scripts to test under a connection with viewtestuser
****/
select * 
from dbo.vwReadSelectOne

-- Test changing the view
ALTER VIEW dbo.vwReadSelectOne
AS
SELECT 1 as ImportantData, 11 AS EvenMoreImportantData

-- Cannot drop the view 'vwReadSelectOne', because it does not exist or you do not have permission.
DROP VIEW dbo.vwReadSelectOne;

ALTER VIEW dbo.vwReadSelectTwo
AS
SELECT 2 as ImportantData, 22 AS EvenMoreImportantData

ALTER VIEW dbo.vwReadSelectThree
AS
SELECT 3 as ImportantData, 33 AS EvenMoreImportantData

-- Not possible
DROP VIEW dbo.vwReadSelectOne;
DROP VIEW dbo.vwReadSelectTwo;
DROP VIEW dbo.vwReadSelectThree;
