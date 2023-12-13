------------------------------------------------------------------------------
-- 1. Create table with sparse columns and COLUMN_SET [SpecialPurposeColumns]
------------------------------------------------------------------------------
CREATE TABLE DocumentStoreWithColumnSet
    (DocID int PRIMARY KEY,
     Title varchar(200) NOT NULL,
     ProductionSpecification varchar(20) SPARSE NULL,
     ProductionLocation smallint SPARSE NULL,
     MarketingSurveyGroup varchar(20) SPARSE NULL,
     MarketingProgramID int SPARSE NULL,
     EditorialReviewStatus varchar(50) SPARSE NULL,  -- New sparse column for editorial review status
     DistributionRegionCode int SPARSE NULL,         -- New sparse column for distribution region code
     DigitalAssetManagementTag varchar(100) SPARSE NULL, -- New sparse column for digital asset management tags
     SpecialPurposeColumns XML COLUMN_SET FOR ALL_SPARSE_COLUMNS);
GO


--
-- Insert different combinations
INSERT INTO dbo.DocumentStoreWithColumnSet 
    (DocID, Title, ProductionSpecification, ProductionLocation, MarketingSurveyGroup, EditorialReviewStatus)
VALUES 
    (1, 'Document Title 1', 'Spec A', 101, 'Survey Group A', 'Pending');

-- Insert where different sparse columns are filled
INSERT INTO dbo.DocumentStoreWithColumnSet 
    (DocID, Title, MarketingProgramID, DistributionRegionCode, DigitalAssetManagementTag)
VALUES 
    (2, 'Document Title 2', 2001, 5, 'Tag123');

-- Insert where all sparse columns are null
INSERT INTO dbo.DocumentStoreWithColumnSet 
    (DocID, Title)
VALUES 
    (3, 'Document Title 3');

-- Insert where a mix of sparse columns are filled
INSERT INTO dbo.DocumentStoreWithColumnSet 
    (DocID, Title, ProductionLocation, MarketingProgramID, EditorialReviewStatus, DigitalAssetManagementTag)
VALUES 
    (4, 'Document Title 4', 102, 2002, 'Approved', 'Tag456');

-- Insert where another different combination of sparse columns are filled
INSERT INTO dbo.DocumentStoreWithColumnSet 
    (DocID, Title, ProductionSpecification, MarketingSurveyGroup, DistributionRegionCode)
VALUES 
    (5, 'Document Title 5', 'Spec B', 'Survey Group B', 10);

	
--
-- Casually review data.
SELECT
	*
FROM 
	dbo.DocumentStoreWithColumnSet

-- 
-- Casually review data.
SELECT
	DocID, Title, ProductionSpecification, MarketingSurveyGroup, DistributionRegionCode
FROM 
	dbo.DocumentStoreWithColumnSet


-- 
-- Insert the same data in XML-format through the COLUMN_SET column

-- Insert using XML column set where some sparse columns are filled
INSERT INTO DocumentStoreWithColumnSet 
    (DocID, Title, SpecialPurposeColumns)
VALUES 
    (6, 'Document Title 6', '<ProductionSpecification>Spec A</ProductionSpecification><ProductionLocation>101</ProductionLocation><MarketingSurveyGroup>Survey Group A</MarketingSurveyGroup><EditorialReviewStatus>Pending</EditorialReviewStatus>');

-- Insert using XML column set where different sparse columns are filled
INSERT INTO DocumentStoreWithColumnSet 
    (DocID, Title, SpecialPurposeColumns)
VALUES 
    (7, 'Document Title 7', '<MarketingProgramID>2001</MarketingProgramID><DistributionRegionCode>5</DistributionRegionCode><DigitalAssetManagementTag>Tag123</DigitalAssetManagementTag>');

-- Insert using XML column set where all sparse columns are null
INSERT INTO DocumentStoreWithColumnSet 
    (DocID, Title, SpecialPurposeColumns)
VALUES 
    (8, 'Document Title 8', NULL);

-- Insert using XML column set where a mix of sparse columns are filled
INSERT INTO DocumentStoreWithColumnSet 
    (DocID, Title, SpecialPurposeColumns)
VALUES 
    (9, 'Document Title 9', '<ProductionLocation>102</ProductionLocation><MarketingProgramID>2002</MarketingProgramID><EditorialReviewStatus>Approved</EditorialReviewStatus><DigitalAssetManagementTag>Tag456</DigitalAssetManagementTag>');

-- Insert using XML column set where another different combination of sparse columns are filled
INSERT INTO DocumentStoreWithColumnSet 
    (DocID, Title, SpecialPurposeColumns)
VALUES 
    (10, 'Document Title 10', '<ProductionSpecification>Spec B</ProductionSpecification><MarketingSurveyGroup>Survey Group B</MarketingSurveyGroup><DistributionRegionCode>10</DistributionRegionCode>');

--
-- Casually review data.
SELECT
	*
FROM 
	dbo.DocumentStoreWithColumnSet;

-- 
-- Casually review data.
SELECT
	DocID, Title, ProductionSpecification, MarketingSurveyGroup, DistributionRegionCode
FROM 
	dbo.DocumentStoreWithColumnSet;

--
-- Columns?
SELECT *
FROM sys.tables as t
INNER JOIN sys.columns as c 
on t.object_id = c.object_id
WHERE t.name = 'DocumentStoreWithColumnSet_COPY';


------------------------------------------------------------------------
-- 2. Create COPY table
------------------------------------------------------------------------
CREATE TABLE DocumentStoreWithColumnSet_COPY
    (DocID int PRIMARY KEY,
     Title varchar(200) NOT NULL,
     ProductionSpecification varchar(20) SPARSE NULL,
     ProductionLocation smallint SPARSE NULL,
     MarketingSurveyGroup varchar(20) SPARSE NULL,
     MarketingProgramID int SPARSE NULL,
     EditorialReviewStatus varchar(50) SPARSE NULL,  -- New sparse column for editorial review status
     DistributionRegionCode int SPARSE NULL,         -- New sparse column for distribution region code
     DigitalAssetManagementTag varchar(100) SPARSE NULL, -- New sparse column for digital asset management tags
     SpecialPurposeColumns XML COLUMN_SET FOR ALL_SPARSE_COLUMNS);
GO


--
-- Copy a subset of the table
INSERT INTO DocumentStoreWithColumnSet_COPY
    (DocID, Title, SpecialPurposeColumns)
SELECT 
    DocID, Title, SpecialPurposeColumns
FROM 
    DocumentStoreWithColumnSet;

--
-- Casually review data.
SELECT
	*
FROM 
	dbo.DocumentStoreWithColumnSet_COPY;

-- 
-- Casually review data.
SELECT
	DocID, Title, ProductionSpecification, MarketingSurveyGroup, DistributionRegionCode
FROM 
	dbo.DocumentStoreWithColumnSet_COPY;


------------------------------------------------------------------------
-- 3. SELECT INTO - Warning, doesn't take the Column Set and Sparse columns
------------------------------------------------------------------------
SELECT *
INTO DocumentStoreWithColumnSet_INTOCOPY
FROM DocumentStoreWithColumnSet;

-- 
-- 
SELECT DocID, Title, ProductionSpecification, ProductionLocation, MarketingSurveyGroup
FROM DocumentStoreWithColumnSet_INTOCOPY

--
-- Columns?
SELECT *
FROM sys.tables as t
INNER JOIN sys.columns as c 
on t.object_id = c.object_id
WHERE t.name = 'DocumentStoreWithColumnSet_INTOCOPY';