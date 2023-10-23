DO $$ BEGIN 
    IF NOT EXISTS (SELECT * FROM pg_catalog.pg_user WHERE usename = '$DB_USER') THEN
        CREATE USER "$DB_USER" WITH PASSWORD '$DB_PASSWORD';
--      GRANT ALL PRIVILEGES ON DATABASE "$DB_NAME" to "$DB_ADMIN" WITH GRANT OPTION;
        ALTER USER "$DB_USER" CREATEROLE;
    END IF;

/*    IF NOT EXISTS (SELECT FROM pg_database WHERE datname = '$DB_NAME') THEN # ERROR:  CREATE DATABASE cannot be executed from a function
        CREATE DATABASE "$DB_NAME";
      END IF; */
    
--  USE "$DB_NAME"; # This statement does not exist in PostgreSQL :(

END $$;