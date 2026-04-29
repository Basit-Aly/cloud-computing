-- Run this script once on your Azure SQL Database to create the schema and seed menu data.

-- Table: MenuItems
CREATE TABLE MenuItems (
    id          INT IDENTITY(1,1) PRIMARY KEY,
    name        NVARCHAR(100)   NOT NULL,
    description NVARCHAR(255),
    price       DECIMAL(8,2)    NOT NULL,
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
    total_amount  DECIMAL(10,2)  NOT NULL,
    created_at    DATETIME       DEFAULT GETDATE()
);

-- Table: BookingItems (links a booking to menu items)
CREATE TABLE BookingItems (
    id             INT IDENTITY(1,1) PRIMARY KEY,
    booking_id     INT NOT NULL REFERENCES Bookings(id),
    menu_item_id   INT NOT NULL REFERENCES MenuItems(id),
    quantity       INT NOT NULL DEFAULT 1
);

-- Seed Data: Pakistani Menu Items (prices in PKR)
INSERT INTO MenuItems (name, description, price, category) VALUES

-- Starters
('Chicken Corn Soup',     'Classic hot and sour chicken corn soup',               350.00,  'Starter'),
('Shami Kebab',           'Tender minced meat patties with spices (2 pcs)',        450.00,  'Starter'),
('Dahi Bhalle',           'Soft lentil dumplings topped with yogurt and chutney',  300.00,  'Starter'),

-- Main Course
('Chicken Karahi',        'Tender chicken cooked in tomato and spice gravy',      1200.00,  'Main Course'),
('Mutton Biryani',        'Fragrant basmati rice layered with spiced mutton',     1100.00,  'Main Course'),
('Beef Nihari',           'Slow cooked beef stew with aromatic spices',           1300.00,  'Main Course'),
('Chicken Handi',         'Creamy chicken curry cooked in a clay pot',            1100.00,  'Main Course'),
('Daal Makhani',          'Slow cooked black lentils in butter and cream',         750.00,  'Main Course'),
('Seekh Kebab Platter',   'Juicy minced meat kebabs served with naan and raita',  1050.00,  'Main Course'),
('Chicken Tikka Masala',  'Grilled chicken tikka in rich creamy masala sauce',    1200.00,  'Main Course'),
('Lamb Rogan Josh',       'Tender lamb slow cooked in Kashmiri spices',           1450.00,  'Main Course'),
('Chicken Chapli Kebab',  'Crispy minced chicken patties with fresh herbs',       1000.00,  'Main Course'),
('Beef Kofta Curry',      'Spiced beef meatballs simmered in tomato curry',       1100.00,  'Main Course'),
('Paneer Butter Masala',  'Soft paneer cubes in a rich buttery tomato gravy',      950.00,  'Main Course'),

-- Desserts
('Gulab Jamun',           'Soft milk solid dumplings soaked in sugar syrup',       300.00,  'Dessert'),
('Kheer',                 'Creamy rice pudding with cardamom and pistachios',       350.00,  'Dessert'),
('Gajar Ka Halwa',        'Slow cooked carrot pudding with nuts and khoya',         400.00,  'Dessert'),

-- Drinks
('Lassi',                 'Chilled yogurt drink, sweet or salty',                   250.00,  'Drinks'),
('Rooh Afza',             'Refreshing rose flavored sharbat with milk',             180.00,  'Drinks'),
('Soft Drink',            'Choice of Coke, Sprite, or Fanta',                       150.00,  'Drinks');