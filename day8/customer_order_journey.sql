CREATE TABLE Customers (
    customer_id INT PRIMARY KEY,
    customer_name VARCHAR(100),
    email VARCHAR(100)
);
CREATE TABLE Orders (
    order_id INT PRIMARY KEY,
    customer_id INT,
    order_stage VARCHAR(50),   -- Example stages: 'Order Placed', 'Shipped', 'Delivered'
    order_date TIMESTAMP,      -- Timestamp of the event
    FOREIGN KEY (customer_id) REFERENCES Customers(customer_id)
);
CREATE TABLE Order_Stages (
    stage_id INT PRIMARY KEY,
    stage_name VARCHAR(50),
    parent_stage_id INT NULL,  -- Points to parent stage if it's hierarchical
    FOREIGN KEY (parent_stage_id) REFERENCES Order_Stages(stage_id)
);
WITH OrderJourney AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_stage,
        o.order_date,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS event_order
    FROM Orders o
)
SELECT * FROM OrderJourney
ORDER BY customer_id, event_order;
WITH OrderJourney AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_stage,
        o.order_date,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS event_order,
        LAG(o.order_date) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS previous_stage_date
    FROM Orders o
)
SELECT
    order_id,
    customer_id,
    order_stage,
    order_date,
    event_order,
    previous_stage_date,
    EXTRACT(EPOCH FROM (order_date - previous_stage_date)) / 3600 AS time_diff_hours  -- Time difference in hours
FROM OrderJourney
WHERE previous_stage_date IS NOT NULL
ORDER BY customer_id, event_order;
WITH RECURSIVE OrderStageHierarchy AS (
    -- Base case: starting with the initial stage
    SELECT
        os.stage_id,
        os.stage_name,
        os.parent_stage_id,
        1 AS level
    FROM Order_Stages os
    WHERE os.parent_stage_id IS NULL

    UNION ALL

    -- Recursive case: find sub-stages
    SELECT
        os.stage_id,
        os.stage_name,
        os.parent_stage_id,
        osh.level + 1 AS level
    FROM Order_Stages os
    JOIN OrderStageHierarchy osh ON os.parent_stage_id = osh.stage_id
)
SELECT * FROM OrderStageHierarchy
ORDER BY level, stage_id;
WITH CustomerOrderFrequency AS (
    SELECT
        customer_id,
        COUNT(o.order_id) AS order_count
    FROM Orders o
    GROUP BY o.customer_id
),
RankedCustomers AS (
    SELECT
        customer_id,
        order_count,
        RANK() OVER (ORDER BY order_count DESC) AS order_rank
    FROM CustomerOrderFrequency
)
SELECT * FROM RankedCustomers
ORDER BY order_rank;
WITH RECURSIVE OrderStageHierarchy AS (
    SELECT
        os.stage_id,
        os.stage_name,
        os.parent_stage_id,
        1 AS level
    FROM Order_Stages os
    WHERE os.parent_stage_id IS NULL

    UNION ALL

    SELECT
        os.stage_id,
        os.stage_name,
        os.parent_stage_id,
        osh.level + 1 AS level
    FROM Order_Stages os
    JOIN OrderStageHierarchy osh ON os.parent_stage_id = osh.stage_id
),
OrderJourney AS (
    SELECT
        o.order_id,
        o.customer_id,
        o.order_stage,
        o.order_date,
        ROW_NUMBER() OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS event_order,
        LAG(o.order_date) OVER (PARTITION BY o.customer_id ORDER BY o.order_date) AS previous_stage_date
    FROM Orders o
),
OrderJourneyWithTime AS (
    SELECT
        order_id,
        customer_id,
        order_stage,
        order_date,
        event_order,
        previous_stage_date,
        EXTRACT(EPOCH FROM (order_date - previous_stage_date)) / 3600 AS time_diff_hours  -- Time difference in hours
    FROM OrderJourney
    WHERE previous_stage_date IS NOT NULL
),
CustomerOrderFrequency AS (
    SELECT
        customer_id,
        COUNT(o.order_id) AS order_count
    FROM Orders o
    GROUP BY o.customer_id
),
RankedCustomers AS (
    SELECT
        customer_id,
        order_count,
        RANK() OVER (ORDER BY order_count DESC) AS order_rank
    FROM CustomerOrderFrequency
)
-- Final result combining everything
SELECT
    'Order Journey' AS section,
    oj.customer_id,
    c.customer_name,
    oj.order_stage,
    oj.order_date,
    oj.event_order,
    oj.previous_stage_date,
    oj.time_diff_hours,
    ocf.order_count,
    rc.order_rank
FROM OrderJourneyWithTime oj
JOIN Customers c ON oj.customer_id = c.customer_id
JOIN CustomerOrderFrequency ocf ON oj.customer_id = ocf.customer_id
JOIN RankedCustomers rc ON oj.customer_id = rc.customer_id
ORDER BY rc.order_rank, oj.customer_id, oj.event_order;
