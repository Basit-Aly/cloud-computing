-- Run this script once on your Azure SQL Database to create the schema and seed menu data.

-- Table: MenuItems
CREATE TABLE MenuItems (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(100)   NOT NULL,
    description NVARCHAR(255),
    price       DECIMAL(6,2)    NOT NULL,
    category    NVARCHAR(50)    NOT NULL
);

-- Table: Bookings
CREATE TABLE Bookings (
    id            INT IDENTITY(1,1) PRIMARY KEY,
    customer_name NVARCHAR(100)  NOT NULL,
    phone         NVARCHAR(20)   NOT NULL,
    booking_date  DATE           NOT NULL,
    booking_time  TIME           NOT NULL,
    guests        INT            NOT NULL,
    total_amount  DECIMAL(8,2)   NOT NULL,
    created_at    DATETIME       DEFAULT GETDATE()
);

-- Table: BookingItems  (links a booking to menu items)
CREATE TABLE BookingItems (
    id             INT IDENTITY(1,1) PRIMARY KEY,
    booking_id     INT NOT NULL REFERENCES Bookings(id),
    menu_item_id   INT NOT NULL REFERENCES MenuItems(id),
    quantity       INT NOT NULL DEFAULT 1
);

-- ── Seed Data: Menu Items ────────────────────────────────────────────────────
INSERT INTO MenuItems (name, description, price, category) VALUES
('Tomato Soup',        'Classic tomato soup with cream',           5.99,  'Starter'),
('Caesar Salad',       'Fresh romaine with Caesar dressing',        7.99,  'Starter'),
('Grilled Chicken',    'Herb-marinated grilled chicken breast',    14.99,  'Main Course'),
('Beef Steak',         'Grilled sirloin steak with sides',         22.99,  'Main Course'),
('Margherita Pizza',   'Classic pizza with mozzarella and basil',  13.99,  'Main Course'),
('Pasta Carbonara',    'Creamy pasta with bacon and parmesan',     12.99,  'Main Course'),
('Chocolate Lava Cake','Warm chocolate cake with molten center',    6.99,  'Dessert'),
('Tiramisu',           'Classic Italian coffee dessert',            5.99,  'Dessert'),
('Soft Drink',         'Choice of Coke, Sprite, or Fanta',         2.49,  'Drinks'),
('Fresh Juice',        'Orange, Apple, or Mango',                   3.49,  'Drinks');
