CREATE TABLE Categories (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100),
    parent_category_id INT NULL,  -- Null for top-level categories
    FOREIGN KEY (parent_category_id) REFERENCES Categories(category_id)
);
CREATE TABLE Products (
    product_id INT PRIMARY KEY,
    product_name VARCHAR(100),
    category_id INT,
    stock_quantity INT,  -- Available stock
    created_at DATE,     -- Date when the product was added
    FOREIGN KEY (category_id) REFERENCES Categories(category_id)
);
WITH RECURSIVE CategoryTree AS (
    -- Base case: top-level categories (parent_category_id is NULL)
    SELECT category_id, category_name, parent_category_id, 0 AS level
    FROM Categories
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    -- Recursive case: subcategories
    SELECT c.category_id, c.category_name, c.parent_category_id, ct.level + 1 AS level
    FROM Categories c
    JOIN CategoryTree ct ON c.parent_category_id = ct.category_id
)
SELECT * FROM CategoryTree
ORDER BY level, parent_category_id, category_name;
WITH CategoryProductCount AS (
    SELECT
        c.category_id,
        c.category_name,
        COUNT(p.product_id) AS total_products
    FROM Categories c
    LEFT JOIN Products p ON c.category_id = p.category_id
    GROUP BY c.category_id, c.category_name
),
RankedCategories AS (
    SELECT
        category_id,
        category_name,
        total_products,
        RANK() OVER (ORDER BY total_products DESC) AS category_rank
    FROM CategoryProductCount
)
SELECT * FROM RankedCategories
ORDER BY category_rank;
WITH CategoryProductHistory AS (
    SELECT
        c.category_id,
        c.category_name,
        COUNT(p.product_id) AS total_products,
        p.created_at
    FROM Categories c
    LEFT JOIN Products p ON c.category_id = p.category_id
    GROUP BY c.category_id, c.category_name, p.created_at
),
CategoryMovement AS (
    SELECT
        category_id,
        category_name,
        created_at,
        total_products,
        LAG(total_products) OVER (PARTITION BY category_id ORDER BY created_at) AS previous_month_count,
        LEAD(total_products) OVER (PARTITION BY category_id ORDER BY created_at) AS next_month_count
    FROM CategoryProductHistory
)
SELECT * FROM CategoryMovement
ORDER BY category_id, created_at;
WITH ProductAvailability AS (
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
        p.stock_quantity
    FROM Products p
    JOIN Categories c ON p.category_id = c.category_id
)
SELECT
    product_name,
    category_name,
    stock_quantity
FROM ProductAvailability
WHERE stock_quantity > 0
ORDER BY category_name, product_name;
-- 1. Display Full Category Tree
WITH RECURSIVE CategoryTree AS (
    SELECT category_id, category_name, parent_category_id, 0 AS level
    FROM Categories
    WHERE parent_category_id IS NULL
    
    UNION ALL
    
    SELECT c.category_id, c.category_name, c.parent_category_id, ct.level + 1 AS level
    FROM Categories c
    JOIN CategoryTree ct ON c.parent_category_id = ct.category_id
),

-- 2. Rank Categories by Total Product Count
CategoryProductCount AS (
    SELECT
        c.category_id,
        c.category_name,
        COUNT(p.product_id) AS total_products
    FROM Categories c
    LEFT JOIN Products p ON c.category_id = p.category_id
    GROUP BY c.category_id, c.category_name
),
RankedCategories AS (
    SELECT
        category_id,
        category_name,
        total_products,
        RANK() OVER (ORDER BY total_products DESC) AS category_rank
    FROM CategoryProductCount
),

-- 3. Track Category Movement Over Time
CategoryProductHistory AS (
    SELECT
        c.category_id,
        c.category_name,
        COUNT(p.product_id) AS total_products,
        p.created_at
    FROM Categories c
    LEFT JOIN Products p ON c.category_id = p.category_id
    GROUP BY c.category_id, c.category_name, p.created_at
),
CategoryMovement AS (
    SELECT
        category_id,
        category_name,
        created_at,
        total_products,
        LAG(total_products) OVER (PARTITION BY category_id ORDER BY created_at) AS previous_month_count,
        LEAD(total_products) OVER (PARTITION BY category_id ORDER BY created_at) AS next_month_count
    FROM CategoryProductHistory
),

-- 4. Product Availability Report
ProductAvailability AS (
    SELECT
        p.product_id,
        p.product_name,
        c.category_name,
        p.stock_quantity
    FROM Products p
    JOIN Categories c ON p.category_id = c.category_id
)
-- Final selection: We will select relevant results as needed
SELECT 
    'Category Tree' AS section,
    category_id,
    category_name,
    parent_category_id,
    level
FROM CategoryTree

UNION ALL

SELECT 
    'Ranked Categories' AS section,
    category_id,
    category_name,
    total_products,
    category_rank
FROM RankedCategories

UNION ALL

SELECT 
    'Category Movement' AS section,
    category_id,
    category_name,
    created_at,
    total_products,
    previous_month_count,
    next_month_count
FROM CategoryMovement

UNION ALL

SELECT 
    'Product Availability' AS section,
    product_id,
    product_name,
    category_name,
    stock_quantity
FROM ProductAvailability
WHERE stock_quantity > 0
ORDER BY section, category_name, product_name;
