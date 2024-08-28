Use master;

GO
-- Verifica si la base de datos ya existe
IF EXISTS (SELECT * FROM sys.databases WHERE name = 'tickets_airport')
BEGIN 
    PRINT 'La base de datos ya existe, la crearemos de nuevo';
	DROP DATABASE tickets_airport;
	CREATE DATABASE tickets_airport;
END 
ELSE 
BEGIN
    PRINT 'La base de datos no existe, iniciando proceso de creación';
    CREATE DATABASE tickets_airport;
END;

GO
-- Cambia al contexto de la base de datos tickets_airport
USE tickets_airport;
GO
-- Crea las tablas
BEGIN TRANSACTION;
BEGIN TRY
    IF OBJECT_ID('passport', 'U') IS NOT NULL
    BEGIN
        DROP TABLE passport;
    END

    IF OBJECT_ID('identity_card', 'U') IS NOT NULL
    BEGIN
        DROP TABLE identity_card;
    END

    IF OBJECT_ID('customer', 'U') IS NOT NULL
    BEGIN
        DROP TABLE customer;
    END

    IF OBJECT_ID('frequent_flyer_card', 'U') IS NOT NULL
    BEGIN
        DROP TABLE frequent_flyer_card;
    END

	IF OBJECT_ID('category', 'U') IS NOT NULL
    BEGIN
        DROP TABLE category;
    END

    IF OBJECT_ID('ticket', 'U') IS NOT NULL
    BEGIN
        DROP TABLE ticket;
    END

    IF OBJECT_ID('country', 'U') IS NOT NULL
    BEGIN
        DROP TABLE country;
    END

    IF OBJECT_ID('city', 'U') IS NOT NULL
    BEGIN
        DROP TABLE city;
    END

    IF OBJECT_ID('airport', 'U') IS NOT NULL
    BEGIN
        DROP TABLE airport;
    END

    IF OBJECT_ID('plane_model', 'U') IS NOT NULL
    BEGIN
        DROP TABLE plane_model;
    END

    IF OBJECT_ID('seat', 'U') IS NOT NULL
    BEGIN
        DROP TABLE seat;
    END

    IF OBJECT_ID('airplane', 'U') IS NOT NULL
    BEGIN
        DROP TABLE airplane;
    END

    IF OBJECT_ID('flight_number', 'U') IS NOT NULL
    BEGIN
        DROP TABLE flight_number;
    END

    IF OBJECT_ID('distance', 'U') IS NOT NULL
    BEGIN
        DROP TABLE distance;
    END

    IF OBJECT_ID('modes', 'U') IS NOT NULL
    BEGIN
        DROP TABLE modes;
    END

    IF OBJECT_ID('flight', 'U') IS NOT NULL
    BEGIN
        DROP TABLE flight;
    END

    IF OBJECT_ID('coupon', 'U') IS NOT NULL
    BEGIN
        DROP TABLE coupon;
    END

    IF OBJECT_ID('pieces_of_luggage', 'U') IS NOT NULL
    BEGIN
        DROP TABLE pieces_of_luggage;
    END

    IF OBJECT_ID('available_seat', 'U') IS NOT NULL
    BEGIN
        DROP TABLE available_seat;
    END

    CREATE TABLE passport (
    number INT PRIMARY KEY NOT NULL,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    nationality VARCHAR(20) NOT NULL,
    issue_date DATE NOT NULL CHECK (issue_date <= GETDATE())  -- La fecha de emisión no puede ser futura
	);

	-- Índice en el campo last_name para acelerar búsquedas por apellido
	CREATE INDEX idx_passport_last_name ON passport(last_name);

	CREATE TABLE identity_card (
		number INT PRIMARY KEY NOT NULL,
		first_name VARCHAR(50) NOT NULL,
		last_name VARCHAR(50) NOT NULL,
		birthdate DATE NOT NULL CHECK (birthdate <= GETDATE()),  -- La fecha de nacimiento no puede ser futura
		address_home VARCHAR(100) NOT NULL
	);

	-- Índice en el campo last_name para acelerar búsquedas por apellido
	CREATE INDEX idx_identity_card_last_name ON identity_card(last_name);

	CREATE TABLE customer (
		id INT PRIMARY KEY NOT NULL,
		date_of_birth DATE NOT NULL CHECK (date_of_birth <= GETDATE()),  -- La fecha de nacimiento no puede ser futura
		name_customer VARCHAR(25) NOT NULL,
		id_passport INT,
		id_identity_card INT,
		FOREIGN KEY(id_passport) REFERENCES passport(number)
			ON DELETE SET NULL ON UPDATE CASCADE,  -- Si el pasaporte se elimina, se establece NULL
		FOREIGN KEY(id_identity_card) REFERENCES identity_card(number)
			ON DELETE SET NULL ON UPDATE CASCADE   -- Si la tarjeta de identidad se elimina, se establece NULL
	);

	-- Índice en el campo id_passport para optimizar búsquedas por pasaporte
	CREATE INDEX idx_customer_id_passport ON customer(id_passport);

	-- Índice en el campo id_identity_card para optimizar búsquedas por identidad
	CREATE INDEX idx_customer_id_identity_card ON customer(id_identity_card);

	CREATE TABLE frequent_flyer_card (
		ffc_number INT PRIMARY KEY NOT NULL,
		milles INT CHECK (milles >= 0),  -- Las millas no pueden ser negativas
		meal_code VARCHAR(50),
		customer_id INT NOT NULL,
		FOREIGN KEY (customer_id) REFERENCES customer(id)
			ON DELETE CASCADE ON UPDATE CASCADE   -- Si el cliente se elimina, la tarjeta se elimina
	);

	-- Índice en el campo customer_id para optimizar búsquedas por cliente
	CREATE INDEX idx_frequent_flyer_card_customer_id ON frequent_flyer_card(customer_id);

	CREATE TABLE category (
		id INT PRIMARY KEY NOT NULL,
		category_name VARCHAR(20)
	)

	CREATE TABLE ticket (
		number INT PRIMARY KEY NOT NULL,
		ticketing_code VARCHAR(15) NOT NULL,
		id_customer INT NOT NULL,
		id_category INT NOT NULL,
		FOREIGN KEY (id_customer) REFERENCES customer(id)
			ON DELETE CASCADE ON UPDATE CASCADE,  -- Si el cliente se elimina, el ticket se elimina
		FOREIGN KEY (id_category) REFERENCES category(id)
			ON DELETE SET NULL ON UPDATE CASCADE  -- Si se elimina una categoría, se establece el campo como NULL 
												  -- Si se actualiza una categoría, se actualiza la referencia en tickets
			
	);

	-- Índice en el campo id_customer para optimizar búsquedas por cliente
	CREATE INDEX idx_ticket_id_customer ON ticket(id_customer);
	-- Índice en id_category para optimizar búsquedas en la tabla ticket
	CREATE INDEX idx_ticket_id_category ON ticket(id_category);

	CREATE TABLE country (
		id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		name VARCHAR(50) NOT NULL
	);

	CREATE TABLE city (
		id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		name VARCHAR(50) NOT NULL,
		id_country INT NOT NULL,
		FOREIGN KEY (id_country) REFERENCES country(id)
			ON DELETE CASCADE ON UPDATE CASCADE   -- Si el país se elimina, las ciudades asociadas también
	);

	-- Índice en el campo id_country para optimizar búsquedas por país
	CREATE INDEX idx_city_id_country ON city(id_country);

	CREATE TABLE airport (
		id VARCHAR(5) PRIMARY KEY NOT NULL,
		name_airport VARCHAR(160) NOT NULL,
		id_city INT NOT NULL,
		FOREIGN KEY (id_city) REFERENCES city(id)
			ON DELETE CASCADE ON UPDATE CASCADE  -- Si la ciudad se elimina, el aeropuerto también
	);

	-- Índice en el campo id_city para optimizar búsquedas por ciudad
	CREATE INDEX idx_airport_id_city ON airport(id_city);

	CREATE TABLE plane_model (
		id INT PRIMARY KEY NOT NULL,
		description VARCHAR(100) NOT NULL,
		graphic VARBINARY(MAX)
	);

	CREATE TABLE seat (
		location_seat VARCHAR(4) PRIMARY KEY NOT NULL,
		size INT CHECK (size > 0),  -- El tamaño del asiento debe ser positivo
		id_plane_model INT NOT NULL,
		FOREIGN KEY (id_plane_model) REFERENCES plane_model(id)
			ON DELETE CASCADE ON UPDATE CASCADE  -- Si el modelo de avión se elimina, los asientos también
	);

	-- Índice en el campo id_plane_model para optimizar búsquedas por modelo de avión
	CREATE INDEX idx_seat_id_plane_model ON seat(id_plane_model);

	CREATE TABLE airplane (
		registration_number VARCHAR(10) PRIMARY KEY NOT NULL,
		begin_of_operation DATE NOT NULL CHECK (begin_of_operation <= GETDATE()),  -- La operación no puede empezar en el futuro
		status_airplane VARCHAR(12) CHECK (status_airplane IN ('active', 'maintenance', 'retired')),  -- Validar el estado
		id_plane_model INT NOT NULL,
		FOREIGN KEY (id_plane_model) REFERENCES plane_model(id)
			ON DELETE CASCADE ON UPDATE CASCADE  -- Si el modelo de avión se elimina, el avión también
	);

	-- Índice en el campo id_plane_model para optimizar búsquedas por modelo de avión
	CREATE INDEX idx_airplane_id_plane_model ON airplane(id_plane_model);

	CREATE TABLE flight_number (
		id VARCHAR(10) PRIMARY KEY NOT NULL,
		departure_time DATETIME NOT NULL CHECK (departure_time > GETDATE()),  -- La hora de salida debe ser en el futuro
		description_flight VARCHAR(100),
		type_flight VARCHAR(20),
		airline VARCHAR(30),
		id_plane_model INT NOT NULL,
		startAirport VARCHAR(5) NOT NULL,
		goalAirport VARCHAR(5) NOT NULL,
		FOREIGN KEY (startAirport) REFERENCES airport(id)
			ON DELETE NO ACTION ON UPDATE CASCADE,  -- No se permite eliminar aeropuertos que están en uso
		FOREIGN KEY (goalAirport) REFERENCES airport(id)
			ON DELETE NO ACTION ON UPDATE CASCADE,  -- No se permite eliminar aeropuertos que están en uso
		FOREIGN KEY (id_plane_model) REFERENCES plane_model(id)
			ON DELETE CASCADE ON UPDATE CASCADE  -- Si el modelo de avión se elimina, los números de vuelo asociados también
	);

	-- Índices en startAirport y goalAirport para optimizar búsquedas por aeropuerto
	CREATE INDEX idx_flight_number_start_airport ON flight_number(startAirport);
	CREATE INDEX idx_flight_number_goal_airport ON flight_number(goalAirport);

	-- Índice en id_plane_model para optimizar búsquedas por modelo de avión
	CREATE INDEX idx_flight_number_id_plane_model ON flight_number(id_plane_model);

	CREATE TABLE distance (
		id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		distance_range VARCHAR(20) NOT NULL
	);

	CREATE TABLE modes (
		id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		mode VARCHAR(20) NOT NULL
	);

	CREATE TABLE flight (
		id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		boarding_time TIME NOT NULL,
		flight_date DATE NOT NULL CHECK (flight_date >= GETDATE()),  -- La fecha del vuelo no puede ser en el pasado
		gate VARCHAR(5),
		check_in_counter VARCHAR(10),
		id_flight_number VARCHAR(10) NOT NULL,
		id_distance INT NOT NULL,
		id_modes INT NOT NULL,
		FOREIGN KEY (id_distance) REFERENCES distance(id)
			ON DELETE CASCADE ON UPDATE CASCADE,  -- Si la distancia se elimina, los vuelos asociados también
		FOREIGN KEY (id_modes) REFERENCES modes(id)
			ON DELETE CASCADE ON UPDATE CASCADE,  -- Si el modo se elimina, los vuelos asociados también
		FOREIGN KEY (id_flight_number) REFERENCES flight_number(id)
			ON DELETE CASCADE ON UPDATE CASCADE  -- Si el número de vuelo se elimina, los vuelos asociados también
	);

	-- Índice en id_flight_number para optimizar búsquedas por número de vuelo
	CREATE INDEX idx_flight_id_flight_number ON flight(id_flight_number);

	-- Índices en id_distance y id_modes para optimizar búsquedas por distancia y modo
	CREATE INDEX idx_flight_id_distance ON flight(id_distance);
	CREATE INDEX idx_flight_id_modes ON flight(id_modes);

	CREATE TABLE coupon (
		id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		date_of_redemption DATE,
		class VARCHAR(20),
		stand_by INT,
		meal_code VARCHAR(50),
		number_ticket INT NOT NULL,
		FOREIGN KEY (number_ticket) REFERENCES ticket(number)
			ON DELETE CASCADE ON UPDATE CASCADE  -- Si el ticket se elimina, el cupón asociado también
	);

	-- Índice en number_ticket para optimizar búsquedas por ticket
	CREATE INDEX idx_coupon_number_ticket ON coupon(number_ticket);

	CREATE TABLE pieces_of_luggage (
		number VARCHAR(20) PRIMARY KEY NOT NULL,
		weight_of_luggage DECIMAL(10,2) CHECK (weight_of_luggage > 0),  -- El peso del equipaje debe ser positivo
		id_coupon INT NOT NULL,
		FOREIGN KEY (id_coupon) REFERENCES coupon(id)
			ON DELETE CASCADE ON UPDATE CASCADE  -- Si el cupón se elimina, el equipaje asociado también
	);

	-- Índice en id_coupon para optimizar búsquedas por cupón
	CREATE INDEX idx_pieces_of_luggage_id_coupon ON pieces_of_luggage(id_coupon);

	CREATE TABLE available_seat (
		id INT PRIMARY KEY NOT NULL IDENTITY(1,1),
		id_flight INT NOT NULL,
		id_coupon INT,
		id_seat VARCHAR(4) NOT NULL,
		FOREIGN KEY (id_flight) REFERENCES flight(id)
			ON DELETE CASCADE ON UPDATE CASCADE,  -- Si el vuelo se elimina, los asientos disponibles asociados también
		FOREIGN KEY (id_coupon) REFERENCES coupon(id)
			ON DELETE SET NULL ON UPDATE CASCADE,  -- Si el cupón se elimina, establecer NULL
		FOREIGN KEY (id_seat) REFERENCES seat(location_seat)
			ON DELETE CASCADE ON UPDATE CASCADE  -- Si el asiento se elimina, los asientos disponibles asociados también
	);

	-- Índices en id_flight, id_coupon y id_seat para optimizar búsquedas
	CREATE INDEX idx_available_seat_id_flight ON available_seat(id_flight);
	CREATE INDEX idx_available_seat_id_coupon ON available_seat(id_coupon);
	CREATE INDEX idx_available_seat_id_seat ON available_seat(id_seat);


    PRINT 'Operaci�n exitosa';
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
        (1, 'Juan', 'P�rez', 'Mexicano', '2024-01-15'),
        (2, 'Ana', 'Garc�a', 'Espa�ola', '2023-06-22'),
        (3, 'Pedro', 'Mart�nez', 'Argentino', '2024-03-30'),
        (4, 'Luisa', 'Fern�ndez', 'Colombiana', '2024-07-12');

    INSERT INTO identity_card (number, first_name, last_name, birthdate, address_home)
    VALUES
        (101, 'Juan', 'P�rez', '1985-11-23', 'Calle Falsa 123'),
        (102, 'Ana', 'Garc�a', '1990-02-14', 'Avenida Principal 456'),
        (103, 'Pedro', 'Mart�nez', '1987-05-09', 'Calle Real 789'),
        (104, 'Luisa', 'Fern�ndez', '1992-08-17', 'Carrera Central 321');

    INSERT INTO customer (id, date_of_birth, name_customer, id_passport, id_identity_card)
    VALUES
        (1, '1985-11-23', 'Juan P�rez', 1, 101),
        (2, '1990-02-14', 'Ana Garc�a', 2, 102),
        (3, '1987-05-09', 'Pedro Mart�nez', 3, 103),
        (4, '1992-08-17', 'Luisa Fern�ndez', 4, 104);

    INSERT INTO frequent_flyer_card (ffc_number, milles, meal_code, customer_id)
    VALUES
        (1001, 5000, 'Vegan', 1),
        (1002, 3000, 'Vegetarian', 2),
        (1003, 7000, 'Non-Vegetarian', 3),
        (1004, 2500, 'Kosher', 4);

	INSERT INTO category (id, category_name)
	VALUES
		(1, 'Comercial'),
		(2, 'Militar'),
		(3, 'Negocios')

    INSERT INTO ticket (number, ticketing_code, id_customer, id_category)
    VALUES
        (10001, 'TICKET01', 1, 1),
        (10002, 'TICKET02', 2, 2),
        (10003, 'TICKET03', 3, 3),
        (10004, 'TICKET04', 4, 1);

    INSERT INTO country (name)
    VALUES
        ('M�xico'),
        ('Espa�a'),
        ('Argentina'),
        ('Colombia');

    INSERT INTO city (name, id_country)
    VALUES
        ('Ciudad de M�xico', 1),
        ('Madrid', 2),
        ('Buenos Aires', 3),
        ('Bogot�', 4);

    INSERT INTO airport (id, name_airport, id_city)
    VALUES
        ('A001', 'Aeropuerto Internacional de la Ciudad de M�xico', 1),
        ('A002', 'Aeropuerto Adolfo Su�rez Madrid-Barajas', 2),
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

    INSERT INTO flight_number (id, departure_time, description_flight, type_flight, airline, startAirport, goalAirport, id_plane_model)
    VALUES
        ('FL001', '2024-09-01 10:00:00', 'Vuelo Nacional', 'Regular', 'AeroMex', 'A001', 'A002', 1),
        ('FL002', '2024-09-02 14:00:00', 'Vuelo Internacional', 'Regular', 'Iberia', 'A002', 'A001', 2),
        ('FL003', '2024-09-03 18:00:00', 'Vuelo Regional', 'Charter', 'AeroArg', 'A003','A004', 3),
        ('FL004', '2024-09-04 22:00:00', 'Vuelo Internacional', 'Regular', 'AeroCol', 'A004', 'A003', 4);

    INSERT INTO distance (distance_range)
    VALUES
        ('Corta'),
        ('Media'),
        ('Larga'),
        ('Muy Larga');

    INSERT INTO modes (mode)
    VALUES
        ('Econ�mica'),
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
