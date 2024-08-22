-- Verifica si la base de datos ya existe
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'Airport')
BEGIN 
    PRINT 'La base de datos ya existe';
END 
ELSE 
BEGIN
    PRINT 'La base de datos no existe, Procediendo a crearla';
    CREATE DATABASE Airport;
END;

GO
-- Cambia al contexto de la base de datos Airport
USE Airport;
GO
-- Crea las tablas
BEGIN TRANSACTION;
BEGIN TRY
    CREATE TABLE passport (
        number INT PRIMARY KEY NOT NULL,
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        nationality VARCHAR(20),
        issue_date DATE
    );

    CREATE TABLE identity_card (
        number INT PRIMARY KEY NOT NULL,
        first_name VARCHAR(50),
        last_name VARCHAR(50),
        birthdate DATE,
        address_home VARCHAR(100)
    );

    CREATE TABLE customer (
        id INT PRIMARY KEY NOT NULL,
        date_of_birth DATE,
        name_customer VARCHAR(25),
        id_passport INT,
        id_identity_card INT,
        FOREIGN KEY(id_passport) REFERENCES passport(number),
        FOREIGN KEY(id_identity_card) REFERENCES identity_card(number)
    );

    CREATE TABLE frequent_flyer_card (
        ffc_number INT PRIMARY KEY NOT NULL,
        milles INT,
        meal_code VARCHAR(50),
        customer_id INT,
        FOREIGN KEY (customer_id) REFERENCES customer(id)
    );

    CREATE TABLE ticket (
        number INT PRIMARY KEY NOT NULL,
        ticketing_code VARCHAR(15),
        id_customer INT,
        FOREIGN KEY (id_customer) REFERENCES customer(id)
    );

    CREATE TABLE country (
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        name VARCHAR(50)
    );

    CREATE TABLE city (
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        name VARCHAR(50),
        id_country INT,
        FOREIGN KEY (id_country) REFERENCES country(id)
    );

    CREATE TABLE airport (
        id VARCHAR(5) PRIMARY KEY NOT NULL,
        name_airport VARCHAR(160),
        id_city INT,
        FOREIGN KEY (id_city) REFERENCES city(id)
    );

    CREATE TABLE plane_model (
        id INT PRIMARY KEY NOT NULL,
        description VARCHAR(100),
        graphic VARBINARY(MAX)
    );

    CREATE TABLE seat (
        location_seat VARCHAR(4) PRIMARY KEY NOT NULL,
        size INT,
        id_plane_model INT,
        FOREIGN KEY (id_plane_model) REFERENCES plane_model(id)
    );

    CREATE TABLE airplane (
        registration_number VARCHAR(10) PRIMARY KEY NOT NULL,
        begin_of_operation DATE,
        status_airplane VARCHAR(12),
        id_plane_model INT,
        FOREIGN KEY (id_plane_model) REFERENCES plane_model(id)
    );

    CREATE TABLE flight_number (
        id VARCHAR(10) PRIMARY KEY NOT NULL,
        departure_time DATETIME,
        description_flight VARCHAR(100),
        type_flight VARCHAR(20),
        airline VARCHAR(30),
        id_plane_model INT,
        StartAirport INT,
		GoalAirport INT,
		FOREIGN KEY (StartAirport) REFERENCES Airport(id),
		FOREIGN KEY (GoalAirport) REFERENCES Airport(id),
        FOREIGN KEY (id_plane_model) REFERENCES plane_model(id)
    );

    CREATE TABLE distance (
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        distance_range VARCHAR(20)
    );

    CREATE TABLE modes (
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        mode VARCHAR(20)
    );

    CREATE TABLE flight (
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        boarding_time TIME,
        flight_date DATE,
        gate VARCHAR(5),
        check_in_counter VARCHAR(10),
        id_flight_number VARCHAR(10),
        id_distance INT,
        id_modes INT,
        FOREIGN KEY (id_distance) REFERENCES distance(id),
        FOREIGN KEY (id_modes) REFERENCES modes(id),
        FOREIGN KEY (id_flight_number) REFERENCES flight_number(id)
    );

    CREATE TABLE coupon (
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        date_of_redemption DATE,
        class VARCHAR(20),
        stand_by INT,
        meal_code VARCHAR(50),
        number_ticket INT,
        FOREIGN KEY (number_ticket) REFERENCES ticket(number)
    );

    CREATE TABLE pieces_of_luggage (
        number VARCHAR(20) PRIMARY KEY NOT NULL,
        weight_of_luggage DECIMAL(10,2),
        id_coupon INT,
        FOREIGN KEY (id_coupon) REFERENCES coupon(id)
    );

    CREATE TABLE available_seat (
        id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
        id_flight INT,
        id_coupon INT,
        id_seat VARCHAR(4),
        FOREIGN KEY (id_flight) REFERENCES flight(id),
        FOREIGN KEY (id_coupon) REFERENCES coupon(id),
        FOREIGN KEY (id_seat) REFERENCES seat(location_seat)
    );

    PRINT 'Operación exitosa';
    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al crear tablas: ' + ERROR_MESSAGE();
END CATCH;
GO
-- Inserta datos en las tablas
BEGIN TRANSACTION;
BEGIN TRY
    INSERT INTO passport (number, first_name, last_name, nationality, issue_date)
    VALUES
        (1, 'Juan', 'Pérez', 'Mexicano', '2024-01-15'),
        (2, 'Ana', 'García', 'Española', '2023-06-22'),
        (3, 'Pedro', 'Martínez', 'Argentino', '2024-03-30'),
        (4, 'Luisa', 'Fernández', 'Colombiana', '2024-07-12');

    INSERT INTO identity_card (number, first_name, last_name, birthdate, address_home)
    VALUES
        (101, 'Juan', 'Pérez', '1985-11-23', 'Calle Falsa 123'),
        (102, 'Ana', 'García', '1990-02-14', 'Avenida Principal 456'),
        (103, 'Pedro', 'Martínez', '1987-05-09', 'Calle Real 789'),
        (104, 'Luisa', 'Fernández', '1992-08-17', 'Carrera Central 321');

    INSERT INTO customer (id, date_of_birth, name_customer, id_passport, id_identity_card)
    VALUES
        (1, '1985-11-23', 'Juan Pérez', 1, 101),
        (2, '1990-02-14', 'Ana García', 2, 102),
        (3, '1987-05-09', 'Pedro Martínez', 3, 103),
        (4, '1992-08-17', 'Luisa Fernández', 4, 104);

    INSERT INTO frequent_flyer_card (ffc_number, milles, meal_code, customer_id)
    VALUES
        (1001, 5000, 'Vegan', 1),
        (1002, 3000, 'Vegetarian', 2),
        (1003, 7000, 'Non-Vegetarian', 3),
        (1004, 2500, 'Kosher', 4);

    INSERT INTO ticket (number, ticketing_code, id_customer)
    VALUES
        (10001, 'TICKET01', 1),
        (10002, 'TICKET02', 2),
        (10003, 'TICKET03', 3),
        (10004, 'TICKET04', 4);

    INSERT INTO country (name)
    VALUES
        ('México'),
        ('España'),
        ('Argentina'),
        ('Colombia');

    INSERT INTO city (name, id_country)
    VALUES
        ('Ciudad de México', 1),
        ('Madrid', 2),
        ('Buenos Aires', 3),
        ('Bogotá', 4);

    INSERT INTO airport (id, name_airport, id_city)
    VALUES
        ('A001', 'Aeropuerto Internacional de la Ciudad de México', 1),
        ('A002', 'Aeropuerto Adolfo Suárez Madrid-Barajas', 2),
        ('A003', 'Aeropuerto Internacional de Ezeiza', 3),
        ('A004', 'Aeropuerto El Dorado', 4);

    INSERT INTO plane_model (id, description)
    VALUES
        (1, 'Boeing 737'),
        (2, 'Airbus A320'),
        (3, 'Boeing 787'),
        (4, 'Airbus A350');

    INSERT INTO seat (location_seat, size, id_plane_model)
    VALUES
        ('1A', 1, 1),
        ('2B', 1, 2),
        ('3C', 2, 3),
        ('4D', 2, 4);

    INSERT INTO airplane (registration_number, begin_of_operation, status_airplane, id_plane_model)
    VALUES
        ('REG001', '2015-01-01', 'Operational', 1),
        ('REG002', '2018-05-20', 'Operational', 2),
        ('REG003', '2020-07-15', 'Maintenance', 3),
        ('REG004', '2021-03-10', 'Operational', 4);

    INSERT INTO flight_number (id, departure_time, description_flight, type_flight, airline, id_airport, id_plane_model)
    VALUES
        ('FL001', '2024-09-01 10:00:00', 'Vuelo Nacional', 'Regular', 'AeroMex', 'A001', 1),
        ('FL002', '2024-09-02 14:00:00', 'Vuelo Internacional', 'Regular', 'Iberia', 'A002', 2),
        ('FL003', '2024-09-03 18:00:00', 'Vuelo Regional', 'Charter', 'AeroArg', 'A003', 3),
        ('FL004', '2024-09-04 22:00:00', 'Vuelo Internacional', 'Regular', 'AeroCol', 'A004', 4);

    INSERT INTO distance (distance_range)
    VALUES
        ('Corta'),
        ('Media'),
        ('Larga'),
        ('Muy Larga');

    INSERT INTO modes (mode)
    VALUES
        ('Económica'),
        ('Primera Clase'),
        ('Business'),
        ('Premium Economy');

    INSERT INTO flight (boarding_time, flight_date, gate, check_in_counter, id_flight_number, id_distance, id_modes)
    VALUES
        ('08:00:00', '2024-09-01', 'G01', 'C01', 'FL001', 1, 1),
        ('12:00:00', '2024-09-02', 'G02', 'C02', 'FL002', 2, 2),
        ('16:00:00', '2024-09-03', 'G03', 'C03', 'FL003', 3, 3),
        ('20:00:00', '2024-09-04', 'G04', 'C04', 'FL004', 4, 4);

    INSERT INTO coupon (date_of_redemption, class, stand_by, meal_code, number_ticket)
    VALUES
        ('2024-09-01', 'Economy', 0, 'Vegan', 10001),
        ('2024-09-02', 'Business', 1, 'Vegetarian', 10002),
        ('2024-09-03', 'First Class', 0, 'Non-Vegetarian', 10003),
        ('2024-09-04', 'Economy', 1, 'Kosher', 10004);

    INSERT INTO pieces_of_luggage (number, weight_of_luggage, id_coupon)
    VALUES
        ('LUG001', 23.50, 1),
        ('LUG002', 15.75, 2),
        ('LUG003', 18.00, 3),
        ('LUG004', 22.25, 4);

    INSERT INTO available_seat (id_flight, id_coupon, id_seat)
    VALUES
        (1, 1, '1A'),
        (2, 2, '2B'),
        (3, 3, '3C'),
        (4, 4, '4D');

    COMMIT TRANSACTION;
END TRY
BEGIN CATCH
    ROLLBACK TRANSACTION;
    PRINT 'Error al insertar datos: ' + ERROR_MESSAGE();
END CATCH;
