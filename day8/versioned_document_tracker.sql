CREATE TABLE Documents (
    document_id INT PRIMARY KEY,
    document_name VARCHAR(255),
    created_at TIMESTAMP,
    modified_at TIMESTAMP
);
CREATE TABLE Document_Versions (
    version_id INT PRIMARY KEY,
    document_id INT,
    version_number INT,  -- e.g., v1, v2, v3, etc.
    content TEXT,  -- Version-specific content of the document
    created_at TIMESTAMP,
    modified_at TIMESTAMP,
    FOREIGN KEY (document_id) REFERENCES Documents(document_id)
);
CREATE TABLE Document_Dependencies (
    dependent_document_id INT,
    dependency_document_id INT,
    FOREIGN KEY (dependent_document_id) REFERENCES Documents(document_id),
    FOREIGN KEY (dependency_document_id) REFERENCES Documents(document_id),
    PRIMARY KEY (dependent_document_id, dependency_document_id)
);
WITH DocumentVersionList AS (
    SELECT 
        dv.version_id,
        dv.document_id,
        dv.version_number,
        dv.created_at,
        dv.modified_at,
        ROW_NUMBER() OVER (PARTITION BY dv.document_id ORDER BY dv.version_number DESC) AS version_rank
    FROM Document_Versions dv
)
SELECT 
    document_id,
    version_number,
    created_at,
    modified_at,
    version_rank
FROM DocumentVersionList
ORDER BY document_id, version_number DESC;
WITH DocumentVersionComparison AS (
    SELECT 
        dv.version_id,
        dv.document_id,
        dv.version_number,
        dv.content,
        LAG(dv.content) OVER (PARTITION BY dv.document_id ORDER BY dv.version_number) AS previous_version_content,
        dv.created_at,
        dv.modified_at
    FROM Document_Versions dv
)
SELECT 
    document_id,
    version_number,
    content,
    previous_version_content,
    created_at,
    modified_at
FROM DocumentVersionComparison
ORDER BY document_id, version_number DESC;
WITH RECURSIVE DocumentDependencyTree AS (
    -- Base case: start with documents that have dependencies
    SELECT 
        dd.dependent_document_id AS document_id,
        dd.dependency_document_id,
        1 AS level  -- Level 1 is the direct dependencies
    FROM Document_Dependencies dd

    UNION ALL

    -- Recursive case: Find documents that depend on the previously identified documents
    SELECT 
        dd.dependent_document_id,
        dd.dependency_document_id,
        ddt.level + 1 AS level
    FROM Document_Dependencies dd
    JOIN DocumentDependencyTree ddt ON dd.dependency_document_id = ddt.document_id
)
SELECT 
    document_id,
    dependency_document_id,
    level
FROM DocumentDependencyTree
ORDER BY level, document_id;
WITH VersionStatus AS (
    SELECT 
        dv.version_id,
        dv.document_id,
        dv.version_number,
        dv.created_at,
        dv.modified_at,
        ROW_NUMBER() OVER (PARTITION BY dv.document_id ORDER BY dv.version_number DESC) AS version_rank
    FROM Document_Versions dv
),
CurrentVersion AS (
    SELECT 
        document_id,
        version_id,
        version_number,
        'current' AS version_status
    FROM VersionStatus
    WHERE version_rank = 1
),
OutdatedVersion AS (
    SELECT 
        document_id,
        version_id,
        version_number,
        'outdated' AS version_status
    FROM VersionStatus
    WHERE version_rank > 1
),
BrokenVersion AS (
    SELECT 
        dv.version_id,
        dv.document_id,
        dv.version_number,
        'broken' AS version_status
    FROM Document_Versions dv
    LEFT JOIN Document_Dependencies dd ON dv.document_id = dd.dependent_document_id
    WHERE dd.dependent_document_id IS NULL
)
SELECT 
    dv.document_id,
    dv.version_number,
    COALESCE(cv.version_status, ov.version_status, bv.version_status) AS version_status
FROM Document_Versions dv
LEFT JOIN CurrentVersion cv ON dv.version_id = cv.version_id
LEFT JOIN OutdatedVersion ov ON dv.version_id = ov.version_id
LEFT JOIN BrokenVersion bv ON dv.version_id = bv.version_id
ORDER BY dv.document_id, dv.version_number DESC;
