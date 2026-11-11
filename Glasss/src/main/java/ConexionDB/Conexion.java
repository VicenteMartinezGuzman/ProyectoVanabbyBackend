/*
 * Click nbfs://nbhost/SystemFileSystem/Templates/Licenses/license-default.txt to change this license
 * Click nbfs://nbhost/SystemFileSystem/Templates/Classes/Class.java to edit this template
 */
package ConexionDB;

import jakarta.jms.Connection;
import java.sql.DriverManager;
import java.sql.SQLException;

/**
 *
 * @author vicen
 */
public class Conexion {
    // Configura los datos de tu base de datos local o remota
    private static final String URL = "jdbc:postgresql://localhost:5412/tu_base_datos";
    private static final String USER = "postgres";
    private static final String PASSWORD = "tu_password";

    public static Connection getConexion() throws SQLException {
        try {
            // Registramos explícitamente el driver para entornos de Servlets clásicos
            Class.forName("org.postgresql.Driver");
            return (Connection) DriverManager.getConnection(URL, USER, PASSWORD);
        } catch (ClassNotFoundException e) {
            throw new SQLException("No se encontró el driver de PostgreSQL en el proyecto", e);
        }
    }
}